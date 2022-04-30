;============================================================================
; Copyright Tait Electronics Ltd., 2004. All rights reserved.
;
; Program Name: autosilkUtils.il
;
; Author:	Dave Elder, PCB Design Manager,
;		Tait Electronics, Christchurch, New Zealand
;		dave.elder@tait.co.nz
;
; Should work on:	Allegro 15.2 and above
; Fully Tested on:	Allegro 16.2
;
; Purpose:
;	1/ ASU_start - loads user interface form.
;	2/ ASU_copySilkShapesToAutoSilk
;	   - Copies silk shape objects from Board and Package Geometry layers to AutoSilk.
;	   - Checks silk to pin and via soldermask spacings.
;	3/ ASU_checkSpacings
;	   - Check text and shapes for DRCs over soldermask on pins, vias and shapes.
;
; Usage:	To run the routine within Allegro type: "silkutils".
;
; History:
;
;  1.0	02-Sep-03 DE	Re-created for general release.
;  7.0	11-Feb-04 DE	New general release.
;  7.19	20-Jul-04 DE	ICU 2004 CD Release.
;  7.20	27-Jul-04 DE	Update for 15.2.
;  7.27 04-Aug-04 DE	Added Reference Designator check.
;  8.0	06-Aug-04 DE	Added Move Symbol and Right Button Rotate on both move buttons.
;  8.03 01-Sep-04 DE	Pre-ICU 2004 Release 1
;  8.04 02-Sep-04 DE	Pre-ICU 2004 Release 2
;  8.05 03-Sep-04 DE	Pre-ICU 2004 Release 3
;  8.07 03-Sep-04 DE	ICU 2004 Actual demonstration version
;  8.08 27-Sep-04 DE	Fixed windows cancel button crash problem.
;  8.09	05-Oct-04 DE	Fixed bug with line end identification. Enabled trimming of multi-segment lines and arcs.
;  8.10	14-Dec-04 DE	Updated DRCbrowse_getDRCID for integer DRC dbids.
;  8.11	07-Feb-05 DE	Use cancel instead of Quit to ensure that Windows Close button works.
;  8.12	30-Mar-05 DE	Sourcelink Update Release
;  8.13	08-Dec-05 DE	Fixed for shapes with objType "polygon". Minor sklint tidies. Tested in 15.5.
;  8.14 20-Feb-06 DE	Add ability to force move of matching parent text to same location as autosilk.
;  8.15 18-Jan-07 DE	Use findByProperty to ensure select set is cleared/restored
;  8.16	29-Feb-08 DE	Added colorisation of fields if values less than co. defaults. Added buttons to reset to defaults.
;  8.17	04-Apr-08 DE	Added silkparam button to enable user to run the Cadence Silkscreen utility.
;  8.18	09-Feb-09 DE	Added Cut Line option.
;  8.19	11-Feb-09 DE	Tidies.
;  8.20	26-Aug-09 DE	Also select associated objects that do not have a parent - such as board geometry text.
;  8.21	07-Sep-09 DE	Reinstated axlDBRefreshId to refresh associated objects. Seems to be needed.
;  8.22	27-Nov-09 DE	Use AFn_formOpenFile to improve chances that form file is created.
;  8.23	09-Dec-09 DE	Added grid snap option on Evan Shultz's suggestion.
;			Sourcelink Update Release
;
;============================================================================

axlCmdRegister("silkutils" 'ASU_start ?cmdType "interactive")

defun( ASU_start (@optional txtSpacing, shpSpacing, lineSpacing, spacingUnits)
 let((preset, version, release, releaseType, releaseNumber, analyse, unitsList, units, designProperties, artworks, formFile
      p, x, y, grpLen, tabLen, y1, form, defaultFilm, nonCuFilms, filmPairs, vias, viaResist)
  preset = boundp('ASU_thisDesign) && ASU_thisDesign == axlCurrentDesign()
  defvar(ASU_version, 8.23)
  defvar(ASU_versionWarning)
  version = axlVersion('version)
  release = axlVersion('release)
  releaseType = lowerCase(substring(release, 1, 1)), releaseNumber = readNumberString(substring(release, 2))
  cond(
    (version == 15.2 && (releaseType != "s" || releaseNumber < 14)
      ASU_versionWarning = "WARNING: Will not fully work on releases prior to s014"
    )
    (version >= 15.2, ASU_versionWarning = nil)
    (t, ASU_versionWarning = "WARNING: Not been tested for releases prior to 15.2")
  )
  unitsList = AFn_getDesignUnits()
  units = car(unitsList)
  defvar(ASU_designUnits, units)
  defvar(ASU_precision, cadr(unitsList))
  defvar(ASU_spacing)
  ASU_spacing = if(member(units, '("mils", "inches")), axlMKSConvert(10, "mils"), axlMKSConvert(0.25 "mm"))
  unless(txtSpacing, txtSpacing = ASU_spacing)
  if(preset then
    analyse = axlUIYesNo("Re-Analyse Design?")
   else
    analyse = t
    defvar(ASU_thisDesign, axlCurrentDesign())
    defvar(ASU_checktext, t)
    defvar(ASU_checktextloc, t)
    defvar(ASU_quickChk)
    defvar(ASU_checklines, t)
    defvar(ASU_checkshapes, t)
    defvar(ASU_checkPins, t)
    defvar(ASU_solderedpadsChk)
    defvar(ASU_checkVias, t)
    defvar(ASU_checksmShps, t)
    defvar(ASU_shapescopyCheck, t)
    defvar(ASU_shapesCopyIgnoreFixed, t)
    defvar(ASU_checktop, t)
    defvar(ASU_checkbottom, t)
    defvar(ASU_TOPfilm)
    defvar(ASU_BOTTOMfilm)
    defvar(ASU_AUTOSILK)
    defvar(ASU_SILKSCREEN)
    defvar(ASU_ASSEMBLY)
    defvar(ASU_autosilkChkClasses, '("ASU_AUTOSILK", ("MANUFACTURING", t)))
    defvar(ASU_silkChkClasses
      '("ASU_SILKSCREEN", ("BOARD GEOMETRY", t), ("PACKAGE GEOMETRY", t), ("COMP VALUE", t), ("DEV TYPE", t), ("REF DES", t), ("TOLERANCE", t), ("USER PART", t))
    )
    defvar(ASU_assyChkClasses
      '("ASU_ASSEMBLY", ("BOARD GEOMETRY", t), ("PACKAGE GEOMETRY", t), ("COMP VALUE", nil), ("DEV TYPE", nil), ("REF DES", t), ("TOLERANCE", nil), ("USER PART", nil))
    )
    defvar(ASU_subclasses, '("silkscreenlayer", "autosilklayer", "assemblylayer"))
    defvar(ASU_chkSubclass)
    defvar(ASU_soldermaskClasses, '("BOARD GEOMETRY", "PACKAGE GEOMETRY", "PIN", "VIA CLASS"))
    defvar(ASU_userClass)
    defvar(ASU_userSubclass)
    defvar(ASU_drcMsgs)
    defvar(ASU_vectorFontData, AFn_vectorFontData())
  )
  when(analyse
    defvar(ASU_allChkClasses, '("MANUFACTURING")); Required to enable check box if user copies shapes to this Autosilk layer
    ASU_allChkClasses = ASU_analyseDesign(ASU_allChkClasses, ASU_autosilkChkClasses, ASU_silkChkClasses, ASU_assyChkClasses)
  )
  unless(preset, defvar(ASU_tickedClasses, ASU_allChkClasses))
  when(stringp(txtSpacing), txtSpacing = atof(txtSpacing))
  when(stringp(shpSpacing), shpSpacing = atof(shpSpacing))
  when(stringp(lineSpacing), lineSpacing = atof(lineSpacing))
  when(spacingUnits; Required when parsing values from a menu as they are strings.
    txtSpacing = axlMKSConvert(txtSpacing, spacingUnits, units)
    shpSpacing = axlMKSConvert(shpSpacing, spacingUnits, units)
    lineSpacing = axlMKSConvert(lineSpacing, spacingUnits, units)
  )
  defvar(ASU_minSpacing, axlMKSConvert(0.125 "mm"))
  defvar(ASU_defaultTxtSpacing, txtSpacing)
  defvar(ASU_defaultShpSpacing, shpSpacing || txtSpacing)
  defvar(ASU_defaultLineSpacing, lineSpacing || txtSpacing)
  axlDBRefreshId(nil)
  designProperties = axlDBGetDesign() ->prop
  txtSpacing = designProperties ->ASU_TXTSPACING || txtSpacing
  shpSpacing = designProperties ->ASU_SHPSPACING || shpSpacing
  lineSpacing = designProperties ->ASU_LINESPACING || lineSpacing
  when(stringp(txtSpacing), txtSpacing = atof(txtSpacing))
  when(stringp(shpSpacing), shpSpacing = atof(shpSpacing))
  when(stringp(lineSpacing), lineSpacing = atof(lineSpacing))
  unless(shpSpacing, shpSpacing = txtSpacing)
  unless(lineSpacing, lineSpacing = shpSpacing)
  artworks = axlGetParam("artwork") ->groupMembers

  grpLen = 3 + max(length(ASU_allChkClasses), length(ASU_subclasses), 2) * 2
  tabLen = max(40, 29 + grpLen)
  x = 1, y = 0
  p = AFn_formOpenFile()
  formFile = get_filename(p)
  AFn_formHeader(p, 43, sprintf(nil, "Silkscreen Check v%2.2f", ASU_version))
  AFn_formPopupDefine(p, "TOPFILMPOP", '("topfilm"))
  AFn_formPopupDefine(p, "BOTTOMFILMPOP", '("bottomfilm"))
  AFn_formPopupDefine(p, "UCLASS")
  AFn_formPopupDefine(p, "USUBCLASS")
  AFn_formMessage(p, "chkProgress", ?level 0, ?msgString "Checking %s %s...")
  AFn_formMessage(p, "drcsFound", ?level 0, ?msgString "%d DRCs found")
  AFn_formMessage(p, "drcsCreated", ?level 0, ?msgString "%d shapes copied. %d DRCs created")
  AFn_formMessage(p, "shpsCopied", ?level 0, ?msgString "%d shapes copied. No checks performed")
  when(ASU_versionWarning, AFn_formText(p, ASU_versionWarning, x + 1, y ?label "versionwarning"), y = y + 1)
  y = y + 1
  AFn_formThumbnail(p, "taitlogo", x + 37, 0, 5, 3)
  AFn_formTabSetDispatch(p, x, y, 42, tabLen)
  AFn_formTab(p, "Setup"), y = 1
  AFn_formButton(p, "silkparam", "Setup Cadence Silkscreen", x + 2, y, 30, 3)
  AFn_formButton(p, "silkparamHelp", "?", x + 33, y, 3, 3), y = y + 2
  AFn_formGroup(p, "Spacing Constraints", x, y, 39, 14)
  y = y + 2, AFn_formChecklistItem(p, "text", x + 2, y, "Text Spacing")
  AFn_formButton(p, "txtspcdefault", "D", x + 16, y, 3, 3)
  AFn_formRealFillin(p, "txtspc", 6, 6, x + 19, y, ?value txtSpacing, ?decimalPlaces ASU_precision, ?minVal 0, ?units units)
  AFn_formButton(p, "txtspcHelp", "?", x + 33, y, 3, 3)
  y = y + 2, AFn_formChecklistItem(p, "quickchk", x + 6, y, "Faster Text Check")
  AFn_formButton(p, "quickchkHelp", "?", x + 33, y, 3, 3)
  y = y + 2, AFn_formChecklistItem(p, "shapes", x + 2, y, "Shape Spacing")
  AFn_formButton(p, "shpspcdefault", "D", x + 16, y, 3, 3)
  AFn_formRealFillin(p, "shpspc", 6, 6, x + 19, y, ?value shpSpacing, ?decimalPlaces ASU_precision, ?minVal 0, ?units units)
  AFn_formButton(p, "shpspcHelp", "?", x + 33, y, 3, 3)
  y = y + 2, AFn_formChecklistItem(p, "lines", x + 2, y, "Line Spacing")
  AFn_formButton(p, "linespcdefault", "D", x + 16, y, 3, 3)
  AFn_formRealFillin(p, "linespc", 6, 6, x + 19, y, ?value lineSpacing, ?decimalPlaces ASU_precision, ?minVal 0, ?units units)
  AFn_formButton(p, "linespcHelp", "?", x + 33, y, 3, 3)
  
  y = y + 3, AFn_formChecklistItem(p, "textloc", x + 2, y, "Reference Designator Locations")
  AFn_formButton(p, "textlocHelp", "?", x + 33, y, 3, 3)
  
  y = y + 3, AFn_formGroup(p, "Solder Mask Objects to be Checked", x, y, 39, 11)
  y = y + 2, AFn_formChecklistItem(p, "pins", x + 2, y, "Check to Solder Mask Pads on Pads")
  AFn_formButton(p, "pinsHelp", "?", x + 33, y, 3, 3)
  y = y + 2, AFn_formChecklistItem(p, "solderedpads", x + 6, y, "Check to Soldered Pads Only")
  AFn_formButton(p, "solderedpadsHelp", "?", x + 33, y, 3, 3)

  y = y + 2, AFn_formChecklistItem(p, "vias", x + 2, y, "Check to Solder Mask Pads on Vias")
  AFn_formButton(p, "viasHelp", "?", x + 33, y, 3, 3)
  y = y + 2, AFn_formChecklistItem(p, "smShps", x + 2, y, "Check to Solder Mask Shapes")
  AFn_formButton(p, "smShpsHelp", "?", x + 33, y, 3, 3)

  y = y + 3, AFn_formGroup(p, "AutoSilk Layers Shapes Copying", x, y, 39, if(isCallable('axlDBIgnoreFixed), 9, 7))
  y = y + 2, AFn_formChecklistItem(p, "shapescopyCheck", x + 2, y, "Check Spacings on objects selected above")
  when(isCallable('axlDBIgnoreFixed)
    y = y + 2, AFn_formChecklistItem(p, "shapescopyignorefixed", x + 6, y, "Ignore fixed status")
    AFn_formButton(p, "ignorefixedHelp", "?", x + 33, y, 3, 3)
  )
  y = y + 2, AFn_formButton(p, "copy", "Copy Geometry Layer Shapes to AutoSilk", x + 2, y, 30, 3)
  AFn_formEndTab(p)
  
  AFn_formTab(p, "Check"), y = 0
  when(axlGetParam("artwork") && sort(copy(artworks), nil) != '("BOTTOM" "TOP")
    AFn_formGroup(p, "Use Films", x, y, 38, 9)
    y = y + 2, AFn_formChecklistItem(p, "usefilms", x + 1, y, "Use films to determine checked layers" ?radioLabel "chktype")
    y = y + 2, AFn_formText(p, "Top:", x + 1, y), AFn_formPop(p, "TOPfilm", "TOPFILMPOP", x + 9, y, 20)
    y = y + 2, AFn_formText(p, "Bottom:", x + 1, y), AFn_formPop(p, "BOTTOMfilm", "BOTTOMFILMPOP", x + 9, y, 20)
    y++
  )
  y = y + 2, AFn_formGroup(p, "Use Silk Layers", x, y, 38, grpLen + 5); 4
  y = y + 2
  AFn_formChecklistItem(p, "usesilk", x + 1, y, "Auto suggested layer selection" ?radioLabel "chktype")
  y = y + 1, y1 = y
  AFn_formGroup(p, "Classes", x + 1, y1, 21, 2 + length(ASU_allChkClasses) * 2)
  foreach(chkClass, ASU_allChkClasses, y1 = y1 + 2, AFn_formChecklistItem(p, chkClass, x + 2, y1, axlPPrint(chkClass)))
  AFn_formGroup(p, "Subclasses", x + 23, y, 14, 2 + length(ASU_subclasses) * 2)
  foreach(subclass, ASU_subclasses
    y = y + 2, AFn_formChecklistItem(p, subclass, x + 24, y, axlPPrint(substring(subclass, 1, strlen(subclass) - 5)) ?radioLabel "chklayer")
  )

  y = max(y1, y) + 2
  AFn_formText(p, "Check sides:", x + 2, y)
  AFn_formChecklistItem(p, "checktop", x + 14, y, "Top")
  AFn_formChecklistItem(p, "checkbottom", x + 22, y, "Bottom")
  
  y = y + 3, AFn_formGroup(p, "User selection", x, y, 38, 9)
  y = y + 2, AFn_formChecklistItem(p, "useother", x + 1, y, "Select user layer to check" ?radioLabel "chktype")
  y = y + 2, AFn_formText(p, "Class:", x + 1, y), AFn_formPop(p, "userclass", "UCLASS", x + 9, y, 20)
  y = y + 2, AFn_formText(p, "Subclass:", x + 1, y)
  AFn_formPop(p, "usersubclass", "USUBCLASS", x + 9, y, 20 ?options "ownerdrawn")
  y = y + 4, AFn_formButton(p, "checkWindow", "Check in Window", x + 3, y, 15, 3)
  AFn_formButton(p, "checkAll", "Check All", x + 22, y, 15, 3)
  AFn_formEndTab(p)
  AFn_formEndTabSet(p)
  y = tabLen + 3
  AFn_formButton(p, "viewLog", "View Log", x + 2, y, 9, 3)
  AFn_formButton(p, "cancel", "Close", x + 15, y, 9, 3)
  AFn_formButton(p, "asuhelp", "Help", x + 28, y, 9, 3)
  AFn_formEnd(p)
  axlDMClose(p)
  
  defvar(ASU_startForm, axlFormCreate('form, formFile, '(E INNER), 'ASU_formAction, nil))
  axlGRPDrwInit(form, "taitlogo", 'tait_logoThumbnail)
  when(ASU_versionWarning && substring(ASU_versionWarning, 1, 7) == "WARNING"
    axlFormColorize(form, "versionwarning", 'text, 'red)
  )
  ASU_setSpacingBackgroundColours(form)
  axlFormSetField(form, "quickchk", ASU_quickChk)
  axlFormSetField(form, "solderedpads", ASU_solderedpadsChk)
  axlFormSetField(form, "shapescopyCheck", ASU_shapescopyCheck)
  unless(ASU_shapescopyCheck, axlFormSetFieldEditable(form, "shapescopyignorefixed", 0))
  if(ASU_checkPins then axlFormSetField(form, "pins", t) else axlFormSetFieldEditable(form, "solderedpads", 0))
  vias = findTypeObjects("VIAS")
  foreach(side, '("TOP", "BOTTOM")
    while(!viaResist && vias
      when(axlDBGetPad(car(vias), strcat("PIN/SOLDERMASK_", side), "REGULAR"), viaResist = t)
      vias = cdr(vias)
    )
  )
  if(viaResist then when(ASU_checkVias, axlFormSetField(form, "vias", t)) else axlFormSetFieldEditable(form, "vias", 0))
  if(ASU_getGeometryObjects("SOLDERMASK", "SHAPES")
   then when(ASU_checksmShps, axlFormSetField(form, "smShps", t))
   else axlFormSetFieldEditable(form, "smShps", 0)
  )
  axlFormSetField(form, "shapescopyignorefixed", ASU_shapesCopyIgnoreFixed)

  foreach(side, '("TOP", "BOTTOM")
    defaultFilm = car(setof(f, artworks, setof(l, axlGetParam(strcat("artwork:", f)) ->groupMembers, index(l, strcat("_", side)) && index(l, "SILK"))))
    nonCuFilms = setof(f, artworks, !index(buildString(axlGetParam(strcat("artwork:", f)) ->groupMembers), "ETCH/"))
    filmPairs = cons('("", ""), mapcar(lambda((filmName), list(filmName, filmName)), nonCuFilms))
    axlFormBuildPopup(form, strcat(side, "FILMPOP"), filmPairs)
    defaultFilm = eval(stringToSymbol(strcat("ASU_", side, "film"))) || defaultFilm
    when(defaultFilm
      axlFormSetField(form, strcat(side, "film"), defaultFilm)
      unless(boundp('ASU_useFilms) && !ASU_useFilms, axlFormSetField(form, "usefilms", t), defvar(ASU_useFilms, t))
    )
  )
  axlFormBuildPopup(form, "UCLASS", '("MANUFACTURING" "BOARD GEOMETRY" "PACKAGE GEOMETRY"))
  cond(
    (ASU_AUTOSILK != '(nil, nil, nil) && (!ASU_chkSubclass || ASU_chkSubclass == "autosilklayer")
      axlFormSetField(form, "autosilklayer", t)
      ASU_chkSubclass = "autosilklayer"
      ASU_setChkClasses(form, ASU_autosilkChkClasses)
    )
    (ASU_SILKSCREEN != '(nil, nil, nil) && (!ASU_chkSubclass || ASU_chkSubclass == "silkscreenlayer")
      axlFormSetField(form, "silkscreenlayer", t)
      ASU_chkSubclass = "silkscreenlayer"
      ASU_setChkClasses(form, ASU_silkChkClasses)
    )
    (ASU_ASSEMBLY != '(nil, nil, nil) && (!ASU_chkSubclass || ASU_chkSubclass == "assemblylayer")
      axlFormSetField(form, "assemblylayer", t)
      ASU_chkSubclass = "assemblylayer"
      ASU_setChkClasses(form, ASU_assyChkClasses)
    )
  )
  axlFormSetField(form, "checktop", ASU_checktop)
  axlFormSetField(form, "checkbottom", ASU_checkbottom)

  cond(
    (and(boundp('ASU_useFilms), ASU_useFilms), axlFormSetField(form, "usefilms", t))
    (and(boundp('ASU_useSilk), ASU_useSilk), axlFormSetField(form, "usesilk", t))
    (and(boundp('ASU_useOther), ASU_useOther), axlFormSetField(form, "useother", t))
    (ASU_chkSubclass, defvar(ASU_useSilk, t), axlFormSetField(form, "usesilk", t))
    (t, defvar(ASU_useOther, t), axlFormSetField(form, "useother", t))
  )

  unless(axlFormGetField(form, "usefilms")
    foreach(field, '("TOPfilm", "BOTTOMfilm"), axlFormSetFieldEditable(form, field, 0))
  )
  unless(axlFormGetField(form, "usesilk")
    foreach(field, append(ASU_allChkClasses, ASU_subclasses), axlFormSetFieldEditable(form, field, 0))
    foreach(field, '("checktop", "checkbottom"), axlFormSetFieldEditable(form, field, 0))
  )
  when(ASU_userClass
    axlFormSetField(form, "userclass", ASU_userClass)
    axlSubclassFormPopup(form, "usersubclass", ASU_userClass, nil)
  )
  when(ASU_userSubclass, axlFormSetField(form, "usersubclass", ASU_userSubclass))
  unless(axlFormGetField(form, "useother")
    foreach(field, '("userclass", "usersubclass"), axlFormSetFieldEditable(form, field, 0))
  )
  axlFormSetFieldEditable(form, "viewLog", 0)
  axlFormDisplay(form)
  deleteFile(formFile)
))

defun( ASU_analyseDesign (allChkClasses, autosilkChkClasses, silkChkClasses, assemblyChkClasses)
 let((nLayers, subclassPrefix, typeText, typeShapes, typeLines, class, classVar, text, shapes, lines, layers, (layN 0))
  axlMeterCreate("Design Analysis" "Analysing..." t)
  rexCompile(" ")
  nLayers = (length(autosilkChkClasses) - 1 + length(silkChkClasses) - 1 + length(assemblyChkClasses) - 1) * 2
  foreach(chkList, list(autosilkChkClasses, silkChkClasses, assemblyChkClasses)
    subclassPrefix = substring(car(chkList), 5)
    set(stringToSymbol(subclassPrefix), nil)
    typeText = typeShapes = typeLines = nil
    foreach(classChk, cdr(chkList)
      class = car(classChk)
      classVar = rexReplace(class, "_", 0)
      text = shapes = lines = nil
      when(axlGetParam(strcat("paramLayerGroup:", class)) ->groupMembers
	layers = list(strcat(class, "/", subclassPrefix, "_TOP"), strcat(class, "/", subclassPrefix, "_BOTTOM"))
	axlMeterUpdate(layN * 200 / nLayers , strcat("Analysing ", class, "/", subclassPrefix, " objects..."))
	when(findTypeObjects("TEXT", ?layers layers), text = t, typeText = t)
	when(findTypeObjects("SHAPES", ?layers layers), shapes = t, typeShapes = t)
	when(findTypeObjects("LINES", ?layers layers), lines = t, typeLines = t)
	and((text || shapes || lines), !member(classVar, allChkClasses), allChkClasses = append1(allChkClasses, classVar))
      )
      layN++
    )
    set(stringToSymbol(strcat("ASU_", subclassPrefix)), list(typeText, typeShapes, typeLines))
  )
  axlMeterDestroy()
  allChkClasses
))

defun( ASU_formAction (form)
 let((curField, value, shpSpacing, txtSpacing, lineSpacing, chkClasses, nShps)
  curField = form ->curField
  value = form ->curValue
  shpSpacing = axlFormGetField(form, "shpspc")
  txtSpacing = axlFormGetField(form, "txtspc")
  lineSpacing = axlFormGetField(form, "linespc")
  unless(member(curField, ASU_subclasses)
    ASU_tickedClasses = setof(chkClass, ASU_allChkClasses, axlFormGetField(form, chkClass))
  )
  cond(
    (axlFormGetField(form, "silkscreenlayer"), chkClasses = ASU_silkChkClasses)
    (axlFormGetField(form, "autosilklayer"), chkClasses = ASU_autosilkChkClasses)
    (axlFormGetField(form, "assemblylayer"), chkClasses = ASU_assyChkClasses)
    (t, chkClasses = ASU_autosilkChkClasses)
  )
  case(curField
    ("silkparam", axlShellPost("silkscreen param"), axlFormClose(form), axlCancelEnterFun())
    ("silkparamHelp", ASU_helpDisplay("Cadence Silkscreen Setup"))
    ("text", ASU_setChkClasses(form, chkClasses, t), ASU_checktext = value, axlFormSetFieldEditable(form, "quickchk", if(value, 1, 0)))
    ("txtspcdefault"
      axlFormSetField(form, "txtspc", ASU_defaultTxtSpacing)
      ASU_setSpacingProps(form, txtSpacing, shpSpacing, lineSpacing)
    )
    ("txtspc", ASU_setSpacingProps(form, txtSpacing, shpSpacing, lineSpacing))
    ("txtspcHelp", ASU_helpDisplay("Text Spacing"))
    ("quickchk", ASU_quickChk = value)
    ("quickchkHelp", ASU_helpDisplay("Faster Text Check"))
    ("shapes", ASU_setChkClasses(form, chkClasses, t), ASU_checkshapes = value)
    ("shpspcdefault"
      axlFormSetField(form, "shpspc", ASU_defaultShpSpacing)
      ASU_setSpacingProps(form, txtSpacing, shpSpacing, lineSpacing)
    )
    ("shpspc", ASU_setSpacingProps(form, txtSpacing, shpSpacing, lineSpacing))
    ("shpspcHelp", ASU_helpDisplay("Shape Spacing"))
    ("lines", ASU_setChkClasses(form, chkClasses, t), ASU_checklines = value)
    ("linespcdefault"
      axlFormSetField(form, "linespc", ASU_defaultLineSpacing)
      ASU_setSpacingProps(form, txtSpacing, shpSpacing, lineSpacing)
    )
    ("linespc", ASU_setSpacingProps(form, txtSpacing, shpSpacing, lineSpacing))
    ("linespcHelp", ASU_helpDisplay("Line Spacing"))
    ("textloc", ASU_checktextloc = value)
    ("textlocHelp", ASU_helpDisplay("Reference Text Locations"))
    ("pins", ASU_checkPins = value, axlFormSetFieldEditable(form, "solderedpads", if(value, 1, 0)))
    ("pinsHelp", ASU_helpDisplay("Pin Pads"))
    ("solderedpads", ASU_solderedpadsChk = value)
    ("solderedpadsHelp", ASU_helpDisplay("Soldered Pads Only"))
    ("vias", ASU_checkVias = value)
    ("viasHelp", ASU_helpDisplay("Vias"))
    ("smShps", ASU_checksmShps = value)
    ("smShpsHelp", ASU_helpDisplay("Shapes"))
    
    ("shapescopyCheck", ASU_shapescopyCheck = value, axlFormSetFieldEditable(form, "shapescopyignorefixed", if(value, 1, 0)))
    ("shapescopyignorefixed", ASU_shapesCopyIgnoreFixed = value)
    ("ignorefixedHelp", ASU_helpDisplay("Ignore Fixed Status Option"))
    
    ("copy"
      nShps = ASU_copySilkShapesToAutoSilk(form, shpSpacing)
      when(nShps > 0 && !axlFormIsFieldEditable(form, "shapes")
	axlFormSetFieldEditable(form, "shapes", 1)
	axlFormSetField(form, "shapes", t)
	ASU_checkshapes = t
      )
      axlFormSetFieldEditable(form, "viewLog", 1)
    )
    ("usefilms", ASU_setChkFields(form))
    ("usesilk", ASU_setChkFields(form))
    ("useother", ASU_setChkFields(form))

    ("TOPfilm", ASU_TOPfilm = axlFormGetField(form, "TOPfilm"))
    ("BOTTOMfilm", ASU_BOTTOMfilm = axlFormGetField(form, "BOTTOMfilm"))
    
    ("silkscreenlayer", ASU_chkSubclass = "silkscreenlayer", ASU_setChkClasses(form, ASU_silkChkClasses, t))
    ("autosilklayer", ASU_chkSubclass = "autosilklayer", ASU_setChkClasses(form, ASU_autosilkChkClasses, t))
    ("assemblylayer", ASU_chkSubclass = "assemblylayer", ASU_setChkClasses(form, ASU_assyChkClasses, t))
    ("userclass"
      axlSubclassFormPopup(form, "usersubclass", axlFormGetField(form, "userclass"), nil)
      ASU_userClass = axlFormGetField(form, "userclass")
    )
    ("usersubclass", ASU_userSubclass = axlFormGetField(form, "usersubclass"))
    ("checktop", ASU_checktop = axlFormGetField(form, "checktop"))
    ("checkbottom", ASU_checkbottom = axlFormGetField(form, "checkbottom"))
    ("checkWindow"
      ASU_checkSpacings(form, t, txtSpacing, shpSpacing, lineSpacing, ASU_checkshapes, ASU_checktext, ASU_checklines, ASU_checkPins, ASU_checkVias, ASU_checksmShps, ASU_solderedpadsChk, ASU_checktextloc)
      axlFormSetFieldEditable(form, "viewLog", 1)
    )
    ("checkAll"
      ASU_checkSpacings(form, nil, txtSpacing, shpSpacing, lineSpacing, ASU_checkshapes, ASU_checktext, ASU_checklines, ASU_checkPins, ASU_checkVias, ASU_checksmShps, ASU_solderedpadsChk, ASU_checktextloc)
      axlFormSetFieldEditable(form, "viewLog", 1)
    )
    ("viewLog", ASU_showLog(ASU_drcMsgs))
    ("asuhelp", ASU_helpDisplay())
    ("cancel"
      axlFormClose(form)
      axlCancelEnterFun()
    )
  )
  unless(curField == "cancel"
    value = ASU_checktextloc || ((ASU_checkshapes || ASU_checktext || ASU_checklines) && (ASU_checkPins || ASU_checkVias || ASU_checksmShps))
    foreach(field, '("checkWindow", "checkAll"), axlFormSetFieldEditable(form, field, if(value, 1, 0)))
  )
))

defun( ASU_setChkFields (form)
  defvar(ASU_useFilms, axlFormGetField(form, "usefilms"))
  defvar(ASU_useSilk, axlFormGetField(form, "usesilk"))
  defvar(ASU_useOther, axlFormGetField(form, "useother"))
  cond(
    (ASU_useFilms
      foreach(field, '("TOPfilm", "BOTTOMfilm"), axlFormSetFieldEditable(form, field, 1))
      foreach(field, append(ASU_allChkClasses, ASU_subclasses), axlFormSetFieldEditable(form, field, 0))
      foreach(field, '("userclass", "usersubclass", "checktop", "checkbottom"), axlFormSetFieldEditable(form, field, 0))
    )
    (ASU_useSilk
      foreach(field, '("TOPfilm", "BOTTOMfilm", "userclass", "usersubclass"), axlFormSetFieldEditable(form, field, 0))
      foreach(field, ASU_subclasses, axlFormSetFieldEditable(form, field, 1))
      foreach(field, '("checktop", "checkbottom"), axlFormSetFieldEditable(form, field, 1))
      cond(
	(axlFormGetField(form, "silkscreenlayer"), ASU_setChkClasses(form, ASU_silkChkClasses, t))
	(axlFormGetField(form, "autosilklayer"), ASU_setChkClasses(form, ASU_autosilkChkClasses, t))
	(axlFormGetField(form, "assemblylayer"), ASU_setChkClasses(form, ASU_assyChkClasses, t))
      )
    )
    (ASU_useOther
      foreach(field, append(ASU_allChkClasses, ASU_subclasses), axlFormSetFieldEditable(form, field, 0))
      foreach(field, '("TOPfilm", "BOTTOMfilm", "checktop", "checkbottom"), axlFormSetFieldEditable(form, field, 0))
      foreach(field, '( "userclass", "usersubclass"), axlFormSetFieldEditable(form, field, 1))
    )
  )
)
    
defun( ASU_setSpacingProps (form, txtSpacing, shpSpacing, lineSpacing)
 let((design)
  design = axlDBGetDesign()
  foreach(propName, '("ASU_TXTSPACING", "ASU_SHPSPACING", "ASU_LINESPACING")
    unless(axlDBGetPropDictEntry(propName), axlDBCreatePropDictEntry(propName, "REAL", "DESIGNS"))
  )
  axlDBAddProp(design, list("ASU_TXTSPACING", txtSpacing))
  axlDBAddProp(design, list("ASU_SHPSPACING", shpSpacing))
  axlDBAddProp(design, list("ASU_LINESPACING", lineSpacing))
  ASU_setSpacingBackgroundColours(form)
))

defun( ASU_setSpacingBackgroundColours (form)
 let((spc)
  spc = axlFormGetField(form, "txtspc")
  axlFormColorize(form, "txtspc", 'background, cond((spc < ASU_minSpacing, 'red)(spc < ASU_defaultTxtSpacing, 'yellow)))
  spc = axlFormGetField(form, "shpspc")
  axlFormColorize(form, "shpspc", 'background, cond((spc < ASU_minSpacing, 'red)(spc < ASU_defaultShpSpacing, 'yellow)))
  spc = axlFormGetField(form, "linespc")
  axlFormColorize(form, "linespc", 'background, cond((spc < ASU_minSpacing, 'red)(spc < ASU_defaultLineSpacing, 'yellow)))
))

defun( ASU_helpDisplay (@optional topic)
 let((helpTxts)
  helpTxts = list(
    '("This utility should work for PSD14.2 through to SPB16.3")
    '("Setup Tab")
    '("Cadence Silkscreen Setup", "Equivalent to selecting 'Silkscreen...' in the Manufacturing menu.")
    '("Spacing Constraints:")
	list("Text Spacing"
		"Spacing from each text string character to a solder mask object."
		sprintf(nil, "Use the \"D\" button to reset this value to the company default (%g%s)", ASU_defaultTxtSpacing, ASU_designUnits)
	)
	'("Faster Text Check", "Check using a bounding box around the whole \"word\" rather than each vectorised character.")
	list("Shape Spacing"
		"Spacing from a shape to a solder mask object."
		sprintf(nil, "Use the \"D\" button to reset this value to the company default (%g%s)", ASU_defaultShpSpacing, ASU_designUnits)
	)
	list("Line Spacing"
		"Spacing from a line to a solder mask object. Can be quite slow."
		sprintf(nil, "Use the \"D\" button to reset this value to the company default (%g%s)", ASU_defaultLineSpacing, ASU_designUnits)
	)
	'("Reference Text Locations"
		"Check that each reference designator is closest to its own parent symbol."
		"Checks components of the same class only."
	)
	'("Note:", "These values are maintained between sessions\n")
    '("Solder Mask Objects to be Checked:")
	'("Pin Pads", "Select this check box to check objects against solder mask pads on pin pads")
	'("Soldered Pads Only"
		"Select this check box to only check objects against solder mask pads on soldered pins."
		"This will exclude pads on the non-soldered side of a leaded device."
	)
	'("Vias", "Select this check box to check objects against solder mask pads on vias")
	'("Shapes", "Select this check box to check objects against solder mask shapes")
    '("AutoSilk Layers Shapes Copying:")
	'("Check Spacings button", "Perform drc checks on the Soldermask objects selected in the above group")
	'("Ignore Fixed Status Option"
		"Ignores the fixed status of objects or their parents when copying shapes"
		"(by deleting any existing AutoSilk layer shapes and replacing them)."
	)
    	'("Copy button"
    		"Copy BOARD GEOMETRY and/or PACKAGE GEOMETRY silkscreen shapes to the AutoSilk layers."
		"Useful for pin 1 markers etc."
	)
    '("Check tab")
	'("Use Films:")
		'("Use Films to determine layers to check", "Selected by default if one or more films containing a silk layer is found")
	'("Use Silk Layers:")
		'("Auto suggested layer selection", "Selected based on existance of objects on these layers")
		'("Classes", "Only class/subclass combinations with spacing rules objects present are selectable")
		'("Subclasses", "Only one subclass, that has spacing rules objects present, is selectable")
		'("Check sides", "Only check the sides that have been selected")
    '("User Selection:")
	'("Class", "User selectable class")
	'("Subclass", "User selectable legal subclass for the selected class")
    '("Checking:")
	'("Check in Window button", "Start checking in the current window.")
	'("Check All button", "Start checking. This may take a several minutes on a large design")
    '("General:")
    	'("View Log button", "View the list of DRCs created")
    	'("Quit button", "Quit this utility")
    	'("Help button", "Display this file")
    '("Support:")
	'("Feedback", "This utility is unsupported. However feedback is invited and appreciated.")
	'("Author", "Dave Elder, dave.elder@tait.co.nz")
  )
  AFn_displayHelpText("Silkscreen Utilities Help Information", helpTxts, topic)
))

defun( ASU_setChkClasses (form, classes @optional layersOnly)
 let((objectsExist, subclassPrefix, objTypes, class, ticked, layers)
  unless(layersOnly
    when(classes, objectsExist = eval(stringToSymbol(car(classes))))
    ASU_toggleField(form, "text", car(objectsExist))
    ASU_toggleField(form, "textloc", car(objectsExist))
    ASU_toggleField(form, "shapes", cadr(objectsExist))
    ASU_toggleField(form, "lines", caddr(objectsExist))
  )
  foreach(chkClass, ASU_allChkClasses
    axlFormSetField(form, chkClass, nil)
    axlFormSetFieldEditable(form, chkClass, 0)
  )
  subclassPrefix = substring(car(classes), 5)
  when(axlFormGetField(form, "text") || axlFormGetField(form, "textloc"), objTypes = cons("TEXT", objTypes))
  when(axlFormGetField(form, "shapes"), objTypes = cons("SHAPES", objTypes))
  when(axlFormGetField(form, "lines"), objTypes = cons("LINES", objTypes))
  rexCompile(" ")
  foreach(item, cdr(classes)
    class = car(item), ticked = cadr(item)
    layers = mapcar(lambda((side) strcat(class, "/", subclassPrefix, "_", side)) '("TOP", "BOTTOM"))
    layers = setof(layer, layers, axlIsLayer(layer))
    when(findTypeObjects(objTypes, ?layers layers)
      class = rexReplace(class, "_", 0)
      unless(axlFormGetField(form, "usefilms"), axlFormSetFieldEditable(form, class, 1))
      and(ticked, member(class, ASU_tickedClasses), axlFormSetField(form, class, t))
    )
  )
  ASU_tickedClasses = ASU_allChkClasses
))

defun( ASU_toggleField (form, field, flag)
  if(flag
   then when(eval(stringToSymbol(strcat("ASU_check", field))), axlFormSetField(form, field, t))
   else axlFormSetField(form, field, nil)
  )
)

defun( ASU_checkSpacings (@optional form, window, (txtSpacing, ASU_spacing)
  shpSpacing, lineSpacing, (shpChk, t) (txtChk, t) (lineChk, t) (pinChk, t) (viaChk, t) (smShpChk, t) (solderedPadsOnlyChk, nil) (refdesLocChk t))
 let((chkTypes, useFilms, (checkTop t), (checkBottom t), filmName, topLayers, bottomLayers, chkClassInfo
      chkClasses, subclassPrefix, class, sides, ndrcs, chkLayer, userLayer, drcMsgs, visibleLayers)
  unless(shpSpacing, shpSpacing = txtSpacing)
  unless(lineSpacing, lineSpacing = shpSpacing)
  chkTypes = setof(objType, list(list(shpChk, "SHAPES", shpSpacing), list(txtChk || refdesLocChk, "TEXT", txtSpacing), list(lineChk, "LINES", lineSpacing)), car(objType))
  if(form then
    useFilms = axlFormGetField(form, "usefilms")
    checkTop = axlFormGetField(form, "checktop")
    checkBottom = axlFormGetField(form, "checkbottom")
    cond(
      (useFilms
	filmName = axlFormGetField(form, "TOPfilm")
	when(filmName != "" && filmName != "0", topLayers = axlGetParam(strcat("artwork:", filmName)) ->groupMembers)
	filmName = axlFormGetField(form, "BOTTOMfilm")
	when(filmName != "" && filmName != "0", bottomLayers = axlGetParam(strcat("artwork:", filmName)) ->groupMembers)
      )
      (axlFormGetField(form, "useother")
        userLayer = strcat(axlFormGetField(form, "userclass"), "/", axlFormGetField(form, "usersubclass"))
      )
      (axlFormGetField(form, "silkscreenlayer"), chkClassInfo = ASU_silkChkClasses)
      (axlFormGetField(form, "autosilklayer"), chkClassInfo = ASU_autosilkChkClasses)
      (axlFormGetField(form, "assemblylayer"), chkClassInfo = ASU_assyChkClasses)
    )
   else chkClassInfo = ASU_autosilkChkClasses
  )
  removeExternalDRCs()
  ndrcs = axlDRCGetCount()
  visibleLayers = axlVisibleGet()
  cond(
    (useFilms
      drcMsgs = ASU_checkObjTypes(form, window, append(topLayers, bottomLayers), chkTypes, pinChk, viaChk, smShpChk, solderedPadsOnlyChk, refdesLocChk)
    )
    (userLayer, drcMsgs = ASU_checkObjTypes(form, window, userLayer, chkTypes, pinChk, viaChk, smShpChk, solderedPadsOnlyChk, refdesLocChk))
    (t
      when(checkBottom, sides = '("BOTTOM"))
      when(checkTop, sides = cons("TOP", sides))
      subclassPrefix = substring(car(chkClassInfo), 5), chkClasses = cdr(chkClassInfo)
      foreach(item, chkClasses
	class = car(item)
	rexCompile(" ")
	when((form && axlFormGetField(form, rexReplace(class, "_", 0))) || !form
	  foreach(side, sides
	    chkLayer = strcat(class, "/", subclassPrefix, "_" side)
	    drcMsgs = append(drcMsgs, ASU_checkObjTypes(form, window, chkLayer, chkTypes, pinChk, viaChk, smShpChk, solderedPadsOnlyChk, refdesLocChk))
	  )	
	)
      )
    )
  )
  axlVisibleSet(visibleLayers)
  ndrcs = axlDRCGetCount() - ndrcs
  if(form then axlFormMsg(form, "drcsFound", ndrcs) else axlUIConfirm(sprintf(nil, "%d DRCs found", ndrcs)))
  ASU_drcMsgs = drcMsgs
  unless(zerop(ndrcs), DRCbrowse_createForm())
))

defun( ASU_checkObjTypes (form, window, chkLayers, chkTypes, pinChk, viaChk, smShpChk, solderedPadsOnlyChk, refdesLocChk)
 let((txtChk, side, smLayer, drcLayer, spacing, drcMsgs)
  unless(listp(chkLayers), chkLayers = list(chkLayers))
  defvar(ASU_window)
  when(window, ASU_window = axlWindowBoxGet())
  txtChk = axlFormGetField(form, "text")
  when(txtChk && axlFormGetField(form, "quickchk"), txtChk = "QUICK")
  foreach(layer, chkLayers
    unless(axlIsVisibleLayer(layer), axlVisibleLayer(layer, t))
    side = ASU_getLayerSide(layer)
    foreach(layerPrefix, '("BOARD GEOMETRY/SOLDERMASK_", "PACKAGE GEOMETRY/SOLDERMASK_")
      smLayer = strcat(layerPrefix, side)
      unless(axlIsVisibleLayer(smLayer), axlVisibleLayer(smLayer, t))
    )
  )
  foreach(layer, chkLayers
    drcLayer = strcat("DRC ERROR CLASS/", ASU_getLayerSide(layer))
    foreach(objType, chkTypes
      axlFormMsg(form, "chkProgress", lowerCase(layer), lowerCase(cadr(objType)))
      foreach(obj, findTypeObjects(cadr(objType), ?layers layer, ?bbox ASU_window)
	spacing = caddr(objType)
	drcMsgs = append(drcMsgs, ASU_checkObj(obj, spacing, drcLayer, pinChk, viaChk, smShpChk, solderedPadsOnlyChk, txtChk, refdesLocChk))
      )
    )
  )
  drcMsgs
))

defun( ASU_copySilkShapesToAutoSilk (form, spacing)
 let((layers, ndrcs, class, drcLayer, layer, parent, poly, parentGroups, oShp, (nShps 0), drcMsgs)
  unless(spacing, spacing = getUINumber("Spacing", ASU_spacing, 0))
  when(spacing
    removeExternalDRCs()
    layers = '("MANUFACTURING/AUTOSILK_TOP" "MANUFACTURING/AUTOSILK_BOTTOM")
    ;axlDeleteObject(setof(shp, findTypeObjects("SHAPES", ?layers layers, ?attrPairs list('fill t)), !axlDBIsFixed(shp)))
    when(ASU_shapesCopyIgnoreFixed, axlDBIgnoreFixed(t))
    axlDeleteObject(findTypeObjects("SHAPES", ?layers layers, ?attrPairs list('fill t)))
    when(ASU_shapesCopyIgnoreFixed, axlDBIgnoreFixed(nil))
    ndrcs = axlDRCGetCount()
    foreach(item, cdr(ASU_silkChkClasses)
      class = car(item)
      foreach(side, '("TOP", "BOTTOM")
	drcLayer = strcat("DRC ERROR CLASS/", side)
	layer = strcat("MANUFACTURING/AUTOSILK_", side)
	foreach(shp, findTypeObjects("SHAPES", ?layers strcat(class, "/SILKSCREEN_", side), ?attrPairs list('fill t))
	  parent = shp ->parent, parentGroups = shp ->parentGroups
	  and(
	    poly = car(axlPolyFromDB(shp))
	    ;Check that a shape does not already exist here: (as will happen with fixed shapes)
	    !setof(subShp, parent ->children
	      and(
		subShp ->layer == layer
		(subShp ->objType == "shape" || subShp ->objType == "polygon")
		axlPolyOperation(poly, car(axlPolyFromDB(subShp)), 'AND)
	      )
	    )
	    oShp = axlDBCreateOpenShape(poly, t, strcat("MANUFACTURING/AUTOSILK_", side), nil, parent)
	    shp = car(axlDBCreateCloseShape(oShp))
	    ++nShps
	    foreach(grp, parentGroups, axlDBAddGroupObjects(grp, shp))
	  )
	  and(shp, ASU_shapescopyCheck
	    drcMsgs = append(drcMsgs, ASU_checkObj(shp, spacing, drcLayer, ASU_checkPins, ASU_checkVias, ASU_checksmShps, ASU_solderedpadsChk))
	  )
	)
      )
    )
    ndrcs = axlDRCGetCount() - ndrcs
    if(ASU_shapescopyCheck then
      ASU_drcMsgs = drcMsgs
      if(form
       then axlFormMsg(form, "drcsCreated", nShps, ndrcs)
       else axlUIConfirm(sprintf(nil, "%d shapes copied. %d DRCs created", nShps, ndrcs))
      )
      unless(zerop(ndrcs), DRCbrowse_createForm())
     else
      if(form
       then axlFormMsg(form, "shpsCopied", nShps)
       else axlUIConfirm(sprintf(nil, "%d shapes copied. No checks performed", nShps))
      )
    )
  )
  nShps
))

defun( ASU_checkObj (obj, spacing, drcLayer, pinChk, viaChk, smShpChk @optional solderedPadsOnlyChk, txtChk, refdesLocChk)
 let((precisionFactor, layer, side, objType, bbox, smObjTypes, smLayers, smObjs, text, tempShps, symb, class, tempShp1
      pbLayer, gap, boundShp, pkgHgt, boundShps, minHgt, airGap, airGap2, sym2, chkObjs, expected, smObjTypeText
      smObjPoly, delShp, drcPt, smObjShp, gapData, actual, txt, drcTxt, drcMsg, drcMsgs, smObjLoc)
  precisionFactor = 10.0 ** ASU_precision
  layer = obj ->layer
  side = ASU_getLayerSide(layer, obj)
  objType = obj ->objType
  bbox = bBoxAdd(obj ->bBox, list(list(-spacing, -spacing) list(spacing, spacing)))
  when(pinChk, smObjTypes = '("PINS"))
  when(viaChk, smObjTypes = cons("VIAS", smObjTypes))
  when(smObjTypes, smObjs = findTypeObjects(smObjTypes, ?bbox bbox))
  when(pinChk && solderedPadsOnlyChk
    smObjs = setof(pin, smObjs
      or(
	pin ->objType == "via"; Check all via pads
	car(pin ->startEnd) == cadr(pin ->startEnd); Check all SMD pads
	cadr(parseString(cadr(pin ->startEnd), "/")) == side; Check only pads on opposite side from leaded device
      )
    )
  )
  when(smShpChk
    smObjTypes = cons("SHAPES", smObjTypes)
    smLayers = list(strcat("BOARD GEOMETRY/SOLDERMASK_", side), strcat("PACKAGE GEOMETRY/SOLDERMASK_", side))
    smObjs = remove(obj, append(smObjs, findTypeObjects("SHAPES", ?layers smLayers ?bbox bbox)))
  )
  case(objType
    ("text"
      text = obj ->text, tempShps = ASU_textToShape(obj, ?quickChk (txtChk == "QUICK"))
      /* Next few lines are for ref desig location checking */
      when(refdesLocChk
	symb = obj ->parent
	class = symb ->component ->class
	when(symb && (symb ->objType == "symbol") && (symb ->refdes == text)
	  tempShp1 = car(if(txtChk == "QUICK", tempShps, ASU_textToShape(obj, ?quickChk t)))
	  pbLayer = strcat("PACKAGE GEOMETRY/PLACE_BOUND_", side)
	  foreach(shp, setof(shp, symb ->children, shp ->layer == pbLayer)
	    gap = caddr(AFn_getAirGap(tempShp1, shp)) || 0
	    when(!airGap || gap < airGap, boundShp = shp, airGap = gap)
	  )
	  pkgHgt = AFn_getProperty(boundShp, "PACKAGE_HEIGHT_MAX")
	  pkgHgt = if(pkgHgt, readstring(pkgHgt), 0)
	  when(airGap && airGap > 0
	    bbox = bBoxAdd(tempShp1 ->bBox, list(list(-airGap, -airGap), list(airGap, airGap)))
	    boundShps = setof(shp, remove(boundShp, findTypeObjects("SHAPES", ?layers pbLayer ?bbox bbox))
	      and(sym2 = shp ->parent, sym2 ->objType == "symbol", sym2 ->component ->class == class))
	    foreach(shp, boundShps
	      minHgt = AFn_getProperty(shp, "PACKAGE_HEIGHT_MIN")
	      minHgt = if(minHgt, readstring(minHgt), 0)
	      gapData = AFn_getAirGap(tempShp1, shp)
	      airGap2 = caddr(gapData) || 0
	      when(airGap2 < airGap && minHgt <= pkgHgt
	        sym2 = shp ->parent
	        actual = round((airGap - airGap2) * precisionFactor) / precisionFactor; round number to precision
	        sprintf(actual, "%g %s", actual, ASU_designUnits)
		sprintf(drcTxt, "%s text ('%s') is %s closer to %s than its own parent symbol", side, text, actual, sym2 ->refdes)
		sprintf(drcMsg, "%s text ('%s') at %L is %s closer to %s than its own parent symbol", side, text, obj ->xy, actual, sym2 ->refdes)
		drcMsgs = cons(drcMsg, drcMsgs)
		drcPt = cadr(gapData) || obj ->xy
		axlDBCreateExternalDRC(drcTxt, drcPt, drcLayer, list(boundShp, obj), sym2 ->xy, actual)
	      )
	    )
	  )
	  unless(txtChk == "QUICK", axlDeleteObject(tempShp1))
	)
	unless(txtChk, axlDeleteObject(tempShps), tempShps = nil)
      )
      /* ************************************************* */
    )
    ("shape", chkObjs = list(obj))
    ("polygon", chkObjs = list(obj))
    ("path", chkObjs = list(obj))
  )
  sprintf(expected, "%g %s", spacing, ASU_designUnits)
  foreach(tempObj, append(tempShps, chkObjs)
    foreach(soldermaskObj, smObjs
      smObjTypeText = case(soldermaskObj ->objType
	("pin", "Pin Soldermask Pad")
	("via", "Via Soldermask Pad")
	("shape", "Soldermask Shape")
	("polygon", "Soldermask Polygon")
	(t, "Unexpected Soldermask object")
      )
      if(member(soldermaskObj ->objType, '("pin", "via")) then
	smObjPoly = car(axlPolyFromDB(soldermaskObj, ?layer strcat("PIN/SOLDERMASK_", side), ?padType "REGULAR"))
	delShp = smObjShp = car(axlDBCreateShape(smObjPoly, t, layer))
       else
        delShp = nil, smObjShp = soldermaskObj
      )
      when(smObjShp
	actual = nil
	if(objType == "path" then
	  foreach(seg, tempObj ->segments
	    gapData = AFn_getAirGap(seg, smObjShp)
	    airGap = caddr(gapData) || 0.0; axlAirGap returns nil if overlap
	    when(!actual || (airGap < actual), actual = airGap, drcPt = getRectangleCentre(gapData))
	  )
	 else
	  gapData = AFn_getAirGap(tempObj, smObjShp)
	  drcPt = getRectangleCentre(gapData)
	  actual = caddr(gapData) || 0.0; axlAirGap returns nil if overlap
	)
	axlDeleteObject(delShp)
	when(actual
	  actual = round(actual * precisionFactor) / precisionFactor; round number to precision
	  unless(actual >= spacing - axlMKSConvert(0.2, "MILS"); Add a tad to allow for rounding problems
	    actual = if(zerop(actual), "Overlap", sprintf(nil, "%g %s", actual, ASU_designUnits))
	    txt = if(objType == "text", strcat(" ('", text, "')"), "")
	    sprintf(drcTxt, "%s %s%s to %s/req:%s; actual:%s", side, objType, txt, smObjTypeText, expected, actual)
	    sprintf(drcMsg, "%s %s%s to %s/req:%s; actual:%s at %L", side, objType, txt, smObjTypeText, expected, actual, drcPt)
	    drcMsgs = cons(drcMsg, drcMsgs)
	    smObjLoc = soldermaskObj ->xy || car(soldermaskObj ->bBox)
	    axlDBCreateExternalDRC(drcTxt, drcPt, drcLayer, list(obj, soldermaskObj), smObjLoc, actual)
	  )
	)
      )
    )
  )
  axlDeleteObject(tempShps)
  drcMsgs
))

defun( ASU_textToShape (txtObjs @key quickChk, shpLayer, propValue)
 let((layer, tad, text, loc, x0, y0, rot, tbParam, photoWidth, txtHgt, chWid, chSpc, txtLen
      lx, txtLst, txtCh, mergedPolys, unmergedPolys, line, shp, shps, bbox, w, corners, rpath, mergedPoly)
  unless(listp(txtObjs), txtObjs = list(txtObjs))
  tad = axlMKSConvert(0.001, "mm")
  and(shpLayer, !axlIsLayer(shpLayer), axlLayerCreateNonConductor(shpLayer))
  foreach(obj, txtObjs
    layer = shpLayer || obj ->layer
    text = obj ->text, loc = obj ->xy, x0 = car(loc), y0 = cadr(loc), rot = obj ->rotation
    tbParam = axlGetParam(strcat("paramTextBlock:" obj ->textBlock))
    photoWidth = tbParam ->photoWidth
    when(zerop(photoWidth), photoWidth = tad)
    txtHgt = tbParam ->height, chWid = tbParam ->width, chSpc = tbParam ->charSpace
    txtLen = strlen(text) * (tbParam ->width + chSpc) - chSpc
    when(obj ->isMirrored, txtLen = -txtLen, chWid = -chWid, chSpc = -chSpc)
    lx = case(obj ->justify, ("LEFT", x0), ("CENTER", x0 - txtLen / 2.0), ("RIGHT", x0 - txtLen))
    txtLst = parseString(text, "")
    while(txtLst
      txtCh = car(txtLst), txtLst = cdr(txtLst)
      mergedPolys = unmergedPolys = nil
      ;foreach(pts, ASU_getChLines(txtCh, chWid, txtHgt, lx, y0)
      foreach(pts, AFn_getVectorFontChLines(txtCh, chWid, txtHgt, lx, y0, ASU_vectorFontData)
	if(quickChk then bbox = ASU_getLinesBbox(pts, bbox), mergedPolys = t
         else
          unless(zerop(rot), pts = GeoRotatePts(rot, pts, loc))
	  line = caar(axlDBCreateLine(pts, photoWidth, layer))
	  foreach(poly, axlPolyFromDB(line, ?endCapType 'ROUND)
	    mergedPoly = axlPolyOperation(mergedPolys, poly, 'or)
	    ; Polys with isHole == t might occur.
	    ;A bug with axlPolyOperation appears to have this affect sometimes.
	    if(mergedPoly && !member(t, mergedPoly ~>isHole)
	     then mergedPolys = mergedPoly
	     else unmergedPolys = cons(poly, unmergedPolys)
	    )
	  )
	  axlDeleteObject(line)
	)
      )
      unless(quickChk
	foreach(poly, append(mergedPolys, unmergedPolys)
	  shp = if(poly ->isHole ; This shouldn't occur. A bug with axlPolyOperation appears to have this affect sometimes.
	   then car(axlDBCreateRectangle(poly ->bBox, t, layer))
	   else car(axlDBCreateShape(poly, t, layer))
	  )
	  when(shp
	    when(propValue, AFn_addProperty(shp, "TEXTSHAPE", propValue))
	    shps = cons(shp, shps)
	  )
	)
      )
      lx = lx + chWid + chSpc
    )
  )
  when(quickChk
    w = photoWidth / 2.0
    bbox = list(list(caar(bbox) - w, cadar(bbox) - w), list(caadr(bbox) + w, cadadr(bbox) + w))
    if(orthogonalp(rot) then
      unless(zerop(rot), bbox = GeoRotatePts(rot, bbox, loc))
      shp = car(axlDBCreateRectangle(bbox, t, layer))
     else
      corners = list(car(bbox), list(caar(bbox), cadadr(bbox)), cadr(bbox), list(caadr(bbox), cadar(bbox)), car(bbox))
      unless(zerop(rot), corners = GeoRotatePts(rot, corners, loc))
      rpath = axlPathStart(corners)
      shp = car(axlDBCreateShape(rpath, t, layer))
    )
    when(propValue, AFn_addProperty(shp, "TEXTSHAPE", propValue))
    shps = list(shp)
  )
  shps
))

defun( ASU_getLinesBbox (pts, bbox)
 let((lx, ly, rx, uy)
  if(bbox
   then lx = caar(bbox), ly = cadar(bbox), rx = caadr(bbox), uy = cadadr(bbox)
   else lx = rx = caar(pts), ly = uy = cadar(pts), pts = cdr(pts)
  )
  foreach(pt, pts, lx = min(lx, car(pt)), ly = min(ly, cadr(pt)), rx = max(rx, car(pt)), uy = max(uy, cadr(pt)))
  list(lx:ly, rx:uy)
))

defun( ASU_getGeometryObjects (subclassPrefix, objTypes)
 let((layers)
  foreach(class, '("BOARD", "PACKAGE")
    layers = append(mapcar(lambda((side) strcat(class, " GEOMETRY/", subclassPrefix, "_", side)) '("TOP", "BOTTOM")), layers)
  )
  findTypeObjects(objTypes, ?layers layers)
))

defun( ASU_showLog (drcMsgs)
 let((drcLogFileName, drcLogFile, p)
  drcLogFileName = "ASU_drcs"
  drcLogFile = strcat(drcLogFileName, ".log")
  p = if(isCallable('axlDMOpenLog), axlDMOpenLog(drcLogFileName), outfile(drcLogFile, "w"))
  when(isCallable('axlLogHeader), axlLogHeader(p, "Silkscreen Checker DRC log"))
  if(drcMsgs then foreach(msg, drcMsgs, fprintf(p, "%s\n", msg)) else fprintf(p, "No DRCs created\n"))
  if(isCallable('axlDMClose), axlDMClose(p), close(p))
  axlUIViewFileCreate(drcLogFile, "Silkscreen Checker DRC log", nil)
))

;The following function is required because axlFlushDisplay doesn't work in some circumstances.
defun( ASU_tweakDisplay ()
 let((wBox, (tad axlMKSConvert(0.001, "MM")))
  wBox = axlWindowBoxGet()
  axlWindowBoxSet(list(caar(wBox) + tad:cadar(wBox), cadr(wBox)))
  axlWindowBoxSet(wBox)
))

defun( ASU_getLayerSide (layer @optional obj)
 let((side)
  side = car(last(parseString(layer, "/_"))), when(side == "BOT", side = "BOTTOM")
  and(obj, !member(side, '("TOP", "BOTTOM")), if(obj ->isMirrored then side = "BOTTOM" else side = "TOP"))
  unless(side == "BOTTOM", side = "TOP")
  side
))

defun( DRCbrowse_createForm (@optional drcs, padSubclass)
 let((units, drcList, formFile, p, (x 2), (y 0), listLen, zoomExt, form, vis, txtInfo, txtBlkPairs)
  defvar(DRCbrowse_tempLayers)
  defvar(DRCbrowse_hiddenLayers)
  defvar(DRCbrowse_drcInfo)
  defvar(DRCbrowse_drcLayer)
  defvar(DRCbrowse_padSubclass)
  defvar(DRCbrowse_transactionMark)
  defvar(DRCbrowse_transactionLevel)
  unless(drcs, drcs = findByProperty("DRC", "EXTERNAL_VIOLATION_DESCRIPTION"))
  DRCbrowse_padSubclass = if(padSubclass then padSubclass else "SOLDERMASK")
  units = car(AFn_getDesignUnits())
  unless(axlDBGetPropDictEntry("DRCBROWSE_INDEX"), axlDBCreatePropDictEntry("DRCBROWSE_INDEX", "INTEGER" "drcs"))
  when(drcs, drcs = DRCbrowse_sort(drcs, "ByLocation"))
  drcList = DRCbrowse_getDRClist(drcs)
  listLen = max(4, min(length(drcList), 10))
  p = AFn_formOpenFile()
  formFile = get_filename(p)
  AFn_formHeader(p, 63, "DRC Browse Form")
  AFn_formPopupDefine(p, "TEXTBLKPOP", '(("17" "0.85mm")))
  AFn_formMessage(p, "drcCount", ?level 0, ?msgString "%d DRCs")
  AFn_formMessage(p, "drcMessage", ?level 0, ?msgString "%s")
  AFn_formText(p, "DRC list", x, y), y = y + 2
  AFn_formList(p, "drclist", "DRC List:", x, y, 60, listLen), y = y + listLen * 2
  unless(boundp('DRCbrowse_units), defvar(DRCbrowse_units, units))
  if(boundp('DRCbrowse_zoomExt) && DRCbrowse_units == units then zoomExt = DRCbrowse_zoomExt
   else
    zoomExt = if(units == "mils" || units == "inches" then axlMKSConvert(800 "mils") else axlMKSConvert(20 "mm"))
    defvar(DRCbrowse_zoomExt, zoomExt)
  )
  AFn_formRealFillin(p, "zoomExt", 5, 5, x, y ?title "Zoom extent: " ?minVal 0, ?value zoomExt, ?units units)
  AFn_formChecklistItem(p, "zoomEnable", x + 24, y, "Zoom Enable")
  AFn_formChecklistItem(p, "filterLayers", x + 39, y, "Filter Display Layers"), y = y + 3
  AFn_formButton(p, "removeDRC", "Remove DRC", x, y, 15, 3)
  AFn_formButton(p, "removeAllDRC", "Remove All Remaining DRCs", x + 20, y, 25, 3)
  AFn_formButton(p, "viewDRCLog", "View DRC log", x + 47, y, 12, 3), y = y + 3
  AFn_formChecklistItem(p, "allowFixMods", x, y, "Allow modification of fixed objects"), y = y + 2
  AFn_formChecklistItem(p, "associate", x, y, "Apply changes to matching parent silkscreen object"), y = y + 2
  AFn_formChecklistItem(p, "gridsnap", x, y, "Snap moved objects to grid"), y = y + 2
  AFn_formButton(p, "moveObj" "Move Object", x, y, 13, 3)
  AFn_formChecklistItem(p, "aligntext", x, y + 2, "Align same text")
  AFn_formButton(p, "rotateObj" "Rotate Object", x + 15, y, 12, 3)
  AFn_formRealFillin(p, "rotateAng", 3, 3, x + 15, y + 2, ?units "degrees", ?value 90, ?decimalPlaces 0)
  AFn_formButton(p, "changeObj" "Change Object", x + 30, y, 12, 3)
  AFn_formRealFillin(p, "changeVal", 4, 4, x + 29, y + 2, ?title "Change Val:", ?titleLabel "chgValLabel", ?units "units           ")
  AFn_formButton(p, "removeObj", "Remove Object", x + 46, y, 12, 3), y = y + 4
  AFn_formButton(p, "moveSymb" "Move symbol", x, y, 13, 3)
  AFn_formPop(p, "textblk", "TEXTBLKPOP", x + 29, y, 20, ?title "Change to:", ?x2 x + 38, ?titleLabel "txtblktitle")
  AFn_formButton(p, "cutLine" "Cut line", x + 30, y, 12, 3), y = y + 3
  AFn_formList(p, "drcInfo", "DRC Info", x, y, 60, 4), y = y + 8
  AFn_formButton(p, "oops", "Oops", x, y, 12, 3)
  AFn_formButton(p, "cancel", "Close", x + 23, y, 15, 3)
  AFn_formButton(p, "drcbrowsehelp", "Help", x + 50, y, 10, 3)
  AFn_formEnd(p)
  axlDMClose(p)
  defvar(DRCbrowse_drcList, drcList)
  axlDehighlightObject(findTypeObjects('("SHAPES", "TEXT", "LINES", "DRCS"))); Delete all temporary highlights
  defvar(DRCbrowse_highlightedObjs)
  defvar(DRCbrowse_movedObj)
  defvar(DRCbrowse_form, axlFormCreate('form, formFile, '(E INNER), 'DRCbrowse_formAction, nil))
  axlUIWShow(ASU_startForm, 'hide)
  defvar(DRCbrowse_modFields
    '("aligntext", "moveObj", "moveSymb", "rotateObj", "removeObj", "changeObj", "cutLine", "removeDRC"
      "changeVal", "textblk", "chgValLabel", "changeValUnits", "oops")
  )
  defvar(DRCbrowse_obj)
  foreach(drc, drcList, axlFormSetField(form, "drclist", car(drc)))
  foreach(field, DRCbrowse_modFields, axlFormSetFieldEditable(form, field, 0))
  unless(boundp('DRCbrowse_zoomEnable), defvar(DRCbrowse_zoomEnable, t))
  axlFormSetField(form, "zoomEnable", DRCbrowse_zoomEnable)
  unless(boundp('DRCbrowse_filterLayers), defvar(DRCbrowse_filterLayers, t))
  axlFormSetField(form, "filterLayers", DRCbrowse_filterLayers)
  unless(boundp('DRCbrowse_associate), defvar(DRCbrowse_associate))
  axlFormSetField(form, "associate", DRCbrowse_associate)
  unless(boundp('DRCbrowse_alignText), defvar(DRCbrowse_alignText))
  axlFormSetField(form, "aligntext", DRCbrowse_alignText)
  axlFormSetFieldEditable(form, "aligntext", if(DRCbrowse_associate, 1, 0))
  unless(boundp('DRCbrowse_allowFixMods), defvar(DRCbrowse_allowFixMods))
  axlFormSetField(form, "allowFixMods", DRCbrowse_allowFixMods)
  unless(boundp('DRCbrowse_gridSnap), defvar(DRCbrowse_gridSnap))  
  axlFormSetField(form, "gridsnap", DRCbrowse_gridSnap)
  vis = if(DRCbrowse_getDRCID("0") && drcList && index(DRCbrowse_getObj(DRCbrowse_getDRCID("0")) ->layer, "AUTOSILK") 1 0)
  axlFormSetFieldVisible(form, "associate", vis)
  axlFormSetFieldVisible(form, "aligntext", vis)
  foreach(field, '("aligntext", "textblk", "txtblktitle"), axlFormSetFieldVisible(form, field, 0))
  for(txtBlk, 1, axlDBControl('maxTextBlock)
    txtInfo = DRCbrowse_getTextBlkStr(txtBlk)
    txtBlkPairs = cons(list(sprintf(nil, "%-4d %s", txtBlk, txtInfo), txtBlk), txtBlkPairs)
  )
  axlFormBuildPopup(form, "TEXTBLKPOP", reverse(txtBlkPairs))
  if(drcList then
    axlFormSetInfo(form "actionMsg" "Select a DRC to zoom into")
    axlFormMsg(form, "drcCount", length(DRCbrowse_drcList))
   else	axlFormSetInfo(form, "actionMsg", "No DRCs were found")
  )
  unless(fboundp('axlDBTransactionCommit), axlFormSetFieldVisible(form, "oops", 0))
  axlFormDisplay(form)
  deleteFile(formFile)
))

defun( DRCbrowse_formAction (form)
 let((allowFixMods, changeFields, gridSnap, layer, drcid, drcPos, obj, objs, sameObj, objOrigin, symb, objType, pt, text
      defaultRotation, rots, popups, drcids, fixedObjs, fixedObj, isFixed, drcList, popid, event)
  allowFixMods = axlFormGetField(form, "allowFixMods")
  changeFields = '("aligntext", "moveObj", "moveSymb", "rotateObj", "removeObj", "changeObj", "cutLine", "changeVal", "chgValLabel", "changeValUnits", "textblk")
  gridSnap = axlFormGetField(form, "gridsnap")
  case(form ->curField
    ("drclist"
      drcPos = form ->curValueInt
      and(fboundp('axlDBTransactionCommit), DRCbrowse_transactionMark, axlDBTransactionCommit(DRCbrowse_transactionMark))
      DRCbrowse_drcSelect(form, drcPos)
      when(fboundp('axlDBTransactionCommit), DRCbrowse_transactionMark = axlDBTransactionStart(), DRCbrowse_transactionLevel = 0)
    )
    ("zoomExt", DRCbrowse_zoomExt = axlFormGetField(form, "zoomExt"))
    ("zoomEnable"
      DRCbrowse_zoomEnable = axlFormGetField(form, "zoomEnable")
      when(DRCbrowse_zoomEnable
	drcid = DRCbrowse_getDRCID(caddr(DRCbrowse_drcInfo))
	DRCbrowse_displayDrcInfo(form, drcid)
      )
    )
    ("filterLayers", DRCbrowse_filterLayers = axlFormGetField(form, "filterLayers"))
    ("allowFixMods", DRCbrowse_allowFixMods = axlFormGetField(form, "allowFixMods"))
    ("associate"
      DRCbrowse_associate = axlFormGetField(form, "associate")
      axlFormSetFieldEditable(form, "aligntext", if(DRCbrowse_associate, 1, 0))
    )
    ("gridsnap", DRCbrowse_gridSnap = axlFormGetField(form, "gridsnap"))
    ("aligntext", DRCbrowse_alignText = axlFormGetField(form, "aligntext"))
    ("moveObj"
      obj = DRCbrowse_getDRCObj()
      if(axlDBIsFixed(obj) && !allowFixMods then
	axlUIWBeep(), axlFormMsg(form, "drcMessage" "The object is fixed and cannot be moved")
       else
	when(fboundp('axlDBTransactionCommit), axlDBTransactionMark(DRCbrowse_transactionMark), DRCbrowse_transactionLevel++)
	axlFormSetFieldEditable(form, "oops", 0)
	objs = if(axlFormGetField(form, "associate") then DRCbrowse_getAssociatedObjects(obj) else list(obj))
	axlClearDynamics()
	objOrigin = obj ->xy || getRectangleCentre(obj ->bBox)
	axlDynamicsObject(obj, objOrigin)
	symb = obj ->parent
	objType = obj ->objType
	if(symb ->objType == "symbol" && objType == "text" then
	  text = obj ->text
	  cond(
	    (symb ->refdes == text, pt = symb ->xy)
	    (member(text, symb ->pins ~>number), pt = car(setof(pin, symb ->pins, pin ->number == text)) ->xy)
	    (t, pt = symb ->xy)
	  )
	 else pt = symb ->xy
	)
	when(pt, axlAddSimpleRbandDynamics(pt, "directline", ?origin pt, ?var_point 0:0))
	axlUIWShow(form, 'hide)
	defaultRotation = round(axlFormGetField(form, "rotateAng"))
	rots = '(90 180 270)
	unless(member(defaultRotation, rots), rots = cons(defaultRotation, rots))
	popups = '(("Done", "axlFinishEnterFun()"), ("Cancel", "DRCbrowse_cancel()"), ("MENU_SEPARATOR", nil))
	foreach(ang, rots
	  popups = append1(popups, list(sprintf(nil, "Rotate %n", ang), sprintf(nil, "DRCbrowse_rotateObjs(form, obj, objs %n)", ang)))
	)
	popid = axlUIPopupDefine(nil, popups)
	axlUIPopupSet(popid)
	event = axlEnterEvent(list('PICK), "Select the destination point (Use right mouse button to rotate or cancel)", gridSnap)
	caseq(event ->type
	  (PICK, pt = event ->xy)
	  (DONE, pt = nil)
	  (CANCEL, pt = nil)
	)
	axlUIPopupSet(nil)
	axlUIWShow(form, 'show)
	when(pt
	  when(fboundp('axlDBTransactionCommit), axlDBTransactionMark(DRCbrowse_transactionMark), DRCbrowse_transactionLevel++)
	  fixedObjs = AFn_unFixObject(obj)
	  foreach(ob, objs
	    sameObj = ob == obj
	    objOrigin = ob ->xy || getRectangleCentre(ob ->bBox)
	    ob = AFn_transformObject(ob, ?move list(car(pt) - car(objOrigin), cadr(pt) - cadr(objOrigin)))
	    and(sameObj, ob, DRCbrowse_movedObj = ob, DRCbrowse_highlightedObjs = consx(ob, DRCbrowse_highlightedObjs))
	  )
	  axlDBAddProp(setof(ob, fixedObjs, ob ->objType), '("FIXED" t))
	  axlFormSetFieldEditable(form, "oops", 1)
	)
	axlClearDynamics()
	DRCbrowse_recalcDRCs(DRCbrowse_movedObj, DRCbrowse_drcLayer)
	DRCbrowse_regenDrcList(form, DRCbrowse_movedObj)
      )
    )
    ("moveSymb"
      obj = DRCbrowse_getDRCObj()
      if(axlDBIsFixed(obj) && !allowFixMods then
	axlUIWBeep(), axlFormMsg(form, "drcMessage" "The object is fixed and cannot be moved")
       else
        when(fboundp('axlDBTransactionCommit), axlDBTransactionMark(DRCbrowse_transactionMark), DRCbrowse_transactionLevel++)
        axlFormSetFieldEditable(form, "oops", 0)
	symb = obj ->parent
	axlClearDynamics()
	axlDynamicsObject(symb, symb ->xy)
	axlUIWShow(form, 'hide)
	defaultRotation = round(axlFormGetField(form, "rotateAng"))
	rots = '(90 180 270)
	unless(member(defaultRotation, rots), rots = cons(defaultRotation, rots))
	popups = '(("Done", "axlFinishEnterFun()"), ("Cancel", "DRCbrowse_cancel()"), ("MENU_SEPARATOR", nil))
	foreach(ang, rots
	  popups = append1(popups, list(sprintf(nil, "Rotate %n", ang), sprintf(nil, "DRCbrowse_rotateObjSymb(form, symb, obj %n)", ang)))
	)
	popid = axlUIPopupDefine(nil, popups)
	axlUIPopupSet(popid)
	event = axlEnterEvent(list('PICK), "Select the destination point (Use right mouse button to rotate or cancel)", gridSnap)
	caseq(event ->type
	  (PICK, pt = event ->xy)
	  (DONE, pt = nil)
	  (CANCEL, pt = nil)
	)
	axlUIPopupSet(nil)
	axlUIWShow(form, 'show)
	when(pt
	  fixedObj = axlDBIsFixed(symb)
	  objOrigin = symb ->xy
	  when(fboundp('axlDBTransactionCommit), axlDBTransactionMark(DRCbrowse_transactionMark), DRCbrowse_transactionLevel++)
	  symb = AFn_transformObject(symb, ?move list(car(pt) - car(objOrigin), cadr(pt) - cadr(objOrigin)))
	  when(obj ->objType
	    DRCbrowse_movedObj = obj
	    DRCbrowse_highlightedObjs = consx(obj, DRCbrowse_highlightedObjs)
	  )
	  when(fixedObj, axlDBAddProp(symb, '("FIXED" t)))
	  axlFormSetFieldEditable(form, "oops", 1)
	)
	axlClearDynamics()
	DRCbrowse_recalcDRCs(DRCbrowse_movedObj, DRCbrowse_drcLayer)
	DRCbrowse_regenDrcList(form, DRCbrowse_movedObj)
      )
    )
    ("rotateObj"
      obj = DRCbrowse_getDRCObj()
      if(axlDBIsFixed(obj) && !allowFixMods then
	axlUIWBeep(), axlFormMsg(form, "drcMessage" "The object is fixed and cannot be rotated")
       else
	when(fboundp('axlDBTransactionCommit), axlDBTransactionMark(DRCbrowse_transactionMark), DRCbrowse_transactionLevel++)
	objs = if(axlFormGetField(form, "associate") then DRCbrowse_getAssociatedObjects(obj) else list(obj))
	fixedObjs = AFn_unFixObject(obj)
	foreach(ob, objs
	  sameObj = ob == obj
	  ob = AFn_transformObject(ob, ?angle axlFormGetField(form, "rotateAng"))
	  and(sameObj, ob, DRCbrowse_movedObj = ob, DRCbrowse_highlightedObjs = consx(ob, DRCbrowse_highlightedObjs))
	)
	axlDBAddProp(setof(ob, fixedObjs, ob ->objType), '("FIXED", t))
	DRCbrowse_recalcDRCs(DRCbrowse_movedObj, DRCbrowse_drcLayer)
	DRCbrowse_regenDrcList(form, DRCbrowse_movedObj)
	axlFormSetFieldEditable(form, "oops", 1)
      )
    )
    ("changeObj"
      obj = DRCbrowse_getDRCObj()
      if(axlDBIsFixed(obj) && !allowFixMods then
	axlUIWBeep(), axlFormMsg(form, "drcMessage" "The object is fixed and cannot be modified")
       else
	when(fboundp('axlDBTransactionCommit), axlDBTransactionMark(DRCbrowse_transactionMark), DRCbrowse_transactionLevel++)
	fixedObjs = AFn_unFixObject(obj)
	layer = obj ->layer
	objs = if(axlFormGetField(form, "associate") then DRCbrowse_getAssociatedObjects(obj) else list(obj))
	foreach(ob, objs
	  case(ob ->objType
	    ("text", ob = DRCbrowse_ChangeText(form, ob))
	    ("path", ob = DRCbrowse_TrimLine(form, ob))
	    ("shape", ob = DRCbrowse_ShrinkShape(form, ob))
	    ("polygon", ob = DRCbrowse_ShrinkShape(form, ob))
	  )
	  when(ob ->layer == layer, DRCbrowse_movedObj = ob)
	)
	axlDBAddProp(setof(ob, fixedObjs, ob ->objType), '("FIXED" t))
	DRCbrowse_recalcDRCs(DRCbrowse_movedObj, DRCbrowse_drcLayer)
	DRCbrowse_regenDrcList(form, DRCbrowse_movedObj)
	axlFormSetFieldEditable(form, "oops", 1)
      )
    )
    ("cutLine"
      obj = DRCbrowse_getDRCObj()
      if(axlDBIsFixed(obj) && !allowFixMods then
	axlUIWBeep(), axlFormMsg(form, "drcMessage" "The object is fixed and cannot be modified")
       else
	when(fboundp('axlDBTransactionCommit), axlDBTransactionMark(DRCbrowse_transactionMark), DRCbrowse_transactionLevel++)
	fixedObjs = AFn_unFixObject(obj)
	layer = obj ->layer
	isFixed = axlDBIsFixed(obj)
	objs = DRCbrowse_CutLine(form, obj)
	DRCbrowse_movedObj = nil
	when(objs && isFixed, axlDBAddProp(objs, '("FIXED" t)))
	foreach(ob, objs, when(DRCbrowse_recalcDRCs(ob, DRCbrowse_drcLayer), DRCbrowse_movedObj = ob))
	axlDBAddProp(setof(ob, fixedObjs, ob ->objType), '("FIXED" t)); refix any parent oblects that were originally fixed.
	DRCbrowse_removeObjectHilights()
	if(DRCbrowse_movedObj
	 then axlHighlightObject(DRCbrowse_movedObj), DRCbrowse_highlightedObjs = list(DRCbrowse_movedObj)
	 else foreach(field, changeFields, axlFormSetFieldEditable(form, field, 0))
	)
	DRCbrowse_regenDrcList(form, DRCbrowse_movedObj)
	axlFlushDisplay()
	axlFormSetFieldEditable(form, "oops", 1)
      )
    )
    ("textblk", axlFormSetFieldEditable(form, "changeObj", if(axlFormGetField(form, "textblk") == "", 0, 1)))
    ("removeObj"
      obj = DRCbrowse_getDRCObj()
      if(axlDBIsFixed(obj) && !allowFixMods then
	axlUIWBeep(), axlFormMsg(form, "drcMessage" "The object is fixed and cannot be rotated")
       else
	when(fboundp('axlDBTransactionCommit), axlDBTransactionMark(DRCbrowse_transactionMark), DRCbrowse_transactionLevel++)
	objs = if(axlFormGetField(form, "associate") then DRCbrowse_getAssociatedObjects(obj) else list(obj))
	drcids = setof(drc, mapcar('DRCbrowse_getDRCID, mapcar('caddr, DRCbrowse_drcList)), member(obj, drc ->violations))
	fixedObjs = AFn_unFixObject(obj)
	if(axlDeleteObject(remd(nil, drcids)) && axlDeleteObject(remd(nil, objs)) then
	  DRCbrowse_movedObj = nil
	  DRCbrowse_removeObjectHilights()
	  axlClearDynamics()
	  DRCbrowse_regenDrcList(form)
	  foreach(field, changeFields, axlFormSetFieldEditable(form, field, 0))
	  axlFlushDisplay()
	  axlFormSetFieldEditable(form, "oops", 1)
	 else axlFormMsg(form, "drcMessage" "The object could not be removed")
	)
	axlDBAddProp(setof(ob, fixedObjs, ob ->objType), '("FIXED" t))
      )
    )
    ("removeDRC"
      when(fboundp('axlDBTransactionCommit), axlDBTransactionMark(DRCbrowse_transactionMark), DRCbrowse_transactionLevel++)
      drcid = DRCbrowse_getDRCID(caddr(DRCbrowse_drcInfo))
      DRCbrowse_movedObj = DRCbrowse_getObj(drcid)
      axlDeleteObject(drcid, t)
      DRCbrowse_regenDrcList(form, DRCbrowse_movedObj)
      axlFlushDisplay()
      axlFormSetFieldEditable(form, "oops", 1)
    )
    ("removeAllDRC", removeExternalDRCs(), DRCbrowse_QuitForm(form))
    ("viewDRCLog"
      foreach(drc, DRCbrowse_drcList
        drcList = cons(sprintf(nil, "%s at %L", car(drc), cadr(drc)), drcList)
      )
      ASU_showLog(drcList)
    )
    ("oops"
      axlDBTransactionOops(DRCbrowse_transactionMark)
      when(zerop(--DRCbrowse_transactionLevel), axlFormSetFieldEditable(form, "oops", 0))
      DRCbrowse_movedObj = DRCbrowse_obj
      DRCbrowse_regenDrcList(form, DRCbrowse_movedObj)
      axlFlushDisplay()
      unless(DRCbrowse_getDRCObj(), foreach(field, changeFields, axlFormSetFieldEditable(form, field, 0)))
    )
    ("drcbrowsehelp", DRCbrowse_helpDisplay())
    ("cancel", DRCbrowse_QuitForm(form))
  )
))

defun( DRCbrowse_cancel ()
  when(fboundp('axlDBTransactionCommit)
    axlDBTransactionRollback(DRCbrowse_transactionMark)
    DRCbrowse_transactionLevel = 0
  )
  axlFormSetFieldEditable(DRCbrowse_form, "oops", 0)
  axlCancelEnterFun()
)

defun( DRCbrowse_rotateObjs (form, obj, objs @optional angle)
 let((symb, text, pt, fixedObjs, sameObj)
  unless(angle, angle = axlFormGetField(form, "rotateAng"))
  symb = obj ->parent
  if(symb ->objType == "symbol" && obj ->objType == "text" then
    text = obj ->text
    cond(
      (symb ->refdes == text, pt = symb ->xy)
      (member(text, symb ->pins ~>number), pt = car(setof(pin, symb ->pins, pin ->number == text)) ->xy)
      (t, pt = symb ->xy)
    )
   else pt = symb ->xy
  )
  axlClearDynamics()
  fixedObjs = AFn_unFixObject(obj)
  when(fboundp('axlDBTransactionCommit), axlDBTransactionMark(DRCbrowse_transactionMark), DRCbrowse_transactionLevel++)
  axlFormSetFieldEditable(form, "oops", 1)
  foreach(ob, objs
    sameObj = ob == obj
    ob = AFn_transformObject(ob, ?angle angle)
    and(sameObj, ob, DRCbrowse_movedObj = ob, DRCbrowse_highlightedObjs = consx(ob, DRCbrowse_highlightedObjs))
  )
  axlDBAddProp(setof(ob, fixedObjs, ob ->objType), '("FIXED" t))
  axlDynamicsObject(obj, obj ->xy || getRectangleCentre(obj ->bBox))
  when(pt, axlAddSimpleRbandDynamics(pt, "directline", ?origin pt, ?var_point 0:0))
))

defun( DRCbrowse_rotateObjSymb (form, symb, obj @optional angle)
 let((fixedObj)
  unless(angle, angle = axlFormGetField(form, "rotateAng"))
  axlClearDynamics()
  when(fboundp('axlDBTransactionCommit), axlDBTransactionMark(DRCbrowse_transactionMark), DRCbrowse_transactionLevel++)
  axlFormSetFieldEditable(form, "oops", 1)
  fixedObj = axlDBIsFixed(symb)
  symb = AFn_transformObject(symb, ?angle angle)
  DRCbrowse_movedObj = obj
  DRCbrowse_highlightedObjs = consx(obj, DRCbrowse_highlightedObjs)
  when(fixedObj, axlDBAddProp(symb, '("FIXED" t)))
  axlDynamicsObject(symb, symb ->xy)
))

defun( DRCbrowse_drcSelect (form, drcPos)
 let((layer, drcid, obj)
  axlFormSetFieldEditable(form, "oops", 0)
  axlClearDynamics()
  DRCbrowse_removeObjectHilights()
  DRCbrowse_movedObj = nil
  foreach(tempLayer, DRCbrowse_tempLayers, axlVisibleLayer(tempLayer, nil))
  DRCbrowse_tempLayers = nil
  foreach(hiddenLayer, DRCbrowse_hiddenLayers, axlVisibleLayer(hiddenLayer, t))
  DRCbrowse_hiddenLayers = nil
  when(axlFormGetField(form, "filterLayers")
    foreach(class '("ETCH", "PIN", "VIA CLASS")
      foreach(subclass, axlGetParam(strcat("paramLayerGroup:", class)) ->groupMembers
	and(axlIsLayer(strcat("ETCH/", subclass))
	  layer = strcat(class, "/", subclass)
	  axlIsVisibleLayer(layer)
	  DRCbrowse_hiddenLayers = cons(layer, DRCbrowse_hiddenLayers)
	  axlVisibleLayer(layer, nil)
	)
      )
    )
  )
  drcid = DRCbrowse_getDRCID(caddr(DRCbrowse_drcInfo))
  axlDehighlightObject(drcid)
  DRCbrowse_drcInfo = nth(drcPos, DRCbrowse_drcList)
  drcid = DRCbrowse_getDRCID(caddr(DRCbrowse_drcInfo))
  if(drcid then
    axlFormMsg(form, "drcCount", length(DRCbrowse_drcList))
    obj = DRCbrowse_getObj(drcid)
    DRCbrowse_obj = obj
    axlHighlightObject(obj)
    DRCbrowse_highlightedObjs = list(obj)
    DRCbrowse_displayDrcInfo(form, drcid)
   else
    axlFormListDeleteItem(form, "drclist", drcPos)
    axlFormMsg(form, "drcMessage" "The DRC has been removed")
    DRCbrowse_drcList = remd(DRCbrowse_drcInfo, DRCbrowse_drcList)
  )
  ASU_tweakDisplay()
))

defun( DRCbrowse_removeObjectHilights ()
  axlDehighlightObject(setof(obj, DRCbrowse_highlightedObjs, obj ->objType))
  axlDehighlightObject(findTypeObjects("DRCS"))
  DRCbrowse_highlightedObjs = nil
)

defun( DRCbrowse_getAssociatedObjects (obj)
 let((objOrigin, objType, objs, (tad axlMKSConvert(0.5, "mils")))
  objOrigin = obj ->xy || getRectangleCentre(obj ->bBox)
  objType = obj ->objType
  axlDBRefreshId(obj ->parent); This should be here DE 07-Sep-09
  objs = if(obj ->parent
   then obj ->parent ->children
   else findTypeObjects(case(objType, ("text", "TEXT"), ("arc", "LINES"), ("line", "LINES"), ("path", "LINES"), ("shape", "SHAPES"))); obj = DRCbrowse_getDRCObj()
  )
  setof(child, objs; obj ->parent ->children
    and(
      child ->?
      index(child ->layer, "SILK")
      child ->objType == objType
      child ->rotation == obj ->rotation
      child ->isMirrored == obj ->isMirrored
      child ->text == obj ->text
      child ->textBlock == obj ->textBlock
      or(
	and(DRCbrowse_alignText, objType == "text")
	and(
	  (samePoint(child ->xy, objOrigin, tad) || samePoint(getRectangleCentre(child ->bBox), objOrigin))
	  sameLine(child ->bBox, obj ->bBox, tad)
	)
      )
    )
  ) || list(obj)
))

defun( DRCbrowse_getDRCObj ()
 let((obj, drcid)
  if(DRCbrowse_movedObj then obj = DRCbrowse_movedObj
   else
    drcid = DRCbrowse_getDRCID(caddr(DRCbrowse_drcInfo))
    DRCbrowse_movedObj = obj = DRCbrowse_getObj(drcid)
    DRCbrowse_drcLayer = drcid ->layer
  )
  obj
))

defun( DRCbrowse_helpDisplay (@optional topic)
 let((helpTxts)
  helpTxts = '(
    ("DRC list:")
    	("DRC list",	"List of all the relevant drcs."
    		 	"Select a line to view more information on the drc and, optionally, zoom in to it")
    ("Zoom Extent", "Change this number to alter the zoom extent.")
    ("Zoom Enable", "Enable or disable zooming to drcs.")
    ("Filter Display Layers", "Show only the objects on the same side as the drc."
    			      "Only affects ETCH, PIN and VIA classes")
    ("Action buttons:")
	("Remove DRC", "Removes the DRC from the design and the list")
	("Remove All Remaining DRCs", "Removes all the remaining DRC markers from the design and quits the form")
	("View DRC log", "View the remaining DRCs in a text file")
	("Allow modification of fixed ...",	"Tick this box to enable objects that are fixed themselves,"
    						"or have inherited a fixed property, to be moved.")
	("Apply changes to matching...", "Only visible during autosilk actions."
    					 "Will apply the action to the corresponding silkscreen layer object"
    					 "if it is identical in location, rotation and size.")
    	("Snap moved objects to grid", "Snaps the moved silkscreen object or symbol to the non-etch grid")
    	("Align same text...", "Moves identical master text, such as the original reference designator,"
    				    "to the same location.")
	("Move Object",	"Move the selected object")
	("Rotate Object", "Rotate the selected object by the angle entered (defaults to 90 degrees)")
	("Change Object", "Functionality varies depending on object type:"
    			  "Text - change the text block to the entered number"
    			  "- Text block height and photoplot widths are shown to assist selection"
    			  "- This option becomes enabled when a replacement text block has been selected"
    			  "Line - trim the line length at the end that will be requested"
    			  "Shape - Shrink the shape by the entered percentage. This may have unexpected results.")
	("Cut line", "Cuts the line segment or arc into two lines or arcs at the point closest to that selected.")
	("Remove Object", "Deletes the object causing the drc. Also removes all associated drcs from the list")
	("Move Symbol",	"Move the selected object's parent symbol")
    ("General:")
    	("Oops", "Back up one action - Only available in 14.2 and above")
	("Help", "Display this file")
	("Quit", "Quit this utility")
    ("Support:")
	("Feedback", "This utility is unsupported. However feedback is invited and appreciated.")
	("Author", "Dave Elder, dave.elder@tait.co.nz")
  )
  AFn_displayHelpText("DRC Browse Help Information", helpTxts, topic)
))

defun( DRCbrowse_ChangeText (form, obj)
 let((layer, xy, text, textBlock, rotation, isMirrored, justify, parent, parentGroups, txtOrient, newObj, txtInfo)
  foreach(attr, '(layer, xy, text, textBlock, rotation, isMirrored, justify, parent, parentGroups)
    set(attr, get(obj, attr))
  )
  and(
    textBlock = axlFormGetField(form, "textblk")
    txtOrient = make_axlTextOrientation(?textBlock textBlock, ?rotation rotation, ?mirrored isMirrored, ?justify justify)
    axlDeleteObject(obj)
    newObj = caar(axlDBCreateText(text, xy, txtOrient, layer, parent))
  )
  when(newObj
    when(axlHighlightObject(newObj), DRCbrowse_highlightedObjs = consx(newObj, DRCbrowse_highlightedObjs))
    foreach(grp, parentGroups, axlDBAddGroupObjects(grp, newObj))
    txtInfo = DRCbrowse_getTextBlkStr(textBlock)
    axlFormSetField(form, "changeValUnits", txtInfo)
  )
  newObj
))

defun( DRCbrowse_TrimLine (form, obj)
 let((segments, parentGroups, parent, segment, layer, width, startEnd, d, end1, end2, drcLoc, ends, rpath
      otherSegData, objType, cw, xy, r)
  foreach(attr, '(segments, layer, parentGroups, parent), set(attr, get(obj, attr)))
  d = axlFormGetField(form, "changeVal")
  axlUIWBeep(), axlFormMsg(form, "drcMessage", "Select the end to trim")
  axlUIWShow(form, 'hide)
  drcLoc = axlEnterPoint(?prompts "Select the segment end to trim (Use right mouse button to cancel)")
  axlUIWShow(form, 'show)
  when(drcLoc
    segment = car(findTypeObjects("LINESEGS" ?visibleOnly t, ?layers layer, ?point drcLoc))
    when(segment && member(segment, segments)
      foreach(seg, remove(segment, segments)
	otherSegData = cons(list(seg ->objType, seg ->width, seg ->startEnd, seg ->isClockwise, seg ->xy), otherSegData)
      )
      objType = segment ->objType, width = segment ->width, startEnd = segment ->startEnd
      cw = segment ->isClockwise, xy = segment ->xy, r = segment ->radius
      axlDeleteObject(obj)
      axlDBRefreshId(nil)
      end1 = car(startEnd), end2 = cadr(startEnd)
      case(objType
	("line"
	  ends = if(axlDistance(drcLoc, end1) < axlDistance(drcLoc, end2) then trimLineSegment(end2, end1, d) else trimLineSegment(end1, end2, d))
	  obj = caar(axlDBCreateLine(ends, width, layer, nil, parent))
	)
	("arc"
	  if(axlDistance(drcLoc, end1) < axlDistance(drcLoc, end2)
	   then end1 = axlGeoRotatePt(if(cw, -1, 1) * rad2deg(atan2(d, 2 * r)), end1, xy)
	   else end2 = axlGeoRotatePt(if(cw, 1, -1) * rad2deg(atan2(d, 2 * r)), end2, xy)
	  )
	  rpath = axlPathStart(list(end1))
	  rpath = axlPathArcCenter(rpath, width, end2, cw, xy)
	  obj = caar(axlDBCreatePath(rpath, layer, nil, parent))
	)
      )
      axlHighlightObject(obj)
      DRCbrowse_highlightedObjs = consx(obj, DRCbrowse_highlightedObjs)
      foreach(grp, parentGroups, axlDBAddGroupObjects(grp, obj))
      foreach(segData, otherSegData
	width = cadr(segData), ends = caddr(segData)
	case(car(segData)
	  ("line", segment = caar(axlDBCreateLine(ends, width, layer, nil, parent)))
	  ("arc"
	    rpath = axlPathStart(list(car(ends)))
	    rpath = axlPathArcCenter(rpath, width, cadr(ends), cadddr(segData), nth(4, segData))
	    segment = caar(axlDBCreatePath(rpath, layer, nil, parent))
	  )
	)
	foreach(grp, parentGroups, axlDBAddGroupObjects(grp, segment))
      )
    )
  )
  obj
))

defun( DRCbrowse_CutLine (form, obj)
 let((segments, layer, parentGroups, parent, cutPt, segment, otherSegData, objType, width, startEnd, cw, xy, end1, end2, lineEq, rpath, objs, ends)
  foreach(attr, '(segments, layer, parentGroups, parent), set(attr, get(obj, attr)))
  axlUIWBeep(), axlFormMsg(form, "drcMessage", "Select the cut point")
  axlUIWShow(form, 'hide)
  cutPt = axlEnterPoint(?prompts "Select the cut point (Use right mouse button to cancel)")
  axlUIWShow(form, 'show)
  when(cutPt
    segment = car(findTypeObjects("LINESEGS" ?visibleOnly t, ?layers layer, ?point cutPt))
    when(segment && member(segment, segments)
      foreach(seg, remove(segment, segments)
	otherSegData = cons(list(seg ->objType, seg ->width, seg ->startEnd, seg ->isClockwise, seg ->xy), otherSegData)
      )
      objType = segment ->objType, width = segment ->width, startEnd = segment ->startEnd
      cw = segment ->isClockwise, xy = segment ->xy; r = segment ->radius
      axlDeleteObject(obj)
      axlDBRefreshId(nil)
      end1 = car(startEnd), end2 = cadr(startEnd)
      case(objType
	("line"
	  lineEq = lineEquation(car(end1), cadr(end1), car(end2), cadr(end2))
	  cutPt = findPointOnLine(car(lineEq), cadr(lineEq), car(cutPt), cadr(cutPt))
	  objs = list(
	    caar(axlDBCreateLine(list(end1, cutPt), width, layer, nil, parent))
	    caar(axlDBCreateLine(list(cutPt, end2), width, layer, nil, parent))
	  )
	)
	("arc"
	  cutPt = findClosestPointOnArc(cutPt, end1, xy)
	  rpath = axlPathStart(list(end1))
	  rpath = axlPathArcCenter(rpath, width, cutPt, cw, xy)
	  obj = caar(axlDBCreatePath(rpath, layer, nil, parent))
	  objs = list(obj)
	  rpath = axlPathStart(list(cutPt))
	  rpath = axlPathArcCenter(rpath, width, end2, cw, xy)
	  objs = list(obj, caar(axlDBCreatePath(rpath, layer, nil, parent)))
	)
      )
      axlHighlightObject(objs)
      DRCbrowse_highlightedObjs = append(objs, DRCbrowse_highlightedObjs)
      foreach(grp, parentGroups, axlDBAddGroupObjects(grp, objs))
      foreach(segData, otherSegData
	width = cadr(segData), ends = caddr(segData)
	case(car(segData)
	  ("line", segment = caar(axlDBCreateLine(ends, width, layer, nil, parent)))
	  ("arc"
	    rpath = axlPathStart(list(car(ends)))
	    rpath = axlPathArcCenter(rpath, width, cadr(ends), cadddr(segData), nth(4, segData))
	    segment = caar(axlDBCreatePath(rpath, layer, nil, parent))
	  )
	)
	foreach(grp, parentGroups, axlDBAddGroupObjects(grp, segment))
      )
    )
  )
  objs
))

defun( DRCbrowse_ShrinkShape (form, obj)
 let((bBox, fill, layer, parent, parentGroups, pc, ext, decr, poly, objPoly, newObj)
  foreach(attr, '(bBox, fill, layer, parent, parentGroups), set(attr, get(obj, attr)))
  pc = axlFormGetField(form, "changeVal")
  unless(pc > 100.0, pc = -pc)
  and(
    ext = max(caadr(bBox) - caar(bBox), cadadr(bBox) - cadar(bBox))
    decr = (pc / 100.0) * ext / 2.0
    poly = car(axlPolyFromDB(obj))
    objPoly = car(axlPolyExpand(poly, decr, 'ALL_ARC))
    axlDeleteObject(obj)
    newObj = car(axlDBCreateShape(objPoly, fill, layer, nil, parent))
  )
  when(newObj
    when(axlHighlightObject(newObj), DRCbrowse_highlightedObjs = consx(newObj, DRCbrowse_highlightedObjs))
    foreach(grp, parentGroups, axlDBAddGroupObjects(grp, newObj))
  )
  newObj
))

defun( DRCbrowse_getObj (drcid)
  car(setof(vObj, drcid ->violations, and(vObj ->layer, !index(vObj ->layer, "SOLDERMASK"))))
)

defun( DRCbrowse_displayDrcInfo (form, drcid)
 let((layer, visibleLayers, vLoc, objType, side, sides, smLayer, pins, obj, action
      chgVal, chgValLabel, chgUnits, chgMin, chgMax, field, symb, otherObj)
  layer = drcid ->layer
  and(layer, !axlIsVisibleLayer(layer), DRCbrowse_tempLayers = list(layer))
  axlFormListAddItem(form, "drcInfo", nil, -1)
  axlFormListDeleteAll(form, "drcInfo")
  axlFormListAddItem(form, "drcInfo", "Violating objects:", -1)
  when(axlFormGetField(form, "filterLayers")
    foreach(layerInfo, setof(lay, axlVisibleGet(), lay ->visible)
      foreach(subclassInfo, setof(subInf, layerInfo ->subclassinfo, cadr(subInf))
	visibleLayers = cons(strcat(layerInfo ->class, "/" car(subclassInfo)), visibleLayers)
      )
    )
  )
  foreach(vObj, drcid ->violations
    layer = vObj ->layer
    vLoc = vObj ->xy
    objType = vObj ->objType
    unless(vLoc, vLoc = getRectangleCentre(vObj ->bBox))
    sprintf(vLoc, "%2.3f:%2.3f", car(vLoc), cadr(vLoc))
    cond(
      (layer
	case(objType
	  ("text", axlFormListAddItem(form, "drcInfo", sprintf(nil, "- Text ('%s') on layer %s at %s", vObj ->text, layer, vLoc) -1))
	  ("path", axlFormListAddItem(form, "drcInfo", sprintf(nil, "- Line on layer %s at %s", layer, vLoc) -1))
	  ("shape", axlFormListAddItem(form, "drcInfo", sprintf(nil, "- Shape on layer %s at %s", layer, vLoc) -1))
	  ("polygon", axlFormListAddItem(form, "drcInfo", sprintf(nil, "- Polygon on layer %s at %s", layer, vLoc) -1))
	)
	and(!axlIsVisibleLayer(layer)
	  !member(layer, DRCbrowse_tempLayers)
	  DRCbrowse_tempLayers = cons(layer, DRCbrowse_tempLayers)
	)
	side = ASU_getLayerSide(layer)
	sides = consx(side, sides)
	foreach(smClass, ASU_soldermaskClasses
	  smLayer = strcat(smClass, "/SOLDERMASK_", side)
	  and(!axlIsVisibleLayer(smLayer)
	    !member(smLayer, DRCbrowse_tempLayers)
	    DRCbrowse_tempLayers = cons(smLayer, DRCbrowse_tempLayers)
	  )
	)
	and(
	  objType == "text"
	  axlFormGetField(ASU_startForm, "textloc")
	  car(remove(vObj, drcid ->violations)) ->objType == "text"
	  symb = vObj ->parent
	  symb ->objType == "symbol"
	  smLayer = strcat("PACKAGE GEOMETRY/PLACE_BOUND_", side)
	  !axlIsVisibleLayer(smLayer)
	  !member(smLayer, DRCbrowse_tempLayers)
	  DRCbrowse_tempLayers = cons(smLayer, DRCbrowse_tempLayers)
	)
	foreach(vLayer, visibleLayers
	  and(
	    (substring(vLayer, -3) == "TOP" || substring(vLayer, -6) == "BOTTOM")
	    substring(vLayer, -strlen(side)) != side
	    !member(vLayer, DRCbrowse_hiddenLayers)
	    DRCbrowse_hiddenLayers = cons(vLayer, DRCbrowse_hiddenLayers)
	    axlVisibleLayer(vLayer, nil)
	  )
	)
      )
      (objType == "pin"
	pins = cons(list(vObj "PIN"), pins)
	axlFormListAddItem(form, "drcInfo", sprintf(nil, "- Pin pad on pin at %s", vLoc) -1)
      )
      (objType == "via"
	pins = cons(list(vObj "VIA CLASS"), pins)
	axlFormListAddItem(form, "drcInfo", sprintf(nil, "- Via pad on pin at %s", vLoc) -1)
      )
    )
  )
  axlFormListAddItem(form, "drcInfo", nil, -1)
  foreach(pcbSide, sides
    foreach(pin, pins
      foreach(end, car(pin) ->startEnd
	and(car(last(parseString(end, "/_"))) == pcbSide
	  layer = strcat(cadr(pin), "/", DRCbrowse_padSubclass, "_", pcbSide)
	  axlDBGetPad(car(pin), layer, "REGULAR")
	  !axlIsVisibleLayer(layer)
	  !member(layer, DRCbrowse_tempLayers)
	  DRCbrowse_tempLayers = cons(layer, DRCbrowse_tempLayers)
	)
      )
    )
  )
  if(drcid then
    foreach(tempLayer, DRCbrowse_tempLayers, axlVisibleLayer(tempLayer, t))
    when(DRCbrowse_tempLayers, axlFlushDisplay())
    axlHighlightObject(drcid)
    if(axlFormGetField(form, "zoomEnable")
     then zoomToLocation(drcid ->xy, axlFormGetField(form, "zoomExt") / 2.0)
     else ASU_tweakDisplay()
    )
    obj = DRCbrowse_getObj(drcid)
    otherObj = car(remove(obj, drcid ->violations))
    objType = obj ->objType
    case(objType
      ("text"
	when(otherObj ->objType == "shape" || otherObj ->objType == "polygon", axlHighlightObject(otherObj))
	axlFormSetFieldVisible(form, "textblk", 1)
	axlFormSetFieldVisible(form, "txtblktitle", 1)
	axlFormSetFieldVisible(form, "aligntext", 1)
	axlFormSetFieldVisible(form, "changeValUnits", 1)
	axlFormSetFieldEditable(form, "changeVal", 0)
	axlFormSetFieldVisible(form, "cutLine", 0)
	axlFormSetFieldEditable(form, "cutLine", 0)
	chgVal = obj ->textBlock, chgMin = 1, chgMax = axlDBControl('maxTextBlock)
	action = "Change text size", chgValLabel = "Text Block:"
	chgUnits = DRCbrowse_getTextBlkStr(chgVal)
      )
      ("path"
	axlFormSetFieldVisible(form, "textblk", 0)
	axlFormSetFieldVisible(form, "txtblktitle", 0)
	axlFormSetFieldVisible(form, "aligntext", 0)
	axlFormSetFieldVisible(form, "changeValUnits", 1)
	axlFormSetFieldEditable(form, "changeVal", 1)
	axlFormSetFieldVisible(form, "cutLine", 1)
	axlFormSetFieldEditable(form, "cutLine", 1)
	chgMin = 0, chgMax = axlDistance(car(car(obj ->segments) ->startEnd), cadr(car(obj ->segments) ->startEnd))
	chgVal = chgMax / 10.0
	action = "Trim line", chgValLabel = "Trim by:"
	chgUnits = car(AFn_getDesignUnits())
      )
      ("shape"
	axlFormSetFieldVisible(form, "textblk", 0)
	axlFormSetFieldVisible(form, "txtblktitle", 0)
	axlFormSetFieldVisible(form, "aligntext", 0)
	axlFormSetFieldVisible(form, "changeValUnits", 1)
	axlFormSetFieldEditable(form, "changeVal", 1)
	axlFormSetFieldVisible(form, "cutLine", 0)
	axlFormSetFieldEditable(form, "cutLine", 0)
	action = "Shrink shape"
	chgValLabel = "      By:", chgVal = 10, chgUnits = "%", chgMin = 1, chgMax = 999
      )
      ("polygon"
	axlFormSetFieldVisible(form, "textblk", 0)
	axlFormSetFieldVisible(form, "txtblktitle", 0)
	axlFormSetFieldVisible(form, "aligntext", 0)
	axlFormSetFieldVisible(form, "changeValUnits", 1)
	axlFormSetFieldEditable(form, "changeVal", 1)
	axlFormSetFieldVisible(form, "cutLine", 0)
	axlFormSetFieldEditable(form, "cutLine", 0)
	action = "Shrink shape"
	chgValLabel = "      By:", chgVal = 10, chgUnits = "%", chgMin = 1, chgMax = 999
      )
    )
    foreach(act, '("Move", "Rotate", "Remove", "Change")
      field = strcat(lowerCase(act), "Obj")
      axlFormSetFieldEditable(form, field, 0)
      when(objType == "path", objType = "line")
      if(act == "Change" then
        axlFormSetField(form, field, action)
	cond(
	  (objType == "text" && axlFormGetField(form, "textblk") == "", nil)
	  (t, axlFormSetFieldEditable(form, field, 1))
	)
       else
        axlFormSetField(form, field, strcat(act, " ", objType))
        axlFormSetFieldEditable(form, field, 1)
      )
    )
    when(obj ->parent ->objType == "symbol", axlFormSetFieldEditable(form, "moveSymb", 1))
    axlFormSetField(form, "chgValLabel", chgValLabel)
    axlFormSetField(form, "changeVal", chgVal)
    axlFormSetField(form, "changeValUnits", chgUnits)
    axlFormSetFieldLimits(form, "changeVal", chgMin, chgMax)
    foreach(chgField, '("chgValLabel", "changeValUnits", "removeDRC", "textblk")
      axlFormSetFieldEditable(form, chgField, 1)
    )
   else foreach(chgField, DRCbrowse_modFields, axlFormSetFieldEditable(form, chgField, 0))
  )
))

defun( DRCbrowse_getTextBlkStr (txtBlk)
 let((tbParam, txtHgt, photoWidth, units)
  when(numberp(txtBlk), sprintf(txtBlk, "%d", txtBlk))
  tbParam = axlGetParam(sprintf(nil, "paramTextBlock:%s", txtBlk))
  txtHgt = tbParam ->height, photoWidth = tbParam ->photoWidth
  units = car(AFn_getDesignUnits())
  sprintf(nil, "Hgt:%3.2f, Apt:%3.2f %s", txtHgt, photoWidth, units)
))

defun( DRCbrowse_recalcDRCs (obj, drcLayer)
 let((value, associatedDRCs, drcid, objType, spacing, pinChk, viaChk, smShpChk, solderedPadsOnlyChk, txtChk, refdesLocChk)
  foreach(drc, mapcar('DRCbrowse_getDRCID, mapcar('caddr, DRCbrowse_drcList))
    and(member(obj, drc ->violations)
      value = AFn_getProperty(drc, "DRCBROWSE_INDEX")
      !member(value, associatedDRCs)
      associatedDRCs = cons(value, associatedDRCs)
    )
  )
  foreach(drcIndex, associatedDRCs
    drcid = DRCbrowse_getDRCID(drcIndex)
    axlDeleteObject(drcid, t)
    axlDBRefreshId(nil)
    axlFlushDisplay()
  )
  objType = obj ->objType
  spacing = case(objType
    ("text", axlFormGetField(ASU_startForm, "txtspc"))
    ("shape", axlFormGetField(ASU_startForm, "shpspc"))
    ("polygon", axlFormGetField(ASU_startForm, "shpspc"))
    ("path", axlFormGetField(ASU_startForm, "linespc"))
  )
  pinChk = axlFormGetField(ASU_startForm, "pins")
  solderedPadsOnlyChk = axlFormGetField(ASU_startForm, "solderedpads")
  viaChk = axlFormGetField(ASU_startForm, "vias")
  smShpChk = axlFormGetField(ASU_startForm, "smShps")
  txtChk = axlFormGetField(ASU_startForm, "text")
  when(txtChk && axlFormGetField(ASU_startForm, "quickchk"), txtChk = "QUICK")
  
  refdesLocChk = axlFormGetField(ASU_startForm, "textloc")
  ASU_checkObj(obj, spacing, drcLayer, pinChk, viaChk, smShpChk, solderedPadsOnlyChk, txtChk, refdesLocChk)
))

defun( DRCbrowse_regenDrcList (form @optional obj)
 let((drcs, drcList, drcid, selected, selectedDRC (drcPos 0))
  drcs = findByProperty("DRC", "EXTERNAL_VIOLATION_DESCRIPTION")
  when(drcs, drcs = DRCbrowse_sort(drcs, "ByLocation"))
  drcList = DRCbrowse_getDRClist(drcs)
  axlFormListDeleteAll(form, "drclist")
  axlFormListDeleteAll(form, "drcInfo")
  foreach(drc, drcList
    axlFormSetField(form, "drclist", car(drc))
    drcid = DRCbrowse_getDRCID(caddr(drc))
    if(obj && (obj == DRCbrowse_getObj(drcid)) then
      selected = drcPos
      selectedDRC = drcid
      DRCbrowse_drcInfo = drc
     else
      when(drcid ->xy, axlDehighlightObject(drcid))
    )
    drcPos++
  )
  axlFormSetField(form, "drclist", nil); nil required first time list is displayed
  DRCbrowse_drcList = drcList
  axlFormMsg(form, "drcCount", length(DRCbrowse_drcList))
  if(selected then
    axlFormListSelect(form, "drclist", selected)
    axlHighlightObject(selectedDRC)
    DRCbrowse_displayDrcInfo(form, selectedDRC)
    axlFormSetFieldEditable(form, "removeDRC", 1)
   else
    DRCbrowse_drcInfo = nil
    axlFormSetFieldEditable(form, "removeDRC", 0)
  )
))

defun( DRCbrowse_QuitForm (form)
  and(fboundp('axlDBTransactionCommit), DRCbrowse_transactionMark, axlDBTransactionCommit(DRCbrowse_transactionMark))
  DRCbrowse_removeObjectHilights()
  axlFormClose(form)
  axlCancelEnterFun()
  axlUIWShow(ASU_startForm, 'show)
  foreach(layer, DRCbrowse_tempLayers, axlVisibleLayer(layer, nil))
  foreach(layer, DRCbrowse_hiddenLayers, axlVisibleLayer(layer, t))
  axlFlushDisplay()
  axlVisibleUpdate(nil)
)

defun( DRCbrowse_getDRCID (drcIndex)
  when(drcIndex, 
    when(integerp(drcIndex), sprintf(drcIndex, "%d", drcIndex))
    car(findByProperty("DRC", "DRCBROWSE_INDEX", drcIndex))
  )
)

defun( DRCbrowse_getDRClist (drcs)
 let((descr, (n 0), drcList)
  foreach(drc, drcs
    descr = drc ->prop ->EXTERNAL_VIOLATION_DESCRIPTION || "No description"
    axlDBAddProp(drc, list("DRCBROWSE_INDEX", n))
    drcList = cons(list(descr, drc ->xy, sprintf(nil, "%d", n++)), drcList)
  )
  drcList
))

defun( DRCbrowse_sort (drcs, sortType)
 let((loc, x, y, minx, miny, unsorted, sortedBLtoTR, drc0, minDist, drcid, dist, closestDRC, sortedFinal)
  case(sortType
    ("ByLocation"
      foreach(drc, drcs
	loc = drc ->xy, x = car(loc), y = cadr(loc)
	minx = if(minx then min(x, minx) else x)
	miny = if(miny then min(y, miny) else y)
      )
      foreach(drc, drcs, unsorted = cons(list(axlDistance(minx:miny, drc ->xy), drc), unsorted))
      sortedBLtoTR = mapcar(lambda((drcInfo) cadr(drcInfo)), sortcar(unsorted, 'lessp))
      drc0 = car(sortedBLtoTR)
      sortedFinal = list(drc0), sortedBLtoTR = cdr(sortedBLtoTR)
      while(sortedBLtoTR
        minDist = nil
	for(i, 0, 5
	  drcid = nth(i, sortedBLtoTR)
	  when(drcid
	    dist = axlDistance(drcid ->xy, drc0 ->xy)
	    if(minDist
	     then when(dist < minDist, minDist = dist, closestDRC = drcid)
	     else minDist = dist, closestDRC = drcid
	    )
	  )
	)
	drc0 = closestDRC
	sortedFinal = cons(closestDRC, sortedFinal)
	sortedBLtoTR = remd(closestDRC, sortedBLtoTR)
      )
    )
    (t, sortedFinal = drcs)
  )
  sortedFinal
))

/*******************************************/
/***	   GENERIC SUBROUTINES		 ***/
/*******************************************/

;Finds all objects on selected layers of nominated type(s) with optional:
;  layers, attribute pairs, properties, and either bounding box or near a point.
defun( findTypeObjects (types @key visibleOnly, layers, attrPairs, props, bbox, point, xy)
 let((oldSetData, onButtons, enabledTypes, selSet, propVal)
  unless(listp(types), types = list(types))
  unless(listp(layers), layers = list(layers))
  when(!layers || (layers = setof(layer, layers, axlIsLayer(layer)))
    oldSetData = list(axlGetSelSet(), axlGetFindFilter(nil), axlGetFindFilter(t))
    onButtons = cons("noall", types)
    axlClearSelSet()
    if(visibleOnly || (layers && forall(layer, layers, axlIsVisibleLayer(layer)))
     then enabledTypes = onButtons
     else enabledTypes = append1(onButtons, "invisible")
    )
    axlSetFindFilter(?enabled enabledTypes, ?onButtons onButtons)
    cond(
      (bbox, axlAddSelectBox(bbox))
      (point, while(axlAddSelectPoint(point), t)); necessary to add all objects at point
      (xy, while(axlAddSelectPoint(xy), t))
      (t, axlAddSelectAll())
    )
    selSet = axlGetSelSet()
    when(layers
      layers = mapcar('upperCase, layers)
      selSet = setof(obj, selSet, member(obj ->layer, layers))
    )
    when(attrPairs
      unless(listp(car(attrPairs)), attrPairs = list(attrPairs))
      selSet = setof(obj, selSet, forall(pair, attrPairs, get(obj, car(pair)) == cadr(pair)))
    )
    when(props
      unless(listp(car(props)), props = list(props))
      selSet = setof(obj, selSet
	forall(pair, props, and(propVal = get(obj ->prop, car(pair)), or(!cadr(pair), propVal == cadr(pair))))
      )
    )
    when(xy, selSet = setof(obj, selSet, samePoint(obj ->xy, xy)))
    axlSetFindFilter(?enabled cons("noall", cadr(oldSetData)) ?onButtons cons("noall", caddr(oldSetData)))
    axlSingleSelectObject(car(oldSetData))
  )
  selSet
))

defun( findByProperty (objTypes, property @optional value, regularExpression)
 let((oldSetData, objs)
  oldSetData = list(axlGetSelSet(), axlGetFindFilter(nil), axlGetFindFilter(t))
  unless(listp(objTypes), objTypes = list(objTypes))
  objs = if(value
   then mapcan(lambda((objType), axlSelectByProperty(lowerCase(objType), property, value, regularExpression)), objTypes)
   else mapcan(lambda((objType), axlSelectByProperty(lowerCase(objType), property)), objTypes)
  )
  axlSetFindFilter(?enabled cons("noall", cadr(oldSetData)) ?onButtons cons("noall", caddr(oldSetData)))
  axlSingleSelectObject(car(oldSetData))
  objs
))

defun( getRectangleCentre (exts) list((caar(exts) + caadr(exts)) / 2.0, (cadar(exts) + cadadr(exts)) / 2.0))

defun( GeoRotatePts (angle, pts @optional (origin '(0 0))) mapcar(lambda((pt), axlGeoRotatePt(angle, pt, origin)), pts)); angle in degrees (negative angle rotates clockwise).

defun( zoomToLocation (loc @optional dx)
 let((wBox, aspectRatio, dy, x, y)
  unless(dx, dx = axlMKSConvert(500, "mils"))
  wBox = axlWindowBoxGet()
  aspectRatio = (cadadr(wBox) - cadar(wBox)) / (caadr(wBox) - caar(wBox))
  dy = dx * aspectRatio
  x = car(loc), y = cadr(loc)
  axlWindowBoxSet(list(x - dx:y - dy, x + dx:y + dy))
))

defun( getUINumber (promptText @optional defaultValue, minLimit, maxLimit)
 let((result)
  if(numberp(defaultValue)
   then sprintf(defaultValue, "%g" float(defaultValue))
   else defaultValue = "")
  cond(
    (minLimit && maxLimit, sprintf(promptText, "%s (%L < n < %L)", promptText, minLimit, maxLimit))
    (minLimit, sprintf(promptText, "%s (%L < n)", promptText, minLimit))
    (maxLimit, sprintf(promptText, "%s (n < %L)", promptText, maxLimit))
  )
  while(result != "CANCEL" && (!numberp(result) || (minLimit && result < minLimit) || (maxLimit && result > maxLimit))
    result = axlUIPrompt(promptText, defaultValue)
    if(result then result = car(errsetstring(result)) else result = "CANCEL")
  )
  when(result == "CANCEL", result = nil)
  result
))

defun( AFn_getProperty (obj, name, "gt")
 let((value, dataType)
  unless(obj, obj = axlDBGetDesign())
  and(
    obj ->prop ->??; This line is necessary to force get(obj ->prop...) to work correctly. DE 16-Mar-07
    value = get(obj ->prop, upperCase(name)); This method handles strings longer than 512 (Up to 1023).
    dataType = axlDBGetPropDictEntry(name) ->dataType
    (dataType == "INTEGER" || dataType == "REAL"), value = evalstring(value)
  )
  value
))

;Removes all externally generated DRCs:
defun( removeExternalDRCs ()
 let((drcs, n)
  drcs = getExternalDRCs()
  n = length(drcs)
  axlDeleteObject(drcs)
  n
))

;Returns all externally generated DRCs:
defun( getExternalDRCs ()
  unless(axlDBGetPropDictEntry("EXTERNAL_VIOLATION_DESCRIPTION") == '("drcs"), axlDBCreatePropDictEntry("EXTERNAL_VIOLATION_DESCRIPTION", "STRING" "drcs"))
  axlSelectByProperty("DRC", "EXTERNAL_VIOLATION_DESCRIPTION")
)

;Add or delete an object property:
;Pass db Object, name of property and value ... to this function
; If value of "?" is passed, returns the value of the named property in the design - nil if no value or property found.
; If value is nil, the property is deleted.
defun( AFn_addProperty (dbObj, propName, propVal @optional dataType, objTypes, valRange, units, hidden)
 let((value, propDict, errMsg)
  dataType = or(dataType, axlDBGetPropDictEntry(propName) ->dataType
    cond((!propVal, nil), (propVal == t, 'boolean), (type(propVal) == 'list, 'string), (t, type(propVal)))
  )
  dataType = caseq(dataType (string "STRING") (fixnum "INTEGER") (flonum "REAL") (boolean "BOOLEAN") (t dataType))
  objTypes = objTypes || case(dbObj ->objType
    ("polygon", '("lines", "shapes"))
    ("shape", '("lines", "shapes"))
    ("path", '("clines", "lines", "shapes"))
    ("symbol", "symbols")
    ("component", "components")
    (t, "designs")
  )
  valRange = valRange || '(nil, nil)
  propDict = axlDBGetPropDictEntry(propName) || !propVal
  unless(propDict 
    propDict = cond(
      (hidden, axlDBCreatePropDictEntry(propName, dataType, objTypes, valRange, units || "", hidden))
      (units, axlDBCreatePropDictEntry(propName, dataType, objTypes, valRange, units))
      (t, axlDBCreatePropDictEntry(propName, dataType, objTypes, valRange))
    )
  )
  cond(
    (!propDict, errMsg = "Error: Problem Creating Property Dictionary Entry.")
    (propVal && axlDBAddProp(list(dbObj || axlDBGetDesign()), list(propName, propVal)), value = propVal)
    (!propVal, axlDBDeleteProp(dbObj, propName))
    (setof(item, propDict ->objects, member(item, objTypes)) != propDict ->objects, errMsg = "Error: propDict entry already defined differently.")
    (t, errMsg = "Error: Unknown problem.")
  )
  axlDBRefreshId(dbObj); DE 27-Nov-07
  when(errMsg, printf("%s Property '%s' not added to %s\n", errMsg, propName, dbObj ->name || dbObj ->objType || "design"))
  value
))

defun( AFn_unFixObject (obj)
 let((fixedObj, fixedObjs)
  when(obj ->objType; Check that the dbid has not been removed.
    while(fixedObj = axlDBIsFixed(obj); Returns first item found that causes element to be fixed (could be more then one)
      when(fixedObj = caar(axlDBDeleteProp(fixedObj, "FIXED")), fixedObjs = cons(fixedObj, fixedObjs))
    )
  )
  fixedObjs
))

;Exclusive cons (only cons an item if it doesn't already exist in the list):
defun( consx (item items), unless(member(item, items), items = cons(item, items)), items)

defun( lineEquation (x1, y1, x2, y2)
 let((m, b)
;  Returns m b s.t. y = mx + b is the equation for the line
;    joining points (x1,y1) and (x2,y2)
;  Returns nil, b if a vertical line (ie. x = b)
  x1 = float(x1), y1 = float(y1), x2 = float(x2), y2 = float(y2)
  cond(
    (same(x1, x2), list(nil, x1))
    (t, m = (y2 - y1) / (x2 - x1), b = y2 - m * x2, list(m, b))
  )
))

defun( lineLineIntersect (m1, b1, m2, b2)
 let((x)
;  Returns x,y intersection of line
;     y = m1 x + b1
;  with line
;     y = m2 x + b2
;  Returns nil if no or infinite no of points (i.e. m1 = m2)
;
;  m1x + b1 = m2x + b2
;  x = (b2 - b1)/(m1 - m2)
;  y = m1 x + b1
  cond(
    (!m1 && !m2, nil)
    (!m1, list(b1, m2 * b1 + b2)) ; ie. x = b1 for first line (not both nil!)
    (!m2, list(b2, m1 * b2 + b1)) ; ie. x = b2 for 2nd line (not both nil!)
    (m1 == m2, nil)
    (t, x = (b2 - b1) / (m1 - m2), list(x, m1 * x + b1))
  )
))

defun( findPointOnLine (m1, b1, x, y)
 let((m2, b2)
  cond(
    (!m1, list(b1, y))
    (same(m1, 0), list(x, b1))
    (t, m2 = -1.0 / float(m1), b2 = y + x / float(m1), lineLineIntersect(m1, b1, m2, b2))
  )
))

defun( same (x1, x2 @optional tolp, tolm)
  unless(tolp, tolp = expt(10, -2 - cadr(axlDBGetDesignUnits())))
  cond(
    (!x1 && !x2, t); Both are nil
    (!x1 || !x2, nil) ; One, and only one, is nil
    (!tolm && abs(x1 - x2) > tolp, nil)
    (tolm && x1 - x2 > tolp, nil)
    (tolm && x2 - x1 > tolm, nil)
    (t, t)
  )
)

defun( samePoint (pt1, pt2, @optional tolp, tolm)
  unless(tolp, tolp = expt(10, -2 - cadr(axlDBGetDesignUnits())))
  and(same(car(pt1), car(pt2), tolp, tolm), same(cadr(pt1), cadr(pt2), tolp, tolm))
)

defun( sameLine (ends1, ends2, @optional tolp, tolm)
 let((a1, a2, b1, b2)
  unless(tolp, tolp = expt(10, -2 - cadr(axlDBGetDesignUnits())))
  a1 = car(ends1), a2 = cadr(ends1), b1 = car(ends2), b2 = cadr(ends2)
  or(
    and(samePoint(a1, b1, tolp, tolm), samePoint(a2, b2, tolp, tolm))
    and(samePoint(a1, b2, tolp, tolm), samePoint(a2, b1, tolp, tolm))
  )
))

defun( orthogonalp (ang), and(round(ang) == ang, zerop(mod(round(ang), 90))))

defun( findClosestPointOnArc (pt, arcEnd, arcCentre)
 let((r, d, x, y)
  r = axlDistance(arcEnd, arcCentre)
  d = axlDistance(pt, arcCentre)
  x = car(arcCentre), y = cadr(arcCentre)
  list(x - r * (x - car(pt)) / d, y - r * (y - cadr(pt)) / d)
))

defun( trimLineSegment (end1, end2, shorten_len)
 let((x1, y1, x2, y2, len, diff_len)
  x1 = car(end1), y1 = cadr(end1), x2 = car(end2), y2 = cadr(end2)
  len = axlDistance(end1, end2)
  when(len > shorten_len
    diff_len = len - shorten_len
    x2 = x1 + diff_len * (x2 - x1) / len
    y2 = y1 + diff_len * (y2 - y1) / len
  )
  list(x1:y1, x2:y2)
))

defun( AFn_getDesignUnits ()
 let((unitsInfo, units, precision)
  unitsInfo = axlDBGetDesignUnits()
  precision = cadr(unitsInfo)
  units = car(unitsInfo), when(units == "millimeters", units = "mm")
  list(units, precision)
))

defun( AFn_displayHelpText (title, helpTxts @optional topic)
 let(((txt ""), p, subject)
  if(topic then
    txt = car(setof(hlpTopic, helpTxts,  car(hlpTopic) == topic))
    sprintf(txt, "%s\n%s\n%s", car(txt), strRepeat("=", strlen(car(txt))), buildString(cdr(txt), "\n"))
    axlUIConfirm(txt)
   else
    p = axlDMOpenFile("MISC", "temp_help.txt", "w")
    if(p then
      fprintf(p, "%s\n", title)
      fprintf(p, "%s\n", strRepeat("-", strlen(title)))
      rexCompile(".") 
      foreach(helpTopic, helpTxts
	subject = cdr(helpTopic)
	if(subject then
	  fprintf(p, "'%s' - %s\n", car(helpTopic), car(subject))
	  foreach(line, cdr(subject), fprintf(p, "  %s\n", line))
	 else fprintf(p, "\n%s\n%s\n", car(helpTopic), rexReplace(car(helpTopic) "-" 0))
	)
      )
      drain(p)
      axlDMClose(p)
      axlUIViewFileCreate("temp_help.txt", title, t)
     else axlUIConfirm("Error: Could not create temporary help text file", 'error)
    )
  )
))

defun( AFn_getAirGap (obj1, obj2, @optional layer, fullOption)
  if(isCallable('axlAirGap), axlAirGap(obj1, obj2, layer, fullOption), _fpUtilCalculateAirGap(obj1, obj2))
)

defun( AFn_transformObject (obj @key move, mirror, angle, origin, allOrNone)
 let((layer, layerVisible, transObjs, cmd)
  layer = if(listp(obj), car(obj), obj) ->layer
  when(layer, layerVisible = axlIsVisibleLayer(layer), unless(layerVisible, axlVisibleLayer(layer, t)))
  cmd = "axlTransformObject(obj"
  when(move, cmd = strcat(cmd, " ?move move"))
  when(mirror, cmd = strcat(cmd, " ?mirror mirror"), unless(angle, angle = 0)); angle required to force mirror (bug?)
  when(angle, cmd = strcat(cmd, " ?angle angle"))
  when(origin, cmd = strcat(cmd, " ?origin origin"))
  when(allOrNone, cmd = strcat(cmd, " ?allOrNone allOrNone"))
  cmd = strcat(cmd, ")")
  transObjs = evalstring(cmd)
  and(layer, !layerVisible, axlVisibleLayer(layer, nil))
  transObjs
))

defun( strRepeat (str, n) let(((out "")) for(i, 1, n, out = strcat(out, str)), out))

defun( numberToString (n) cond((integerp(n), sprintf(nil, "%d", n)) (numberp(n), sprintf(nil, "%g", n)) (t, n)))

defun( readNumberString (txt), readstring(ltrim(txt, "0"))); Stripping leading zeros ensures number is not read as octal. readstring("0...") and evalstring("0...") return octal conversions.

defun( ltrim (txt @optional (ch " ")), while(txt && substring(txt, 1, strlen(ch)) == ch, txt = substring(txt, strlen(ch) + 1)), txt || "")

defun( AFn_newTempFile (@optional id, name)
 let((tempFolder)
  id = id || "TEMP"
  name = name || gensym("allegroTemp")
  tempFolder = AFn_getTempDir()
  axlDMOpenFile(id, if(tempFolder && isDir(tempFolder), strcat(tempFolder "\\", name), name), "w")
))

defun( AFn_getTempDir ()
  cond(
    (axlGetVariable("TEMP") && !index(axlGetVariable("TEMP"), "~"), axlGetVariable("TEMP"))
    (getTempDir() && !index(getTempDir(), "~"), getTempDir())
    (isDir("c:\\temp"), "c:\\temp")
    (createDir("c:\\temp"), "c:\\temp")
    (t, ".")
  )
)

defun( AFn_getVectorFontChLines (ch, w, h, x, y @optional fontData, fontFile)
  unless(fontData, fontData = AFn_vectorFontData(fontFile))
  mapcar(lambda((l), mapcar(lambda((pt), list(x + w * car(pt), y + h * cadr(pt))), l)), cadr(assoc(ch, fontData) || assoc("RECT", fontData)))
)

defun( AFn_vectorFontData (@optional fontFile)
 let((fontData, p, ln, data, widFact, hgtFact, ch, x, y, pts, chPts, minY, maxY)
  unless(fontFile, fontFile = axlGetVariable("ansifont") || "ansifont")
  p = axlDMOpenFile("VECTORFONT", fontFile, "r"); Looks for the font file in share\pcb\text
  if(p then
    fontData = list(list(" ", nil), list("RECT", list(list(0.1:0, 0.1:1, 0.9:1, 0.9:0, 0.1:0)))); Include the space character and rectangle for missing/system characters
    while(gets(ln, p)
      data = linereadstring(ln)
      cond(
	(zerop(car(data)), t)
	(car(data) == 'Width,  widFact = float(cadr(data)))
	(car(data) == 'Height, hgtFact = float(cadr(data)))
	(index(ln, "***")
	  ch = caddr(parseString(ln))
	  for(i, 1, car(data)
	    ln = linereadstring(gets(ln, p)), x = cadr(ln) / widFact, y = caddr(ln) / hgtFact
	    pts = if(onep(car(ln)) then when(pts, chPts = append1(chPts, pts)), list(x:y) else append1(pts, x:y))
	    minY = if(minY, min(y, minY), y), maxY = if(maxY, max(y, maxY), y)
	  )
	  fontData = cons(list(ch, append1(chPts, pts)), fontData), pts = chPts = nil
	)
      ); cond
    ); while
    axlDMClose(p)
   else
    printf("Error: '%s' vector font file not found\n", fontFile)
  )
  fontData
))

/*******************************************/
/***	    FORM SUBROUTINES		 ***/
/*******************************************/

defun( AFn_formOpenFile (@optional name), AFn_newTempFile("FORM", name))

;Create HEADER lines on a form:
defun( AFn_formHeader (port @optional (formWidth 36), (title "My Form"))
  fprintf(port, "FILE_TYPE=FORM_DEFN VERSION=2\nFORM\nFIXED\nPORT %d 10\n", formWidth)
  fprintf(port, "HEADER \"%s\"\n", title)
  fprintf(port, "TILE\n")
)

defun( AFn_formEnd (port), fprintf(port, "ENDTILE\nENDFORM\n"), drain(port))

defun( AFn_formPopupDefine (port, popupName @optional (popPairs '("")))
 let((pair, (popPairsStr ""), tdisplay, tdispatch, (chCount 0))
  fprintf(port, "POPUP <%s> ", popupName)
  while(popPairs && chCount < 6000
    pair = car(popPairs), popPairs = cdr(popPairs)
    if(listp(pair) then tdisplay = car(pair), tdispatch = cadr(pair) else tdisplay = tdispatch = pair)
    when(numberp(tdisplay), tdisplay = numberToString(tdisplay))
    when(numberp(tdispatch), tdispatch = numberToString(tdispatch))
    sprintf(popPairsStr, "%s \"%s\" \"%s\"", popPairsStr, tdisplay, tdispatch)
    chCount = chCount + strlen(popPairsStr)
    when(popPairs && chCount < 6000, sprintf(popPairsStr, "%s%s", popPairsStr, ","))
    when(strlen(popPairsStr) > 60 && popPairs
      fprintf(port, "%s\\\n", popPairsStr)
      popPairsStr = ""
    )
  )
  fprintf(port, "%s.\n", popPairsStr)
))

defun( AFn_formMessage (port, msgLabel @key (level 0), (msgString "%s"))
  sprintf(level, " %d", level)
  msgString = strcat(" \"", msgString, "\"")
  fprintf(port, "MESSAGE %s%s%s\n", msgLabel, level, msgString)
)

defun( AFn_formTabSetDispatch (port, x, lineNo, w, h @key (tabName "tab"))
  fprintf(port, "TABSET \"%s\"\n\tOPTIONS tabsetDispatch\n\tFLOC %d %d\n\tFSIZE %d %d\n", tabName, x, lineNo, w, h)
)

defun( AFn_formTab (port, title @optional (label "")), fprintf(port, "TAB \"%s\" %s\n", title, label))
defun( AFn_formEndTab (port), fprintf(port, "ENDTAB\n"))
defun( AFn_formEndTabSet (port), fprintf(port, "ENDTABSET\n"))

;Create a Group on a form:
defun( AFn_formGroup (port, displayTxt, x, lineNo, w, h @key (label "") infoLabel)
  unless(label == "", label = strcat(" ", label))
  infoLabel = AFn_formOptionalString("INFO", infoLabel)
  fprintf(port, "GROUP \"%s\"%s\n\tFLOC %d %d\n\tFSIZE %d %d\n%sENDGROUP\n", displayTxt, label, x, lineNo, w, h, infoLabel)
; GROUP "display" [label]
;	FLOC x lineNo
;	FSIZE w h
;	[INFO label]
; ENDGROUP
)

;Create a TEXT line on a form:
defun( AFn_formText (port, txt, x, lineNo @key info, fsize, options (label ""))
  info = AFn_formOptionalString("INFO", info)
  fsize = AFn_formSizeString(fsize)
  options = AFn_formOptionsString(options)
  fprintf(port, "TEXT \"%s\" %s\n\tTLOC %d %d\n%s%s%sENDTEXT\n", txt, label, x, lineNo, info, fsize, options)
; TEXT "display" [label]
;	FLOC x lineNo
;	[FSIZE w h]
;	text_type
;	[OPTIONS textOptions]
; ENDTEXT
)

;Create a Button on a form:
defun( AFn_formButton (port, label, txt, x, lineNo, w, h @key fsize, options, pop)
  fsize = AFn_formSizeString(fsize)
  options = AFn_formOptionsString(options)
  pop = AFn_formOptionalString("POP", pop)
  fprintf(port, "FIELD %s\n\tFLOC %d %d\n%s\tMENUBUTTON \"%s\" %d %d\n%s%sENDFIELD\n", label, x, lineNo, fsize, txt, w, h, options, pop)
; FIELD label
;	FLOC x lineNo
;	[FSIZE w h]
;	MENUBUTTON "display" w h
;	[OPTIONS button_options]
;	[POP "<popupName>"]
; ENDFIELD
)

;Create a List on a form:
defun( AFn_formList (port, label, txt, x, lineNo, w, h @key fsize, options)
  fsize = AFn_formSizeString(fsize)
  options = AFn_formOptionsString(options)
  fprintf(port, "FIELD %s\n\tFLOC %d %d\n%s\tLIST \"%s\" %d %d\n%sENDFIELD\n", label, x, lineNo, fsize, txt, w, h, options)
; FIELD label
;	FLOC x lineNo
;	[FSIZE w h]
;	LIST "display" w h
;	[OPTIONS list_options] ; (sort)
; ENDFIELD 
)

;Create a Checklist item on a form:
defun( AFn_formChecklistItem (port, label, x, lineNo, displayTxt @key (radioLabel ""))
  unless(radioLabel == "", radioLabel = strcat(" \"", radioLabel, "\""))
  fprintf(port, "FIELD %s\n\tFLOC %d %d\n\tCHECKLIST \"%s\"%s\nENDFIELD\n", label, x, lineNo, displayTxt, radioLabel)
; FIELD label
;	FLOC x lineNo
;	CHECKLIST "display" ["radioLabel"] ;radioLabel should be lower case
; ENDFIELD
)

;Create a REALFILLIN line on a form. A title is optional:
defun( AFn_formRealFillin (port, label, fillinWidth, fillinLength, x1, lineNo
  @key title, fillInX, (titleLabel ""), minVal, maxVal, value, decimalPlaces, dp, pop, units, options, infoOnly)
  if(title then
    fillInX = fillInX || strlen(title) + x1 - 2
    AFn_formText(port, title, x1, lineNo, ?label titleLabel)
   else fillInX = x1
  )
  if(minVal then sprintf(minVal, "\tMIN %L\n", minVal) else minVal = "")
  if(maxVal then sprintf(maxVal, "\tMAX %L\n", maxVal) else maxVal = "")
  if(value then sprintf(value, "\tVALUE %L\n", value) else value = "")
  infoOnly = AFn_formOptionalString("INFO_ONLY", infoOnly); if(infoOnly, "\tINFO_ONLY\n", "")
  sprintf(decimalPlaces, "\tDECIMAL %d\n", decimalPlaces || dp || cadr(axlDBGetDesignUnits()))
  pop = AFn_formOptionalString("POP", pop)
  options = AFn_formOptionsString(options)
  fprintf(port, "FIELD %s\n\tFLOC %d %d\n\tREALFILLIN %d %d\n%s%s%s%s%s%s%sENDFIELD\n",
    label, fillInX, lineNo, fillinWidth, fillinLength, options, minVal, maxVal, value, decimalPlaces, pop, infoOnly)
  when(units
    AFn_formText(port, units, fillInX + fillinWidth + if(pop == "", 2, 5), lineNo, ?label strcat(label, "Units"))
  )
; FIELD label
;	FLOC fillInX lineNo
;	REALFILLIN
;	field_options ...
;	MIN <n>
;	MAX <n>
;	VALUE <n>
;	DECIMAL n (defaults to 2)
;	POP "<string>"
;	INFO_ONLY
; ENDFIELD
)

;Create a Popup on a form:
defun( AFn_formPop (port, label, popDef, titlex, lineNo, enumset @key title, x2, titleLabel, units, options)
  if(title then
    x2 = x2 || titlex + round(strlen(title) * 0.8)
    AFn_formText(port, title, titlex, lineNo ?label titleLabel || strcat(label, "_title"))
   else x2 = titlex)
  options = AFn_formOptionsString(options)
  fprintf(port, "FIELD %s\n\tFLOC %d %d\n\tENUMSET %d\n\tPOP \"%s\"\n%sENDFIELD\n", label, x2, lineNo, enumset, popDef, options)
  when(units, AFn_formText(port, units, x2 + enumset + 3, lineNo, ?label strcat(label, "Units")))
; FIELD <label>
;	FLOC <x> <lineNo>
;	ENUMSET <enumset>
;	POP "<txt>"
; ENDFIELD
)

;Create a Thumbnail on a form:
defun( AFn_formThumbnail (port, label, x, lineNo, w, h @key (bitmap "") options)
 let(((fieldName "THUMBNAIL"))
  unless(bitmap == "", sprintf(fieldName, "THUMBNAIL %s", bitmap))
  options = AFn_formOptionsString(options)
  fprintf(port, "FIELD %s\n\t%s\n\tFLOC %d %d\n\tFSIZE %d %d\n%sENDFIELD\n", label, fieldName, x, lineNo, w, h, options)
; FIELD label
;	THUMBNAIL [bitmapFile]
;	FLOC x lineNo
;	FSIZE w h
;	[OPTIONS STRETCH]
; ENDFIELD 
))

defun( AFn_formOptionsString (options)
  when(listp(options), options = buildString(options, " "))
  unless(options == "", options = strcat("\tOPTIONS ", options, "\n"))
  options
)

defun( AFn_formSizeString (fsize)
  cond(
    ((fsize == "") || !fsize, "")
    (listp(fsize), sprintf(nil, "\tFSIZE %d %d\n", car(fsize), cadr(fsize)))
    (t, sprintf(nil, "\tFSIZE %s\n", fsize))
  )
)

defun( AFn_formOptionalString (fieldName, value)
  cond(
    (stringp(value), sprintf(nil, "\t%s %s\n", fieldName, value))
    (value, sprintf(nil, "\t%s\n", fieldName))
    (t, "")
  )
)

/****************************************************************/

defun( tait_logoThumbnail (handle)
  axlGRPDrwMapWindow(handle, 140, 140)
  putprop(handle, 1, 'width)
  putprop(handle, "filled", 'fill)
  putprop(handle, "white", 'color)
  axlGRPDrwCircle(handle, 70:70, 70)
  putprop(handle, "blue", 'color)
  axlGRPDrwCircle(handle, 70:70, 70)
  putprop(handle, "white", 'color)
  axlGRPDrwPoly(handle, list(20:97 55:50 29:50 35:45 135:45 138:50 120:50 120:97 112:97 112:50 64:50 28:97 20:97)); T T
  axlGRPDrwPoly(handle, list(41:97 71:57 86:57 86:97 78:97 78:62 51:97 41:97)); Outline of A
  axlGRPDrwPoly(handle, list(55:88 62:84 78:84 78:88 55:88)); Bar in A
  axlGRPDrwPoly(handle, list(95:57 103:57 103:97 95:97 95:57)); I
  putprop(handle, "blue", 'color)
  axlGRPDrwCircle(handle, 99:48, 5); "." in i
)

/*******************************************/
/***	    DEBUG SUBROUTINES		 ***/
/*******************************************/

defun( ASUlint ()
 let((file)
  file = strcat(getShellEnvVar("MySkillDir"), "\\autosilkUtils_public.il")
  sklint(?file file, ?outputFile "ASU_lint.log", ?ignores '(hint suggestion))
))

;load(strcat(getShellEnvVar("MySkillDir"), "\\autosilkUtils_public.il"))

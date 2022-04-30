;###########################################################
;#                                                         #
;#              Main Program lcb_changewidth               #
;#                                                         #
;###########################################################
axlCmdRegister("cwidth" 'lcb_changewidth)

(defun lcb_changewidth (@optional (args ""))
prog( ()
 ;; Check for command line arguments
 if(args != "" then
  ;; display help file
  axlUIWPrint(nil "")
  axlUIWPrint(nil " - Displaying INFO information. -")
  cwidth_info_createInfo()               
  return()
 ); endif


 
dbaccuracy = nthelem(2 axlDBGetDesignUnits())
dbunits = nthelem(1 axlDBGetDesignUnits())

doagain = nil
l_swidth = nil
newwidth = nil
sourcewidth = nil
lwidthpopup = list(list("0" "0"))
LCB_getlayers()
curdrcs = axlDRCGetCount()


_createForm_changewidth(lpopstack)
changewidth_Form=axlFormCreate( (gensym) changewidth_form_file nil 'changewidth_Form_Action t)
axlFormDisplay(changewidth_Form)
axlFormBuildPopup(changewidth_Form "layers" lstackpopup) 
axlFormBuildPopup(changewidth_Form "widths" lwidthpopup)

axlUIWPrint(changewidth_Form "** Current DRCS: %n **" curdrcs)
axlUIWPrint(nil "** Current DRCS: %n **" curdrcs)

if(isFile(changewidth_form_file)
 deleteFile(changewidth_form_file)
);endif
); end prog
); end defun
;###########################################################
;#                                                         #
;#     End of Main Program lcb_changewidth                 #
;#                                                         #
;###########################################################

;###########################################################
;#                                                         #
;#                 changewidth_Form_Action                 #
;#                                                         #
;###########################################################
(defun changewidth_Form_Action (changewidth_Form)
 (case changewidth_Form->curField
  ("layers" 
    layername = changewidth_Form->curValue
    axlFormSetField(changewidth_Form "widths" "")
    LCB_formupdate()
  )
  ("widths"
    sourcewidth = evalstring(changewidth_Form->curValue)
   if(l_swidth then
    axlDehighlightObject(l_swidth)
    axlFlushDisplay()
    l_swidth = list()
   ); endif

   fnumaccuracy = dbaccuracy + 1
   tol = expt(10 -fnumaccuracy)
   l_swidth = setof(sw layerclinesegs abs(sw->width - sourcewidth) < tol)

   axlHighlightObject(l_swidth)
   axlFlushDisplay()
   axlUIWPrint(nil "** Selected %n Cline Segments. **" length(l_swidth))
   axlUIWPrint(changewidth_Form "Selected %n Segments." length(l_swidth))
   
  )
  ("newsegwidth" newwidth = changewidth_Form->curValue
  )
  ("done" ;; Change Width
   if(newwidth != sourcewidth then
    newlist = list()
    doagain = nil
    LCB_changeWidth()
   
    if(doagain then
     axlUIWPrint(nil " -- Trying to change remaining Csegs. --")
     axlFormSetField(changewidth_Form "widths" sourcewidth)
     axlFormSetField(changewidth_Form "layers" "")
     axlFormSetField(changewidth_Form "layers" layername)
     LCB_getwidth(layername)
     l_swidth = setof(sw layerclinesegs sw->width == sourcewidth)
     LCB_changeWidth()
    ); endif

    if(totdrcs != 0 && !doagain then
     sprintf(errmsg "\nFinal DRC's are: %n\n" axlDRCGetCount())
     axlUIWPrint(nil "--> Final DRC's are: %n" axlDRCGetCount())
     axlUIConfirm(errmsg)
    else
     axlUIWPrint(nil "No DRC's created.")
     axlUIWPrint(nil "--> Total DRC's are: %n" axlDRCGetCount())
    ); endif
  
    l_swidth = nil

    axlUIWPrint(nil "- Done -")
    axlUIWPrint(changewidth_Form " - Done -")
   else
    axlUIWPrint(nil "*** Source Segment Width and New Segment Width are the same! Try again.")
    axlUIWPrint(changewidth_Form "Source Width & New Width are the same! Try again.")
   ); end source==new

  )
  ("info" axlUIWPrint(changewidth_Form "Info Button")
    cwidth_info_createInfo()
  )
  ("close"
     if(l_swidth then
       axlDehighlightObject(l_swidth)
       axlFlushDisplay()
     ); endif
     axlCancelEnterFun()
     axlFormClose(changewidth_Form)
     axlUIWPrint(nil "- Change Width Form closed. -")
  ); end close
 ); end case
);end defun
;###########################################################
;#                                                         #
;#             End of changewidth_Form_Action              #
;#                                                         #
;###########################################################

;###########################################################
;#                                                         #
;#              LCB_changeWidth                            #
;#                                                         #
;###########################################################
(defun LCB_changeWidth ()
    
    if(l_swidth && newwidth && sourcewidth then
     if(!doagain then
      totdrcs = 0
     else
      doagain = nil
     ); endif
     segcount = length(l_swidth)
     axlUIWPrint(nil "** Changing %n Seg Widths, please wait...** " segcount)
     axlUIWPrint(changewidth_Form "Changing %n Seg Widths, please wait..." segcount)
     
      ;; Go through each segment
      foreach(one l_swidth
         ;axlDBRefreshId(one)
        ;; Get netname
        netname = one->net->name
        ;; Get startEnd
        endpoints = one->startEnd
        ;; Get layer name to be sure
        t_layer = one->layer
        ;; Get seg width
        oldsegwidth = one->width
    
        ;; Change width and dehighlight
        ;; Dbid may be removed
       if(t_layer then
              axlDehighlightObject(one)
              axlFlushDisplay()
 
        ;; Remove the existing trace.
        ; Somehow when creating a new cline seg with axlDBCreateLine
        ; it creates a single new segment without having to delete the original.
        ;; Remove the original existing trace anyway.
         if(! axlDeleteObject(one) then
           axlUIWPrint(nil "** Error. Unable to delete Cline Segment, %L" one)
         ); endif
        
        ;; Add new trace at new width
        if(createdline = axlDBCreateLine(endpoints newwidth t_layer netname nil) then
           newline = nthelem(1 nthelem(1 createdline))
           if(nthelem(2 createdline) then
             ;; DRC created. Increment counter.
             totdrcs++
           ); endif
           newlist = cons(newline newlist)          
        else
          axlUIWPrint(nil "*** Error. Unable to change width from %L to %L on net %s on layer %s." oldsegwidth newwidth netname t_layer)
        ); endif

      else
        ; Probably deleted a tee and this dbid was removed.
        axlUIWPrint(nil " -- DBID removed. Probably due to tee removal. --")
        doagain = t
      ); endif 
    ); end foreach

      l_swidth = newlist
   
      ;; Trying to reset the popup.
      axlFormSetField(changewidth_Form "widths" "")
      LCB_formupdate()

    else
      axlUIWPrint(nil "** Cline Segments not selected, try again. **")
      axlUIWPrint(changewidth_Form "** Cline Segments not selected, try again. **")
    ); endif   

); end defun
;###########################################################
;#                                                         #
;#              End of LCB_changeWidth                     #
;#                                                         #
;###########################################################

;###########################################################
;#                                                         #
;#                 LCB_getwidth                            #
;#                                                         #
;###########################################################
(defun LCB_getwidth (lname)
 prog( ()

  if(upperCase(axlDesignType(t)) == "BOARD" then
   class = strcat(upperCase("etch") "/" upperCase(lname))
  else
   class = strcat(upperCase("conductor") "/" upperCase(lname))
  ); endif
  ;; find width of all clines
  axlDBRefreshId(nil)

  lwidth = list()
  lwidthpopup = list()
  layerclinesegs = list()
  if( lallclinesegs = ashFindAllClinesegs() then
   if(layerclinesegs = setof(n lallclinesegs n->layer == class) then    
    lwidth = cons(nthelem(1 layerclinesegs)->width lwidth)
    foreach(one layerclinesegs
     if(member(one->width lwidth) then
     else
      lwidth = cons(one->width lwidth)
      lwidth = sort(lwidth 'lessp)
     ); endif    
    ); end foreach
    foreach(segw lwidth
     lwidthpopup = append(lwidthpopup list(list(sprintf(w "%L" segw) sprintf(w "%L" segw))))
    ); endforeach
   else
    ;; no clinesegs on particular layer
    lwidthpopup = list("" "")
    axlUIWPrint(nil " - No Cline Segs on layer %s." lname)
    return()
   ); endif
  else
   ;; no clinesegs in layout
   axlUIWPrint(nil " - No Cline Segs in layout.")
   return()
  );endif

 ); end prog
)
;###########################################################
;#                                                         #
;#                 End of LCB_getwidth                     #
;#                                                         #
;###########################################################

;###########################################################
;#                                                         #
;#                 LCB_formupdate                          #
;#                                                         #
;###########################################################
(defun LCB_formupdate ()
   
   LCB_getwidth(layername)
   axlFormBuildPopup(changewidth_Form "widths" lwidthpopup)
   axlVisibleDesign(nil)
   axlVisibleLayer(strcat("etch/" layername) t)
   axlVisibleLayer(strcat("pin/" layername) t)
   axlVisibleLayer(strcat("via class/" layername) t)
   axlVisibleLayer(strcat("drc error class/" layername) t)
   axlVisibleUpdate(t) 


); end defun


;###########################################################
;#                                                         #
;#                 LCB_getlayers                           #
;#                                                         #
;###########################################################
(defun LCB_getlayers ()
; Get layers
  lstackpopup = list()
  llayers = list()
  etchparam = axlGetParam("paramLayerGroup:ETCH")
  l_layers = etchparam->groupMembers

 fbegin = "POPUP <layernames>"

  _zr_layerinit = axlConductorTopLayer()

  zrlayerline = strcat(fbegin "\"" _zr_layerinit "\"\"" _zr_layerinit "\".")
  lpopstack = list(zrlayerline)

  
  foreach(lname l_layers 
   lstackpopup = append(lstackpopup list(list(lname lname)))
   llayers = cons(lname llayers)
  ); end foreach


)
;###########################################################
;#                                                         #
;#                 End of LCB_getlayers                    #
;#                                                         #
;###########################################################


;###########################################################
;#                                                         #
;#                 _createForm_changewidth                 #
;#                                                         #
;###########################################################
(defun _createForm_changewidth (lstack)
 let( ()
  changewidth_form_file = "./changewidth.form"
  changewidth_form = outfile(changewidth_form_file "w")
  fprintf(changewidth_form "FILE_TYPE=FORM_DEFN VERSION=2\n")
  fprintf(changewidth_form "FORM \n")
  fprintf(changewidth_form "FIXED\n")
  fprintf(changewidth_form "PORT 41 11\n")
  fprintf(changewidth_form "HEADER \"Change Width\"\n")
  fprintf(changewidth_form "\n")
  foreach(one lstack
    fprintf(changewidth_form "%s\n" one)
  ); end foreach

  ;fprintf(changewidth_form "POPUP <layernames>\"top\"\"top\",\"bottom\"\"bottom\".\n")
  fprintf(changewidth_form "\n")
  fprintf(changewidth_form "POPUP <segwidth>\"5\"\"5\",\"6\"\"6\".\n")
  fprintf(changewidth_form "\n")
  fprintf(changewidth_form "\n")
  fprintf(changewidth_form "TILE\n")
  fprintf(changewidth_form "TEXT \"Source Layer\"\n")
  fprintf(changewidth_form "TLOC 2 5\n")
  fprintf(changewidth_form "TGROUP \"Change Width\"\n")
  fprintf(changewidth_form "ENDTEXT\n")
  fprintf(changewidth_form "\n")
  fprintf(changewidth_form "TEXT \"Source Segment Width\"\n")
  fprintf(changewidth_form "TLOC 2 8\n")
  fprintf(changewidth_form "TGROUP \"Change Width\"\n")
  fprintf(changewidth_form "ENDTEXT\n")
  fprintf(changewidth_form "\n")
  fprintf(changewidth_form "TEXT \"New Segment Width\"\n")
  fprintf(changewidth_form "TLOC 2 11\n")
  fprintf(changewidth_form "TGROUP \"Change Width\"\n")
  fprintf(changewidth_form "ENDTEXT\n")
  fprintf(changewidth_form "\n")
  fprintf(changewidth_form "FIELD layers\n")
  fprintf(changewidth_form "FLOC 23 5\n")
  fprintf(changewidth_form "FGROUP \"Change Width\"\n")
  fprintf(changewidth_form "ENUMSET 8\n")
  fprintf(changewidth_form "POP \"layernames\"\n")
  fprintf(changewidth_form "ENDFIELD\n")
  fprintf(changewidth_form "\n")
  fprintf(changewidth_form "FIELD widths\n")
  fprintf(changewidth_form "FLOC 24 8\n")
  fprintf(changewidth_form "FGROUP \"Change Width\"\n")
  fprintf(changewidth_form "ENUMSET 6\n")
  fprintf(changewidth_form "POP \"segwidth\"\n")
  fprintf(changewidth_form "ENDFIELD\n")
  fprintf(changewidth_form "\n")
  fprintf(changewidth_form "FIELD newsegwidth\n")
  fprintf(changewidth_form "FLOC 24 11\n")
  fprintf(changewidth_form "FGROUP \"Change Width\"\n")
  fprintf(changewidth_form "REALFILLIN 5 5\n")
  fprintf(changewidth_form "REALMIN 1.0\n")
  fprintf(changewidth_form "REALMAX 1000.000000\n")
  fprintf(changewidth_form "DECIMAL %n\n" dbaccuracy )
  fprintf(changewidth_form "ENDFIELD\n")
  fprintf(changewidth_form "\n")

  fprintf(changewidth_form "FIELD close\n")
  fprintf(changewidth_form "FLOC 1 16\n")
  fprintf(changewidth_form "MENUBUTTON \"Close\" 7 3\n")
  fprintf(changewidth_form "ENDFIELD\n")
  fprintf(changewidth_form "\n")

  fprintf(changewidth_form "FIELD info\n")
  fprintf(changewidth_form "FLOC 10 16\n")
  fprintf(changewidth_form "MENUBUTTON \"Info\" 7 3\n")
  fprintf(changewidth_form "ENDFIELD\n")
  fprintf(changewidth_form "\n")

  fprintf(changewidth_form "FIELD done\n")
  fprintf(changewidth_form "FLOC 23 16\n")
  fprintf(changewidth_form "MENUBUTTON \"Change Width\" 14 3\n")
  fprintf(changewidth_form "ENDFIELD\n")
  fprintf(changewidth_form "\n")
  fprintf(changewidth_form "GROUP \"Change Width\"\n")
  fprintf(changewidth_form "GLOC 1 1\n")
  fprintf(changewidth_form "GSIZE 36 14\n")
  fprintf(changewidth_form "ENDGROUP\n")
  fprintf(changewidth_form "\n")
  fprintf(changewidth_form "ENDTILE\n")
  fprintf(changewidth_form "\n")
  fprintf(changewidth_form "ENDFORM\n")
  close(changewidth_form)
  ); end prog
); end defun
;###########################################################
;#                                                         #
;#             End of _createForm_changewidth              #
;#                                                         #
;###########################################################
;###########################################################
;#                                                         #
;#             cwidth_info_createInfo                      #
;#                                                         #
;###########################################################
(defun cwidth_info_createInfo ()
  cwidth_info_helpfile = "./cwidth_info_info.txt"
  cwidth_info_info = outfile(cwidth_info_helpfile "w")
  fprintf(cwidth_info_info "################################################################################\n")
  fprintf(cwidth_info_info "#                                                                              #\n")
  fprintf(cwidth_info_info "#                      Command: cwidth                                         #\n")
  fprintf(cwidth_info_info "#                   Skill File: cwidth.il                                      #\n")
  fprintf(cwidth_info_info "#                  How To Load: Command> (load(\"cwidth.il\"))                   #\n")
  fprintf(cwidth_info_info "#               How To Execute: Command> cwidth            OR                  #\n")
  fprintf(cwidth_info_info "#                                        cwidth  <anything>                    #\n")
  fprintf(cwidth_info_info "#                                                                              #\n")
  fprintf(cwidth_info_info "#                       Author: Larry Bowman, Cadence Design Systems           #\n")
  fprintf(cwidth_info_info "#                        Email: bowman@cadence.com                             #\n")
  fprintf(cwidth_info_info "#                    Telephone: 512-349-1109                                   #\n")
  fprintf(cwidth_info_info "#                Creation Date: 02/28/2003                                     #\n")
  fprintf(cwidth_info_info "#                                                                              #\n")
  fprintf(cwidth_info_info "#                 Version: 3.0  Corrected Floating Point Comparison.           #\n")
  fprintf(cwidth_info_info "#                         Date: 07/24/2003                                     #\n")
  fprintf(cwidth_info_info "################################################################################\n")
  fprintf(cwidth_info_info "\n")
  fprintf(cwidth_info_info "################################################################################\n")
  fprintf(cwidth_info_info "#  DISCLAIMER:                                                                 #\n")
  fprintf(cwidth_info_info "#       The user of this command assumes all responsibility and does not       #\n")
  fprintf(cwidth_info_info "#       hold Cadence Design Systems nor the author of this code for any        #\n")
  fprintf(cwidth_info_info "#       unwarranted results or problems due to the use of this code.           #\n")
  fprintf(cwidth_info_info "#                                                                              #\n")
  fprintf(cwidth_info_info "#       This is non-supported code and the user may modify it as needed.       #\n")
  fprintf(cwidth_info_info "#                                                                              #\n")
  fprintf(cwidth_info_info "################################################################################\n")
  fprintf(cwidth_info_info "\n")
  fprintf(cwidth_info_info "################################################################################\n")
  fprintf(cwidth_info_info "#                                                                              #\n")
  fprintf(cwidth_info_info "# DESCRIPTION:                                                                 #\n")
  fprintf(cwidth_info_info "#      This program will change selected cline segment widths based on layer   #\n")
  fprintf(cwidth_info_info "#      selection and cline segment widths on that layer.                       #\n")
  fprintf(cwidth_info_info "#                                                                              #\n")
  fprintf(cwidth_info_info "#      This is a DESTRUCTIVE operation! Be sure to do a \"Save As\" before       #\n")
  fprintf(cwidth_info_info "#      executing in case you are not satisfied with the results.               #\n")
  fprintf(cwidth_info_info "#                                                                              #\n")
  fprintf(cwidth_info_info "#      This program will not recognize arc segments.  Hence if there are any   #\n")
  fprintf(cwidth_info_info "#      the program will find them and change them to line segments.            #\n")
  fprintf(cwidth_info_info "#                                                                              #\n")
  fprintf(cwidth_info_info "#      At the beginning of the program it will display the current number      #\n")
  fprintf(cwidth_info_info "#      of DRC violations.  During the process of changing widths DRC's may     #\n")
  fprintf(cwidth_info_info "#      be created.  This program will report such but it is up to the user     #\n")
  fprintf(cwidth_info_info "#      to correct such errors.                                                 #\n")
  fprintf(cwidth_info_info "#                                                                              #\n")
  fprintf(cwidth_info_info "#      There may be an earlier version of this program.  You can tell if no    #\n")
  fprintf(cwidth_info_info "#      DRC's are reported and this help information is not available.          #\n")
  fprintf(cwidth_info_info "#      Use this version as there were some minor errors in the original.       #\n")
  fprintf(cwidth_info_info "#                                                                              #\n")
  fprintf(cwidth_info_info "#                                                                              #\n")
  fprintf(cwidth_info_info "################################################################################\n")
  fprintf(cwidth_info_info "\n")
  close(cwidth_info_info)
  axlUIViewFileCreate(cwidth_info_helpfile "Info" t list(82 20))
  deleteFile(cwidth_info_helpfile)
); end defun
;###########################################################
;#                                                         #
;#             End of cwidth_info_createInfo               #
;#                                                         #
;###########################################################



;########################################################################
;#                                                                      #
;#                Function _saveSelSet                                  #
;#                                                                      #
;########################################################################
(defun _saveSelSet ()
    (list (axlGetSelSet) (axlGetFindFilter nil) (axlGetFindFilter t)))

;########################################################################
;#                                                                      #
;#                Function _restoreSelSet                               #
;#                                                                      #
;########################################################################
(defun _restoreSelSet (oldSelSet "l")
    (axlSetFindFilter ?enabled (cons "noall" (nth 1 oldSelSet))
		      ?onButtons (cons "noall" (nth 2 oldSelSet)))
    (axlSingleSelectObject (car oldSelSet))
    t)


;########################################################################
;#                                                                      #
;#                Function findAllOfType                                #
;#                                                                      #
;########################################################################
(defun findAllOfType (findType "t")
    (let (selSet oldSetData)
	(setq oldSetData (_saveSelSet))
	(axlClearSelSet)
	(axlSetFindFilter ?enabled  (list "noall" findType "invisible")
			  ?onButtons  (list "noall" findType))
	(axlAddSelectAll)
	(setq selSet (axlGetSelSet))
	(_restoreSelSet oldSetData)

	selSet))

;########################################################################
;#                                                                      #
;#                Function skillFindAll                                 #
;#                                                                      #
;########################################################################
(defun skillFindAll ()
    (let (selSet oldSetData)
	(setq oldSetData (_saveSelSet))
	(axlClearSelSet)
	(axlSetFindFilter ?enabled  (list  "all" )
			  ?onButtons  (list  "all" ))
	(axlAddSelectAll)
	(setq selSet (axlGetSelSet))
	(_restoreSelSet oldSetData)

	selSet)
);skillFindAll


;########################################################################
;#                                                                      #
;#                Function ashFindAllPins                               #
;#                                                                      #
;########################################################################
(defun ashFindAllPins ()
    (findAllOfType "PINS"))

;########################################################################
;#                                                                      #
;#                Function ashFindAllVias                               #
;#                                                                      #
;########################################################################
(defun ashFindAllVias ()
    (findAllOfType "VIAS"))

;########################################################################
;#                                                                      #
;#                Function ashFindAllClines                             #
;#                                                                      #
;########################################################################
(defun ashFindAllClines ()
    (findAllOfType "CLINES")
); end ashFindAllClines

;########################################################################
;#                                                                      #
;#                Function ashFindAllClinesegs                          #
;#                                                                      #
;########################################################################
(defun ashFindAllClinesegs ()
    (findAllOfType "CLINESEGS"))

;########################################################################
;#                                                                      #
;#                Function ashFindAllLines                              #
;#                                                                      #
;########################################################################
(defun ashFindAllLines ()
    (findAllOfType "LINES"))

;########################################################################
;#                                                                      #
;#                Function ashFindAllLinesegs                           #
;#                                                                      #
;########################################################################
(defun ashFindAllLinesegs ()
    (findAllOfType "LINESEGS"))

;########################################################################
;#                                                                      #
;#                Function ashFindAllDrcs                               #
;#                                                                      #
;########################################################################
(defun ashFindAllDrcs ()
    (findAllOfType "DRCS"))

;########################################################################
;#                                                                      #
;#                Function ashFindAllText                               #
;#                                                                      #
;########################################################################
(defun ashFindAllText ()
    (findAllOfType "TEXT"))

;########################################################################
;#                                                                      #
;#                Function ashFindAllShapes                             #
;#                                                                      #
;########################################################################
(defun ashFindAllShapes ()
    (findAllOfType "SHAPES"))

;########################################################################
;#                                                                      #
;#                Function ashFindAllShapesegs                          #
;#                                                                      #
;########################################################################
(defun ashFindAllShapesegs ()
    (findAllOfType "SHAPESEGS"))

;########################################################################
;#                                                                      #
;#                Function ashFindAllVoids                              #
;#                                                                      #
;########################################################################
(defun ashFindAllVoids ()
    (findAllOfType "VOIDS"))

;########################################################################
;#                                                                      #
;#                Function ashFindAllVoidsegs                           #
;#                                                                      #
;########################################################################
(defun ashFindAllVoidsegs ()
    (findAllOfType "VOIDSEGS"))

;########################################################################
;#                                                                      #
;#                Function ashFindAllSymbols                            #
;#                                                                      #
;########################################################################
(defun ashFindAllSymbols ()
    (findAllOfType "SYMBOLS"))

;########################################################################
;#                                                                      #
;#                Function ashFindAllComponents                         #
;#                                                                      #
;########################################################################
(defun ashFindAllComponents ()
    (findAllOfType "COMPONENTS"))

;########################################################################
;#                                                                      #
;#                Function ashFindAllNets                               #
;#                                                                      #
;########################################################################
(defun ashFindAllNets ()
    (findAllOfType "NETS"))

;########################################################################
;#                                                                      #
;#                Function ashFindAllFigures                            #
;#                                                                      #
;########################################################################
(defun ashFindAllFigures ()
    (findAllOfType "FIGURES"))


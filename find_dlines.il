;########################################################################
;#                                                                      #
;#                Header Section                                        #
;#                                                                      #
;########################################################################
;
; Date Created: December 22, 1995
; Tested with Allegro Release:  11.0 - 9502
; Name of this file: find_dlines.il
; Written by Larry Bowman (bowman@cadence.com) 
;
;
; 1-5-96 Added option of leaving traces hilighted.
;        added to comment section
;        changed 'ars' references to 'skill'
;
; 1-8-96 Corrected problem with registering command name
;
;      Revision: June 18, 1996              
;            By: Larry Bowman - Cadence Technical Services
;         email: bowman@cadence.com
;     Telephone: 512-349-1109
; Modifications: Modified this program to have a form driven interface.
;                The form will display all the dangling clines and
;                dangling lines.  From the form, the user may select
;                any of the dangling clines or dangling lines by their
;                XY locations and the program will dehilite the other
;                dangling (C)lines and hilite the one selected and zoom
;                into the problem (C)line.  The user may delete the
;                dangling (C)line individually or the entire list at one
;                time.  Users need to be aware that some designers may
;                put lines on the Etch Class when adding company logos
;                or other information and these items will be considered
;                "dangling" lines.  Basically, any (C)line without a net
;                name on the ETCH class is, by definition, a dangling
;                (C)line.
;
;                When an item is selected from the list, a "Show Element"
;                window will appear with the data as if the Show Element
;                command was executed on the selected item.
;
;                If the Show Element window does NOT appear or the data
;                in the Show Element window does NOT update, then it is
;                likely that this selection is on an ETCH/CONDUCTOR subclass that
;                is invisibile.  To see this data, turn on the visibility
;                from the DISPLAY->Color/Visibility menu selection.
;
;
;                The command was changed from "find dang" to "find_dang"
;                as a work around for a bug in BoardQuest.
;
; 7-6-98  Made the following changes to be compatible with Allegro 12.x and
;         Allegro 13.x
;         1.  Changed the argument to axlDBCreateExternalDRC from
;             "drc error/" to "drc error class/".
;         2.  Corrected problem with X/Y locations not being
;             displayed in the list boxes.
;
;########################################################################
;# WARNING: The form may not display the XY locations in the lists      #
;#          occasionally.  The work around is to select the "Redisplay" #
;#          in the form's window banner with the Right Mouse button.    #
;#          This will bring the XY locations into the list.  If anyone  #
;#          can determine why this is happening, and has a fix, please  #
;#          let me know.  - Larry Bowman                                #
;########################################################################
;########################################################################
;#                                                                      #
;#                Comment Section                                       #
;#                                                                      #
;########################################################################
;
; This program will check an APD design for any "dangling"
; cline segments, mark all the "dangling" Cline segments with a
; user definded DRC marker and hilite all dangling Clines found.
;
; If the user elects NOT to delete the "dangling" cline, then these
; "dangling" cline segments will remain with a user defined DRC marker.
; To remove these user defined DRC markers, issue the command:
;     APD>  rmdrcs
; Or select the "Remove DRCs" button from the "Find Dangling Clines
; and Dangling Lines" form.
;
; Any stand alone vias or clines with net names that are dangling,
; (Actully called 'hanging' traces) may be removed with the APD gloss 
; program.
;
; A "dangling" cline is any cline in the design that does not have a net
; name associated with it.
;
; The APD summary report (-v sum) reports both hanging AND dangling in 
; the dangling_lines.log.
;
; This program will also find any line segments in the design that
; are on the CLASS->ETCH layers and perform the same way as mentioned
; above for cline segments.
;
;
; This APD Skill program may be loaded automatically
; when APD is invoked by creating an apd.ilinit
; file in the user's pcbenv directory (i.e., ~/pcbenv/apd.ilinit).
;
; The apd.ilinit file could look like the following:

;----------- Start of apd.ilinit file -----------------------------
;setSkillPath(". ~/scripts/SKILL.sav /cds/9502/ibm/tools/pcb/etc/skill")
;load("find_dlines.il")
;----------- End of apd.ilinit file --------------------------------
;
; Where this file, find_dlines.il, is located in one of the directory paths
; as defined by the setSkillPath function.
;
; Note:  If you ever change the APD Skill path with the setSkillPath
;        function as noted above, ALWAYS be sure to include the period(.),
;        which is the current working directory, as part of the search path
;        definition.  There are some APD commands that expect to see the
;        current working directory as part of the search path and will fail
;        if it is not part of the search path.
;
;        Also, most of the Skill functions that do file access will use the
;        setSkillPath value as the directory paths to perform their file
;        reads and writes.
;
; The command to type in the APD editor to invoke this program is:
;    APD>  find_dang
;
; There is also a command that will remove the DRC bow ties.  This comand is:
;    APD>  rmdrcs
;
;
;###################### End Of Comment Section ##########################

;########################################################################
;#                                                                      #
;#                Main Program skillFindDang                            #
;#                                                                      #
;########################################################################
axlCmdRegister("find_dang" 'skillFindDang)
axlCmdRegister("rmdrcs" 'skillDeleteDrcs)


(defun skillFindDang ()

; create find_dline.form file
 _createForm()

; set variables
l_alldang = list()
selected_dbid = nil
lineList = nil
dangList = nil
linecheck = nil
clinecheck = nil


; create the form symbol and display
Form=axlFormCreate( (gensym) form_file nil 'Form_Action t)
axlFormDisplay(Form)

; Setup the Form
_setup()


; Remove form_file from disk
deleteFile(form_file)

) ; end skillFindDang 
;########################################################################
;#                                                                      #
;#                End of Main Program skillFindDang                     #
;#                                                                      #
;########################################################################
 
;##################################
;#   Function Form CallBack       #
;##################################

;---------------------------------------------------
;|                                                 |
;|  This function determines what APD commands |
;|  to execute, based on the user's selection from |
;|  the Find Dangling form.                        |
;|                                                 |
;---------------------------------------------------
  (defun Form_Action (Form)
    (case Form->curField

     ("delete_all_clines" axlUIWPrint(Form "Deleting ALL Dangling Clines.")
                          axlUIWPrint(nil "Deleting ALL Dangling Clines.")
                          _deleteAllClines()
                          axlFlushDisplay() 
                          selected_dbid = nil)

     ("delete_all_lines" axlUIWPrint(Form "Deleting ALL Dangling Lines.")
                         axlUIWPrint(nil "Deleting ALL Dangling Lines.")
                         _deleteAllLines()
                         axlFlushDisplay() 
                         selected_dbid = nil)

     ("cline_list" sel_cline = t
                   _zoomin2(l_clinedang "c") 
                   )

     ("line_list" sel_cline = nil
                  _zoomin2(l_linedang "l") 
                   )

     ("delete_one" 
              _deleteXY()
              selected_dbid = nil
              ) ; delete_one


     ("find_clines" axlUIWPrint(Form "Looking for Dangling Clines with no netname.")
                axlUIWPrint(nil "Looking for Dangling Clines with no netname.")
                clinecheck = t
                _find_Clines()
                axlFlushDisplay() )

     ("find_lines" axlUIWPrint(Form "Looking for Dangling Lines.")
                axlUIWPrint(nil "Looking for Dangling Lines.")
                linecheck = t
                _find_Lines()
                axlFlushDisplay() )

     ("remove_drcs" axlUIWPrint(Form "Clearing DRCs.")
                    axlUIWPrint(nil "Clearing DRCs.")
                    skillDeleteDrcs()
                    axlFlushDisplay() )

     ("remove_hilite" 
                      if(!axlOKToProceed() then
                        axlFlushDisplay() 
                      else
                       if(clinecheck then
                        if(car(dangList)->objType then
                          axlUIWPrint(Form "Dehiliting Clines.")
                          axlDehighlightObject( dangList)
                        else
                          axlUIWPrint(Form "Dbids out of date; rechecking Clines . . .")
                          _find_Clines()
                          axlDehighlightObject( dangList)
                        ); endif
                       ); endif
                       if(linecheck then
                        if(car(lineList)->objType then
                          axlUIWPrint(nil "Dehiliting Lines.")
                          axlDehighlightObject( lineList)
                        else
                          axlUIWPrint(Form "Dbids out of date; rechecking Lines . . .")
                          _find_Lines()
                          axlDehighlightObject( lineList)
                        ); endif
                       ); endif
                        axlFlushDisplay() 
                      );endif 
                      )

     ("done" if(axlOKToProceed() then
               (axlFlushDisplay)
               (axlCancelEnterFun)
               (axlFormClose Form)
               else
                 axlUIWPrint(Form "End the current command and try again.")
                 axlUIWPrint(nil "End the current command and try again.")
             );endif 
             ); end done


     ("pr_help"  _helpButton() )

    ); endcase

  ); end defun Form_Action
;##################################
;# End Function Form CallBack     #
;##################################

;########################################################################
;#                                                                      #
;#      _setup  Check the database size and set the default entries.    #
;#                                                                      #
;########################################################################
(defun _setup ()
   axlFormSetField(Form "cline_list" list("Not Checked"))
   axlFormSetField(Form "line_list" list("Not Checked"))
   _findSize()
); end defun _setup


;########################################################################
;#                                                                      #
;#      _findSize Check the size of the .brd file.                      #
;#                                                                      #
;########################################################################
(defun _findSize ()
  brdname = axlCurrentDesign()
  brdpath = axlGetDrawingName()
  brdsize = fileLength(brdpath)
  chksize = 8000000
  brdsizemb = brdsize / 1000000
  if(brdsize >= chksize then
    axlUIWPrint(Form "Your %s design is %n MB, checking may be >5 min." brdname brdsizemb)
    axlUIWPrint(nil "Your %s design is %n MB, checking may be >5 minutes." brdname brdsizemb)
    axlUIWPrint(nil "For Large designs, (8MB+), it may take a while to check.")
    sprintf(warn "Your %s design is %n MB, checking may be longer than 5 minutes." brdname brdsizemb)
    axlUIConfirm(warn)
  ); end if
); end defun _findSize

;########################################################################
;#                                                                      #
;#      recheck() Do this if dbids get removed.                         #
;#                                                                      #
;########################################################################
(defun recheck (checkfunction)
    axlDBRefreshId(axlDBGetDesign())
    l_alldang = list()
    checkfunction

); end defun


;########################################################################
;#                                                                      #
;#      _deleteXY Delete the selected Dangling Cline or Line.           #
;#                                                                      #
;########################################################################
(defun  _deleteXY ()
       if(selected_dbid  then
         skillDeleteOneDrc()
         axlDeleteObject(selected_dbid)
         if(sel_cline then
           axlUIWPrint(Form "Deleting Dangling Cline.")
           axlUIWPrint(nil "Deleting Dangling Cline.")
           _find_Clines() 
         else
           axlUIWPrint(Form "Deleting Dangling Line.")
           axlUIWPrint(Form "Deleting Dangling Line.")
           _find_Lines()
         ); endif
         axlFlushDisplay()
       else
         axlUIWPrint(Form "No Dangling [C]line selected.")
         axlUIWPrint(nil "No Dangling [C]line selected.")
       ); endif
 
); end defun


;########################################################################
;#                                                                      #
;#      _zoomin2 for getting dbids from the form                        #
;#                                                                      #
;########################################################################
(defun _zoomin2 (assoclist linetype)
  ; get the bBox from the dbid

 if(cdr(assoc(Form->curValue assoclist)) == nil then
  axlUIWPrint(nil "You selected NONE.")
  axlUIWPrint(Form "You selected NONE.")
 else
  if(car(cadr(assoc(Form->curValue assoclist))->bBox) == nil then
     if(linetype == "c" then
       axlUIWPrint(Form "Dbids out of date; rechecking Clines . . .")
       _find_Clines()
     else
       axlUIWPrint(Form "Dbids out of date; rechecking Lines . . .")
       _find_Lines()
     ); endif
     axlFlushDisplay()
     axlUIWPrint(Form ">> Please make another selection.")
  else
     zx1 = caar(cadr(assoc(Form->curValue assoclist))->bBox)
     zy1 = cadar(cadr(assoc(Form->curValue assoclist))->bBox)
     zx2 = caadr(cadr(assoc(Form->curValue assoclist))->bBox)
     zy2 = cadadr(cadr(assoc(Form->curValue assoclist))->bBox)


     xcenter = ((zx2 - zx1) / 2) + zx1
     ycenter = ((zy2 - zy1) / 2) + zy1
     wcentercom = sprintf(wincenter "window center; x %n %n" xcenter ycenter)

     ; save the last dbid selected
     selected_dbid = cdr(assoc(Form->curValue assoclist))
     class_subclass = car(selected_dbid)->layer

     sprintf(msg "Selected %L %s." car(car(selected_dbid)->segments)->startEnd class_subclass)
     axlUIWPrint(Form msg)


     ; dehilite all but the one being selected
     if(dangList then
       axlDehighlightObject( dangList)
     ); endif
     if(lineList then
       axlDehighlightObject( lineList)
     ); endif
     axlHighlightObject(selected_dbid)

     ; Check the delta between the X/Y coordinates and assign a number to
     ; window out a reasonable distance from the actual error.
     cond(
       ( (abs(zx2 - zx1) < 1) (zxnum = 1) )
       ( (abs(zx2 - zx1) > 1) ( zxnum = 100) )
     ); end cond for x
     cond(
       ( (abs(zy2 - zy1) < 1) (zynum = 1.5) )
       ( (abs(zy2 - zy1) > 1) ( zynum = 150) )
     ) ; end cond for y
     sprintf(wc "window points; x %n %n; x %n %n" (zx1 + zxnum) (zy1 + zxnum) (zx2 + zynum) (zy2 + zynum))

     axlShell(wc)
     t
     axlShell(wcentercom)
     t
     axlUIWPrint(nil msg)
     axlShowObject(selected_dbid)
  ); end if
 ); endif
); end defun

;########################################################################
;#                                                                      #
;#      _clearForm                                                      #
;#                                                                      #
;########################################################################
(defun _clearForm (formlist formtotal)

; Reset any items in the form
axlFormListDeleteAll(Form formlist)
axlFormListDeleteAll(Form formtotal)
); end defun

;########################################################################
;#                                                                      #
;#      _find_Clines                                                    #
;#                                                                      #
;########################################################################
(defun _find_Clines ()
   axlFormSetField(Form "cline_list" "None")

   ; clear the form
   _clearForm("cline_list" "total_clines")

   ; Find dangling clines
   dangList = skillMakeDangList()

   ; Put the XY locations into the Form
   if(dangList then
     l_alldang = list()
     lcbMakeDrc(dangList "cline_list" "Dangling Cline")
     l_clinedang = l_alldang
   else
     axlFormSetField(Form "cline_list" list("NONE"))
     axlUIWPrint(nil "No Dangling Clines Found.")
     clinecheck = nil
   ); endif 
   axlFormSetField(Form "total_clines" length(dangList) )

); end defun

;########################################################################
;#                                                                      #
;#      _find_Lines  Function                                           #
;#                                                                      #
;########################################################################
(defun _find_Lines ()


  ; clear the form
   _clearForm("line_list" "total_lines")

  lineList = lcbMakeLineList()

  ; Put the XY locations into the Form
  if(lineList then
    l_alldang = list()
    lcbMakeDrc(lineList "line_list" "Dangling Line")
    l_linedang = l_alldang
  else
    axlFormSetField(Form "line_list" list("NONE"))
    axlUIWPrint(nil "No Dangling Lines Found.")
    linecheck = nil
  );endif
  axlFormSetField(Form "total_lines" length(lineList) )
  
); end defun _find_Lines

;########################################################################
;#                                                                      #
;#      _deleteAllClines Function                                       #
;#                                                                      #
;########################################################################
(defun _deleteAllClines ()
 if(dangList != nil then
  ; Dehilite each dangling cline
  axlDehighlightObject( dangList)
  
  ; Remove each dangling cline
  skillDeleteDrcs()
  axlDeleteObject( dangList)
  ;_find_Lines()
  _find_Clines()
 else
  axlUIWPrint(Form "No Dangling Clines found.")
  axlUIWPrint(nil "No Dangling Clines found.")
 ); endif
); enddefun

;########################################################################
;#                                                                      #
;#  _deleteAllLines Function                                            #
;#                                                                      #
;########################################################################
(defun _deleteAllLines ()
 if(lineList != nil then
  ; Dehilite each Line on ETCH
  axlDehighlightObject( lineList)

  ; Remove each Line on ETCH
  skillDeleteDrcs()
  axlDeleteObject( lineList)
  _find_Lines()
 else
  axlUIWPrint(Form "No Dangling Lines found.")
  axlUIWPrint(nil "No Dangling Lines found.")
 ); endif
); end defun

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

;########################################################################
;#                                                                      #
;#                Function skillMakeDangList                            #
;#                                                                      #
;########################################################################
(defun skillMakeDangList ()
	setof( n ashFindAllClines() n ->net->name == nil)
);skillMakeDangList

;########################################################################
;#                                                                      #
;#                Function skillDeleteOneDrc                            #
;#                                                                      #
;########################################################################
(defun skillDeleteOneDrc ()
  (foreach oneDRC (ashFindAllDrcs)
	(case oneDRC~>name
		("Externally Determined Violation" 
                      if(oneDRC->xy == car(car(car(selected_dbid)->segments)->startEnd)
                        axlDeleteObject( oneDRC )
                      ); endif
                      )
		( t nil)
	);case
  );foreach
);skillDeleteDrcs


;########################################################################
;#                                                                      #
;#                Function skillDeleteDrcs                              #
;#                                                                      #
;########################################################################
(defun skillDeleteDrcs ()
  (foreach oneDRC (ashFindAllDrcs)
	(case oneDRC~>name
		("Externally Determined Violation" axlDeleteObject( oneDRC ))
		( t nil)
	);case
  );foreach
);skillDeleteDrcs

;########################################################################
;#                                                                      #
;#                Function skillDehighlightAll                          #
;#                                                                      #
;########################################################################
(defun skillDehighlightAll ()
axlDehighlightObject(skillFindAll())
)

;########################################################################
;#                                                                      #
;#                Function lcbMakeLineList                              #
;#                                                                      #
;########################################################################
; Try to find all line segments on the Class, ETCH.
(defun lcbMakeLineList ()
    setof(n ashFindAllLines() (car(parseString(n->layer "/")) == "CONDUCTOR"))
);lcbMakeLineList

;########################################################################
;#                                                                      #
;#                Function lcbMakeDrc                                   #
;#                                                                      #
;########################################################################
; Make a function that will take a list, an error message, and an
; output file name as arguments and will create the DRC markers
; and report files.
(defun lcbMakeDrc (l_dang formfield errmsg)
 prog( ()
  (foreach oneLine l_dang
         theLine = oneLine
         onesegX = xCoord(car(car(theLine->segments)->startEnd))
         onesegY = yCoord(car(car(theLine->segments)->startEnd))
       
         ; Use the dbid and XY in the form
         sprintf(snum "%L" car(oneLine->segments)->startEnd)
        
         ; Make an associative list
         l_alldang = append(l_alldang list(list(snum oneLine))) 

         layer = theLine->layer
         subclass = cadr(parseString(layer "/"))
         drcLayer = strcat( "drc error class/" subclass)
         axlDBCreateExternalDRC( errmsg, onesegX:onesegY, drcLayer)
         axlFormSetField(Form formfield list(snum) )
  );foreach

   
   ;Highlight each cline/line
   axlHighlightObject( l_dang)


   ; return with the number of errors.
   return()

 ); end prog
); end lcbMakeDrc

;########################################################################
;#                                                                      #
;#                Function _createForm                                  #
;#                                                                      #
;########################################################################
(defun _createForm () 
 form_file = "find_dlines.form"
 form = outfile(form_file "w")
 fprintf(form "FILE_TYPE=FORM_DEFN VERSION=2\n")
 fprintf(form "FORM\n")
 fprintf(form "FIXED\n")
 fprintf(form "PORT 67 20\n")
 fprintf(form "HEADER \"Find Dangling Clines and Dangling Lines\"\n")
 fprintf(form "\n")
 fprintf(form "POPUP <PRINTP>\"to File\"\"0\",\"to Printer\"\"1\",\"to Script\"\"2\".\n")
 fprintf(form "\n")
 fprintf(form "\n")
 fprintf(form "TILE\n")
 fprintf(form "TEXT \"*********************************************************************\"\n")
 fprintf(form "TLOC 0 0\n")
 fprintf(form "ENDTEXT\n")
 fprintf(form "\n")
 fprintf(form "TEXT \"\"\n")
 fprintf(form "TLOC 0 1\n")
 fprintf(form "ENDTEXT\n")
 fprintf(form "\n")
 fprintf(form "TEXT \"  This program will locate any Clines or Lines on the                \"\n")
 fprintf(form "TLOC 0 2\n")
 fprintf(form "ENDTEXT\n")
 fprintf(form "\n")
 fprintf(form "TEXT \"  Conductor Class/Subclass that do not have any associated           \"\n")
 fprintf(form "TLOC 0 3\n")
 fprintf(form "ENDTEXT\n")
 fprintf(form "\n")
 fprintf(form "TEXT \"  net name.  Select the Info button for more details.                \"\n")
 fprintf(form "TLOC 0 4\n")
 fprintf(form "ENDTEXT\n")
 fprintf(form "\n")
 fprintf(form "TEXT \"\"\n")
 fprintf(form "TLOC 0 5\n")
 fprintf(form "ENDTEXT\n")
 fprintf(form "\n")
 fprintf(form "TEXT \"\"\n")
 fprintf(form "TLOC 0 6\n")
 fprintf(form "ENDTEXT\n")
 fprintf(form "\n")
 fprintf(form "TEXT \"*********************************************************************\"\n")
 fprintf(form "TLOC 0 7\n")
 fprintf(form "ENDTEXT\n")
 fprintf(form "\n")
 fprintf(form "TEXT \"Dangling Clines\"\n")
 fprintf(form "TLOC 3 12\n")
 fprintf(form "ENDTEXT\n")
 fprintf(form "\n")
 fprintf(form "TEXT \"Dangling Lines\"\n")
 fprintf(form "TLOC 46 12\n")
 fprintf(form "ENDTEXT\n")
 fprintf(form "\n")
 fprintf(form "TEXT \"Found\"\n")
 fprintf(form "TLOC 1 26\n")
 fprintf(form "ENDTEXT\n")
 fprintf(form "\n")
 fprintf(form "TEXT \"Clines\"\n")
 fprintf(form "TLOC 14 26\n")
 fprintf(form "ENDTEXT\n")
 fprintf(form "\n")
 fprintf(form "TEXT \"Found\"\n")
 fprintf(form "TLOC 44 26\n")
 fprintf(form "ENDTEXT\n")
 fprintf(form "\n")
 fprintf(form "TEXT \"Lines\"\n")
 fprintf(form "TLOC 57 26\n")
 fprintf(form "ENDTEXT\n")
 fprintf(form "\n")
 fprintf(form "FIELD delete_all_clines\n")
 fprintf(form "FLOC 1 9\n")
 fprintf(form "MENUBUTTON \"Delete ALL Clines\" 19 3\n")
 fprintf(form "ENDFIELD\n")
 fprintf(form "\n")
 fprintf(form "FIELD delete_all_lines\n")
 fprintf(form "FLOC 44 9\n")
 fprintf(form "MENUBUTTON \"Delete ALL Lines\" 18 3\n")
 fprintf(form "ENDFIELD\n")
 fprintf(form "\n")
 fprintf(form "FIELD cline_list\n")
 fprintf(form "FLOC 1 14\n")
 fprintf(form "LIST \"\" 20 5\n")
 fprintf(form "ENDFIELD\n")
 fprintf(form "\n")
 fprintf(form "FIELD line_list\n")
 fprintf(form "FLOC 44 14\n")
 fprintf(form "LIST \"\" 20 5\n")
 fprintf(form "ENDFIELD\n")
 fprintf(form "\n")
 fprintf(form "FIELD delete_one\n")
 fprintf(form "FLOC 21 15\n")
 fprintf(form "MENUBUTTON \"Delete SELECTED X/Y\" 21 3\n")
 fprintf(form "ENDFIELD\n")
 fprintf(form "\n")
 fprintf(form "FIELD total_clines\n")
 fprintf(form "FLOC 7 26\n")
 fprintf(form "INFO_ONLY\n")
 fprintf(form "INTFILLIN 4 4\n")
 fprintf(form "ENDFIELD\n")
 fprintf(form "\n")
 fprintf(form "FIELD total_lines\n")
 fprintf(form "FLOC 50 26\n")
 fprintf(form "INFO_ONLY\n")
 fprintf(form "INTFILLIN 4 4\n")
 fprintf(form "ENDFIELD\n")
 fprintf(form "\n")
 fprintf(form "FIELD find_clines\n")
 fprintf(form "FLOC 1 29\n")
 fprintf(form "MENUBUTTON \"Find Dangling Clines\" 22 3\n")
 fprintf(form "ENDFIELD\n")
 fprintf(form "\n")
 fprintf(form "FIELD find_lines\n")
 fprintf(form "FLOC 44 29\n")
 fprintf(form "MENUBUTTON \"Find Dangling Lines\" 22 3\n")
 fprintf(form "ENDFIELD\n")
 fprintf(form "\n")
 fprintf(form "FIELD remove_drcs\n")
 fprintf(form "FLOC 11 33\n")
 fprintf(form "MENUBUTTON \"Remove DRCs\" 15 3\n")
 fprintf(form "ENDFIELD\n")
 fprintf(form "\n")
 fprintf(form "FIELD remove_hilite\n")
 fprintf(form "FLOC 36 33\n")
 fprintf(form "MENUBUTTON \"UnHilite Errors\" 17 3\n")
 fprintf(form "ENDFIELD\n")
 fprintf(form "\n")
 fprintf(form "FIELD done\n")
 fprintf(form "FLOC 2 37\n")
 fprintf(form "MENUBUTTON \"Done\" 10 3\n")
 fprintf(form "ENDFIELD\n")
 fprintf(form "\n")
 fprintf(form "FIELD pr_help\n")
 fprintf(form "FLOC 40 37\n")
 fprintf(form "MENUBUTTON \"Info\" 10 3\n")
 fprintf(form "ENDFIELD\n")
 fprintf(form "\n")
 fprintf(form "FIELD print\n")
 fprintf(form "FLOC 52 37\n")
 fprintf(form "MENUBUTTON \"Print\" 10 3\n")
 fprintf(form "POP \"PRINTP\"\n")
 fprintf(form "ENDFIELD\n")
 fprintf(form "\n")
 fprintf(form "ENDTILE\n")
 fprintf(form "\n")
 fprintf(form "ENDFORM\n")
 close(form)
 ); end defun _createForm

;########################################################################
;#                                                                      #
;#                Function _helpButton                                  #
;#                                                                      #
;########################################################################
(defun _helpButton () 
 helpfile = "find_dlines.info"
 info = outfile(helpfile "w") 
 fprintf(info "########################################################################\n")
 fprintf(info "#                                                                      #\n")
 fprintf(info "#                Header Section                                        #\n")
 fprintf(info "#                                                                      #\n")
 fprintf(info "########################################################################\n")
 fprintf(info "     \n")
 fprintf(info " Date Created: December 22, 1995\n")
 fprintf(info " Tested with Allegro Release:  11.0 - 9502\n")
 fprintf(info " Name of this file: find_dlines.il\n")
 fprintf(info " Written by Larry Bowman (bowman@cadence.com)\n")
 fprintf(info "\n")
 fprintf(info "\n")
 fprintf(info " 1-5-96 Added option of leaving traces hilighted.\n")
 fprintf(info "        added to comment section\n")
 fprintf(info "        changed 'ars' references to 'skill'\n")
 fprintf(info "\n")
 fprintf(info " 1-8-96 Corrected problem with registering command name\n")
 fprintf(info "\n")
 fprintf(info "-----------------------------------------------------------------------------\n")
 fprintf(info "|      Revision: May 10, 1996                                               |\n")
 fprintf(info "|            By: Larry Bowman - Cadence Technical Services                  |\n")
 fprintf(info "|         email: bowman@cadence.com                                         |\n")
 fprintf(info "|     Telephone: 512-349-1109                                               |\n")
 fprintf(info "| Modifications: Modified this program to have a form driven interface.     |\n")
 fprintf(info "|                The form will display all the dangling clines and          |\n")
 fprintf(info "|                dangling lines.  From the form, the user may select        |\n")
 fprintf(info "|                any of the dangling clines or dangling lines by their      |\n")
 fprintf(info "|                XY locations and the program will dehilite the other       |\n")
 fprintf(info "|                dangling (C)lines and hilite the one selected and zoom     |\n")
 fprintf(info "|                into the problem (C)line.  The user may delete the         |\n")
 fprintf(info "|                dangling (C)line individually or the entire list at one    |\n")
 fprintf(info "|                time.  Users need to be aware that some designers may      |\n")
 fprintf(info "|                put lines on the Etch Class when adding company logos      |\n")
 fprintf(info "|                or other information and these items will be considered    |\n")
 fprintf(info "|                \"dangling\" lines.  Basically, any (C)line without a net    |\n")
 fprintf(info "|                name on the ETCH class is, by definition, a dangling       |\n")
 fprintf(info "|                (C)line.                                                   |\n")
 fprintf(info "|                                                                           |\n")
 fprintf(info "|                When an item is selected from the list, a \"Show Element\"   |\n")
 fprintf(info "|                window will appear with the data as if the Show Element    |\n")
 fprintf(info "|                command was executed on the selected item.                 |\n")
 fprintf(info "|                                                                           |\n")
 fprintf(info "|                If the Show Element window does NOT appear or the data     |\n")
 fprintf(info "|                in the Show Element window does NOT update, then it is     |\n")
 fprintf(info "|                likely that this selection is on a CONDUCTOR subclass that |\n")
 fprintf(info "|                is invisibile.  To see this data, turn on the visibility   |\n")
 fprintf(info "|                from the Display->Color/Visibility menu selection.         |\n")
 fprintf(info "|                                                                           |\n")
 fprintf(info "|                The command was changed from \"find dang\" to \"find_dang\"    |\n")
 fprintf(info "|                as a work around for a bug in BoardQuest.                  |\n")
 fprintf(info "|                                                                           |\n")
 fprintf(info "-----------------------------------------------------------------------------\n")
 fprintf(info "|                                                                           |\n")
 fprintf(info "| 7-6-98  Made the following changes to be compatible with Allegro 12.x and |\n")
 fprintf(info "|         Allegro 13.x .                                                    |\n")
 fprintf(info "|         1.  Changed the argument to axlDBCreateExternalDRC from           |\n")
 fprintf(info "|             \"drc error/\" to \"drc error class/\".                           |\n")
 fprintf(info "|         2.  Corrected problem with X/Y locations not being                |\n")
 fprintf(info "|             displayed in the list boxes.                                  |\n")
 fprintf(info "|                                                                           |\n")
 fprintf(info "-----------------------------------------------------------------------------\n")
 fprintf(info "\n")
 fprintf(info "########################################################################\n")
 fprintf(info "#                                                                      #\n")
 fprintf(info "#                Comment Section                                       #\n")
 fprintf(info "#                                                                      #\n")
 fprintf(info "########################################################################\n")
 fprintf(info "\n")
 fprintf(info " This program will check an APD design for any \"dangling\"\n")
 fprintf(info " cline segments, mark all the \"dangling\" Cline segments with a\n")
 fprintf(info " user definded DRC marker and hilite all dangling Clines found.\n")
 fprintf(info "\n")
 fprintf(info " If the user selects NOT to delete the \"dangling\" cline, then these\n")
 fprintf(info " \"dangling\" cline segments will remain with a user defined DRC marker.\n")
 fprintf(info " To remove these user defined DRC markers, issue the command:\n")
 fprintf(info "     APD>  rmdrcs\n")
 fprintf(info " Or select the \"Remove DRCs\" button from the \"Find Dangling Clines\n")
 fprintf(info " and Dangling Lines\" form.\n")
 fprintf(info "\n")
 fprintf(info " Any stand alone vias or clines with net names that are dangling,\n")
 fprintf(info " (Actully called 'hanging' traces) may be removed with the APD gloss\n")
 fprintf(info " program.\n")
 fprintf(info "\n")
 fprintf(info " A \"dangling\" cline is any cline in the design that does not have a net\n")
 fprintf(info " name associated with it.\n")
 fprintf(info "\n")
 fprintf(info " The APD summary report (-v sum) reports both hanging AND dangling in\n")
 fprintf(info " the dangling_lines.log.\n")
 fprintf(info "\n")
 fprintf(info " This program will also find any line segments in the design that\n")
 fprintf(info " are on the CLASS->ETCH layers and perform the same way as mentioned\n")
 fprintf(info " above for cline segments.\n")
 fprintf(info "\n")
 fprintf(info "\n")
 fprintf(info " This APD Skill program may be loaded automatically\n")
 fprintf(info " when APD is invoked by creating an apd.ilinit\n")
 fprintf(info " file in the user's pcbenv directory (i.e., ~/pcbenv/apd.ilinit).\n")
 fprintf(info "\n")
 fprintf(info " The apd.ilinit file could look like the following:\n")
 fprintf(info "\n")
 fprintf(info "----------- Start of apd.ilinit file -----------------------------\n")
 fprintf(info "setSkillPath(\". ~/scripts/SKILL.sav /cds/9502/ibm/tools/pcb/etc/skill\")\n")
 fprintf(info "load(\"find_dlines.il\")\n")
 fprintf(info "----------- End of apd.ilinit file --------------------------------\n")
 fprintf(info "\n")
 fprintf(info " Where this file, find_dlines.il, is located in one of the directory paths\n")
 fprintf(info " as defined by the setSkillPath function.\n")
 fprintf(info "\n")
 fprintf(info " Note:  If you ever change the APD Skill path with the setSkillPath\n")
 fprintf(info "        function as noted above, ALWAYS be sure to include the period(.),\n")
 fprintf(info "        which is the current working directory, as part of the search path\n")
 fprintf(info "        definition.  There are some APD commands that expect to see the\n")
 fprintf(info "        current working directory as part of the search path and will fail\n")
 fprintf(info "        if it is not part of the search path.\n")
 fprintf(info "\n")
 fprintf(info "        Also, most of the Skill functions that do file access will use the\n")
 fprintf(info "        setSkillPath value as the directory paths to perform their file\n")
 fprintf(info "        reads and writes.\n")
 fprintf(info "\n")
 fprintf(info " The command to type in the APD editor to invoke this program is:\n")
 fprintf(info "    APD>  find_dang\n")
 fprintf(info "\n")
 fprintf(info " There is also a command that will remove the DRC bow ties.  This comand is:\n")
 fprintf(info "    APD>  rmdrcs\n")
 fprintf(info "\n")
 fprintf(info "\n")
 fprintf(info "###################### End Of Comment Section ##########################\n")
 fprintf(info "\n")
 fprintf(info "\n")
 fprintf(info "\n")
 close(info)
 axlUIViewFileCreate(helpfile "Find Dang Information" t)
); end defun _helpButton

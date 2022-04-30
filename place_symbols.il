;------------ Cut Here and save to file as: place_symbols.il ---------------
;###########################################################################
;#                                                                         #
;#                      Comment Section                                    #
;#                                                                         #
;###########################################################################
;  Author:  Larry Bowman - Cadence Technical Services
;   Email:  bowman@cadence.com
; Product:  Allegro
; Version:  11.0
;    Date:  February 29, 1996
; Command:  place symbols

;  Revision Date:  May 13, 1996
;    Description: Changed the Allegro command for this program from 
;                 "place symbols" to "place_symbols" to work around a bug
;                 in BoardQuest.

; This program was inspired by the "Place List" Allegro Skill program.  This
; program includes that functionality along with access to the other Allegro
; symbols.  Since this was an extensive addition, I did not want to corrupt
; the original "Place List" program.

; This program will open a form which will display the MECHANICAL (.bsm),
; the FORMAT (.osm), the PACKAGE (.psm), and the REFERENCE DESIGNATORS
; that may be placed in an Allegro database.  The MECHANICAL,FORMAT, and
; PACKAGE symbols are located via the PSMPATH variable.

; The order of the symbols in the menu lists are in the same order
; as the directory paths as defined by the PSMPATH variable.  If there
; are any duplicate entries, then that means the same symbol name exists
; in duplicate library directories.

; When the user selects a symbol or reference designator from the list,
; it is attached to the cursor in "place" mode.  All of the standard 
; middle mouse button operations are available (as in the standard place by refdes)
; except the "next" and "oops" buttons.  The equivalent to "next" or "oops" is 
; to merely select a new symbol(or reference designator) from the list.

; The list of Reference Designators will update upon the next selection from
; the Reference Designator list or by hitting the "Refresh RefDes" button.

; The "Place Symbols" form may be left open and accessed at any time, regardless
; of the current Allegro mode.

; To run this program in the Allegro editor at the command line, you would
; type in the command, "place symbols".
;
; For example:
; Allegro> place symbols

; You may also modify an Allegro menu to include this command as a menu
; selection.

;
; This Allegro Skill program may be loaded automatically
; when Allegro is invoked by creating an allegro.ilinit
; file in the user's pcbenv directory (i.e., ~/pcbenv/allegro.ilinit).
;
; The allegro.ilinit file could look like the following:

;----------- Start of allegro.ilinit file -----------------------------
;setSkillPath(". ~/scripts/SKILL.sav /cds/9502/ibm/tools/pcb/etc/skill")
;load("place_symbols.il")
;----------- End of allegro.ilinit file --------------------------------
;
; Where this file, place_symbols.il, is located in one of the directory paths
; as defined by the setSkillPath function.
;
; Note:  If you ever change the Allegro Skill path with the setSkillPath
;        function as noted above, ALWAYS be sure to include the period(.),
;        which is the current working directory, as part of the search path
;        definition.  There are some Allegro commands that expect to see the
;        current working directory as part of the search path and will fail
;        if it is not part of the search path.
;
;        Also, most of the Skill functions that do file access will use the
;        setSkillPath value as the directory paths to perform their file
;        reads and writes.

;###########################################################################
;#                                                                         #
;#                      End Of Comment Section                             #
;#                                                                         #
;###########################################################################

axlCmdRegister("place_symbols" 'place_sym)

(defun place_sym ()

;**************************************************
;*         Function Subroutines                   *
;**************************************************

;##################################
;#   Function Form CallBack       #
;##################################

;---------------------------------------------------
;|                                                 |
;|  This function determines what Allegro commands |
;|  to execute, based on the user's selection from |
;|  the Place Symbols form.                        |
;|                                                 |
;---------------------------------------------------
  (defun Form_Action (Form)

   (case Form->curField

    ("Mechanical_List"
     _refreshRefDes()
     if( car(mechlist) != "No Symbols Found" then
      axlUIWPrint(Form "Placing Mechanical Symbol %s" Form->curValue)
      Command=strcat("add symbol mechanical " Form->curValue)
      axlShell(Command)
      t
     else
       axlUIWPrint(Form "No MECHANICAL Symbols Found.")
     ); endif
    ); end Mechanical_List

    ("Format_List"
     _refreshRefDes()
     if( car(formatlist) != "No Symbols Found" then
      axlUIWPrint(Form "Placing Format Symbol %s" Form->curValue)
      Command=strcat("add symbol format " Form->curValue)
      axlShell(Command)
      t
     else
       axlUIWPrint(Form "No FORMAT Symbols Found.")
    ); end if
    ); end Format_List

    ("Package_List"
     _refreshRefDes()
     if( car(psmlist) != "No Symbols Found" then
      axlUIWPrint(Form "Placing Package Symbol %s" Form->curValue)
      Command=strcat("add symbol package " Form->curValue)
      axlShell(Command)
      t
     else
       axlUIWPrint(Form "No PACKAGE Symbols Found.")
     ); endif
    ); end Package_List

    ("Unplaced_List"
      _refreshRefDes()
      if(car(l_unplaced) != "No Netlist Loaded" && car(l_unplaced) != "All RefDes Placed" then
        axlUIWPrint(Form "Placing Reference Designator %s" Form->curValue)
        Command=strcat("place refdes " Form->curValue)
        axlShell(Command)
        t
      else
       axlUIWPrint(Form "No More Reference Designators")
      ); endif
    ); end Unplaced_List

    ("Refresh_List"
      _refreshRefDes()
    ) ; end Refresh_List

    ("refdestot"
      axlUIWPrint(Form "There are %n Components to Place." refcount)
      axlFormSetField(Form "refdestot" refcount)
    ); end refdestot

    ("close"
     if(axlOKToProceed() then
       (axlCancelEnterFun)
       (axlFormClose Form)
     ); endif
    ); end close

    ("cancel"
       axlUIWPrint(Form ">> Select Symbol or Reference Designator")
       axlShell("cancel")
       t
    ); end cancel

   ); end case

  ); end defun Form_Action
;##################################
;# End Function Form CallBack     #
;##################################

;##################################
;# Function _getUnplacedRefDes    #
;##################################
(defun _getUnplacedRefDes ()
 prog( (l_unplacedRefDes)
   l_unplacedRefDes = list()
   refcount = 0
   axlDBRefreshId(axlDBGetDesign())
   if( (l_components = axlDBGetDesign()->components) == nil then
    no_netlist = list("No Netlist Loaded")
    axlFormSetField(Form "refdestot" refcount)
    return(no_netlist)
   );endif
   placedRefDes = t
   foreach(component l_components
     if(component->symbol == nil then
      placedRefDes = nil
      l_unplacedRefDes = cons(component->name l_unplacedRefDes)
     ); end if
     refcount = length(l_unplacedRefDes)
   ); endforeach 
   if(placedRefDes then
     axlFormSetField(Form "refdestot" refcount)
     return(list("All RefDes Placed"))
   else
     axlFormSetField(Form "refdestot" refcount)
     return(sort(l_unplacedRefDes nil))
   ); endif
 ); end of prog
); end defun
;##################################
;# End Of _getUnplacedRefDes      #
;##################################

;##################################
;# _refreshRefDes                 #
;##################################
(defun _refreshRefDes ()
      cur_refcount = refcount
      l_unplaced = _getUnplacedRefDes()
      if(cur_refcount != refcount then
        _loadRefDes()
      ); endif
); end defun
;##################################
;# End of _refreshRefDes          #
;##################################

;##################################
;# _loadRefDes                    #
;##################################
(defun _loadRefDes ()
  axlFormListDeleteAll(Form "Unplaced_List")
  foreach(one l_unplaced
   axlFormSetField(Form "Unplaced_List" one)
  ); endforeach
); end defun
;##################################
;# End Of _loadRefDes             #
;##################################

;##################################
;# _createForm                    #
;##################################
(defun _createForm ()
  Form = outfile("Place_symbols.form" "w")
  fprintf(Form "FILE_TYPE=FORM_DEFN VERSION=2\n")
  fprintf(Form "FORM\n")
  fprintf(Form "FIXED\n")
  fprintf(Form "PORT 87 23\n")
  fprintf(Form "HEADER \"Place Symbols\"\n")
  fprintf(Form "TILE\n")
  fprintf(Form "TEXT \"################################################################################\"\n")
  fprintf(Form "TLOC 2 2\n")
  fprintf(Form "ENDTEXT\n")
  fprintf(Form "TEXT \"#                                                                              #\"\n")
  fprintf(Form "TLOC 2 3\n")
  fprintf(Form "ENDTEXT\n")
  fprintf(Form "TEXT \"#        Place Allegro symbols by selecting them from the Menus below.         #\"\n")
  fprintf(Form "TLOC 2 4\n")
  fprintf(Form "ENDTEXT\n")
  fprintf(Form "TEXT \"#                                                                              #\"\n")
  fprintf(Form "TLOC 2 5\n")
  fprintf(Form "ENDTEXT\n")
  fprintf(Form "TEXT \"################################################################################\"\n")
  fprintf(Form "TLOC 2 6\n")
  fprintf(Form "ENDTEXT\n")
  fprintf(Form "TEXT \"MECHANICAL (.bsm)\"\n")
  fprintf(Form "TLOC 2 8\n")
  fprintf(Form "ENDTEXT\n")
  fprintf(Form "TEXT \"FORMAT (.osm)\"\n")
  fprintf(Form "TLOC 44 8\n")
  fprintf(Form "ENDTEXT\n")
  fprintf(Form "TEXT \"Total MECHANICAL Symbols:\"\n")
  fprintf(Form "TLOC 2 20\n")
  fprintf(Form "ENDTEXT\n")
  fprintf(Form "TEXT \"Total FORMAT Symbols:\"\n")
  fprintf(Form "TLOC 44 20\n")
  fprintf(Form "ENDTEXT\n")
  fprintf(Form "TEXT \"PACKAGE (.psm)\"\n")
  fprintf(Form "TLOC 2 25\n")
  fprintf(Form "ENDTEXT\n")
  fprintf(Form "TEXT \"REF DES\"\n")
  fprintf(Form "TLOC 44 25\n")
  fprintf(Form "ENDTEXT\n")
  fprintf(Form "TEXT \"Total PACKAGE Symbols:\"\n")
  fprintf(Form "TLOC 2 37\n")
  fprintf(Form "ENDTEXT\n")
  fprintf(Form "TEXT \"There are\"\n")
  fprintf(Form "TLOC 44 37\n")
  fprintf(Form "ENDTEXT\n")
  fprintf(Form "TEXT \"unplaced components.\"\n")
  fprintf(Form "TLOC 61 37\n")
  fprintf(Form "ENDTEXT\n")
  fprintf(Form "FIELD Mechanical_List\n")
  fprintf(Form "FLOC 2 10\n")
  fprintf(Form "LIST \"\" 40 5\n")
  fprintf(Form "ENDFIELD\n")
  fprintf(Form "FIELD Format_List\n")
  fprintf(Form "FLOC 44 10\n")
  fprintf(Form "LIST \"\" 40 5\n")
  fprintf(Form "ENDFIELD\n")
  fprintf(Form "FIELD mechtot\n")
  fprintf(Form "FLOC 28 20\n")
  fprintf(Form "INFO_ONLY\n")
  fprintf(Form "INTFILLIN 10 1\n")
  fprintf(Form "ENDFIELD\n")
  fprintf(Form "FIELD formattot\n")
  fprintf(Form "FLOC 66 20\n")
  fprintf(Form "INFO_ONLY\n")
  fprintf(Form "INTFILLIN 10 1\n")
  fprintf(Form "ENDFIELD\n")
  fprintf(Form "FIELD Package_List\n")
  fprintf(Form "FLOC 2 27\n")
  fprintf(Form "LIST \"\" 40 5\n")
  fprintf(Form "ENDFIELD\n")
  fprintf(Form "FIELD Unplaced_List\n")
  fprintf(Form "FLOC 44 27\n")
  fprintf(Form "LIST \"\" 40 5\n")
  fprintf(Form "ENDFIELD\n")
  fprintf(Form "FIELD psmtot\n")
  fprintf(Form "FLOC 25 37\n")
  fprintf(Form "INFO_ONLY\n")
  fprintf(Form "INTFILLIN 10 1\n")
  fprintf(Form "ENDFIELD\n")
  fprintf(Form "FIELD refdestot\n")
  fprintf(Form "FLOC 54 37\n")
  fprintf(Form "INTFILLIN 4 1\n")
  fprintf(Form "ENDFIELD\n")
  fprintf(Form "FIELD Refresh_List\n")
  fprintf(Form "FLOC 45 40\n")
  fprintf(Form "MENUBUTTON \"Refresh RefDes\" 16 3\n")
  fprintf(Form "ENDFIELD\n")
  fprintf(Form "FIELD cancel\n")
  fprintf(Form "FLOC 2 41\n")
  fprintf(Form "MENUBUTTON \"CANCEL\" 10 3\n")
  fprintf(Form "ENDFIELD\n")
  fprintf(Form "FIELD close\n")
  fprintf(Form "FLOC 14 41\n")
  fprintf(Form "MENUBUTTON \"CLOSE\" 10 3\n")
  fprintf(Form "ENDFIELD\n")
  fprintf(Form "ENDTILE\n")
  fprintf(Form "ENDFORM\n")
  close(Form)
); end defun
;##################################
;# End of _createForm             #
;##################################

;##################################
;#  _getSymbols                    #
;##################################
(defun _getSymbols (symext)
  l_symbols = ()
  symext = strcat(symext "$")
  foreach( dir symdirs
    if( (isDir dir) then
     l_symbols = append( l_symbols setof(x (getDirFiles dir) (rexMatchp symext x)) )
    ); endif
  ); end foreach
); end defun

;##################################
;# End of _getSymbols             #
;##################################

;**************************************************
;*      End of Function Subroutines               *
;**************************************************


;######################################################################
;#                    Main Program                                    #
;######################################################################

; Check the Skill path to make sure the current working directory(.)
; is set in the path.  Otherwise set it to the current working directory 
; so the Form will work.
firstone = car(parseString(car(getSkillPath())))
if(firstone != "./" && firstone != "." then
  axlUIWPrint(nil "** ERROR - Skill Path does not include the working directory%s.%s **" "(" ")")
  axlUIWPrint(nil "** Setting Skill Path to include %s.%s - Please Correct! **" "(" ")")
  curSkillPath = getSkillPath()
  setSkillPath(cons("." curSkillPath))
  ; remove form file if it is there
  if(isFile(strcat(firstone "/Place_symbols.form"))
   deleteFile(strcat(firstone "/Place_symbols.form"))
  ); endif
);endif

; Create the file, "Place_symbols.form"
 _createForm()


; =======  Get ALL the MECHANICAL, FORMAT, and PACKAGE symbols ========
sympath = axlGetVariable("psmpath")
symdirs = parseString(sympath)

; ======= Display the Place Symbols form =========================================
Form=axlFormCreate( (gensym) "Place_symbols.form" nil 'Form_Action t)
axlFormDisplay(Form)

;#########################################################################
;#  Get All the symbols (.bsm, .osm, and .psm)                           #
;#########################################################################
mechlist = list()
formatlist = list()
psmlist = list()
axlUIWPrint(nil "** Gathering symbols from PSMPATH, please wait. **")
l_exts = list(".bsm" ".osm" ".psm")
foreach(ext l_exts
  _getSymbols(ext)
  case(ext
   (".bsm" if(length(l_symbols) == 0 then
             mechlist = list("No Symbols Found")
             axlFormSetField(Form "Mechanical_List" car(mechlist))
             axlFormSetField(Form "mechtot" 0)
           else
             foreach(onesym l_symbols
               axlFormSetField(Form "Mechanical_List" onesym)
             ); endforeach
             axlFormSetField(Form "mechtot" length(l_symbols))
           )); endif
   (".osm" if(length(l_symbols) == 0 then
             formatlist = list("No Symbols Found")
             axlFormSetField(Form "Format_List" car(formatlist))
             axlFormSetField(Form "formattot" 0)
           else 
             foreach(onesym l_symbols
               axlFormSetField(Form "Format_List" onesym)
             ); endforeach
             axlFormSetField(Form "formattot" length(l_symbols))
           )); endif
   (".psm" if(length(l_symbols) == 0 then
             psmlist = list("No Symbols Found")
             axlFormSetField(Form "Package_List" car(psmlist))
             axlFormSetField(Form "psmtot" 0)
           else 
             foreach(onesym l_symbols
               axlFormSetField(Form "Package_List" onesym)
             ); endforeach
           axlFormSetField(Form "psmtot" length(l_symbols))
           )); endif
   ); endcase
); end foreach

axlUIWPrint(nil " - Done - " )


; ======= Get the Reference Designators ==========================================
; Get all the unplaced components (Refdes)
l_unplaced = _getUnplacedRefDes()

; ===== Load the Place Symbols form with the Reference Designators. ===============
; Enter the Refdes into the form
_loadRefDes()


; ===== Print message to the Place Symbols form. ==================================
axlUIWPrint(Form ">> Select Symbol/RefDes")

; ===== Remove the unix files created by this program. ============================
; remove Place_symbols.form
deleteFile("Place_symbols.form")

;######################################################################
;#             End of Main Program                                    #
;######################################################################

); enddefun place_sym

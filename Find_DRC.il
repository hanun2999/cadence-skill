; ##########################################################################
;
;                       Find DRC Markers from List
;
;   This routine will open a form which displays all DRC markers for a given
;   layer.

;   To run the routine within Allegro type "find drc".

;   Written by David J. Scheuring (djs@cadence.com)
;   Sr. Applications Eng. Cadence Design Systems
;   Oct. 9, 1995

;   This skill routine has been tested under version 10.0, 11.0, and 11.5

;   Revision A, May 17,1996
;   Changed default DRC_Layer from "TOP" to a dynamically set variable.
;   Changed Last_Layer from "BOTTOM" to a dynamically set variable.
;   Set the visibility for "ALL" to turn on all etch subclasses.
;   Incorporated Ok to proceed for List and Update.

;   Revision B, Oct. 29, 1996
;   Incorporated axlWindowBoxSet instead of allegro command. This is allow the routine
;   to work in Allegro Designer provided Find_DRC.il is made into a context.

; ##########################################################################

;   USAGE:
;      Entering "find drc" in the Allegro window will display the Find DRC Form
;      which will provide a popup window containing each DRC subclass, and a LIST
;      and OK button.

;   Find DRC From:
;      Select DRC Layer - This is used to select the subclass for which markers are
;                         listed. A left detect will toggle through each DRC subclass
;                         currently defined. A middle detect will display all subclass
;                         defined.
;      OK - This button resets the graphic display to it's former state and exits
;           the routine.
;      List - This button closes the Find DRC Form and displays the Find DRC Marker form.

;   Find DRC Marker:
;      OK - This button resets the graphic display to it's former state and exits
;           the routine.
;      Update - This button causes the list of DRCs to be update to reflect any corrections
;               made to the database.
;      DRC List - Left detect resets the graphic display appropriate to the subclass
;                 being reveiwes, centers the marker in the display, and sets the zoom
;                 level to an area equal to 500 drawing units around the marker.
      
;   Interactive editting of etch or component data is permissable while the Find DRC Marker
;   form is displayed. In fact the intent of this routine is to provide a semi-automated
;   mechanism that facilitates finding and correcting DRC errors. However, if Update is
;   pushed while an Allegro command is active an Error message is echoed stating that you
;   must first finish the Allegro command. The Update button does NOT run a design rule
;   check, it only reflects list the DRC markers currently defined in the database. Making
;   edits to the etch or component data invokes the real time DRC which automatically updates
;   the database.


axlCmdRegister("find drc" `Find_DRC_Main_Routine ?cmdType "interactive")

; #######################
; Define the main routine
; #######################
; This routine gathers the data needed to build the Find DRC Form
; Variables used in the routine are:
;   Visible_List - This defines current Class/Subclass visibility
;   Available_Layers - This defines the DRC subclasses
;   DRC_Layer - This defines the first subclass in the DRC class
;   Last_Layer - This defines the last subclass in the DRC class

 (defun Find_DRC_Main_Routine ()
  Visible_List=axlVisibleGet()
  Available_Layers=(axlGetParam("paramLayerGroup:DRC Error Class")->groupMembers)
  DRC_Layer=car(Available_Layers)
  Last_Layer=car(reverse(Available_Layers))
  Find_DRC_Routine()
 ); end defun Find_DRC_Main_Routine

 ; #####################################################
 ; Define the routine that writes the fform file to disk
 ; #####################################################
 ; Variables used in this routine are:
 ; Find_DRC_Form - internal form name

 (defun Find_DRC_Routine ()
  Find_DRC_Form=outfile("./Find_DRC_Form.form" "w")
  fprintf(Find_DRC_Form "FILE_TYPE=FORM_DEFN VERSION=2\n")
  fprintf(Find_DRC_Form "FORM\n")
  fprintf(Find_DRC_Form "FIXED\n")
  fprintf(Find_DRC_Form "PORT 27 5\n")
  fprintf(Find_DRC_Form "HEADER \"Find DRC Form\"\n")
  fprintf(Find_DRC_Form "POPUP <Layer_Names>")
  (foreach Item Available_Layers
   (if Item==Last_Layer then
    (fprintf Find_DRC_Form "\"%s\"" Item)
    (fprintf Find_DRC_Form "\"%s\".\n" Item)
    else
    (fprintf Find_DRC_Form "\"%s\"" Item)
    (fprintf Find_DRC_Form "\"%s\"," Item)
   ); end if Item==Last_Layer
  ); end foreach Item Available_Layers
  fprintf(Find_DRC_Form "TILE\n")
  fprintf(Find_DRC_Form "TEXT \"Select DRC Layer:\"\n")
  fprintf(Find_DRC_Form "TLOC 3 1\n")
  fprintf(Find_DRC_Form "ENDTEXT\n")
  fprintf(Find_DRC_Form "FIELD Existing_Layer_Names\n")
  fprintf(Find_DRC_Form "FLOC 2 3\n")
  fprintf(Find_DRC_Form "ENUMSET 20\n")
  fprintf(Find_DRC_Form "POP \"Layer_Names\"\n")
  fprintf(Find_DRC_Form "ENDFIELD\n")
  fprintf(Find_DRC_Form "FIELD List\n")
  fprintf(Find_DRC_Form "FLOC 16 6\n")
  fprintf(Find_DRC_Form "MENUBUTTON \"List\" 9 3\n")
  fprintf(Find_DRC_Form "ENDFIELD\n")
  fprintf(Find_DRC_Form "FIELD Done\n")
  fprintf(Find_DRC_Form "FLOC 2 6\n")
  fprintf(Find_DRC_Form "MENUBUTTON \"Done\" 9 3\n")
  fprintf(Find_DRC_Form "ENDFIELD\n")
  fprintf(Find_DRC_Form "ENDTILE\n")
  fprintf(Find_DRC_Form "ENDFORM\n")
  close(Find_DRC_Form)
  
  Find_DRC_Form=axlFormCreate( (gensym) "Find_DRC_Form.form" '(e inner) 'Find_DRC_Form_Action t)
  axlFormDisplay(Find_DRC_Form)
  axlFormSetField(Find_DRC_Form "Existing_Layer_Names" DRC_Layer)

  ; ###############################
  ; Define the Find DRC form action
  ; ###############################
  ; Variables used in thei routine are:
  ; DRC_Layer - This represents the DRC subclass to be listed

  (defun Find_DRC_Form_Action (Find_DRC_Form)
   (case Find_DRC_Form->curField
    ("Done"
     axlFormClose(Find_DRC_Form)
     axlCancelEnterFun()
     shell("rm Find_DRC_Form.form")
     axlVisibleSet(Visible_List)
     axlShell("redisplay")
     nil
    ); end "Done"
    ("Existing_Layer_Names"
     DRC_Layer=(Find_DRC_Form->curValue)
     t
    ); end "Existing_Layer_Names"
    ("List"
     (when axlOKToProceed()
      axlFormClose(Find_DRC_Form)
      axlVisibleDesign(nil)
      (if DRC_Layer=="PACKAGE_TOP" then
       axlVisibleLayer(sprintf(dummy "DRC Error Class/%s" DRC_Layer) t)
       axlVisibleLayer(sprintf(dummy "Pin/%s" DRC_Layer) t)
       axlVisibleLayer("Package Geometry/PLACE_BOUND_TOP" t)
       axlVisibleLayer("Package Geometry/ASSEMBLY_TOP" t)
       axlVisibleLayer("Package Keepout/TOP" t)
       axlVisibleLayer("Package Keepout/ALL" t)
       axlVisibleLayer("Package Keepin/ALL" t)
       else
       (if DRC_Layer=="PACKAGE_BOTTOM" then
        axlVisibleLayer(sprintf(dummy "DRC Error Class/%s" DRC_Layer) t)
        axlVisibleLayer(sprintf(dummy "Pin/%s" DRC_Layer) t)
        axlVisibleLayer("Package Geometry/PLACE_BOUND_BOTTOM" t)
        axlVisibleLayer("Package Geometry/ASSEMBLY_BOTTOM" t)
        axlVisibleLayer("Package Keepout/BOTTOM" t)
        axlVisibleLayer("Package Keepout/BOTTOM" t)
        axlVisibleLayer("Package Keepout/ALL" t)
        axlVisibleLayer("Package Keepin/ALL" t)
        else
        (if DRC_Layer=="ALL" then
         axlVisibleLayer(sprintf(dummy "DRC Error Class/%s" DRC_Layer) t)
         axlVisibleLayer("Pin/TOP" t)
         axlVisibleLayer("Via Class/TOP" t)
         (foreach subclass (axlGetParam("paramLayerGroup:ETCH")->groupMembers)
          axlVisibleLayer(sprintf(dummy "Etch/%s" subclass) t)
         ); end foreach
         else
         axlVisibleLayer(sprintf(dummy "Etch/%s" DRC_Layer) t)
         axlVisibleLayer(sprintf(dummy "Pin/%s" DRC_Layer) t)
         axlVisibleLayer(sprintf(dummy "Via Class/%s" DRC_Layer) t)
         axlVisibleLayer(sprintf(dummy "DRC Error Class/%s" DRC_Layer) t)
         axlVisibleLayer("Route Keepin/ALL" t)
         axlVisibleLayer(sprintf(dummy "Route Keepout/%s" DRC_Layer) t)
         axlVisibleLayer("Route Keepout/ALL" t)
         axlVisibleLayer(sprintf(dummy "Via Keepout/%s" DRC_Layer) t)
         axlVisibleLayer("Via Keepout/ALL" t)
        ); end if DRC_Layer=="ALL"
       ); end if DRC_Layer=="PACKAGE_BOTTOM"
      ); end DRC_Layer=="PACKAGE_TOP"
      axlFlushDisplay()
      axlShell("redisplay")
      List_DRC_Routine()
     ); end when
    ); end "List"
   ); end case Find_DRC_Form->curField
  ); end defun Find_DRC_Form_Action
 ); end defun Find_DRC_Routine

; #############################################
; Define the routine that lists the DRC markers
; #############################################
; Variables used in this routine are:
; List_DRC_From - the name of the file containing the form data
; DRC_List - A list of all DRC errors in the database
; Error_List - DRC_List with XY location and descriptions

 (defun List_DRC_Routine ()
  axlDBRefreshId(axlDBGetDesign())
  axlClearSelSet()
  List_DRC_From=outfile("List_DRC_From.form" "w")
  fprintf(List_DRC_From "FILE_TYPE=FORM_DEFN VERSION=2\n")
  fprintf(List_DRC_From "FORM\n")
  fprintf(List_DRC_From "FIXED\n")
  fprintf(List_DRC_From "PORT 80 10\n")
  fprintf(List_DRC_From "HEADER \"Find DRC Marker\"\n")
  fprintf(List_DRC_From "TILE\n")
  fprintf(List_DRC_From "TEXT \"DRC LIST\"\n")
  fprintf(List_DRC_From "TLOC 35 0\n")
  fprintf(List_DRC_From "ENDTEXT\n")
  fprintf(List_DRC_From "FIELD DRC_List\n")
  fprintf(List_DRC_From "FLOC 2 2\n")
  fprintf(List_DRC_From "LIST \"\" 77 6\n")
  fprintf(List_DRC_From "ENDFIELD\n")
  fprintf(List_DRC_From "FIELD Reset\n")
  fprintf(List_DRC_From "FLOC 54 16\n")
  fprintf(List_DRC_From "MENUBUTTON \"Reset\" 20 3\n")
  fprintf(List_DRC_From "ENDFIELD\n")
  fprintf(List_DRC_From "FIELD Update\n")
  fprintf(List_DRC_From "FLOC 30 16\n")
  fprintf(List_DRC_From "MENUBUTTON \"Update\" 20 3\n")
  fprintf(List_DRC_From "ENDFIELD\n")
  fprintf(List_DRC_From "FIELD Done\n")
  fprintf(List_DRC_From "FLOC 6 16\n")
  fprintf(List_DRC_From "MENUBUTTON \"Done\" 20 3\n")
  fprintf(List_DRC_From "ENDFIELD\n")
  fprintf(List_DRC_From "ENDTILE\n")
  fprintf(List_DRC_From "ENDFORM\n")
  close(List_DRC_From)

  ; #####################
  ; Generate list of DRCs
  ; #####################
  axlSetFindFilter(?enabled '(noall drcs) ?onButtons '(noall drcs))
  DRC_List=axlGetSelSet(axlAddSelectAll())
  axlClearSelSet()
  Error_List=nil
  (foreach DRC DRC_List
   Error_List=cons(sprintf(dummy "%s; Is %s; Should be %s; X/Y ,%f,%f" DRC->name DRC->actual DRC->expected car(DRC->xy) car(cdr(DRC->xy))) Error_List)
  )

  ; #################################
  ; Define the place list form action
  ; #################################
  ; Variables used in this routine are:
  ; DRC_List - a list of all DRC errors in the database
  ; Error_List - DRC_List with XY locations and descriptions
  ; Counter - Used to determine parser location within Error_List
  ; X_Loc - X coordinate of DRC marker
  ; Y_Loc - Y coordinate of DRC marker
  ; Lower_X - Lower X extent of graphics display
  ; Lower_Y - Lower Y extent of graphics display
  ; Upper_X - Upper X extent of graphics display
  ; Upper_Y - Upper Y extent of graphics display
  ; List_DRC_From - the internal name of the List DRC Form file

  (defun List_DRC_From_Action_Routine (List_DRC_From)
   (case List_DRC_From->curField
    ("Done"
     DRC_List=nil
     Error_List=nil
     (axlFormClose List_DRC_From)
     (axlCancelEnterFun)
     axlVisibleSet(Visible_List)
     axlShell("redisplay")
    ); end "Done"
    ("Update"
     (when axlOKToProceed()
      Error_List=nil
      axlDBRefreshId(axlDBGetDesign())
      axlSetFindFilter(?enabled '(noall drcs) ?onButtons '(noall drcs))
      DRC_List=axlGetSelSet(axlAddSelectAll())
      axlClearSelSet()
      (if DRC_List==nil then
       axlFormListDeleteAll(List_DRC_From "DRC_List")
       axlFormSetField(List_DRC_From "DRC_List" "No DRCs on this Layer")
       axlFormDisplay(List_DRC_From)
       axlUIWPrint(List_DRC_From "No DRCs on this Layer")
       else
       (foreach DRC DRC_List
        Error_List=cons(sprintf(dummy "%s; Is %s; Should be %s; X/Y ,%f,%f" DRC->name DRC->actual DRC->expected car(DRC->xy) car(cdr(DRC->xy))) Error_List)
       ); end foreach DRC DRC_List
       Error_List=sort(Error_List nil)
       axlFormListDeleteAll(List_DRC_From "DRC_List")
       (foreach Error Error_List
       axlFormSetField(List_DRC_From "DRC_List" Error)
        axlFormDisplay(List_DRC_From)
        axlUIWPrint(List_DRC_From "Select Error")
       ); end foreach Error Error_List
      ); end if DRC_List==nil
     ); end when
    ); end "Update"
    ("Reset"
     DRC_List=nil
     Error_List=nil
     (axlFormClose List_DRC_From)
     (axlCancelEnterFun)
     Find_DRC_Routine()
    ); end "Reset"
    ("DRC_List"
     axlSetFindFilter(?enabled '(noall drcs) ?onButtons '(noall drcs))
     DRC=List_DRC_From->curValue
     Counter=0
     (foreach String parseString(DRC ",")
      Counter=Counter+1
      (if Counter==2 then
       X_Loc=atof(String)
      ); end if Counter=2
      (if Counter==3 then
       Y_Loc=atof(String)
      ); end if Counter=3
     ); end foreach String parseString(DRC ",")
     Lower_X=X_Loc-500
     Lower_Y=Y_Loc-500
     Upper_X=X_Loc+500
     Upper_Y=Y_Loc+500
     axlWindowBoxSet(list(Lower_X:Lower_Y Upper_X:Upper_Y))
     axlFlushDisplay()
     t
    ); end "DRC_List"
   ); end case
  ); end defun List_DRC_From_Action_Routine

  ; #####################
  ; Display the form/list
  ; #####################
   List_DRC_From=axlFormCreate( (gensym) "List_DRC_From.form" '(e outer) 'List_DRC_From_Action_Routine t)
   (if DRC_List==nil then
    axlFormSetField(List_DRC_From "DRC_List" "No DRCs on this Layer")
    axlFormDisplay(List_DRC_From)
    axlUIWPrint(List_DRC_From "No DRCs on this Layer")
    else
    List_DRC_From=axlFormCreate( (gensym) "List_DRC_From.form" '(e outer) 'List_DRC_From_Action_Routine t)
    Error_List=sort(Error_List nil)
    (foreach Error Error_List
     axlFormSetField(List_DRC_From "DRC_List" Error)
     axlFormDisplay(List_DRC_From)
     axlUIWPrint(List_DRC_From "Select Error")
    ); end foreach Ref_Des Placed_Lis
   ); end if DRC_List==nil
  shell("rm List_DRC_From.form")
); end defun List_DRC_Routine

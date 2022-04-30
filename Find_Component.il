; ##########################################################################
;
;                       Find Components from List
;
;   This routine will open a form which displays all currently placed
;   components. When the user selects a ref des from the list the component
;   is highlighted and the working window is resized to the components
;   bounding box with 500 drawing units (500 mils) on each side. The "Filter"
;   in the form allows the user to select only components beginning with the
;   specified character. The "REFRESH LIST" button updates the list with the
;   current data taking any filter setting into account.

;   To run the routine within Allegro type "find component".

;   Written by David J. Scheuring
;   Sr. Applications Eng. Cadence Design Systems
;   May 31, 1995

axlCmdRegister( "find component" `Find_Component_Routine ?cmdType "interactive")

; ########################
; Set the global variables
; ########################

Ref_Des_Filter="*"
Comp_List=nil
Placed_List=nil

(defun Find_Component_Routine ()
 axlDBRefreshId(axlDBGetDesign())
 axlClearSelSet()

 ; #################
 ; Declare variables
 ; #################
 (let (Find_Component_Form Command)

  ; ###############
  ; Clear variables
  ; ###############
  Find_Component_Form=nil
  Command=nil

  ; ####################################
  ; Build the placed component list form
  ; ####################################
  Find_Component_Form=outfile("Find_Component_Form.form" "w")
  fprintf(Find_Component_Form "FILE_TYPE=FORM_DEFN VERSION=2\n")
  fprintf(Find_Component_Form "FORM\n")
  fprintf(Find_Component_Form "FIXED\n")
  fprintf(Find_Component_Form "PORT 25 20\n")
  fprintf(Find_Component_Form "HEADER \"Find Component\"\n")
  fprintf(Find_Component_Form "TILE\n")
  fprintf(Find_Component_Form "TEXT \"COMPONENTS LIST\"\n")
  fprintf(Find_Component_Form "TLOC 4 0\n")
  fprintf(Find_Component_Form "ENDTEXT\n")
  
  fprintf(Find_Component_Form "FIELD Placed_List\n")
  fprintf(Find_Component_Form "FLOC 2 2\n")
  fprintf(Find_Component_Form "LIST \"\" 21 10\n")
  fprintf(Find_Component_Form "ENDFIELD\n")
  
  fprintf(Find_Component_Form "TEXT \"Current Ref Des\"\n")
  fprintf(Find_Component_Form "TLOC 2 25\n")
  fprintf(Find_Component_Form "ENDTEXT\n")
  
  fprintf(Find_Component_Form "FIELD Current_Ref_Des\n")
  fprintf(Find_Component_Form "FLOC 2 27\n")
  fprintf(Find_Component_Form "STRFILLIN 16 10\n")
  fprintf(Find_Component_Form "ENDFIELD\n")
  
  fprintf(Find_Component_Form "TEXT \"Filter:\"\n")
  fprintf(Find_Component_Form "TLOC 2 30\n")
  fprintf(Find_Component_Form "ENDTEXT\n")
  
  fprintf(Find_Component_Form "FIELD Ref_Des_Filter\n")
  fprintf(Find_Component_Form "FLOC 10 30\n")
  fprintf(Find_Component_Form "STRFILLIN 5 10\n")
  fprintf(Find_Component_Form "ENDFIELD\n")
  
  fprintf(Find_Component_Form "FIELD Refresh_List\n")
  fprintf(Find_Component_Form "FLOC 2 33\n")
  fprintf(Find_Component_Form "MENUBUTTON \"REFRESH LIST\" 15 3\n")
  fprintf(Find_Component_Form "ENDFIELD\n")
  
  fprintf(Find_Component_Form "FIELD done\n")
  fprintf(Find_Component_Form "FLOC 2 36\n")
  fprintf(Find_Component_Form "MENUBUTTON \"Done\" 6 3\n")
  fprintf(Find_Component_Form "ENDFIELD\n")
  
  fprintf(Find_Component_Form "ENDTILE\n")
  fprintf(Find_Component_Form "ENDFORM\n")
  close(Find_Component_Form)

  ; ##################################
  ; Generate list of placed components
  ; ##################################
  axlSetFindFilter(?enabled '(noall components) ?onButtons '(noall components))
  Comp_List=axlGetSelSet(axlSingleSelectName("COMPONENT" Ref_Des_Filter))
  (foreach Item Comp_List
   (if Item->symbol!=nil then
    Placed_List = cons(Item->name Placed_List)
   ); if Item->symbol!=nil
  ); end foreach Item Comp_List

  ; #################################
  ; Define the place list form action
  ; #################################
  (defun Find_Component_Form_Action_Routine (Find_Component_Form)
   (case Find_Component_Form->curField
   
    ("Refresh_List"
    Placed_List=nil
    axlDBRefreshId(axlDBGetDesign())
    axlClearSelSet()
    axlSetFindFilter(?enabled '(noall components) ?onButtons '(noall components))
    Comp_List=axlGetSelSet(axlSingleSelectName("COMPONENT" Ref_Des_Filter))
    (foreach Item Comp_List
     (if Item->symbol!=nil then
      Placed_List=cons(Item->name Placed_List)
     ); end if Item->symbol!=nil
    ); end foreach Item Comp_List
    (if Placed_List==nil then
     axlFormListDeleteAll(Find_Component_Form "Placed_List")
     axlFormSetField(Find_Component_Form "Placed_List" "No Match")
     axlFormSetField(Find_Component_Form "Ref_Des_Filter" Ref_Des_Filter)
     axlFormDisplay(Find_Component_Form)
     axlUIWPrint(Find_Component_Form "No Match")
     else
     axlFormListDeleteAll(Find_Component_Form "Placed_List")
     Placed_List=sort(Placed_List nil)
     (foreach Ref_Des Placed_List
      axlFormSetField(Find_Component_Form "Placed_List" Ref_Des)
      axlFormSetField(Find_Component_Form "Ref_Des_Filter" Ref_Des_Filter)
      axlFormDisplay(Find_Component_Form)
      axlUIWPrint(Find_Component_Form "Select Component")
     ); end foreach Ref_Des Placed_List
    ); end if Placed_List==nil
   ); end Refresh_List
   
    ("Ref_Des_Filter"
     Ref_Des_Filter=strcat(Find_Component_Form->curValue "*")
     t
    ); end "Ref_Des_Filter"
	
    ("done"
     Placed_List=nil
     (axlFormClose Find_Component_Form)
     (axlCancelEnterFun)
    ); end "done"
	
    ("Placed_List"
     axlSetFindFilter(?enabled '(components) ?onButtons '(components))
     Component=axlGetSelSet(axlSingleSelectName("COMPONENT" strcat(Find_Component_Form->curValue)))
     axlHighlightObject(Component)
     Lower_X=car(car(car(Component)->symbol->bBox))-500
     Lower_Y=car(cdr(car(car(Component)->symbol->bBox)))-500
     Upper_X=car(car(cdr(car(Component)->symbol->bBox)))+500
     Upper_Y=car(cdr(car(cdr(car(Component)->symbol->bBox))))+500
     Command=sprintf(dummy "window points;x %f y %f;x %f y %f" Lower_X Lower_Y Upper_X Upper_Y)
     axlFormSetField(Find_Component_Form "Current_Ref_Des" Find_Component_Form->curValue)
     axlShell(Command)
     t
    ); end "Placed_List"
	
   ); end case
  ); end defun Find_Component_Form_Action_Routine

  ; #####################
  ; Display the form/list
  ; #####################
   Find_Component_Form=axlFormCreate( (gensym) "Find_Component_Form.form" '(e outer) 'Find_Component_Form_Action_Routine t)
   (if Placed_List==nil then
    axlFormSetField(Find_Component_Form "Placed_List" "No Placed Comps")
    axlFormSetField(Find_Component_Form "Ref_Des_Filter" Ref_Des_Filter)
    axlFormDisplay(Find_Component_Form)
    axlUIWPrint(Find_Component_Form "No Placed Comps")
    else
    Find_Component_Form=axlFormCreate( (gensym) "Find_Component_Form.form" '(e outer) 'Find_Component_Form_Action_Routine t)
    Placed_List=sort(Placed_List nil)
    (foreach Ref_Des Placed_List
     axlFormSetField(Find_Component_Form "Placed_List" Ref_Des)
     axlFormSetField(Find_Component_Form "Ref_Des_Filter" Ref_Des_Filter)
     axlFormDisplay(Find_Component_Form)
     axlUIWPrint(Find_Component_Form "Select Component")
    ); end foreach Ref_Des Placed_Lis
   ); end if Placed_List==nil
  shell("rm Find_Component_Form.form")
 ); end let
); end defun Find_Component_Routine

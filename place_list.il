; ##########################################################################
;
;                       Place Component from List
;
;   This routine will open a form which displays all currently unplaced
;   components. When the user selects a ref des from the list it is attached
;   to the cursor in "place" mode. All of the standard middle mouse button
;   operations are available (as in the standard place by refdes) except the
;   "next" and "oops" buttons. The equivelant to next or oops is to mearly
;   select a new refdes from the list. The "Filter" in the form allows the
;   user to select only components beginning with the specified character.
;   The "REFRESH LIST" button updates the list with the current data taking
;   any filter setting into account. The list of reference designators does
;   not update automatically. After placing components from the list the user
;   must hit the "REFRESH LIST" button to update the list with current data.
;   The "PLACE BY REF DES" form can be left open and accessed at any time
;   regardless of the current mode Allegro is in.

;   To run the routine within Allegro type "place list".

;   Written by David J. Scheuring
;   Sr. Applications Eng. Cadence Design Systems
;   May 20, 1994
;   Modified Apr 1999 - improved performance in 13/13.5 - blm@cadence.com









axlCmdRegister( "place list" `Place_By_List)

; ########################
; Set the global variables
; ########################

Ref_Des_Filter="*"
Comp_List=nil
Unplaced_List=nil

(defun Place_By_List ()

 axlDBRefreshId(axlDBGetDesign())
 axlClearSelSet()

 ; #################
 ; Declare variables
 ; #################

 (let (
       Form
       Command
      )


  ; ###############
  ; Clear variables
  ; ###############
 
  Form=nil
  Command=nil
 
  ; #########################
  ; Build the place list form
  ; #########################
 
Form=outfile("Form.form" "w")
fprintf(Form "FILE_TYPE=FORM_DEFN VERSION=2\n")
fprintf(Form "FORM\n")
fprintf(Form "FIXED\n")
fprintf(Form "PORT 25 20\n")
fprintf(Form "HEADER \"PLACE BY REF DES\"\n")
fprintf(Form "TILE\n")
fprintf(Form "TEXT \"UNPLACED COMPONENTS\"\n")
fprintf(Form "TLOC 2 0\n")
fprintf(Form "ENDTEXT\n")
fprintf(Form "FIELD Unplaced_List\n")
fprintf(Form "FLOC 2 2\n")
fprintf(Form "LIST \"\" 21 10\n")
fprintf(Form "ENDFIELD\n")
fprintf(Form "TEXT \"Current Ref Des\"\n")
fprintf(Form "TLOC 2 21\n")
fprintf(Form "ENDTEXT\n")
fprintf(Form "FIELD Current_Ref_Des\n")
fprintf(Form "FLOC 2 23\n")
fprintf(Form "STRFILLIN 16 10\n")
fprintf(Form "ENDFIELD\n")
fprintf(Form "TEXT \"Filter:\"\n")
fprintf(Form "TLOC 2 26\n")
fprintf(Form "ENDTEXT\n")
fprintf(Form "FIELD Ref_Des_Filter\n")
fprintf(Form "FLOC 10 26\n")
fprintf(Form "STRFILLIN 5 10\n")
fprintf(Form "ENDFIELD\n")
fprintf(Form "FIELD Refresh_List\n")
fprintf(Form "FLOC 2 29\n")
fprintf(Form "MENUBUTTON \"REFRESH LIST\" 15 3\n")
fprintf(Form "ENDFIELD\n")
fprintf(Form "FIELD done\n")
fprintf(Form "FLOC 2 32\n")
fprintf(Form "MENUBUTTON \"Done\" 6 3\n")
fprintf(Form "ENDFIELD\n")
fprintf(Form "ENDTILE\n")
fprintf(Form "ENDFORM\n")
close(Form)
 
  ; ####################################
  ; Generate list of unplaced components
  ; ####################################
 
  axlSetFindFilter(?enabled '(noall components) ?onButtons '(noall components))
  Comp_List=axlGetSelSet(axlSingleSelectName("COMPONENT" Ref_Des_Filter))
 
  (foreach Item Comp_List
 
  (if Item->symbol==nil then
 
   Unplaced_List=cons(Item->name Unplaced_List)
 
  ); if Item->symbol==nil
 
  ); end foreach Item Comp_List
 
 
  ; #####################
  ; Display the form/list
  ; #####################
 
   Form=axlFormCreate( (gensym) "Form.form" '(e outer) 'Form_Action t)
 
   (if Unplaced_List==nil then
 
    axlFormSetField(Form "Unplaced_List" "No Unplaced Comps")
    axlFormSetField(Form "Ref_Des_Filter" Ref_Des_Filter)
    axlUIWPrint(Form "No Unplaced Comps")
 
    else
 
    Unplaced_List=sort(Unplaced_List nil)
 
    (foreach Ref_Des Unplaced_List
        axlFormSetField(Form "Unplaced_List" Ref_Des)
    ); end foreach Ref_Des Unplaced_Lis
     axlFormSetField(Form "Ref_Des_Filter" Ref_Des_Filter)
     axlUIWPrint(Form "Select Component")
 
   ); end if Unplaced_List==nil

   axlFormSetField(Form "Unplaced_List" nil)
   axlFormDisplay(Form)
 
   shell("rm Form.form")
 
 ); end let
 
); end defun Place_By_List



 
  ; #################################
  ; Define the place list form action
  ; #################################
 
  (defun Form_Action (Form)
 
   (case Form->curField
 
    ("Refresh_List"
 
    Unplaced_List=nil
    axlDBRefreshId(axlDBGetDesign())
    axlClearSelSet()
    axlSetFindFilter(?enabled '(noall components) ?onButtons '(noall components))
    Comp_List=axlGetSelSet(axlSingleSelectName("COMPONENT" Ref_Des_Filter))
 
    (foreach Item Comp_List
 
     (if Item->symbol==nil then
 
      Unplaced_List=cons(Item->name Unplaced_List)
 
     ); end if Item->symbol==nil
 
    ); end foreach Item Comp_List
 
    (if Unplaced_List==nil then
 
     axlFormListDeleteAll(Form "Unplaced_List")
     axlFormSetField(Form "Unplaced_List" "No Match")
     axlFormSetField(Form "Unplaced_List" nil)
     axlFormSetField(Form "Ref_Des_Filter" Ref_Des_Filter)
     axlUIWPrint(Form "No Match")
 
    else

     axlFormListDeleteAll(Form "Unplaced_List")
     Unplaced_List=sort(Unplaced_List nil)

     (foreach Ref_Des Unplaced_List
      axlFormSetField(Form "Unplaced_List" Ref_Des)
     ); end foreach Ref_Des Unplaced_List

;################################################################
;
;         ADDED LINE BELOW
;
;################################################################
      axlFormSetField(Form "Unplaced_List" nil)

      axlFormSetField(Form "Ref_Des_Filter" Ref_Des_Filter)
 
      axlUIWPrint(Form "Select Component")
 
    ); end if Unplaced_List==nil
 
   ); end Refresh_List
 
    ("Ref_Des_Filter"
 
     Ref_Des_Filter=strcat(Form->curValue "*")
     t
 
    ); end "Ref_Des_Filter"
 
    ("done"
 
     Unplaced_List=nil
     (axlFormClose Form)
     (axlFinishEnterFun)
 
    ); end "done"
 
    ("Unplaced_List"
 
     Command=strcat("place refdes " Form->curValue)
     axlFormSetField(Form "Current_Ref_Des" Form->curValue)
     axlShell(Command)
     t
 
    ); end "Unplaced_List"
 
   ); end case
 
  ); end defun Form_Action
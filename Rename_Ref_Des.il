; ###############################################################################
 
;                   Interactive Reference Designator renaming

;  This routine will open a form which allows the operator to specify the new prefix
;  and starting number to use when renaming components. By selecting "Begin Rename"
;  the form is replaced with a form which displays the "Next Number" that will be
;  used when a reference designator is selected. The next number will increment by
;  1 with each selection. The routine will also highlight all components whose name
;  matches the new pefix. This makes it much easier to determine which components
;  should be selected when viewing the whole board. As each ref des is selected it
;  is changed to the current "next number" and the component is de-highlighted. The
;  routine tracks the number of components that have been changed and compares the
;  the running talley against the number of components whose prefix matches the the
;  Match Prefix, when the last matching component is renamed the tracking form will
;  automatically close and the original Rename form will be displayed.

;  The action of the form is as follows:
;  > Match Prefix - This field is used to specify the ref des prefix to use when
;    highlighting components.
;  > New Prefix - This field is used to specify the ref des prefix to use when the
;    components are renamed.
;  > Start Number - This field is used to specify the starting number to use when
;    renaming the components.
;  > Begine Rename - This button closes the Rename Ref Des form and opens the Tracking
;    form. All components whose ref des matches the match prefix are highlighted and
;    the operator is prompted to "Enter selection point". With each ref des selected
;    the component is renamed to the current next number and the selected component
;    is de-highlighted. A middle mouse button push will display a popup containing
;    3 selections described below.
;  > Cancel Rename - This button closes the Rename Ref Des form and exits the routine.

;  The action of the Popup is as follows:
;  > Reset - Selecting reset closes the tracking form, de-highlights any comps still
;    highlighted, and re-opens the Rename Ref Des form allowing the operator to change
;    the new prefix and starting number so that a new group of components may be renamed.
;  > Oops - Selecting oops will change the previously changed ref des back to it's
;    original value. If no ref des renames have yet been made a "Nothing to Oops"
;    confirmer will be displayed. The Oops routine keeps track of all ref des changes
;    in a session (from Begine Rename to Done, Reset, or Cancel Rename) and may be used
;    to back all changed ref des to their original value. After the first change has
;    been converted back to it's original value pushing the Oops button will display a
;    "Nothing to Oops" confirmer.
;  > Done - Selecting done closes the tracking form, de-highlights any comps still
;    highlighted, and exits the routine.

;  NOTES:
;  > When making a selection select the reference designator not the component.
;  > Because there is no way to rename a component with skill this routine uses an
;    Allegro script to make the actual text change. Therefore if two or more ref des
;    share an X/Y location or overlap, the wrong component may be renamed. It is 
;    suggested that the rename routine not be run until the ref des have been
;    repositioned for readability.

;  To start the routine in Allegro type "rename ref des"
 
;  Written by David J. Scheuring
;  Sr. Applications Eng. Cadence Design Systems
;  June 2, 1995
 
axlCmdRegister( "rename ref des" 'Rename_Ref_Des_Routine ?cmdType "interactive")
 
; Set the global variables
; ########################
Match_Prefix="U"; This variable represents the prefix to match
New_Prefix="U"; This variable represents the prefix to rename to
Start_Number=1; theis varible represents the first number to use when renaming

; Define the routine to get things started
; ########################################
defun(Rename_Ref_Des_Routine ()

   ; Set the variables
   ; #################
   Finished=nil; this variable is used to determine when to stop requesting another selection
   Oops_On=nil; this variable is used to determine when an Oops has been pushed
   Oops_List=nil; This list keeps track of the old (pre-rename) ref des
   New_Name_List=nil; This list keeps track of the new (changed) ref des
   X_Y_Loc_List=nil; This list keeps track of the ref des locations so Oops can find them

   ; Run the routine to create the form
   ; ##################################
   Rename_Form_Routine()

   ; Display the form and set the fields
   ; ###################################
   Rename_Ref_Des_Form=axlFormCreate( (gensym) "Rename_Ref_Des_Form.form" '(e inner) 'Rename_Form_Action t)
   axlFormDisplay(Rename_Ref_Des_Form)
   axlFormSetField(Rename_Ref_Des_Form "Match_Prefix_Field" upperCase(Match_Prefix))
   axlFormSetField(Rename_Ref_Des_Form "New_Prefix_Field" upperCase(New_Prefix))
   axlFormSetField(Rename_Ref_Des_Form "Start_Number_field" Start_Number)
); end defun Rename_Ref_Des_Routine

; Create the Rename Ref Des form
; ##############################
defun(Rename_Form_Routine ()
   Rename_Ref_Des_Form=outfile("./Rename_Ref_Des_Form.form" "w")
   fprintf(Rename_Ref_Des_Form "FILE_TYPE=FORM_DEFN VERSION=2\n")
   fprintf(Rename_Ref_Des_Form "FORM\n")
   fprintf(Rename_Ref_Des_Form "FIXED\n")
   fprintf(Rename_Ref_Des_Form "HEADER \"Rename Ref Des\"\n")
   fprintf(Rename_Ref_Des_Form "PORT 25 9\n")
   fprintf(Rename_Ref_Des_Form "TILE\n")
   fprintf(Rename_Ref_Des_Form "TEXT \"Match Prefix:\"\n")
   fprintf(Rename_Ref_Des_Form "TLOC 1 1\n")
   fprintf(Rename_Ref_Des_Form "ENDTEXT\n")
   fprintf(Rename_Ref_Des_Form "FIELD Match_Prefix_Field\n")
   fprintf(Rename_Ref_Des_Form "FLOC 15 1\n")
   fprintf(Rename_Ref_Des_Form "STRFILLIN 6 30\n")
   fprintf(Rename_Ref_Des_Form "ENDFIELD\n")
   fprintf(Rename_Ref_Des_Form "TEXT \"New  Prefix :\"\n")
   fprintf(Rename_Ref_Des_Form "TLOC 1 4\n")
   fprintf(Rename_Ref_Des_Form "ENDTEXT\n")
   fprintf(Rename_Ref_Des_Form "FIELD New_Prefix_Field\n")
   fprintf(Rename_Ref_Des_Form "FLOC 15 4\n")
   fprintf(Rename_Ref_Des_Form "STRFILLIN 6 30\n")
   fprintf(Rename_Ref_Des_Form "ENDFIELD\n")
   fprintf(Rename_Ref_Des_Form "TEXT \"Start Number:\"\n")
   fprintf(Rename_Ref_Des_Form "TLOC 1 7\n")
   fprintf(Rename_Ref_Des_Form "ENDTEXT\n")
   fprintf(Rename_Ref_Des_Form "FIELD Start_Number_Field\n")
   fprintf(Rename_Ref_Des_Form "FLOC 15 7\n")
   fprintf(Rename_Ref_Des_Form "INTFILLIN 6 30\n")
   fprintf(Rename_Ref_Des_Form "ENDFIELD\n")
   fprintf(Rename_Ref_Des_Form "FIELD Begin_Rename_Field\n")
   fprintf(Rename_Ref_Des_Form "FLOC 5 10\n")
   fprintf(Rename_Ref_Des_Form "MENUBUTTON \"Begin Rename\" 15 3\n")
   fprintf(Rename_Ref_Des_Form "ENDFIELD\n")
   fprintf(Rename_Ref_Des_Form "FIELD Cancel_Field\n")
   fprintf(Rename_Ref_Des_Form "FLOC 5 13\n")
   fprintf(Rename_Ref_Des_Form "MENUBUTTON \"Cancel Rename\" 15 3\n")
   fprintf(Rename_Ref_Des_Form "ENDFIELD\n")
   fprintf(Rename_Ref_Des_Form "ENDTILE\n")
   fprintf(Rename_Ref_Des_Form "ENDFORM\n")
   close(Rename_Ref_Des_Form)
); end defun Rename_Form_Routine

; Define action of the form buttons in the Rename_Ref_Des_Form
; ############################################################
defun(Rename_Form_Action (Rename_Ref_Des_Form)
  case(Rename_Ref_Des_Form->curField

     ("Match_Prefix_Field"
        Match_Prefix=(Rename_Ref_Des_Form->curValue)
        t
     ); end "Match_Prefix_Field"

     ("New_Prefix_Field"
        New_Prefix=(Rename_Ref_Des_Form->curValue)
        t
     ); end "New_Prefix_Field"

     ("Start_Number_Field"
        Start_Number=(Rename_Ref_Des_Form->curValue)
        t
     ); end "Start_Number_Field"

     ("Begin_Rename_Field"
        Finished=nil

        ; Close the rename form
        ; #####################
        axlFormClose(Rename_Ref_Des_Form)

        ; Start the next number counter and build the new ref des
        ; #######################################################
        Next_Number=Start_Number; This variable is used to increment the ref des number
        New_Name=sprintf(dummy "%s%d" upperCase(New_Prefix) Next_Number); This variable is the new ref des

        ; Build and display the tracking form
        ; ###################################
        Rename_Tracking_Form_Routine()
        Rename_Tracking_Form=axlFormCreate( (gensym) "./Rename_Tracking_Form.form" '(e inner) nil t)
        axlFormDisplay(Rename_Tracking_Form)

        ; Define the pop up
        ; #################
        Rename_Popup=axlUIPopupDefine(nil
            list(
            list("Reset" 'Reset_Rename_Prefix_Routine)
            list("Oops" 'Rename_Oops_Routine)
            list("Done" 'Rename_Done_Routine)))

        ; Build the List of all placed symbols
        ; ####################################
        axlSetFindFilter(?enabled '(noall symbols) ?onButtons '(noall symbols))
        Symbols=axlGetSelSet(axlAddSelectAll())

        ; Parse the list and keep the ref des that match the match prefix
        ; ###############################################################
        Component_List=nil; This variable represents the components that match
        Last_Number=1; This varable represents the total number of components that match
        Pattern=strcat(upperCase(Match_Prefix) "[0-9]+"); This variable represents the match criteria
        foreach(Symbol Symbols
           if(Symbol->refdes && rexMatchp(Pattern Symbol->refdes) then
              Component_List=cons(Symbol Component_List)
              Last_Number=Last_Number+1
           ); end if Symbol->refdes && rexMatchp(Pattern Symbol->refdes)
        ); end foreach Symbol Symbols

        ; Highlight all components that match the Match_Prefix
        ; ####################################################
        axlClearSelSet()
        axlHighlightObject(Component_List)

        ; Run the interactive ref des selection routine
        ; #############################################
        Interactive_Rename_Routine()
        t
     ); end "Begin_Rename_Field"

     ("Cancel_Field"
        axlCancelEnterFun()
        axlFormClose(Rename_Ref_Des_Form)
        shell("rm ./Rename_Ref_Des_Form.form")
        t
     ); end "Cancel_Field"
  ); end case Rename_Ref_Des_Form->curField
); end defun Rename_Form_Action

; Define the Interactive_Rename_Routine
; #####################################
defun(Interactive_Rename_Routine ()
   while(Finished == nil; This loop allows the continual selection of ref des

      ; Set the pop up and the tracking form field
      ; ##########################################
      axlUIPopupSet(Rename_Popup)
      axlFormSetField(Rename_Tracking_Form "Next_Number_Field" New_Name)

      ; Select the ref des to rename
      ; ############################
      axlSetFindFilter(?enabled '(noall text) ?onButtons '(noall text))
      Text=car(axlGetSelSet(axlSingleSelectPoint())); This variable represent the ref des to be renamed
 
      ; Check if Reset, Done, or Oops were pushed
      ; #########################################
      if(Oops_On == nil then
         if(Finished == nil then

            ; Check if any text was selected
            ; ##############################
            if(Text != nil then

               ; Add to the tally lists
               ; #####################
               Oops_List=cons(Text->text Oops_List)
               New_Name_List=cons(New_Name New_Name_List)
               Next_Number=Next_Number+1
               X_Y_Loc_List=cons(Text->xy X_Y_Loc_List)

               ; Determine where the ref des actually is located
               ; ###############################################
               X_Loc=car(car(X_Y_Loc_List))
               Y_Loc=car(cdr(car(X_Y_Loc_List)))

               ; Dehighlight the selected component, write and replay the script
               ; ###############################################################
               axlDehighlightObject(Text->parent)
               Script_File=outfile("./Rename_Ref_Des.scr" "w")
               fprintf(Script_File "setwindow pcb\ntext edit\n")
               fprintf(Script_File "pick %f %f\ntext %s\n" X_Loc Y_Loc New_Name)
               fprintf(Script_File "done\n")
               close(Script_File)
               axlShell("replay ./Rename_Ref_Des.scr")
               shell("rm ./Rename_Ref_Des.scr")
 
               ; Check if you got them all
               ; #########################
               if((Next_Number-Start_Number)+1 == Last_Number then
                  Reset_Rename_Prefix_Routine()
               ); end if (Next_Number-Start_Number)+1 == Last_Number

               ; Increment the new ref des and update the tracking form
               ; ######################################################
               New_Name=sprintf(dummy "%s%d" upperCase(New_Prefix) Next_Number)
               axlFormSetField(Rename_Tracking_Form "Next_Number_Field" New_Name)

            ); end if Text != nil

         else; if Finished == nil
            axlUIPopupSet(nil)

         ); end if Finished == nil

      else; if Oops_On == nil

         ; Check if there is anything to Oops
         ; ##################################
         if(Oops_List==nil then
            axlUIConfirm("Nothing to Oops")
            Finished=nil
            Oops_On=nil

         else; if Oops_List==nil

            ; Get the component at the top of Oops list
            ; #########################################
            axlClearSelSet()
            axlCancelEnterFun()
            axlSetFindFilter(?enabled '(noall symbols) ?onButtons '(noall symbols))
            Oppsed_Component=car(axlGetSelSet(axlSingleSelectName("SYMBOL" car(New_Name_List))))
            axlClearSelSet()

            ; If it is a matching prefix component re-highlight it
            ; ####################################################
            if(car(Oops_List)&& rexMatchp(Pattern car(Oops_List)) then
               axlHighlightObject(Oppsed_Component)
            ); end if car(Oops_List)&& rexMatchp(Pattern car(Oops_List))

            ; Determine where the Oops'd ref des was actually located
            ; #######################################################
            X_Loc=car(car(X_Y_Loc_List)) 
            Y_Loc=car(cdr(car(X_Y_Loc_List)))

            ; Write and replay the rename script
            ; ##################################
            Script_File=outfile("./Rename_Ref_Des.scr" "w")
            fprintf(Script_File "setwindow pcb\ntext edit\n")
            fprintf(Script_File "pick %f %f\ntext %s\n" X_Loc Y_Loc car(Oops_List))
            fprintf(Script_File "done\n")
            close(Script_File)
            axlShell("replay ./Rename_Ref_Des.scr")
            shell("rm ./Rename_Ref_Des.scr")

            ; Update the tally lists
            ; ######################
            Oops_List=cdr(Oops_List)
            X_Y_Loc_List=cdr(X_Y_Loc_List)
            New_Name=car(New_Name_List)
            Next_Number=Next_Number-1
            New_Name_List=cdr(New_Name_List)

            ; Reset the Oops_on and Finished variables
            ; ########################################
            Oops_On=nil
            Finished=nil

         ); end if Oops_List == nil
      ); end if Oops_On==nil
   ); end while Finished=nil
);end Interactive_Rename_Routine

; Define the rename tracking form
; ###############################
defun(Rename_Tracking_Form_Routine ()
   Rename_Tracking_Form=outfile("./Rename_Tracking_Form.form" "w")
   fprintf(Rename_Tracking_Form "FILE_TYPE=FORM_DEFN VERSION=2\n")
   fprintf(Rename_Tracking_Form "FORM\n")
   fprintf(Rename_Tracking_Form "FIXED\n")
   fprintf(Rename_Tracking_Form "HEADER \"Tracking\"\n")
   fprintf(Rename_Tracking_Form "PORT 17 3\n")
   fprintf(Rename_Tracking_Form "TILE\n")
   fprintf(Rename_Tracking_Form "TEXT \"Next Number\"\n")
   fprintf(Rename_Tracking_Form "TLOC 3 1\n")
   fprintf(Rename_Tracking_Form "ENDTEXT\n")
   fprintf(Rename_Tracking_Form "FIELD Next_Number_Field\n")
   fprintf(Rename_Tracking_Form "FLOC 1 3\n")
   fprintf(Rename_Tracking_Form "STRFILLIN 12 30\n")
   fprintf(Rename_Tracking_Form "ENDFIELD\n")
   fprintf(Rename_Tracking_Form "ENDTILE\n")
   fprintf(Rename_Tracking_Form "ENDFORM\n")
   close(Rename_Tracking_Form)
); end defun Rename_Tracking_Form
 
; Define "Reset" for the popup
; ############################
defun(Reset_Rename_Prefix_Routine ()

   ; Stop the select function
   ; ########################
   Finished=t
   axlClearSelSet()
   axlCancelEnterFun()

   ; De-highlight any components still highlighted
   ; #############################################
   axlSetFindFilter(?enabled '(noall symbols) ?onButtons '(noall symbols))
   Component_List=axlGetSelSet(axlAddSelectName("SYMBOL" sprintf(dummy "%s*" Match_Prefix)))
   axlClearSelSet()
   axlDehighlightObject(Component_List)

   ; Update the tally lists
   ; ######################
   Oops_List=nil
   New_Name_List=nil
   X_Y_Loc_List=nil
   Start_Number=Next_Number

   ; Close the tracking form
   ; #######################
   axlFormClose(Rename_Tracking_Form)
   shell("rm ./Rename_Tracking_Form.form")
   Form=axlFormCreate( (gensym) "Rename_Ref_Des_Form.form" '(e inner) 'Rename_Form_Action t)

   ; Display the rename form and set the fields
   ; ##########################################
   axlFormDisplay(Form)
   axlFormSetField(Form "Match_Prefix_Field" upperCase(Match_Prefix))
   axlFormSetField(Form "New_Prefix_Field" upperCase(New_Prefix))
   axlFormSetField(Form "Start_Number_field" Start_Number)
   axlShell("redisplay")
); defun end Reset_Rename_Prefix_Routine

; Define "Oops" for the popup
; ###########################
defun(Rename_Oops_Routine ()

   ; Stop the select function
   ; ########################
   axlCancelEnterFun()
   Finished=t

   ; Let the rename routine know you want to Oops
   ; ############################################
   Oops_On=t
); end defun Rename_Oops_Routine

; Define "Done" for the popup
; ###########################
defun(Rename_Done_Routine ()

   ; Stop the select function   
   ; ########################
   Finished=t
   axlCancelEnterFun()

   ; De-highlight any components still highlighted
   ; #############################################
   axlClearSelSet()
   axlSetFindFilter(?enabled '(noall symbols) ?onButtons '(noall symbols))
   Component_List=axlGetSelSet(axlAddSelectName("SYMBOL" sprintf(dummy "%s*" Match_Prefix)))
   axlClearSelSet()
   axlDehighlightObject(Component_List)

   ; Update the tally lists
   ; ######################
   Oops_List=nil
   New_Name_List=nil
   X_Y_Loc_List=nil

   ; Close the tracking form
   ; #######################
   axlFormClose(Rename_Tracking_Form)
   shell("rm ./Rename_Tracking_Form.form")
   shell("rm ./Rename_Ref_Des_Form.form")
   axlShell("redisplay")
); end defun Rename_Done_Routine

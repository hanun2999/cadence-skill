; stub-finding SKILL routine
; Written by: Chris Walters   Motorola SSTG  2000/04/28
;
; Description:
; This SKILL routine will find and identify "stubs" , pieces of etch on a net
; that do not terminate on a pin/via/tee on both ends and pieces of etch that
; have either both ends terminating on the same shape or one end terminating
; on a shape and the other not terminating against a pin/via/tee. It does not
; find "floating" pieces of etch, those pieces which are not on a net and do
; not terminate against anything on both ends
;
; Once the routine builds up a list of stubs it loads the list into a list field
; in the form. In the list field stubs are listed by their start/end points and
; layer. Selecting a stub from the list pops the main window to display the 
; stub, which is highlighted and marked with an external DRC. If the user wishes
; to keep the stub, clicking the "remove DRC" button will dehighlight the stub
; and delete the DRC marker. If the user wishes to delete the stub, clicking the
; "Delete stub" button will dehighlight the stub, delete the DRC marker and delete
; the stub itself. If either button is clicked the selected element is removed from
; the list - the idea here being you keep selecting stubs until you've either kept
; or deleted all of them which brings the list down to no entries, which locks both
; the "Remove" and "Delete" buttons. Clicking the "Exit" button removes all remaining
; highlighting and external DRC markers.
;
; Limitations:
;   - This SKILL program has been created on Allegro Revision 13.0/Solaris . No
;     testing on earlier versions or other OSes has been done.
;
; Execution:
;     Position this file (mot_find_stubs.il) in the directory path where all other
;     skill routines are located. In the allegro.ilinit file include the line
;     load("mot_find_stubs.il")
;     To Execute the command in the Allegro command window enter "find_stubs"
;
; Associated files:
;     the form file mot_find_stubs.form gets created on-the-fly and deleted at end
;     of routine
;
; Revision History
; Revision 1.0 -  2000/04/28 Chris Walters           Motorola SSTG
; Revision 1.1 -  2000/06/16 Delete extra axlFormDisplay - line 250
;                            Modify form functionality - line 248
;
;==========================================================================
defun(FindStubs ()

boardname = axlCurrentDesign()

printf("\n%s\n" , "this will highlight all stubs and mark them with a DRC. Please wait....")
drain(poport)

; selects symbol objects
; ---------------------

drain()
axlClearSelSet()
axlSetFindFilter(?enabled list("noall" "nets")
        ?onButtons list("noall" "nets"))
net_list = axlGetSelSet(axlAddSelectAll());
axlClearSelSet()

; starts file header
; ------------------

foreach( net_db net_list

	net_name = net_db->name
	net_xy = net_db->xy
	branch_list = net_db->branches

	children_list = nil
 	foreach( branch_db branch_list
 		branch_name = branch_db->name
 		branch_xy = branch_db->xy
 		children_list = branch_db->children
         	
		child_list = nil
		path_list = nil
		sibling_list = nil
		foreach( child_db children_list
			child_name = child_db->name
			child_xy = child_db->xy
			child_data = list( child_db branch_db net_db child_db->objType)
			child_list = cons( child_data child_list)

			if( child_db->objType == "path"  then   ; list of paths in a branch with start/end points
				path_layer = child_db->layer
				path_segments = child_db->segments
				path_segments_cnt = child_db->nSegs - 1    ; need to subtract by one here to use nth
				path_first_seg = nth( 0 path_segments)
				path_last_seg = nth( path_segments_cnt path_segments)
				path_start_point = car( path_first_seg->startEnd)
				path_end_point = cadr( path_last_seg->startEnd)
				path_data = list( child_db path_segments path_start_point path_end_point path_layer)
				path_list = cons( path_data path_list)
			else					; list of non-path objects in a branch with coordinate
				sibling_xy = child_db->xy
				sibling_type = child_db->objType
				sibling_data = list( child_db sibling_type sibling_xy)
				sibling_list = cons( sibling_data sibling_list)
			);end-if    

 		);end-foreach

 	);end-foreach

	LookUp()

);end-foreach

);end-defun
;==========================================================================
defun(LookUp ()

foreach( path_obj path_list      
	path_dbid = nth(0 path_obj)
	path_start_point = nth( 2 path_obj)
	path_end_point = nth( 3 path_obj)
	path_class_subclass = nth( 4 path_obj)
	path_points = nil
	path_is_stub = nil
	touch_start = nil
	touch_end = nil
	touch_shape = nil
	drc_xy = nil
	foreach( sib_obj sibling_list
		sib_dbid = nth( 0 sib_obj)
		sib_type = nth( 1 sib_obj)
		sib_point = nth( 2 sib_obj)
		if( sib_type == "shape" then     ; sibling is shape
			foreach( sib_con_dbid sib_dbid->connect
				if( sib_con_dbid == path_dbid then
					touch_shape = t
					path_points = list( path_start_point path_end_point)
				);end-if
			);end-foreach
		else ; sibling is pin/via/tee
			if( sib_point == path_start_point then
				touch_start = t
				path_points = list( path_end_point path_start_point)  ; place hanging end first in list
			);end-if
			if( sib_point == path_end_point then
				touch_end   = t
				path_points = list( path_start_point path_end_point)  ; place hanging end first in list
			);end-if
		);end-if
	);end-foreach

	; decide if path is stub or not

	when( !touch_shape && !touch_start && !touch_end
		null( nil)	 ; not logically possible  - floating etch is not on a net
	);end-when
	when( !touch_shape && !touch_start &&  touch_end
		AddToStubList()
	);end-when
	when( !touch_shape &&  touch_start && !touch_end
		AddToStubList()
	);end-when
	when( !touch_shape &&  touch_start &&  touch_end
		null( nil)	 ; path is not a stub when both ends touch a sibling
	);end-when
	when(  touch_shape && !touch_start && !touch_end
		AddToStubList()
	);end-when
	when(  touch_shape && !touch_start &&  touch_end
		null( nil)
	);end-when
	when(  touch_shape &&  touch_start && !touch_end
		null( nil)
	);end-when
	when(  touch_shape &&  touch_start &&  touch_end
		null( nil)
	);end-when

);end-foreach

);end-defun
;==========================================================================
defun(AddToStubList ()

drc_xy = car( path_points)
path_points_str = "   "   ; initializes symbol to type char
sprintf(path_points_str "%L" path_points)

path_subclass = cadr( parseString( path_class_subclass "/"))
drc_Layer = strcat( "drc error class/" path_subclass)
out_field = strcat( path_points_str "  " path_subclass)
drc_dbid = car( axlDBCreateExternalDRC( "stub" drc_xy drc_Layer nil nil nil) )
axlHighlightObject( path_dbid) 
path_item = list(path_dbid path_points path_class_subclass drc_dbid out_field)
stub_list = cons( path_item stub_list)

);end-defun
;==========================================================================
(defun CreateForm () 

 form_file = "./find_stubs.form"
 form = outfile(form_file "w")
 fprintf( form "FILE_TYPE=FORM_DEFN VERSION=2\n")
 fprintf( form "FORM\n")
 fprintf( form "FIXED\n")
 fprintf( form "PORT 60 21\n")
 fprintf( form "HEADER \"stub finding SKILL routine\"\n")
 fprintf( form "\n")
 fprintf( form "\n")
 fprintf( form "TILE\n")
 fprintf( form "TEXT \"List of Stubs found\"\n")
 fprintf( form "TLOC 16 3\n")
 fprintf( form "ENDTEXT\n")
 fprintf( form "\n")
 fprintf( form "TEXT\n")
 fprintf( form "TLOC 13 27\n")
 fprintf( form "INFO Msg_Field 30\n")
 fprintf( form "ENDTEXT\n")
 fprintf( form "\n")
 fprintf( form "FIELD Stub_List_Field\n")
 fprintf( form "FLOC 6 7\n")
 fprintf( form "LIST \"\" 45 10\n")
 fprintf( form "ENDFIELD\n")
 fprintf( form "\n")
 fprintf( form "FIELD Remove_Field\n")
 fprintf( form "FLOC 6 31\n")
 fprintf( form "MENUBUTTON \"Remove DRC\" 15 5\n")
 fprintf( form "ENDFIELD\n")
 fprintf( form "\n")
 fprintf( form "FIELD Delete_Field\n")
 fprintf( form "FLOC 24 31\n")
 fprintf( form "MENUBUTTON \"Delete stub\" 15 5\n")
 fprintf( form "ENDFIELD\n")
 fprintf( form "\n")
 fprintf( form "FIELD Exit_Field\n")
 fprintf( form "FLOC 42 31\n")
 fprintf( form "MENUBUTTON \"Exit\" 10 5\n")
 fprintf( form "ENDFIELD\n")
 fprintf( form "\n")
 fprintf( form "ENDTILE\n")
 fprintf( form "\n")
 fprintf( form "ENDFORM\n")
 close(form)

 );end-defun
;==========================================================================
defun(Stub_Find_Form_Routine ()

; update the display to show all highlighting and DRCs
axlFlushDisplay()

; read in the form
Stub_Find_Form=axlFormCreate( (gensym) form_file '(e inner) 'Stub_Find_Form_Action nil)



if(stub_list == nil then
	axlFormSetFieldEditable( Stub_Find_Form "Remove_Field" 0 )
	axlFormSetFieldEditable( Stub_Find_Form "Delete_Field" 0 )
   	axlFormSetInfo( Stub_Find_Form "Msg_Field" "No stubs were found")
else	; stubs were found
	foreach( stub_item stub_list 	; set the fields of the form in the same order as in stub_list
		sel_field = nth( 4 stub_item)
		axlFormSetField(Stub_Find_Form "Stub_List_Field" sel_field)
	);end-foreach
   	axlFormSetInfo( Stub_Find_Form "Msg_Field" "Select stub from list")
);end-if

axlFormDisplay(Stub_Find_Form) 		; display the form

); end-defun

; Define action of the form buttons in the Stub_Find_Form
; ############################################################
defun(Stub_Find_Form_Action (Stub_Find_Form)
  case(Stub_Find_Form->curField                ; contains name of field that has been touched

     ("Stub_List_Field"
	axlFormSetFieldEditable( Stub_Find_Form "Remove_Field" 1 ) ; unlock button
	axlFormSetFieldEditable( Stub_Find_Form "Delete_Field" 1 ) ; unlock button
        selected_stub=(Stub_Find_Form->curValue)      ; stores value user put in field to program variable
        selected_stub_pos=(Stub_Find_Form->curValueInt)  ; stores index of selection on list

	if( selected_stub == nil then	; no more stubs in list, lock buttons
		axlFormSetFieldEditable( Stub_Find_Form "Remove_Field" 0 )
		axlFormSetFieldEditable( Stub_Find_Form "Delete_Field" 0 )
   		axlFormSetInfo( Stub_Find_Form "Msg_Field" "No more stubs")
		printf("%s\n" " no more stubs ")
	else				; at least one stub left
	
		; go back thru stub_list to find stub that matches selected_stub
		foreach( look_item stub_list
			look_dbid = nth( 0 look_item)
			look_points = nth( 1 look_item)
			look_class_subclass = nth( 2 look_item)
			look_drc_dbid = nth( 3 look_item)
			look_out_field = nth( 4 look_item)
			look_subclass = cadr( parseString( look_class_subclass "/"))
			look_etch_layer = strcat( "ETCH/" look_subclass)
			look_pin_layer = strcat( "PIN/" look_subclass)
			look_via_layer = strcat( "VIA CLASS/" look_subclass)
			look_drc_layer = strcat( "drc error class/" look_subclass)
			pop_xy = car( look_points)
			pop_x = xCoord( pop_xy)
			pop_y = yCoord( pop_xy)
			if( look_out_field == selected_stub then
				; snaps window to center on selected stub
				llx = pop_x - 500
				lly = pop_y - 400
				urx = pop_x + 500
				ury = pop_y + 400
				window_bbox = list( llx:lly urx:ury)
				axlWindowBoxSet( window_bbox)
				axlVisibleLayer( "ETCH" nil)
				axlVisibleLayer( "PIN" nil)
				axlVisibleLayer( "VIA CLASS" nil)
				axlVisibleLayer( "drc error class" nil)
				axlVisibleLayer( look_etch_layer t )
				axlVisibleLayer( look_pin_layer t )
				axlVisibleLayer( look_via_layer t )
				axlVisibleLayer( look_drc_layer t )
				; latch item in list in case user chooses to delete it
				selected_stub_item = look_item
				; latch dbid of external DRC in case user chooses to delete it
				selected_stub_drc_dbid = look_drc_dbid
				; latch dbid of path in case user chooses to delete it
				selected_stub_dbid = look_dbid
			);end-if
		);end-foreach
	);end-if
	t                                       ; read this statement as " if field has been set
     ); end

     ("Remove_Field"
        ; delete path, drc marker and list entry
	axlDehighlightObject( selected_stub_dbid)	; dehilights path
 	axlDeleteObject( selected_stub_drc_dbid t)	; deletes external DRC
	axlFormListDeleteItem( Stub_Find_Form "Stub_List_Field" selected_stub_pos) ; deletes selection from list
	axlFlushDisplay()		; forces screen refresh so dehighlight takes effect
	stub_list = remd( selected_stub_item stub_list) ; deletes element from stub_list
	axlFormSetFieldEditable( Stub_Find_Form "Remove_Field" 0 ) ;   lock button
	axlFormSetFieldEditable( Stub_Find_Form "Delete_Field" 0 ) ;   lock button
		; needed to prevent clicking before selecting another stub
     ); end

     ("Delete_Field"
        ; delete path, drc marker and list entry
	axlDehighlightObject( selected_stub_dbid)	; dehilights path
 	axlDeleteObject( selected_stub_drc_dbid t)	; deletes external DRC
	axlFormListDeleteItem( Stub_Find_Form "Stub_List_Field" selected_stub_pos) ; deletes selection from list
 	axlDeleteObject( selected_stub_dbid t)		; deletes stub
	axlFlushDisplay()		; forces screen refresh so dehighlight takes effect
	stub_list = remd( selected_stub_item stub_list) ; deletes element from stub_list
	axlFormSetFieldEditable( Stub_Find_Form "Remove_Field" 0 ) ;   lock button
	axlFormSetFieldEditable( Stub_Find_Form "Delete_Field" 0 ) ;   lock button
		; needed to prevent clicking before selecting another stub
     ); end

     ("Exit_Field"
	foreach( stub_item stub_list 			; clear off all remaining tagged stubs
		look_dbid = nth( 0 stub_item)
		look_drc_dbid = nth( 3 stub_item)
		axlDehighlightObject( look_dbid)	; dehilights path
 		axlDeleteObject( look_drc_dbid t)	; deletes external DRC
	);end-foreach
	axlFlushDisplay()		; forces screen refresh so dehighlight takes effect
        axlFinishEnterFun()
        axlFormClose(Stub_Find_Form)
	printf("\n%s\n" , ".... all done.")
	t
     ); end

  ); end-case

); end-defun

;==========================================================================
defun( find_stubs ()		; main function

boardname = axlCurrentDesign()
;alleg_ver = axlVersion( version )        doesn't seem to work in 12.8, maybe in PE13

vis_list = axlVisibleGet()       ;saves color settings

child_list = nil
path_list = nil
sibling_list = nil
stub_list = nil

; get date and time, write out line
timestr = getCurrentTime()

FindStubs()
CreateForm()
Stub_Find_Form_Routine()

axlVisibleSet(vis_list)         ;restores color settings
deleteFile(form_file)		;deletes form file

);end-defun

; registers command with allegro
; ------------------------------

axlCmdRegister( "find_stubs" `find_stubs)


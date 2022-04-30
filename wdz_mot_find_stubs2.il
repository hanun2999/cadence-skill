; stub-finding SKILL routine
; Written by: Chris Walters   Motorola SSTG  2000/04/28
;
; Description:
; This SKILL routine will find and identify "stubs" , pieces of etch on a t
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
defun(FindStubsMe ()

axlShell("done")

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

;outputa=outfile("/home1/user/wdz/skill/via_loc.txt")

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
		shape_connect_dbids=nil    ;added by WUDEZHOU
		
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
				;if(net_name=="TDO" then 
				;   printf("\nwhole length : %L \nSeg length:%L" child_db->length path_first_seg->length))
			else					; list of non-path objects in a branch with coordinate
				sibling_xy = child_db->xy
				sibling_type = child_db->objType
				sibling_data = list( child_db sibling_type sibling_xy)
				sibling_list = cons( sibling_data sibling_list)
				if(sibling_type == "shape" then  ;collect the shapes connect to one net
					   shape_connect_dbids = cons( child_db shape_connect_dbids) ;added by WUDEZHOU
				);end-if
			);end-if    

 		);end-foreach		
	
 	);end-foreach

 	; added by WUDEZHOU  
	con_to_shape_dbids = nil
	foreach(sig_shape_dbid shape_connect_dbids	                        
		con_to_shape_dbids = cons(sig_shape_dbid->connect  con_to_shape_dbids)  ;get the dbids that connected to the shape
	);end-foreach
	
	LookUpNoVia()
        LookUpPathWithVia()
        
);end-foreach
;close(outputa)
);end-defun
;==========================================================================
defun(LookUpNoVia ()

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
		AddToStubListNoVia()
	);end-when
	when( !touch_shape &&  touch_start && !touch_end
		AddToStubListNoVia()
	);end-when
	when( !touch_shape &&  touch_start &&  touch_end
		null( nil)	 ; path is not a stub when both ends touch a sibling
	);end-when
	when(  touch_shape && !touch_start && !touch_end
		AddToStubListNoVia()
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
defun(AddToStubListNoVia ()

	drc_xy = car( path_points)
	path_points_str = "   "   ; initializes symbol to type char
	sprintf(path_points_str "%L" path_points)

	path_subclass = cadr( parseString( path_class_subclass "/"))
	drc_Layer = strcat( "drc error class/" path_subclass)
	out_field = strcat( path_points_str "  " path_subclass)
	drc_dbid = car( axlDBCreateExternalDRC( "stub" drc_xy drc_Layer nil nil nil) )
	axlHighlightObject( path_dbid) 
	path_item = list(path_dbid path_points path_class_subclass drc_dbid out_field NO_STUBVIA)
	stub_list = cons( path_item stub_list)

);end-defun

;==========================================================================
;       Added by WUDEZHOU to search the stubs with a via which is not a testpoint 
;==========================================================================
defun(LookUpPathWithVia ()
		         	
        nets_to_negplane=nil
        netsname_to_negplane=nil        
  
          ;find the nets on neg_plane
       
	axlClearSelSet()  
        axlSetFindFilter(?enabled list("noall" "nets") ?onButtons list("all"))
	axlAddSelectName("PROPERTY" list("ROUTE_TO_SHAPE" "VOLTAGE"))
	netsid_to_negplane = axlGetSelSet() 
	axlClearSelSet()
        foreach(netid netsid_to_negplane
                netsname_to_negplane = cons( netid->name  netsname_to_negplane)
	);end-foreach               

	foreach( sib_obj sibling_list
		sib_dbid = nth( 0 sib_obj)
		sib_type = nth( 1 sib_obj)
		sib_point = nth( 2 sib_obj)

		drc_xy=nil
                path_start_count=0
                path_end_count=0 
		path_points=nil
		my_touch_start = nil
		my_touch_end = nil				
  		my_touch_shape = nil	
  		my_child_db = nil
  		sum_path_length = 0.0	

		;if( sib_type == "via" && sib_dbid->testPoint==nil then   
		if( sib_type == "via" then			
			foreach( path_obj path_list      
				path_dbid = nth(0 path_obj)
				path_start_point = nth( 2 path_obj)
				path_end_point = nth( 3 path_obj)
				path_class_subclass = nth( 4 path_obj)

				if( sib_point == path_start_point then                                         
					my_touch_start = t
					++path_start_count
					my_child_db=path_dbid    ;record the stub's dbid imformation
					my_path_class_subclass = nth( 4 path_obj)
					path_points = list( path_end_point path_start_point)  ; place hanging end first in list
                                );end-if
				if( sib_point == path_end_point then
					my_touch_end = t	
					++path_end_count
					my_child_db=path_dbid	;record the stub's dbid imformation
					my_path_class_subclass = nth( 4 path_obj)
					path_points = list( path_start_point path_end_point)  ; place hanging end first in list
				);end-if												
			);end for each                        
    			       ;if the via with a stub connect to a shape,it will not be considered as a stub! 
 			foreach(sib_shape_connect_dbid con_to_shape_dbids
				if( member(sib_dbid sib_shape_connect_dbid) then						
 					my_touch_shape = t
				);end-if
			);end-foreach   

			if( !my_touch_shape && my_touch_start && !my_touch_end && path_start_count==1 then			        
		                ;if the via is testpoint,will compute the stub length
		                if( sib_dbid->testPoint then 
		                	MyComputePathLenth()
		                );end if  	
		          
				via_location = sib_point  ; location of via with stub line 
				;if it isn't a testpoint or the length of stub with a testpoint exceed 500MIL,
				;the stub will be hilighted!
			        if( !sib_dbid->testPoint || sum_path_length>500.0 then 
			             	MyAddToStubList()
			        );end if
			);end if 	
			if( !my_touch_shape && !my_touch_start && my_touch_end && path_end_count==1 then
				
				if( sib_dbid->testPoint then 
		                	MyComputePathLenth()
		                );end if 			        					
			        via_location = sib_point  ; location of via with stub line 
			        if( !sib_dbid->testPoint || sum_path_length>500.0 then 
			         	MyAddToStubList()
			        );end if
			);end if 					
		);end-if
	);end-foreach	
);end-defun
;==========================================================================
;  added by WUDEZHOU to compute the path's lenth
;==========================================================================
defun(MyComputePathLenth ()
	
	test_path_segments = my_child_db->segments
	test_path_segments_cnt = my_child_db->nSegs - 1  ; need to subtract by one here to use nth

	for(i 0 test_path_segments_cnt
		test_path_seg = nth( i test_path_segments)
		test_path_start_point = car(test_path_seg->startEnd)
		test_path_end_point = cadr(test_path_seg->startEnd)
		x1 = nth(0 test_path_start_point)
	   	y1 = nth(1 test_path_start_point)
	   	x2 = nth(0 test_path_end_point)
	   	y2 = nth(1 test_path_end_point)
	   	dist = sqrt((x2-x1)**2+(y2-y1)**2)
		sum_path_length = sum_path_length+dist
	);end-foreach 					
);end-defun
;==========================================================================
;  added by WUDEZHOU to add the stub with via to the stub list
;==========================================================================
defun(MyAddToStubList ()

if( !member( my_child_db->net->name netsname_to_negplane) then     

	drc_xy = car( path_points)
	path_points_str = "   "   ; initializes symbol to type char
	sprintf(path_points_str "%L" path_points)

	path_subclass = cadr( parseString( my_path_class_subclass "/"))
	drc_Layer = strcat( "drc error class/" path_subclass)
	out_field = strcat( path_points_str "  " path_subclass)
	drc_dbid = car( axlDBCreateExternalDRC( "stub" drc_xy drc_Layer nil nil nil) )
	axlHighlightObject( my_child_db) 
	axlHighlightObject( sib_dbid )
	path_item = list(my_child_db path_points my_path_class_subclass drc_dbid out_field sib_dbid)
	stub_list = cons( path_item stub_list)
);end if 

);end-defun

;==========================================================================
(defun CreateFormNew () 

 form_file = "find_stubs.form"
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
defun(Stub_Find_Form_Routine_New ()

; update the display to show all highlighting and DRCs
axlFlushDisplay()

; read in the form
Stub_Find_Form=axlFormCreate( (gensym) form_file '(e inner) 'Stub_Find_Form_Action_New nil)

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
defun(Stub_Find_Form_Action_New (Stub_Find_Form)
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
			look_stubvia_dbid = nth(5 look_item)   ; added by WUDEZHOU
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
                                ; latch dbid of stubvia in case user choose to delete it   added by WUDEZHOU
 				selected_stubvia_dbid = look_stubvia_dbid 
			);end-if
		);end-foreach
	);end-if
	t                                       ; read this statement as " if field has been set
     ); end

     ("Remove_Field"
        ; delete path, drc marker and list entry
	axlDehighlightObject( selected_stub_dbid)	; dehilights path
        if(selected_stubvia_dbid != NO_STUBVIA then 
                axlDehighlightObject( selected_stubvia_dbid)	; dehilights stubvia  added by WUDEZHOU
	);end if
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
	if(selected_stubvia_dbid != NO_STUBVIA then 
                axlDeleteObject( selected_stubvia_dbid t)  ;deletes stub via added by WUDEZHOU
	);end if
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
		look_stubvia_dbid = nth(5 stub_item)   ; added by WUDEZHOU
		axlDehighlightObject( look_dbid)	; dehilights path
                if(look_stubvia_dbid != NO_STUBVIA then 
                	axlDehighlightObject( look_stubvia_dbid)	; dehilights stubvia  added by WUDEZHOU
		);end if
 
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
defun( find_stubs2 ()		; main function

boardname = axlCurrentDesign()
;alleg_ver = axlVersion( version )        doesn't seem to work in 12.8, maybe in PE13

vis_list = axlVisibleGet()       ;saves color settings

child_list = nil
path_list = nil
sibling_list = nil
stub_list = nil
NO_STUBVIA = 0

; get date and time, write out line
timestr = getCurrentTime()

FindStubsMe()
CreateFormNew()
Stub_Find_Form_Routine_New()

axlVisibleSet(vis_list)         ;restores color settings
deleteFile(form_file)		;deletes form file

);end-defun

; registers command with allegro
; ------------------------------

axlCmdRegister( "find_stubs2" `find_stubs2)


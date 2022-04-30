; Find Component
; Rev 1.3: May 26,2002
; Written by:	
; LiGuangsheng/24445
; CAD Group Fundamental Dept R&D Engineer
; HUAWEI TECHNOLOGIES CO., LTD.

;===============REGIST COMMAND LINE=========================================================================================
;===========================================================================================================================
axlCmdRegister( "find comps" `Find_Component_Routine ?cmdType "interactive")

Ref_Des_Filter_net = "*"
Ref_Des_Filter_comps = "*"
lgs_c_or_n = t
lgs_refadt_onoff = nil
lgs_refadb_onoff = nil
lgs_alletch_onoff = nil
lgs_alletch_onoff_c = nil
lgs_alletch_onoff_n = nil

;===============MAIN FUNCTION===============================================================================================
;===========================================================================================================================
(defun Find_Component_Routine ()

	Comp_List=nil
	Placed_List=nil
	Placed_List_bbox = nil
	Placed_list_pin_xy = nil
	lgs_command_type = nil


	axlDBRefreshId(axlDBGetDesign())
	axlClearSelSet()
  	Find_Component_Form=nil
  	Command=nil
	Find_Component_Form=outfile("Find_Component_Form.form" "w")
        fprintf( Find_Component_Form "FILE_TYPE=FORM_DEFN VERSION=2\n")
        fprintf( Find_Component_Form "FORM\n")
        fprintf( Find_Component_Form "FIXED\n")
        fprintf( Find_Component_Form "PORT 24 20\n")
        fprintf( Find_Component_Form "HEADER \"Find Comps V1.3\"\n")
        fprintf( Find_Component_Form "TILE\n")
        fprintf( Find_Component_Form "\n")
        fprintf( Find_Component_Form "FIELD lgs_comps\n")
        fprintf( Find_Component_Form "FLOC 3 1\n")
        fprintf( Find_Component_Form "FGROUP \"c2check\"\n")
        fprintf( Find_Component_Form "CHECKLIST \"COMPS \" \"c2check\"\n")
        fprintf( Find_Component_Form "ENDFIELD\n")
        fprintf( Find_Component_Form "FIELD lgs_nets\n")
        fprintf( Find_Component_Form "FLOC 15 1\n")
        fprintf( Find_Component_Form "FGROUP \"c2check\"\n")
        fprintf( Find_Component_Form "CHECKLIST \"NETS\" \"c2check\"\n")
        fprintf( Find_Component_Form "ENDFIELD\n")
        fprintf( Find_Component_Form "\n")
        fprintf( Find_Component_Form "GROUP \"COMPONENTS LIST\"\n")
        fprintf( Find_Component_Form "FLOC 1 3\n")
        fprintf( Find_Component_Form "FSIZE 23 31\n")
        fprintf( Find_Component_Form "INFO group\n")
        fprintf( Find_Component_Form "ENDGROUP  \n")
        fprintf( Find_Component_Form "FIELD Placed_List\n")
        fprintf( Find_Component_Form "FLOC 2 5\n")
        fprintf( Find_Component_Form "LIST \"\" 21 10\n")
        fprintf( Find_Component_Form "OPTIONS sort\n")
        fprintf( Find_Component_Form "ENDFIELD\n")
        fprintf( Find_Component_Form "\n")
        fprintf( Find_Component_Form "FIELD lgs_command\n")
        fprintf( Find_Component_Form "FLOC 3 24\n")
        fprintf( Find_Component_Form "FGROUP \"c1check\"\n")
        fprintf( Find_Component_Form "CHECKLIST \"Command\" \"c1check\"\n")
        fprintf( Find_Component_Form "ENDFIELD\n")
        fprintf( Find_Component_Form "FIELD lgs_hilight\n")
        fprintf( Find_Component_Form "FLOC 15 24\n")
        fprintf( Find_Component_Form "FGROUP \"c1check\"\n")
        fprintf( Find_Component_Form "CHECKLIST \"Hilight\" \"c1check\"\n")
        fprintf( Find_Component_Form "ENDFIELD\n")
        fprintf( Find_Component_Form "\n")
        fprintf( Find_Component_Form "FIELD Refresh_List\n")
        fprintf( Find_Component_Form "FLOC 13 26\n")
        fprintf( Find_Component_Form "MENUBUTTON \"UPDATE\" 6 3\n")
        fprintf( Find_Component_Form "ENDFIELD\n")
        fprintf( Find_Component_Form "\n")
        fprintf( Find_Component_Form "FIELD lgsadt\n")
        fprintf( Find_Component_Form "FLOC 13 29\n")
        fprintf( Find_Component_Form "MENUBUTTON \"ADT\" 10 3\n")
        fprintf( Find_Component_Form "ENDFIELD\n")
        fprintf( Find_Component_Form "\n")
        fprintf( Find_Component_Form "TEXT \"Filter:\"\n")
        fprintf( Find_Component_Form "TLOC 2 26\n")
        fprintf( Find_Component_Form "ENDTEXT\n")
        fprintf( Find_Component_Form "FIELD Ref_Des_Filter\n")
        fprintf( Find_Component_Form "FLOC 6 26\n")
        fprintf( Find_Component_Form "STRFILLIN 5 10\n")
        fprintf( Find_Component_Form "ENDFIELD\n")
        fprintf( Find_Component_Form "\n")
        fprintf( Find_Component_Form "FIELD lgsadb\n")
        fprintf( Find_Component_Form "FLOC 13 31\n")
        fprintf( Find_Component_Form "MENUBUTTON \"ADB\" 10 3\n")
        fprintf( Find_Component_Form "ENDFIELD\n")
        fprintf( Find_Component_Form "\n")
        fprintf( Find_Component_Form "FIELD lgs_refadt\n")
        fprintf( Find_Component_Form "FLOC 2 28\n")
        fprintf( Find_Component_Form "CHECKLIST \"ref top\"\n")
        fprintf( Find_Component_Form "ENDFIELD\n")
        fprintf( Find_Component_Form "\n")
        fprintf( Find_Component_Form "FIELD lgs_alletch\n")
        fprintf( Find_Component_Form "FLOC 2 30\n")
        fprintf( Find_Component_Form "CHECKLIST \"all etch\"\n")
        fprintf( Find_Component_Form "ENDFIELD\n")
        fprintf( Find_Component_Form "\n")
        fprintf( Find_Component_Form "FIELD lgs_refadb\n")
        fprintf( Find_Component_Form "FLOC 2 32\n")
        fprintf( Find_Component_Form "CHECKLIST \"ref botm\"\n")
        fprintf( Find_Component_Form "ENDFIELD\n")
        fprintf( Find_Component_Form "\n")
        fprintf( Find_Component_Form "\n")
        fprintf( Find_Component_Form "FIELD done\n")
        fprintf( Find_Component_Form "FLOC 2 35\n")
        fprintf( Find_Component_Form "MENUBUTTON \"Done\" 8 3\n")
        fprintf( Find_Component_Form "ENDFIELD\n")
        fprintf( Find_Component_Form "FIELD lgs_help_find_comp\n")
        fprintf( Find_Component_Form "FLOC 15 35\n")
        fprintf( Find_Component_Form "MENUBUTTON \"Help\" 6 3\n")
        fprintf( Find_Component_Form "ENDFIELD\n")
        fprintf( Find_Component_Form "ENDTILE\n")
        fprintf( Find_Component_Form "ENDFORM\n")
	close(Find_Component_Form)

if(lgs_c_or_n == t
then
	axlSetFindFilter(?enabled '(noall components) ?onButtons '(noall components))
	Comp_List=axlGetSelSet(axlSingleSelectName("COMPONENT" Ref_Des_Filter_comps))
	(foreach Item Comp_List
		(if Item->symbol!=nil 
		 then
			Placed_List=cons(Item->name Placed_List)
			Placed_List_bbox = cons( Item->symbol->bBox Placed_List_bbox )
			;Placed_list_pin_xy = cons( car( Item->symbol->pins~>xy) Placed_list_pin_xy)
		); if Item->symbol!=nil
	); end foreach Item Comp_List

else
	axlSetFindFilter(?enabled '(noall nets) ?onButtons '(noall nets))
	Comp_List=axlGetSelSet(axlSingleSelectName("NET" Ref_Des_Filter_net))
	(foreach Item Comp_List

			Placed_List=cons(Item->name Placed_List)
			
			Placed_List_bbox = cons( Item->bBox Placed_List_bbox )

	); end foreach Item Comp_List





);end if(lgs_c_or_n == t

	axlClearSelSet()
	Find_Component_Form=axlFormCreate( (gensym) "Find_Component_Form.form" '(e outer) 'Find_Component_Form_Action_Routine t)
	axlFormSetField(Find_Component_Form "lgs_command" nil)
	axlFormSetField(Find_Component_Form "lgs_hilight" t)
	axlFormSetField(Find_Component_Form "lgs_comps" lgs_c_or_n)
	axlFormSetField(Find_Component_Form "lgs_nets" !lgs_c_or_n)
	axlFormSetField(Find_Component_Form "lgs_refadt" lgs_refadt_onoff)
	axlFormSetField(Find_Component_Form "lgs_alletch" lgs_alletch_onoff)	
	axlFormSetField(Find_Component_Form "lgs_refadb" lgs_refadb_onoff) 
	
	axlFormSetField(Find_Component_Form "lgs_alletch" lgs_alletch_onoff)

	
	(if Placed_List==nil 
	 then
		axlFormSetField(Find_Component_Form "Placed_List" "Nothing Find")
		if(lgs_c_or_n == t
		then
			axlFormSetField(Find_Component_Form "Ref_Des_Filter" Ref_Des_Filter_comps)
		else
			axlFormSetField(Find_Component_Form "Ref_Des_Filter" Ref_Des_Filter_net)
		  );end if

		axlFormDisplay(Find_Component_Form)
		axlUIWPrint(Find_Component_Form "Nothing Find")
	 else
		axlFormSetField(Find_Component_Form "Placed_List" Placed_List)
		if(lgs_c_or_n == t
		then
			axlFormSetField(Find_Component_Form "Ref_Des_Filter" Ref_Des_Filter_comps)
		else
			axlFormSetField(Find_Component_Form "Ref_Des_Filter" Ref_Des_Filter_net)
		  );end if
		axlFormDisplay(Find_Component_Form)
		axlUIWPrint(Find_Component_Form "Select Component or Net")
   	); end if Placed_List==nil
   	
  shell("rm Find_Component_Form.form")
 
 
 
;************************************************************************************************************
;		Find_Component_Form_Action_Routine (Find_Component_Form)
;************************************************************************************************************

(defun Find_Component_Form_Action_Routine (Find_Component_Form)
	(case Find_Component_Form->curField
		("lgs_comps"
			lgs_c_or_n = Find_Component_Form->curValue
			if(lgs_c_or_n == nil
			then
				lgs_command_type = nil
				axlFormSetField(Find_Component_Form "Ref_Des_Filter" Ref_Des_Filter_net)
				axlFormSetField(Find_Component_Form "lgs_comps" lgs_command_type)
				axlFormSetField(Find_Component_Form "lgs_hilight" !lgs_command_type)
				if(lgs_alletch_onoff != lgs_alletch_onoff_n
				then
					lgs_alletch_onoff = lgs_alletch_onoff_n
					axlFormSetField(Find_Component_Form "lgs_alletch" lgs_alletch_onoff)
					;_lgs_show_alletch()
				  );end if
			else
				axlFormSetField(Find_Component_Form "Ref_Des_Filter" Ref_Des_Filter_comps)
				if(lgs_alletch_onoff != lgs_alletch_onoff_c
				then
					lgs_alletch_onoff = lgs_alletch_onoff_c
					axlFormSetField(Find_Component_Form "lgs_alletch" lgs_alletch_onoff)
					;_lgs_show_alletch()
				  );end if
								
			  );end if
			  

			lgs_find_updata_Callback()
		
		t)
		
		("lgs_refadt"
			lgs_refadt_onoff = Find_Component_Form->curValue
  			axlShell("setwindow pcb")
  			if(lgs_refadt_onoff == t
			then
				axlVisibleLayer( "REF DES/SILKSCREEN_TOP" t )
			else
				axlVisibleLayer( "REF DES/SILKSCREEN_TOP" nil )
			  );end if
			axlFlushDisplay()
			axlShell("redraw")
	
		t)
		
		("lgs_alletch"
			if(lgs_c_or_n == nil
			then
				lgs_alletch_onoff_n = Find_Component_Form->curValue
				lgs_alletch_onoff = Find_Component_Form->curValue
			else
				lgs_alletch_onoff_c = Find_Component_Form->curValue
				lgs_alletch_onoff = Find_Component_Form->curValue
			  );end if
			_lgs_show_alletch()
		t)

		("lgs_refadb"
			lgs_refadb_onoff = Find_Component_Form->curValue
  			axlShell("setwindow pcb")
			if(lgs_refadb_onoff == t
			then
				axlVisibleLayer( "REF DES/SILKSCREEN_BOTTOM" t )
			else
				axlVisibleLayer( "REF DES/SILKSCREEN_BOTTOM" nil )
			  );end if
			axlFlushDisplay()
			axlShell("redraw")
		t)
		
;		("lgsall"
;			;axlShell("setwindow pcb")
;			axlShell("setwindow form.vf_vis")
;			axlShell("FORM vf_vis all_all_visible YES")
;			;axlFlushDisplay()
;			axlShell("redraw")
;
;		t)
	
		("Refresh_List"
			lgs_find_updata_Callback()
   		); end Refresh_List
   		
		("Ref_Des_Filter"
			if(lgs_c_or_n == t
			then
				Ref_Des_Filter_comps = Find_Component_Form->curValue 
			else
				Ref_Des_Filter_net = Find_Component_Form->curValue 
		  	);end if

    			lgs_find_updata_Callback()
    			
		t); end "Ref_Des_Filter"
  			
  		("lgsadt"
  			axlShell("setwindow pcb")
  			axlVisibleDesign(nil)
			axlVisibleLayer( "BOARD GEOMETRY/OUTLINE" t )
			axlVisibleLayer( "BOARD GEOMETRY/SILKSCREEN_TOP" t ) 
			axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_TOP" t )
			if(lgs_refadt_onoff == t
			then
				axlVisibleLayer( "REF DES/SILKSCREEN_TOP" t )
			  );end if
			axlShell( "setwindow form.vf_vis")
			if(lgs_alletch_onoff == t
			then
				axlShell("FORM vf_vis all_all_visible NO") 
				axlShell("FORM vf_vis all_all_visible YES") 
			else
				axlShell("FORM vf_vis all_all_visible YES") 
				axlShell("FORM vf_vis all_all_visible NO") 
			);end if
			axlShell("setwindow pcb")
			axlVisibleLayer( "PIN/TOP" t )
			axlFlushDisplay()
			;axlShell("setwindow pcb")
			axlShell("redraw")
			;_lgs_show_alletch()
  		t)
  			
  			
  		("lgsadb"
  			axlShell("setwindow pcb")
  			axlVisibleDesign(nil)
			axlVisibleLayer( "BOARD GEOMETRY/OUTLINE" t )
			axlVisibleLayer( "BOARD GEOMETRY/SILKSCREEN_BOTTOM" t ) 
			axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" t )
			if(lgs_refadb_onoff == t
			then
				axlVisibleLayer( "REF DES/SILKSCREEN_BOTTOM" t )
			  );end if
			axlShell( "setwindow form.vf_vis")
			if(lgs_alletch_onoff == t
			then
				axlShell("FORM vf_vis all_all_visible NO") 
				axlShell("FORM vf_vis all_all_visible YES") 
			else
				axlShell("FORM vf_vis all_all_visible YES") 
				axlShell("FORM vf_vis all_all_visible NO") 
			);end if
			axlShell("setwindow pcb")
			axlVisibleLayer( "PIN/BOTTOM" t )
			axlFlushDisplay()
			axlShell("redraw")
			
  		t)
  			
  		("lgs_command"
  				lgs_command_type =  Find_Component_Form->curValue   			
  		t)

		("done"
			Placed_List=nil
			axlClearSelSet()
			(axlFormClose Find_Component_Form)
			(axlCancelEnterFun)
		); end "done"
		
		("Placed_List"
			if(lgs_command_type == t
			then
				Component_bBox = nthelem(_lgs_name_find_number(Find_Component_Form->curValue) Placed_List_bbox)
				;lgs_temp =  nthelem(_lgs_name_find_number(Find_Component_Form->curValue) Placed_list_pin_xy)
				;sprintf(lgs_temp1 "x %1.2f y %1.2f" car( lgs_temp) nthelem(2 lgs_temp))
				;axlShell(lgs_temp1)
				Lower_X=car(car(Component_bBox))-200
				Lower_Y=car(cdr(car(Component_bBox)))-200
				Upper_X=car(car(cdr(Component_bBox)))+200
				Upper_Y=car(cdr(car(cdr(Component_bBox))))+200
				axlWindowBoxSet(list(Lower_X:Lower_Y Upper_X:Upper_Y)) 
			else
				if(lgs_c_or_n == t  
				then
					axlSetFindFilter(?enabled '(components) ?onButtons '(components))
					Component=axlGetSelSet(axlSingleSelectName("COMPONENT" strcat(Find_Component_Form->curValue)))
					axlHighlightObject(Component)
					Lower_X=car(car(car(Component)->symbol->bBox))-300
					Lower_Y=car(cdr(car(car(Component)->symbol->bBox)))-300
					Upper_X=car(car(cdr(car(Component)->symbol->bBox)))+300
					Upper_Y=car(cdr(car(cdr(car(Component)->symbol->bBox))))+300
				else
					axlSetFindFilter(?enabled '(noall nets) ?onButtons '(noall nets))
					;Comp_List=axlGetSelSet(axlSingleSelectName("NET" Ref_Des_Filter))

					;axlSetFindFilter(?enabled '(components) ?onButtons '(components))
					Component=axlGetSelSet(axlSingleSelectName("NET" strcat(Find_Component_Form->curValue)))
					axlHighlightObject(Component)
					Lower_X=car(car(car(Component)->bBox))-300
					Lower_Y=car(cdr(car(car(Component)->bBox)))-300
					Upper_X=car(car(cdr(car(Component)->bBox)))+300
					Upper_Y=car(cdr(car(cdr(car(Component)->bBox))))+300
				
				 );end   if(lgs_c_or_n == t     
					Command=sprintf(dummy "window points;x %f y %f;x %f y %f" Lower_X Lower_Y Upper_X Upper_Y)
					;axlFormSetField(Find_Component_Form "Current_Ref_Des" Find_Component_Form->curValue)
					axlShell(Command)

			);end if
		 	t
  			); end "Placed_List"
  			
  			("lgs_help_find_comp"
  				_lgs_Build_Technics_Manager_Help_Form()
  			t)
  			
	); end case
	
); end defun Find_Component_Form_Action_Routine
 
 
;************************************************************************************************************
;		_lgs_name_find_number (comps_name)
;************************************************************************************************************
(defun _lgs_name_find_number (comps_name)
(prog ()
i = 0
foreach(lgs_temp Placed_List
	i++
	if(lgs_temp == comps_name 
	then
		return(i)
	  );end if
	);end foreach

return(nil)
));end defun _lgs_name_find_number (comps_name)


;************************************************************************************************************
;		_lgs_Build_Technics_Manager_Help_Form ()
;************************************************************************************************************
(defun _lgs_Build_Technics_Manager_Help_Form ()
	setq( lgsfindcompshelpform "./lgsfindhelp.form")
        deleteFile( lgsfindcompshelpform)
        FORMFINDHELPFILE = outfile( lgsfindcompshelpform)
        fprintf( FORMFINDHELPFILE "#FIND COMPS V1.3 HELP FROM FILE\n")
        fprintf( FORMFINDHELPFILE "#WRITE BY LIGUANGSHENG HUAWEI 24445\n")
        fprintf( FORMFINDHELPFILE "FILE_TYPE=FORM_DEFN VERSION=2\n")
        fprintf( FORMFINDHELPFILE "FORM\n")
        fprintf( FORMFINDHELPFILE "FIXED\n")
        fprintf( FORMFINDHELPFILE "PORT 33 70\n")
        fprintf( FORMFINDHELPFILE "HEADER \"Find Comps V1.3\"\n")
        fprintf( FORMFINDHELPFILE "TILE\n")
        fprintf( FORMFINDHELPFILE "GROUP \"\"\n")
        fprintf( FORMFINDHELPFILE "FLOC 3 0\n")
        fprintf( FORMFINDHELPFILE "FSIZE 28 6\n")
        fprintf( FORMFINDHELPFILE "INFO group\n")
        fprintf( FORMFINDHELPFILE "ENDGROUP\n")
        fprintf( FORMFINDHELPFILE "TEXT \"FIND COMPS V1.3\"\n")
        fprintf( FORMFINDHELPFILE "TLOC 10 2\n")
        fprintf( FORMFINDHELPFILE "ENDTEXT\n")
        fprintf( FORMFINDHELPFILE "TEXT \"Find Component Zoom Fit\"\n")
        fprintf( FORMFINDHELPFILE "TLOC 8 4\n")
        fprintf( FORMFINDHELPFILE "ENDTEXT\n")
        fprintf( FORMFINDHELPFILE "TEXT \"Revision:1.3\"\n")
        fprintf( FORMFINDHELPFILE "TLOC 13 6\n")
        fprintf( FORMFINDHELPFILE "ENDTEXT\n")
        fprintf( FORMFINDHELPFILE "TEXT \"Write by:Li Guangsheng/24445\"\n")
        fprintf( FORMFINDHELPFILE "TLOC 6 8\n")
        fprintf( FORMFINDHELPFILE "ENDTEXT\n")
        fprintf( FORMFINDHELPFILE "TEXT \"HUAWEI CAD \"\n")
        fprintf( FORMFINDHELPFILE "TLOC 12 10\n")
        fprintf( FORMFINDHELPFILE "ENDTEXT\n")
        fprintf( FORMFINDHELPFILE "TEXT \"DATA:05/25/2002\"\n")
        fprintf( FORMFINDHELPFILE "TLOC 11 12\n")
        fprintf( FORMFINDHELPFILE "ENDTEXT\n")
        fprintf( FORMFINDHELPFILE "TEXT \"Have any Problem Please Contact Me!\"\n")
        fprintf( FORMFINDHELPFILE "TLOC 4 14\n")
        fprintf( FORMFINDHELPFILE "ENDTEXT\n")
        fprintf( FORMFINDHELPFILE "TEXT \"ADD:1618   TEL:50574\"\n")
        fprintf( FORMFINDHELPFILE "TLOC 8 16\n")
        fprintf( FORMFINDHELPFILE "ENDTEXT\n")
        fprintf( FORMFINDHELPFILE "FIELD lgsok\n")
        fprintf( FORMFINDHELPFILE "FLOC 11 18\n")
        fprintf( FORMFINDHELPFILE "MENUBUTTON \"OK\" 10 3\n")
        fprintf( FORMFINDHELPFILE "ENDFIELD\n")
        fprintf( FORMFINDHELPFILE "ENDTILE\n")
        fprintf( FORMFINDHELPFILE "ENDFORM\n")
        close( FORMFINDHELPFILE)
        findhelpform = (axlFormCreate (gensym) lgsfindcompshelpform `("E" "OUTER") `lgs_find_help_Callback t)
        axlFormDisplay( findhelpform)
);defun _lgs_Build_Technics_Manager_Help_Form ()

;************************************************************************************************************
;		lgs_find_help_Callback (findhelpform)
;************************************************************************************************************
(defun lgs_find_help_Callback (findhelpform)
	axlFormClose( findhelpform)
	deleteFile( lgsfindcompshelpform)
);end defun lgs_tech_help_Callback (helpform) 

;************************************************************************************************************
;		lgs_find_updata_Callback ()
;************************************************************************************************************
(defun lgs_find_updata_Callback ()
			Placed_List=nil
			Placed_List_bbox = nil
			Placed_list_pin_xy = nil
			axlDBRefreshId(axlDBGetDesign())
			axlClearSelSet()
			
			
			if(lgs_c_or_n == t
			then
				axlSetFindFilter(?enabled '(noall components) ?onButtons '(noall components))
				Comp_List=axlGetSelSet(axlSingleSelectName("COMPONENT" Ref_Des_Filter_comps))
				(foreach Item Comp_List
					(if Item->symbol!=nil 
					 then
						Placed_List=cons(Item->name Placed_List)
						Placed_List_bbox = cons( Item->symbol->bBox Placed_List_bbox )
						;Placed_list_pin_xy = cons( car( Item->symbol->pins~>xy) Placed_list_pin_xy)
					); if Item->symbol!=nil
				); end foreach Item Comp_List
			
			else
				axlSetFindFilter(?enabled '(noall nets) ?onButtons '(noall nets))
				Comp_List=axlGetSelSet(axlSingleSelectName("NET" Ref_Des_Filter_net))
				(foreach Item Comp_List
			
						Placed_List=cons(Item->name Placed_List)
						Placed_List_bbox = cons( Item->bBox Placed_List_bbox )
						;Placed_List_bbox = cons( getbox( Item) Placed_List_bbox )
			
				); end foreach Item Comp_List
			
			);end if(lgs_c_or_n == t
  
			axlClearSelSet()
		
			(if Placed_List==nil 
			 then
			 	axlFormListDeleteAll(Find_Component_Form "Placed_List")
			 	axlFormSetField(Find_Component_Form "Placed_List" "No Match")
				if(lgs_c_or_n == t
				then
					axlFormSetField(Find_Component_Form "Ref_Des_Filter" Ref_Des_Filter_comps)
				else
					axlFormSetField(Find_Component_Form "Ref_Des_Filter" Ref_Des_Filter_net)
				  );end if
			 	;axlFormSetField(Find_Component_Form "Ref_Des_Filter" Ref_Des_Filter)
			 	axlFormSetField(Find_Component_Form "lgs_refadt" lgs_refadt_onoff)
			 	axlFormSetField(Find_Component_Form "lgs_refadb" lgs_refadb_onoff) 
			 	axlFormSetField(Find_Component_Form "lgs_alletch" lgs_alletch_onoff)
			 	axlFormDisplay(Find_Component_Form)
			 	axlUIWPrint(Find_Component_Form "No Match")
			 else
			 	axlFormListDeleteAll(Find_Component_Form "Placed_List")
			 					  
			 axlFormSetField(Find_Component_Form "Placed_List" Placed_List)
			 
			); end if Placed_List==nil

);(defun lgs_find_updata_Callback ()


;************************************************************************************************************
;		lgs_find_updata_Callback ()
;************************************************************************************************************
(defun _lgs_show_alletch ()
axlShell( "setwindow form.vf_vis")
if(lgs_alletch_onoff == t
then
;	axlShell("FORM vf_vis all_all_visible NO") 
	axlShell("FORM vf_vis all_all_visible YES") 
else
;	axlShell("FORM vf_vis all_all_visible YES") 
	axlShell("FORM vf_vis all_all_visible NO") 
);end if
);end defun
;************************************************************************************************************
;************************************************************************************************************
); end defun Find_Component_Routine
;************************************************************************************************************





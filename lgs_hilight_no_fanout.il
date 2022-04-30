;			Hilight SMD Pins without Fanout
;		------------------------------------------------
;
;
;File name: lgs_hilight_nofanout.il
;Revision:1.0	
;Date:June 1,2002
;Writen by: 
;LiGuangsheng/24445
;Tel: 6540574
;E_mail: liguangsheng@huawei.com
;CAD Group Fundamental Dept R&D Engineer
;HUAWEI TECHNOLOGIES CO., LTD.

   


;***************************************************************************************************************************
;		Register Main Function
;***************************************************************************************************************************
axlCmdRegister( "hl_nf_top" `_lgs_hilight_no_fanoutsmd_top ?cmdType "general")
axlCmdRegister( "hl_nf_botm" `_lgs_hilight_no_fanoutsmd_botm ?cmdType "general")
axlCmdRegister( "hl_nf" `_lgs_hilight_smd_main ?cmdType "general")

;***************************************************************************************************************************
;		Main Function
;***************************************************************************************************************************
(defun _lgs_hilight_smd_main ()
let( ( lgs_smd_bBox lgs_all_pins_list lgs_hilight_bBox lgs_time lgs_step lgs_i lgs_item_bBox_mi lgs_hilight_smd_main_form)


 

;***************************************************************************************************************************
;		_lgs_creat_hilight_smd_main_form()
;***************************************************************************************************************************
(defun _lgs_creat_hilight_smd_main_form ()
	Hilight_SMD_Form_File = outfile("lgs_hilight_smd_Main_Form.form" "w")
        fprintf( Hilight_SMD_Form_File "FILE_TYPE=FORM_DEFN VERSION=2\n")
        fprintf( Hilight_SMD_Form_File "FORM\n")
        fprintf( Hilight_SMD_Form_File "FIXED\n")
        fprintf( Hilight_SMD_Form_File "PORT 24 20\n")
        fprintf( Hilight_SMD_Form_File "HEADER \"Hilight SMD V1.0\"\n")
        fprintf( Hilight_SMD_Form_File "TILE\n")
        fprintf( Hilight_SMD_Form_File "GROUP \"\"\n")
        fprintf( Hilight_SMD_Form_File "FLOC 1 0\n")
        fprintf( Hilight_SMD_Form_File "FSIZE 23 11\n")
        fprintf( Hilight_SMD_Form_File "INFO group\n")
        fprintf( Hilight_SMD_Form_File "ENDGROUP  \n")
        fprintf( Hilight_SMD_Form_File "FIELD lgs_h_top\n")
        fprintf( Hilight_SMD_Form_File "FLOC 2 2\n")
        fprintf( Hilight_SMD_Form_File "MENUBUTTON \"Hilight Top\" 3 3\n")
        fprintf( Hilight_SMD_Form_File "ENDFIELD\n")
        fprintf( Hilight_SMD_Form_File "FIELD lgs_h_botm\n")
        fprintf( Hilight_SMD_Form_File "FLOC 12 2\n")
        fprintf( Hilight_SMD_Form_File "MENUBUTTON \"Hilight Botm\" 3 3\n")
        fprintf( Hilight_SMD_Form_File "ENDFIELD\n")
        fprintf( Hilight_SMD_Form_File "FIELD lgs_info\n")
        fprintf( Hilight_SMD_Form_File "FLOC 2 5\n")
        fprintf( Hilight_SMD_Form_File "STRFILLIN 19 45\n")
        fprintf( Hilight_SMD_Form_File "ENDFIELD\n")
        fprintf( Hilight_SMD_Form_File "FIELD lgs_first\n")
        fprintf( Hilight_SMD_Form_File "FLOC 2 8\n")
        fprintf( Hilight_SMD_Form_File "MENUBUTTON \"First\" 3 3\n")
        fprintf( Hilight_SMD_Form_File "ENDFIELD\n")
        fprintf( Hilight_SMD_Form_File "FIELD lgs_next\n")
        fprintf( Hilight_SMD_Form_File "FLOC 7 8\n")
        fprintf( Hilight_SMD_Form_File "MENUBUTTON \"Next\" 3 3\n")
        fprintf( Hilight_SMD_Form_File "ENDFIELD\n")
        fprintf( Hilight_SMD_Form_File "FIELD lgs_prev\n")
        fprintf( Hilight_SMD_Form_File "FLOC 13 8\n")
        fprintf( Hilight_SMD_Form_File "MENUBUTTON \"Prev\" 3 3\n")
        fprintf( Hilight_SMD_Form_File "ENDFIELD\n")
        fprintf( Hilight_SMD_Form_File "FIELD lgs_last\n")
        fprintf( Hilight_SMD_Form_File "FLOC 18 8\n")
        fprintf( Hilight_SMD_Form_File "MENUBUTTON \"Last\" 3 3\n")
        fprintf( Hilight_SMD_Form_File "ENDFIELD\n")
        fprintf( Hilight_SMD_Form_File "FIELD done\n")
        fprintf( Hilight_SMD_Form_File "FLOC 2 12\n")
        fprintf( Hilight_SMD_Form_File "MENUBUTTON \"Done\" 8 3\n")
        fprintf( Hilight_SMD_Form_File "ENDFIELD\n")
        fprintf( Hilight_SMD_Form_File "FIELD lgs_hilight_help\n")
        fprintf( Hilight_SMD_Form_File "FLOC 15 12\n")
        fprintf( Hilight_SMD_Form_File "MENUBUTTON \"Help\" 6 3\n")
        fprintf( Hilight_SMD_Form_File "ENDFIELD\n")
        fprintf( Hilight_SMD_Form_File "ENDTILE\n")
        fprintf( Hilight_SMD_Form_File "ENDFORM\n")
	close( Hilight_SMD_Form_File)
	lgs_hilight_smd_main_form = axlFormCreate( (gensym) "lgs_hilight_smd_Main_Form.form" 
						'(e outer) '_lgs_hilight_smd_main_back t)
	deleteFile( "lgs_hilight_smd_Form.form")
	axlFormDisplay( lgs_hilight_smd_main_form)
);end (defun _lgs_creat_hilight_smd_main_form ()

;***************************************************************************************************************************
;		_lgs_hilight_smd_main_back()
;***************************************************************************************************************************
(defun _lgs_hilight_smd_main_back ( lgs_hilight_smd_main_form)
case(lgs_hilight_smd_main_form->curField

	("lgs_h_top"
		_lgs_hilight_no_fanoutsmd_top()
		sprintf(lgs_info "Hilight %d SMD Pin!" length(lgs_hilight_bBox))
		axlFormSetField( lgs_hilight_smd_main_form "lgs_info" lgs_info)
		lgs_view_number = 0
	t)

	("lgs_h_botm"
		_lgs_hilight_no_fanoutsmd_botm()
		sprintf(lgs_info "Hilight %d SMD Pin!" length(lgs_hilight_bBox))
		axlFormSetField( lgs_hilight_smd_main_form "lgs_info" lgs_info)
		lgs_view_number = 0
	t)
	
	("lgs_first"
		if(length( lgs_hilight_bBox) != 0
		then
			lgs_view_number = 1
			lgs_bBox = nthelem(lgs_view_number lgs_hilight_bBox)
			axlWindowBoxSet(list((caar( lgs_bBox)-200):(cadar( lgs_bBox)-200) 
					     (caar( lgs_bBox)+200):(cadar( lgs_bBox)+200)))
			sprintf(lgs_info "%d of %d" lgs_view_number length(lgs_hilight_bBox))
			axlFormSetField( lgs_hilight_smd_main_form "lgs_info" lgs_info)					 
		);end if
	t)
	
	("lgs_next"
		if(length( lgs_hilight_bBox) > lgs_view_number
		then
			lgs_view_number++
			lgs_bBox = nthelem(lgs_view_number lgs_hilight_bBox)
			axlWindowBoxSet(list((caar( lgs_bBox)-200):(cadar( lgs_bBox)-200) 
					     (caar( lgs_bBox)+200):(cadar( lgs_bBox)+200)))
			sprintf(lgs_info "%d of %d" lgs_view_number length(lgs_hilight_bBox))
			axlFormSetField( lgs_hilight_smd_main_form "lgs_info" lgs_info)					 
		);end if
	t)
	
	("lgs_prev"
		if(lgs_view_number > 1
		then
			lgs_view_number--
			lgs_bBox = nthelem(lgs_view_number lgs_hilight_bBox)
			axlWindowBoxSet(list((caar( lgs_bBox)-200):(cadar( lgs_bBox)-200) 
					     (caar( lgs_bBox)+200):(cadar( lgs_bBox)+200)))
			sprintf(lgs_info "%d of %d" lgs_view_number length(lgs_hilight_bBox))
			axlFormSetField( lgs_hilight_smd_main_form "lgs_info" lgs_info)					 
		);end if
	t)
	
	("lgs_last"
		if(length( lgs_hilight_bBox) != 0
		then
			lgs_view_number = length( lgs_hilight_bBox)
			lgs_bBox = nthelem(lgs_view_number lgs_hilight_bBox)
			axlWindowBoxSet(list((caar( lgs_bBox)-200):(cadar( lgs_bBox)-200) 
					     (caar( lgs_bBox)+200):(cadar( lgs_bBox)+200)))
			sprintf(lgs_info "%d of %d" lgs_view_number length(lgs_hilight_bBox))
			axlFormSetField( lgs_hilight_smd_main_form "lgs_info" lgs_info)					 
		);end if
	t)
	
	("done"
		axlFormClose( lgs_hilight_smd_main_form)
	t)
	
	("lgs_hilight_help"
		_lgs_hilight_smd_help_Form()
	t)



);end case
);end defun _lgs_hilight_smd_main_back ()

;************************************************************************************************************
;		_lgs_Build_Technics_Manager_Help_Form ()
;************************************************************************************************************
(defun _lgs_hilight_smd_help_Form ()
	setq( lgsfindcompshelpform "./lgshilighthelp.form")
        deleteFile( lgsfindcompshelpform)
        FORMFINDHELPFILE = outfile( lgsfindcompshelpform)
        fprintf( FORMFINDHELPFILE "FILE_TYPE=FORM_DEFN VERSION=2\n")
        fprintf( FORMFINDHELPFILE "FORM\n")
        fprintf( FORMFINDHELPFILE "FIXED\n")
        fprintf( FORMFINDHELPFILE "PORT 33 70\n")
        fprintf( FORMFINDHELPFILE "HEADER \"Hilight SMD V1.0\"\n")
        fprintf( FORMFINDHELPFILE "TILE\n")
        fprintf( FORMFINDHELPFILE "GROUP \"\"\n")
        fprintf( FORMFINDHELPFILE "FLOC 3 0\n")
        fprintf( FORMFINDHELPFILE "FSIZE 28 6\n")
        fprintf( FORMFINDHELPFILE "INFO group\n")
        fprintf( FORMFINDHELPFILE "ENDGROUP\n")
        fprintf( FORMFINDHELPFILE "TEXT \"Hilight SMD V1.0\"\n")
        fprintf( FORMFINDHELPFILE "TLOC 10 2\n")
        fprintf( FORMFINDHELPFILE "ENDTEXT\n")
        fprintf( FORMFINDHELPFILE "TEXT \"Hilight SMD without fanout\"\n")
        fprintf( FORMFINDHELPFILE "TLOC 8 4\n")
        fprintf( FORMFINDHELPFILE "ENDTEXT\n")
        fprintf( FORMFINDHELPFILE "TEXT \"Revision:1.0\"\n")
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
);(defun _lgs_hilight_smd_help_Form ()

;************************************************************************************************************
;		lgs_find_help_Callback (findhelpform)
;************************************************************************************************************
(defun lgs_find_help_Callback (findhelpform)
	axlFormClose( findhelpform)
	deleteFile( lgsfindcompshelpform)
);end defun lgs_tech_help_Callback (helpform) 

;***************************************************************************************************************************
;		_lgs_hilight_no_fanoutsmd_top()
;***************************************************************************************************************************
(defun _lgs_hilight_no_fanoutsmd_top ()

_lgs_creat_hilight_smd_form()
axlUIWPrint( lgs_hilight_smd_form "getting pins information.Please Wait...")
axlFormSetField( lgs_hilight_smd_form "lgs_progress" 1)                                                      
lgs_smd_bBox = nil

axlShell("setwindow pcb")
axlVisibleDesign( nil)
axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t)
axlVisibleLayer("BOARD GEOMETRY/SILKSCREEN_TOP" t)
axlVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_TOP" t)
axlVisibleLayer("ETCH/TOP" t)
axlVisibleLayer("VIA CLASS/TOP" t)
axlVisibleLayer("PIN/TOP" t)
axlFlushDisplay()
axlShell("redraw")
axlFormSetField( lgs_hilight_smd_form "lgs_progress" 2)
axlSetFindFilter(?enabled '(noall pins) ?onButtons '(noall pins))
lgs_all_pins_list = axlGetSelSet(axlAddSelectAll())
axlFormSetField( lgs_hilight_smd_form "lgs_progress" 10)
axlUIWPrint( lgs_hilight_smd_form "Finding SMD Pins without Fanout.Please Wait...")
axlClearSelSet()
axlSetFindFilter(?enabled '(noall VIAS CLINESEGS SHAPES) ?onButtons '(noall VIAS CLINESEGS SHAPES))

;---------------get smd pin bBox--------------------------------------------------------------------------------------------
lgs_hilight_bBox = nil
lgs_time = 11
lgs_step = length( lgs_all_pins_list)/45
lgs_i = 0
foreach(lgs_item_pin lgs_all_pins_list
	lgs_i++
	if((lgs_item_pin->isThrough==nil) && (lgs_item_pin->startEnd=='("ETCH/TOP" "ETCH/TOP"))
	then
		
		lgs_item_bBox_mi = list(list( (caar(lgs_item_pin->bBox)+caadr(lgs_item_pin->bBox))/2-1 
					      (cadar(lgs_item_pin->bBox)+cadadr(lgs_item_pin->bBox))/2-1) 
					list( (caar(lgs_item_pin->bBox)+caadr(lgs_item_pin->bBox))/2+1 
					      (cadar(lgs_item_pin->bBox)+cadadr(lgs_item_pin->bBox))/2+1))
		;-------------------check fanout---------------------------------------------------
		if(axlSingleSelectBox( lgs_item_bBox_mi) == nil
		then
			;-----------check one point net---------------------------------------------
			if(lgs_item_pin~>net~>bBox != lgs_item_pin~>bBox
			then
				lgs_hilight_bBox = append( lgs_hilight_bBox list(lgs_item_bBox_mi))
			);end if(lgs_item_pin~>net~>bBox != lgs_item_pin~>bBox
		);end ifaxlSingle
	);end if
	
	if(lgs_i > lgs_step
	then
		lgs_i = 0
		lgs_time++
		axlFormSetField( lgs_hilight_smd_form "lgs_progress" lgs_time)
	
	);end if(lgs_i > lgs_step	

);end foreach(lgs_item lgs_all_pins_list
;---------------high no fanout top smd pin----------------------------------------------------------------------------------
axlShell("setwindow pcb")
axlShell("hilight")
axlShell("setwindow form.find")
axlShell("FORM find all_off")
axlShell("FORM find pins YES")
lgs_step = length( lgs_hilight_bBox)/45
lgs_i = 0
lgs_time++
axlFormSetField( lgs_hilight_smd_form "lgs_progress" lgs_time)
axlUIWPrint( lgs_hilight_smd_form "Hilight SMD Pins without Fanout.Please Wait...")

foreach(lgs_item_bBox lgs_hilight_bBox
	lgs_i++
	sprintf(lgs_command_line "pick grid %1.2f %1.2f" caar( lgs_item_bBox)+1 cadar( lgs_item_bBox)+1)
	axlShell( lgs_command_line)
	
	if(lgs_i > lgs_step
	then
		lgs_i = 0
		lgs_time++
		axlFormSetField( lgs_hilight_smd_form "lgs_progress" lgs_time)
	
	);end if(lgs_i > lgs_step	

);end foreach(lgs_item_bBox lgs_hilight_bBox
axlShell("setwindow pcb")
axlShell("done")
axlFormClose( lgs_hilight_smd_form)

;------------printf information;---------------------------------
printf( "Hilight SMD Pin without fanout V1.0-----Write by HUAWEI: LiGuangsheng/24445\n")
printf( "Hilight SMD Pin without fanout Successful\n")
printf( " %d SMD Pin on ETCH/TOP without fanout, Already Hilight!\n" length( lgs_hilight_bBox))


;------------end defun _lgs_hilight_no_fanoutsmd_top;------------
);end (defun _lgs_hilight_no_fanoutsmd_top ()

;***************************************************************************************************************************
;		END _lgs_hilight_no_fanoutsmd_top()
;***************************************************************************************************************************






;***************************************************************************************************************************
;		_lgs_hilight_no_fanoutsmd_botm()
;***************************************************************************************************************************
(defun _lgs_hilight_no_fanoutsmd_botm ()

_lgs_creat_hilight_smd_form()
axlUIWPrint( lgs_hilight_smd_form "getting pins information.Please Wait...")
axlFormSetField( lgs_hilight_smd_form "lgs_progress" 1)                                                      
lgs_smd_bBox = nil

axlShell("setwindow pcb")
axlVisibleDesign( nil)
axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t)
axlVisibleLayer("BOARD GEOMETRY/SILKSCREEN_BOTTOM" t)
axlVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" t)
axlVisibleLayer("ETCH/BOTTOM" t)
axlVisibleLayer("VIA CLASS/BOTTOM" t)
axlVisibleLayer("PIN/BOTTOM" t)
axlFlushDisplay()
axlShell("redraw")
axlFormSetField( lgs_hilight_smd_form "lgs_progress" 2)
axlSetFindFilter(?enabled '(noall pins) ?onButtons '(noall pins))
lgs_all_pins_list = axlGetSelSet(axlAddSelectAll())
axlFormSetField( lgs_hilight_smd_form "lgs_progress" 10)
axlUIWPrint( lgs_hilight_smd_form "Finding SMD Pins without Fanout.Please Wait...")
axlClearSelSet()
axlSetFindFilter(?enabled '(noall VIAS CLINESEGS SHAPES) ?onButtons '(noall VIAS CLINESEGS SHAPES))

;---------------get smd pin bBox--------------------------------------------------------------------------------------------
lgs_hilight_bBox = nil
lgs_time = 11
lgs_step = length( lgs_all_pins_list)/45
lgs_i = 0

foreach(lgs_item_pin lgs_all_pins_list
	lgs_i++
	if((lgs_item_pin->isThrough==nil) && (lgs_item_pin->startEnd=='("ETCH/BOTTOM" "ETCH/BOTTOM"))
	then
		
		lgs_item_bBox_mi = list(list( (caar(lgs_item_pin->bBox)+caadr(lgs_item_pin->bBox))/2-1 
					      (cadar(lgs_item_pin->bBox)+cadadr(lgs_item_pin->bBox))/2-1) 
				        list( (caar(lgs_item_pin->bBox)+caadr(lgs_item_pin->bBox))/2+1 
				              (cadar(lgs_item_pin->bBox)+cadadr(lgs_item_pin->bBox))/2+1))
		;-------------------check fanout---------------------------------------------------
		if(axlSingleSelectBox( lgs_item_bBox_mi) == nil
		then
			;-----------check one point net---------------------------------------------
			if(lgs_item_pin~>net~>bBox != lgs_item_pin~>bBox
			then
				lgs_hilight_bBox = append( lgs_hilight_bBox list(lgs_item_bBox_mi))
			);end if(lgs_item_pin~>net~>bBox != lgs_item_pin~>bBox
		);end ifaxlSingle
	);end if
	
	if(lgs_i > lgs_step
	then
		lgs_i = 0
		lgs_time++
		axlFormSetField( lgs_hilight_smd_form "lgs_progress" lgs_time)
	
	);end if(lgs_i > lgs_step	
	

);end foreach(lgs_item lgs_all_pins_list
;---------------high no fanout bottom smd pin-------------------------------------------------------------------------------
axlShell("setwindow pcb")
axlShell("hilight")
axlShell("setwindow form.find")
axlShell("FORM find all_off")
axlShell("FORM find pins YES")
lgs_step = length( lgs_hilight_bBox)/45
lgs_i = 0
lgs_time++
axlFormSetField( lgs_hilight_smd_form "lgs_progress" lgs_time)
axlUIWPrint( lgs_hilight_smd_form "Hilight SMD Pins without Fanout.Please Wait...")

foreach(lgs_item_bBox lgs_hilight_bBox
	lgs_i++
	sprintf(lgs_command_line "pick grid %1.2f %1.2f" caar( lgs_item_bBox)+1 cadar( lgs_item_bBox)+1)
	axlShell( lgs_command_line)
		
	if(lgs_i > lgs_step
	then
		lgs_i = 0
		lgs_time++
		axlFormSetField( lgs_hilight_smd_form "lgs_progress" lgs_time)
	
	);end if(lgs_i > lgs_step	

);end foreach(lgs_item_bBox lgs_hilight_bBox
axlShell("setwindow pcb")
axlShell("done")
axlFormClose( lgs_hilight_smd_form)

;------------printf information------------------------------------
printf( "Hilight SMD Pin without fanout V1.0-----Write by HUAWEI: LiGuangsheng/24445\n")
printf( "Hilight SMD Pin without fanout Successful\n")
printf( " %d SMD Pin on ETCH/BOTTOM without fanout, Already Hilight!\n" length( lgs_hilight_bBox))

;------------end defun _lgs_hilight_no_fanoutsmd_botm------------------------------------

);end (defun _lgs_hilight_no_fanoutsmd_botm ()

;***************************************************************************************************************************
;		END _lgs_hilight_no_fanoutsmd_botm()
;***************************************************************************************************************************



;***************************************************************************************************************************
;		_lgs_creat_hilight_smd_form()
;***************************************************************************************************************************
(defun _lgs_creat_hilight_smd_form ()
;let( (hilightsmd_Form)
hilightsmd_Form=outfile("lgs_hilight_smd_Form.form" "w")
fprintf(hilightsmd_Form "#Write by lgs \n")
fprintf(hilightsmd_Form "FILE_TYPE=FORM_DEFN VERSION=2\n")
fprintf(hilightsmd_Form "FORM\n")     
fprintf(hilightsmd_Form "FIXED\n")               
fprintf(hilightsmd_Form "PORT 45 14\n")          
fprintf(hilightsmd_Form "HEADER \"Hilight SMD Pin without fanout V1.0\"\n")
fprintf(hilightsmd_Form "TILE\n")                
fprintf(hilightsmd_Form "FIELD lgs_progress\n")      
fprintf(hilightsmd_Form "FLOC 3 1\n")            
fprintf(hilightsmd_Form "PROGRESS 40 3\n")       
fprintf(hilightsmd_Form "ENDFIELD\n")            
fprintf(hilightsmd_Form "ENDTILE\n")             
fprintf(hilightsmd_Form "ENDFORM  \n")           
close(hilightsmd_Form)
lgs_hilight_smd_form = axlFormCreate( (gensym) "lgs_hilight_smd_Form.form" '(e outer) '_lgs_nil t)
deleteFile( "lgs_hilight_smd_Form.form")
axlFormDisplay( lgs_hilight_smd_form)
(defun _lgs_nil (hilightsmd_Form)
1==1
)
;);end let
);end (defun _lgs_creat_hilight_smd_form ()


;***************************************************************************************************************************
;***************************************************************************************************************************
;	END _lgs_hilight_no_fanoutsmd_top()
;***************************************************************************************************************************
;***************************************************************************************************************************


;--------main-----------------------
lgs_view_number = 0
_lgs_creat_hilight_smd_main_form()

);end let
);end (defun _lgs_hilight_smd_main ()
;***************************************************************************************************************************
;***************************************************************************************************************************

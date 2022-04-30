;			Auto Check
;		------------------------------------------------
;
;
;File name: lgs_auto_check.il
;Revision:1.1
;Date:9-14,2002
;Writen by:
;LiGuangsheng/24445
;Tel: 26540574
;E_mail: liguangsheng@huawei.com
;CAD Group Fundamental Dept R&D Engineer
;HUAWEI TECHNOLOGIES CO., LTD.


axlCmdRegister( "loop90 Check" `_lgs_auto_check )

lgs_debug = nil


lgs_filter = "*"
lgs_degree_length = 0.00
declare( lgs_crosstalk_data[12])
lgs_temp = '(nil 5 3000 nil 6 4000 nil 8 8000 nil 10 12000)
for(i 0 11
	lgs_crosstalk_data[i] = nth( i lgs_temp)
);end for


;***************************************************************************************************************************
;***************************************************************************************************************************

;				MAIN FUNCTION
;			==============================

;***************************************************************************************************************************
;		_lgs_auto_check()
;***************************************************************************************************************************

(defun _lgs_auto_check ()

	lgs_number = 0		;?????????????????
	lgs_list_mode = "net"
	_lgs_make_acform()
	lgs_command = 0
	lgs_zoom = 0
	lgs_temp_xy = nil
	lgs_temp_bbox = nil
	lgs_netlist = _lgs_get_match_netname( lgs_filter)
	lgs_errlist = nil
	lgs_errlistxy = nil
	_lgs_first_setup_form()


);end defun _lgs_auto_check
;***************************************************************************************************************************
;		_lgs_first_setup_form()
;***************************************************************************************************************************
(defun _lgs_first_setup_form ()

	axlFormSetField( lgs_ac_form "lgs_net_err" "net")
	axlFormSetField( lgs_ac_form "Ref_Des_Filter" lgs_filter)
	axlFormSetField( lgs_ac_form "Err_List" lgs_netlist)
	axlFormSetField( lgs_ac_form "lgs_loop" t)
	axlFormSetField( lgs_ac_form "lgs_90degree" nil)
	axlFormSetField( lgs_ac_form "lgs_length" lgs_degree_length)
	axlFormSetField( lgs_ac_form "shadow_factor"  "0%")
	;axlFormSetField( lgs_ac_form "shadow_bright" 50)

);end _lgs_first_setup_form()
;***************************************************************************************************************************
;		_lgs_get_match_netname()
;***************************************************************************************************************************
(defun _lgs_get_match_netname ( lgs_filter)
(prog ()
axlSetFindFilter(?enabled '(noall nets) ?onButtons '(noall nets))
lgs_List = axlGetSelSet(axlSingleSelectName("NET" lgs_filter))
lgs_temp = nil
foreach(lgs_net lgs_List
		lgs_temp = append(lgs_temp list(lgs_net->name))
	);end foreach
lgs_temp = sort( lgs_temp nil)
return( lgs_temp)
));end defun _lgs_get_match_netname
;***************************************************************************************************************************
;		_lgs_ac_check()
;***************************************************************************************************************************
(defun _lgs_ac_check ()
case(lgs_command

	(0
		axlUIWPrint( lgs_ac_form "Checking Loop Error!")
		_lgs_creat_progress_formloop()
		axlUIWPrint( lgs_progress_form  "0%% complete!")
		lgs_templist = _lgs_check_loop( lgs_netlist)


		lgs_errlist = car( lgs_templist)
		lgs_errlistxy = cadr( lgs_templist)

		axlClearSelSet()
		lgs_list_mode = "err"
		axlFormSetField( lgs_ac_form "lgs_net_err" "error")
		axlFormListDeleteAll( lgs_ac_form "Err_List")
		axlFormSetField( lgs_ac_form "Err_List" lgs_errlist)
		axlFormClose( lgs_progress_form)
		axlUIWPrint( lgs_ac_form "%d Loop Errors Be Find!" length(lgs_errlist))



	t)

	(1
		;printf("Checking 90 Degree Error!\n")
		axlUIWPrint( lgs_ac_form "Checking Degree Error!")
		_lgs_creat_progress_formloop()
		axlUIWPrint( lgs_progress_form  "0%% complete!")

		lgs_templist = _lgs_check_90Degree( lgs_netlist)

		lgs_errlist = car( lgs_templist)
		lgs_errlistxy = cadr( lgs_templist)

		axlClearSelSet()
		lgs_list_mode = "err"
		axlFormSetField( lgs_ac_form "lgs_net_err" "error")
		axlFormListDeleteAll( lgs_ac_form "Err_List")
		axlFormSetField( lgs_ac_form "Err_List" lgs_errlist)
		axlFormClose( lgs_progress_form)
		axlUIWPrint( lgs_ac_form "%d Degree Errors Be Find!" length(lgs_errlist))


	t)

	(2
		printf("Checking Crosstalk Error!\n")
	t)

);end case(lgs_command
);end dufun _lgs_ac_check
;***************************************************************************************************************************
;		_lgs_ac_form_callback()
;***************************************************************************************************************************
(defun _lgs_ac_form_callback ( lgs_ac_form)
case(lgs_ac_form->curField
	;---------------------------------------------------------
	("lgs_net_err"
		if(lgs_ac_form->curValue == "net"
		then
			lgs_list_mode = "net"
			axlFormListDeleteAll( lgs_ac_form "Err_List")
			axlFormSetField( lgs_ac_form "Err_List" lgs_netlist)
			axlUIWPrint( lgs_ac_form "Net List.")
		else
			lgs_list_mode = "err"
			axlFormListDeleteAll( lgs_ac_form "Err_List")
			axlFormSetField( lgs_ac_form "Err_List" lgs_errlist)
			axlUIWPrint( lgs_ac_form "Error List.")

		);end if
	t)

	("Ref_Des_Filter"
		lgs_filter = lgs_ac_form->curValue
		lgs_netlist = _lgs_get_match_netname( lgs_filter)
		axlFormSetField( lgs_ac_form "lgs_net_err" "net")
		axlFormListDeleteAll( lgs_ac_form "Err_List")
		axlFormSetField( lgs_ac_form "Err_List" lgs_netlist)
		axlUIWPrint( lgs_ac_form "%d Nets Be Find!" length( lgs_netlist))
	t)


	("Loop_or_90Degree"
		lgs_command = 0
		axlFormSetField( lgs_ac_form "lgs_loop" t)
		axlFormSetField( lgs_ac_form "lgs_90degree" nil)
		axlUIWPrint( lgs_ac_form "Check Loop Error.")
	t)

	("Crosstalk"
		lgs_command = 2
		axlUIWPrint( lgs_ac_form "Check Crosstalk Error.")
	t)

	("lgs_loop"
		if(lgs_ac_form->curValue
		then
			lgs_command = 0
			axlUIWPrint( lgs_ac_form "Check Loop Error.")
		);end if
	t)

	("lgs_90degree"
		if(lgs_ac_form->curValue
		then
			lgs_command = 1
			axlUIWPrint( lgs_ac_form "Check Degree Error.")
		);end if
	t)
	;---------------------------------------------------------
	("lgs_check"
		lgs_number = 0		;?????????????????
		_lgs_ac_check()
	t)

	("lgsdone"
		axlFormClose( lgs_ac_form)
		deleteFile("./lgs_auto_check_form.form")
	t)

	("lgs_length"
		lgs_degree_length = lgs_ac_form->curValue
	t)

	;---------------------------------------------------------
	("lgs_cross_en_1"
		lgs_crosstalk_data[0] = lgs_ac_form->curValue
	t)

	("lgs_cross_en_2"
		lgs_crosstalk_data[3] = lgs_ac_form->curValue
	t)

	("lgs_cross_en_3"
		lgs_crosstalk_data[6] = lgs_ac_form->curValue
	t)

	("lgs_cross_en_4"
		lgs_crosstalk_data[9] = lgs_ac_form->curValue
	t)

	;---------------------------------------------------------
	("Err_List"
		if(lgs_list_mode == "err"
		then
			axlSetFindFilter(?enabled '(noall nets) ?onButtons '(noall nets))
			axlSingleSelectName("NET" lgs_ac_form->curValue)
			lgs_temp_xy = nth( lgs_ac_form->curValueInt lgs_errlistxy)
			lgs_zoom_i = 270 - 2.5*lgs_zoom
			axlWindowBoxSet(list((car( lgs_temp_xy)-lgs_zoom_i):(cadr( lgs_temp_xy)-lgs_zoom_i) (car( lgs_temp_xy)+lgs_zoom_i):(cadr( lgs_temp_xy)+lgs_zoom_i)))
		;	axlWindowBoxSet(list((car( lgs_temp_xy)-20):(cadr( lgs_temp_xy)-20) (car( lgs_temp_xy)+20):(cadr( lgs_temp_xy)+20)))
			axlUIWPrint( lgs_ac_form "(%1.0f,%1.0f)  (%d/%d)" car( lgs_temp_xy) cadr( lgs_temp_xy) lgs_ac_form->curValueInt+1 length( lgs_errlist))
		else
			axlSetFindFilter(?enabled '(noall nets) ?onButtons '(noall nets))
			lgs_temp_bbox = car(axlGetSelSet(axlSingleSelectName("NET" lgs_ac_form->curValue)))->bBox
			Lower_X=car(car(lgs_temp_bbox))-lgs_zoom_i
			Lower_Y=car(cdr(car(lgs_temp_bbox)))-lgs_zoom_i
			Upper_X=car(car(cdr(lgs_temp_bbox)))+lgs_zoom_i
			Upper_Y=car(cdr(car(cdr(lgs_temp_bbox))))+lgs_zoom_i
			axlWindowBoxSet(list(Lower_X:Lower_Y Upper_X:Upper_Y))

		);end if(lgs_list_mode == "err"
	t)

	("shadow_bright"

			lgs_zoom = lgs_ac_form->curValue
			lgs_zoom_i = 270 - 2.5*lgs_zoom
			axlFormSetField( lgs_ac_form "shadow_factor"  strcat(sprintf( lgs_temp "%d" lgs_zoom) "%"))
			if(lgs_list_mode == "err"
			then
				if(lgs_temp_xy != nil
				then
					axlWindowBoxSet(list((car( lgs_temp_xy)-lgs_zoom_i):(cadr( lgs_temp_xy)-lgs_zoom_i) (car( lgs_temp_xy)+lgs_zoom_i):(cadr( lgs_temp_xy)+lgs_zoom_i)))
				);end if
			else
				if(lgs_temp_bbox != nil
				then
					Lower_X=car(car(lgs_temp_bbox))-lgs_zoom_i
					Lower_Y=car(cdr(car(lgs_temp_bbox)))-lgs_zoom_i
					Upper_X=car(car(cdr(lgs_temp_bbox)))+lgs_zoom_i
					Upper_Y=car(cdr(car(cdr(lgs_temp_bbox))))+lgs_zoom_i
					axlWindowBoxSet(list(Lower_X:Lower_Y Upper_X:Upper_Y))
				);end if
			);end if

	t)

	(""
	t)

	(""
	t)

	(""
	t)

	(""
	t)

	(""
	t)

	(""
	t)

	(""
	t)

	(""
	t)


    );end case
);end defun _lgs_ac_form_callback


;***************************************************************************************************************************
;		_lgs_progress()
;***************************************************************************************************************************

(defun _lgs_progress (percent all)

lgs_temp = round( 100*percent/all)
axlFormSetField( lgs_progress_form "lgs_progress" lgs_temp)
axlUIWPrint( lgs_progress_form  "%d%% complete!" lgs_temp)

);end
;***************************************************************************************************************************
;		_lgs_make_acform()
;***************************************************************************************************************************
(defun _lgs_make_acform ()
	lgs_ac_form = outfile("./lgs_auto_check_form.form" "w")
	fprintf( lgs_ac_form "#Auto Check V1.0 Form File						\n")
	fprintf( lgs_ac_form "#Write by HuaWei LiGungsheng/24445                            \n")
	fprintf( lgs_ac_form "FILE_TYPE=FORM_DEFN VERSION=2                                 \n")
	fprintf( lgs_ac_form "FORM                                                          \n")
	fprintf( lgs_ac_form "FIXED                                                         \n")
	fprintf( lgs_ac_form "PORT 24 20                                                    \n")
	fprintf( lgs_ac_form "HEADER \"Auto Check V1.0\"                                    \n")
	fprintf( lgs_ac_form "TILE                                                          \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "GROUP \"Check Net or Error List\"                             \n")
	fprintf( lgs_ac_form "FLOC 1 0                                                      \n")
	fprintf( lgs_ac_form "FSIZE 23 24                                                   \n")
	fprintf( lgs_ac_form "INFO group                                                    \n")
	fprintf( lgs_ac_form "ENDGROUP                                                      \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "POPUP <key_Names>\"Net\" \"net\",\"Error\" \"error\".         \n")
	fprintf( lgs_ac_form "FIELD lgs_net_err                                             \n")
	fprintf( lgs_ac_form "FLOC 2 2                                                      \n")
	fprintf( lgs_ac_form "ENUMSET 5                                                     \n")
	fprintf( lgs_ac_form "POP \"key_Names\"                                             \n")
	fprintf( lgs_ac_form "ENDFIELD                                                      \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "TEXT \"Filter:\"                                              \n")
	fprintf( lgs_ac_form "TLOC 10 2                                                     \n")
	fprintf( lgs_ac_form "ENDTEXT                                                       \n")
	fprintf( lgs_ac_form "FIELD Ref_Des_Filter                                          \n")
	fprintf( lgs_ac_form "FLOC 14 2                                                     \n")
	fprintf( lgs_ac_form "STRFILLIN 7 20                                                \n")
	fprintf( lgs_ac_form "ENDFIELD                                                      \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "FIELD Err_List                                                \n")
	fprintf( lgs_ac_form "FLOC 2 4                                                      \n")
	fprintf( lgs_ac_form "LIST \"\" 21 10                                               \n")
	;fprintf( lgs_ac_form "OPTIONS sort									\n")
	fprintf( lgs_ac_form "ENDFIELD     									\n")

	fprintf( lgs_ac_form "TEXT \"Zoom:\"								\n")
	fprintf( lgs_ac_form "TLOC 1 24                                                     \n")
	fprintf( lgs_ac_form "ENDTEXT                                                       \n")
	fprintf( lgs_ac_form "TEXT                                                          \n")
	fprintf( lgs_ac_form "TLOC 20 24                                                    \n")
	fprintf( lgs_ac_form "FGROUP \"Shadow mode\"                                        \n")
	fprintf( lgs_ac_form "INFO shadow_factor 4                                          \n")
	fprintf( lgs_ac_form "ENDTEXT                                                       \n")
	fprintf( lgs_ac_form "FIELD shadow_bright                                           \n")
	fprintf( lgs_ac_form "FLOC 6 24                                                     \n")
	;fprintf( lgs_ac_form "FGROUP \"Shadow mode\"                                        \n")
	fprintf( lgs_ac_form "TRACKBAR 14 4                                                 \n")
	fprintf( lgs_ac_form "MIN 0                                                         \n")
	fprintf( lgs_ac_form "MAX 100                                                       \n")
	fprintf( lgs_ac_form "ENDFIELD                                                      \n")

	fprintf( lgs_ac_form "###############################                               \n")
	fprintf( lgs_ac_form "TABSET \"tab\"                                                \n")
	fprintf( lgs_ac_form "FLOC 1 27                                                     \n")
	fprintf( lgs_ac_form "TSSIZE 23 18                                                  \n")
	fprintf( lgs_ac_form "###############################                               \n")
	fprintf( lgs_ac_form "TAB \"Loop or 90Degree\"                                      \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "FIELD pselect_image                                           \n")
	fprintf( lgs_ac_form "THUMBNAIL lgs_cross                                           \n")
	fprintf( lgs_ac_form "FLOC 4 3                                                      \n")
	fprintf( lgs_ac_form "FSIZE 15 5                                                    \n")
	fprintf( lgs_ac_form "ENDFIELD                                                      \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "FIELD pselect_image                                           \n")
	fprintf( lgs_ac_form "THUMBNAIL lgs_90bends                                         \n")
	fprintf( lgs_ac_form "FLOC 4 10                                                     \n")
	fprintf( lgs_ac_form "FSIZE 9 5                                                     \n")
	fprintf( lgs_ac_form "ENDFIELD                                                      \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "TEXT \"Length\"                                               \n")
	fprintf( lgs_ac_form "FLOC 14 10                                                    \n")
	fprintf( lgs_ac_form "ENDTEXT                                                       \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "FIELD lgs_length                                              \n")
	fprintf( lgs_ac_form "FLOC 14 12                                                    \n")
	fprintf( lgs_ac_form "REALFILLIN 5 5                                                \n")
	fprintf( lgs_ac_form "REALMIN 0                                                     \n")
	fprintf( lgs_ac_form "ENDFIELD                                                      \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "FIELD lgs_loop                                                \n")
	fprintf( lgs_ac_form "FLOC 3 1                                                      \n")
	fprintf( lgs_ac_form "CHECKLIST \"Check Loop\" \"loop_degree\"                      \n")
	fprintf( lgs_ac_form "ENDFIELD                                                      \n")
	fprintf( lgs_ac_form "FIELD lgs_90degree                                            \n")
	fprintf( lgs_ac_form "FLOC 3 8                                                      \n")
	fprintf( lgs_ac_form "CHECKLIST \"Check 90 Degree\" \"loop_degree\"                 \n")
	fprintf( lgs_ac_form "ENDFIELD                                                      \n")
	fprintf( lgs_ac_form "ENDTAB                                                        \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "###############################                               \n")
	fprintf( lgs_ac_form "TAB \"Unuse\"                                             \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "FIELD pselect_image                                           \n")
	fprintf( lgs_ac_form "THUMBNAIL lgs_xtalk                                           \n")
	fprintf( lgs_ac_form "FLOC 6 0                                                      \n")
	fprintf( lgs_ac_form "FSIZE 10 5                                                    \n")
	fprintf( lgs_ac_form "ENDFIELD                                                      \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "TEXT \"EN  Spacing      Length\"                              \n")
	fprintf( lgs_ac_form "FLOC 2 5                                                      \n")
	fprintf( lgs_ac_form "ENDTEXT                                                       \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "FIELD lgs_cross_en_1                                          \n")
	fprintf( lgs_ac_form "FLOC  2 7                                                     \n")
	fprintf( lgs_ac_form "CHECKLIST \"\"                                                \n")
	fprintf( lgs_ac_form "ENDFIELD                                                      \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "FIELD lgs_cross_spacing_1                                     \n")
	fprintf( lgs_ac_form "FLOC 5 7                                                      \n")
	fprintf( lgs_ac_form "REALFILLIN 4 4                                                \n")
	fprintf( lgs_ac_form "REALMIN 0                                                     \n")
	fprintf( lgs_ac_form "ENDFIELD                                                      \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "FIELD lgs_cross_length_1                                      \n")
	fprintf( lgs_ac_form "FLOC 13 7                                                     \n")
	fprintf( lgs_ac_form "REALFILLIN 6 6                                                \n")
	fprintf( lgs_ac_form "REALMIN 0                                                     \n")
	fprintf( lgs_ac_form "ENDFIELD                                                      \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "FIELD lgs_cross_en_2                                          \n")
	fprintf( lgs_ac_form "FLOC  2 9                                                     \n")
	fprintf( lgs_ac_form "CHECKLIST \"\"                                                \n")
	fprintf( lgs_ac_form "ENDFIELD                                                      \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "FIELD lgs_cross_spacing_2                                     \n")
	fprintf( lgs_ac_form "FLOC 5 9                                                      \n")
	fprintf( lgs_ac_form "REALFILLIN 4 4                                                \n")
	fprintf( lgs_ac_form "REALMIN 0                                                     \n")
	fprintf( lgs_ac_form "ENDFIELD                                                      \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "FIELD lgs_cross_length_2                                      \n")
	fprintf( lgs_ac_form "FLOC 13 9                                                     \n")
	fprintf( lgs_ac_form "REALFILLIN 6 6                                                \n")
	fprintf( lgs_ac_form "REALMIN 0                                                     \n")
	fprintf( lgs_ac_form "ENDFIELD                                                      \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "FIELD lgs_cross_en_3                                          \n")
	fprintf( lgs_ac_form "FLOC  2 11                                                    \n")
	fprintf( lgs_ac_form "CHECKLIST \"\"                                                \n")
	fprintf( lgs_ac_form "ENDFIELD                                                      \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "FIELD lgs_cross_spacing_3                                     \n")
	fprintf( lgs_ac_form "FLOC 5 11                                                     \n")
	fprintf( lgs_ac_form "REALFILLIN 4 4                                                \n")
	fprintf( lgs_ac_form "REALMIN 0                                                     \n")
	fprintf( lgs_ac_form "ENDFIELD                                                      \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "FIELD lgs_cross_length_3                                      \n")
	fprintf( lgs_ac_form "FLOC 13 11                                                    \n")
	fprintf( lgs_ac_form "REALFILLIN 6 6                                                \n")
	fprintf( lgs_ac_form "REALMIN 0                                                     \n")
	fprintf( lgs_ac_form "ENDFIELD                                                      \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "FIELD lgs_cross_en_4                                          \n")
	fprintf( lgs_ac_form "FLOC  2 13                                                    \n")
	fprintf( lgs_ac_form "CHECKLIST \"\"                                                \n")
	fprintf( lgs_ac_form "ENDFIELD                                                      \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "FIELD lgs_cross_spacing_4                                     \n")
	fprintf( lgs_ac_form "FLOC 5 13                                                     \n")
	fprintf( lgs_ac_form "REALFILLIN 4 4                                                \n")
	fprintf( lgs_ac_form "REALMIN 0                                                     \n")
	fprintf( lgs_ac_form "ENDFIELD                                                      \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "FIELD lgs_cross_length_4                                      \n")
	fprintf( lgs_ac_form "FLOC 13 13                                                    \n")
	fprintf( lgs_ac_form "REALFILLIN 6 6                                                \n")
	fprintf( lgs_ac_form "REALMIN 0                                                     \n")
	fprintf( lgs_ac_form "ENDFIELD                                                      \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "ENDTAB                                                        \n")
	fprintf( lgs_ac_form "ENDTABSET                                                     \n")
	fprintf( lgs_ac_form "###############################                               \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "FIELD lgs_check                                               \n")
	fprintf( lgs_ac_form "FLOC 2 46                                                     \n")
	fprintf( lgs_ac_form "MENUBUTTON \"Check\" 0 3                                      \n")
	fprintf( lgs_ac_form "ENDFIELD                                                      \n")
	fprintf( lgs_ac_form "                                                              \n")
	fprintf( lgs_ac_form "FIELD lgsdone                                                 \n")
	fprintf( lgs_ac_form "FLOC 11 46                                                    \n")
	fprintf( lgs_ac_form "MENUBUTTON \"Exit\" 3 3                                       \n")
	fprintf( lgs_ac_form "ENDFIELD                                                      \n")
	fprintf( lgs_ac_form "FIELD help                                                    \n")
	fprintf( lgs_ac_form "FLOC 17 46                                                    \n")
	fprintf( lgs_ac_form "MENUBUTTON \"Help\" 1 3                                       \n")
	fprintf( lgs_ac_form "ENDFIELD                                                      \n")
	fprintf( lgs_ac_form "###############################                               \n")
	fprintf( lgs_ac_form "ENDTILE                                                       \n")
	fprintf( lgs_ac_form "ENDFORM                                                       \n")
	close( lgs_ac_form)
	lgs_ac_form = axlFormCreate( (gensym) "lgs_auto_check_form.form" '(e outer) '_lgs_ac_form_callback t)
	axlFormDisplay( lgs_ac_form)
	axlUIWPrint( lgs_ac_form "Select Object to Check.!")
);end defun _lgs_make_acform


;***************************************************************************************************************************
;	_lgs_creat_progress_formloop ()
;***************************************************************************************************************************

(defun _lgs_creat_progress_formloop ()
;let( (progress_Form)
progress_Form=outfile("lgs_progress_Form.form" "w")
fprintf(progress_Form "#Write by lgs \n")
fprintf(progress_Form "FILE_TYPE=FORM_DEFN VERSION=2\n")
fprintf(progress_Form "FORM\n")
fprintf(progress_Form "FIXED\n")
fprintf(progress_Form "PORT 45 14\n")
fprintf(progress_Form "HEADER \"Auto Check Progress V1.0\"\n")
fprintf(progress_Form "TILE\n")
fprintf(progress_Form "FIELD lgs_progress\n")
fprintf(progress_Form "FLOC 3 1\n")
fprintf(progress_Form "PROGRESS 40 3\n")
fprintf(progress_Form "ENDFIELD\n")
fprintf(progress_Form "ENDTILE\n")
fprintf(progress_Form "ENDFORM  \n")
close(progress_Form)
lgs_progress_form = axlFormCreate( (gensym) "lgs_progress_Form.form" '(e outer) '_lgs_nil t)
deleteFile( "lgs_progress_Form.form")
axlFormDisplay( lgs_progress_form)
;);end let
);end (defun _lgs_creat_progress_formloop ()

(defun _lgs_nil (lgs_progress_form)
1==1
)
;***************************************************************************************************************************
;***************************************************************************************************************************

;				LOOP CHECK FUNCTION
;			==============================

;***************************************************************************************************************************
;		_lgs_check_loop( netlist)
;***************************************************************************************************************************
(defun _lgs_check_loop ( netlist)
prog( ()
lgs_loop_errlistxy = nil
lgs_loop_errlist = nil
lgs_prog_percent = 0
foreach(lgs_temp_netname netlist

	lgs_segments = _lgs_get_net_allsegments( lgs_temp_netname)

	;------Remove Vcc Gnd---------------
	if(length( lgs_segments) > 200
	then
		lgs_segments = nil
	);end if

	axlSetFindFilter(?enabled '(noall pins vias) ?onButtons '(noall pins vias))
;--------------------------------------------------------------------------

for(i 1 length(lgs_segments)

	lgs_tempseglist = nthelem(i lgs_segments)

	for(j i+1 length(lgs_segments)

		lgs_tempseglist2 = nthelem(j lgs_segments)

		lgs_check_b = 0
		;------------------------------------------------
		foreach(lgs_tempseg lgs_tempseglist

			foreach(lgs_tempseg2 lgs_tempseglist2

				lgs_temp = _lgs_Is_Cross( lgs_tempseg lgs_tempseg2)
				if(lgs_temp != 0
				then
					lgs_check_b = lgs_check_b + car( lgs_temp)
					lgs_xy = cadr( lgs_temp)
				);

			);end foreach(lgs_tempseg2 lgs_tempseglist2
		);end for(j i+1 length(lgs_segments)
		;------------------------------------------------

		if(lgs_check_b > 1
		then
			;printf("\nError:%d\n\n" lgs_number++)
			;printf("%1.2f,%1.2f\n" car(lgs_xy) cadr(lgs_xy))

			lgs_loop_errlistxy = cons( lgs_xy lgs_loop_errlistxy)
			lgs_loop_errlist   = cons( lgs_temp_netname lgs_loop_errlist)


		);end if(lgs_check_b > 1

	);for(j i+1 length(lgs_segments)

);end for(i 1 length(lgs_segments)

;--------progress----------------------------------------------------------------

_lgs_progress(++lgs_prog_percent length( netlist))
;------------------------------------------------------------------------
);end foreach(lgs_temp_net netlist

return( list(lgs_loop_errlist lgs_loop_errlistxy))

;axlClearSelSet()
;lgs_list_mode = "err"
;axlFormSetField( lgs_ac_form "lgs_net_err" "error")
;axlFormListDeleteAll( lgs_ac_form "Err_List")
;axlFormSetField( lgs_ac_form "Err_List" lgs_errlist)

));end defun _lgs_check_loop ( netlist)

;***************************************************************************************************************************
;		_lgs_get_net_allsegments ( netname)
;***************************************************************************************************************************
(defun _lgs_get_net_allsegments ( netname)
prog( ()
	;printf("Checking Net:  %s\n" netname)
	axlSetFindFilter(?enabled '(noall nets) ?onButtons '(noall nets))
	lgs_temp_net = car(axlGetSelSet(axlSingleSelectName("NET" netname)))
	lgs_temp_segments = nil
	foreach(lgs_branch lgs_temp_net->branches
		foreach(lgs_children lgs_branch->children
		if( lgs_children->objType == "path"
			then
				lgs_temp_segments = cons(lgs_children->segments lgs_temp_segments)
			else
		  );end if( ch_children->objType == "path"
		);end foreach(ch_children ch_branch->children
	);end foreach(ch_branch ch_net->branches
return( lgs_temp_segments)
));end defun _lgs_get_net_allsegments ( netname)

;***************************************************************************************************************************
;		_lgs_Is_Cross ( point1 point2 point3 point4)
;***************************************************************************************************************************
defun( _lgs_Is_Cross ( lgs_tempseg lgs_tempseg2)
prog( ()

	point1 = car( lgs_tempseg->startEnd)
	point2 = cadr( lgs_tempseg->startEnd)
	point3 = car( lgs_tempseg2->startEnd)
	point4 = cadr( lgs_tempseg2->startEnd)


	;-------------------------------------------------------------
	x1 = car( point1)
	x2 = car( point2)
	y1 = cadr( point1)
	y2 = cadr( point2)

	x11 = car( point3)
	x22 = car( point4)
	y11 = cadr( point3)
	y22 = cadr( point4)

	;-------------------------------------------------------------
	if(max( x1 x2) < min( x11 x22) || min( x1 x2) > max( x11 x22)
	then
		return( 0)
	);end if

	if(max( y1 y2) < min( y11 y22) || min( y1 y2) > max( y11 y22)
	then
		return( 0)
	);end if
	;-------------------------------------------------------------
	if(point1 == point3
	then
		if(_lgs_is_viapin( point1)
		then
			return( 0)
		);end if(!_lgs_is_viapin( point3)
	);end if(point1 == point3

	if(point1 == point4
	then
		if(_lgs_is_viapin( point1)
		then
			return( 0)
		);end if(!_lgs_is_viapin( point1)
	);end if(point1 == point4

	if(point2 == point3
	then
		if(_lgs_is_viapin( point2)
		then
			return( 0)
		);end if(!_lgs_is_viapin( point1)
	);end if(point1 == point4

	if(point2 == point4
	then
		if(_lgs_is_viapin( point2)
		then
			return( 0)
		);end if(!_lgs_is_viapin( point1)
	);end if(point1 == point4


	if(x1 == x2
	then
		k1 = t
	else
		k1 = (1.0*y1-y2)/(x1-x2)
	);end if

	if(x11 == x22
	then
		k2 = t
	else
		k2 = (1.0*y11-y22)/(x11-x22)
	);end if

	if(k1 == k2
	then
		return( 0)
	);end if
	;-------------------------------------------------------------
	;-------------------------------------------------------------
	if(k1 == t
	then
		if(k2 == 0
		then
			;-----------------
			x = x1
			y = y11

			if((x == x11) || (x == x22) || (y == y1) || (y == y2)
			then
				return( list(1 list( x y)))
			else
				return( list(2 list( x y)))
			);end if
			;-----------------
		else
			;-----------------
			x = x1
			y = k2*x + (x11*y22 - x22*y11)/(x11 - x22)

			if(y > min( y1 y2) && y < max( y1 y2)
			then
				if((y == y1) || (y == y2) || (x == x11) || (x = x22)
				then
					return( list(1 list( x y)))
				else
					return( list(2 list( x y)))
				);end if
			else
				return( 0)
			);end if
		);end if
	);end if
	;-------------------------------------------------------------
	if(k2 == t
	then
		if(k1 == 0
		then
			;-----------------
			x = x11
			y = y1

			if((x == x1) || (x == x2) || (y == y11) || (y == y22)
			then
				return( list(1 list( x y)))
			else
				return( list(2 list( x y)))
			);end if
			;-----------------
		else
			;-----------------
			x = x11
			y = k1*x + (x1*y2 - x2*y1)/(x1 - x2)

			if(y > min( y11 y22) && y < max( y11 y22)
			then
				if((y == y1) || (y == y22) || (x == x1) || (x = x2)
				then
					return( list(1 list( x y)))
				else
					return( list(2 list( x y)))
				);end if
			else
				return( 0)
			);end if
		);end if
	);end if
	;-------------------------------------------------------------
	;-------------------------------------------------------------

	b1 = (x1*y2 - x2*y1)/(x1 - x2)
	b2 = (x11*y22 - x22*y11)/(x11 - x22)

	x = (b2 - b1)/(k1 - k2)
	y = (b2*k1 - b1*k2)/(k1 - k2)

	if( (x >= min(x1 x2)) && (x >= min(x11 x22)) && (x <= max(x1 x2)) && (x <= max(x11 x22))
	  ||(y >= min(y1 y2)) && (y >= min(y11 y22)) && (y <= max(y1 y2)) && (y <= max(y11 y22))
	then
		if((x>x1-0.1 && x<x1+0.1 && y>y1-0.1 && y<y1+0.1)
		 ||(x>x2-0.1 && x<x2+0.1 && y>y2-0.1 && y<y2+0.1)
		 ||(x>x11-0.1 && x<x11+0.1 && y>y11-0.1 && y<y11+0.1)
		 ||(x>x22-0.1 && x<x22+0.1 && y>y22-0.1 && y<y22+0.1)
		;(list(x y) == point1) || (list(x y) == point2) || (list(x y) == point3) || (list(x y) == point4)
		then
			return( list(1 list(x y)))
		else
			return( list(2 list(x y)))
		);end if
	else
		return( 0)
	);end if


));end defun( jkIs_Cross ( point1 point2 point3 point4)

;***************************************************************************************************************************
;	_lgs_is_viapin(point)		???????????????????????????????????
;***************************************************************************************************************************
(defun _lgs_is_viapin ( point)
prog( ()

return( t)

));end defun _lgs_is_viapin ( point)
;***************************************************************************************************************************
;***************************************************************************************************************************
;***************************************************************************************************************************
;		_lgs_check_90Degree( lgs_netlist)
;***************************************************************************************************************************
(defun _lgs_check_90Degree ( netlist)
prog( ()
lgs_degree_errlistxy = nil
lgs_degree_errlist = nil
lgs_prog_percent = 0

foreach(lgs_temp_netname netlist

	;printf("%s\n" lgs_temp_netname)
	lgs_segments = _lgs_get_net_allsegments( lgs_temp_netname)


	;------Remove Vcc Gnd---------------
;	if(length( lgs_segments) > 200
;	then
;		lgs_segments = nil
;	);end if
;
;--------------------------------------------------------------------------
	foreach( lgs_temp_seglist lgs_segments

		;lgs_first_times = t

		for(i 1 length(lgs_temp_seglist)-1

			if(_lgs_line_length( nthelem(i lgs_temp_seglist)) > lgs_degree_length
			then
				j = i+1
				lgs_while = t
				while( lgs_while
					if(_lgs_line_length( nthelem(j lgs_temp_seglist)) > lgs_degree_length
					then
						lgs_while = nil

					else
						if(j >= length( lgs_temp_seglist)
						then
							lgs_while = nil
							j = nil
						else
							j++
						)

					)
				);end while

				if(j != nil
				then

					lgs_temp = _lgs_Is90degree( nthelem(i lgs_temp_seglist) nthelem(j lgs_temp_seglist))
					if(lgs_temp != nil
					then
						lgs_degree_errlist = cons( lgs_temp_netname lgs_degree_errlist)
						lgs_degree_errlistxy = cons( lgs_temp lgs_degree_errlistxy)
					);end if(lgs_temp == nil

				);end if(j !=nil

			);end if(nthelem(i lgs_temp_seglist) > lgs_degree_length

		);end for(i 1 length(lgs_temp_seglist)

	);end foreach( lgs_temp_seglist lgs_segments
;--------progress----------------------------------------------------------------

_lgs_progress(++lgs_prog_percent length( netlist))
);end foreach(lgs_temp_netname netlist
return( list(lgs_degree_errlist lgs_degree_errlistxy))
));end defun _lgs_check_90Degree ( netlist)


;***************************************************************************************************************************
;		_lgs_Is90degree( nthelem(i lgs_temp_seglist) nthelem(i+1 lgs_temp_seglist))
;***************************************************************************************************************************
(defun _lgs_Is90degree ( seg1 seg2)
prog( ()
;seg1 = seg1->startEnd
;seg2 = seg2->startEnd

k1 = _lgs_k( list(cadr( seg1->startEnd) car( seg1->startEnd)))
k2 = _lgs_k( seg2->startEnd)

if(k1 == nil || k2 == nil
then
	return( cadr( seg1->startEnd))
else
	if( (max(k1 k2) - min(k1 k2)) <= 90 || (max(k1 k2) - min(k1 k2)) >= 270
	then
		return( cadr( seg1->startEnd))
	else
		return( nil)
	);end if( (max(k1 k2) - min(k1 k2)) <= 90
);end if(k1 == nil || k2 == nil


));end defun _lgs_Is90degree ( seg1 seg2)

;***************************************************************************************************************************
;		_lgs_k ( lgs_line)
;***************************************************************************************************************************

(defun _lgs_k ( line)
prog( ()
if(caar(line) == caadr(line)
then						;k = &
	if(cadadr(line) > cadar(line)
	then
		return( 90)
	else
		return( -90)
	);end if(cadar(line) > cadadr(line)
else
	if(cadar( line) == cadadr(line)
	then					;k = 0 180
		if(caadr(line) > caar(line)
		then
			return( 0)
		else
			return( 180)
		);end if
	else
		lgs_temp1 = abs( caar(line) - caadr(line))
		lgs_temp2 = abs( cadar(line) - cadadr(line))
		if(lgs_temp1 > lgs_temp2-1 || lgs_temp1 < lgs_temp2+1
		then
			if(caadr(line) > caar(line)
			then
				if(cadadr(line) > cadar(line)
				then
					return( 45)
				else
					return( -45)
				);end if
			else
				if(cadadr(line) > cadar(line)
				then
					return( 135)
				else
					return( -135)
				);end if

			);end if

		else
			return( nil)
		);end if(abs( caar(line) - caadr(line)) > abs( cadar(line) - cadadr(line)) - 1

	);end if(cadar( line) == cadadr(line)
);end if(caar(line) == caadr(line)
));end defun _lgs_k ( lgs_line)


(defun _lgs_line_length ( lgs_seg_list)
prog( ()
	lgs_seg = lgs_seg_list->startEnd

	return( expt( expt( caadr( lgs_seg) - caar( lgs_seg) 2) + expt( cadadr( lgs_seg) - cadar( lgs_seg) 2) 0.5))


))

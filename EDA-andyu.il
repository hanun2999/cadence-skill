

;changed by andyluhero 2010.09.13 增加了线压阻焊铜皮，修正PCB_out子程序 
;changed by andyluhero 2010.09.09 界面调整,增加了测试点规则，设计状态以及字符压器件体
;changed by andyluhero2010.08.18 check_border
;added subdist_module_check_function by andyluhero2010.08.12
;added check mark function by andyluhero2010.08.12
;added display introdaction of function by andyluhero2010.07.28
;changed by andyluhero 2010.07.21 changed" calc_lt_symbol_selct " and remove "testing_Hlilight_line" "testing_Hlilight" "testing_ownHlilight" "testing_text_Cross"
;changed by andyluhero 2010.07.21 added calc_lt_symbol_selct
;
;changed by andyluhero 2010.07.19 because of silimar text
;changed by andyluhero 2010.07.19 added next lines
axlShell("funckey ~b andylu")

axlCmdRegister( "andylu" `andylu)

 ; WARRANTY:
 ; NONE. NONE. NONE.
(defun andylu ()
	case(car(axlDBGetDesignUnits())
		("millimeters"  change_mil_mm_units=0.0254 change_mm_mil_units=1)
		("mils"   change_mil_mm_units=1 change_mm_mil_units=0.0254)
	)

	testing_Creat_layer()
	testing_Allcolor_set()
	time = getCurrentTime()
	time = parseString(time)
	day = nth(1 time)
	month = car(time)
	month = upperCase(month)
	year = nth(3 time)
	date = strcat(" Date: " day " " month " " year)
	form_file = "new_andy_form.form"
	CreateForm(form_file)
	myform=axlFormCreate( (gensym) form_file `(e inner) 'Form_Action t)
	axlFormSetField(myform "Combo_select_layer" "TOP")
	select_layer_flag="TOP"
	testing_turn_on_layer(select_layer_flag)
	FieldA = list("PCB\320\305\317\242" "\327\326\267\373\274\354\262\351" "\274\344\276\340\274\354\262\351" "\270\275\274\323\271\246\304\334")
	axlFormBuildPopup(myform "Combo_select_subclass" FieldA )
	axlFormSetField(myform "Combo_select_subclass" "PCB\320\305\317\242")
	subclass_flag="PCB\320\305\317\242"
	check_flag(subclass_flag)
/*
	FieldB = list("TOP"  "BOTTOM")
	axlFormBuildPopup(myform "Combo_select_layer" FieldB )
	axlFormSetField(myform "Combo_select_layer" "TOP")
*/

	axlFormDisplay(myform)
	axlUIWPrint(myform date)
	if(isFile(form_file) then
		deleteFile(form_file)
	);endif
)
 
(defun CreateForm (form_file)
	drain()
	myform = outfile(form_file "w")
	fprintf(myform "FILE_TYPE=FORM_DEFN VERSION=2\n")
	fprintf(myform "FORM AUTOGREYTEXT\n")
	fprintf(myform "FIXED\n")
	fprintf(myform "PORT 35 51\n")
	fprintf(myform "HEADER \"\271\244\322\325\274\354\262\351V2.0\"\n\n")
	;fprintf(myform "POPUP <ENUM>\"ITEM1\"\"0\",\"ITEM2\"\"1\",\"ITEM3\"\"2\",\"LAST ONE\"\"3\".\n\n")
	;fprintf(myform "POPUP <subclass>\"0\" \"0\",\"LAST ONE\" \"1\".\n\n")
	fprintf(myform "POPUP <subclass>")
	fprintf(myform "\"TOP\" \"TOP\",\"BOTTOM\" \"BOTTOM\".\n")
	fprintf(myform "POPUP <CLASS>\"item1\" \"0\",\"LAST ONE\" \"1\".\n\n")
	fprintf(myform "POPUP <CHECKMODEP>\"item1\" \"0\",\"LAST ONE\" \"1\".\n\n")	
	fprintf(myform "TILE\n\n")

	fprintf(myform "## ENUM Field in Form## \n")
	fprintf(myform "FIELD Combo_select_subclass\n")
	fprintf(myform "FLOC 1 2\n")
	fprintf(myform "STRFILLIN 11 50\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "POP \"CLASS\"\n") 
	fprintf(myform "OPTIONS multiselect prettyprint\n")
	fprintf(myform "ENDFIELD\n\n")

	fprintf(myform "## ENUM Field in Form## \n")
	fprintf(myform "FIELD Combo_select_layer\n")
	fprintf(myform "FLOC 19 2\n")
	fprintf(myform "STRFILLIN 11 50\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "POP \"subclass\"\n") 
	fprintf(myform "OPTIONS multiselect prettyprint\n")
	fprintf(myform "ENDFIELD\n\n")

	fprintf(myform "## Text Field in Form## \n")
	fprintf(myform "TEXT \n" )
	fprintf(myform "FLOC 19 5\n" )
	fprintf(myform "INFO Label_input \n" )
	fprintf(myform "FSIZE 32 20\n" )     
	fprintf(myform "ENDTEXT\n" )

	fprintf(myform "## Input Field in Form## \n")
	fprintf(myform "FIELD Input_float\n")
	fprintf(myform "FLOC 26 5\n")
	fprintf(myform "FSIZE 7 2\n")
	fprintf(myform "STRFILLIN 7 50\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "VALUE \"1.00\"\n")
	fprintf(myform "ENDFIELD \n\n\n")


	fprintf(myform "## Text Field in Form## \n")
	fprintf(myform "TEXT \n" )
	fprintf(myform "FLOC 3 5\n" )
	fprintf(myform "INFO Label_Message\n" )
	fprintf(myform "FSIZE 32 20\n" )     
	fprintf(myform "ENDTEXT\n" )

	;------------------------------pcb_message----------
	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD  module_check_flag\n")
	fprintf(myform "FLOC 3 7\n")
	fprintf(myform "CHECKLIST \"1-\321\351\326\244\304\243\260\345\"  \"PCB_message\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD standard_list_on\n")
	fprintf(myform "FLOC 20 7\n")
	fprintf(myform "CHECKLIST \"2-\316\363\262\356\261\352\327\274\"  \"PCB_message\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD bianma_on\n")
	fprintf(myform "FLOC 3 9\n")
	fprintf(myform "CHECKLIST \"3-\274\354\262\351\261\340\302\353\277\362\"  \"PCB_message\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")
	
	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD testpoints_ruler\n")
	fprintf(myform "FLOC 20 9\n")
	fprintf(myform "CHECKLIST \"4-\274\354\262\351\262\342\312\324\265\343\271\346\324\362\"  \"PCB_message\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")
	
	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD status_ruler\n")
	fprintf(myform "FLOC 3 11\n")
	fprintf(myform "CHECKLIST \"5-\274\354\262\351\327\264\314\254\300\270\"  \"PCB_message\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")
	

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD mark_check_flag\n")
	fprintf(myform "FLOC 20 11\n")
	fprintf(myform "CHECKLIST \"6-\274\354\262\351mark\265\343\"  \"PCB_message\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")
	
	fprintf(myform "## Text Field in Form## \n")
	fprintf(myform "TEXT \n" )
	fprintf(myform "FLOC 1 13\n" )
	fprintf(myform "INFO Label_PCB_PB_view\n" )
	fprintf(myform "FSIZE 5 20\n" )     
	fprintf(myform "ENDTEXT\n" )

	fprintf( myform "TEXT \n" )
	fprintf( myform "FLOC 5 13\n" )
	fprintf( myform "INFO testing_PB_view \n" )
	fprintf( myform "FSIZE 50 2\n" )     
	fprintf( myform "ENDTEXT\n" )

	fprintf(myform "## Text Field in Form## \n")
	fprintf(myform "TEXT \n" )
	fprintf(myform "FLOC 25 13\n" )
	fprintf(myform "INFO Label_PCB_PL_view\n" )
	fprintf(myform "FSIZE 5 20\n" )     
	fprintf(myform "ENDTEXT\n" )

	fprintf( myform "TEXT \n" )
	fprintf( myform "FLOC 30 13\n" )
	fprintf( myform "INFO testing_PL_view \n" )
	fprintf( myform "FSIZE 50 2\n" )     
	fprintf( myform "ENDTEXT\n" )

	fprintf(myform "## ENUM Field in Form## \n")
	fprintf(myform  "FIELD testing_PLN_view\n")
	fprintf(myform  "FLOC 25 15\n")
	fprintf(myform  "ENUMSET 6\n")
	fprintf(myform  "POP \"CHECKMODEP\"\n") 
	fprintf(myform  "ENDFIELD\n\n")


	fprintf(myform "## Text Field in Form## \n")
	fprintf(myform "TEXT \n" )
	fprintf(myform "FLOC 1 15\n" )
	fprintf(myform "INFO Label_PCB_ME_view\n" )
	fprintf(myform "FSIZE 5 20\n" )     
	fprintf(myform "ENDTEXT\n" )
	
	fprintf(myform "FIELD testing_ME_view\n")
	fprintf(myform "FLOC 5 15\n")
	fprintf(myform "STRFILLIN 16 40\n")
	fprintf(myform "ENDFIELD\n")


	fprintf(myform "## Text Field in Form## \n")
	fprintf(myform "TEXT \n" )
	fprintf(myform "FLOC 1 18\n" )
	fprintf(myform "INFO Label_PCB_out_view\n" )
	fprintf(myform "FSIZE 2 20\n" )     
	fprintf(myform "ENDTEXT\n" )

	fprintf(myform "FIELD output_list\n")
	fprintf(myform "FLOC 5 18\n")
	fprintf(myform "LIST \"\" 25 4\n")
	fprintf(myform "ENDFIELD\n")	
	

	;;------------------------------text_message----------

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD testing_text_LostRef\n")
	fprintf(myform "FLOC 3 8\n")
	fprintf(myform "CHECKLIST \"1-\327\326\267\373\266\252\312\247\"  \"andylu_form1\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD testing_text_LostPinName\n")
	fprintf(myform "FLOC 20 8\n")
	fprintf(myform "CHECKLIST \"2-1\275\305\261\352\312\266\266\252\312\247\"  \"andylu_form1\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD testing_text_Rotation\n")
	fprintf(myform "FLOC 3 10\n")
	fprintf(myform "CHECKLIST \"3-\327\326\267\373\267\275\317\362\"  \"andylu_form1\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD testing_text_same\n")
	fprintf(myform "FLOC 20 10\n")
	fprintf(myform "CHECKLIST \"4-\327\326\267\373\326\330\270\264\"  \"andylu_form1\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD testing_text_pad\n")
	fprintf(myform "FLOC 3 12\n")
	fprintf(myform "CHECKLIST \"5-\327\326\267\373\321\271\272\270\305\314\"  \"andylu_form1\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD testing_text_testpoint\n")
	fprintf(myform "FLOC 20 12\n")
	fprintf(myform "CHECKLIST \"6-\327\326\267\373\321\271\262\342\312\324\265\343\"  \"andylu_form1\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD testing_text_shape\n")
	fprintf(myform "FLOC 3 14\n")
	fprintf(myform "CHECKLIST \"7-\327\326\267\373\321\271\327\350\272\270\315\255\306\244\"  \"andylu_form1\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD testing_text_text\n")
	fprintf(myform "FLOC 20 14\n")
	fprintf(myform "CHECKLIST \"8-\327\326\267\373\321\271\327\326\267\373\"  \"andylu_form1\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD testing_text_line\n")
	fprintf(myform "FLOC 3 16\n")
	fprintf(myform "CHECKLIST \"9-\327\326\267\373\321\271\313\277\323\241\"  \"andylu_form1\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD testing_text_Via\n")
	fprintf(myform "FLOC 20 16\n")
	fprintf(myform "CHECKLIST \"10-\327\326\267\373\321\271\264\363\277\327\"  \"andylu_form1\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD testing_line_pad\n")
	fprintf(myform "FLOC 3 18\n")
	fprintf(myform "CHECKLIST \"11-\313\277\323\241\277\362\311\317\327\350\272\270\"  \"andylu_form1\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")
	
	
	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD testing_text_inside_comp\n")
	fprintf(myform "FLOC 20 18\n")
	fprintf(myform "CHECKLIST \"12-\327\326\267\373\321\271\306\367\274\376\314\345\"  \"andylu_form1\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")
	
	;;;;

	fprintf(myform "## Text Field in Form## \n")
	fprintf(myform "TEXT \n" )
	fprintf(myform "FLOC 3 20\n" )
	fprintf(myform "INFO Label_intro\n" )
	fprintf(myform "FSIZE 32 20\n" )     
	fprintf(myform "ENDTEXT\n" )

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD testing_text_Symbols\n")
	fprintf(myform "FLOC 3 22\n")
	fprintf(myform "CHECKLIST \"12-\327\326\267\373\271\330\301\252\306\367\274\376\"  \"andylu_form1\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD testing_calc_lt_symbol\n")
	fprintf(myform "FLOC 20 22\n")
	fprintf(myform "CHECKLIST \"13-\327\326\267\373\275\273\264\355\"  \"andylu_form1\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD testing_Del_Connect\n")
	fprintf(myform "FLOC 3 24\n")
	fprintf(myform "CHECKLIST \"14-\311\276\263\375\301\254\317\337\"  \"andylu_form1\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")
	;;------------------------------distance_message----------



	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD senddis_border\n")
	fprintf(myform "FLOC 3 8\n")
	fprintf(myform "CHECKLIST \"1-\264\253\313\315\261\337\276\340\300\353\"  \"andylu_form2\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD testing_shape_offset_drawing\n")
	fprintf(myform "FLOC 20 8\n")
	fprintf(myform "CHECKLIST \"2-\260\345\261\337\304\332\313\3655mm\"  \"andylu_form3\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD holedis_r5mm\n")
	fprintf(myform "FLOC 3 10\n")
	fprintf(myform "CHECKLIST \"3-\260\262\327\260\277\327\"  \"andylu_form2\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD pressdist_fit\n")
	fprintf(myform "FLOC 20 10\n")
	fprintf(myform "CHECKLIST \"4-\262\250\267\345\321\271\275\323\"  \"andylu_form2\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD subdist_check_BGA\n")
	fprintf(myform "FLOC 3 12\n")
	fprintf(myform "CHECKLIST \"5-\274\354\262\351 BGA\"  \"andylu_form2\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD via_pad\n")
	fprintf(myform "FLOC 20 12\n")
	fprintf(myform "CHECKLIST \"6-\271\375\277\327\311\317\272\270\305\314\"  \"andylu_form2\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD shape_pad\n")
	fprintf(myform "FLOC 3 14\n")
	fprintf(myform "CHECKLIST \"7-\272\270\305\314\312\265\301\254\275\323 \"  \"andylu_form2\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD pin_pad\n")
	fprintf(myform "FLOC 20 14\n")
	fprintf(myform "CHECKLIST \"8-\272\270\305\314\274\344\276\340\"  \"andylu_form2\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")	
	
	;;---------------------special_function------------------
	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD select_layer_flag_fill\n")
	fprintf(myform "FLOC 3 8\n")
	fprintf(myform "CHECKLIST \"1-\265\376\262\343\320\305\317\242\"  \"andylu_form3\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD testing_single_width\n")
	fprintf(myform "FLOC 20 8\n")
	fprintf(myform "CHECKLIST \"2-\265\245\317\337\317\337\277\355\"  \"andylu_form3\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD testing_diff_width\n")
	fprintf(myform "FLOC 3 10\n")
	fprintf(myform "CHECKLIST \"3-\262\356\267\326\317\337\277\355\"  \"andylu_form3\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD testing_oil_fill_all\n")
	fprintf(myform "FLOC 20 10\n")
	fprintf(myform "CHECKLIST \"4-\310\373\277\327\320\305\317\242\"  \"andylu_form3\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD testing_text_move_all\n")
	fprintf(myform "FLOC 3 12\n")
	fprintf(myform "CHECKLIST \"5-\322\306\266\257\320\375\327\252\327\326\267\373\"  \"andylu_form3\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD testing_output_layer\n")
	fprintf(myform "FLOC 20 12\n")
	fprintf(myform "CHECKLIST \"6-\312\344\263\366DXF\"  \"andylu_form3\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## RadioButton Field in Form## \n")
	fprintf(myform "FIELD testing_search_vias\n")
	fprintf(myform "FLOC 3 14\n")
	fprintf(myform "CHECKLIST \"7-\262\351\325\322\327\352\277\327\"  \"andylu_form3\"\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")
	;;;;---------------all----------------
	fprintf(myform "## Text Field in Form## \n")
	fprintf(myform "TEXT \n" )
	fprintf(myform "FLOC 3 26\n" )
	fprintf(myform "INFO Label_shuoming\n" )
	fprintf(myform "FSIZE 32 20\n" )     
	fprintf(myform "ENDTEXT\n" )

	fprintf(myform "## List Field in FORM ## \n")
	fprintf(myform "FIELD testing_next_view_All\n")
	fprintf(myform "FLOC 3 30\n")
	fprintf(myform "LIST \" \" 30 7\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## Button Field in FORM ## \n")
	fprintf(myform "FIELD testing_text_check\n")
	fprintf(myform "FLOC 3 45\n")
	fprintf(myform "MENUBUTTON \"\326\360\317\356\274\354\262\351\" 9 3\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## Button Field in FORM ## \n")
	fprintf(myform "FIELD testing_unselect\n")
	fprintf(myform "FLOC 12 45\n")
	fprintf(myform "MENUBUTTON \"\310\241\317\373\270\337\301\301\" 9 3\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "## Button Field in FORM ## \n")
	fprintf(myform "FIELD testing_finish\n")
	fprintf(myform "FLOC 21 45\n")
	fprintf(myform "MENUBUTTON \"\315\352\263\311\" 9 3\n")
	fprintf(myform "FGROUP \"andyluhero\"\n")
	fprintf(myform "ENDFIELD \n\n")

	fprintf(myform "ENDTILE\n\n")
	fprintf(myform "ENDFORM\n\n")

	close(myform)
)



defun( check_subclass_flag (subclass_flag)
	prog( ()
	select_function__flag=nil
		case(subclass_flag
;;;;;;;;-----------pcb_message----------
			("PCB\320\305\317\242"
				select_function__flag=0
			t
			)
;;;;;;;;-----------text_check----------			
			("\327\326\267\373\274\354\262\351"
				select_function__flag=1
			t
			)
;;;;;;;;-----------distance_check----------				
			("\274\344\276\340\274\354\262\351"
				select_function__flag=2
			t
			)
;;;;;;;;-----------special_function----------			
			("\270\275\274\323\271\246\304\334"
				select_function__flag=3
			t
			)
		)
	return(select_function__flag)
	)
)



defun( check_flag (subclass_flag)
	prog( ()
		pro_function_flag= nil
		pro_function_flag=check_subclass_flag(subclass_flag)
		if(pro_function_flag == 0 then    ;;;;;;;;-----------pcb_message----------
			function_init()
			Label_shuoming_flag= "\323\303\323\332\274\354\321\351\325\373\260\345\265\304\320\305\317\242"
			axlFormSetFieldVisible(myform "module_check_flag"     1)			
			axlFormSetField(myform "module_check_flag" module_checking_flag)	
			axlFormSetFieldVisible(myform "standard_list_on"     1)			
			axlFormSetField(myform "standard_list_on" standard_list_on_flag)
			axlFormSetFieldVisible(myform "bianma_on"     1)			
			axlFormSetField(myform "bianma_on" bianma_on_flag)	
			axlFormSetFieldVisible(myform "mark_check_flag"     1)			
			axlFormSetField(myform "mark_check_flag" mark_checking_flag)
			axlFormSetFieldVisible(myform "testpoints_ruler"     1)			
			axlFormSetField(myform "testpoints_ruler" testpoints_ruler_flag)

			axlFormSetFieldVisible(myform "status_ruler"     1)			
			axlFormSetField(myform "status_ruler" status_ruler_flag)
			axlFormSetFieldVisible(myform "Label_Message"     1)		
			axlFormSetField(myform "Label_Message"  Label_Message_flag)	
			axlFormSetFieldVisible(myform "Label_shuoming"     1)		
			axlFormSetField(myform "Label_shuoming" Label_shuoming_flag)
			axlFormSetFieldVisible(myform "Label_PCB_out_view"     1)		
			axlFormSetField(myform "Label_PCB_out_view" Label_PCB_out_view_flag)
			axlFormSetFieldVisible(myform "output_list"     1)		
			axlFormSetField(myform "output_list" output_list_flag)
			axlFormSetFieldVisible(myform "testing_ME_view"     1)		
			axlFormSetField(myform "testing_ME_view" testing_ME_view_flag)
			axlFormSetFieldVisible(myform "Label_PCB_ME_view"     1)		
			axlFormSetField(myform "Label_PCB_ME_view" Label_PCB_ME_view_flag)
			axlFormSetFieldVisible(myform "testing_PLN_view"     1)		
			axlFormSetField(myform "testing_PLN_view" testing_PLN_view_flag)
			axlFormSetFieldVisible(myform "testing_PL_view"     1)		
			axlFormSetField(myform "testing_PL_view" testing_PL_view_flag)
			axlFormSetFieldVisible(myform "Label_PCB_PL_view"     1)		
			axlFormSetField(myform "Label_PCB_PL_view" Label_PCB_PL_view_flag)
			axlFormSetFieldVisible(myform "testing_PB_view"     1)		
			axlFormSetField(myform "testing_PB_view" testing_PB_view_flag)
			axlFormSetFieldVisible(myform "Label_PCB_PB_view"     1)		
			axlFormSetField(myform "Label_PCB_PB_view" Label_PCB_PB_view_flag)
			
			;check_testing_PCB_output()
			pro_function_flag= nil
		)
		if(pro_function_flag == 1 then  ;-----------text_check--------------------
			function_init()
			Label_shuoming_flag= "\323\303\323\332\274\354\262\351\325\373\260\345\265\304\306\367\274\376\327\326\267\373\317\356"
			axlFormSetFieldVisible(myform "Input_float"     1)		
			axlFormSetField(myform "Input_float" 1.00*change_mil_mm_units)				
			axlFormSetFieldVisible(myform "testing_text_LostPinName"     1)		
			axlFormSetField(myform "testing_text_LostPinName" testing_text_LostPinName_flag)
			axlFormSetFieldVisible(myform "testing_text_LostRef"     1)			
			axlFormSetField(myform "testing_text_LostRef" testing_text_LostRef_flag)
			axlFormSetFieldVisible(myform "testing_text_Rotation"     1)			
			axlFormSetField(myform "testing_text_Rotation" testing_text_Rotation_flag)
			axlFormSetFieldVisible(myform "testing_text_same"     1)			
			axlFormSetField(myform "testing_text_same" testing_text_same_flag)
			axlFormSetFieldVisible(myform "testing_text_pad"     1)			
			axlFormSetField(myform "testing_text_pad" testing_text_pad_flag)
			axlFormSetFieldVisible(myform "testing_text_shape"     1)			
			axlFormSetField(myform "testing_text_shape" testing_text_shape_flag)
			axlFormSetFieldVisible(myform "testing_text_testpoint"     1)			
			axlFormSetField(myform "testing_text_testpoint" testing_text_testpoint_flag)
			axlFormSetFieldVisible(myform "testing_text_text"     1)			
			axlFormSetField(myform "testing_text_text" testing_text_text_flag)
			axlFormSetFieldVisible(myform "testing_text_Via"     1)			
			axlFormSetField(myform "testing_text_Via" testing_text_Via_flag)
			axlFormSetFieldVisible(myform "testing_text_line"     1)			
			axlFormSetField(myform "testing_text_line" testing_text_line_flag)
			axlFormSetFieldVisible(myform "testing_line_pad"     1)			
			axlFormSetField(myform "testing_line_pad" testing_line_pad_flag)
			axlFormSetFieldVisible(myform "testing_text_inside_comp"     1)			
			axlFormSetField(myform "testing_text_inside_comp" testing_text_inside_comp_flag)			
			axlFormSetFieldVisible(myform "testing_text_Symbols"     1)			
			axlFormSetField(myform "testing_text_Symbols" testing_text_Symbols_flag)			
			axlFormSetFieldVisible(myform "testing_calc_lt_symbol"     1)			
			axlFormSetField(myform "testing_calc_lt_symbol" testing_calc_lt_symbol_flag)
			axlFormSetFieldVisible(myform "testing_Del_Connect"     1)			
			axlFormSetField(myform "testing_Del_Connect" testing_Del_Connect_flag)
			axlFormSetFieldVisible(myform "Label_input"     1)		
			axlFormSetField(myform "Label_input" Label_input_flag)
			axlFormSetFieldVisible(myform "Label_Message"     1)		
			axlFormSetField(myform "Label_Message"  Label_Message_flag)	
			axlFormSetFieldVisible(myform "Label_intro"     1)		
			axlFormSetField(myform "Label_intro" Label_intro_flag)	
			axlFormSetFieldVisible(myform "Label_shuoming"     1)		
			axlFormSetField(myform "Label_shuoming" Label_shuoming_flag)
			pro_function_flag= nil
		)
		if(pro_function_flag == 2 then    ;-----------distance_check---------------------
			function_init()
			Label_input_flag= "\276\340\300\353(mm):"
			Label_intro_flag= "\323\303\323\332\274\354\262\351\325\373\260\345\265\304\306\367\274\376\276\340\300\353\317\356\243\254\304\277\307\260\276\340\300\353\304\307\317\356\275\366\266\324\262\250\267\345\321\271\275\323\317\356\323\320\320\247\241\243"
			axlFormSetFieldVisible(myform "Input_float"     1)		
			axlFormSetField(myform "Input_float" 5.00)	
			axlFormSetFieldVisible(myform "senddis_border"     1)
			axlFormSetField(myform "senddis_border" senddis_border_flag)
			axlFormSetFieldVisible(myform "testing_shape_offset_drawing"     1)
			axlFormSetField(myform "testing_shape_offset_drawing" testing_shape_offset_drawing_flag)
			axlFormSetFieldVisible(myform "holedis_r5mm"     1)
			axlFormSetField(myform "holedis_r5mm" holedis_r5mm_flag)
			axlFormSetFieldVisible(myform "pressdist_fit"     1)
			axlFormSetField(myform "pressdist_fit" pressdist_fit_flag)
			axlFormSetFieldVisible(myform "subdist_check_BGA"     1)
			axlFormSetField(myform "subdist_check_BGA" subdist_check_BGA_flag)
			axlFormSetFieldVisible(myform "via_pad"     1)
			axlFormSetField(myform "via_pad" via_pad_flag)
			axlFormSetFieldVisible(myform "shape_pad"     1)
			axlFormSetField(myform "shape_pad" shape_pad_flag)
			axlFormSetFieldVisible(myform "pin_pad"     1)
			axlFormSetField(myform "pin_pad" pin_pad_flag)			
			axlFormSetFieldVisible(myform "Label_input"     1)		
			axlFormSetField(myform "Label_input" Label_input_flag)
			axlFormSetFieldVisible(myform "Label_Message"     1)		
			axlFormSetField(myform "Label_Message" Label_Message_flag)	
			axlFormSetFieldVisible(myform "Label_intro"     1)		
			axlFormSetField(myform "Label_intro" Label_intro_flag)
			pro_function_flag= nil
		)
		if(pro_function_flag == 3 then ;;;;;special_function---------------
			function_init()
			Label_shuoming_flag= "\323\303\323\332\322\273\320\251\311\350\274\306\313\371\320\350\265\304\270\275\274\323\271\246\304\334"
			axlFormSetFieldVisible(myform "select_layer_flag_fill"     1)
			axlFormSetField(myform "select_layer_flag_fill" select_layer_flag_fill_flag)
			axlFormSetFieldVisible(myform "testing_single_width"     1)
			axlFormSetField(myform "testing_single_width" testing_single_width_flag)
			axlFormSetFieldVisible(myform "testing_diff_width"     1)
			axlFormSetField(myform "testing_diff_width" testing_diff_width_flag)
			axlFormSetFieldVisible(myform "testing_oil_fill_all"     1)
			axlFormSetField(myform "testing_oil_fill_all" testing_oil_fill_all_flag)
			axlFormSetFieldVisible(myform "testing_text_move_all"     1)
			axlFormSetField(myform "testing_text_move_all" testing_text_move_all_flag)
			axlFormSetFieldVisible(myform "testing_output_layer"     1)
			axlFormSetField(myform "testing_output_layer" testing_output_layer_flag)
			axlFormSetFieldVisible(myform "testing_search_vias"     1)
			axlFormSetField(myform "testing_search_vias" testing_search_vias_flag)
			axlFormSetFieldVisible(myform "Label_Message"     1)		
			axlFormSetField(myform "Label_Message" Label_Message_flag)	
			axlFormSetFieldVisible(myform "Label_shuoming"     1)		
			axlFormSetField(myform "Label_shuoming" Label_shuoming_flag)
			pro_function_flag= nil
		)
		axlFormDisplay(myform)	
	)
)
	
defun( function_init ()
	prog( ()
	;--------------text-------------
		
	testing_text_LostPinName_flag= nil
	testing_text_LostRef_flag = nil
	testing_text_Rotation_flag = nil
	testing_text_same_flag = nil
	testing_text_pad_flag = nil
	testing_text_shape_flag = nil
	testing_text_testpoint_flag = nil
	testing_text_text_flag = nil
	testing_text_Via_flag = nil
	testing_text_line_flag = nil
	testing_line_pad_flag = nil
	testing_text_Symbols_flag = nil			
	testing_calc_lt_symbol_flag = nil
	testing_Del_Connect_flag = nil
	testing_text_inside_comp_flag= nil
	
	axlFormSetFieldVisible(myform "testing_text_LostPinName"     0)		
	axlFormSetField(myform "testing_text_LostPinName" testing_text_LostPinName_flag)
	axlFormSetFieldVisible(myform "testing_text_LostRef"     0)			
	axlFormSetField(myform "testing_text_LostRef" testing_text_LostRef_flag)
	axlFormSetFieldVisible(myform "testing_text_Rotation"     0)			
	axlFormSetField(myform "testing_text_Rotation" testing_text_Rotation_flag)
	axlFormSetFieldVisible(myform "testing_text_same"     0)			
	axlFormSetField(myform "testing_text_same" testing_text_same_flag)
	axlFormSetFieldVisible(myform "testing_text_pad"     0)			
	axlFormSetField(myform "testing_text_pad" testing_text_pad_flag)
	axlFormSetFieldVisible(myform "testing_text_shape"     0)			
	axlFormSetField(myform "testing_text_shape" testing_text_shape_flag)
	axlFormSetFieldVisible(myform "testing_text_testpoint"     0)			
	axlFormSetField(myform "testing_text_testpoint" testing_text_testpoint_flag)
	axlFormSetFieldVisible(myform "testing_text_text"     0)			
	axlFormSetField(myform "testing_text_text" testing_text_text_flag)
	axlFormSetFieldVisible(myform "testing_text_Via"     0)			
	axlFormSetField(myform "testing_text_Via" testing_text_Via_flag)
	axlFormSetFieldVisible(myform "testing_text_line"     0)			
	axlFormSetField(myform "testing_text_line" testing_text_line_flag)
	axlFormSetFieldVisible(myform "testing_line_pad"     0)			
	axlFormSetField(myform "testing_line_pad" testing_line_pad_flag)
	axlFormSetFieldVisible(myform "testing_text_inside_comp"     0)			
	axlFormSetField(myform "testing_text_inside_comp" testing_text_inside_comp_flag)
	axlFormSetFieldVisible(myform "testing_text_Symbols"     0)			
	axlFormSetField(myform "testing_text_Symbols" testing_text_Symbols_flag)			
	axlFormSetFieldVisible(myform "testing_calc_lt_symbol"     0)			
	axlFormSetField(myform "testing_calc_lt_symbol" testing_calc_lt_symbol_flag)
	axlFormSetFieldVisible(myform "testing_Del_Connect"     0)			
	axlFormSetField(myform "testing_Del_Connect" testing_Del_Connect_flag)
	;-------pcb_message----------
	Label_PCB_out_view_flag= "\263\254\270\337\306\367\274\376\301\320\261\355"
	output_list_flag= nil
	testing_ME_view_flag= nil
	Label_PCB_ME_view_flag= "\263\337\264\347:"
	testing_PLN_view_flag= nil
	testing_PL_view_flag= nil
	Label_PCB_PL_view_flag= "\262\343\312\375:"
	testing_PB_view_flag= nil
	Label_PCB_PB_view_flag= "\261\340\302\353:"
	testpoints_ruler_flag= nil
	status_ruler_flag= nil
	module_checking_flag = nil	
	standard_list_on_flag = nil
	bianma_on_flag = nil	
	mark_checking_flag = nil
	Input_float_flag= 1.00
	axlFormColorize( myform "testing_PB_view" 'text 'blue )
	axlFormColorize( myform "testing_PL_view" 'text 'blue )
	axlFormColorize( myform "testing_PLN_view" 'text 'blue )
	axlFormColorize( myform "Label_PCB_ME_view" 'text 'blue )
	axlFormColorize( myform "Label_PCB_PL_view" 'text 'blue )
	axlFormColorize( myform "Label_PCB_PB_view" 'text 'blue )
	axlFormColorize( myform "Label_PCB_out_view" 'text 'blue )
	axlFormColorize( myform "testing_ME_view" 'text 'blue )
	axlFormSetFieldVisible(myform "Input_float"     0)		
	axlFormSetField(myform "Input_float" Input_float_flag)	
	axlFormSetFieldVisible(myform "module_check_flag"     0)			
	axlFormSetField(myform "module_check_flag" module_checking_flag)	
	axlFormSetFieldVisible(myform "standard_list_on"     0)			
	axlFormSetField(myform "standard_list_on" standard_list_on_flag)
	axlFormSetFieldVisible(myform "bianma_on"     0)			
	axlFormSetField(myform "bianma_on" bianma_on_flag)	
	axlFormSetFieldVisible(myform "mark_check_flag"     0)
	axlFormSetField(myform "mark_check_flag" mark_checking_flag)
	
	axlFormSetFieldVisible(myform "testpoints_ruler"     0)			
	axlFormSetField(myform "testpoints_ruler" testpoints_ruler_flag)
	
	axlFormSetFieldVisible(myform "status_ruler"     0)			
	axlFormSetField(myform "status_ruler" status_ruler_flag)
	
	axlFormSetFieldVisible(myform "Label_PCB_out_view"     0)		
	axlFormSetField(myform "Label_PCB_out_view" Label_PCB_out_view_flag)
	axlFormSetFieldVisible(myform "output_list"     0)		
	axlFormSetField(myform "output_list" output_list_flag)
	axlFormSetFieldVisible(myform "testing_ME_view"     0)		
	axlFormSetField(myform "testing_ME_view" testing_ME_view_flag)
	axlFormSetFieldVisible(myform "Label_PCB_ME_view"     0)		
	axlFormSetField(myform "Label_PCB_ME_view" Label_PCB_ME_view_flag)
	axlFormSetFieldVisible(myform "testing_PLN_view"     0)		
	axlFormSetField(myform "testing_PLN_view" testing_PLN_view_flag)
	axlFormSetFieldVisible(myform "testing_PL_view"     0)		
	axlFormSetField(myform "testing_PL_view" testing_PL_view_flag)
	axlFormSetFieldVisible(myform "Label_PCB_PL_view"     0)		
	axlFormSetField(myform "Label_PCB_PL_view" Label_PCB_PL_view_flag)
	axlFormSetFieldVisible(myform "testing_PB_view"     0)		
	axlFormSetField(myform "testing_PB_view" testing_PB_view_flag)
	axlFormSetFieldVisible(myform "Label_PCB_PB_view"     0)		
	axlFormSetField(myform "Label_PCB_PB_view" Label_PCB_PB_view_flag)	
;------------------intro----------
	
	Label_input_flag= "\306\253\262\356(mil):"
	Label_Message_flag= "--------------------\274\354\262\351\317\356--------------------------------------"
	Label_intro_flag= "----------------------\306\367\274\376\327\326\267\373\275\273\264\355\274\354\262\351--------------"
	Label_shuoming_flag= "\316\304\327\326\313\265\303\367\243\272"
	axlFormSetFieldVisible(myform "Label_input"     0)		
	axlFormSetField(myform "Label_input" Label_input_flag)
	axlFormSetFieldVisible(myform "Label_Message"     0)		
	axlFormSetField(myform "Label_Message" Label_Message_flag)	
	axlFormSetFieldVisible(myform "Label_intro"     0)		
	axlFormSetField(myform "Label_intro" Label_intro_flag)	
	axlFormSetFieldVisible(myform "Label_shuoming"     0)		
	axlFormSetField(myform "Label_shuoming" Label_shuoming_flag)	
	axlFormColorize(myform "Label_input" 'text 'red )
	axlFormColorize(myform "Label_Message" 'text 'red )
	axlFormColorize(myform "Label_intro" 'text 'red )	
	axlFormColorize(myform "Label_shuoming" 'text 'red )
	;-----------------distance_check---------------------
	senddis_border_flag= nil
	testing_shape_offset_drawing_flag= nil	
	holedis_r5mm_flag= nil	
	pressdist_fit_flag= nil
	subdist_check_BGA_flag= nil
	via_pad_flag= nil
	shape_pad_flag = nil
	pin_pad_flag = nil
	axlFormSetFieldVisible(myform "senddis_border"     0)
	axlFormSetField(myform "senddis_border" senddis_border_flag)
	axlFormSetFieldVisible(myform "testing_shape_offset_drawing"     0)
	axlFormSetField(myform "testing_shape_offset_drawing" testing_shape_offset_drawing_flag)
	axlFormSetFieldVisible(myform "holedis_r5mm"     0)
	axlFormSetField(myform "holedis_r5mm" holedis_r5mm_flag)
	axlFormSetFieldVisible(myform "pressdist_fit"     0)
	axlFormSetField(myform "pressdist_fit" pressdist_fit_flag)
	axlFormSetFieldVisible(myform "subdist_check_BGA"     0)
	axlFormSetField(myform "subdist_check_BGA" subdist_check_BGA_flag)
	axlFormSetFieldVisible(myform "via_pad"     0)
	axlFormSetField(myform "via_pad" via_pad_flag)
	axlFormSetFieldVisible(myform "shape_pad"     0)
	axlFormSetField(myform "shape_pad" shape_pad_flag)
	axlFormSetFieldVisible(myform "pin_pad"     0)
	axlFormSetField(myform "pin_pad" pin_pad_flag)	
	
;--------------------special_function---------------
	select_layer_flag_fill_flag= nil
	testing_single_width_flag= nil
	testing_diff_width_flag= nil
	testing_oil_fill_all_flag= nil
	testing_text_move_all_flag= nil
	testing_output_layer_flag= nil
	testing_search_vias_flag= nil
	axlFormSetFieldVisible(myform "select_layer_flag_fill"     0)
	axlFormSetField(myform "select_layer_flag_fill" select_layer_flag_fill_flag)
	axlFormSetFieldVisible(myform "testing_single_width"     0)
	axlFormSetField(myform "testing_single_width" testing_single_width_flag)
	axlFormSetFieldVisible(myform "testing_diff_width"     0)
	axlFormSetField(myform "testing_diff_width" testing_diff_width_flag)
	axlFormSetFieldVisible(myform "testing_oil_fill_all"     0)
	axlFormSetField(myform "testing_oil_fill_all" testing_oil_fill_all_flag)
	axlFormSetFieldVisible(myform "testing_text_move_all"     0)
	axlFormSetField(myform "testing_text_move_all" testing_text_move_all_flag)
	axlFormSetFieldVisible(myform "testing_output_layer"     0)
	axlFormSetField(myform "testing_output_layer" testing_output_layer_flag)
	axlFormSetFieldVisible(myform "testing_search_vias"     0)
	axlFormSetField(myform "testing_search_vias" testing_search_vias_flag)
;------------------------all---------------
	testing_next_view_All_flag= nil
	axlFormSetFieldVisible(myform "testing_next_view_All"     1)
	axlFormSetField(myform "testing_next_view_All" testing_next_view_All_flag)
	axlFormListDeleteAll(myform "testing_next_view_All")
	runonce_flag_testing= nil
	)
)



(defun Form_Action (myform)
(let (t1 item index field cnt)(printf "field/value %L = %L (int %L\n)" 
myform->curField myform->curValue, myform->curValueInt )
(printf "doneState %L\n" myform->doneState )
case(myform->curField
		("Combo_select_subclass"
		subclass_flag=axlFormGetField(myform "Combo_select_subclass")
		check_flag(subclass_flag)
		;Combo Field 
		;Enter Action Here
		t
		)
		("Combo_select_layer"
		;select_layer_flag=axlFormGetField(myform "Combo_select_layer")
		select_layer_flag= myform->curValue
		testing_turn_on_layer(select_layer_flag)
	
		)
		;-----------------pcb_message----------
		("module_check_flag"
			module_checking_flag = myform->curValue	
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\321\351\326\244\304\243\260\345\265\304\322\273\326\302\320\324\243\254\310\267\266\250\306\367\274\376\316\273\326\303\312\307\267\361\272\315\304\243\260\345\322\273\326\302")
			axlFormSetField( myform "Label_shuoming" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All") 
			select_layer_flag=axlFormGetField(myform "Combo_select_layer")
			subdist_module_check_function(select_layer_flag)
			module_checking_flag=nil
			axlFormSetField(myform "module_check_flag" module_checking_flag)
			t
		)
		("standard_list_on"
			standard_list_on_flag =myform->curValue
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\327\242\322\342\316\363\262\356\261\352\327\274\323\353\327\356\320\302\265\304\261\352\327\274\317\340\315\254")
			axlFormSetField( myform "Label_shuoming" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All")
			select_layer_flag=axlFormGetField(myform "Combo_select_layer")			
			subdist_check_standard_list_on(select_layer_flag)
			standard_list_on_flag= nil
			axlFormSetField(myform "standard_list_on" standard_list_on_flag)
			t
		)
		("bianma_on"
			bianma_on_flag = myform->curValue
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\261\340\302\353\277\362\262\273\304\334\321\271\327\337\317\337\243\254\264\363\277\327\243\254\327\356\272\303\265\275\261\3375mm\322\324\311\317")
			axlFormSetField( myform "Label_shuoming" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All") 
			select_layer_flag=axlFormGetField(myform "Combo_select_layer")
			subdist_check_bianma_on(select_layer_flag)
			bianma_on_flag= nil
			axlFormSetField(myform "bianma_on"  bianma_on_flag)
			t
		)
		("mark_check_flag"
			mark_checking_flag =myform->curValue
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\310\267\310\317\262\273\310\261\311\331mark\265\343\243\254mark\265\343\265\275\260\345\261\337\276\340\300\353\243\254mark\265\343\265\275\317\270\271\334\275\305\306\367\274\376\276\340\300\353")
			axlFormSetField( myform "Label_shuoming" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All") 
			select_layer_flag=axlFormGetField(myform "Combo_select_layer")
			subdist_check_mark_function(select_layer_flag)
			mark_checking_flag=nil
			axlFormSetField(myform "mark_check_flag" mark_checking_flag)
			t
		
		)
		("testpoints_ruler"
			testpoints_ruler_flag =myform->curValue
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\274\354\262\351PCB\311\350\274\306\262\342\312\324\265\343\271\346\324\362")
			axlFormSetField( myform "Label_shuoming" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All") 
			select_layer_flag=axlFormGetField(myform "Combo_select_layer")
			testing_check_testpoints_ruler()
			testpoints_ruler_flag=nil
			axlFormSetField(myform "testpoints_ruler" testpoints_ruler_flag)
			t
		
		)
		("status_ruler"
			status_ruler_flag =myform->curValue
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\274\354\262\351PCB\311\350\274\306\327\264\314\254\300\270\243\254\327\242\322\342\271\302\315\255\322\324\274\260\301\254\275\323\315\352\263\311\320\324")
			axlFormSetField( myform "Label_shuoming" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All") 
			select_layer_flag=axlFormGetField(myform "Combo_select_layer")
			testing_check_status_ruler()
			status_ruler_flag=nil
			axlFormSetField(myform "status_ruler" status_ruler_flag)
			t
		
		)
		;---------------------text_check--------------------
		("testing_text_LostRef" 
			testing_text_LostRef_flag = myform->curValue 
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\326\367\322\252\323\303\323\332\265\245\303\346\274\354\262\351\306\367\274\376\265\304\316\273\272\305\312\307\267\361\266\252\312\247")
			axlFormSetField( myform "Label_shuoming" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All")
			testing_unselect_object()
			testing_LostRef()
			testing_text_LostRef_flag=nil
			axlFormSetField(myform "testing_text_LostRef" testing_text_LostRef_flag)
		t
		)

		("testing_text_LostPinName" 
			testing_text_LostPinName_flag = myform->curValue
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\326\367\322\252\323\303\323\332\274\354\262\351\325\373\260\345\264\370\323\3201\275\305\261\352\312\266\306\367\274\376\265\304\261\352\312\266\327\326\267\373\312\307\267\361\266\252\312\247,\273\341\275\253\313\371\323\320\265\3041\275\305\261\352\312\266\270\337\301\301\243\254\262\242\275\253\310\2611\275\305\265\304\306\367\274\376\324\335\270\337\301\301\243\254\312\344\263\366\261\250\270\346")
			axlFormSetField( myform "Label_shuoming" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All")
			testing_unselect_object()  
			testing_LostPinName()
			testing_text_LostPinName_flag= nil
			axlFormSetField(myform "testing_text_LostPinName" testing_text_LostPinName_flag)
		t
		) 

		("testing_text_Rotation" 
			testing_text_Rotation_flag = myform->curValue 
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\326\367\322\252\323\303\323\332\274\354\262\351\265\245\303\346\306\367\274\376\265\304\327\326\267\373\267\275\317\362\312\307\267\361\325\375\310\267")
			axlFormSetField( myform "Label_shuoming" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All")
			testing_unselect_object()
			testing_Refdes_Direction()
			testing_text_Rotation_flag=nil
			axlFormSetField(myform "testing_text_Rotation" testing_text_Rotation_flag)
		t
		)

		("testing_text_same"
			testing_text_same_flag = myform->curValue 
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\326\367\322\252\323\303\323\332\274\354\262\351\325\373\260\345\306\367\274\376\265\304\327\326\267\373\312\307\267\361\326\330\270\264")
			axlFormSetField( myform "Label_shuoming" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All")
			testing_unselect_object()
			testing_Refdes_same()
			testing_text_same_flag=nil
			axlFormSetField(myform "testing_text_same" testing_text_same_flag)
		t
		)

		("testing_text_pad"
			testing_text_pad_flag = myform->curValue 
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\326\367\322\252\323\303\323\332\274\354\262\351\327\326\267\373\312\307\267\361\321\271\324\332\301\313\277\252\327\350\272\270\272\270\305\314")
			axlFormSetField( myform "Label_shuoming" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All")
			Input_float_flag=atof(axlFormGetField(myform "Input_float"))
			testing_unselect_object()
			testing_text_on_pad()
			testing_text_pad_flag=nil
			axlFormSetField(myform "testing_text_pad" testing_text_pad_flag)
		t
		)

		("testing_text_testpoint" 
			testing_text_testpoint_flag = myform->curValue 
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\326\367\322\252\323\303\323\332\274\354\262\351\327\326\267\373\312\307\267\361\321\271\324\332\301\313\264\370\323\320\262\342\312\324\265\343\312\364\320\324\265\304\271\375\277\327\311\317")
			axlFormSetField( myform "Label_shuoming" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All")
			Input_float_flag=atof(axlFormGetField(myform "Input_float"))
			testing_unselect_object()
			testing_text_on_testpoints()
			testing_text_testpoint_flag=nil
			axlFormSetField(myform "testing_text_testpoint" testing_text_testpoint_flag)
		t
		)

		("testing_text_shape"
			testing_text_shape_flag = myform->curValue 
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\326\367\322\252\323\303\323\332\274\354\262\351\327\326\267\373\312\307\267\361\321\271\324\332\301\313\277\252\327\350\272\270\315\255\306\244\311\317")
			axlFormSetField( myform "Label_shuoming" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All")
			Input_float_flag=atof(axlFormGetField(myform "Input_float"))
			testing_unselect_object()
			testing_text_on_shape()
			testing_text_shape_flag=nil
			axlFormSetField(myform "testing_text_shape" testing_text_shape_flag)
		t
		)

		("testing_text_text" 
			testing_text_text_flag = myform->curValue 
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\326\367\322\252\323\303\323\332\274\354\262\351\327\326\267\373\312\307\267\361\317\340\321\271")
			axlFormSetField( myform "Label_shuoming" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All")
			Input_float_flag=atof(axlFormGetField(myform "Input_float"))
			testing_unselect_object()
			testing_text_overlap_text()
			testing_text_text_flag=nil
			axlFormSetField(myform "testing_text_text" testing_text_text_flag)
		t
		)

		("testing_text_line" 
			testing_text_line_flag = myform->curValue 
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\326\367\322\252\323\303\323\332\274\354\262\351\327\326\267\373\312\307\267\361\321\271\324\332\267\307\265\347\306\370\315\370\302\347\265\304\301\254\317\337\311\317")
			axlFormSetField( myform "Label_shuoming" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All")
			Input_float_flag=atof(axlFormGetField(myform "Input_float"))
			testing_unselect_object()
			testing_text_overlap_line()
			testing_text_line_flag=nil
			axlFormSetField(myform "testing_text_line" testing_text_line_flag)
		t
		)

		("testing_text_Via" 
			testing_text_Via_flag = myform->curValue 
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\326\367\322\252\323\303\323\332\274\354\262\351\327\326\267\373\312\307\267\361\321\271\277\327\276\266\264\363\323\33240\265\304\264\363\277\327\243\250\277\274\302\307\310\373\277\327\316\312\314\342\243\251")
			axlFormSetField( myform "Label_shuoming" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All")
			Input_float_flag=atof(axlFormGetField(myform "Input_float"))
			testing_unselect_object()
			testing_text_on_Via()
			testing_text_Via_flag=nil 
			axlFormSetField(myform "testing_text_Via" testing_text_Via_flag)

		t
		)


		("testing_text_Symbols"
			testing_text_Symbols_flag = myform->curValue 
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\277\311\262\273\323\303\265\343\313\277\323\241\243\254\323\303\321\333\276\246\271\333\262\354\313\277\323\241\243\254\261\334\303\342\310\313\316\252\265\343\306\367\274\376\263\366\262\356")
			axlFormSetField( myform "Label_shuoming" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All")
			Input_float_flag=atof(axlFormGetField(myform "Input_float"))
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\325\342\317\356\277\311\304\334\320\350\322\252\274\270\267\326\326\323\243\254\307\353\311\324\265\310\241\243")
			axlUIWPrint(myform uidisplayer)
			testing_Delline()
			testing_text_lt_symbolsall()
			axlVisibleLayer( strcat("MANUFACTURING/lless 600 "  select_layer_flag) t )
			axlVisibleLayer( strcat("MANUFACTURING/lmore 600 "  select_layer_flag) t )
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "OK")
			axlUIWPrint(myform uidisplayer)
			testing_text_Symbols_flag=nil
			axlFormSetField(myform "testing_text_Symbols"  testing_text_Symbols_flag)
		t
		)
		("testing_calc_lt_symbol"
			testing_unselect_object()
			testing_calc_lt_symbol_flag=myform->curValue
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\275\253\277\362\321\241\327\326\267\373\277\311\304\334\275\273\264\355\265\304\306\367\274\376\265\343\301\301")
			axlFormSetField( myform "Label_shuoming" uidisplayer)
			allsymbolheight=nil
			allsymbolheight =sprintf(dummy , "\327\326\267\373\275\273\264\355 && \270\337\301\301" )
			axlUIWPrint(myform allsymbolheight)
			testing_calc_lt_symbol_range()
			testing_calc_lt_symbol_flag=nil
			axlFormSetField(myform "testing_calc_lt_symbol" testing_calc_lt_symbol_flag)
		t
		)

		("testing_Del_Connect"
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\311\276\263\375\301\254\317\337")
			axlFormSetField( myform "Label_shuoming" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All")
			testing_Delline()
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "OK")
			axlUIWPrint(myform uidisplayer)
			testing_Del_Connect_flag=nil
			axlFormSetField(myform "testing_Del_Connect" testing_Del_Connect_flag)
		t
		)
		("testing_line_pad"
			testing_line_pad_flag= myform->curValue
			uidisplayer=sprintf(dummy , "\274\354\262\351\313\277\323\241\277\362\324\332\327\350\272\270\311\317")
			axlFormSetField( myform "Label_shuoming" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All") 
			Input_float_flag=atof(axlFormGetField(myform "Input_float"))
			testing_check_line_on_pad()
			testing_line_pad_flag=nil
			axlFormSetField(myform "testing_line_pad" testing_line_pad_flag)

		t
		)
			("testing_text_inside_comp"
			testing_text_inside_comp_flag= myform->curValue
			uidisplayer=sprintf(dummy , "\274\354\262\351\327\326\267\373\277\311\304\334\324\332\306\367\274\376\314\345\304\332")
			axlFormSetField( myform "Label_shuoming" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All") 
			Input_float_flag=atof(axlFormGetField(myform "Input_float"))
			testing_check_text_inside_comp()
			testing_text_inside_comp_flag=nil
			axlFormSetField(myform "testing_text_inside_comp" testing_text_inside_comp_flag)

		t
		)	
;----------------distance_check---------------------
		("holedis_r5mm"
		holedis_r5mm_flag = myform->curValue
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\273\346\326\306\263\3665mm\272\3153.5mm\265\304\277\325\274\344\243\254\305\320\266\317\320\241\323\3320805\265\304\265\347\310\335\243\254\264\271\326\261\267\275\317\3624\243\254\306\275\320\320\267\275\317\3622.5\243\254\264\363\323\3320805C\265\304\302\372\327\343\264\271\326\261\267\275\317\3625\243\254\306\275\320\320\267\275\317\3623.5\243\254\264\363\323\3321210\265\304\265\347\310\33510mm\243\254\276\247\325\361\316\25210mm\243\254BGA3mm")
			axlFormSetField( myform "Label_intro" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All")
			Input_float_flag=atof(axlFormGetField(myform "Input_float"))
			subdist_check_mount_hole()
			holedis_r5mm_flag=nil
			axlFormSetField(myform "holedis_r5mm" holedis_r5mm_flag)
		t
		)

		("senddis_border"
		senddis_border_flag= myform->curValue 
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\261\310\275\317\263\337\264\347\243\254\310\267\266\250\264\253\313\315\261\337\272\315\267\307\264\253\313\315\261\337\243\254\262\242\275\253\274\354\262\351\260\345\261\3375mm\304\332\312\307\267\361\323\320\314\371\306\254\306\367\274\376")
			axlFormSetField( myform "Label_intro" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All")
			Input_float_flag=atof(axlFormGetField(myform "Input_float"))
			subdist_check_send_border() 
			senddis_border_flag=nil
			axlFormSetField(myform "senddis_border" senddis_border_flag)
		t
		)

		("pressdist_fit"
			pressdist_fit_flag= myform->curValue
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\273\346\326\306\263\3665mm\265\304\277\325\274\344\243\254\262\242\266\324\306\367\274\376\265\275\262\345\327\260\277\327\265\304\276\340\300\353\275\370\320\320\261\310\275\317\243\254\266\324\262\273\327\3435mm\265\304\306\367\274\376\315\250\271\375\261\250\270\346\312\344\263\366\243\254\264\363\323\3321210\265\304\265\347\310\335\322\252\302\372\327\34310mm")
			axlFormSetField( myform "Label_intro" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All") 
			case(car(axlDBGetDesignUnits())
				("millimeters" Input_float_flag=atof(axlFormGetField(myform "Input_float")))
				("mils"  Input_float_flag=atof(axlFormGetField(myform "Input_float"))/change_mm_mil_units)
			)
			/*
						case(car(axlDBGetDesignUnits())
				("millimeters"  change_mil_mm_units=0.0254 change_mm_mil_units=1 Input_float_flag=atof(axlFormGetField(myform "Input_float")))
				("mils"   change_mil_mm_units=1 change_mm_mil_units=0.0254 Input_float_flag=atof(axlFormGetField(myform "Input_float"))/change_mm_mil_units)
			)
			*/
			Input_float_flag=atof(axlFormGetField(myform "Input_float"))/change_mm_mil_units
			subdist_check_pressfit(Input_float_flag)
			pressdist_fit_flag=nil
			axlFormSetField(myform "pressdist_fit" pressdist_fit_flag)
		t
		)

		("via_pad"
			via_pad_flag= myform->curValue 
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\271\375\277\327\324\332\272\270\305\314\311\317")
			axlFormSetField( myform "Label_intro" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All")
			Input_float_flag=atof(axlFormGetField(myform "Input_float"))
			subdist_check_via_on_pad()
			via_pad_flag=nil
			axlFormSetField(myform "via_pad" via_pad_flag)
		t
		) 


		("subdist_check_BGA"
			subdist_check_BGA_flag= myform->curValue
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\273\346\326\306\263\3662.5mm\265\304\277\325\274\344\243\254\262\242\266\324\306\367\274\376\265\275BGA\261\337\265\304\276\340\300\353\275\370\320\320\261\310\275\317\243\254\266\324\262\273\327\3432.5mm\265\304\306\367\274\376\315\250\271\375\261\250\270\346\312\344\263\366")
			axlFormSetField( myform "Label_intro" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All") 
			Input_float_flag=atof(axlFormGetField(myform "Input_float"))
			subdist_check_BGA_range()
			subdist_check_BGA_flag=nil
			axlFormSetField(myform "subdist_check_BGA" subdist_check_BGA_flag)
		t
		) 

		("shape_pad"
			shape_pad_flag = myform->curValue
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\274\354\262\351\306\367\274\376\312\307\267\361\266\324\263\306\301\254\275\323")
			axlFormSetField( myform "Label_intro" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All") 
			Input_float_flag=atof(axlFormGetField(myform "Input_float"))
			subdist_check_thermal_on_pad()
			shape_pad_flag=nil
			axlFormSetField(myform "shape_pad" shape_pad_flag)

		t
		)
		("pin_pad"
			pin_pad_flag = myform->curValue
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\274\354\262\351\272\270\305\314\272\270\305\314\276\340\300\353\262\273\320\241\323\332\271\244\322\325\271\346\267\266")
			axlFormSetField( myform "Label_intro" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All") 
			Input_float_flag=atof(axlFormGetField(myform "Input_float"))
			testing_check_pin_range()
			pin_pad_flag=nil
			axlFormSetField(myform "pin_pad" pin_pad_flag)

		t
		)		
		("testing_shape_offset_drawing"
			testing_shape_offset_drawing_flag = myform->curValue
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\273\346\326\306\263\3665mm\265\304\277\325\274\344\243\254\305\320\266\317\320\241\323\3320805\265\304\267\342\327\260\265\304\265\347\310\335\243\254\264\271\326\261\267\275\317\3624\243\254\306\275\320\320\267\275\317\3622.5\243\254\264\363\323\3320805C\265\304\302\372\327\343\264\271\326\261\267\275\317\3625\243\254\306\275\320\320\267\275\317\3623.5\243\254\264\363\323\3321210\265\304\320\350\302\372\327\34310mm\243\254\276\247\325\361\316\25210mm\243\254BGA\302\372\327\3435mm\243\254mark\265\3435mm")
			axlFormSetField( myform "Label_intro" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All") 
			Input_float_flag=atof(axlFormGetField(myform "Input_float"))
			shape_offset_drawing() 
			testing_shape_offset_drawing_flag=nil
			axlFormSetField(myform "testing_shape_offset_drawing" testing_shape_offset_drawing_flag)
		t
		)

;------------special_function------------------

		("select_layer_flag_fill"
			select_layer_flag_fill_flag = myform->curValue
			axlFormListDeleteAll(myform "testing_next_view_All") 
			select_layer_flag_fill_list() 
			select_layer_flag_fill_flag=nil
			axlFormSetField(myform "select_layer_flag_fill" select_layer_flag_fill_flag)
		t
		)

		("testing_single_width"
			testing_single_width_flag = myform->curValue
			axlFormListDeleteAll(myform "testing_next_view_All") 
			testing_single_fill() 
			testing_single_width_flag= nil
			axlFormSetField(myform "testing_single_width" testing_single_width_flag)
		t
		)

		("testing_diff_width"
			testing_diff_width_flag = myform->curValue
			axlFormListDeleteAll(myform "testing_next_view_All") 
			testing_diff_fill() 
			testing_diff_width_flag=nil
			axlFormSetField(myform "testing_diff_width" testing_diff_width_flag)
		t
		)
		("testing_oil_fill_all"
			testing_oil_fill_all_flag = myform->curValue
			axlFormListDeleteAll(myform "testing_next_view_All") 
			testing_oil_fill() 
			testing_oil_fill_all_flag=nil
			axlFormSetField(myform "testing_oil_fill_all" testing_oil_fill_all_flag)
		t
		)
		("testing_text_move_all"
			testing_text_move_all_flag = myform->curValue
			axlFormListDeleteAll(myform "testing_next_view_All") 
			testing_move_function() 
			testing_text_move_all_flag=nil
			axlFormSetField(myform "testing_text_move_all" testing_text_move_all_flag)
		t
		)
		("testing_output_layer"
			testing_output_layer_flag = myform->curValue
			uidisplayer=nil
			axlFormSetField( myform "Label_shuoming" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All") 
			testing_output_DXF_layer() 
			testing_output_layer_flag=nil
			axlFormSetField(myform "testing_output_layer" testing_output_layer_flag)
		t
		)
		("testing_search_vias"
			testing_search_vias_flag= myform->curValue
			uidisplayer=nil
			uidisplayer=sprintf(dummy ,"\262\351\325\322\314\330\312\342\265\304\271\375\277\327\243\254\273\341\314\370\265\275\265\332\322\273\270\366\277\327\265\304\316\273\326\303\243\254\262\242\275\253\277\327\265\343\301\301")
			axlFormSetField( myform "Label_shuoming" uidisplayer)
			axlFormListDeleteAll(myform "testing_next_view_All") 
			testing_search_vias_hilight() 
			testing_search_vias_flag=nil
			axlFormSetField(myform "testing_search_vias" testing_search_vias_flag)
		t
		)

;-----------------all------------------	
		("Input_float"
			Input_float_flag = myform->curValue
			t
		)
		("testing_unselect"
			uidisplayer=nil
			axlFormSetField( myform "Label_shuoming" uidisplayer)
			testing_unselect_object()
			allsymbolheight=nil
			allsymbolheight =sprintf(dummy , "\310\241\317\373\313\371\323\320\270\337\301\301" )
			axlUIWPrint(myform allsymbolheight)
			t
		)
		("testing_text_check"
			pro_function_flag= nil		
			subclass_flag=axlFormGetField(myform "Combo_select_subclass")
			pro_function_flag=check_subclass_flag(subclass_flag)
			if(pro_function_flag== 1 then
				uidisplayer=nil
				uidisplayer=sprintf(dummy , "\325\342\317\356\277\311\304\334\320\350\322\252\274\270\267\326\326\323\243\254\307\353\311\324\265\310\241\243")
				axlUIWPrint(myform uidisplayer)
				axlFormListDeleteAll(myform "testing_next_view_All")
				check_text_over_item()
				t
			)
			/*
			if(pro_function_flag== 2 then
				axlFormListDeleteAll(myform "testing_next_view_All")
				subdist_checkitem_to_symbols() 
			t
			)
			*/
			if(pro_function_flag== 0 then
				axlFormListDeleteAll(myform "testing_next_view_All")
				axlFormListDeleteAll(myform "output_list")
				check_testing_PCB_output()
				check_sumlength=0
				check_i=0
				check_height_extract()
				check_board_height_extract()
				allsymbolheight=nil
				allsymbolheight =sprintf(dummy , "\327\334\271\262  %d/%d  \323\320\270\337\266\310"  check_i check_sumlength)
				axlUIWPrint(myform allsymbolheight)
				testing_turn_on_layer(select_layer_flag)
				axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
				axlUIWUpdate(nil)
				axlUIWRedraw(nil)
			t
			)
			
		t
		)

		("testing_finish"
			axlFormClose(myform)
			axlCancelEnterFun()
			if(isFile(form_file) deleteFile(form_file));endif
			axlMsgPut("Done")
			testing_Delline()
			if(isFile("./setColor.scr")	deleteFile("./setColor.scr"));endif
		t
		)
		("testing_next_view_All"
			pro_function_flag= nil		
			subclass_flag=axlFormGetField(myform "Combo_select_subclass")
			pro_function_flag=check_subclass_flag(subclass_flag)
			if(pro_function_flag== 2 then
				testing_next_view_All=strcat(myform->curValue)
				lst = parseString(testing_next_view_All ";")
				dist_refdes = sprintf(dummy " %s" nthelem(1 lst))
				x = atoi(nthelem(2 lst))
				y = atoi(nthelem(3 lst))
				axlUIWPrint(myform dist_refdes)
				units=car(axlDBGetDesignUnits())	
				if( (units=="mils") then	    window_buffer = 400 rectx=10)
				if( (units=="millimeters") then    window_buffer = 10 rectx=0.25)
				axlSetFindFilter(?enabled '(components) ?onButtons '(components))
				if(rexMatchp("MARK"  dist_refdes)||rexMatchp("SB"  dist_refdes) then
					axlWindowBoxSet(list(x-window_buffer:y-window_buffer x+window_buffer:y+window_buffer))
					axlSetFindFilter(?enabled '( symbols ) ?onButtons '( symbols ))
					if(axlSingleSelectBox(list(x-rectx:y-rectx x+rectx:y+rectx))!=nil then
						axlHighlightObject(axlGetSelSet()))
				else
					Component=axlGetSelSet(axlSingleSelectName("COMPONENT"  parseString(testing_next_view_All ";")))
					Lower_X=car(car(car(Component)->symbol->bBox))-window_buffer
					Lower_Y=car(cdr(car(car(Component)->symbol->bBox)))-window_buffer
					Upper_X=car(car(cdr(car(Component)->symbol->bBox)))+window_buffer
					Upper_Y=car(cdr(car(cdr(car(Component)->symbol->bBox))))+window_buffer
					axlWindowBoxSet(list(Lower_X:Lower_Y Upper_X:Upper_Y))
					axlUIWPrint(myform dist_refdes)
				)
			)
			if(pro_function_flag== 1 then
				testing_view_all=strcat(myform->curValue)
				units=car(axlDBGetDesignUnits())	
				if( (units=="mils") then
					viewx = 400
					viewy = 300
					rectx=20
				)
				if( (units=="millimeters") then
					viewx = 10
					viewy = 7.5
					rectx=0.5	
				)
				lst = parseString(testing_view_all ";")
				refdes = sprintf(dummy " %s" nthelem(1 lst))
				x = atoi(nthelem(2 lst))
				y = atoi(nthelem(3 lst))
				axlUIWPrint(myform refdes)
				axlWindowBoxSet(list(x-viewx:y-viewy x+viewx:y+viewy))
				axlSetFindFilter(?enabled '( text ) ?onButtons '( text ))
				allboxes=nil
				andyluhero=0
				if(axlSingleSelectBox(list(x-rectx:y-rectx x+rectx:y+rectx))!=nil then
					allboxes = axlGetSelSet()
					foreach(txtitem allboxes 
						if(txtitem->objType=="text" then 
							axlHighlightObject(txtitem)
						else 
							axlHighlightObject(txtitem)
						)
					)
				)
			)
		t
		)
		("output_list"
			axlSetFindFilter(?enabled '(components) ?onButtons '(components))
			Component=axlGetSelSet(axlSingleSelectName("COMPONENT" strcat(myform->curValue)))
			compsymbol=car(Component)->symbol
			axlHighlightObject(compsymbol)
			units=car(axlDBGetDesignUnits())	
			if( (units=="mils") then	    window_buffer = 500)
			if( (units=="millimeters") then    window_buffer = 12.5)
			Lower_X=car(car(car(Component)->symbol->bBox))-window_buffer
			Lower_Y=car(cdr(car(car(Component)->symbol->bBox)))-window_buffer
			Upper_X=car(car(cdr(car(Component)->symbol->bBox)))+window_buffer
			Upper_Y=car(cdr(car(cdr(car(Component)->symbol->bBox))))+window_buffer
			axlWindowBoxSet(list(Lower_X:Lower_Y Upper_X:Upper_Y))
			units=car(axlDBGetDesignUnits())	
			if( (units=="mils") then
			change_mil_mm_units=0.0254)
			if( (units=="millimeters") then
			change_mil_mm_units=0.9999)
			foreach(shapeitem compsymbol->children
				if(shapeitem->layer=strcat("PACKAGE GEOMETRY/PLACE_BOUND_" select_layer_flag) then
					place_bound_text = axlDBGetProperties(shapeitem)
					foreach(prop place_bound_text
						propS=symbolToString(car(prop))															
						if( (propS=="PACKAGE_HEIGHT_MAX") then
							select_compheight=car(cdr(prop))
							select_comp_height_check= select_compheight
							select_comp_height_check= car(linereadstring(select_comp_height_check))
							select_comp_height_check=select_comp_height_check*change_mil_mm_units
							checkheight_location =sprintf(dummy , "%s %s %0.2f %s" , compsymbol->refdes , "\270\337\266\310\312\307" , select_comp_height_check, "mm")
						)
					)
				) ;end of if(shapeitem
			);end of compsymbol->children
			axlUIWPrint(myform checkheight_location)
			axlFlushDisplay()
		t	
		) 
		axlFormDisplay(myform)
		axlFlushDisplay()	
	)
)

if((nequal myform->doneState 0)
axlFormClose(myform))
)

;;;--------------检查编码框是否符合规范---------

(defun subdist_check_bianma_on (select_layer_flag)
	prog(()
		axlClearSelSet()
		subdist_cnt=0
		bianma_item=car(axlSelectByName("SYMTYPE" "BARCODE"))
		if(bianma_item->isMirrored==nil then
		select_layer_flag="TOP"
		else
		select_layer_flag="BOTTOM"
		)
		testing_turn_on_layer(select_layer_flag) 
		axlVisibleLayer(strcat("VIA CLASS/"  select_layer_flag)  t)
		axlVisibleLayer(strcat("etch/"  select_layer_flag)  t)
		axlClearSelSet()
		bianma_x=car(bianma_item->xy)
		bianma_y=cadr(bianma_item->xy)
		clearancesmall=130*change_mil_mm_units
		clearance=445*change_mil_mm_units
		if(abs(bianma_item->rotation - 0.0) < 5.0 || abs(bianma_item->rotation - 180.0) < 5.0|| abs(bianma_item->rotation - 360.0) < 5.0  then
			left = bianma_x-clearance
			top = bianma_y+clearancesmall
			right = bianma_x+clearance
			bottom = bianma_y-clearancesmall
		else
			left = bianma_x-clearancesmall
			top = bianma_y+clearance
			right = bianma_x+clearancesmall
			bottom = bianma_y-clearance
		)
		bianma_box=list(left:bottom right:top)
		outline_flag=nil
		cline_flag=nil
		via_flag=nil
		symbol_flag=nil
		allboxes=nil
		error_list=nil
		string_list=nil
		;axlDBCreateRectangle(list(left:top right:bottom), nil ,"PACKAGE GEOMETRY/Display_Bottom")
		axlSetFindFilter( ?enabled '( "NOALL" "components" "clines" "vias")  ?onButtons '( "NOALL" "components" "lines" "clines" "vias") ) 
		if(axlSingleSelectBox(bianma_box)!=nil then
			allboxes= axlGetSelSet()
			axlClearSelSet()
			cline_flag=nil
			via_flag=nil
			symbol_flag=nil
			stard_via_dia=15*change_mil_mm_units
			foreach(itemline allboxes
				if(itemline->objType=="path" then
					;axlHighlightObject(itemline)
					cline_flag=t
				)
				if(itemline->objType=="component" then
					;axlHighlightObject(itemline)
					symbol_flag=t
				)
				if(itemline->objType=="via" && itemline->testPoint != nil || 
				itemline->objType=="via" && itemline->definition->drillDiameter>=stard_via_dia then
					;axlHighlightObject(itemline)
					via_flag=t
				)
				if(cline_flag==t then
					;if(itemline->net->name!=nil then
						error_list=cons(sprintf(dummy "\261\340\302\353\277\362\321\271\315\255\317\337 %s" itemline->net->name) error_list)
					;)
					cline_flag=nil
				)
				if(via_flag==t then
					;if(itemline->name!=nil then
						error_list=cons(sprintf(dummy "\261\340\302\353\277\362\321\271\277\327 %s" itemline->name) error_list)
					;)
					via_flag=nil
				)
				if(symbol_flag==t then
					;if(itemline->name1=nil then
						error_list=cons(sprintf(dummy "\261\340\302\353\277\362\321\271\306\367\274\376 %s" itemline->name) error_list)
					;)
					symbol_flag=nil
				)
			)
		)
		clearancesmall=330*change_mil_mm_units
		clearance=645*change_mil_mm_units
		if(abs(bianma_item->rotation - 0.0) < 5.0 || abs(bianma_item->rotation - 180.0) < 5.0|| abs(bianma_item->rotation - 360.0) < 5.0  then
			left = bianma_x-clearance
			top = bianma_y+clearancesmall
			right = bianma_x+clearance
			bottom = bianma_y-clearancesmall
		else
			left = bianma_x-clearancesmall
			top = bianma_y+clearance
			right = bianma_x+clearancesmall
			bottom = bianma_y-clearance
		)
		bianma_box_2=list(left:bottom right:top)
		outline_flag=nil
		cline_flag=nil
		via_flag=nil
		symbol_flag=nil
		allboxes=nil
		;axlDBCreateRectangle(list(left:top right:bottom), nil ,"PACKAGE GEOMETRY/Display_Bottom")
		axlSetFindFilter( ?enabled '( "NOALL"  "lines" "shapes")  ?onButtons '( "NOALL" "lines" "shapes") ) 
		if(axlSingleSelectBox(bianma_box_2)!=nil then
			allboxes= axlGetSelSet()
			axlClearSelSet()
			outline_flag=nil
			foreach(itemline allboxes
				if(itemline->layer=="BOARD GEOMETRY/OUTLINE" then
					;axlHighlightObject(itemline)
					outline_flag=t
				)
				
				if(outline_flag==t then
					error_list=cons( "\265\275\260\345\261\337\262\273\327\3435mm." error_list)
					outline_flag=nil
					)
			)
		)

		error_list=testing_justice_list(error_list)
		error_list=remdq(nil error_list)
		subdist_cnt=length(error_list)
		testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 1 \317\356: \274\354\262\351\261\340\302\353\277\362:\271\262  %d  \317\356" subdist_cnt)
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		testing_next_view_All=error_list
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		if(subdist_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\261\340\302\353\277\362"  subdist_cnt)
		axlUIWPrint(myform uidisplayer)
		axlWindowBoxSet(bianma_box_2)
		axlUIWRedraw(nil)
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)
		t	
	)
)
;;;--------------检查标准是否符合最新规范 ---------
(defun subdist_check_standard_list_on (select_layer_flag)
    prog( ()
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\265\376\262\343\320\305\317\242\275\370\320\320\326\320")
		axlUIWPrint(myform uidisplayer)
		axlClearSelSet()
		write_location_x=0
		write_location_y=0
		axlVisibleDesign(nil)
		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:BOARD GEOMETRY/paramLayer:DIMENSION" ))
		Going_On->visible=t
		axlSetParam(Going_On)
		text_list=nil
		axlSetFindFilter(?enabled '("noall"  "text" ) ?onButtons '("noall"  "text" ))
		text_list = axlGetSelSet(axlAddSelectAll())
		axlClearSelSet()
		ddetx=0
		ddety=0
		foreach(textitem text_list
			if(rexMatchp("^Q/ZX"  textitem->text)  then
				textitemxy=textitem->xy
				textitem_left=car(nthelem(1 textitem->bBox))
				textitem_top=cadr(nthelem(1 textitem->bBox))
				;ddety=1778*change_mil_mm_units
				;ddetx=685.8*change_mil_mm_units
				textblock=textitem->textBlock
				write_location_x_ori=textitem_left
				write_location_y_ori=textitem_top
				write_sTxtBlock=textblock
			)	
		)
		testing_turn_on_layer(select_layer_flag) 
		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:BOARD GEOMETRY/paramLayer:DIMENSION" ))
		Going_On->visible=t
		axlSetParam(Going_On)
			 axlUIWRedraw(nil)
		axlUIWUpdate(nil)
			case(car(axlDBGetDesignUnits())	
				("millimeters" view = 37.5    )
				("mils" view = 1500  ))
		axlWindowBoxSet(list(write_location_x_ori-view:write_location_y_ori-view write_location_x_ori+view:write_location_y_ori+view))
		axlClearSelSet()
			  axlUIWRedraw(nil) 
		 uidisplayer=nil
		uidisplayer=sprintf(dummy , "\316\363\262\356\261\352\327\274\323\246\270\303\316\252\"00419\""  )
		axlUIWPrint(myform uidisplayer)
		axlClearSelSet()
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)
		t
	)
)
;;;--------------检查mark点 ---------
(defun subdist_check_mark_function (select_layer_flag)
	prog(()
		axlClearSelSet()
		subdist_cnt=0
		all_comp_list=nil
		testing_turn_on_layer(select_layer_flag)
		axlSetFindFilter(?enabled '(noall symbols) ?onButtons '(noall symbols))
		if(select_layer_flag=="TOP" then 
			all_comp_list=axlGetSelSet(axlAddSelectAll())
			foreach( compitem  all_comp_list
				if(compitem->isMirrored==t then
					all_comp_list=remove(compitem all_comp_list)
				)
			)
				all_comp_list=remdq(nil all_comp_list)	
		else
			all_comp_list=axlGetSelSet(axlAddSelectAll())

			foreach( compitem  all_comp_list
				if(compitem->isMirrored==nil then
					all_comp_list=remove(compitem all_comp_list)
				)
			)
			
		)
		all_comp_list=remdq(nil all_comp_list)
		axlClearSelSet()
		mark_list=nil
		foreach(symitem  all_comp_list
			if(rexMatchp("^MARK" upperCase(symitem->name)) then
			mark_list=cons(symitem mark_list)
			)
		)
		mark_num=length(mark_list)
		error_list=nil
		foreach(mark_item mark_list
			axlHighlightObject(mark_item t)
			mark_item_xy=mark_item->xy
			mark_item_box=mark_item->bBox
			item_box_x_dist=abs(car(nthelem(2 mark_item_box))-car(nthelem(1 mark_item_box)))
			item_box_y_dist=abs(cadr(nthelem(2 mark_item_box))-cadr(nthelem(1 mark_item_box)))
			if(mark_item->name=="MARK1R0" then
				min_radius=min(item_box_x_dist item_box_y_dist)/2-23*change_mil_mm_units
			else
				min_radius=min(item_box_x_dist item_box_y_dist)/2-6*change_mil_mm_units
			)
			mark_item_box_new=list((car(mark_item_xy)-min_radius):(cadr(mark_item_xy)-min_radius) (car(mark_item_xy)+min_radius):(cadr(mark_item_xy)+min_radius))
			mark_item_box_5mm=list((car(mark_item_xy)-196.84*change_mil_mm_units):(cadr(mark_item_xy)-196.84*change_mil_mm_units) (car(mark_item_xy)+196.84*change_mil_mm_units):(cadr(mark_item_xy)+196.84*change_mil_mm_units))
			axlVisibleLayer(strcat("VIA CLASS/"  select_layer_flag)  t)
			axlVisibleLayer(strcat("etch/"  select_layer_flag)  t)
			outline_flag=nil
			cline_flag=nil
			via_flag=nil
			symbol_flag=nil
			allboxes=nil
			string_list=nil
			;axlDBCreateRectangle(mark_item_box_new nil "PACKAGE GEOMETRY/SILKSCREEN_TOP")
			axlSetFindFilter( ?enabled '( "NOALL" "symbols" "lines"  "clines" "vias")  ?onButtons '( "NOALL" "symbols" "lines" "clines" "vias") ) 
			if(axlSingleSelectBox(mark_item_box_new)!=nil then
				allboxes= axlGetSelSet()
				axlClearSelSet()
				cline_flag=nil
				via_flag=nil
				symbol_flag=nil
				stard_via_dia=15.35*change_mil_mm_units
				subdist_clearance=4*change_mil_mm_units
				foreach(itemline allboxes
					if(itemline->objType=="path" then
						foreach(child_item itemline->segments
							if(axlAirGap(child_item car(mark_item->pins) strcat( "ETCH/" select_layer_flag))!=nil && nthelem(3 axlAirGap(child_item car(mark_item->pins) strcat( "ETCH/" select_layer_flag)))<min_radius then
							cline_flag=t
							)
						)
					)
					if(itemline!=mark_item && itemline->objType=="symbol" then
						foreach(child_item itemline->pins
							if(axlAirGap(child_item car(mark_item->pins) strcat( "ETCH/" select_layer_flag))!=nil && nthelem(3 axlAirGap(child_item car(mark_item->pins) strcat( "ETCH/" select_layer_flag)))<min_radius then
								println(nthelem(3 axlAirGap(child_item car(mark_item->pins) strcat( "ETCH/" select_layer_flag))))
								symbol_flag=t
							)
						)
					)
					if(itemline->parent!=mark_item && itemline->objType=="via" && itemline->testPoint != nil || 
					itemline->parent!=mark_item && itemline->objType=="via" && abs(itemline->definition->drillDiameter-stard_via_dia)<=2*change_mil_mm_units then 
						if(axlAirGap(itemline car(mark_item->pins) strcat( "ETCH/" select_layer_flag))!=nil && nthelem(3 axlAirGap(itemline car(mark_item->pins) strcat( "ETCH/" select_layer_flag)))<min_radius then
						via_flag=t
						)
					)
					if(cline_flag==t then
						if(itemline->net->name!=nil then
							error_list=cons(sprintf(dummy "mark\265\343\321\271\315\255\317\337 %s" itemline->net->name) error_list)
						axlHighlightObject(itemline)
						)
						cline_flag=nil
					)
					if(via_flag==t then
						if(itemline->name!=nil then
							error_list=cons(sprintf(dummy "mark\265\343\321\271\277\327 %s" itemline->name) error_list)
							axlHighlightObject(itemline)
							
						)
						via_flag=nil
					)
					if(symbol_flag==t then
						if(itemline->refdes!=nil then
							error_list=cons(sprintf(dummy "mark\265\343\321\271\306\367\274\376 %s" itemline->refdes) error_list)
							axlHighlightObject(itemline)
						)
						symbol_flag=nil
					)
				)
			)
			axlClearSelSet()
			axlSetFindFilter( ?enabled '( "NOALL"  "lines" "shapes")  ?onButtons '( "NOALL" "lines" "shapes") ) 
			if(axlSingleSelectBox(mark_item_box_5mm)!=nil then
				allboxes= axlGetSelSet()
				axlClearSelSet()
				outline_flag=nil
				foreach(itemline allboxes
					if(itemline->layer=="BOARD GEOMETRY/OUTLINE" then
						outline_flag=t
					)
					
					if(outline_flag==t then
						error_list=cons( "\265\275\260\345\261\337\262\273\327\3435mm." error_list)
						outline_flag=nil
					)
				)

			)
		)
		error_list=testing_justice_list(error_list)
		error_list=remdq(nil error_list)
		subdist_cnt=length(error_list)
		testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 6 \317\356: \274\354\262\351mark\265\343:\271\262  %d  \317\356" subdist_cnt)
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		testing_next_view_All=sprintf(dummy, "\270\303\303\346\327\334\271\262\323\320 %d \270\366mark\265\343" mark_num)
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		testing_next_view_All=error_list
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		if(subdist_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\261\340\302\353\277\362"  subdist_cnt)
		axlUIWPrint(myform uidisplayer)
		axlUIWRedraw(nil)
		axlClearSelSet()
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)
		t
	)
)
;;;--------------验证模板是否符合 ---------

procedure(subdist_module_check_function(select_layer_flag)
	prog( ()
		testing_turn_on_layer(select_layer_flag)  
		axlClearSelSet()
		subdist_Delete_object()
		testing_unselect_object()
		andy_Etch_Layers=(axlGetParam("paramLayerGroup:ETCH")->groupMembers)
		layersum=length(andy_Etch_Layers)
		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:BOARD GEOMETRY/paramLayer:ASSEMBLY_DETAIL" ))
		Going_On->visible=t
		axlSetParam(Going_On)
		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:BOARD GEOMETRY/paramLayer:DIMENSION" ))
		Going_On->visible=t
		axlSetParam(Going_On)
		axlUIWRedraw(nil)
		axlClearSelSet()
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)
		t
	)
)
;;;--------------删除2层的线或shape---------
(defun subdist_Delete_object ()
	(let ()
		axlClearSelSet()
		axlVisibleDesign(nil)
		axlVisibleLayer("PACKAGE GEOMETRY/DISPLAY_Bottom"  t)
		axlVisibleLayer("PACKAGE GEOMETRY/DISPLAY_TOP"  t)
		axlSetFindFilter(?enabled '(noall lines shapes) ?onButtons '(noall lines shapes))
		deletelinelist=axlGetSelSet(axlAddSelectAll())
		axlDeleteObject(deletelinelist)
		axlClearSelSet()
		testing_turn_on_layer(select_layer_flag)
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)
	)
)
;;;--------------取消高亮---------
(defun testing_unselect_object ()
	(let (allsel)
		axlClearSelSet()
		axlSetFindFilter(?enabled '(noall lines pins vias text linesegs shapes lines) ?onButtons '(noall lines pins vias text linesegs shapes lines))
		; axlSetFindFilter(?enabled '(all) ?onButtons '(all))
		allsel = axlGetSelSet(axlAddSelectAll())
		;axlDehighlightObject(allsel)
		axlClearSelSet()
		axlSetFindFilter(?enabled '(noall symbols) ?onButtons '(noall symbols))
		allsel = axlGetSelSet(axlAddSelectAll())
		axlClearSelSet()
		Design = axlDBGetDesign()
		symbolslist = Design->symbols
		netslist= Design ->nets
		functionlist=Design ->functions
		pinlist= Design ->pins
		foreach( Item  symbolslist axlDehighlightObject(Item t) )
		;  foreach( Item  netslist 	axlDehighlightObject(Item t) )
		foreach( Item  functionlist axlDehighlightObject(Item t) )
		foreach( Item  pinlist	axlDehighlightObject(Item t) )
	)
)
;;;--------------输出PCB信息；PCB编码，板长宽，叠层信息 ---------
(defun check_testing_PCB_output ()
	Design = axlDBGetDesign()
	Design_name=Design->prop->SCHEMATIC_NAME
	;axlFormSetField(myform "testing_DN_view" Design_name)
	testing_bianma_check()
	testing_Mech_check()
	select_layer_flag_check()
	;testing_text_check()
	axlFormDisplay(myform)
	axlFlushDisplay()
	testing_turn_on_layer(select_layer_flag) 
	main_check_show()
	axlUIWUpdate(nil)
	axlUIWRedraw(nil)
)
;;;;;;;;;;;;;;;;;;;;;;;
;钻孔层显示
; input : no output : no
;;;;;;;;;;;;;;;;;;;;;;;



procedure(main_check_show()
	prog( ()
		andy_Etch_Layers=(axlGetParam("paramLayerGroup:ETCH")->groupMembers)
		layersum=length(andy_Etch_Layers)
		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:BOARD GEOMETRY/paramLayer:DIMENSION" ))
		Going_On->visible=t
		axlSetParam(Going_On)
		;  Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:BOARD GEOMETRY/paramLayer:ASSEMBLY_DETAIL" ))
		;  Going_On->visible=t
		;  axlSetParam(Going_On)
		unless( axlIsVisibleLayer( "MANUFACTURING/NCdrill_Legend")
			Going_On=axlGetParam("paramLayerGroup:MANUFACTURING/paramLayer:NCdrill_Legend"  )
			Going_On->visible=t
			axlSetParam(Going_On)
		)
		unless( axlIsVisibleLayer( "MANUFACTURING/NCdrill_Figure")
			Going_On=axlGetParam("paramLayerGroup:MANUFACTURING/paramLayer:NCdrill_Figure"  )
			Going_On->visible=t
			axlSetParam(Going_On)
		)
		if(axlIsLayer(strcat("MANUFACTURING/NClegend-1-" concat(layersum)))== t then
			unless( axlIsVisibleLayer(strcat("MANUFACTURING/NClegend-1-" concat(layersum)))
				Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:MANUFACTURING/paramLayer:NClegend-1-%s"  concat(layersum)))
				Going_On->visible=t
				axlSetParam(Going_On)
			)
		)
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)
		axlClearSelSet()
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;检验编码
; input : no output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_bianma_check ()
	prog( ()
		axlVisibleDesign(t)
		axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t)
		axlSetFindFilter(?enabled '("noall"  "text" ) ?onButtons '("noall"  "text" ))
		text_list = axlGetSelSet(axlAddSelectAll())
		axlClearSelSet()
		list_out=nil
		standard_name=axlDBGetDesign()->prop->SCHEMATIC_NAME
		foreach(textitem text_list
			if(textitem ->layer=="BOARD GEOMETRY/SILKSCREEN_TOP" || textitem ->layer=="BOARD GEOMETRY/SILKSCREEN_BOTTOM" || 
			textitem ->layer=="ETCH/TOP" || textitem ->layer=="ETCH/BOTTOM"  then
				if(rexMatchp("R6$"  upperCase(textitem->text)) ||rexMatchp("R5$"  upperCase(textitem->text)) then
					;println(textitem->text)
					list_out=textitem->text
					axlFormSetField(myform "testing_PB_view" textitem->text)
				)

			)
		)
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;检验输出叠层
; input : no output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun select_layer_flag_check ()
	prog( ()
	testing_Etch_Layers=(axlGetParam("paramLayerGroup:ETCH")->groupMembers)
	layersum=length(testing_Etch_Layers)
	axlFormSetField(myform "testing_PL_view" layersum)
;	axlFormSetField(myform "CHECKMODEP" "0")
	FieldA = testing_Etch_Layers
	axlFormBuildPopup( myform "testing_PLN_view" FieldA )
	axlFormSetField(myform "testing_PLN_view" "TOP")
	
))
;;;;;;;;;;;;;;;;;;;;;;;
;检验整板字体的大小，输出
; input : no output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_text_check ()
	prog( ()
		axlVisibleDesign(t)
		axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t)
		axlSetFindFilter(?enabled '("noall"  "text" ) ?onButtons '("noall"  "text" ))
		text_list = axlGetSelSet(axlAddSelectAll())
		axlClearSelSet()
		textBlock_list=nil
		foreach(textitem text_list
			if(textitem ->layer=="BOARD GEOMETRY/SILKSCREEN_TOP" || textitem ->layer=="BOARD GEOMETRY/SILKSCREEN_BOTTOM" || 
			textitem ->layer=="ETCH/TOP" || textitem ->layer=="ETCH/BOTTOM" || textitem ->layer=="PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" 
			|| textitem ->layer=="PACKAGE GEOMETRY/SILKSCREEN_TOP" || textitem ->layer=="REF DES/SILKSCREEN_TOP" ||
			textitem ->layer=="REF DES/SILKSCREEN_BOTTOM"  then
				textBlock_list=cons(textitem ->textBlock textBlock_list)
			)
		)
		textBlock_list=testing_justice_list(textBlock_list)
		textBlock_list=remdq(nil textBlock_list)
		axlFormSetField(myform "testing_text_view" textBlock_list)
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;输出没有重复项的子程序
; input : list output : list
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_justice_list (list)
	prog(()
		subdist_i=1
		midstrc=nil
		midlist=nil
		fulllist=nil
		length_list=length(list)
		while((subdist_i<=length_list)
			midstrc=nthelem(subdist_i list)
			midlist=remove(midstrc  list)
			list=cons(midstrc midlist)
			subdist_i++
		)
		fulllist=reverse(remdq(nil list))
		return(fulllist)
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;输出PCB板尺寸
; input : no output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_Mech_check ()
    prog( ()
		axlVisibleDesign(nil)
		axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t)
		axlSetFindFilter(?enabled '("noall"  "shapes" "linesegs") ?onButtons '("noall" "shapes" "linesegs" ))
		shapeline_segments = axlGetSelSet(axlAddSelectAll())
		testing_segments=nil
		foreach(item shapeline_segments
			if(item->objType="shape" then
					testing_segments=append(item->segments testing_segments))
			if(item->objType="line" then
					testing_segments=cons(item testing_segments)
			)
		)
		testing_segments=remdq(nil testing_segments)  
		testing_sumlength=length(testing_segments)
		if(testing_sumlength>9 then 
			list_out=nil
			sprintf(list_out , " %s " ,"\277\311\304\334\312\307\322\354\320\315\260\345\243\254\320\350\322\252\274\323\306\264\260\345")
			axlUIWPrint(myform list_out)
		else
			list_out=nil
			sprintf(list_out , " %s " ,"\262\273\312\307\322\354\320\315\260\345\243\254\310\267\310\317\264\253\313\315\261\337")
			axlUIWPrint(myform list_out)
		)
		axlClearSelSet()
		segitem_xlist=nil
		segitem_ylist=nil
		check_units=0
		units=0
		detx=1.00
		dety=1.00
		units=car(axlDBGetDesignUnits())	
		if( (units=="mils") then
			check_units=0.0254)
		if( (units=="millimeters") then
			check_units=1)
			if(testing_segments!=nil then 
			minx=car(nthelem(1 testingfind_getmax_min(testing_segments)))
			miny=cadr(nthelem(1 testingfind_getmax_min(testing_segments)))
			maxx=car(nthelem(2 testingfind_getmax_min(testing_segments)))
			maxy=cadr(nthelem(2 testingfind_getmax_min(testing_segments)))
			detx=abs(maxx-minx)*check_units
			dety=abs(maxy-miny)*check_units
		)
		checkmil_units=0
		units=0
		units=car(axlDBGetDesignUnits())	
		if( (units=="mils") then
			checkmil_units=1)
		if( (units=="millimeters") then
		checkmil_units=0.0254)
		axlVisibleDesign(nil)
		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:BOARD GEOMETRY/paramLayer:DIMENSION" ))
		Going_On->visible=t
		axlSetParam(Going_On)
		axlSetFindFilter(?enabled '("noall"  "text" ) ?onButtons '("noall"  "text" ))
		text_list = axlGetSelSet(axlAddSelectAll())
		axlClearSelSet()
		getbox=nil
		thickness=nil
		ddetx=0
		ddety=0
		foreach(textitem text_list
			if(rexMatchp("Board Thickness"  textitem->text) then
				textitem_right=car(nthelem(2 textitem->bBox))
				textitem_bottom=cadr(nthelem(2 textitem->bBox))
				ddetx=2000*checkmil_units
				ddety=200*checkmil_units
				allboxes =nil
				getbox=list(textitem_right:textitem_bottom-ddety textitem_right+ddetx:textitem_bottom+ddety)
				axlSetFindFilter(?enabled '("noall"  "text" ) ?onButtons '("noall"  "text" ))
				if(axlSingleSelectBox(getbox) != nil then
					allboxes = axlGetSelSet() 
					axlClearSelSet()
					foreach(item allboxes 
						if(rexMatchp("^[0-9]"  item ->text) then
							thickness=item ->text
						)
					)
				
				)

			)
		)
		list_out=nil
		sprintf(list_out , "%0.2f%s%0.2f%s%s" ,detx ,"X", dety, "X", thickness )
		axlFormSetField(myform "testing_ME_view" list_out)
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))	
	)
)



/*

(defun testing_Mech_check ()
    prog( ()
		axlVisibleDesign(nil)
		axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t)
		axlSetFindFilter(?enabled '("noall"  "shapes" "linesegs") ?onButtons '("noall" "shapes" "linesegs" ))
		shapeline_segments = axlGetSelSet(axlAddSelectAll())
		testing_segments=nil
		foreach(item shapeline_segments
			if(item->objType="shape" then
				testing_segments=append(item->segments testing_segments))
			if(item->objType="line" then
				testing_segments=cons(item testing_segments)
			)
		)
		testing_segments=remdq(nil testing_segments)  
		testing_sumlength=length(testing_segments)
		if(testing_sumlength>9 then 
			list_out=nil
			sprintf(list_out , " %s " ,"\277\311\304\334\312\307\322\354\320\315\260\345\243\254\320\350\322\252\274\323\306\264\260\345")
			axlUIWPrint(myform list_out)
		else
			list_out=nil
			sprintf(list_out , " %s " ,"\262\273\312\307\322\354\320\315\260\345\243\254\310\267\310\317\264\253\313\315\261\337")
			axlUIWPrint(myform list_out)
		)
		axlClearSelSet()
		segitem_xlist=nil
		segitem_ylist=nil
		if(testing_segments!=nil then 
			minx=car(nthelem(1 testingfind_getmax_min(testing_segments)))
			miny=cadr(nthelem(1 testingfind_getmax_min(testing_segments)))
			maxx=car(nthelem(2 testingfind_getmax_min(testing_segments)))
			maxy=cadr(nthelem(2 testingfind_getmax_min(testing_segments)))
			detx=abs(maxx-minx)*change_mil_mm_units
			dety=abs(maxy-miny)*change_mil_mm_units
		)
		axlVisibleDesign(nil)
		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:BOARD GEOMETRY/paramLayer:DIMENSION" ))
		Going_On->visible=t
		axlSetParam(Going_On)
		axlSetFindFilter(?enabled '("noall"  "text" ) ?onButtons '("noall"  "text" ))
		text_list = axlGetSelSet(axlAddSelectAll())
		axlClearSelSet()
		getbox=nil
		thickness=nil
		ddetx=0
		ddety=0
		foreach(textitem text_list
			if(rexMatchp("Board Thickness"  textitem->text) then
				textitem_right=car(nthelem(2 textitem->bBox))
				textitem_bottom=cadr(nthelem(2 textitem->bBox))
				ddetx=800*change_mil_mm_units
				ddety=400*change_mil_mm_units
				allboxes =nil
				getbox=list(textitem_right:textitem_bottom-ddety textitem_right+ddetx:textitem_bottom+ddety)
				axlSetFindFilter(?enabled '("noall"  "text" ) ?onButtons '("noall"  "text" ))
				if(axlSingleSelectBox(getbox) != nil then
					allboxes = axlGetSelSet() 
							axlClearSelSet()
					foreach(item allboxes 
						if(rexMatchp("^[0-9]"  item ->text) then
							thickness=item ->text
							;println(item->text)
							)
						)
				)

			)
		)
		list_out=nil
		sprintf(list_out , "%0.2f%s%0.2f%s%s" ,detx ,"X", dety, "X", thickness )
		axlFormSetField(myform "testing_ME_view" list_out)
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))	
	)
)
*/
;;;;;;;;;;;;;;;;;;;;;;;
;取得最大最小值子程序
; input : （testing_segments）list output : list
;;;;;;;;;;;;;;;;;;;;;;;
(defun testingfind_getmax_min (testing_segments)
	(prog ()
		segitem_xlist=nil
		segitem_ylist=nil
		foreach(segitem testing_segments
			segitem_startend=segitem ->startEnd
			startx=car(nthelem(1 segitem_startend))
			starty=cadr(nthelem(1 segitem_startend))
			endx=car(nthelem(2 segitem_startend))
			endy=cadr(nthelem(2 segitem_startend))
			segitem_xlist=cons( startx  segitem_xlist)
			segitem_xlist=cons( endx  segitem_xlist)
			segitem_ylist=cons( starty  segitem_ylist)
			segitem_ylist=cons( endy  segitem_ylist)
		)
		segitem_xlist=remdq(nil segitem_xlist)
		segitem_ylist=remdq(nil segitem_ylist)
		segitem_xlist=sort(segitem_xlist  'lessp)
		segitem_ylist=sort(segitem_ylist  'lessp)
		min_x=car(segitem_xlist)
		min_y=car(segitem_ylist)
		segitem_xlist=sort(segitem_xlist  'greaterp)
		segitem_ylist=sort(segitem_ylist  'greaterp)
		max_x=car(segitem_xlist)
		max_y=car(segitem_ylist)
		return(list(min_x:min_y max_x:max_y))   
	)
)

;;;;;;;;;;;;;;;;;;;;;;;
;判别整板禁布
; input : no output : no
;;;;;;;;;;;;;;;;;;;;;;;
/*
(defun check_board_height_extract ()
	axlClearSelSet()
	axlUIWPrint(myform "Please Wait....")
	axlVisibleDesign(nil)
	axlVisibleLayer(strcat("PACKAGE GEOMETRY/PLACE_BOUND_" select_layer_flag) t)
	;axlVisibleLayer(strcat("PACKAGE KEEPOUT/" select_layer_flag) t)
	;axlVisibleLayer("PACKAGE KEEPOUT/ALL" t)

	axlSetFindFilter(?enabled '(noall shapes) ?onButtons '(noall shapes))
	shape_db_list = axlGetSelSet(axlAddSelectAll())
	foreach( htext_db shape_db_list
		place_bound_text = axlDBGetProperties(htext_db)
		htext_layer=htext_db->layer
		parent = htext_db->parent
		if( parent==nil && place_bound_text!= nil then
			foreach(prop place_bound_text
				propS=symbolToString(car(prop))
				if(propS then														
					if( propS=="PACKAGE_HEIGHT_MIN" then
						compheight_check=car(cdr(prop))
						compheight_check= car(linereadstring(compheight_check))
						compheight_check=compheight_check*change_mm_mil_units
						hl_height=compheight_check
						list_out=nil
						if( htext_layer== strcat("PACKAGE GEOMETRY/PLACE_BOUND_" select_layer_flag) then
							sprintf(list_out , "%s %0.2f %s" , strcat(select_layer_flag "\303\346\317\336\270\337\270\337\266\310\312\307") , hl_height, "mm")
							axlFormSetField(myform "check_select_layer_flag" select_layer_flag)	
							axlFormSetField(myform "testing_next_view_All" list_out)
							axlFormDisplay(myform)
						)
						check_print_height(htext_db->bBox)
					)
				)
			)
		)
	) 
)
*/

(defun check_board_height_extract ()
	axlClearSelSet()
	axlUIWPrint(myform "Please Wait....")
	axlVisibleDesign(nil)
	axlVisibleLayer(strcat("PACKAGE GEOMETRY/PLACE_BOUND_" select_layer_flag) t)
	;axlVisibleLayer(strcat("PACKAGE KEEPOUT/" select_layer_flag) t)
	;axlVisibleLayer("PACKAGE KEEPOUT/ALL" t)
	 
	axlSetFindFilter(?enabled '(noall shapes) ?onButtons '(noall shapes))
	shape_db_list = axlGetSelSet(axlAddSelectAll())
	check_units=0
	units=0
	units=car(axlDBGetDesignUnits())	
	if( (units=="mils") then
		check_units=0.0254)
	if( (units=="millimeters") then
		check_units=0.9999)

	foreach( htext_db shape_db_list
		place_bound_text = axlDBGetProperties(htext_db)
		htext_layer=htext_db->layer
		parent = htext_db->parent
		if( parent==nil && place_bound_text!= nil then
			foreach(prop place_bound_text
				propS=symbolToString(car(prop))
				if(propS then														
					if( propS=="PACKAGE_HEIGHT_MIN" then
						compheight_check=car(cdr(prop))
						compheight_check= car(linereadstring(compheight_check))
						compheight_check=compheight_check*check_units
						hl_height=compheight_check
						list_out=nil
						if( htext_layer== strcat("PACKAGE GEOMETRY/PLACE_BOUND_" select_layer_flag) then
							sprintf(list_out , "%s %0.2f %s" , strcat(select_layer_flag "\303\346\317\336\270\337\270\337\266\310\312\307") , hl_height, "mm")
							axlFormSetField(myform "check_select_layer_flag" select_layer_flag)	
							axlFormSetField(myform "testing_next_view_All" list_out)
							axlFormDisplay(myform)
						)
						check_print_height(htext_db->bBox)
					)
				)
			)
		)
	) 
)


;;;;;;;;;;;;;;;;;;;;;;;
;判别局部禁布
; input : no output : no
;;;;;;;;;;;;;;;;;;;;;;;
/*
(defun check_height_extract ()
	axlUIWPrint(myform "Please Wait....")
	axlClearSelSet()
	axlVisibleDesign(nil)
	axlVisibleLayer(strcat("PACKAGE KEEPOUT/" select_layer_flag) t)
	axlVisibleLayer("PACKAGE KEEPOUT/ALL" t)
	axlSetFindFilter(?enabled '(noall shapes) ?onButtons '(noall shapes))
	shape_db_list = axlGetSelSet(axlAddSelectAll())
	foreach( htext_db shape_db_list
		place_bound_text = axlDBGetProperties(htext_db)
		htext_layer=htext_db->layer
		parent = htext_db->parent
		if( place_bound_text!= nil then
			foreach(prop place_bound_text
				propS=symbolToString(car(prop))
				if(propS then														
					if( propS=="PACKAGE_HEIGHT_MIN" then
						compheight_check=car(cdr(prop))
						compheight_check= car(linereadstring(compheight_check))
						compheight_check=compheight_check*change_mm_mil_units
						hl_height=compheight_check
						list_out=nil
						if( htext_layer== strcat("PACKAGE KEEPOUT/" select_layer_flag) || htext_layer== "PACKAGE KEEPOUT/ALL"  then
							sprintf(list_out , "%s %0.2f %s" , "\275\373\262\274\307\370\317\336\270\337\270\337\266\310\312\307" , hl_height ,"mm")
							axlFormSetField(myform "check_select_layer_flag" select_layer_flag)	
							axlFormSetField(myform "testing_next_view_All" list_out)
							axlFormDisplay(myform)
						)
						axlVisibleLayer(strcat("PACKAGE GEOMETRY/PLACE_BOUND_" select_layer_flag) t)
						check_print_height(htext_db->bBox)
					)
				)
			)
		)
	) 
)
*/
(defun check_height_extract ()
	axlUIWPrint(myform "Please Wait....")
	axlClearSelSet()
	axlVisibleDesign(nil)
	axlVisibleLayer(strcat("PACKAGE KEEPOUT/" select_layer_flag) t)
	axlVisibleLayer("PACKAGE KEEPOUT/ALL" t)
	axlSetFindFilter(?enabled '(noall shapes) ?onButtons '(noall shapes))
	shape_db_list = axlGetSelSet(axlAddSelectAll())
	check_units=0
	units=0
	units=car(axlDBGetDesignUnits())	
	if( (units=="mils") then
		check_units=0.0254)
	if( (units=="millimeters") then
		check_units=0.9999)
	foreach( htext_db shape_db_list
		place_bound_text = axlDBGetProperties(htext_db)
		htext_layer=htext_db->layer
		parent = htext_db->parent
		if( place_bound_text!= nil then
			foreach(prop place_bound_text
				propS=symbolToString(car(prop))
				if(propS then														
					if( propS=="PACKAGE_HEIGHT_MIN" then
						compheight_check=car(cdr(prop))
						compheight_check= car(linereadstring(compheight_check))
						compheight_check=compheight_check*check_units
						hl_height=compheight_check
						list_out=nil
						if( htext_layer== strcat("PACKAGE KEEPOUT/" select_layer_flag) || htext_layer== "PACKAGE KEEPOUT/ALL"  then
							sprintf(list_out , "%s %.01f %s" , "\275\373\262\274\307\370\317\336\270\337\270\337\266\310\312\307" , hl_height ,"mm")
							axlFormSetField(myform "check_select_layer_flag" select_layer_flag)	
							axlFormSetField(myform "testing_next_view_All" list_out)
							axlFormDisplay(myform)
						)
						axlVisibleLayer(strcat("PACKAGE GEOMETRY/PLACE_BOUND_" select_layer_flag) t)
						check_print_height(htext_db->bBox)
					)
				)
			)
		)
	) 
)
;;;;;;;;;;;;;;;;;;;;;;;
;判别整板器件高度与禁布区大小比较
; input : checkhei_box output : no
;;;;;;;;;;;;;;;;;;;;;;;
/*
(defun check_print_height (checkhei_box)
	prog( (ht_list hilite_list)
		axlSetFindFilter(?enabled '( noall shapes) ?onButtons '( noall shapes))
		if(axlSingleSelectBox(checkhei_box) != nil then
			allboxes = axlGetSelSet()
			axlClearSelSet()
			check_sumlength=0
			check_sumlength=length(allboxes)
			check_i=0
			foreach( text_db allboxes
				text_layer = text_db->layer
				place_bound_text = axlDBGetProperties(text_db)
				refdes = text_db->parent->refdes
				if( refdes!=nil && place_bound_text!= nil then
					foreach(prop place_bound_text
						propS=symbolToString(car(prop))															
						if( (propS=="PACKAGE_HEIGHT_MAX") then
							check_i++
							sym_compheight=car(cdr(prop))
							sym_comp_height= sym_compheight
							sym_comp_height = car(linereadstring(sym_comp_height))
							sym_comp_height =sym_comp_height*change_mm_mil_units
							if(sym_comp_height> hl_height then
								checkheight_location =sprintf(dummy , "%s %s %0.2f %s" , refdes , "\270\337\266\310\312\307" , sym_comp_height, "mm")
								axlHighlightObject(text_db->parent t)
								hilite_list = cons(refdes hilite_list)
								ht_list = cons(checkheight_location ht_list)	
							) ; end if
						);end if
					) ; end of if
				) ; 
			)
			axlFormSetField(myform "testing_next_view_All" ht_list)
			axlFormSetField(myform "output_list" hilite_list)
			if(hilite_list==nil then
				axlFormSetField(myform "testing_next_view_All" "\316\264\267\242\317\326\263\254\270\337\306\367\274\376!")
			)
			axlFormDisplay(myform)
			axlFlushDisplay()
		)
	)
)
*/

(defun check_print_height (checkhei_box)
	prog( (ht_list hilite_list)
		axlSetFindFilter(?enabled '( noall shapes) ?onButtons '( noall shapes))
		if(axlSingleSelectBox(checkhei_box) != nil then
			allboxes = axlGetSelSet()
			axlClearSelSet()
			check_units=0
			units=0
			units=car(axlDBGetDesignUnits())	
			if( (units=="mils") then
				check_units=0.0254)
			if( (units=="millimeters") then
				check_units=0.9999)
			check_sumlength=0
			check_sumlength=length(allboxes)
			check_i=0
			foreach( text_db allboxes
				text_layer = text_db->layer
					place_bound_text = axlDBGetProperties(text_db)
					refdes = text_db->parent->refdes
					if( refdes!=nil && place_bound_text!= nil then
								foreach(prop place_bound_text
							propS=symbolToString(car(prop))															
							if( (propS=="PACKAGE_HEIGHT_MAX") then
									check_i++
									sym_compheight=car(cdr(prop))
											sym_comp_height= sym_compheight
							sym_comp_height = car(linereadstring(sym_comp_height))
							sym_comp_height =sym_comp_height*check_units
								if(sym_comp_height> hl_height then
								checkheight_location =sprintf(dummy , "%s %s %.01f %s" , refdes , "\270\337\266\310\312\307" , sym_comp_height, "mm")
									  axlHighlightObject(text_db->parent t)
								hilite_list = cons(refdes hilite_list)
									  ht_list = cons(checkheight_location ht_list)	
								) ; end if
								);end if
						  
						) ; end of if
					) ; end of if
				)
					axlFormSetField(myform "testing_next_view_All" ht_list)
					axlFormSetField(myform "output_list" hilite_list)
				if(hilite_list==nil then 
					axlFormSetField(myform "testing_next_view_All" "\316\264\267\242\317\326\263\254\270\337\306\367\274\376!")
				)
				axlFormDisplay(myform)
				axlFlushDisplay()
		)
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;生成4层子程序
; input : nox output : no
;;;;;;;;;;;;;;;;;;;;;;;
;--------creat layer---------
defun( testing_Creat_layer () 
unless( axlIsLayer( "MANUFACTURING/lless 600 TOP")
		axlMsgPut("Creating Layer MANUFACTURING/lless 600 TOP")
		axlLayerCreateNonConductor("MANUFACTURING/lless 600 TOP")
	)
unless( axlIsLayer( "MANUFACTURING/lmore 600 TOP")
		axlMsgPut("Creating Layer MANUFACTURING/lmore 600 TOP")
		axlLayerCreateNonConductor("MANUFACTURING/lmore 600 TOP")
	)
unless( axlIsLayer( "MANUFACTURING/lless 600 BOTTOM")
		axlMsgPut("Creating Layer MANUFACTURING/lless 600 BOTTOM")
		axlLayerCreateNonConductor("MANUFACTURING/lless 600 BOTTOM")
	)
unless( axlIsLayer( "MANUFACTURING/lmore 600 BOTTOM")
		axlMsgPut("Creating Layer MANUFACTURING/lmore 600 BOTTOM")
		axlLayerCreateNonConductor("MANUFACTURING/lmore 600 BOTTOM")
	)
/*
unless( axlIsLayer( "MANUFACTURING/REFDES BOTTOM DRC")
		axlMsgPut("Creating Layer MANUFACTURING/REFDES BOTTOM DRC")
		axlLayerCreateNonConductor("MANUFACTURING/REFDES BOTTOM DRC"))
unless( axlIsLayer( "MANUFACTURING/REFDES TOP DRC")
		axlMsgPut("Creating Layer MANUFACTURING/REFDES TOP DRC")
		axlLayerCreateNonConductor("MANUFACTURING/REFDES TOP DRC"))
*/
    axlUIWRedraw(nil)
    axlClearSelSet()
)

;;;;;;;;;;;;;;;;;;;;;;;
;相关层配色
; input : nox output : no
;;;;;;;;;;;;;;;;;;;;;;;

;_____________ set color ____________________________________________
defun( testing_Allcolor_set ()   
	rpt = outfile("./setColor.scr")
	fprintf(rpt "version 14.0\n\nsetwindow pcb\ncolor \n")
	fprintf(rpt "setwindow form.cvf_main \n")
	fprintf(rpt "FORM cvf_main class_list Stack-Up \n")
	fprintf(rpt "FORM cvf_main color4 3 \n")
	fprintf(rpt "FORM cvf_main via_class/soldermask_top/color 4 \n")
	fprintf(rpt "FORM cvf_main via_class/soldermask_bottom/color 4 \n")
	fprintf(rpt "FORM cvf_main color4 3 \n")
	fprintf(rpt "FORM cvf_main pin/soldermask_top/color 4 \n")
	fprintf(rpt "FORM cvf_main color4 3 \n")
	fprintf(rpt "FORM cvf_main pin/soldermask_bottom/color 4 \n")
	fprintf(rpt "FORM cvf_main class_list Geometry \n")
	;fprintf(rpt "FORM cvf_main board_geometry/outline/color 1 \n")
	fprintf(rpt "FORM cvf_main color4 3 \n")
	fprintf(rpt "FORM cvf_main board_geometry/soldermask_top/color 4 \n")
	fprintf(rpt "FORM cvf_main color4 3 \n")
	fprintf(rpt "FORM cvf_main board_geometry/soldermask_bottom/color 4\n")
	fprintf(rpt "FORM cvf_main color4 3 \n")
	fprintf(rpt "FORM cvf_main package_geometry/soldermask_top/color 4 \n")
	fprintf(rpt "FORM cvf_main color4 3 \n")
	fprintf(rpt "FORM cvf_main package_geometry/soldermask_bottom/color 4\n") 
	fprintf(rpt "FORM cvf_main color2 1 \n")
	fprintf(rpt "FORM cvf_main package_geometry/display_top/color 2 \n")
	fprintf(rpt "FORM cvf_main color2 1 \n")
	fprintf(rpt "FORM cvf_main package_geometry/display_bottom/color 2\n") 
	fprintf(rpt "FORM cvf_main class_list Manufacturing \n")
	;fprintf(rpt "FORM cvf_main manufacturing/refdes_top_drc/visible YES \n")
	;fprintf(rpt "FORM cvf_main manufacturing/refdes_bottom_drc/visible YES \n")
	;fprintf(rpt "FORM cvf_main color5 4 \n")
	;fprintf(rpt "FORM cvf_main manufacturing/refdes_top_drc/color 5 \n")
	;fprintf(rpt "FORM cvf_main color8 7 \n")
	;fprintf(rpt "FORM cvf_main manufacturing/refdes_bottom_drc/color 8 \n")
	;fprintf(rpt "FORM cvf_main manufacturing/Lmore_600_bottom/visible YES \n")
	;fprintf(rpt "FORM cvf_main manufacturing/Lmore_600_top/visible YES \n")
	fprintf(rpt "FORM cvf_main color8 7 \n")
	fprintf(rpt "FORM cvf_main manufacturing/Lmore_600_bottom/color 2 \n")
	fprintf(rpt "FORM cvf_main color8 7 \n")
	fprintf(rpt "FORM cvf_main manufacturing/Lmore_600_top/color 8 \n")
	;fprintf(rpt "FORM cvf_main manufacturing/Lless_600_bottom/visible YES \n")
	;fprintf(rpt "FORM cvf_main manufacturing/Lless_600_top/visible YES \n")
	fprintf(rpt "FORM cvf_main color2 1\n")
	fprintf(rpt "FORM cvf_main manufacturing/Lless_600_bottom/color 8 \n")
	fprintf(rpt "FORM cvf_main color2 1 \n")
	fprintf(rpt "FORM cvf_main manufacturing/Lless_600_top/color 2 \n")
;/*
	fprintf(rpt "FORM cvf_main class_list Areas \n")
	fprintf(rpt "FORM cvf_main color2 1 \n")
	fprintf(rpt "FORM cvf_main route_keepout/all/color 2 \n")
	fprintf(rpt "FORM cvf_main color2 1 \n")
	fprintf(rpt "FORM cvf_main route_keepout/top/color 2 \n")
	fprintf(rpt "FORM cvf_main color2 1 \n")
	fprintf(rpt "FORM cvf_main route_keepout/bottom/color 2 \n")
	fprintf(rpt "FORM cvf_main color5 4 \n")
	fprintf(rpt "FORM cvf_main package_keepout/all/color 5 \n")
	fprintf(rpt "FORM cvf_main color5 4 \n")
	fprintf(rpt "FORM cvf_main package_keepout/top/color 5 \n")
	fprintf(rpt "FORM cvf_main color5 4 \n")
	fprintf(rpt "FORM cvf_main package_keepout/bottom/color 5 \n")
  	fprintf(rpt "FORM cvf_main class_list Display\n") 
	fprintf(rpt "FORM cvf_main color5 4\n")
	fprintf(rpt "FORM cvf_main hilite_col 5 \n")
	fprintf(rpt "FORM cvf_main color8 7 \n")
	fprintf(rpt "FORM cvf_main perm_hilite_col 8 \n")
;*/
	fprintf(rpt "FORM cvf_main apply \n")
	fprintf(rpt "FORM cvf_main ok \n")
	close(rpt)
	axlShell("replay ./setColor.scr")
    deleteFile("./setColor.scr")
)

;;;;;;;;;;;;;;;;;;;;;;;
;相关层一些信息打开
; input : nox output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_turn_on_layer (select_layer_flag)
		axlVisibleDesign(nil)
		axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t) 
		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:BOARD GEOMETRY/paramLayer:SOLDERMASK_%s" select_layer_flag))
		Going_On->visible=t
		axlSetParam(Going_On)

		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:BOARD GEOMETRY/paramLayer:SILKSCREEN_%s" select_layer_flag))
		Going_On->visible=t
		axlSetParam(Going_On)
		;Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:BOARD GEOMETRY/paramLayer:Switch_Area_%s" select_layer_flag))
		;Going_On->visible=t
		;axlSetParam(Going_On)
		;Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:PACKAGE GEOMETRY/paramLayer:Display_%s" select_layer_flag))
		;Going_On->visible=t
		;axlSetParam(Going_On)

		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:VIA CLASS/paramLayer:SOLDERMASK_%s" select_layer_flag))
		Going_On->visible=t
		axlSetParam(Going_On)
		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:PACKAGE GEOMETRY/paramLayer:SOLDERMASK_%s" select_layer_flag))
		Going_On->visible=t
		axlSetParam(Going_On)  
		;Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:VIA CLASS/paramLayer:%s" select_layer_flag))
		;Going_On->visible=t
		;axlSetParam(Going_On)  

		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:PIN/paramLayer:%s" select_layer_flag))
		Going_On->visible=t
		axlSetParam(Going_On)
		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:PIN/paramLayer:SOLDERMASK_%s" select_layer_flag))
		Going_On->visible=t
		axlSetParam(Going_On)
		; Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:BOARD GEOMETRY/paramLayer:DIMENSION" ))
		; Going_On->visible=t
		; axlSetParam(Going_On)
		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:PACKAGE GEOMETRY/paramLayer:SILKSCREEN_%s" select_layer_flag))
		Going_On->visible=t
		axlSetParam(Going_On)  
		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:REF DES/paramLayer:SILKSCREEN_%s" select_layer_flag))
		Going_On->visible=t
		axlSetParam(Going_On)

		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:ROUTE KEEPOUT/paramLayer:%s" select_layer_flag))
		Going_On->visible = t
		axlSetParam(Going_On)

		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:PACKAGE KEEPOUT/paramLayer:%s" select_layer_flag))
		Going_On->visible = t
		axlSetParam(Going_On)
		axlVisibleLayer("ROUTE KEEPOUT/All" t)
		axlVisibleLayer("ROUTE KEEPIN" t)
		axlVisibleLayer("PACKAGE KEEPOUT/All" t)

		axlUIWRedraw(nil)
		axlClearSelSet()
)
;;;;;;;;;;;;;;;;;;;;;;;
;删除4层的连线
; input : nox output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_Delline ()
	prog( () 
		let((mypopup) 
			axlClearSelSet()
			axlVisibleDesign(nil)
			axlVisibleLayer("MANUFACTURING/lmore 600 TOP"  t)
			axlVisibleLayer("MANUFACTURING/lmore 600 BOTTOM"  t)
			axlVisibleLayer("MANUFACTURING/lless 600 TOP"  t)
			axlVisibleLayer("MANUFACTURING/lless 600 BOTTOM"  t)
			;axlVisibleLayer("MANUFACTURING/REFDES BOTTOM DRC"  t)
			;axlVisibleLayer("MANUFACTURING/REFDES TOP DRC"  t)
			axlClearSelSet()
			axlUIWUpdate(nil)
			axlClearSelSet()
			axlSetFindFilter(?enabled list("lines")  ?onButtons "lines")
			axlOpenFindFilter()
			axlAddSelectAll()
			lslist=axlGetSelSet()
			axlClearSelSet()
			axlUIWUpdate(nil)
			axlDeleteObject(lslist)
			axlUIWRedraw(nil)
			axlClearSelSet()
			axlUIWRedraw(nil)
			testing_turn_on_layer( select_layer_flag)
			testing_cnt = 0
			axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
			axlUIWUpdate(nil)
			axlUIWRedraw(nil)
		)
	)
) 
;;;;;;;;;;;;;;;;;;;;;;;
;区域高亮成不同颜色主程序
; input : nox output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_HilElement ()
	prog( () 
		let((mypopup) 
			"Delete selected Objects" 
			mypopup = axlUIPopupDefine(nil 
			'(("Done" axlFinishEnterFun) 
			("Cancel" axlFinishEnterFun))) 
			axlUIPopupSet(mypopup) 
			axlSetFindFilter(?enabled '("noall" "components") ?onButtons '("noall" "components")) 
			while( axlSingleSelectBox() 	testing_Hilight_box() )
			;while( axlSingleSelectBox() testing_line_symbolslist())
			axlUIPopupSet( axlUIPopupDefine(nil nil)) 
			axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
			axlUIWUpdate(nil)
			axlUIWRedraw(nil)
		)
	)
) 

;;;;;;;;;;;;;;;;;;;;;;;
;高亮成不同颜色子程序
; input : nox output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_Hilight_box ()
	prog( ()
		symbolslist=axlGetSelSet()
		axlClearSelSet()
		axlUIWUpdate(nil)
		colorlist=list(2 3 4 5 7 8 10 11)
		item1=1
		foreach(item symbolslist
			colorfill=nthelem(item1 colorlist)
			axlDBControl('highlightColor colorfill)
			axlHighlightObject(item->symbol t) 
			item1++
			if(item1>8 then item1=1)
		) 
		testing_turn_on_layer(select_layer_flag)
		axlVisibleLayer( strcat("MANUFACTURING/lless 600 "  select_layer_flag) t )
		axlVisibleLayer( strcat("MANUFACTURING/lmore 600 "  select_layer_flag) t )
		axlUIWRedraw(nil)
		axlUIWUpdate(nil)
		axlClearSelSet()
	)
)




;2010.07.20 added by andyluhero
;2010.07.22 changed by andyluhero
;;;;;;;;;;;;;;;;;;;;;;;
;判别交错框选器件与位号连线主程序
; input : nox output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_calc_lt_symbol_range  ()
	prog( () 
		let((mypopup) 
			(when !axlOKToProceed()
				return(nil)
			)
			testing_turn_on_layer( select_layer_flag)
			axlVisibleLayer( strcat("MANUFACTURING/lless 600 "  select_layer_flag) t )
			axlVisibleLayer( strcat("MANUFACTURING/lmore 600 "  select_layer_flag) t )
			mypopup = axlUIPopupDefine(nil 
				'(("Done" axlFinishEnterFun) 
					("Cancel" axlFinishEnterFun))) 
			axlUIPopupSet(mypopup) 
			testing_turn_on_layer( select_layer_flag)
			axlSetFindFilter(?enabled '("noall" "components") ?onButtons '("noall" "components")) 
			while( axlSingleSelectBox() testing_line_symbolslist_calc())
			axlUIPopupSet( axlUIPopupDefine(nil nil)) 
			testing_turn_on_layer( select_layer_flag)
			axlVisibleLayer( strcat("MANUFACTURING/lless 600 "  select_layer_flag) t )
			axlVisibleLayer( strcat("MANUFACTURING/lmore 600 "  select_layer_flag) t )
			axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
			axlUIWUpdate(nil)
			axlUIWRedraw(nil)
		)
	)
) 
;;;;;;;;;;;;;;;;;;;;;;;
;框选器件与位号连线，输出交错子程序
; input : nox output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_line_symbolslist_calc ()
    prog( ()
		axlFormListDeleteAll(myform "testing_next_view_All")
		testing_next_view_num=nil
		symbols_list=axlGetSelSet()
		testing_unselect_object()
		axlClearSelSet()
		axlUIWUpdate(nil)
		deletelinelist=nil
		axlVisibleDesign(nil)
		axlVisibleLayer( strcat("MANUFACTURING/lless 600 "  select_layer_flag) t )
		axlVisibleLayer( strcat("MANUFACTURING/lmore 600 "  select_layer_flag) t )
		axlSetFindFilter(?enabled '(noall lines) ?onButtons '(noall lines))
		deletelinelist=axlGetSelSet(axlAddSelectAll())
		axlClearSelSet()
		testing_turn_on_layer( select_layer_flag)
		calc_symline_list=nil
		calc_symline=nil
		foreach(item symbols_list
			calc_symline=testing_line_symbols_high(item->symbol)
			calc_symline_list=cons(calc_symline calc_symline_list)
		) 
		calc_symline_list=testing_justice_list(calc_symline_list)
		calc_symline_list=remdq(nil calc_symline_list)
		output_list=nil
		if(calc_symline_list!=nil then
			output_list=calc_lt_symbol_selct_all(calc_symline_list)
		)
		output_list=testing_justice_list(output_list)
		output_list=remdq(nil output_list)
		if(output_list!=nil then
			foreach(item  output_list
				x = nthelem(1 item->symbol->xy) 
				y = nthelem(2 item->symbol->xy)
				testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" item->name x y ) testing_next_view_num)
			)
		)
		testing_next_view_num=testing_justice_list(testing_next_view_num)
		testing_next_view_num=remdq(nil testing_next_view_num)
		testing_cnt=length(testing_next_view_num)
		testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 13 \317\356: \327\326\267\373\275\273\264\355:\271\262  %d  \317\356" testing_cnt)
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		testing_next_view_All=testing_next_view_num
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		if(testing_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))	
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\327\326\267\373\275\273\264\355"  testing_cnt)
		axlUIWPrint(myform uidisplayer)  
		axlFormDisplay(myform)
		axlVisibleLayer( strcat("MANUFACTURING/lless 600 "  select_layer_flag) t )
		axlVisibleLayer( strcat("MANUFACTURING/lmore 600 "  select_layer_flag) t )
		axlUIWRedraw(nil)
		axlUIWUpdate(nil)
		axlSetFindFilter(?enabled '("noall" "components") ?onButtons '("noall" "components")) 
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;判别连线交错子程序
; input : calc_symline_list output : output_calc_line_list
;;;;;;;;;;;;;;;;;;;;;;;
procedure(calc_lt_symbol_selct_all(calc_symline_list)
    prog(()
		getbox1=nil
		calc_box_dist=10*change_mil_mm_units
		output_calc_line_list=nil
		foreach(item1 calc_symline_list
			foreach(item2 calc_symline_list
				if( item2!=item1  then
					if(abs(nthelem(3 axl_ol_ol2(item1 item2))-0.0)<=0.1*change_mil_mm_units then 
						axlSetFindFilter(?enabled list("noall" "components")  ?onButtons list("noall" "components"))
						getbox1=list(car(car(item1))-calc_box_dist:cadr(car(item1))-calc_box_dist car(car(item1))+calc_box_dist:cadr(car(item1))+calc_box_dist)
						calc_line_list=nil
						if(axlSingleSelectBox(getbox1)!=nil then
							calc_line_list=axlGetSelSet()
							output_calc_line_list=append(calc_line_list  output_calc_line_list)
							foreach(item calc_line_list
								axlHighlightObject(item->symbol t)
							)
						)

					)
				)
			)
		)
		axlClearSelSet()
		axlUIWRedraw(nil)
		axlUIWUpdate(nil)
		return(output_calc_line_list)
	)
)
/*
(defun testing_calc_lt_symbol_range ()
prog( () 
    let((mypopup) 
    "Delete selected Objects" 
    mypopup = axlUIPopupDefine(nil 
        '(("Done" axlFinishEnterFun) 
            ("Cancel" axlFinishEnterFun))) 
axlUIPopupSet(mypopup) 
testing_text_lt_symbolsall()
   axlClearSelSet()
axlUIWUpdate(nil)

testing_turn_on_layer(select_layer_flag)
axlVisibleLayer( strcat("MANUFACTURING/lless 600 "  select_layer_flag) t )
axlVisibleLayer( strcat("MANUFACTURING/lmore 600 "  select_layer_flag) t )
axlUIWRedraw(nil)
axlUIWUpdate(nil)
change_mil_mm_units=0
case(car(axlDBGetDesignUnits())
("millimeters"  change_mil_mm_units=0.0254 )
("mils"   change_mil_mm_units=0.9999))
lineseglist=nil
axlSetFindFilter(?enabled list("noall" "linesegs")  ?onButtons list("noall" "linesegs"))
while( axlSingleSelectBox() calc_lt_symbol_selct())
	axlUIPopupSet( axlUIPopupDefine(nil nil)) 
;testing_Delline()
axlUIWRedraw(nil)
axlUIWUpdate(nil)
))) 

procedure(calc_lt_symbol_selct()
     prog(()
lineseglist=axlGetSelSet()
testing_unselect_object()
axlClearSelSet()
calc_lineseglist=nil
foreach(item lineseglist
	if(item->layer==strcat("MANUFACTURING/LLESS 600 "  select_layer_flag) || item->layer==strcat("MANUFACTURING/LMORE 600 "  select_layer_flag)  then
		calc_lineseglist=cons(item calc_lineseglist)
	)
)
calc_lineseglist=remdq(nil calc_lineseglist)
axlClearSelSet()
calc_box_dist=10*change_mil_mm_units
foreach(item1 calc_lineseglist
		item1_startEnd=item1->startEnd
		foreach(item2 calc_lineseglist
			item2_startEnd=item2->startEnd
			if( item2!=item1  then
				if(abs(nthelem(3 axl_ol_ol2(item1_startEnd item2_startEnd))-0.0)<=0.1*change_mil_mm_units then 
					axlHighlightObject(list(item1 item2))
						axlSetFindFilter(?enabled list("noall" "symbols")  ?onButtons list("noall" "symbols"))
						axlHighlightObject(
								axlGetSelSet(
									axlSingleSelectBox(
											list(car(car(item1_startEnd))-calc_box_dist:cadr(car(item1_startEnd))-calc_box_dist car(car(item1_startEnd))+calc_box_dist:cadr(car(item1_startEnd))+calc_box_dist)
												)
										)
									t )
				)
			)
		)

)
axlUIWRedraw(nil)
axlUIWUpdate(nil)
axlSetFindFilter(?enabled list("noall" "linesegs")  ?onButtons list("noall" "linesegs"))
))
*/

;;;;;;;;;;;;;;;;;;;;;;;
;框选器件与位号连线并将器件高亮成不同颜色主程序
; input : nox output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_HilElement_line ()
	prog( () 
		let((mypopup) 
			mypopup = axlUIPopupDefine(nil 
				'(("Done" axlFinishEnterFun) 
				("Cancel" axlFinishEnterFun))) 
			axlUIPopupSet(mypopup) 
			axlSetFindFilter(?enabled '("noall" "components") ?onButtons '("noall" "components")) 
			;while( axlSingleSelectBox() 	testing_Hilight_box() )
			while( axlSingleSelectBox() testing_line_symbolslist())
			axlUIPopupSet( axlUIPopupDefine(nil nil)) 
			axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
			axlUIWUpdate(nil)
			axlUIWRedraw(nil)
		)
	)
) 

;;;;;;;;;;;;;;;;;;;;;;;
;将器件高亮成不同颜色子程序
; input : no output : no
;;;;;;;;;;;;;;;;;;;;;;;

(defun testing_line_symbolslist ()
	prog( ()
		symbolslist=axlGetSelSet()
		axlClearSelSet()
		axlUIWUpdate(nil)
		deletelinelist=nil
		axlVisibleDesign(nil)
		axlVisibleLayer( strcat("MANUFACTURING/lless 600 "  select_layer_flag) t )
		axlVisibleLayer( strcat("MANUFACTURING/lmore 600 "  select_layer_flag) t )
		axlSetFindFilter(?enabled '(noall lines) ?onButtons '(noall lines))
		deletelinelist=axlGetSelSet(axlAddSelectAll())
		axlClearSelSet()
		axlDeleteObject(deletelinelist)
		colorlist=list(2 3 4 5 7 8 10 11)
		item1=1
		foreach(item symbolslist
			testing_line_symbols_high(item->symbol)
			colorfill=nthelem(item1 colorlist)
			axlDBControl('highlightColor colorfill)
			axlHighlightObject(item->symbol t) 
			item1++
			if(item1>8 then item1=1)
		) 
		axlVisibleDesign(nil)
		testing_turn_on_layer(select_layer_flag)
		axlVisibleLayer( strcat("MANUFACTURING/lless 600 "  select_layer_flag) t )
		axlVisibleLayer( strcat("MANUFACTURING/lmore 600 "  select_layer_flag) t )
		axlUIWRedraw(nil)
		axlUIWUpdate(nil)
		axlSetFindFilter(?enabled '("noall" "components") ?onButtons '("noall" "components")) 
	)
)
;changed by andyluhero 2010.07.22
;;;;;;;;;;;;;;;;;;;;;;;
;框选器件与位号连线子程序
; input : nox output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_line_symbols_high (symitem)
    prog( ()
		symxy=0
		txtxy=0
		symline=nil
		if(symitem->type == "PACKAGE" then 
			foreach(txt symitem->children 
				if(txt->objType == "text" then 
					if(txt->layer ==strcat("REF DES/SILKSCREEN_" select_layer_flag)  then 
						if( txt->parent->xy != nil && txt->xy != nil then
							symxy= txt->parent->xy
							txtxy = txt->xy
							symline=list(txtxy symxy)
							testing_line1width=0
							testing_line2width=0
							testing_linelength=0
							case(car(axlDBGetDesignUnits())
								("millimeters" testing_line1width=0.1  testing_line2width=0.075   testing_linelength=15 )
								("mils" testing_line1width=4  testing_line2width=3   testing_linelength=600 )
							)
							if(axlDistance(txtxy symxy)<testing_linelength  then 				
								pline=axlDBCreateLine(symline,testing_line1width, strcat("MANUFACTURING/lless 600 " select_layer_flag) )
							else
								pline=axlDBCreateLine(symline,testing_line2width, strcat("MANUFACTURING/lmore 600 " select_layer_flag) )
							)
						)
					)
				)
			)
		)
		return(symline)
	)
)
/*
(defun testing_line_symbols_high (symitem)
    prog( ()
	symxy=0
	txtxy=0
	if(symitem->type == "PACKAGE" then 
		foreach(txt symitem->children 
			if(txt->objType == "text" then 
			if(txt->layer ==strcat("REF DES/SILKSCREEN_" select_layer_flag)  then 
					if( txt->parent->xy != nil && txt->xy != nil then
			symxy= txt->parent->xy
			txtxy = txt->xy
			symline=list(txtxy symxy)
			testing_line1width=0
			testing_line2width=0
			testing_linelength=0
			case(car(axlDBGetDesignUnits())
		("millimeters" testing_line1width=0.1  testing_line2width=0.075   testing_linelength=15 )
		("mils" testing_line1width=4  testing_line2width=3   testing_linelength=600 ))
    	if(axlDistance(txtxy symxy)<testing_linelength  then 				
			pline=axlDBCreateLine(symline,testing_line1width, strcat("MANUFACTURING/lless 600 " select_layer_flag) )
			else
			pline=axlDBCreateLine(symline,testing_line2width, strcat("MANUFACTURING/lmore 600 " select_layer_flag) )
			))
			))
			))
))
*/
;;;;;;;;;;;;;;;;;;;;;;;
;整板器件与位号连线子程序
; input : no output : no
;;;;;;;;;;;;;;;;;;;;;;;
procedure(testing_text_lt_symbolsall()
    prog(()
		complinelist=nil
		testing_turn_on_layer(select_layer_flag)
		axlSetFindFilter(?enabled list("noall" "components")  ?onButtons list("noall" "components"))
		axlOpenFindFilter()
		complinelist=axlGetSelSet(axlAddSelectAll())
		axlClearSelSet()
		foreach(item complinelist
			testing_line_symbols_high(item->symbol)
		)
		axlVisibleLayer( strcat("MANUFACTURING/lless 600 "  select_layer_flag) t )
		axlVisibleLayer( strcat("MANUFACTURING/lmore 600 "  select_layer_flag) t )
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;检查整板单面器件位号丢失程序；除mark点外的器件，mark点高亮但不做判别
; input : no output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_LostRef () 
	(prog ()
		layersym_list=nil
		testing_turn_on_layer(select_layer_flag)
		;testing_DeHLSymNetsPins() 
		andy_design= axlDBGetDesign() 
		axlDehighlightObject(andy_design->symbols t)
		axlSetFindFilter(?enabled list("noall" "symbols")  ?onButtons list("noall" "symbols"))
		axlOpenFindFilter()
		layersym_list=axlGetSelSet(axlAddSelectAll())
		axlClearSelSet()
		testing_cnt = 0
		testing_next_view_num =nil
		foreach(sym   layersym_list
			if(sym->type == "PACKAGE" then 
				if(rexMatchp("^MARK"  upperCase(sym->name))!=nil then 	axlHighlightObject(sym t))
				if(rexMatchp("^MARK"  upperCase(sym->name))==nil then 
					flag = nil 
					foreach(FindRefdes 	sym->children 
						if(FindRefdes->objType == "text" then 
							if(FindRefdes->layer =="REF DES/SILKSCREEN_TOP" ||FindRefdes->layer =="REF DES/SILKSCREEN_BOTTOM"   then 
								if(FindRefdes->text == sym->refdes then flag = t)
							)
						)
					)
					if(!flag then ++testing_cnt 
						x = nthelem(1 sym->xy) 
						y = nthelem(2 sym->xy)	
						axlHighlightObject(sym t)
						if(sym->refdes==nil then
							foreach(txtitem sym->children
								if(txtitem->layer=="REF DES/ASSEMBLY_TOP" || txtitem->layer =="REF DES/ASSEMBLY_BOTTOM"   then
									testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" txtitem->text x y) testing_next_view_num)
								)
							)
						else
							testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" sym->refdes x y) testing_next_view_num)
						)
					)
				)
			)
		)
		testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 1 \317\356: \327\326\267\373\266\252\312\247:\271\262 %d \317\356" testing_cnt)
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		testing_next_view_num=remdq(nil testing_next_view_num)
		testing_next_view_All=testing_next_view_num
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		if(testing_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))	
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\327\326\267\373\266\252\312\247"  testing_cnt)
		axlUIWPrint(myform uidisplayer) 
		axlFormDisplay(myform)
		testing_turn_on_layer(select_layer_flag)
		axlClearSelSet()
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;检查整板器件1脚标识丢失程序；对两面的器件都进行检查
; input : no output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_LostPinName () 
	(prog ()
		testing_turn_on_layer(select_layer_flag)
		axlClearSelSet()
		;testing_DeHLSymNetsPins() 
		andy_design = axlDBGetDesign() 
		;axlDehighlightObject(andy_design->symbols t)
		andy_dbsymdefs = andy_design->symdefs
		testing_cnt = 0
		testing_next_view_num =nil
		foreach(dbsym andy_dbsymdefs
			if(dbsym->type == "PACKAGE" then 
				foreach(Childdef  dbsym->children 
					if(Childdef->objType == "text" then 
						if(Childdef->layer == "PACKAGE GEOMETRY/SILKSCREEN_TOP" || Childdef->layer == "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM"  then 
							if(Childdef->text == "1" || Childdef->text == "O" || Childdef->text == "o" || Childdef->text == "A" || Childdef->text == "+" then 
								axlHighlightObject(dbsym->instances t);added by andyluhero 2010.07.23
								pinname = Childdef->text 
								foreach(sym dbsym->instances 
									flag = nil 
									foreach(FindRefdes sym->children 
										if(FindRefdes->objType == "text" then 
											if(FindRefdes->layer == "PACKAGE GEOMETRY/SILKSCREEN_TOP" 
											|| FindRefdes->layer == "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM"  then 
												if(FindRefdes->text == pinname then flag = t)
											)
										)
									) 
									if(!flag then ++testing_cnt
										axlHighlightObject(sym)
										x = nthelem(1 sym->xy) 
										y = nthelem(2 sym->xy)	
										testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" sym->refdes x y) testing_next_view_num)
									)
								)
							)
						)
					)
				)
			)
		)
		testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 2 \317\356: 1\275\305\261\352\312\266\266\252\312\247:\271\262  %d  \317\356" testing_cnt)
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		testing_next_view_num=remdq(nil testing_next_view_num)
		testing_next_view_All=testing_next_view_num
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		if(testing_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))	
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356 1\275\305\261\352\312\266\266\252\312\247"  testing_cnt)
		axlUIWPrint(myform uidisplayer)
		axlFormDisplay(myform) 
		testing_turn_on_layer(select_layer_flag)
		axlClearSelSet()
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)
	)
)
/*
;;2010.0422,added text->mirrored and 270
defun( testing_Refdes_Direction ()
        axlVisibleDesign(nil)
testing_turn_on_layer(select_layer_flag)
;	setq(allsym axlDBGetDesign()->symbols)
;	axlDehighlightObject(allsym)
   axlSetFindFilter(?enabled list("noall" "text")  ?onButtons list("noall" "text"))
		axlOpenFindFilter()
        	axlAddSelectAll()
		layersym_list=axlGetSelSet()
		axlClearSelSet()
	dir = nil
	testing_cnt = 0
testing_next_view_num =nil
	foreach(txt layersym_list	
		have=nil
		if(txt != nil && txt->text != nil then
			if(txt->layer == strcat("REF DES/SILKSCREEN_" select_layer_flag )||
				txt->layer == strcat("BOARD GEOMETRY/SILKSCREEN_" select_layer_flag) then
			if(txt->isMirrored != t then
				if(abs(txt->rotation - 0.0) < 5.0 ||  abs(txt->rotation - 90.0) < 5.0 || 
				  abs(txt->rotation - 360.0) < 5.0  then
				xx = 0
				else
					axlHighlightObject(list( txt) )
					have=t ; ++testing_cnt
				)
			else
				if(abs(txt->rotation - 0.0) < 5.0 ||  abs(txt->rotation - 270.0) < 5.0 || 
				  abs(txt->rotation - 360.0) < 5.0  then
				xx = 1
				else
					axlHighlightObject(list(txt) )
					have=t 
				)
			
			)
		)

		  if(have then ++testing_cnt 
testing_sub_texts=cons(txt testing_sub_texts) 
    x = nthelem(1 txt->xy) 
    y = nthelem(2 txt->xy)	
testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" txt->text x y) testing_next_view_num)
)    
		);if_end
		
	);foreach-end
testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 3 \317\356: \327\326\267\373\267\275\317\362\262\273\325\375\310\267:\271\262  %d  \317\356" testing_cnt)
axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
testing_next_view_num=remdq(nil testing_next_view_num)
testing_next_view_All=testing_next_view_num
axlFormSetField(myform "testing_next_view_All" testing_next_view_All)	
if(testing_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))	
	uidisplayer=nil
uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\327\326\267\373\267\275\317\362\262\273\325\375\310\267"  testing_cnt)
axlUIWPrint(myform uidisplayer)
axlFormDisplay(myform) 
testing_turn_on_layer(select_layer_flag)     
    axlClearSelSet()
);defun_end

*/
;;2010.0513,added justice num of 0-180 and 90-270 
;;;;;;;;;;;;;;;;;;;;;;;
;检查整板单面器件位号方向不正确程序；根据器件位号方向数量比进行判别
; input : no output : no
;;;;;;;;;;;;;;;;;;;;;;;
defun( testing_Refdes_Direction ()
	(prog ()
		axlVisibleDesign(nil)
		testing_turn_on_layer(select_layer_flag)
		axlSetFindFilter(?enabled list("noall" "text")  ?onButtons list("noall" "text"))
		axlOpenFindFilter()
		axlAddSelectAll()
		layersym_list=axlGetSelSet()
		axlClearSelSet()
		testing_cnt = 0
		testing_next_view_num =nil
		rotation_0_num=0
		rotation_0_list=nil
		rotation_90_num=0
		rotation_90_list=nil
		rotation_180_num=0
		rotation_180_list=nil
		rotation_270_num=0
		rotation_270_list=nil
		txt_wrong_list=nil
		foreach(txt layersym_list	
			have=nil
			if(txt != nil && txt->text != nil then
				if(txt->layer == strcat("REF DES/SILKSCREEN_" select_layer_flag )||
				txt->layer == strcat("BOARD GEOMETRY/SILKSCREEN_" select_layer_flag) then
					if(abs(txt->rotation - 0.0) < 5.0 ||  abs(txt->rotation - 90.0) < 5.0 || 
					abs(txt->rotation - 180.0) < 5.0 ||  abs(txt->rotation - 270.0) < 5.0 || 
					abs(txt->rotation - 360.0) < 5.0  then
						if(abs(txt->rotation - 0.0) < 5.0 || abs(txt->rotation - 360.0) < 5.0  then
							rotation_0_list=cons(txt rotation_0_list)
							++rotation_0_num
						)
						if(abs(txt->rotation - 90.0) < 5.0   then
							rotation_90_list=cons(txt rotation_90_list)
							++rotation_90_num
						)
						if(abs(txt->rotation - 180.0) < 5.0   then
							rotation_180_list=cons(txt rotation_180_list)
							++rotation_180_num
						)
						if(abs(txt->rotation - 270.0) < 5.0   then
							rotation_270_list=cons(txt rotation_270_list)
							++rotation_270_num
						)
					else
						axlHighlightObject(list(txt) )
						txt_wrong_list=cons(txt txt_wrong_list)
					)
				)

			);if_end

		);foreach-end
		if(rotation_0_num >= rotation_180_num then
			axlHighlightObject(rotation_180_list)
			txt_wrong_list=append(rotation_180_list txt_wrong_list)
		else
			axlHighlightObject(rotation_0_list)
			txt_wrong_list=append(rotation_0_list txt_wrong_list)
		)
		if(rotation_90_num >= rotation_270_num then
			axlHighlightObject(rotation_270_list)
			txt_wrong_list=append(rotation_270_list txt_wrong_list)
		else
			axlHighlightObject(rotation_90_list)
			txt_wrong_list=append(rotation_90_list txt_wrong_list)
		)			
		txt_wrong_list=remdq(nil txt_wrong_list)
		if(txt_wrong_list!=nil then
			foreach(txtitem txt_wrong_list
				++testing_cnt 
				x = nthelem(1 txtitem->xy) 
				y = nthelem(2 txtitem->xy)
				xyrotation=txtitem->rotation	
				testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f; %0.2f%s" txtitem->text x y  xyrotation "\266\310") testing_next_view_num)
			)
		)
		testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 3 \317\356: \327\326\267\373\267\275\317\362\262\273\325\375\310\267:\271\262  %d  \317\356" testing_cnt)
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		testing_next_view_num=remdq(nil testing_next_view_num)
		testing_next_view_All=testing_next_view_num
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		if(testing_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))	
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\327\326\267\373\267\275\317\362\262\273\325\375\310\267"  testing_cnt)
		axlUIWPrint(myform uidisplayer)
		axlFormDisplay(myform) 
		testing_turn_on_layer(select_layer_flag)     
		axlClearSelSet()
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)
	)
);defun_end

;;;;;;;;;;;;;;;;;;;;;;;
;关掉器件以及器件管脚的颜色
; input : no output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_DeHLSymNetsPins ()
	andy_design = axlDBGetDesign() 
	axlDehighlightObject(andy_design->symbols t) 
	;axlDehighlightObject(andy_design->nets t)
	foreach(sym andy_design->symbols 
	    lpins = sym->pins
	    axlDehighlightObject(lpins t)
	)
)



;changed by andyluhero 2010.07.19 because of silimar text
;;;;;;;;;;;;;;;;;;;;;;;
;检查整板两面除位号和器件本身字符外添加的位号重复性，根据层来进行划分，因此层一定要正确
; input : no output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_Refdes_same ()
	prog( ()
		axlVisibleDesign(nil)
		testing_turn_on_layer(select_layer_flag)
		axlVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_TOP"  t)
		axlVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_BOTTOM"  t)
		axlVisibleLayer("BOARD GEOMETRY/SILKSCREEN_TOP"  t)
		axlVisibleLayer("BOARD GEOMETRY/SILKSCREEN_BOTTOM"  t)
		axlVisibleLayer("REF DES/SILKSCREEN_TOP"  t)
		axlVisibleLayer("REF DES/SILKSCREEN_BOTTOM"  t)
		testing_next_view_num =nil
		testing_cnt = 0
		axlClearSelSet()
		axlUIWUpdate(nil)
		textlist=nil
		axlSetFindFilter(?enabled list("noall" "text")  ?onButtons list("noall" "text"))
		axlOpenFindFilter()
		textlist=axlGetSelSet(axlAddSelectAll())
		axlClearSelSet()
		non_symol_txt_list=nil
		foreach(txtitem textlist
			if(txtitem->parent==nil  then
				non_symol_txt_list=cons(txtitem non_symol_txt_list)
				textlist=remove(txtitem textlist)
			)
			if(txtitem->parent!=nil  && txtitem->layer=="PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" 
				|| txtitem->parent!=nil && txtitem->layer=="PACKAGE GEOMETRY/SILKSCREEN_TOP" then
					textlist=remove(txtitem textlist)
			)
		)
		textlist=remdq(nil textlist)
		non_symol_txt_list=remdq(nil non_symol_txt_list)
		andy_list=nil
		foreach(item1 non_symol_txt_list
			foreach( item2 non_symol_txt_list
				if(item2!=item1 && item2->text==item1->text then
					axlHighlightObject(list(item1 item2))
					andy_list=append(list(item1 item2) andy_list)
					;andy_list=cons(item1  andy_list)
				)
			)
			foreach( item3 textlist
				if(item3->text==item1->text then
					axlHighlightObject(list(item1 item3))
					andy_list=append(list(item1 item3) andy_list)
					;andy_list=cons(item1  andy_list)
				)
			)
			
		)
		axlUIWRedraw(nil)
		axlUIWUpdate(nil)
		andy_list=remdq(nil andy_list)
		;andy_list= sort(andy_list 'axlStrcmpAlpNum)
		;println(andy_list)
		if(andy_list!=nil then
			foreach(txt  andy_list
				x = nthelem(1 txt->xy) 
				y = nthelem(2 txt->xy)
				txt_layer=nil
				if(txt->isMirrored==nil then
					txt_layer="TOP"
				else
					txt_layer="BOTTOM"
				)
				testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f  -->%s" txt->text x y txt_layer) testing_next_view_num)
			)
		)
		testing_next_view_num=testing_justice_list(testing_next_view_num)
		testing_next_view_num=remdq(nil testing_next_view_num)
		testing_next_view_num= sort(testing_next_view_num 'axlStrcmpAlpNum)
		testing_cnt=length(testing_next_view_num)
		testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 4 \317\356: \327\326\267\373\326\330\270\264:\271\262  %d  \317\356" testing_cnt)
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		testing_next_view_All=testing_next_view_num
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		if(testing_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))	
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\327\326\267\373\326\330\270\264"  testing_cnt)
		axlUIWPrint(myform uidisplayer) 
		axlFormDisplay(myform)
		axlClearSelSet()
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;
;可一并检查11项
; input : no output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun  check_text_over_item ()
	(prog ()
		testing_unselect_object()
		testing_sub_texts=nil
		testing_next_view_All=nil
		testing_allnum=0
		testing_text_LostRef_flag= t
		axlFormSetField(myform "testing_text_LostRef" testing_text_LostRef_flag)
		testing_LostRef()
		testing_allnum= testing_allnum+testing_cnt

		testing_text_LostPinName_flag= t
		axlFormSetField(myform "testing_text_LostPinName" testing_text_LostPinName_flag)
		testing_LostPinName()
		testing_allnum= testing_allnum+testing_cnt
		testing_text_Rotation_flag= t
		axlFormSetField(myform "testing_text_Rotation" testing_text_Rotation_flag)
		testing_Refdes_Direction()
		testing_allnum= testing_allnum+testing_cnt

		testing_text_same_flag= t
		axlFormSetField(myform "testing_text_same" testing_text_same_flag)
		testing_Refdes_same()
		testing_allnum= testing_allnum+testing_cnt
		if(runonce_flag_testing== nil then
			testing_Creat_layer()
			testing_Allcolor_set() 
			runonce_flag_testing_flag= t
		)
		testing_text_pad = t
		axlFormSetField(myform "testing_text_pad" testing_text_pad_flag)
		testing_text_on_pad()
		testing_allnum= testing_allnum+testing_cnt
		testing_text_testpoint = t
		axlFormSetField(myform "testing_text_testpoint" testing_text_testpoint_flag)
		testing_text_on_testpoints()
		testing_allnum= testing_allnum+testing_cnt

		testing_text_shape = t
		axlFormSetField(myform "testing_text_shape" testing_text_shape_flag)
		testing_text_on_shape()
		testing_allnum= testing_allnum+testing_cnt

		testing_text_text = t
		axlFormSetField(myform "testing_text_text" testing_text_text_flag)
		testing_text_overlap_text()
		testing_allnum= testing_allnum+testing_cnt
		testing_text_line = t	

		axlFormSetField(myform "testing_text_line" testing_text_line_flag)
		testing_text_overlap_line()
		testing_allnum= testing_allnum+testing_cnt
		testing_text_Via_flag = t
		axlFormSetField(myform "testing_text_Via" testing_text_Via_flag)
		testing_text_on_Via()
		testing_allnum= testing_allnum+testing_cnt
		
		testing_line_pad_flag= t
		axlFormSetField(myform "testing_line_pad" testing_line_pad_flag)
		testing_check_line_on_pad()
		testing_allnum= testing_allnum+testing_cnt
		
		testing_text_inside_comp_flag= t
		axlFormSetField(myform "testing_text_inside_comp" testing_text_inside_comp_flag)
		testing_check_text_inside_comp()
		testing_allnum= testing_allnum+testing_cnt
		testing_text_inside_comp_flag= nil		
		
		axlFormSetField(myform "testing_text_inside_comp" testing_text_inside_comp_flag)
		uidisplayer_all=nil
		uidisplayer_all=sprintf(dummy , "\327\334\271\262  %d  \317\356\320\350\322\252\262\351\277\264\305\320\261\360"  testing_allnum)
		axlUIWPrint(myform uidisplayer_all)

		;axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		axlFormDisplay(myform)
		axlFlushDisplay()
		axlClearSelSet()
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;检查字符压pin
; input : no output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun  testing_text_on_pad ()
	(prog ()
		let( ()
			axlClearSelSet()
			testing_turn_on_layer(select_layer_flag)  
			axlSetFindFilter(?enabled '(noall text) ?onButtons '(noall text))
			alltexts = axlGetSelSet(axlAddSelectAll())
			testing_cnt = 0
			testing_next_view_num =nil
			axlClearSelSet()
			axlSetFindFilter(?enabled '(noall pins)    ?onButtons '(noall pins))
			foreach(txt alltexts 
				if(txt->layer == strcat( "REF DES/SILKSCREEN_" select_layer_flag) 
				|| txt->layer == strcat( "PACKAGE GEOMETRY/SILKSCREEN_" select_layer_flag)|| txt->layer == strcat( "BOARD GEOMETRY/SILKSCREEN_" select_layer_flag) then      
					if(axlSingleSelectBox(testing_getbox(txt)) != nil then
						allboxes = axlGetSelSet() 
						axlClearSelSet()
						have = nil
						foreach(item allboxes 
							if(item->objType == "pin" then
								axlHighlightObject(list(txt item) )
								have = t
							)
						)
						testing_next_view_All=nil
						if(have then ++testing_cnt 
							if(txt!= nil then 
								x = nthelem(1 txt->xy) 
								y = nthelem(2 txt->xy)	
								testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" txt->text x y) testing_next_view_num)
							)
						)
					)    
				)
			)
			testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 5 \317\356: \327\326\267\373\321\271\272\270\305\314:\271\262  %d  \317\356" testing_cnt)
			axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
			testing_next_view_num=remdq(nil testing_next_view_num)
			testing_next_view_All=testing_next_view_num
			axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
			if(testing_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\327\326\267\373\321\271\272\270\305\314"  testing_cnt)
			axlUIWPrint(myform uidisplayer)
			axlFormDisplay(myform)
			testing_turn_on_layer(select_layer_flag) 
			axlClearSelSet()
			axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
			axlUIWUpdate(nil)
			axlUIWRedraw(nil)
		)
	)
)	
;;;;;;;;;;;;;;;;;;;;;;;
;检查字符压测试点
; input : no output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_text_on_testpoints () ; text on testpoiints
	(prog ()
		let( (item allbox)
			axlClearSelSet()
			testing_turn_on_layer(select_layer_flag) 
			axlSetFindFilter(?enabled '(noall text) ?onButtons '(noall text))
			alltexts = axlGetSelSet(axlAddSelectAll())
			testing_cnt = 0
			axlClearSelSet()
			testing_next_view_num =nil
			axlSetFindFilter(?enabled '(noall vias)      ?onButtons '(noall vias))
			foreach(txt alltexts 
				if(txt->layer == strcat( "REF DES/SILKSCREEN_" select_layer_flag) 
				|| txt->layer == strcat( "PACKAGE GEOMETRY/SILKSCREEN_" select_layer_flag)
				|| txt->layer == strcat( "BOARD GEOMETRY/SILKSCREEN_" select_layer_flag) then      
					if(axlSingleSelectBox(testing_getbox(txt)) != nil then
						allboxes = axlGetSelSet() 
						axlClearSelSet()
						allselvia = nil
						have = nil
						foreach(item allboxes ;++k item = nthelem(k allbox);added big via
							if( item->objType == "via" && item->testPoint != nil || item->objType == "via" && rexMatchp("^T_VIA" upperCase(item->name))  then 
								axlHighlightObject(list(item txt))
								have = t
							)      
						)
						testing_next_view_All=nil
						if(have then ++testing_cnt 
							if(txt!= nil then 
								x = nthelem(1 txt->xy) 
								y = nthelem(2 txt->xy)	
								testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" txt->text x y) testing_next_view_num)
							)
						)
					)    
				) 
			)
			testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 6 \317\356: \327\326\267\373\321\271\262\342\312\324\265\343:\271\262  %d  \317\356" testing_cnt)
			axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
			testing_next_view_num=remdq(nil testing_next_view_num)
			testing_next_view_All=testing_next_view_num
			axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
			if(testing_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\327\326\267\373\321\271\262\342\312\324\265\343"  testing_cnt)
			axlUIWPrint(myform uidisplayer) 
			axlFormDisplay(myform)
			testing_turn_on_layer(select_layer_flag) 
			axlClearSelSet()
			axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
			axlUIWUpdate(nil)
			axlUIWRedraw(nil)
		)
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;检查字符压阻焊铜皮
; input : no output : no
;;;;;;;;;;;;;;;;;;;;;;; 
(defun  testing_text_on_shape ()
	(prog ()
		let( ()
			axlClearSelSet()
			testing_turn_on_layer(select_layer_flag) 
			axlSetFindFilter(?enabled '(noall text) ?onButtons '(noall text))
			alltexts = axlGetSelSet(axlAddSelectAll())
			axlClearSelSet()
			testing_cnt = 0
			testing_next_view_num =nil
			axlSetFindFilter(?enabled '(noall shapes)    ?onButtons '(noall shapes))
			foreach(txt alltexts 
				if(txt->layer == strcat( "REF DES/SILKSCREEN_" select_layer_flag) 
				|| txt->layer == strcat( "PACKAGE GEOMETRY/SILKSCREEN_" select_layer_flag)|| txt->layer == strcat( "BOARD GEOMETRY/SILKSCREEN_" select_layer_flag) then      
					if(axlSingleSelectBox(testing_getbox(txt)) != nil then
						allboxes = axlGetSelSet() 
						axlClearSelSet()
						have = nil
						foreach(item allboxes 
							if(item->objType == "shape" && item->layer == strcat( "BOARD GEOMETRY/SOLDERMASK_" select_layer_flag)|| 
							item->layer == strcat( "PACKAGE GEOMETRY/SOLDERMASK_" select_layer_flag) then
								axlHighlightObject(list(txt item) )
								have = t
							)
						)
						testing_next_view_All=nil
						if(have then ++testing_cnt 
							if(txt!= nil then 
							x = nthelem(1 txt->xy) 
							y = nthelem(2 txt->xy)	
							testing_next_view_num =cons(sprintf(dummy "%s; %0.1f; %.0.1f" txt->text x y) testing_next_view_num)
							)
						)
					)    
				)
			)
			testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 7 \317\356: \327\326\267\373\321\271\327\350\272\270\315\255\306\244:\271\262  %d  \317\356" testing_cnt)
			axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
			testing_next_view_num=remdq(nil testing_next_view_num)
			testing_next_view_All=testing_next_view_num
			axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
			if(testing_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\327\326\267\373\321\271\327\350\272\270\315\255\306\244"  testing_cnt)
			axlUIWPrint(myform uidisplayer)
			axlFormDisplay(myform)
			testing_turn_on_layer(select_layer_flag)
			axlClearSelSet()
			axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
			axlUIWUpdate(nil)
			axlUIWRedraw(nil)
		)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;
;检查字符相压
; input : no output : no
;;;;;;;;;;;;;;;;;;;;;;; 
  
(defun testing_text_overlap_text ()
	(prog ()
		let( (item allbox)
			axlClearSelSet()
			testing_turn_on_layer(select_layer_flag) 
			axlSetFindFilter(?enabled '(noall text) ?onButtons '(noall text))
			alltexts = axlGetSelSet(axlAddSelectAll())
			axlClearSelSet()
			testing_cnt = 0
			testing_next_view_num=nil
			allseltext = nil
			axlSetFindFilter(?enabled '(noall text) ?onButtons '(noall text))
			foreach(txt alltexts
				if(txt->layer == strcat( "REF DES/SILKSCREEN_" select_layer_flag) 
				|| txt->layer == strcat( "PACKAGE GEOMETRY/SILKSCREEN_" select_layer_flag)|| txt->layer == strcat( "BOARD GEOMETRY/SILKSCREEN_" select_layer_flag) then      
					if(axlSingleSelectBox(testing_getbox(txt)) != nil then
						allboxes = axlGetSelSet() 
						axlClearSelSet()
						allbox = nil
						foreach(item allboxes ;++n item = nthelem(n allboxes)
							if(item->text != txt->text then
								allbox = cons(item allbox)
							)      
						)
						have = nil
						foreach(item allbox ;++k item = nthelem(k allbox)
							if(item->objType == "text" then
								if(testing_text_on_text(txt item) != nil then 
									axlHighlightObject(list(item txt))
									have = t
								)
							)
						)
						testing_next_view_All=nil
						if(have then ++testing_cnt 
							if(txt!= nil then 
								x = nthelem(1 txt->xy) 
								y = nthelem(2 txt->xy)	
								testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" txt->text x y) testing_next_view_num)
							)
						)
					)    
				) 
			)
			testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 8 \317\356: \327\326\267\373\321\271\327\326\267\373:\271\262  %d  \317\356" testing_cnt)
			axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
			testing_next_view_num=remdq(nil testing_next_view_num)
			testing_next_view_All=testing_next_view_num
			axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
			if(testing_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\327\326\267\373\321\271\327\326\267\373"  testing_cnt)
			axlUIWPrint(myform uidisplayer)
			axlFormDisplay(myform)
			testing_turn_on_layer(select_layer_flag)  
			axlClearSelSet()
			axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
			axlUIWUpdate(nil)
			axlUIWRedraw(nil)
		)
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;判别字符相压子程序
; input : text item output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_text_on_text (text item)
	(prog ()
		(let (tt1 tt2 left top right bottom lt tp rt bm )
			tt2 = testing_getbox(item)
			lt  = car(nth(0 tt2))
			tp  = cadr(nth(0 tt2)) 
			rt  = car(nth(1 tt2))
			bm  = cadr(nth(1 tt2))
			
			tt1    = testing_getbox(text)
			left  = car(nth(0 tt1))
			top    = cadr(nth(0 tt1)) 
			right  = car(nth(1 tt1))
			bottom = cadr(nth(1 tt1))
			
			if(lt>=left && lt<=right && tp<=top && tp>=bottom return(t) )
			if(lt>=left && lt<=right && bm<=top && bm>=bottom return(t) )
			if(rt>=left && rt<=right && bm<=top && bm>=bottom return(t) )
			if(rt>=left && rt<=right && tp<=top && tp>=bottom return(t) )
			return(nil)    
		)
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;判别字符压丝印框程序
; input : no output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_text_overlap_line (); text on line
	(prog ()
		let( (item allbox)
			axlClearSelSet()
			testing_turn_on_layer(select_layer_flag) 
			axlSetFindFilter(?enabled '(noall text) ?onButtons '(noall text))
			alltexts = axlGetSelSet(axlAddSelectAll())
			axlClearSelSet()
			axlSetFindFilter(?enabled '(noall lines) ?onButtons '(noall lines))
			allselcom=nil
			testing_cnt=0
			testing_next_view_num=nil
			foreach(txt alltexts 
				if(txt->layer == strcat( "REF DES/SILKSCREEN_" select_layer_flag)
				|| txt->layer == strcat( "PACKAGE GEOMETRY/SILKSCREEN_" select_layer_flag)|| txt->layer == strcat( "BOARD GEOMETRY/SILKSCREEN_" select_layer_flag) then 
					if(axlSingleSelectBox(testing_getbox(txt)) != nil then
						allboxes = axlGetSelSet() 
						axlClearSelSet()
						have = nil
						foreach(item allboxes ;++n item = nthelem(n allboxes)
							if(item->text != txt->text then
								allbox = cons(item allbox)
							)      
						);item->layer == strcat( "PACKAGE GEOMETRY/SILKSCREEN_" select_layer_flag)
						foreach(item allbox 
							if(item->layer == strcat( "BOARD GEOMETRY/SILKSCREEN_" select_layer_flag)|| item->objType == "line" then
								allselcom = cons(item allselcom)
								allselcom = cons(txt allselcom)
								axlHighlightObject(list(txt item))
								have= t
							)
						)
						if(have then ++testing_cnt 
							if(txt->text!= nil then 
								x = nthelem(1 txt->xy) 
								y = nthelem(2 txt->xy)
								testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" txt->text x y) testing_next_view_num)
							)
						)
					)    
				) 
			)
			testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 9 \317\356: \327\326\267\373\321\271\313\277\323\241:\271\262  %d  \317\356" testing_cnt)
			axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
			testing_next_view_num=remdq(nil testing_next_view_num)
			testing_next_view_All=testing_next_view_num
			axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
			if(testing_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\327\326\267\373\321\271\313\277\323\241"  testing_cnt)
			axlUIWPrint(myform uidisplayer) 
			axlFormDisplay(myform)
			testing_turn_on_layer(select_layer_flag) 
			axlClearSelSet()
			axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
			axlUIWUpdate(nil)
			axlUIWRedraw(nil)
		)
	)
)
/*
(defun testing_text_on_Via ()
(prog ()
let( (item allbox)
axlClearSelSet()
testing_turn_on_layer(select_layer_flag) 
    axlSetFindFilter(?enabled '(noall text) ?onButtons '(noall text))
    alltexts = axlGetSelSet(axlAddSelectAll())
axlClearSelSet()
    testing_cnt = 0
	Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:VIA CLASS/paramLayer:%s" select_layer_flag))
    Going_On->visible=t
    axlSetParam(Going_On)
      axlSetFindFilter(?enabled '(noall vias)       ?onButtons '(noall vias))
testing_next_view_num=nil
foreach(txt alltexts
    if(txt->layer == strcat( "REF DES/SILKSCREEN_" select_layer_flag) 
    || txt->layer == strcat( "PACKAGE GEOMETRY/SILKSCREEN_" select_layer_flag)
	|| txt->layer == strcat( "BOARD GEOMETRY/SILKSCREEN_" select_layer_flag) then      
    if(axlSingleSelectBox(testing_getbox(txt)) != nil then
      allboxes = axlGetSelSet() 
  axlClearSelSet()
  allselvia = nil
  have = nil
      foreach(item allboxes ;++k item = nthelem(k allbox);added big via


;6030
      if( item->objType == "via" && item->name=="VIA0R60D0R30M" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      ) 
      if( item->objType == "via" && item->name=="VIA0R60D0R30M_NT" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      ) 
;;6535
      if( item->objType == "via" && item->name=="VIA0R65D0R35M" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      ) 
      if( item->objType == "via" && item->name=="VIA0R65D0R35M_NT" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      ) 
;---8040
      if( item->objType == "via" && item->name=="VIA0R80D0R40A" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      ) 
      if( item->objType == "via" && item->name=="VIA0R80D0R40A_NT" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      )      
if( item->objType == "via" && item->name=="VIA0R80D0R40F" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      ) 
if( item->objType == "via" && item->name=="VIA0R80D0R40F_NT" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      ) 
if( item->objType == "via" && item->name=="VIA0R80D0R40M" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      ) 
if( item->objType == "via" && item->name=="VIA0R80D0R40M_NT" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      ) 
  ;8045
      if( item->objType == "via" && item->name=="VIA0R80D0R45A" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      ) 
      if( item->objType == "via" && item->name=="VIA0R80D0R45A_NT" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      )      
if( item->objType == "via" && item->name=="VIA0R80D0R45F" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      ) 
if( item->objType == "via" && item->name=="VIA0R80D0R45F_NT" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      ) 
if( item->objType == "via" && item->name=="VIA0R80D0R45M" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      ) 
if( item->objType == "via" && item->name=="VIA0R80D0R45M_NT" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      )
;------9050
     if( item->objType == "via" && item->name=="VIA0R90D0R50A" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      ) 
      if( item->objType == "via" && item->name=="VIA0R90D0R50A_NT" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      )      
if( item->objType == "via" && item->name=="VIA0R90D0R50F" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      ) 
if( item->objType == "via" && item->name=="VIA0R90D0R50F_NT" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      ) 
if( item->objType == "via" && item->name=="VIA0R90D0R50M" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      ) 
if( item->objType == "via" && item->name=="VIA0R90D0R50M_NT" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      )  
;;via36d20,via50d28  
      if( item->objType == "via" && item->name=="VIA36D20" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      )
      if( item->objType == "via" && item->name=="VIA50D28" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      )


;;;

if( item->objType == "via" && item->name=="VIA1R00D0R70M" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      ) 
if( item->objType == "via" && item->name=="VIA1R00D0R70M_NT" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      )
if( item->objType == "via" && item->name=="VIA1R10D0R80M" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      ) 
if( item->objType == "via" && item->name=="VIA1R10D0R80M_NT" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      ) 
if( item->objType == "via" && item->name=="VIA1R30D0R80M" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      ) 
if( item->objType == "via" && item->name=="VIA1R30D0R80M_NT" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      )     
;;
      if( item->objType == "via" && item->name=="T_VIA0R55D0R25B-3S" then 
  allselvia = cons(txt allselvia)
          axlHighlightObject(list(item txt))
          have = t
      )
  )

  if(have then ++testing_cnt 
if(txt!= nil then 
    x = nthelem(1 txt->xy) 
    y = nthelem(2 txt->xy)
testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" txt->text x y) testing_next_view_num)
)    
)
)
)
)
testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 10 \317\356: \327\326\267\373\321\271\264\363\277\327:\271\262  %d  \317\356" testing_cnt)
axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
testing_next_view_num=remdq(nil testing_next_view_num)
testing_next_view_All=testing_next_view_num
axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
if(testing_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))
uidisplayer=nil
uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\327\326\267\373\321\271\264\363\277\327"  testing_cnt)
axlUIWPrint(myform uidisplayer)
axlFormDisplay(myform)
testing_turn_on_layer(select_layer_flag) 
	Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:VIA CLASS/paramLayer:%s" select_layer_flag))
    	Going_On->visible=t
    	axlSetParam(Going_On)
axlClearSelSet()
axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
axlUIWUpdate(nil)
axlUIWRedraw(nil)		
)))

*/
;;;;;;;;;;;;;;;;;;;;;;;
;判别字符压大孔程序
; input : no output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_text_on_Via ()
	(prog ()
		let( (item allbox)
			axlClearSelSet()
			change_mil_mm_units=0
			case(car(axlDBGetDesignUnits())
			("millimeters"  change_mil_mm_units=0.0254 )
			("mils"   change_mil_mm_units=0.9999))
			stard_via_dia=15.3*change_mil_mm_units
			testing_turn_on_layer(select_layer_flag) 
			axlSetFindFilter(?enabled '(noall text) ?onButtons '(noall text))
			alltexts = axlGetSelSet(axlAddSelectAll())
			axlClearSelSet()
			testing_cnt = 0
			Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:VIA CLASS/paramLayer:%s" select_layer_flag))
			Going_On->visible=t
			axlSetParam(Going_On)
			axlSetFindFilter(?enabled '(noall vias)       ?onButtons '(noall vias))
			testing_next_view_num=nil
			foreach(txt alltexts
				if(txt->layer == strcat( "REF DES/SILKSCREEN_" select_layer_flag) 
				|| txt->layer == strcat( "PACKAGE GEOMETRY/SILKSCREEN_" select_layer_flag)
				|| txt->layer == strcat( "BOARD GEOMETRY/SILKSCREEN_" select_layer_flag) then      
					if(axlSingleSelectBox(testing_getbox(txt)) != nil then
						allboxes = axlGetSelSet() 
						axlClearSelSet()
						allselvia = nil
						have = nil
						foreach(item allboxes 
							if( item->objType == "via" && rexMatchp("^VIA" upperCase(item->name)) && rexMatchp("M" upperCase(item->name))
							;	|| item->objType == "via" && rexMatchp("^T_VIA" upperCase(item->name)) 
							||item->objType == "via" && item->definition->drillDiameter>=stard_via_dia  then 
								allselvia = cons(txt allselvia)
								axlHighlightObject(list(item txt))
								have = t
							)
						)

						if(have then ++testing_cnt 
							if(txt!= nil then 
								x = nthelem(1 txt->xy) 
								y = nthelem(2 txt->xy)
								testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" txt->text x y) testing_next_view_num)
							)    
						)
					)
				)
			)
			testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 10 \317\356: \327\326\267\373\321\271\264\363\277\327:\271\262  %d  \317\356" testing_cnt)
			axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
			testing_next_view_num=remdq(nil testing_next_view_num)
			testing_next_view_All=testing_next_view_num
			axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
			if(testing_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\327\326\267\373\321\271\264\363\277\327"  testing_cnt)
			axlUIWPrint(myform uidisplayer)
			axlFormDisplay(myform)
			testing_turn_on_layer(select_layer_flag) 
			Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:VIA CLASS/paramLayer:%s" select_layer_flag))
			Going_On->visible=t
			axlSetParam(Going_On)
			axlClearSelSet()
			axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
			axlUIWUpdate(nil)
			axlUIWRedraw(nil)		
		)
	)
)


;;;;;;;;;;;;;;;;;;;;;;;
;判断焊盘上有丝印框子程序
; input :no  output : no
;;;;;2010.0911 由于库修改把很多+变成了线，因此这种线压阻焊铜皮的情况会造成缺1脚的情况，因此加了shape检查项
;;;;;;;;;;;;;;;;;;;;;;;

;(defun testing_check_line_on_shape ()
(defun testing_check_line_on_pad ()
	prog( ()
		axlClearSelSet()
		SBlist=nil
		subdist_pinslist=nil
		subdist_Delete_object()
		testing_unselect_object()
		axlSetFindFilter(?enabled '(noall linesegs)      ?onButtons '(noall linesegs))		
		subdist_pinslist= axlGetSelSet(axlAddSelectAll())
		axlClearSelSet()
		subdist_cnt = 0 
		axlSetFindFilter(?enabled '(noall shapes pins) ?onButtons '(noall shapes pins))
		foreach(pinitem subdist_pinslist
			if(pinitem->layer == strcat( "PACKAGE GEOMETRY/SILKSCREEN_" select_layer_flag)|| pinitem->layer == strcat( "BOARD GEOMETRY/SILKSCREEN_" select_layer_flag) then
				if(axlSingleSelectBox(pinitem->bBox)!= nil  then
					allboxes = axlGetSelSet()
					axlClearSelSet()
					have = nil
					foreach(item allboxes 
						if(item->objType == "shape"  then
							if(item->layer == strcat( "BOARD GEOMETRY/SOLDERMASK_" select_layer_flag) || item->layer == strcat( "PACKAGE GEOMETRY/SOLDERMASK_" select_layer_flag) then
								axlHighlightObject(pinitem)
								axlHighlightObject(item)
								have = t
							)
						else
							if(item->objType=="pin" && rexMatchp("SM" item->name) && 
							axlAirGap(pinitem item strcat( "ETCH/" select_layer_flag))!= nil && abs(nthelem(3 axlAirGap(pinitem item strcat( "ETCH/" select_layer_flag)))-0.0)<=1*change_mil_mm_units then
								axlHighlightObject(pinitem)
								axlHighlightObject(item)
								have = t
							)
							
						)
						if(have then SBlist=cons(pinitem SBlist))
					)
				)
			)
		)
		SBlist=testing_justice_list(SBlist)
		SBlist=remdq(nil SBlist)
		testing_next_view_num=nil
		if(SBlist==nil then
			testing_next_view_num=cons("OK" testing_next_view_num)
		else
			foreach(symitem SBlist
				itemx=car(nthelem(1 symitem->bBox))
				itemy=cadr(nthelem(1 symitem->bBox))
				println(itemx:itemy)
				testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->objType itemx itemy) testing_next_view_num)
				++subdist_cnt
			)
		)
		testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 11 \317\356: \313\277\323\241\321\271\272\270\305\314:\271\262  %d  \317\356" subdist_cnt)
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		testing_next_view_num=remdq(nil testing_next_view_num)
		testing_next_view_All=testing_next_view_num
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		;if(subdist_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\321\271\272\270\305\314:\271"  subdist_cnt)
		axlUIWPrint(myform uidisplayer)
		axlFormDisplay(myform)
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)
	)
)

/*
(defun testing_check_line_on_pad ()
	prog( ()
		axlClearSelSet()
		SBlist=nil
		subdist_pinslist=nil
		subdist_Delete_object()
		testing_unselect_object()
		axlSetFindFilter(?enabled '(noall pins) ?onButtons '(noall pins))
		subdist_pinslist= axlGetSelSet(axlAddSelectAll())
		axlClearSelSet()
		subdist_cnt = 0 
		axlSetFindFilter(?enabled '(noall linesegs)      ?onButtons '(noall linesegs))
		foreach(pinitem subdist_pinslist 
			if(rexMatchp("SMD" pinitem->name)  then
				if(axlSingleSelectBox(subdist_getbox(pinitem)) != nil then
					allboxes = axlGetSelSet()
					axlClearSelSet()
					allselvia = nil
					have = nil
					foreach(item allboxes 
						if( item->objType == "line"  then
							if(item->layer == strcat( "PACKAGE GEOMETRY/SILKSCREEN_" select_layer_flag)|| item->layer == strcat( "BOARD GEOMETRY/SILKSCREEN_" select_layer_flag) then
								axlHighlightObject( pinitem->parent t)
								have = t
							)
						)
						if(have then SBlist=cons(pinitem->parent SBlist))
					)
				)
			)
		)
		SBlist=testing_justice_list(SBlist)
		SBlist=remdq(nil SBlist)
		testing_next_view_num=nil
	
		if(SBlist==nil then
			testing_next_view_num=cons("OK" testing_next_view_num)
		else
			foreach(symitem SBlist
				if(rexMatchp("^MARK" upperCase(symitem->name)) then
					itemx=car(symitem->xy)
					itemy=cadr(symitem->xy)
					testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->name itemx itemy) testing_next_view_num)
				else
					itemx=car(symitem->xy)
					itemy=cadr(symitem->xy)
					testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->refdes itemx itemy) testing_next_view_num)
				)
				++subdist_cnt
			)
		)
		testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 11 \317\356: \313\277\323\241\321\271\272\270\305\314:\271\262  %d  \317\356" subdist_cnt)
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		testing_next_view_num=remdq(nil testing_next_view_num)
		testing_next_view_All=testing_next_view_num
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		;if(subdist_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\321\271\272\270\305\314:\271"  subdist_cnt)
		axlUIWPrint(myform uidisplayer)
		axlFormDisplay(myform)
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)
	)
)
*/
;;;;;;;;;;;;;;;;;;;;;;;
;检查字符可能在器件体内的子程序
; input : no output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_check_text_inside_comp ()
	prog(()
		testing_next_view_num= nil
		axlClearSelSet()
		testing_cnt = 0
		subdist_Delete_object()
		testing_unselect_object()
		testing_turn_on_layer(select_layer_flag)
		axlSetFindFilter(?enabled '("noall" "components") ?onButtons '("noall" "components")) 
		if(select_layer_flag=="TOP" then 
			layersym_list=axlGetSelSet(axlAddSelectAll())
			foreach( compitem  layersym_list
				if(compitem->symbol->isMirrored==t then
					layersym_list=remove(compitem layersym_list)
				)
			)
					layersym_list=remdq(nil layersym_list)
		else
			layersym_list=axlGetSelSet(axlAddSelectAll())
			foreach( compitem  layersym_list
				if(compitem->symbol->isMirrored==nil then
					layersym_list=remove(compitem layersym_list)
				)
			)
		)
		axlClearSelSet()
		andy_list=nil		
		andy_list=testing_check_text_in_comp(layersym_list)
		andy_list=testing_justice_list(andy_list)
		andy_list=remdq(nil andy_list)
		if(andy_list!=nil then
			foreach(txt  andy_list
/*
				if(txt->parent!=nil then
					x = nthelem(1 txt->xy) 
					y = nthelem(2 txt->xy)
					testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f  -->%s" txt->parent->refdes x y) testing_next_view_num)
				else
*/
					x = nthelem(1 txt->xy) 
					y = nthelem(2 txt->xy)
					testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" txt->text x y) testing_next_view_num)
					++testing_cnt
				;)
			)
		)
		testing_next_view_num=testing_justice_list(testing_next_view_num)
		testing_next_view_num=remdq(nil testing_next_view_num)
		testing_next_view_num= sort(testing_next_view_num 'axlStrcmpAlpNum)
		testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 12 \317\356:\327\326\267\373\321\271\306\367\274\376\314\345:\271\262  %d  \317\356" testing_cnt)
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		testing_next_view_All=testing_next_view_num
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		if(testing_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))	
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\327\326\267\373\326\330\270\264"  testing_cnt)
		axlUIWPrint(myform uidisplayer) 
		axlFormDisplay(myform)
		axlClearSelSet()
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;
;检查字符可能在器件体内的子程序
; input : layersym_list output : SBlist
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_check_text_in_comp (layersym_list)
	prog(()
		SBlist=nil	
		foreach(item layersym_list
			if(item->symbol->refdes!=nil then
				get_line_list=nil
				minx=0
				miny=0
				maxx=0
				maxy=0
				foreach(item_outline item->symbol->children
					if(item_outline->objType=="path" && 
						item_outline->layer==strcat("PACKAGE GEOMETRY/SILKSCREEN_" select_layer_flag) then
						get_line_list=append(item_outline->segments get_line_list)
					)
				)
				get_line_list=remdq(nil get_line_list)	
				if(get_line_list!=nil then		
					get_line_max_min=nil
					get_line_max_min=testingfind_getmax_min(get_line_list)
					minx=car(nthelem(1 get_line_max_min))
					miny=cadr(nthelem(1 get_line_max_min))
					maxx=car(nthelem(2 get_line_max_min))
					maxy=cadr(nthelem(2 get_line_max_min))
					getbox=nil
					allboxes=nil
					getbox=list(minx:miny maxx:maxy)
					;axlDBCreateRectangle(getbox  nil )
					axlSetFindFilter(?enabled '("noall"  "text" ) ?onButtons '("noall" "text" ))
					if(axlSingleSelectBox(getbox)!=nil then
						allboxes = axlGetSelSet() 
						axlClearSelSet()
						foreach(txt_item allboxes
							txt_item_box=testing_getbox(txt_item)
							txt_item_minx=car(nthelem(1 txt_item_box))
							txt_item_miny=cadr(nthelem(1 txt_item_box))
							txt_item_maxx=car(nthelem(2 txt_item_box))
							txt_item_maxy=cadr(nthelem(2 txt_item_box))
							if(txt_item_minx>minx && txt_item_maxx<maxx && txt_item_miny>miny && txt_item_maxy<maxy then
								if(txt_item->xy
									if(txt_item->parent!=nil then
										axlHighlightObject(txt_item->parent t) 
										SBlist=cons(txt_item SBlist)
									else
										axlHighlightObject(txt_item) 
										SBlist=cons(txt_item SBlist)
									)
								)
							)
						)
					)
				)
			)
		)
		return(SBlist)
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;判别字符大小box子程序
; input : txt output : list
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_getbox (txt)
	(prog ()

		loff = 0 toff = 0 roff = 0 boff = 0
		left = car(nth(0 txt->bBox)) - Input_float_flag
		top = cadr(nth(1 txt->bBox)) + Input_float_flag 
		right = car(nth(1 txt->bBox)) + Input_float_flag
		bottom = cadr(nth(0 txt->bBox)) - Input_float_flag
		if(txt->text == "+" || txt->text == "o" || txt->text == "-" then 
			toff = round(abs(top - bottom))*0.35
			roff = round(abs(right - left))*0.35
			left = left+roff  bottom = bottom + toff 
			right = right- roff  top = top - toff
			t  
		else

			if(select_layer_flag== "TOP" then
				case(round(txt->rotation)
					(0
						toff=0
						boff = round(abs(top - bottom))*0.24
						loff = round(abs(right - left))*0.05
						roff = round(abs(right - left))*0.05
						left = left + loff  top = top - toff  
						right = right - roff  bottom = bottom + boff
						t 
					)
					(90
						toff=round(abs(top - bottom))*0.05
						boff = round(abs(top - bottom))*0.05
						loff = 0
						roff = round(abs(right - left))*0.24
						;boff = round(abs(right - left)/5)+3
						left = left + loff  top = top - toff  
						right = right - roff  bottom = bottom + boff
						t 
					)
					(180
						toff=round(abs(top - bottom))*0.24
						boff = 0
						loff = round(abs(right - left))*0.05
						roff = round(abs(right - left))*0.05
						;boff = round(abs(right - left)/5)+3
						left = left + loff  top = top - toff  
						right = right - roff  bottom = bottom + boff
						t 
					)
					(270
						toff=round(abs(top - bottom))*0.05
						boff = round(abs(top - bottom))*0.05
						loff = round(abs(right - left))*0.24
						roff = 0
						left = left + loff  top = top - toff  
						right = right - roff  bottom = bottom + boff
						t 
					)
				)
			)    
			if(select_layer_flag == "BOTTOM" then
				case(round(txt->rotation)
					(0
						toff=0
						boff = round(abs(top - bottom))*0.24
						loff = round(abs(right - left))*0.05
						roff = round(abs(right - left))*0.05 
						left = left + loff  top = top - toff  
						right = right - roff  bottom = bottom + boff
						t 
					)
					(90
						toff=round(abs(top - bottom))*0.05
						boff = round(abs(top - bottom))*0.05
						loff = 0
						roff = round(abs(right - left))*0.24 
						left = left + loff  top = top - toff  
						right = right - roff  bottom = bottom + boff
						t 
					)
					(180
						toff=round(abs(top - bottom))*0.24
						boff = 0
						loff = round(abs(right - left))*0.05
						roff = round(abs(right - left))*0.05 
						left = left + loff  top = top - toff  
						right = right - roff  bottom = bottom + boff
						t 
					)
					(270
						toff=round(abs(top - bottom))*0.05
						boff = round(abs(top - bottom))*0.05
						loff = round(abs(right - left))*0.24 
						roff = 0
						left = left + loff  top = top - toff  
						right = right - roff  bottom = bottom + boff
						t 
					)          
				);case    
			)
		)
		;axlDBCreateRectangle(list(left:top right:bottom) nil "PACKAGE GEOMETRY/Display_Bottom")
		return(list(left:bottom right:top))    
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;可检查距离7项程序
; input : txt output : list
;;;;;;;;;;;;;;;;;;;;;;;
(defun subdist_checkitem_to_symbols ()
	testing_unselect_object()
	subdist_allnum=0

	senddis_border_flag= t
	axlFormSetField(myform "senddis_border" senddis_border_flag)
	subdist_check_send_border()
	subdist_allnum=subdist_allnum+subdist_cnt
	holedis_r5mm_flag= t
	axlFormSetField(myform "holedis_r5mm" holedis_r5mm_flag)
	subdist_check_mount_hole()
	subdist_allnum=subdist_allnum+subdist_cnt
	pressdist_fit_flag= t
	axlFormSetField(myform "pressdist_fit" pressdist_fit_flag)
	subdist_check_pressfit(Input_float_flag)
	subdist_allnum=subdist_allnum+subdist_cnt
	subdist_check_BGA_flag= t
	axlFormSetField(myform "subdist_check_BGA" subdist_check_BGA_flag)
	subdist_check_BGA_range()
	subdist_allnum=subdist_allnum+subdist_cnt
	via_pad_flag= t
	 axlFormSetField(myform "via_pad" via_pad_flag)
	subdist_check_via_on_pad()
	subdist_allnum=subdist_allnum+subdist_cnt
	shape_pad_flag= t
	axlFormSetField(myform "shape_pad" shape_pad_flag)
	subdist_check_thermal_on_pad()
	subdist_allnum=subdist_allnum+subdist_cnt
	pin_pad_flag= t
	axlFormSetField(myform "pin_pad" pin_pad_flag)
	testing_check_pin_range()
	subdist_allnum=subdist_allnum+subdist_cnt	
	pin_pad_flag= nil
	axlFormSetField(myform "pin_pad" pin_pad_flag)
	uidisplayer_all=nil
	uidisplayer_all=sprintf(dummy , "\327\334\271\262  %d  \317\356\320\350\322\252\262\351\277\264\305\320\261\360"  subdist_allnum)
	axlUIWPrint(myform uidisplayer_all)

	axlFormDisplay(myform)
	axlFlushDisplay()
)
;;;;;;;;;;;;;;;;;;;;;;;
;安装孔距离主程序，显示5mm圆和3.5mm圆
; input : no output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun subdist_check_mount_hole ()
	prog( ()
		axlClearSelSet()
		subdist_Delete_object()
		testing_unselect_object()
		axlSetFindFilter(?enabled '(noall symbols) ?onButtons '(noall symbols))
		subdist_symslist= axlGetSelSet(axlAddSelectAll())
		axlClearSelSet()
		subdist_cnt = 0 
		SBlist=nil
		symitem=nil
		right_detR=0
		left_detr=0
		foreach(symitem subdist_symslist
			if(symitem->type == "PACKAGE" then 
				if(rexMatchp("^HOLE" upperCase(symitem->name)) then
					foreach(pinitem symitem->pins
						if( rexMatchp("^THC0R00" upperCase(pinitem->name)) then
							units=car(axlDBGetDesignUnits())	
							if( (units=="mils") then
							subdist_clearance=196.84 subdist_clearance_small=137.795 change_mil_mm_units_offset=5.9)
							if( (units=="millimeters") then
							subdist_clearance=5 subdist_clearance_small=3.5 change_mil_mm_units_offset=0.15)
							pintitemReg=axlDBGetPad(pinitem strcat("etch/"  select_layer_flag) "regular")
							;pinitemDiam=(pinitem->definition->drillDiameter)*0.5
							;pinitemDiam=(pinitem->definition->drillFigureWidth)*0.5
							pintitemReg_left=car(nthelem(1 pintitemReg->bBox))
							pintitemReg_right=car(nthelem(2 pintitemReg->bBox))
							pinitemRius=abs(pintitemReg_left-pintitemReg_right)*0.5
							axlDBCreateCircle(( list pinitem->xy pinitemRius+subdist_get_clearance(subdist_clearance)-change_mil_mm_units_offset), 0, strcat("PACKAGE GEOMETRY/Display_" select_layer_flag))
							axlDBCreateCircle(( list pinitem->xy pinitemRius+subdist_get_clearance(subdist_clearance_small)-change_mil_mm_units_offset), 0, strcat("PACKAGE GEOMETRY/Display_" select_layer_flag))
							subdist_check_distance_on_pin(pinitem)
						)
					)
				)
			)
			if(symitem->type == "MECHANICAL" then 
				x_det=0
				y_det=0
				left=0
				bottom=0
				top=0
				right=0
				xr=0
				yr=0
				foreach(pinitem symitem->children
					if(pinitem->objType="shape" && pinitem->layer==strcat("ROUTE KEEPOUT/" select_layer_flag)  && pinitem->isRect!=t && pinitem->nSegs<3  then
						left=car(nthelem(1 pinitem->bBox))
						bottom=cadr(nthelem(1 pinitem->bBox))
						right=car(nthelem(2 pinitem->bBox)) 
						top=cadr(nthelem(2 pinitem->bBox))
						y_det=abs(top-bottom)/2
						x_det=abs(left-right)/2
						xr=left+x_det
						yr=bottom+y_det
						case(car(axlDBGetDesignUnits())
							("mils"	subdist_clearance=196.84
								axlDBCreateCircle( (list xr:yr y_det+subdist_clearance), 0, strcat("PACKAGE GEOMETRY/Display_" select_layer_flag))
							)
							("millimeters" subdist_clearance=5
								axlDBCreateCircle( (list xr:yr y_det+subdist_clearance), 0, strcat("PACKAGE GEOMETRY/Display_" select_layer_flag))
							)
						)
						case(car(axlDBGetDesignUnits())
							("mils"	subdist_clearance=137.795
								axlDBCreateCircle( (list xr:yr y_det+subdist_clearance), 0, strcat("PACKAGE GEOMETRY/Display_" select_layer_flag))
							)
							("millimeters" subdist_clearance=3.5
								axlDBCreateCircle( (list xr:yr y_det+subdist_clearance), 0, strcat("PACKAGE GEOMETRY/Display_" select_layer_flag))
							)
						)
						subdist_check_distance_on_mount(pinitem)
					)
				)
			)
		)
		testing_next_view_num=nil
		SBlist=testing_justice_list(SBlist)
		SBlist=remdq(nil SBlist)
		if(SBlist==nil then
			testing_next_view_num=cons("OK" testing_next_view_num)
		else
			foreach(symitem SBlist
				if(rexMatchp("^MARK" upperCase(symitem->name)) then
					itemx=car(symitem->xy)
					itemy=cadr(symitem->xy)
					testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->name itemx itemy) testing_next_view_num)
				else
					itemx=car(symitem->xy)
					itemy=cadr(symitem->xy)
					testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->refdes itemx itemy) testing_next_view_num)
				)
				++subdist_cnt
			)
		)
		testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 1 \317\356: \260\262\327\260\277\327\326\334\316\247\276\340\300\353:\271\262  %d  \317\356" subdist_cnt)
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		testing_next_view_All=testing_next_view_num
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\260\262\327\260\277\327\326\334\316\247\276\340\300\353"  subdist_cnt)
		axlUIWPrint(myform uidisplayer)
		axlFormDisplay(myform)
		testing_turn_on_layer(select_layer_flag)  
		axlVisibleLayer(strcat("PACKAGE GEOMETRY/Display_" select_layer_flag)  t)
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;判断电容，BGA和晶振到模板级安装孔距离子程序
; input : itemgap output :SBlist
;;;;;;;;;;;;;;;;;;;;;;;
;scale range 4->5,160->200
(defun subdist_check_distance_on_mount (itemgap)
	prog( ()
		axlSetFindFilter(?enabled list("noall" "pins")  ?onButtons list("noall" "pins"))
		axlOpenFindFilter()
		if(axlSingleSelectBox(subdist_get_airgapbox(itemgap))!= nil then
			allboxes = axlGetSelSet()
			axlClearSelSet()
			allbox = nil
			have = nil
			center_right=0
			center_left=0
			center_x=0
			subdist_yihan_clearance=0
			case(car(axlDBGetDesignUnits())
				("millimeters" subdist_yihan_clearance=5)
				("mils" subdist_yihan_clearance=196.84)
			)
			center_left=car(nthelem(1 itemgap->bBox))
			center_right=car(nthelem(2 itemgap->bBox))
			center_x=left+abs(right-left)/2
			foreach(itempin allboxes ;				
				if( itempin->parent!= nil  then
					if( rexMatchp("^CBGA" upperCase(itempin->parent->name))  || rexMatchp("^PBGA" upperCase(itempin->parent->name)) 
					|| 	rexMatchp("^LGA" upperCase(itempin->parent->name))  ||	rexMatchp("^R-PBGA" upperCase(itempin->parent->name))
					|| rexMatchp("^R-CBGA" upperCase(itempin->parent->name)) ||	rexMatchp("^CCGA" upperCase(itempin->parent->name)) 
					|| rexMatchp("^R-XBGA" upperCase(itempin->parent->name))  then
						case(car(axlDBGetDesignUnits())
							("millimeters" subdist_clearance= 3 )
							("mils" subdist_clearance=118.11)
						)
						minx=0
						miny=0
						maxx=0
						maxy=0
						foreach(item_outline itempin->parent->children
							if(item_outline->objType=="path" && 
							item_outline->layer==strcat("PACKAGE GEOMETRY/SILKSCREEN_" select_layer_flag) then
								foreach(item_outline_seg item_outline->segments
									item1_item2_airgap=axlAirGap(item_outline_seg itemgap strcat( "ETCH/" select_layer_flag))
									if(item1_item2_airgap!=nil && nthelem(3 item1_item2_airgap)<=subdist_clearance then
										axlHighlightObject(itempin->parent t)
										SBlist=cons(itempin->parent SBlist)
									)
								)
							)
						)
					)
					if( rexMatchp("^CO2" upperCase(itempin->parent->name)) &&  rexMatchp("SM" upperCase(itempin->parent->name)) 
					||rexMatchp("^CO3" upperCase(itempin->parent->name)) ||rexMatchp("^CO4" upperCase(itempin->parent->name)) 
					|| rexMatchp("^CO5" upperCase(itempin->parent->name)) ||rexMatchp("^CO6" upperCase(itempin->parent->name))
					|| rexMatchp("^CO7" upperCase(itempin->parent->name)) then
						case(car(axlDBGetDesignUnits())
							("millimeters" subdist_clearance=10)
							("mils" subdist_clearance=393.7)
						)
						if(nthelem(3 axlAirGap(itempin itemgap strcat( "ETCH/" select_layer_flag)))<subdist_clearance then
							axlHighlightObject(itempin->parent t) 
							SBlist=cons(itempin->parent SBlist)
						)
					)
					if(abs(car(itempin->xy)-center_x)>subdist_yihan_clearance   then
						if(abs(itempin->rotation - 0.0) < 5.0 || abs(itempin->rotation - 180.0) < 5.0|| abs(itempin->rotation - 360.0) < 5.0  then
							if(rexMatchp("^0805C" upperCase(itempin->parent->name)) || rexMatchp("^1206C" upperCase(itempin->parent->name))  then
								case(car(axlDBGetDesignUnits())
									("millimeters" subdist_clearance=5)
									("mils" subdist_clearance=196.84 )
								)
								if(nthelem(3 axlAirGap(itempin itemgap strcat( "ETCH/" select_layer_flag)))<subdist_clearance then  
									axlHighlightObject(itempin->parent t) 
									SBlist=cons(itempin->parent SBlist)
								)
							)
							if(rexMatchp("^1210C" upperCase(itempin->parent->name)) || rexMatchp("^1608C" upperCase(itempin->parent->name)) 
							|| rexMatchp("^2012C" upperCase(itempin->parent->name)) || rexMatchp("^2016C" upperCase(itempin->parent->name)) 
							|| rexMatchp("^2512C" upperCase(itempin->parent->name)) || rexMatchp("^3216C" upperCase(itempin->parent->name))
							|| rexMatchp("^1812C" upperCase(itempin->parent->name)) || rexMatchp("^2220C" upperCase(itempin->parent->name)) then
								case(car(axlDBGetDesignUnits())
									("millimeters" subdist_clearance=10)
									("mils" subdist_clearance=393.7)
								)
								if(nthelem(3 axlAirGap(itempin itemgap strcat( "ETCH/" select_layer_flag)))<subdist_clearance then  
									axlHighlightObject(itempin->parent t) 
									SBlist=cons(itempin->parent SBlist)
								)
							)
							if(rexMatchp("^0603C" upperCase(itempin->parent->name)) || rexMatchp("^0402C" upperCase(itempin->parent->name))  then
							case(car(axlDBGetDesignUnits())
							("millimeters" subdist_clearance=4)
							("mils" subdist_clearance=157.48 )
							)
							if(nthelem(3 axlAirGap(itempin itemgap strcat( "ETCH/" select_layer_flag)))<subdist_clearance then  
							axlHighlightObject(itempin->parent t) 
							SBlist=cons(itempin->parent SBlist)
							)
							)
						)
						if(abs(itempin->rotation - 90.0) < 5.0 || abs(itempin->rotation - 270.0) < 5.0  then
							if(rexMatchp("^0805C" upperCase(itempin->parent->name)) || rexMatchp("^1206C" upperCase(itempin->parent->name))  then
								case(car(axlDBGetDesignUnits())
									("millimeters" subdist_clearance=3.5)
									("mils" subdist_clearance=137.795 )
								)
								if(nthelem(3 axlAirGap(itempin itemgap strcat( "ETCH/" select_layer_flag)))<subdist_clearance then  
									axlHighlightObject(itempin->parent t) 
									SBlist=cons(itempin->parent SBlist)
								)
							)
							if(rexMatchp("^1210C" upperCase(itempin->parent->name)) || rexMatchp("^1608C" upperCase(itempin->parent->name))
							|| rexMatchp("^2012C" upperCase(itempin->parent->name)) || rexMatchp("^2016C" upperCase(itempin->parent->name)) 
							|| rexMatchp("^2512C" upperCase(itempin->parent->name)) || rexMatchp("^3216C" upperCase(itempin->parent->name))
							|| rexMatchp("^1812C" upperCase(itempin->parent->name)) || rexMatchp("^2220C" upperCase(itempin->parent->name)) then
								case(car(axlDBGetDesignUnits())
									("millimeters" subdist_clearance=10)
									("mils" subdist_clearance=393.7 )
								)
								if(nthelem(3 axlAirGap(itempin itemgap strcat( "ETCH/" select_layer_flag)))<subdist_clearance then  
									axlHighlightObject(itempin->parent t) 
									SBlist=cons(itempin->parent SBlist)
								)
							)
							if(rexMatchp("^0603C" upperCase(itempin->parent->name)) ||rexMatchp("^0402C" upperCase(itempin->parent->name))  then
								case(car(axlDBGetDesignUnits())
								("millimeters" subdist_clearance=2.5)
								("mils" subdist_clearance=98.42 ))
								if(nthelem(3 axlAirGap(itempin itemgap strcat( "ETCH/" select_layer_flag)))<subdist_clearance then  
									axlHighlightObject(itempin->parent t) 
									SBlist=cons(itempin->parent SBlist)
								)
							)
						)
					else
						if(abs(itempin->rotation - 0.0) < 5.0 || abs(itempin->rotation - 180.0) < 5.0|| abs(itempin->rotation - 360.0) < 5.0  then
							if(rexMatchp("^0805C" upperCase(itempin->parent->name)) || rexMatchp("^1206C" upperCase(itempin->parent->name))  then
								case(car(axlDBGetDesignUnits())
								("millimeters" subdist_clearance=3.5)
								("mils" subdist_clearance=137.795 ))
								if(nthelem(3 axlAirGap(itempin itemgap strcat( "ETCH/" select_layer_flag)))<subdist_clearance then  
									axlHighlightObject(itempin->parent t) 
									SBlist=cons(itempin->parent SBlist)
								)
							)
							if(rexMatchp("^1210C" upperCase(itempin->parent->name)) || rexMatchp("^1608C" upperCase(itempin->parent->name)) 
							|| rexMatchp("^2012C" upperCase(itempin->parent->name)) || rexMatchp("^2016C" upperCase(itempin->parent->name)) 
							|| rexMatchp("^2512C" upperCase(itempin->parent->name)) || rexMatchp("^3216C" upperCase(itempin->parent->name))
							|| rexMatchp("^1812C" upperCase(itempin->parent->name)) || rexMatchp("^2220C" upperCase(itempin->parent->name)) then
								case(car(axlDBGetDesignUnits())
								("millimeters" subdist_clearance=10)
								("mils" subdist_clearance=393.7 ))
								if(nthelem(3 axlAirGap(itempin itemgap strcat( "ETCH/" select_layer_flag)))<subdist_clearance then  
									axlHighlightObject(itempin->parent t) 
									SBlist=cons(itempin->parent SBlist)
								)
							)
							if(rexMatchp("^0603C" upperCase(itempin->parent->name)) ||rexMatchp("^0402C" upperCase(itempin->parent->name))  then
								case(car(axlDBGetDesignUnits())
								("millimeters" subdist_clearance=2.5)
								("mils" subdist_clearance=98.42 ))
								if(nthelem(3 axlAirGap(itempin itemgap strcat( "ETCH/" select_layer_flag)))<subdist_clearance then  
									axlHighlightObject(itempin->parent t) 
									SBlist=cons(itempin->parent SBlist)
								)
							)
						)
						if(abs(itempin->rotation - 90.0) < 5.0 || abs(itempin->rotation - 270.0) < 5.0  then
							if(rexMatchp("^0805C" upperCase(itempin->parent->name)) || rexMatchp("^1206C" upperCase(itempin->parent->name))  then
								case(car(axlDBGetDesignUnits())
								("millimeters" subdist_clearance=5)
								("mils" subdist_clearance=196.84 ))
								if(nthelem(3 axlAirGap(itempin itemgap strcat( "ETCH/" select_layer_flag)))<subdist_clearance then  
									axlHighlightObject(itempin->parent t) 
									SBlist=cons(itempin->parent SBlist)
								)
							)
							if(rexMatchp("^1210C" upperCase(itempin->parent->name)) || rexMatchp("^1608C" upperCase(itempin->parent->name)) 
							|| rexMatchp("^2012C" upperCase(itempin->parent->name)) || rexMatchp("^2016C" upperCase(itempin->parent->name)) 
							|| rexMatchp("^2512C" upperCase(itempin->parent->name)) || rexMatchp("^3216C" upperCase(itempin->parent->name))
							|| rexMatchp("^1812C" upperCase(itempin->parent->name)) || rexMatchp("^2220C" upperCase(itempin->parent->name)) then
								case(car(axlDBGetDesignUnits())
								("millimeters" subdist_clearance=10)
								("mils" subdist_clearance=393.7))
								if(nthelem(3 axlAirGap(itempin itemgap strcat( "ETCH/" select_layer_flag)))<subdist_clearance then  
									axlHighlightObject(itempin->parent t) 
									SBlist=cons(itempin->parent SBlist)
								)
							)
							if(rexMatchp("^0603C" upperCase(itempin->parent->name)) ||rexMatchp("^0402C" upperCase(itempin->parent->name))  then
								case(car(axlDBGetDesignUnits())
								("millimeters" subdist_clearance=4)
								("mils" subdist_clearance=157.48 ))
								if(nthelem(3 axlAirGap(itempin itemgap strcat( "ETCH/" select_layer_flag)))<subdist_clearance then  
									axlHighlightObject(itempin->parent t) 
									SBlist=cons(itempin->parent SBlist)
								)
							)
						)
					)
				)
			)
		)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;
;判断电容，BGA和晶振到器件级安装孔距离子程序
; input : itemgap output :SBlist
;;;;;;;;;;;;;;;;;;;;;;;

(defun subdist_check_distance_on_pin (itemgap)
	prog( ()
		axlSetFindFilter(?enabled list("noall" "pins")  ?onButtons list("noall" "pins"))
		axlOpenFindFilter()
		if(axlSingleSelectBox(subdist_get_airgapbox(itemgap))!= nil then
			allboxes = axlGetSelSet()
			axlClearSelSet()
			allbox = nil
			have = nil
			subdist_yihan_clearance=0
			case(car(axlDBGetDesignUnits())
			("millimeters" subdist_yihan_clearance=5)
			("mils" subdist_yihan_clearance=196.84 ))
			foreach(itempin allboxes
				if(itempin->parent!= nil && itempin->xy!=itemgap->xy then
	;				allbox=cons(item allbox)))
	;				foreach(itempin allbox ;				
	;					if( itempin->parent!= nil  then 
					if( rexMatchp("^CBGA" upperCase(itempin->parent->name))  || rexMatchp("^PBGA" upperCase(itempin->parent->name)) 
					|| 	rexMatchp("^LGA" upperCase(itempin->parent->name))  ||	rexMatchp("^R-PBGA" upperCase(itempin->parent->name))
					|| rexMatchp("^R-CBGA" upperCase(itempin->parent->name)) ||	rexMatchp("^CCGA" upperCase(itempin->parent->name)) 
					|| rexMatchp("^R-XBGA" upperCase(itempin->parent->name))  then
						case(car(axlDBGetDesignUnits())
						("millimeters" subdist_clearance= 3 )
						("mils" subdist_clearance=118.11))
						minx=0
						miny=0
						maxx=0
						maxy=0
						foreach(item_outline itempin->parent->children
							if(item_outline->objType=="path" && item_outline->layer==strcat("PACKAGE GEOMETRY/SILKSCREEN_" select_layer_flag) then
								foreach(item_outline_seg item_outline->segments
										item1_item2_airgap=axlAirGap(item_outline_seg itemgap strcat( "ETCH/" select_layer_flag))
									if(item1_item2_airgap!=nil && nthelem(3 item1_item2_airgap)<subdist_get_clearance(subdist_clearance) then
										axlHighlightObject(itempin->parent t)
										SBlist=cons(itempin->parent SBlist)
									)
								)
							)
						)
					)
					if(rexMatchp("^CO2" upperCase(itempin->parent->name)) &&  rexMatchp("SM" upperCase(itempin->parent->name)) 
						||rexMatchp("^CO3" upperCase(itempin->parent->name)) ||rexMatchp("^CO4" upperCase(itempin->parent->name)) 
						|| rexMatchp("^CO5" upperCase(itempin->parent->name)) ||rexMatchp("^CO6" upperCase(itempin->parent->name))
						|| rexMatchp("^CO7" upperCase(itempin->parent->name)) then
						case(car(axlDBGetDesignUnits())
						("millimeters" subdist_clearance=10)
						("mils" subdist_clearance=393.7))
						if(nthelem(3 axlAirGap(itempin itemgap strcat( "ETCH/" select_layer_flag)))<subdist_get_clearance(subdist_clearance) then
							axlHighlightObject(itempin->parent t) 
							SBlist=cons(itempin->parent SBlist)
						)
					)

					if(abs(car(itempin->xy)-car(itemgap->xy))>subdist_yihan_clearance   then
						if(abs(itempin->rotation - 0.0) < 5.0 || abs(itempin->rotation - 180.0) < 5.0 || abs(itempin->rotation - 360.0) < 5.0 then
							if(rexMatchp("^0805C" upperCase(itempin->parent->name)) || rexMatchp("^1206C" upperCase(itempin->parent->name)) then
								case(car(axlDBGetDesignUnits())
								("millimeters" subdist_clearance=5)
								("mils" subdist_clearance=196.84 ))
								 if(nthelem(3 axlAirGap(itempin itemgap strcat( "ETCH/" select_layer_flag)))<subdist_get_clearance(subdist_clearance) then  
								axlHighlightObject(itempin->parent t) 
								SBlist=cons(itempin->parent SBlist)
								)
							)
							if(rexMatchp("^1210C" upperCase(itempin->parent->name)) || rexMatchp("^1608C" upperCase(itempin->parent->name))
							|| rexMatchp("^2012C" upperCase(itempin->parent->name)) || rexMatchp("^2016C" upperCase(itempin->parent->name)) 
							|| rexMatchp("^2512C" upperCase(itempin->parent->name)) || rexMatchp("^3216C" upperCase(itempin->parent->name))
							|| rexMatchp("^1812C" upperCase(itempin->parent->name)) || rexMatchp("^2220C" upperCase(itempin->parent->name)) then
								case(car(axlDBGetDesignUnits())
								("millimeters" subdist_clearance=10)
								("mils" subdist_clearance=393.7 ))
								if(nthelem(3 axlAirGap(itempin itemgap strcat( "ETCH/" select_layer_flag)))<subdist_get_clearance(subdist_clearance) then  
								axlHighlightObject(itempin->parent t) 
								SBlist=cons(itempin->parent SBlist)
								)
							)	
							if(rexMatchp("^0603C" upperCase(itempin->parent->name)) || rexMatchp("^0402C" upperCase(itempin->parent->name))  then
								case(car(axlDBGetDesignUnits())
								("millimeters" subdist_clearance=4)
								("mils" subdist_clearance=157.48 ))
								  if(nthelem(3 axlAirGap(itempin itemgap strcat( "ETCH/" select_layer_flag)))<subdist_get_clearancesmall(subdist_clearance) then  
								axlHighlightObject(itempin->parent t) 
								SBlist=cons(itempin->parent SBlist)
								)
							)
						)
						if(abs(itempin->rotation - 90.0) < 5.0 || abs(itempin->rotation - 270.0) < 5.0  then
							if(rexMatchp("^0805C" upperCase(itempin->parent->name)) || rexMatchp("^1206C" upperCase(itempin->parent->name)) then
								case(car(axlDBGetDesignUnits())
								("millimeters" subdist_clearance=3.5)
								("mils" subdist_clearance=137.795 ))
								if(nthelem(3 axlAirGap(itempin itemgap strcat( "ETCH/" select_layer_flag)))<subdist_get_clearance(subdist_clearance) then  
								axlHighlightObject(itempin->parent t) 
								SBlist=cons(itempin->parent SBlist)
								)
							)
							if(rexMatchp("^1210C" upperCase(itempin->parent->name)) || rexMatchp("^1608C" upperCase(itempin->parent->name))
							|| rexMatchp("^2012C" upperCase(itempin->parent->name)) || rexMatchp("^2016C" upperCase(itempin->parent->name)) 
							|| rexMatchp("^2512C" upperCase(itempin->parent->name)) || rexMatchp("^3216C" upperCase(itempin->parent->name))
							|| rexMatchp("^1812C" upperCase(itempin->parent->name)) || rexMatchp("^2220C" upperCase(itempin->parent->name)) then
								case(car(axlDBGetDesignUnits())
								("millimeters" subdist_clearance=10)
								("mils" subdist_clearance=393.7))
								if(nthelem(3 axlAirGap(itempin itemgap strcat( "ETCH/" select_layer_flag)))<subdist_get_clearance(subdist_clearance) then  
								axlHighlightObject(itempin->parent t) 
								SBlist=cons(itempin->parent SBlist)
								)
							)	
							if(rexMatchp("^0603C" upperCase(itempin->parent->name)) || rexMatchp("^0402C" upperCase(itempin->parent->name))  then
								case(car(axlDBGetDesignUnits())
								("millimeters" subdist_clearance=2.5)
								("mils" subdist_clearance=98.42 ))
								if(nthelem(3 axlAirGap(itempin itemgap strcat( "ETCH/" select_layer_flag)))<subdist_get_clearancesmall(subdist_clearance) then  
									axlHighlightObject(itempin->parent t) 
									SBlist=cons(itempin->parent SBlist)
								)
							)
						)
					else
						if(abs(itempin->rotation - 0.0) < 5.0 || abs(itempin->rotation - 180.0) < 5.0 || abs(itempin->rotation - 360.0) < 5.0 then
							if(rexMatchp("^0805C" upperCase(itempin->parent->name)) ||  rexMatchp("^1206C" upperCase(itempin->parent->name)) then
								case(car(axlDBGetDesignUnits())
								("millimeters" subdist_clearance=3.5)
								("mils" subdist_clearance=137.795 ))
								if(nthelem(3 axlAirGap(itempin itemgap strcat( "ETCH/" select_layer_flag)))<subdist_get_clearance(subdist_clearance) then  
								axlHighlightObject(itempin->parent t) 
								SBlist=cons(itempin->parent SBlist)
								)
							)
							if( rexMatchp("^1210C" upperCase(itempin->parent->name)) ||  rexMatchp("^1608C" upperCase(itempin->parent->name))
							|| rexMatchp("^2012C" upperCase(itempin->parent->name)) || rexMatchp("^2016C" upperCase(itempin->parent->name)) 
							|| rexMatchp("^2512C" upperCase(itempin->parent->name)) || rexMatchp("^3216C" upperCase(itempin->parent->name))
							|| rexMatchp("^1812C" upperCase(itempin->parent->name)) || rexMatchp("^2220C" upperCase(itempin->parent->name)) then
								case(car(axlDBGetDesignUnits())
								("millimeters" subdist_clearance=10)
								("mils" subdist_clearance=393.7 ))
								if(nthelem(3 axlAirGap(itempin itemgap strcat( "ETCH/" select_layer_flag)))<subdist_get_clearance(subdist_clearance) then  
								axlHighlightObject(itempin->parent t) 
								SBlist=cons(itempin->parent SBlist)
								)
							)
								
							if(rexMatchp("^0603C" upperCase(itempin->parent->name)) || rexMatchp("^0402C" upperCase(itempin->parent->name))  then
								case(car(axlDBGetDesignUnits())
								("millimeters" subdist_clearance=2.5)
								("mils" subdist_clearance=98.42 ))
								if(nthelem(3 axlAirGap(itempin itemgap strcat( "ETCH/" select_layer_flag)))<subdist_get_clearancesmall(subdist_clearance) then  
									axlHighlightObject(itempin->parent t) 
									SBlist=cons(itempin->parent SBlist)
								)
							)
						)
						if(abs(itempin->rotation - 90.0) < 5.0 || abs(itempin->rotation - 270.0) < 5.0  then
							if(rexMatchp("^0805C" upperCase(itempin->parent->name)) ||  rexMatchp("^1206C" upperCase(itempin->parent->name)) then
								case(car(axlDBGetDesignUnits())
								("millimeters" subdist_clearance=5)
								("mils" subdist_clearance=196.84 ))
								if(nthelem(3 axlAirGap(itempin itemgap strcat( "ETCH/" select_layer_flag) ))<subdist_get_clearance(subdist_clearance) then  
								axlHighlightObject(itempin->parent t) 
								SBlist=cons(itempin->parent SBlist)
								)
							)
							if(rexMatchp("^1210C" upperCase(itempin->parent->name)) || rexMatchp("^1608C" upperCase(itempin->parent->name)) 
							|| rexMatchp("^2012C" upperCase(itempin->parent->name)) || rexMatchp("^2016C" upperCase(itempin->parent->name)) 
							|| rexMatchp("^2512C" upperCase(itempin->parent->name)) || rexMatchp("^3216C" upperCase(itempin->parent->name))
							|| rexMatchp("^1812C" upperCase(itempin->parent->name)) || rexMatchp("^2220C" upperCase(itempin->parent->name)) then
								case(car(axlDBGetDesignUnits())
								("millimeters" subdist_clearance=10)
								("mils" subdist_clearance=393.7 ))
								if(nthelem(3 axlAirGap(itempin itemgap strcat( "ETCH/" select_layer_flag) ))<subdist_get_clearance(subdist_clearance) then  
									axlHighlightObject(itempin->parent t) 
									SBlist=cons(itempin->parent SBlist)
								)
							)
							if(rexMatchp("^0603C" upperCase(itempin->parent->name)) || rexMatchp("^0402C" upperCase(itempin->parent->name))  then
								case(car(axlDBGetDesignUnits())
								("millimeters" subdist_clearance=4)
								("mils" subdist_clearance=157.48 ))
								if(nthelem(3 axlAirGap(itempin itemgap strcat( "ETCH/" select_layer_flag)))<subdist_get_clearancesmall(subdist_clearance) then  
									axlHighlightObject(itempin->parent t) 
									SBlist=cons(itempin->parent SBlist)
								)
							)
						)
					)
				)
			)
		)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;
;安装孔范围子程序
; input : itemgap output : list(left:bottom right:top)
;;;;;;;;;;;;;;;;;;;;;;;
(defun subdist_get_airgapbox (itemgap)
	(prog ()
		case(car(axlDBGetDesignUnits())
		("millimeters" subdist_airgap=15)
		("mils"	subdist_airgap=600))
		left=car(nthelem(1 itemgap->bBox))-subdist_airgap
		bottom=cadr(nthelem(1 itemgap->bBox))-subdist_airgap
		right=car(nthelem(2 itemgap->bBox))+subdist_airgap
		top=cadr(nthelem(2 itemgap->bBox))+subdist_airgap
		return(list(left:bottom right:top))
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;计算最大安装孔垂直安规距离子程序
; input : subdist_clearance output : list(left:bottom right:top)
;;;;;;;;;;;;;;;;;;;;;;;
(defun subdist_get_clearance (subdist_clearance)
	(prog ()
		subdist_andy_clearance=0
		case(car(axlDBGetDesignUnits())
		("millimeters" subdist_andy_clearance=subdist_clearance+2.5)
		("mils" subdist_andy_clearance=subdist_clearance+98.42 ))
		return(subdist_andy_clearance)
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;计算最小安装孔平行安规距离子程序
; input : subdist_clearance output : list(left:bottom right:top)
;;;;;;;;;;;;;;;;;;;;;;;
(defun subdist_get_clearancesmall (subdist_clearance)
	(prog ()
		subdist_andy_clearance=0
		case(car(axlDBGetDesignUnits())
		("millimeters" subdist_andy_clearance=subdist_clearance+1.5)
		("mils" subdist_andy_clearance=subdist_clearance+59.35))
		return(subdist_andy_clearance)
	)
)

;;;not rectange  can do  but do not justice rotation
/*
;outlines-offset by andyluhero 2010.07.16,this function can't create opened outlines

(defun subdist_check_send_border ()
    prog( ()
axlClearSelSet()
subdist_Delete_object()
testing_unselect_object()
subdist_cnt = 0 
SBlist=nil
axlClearSelSet()
change_mil_mm_units=0
case(car(axlDBGetDesignUnits())
("millimeters"  change_mil_mm_units=0.0254 )
("mils"   change_mil_mm_units=0.9999))
axlVisibleDesign(nil)
axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t)
axlUIWRedraw(nil)
axlUIWUpdate(nil)
axlSetFindFilter(?enabled '("noall" "lines" "shapes") ?onButtons '("noall" "lines" "shapes" ))
shapeline_segments =car(axlGetSelSet(axlSingleSelectBox()))
axlClearSelSet()
	class_data="PACKAGE GEOMETRY"
	subclass_data=strcat("Display_" select_layer_flag)
	shape_offset=196.86*change_mil_mm_units
       shape_path = andylu_BuildShapePath( shapeline_segments->segments )
	andylu_AddShape( shape_path class_data subclass_data shape_offset)
viewlist=nil
viewlist=subdist_justice_cap()
itemx=0
itemy=0
viewlist=testing_justice_list(viewlist)
viewlist=remdq(nil viewlist)
testing_next_view_num=nil
if(viewlist==nil then
	testing_next_view_num=cons("OK" testing_next_view_num)
else
foreach(symitem viewlist
if(rexMatchp("^MARK" upperCase(symitem->name)) then
itemx=car(symitem->xy)
itemy=cadr(symitem->xy)
testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->name itemx itemy) testing_next_view_num)
else
	
	itemx=car(symitem->xy)
	itemy=cadr(symitem->xy)
	testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->refdes itemx itemy) testing_next_view_num)
)
++subdist_cnt
)
)
testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 2 \317\356: \306\367\274\376\265\275\260\345\261\337\276\340\300\353:\271\262  %d  \317\356" subdist_cnt)
axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
testing_next_view_num=remdq(nil testing_next_view_num)
testing_next_view_All=testing_next_view_num
axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
;if(subdist_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))
uidisplayer=nil
uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\306\367\274\376\265\275\260\345\261\337\276\340\300\353"  subdist_cnt)
axlUIWPrint(myform uidisplayer)
axlFormDisplay(myform)
testing_turn_on_layer(select_layer_flag)  
axlVisibleLayer(strcat("PACKAGE GEOMETRY/Display_" select_layer_flag)  t)
axlVisibleUpdate(t)
axlUIWRedraw(nil)
))

*/

/*
(defun subdist_check_send_border ()
prog( ()
axlClearSelSet()
subdist_Delete_object()
testing_unselect_object()
subdist_cnt = 0 
SBlist=nil
axlVisibleDesign(nil)
axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t)
axlSetFindFilter(?enabled '("noall"  "shapes" "linesegs") ?onButtons '("noall" "shapes" "linesegs" ))
shapeline_segments = axlGetSelSet(axlAddSelectAll())
andy_segments=nil
foreach(item shapeline_segments
	if(item->objType="shape" then
		    andy_segments=append(item->segments andy_segments))
	if(item->objType="line" then
		    andy_segments=cons(item andy_segments)
	))
 andy_segments=remdq(nil andy_segments)   
axlClearSelSet()
segitem_xlist=nil
segitem_ylist=nil
testing_turn_on_layer( select_layer_flag)

foreach(segitem andy_segments
;if( segitem->startend!=nil then
segitem_startend=segitem ->startEnd
	startx=car(nthelem(1 segitem_startend))
    starty=cadr(nthelem(1 segitem_startend))
    endx=car(nthelem(2 segitem_startend))
    endy=cadr(nthelem(2 segitem_startend))
segitem_xlist=cons( startx  segitem_xlist)
segitem_xlist=cons( endx  segitem_xlist)
segitem_ylist=cons( starty  segitem_ylist)
segitem_ylist=cons( endy  segitem_ylist)
;subdist_justice_cap(segitem)
);)
segitem_xlist=remdq(nil segitem_xlist)
segitem_ylist=remdq(nil segitem_ylist)
segitem_xlist=sort(segitem_xlist  'lessp)
segitem_ylist=sort(segitem_ylist  'lessp)
min_x=car(segitem_xlist)
min_y=car(segitem_ylist)
segitem_xlist=sort(segitem_xlist  'greaterp)
segitem_ylist=sort(segitem_ylist  'greaterp)
max_x=car(segitem_xlist)
max_y=car(segitem_ylist)
axlDBCreateRectangle(subdist_getbox_xy(min_x min_y  max_x  max_y ) nil strcat("PACKAGE GEOMETRY/Display_" select_layer_flag))
viewlist=nil
viewlist=subdist_justice_cap()
itemx=0
itemy=0
viewlist=testing_justice_list(viewlist)
viewlist=remdq(nil viewlist)
testing_next_view_num=nil
if(viewlist==nil then
	testing_next_view_num=cons("OK" testing_next_view_num)
else
foreach(symitem viewlist
if(rexMatchp("^MARK" upperCase(symitem->name)) then
itemx=car(symitem->xy)
itemy=cadr(symitem->xy)
testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->name itemx itemy) testing_next_view_num)
else
	
	itemx=car(symitem->xy)
	itemy=cadr(symitem->xy)
	testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->refdes itemx itemy) testing_next_view_num)
)
++subdist_cnt
)
)
testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 2 \317\356: \306\367\274\376\265\275\260\345\261\337\276\340\300\353:\271\262  %d  \317\356" subdist_cnt)
axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
testing_next_view_num=remdq(nil testing_next_view_num)
testing_next_view_All=testing_next_view_num
axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
;if(subdist_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))
uidisplayer=nil
uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\306\367\274\376\265\275\260\345\261\337\276\340\300\353"  subdist_cnt)
axlUIWPrint(myform uidisplayer)
axlFormDisplay(myform)
testing_turn_on_layer(select_layer_flag)  
axlVisibleLayer(strcat("PACKAGE GEOMETRY/Display_" select_layer_flag)  t)
axlVisibleUpdate(t)
axlUIWRedraw(nil)
))

*/
;;;;;;;;;;;;;;;;;;;;;;;
;判别传送边存在器件子程序
; input : subdist_clearance output : list(left:bottom right:top)
;;;;;;;;;;;;;;;;;;;;;;;
(defun subdist_justice_components ()
	prog( ()
		axlVisibleDesign(nil)
		axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t)
		axlSetFindFilter(?enabled '("noall"  "shapes" "linesegs") ?onButtons '("noall" "shapes" "linesegs" ))
		shapeline_segments = axlGetSelSet(axlAddSelectAll())
		andy_segments=nil
		foreach(item shapeline_segments
			if(item->objType="shape"   then
					andy_segments=append(item->segments andy_segments)
			)
			if(item->objType="line" then
					andy_segments=cons(item andy_segments)
			)
		)
		andy_segments=remdq(nil andy_segments)   
		axlClearSelSet()
		SBlist=nil
		testing_turn_on_layer( select_layer_flag)
		case(car(axlDBGetDesignUnits())
		("millimeters"  subdist_andy_clearance=5 subdist_andy_clearancesmall=2)
		("mils" subdist_andy_clearance=196.84 subdist_andy_clearancesmall=80))
		axlSetFindFilter(?enabled '("noall"  "pins" ) ?onButtons '("noall" "pins" ))
		foreach(segitem andy_segments
			if(segitem->objType="line" then	
				segitem_startend=segitem ->startEnd
				startx=car(nthelem(1 segitem_startend))
				starty=cadr(nthelem(1 segitem_startend))
				endx=car(nthelem(2 segitem_startend))
				endy=cadr(nthelem(2 segitem_startend))
				line_ver_flag=nil
				line_hor_flag=nil
				if(startx=endx then
					line_ver_flag=t
					line_hor_flag=nil
				)
				if(starty=endy then
					line_ver_flag=nil
					line_hor_flag=t
				)
				if(line_ver_flag==t then
					;axlDBCreateRectangle(subdist_send_getbox_ver(segitem subdist_andy_clearance subdist_andy_clearancesmall) nil strcat("PACKAGE GEOMETRY/Display_" select_layer_flag))
					if(axlSingleSelectBox(subdist_send_getbox_ver(segitem subdist_andy_clearance subdist_andy_clearancesmall))!=nil then
						allboxes = axlGetSelSet() 
						axlClearSelSet()
						if(allboxes!=nil then
						foreach(itempin allboxes
							if(itempin->parent!=nil &&  itempin->parent->type == "PACKAGE" && rexMatchp("^SM" itempin->name) then
								axlHighlightObject(itempin->parent t) 
								SBlist=cons(itempin->parent SBlist)
								)
							)
						)
					)
				line_ver_flag=nil
				)
				if(line_hor_flag==t then
					;axlDBCreateRectangle(subdist_send_getbox_hor(segitem subdist_andy_clearance subdist_andy_clearancesmall) nil strcat("PACKAGE GEOMETRY/Display_" select_layer_flag))
					if(axlSingleSelectBox(subdist_send_getbox_hor(segitem subdist_andy_clearance subdist_andy_clearancesmall))!=nil then
						allboxes = axlGetSelSet() 
						axlClearSelSet()
						if(allboxes!=nil then
						foreach(itempin allboxes
							if(itempin->parent!=nil  && itempin->parent->type == "PACKAGE" && rexMatchp("^SM" itempin->name) then
								axlHighlightObject(itempin->parent t) 
								SBlist=cons(itempin->parent SBlist)
								)
							)
						)
					)
				line_hor_flag=nil
				)
			)
		)
		SBlist=testing_justice_list(SBlist)
		SBlist=remdq(nil SBlist)
		return(SBlist)
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;判别垂直边范围子程序
; input :andline subdist_andy_clearance subdist_andy_clearancesmall output : list(left:bottom right:top)
;;;;;;;;;;;;;;;;;;;;;;;
(defun subdist_send_getbox_ver (andline subdist_andy_clearance subdist_andy_clearancesmall)
	(prog ()
		left = car(nth(0 andline->bBox)) - subdist_andy_clearance
		top = cadr(nth(1 andline->bBox)) + subdist_andy_clearancesmall 
		right = car(nth(1 andline->bBox)) + subdist_andy_clearance
		bottom = cadr(nth(0 andline->bBox)) - subdist_andy_clearancesmall
		return(list(left:bottom right:top))    
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;判别水平边范围子程序
; input :andline subdist_andy_clearance subdist_andy_clearancesmall output : list(left:bottom right:top)
;;;;;;;;;;;;;;;;;;;;;;;
(defun subdist_send_getbox_hor (andline subdist_andy_clearance subdist_andy_clearancesmall)
	(prog ()
		left = car(nth(0 andline->bBox)) - subdist_andy_clearancesmall
		top = cadr(nth(1 andline->bBox)) + subdist_andy_clearance 
		right = car(nth(1 andline->bBox)) + subdist_andy_clearancesmall
		bottom = cadr(nth(0 andline->bBox))- subdist_andy_clearance
		return(list(left:bottom right:top))    
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;确定传送边范围子程序
; input :list output : list(left:bottom right:top)
;;;;;;;;;;;;;;;;;;;;;;;
(defun subdist_justice_send_border (list subdist_andy_clearance)
	(prog ()
		left = car(nth(0 list)) - subdist_andy_clearance
		bottom = cadr(nth(0 list))- subdist_andy_clearance
		right = car(nth(1 list)) + subdist_andy_clearance
		top = cadr(nth(1 list)) + subdist_andy_clearance
		return(list(left:bottom right:top)) 
	)
)

;changed by andyluhero 2010-08-18
;;;;;;;;;;;;;;;;;;;;;;;
;判断画出传送边5mm，非传送边3.5mm，并判断边5mm内有无器件，高亮并显示--程序
; input :no output :no
;;;;;;;;;;;;;;;;;;;;;;;
(defun subdist_check_send_border ()
	prog( ()
		axlClearSelSet()
		drawing_outline_5mm_3r5mm()
		subdist_cnt = 0 
		SBlist=nil
		viewlist=nil
		viewlist=subdist_justice_components()
		;viewlist=subdist_justice_cap()
		itemx=0
		itemy=0
		viewlist=testing_justice_list(viewlist)
		viewlist=remdq(nil viewlist)
		testing_next_view_num=nil
		if(viewlist==nil then
			testing_next_view_num=cons("OK" testing_next_view_num)
		else
			foreach(symitem viewlist
				itemx=car(symitem->xy)
				itemy=cadr(symitem->xy)
				if(rexMatchp("^MARK" upperCase(symitem->name))  then
					testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->name itemx itemy) testing_next_view_num)
				else
					if(symitem->refdes == nil then
						foreach(txtitem symitem->children
							if(txtitem->layer=="REF DES/ASSEMBLY_TOP" || txtitem->layer =="REF DES/ASSEMBLY_BOTTOM"   then
								testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" txtitem->text itemx itemy) testing_next_view_num)
							)
						)
					else
					testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->refdes itemx itemy) testing_next_view_num)
					)
				)
				++subdist_cnt
			)
		)
		testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 2 \317\356: \306\367\274\376\265\275\260\345\261\337\276\340\300\353:\271\262  %d  \317\356" subdist_cnt)
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		testing_next_view_num=remdq(nil testing_next_view_num)
		testing_next_view_All=testing_next_view_num
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\306\367\274\376\265\275\260\345\261\337\276\340\300\353"  subdist_cnt)
		axlUIWPrint(myform uidisplayer)
		axlFormDisplay(myform)
		testing_turn_on_layer(select_layer_flag)  
		axlVisibleLayer(strcat("PACKAGE GEOMETRY/Display_" select_layer_flag)  t)
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;判断画出传送边5mm，非传送边3.5mm子程序
; input :no output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun drawing_outline_5mm_3r5mm ()
    prog( ()
		axlClearSelSet()
		subdist_Delete_object()
		testing_unselect_object()
		subdist_cnt = 0 
		SBlist=nil
		axlClearSelSet()
		axlVisibleDesign(nil)
		axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t)
		axlUIWRedraw(nil)
		axlUIWUpdate(nil)
		axlSetFindFilter(?enabled '("noall" "lines" "shapes") ?onButtons '("noall" "lines" "shapes" ))
		shapeline_segments =axlGetSelSet(axlSingleSelectBox())
		axlClearSelSet()
		andyhero_segments=nil
		andyhero_segments=yihan_dispayer_num(shapeline_segments)
		max_min_xy=testingfind_getmax_min(andyhero_segments)
		minx=car(nthelem(1 max_min_xy))
		miny=cadr(nthelem(1 max_min_xy))
		maxx=car(nthelem(2 max_min_xy))
		maxy=cadr(nthelem(2 max_min_xy))
		yihan_length_width(minx miny  maxx  maxy )			
		;outline_getbox_xy_list=yihan_getbox_xy(minx miny  maxx  maxy )
		testing_turn_on_layer(select_layer_flag)  
		axlVisibleLayer(strcat("PACKAGE GEOMETRY/Display_" select_layer_flag)  t)
		axlVisibleUpdate(t)
		axlUIWRedraw(nil)
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;判断是否符合公司加工能力子程序
; input :min_x min_y  max_x  max_y output : no
;;;;;;;;;;;;;;;;;;;;;;;

(defun yihan_length_width (min_x min_y  max_x  max_y )
	(prog ()
		x_y_rat=0
		x_y_rat=abs(max_x-min_x)/abs(max_y-min_y)
		stard_length_min=3543.3*change_mil_mm_units
		stard_length_max=21181.1*change_mil_mm_units
		outline_getbox_xy_list=nil
		if(abs(max_x-min_x)>stard_length_max then
			if(abs(max_y-min_y)>stard_length_max then
				uidisplayer=nil
				uidisplayer=sprintf(dummy , "\263\254\271\375\274\323\271\244\304\334\301\246\243\254\307\353\310\267\310\317\311\372\262\372\313\256\306\275!" )
				axlUIConfirm(uidisplayer)
			else
				uidisplayer=nil
				uidisplayer=sprintf(dummy , "\263\254\271\375\274\323\271\244\304\334\301\246\243\254\307\353\310\267\310\317\311\372\262\372\313\256\306\275!" )
				axlUIConfirm(uidisplayer)
			)
		else
			if(abs(max_x-min_x)<stard_length_max && abs(max_x-min_x)>stard_length_min then
				if(abs(max_y-min_y)>stard_length_max then
					uidisplayer=nil
					uidisplayer=sprintf(dummy , "\263\254\271\375\274\323\271\244\304\334\301\246\243\254\307\353\310\267\310\317\311\372\262\372\313\256\306\275!" )
					axlUIConfirm(uidisplayer)
				else
					if(abs(max_y-min_y)>stard_length_min then
						outline_getbox_xy_list=yihan_getbox_xy(min_x min_y  max_x  max_y )
					else
						outline_getbox_xy_list=yihan_getbox_xy(min_x min_y  max_x  max_y )
					)
				)
			else
				if(abs(max_x-min_x)<stard_length_min then
					if(abs(max_y-min_y)>stard_length_max then
						uidisplayer=nil
						uidisplayer=sprintf(dummy , "\263\254\271\375\274\323\271\244\304\334\301\246\243\254\307\353\310\267\310\317\311\372\262\372\313\256\306\275!" )
						axlUIConfirm(uidisplayer)
					else
						if(abs(max_y-min_y)>stard_length_min then
							outline_getbox_xy_list=yihan_getbox_xy(min_x min_y  max_x  max_y )
						else
							uidisplayer=nil
							uidisplayer=sprintf(dummy , "\310\267\266\250\322\252\306\264\260\345\243\254\310\267\310\317\306\264\260\345\267\275\312\275\243\277" )
							axlUIConfirm(uidisplayer)
							outline_getbox_xy_list=yihan_getbox_xy(min_x min_y  max_x  max_y )
						)
					)
				)
			)
		)
		axlDBCreateRectangle(outline_getbox_xy_list nil strcat("PACKAGE GEOMETRY/Display_" select_layer_flag))
	)
)
/*
(defun yihan_length_width (min_x min_y  max_x  max_y )
	(prog ()
		x_y_rat=0
		checkmil_units=0
		case(car(axlDBGetDesignUnits())
		("millimeters"  checkmil_units=0.0254 )
		("mils"   checkmil_units=0.9999))
		x_y_rat=abs(max_x-min_x)/abs(max_y-min_y)
		stard_length_min=3543.3*checkmil_units
		stard_length_max=21181.1*checkmil_units
		outline_getbox_xy_list=nil
		if(abs(max_x-min_x)>stard_length_max then
			if(abs(max_y-min_y)>stard_length_max then
				uidisplayer=nil
				uidisplayer=sprintf(dummy , "\263\254\271\375\274\323\271\244\304\334\301\246\243\254\307\353\310\267\310\317\311\372\262\372\313\256\306\275!" )
				axlUIConfirm(uidisplayer)
			else
				uidisplayer=nil
				uidisplayer=sprintf(dummy , "\263\254\271\375\274\323\271\244\304\334\301\246\243\254\307\353\310\267\310\317\311\372\262\372\313\256\306\275!" )
				axlUIConfirm(uidisplayer)
			)
		else
			if(abs(max_x-min_x)<stard_length_max && abs(max_x-min_x)>stard_length_min then
				if(abs(max_y-min_y)>stard_length_max then
					uidisplayer=nil
					uidisplayer=sprintf(dummy , "\263\254\271\375\274\323\271\244\304\334\301\246\243\254\307\353\310\267\310\317\311\372\262\372\313\256\306\275!" )
					axlUIConfirm(uidisplayer)
				else
					if(abs(max_y-min_y)>stard_length_min then
						outline_getbox_xy_list=yihan_getbox_xy(min_x min_y  max_x  max_y )
					else
						outline_getbox_xy_list=yihan_getbox_xy(min_x min_y  max_x  max_y )
					)
				)
				else
					if(abs(max_x-min_x)<stard_length_min then
						if(abs(max_y-min_y)>stard_length_max then
							uidisplayer=nil
							uidisplayer=sprintf(dummy , "\263\254\271\375\274\323\271\244\304\334\301\246\243\254\307\353\310\267\310\317\311\372\262\372\313\256\306\275!" )
							axlUIConfirm(uidisplayer)
						else
							if(abs(max_y-min_y)>stard_length_min then
								outline_getbox_xy_list=yihan_getbox_xy(min_x min_y  max_x  max_y )
							else
								uidisplayer=nil
								uidisplayer=sprintf(dummy , "\310\267\266\250\322\252\306\264\260\345\243\254\310\267\310\317\306\264\260\345\267\275\312\275\243\277" )
								axlUIConfirm(uidisplayer)
								outline_getbox_xy_list=yihan_getbox_xy(min_x min_y  max_x  max_y )
							)
						)
					)
				)
			)
		axlDBCreateRectangle(outline_getbox_xy_list nil strcat("PACKAGE GEOMETRY/Display_" select_layer_flag))
	)
)
*/

;;;;;;;;;;;;;;;;;;;;;;;
;判断是否拼板子程序
; input :min_x min_y  max_x  max_y output : list(left:bottom right:top)
;;;;;;;;;;;;;;;;;;;;;;;
/*
(defun yihan_getbox_xy (min_x min_y  max_x  max_y )
	(prog ()
		str_ui=nil
		x_y_rat=0
		subdist_andy_clearance=196.86*change_mil_mm_units
		subdist_andy_clearance_small=137.8*change_mil_mm_units
		case(car(axlDBGetDesignUnits())
			("millimeters"  change_units=0.9999 )
			("mils"   change_units=0.0254)
		)
		x_y_rat=abs(max_x-min_x)/abs(max_y-min_y)
		if(x_y_rat<0.8  then
			str_ui=sprintf(dummy ,"Y\317\362")
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "X\317\362\263\244\266\310\316\252%0.2f\243\254Y\317\362\263\244\266\310\316\252%0.2f\243\254X\317\362\323\353Y\317\362\326\256\261\310\316\252%0.2f\243\254\307\353\310\267\310\317\312\307\322\324%s\316\252\264\253\313\315\261\337!" abs(max_x-min_x)*change_units abs(max_y-min_y)*change_units x_y_rat str_ui)
			if(axlUIYesNo(uidisplayer)!= t  then
				axlMsgPut("\322\324X\317\362\316\252\264\253\313\315\261\337!")
				left = min_x  + subdist_andy_clearance_small
				bottom = min_y + subdist_andy_clearance
				right = max_x - subdist_andy_clearance_small
				top = max_y - subdist_andy_clearance
			else
				axlMsgPut("\322\324Y\317\362\316\252\264\253\313\315\261\337!")
				left = min_x  + subdist_andy_clearance
				bottom = min_y + subdist_andy_clearance_small
				right = max_x - subdist_andy_clearance
				top = max_y - subdist_andy_clearance_small
			)
		)
		if(x_y_rat>=0.8 && x_y_rat<=1.25  then
			str_ui=sprintf(dummy ,"Y\317\362")
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "X\317\362\263\244\266\310\316\252%0.2f\243\254Y\317\362\263\244\266\310\316\252%0.2f\243\254X\317\362\323\353Y\317\362\326\256\261\310\316\252%0.2f\243\254\307\353\310\267\310\317\312\307\322\324%s\316\252\264\253\313\315\261\337!" abs(max_x-min_x)*change_units abs(max_y-min_y)*change_units x_y_rat str_ui)
			if(axlUIYesNo(uidisplayer)!= t  then
				axlMsgPut("\322\324X\317\362\316\252\264\253\313\315\261\337!")
				left = min_x  + subdist_andy_clearance_small
				bottom = min_y + subdist_andy_clearance
				right = max_x - subdist_andy_clearance_small
				top = max_y - subdist_andy_clearance
			else
				axlMsgPut("\322\324Y\317\362\316\252\264\253\313\315\261\337!")
				left = min_x  + subdist_andy_clearance
				bottom = min_y + subdist_andy_clearance_small
				right = max_x - subdist_andy_clearance
				top = max_y - subdist_andy_clearance_small
			)
		)
		if(x_y_rat>1.25  then
			str_ui=sprintf(dummy ,"X\317\362")
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "X\317\362\263\244\266\310\316\252%0.2f\243\254Y\317\362\263\244\266\310\316\252%0.2f\243\254X\317\362\323\353Y\317\362\326\256\261\310\316\252%0.2f\243\254\307\353\310\267\310\317\312\307\322\324%s\316\252\264\253\313\315\261\337!" abs(max_x-min_x)*change_units abs(max_y-min_y)*change_units x_y_rat str_ui)
			if(axlUIYesNo(uidisplayer)!= t  then
				axlMsgPut("\322\324Y\317\362\316\252\264\253\313\315\261\337!")
				left = min_x  + subdist_andy_clearance
				bottom = min_y + subdist_andy_clearance_small
				right = max_x - subdist_andy_clearance
				top = max_y - subdist_andy_clearance_small
			else
				axlMsgPut("\322\324X\317\362\316\252\264\253\313\315\261\337!")
				left = min_x  + subdist_andy_clearance_small
				bottom = min_y + subdist_andy_clearance
				right = max_x - subdist_andy_clearance_small
				top = max_y - subdist_andy_clearance
			)
		)
		return(list(left:bottom right:top))    
	)
)


*/


(defun yihan_getbox_xy (min_x min_y  max_x  max_y )
	(prog ()
		str_ui=nil
		x_y_rat=0
		subdist_andy_clearance=196.86*change_mil_mm_units
		subdist_andy_clearance_small=137.8*change_mil_mm_units
		x_y_rat=abs(max_x-min_x)/abs(max_y-min_y)
		if(x_y_rat<0.8  then
			str_ui=sprintf(dummy ,"Y\317\362")
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "X\317\362\263\244\266\310\316\252%0.2f\243\254Y\317\362\263\244\266\310\316\252%0.2f\243\254X\317\362\323\353Y\317\362\326\256\261\310\316\252%0.2f\243\254\307\353\310\267\310\317\312\307\322\324%s\316\252\264\253\313\315\261\337!" abs(max_x-min_x)*change_mm_mil_units abs(max_y-min_y)*change_mm_mil_units x_y_rat str_ui)
			if(axlUIYesNo(uidisplayer)!= t  then
				axlMsgPut("\322\324X\317\362\316\252\264\253\313\315\261\337!")
				left = min_x  + subdist_andy_clearance_small
				bottom = min_y + subdist_andy_clearance
				right = max_x - subdist_andy_clearance_small
				top = max_y - subdist_andy_clearance
			else
				axlMsgPut("\322\324Y\317\362\316\252\264\253\313\315\261\337!")
				left = min_x  + subdist_andy_clearance
				bottom = min_y + subdist_andy_clearance_small
				right = max_x - subdist_andy_clearance
				top = max_y - subdist_andy_clearance_small
			)
		)
		if(x_y_rat>=0.8 && x_y_rat<=1.25  then
			str_ui=sprintf(dummy ,"Y\317\362")
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "X\317\362\263\244\266\310\316\252%0.2f\243\254Y\317\362\263\244\266\310\316\252%0.2f\243\254X\317\362\323\353Y\317\362\326\256\261\310\316\252%0.2f\243\254\307\353\310\267\310\317\312\307\322\324%s\316\252\264\253\313\315\261\337!" abs(max_x-min_x)*change_mm_mil_units abs(max_y-min_y)*change_mm_mil_units x_y_rat str_ui)
			if(axlUIYesNo(uidisplayer)!= t  then
				axlMsgPut("\322\324X\317\362\316\252\264\253\313\315\261\337!")
				left = min_x  + subdist_andy_clearance_small
				bottom = min_y + subdist_andy_clearance
				right = max_x - subdist_andy_clearance_small
				top = max_y - subdist_andy_clearance
			else
				axlMsgPut("\322\324Y\317\362\316\252\264\253\313\315\261\337!")
				left = min_x  + subdist_andy_clearance
				bottom = min_y + subdist_andy_clearance_small
				right = max_x - subdist_andy_clearance
				top = max_y - subdist_andy_clearance_small
			)
		)
		if(x_y_rat>1.25  then
			str_ui=sprintf(dummy ,"X\317\362")
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "X\317\362\263\244\266\310\316\252%0.2f\243\254Y\317\362\263\244\266\310\316\252%0.2f\243\254X\317\362\323\353Y\317\362\326\256\261\310\316\252%0.2f\243\254\307\353\310\267\310\317\312\307\322\324%s\316\252\264\253\313\315\261\337!" abs(max_x-min_x)*change_mm_mil_units abs(max_y-min_y)*change_mm_mil_units x_y_rat str_ui)
			if(axlUIYesNo(uidisplayer)!= t  then
				axlMsgPut("\322\324Y\317\362\316\252\264\253\313\315\261\337!")
				left = min_x  + subdist_andy_clearance
				bottom = min_y + subdist_andy_clearance_small
				right = max_x - subdist_andy_clearance
				top = max_y - subdist_andy_clearance_small
			else
				axlMsgPut("\322\324X\317\362\316\252\264\253\313\315\261\337!")
				left = min_x  + subdist_andy_clearance_small
				bottom = min_y + subdist_andy_clearance
				right = max_x - subdist_andy_clearance_small
				top = max_y - subdist_andy_clearance
			)

		)
		return(list(left:bottom right:top))    
	)
)

;;;;;;;;;;;;;;;;;;;;;;;
;判断是否为异性板子程序
; input :shapeline_segments output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun yihan_dispayer_num (shapeline_segments)
	(prog ()
		andy_segments=nil
		foreach(item shapeline_segments
			if(item->objType="shape" then
				andy_segments=append(item->segments andy_segments)
			)
			if(item->objType="line" then
				andy_segments=cons(item andy_segments)
			)
		)
		andy_segments=remdq(nil andy_segments) 
		testing_sumlength=length(andy_segments)
		if(testing_sumlength>9 then 
			uidisplayer=nil
			uidisplayer=sprintf(dummy , "\322\354\320\316\260\345\243\254\312\307\267\361\320\350\322\252\262\271\306\353\243\277")
			if(axlUIYesNo(uidisplayer)!= t  then
				axlMsgPut("no!")
			else
				axlMsgPut("\310\267\310\317\262\271\306\353\264\246\241\243")
				;yihan_dispayer_move_aling()
			)
		)
		return(andy_segments)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;
;判断电容，BGA和晶振到器件级边界距离子程序
; input :shapeline_segments output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun subdist_justice_cap ()
	prog( ()
		axlVisibleDesign(nil)
		axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t)
		axlSetFindFilter(?enabled '("noall"  "shapes" "linesegs") ?onButtons '("noall" "shapes" "linesegs" ))
		shapeline_segments = axlGetSelSet(axlAddSelectAll())
		andy_segments=nil
		foreach(item shapeline_segments
			if(item->objType="shape" then
				andy_segments=append(item->segments andy_segments)
			)
			if(item->objType="line" then
				andy_segments=cons(item andy_segments)
			)
		)
		andy_segments=remdq(nil andy_segments)   
		axlClearSelSet()
		segitem_xlist=nil
		segitem_ylist=nil
		SBlist=nil
		testing_turn_on_layer( select_layer_flag)
		axlSetFindFilter(?enabled '("noall"  "pins" ) ?onButtons '("noall" "pins" ))
		foreach(segitem andy_segments
			if(segitem->objType="line" then
				segitem_startend=segitem ->startEnd
				startx=car(nthelem(1 segitem_startend))
				starty=cadr(nthelem(1 segitem_startend))
				endx=car(nthelem(2 segitem_startend))
				endy=cadr(nthelem(2 segitem_startend))
				if(startx=endx then
					segitem_startx=car(nthelem(1 segitem_startend))
					segitem_starty=starty
					segitem_endy=endy
					if(axlSingleSelectBox(subdist_send15mm_getbox_ver(segitem))!=nil then
						allboxes = axlGetSelSet() 
						axlClearSelSet()
						;axlDBCreateRectangle(subdist_send15mm_getbox_ver(segitem) nil strcat("PACKAGE GEOMETRY/Display_" select_layer_flag))
						foreach(itempin allboxes
							if(itempin->parent!=nil then
								if( rexMatchp("^CBGA" upperCase(itempin->parent->name))  || rexMatchp("^PBGA" upperCase(itempin->parent->name))  || 
								rexMatchp("^LGA" upperCase(itempin->parent->name))  ||
								rexMatchp("^R-PBGA" upperCase(itempin->parent->name)) || rexMatchp("^R-CBGA" upperCase(itempin->parent->name)) ||
								rexMatchp("^CCGA" upperCase(itempin->parent->name)) || rexMatchp("^R-XBGA" upperCase(itempin->parent->name))  then
									case(car(axlDBGetDesignUnits())
									("millimeters" subdist_clearance= 5 )
									("mils" subdist_clearance=196.84))
									minx=0
									miny=0
									maxx=0
									maxy=0
									get_line_list=nil
									foreach(item_outline itempin->parent->children
										if(item_outline->objType=="path" && 
											item_outline->layer==strcat("PACKAGE GEOMETRY/SILKSCREEN_" select_layer_flag) then
											get_line_list=append(item_outline->segments get_line_list)
										)
									)
									get_line_list=remdq(nil get_line_list)
									minx=car(nthelem(1 testingfind_getmax_min(get_line_list)))
									miny=cadr(nthelem(1 testingfind_getmax_min(get_line_list)))
									maxx=car(nthelem(2 testingfind_getmax_min(get_line_list)))
									maxy=cadr(nthelem(2 testingfind_getmax_min(get_line_list)))

									if(abs(minx-segitem_startx)<subdist_clearance ||
									abs(maxx-segitem_startx)<subdist_clearance then  
										axlHighlightObject(itempin->parent t) 
										SBlist=cons(itempin->parent SBlist)
									)
								)
								if( rexMatchp("^CO2" upperCase(itempin->parent->name)) &&  rexMatchp("SM" upperCase(itempin->parent->name)) 
								||rexMatchp("^CO3" upperCase(itempin->parent->name)) ||rexMatchp("^CO4" upperCase(itempin->parent->name)) 
								|| rexMatchp("^CO5" upperCase(itempin->parent->name)) ||rexMatchp("^CO6" upperCase(itempin->parent->name))
								|| rexMatchp("^CO7" upperCase(itempin->parent->name)) then
									case(car(axlDBGetDesignUnits())
									("millimeters" subdist_clearance=10)
									("mils" subdist_clearance=393.7))
									if(abs(car(nthelem(1 itempin->bBox))-segitem_startx)<subdist_clearance ||
									abs(car(nthelem(2 itempin->bBox))-segitem_startx)<subdist_clearance then  
										axlHighlightObject(itempin->parent t) 
										SBlist=cons(itempin->parent SBlist)
									)
								)
								if( rexMatchp("^MARK" upperCase(itempin->parent->name))  then
									case(car(axlDBGetDesignUnits())
									("millimeters" subdist_clearance= 5)
									("mils" subdist_clearance=196.84))
									if(abs(car(nthelem(1 itempin->bBox))-segitem_startx)<subdist_clearance ||
									abs(car(nthelem(2 itempin->bBox))-segitem_startx)<subdist_clearance then  
										axlHighlightObject(itempin->parent t) 
										SBlist=cons(itempin->parent SBlist)
									)
								)

								if(abs(itempin->rotation - 0.0) < 5.0 || abs(itempin->rotation - 180.0) < 5.0 || abs(itempin->rotation - 360.0) < 5.0  then
									if(rexMatchp("^0603C" upperCase(itempin->parent->name)) || rexMatchp("^0805C" upperCase(itempin->parent->name))
									|| rexMatchp("^1206C" upperCase(itempin->parent->name)) then
									itempin_left=car(nthelem(1 subdist_getbox(itempin)))
									itempin_top=cadr(nthelem(2 subdist_getbox(itempin)))
									itempin_right=car(nthelem(2 subdist_getbox(itempin)))
									itempin_bottom=cadr(nthelem(1 subdist_getbox(itempin)))
									case(car(axlDBGetDesignUnits())
									("millimeters" subdist_clearance=5 subdist_clearancesmall=3.5)
									("mils" subdist_clearance=196.84 subdist_clearancesmall=137.795))
										if(abs(itempin_left-segitem_startx)<subdist_clearance || abs(itempin_right-segitem_startx)<subdist_clearance then  
											axlHighlightObject(itempin->parent t) 
											SBlist=cons(itempin->parent SBlist)
										)
									)
									if( rexMatchp("^1608C" upperCase(itempin->parent->name))|| rexMatchp("^1210C" upperCase(itempin->parent->name)) 
									|| rexMatchp("^2012C" upperCase(itempin->parent->name)) || rexMatchp("^2016C" upperCase(itempin->parent->name)) 
									|| rexMatchp("^2512C" upperCase(itempin->parent->name)) || rexMatchp("^3216C" upperCase(itempin->parent->name))
									|| rexMatchp("^1812C" upperCase(itempin->parent->name)) || rexMatchp("^2220C" upperCase(itempin->parent->name)) then
										itempin_left=car(nthelem(1 subdist_getbox(itempin)))
										itempin_top=cadr(nthelem(2 subdist_getbox(itempin)))
										itempin_right=car(nthelem(2 subdist_getbox(itempin)))
										itempin_bottom=cadr(nthelem(1 subdist_getbox(itempin)))
										case(car(axlDBGetDesignUnits())
										("millimeters" subdist_clearance=10)
										("mils" subdist_clearance=393.7))
										if(abs(itempin_left-segitem_startx)<subdist_clearance || abs(itempin_right-segitem_startx)<subdist_clearance then  
											axlHighlightObject(itempin->parent t) 
											SBlist=cons(itempin->parent SBlist)
										)
									)
									if(rexMatchp("^0402C" upperCase(itempin->parent->name))  then
										case(car(axlDBGetDesignUnits())
										("millimeters" subdist_clearance=4 )
										("mils" subdist_clearance=157.48 ))
										itempin_left=car(nthelem(1 subdist_getbox(itempin)))
										itempin_top=cadr(nthelem(2 subdist_getbox(itempin)))
										itempin_right=car(nthelem(2 subdist_getbox(itempin)))
										itempin_bottom=cadr(nthelem(1 subdist_getbox(itempin)))
										if(abs(itempin_left-segitem_startx)<subdist_clearance || abs(itempin_right-segitem_startx)<subdist_clearance then  
											axlHighlightObject(itempin->parent t)
											SBlist=cons(itempin->parent SBlist)
										)
									)
								)
								if(abs(itempin->rotation - 90.0) < 5.0 || abs(itempin->rotation - 270.0) < 5.0  then
									if(rexMatchp("^0603C" upperCase(itempin->parent->name)) || rexMatchp("^0805C" upperCase(itempin->parent->name))
									|| rexMatchp("^1206C" upperCase(itempin->parent->name)) then
										case(car(axlDBGetDesignUnits())
										("millimeters" subdist_clearance=3.5 )
										("mils" subdist_clearance=137.795 ))
										itempin_left=car(nthelem(1 subdist_getbox(itempin)))
										itempin_top=cadr(nthelem(2 subdist_getbox(itempin)))
										itempin_right=car(nthelem(2 subdist_getbox(itempin)))
										itempin_bottom=cadr(nthelem(1 subdist_getbox(itempin)))
										if( abs(itempin_left-segitem_startx)<subdist_clearance || abs(itempin_right-segitem_startx)<subdist_clearance  then  
											axlHighlightObject(itempin->parent t) 
											SBlist=cons(itempin->parent SBlist)
										)
									)
									if( rexMatchp("^1608C" upperCase(itempin->parent->name))|| rexMatchp("^1210C" upperCase(itempin->parent->name)) 
									|| rexMatchp("^2012C" upperCase(itempin->parent->name)) || rexMatchp("^2016C" upperCase(itempin->parent->name)) 
									|| rexMatchp("^2512C" upperCase(itempin->parent->name)) || rexMatchp("^3216C" upperCase(itempin->parent->name))
									|| rexMatchp("^1812C" upperCase(itempin->parent->name)) || rexMatchp("^2220C" upperCase(itempin->parent->name)) then
										itempin_left=car(nthelem(1 subdist_getbox(itempin)))
										itempin_top=cadr(nthelem(2 subdist_getbox(itempin)))
										itempin_right=car(nthelem(2 subdist_getbox(itempin)))
										itempin_bottom=cadr(nthelem(1 subdist_getbox(itempin)))
										case(car(axlDBGetDesignUnits())
										("millimeters" subdist_clearance=10)
										("mils" subdist_clearance=393.7 ))
										if( abs(itempin_left-segitem_startx)<subdist_clearance || abs(itempin_right-segitem_startx)<subdist_clearance  then  
											axlHighlightObject(itempin->parent t) 
											SBlist=cons(itempin->parent SBlist)
										)
									)
									if(rexMatchp("^0402C" upperCase(itempin->parent->name))  then
										case(car(axlDBGetDesignUnits())
										("millimeters" subdist_clearance=2.5 )
										("mils" subdist_clearance=98.42 ))
										itempin_left=car(nthelem(1 subdist_getbox(itempin)))
										itempin_top=cadr(nthelem(2 subdist_getbox(itempin)))
										itempin_right=car(nthelem(2 subdist_getbox(itempin)))
										itempin_bottom=cadr(nthelem(1 subdist_getbox(itempin)))
										if( abs(itempin_left-segitem_startx)<subdist_clearance || abs(itempin_right-segitem_startx)<subdist_clearance  then  
										axlHighlightObject(itempin->parent t) 
										SBlist=cons(itempin->parent SBlist)
										)
									)
								)
							)
						)
					)
				)
				if(starty=endy then
					segitem_starty=cadr(nthelem(1 segitem_startend))
					if(axlSingleSelectBox(subdist_send15mm_getbox_hor(segitem))!=nil then
						allboxes = axlGetSelSet() 
						axlClearSelSet()
						;axlDBCreateRectangle(subdist_send15mm_getbox_hor(segitem) nil "PACKAGE GEOMETRY/Display_top")
						foreach(itempin allboxes
							if(itempin->parent!=nil then
								if( rexMatchp("^CBGA" upperCase(itempin->parent->name))  || rexMatchp("^PBGA" upperCase(itempin->parent->name))  || 
								rexMatchp("^LGA" upperCase(itempin->parent->name))  ||
								rexMatchp("^R-PBGA" upperCase(itempin->parent->name)) || rexMatchp("^R-CBGA" upperCase(itempin->parent->name)) ||
								rexMatchp("^CCGA" upperCase(itempin->parent->name)) || rexMatchp("^R-XBGA" upperCase(itempin->parent->name))  then
									case(car(axlDBGetDesignUnits())
									("millimeters" subdist_clearance= 5 )
									("mils" subdist_clearance=196.84))
									minx=0
									miny=0
									maxx=0
									maxy=0
									get_line_list=nil
									foreach(item_outline itempin->parent->children
										if(item_outline->objType=="path" && 
											item_outline->layer==strcat("PACKAGE GEOMETRY/SILKSCREEN_" select_layer_flag) then
											get_line_list=append(item_outline->segments get_line_list)
										)
									)
									get_line_list=remdq(nil get_line_list)
									minx=car(nthelem(1 testingfind_getmax_min(get_line_list)))
									miny=cadr(nthelem(1 testingfind_getmax_min(get_line_list)))
									maxx=car(nthelem(2 testingfind_getmax_min(get_line_list)))
									maxy=cadr(nthelem(2 testingfind_getmax_min(get_line_list)))

									if(abs(miny-segitem_starty)<subdist_clearance ||
									abs(maxy-segitem_starty)<subdist_clearance then  
										axlHighlightObject(itempin->parent t) 
										SBlist=cons(itempin->parent SBlist)
									)
								)
								if( rexMatchp("^CO2" upperCase(itempin->parent->name)) &&  rexMatchp("SM" upperCase(itempin->parent->name)) 
								||rexMatchp("^CO3" upperCase(itempin->parent->name)) ||rexMatchp("^CO4" upperCase(itempin->parent->name)) 
								|| rexMatchp("^CO5" upperCase(itempin->parent->name)) ||rexMatchp("^CO6" upperCase(itempin->parent->name))
								|| rexMatchp("^CO7" upperCase(itempin->parent->name)) then
									case(car(axlDBGetDesignUnits())
									("millimeters" subdist_clearance=10)
									("mils" subdist_clearance=393.7))
									if(abs(cadr(nthelem(1 itempin->bBox))-segitem_starty)<subdist_clearance ||
									abs(cadr(nthelem(2 itempin->bBox))-segitem_starty)<subdist_clearance then  
										axlHighlightObject(itempin->parent t) 
										SBlist=cons(itempin->parent SBlist)
									)
								)
								if( rexMatchp("^MARK" upperCase(itempin->parent->name))  then
									case(car(axlDBGetDesignUnits())
									("millimeters" subdist_clearance= 5)
									("mils" subdist_clearance=196.84))
									if(abs(cadr(nthelem(1 itempin->bBox))-segitem_starty)<subdist_clearance ||
									abs(cadr(nthelem(2 itempin->bBox))-segitem_starty)<subdist_clearance then  
										axlHighlightObject(itempin->parent t) 
										SBlist=cons(itempin->parent SBlist)
									)
								)
								if(abs(itempin->rotation - 0.0) < 5.0 || abs(itempin->rotation - 180.0) < 5.0 || abs(itempin->rotation - 360.0) < 5.0  then
									if(rexMatchp("^0603C" upperCase(itempin->parent->name)) || rexMatchp("^0805C" upperCase(itempin->parent->name))
									|| rexMatchp("^1206C" upperCase(itempin->parent->name)) then
										case(car(axlDBGetDesignUnits())
										("millimeters" subdist_clearance=3.5 )
										("mils" subdist_clearance=137.795 ))
										itempin_left=car(nthelem(1 subdist_getbox(itempin)))
										itempin_top=cadr(nthelem(2 subdist_getbox(itempin)))
										itempin_right=car(nthelem(2 subdist_getbox(itempin)))
										itempin_bottom=cadr(nthelem(1 subdist_getbox(itempin)))
										if( abs(itempin_top-segitem_starty)<subdist_clearance || abs(itempin_bottom-segitem_starty)<subdist_clearance  then  
											axlHighlightObject(itempin->parent t) 
											SBlist=cons(itempin->parent SBlist)
										)
									)
									if( rexMatchp("^1608C" upperCase(itempin->parent->name))|| rexMatchp("^1210C" upperCase(itempin->parent->name)) 
									|| rexMatchp("^2012C" upperCase(itempin->parent->name)) || rexMatchp("^2016C" upperCase(itempin->parent->name)) 
									|| rexMatchp("^2512C" upperCase(itempin->parent->name)) || rexMatchp("^3216C" upperCase(itempin->parent->name))
									|| rexMatchp("^1812C" upperCase(itempin->parent->name)) || rexMatchp("^2220C" upperCase(itempin->parent->name)) then
										itempin_left=car(nthelem(1 subdist_getbox(itempin)))
										itempin_top=cadr(nthelem(2 subdist_getbox(itempin)))
										itempin_right=car(nthelem(2 subdist_getbox(itempin)))
										itempin_bottom=cadr(nthelem(1 subdist_getbox(itempin)))
										case(car(axlDBGetDesignUnits())
										("millimeters" subdist_clearance=10 )
										("mils" subdist_clearance=393.7 ))
										if( abs(itempin_top-segitem_starty)<subdist_clearance || abs(itempin_bottom-segitem_starty)<subdist_clearance  then  
											axlHighlightObject(itempin->parent t) 
											SBlist=cons(itempin->parent SBlist)
										)
									)
									if(rexMatchp("^0402C" upperCase(itempin->parent->name))  then
										case(car(axlDBGetDesignUnits())
										("millimeters" subdist_clearance=2.5 )
										("mils" subdist_clearance=98.42 ))
										itempin_left=car(nthelem(1 subdist_getbox(itempin)))
										itempin_top=cadr(nthelem(2 subdist_getbox(itempin)))
										itempin_right=car(nthelem(2 subdist_getbox(itempin)))
										itempin_bottom=cadr(nthelem(1 subdist_getbox(itempin)))
										if( abs(itempin_top-segitem_starty)<subdist_clearance || abs(itempin_bottom-segitem_starty)<subdist_clearance  then  
											axlHighlightObject(itempin->parent t) 
											SBlist=cons(itempin->parent SBlist)
										)
									)
								)
								if(abs(itempin->rotation - 90.0) < 5.0 || abs(itempin->rotation - 270.0) < 5.0  then

									if(rexMatchp("^0603C" upperCase(itempin->parent->name)) || rexMatchp("^0805C" upperCase(itempin->parent->name))
									|| rexMatchp("^1206C" upperCase(itempin->parent->name)) then
										itempin_left=car(nthelem(1 subdist_getbox(itempin)))
										itempin_top=cadr(nthelem(2 subdist_getbox(itempin)))
										itempin_right=car(nthelem(2 subdist_getbox(itempin)))
										itempin_bottom=cadr(nthelem(1 subdist_getbox(itempin)))
										case(car(axlDBGetDesignUnits())
										("millimeters" subdist_clearance=5 )
										("mils" subdist_clearance=196.84 ))
										if( abs(itempin_top-segitem_starty)<subdist_clearance || abs(itempin_bottom-segitem_starty)<subdist_clearance  then  
												axlHighlightObject(itempin->parent t) 
											SBlist=cons(itempin->parent SBlist)
										)
									)
									if( rexMatchp("^1608C" upperCase(itempin->parent->name))|| rexMatchp("^1210C" upperCase(itempin->parent->name)) 
									|| rexMatchp("^2012C" upperCase(itempin->parent->name)) || rexMatchp("^2016C" upperCase(itempin->parent->name)) 
									|| rexMatchp("^2512C" upperCase(itempin->parent->name)) || rexMatchp("^3216C" upperCase(itempin->parent->name))
									|| rexMatchp("^1812C" upperCase(itempin->parent->name)) || rexMatchp("^2220C" upperCase(itempin->parent->name)) then
										itempin_left=car(nthelem(1 subdist_getbox(itempin)))
										itempin_top=cadr(nthelem(2 subdist_getbox(itempin)))
										itempin_right=car(nthelem(2 subdist_getbox(itempin)))
										itempin_bottom=cadr(nthelem(1 subdist_getbox(itempin)))
										case(car(axlDBGetDesignUnits())
										("millimeters" subdist_clearance=10)
										("mils" subdist_clearance=393.7))
										if( abs(itempin_top-segitem_starty)<subdist_clearance || abs(itempin_bottom-segitem_starty)<subdist_clearance  then  
											axlHighlightObject(itempin->parent t) 
											SBlist=cons(itempin->parent SBlist)
										)
									)
									if(rexMatchp("^0402C" upperCase(itempin->parent->name))  then
										case(car(axlDBGetDesignUnits())
										("millimeters" subdist_clearance=4 )
										("mils" subdist_clearance=157.48 ))
										itempin_left=car(nthelem(1 subdist_getbox(itempin)))
										itempin_top=cadr(nthelem(2 subdist_getbox(itempin)))
										itempin_right=car(nthelem(2 subdist_getbox(itempin)))
										itempin_bottom=cadr(nthelem(1 subdist_getbox(itempin)))
										if( abs(itempin_top-segitem_starty)<subdist_clearance || abs(itempin_bottom-segitem_starty)<subdist_clearance  then  
											axlHighlightObject(itempin->parent t) 
											SBlist=cons(itempin->parent SBlist)
										)
									)
								)
							)
						)
					)
				)
			)
		)
		SBlist=testing_justice_list(SBlist)
		SBlist=remdq(nil SBlist)
		return(SBlist)
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;
;判断垂直线段15mm范围子程序
; input :andline output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun subdist_send15mm_getbox_ver (andline)
	(prog ()
		loff =0 toff = 0 roff = 0 boff = 0 subdist_andy_clearance=100
		subdist_clearancesmall=0
		case(car(axlDBGetDesignUnits())
		("millimeters"  subdist_andy_clearance=15 subdist_andy_clearancesmall=2)
		("mils" subdist_andy_clearance=600 subdist_andy_clearancesmall=80))
		left = car(nth(0 andline->bBox)) - subdist_andy_clearance
		top = cadr(nth(1 andline->bBox)) + subdist_andy_clearancesmall 
		right = car(nth(1 andline->bBox)) + subdist_andy_clearance
		bottom = cadr(nth(0 andline->bBox)) - subdist_andy_clearancesmall
		return(list(left:bottom right:top))    
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;判断水平线段15mm范围子程序
; input :andline output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun subdist_send15mm_getbox_hor (andline)
	(prog ()
		loff =0 toff = 0 roff = 0 boff = 0 subdist_andy_clearance=100
		subdist_clearancesmall=0
		case(car(axlDBGetDesignUnits())
		("millimeters"  subdist_andy_clearance=15 subdist_andy_clearancesmall=2)
		("mils" subdist_andy_clearance=600 subdist_andy_clearancesmall=80))
		left = car(nth(0 andline->bBox)) - subdist_andy_clearancesmall
		top = cadr(nth(1 andline->bBox)) + subdist_andy_clearance 
		right = car(nth(1 andline->bBox)) + subdist_andy_clearancesmall
		bottom = cadr(nth(0 andline->bBox))- subdist_andy_clearance
		return(list(left:bottom right:top))    
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;判断垂直线段5mm范围子程序
; input :min_x min_y  max_x  max_y  output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun subdist_getbox_xy (min_x min_y  max_x  max_y )
	(prog ()
		subdist_andy_clearance=6
		case(car(axlDBGetDesignUnits())
		("millimeters"  subdist_andy_clearance=5)
		("mils" subdist_andy_clearance=196.84 ))
		left = min_x  + subdist_andy_clearance
		bottom = min_y + subdist_andy_clearance
		right = max_x - subdist_andy_clearance
		top = max_y - subdist_andy_clearance 
		return(list(left:bottom right:top))    
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;判断压接波峰焊范围子程序
; input :Input_float_flag  output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun subdist_check_pressfit (Input_float_flag)
	prog( ()
		SBlist=nil
		subdist_pinslist=nil
		axlClearSelSet()
		subdist_Delete_object()
		testing_unselect_object()
		testing_turn_on_layer( select_layer_flag)
		axlSetFindFilter(?enabled '(noall pins) ?onButtons '(noall pins))
		subdist_pinslist= axlGetSelSet(axlAddSelectAll())
		axlClearSelSet()
		subdist_cnt = 0
		subdist_pinslist=remdq(nil subdist_pinslist)	
		thol_list=nil	
		foreach(item subdist_pinslist
			pin_symref=item->parent->refdes
			pin_symname=item->parent->name
			pin_name=item->name
			if(item->parent->refdes && item->parent->name then
				if(item->isThrough==t  && item->testpoint==nil && item->use!= ""  then ;&& item->use!= "NC" then
					if(rexMatchp("^SB" pin_symref)==nil && rexMatchp("^HOL" pin_symname)==nil && rexMatchp("^TP" pin_symref)==nil then
						thol_list=cons(item thol_list)
					)
				)
			)
		)
		xxx=0
		thol_list=remdq(nil thol_list)
		offset_change_mm_mil_units=0
		case(car(axlDBGetDesignUnits())
		("millimeters" offset_change_mm_mil_units=0.0254*7.87 )
		("mils" offset_change_mm_mil_units=7.87))
		foreach(pinitem thol_list
			if(axlSingleSelectBox(subdist_get_airgapbox(pinitem))!= nil then
				allboxes = axlGetSelSet()
				axlClearSelSet()
				foreach(itempin allboxes
					if(itempin->parent!=pinitem->parent && itempin->parent->type == "PACKAGE"  then
						if(pinitem->isMirrored==nil then
							if(itempin->isMirrored!=pinitem->isMirrored then
								if( rexMatchp("^1608C" upperCase(itempin->parent->name))|| rexMatchp("^1210C" upperCase(itempin->parent->name)) 
								|| rexMatchp("^2012C" upperCase(itempin->parent->name)) || rexMatchp("^2016C" upperCase(itempin->parent->name)) 
								|| rexMatchp("^2512C" upperCase(itempin->parent->name)) || rexMatchp("^3216C" upperCase(itempin->parent->name))
								|| rexMatchp("^1812C" upperCase(itempin->parent->name)) || rexMatchp("^2220C" upperCase(itempin->parent->name)) then
									if(nthelem(3 axlAirGap(itempin pinitem strcat( "ETCH/" select_layer_flag)))<2*Input_float_flag then  
										axlHighlightObject(itempin->parent t) 
										SBlist=cons(itempin->parent SBlist)
									)
								else
									if(nthelem(3 axlAirGap(itempin pinitem strcat( "ETCH/" select_layer_flag)))<Input_float_flag then  
										axlHighlightObject(itempin->parent t) 
										SBlist=cons(itempin->parent SBlist)
									)
								)
							/*
							;changed by andyluhero 2010.0722
							if(nthelem(3 axlAirGap(itempin pinitem strcat( "ETCH/" select_layer_flag)))<Input_float_flag then  
								axlHighlightObject(itempin->parent t) 
								SBlist=cons(itempin->parent SBlist)
							)
							*/
							else
								xxx=1
							)
						else
							if(itempin->isMirrored!=pinitem->isMirrored then
								if( rexMatchp("^1608C" upperCase(itempin->parent->name))|| rexMatchp("^1210C" upperCase(itempin->parent->name)) 
								|| rexMatchp("^2012C" upperCase(itempin->parent->name)) || rexMatchp("^2016C" upperCase(itempin->parent->name)) 
								|| rexMatchp("^2512C" upperCase(itempin->parent->name)) || rexMatchp("^3216C" upperCase(itempin->parent->name))
								|| rexMatchp("^1812C" upperCase(itempin->parent->name)) || rexMatchp("^2220C" upperCase(itempin->parent->name)) then
									if(nthelem(3 axlAirGap(itempin pinitem strcat( "ETCH/" select_layer_flag)))<2*Input_float_flag then  
										axlHighlightObject(itempin->parent t) 
										SBlist=cons(itempin->parent SBlist)
										)
								else
									if(nthelem(3 axlAirGap(itempin pinitem strcat( "ETCH/" select_layer_flag)))<Input_float_flag then  
										axlHighlightObject(itempin->parent t) 
										SBlist=cons(itempin->parent SBlist)
									)
								)
							/*
							if(itempin->isMirrored!=pinitem->isMirrored then
							if(nthelem(3 axlAirGap(itempin pinitem strcat( "ETCH/" select_layer_flag)))<Input_float_flag then  
							axlHighlightObject(itempin->parent t) 
							SBlist=cons(itempin->parent SBlist))
							*/
							else
								xxx=0
							)
						)
					)
				)
			)

			pintitemReg=axlDBGetPad(pinitem strcat("etch/"  select_layer_flag) "regular")
			;pinitemDiam=(pinitem->definition->drillDiameter)*0.5
			;pinitemDiam=(pinitem->definition->drillFigureWidth)*0.5
			pintitemReg_left=car(nthelem(1 pintitemReg->bBox))
			pintitemReg_right=car(nthelem(2 pintitemReg->bBox))
			pinitemRius=abs(pintitemReg_left-pintitemReg_right)*0.5
			if(pinitem->isMirrored==t then
			axlDBCreateCircle(( list pinitem->xy pinitemRius+Input_float_flag), 0, "PACKAGE GEOMETRY/Display_TOP" )
			else
			axlDBCreateCircle(( list pinitem->xy pinitemRius+Input_float_flag), 0, "PACKAGE GEOMETRY/Display_BOTTOM" )
			)
		)

		axlVisibleLayer(strcat("PACKAGE GEOMETRY/Display_" select_layer_flag)  t)
		SBlist=testing_justice_list(SBlist)
		SBlist=remdq(nil SBlist)
		testing_next_view_num=nil
		if(SBlist==nil then
			testing_next_view_num=cons("OK" testing_next_view_num)
		else
			foreach(symitem SBlist
				itemx=car(symitem->xy)
				itemy=cadr(symitem->xy)
				if(rexMatchp("^MARK" upperCase(symitem->name))  then
					testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->name itemx itemy) testing_next_view_num)
				else
					if(symitem->refdes == nil then
						foreach(txtitem symitem->children
							if(txtitem->layer=="REF DES/ASSEMBLY_TOP" || txtitem->layer =="REF DES/ASSEMBLY_BOTTOM"   then
							testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" txtitem->text itemx itemy) testing_next_view_num)
							)
						)
					else
						testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->refdes itemx itemy) testing_next_view_num)
					)
				)
				++subdist_cnt
			)
		)
		testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 3 \317\356: \321\271\275\323\241\242\262\250\267\345\272\270\275\323\277\3275mm:\271\262  %d  \317\356" subdist_cnt)
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		testing_next_view_num=remdq(nil testing_next_view_num)
		testing_next_view_All=testing_next_view_num
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		;if(subdist_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\321\271\275\323\241\242\262\250\267\345\272\270\275\323\277\3275mm"  subdist_cnt)
		axlUIWPrint(myform uidisplayer)
		axlFormDisplay(myform)
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)
	)
)
/*
(defun subdist_check_pressfit3r ()
prog( ()
SBlist=nil
subdist_pinslist=nil
axlClearSelSet()
subdist_Delete_object()
testing_unselect_object()
testing_turn_on_layer( select_layer_flag)
axlSetFindFilter(?enabled '(noall pins) ?onButtons '(noall pins))
subdist_pinslist= axlGetSelSet(axlAddSelectAll())
	axlClearSelSet()
	subdist_cnt = 0
subdist_pinslist=remdq(nil subdist_pinslist)	
thol_list=nil	
foreach(item subdist_pinslist
pin_symref=item->parent->refdes
pin_symname=item->parent->name
pin_name=item->name
if(item->parent->refdes && item->parent->name then
if(item->isThrough==t  && item->testpoint==nil && item->use!= ""  then ;&& item->use!= "NC" then
if(rexMatchp("^SB" pin_symref)==nil && rexMatchp("^HOL" pin_symname)==nil && rexMatchp("^TP" pin_symref)==nil then
thol_list=cons(item thol_list)
)))
)
xxx=0
thol_list=remdq(nil thol_list)
units=0
check_dist_units=0
offset_change_mm_mil_units=0
units=car(axlDBGetDesignUnits())	
if( (units=="mils") then
	check_dist_units=118.11 offset_change_mm_mil_units=7.87)
if( (units=="millimeters") then
	check_dist_units=3 offset_change_mm_mil_units=0.0254*7.87)
foreach(pinitem thol_list
		if(axlSingleSelectBox(subdist_get_airgapbox(pinitem))!= nil then
			allboxes = axlGetSelSet()
			axlClearSelSet()
			foreach(itempin allboxes
				if(itempin->parent!=pinitem->parent && itempin->parent->type == "PACKAGE" then
					if(pinitem->isMirrored==nil then
						if(itempin->isMirrored!=pinitem->isMirrored then
							if(nthelem(3 axlAirGap(itempin pinitem strcat( "ETCH/" select_layer_flag)))<check_dist_units then  
								axlHighlightObject(itempin->parent t) 
								SBlist=cons(itempin->parent SBlist))
						else
							xxx=1
						)
					else
						if(itempin->isMirrored!=pinitem->isMirrored then
							if(nthelem(3 axlAirGap(itempin pinitem strcat( "ETCH/" select_layer_flag)))<check_dist_units then  
								axlHighlightObject(itempin->parent t) 
								SBlist=cons(itempin->parent SBlist))
						else
							xxx=0
						)
					)

				)
				)
				)

pintitemReg=axlDBGetPad(pinitem strcat("etch/"  select_layer_flag) "regular")
;pinitemDiam=(pinitem->definition->drillDiameter)*0.5
;pinitemDiam=(pinitem->definition->drillFigureWidth)*0.5
pintitemReg_left=car(nthelem(1 pintitemReg->bBox))
pintitemReg_right=car(nthelem(2 pintitemReg->bBox))
pinitemRius=abs(pintitemReg_left-pintitemReg_right)*0.5
if(pinitem->isMirrored==t then
	axlDBCreateCircle(( list pinitem->xy pinitemRius+check_dist_units), 0, "PACKAGE GEOMETRY/Display_TOP" )
else
	axlDBCreateCircle(( list pinitem->xy pinitemRius+check_dist_units), 0, "PACKAGE GEOMETRY/Display_BOTTOM" )
)
)

axlVisibleLayer(strcat("PACKAGE GEOMETRY/Display_" select_layer_flag)  t)
SBlist=testing_justice_list(SBlist)
SBlist=remdq(nil SBlist)
testing_next_view_num=nil
if(SBlist==nil then
	testing_next_view_num=cons("OK" testing_next_view_num)
else
foreach(symitem SBlist
itemx=car(symitem->xy)
itemy=cadr(symitem->xy)
if(rexMatchp("^MARK" upperCase(symitem->name))  then
	testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->name itemx itemy) testing_next_view_num)
else
	if(symitem->refdes == nil then
		foreach(txtitem symitem->children
			if(txtitem->layer=="REF DES/ASSEMBLY_TOP" || txtitem->layer =="REF DES/ASSEMBLY_BOTTOM"   then
				testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" txtitem->text itemx itemy) testing_next_view_num)
			)
		)
	else
		testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->refdes itemx itemy) testing_next_view_num)
	)
)
++subdist_cnt
)
)
testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 11 \317\356: \321\271\275\323\241\242\262\250\267\345\272\270\275\323\277\3273mm:\271\262  %d  \317\356" subdist_cnt)
axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
testing_next_view_num=remdq(nil testing_next_view_num)
testing_next_view_All=testing_next_view_num
axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
;if(subdist_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))
uidisplayer=nil
uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\321\271\275\323\241\242\262\250\267\345\272\270\275\323\277\3275mm"  subdist_cnt)
axlUIWPrint(myform uidisplayer)
axlFormDisplay(myform)
axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
axlUIWUpdate(nil)
axlUIWRedraw(nil)
)
)
*/
;;;;;;;;;;;;;;;;;;;;;;;
;判断BGA范围子程序
; input :Input_float_flag  output : no
;;;;;;;;;;;;;;;;;;;;;;;
/*
(defun subdist_check_BGA_range ()
    prog( ()
		case(car(axlDBGetDesignUnits())
		("millimeters"  checkmil_units=0.0254  testing_line_distance1=5 testing_line_distance=2.5)
		("mils"   checkmil_units=0.9999  testing_line_distance1=200 testing_line_distance=98.42))
		axlClearSelSet()
		SBlist=nil
		subdist_lineslist=nil
		subdist_Delete_object()
		subdist_unselect_object()
			testing_turn_on_layer(select_layer_flag)
			axlSetFindFilter(?enabled '("noall" "components") ?onButtons '("noall" "components")) 
		axlOpenFindFilter()
		if(select_layer_flag=="TOP" then 
			layersym_list=axlGetSelSet(axlAddSelectAll())
			foreach( compitem  layersym_list
				if(compitem->symbol->isMirrored==t then
					layersym_list=remove(compitem layersym_list)
				)
			)
					layersym_list=remdq(nil layersym_list)
		else
			layersym_list=axlGetSelSet(axlAddSelectAll())

			foreach( compitem  layersym_list
				if(compitem->symbol->isMirrored==nil then
					layersym_list=remove(compitem layersym_list)
				)
			)
		)

		axlClearSelSet()
		get_BGA_list=nil
			foreach(symitem layersym_list
				if(rexMatchp("^PBGA"  upperCase(symitem->symbol->name)) || rexMatchp("^LGA"  upperCase(symitem->symbol->name)) || rexMatchp("CCGA"  upperCase(symitem->symbol->name))
				|| rexMatchp("^R-PBGA"  upperCase(symitem->symbol->name)) || rexMatchp("^R-XBGA"  upperCase(symitem->symbol->name)) then
							get_BGA_list=cons(symitem get_BGA_list)
							axlHighlightObject(symitem->symbol t)
				)
			)
		get_BGA_list=subdist_justice_symbol(get_BGA_list)
		get_BGA_list=remdq(nil get_BGA_list)
		uidisplayer=nil
		subdist_cnt = 0
		if(get_BGA_list!=nil then
		foreach(symbol_item get_BGA_list
			getbox=nil
			getbox1=nil
			get_line_list=nil
			foreach(item_outline symbol_item->symbol->children
				if(item_outline->objType=="path" && 
				item_outline->layer==strcat("PACKAGE GEOMETRY/SILKSCREEN_" select_layer_flag) then
					get_line_list=append(item_outline->segments get_line_list)
					foreach(item_outline_seg item_outline->segments
						allboxes = nil
						axlSetFindFilter(?enabled '("noall" "pins") ?onButtons '("noall" "pins")) 
						if(axlSingleSelectBox(subdist_BGAgetbox(item_outline_seg))!= nil then
								  allboxes = axlGetSelSet() 
								axlClearSelSet()
							foreach(item_pin allboxes
								;added item_pin->component!=nil && 2010.07.15 by andyluhero
								if(item_pin->component!=nil && item_pin->parent!=item_outline->parent then
									item1_item2_airgap=axlAirGap(item_outline_seg item_pin strcat( "ETCH/" select_layer_flag))
									if(item1_item2_airgap!=nil && nthelem(3 item1_item2_airgap)<=testing_line_distance then
										axlHighlightObject(item_pin->parent t)
										SBlist=cons(item_pin->parent SBlist)
									)
								)
							)
						)
					
					)
				)
			)
					get_line_list=remdq(nil get_line_list)
					minx=car(nthelem(1 andyfind_getmax_min(get_line_list)))
					miny=cadr(nthelem(1 andyfind_getmax_min(get_line_list)))
					maxx=car(nthelem(2 andyfind_getmax_min(get_line_list)))
					maxy=cadr(nthelem(2 andyfind_getmax_min(get_line_list)))
		getbox=list(minx-testing_line_distance:miny-testing_line_distance maxx+testing_line_distance:maxy+testing_line_distance)
		getbox1=list(minx-testing_line_distance1:miny-testing_line_distance1 maxx+testing_line_distance1:maxy+testing_line_distance1)
		axlDBCreateRectangle(getbox  nil strcat("PACKAGE GEOMETRY/Display_" select_layer_flag))
		)
		)
		axlVisibleLayer(strcat("PACKAGE GEOMETRY/Display_" select_layer_flag)  t)
		SBlist=subdist_justice_symbol(SBlist)
		SBlist=remdq(nil SBlist)
		testing_next_view_num=nil
		if(SBlist==nil then
			testing_next_view_num=cons("OK" testing_next_view_num)
		else
			foreach(symitem SBlist
				if(rexMatchp("^MARK" upperCase(symitem->name)) then
					itemx=car(symitem->xy)
					itemy=cadr(symitem->xy)
					testing_next_view_num =cons(sprintf(dummy "%s;  %.01f;  %.01f" symitem->name itemx itemy) testing_next_view_num)
				else
					
					itemx=car(symitem->xy)
					itemy=cadr(symitem->xy)
					testing_next_view_num =cons(sprintf(dummy "%s;  %.01f;  %.01f" symitem->refdes itemx itemy) testing_next_view_num)
				)
				++subdist_cnt
			)
		)
		testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 4 \317\356: BGA\326\334\316\247\306\367\274\376\276\340\300\353:\271\262  %d  \317\356" subdist_cnt)
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		testing_next_view_num=remdq(nil testing_next_view_num)
		testing_next_view_All=testing_next_view_num
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		;if(subdist_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356BGA\326\334\316\247\306\367\274\376\276\340\300\353"  subdist_cnt)
		axlUIWPrint(myform uidisplayer)
		axlFormDisplay(myform)
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)
	)
)


*/
(defun subdist_check_BGA_range ()
    prog( ()
		case(car(axlDBGetDesignUnits())
		("millimeters"   testing_line_distance1=5 testing_line_distance=2.5)
		("mils"   testing_line_distance1=196.84 testing_line_distance=98.42))
		axlClearSelSet()
		SBlist=nil
		subdist_lineslist=nil
		subdist_Delete_object()
		testing_unselect_object()
		testing_turn_on_layer(select_layer_flag)
		axlSetFindFilter(?enabled '("noall" "components") ?onButtons '("noall" "components")) 
		axlOpenFindFilter()
		if(select_layer_flag=="TOP" then 
			layersym_list=axlGetSelSet(axlAddSelectAll())
			foreach( compitem  layersym_list
				if(compitem->symbol->isMirrored==t then
					layersym_list=remove(compitem layersym_list)
				)
			)
					layersym_list=remdq(nil layersym_list)
		else
			layersym_list=axlGetSelSet(axlAddSelectAll())

			foreach( compitem  layersym_list
				if(compitem->symbol->isMirrored==nil then
					layersym_list=remove(compitem layersym_list)
				)
			)
		)
		axlClearSelSet()
		get_BGA_list=nil
		foreach(symitem layersym_list
			if(rexMatchp("^PBGA"  upperCase(symitem->symbol->name)) || rexMatchp("^LGA"  upperCase(symitem->symbol->name)) || rexMatchp("CCGA"  upperCase(symitem->symbol->name))
			|| rexMatchp("^R-PBGA"  upperCase(symitem->symbol->name)) || rexMatchp("^R-XBGA"  upperCase(symitem->symbol->name)) then
						get_BGA_list=cons(symitem get_BGA_list)
						axlHighlightObject(symitem->symbol t)
			)
		)
		get_BGA_list=testing_justice_list(get_BGA_list)
		get_BGA_list=remdq(nil get_BGA_list)
		uidisplayer=nil
		subdist_cnt = 0
		if(get_BGA_list!=nil then
			foreach(symbol_item get_BGA_list
				getbox=nil
				getbox1=nil
				get_line_list=nil
				foreach(item_outline symbol_item->symbol->children
					if(item_outline->objType=="path" && 
					item_outline->layer==strcat("PACKAGE GEOMETRY/SILKSCREEN_" select_layer_flag) then
						get_line_list=append(item_outline->segments get_line_list)
						foreach(item_outline_seg item_outline->segments
							allboxes = nil
							axlSetFindFilter(?enabled '("noall" "pins") ?onButtons '("noall" "pins")) 
							if(axlSingleSelectBox(subdist_BGAgetbox(item_outline_seg))!= nil then
								allboxes = axlGetSelSet() 
								axlClearSelSet()
								foreach(item_pin allboxes
									;added item_pin->component!=nil && 2010.07.15 by andyluhero
									if(item_pin->component!=nil && item_pin->parent!=item_outline->parent then
										item1_item2_airgap=axlAirGap(item_outline_seg item_pin strcat( "ETCH/" select_layer_flag))
										if(item1_item2_airgap!=nil && nthelem(3 item1_item2_airgap)<testing_line_distance then
											axlHighlightObject(item_pin->parent t)
											SBlist=cons(item_pin->parent SBlist)
										)
									)
								)
							)
						)
					)
				)
				get_line_max_min=nil
				get_line_list=remdq(nil get_line_list)
				get_line_max_min=testingfind_getmax_min(get_line_list)
				minx=car(nthelem(1 get_line_max_min))
				miny=cadr(nthelem(1 get_line_max_min))
				maxx=car(nthelem(2 get_line_max_min))
				maxy=cadr(nthelem(2 get_line_max_min))
				getbox=list(minx-testing_line_distance:miny-testing_line_distance maxx+testing_line_distance:maxy+testing_line_distance)
				getbox1=list(minx-testing_line_distance1:miny-testing_line_distance1 maxx+testing_line_distance1:maxy+testing_line_distance1)
				axlDBCreateRectangle(getbox  nil strcat("PACKAGE GEOMETRY/Display_" select_layer_flag))
			)
		)
		axlVisibleLayer(strcat("PACKAGE GEOMETRY/Display_" select_layer_flag)  t)
		SBlist=testing_justice_list(SBlist)
		SBlist=remdq(nil SBlist)
		testing_next_view_num=nil
		if(SBlist==nil then
			testing_next_view_num=cons("OK" testing_next_view_num)
		else
			foreach(symitem SBlist
				if(rexMatchp("^MARK" upperCase(symitem->name)) then
					itemx=car(symitem->xy)
					itemy=cadr(symitem->xy)
					testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->name itemx itemy) testing_next_view_num)
				else
					itemx=car(symitem->xy)
					itemy=cadr(symitem->xy)
					testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->refdes itemx itemy) testing_next_view_num)
				)
				++subdist_cnt
			)
		)
		testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 4 \317\356: BGA\326\334\316\247\306\367\274\376\276\340\300\353:\271\262  %d  \317\356" subdist_cnt)
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		testing_next_view_num=remdq(nil testing_next_view_num)
		testing_next_view_All=testing_next_view_num
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		;if(subdist_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356BGA\326\334\316\247\306\367\274\376\276\340\300\353"  subdist_cnt)
		axlUIWPrint(myform uidisplayer)
		axlFormDisplay(myform)
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;判断焊盘与焊盘间距小于80mil子程序
; input :no  output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_check_pin_range ()
	prog( ()
		axlClearSelSet()
		SBlist=nil
		subdist_pinslist=nil
		subdist_Delete_object()
		subdist_unselect_object()
		testing_turn_on_layer( testing_layer)
		axlSetFindFilter(?enabled '(noall pins) ?onButtons '(noall pins))
		subdist_pinslist= axlGetSelSet(axlAddSelectAll())
		axlClearSelSet()
		subdist_cnt = 0 
		foreach(pinitem subdist_pinslist
			if(rexMatchp("SMD" pinitem->name)  then
				if(axlSingleSelectBox(pinitem->bBox) != nil then
					allboxes = axlGetSelSet()
					axlClearSelSet()
					allbox= nil
					foreach(andn allboxes
						if(andn->parent!=pinitem->parent  then
							allbox=cons(andn allbox)
						)
					)
					have = nil
					  foreach(item allbox 
					  	if( item->objType == "pin" then
							if(axlAirGap(pinitem item strcat("PIN/SOLDERMASK_" select_layer_flag))== nil  then 
								axlHighlightObject(pinitem t)
								have = t
							else
								if(nthelem(3 axlAirGap(pinitem item strcat( "PIN/SOLDERMASK_" select_layer_flag)))<=12*change_mil_mm_units then
									axlHighlightObject(pinitem t)
									have = t
								)
							)
						)
						if(have then SBlist=cons(pinitem->parent SBlist))
					)
				)
			)
		)
		SBlist=subdist_justice_symbol(SBlist)
		SBlist=remdq(nil SBlist)
		testing_next_view_num=nil
		if(SBlist==nil then
			testing_next_view_num=cons("OK" testing_next_view_num)
		else
			foreach(symitem SBlist
				if(rexMatchp("^MARK" upperCase(symitem->name)) then
					itemx=car(symitem->xy)
					itemy=cadr(symitem->xy)
					testing_next_view_num =cons(sprintf(dummy "%s;  %.01f;  %.01f" symitem->name itemx itemy) testing_next_view_num)
				else
					
					itemx=car(symitem->xy)
					itemy=cadr(symitem->xy)
					testing_next_view_num =cons(sprintf(dummy "%s;  %.01f;  %.01f" symitem->refdes itemx itemy) testing_next_view_num)
				)
				++subdist_cnt
			)
		)
		testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 5 \317\356: \272\270\305\314\274\344\276\340\262\273\267\373\272\317\271\244\322\325\271\346\267\266:\271\262  %d  \317\356" subdist_cnt)
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		testing_next_view_num=remdq(nil testing_next_view_num)
		testing_next_view_All=testing_next_view_num
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		;if(subdist_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\272\270\305\314\274\344\276\340\262\273\267\373\272\317\271\244\322\325\271\346\267\266"  subdist_cnt)
		axlUIWPrint(myform uidisplayer)
		axlFormDisplay(myform)
		axlVisibleUpdate(t)
		axlUIWRedraw(nil)

	)
)
/*
(defun subdist_check_pin_range ()
prog( ()
axlClearSelSet()
SBlist=nil
subdist_pinslist=nil
subdist_Delete_object()
testing_unselect_object()
testing_turn_on_layer( select_layer_flag)
    axlSetFindFilter(?enabled '(noall pins) ?onButtons '(noall pins))
    subdist_pinslist= axlGetSelSet(axlAddSelectAll())
axlClearSelSet()
subdist_cnt = 0 
foreach(pinitem subdist_pinslist
	if(rexMatchp("SMD" pinitem->name)  then
	if(axlSingleSelectBox(subdist_pin12_getbox(pinitem)) != nil then
	allboxes = axlGetSelSet()
  	axlClearSelSet()
  	allbox= nil
	foreach(andn allboxes
		if( andn->xy!=pinitem->xy && andn->parent->refdes!=pinitem->parent->refdes  then
				allbox=cons(andn allbox)
		))

  have = nil
      foreach(item allbox 
      if( item->objType == "pin"  then 
          axlHighlightObject( pinitem->parent t)
          have = t
		)
        if(have then SBlist=cons(pinitem->parent SBlist))
	))))
SBlist=testing_justice_list(SBlist)
SBlist=remdq(nil SBlist)
testing_next_view_num=nil
if(SBlist==nil then
	testing_next_view_num=cons("OK" testing_next_view_num)
else
foreach(symitem SBlist
if(rexMatchp("^MARK" upperCase(symitem->name)) then
itemx=car(symitem->xy)
itemy=cadr(symitem->xy)
testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->name itemx itemy) testing_next_view_num)
else
	
	itemx=car(symitem->xy)
	itemy=cadr(symitem->xy)
	testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->refdes itemx itemy) testing_next_view_num)
)
++subdist_cnt
)
)
testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 5 \317\356: \272\270\305\314\274\344\276\340\262\273\267\373\272\317\271\244\322\325\271\346\267\266:\271\262  %d  \317\356" subdist_cnt)
axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
testing_next_view_num=remdq(nil testing_next_view_num)
testing_next_view_All=testing_next_view_num
axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
;if(subdist_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))
uidisplayer=nil
uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\272\270\305\314\274\344\276\340\262\273\267\373\272\317\271\244\322\325\271\346\267\266"  subdist_cnt)
axlUIWPrint(myform uidisplayer)
axlFormDisplay(myform)
axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
axlUIWUpdate(nil)
axlUIWRedraw(nil)

))
*/
;;;;;;;;;;;;;;;;;;;;;;;
;判断焊盘上有过孔子程序
; input :Input_float_flag  output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun subdist_check_via_on_pad ()
	prog( ()
		axlClearSelSet()
		SBlist=nil
		subdist_pinslist=nil
		subdist_Delete_object()
		testing_unselect_object()
		testing_turn_on_layer( select_layer_flag)
		axlSetFindFilter(?enabled '(noall pins) ?onButtons '(noall pins))
		subdist_pinslist= axlGetSelSet(axlAddSelectAll())
		axlClearSelSet()
		subdist_cnt = 0
		subdist_pinslist=remdq(nil subdist_pinslist)
		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:VIA CLASS/paramLayer:%s" select_layer_flag))
		Going_On->visible=t
		axlSetParam(Going_On)
		axlSetFindFilter(?enabled '(noall vias)    ?onButtons '(noall vias))
		foreach(pinitem subdist_pinslist
			if(rexMatchp("SMD" pinitem->name)  then
				if(axlSingleSelectBox(subdist_getbox(pinitem)) != nil then
					allboxes = axlGetSelSet()
					axlClearSelSet()
					allselvia = nil
					have = nil
					foreach(item allboxes 
					  if( item->objType == "via"  then 
						  axlHighlightObject( pinitem->parent t)
						  have = t
						)
						if(have then 
							SBlist=cons(pinitem->parent SBlist)
						)
					)
				)
			)
		)
		SBlist=testing_justice_list(SBlist)
		SBlist=remdq(nil SBlist)
		testing_next_view_num=nil
		if(SBlist==nil then
			testing_next_view_num=cons("OK" testing_next_view_num)
		else
			foreach(symitem SBlist
				if(rexMatchp("^MARK" upperCase(symitem->name)) then
					itemx=car(symitem->xy)
					itemy=cadr(symitem->xy)
					testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->name itemx itemy) testing_next_view_num)
				else
					itemx=car(symitem->xy)
					itemy=cadr(symitem->xy)
					testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->refdes itemx itemy) testing_next_view_num)
				)
				++subdist_cnt
			)
		)
		testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 6 \317\356: \271\375\277\327\311\317\272\270\305\314:\271\262  %d  \317\356" subdist_cnt)
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		testing_next_view_num=remdq(nil testing_next_view_num)
		testing_next_view_All=testing_next_view_num
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		;if(subdist_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\271\375\277\327\311\317\272\270\305\314"  subdist_cnt)
		axlUIWPrint(myform uidisplayer)
		axlFormDisplay(myform)
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)	
	)
)

;;;;;;;;;;;;;;;;;;;;;;;
;判断焊盘上有铜皮子程序
; input :Input_float_flag  output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun subdist_check_thermal_on_pad ()
	prog( ()
		axlClearSelSet()
		SBlist=nil
		subdist_pinslist=nil
		subdist_Delete_object()
		testing_unselect_object()
		testing_turn_on_layer( select_layer_flag)
		axlSetFindFilter(?enabled '(noall pins) ?onButtons '(noall pins))
		subdist_pinslist= axlGetSelSet(axlAddSelectAll())
		axlClearSelSet()
		subdist_cnt = 0 
		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:ETCH/paramLayer:%s" select_layer_flag))
		Going_On->visible=t
		axlSetParam(Going_On)

		axlSetFindFilter(?enabled '(noall shapes)  ?onButtons '(noall shapes))
		foreach(pinitem subdist_pinslist
			pinname=pinitem->name
			symname=pinitem->parent->refdes
			if(symname then
				if(rexMatchp("Y$" pinname)==nil && rexMatchp("SB" symname)==nil && rexMatchp("TP" symname)==nil
				&& rexMatchp("MARK" pinname)==nil && pinitem->isMech==nil && rexMatchp("_SM$" pinname)==nil then
					if(axlSingleSelectBox(subdist_getbox(pinitem))  != nil then
						allboxes = axlGetSelSet() 
						axlClearSelSet()
						have = nil
						allbox=nil
						case(car(axlDBGetDesignUnits())
						("millimeters"  subdist_andy_clearance=0.125)
						("mils" subdist_andy_clearance=5))
						foreach(item allboxes 
							if(item->objType == "shape" && item->layer==strcat( "ETCH/" select_layer_flag) then
								if(rexMatchp("SMD" pinitem->name)==nil  then
										if(nthelem(3 axlAirGap(item pinitem strcat( "ETCH/" select_layer_flag)))<subdist_andy_clearance then 
										axlHighlightObject(list(pinitem->parent))
												have= t
											);)
								else
								;if(nthelem(3 axlAirGap(item pinitem strcat( "ETCH/" select_layer_flag)))<subdist_andy_clearance then 
										axlHighlightObject(list(pinitem->parent))
												have= t
								)
							)
								if(have then 	SBlist=cons(pinitem->parent SBlist))
						)
					)
				)
			)
		)
		testing_turn_on_layer( select_layer_flag)
		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:ETCH/paramLayer:%s" select_layer_flag))
		Going_On->visible=t
		axlSetParam(Going_On)
		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:VIA CLASS/paramLayer:%s" select_layer_flag))
		Going_On->visible=t
		axlSetParam(Going_On)  
		SBlist=testing_justice_list(SBlist)
		SBlist=remdq(nil SBlist)
		testing_next_view_num=nil
		if(SBlist==nil then
			testing_next_view_num=cons("OK" testing_next_view_num)
		else
			foreach(symitem SBlist
				if(rexMatchp("^MARK" upperCase(symitem->name)) then
					itemx=car(symitem->xy)
					itemy=cadr(symitem->xy)
					testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->name itemx itemy) testing_next_view_num)
				else

					itemx=car(symitem->xy)
					itemy=cadr(symitem->xy)
					testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->refdes itemx itemy) testing_next_view_num)
				)
				++subdist_cnt
			)
		)
		testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 7 \317\356: \272\270\305\314\266\324\263\306\312\265\301\254\275\323:\271\262  %d  \317\356" subdist_cnt)
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		testing_next_view_num=remdq(nil testing_next_view_num)
		testing_next_view_All=testing_next_view_num
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		;if(subdist_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\272\270\305\314\266\324\263\306\312\265\301\254\275\323"  subdist_cnt)
		axlUIWPrint(myform uidisplayer)
		axlFormDisplay(myform)
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)
	)
)

/*
(defun subdist_check_cline_on_pad ()
prog( ()
axlClearSelSet()
SBlist=nil
subdist_pinslist=nil
subdist_Delete_object()
testing_unselect_object()
    axlSetFindFilter(?enabled '(noall pins) ?onButtons '(noall pins))
    subdist_pinslist= axlGetSelSet(axlAddSelectAll())
Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:ETCH/paramLayer:%s" select_layer_flag))
    Going_On->visible=t
    axlSetParam(Going_On)
axlClearSelSet()
	subdist_cnt = 0 
      axlSetFindFilter(?enabled '(noall clinesegs vias)      ?onButtons '(noall clinesegs vias))
foreach(pinitem subdist_pinslist
	if(rexMatchp("BGA" pinitem ->parent->name) == nil then 
	if(axlSingleSelectBox(subdist_getbox(pinitem)) != nil then
	allboxes=nil
      allboxes = axlGetSelSet()
  	axlClearSelSet()
  	have = nil
		case(car(axlDBGetDesignUnits())
		("millimeters" subdist_clearance=5*0.0254)
		("mils" subdist_clearance=5))
      foreach(item allboxes 
      if(  item->net->name!=pinitem->net->name  then
		if(nthelem(3 axlAirGap(item pinitem strcat( "ETCH/" select_layer_flag)))<subdist_clearance then
          axlHighlightObject( pinitem->parent t)
          have = t
		))
        if(have then SBlist=cons(pinitem->parent SBlist))
	))))
SBlist=testing_justice_list(SBlist)
SBlist=remdq(nil SBlist)
testing_next_view_num=nil
if(SBlist==nil then
	testing_next_view_num=cons("OK" testing_next_view_num)
else
foreach(symitem SBlist
if(rexMatchp("^MARK" upperCase(symitem->name)) then
itemx=car(symitem->xy)
itemy=cadr(symitem->xy)
testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->name itemx itemy) testing_next_view_num)
else
	
	itemx=car(symitem->xy)
	itemy=cadr(symitem->xy)
	testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->refdes itemx itemy) testing_next_view_num)
)
++subdist_cnt
)
)
testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 9 \317\356: \272\270\305\314\265\275\301\254\317\337:\271\262  %d  \317\356" subdist_cnt)
axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
testing_next_view_num=remdq(nil testing_next_view_num)
testing_next_view_All=testing_next_view_num
axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
;if(subdist_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))
uidisplayer=nil
uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\313\277\323\241\321\271\272\270\305\314"  subdist_cnt)
axlUIWPrint(myform uidisplayer)
axlFormDisplay(myform)
axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
axlUIWUpdate(nil)
axlUIWRedraw(nil)
)
)
*/
;;;;;;;;;;;;;;;;;;;;;;;
;判断BGA外框范围子程序
; input :andline  output : list(left:bottom right:top)
;;;;;;;;;;;;;;;;;;;;;;;
(defun subdist_BGAgetbox (andline)
	(prog ()
		loff =0 toff = 0 roff = 0 boff = 0 subdist_andy_clearance=100
		case(car(axlDBGetDesignUnits())
		("millimeters"  subdist_andy_clearance=2.5)
		("mils" subdist_andy_clearance=98.42 ))
		left = car(nth(0 andline->bBox)) - subdist_andy_clearance
		top = cadr(nth(1 andline->bBox)) + subdist_andy_clearance 
		right = car(nth(1 andline->bBox)) + subdist_andy_clearance
		bottom = cadr(nth(0 andline->bBox)) - subdist_andy_clearance
		return(list(left:bottom right:top))    
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;判断器件体外框范围子程序
; input :andy_symbols  output : list(left:bottom right:top)
;;;;;;;;;;;;;;;;;;;;;;;

(defun subdist_getbox (andy_symbols)
	(prog ()
		subdist_andy_clearance=6
		case(car(axlDBGetDesignUnits())
		("millimeters"  subdist_andy_clearance=0.2)
		("mils" subdist_andy_clearance=8 ))
		loff =0 toff = 0 roff = 0 boff = 0 
		left = car(nth(0 andy_symbols->bBox)) + subdist_andy_clearance
		top = cadr(nth(1 andy_symbols->bBox)) - subdist_andy_clearance 
		right = car(nth(1 andy_symbols->bBox)) - subdist_andy_clearance
		bottom = cadr(nth(0 andy_symbols->bBox)) + subdist_andy_clearance
		return(list(left:bottom  right:top))    
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;判断焊盘范围子程序
; input :pin12  output : list(left:bottom right:top)
;;;;;;;;;;;;;;;;;;;;;;;
(defun subdist_pin12_getbox (pin12)
	(prog ()
		subdist_andy_clearance=4
		case(car(axlDBGetDesignUnits())
		("millimeters"  subdist_andy_clearance=0.5)
		("mils" subdist_andy_clearance=20 ))
		loff =0 toff = 0 roff = 0 boff = 0 
		left = car(nth(0 pin12->bBox)) - subdist_andy_clearance
		top = cadr(nth(1 pin12->bBox)) + subdist_andy_clearance 
		right = car(nth(1 pin12->bBox)) +subdist_andy_clearance
		bottom = cadr(nth(0 pin12->bBox)) - subdist_andy_clearance
		return(list(left:bottom right:top))    
	)
)


 /* ;;;delete vias on testpoints
(defun delete_vias_testpoints ()
(prog ()
allvialist=nil
alltestvia=nil
have=0
axlSetFindFilter(?enabled '("noall" "vias") ?onButtons '("noall" "vias")) 
allvialist = axlGetSelSet(axlAddSelectAll())
axlClearSelSet()
deletlist=nil
foreach(viaitem allvialist 
      if( viaitem->testPoint!= nil && viaitem->isThrough != nil then 
		allboxes =nil
	    if(axlSingleSelectBox(viaitem->bBox) != nil then
		;axlDBCreateRectangle(viaitem->bBox nil "PACKAGE GEOMETRY/Display_top")
      			allboxes = axlGetSelSet() 
			axlClearSelSet()
		foreach(item allboxes
			if(item->name!=viaitem->name then
			if( item->objType == "via"  && item->testPoint==nil then
				deletlist=cons(item deletlist)
          			axlHighlightObject(list(viaitem))
				;axlDeleteObject(item)
         			 have++
      				) 
  			)

		)
	)
))
deletlist=remdq(nil deletlist)
axlDeleteObject(deletlist)
;println(have)
))
*/
/*
andyfind_layer="TOP"
subandyformname= nil
Current_Ref_Des=nil
Comp_List=nil
Placed_List=nil
;Ref_Des_Filter="*"
andycheck_box=nil
(defun andyFind_Component_Routine ()
Design = axlDBGetDesign()
        symbolslist = Design->symbols
        netslist= Design ->nets
	functionlist=Design ->functions
	pinlist= Design ->pins
	foreach( Item  symbolslist	axlDehighlightObject(Item t))
	;foreach( Item  netslist	axlDehighlightObject(Item t))
	foreach( Item  functionlist	axlDehighlightObject(Item t))
	foreach( Item  pinlist	axlDehighlightObject(Item t) )
    axlVisibleDesign(nil)
    andyfind_turn_on_layer( andyfind_layer)
    subandyformname= "./andysub_find_form.form" 
    biuld_subandyform(subandyformname)
)

(defun biuld_subandyform (subandyformname)
(prog ()  
andysub_find_form=outfile("andysub_find_form.form" "w")
  fprintf(andysub_find_form "FILE_TYPE=FORM_DEFN VERSION=2\n")
  fprintf(andysub_find_form "FORM\n")
  fprintf(andysub_find_form "FIXED\n")
  fprintf(andysub_find_form "PORT 25 20\n")
  fprintf(andysub_find_form "HEADER \"\270\337\301\301\306\367\274\376\"\n")
  fprintf(andysub_find_form "POPUP <Layer_Names>")
  fprintf(andysub_find_form "\"TOP\" \"TOP\",\"BOTTOM\" \"BOTTOM\".\n")
  fprintf(andysub_find_form "TILE\n")
  
  fprintf(andysub_find_form "TEXT \"\321\241\324\361\262\343:\"\n")
  fprintf(andysub_find_form "TLOC 3 0\n")
  fprintf(andysub_find_form "ENDTEXT\n")
  fprintf(andysub_find_form "FIELD andyfind_check_layer\n")
  fprintf(andysub_find_form "FLOC 12 0\n")
  fprintf(andysub_find_form "ENUMSET 8\n")
  fprintf(andysub_find_form "POP \"Layer_Names\"\n")
  fprintf(andysub_find_form "ENDFIELD\n")
  
  fprintf(andysub_find_form "TEXT \"COMPONENTS LIST\"\n")
  fprintf(andysub_find_form "TLOC 4 4\n")
  fprintf(andysub_find_form "ENDTEXT\n")

  fprintf(andysub_find_form "FIELD Placed_List\n")
  fprintf(andysub_find_form "FLOC 2 6\n")
  fprintf(andysub_find_form "LIST \"\" 21 10\n")
  fprintf(andysub_find_form "ENDFIELD\n")

  fprintf(andysub_find_form "TEXT \"\306\367\274\376\301\320\261\355\"\n")
  fprintf(andysub_find_form "TLOC 2 25\n")
  fprintf(andysub_find_form "ENDTEXT\n")
  fprintf(andysub_find_form "FIELD Current_Ref_Des\n")
  fprintf(andysub_find_form "FLOC 2 27\n")
  fprintf(andysub_find_form "STRFILLIN 16 10\n")
  fprintf(andysub_find_form "ENDFIELD\n")

  ;fprintf(andysub_find_form "TEXT \"Filter:\"\n")
 ; fprintf(andysub_find_form "TLOC 2 30\n")
 ; fprintf(andysub_find_form "ENDTEXT\n")

 ; fprintf(andysub_find_form "FIELD Ref_Des_Filter\n")
  ;fprintf(andysub_find_form "FLOC 10 30\n")
  ;fprintf(andysub_find_form "STRFILLIN 5 10\n")
  ;fprintf(andysub_find_form "ENDFIELD\n")

  fprintf(andysub_find_form "FIELD Refresh_List\n")
  fprintf(andysub_find_form "FLOC 2 30\n")
  fprintf(andysub_find_form "MENUBUTTON \"\313\242\320\302\301\320\261\355\" 15 3\n")
  fprintf(andysub_find_form "ENDFIELD\n")

  fprintf(andysub_find_form "FIELD done\n")
  fprintf(andysub_find_form "FLOC 2 33\n")
  fprintf(andysub_find_form "MENUBUTTON \"\315\352\263\311\" 7 3\n")
  fprintf(andysub_find_form "ENDFIELD\n")
  fprintf(andysub_find_form "ENDTILE\n")
  fprintf(andysub_find_form "ENDFORM\n")
  close(andysub_find_form)
  andysub_find_form=axlFormCreate( (gensym) "andysub_find_form.form" 
  `(e outer) `andysub_find_form_Action t)
	Placed_List==nil
  axlFormSetField(andysub_find_form "andyfind_check_layer" andyfind_layer)
  axlFormSetField(andysub_find_form "Placed_List" Placed_List)
    axlFormDisplay(andysub_find_form)
	
	Placed_List=andycheck_box()
    (if Placed_List==nil then
     axlFormListDeleteAll(andysub_find_form "Placed_List")
     axlFormSetField(andysub_find_form "Placed_List" "No Match")
    ; axlFormSetField(andysub_find_form "Ref_Des_Filter" Ref_Des_Filter)
	axlFormSetField(andysub_find_form "andyfind_check_layer" andyfind_layer)
     axlFormDisplay(andysub_find_form)
     axlUIWPrint(andysub_find_form "No Match")
     else
     axlFormListDeleteAll(andysub_find_form "Placed_List")
     ;Placed_List=sort(Placed_List nil)
      axlFormSetField(andysub_find_form "Placed_List" Placed_List)
     ; axlFormSetField(andysub_find_form "Ref_Des_Filter" Ref_Des_Filter)
	axlFormSetField(andysub_find_form "andyfind_check_layer" andyfind_layer)
      axlFormDisplay(andysub_find_form)
      axlUIWPrint(andysub_find_form "Select Component")
axlClearSelSet()
    ); end if Placed_List==nil

))
(defun andysub_find_form_Action (andysub_find_form)
Command=nil
axlDBRefreshId(axlDBGetDesign())
  (case andysub_find_form->curField

    ("done"
	subandy_unselect_object()
	;subandy_Delete_object()
        axlFormClose(andysub_find_form)
        axlCancelEnterFun()
	 if(isFile(subandyformname)        deleteFile(subandyformname));endif
    	   ; myformname = "./testing_mainform.form" 
       ;biuld_testing_mainform(myformname)
	andylu()
        axlMsgPut("Done")
	t
    )
("Placed_List"
deletelinelist=nil
axlVisibleDesign(nil)
axlVisibleLayer( strcat("MANUFACTURING/lless 600 "  andyfind_layer) t )
axlVisibleLayer( strcat("MANUFACTURING/lmore 600 "  andyfind_layer) t )
axlSetFindFilter(?enabled '(noall lines) ?onButtons '(noall lines))
deletelinelist=axlGetSelSet(axlAddSelectAll())
axlClearSelSet()
axlDeleteObject(deletelinelist)
	axlSetFindFilter(?enabled '(components) ?onButtons '(components))
     	Component=axlGetSelSet(axlSingleSelectName("COMPONENT" strcat(andysub_find_form->curValue)))
	compsymbol=car(Component)->symbol
	andyfind_line_symbols(compsymbol)
     	axlHighlightObject(compsymbol t)
     window_buffer = axlMKSConvert(400 "MILS")
     Lower_X=car(car(car(Component)->symbol->bBox))-window_buffer
     Lower_Y=car(cdr(car(car(Component)->symbol->bBox)))-window_buffer
     Upper_X=car(car(cdr(car(Component)->symbol->bBox)))+window_buffer
     Upper_Y=car(cdr(car(cdr(car(Component)->symbol->bBox))))+window_buffer
     Command=sprintf(dummy "window points;x %f y %f;x %f y %f" Lower_X Lower_Y Upper_X Upper_Y)
     axlFormSetField(andysub_find_form "Current_Ref_Des" andysub_find_form->curValue)
     axlShell(Command)
     t
    ); end "Placed_List"


testing_view_all=strcat(myform->curValue)
	units=car(axlDBGetDesignUnits())	
	if( (units=="mils") then
		    viewx = 400
    			viewy = 300
			rectx=20)
	if( (units=="millimeters") then
    viewx = 10
    viewy = 7.5
	rectx=0.5	)
lst = parseString(testing_view_all ";")
refdes = sprintf(dummy " %s" nthelem(1 lst))
    x = atoi(nthelem(2 lst))
    y = atoi(nthelem(3 lst))
axlUIWPrint(myform refdes)
axlWindowBoxSet(list(x-viewx:y-viewy x+viewx:y+viewy))
axlSetFindFilter(?enabled '( text ) ?onButtons '( text ))
allboxes=nil
andyluhero=0
if(axlSingleSelectBox(list(x-rectx:y-rectx x+rectx:y+rectx))!=nil then
	allboxes = axlGetSelSet() 
foreach(txtitem allboxes 
if(txtitem->parent!=nil then
	if(txtitem->parent->type == "PACKAGE" then
		axlHighlightObject(txtitem->parent)
	else
		++andyluhero
		axlHighlightObject(txtitem->parent)
	)
else
axlHighlightObject(txtitem)
)
)
)
)


("Refresh_List"
	subandy_unselect_object()
	Placed_List=andycheck_box()
    (if Placed_List==nil then
     axlFormListDeleteAll(andysub_find_form "Placed_List")
     axlFormSetField(andysub_find_form "Placed_List" "No Match")
    ; axlFormSetField(andysub_find_form "Ref_Des_Filter" Ref_Des_Filter)
	axlFormSetField(andysub_find_form "andyfind_check_layer" andyfind_layer)
     axlFormDisplay(andysub_find_form)
     axlUIWPrint(andysub_find_form "No Match")
     else
     axlFormListDeleteAll(andysub_find_form "Placed_List")
     ;Placed_List=sort(Placed_List nil)
      axlFormSetField(andysub_find_form "Placed_List" Placed_List)
     ; axlFormSetField(andysub_find_form "Ref_Des_Filter" Ref_Des_Filter)
	axlFormSetField(andysub_find_form "andyfind_check_layer" andyfind_layer)
      axlFormDisplay(andysub_find_form)
      axlUIWPrint(andysub_find_form "Select Component")
axlClearSelSet()
    ); end if Placed_List==nil
   ); end Refresh_List
;("Ref_Des_Filter"
 ;    (if andysub_find_form->curValue == "" then
 ;     Ref_Des_Filter="*" else
 ;     Ref_Des_Filter=upperCase(andysub_find_form->curValue)
  ;    t
  ;   ); end if
  ;  ); end "Ref_Des_Filter"

    ("andyfind_check_layer"
	subandy_unselect_object()
       andyfind_layer = andysub_find_form->curValue
       andyfind_turn_on_layer(andyfind_layer) ;turn on the layer etch : etch pin via 
        axlMsgPut("Select %s layer" andyfind_layer)
	Placed_List==nil
	Placed_List=andycheck_box()
    (if Placed_List==nil then
     axlFormListDeleteAll(andysub_find_form "Placed_List")
     axlFormSetField(andysub_find_form "Placed_List" "No Match")
;     axlFormSetField(andysub_find_form "Ref_Des_Filter" Ref_Des_Filter)
	axlFormSetField(andysub_find_form "andyfind_check_layer" andyfind_layer)
     axlFormDisplay(andysub_find_form)
     axlUIWPrint(andysub_find_form "No Match")
     else
     axlFormListDeleteAll(andysub_find_form "Placed_List")
     ;Placed_List=sort(Placed_List nil)
      axlFormSetField(andysub_find_form "Placed_List" Placed_List)
    ;  axlFormSetField(andysub_find_form "Ref_Des_Filter" Ref_Des_Filter)
	axlFormSetField(andysub_find_form "andyfind_check_layer" andyfind_layer)
      axlFormDisplay(andysub_find_form)
      axlUIWPrint(andysub_find_form "Select Component")
axlClearSelSet()
    ); end if Placed_List==nil
	axlUIWRedraw(nil)
	axlUIWUpdate(nil)

        t
    )

))


(defun andyfind_turn_on_layer ( andyfind_layer)
    axlVisibleDesign(nil)
	axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t) 
    Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:BOARD GEOMETRY/paramLayer:SOLDERMASK_%s" andyfind_layer))
    Going_On->visible=t
    axlSetParam(Going_On)

    Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:BOARD GEOMETRY/paramLayer:SILKSCREEN_%s" andyfind_layer))
    Going_On->visible=t
    axlSetParam(Going_On)
    ;Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:BOARD GEOMETRY/paramLayer:Switch_Area_%s" andyfind_layer))
    ;Going_On->visible=t
    ;axlSetParam(Going_On)
    ;Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:PACKAGE GEOMETRY/paramLayer:Display_%s" andyfind_layer))
    ;Going_On->visible=t
    ;axlSetParam(Going_On)

    Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:VIA CLASS/paramLayer:SOLDERMASK_%s" andyfind_layer))
   Going_On->visible=t
    axlSetParam(Going_On)
    Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:PACKAGE GEOMETRY/paramLayer:SOLDERMASK_%s" select_layer_flag))
    Going_On->visible=t
    axlSetParam(Going_On)  
    ;Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:VIA CLASS/paramLayer:%s" andyfind_layer))
    ;Going_On->visible=t
    ;axlSetParam(Going_On)  

    Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:PIN/paramLayer:%s" andyfind_layer))
    Going_On->visible=t
    axlSetParam(Going_On)
Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:PIN/paramLayer:SOLDERMASK_%s" andyfind_layer))
    Going_On->visible=t
    axlSetParam(Going_On)
    
    Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:PACKAGE GEOMETRY/paramLayer:SILKSCREEN_%s" andyfind_layer))
    Going_On->visible=t
    axlSetParam(Going_On)  
    Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:REF DES/paramLayer:SILKSCREEN_%s" andyfind_layer))
    Going_On->visible=t
    axlSetParam(Going_On)

    Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:ROUTE KEEPOUT/paramLayer:%s" andyfind_layer))
    Going_On->visible = t
    axlSetParam(Going_On)

    Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:PACKAGE KEEPOUT/paramLayer:%s" andyfind_layer))
    Going_On->visible = t
    axlSetParam(Going_On)
   axlVisibleLayer("ROUTE KEEPOUT/All" t)
   axlVisibleLayer("ROUTE KEEPIN" t)
   axlVisibleLayer("PACKAGE KEEPOUT/All" t)

    axlUIWRedraw(nil)
    axlClearSelSet()
)

(defun andyfind_line_symbols (symitem)
    prog( ()
	symxy=0
	txtxy=0
	unless( axlIsVisibleLayer( strcat("MANUFACTURING/lless 600 "  andyfind_layer) )
		axlVisibleLayer( strcat("MANUFACTURING/lless 600 "  andyfind_layer) t )
        )
	unless( axlIsVisibleLayer( strcat("MANUFACTURING/lmore 600 "  andyfind_layer) )
		axlVisibleLayer( strcat("MANUFACTURING/lmore 600 "  andyfind_layer) t )
        )
	if(symitem->type == "PACKAGE" then 
		foreach(txt symitem->children 
			if(txt->objType == "text" then 
			if(txt->layer ==strcat("REF DES/SILKSCREEN_" andyfind_layer)  then 
					if( txt->parent->xy != nil && txt->xy != nil then
			symxy= txt->parent->xy
			txtxy = txt->xy
			symline=list(txtxy symxy)
			andyfind_line1width=0
			andyfind_line2width=0
			andyfind_linelength=0
			case(car(axlDBGetDesignUnits())
		("millimeters" andyfind_line1width=0.1  andyfind_line2width=0.075   andyfind_linelength=15 )
		("mils" andyfind_line1width=4  andyfind_line2width=3   andyfind_linelength=600 ))
    	if(axlDistance(txtxy symxy)<andyfind_linelength  then 				
			pline=axlDBCreateLine(symline,andyfind_line1width, strcat("MANUFACTURING/lless 600 " andyfind_layer) )
			else
			pline=axlDBCreateLine(symline,andyfind_line2width, strcat("MANUFACTURING/lmore 600 " andyfind_layer) )
			))
			))
			))

Highlightlinelist=nil
axlVisibleDesign(nil)
axlVisibleLayer( strcat("MANUFACTURING/lless 600 "  andyfind_layer) t )
axlVisibleLayer( strcat("MANUFACTURING/lmore 600 "  andyfind_layer) t )
axlSetFindFilter(?enabled '(noall lines) ?onButtons '(noall lines))
Highlightlinelist=axlGetSelSet(axlAddSelectAll())
axlClearSelSet()
axlHighlightObject(Highlightlinelist)
andyfind_turn_on_layer(andyfind_layer)
axlVisibleLayer( strcat("MANUFACTURING/lless 600 "  andyfind_layer) t )
axlVisibleLayer( strcat("MANUFACTURING/lmore 600 "  andyfind_layer) t )
axlUIWRedraw(nil)
axlUIWUpdate(nil)
))
(defun andycheck_box ()
    prog( ()
axlVisibleDesign(nil)
axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t)
axlSetFindFilter(?enabled '("noall"  "shapes" "linesegs") ?onButtons '("noall" "shapes" "linesegs" ))
shapeline_segments = axlGetSelSet(axlAddSelectAll())
andy_segments=nil
foreach(item shapeline_segments
	if(item->objType="shape" then
		    andy_segments=append(item->segments andy_segments))
	if(item->objType="line" then
		    andy_segments=cons(item andy_segments)
	))
 andy_segments=remdq(nil andy_segments)   
 
  ; axlSetFindFilter(?enabled '("noall"  "shapes" ) ?onButtons '("noall" "shapes" ))
  ;  andy_segments = axlGetSelSet(axlAddSelectAll())
;if(andy_segments==nil then 
  ;  axlSetFindFilter(?enabled '("noall" "linesegs" ) ?onButtons '("noall" "linesegs" ))
  ;  axlClearSelSet( )
  ;  andy_segments = axlGetSelSet(axlAddSelectAll())
  ;  else
  ;  andy_segments=car(andy_segments)
  ;  andy_segments=andy_segments->segments
 ; )
axlClearSelSet()
segitem_xlist=nil
segitem_ylist=nil
	if(andy_segments!=nil then 
	minx=car(nthelem(1 testingfind_getmax_min(andy_segments)))
	miny=cadr(nthelem(1 testingfind_getmax_min(andy_segments)))
	maxx=car(nthelem(2 testingfind_getmax_min(andy_segments)))
	maxy=cadr(nthelem(2 testingfind_getmax_min(andy_segments)))
	detx=nthelem(1 andyfind_justicebox(minx miny maxx maxy))
	dety=nthelem(2 andyfind_justicebox(minx miny maxx maxy))
	nx=nthelem(3 andyfind_justicebox(minx miny maxx maxy))
	ny=nthelem(4 andyfind_justicebox(minx miny maxx maxy))
andyfind_turn_on_layer( andyfind_layer)
axlSetFindFilter(?enabled '(noall components) ?onButtons '(noall components))
yn=1
yi=miny
xn=1
getbox=nil
xi=minx
andycomp_list=nil

while((yn<=ny)
	xn=1
	getbox=nil
	xi=minx
	while((xn<=nx)
		left=xi
		bottom=yi
		right=xi+detx
		top=yi+dety
		getbox=list(left:bottom right:top)
		;axlDBCreateRectangle(getbox  nil strcat("PACKAGE GEOMETRY/Display_" andyfind_layer))
		if(axlSingleSelectBox(getbox)!=nil then 
			Comp_List=reverse(axlGetSelSet()) 
			axlClearSelSet()
			;axlHighlightObject(Comp_List)
		)
		xi=xi+detx
		xn++
	andycomp_list=append(Comp_List andycomp_list)
	)
yi=yi+dety
yn++
)
)
andyluherocomlist=nil
	foreach(item andycomp_list
	if(item->name!=nil then
		andyluherocomlist=cons(item->name andyluherocomlist)
	))
;andyluherocomlist=remdq(nil andyluherocomlist)
luyihanlist=nil
luyihanlist=andy_justice_symbol(andyluherocomlist)
luyihanlist=remdq(nil luyihanlist)
axlUIWUpdate(nil)
axlUIWRedraw(nil)
;println(luyihanlist)
;return(t)	
return(luyihanlist)
))
(defun andy_justice_symbol (list)
  prog(()
subdist_i=1
midstrc=nil
midlist=nil
fulllist=nil
length_list=length(list)
while((subdist_i<=length_list)
midstrc=nthelem(subdist_i list)
midlist=remove(midstrc  list)
list=cons(midstrc midlist)
subdist_i++
	)
fulllist=reverse(remdq(nil list))
return(fulllist)
))
(defun testingfind_getmax_min (andy_segments)
(prog ()
segitem_xlist=nil
segitem_ylist=nil
foreach(segitem andy_segments
;if( segitem->xy!=nil then
segitem_startend=segitem ->startEnd
	startx=car(nthelem(1 segitem_startend))
    starty=cadr(nthelem(1 segitem_startend))
    endx=car(nthelem(2 segitem_startend))
    endy=cadr(nthelem(2 segitem_startend))
segitem_xlist=cons( startx  segitem_xlist)
segitem_xlist=cons( endx  segitem_xlist)
segitem_ylist=cons( starty  segitem_ylist)
segitem_ylist=cons( endy  segitem_ylist)
);)
segitem_xlist=remdq(nil segitem_xlist)
segitem_ylist=remdq(nil segitem_ylist)
segitem_xlist=sort(segitem_xlist  'lessp)
segitem_ylist=sort(segitem_ylist  'lessp)
min_x=car(segitem_xlist)
min_y=car(segitem_ylist)
segitem_xlist=sort(segitem_xlist  'greaterp)
segitem_ylist=sort(segitem_ylist  'greaterp)
max_x=car(segitem_xlist)
max_y=car(segitem_ylist)
    return(list(min_x:min_y max_x:max_y))   
))

(defun andyfind_justicebox (x1 y1 x2 y2)
(prog ()
dtx=0
dty=0
	dtx=abs(x1-x2)
	dty=abs(y1-y2)
nx=0
ny=0
detx=0
dety=0
	case(car(axlDBGetDesignUnits())
("millimeters" 
	if(dtx>600 then nx=15)
	if(dtx<=600 && dtx>400 then nx=10)
	if(dtx<=400 && dtx>200 then nx=8)
	if(dtx<=200 && dtx>100 then nx=5)
	if(dtx<=100  then nx=2)

	if(dty>600 then ny=15)
	if(dty<=600 && dty>400 then ny=10)
	if(dty<=400 && dty>200 then ny=8)
	if(dty<=200 && dty>100 then ny=5)
	if(dty<=100  then ny=2)
)
("mils"
	if(dtx>24000 then nx=15)
	if(dtx<=24000 && dtx>16000 then nx=10)
	if(dtx<=16000 && dtx>8000 then nx=8)
	if(dtx<=8000 && dtx>4000 then nx=5)
	if(dtx<=4000  then nx=2)

	if(dty>24000 then ny=15)
	if(dty<=24000 && dty>16000 then ny=10)
	if(dty<=16000 && dty>8000 then ny=8)
	if(dty<=8000 && dty>4000 then ny=5)
	if(dty<=4000  then ny=2)
))

detx=dtx/nx
dety=dty/ny
    return(list(detx dety nx ny))    
))
(defun andyfind_getbox (xi yi zx zy)
(prog ()
    left = xi
    bottom = yi
    top = xi+zx
    right = yi+zx
    return(list(left:bottom right:top ))   
))
(defun subandy_unselect_object ()
(let (allsel)
axlClearSelSet()
    axlSetFindFilter(?enabled '(noall lines pins vias text) ?onButtons '(noall lines pins vias text))
  ; axlSetFindFilter(?enabled '(all) ?onButtons '(all))
    allsel = axlGetSelSet(axlAddSelectAll())
	;axlDehighlightObject(allsel)
    axlClearSelSet()
    axlSetFindFilter(?enabled '(noall symbols) ?onButtons '(noall symbols))
    allsel = axlGetSelSet(axlAddSelectAll())
	;axlDehighlightObject(allsel)
    axlClearSelSet()
Design = axlDBGetDesign()
        symbolslist = Design->symbols
        netslist= Design ->nets
	functionlist=Design ->functions
	pinlist= Design ->pins
        foreach( Item  symbolslist axlDehighlightObject(Item t) )
      ;  foreach( Item  netslist 	axlDehighlightObject(Item t) )
        foreach( Item  functionlist axlDehighlightObject(Item t) )
        foreach( Item  pinlist	axlDehighlightObject(Item t) )
axlClearSelSet()
))
*/

;;;;;;;;;;;;;;;;;;;;;;;
;写入叠层信息子程序
; input :no  output : no
;;;;;;;;;;;;;;;;;;;;;;;


(defun select_layer_flag_fill_list ()
    prog( ()
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\265\376\262\343\320\305\317\242\275\370\320\320\326\320")
		axlUIWPrint(myform uidisplayer)
		axlClearSelSet()
		change_mil_mm_units=0
		case(car(axlDBGetDesignUnits())
		("millimeters"  change_mil_mm_units=0.0254)
		("mils"   change_mil_mm_units=0.9999))
		write_location_x=0
		write_location_y=0
		axlVisibleDesign(nil)
		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:BOARD GEOMETRY/paramLayer:DIMENSION" ))
		Going_On->visible=t
		axlSetParam(Going_On)
		text_list=nil
		axlSetFindFilter(?enabled '("noall"  "text" ) ?onButtons '("noall"  "text" ))
		text_list = axlGetSelSet(axlAddSelectAll())
		axlClearSelSet()
		ddetx=0
		ddety=0
		foreach(textitem text_list
			if(rexMatchp("STACK-UP LAYERS"  textitem->text) then
				textitemxy=textitem->xy
				textitem_left=car(nthelem(1 textitem->bBox))
				textitem_top=cadr(nthelem(1 textitem->bBox))
				;ddety=1778*change_mil_mm_units
				;ddetx=685.8*change_mil_mm_units
				textblock=textitem->textBlock
				write_location_x_ori=textitem_left
				write_location_y_ori=textitem_top
				write_sTxtBlock=textblock
			)
		)
		axlVisibleDesign(nil)
		testing_Etch_Layers=(axlGetParam("paramLayerGroup:ETCH")->groupMembers)
		layersum=length(testing_Etch_Layers)
		testing_Etch_Layers=remove("TOP" testing_Etch_Layers)
		testing_Etch_Layers=remove("BOTTOM" testing_Etch_Layers)
		cons_layeritem=nil
		cons_layeritem = strcat("01" "TOP")
		testing_Etch_Layers=cons(cons_layeritem testing_Etch_Layers)
		if(layersum>=10 then 
			cons_layeritem = sprintf(dummy , "%d%s" layersum "BOTTOM" )
		else
			cons_layeritem= sprintf(dummy , "%s%d%s" "0" layersum "BOTTOM" )
		)
		testing_Etch_Layers=cons(cons_layeritem testing_Etch_Layers)
		cline_segments=nil
		detx=1400*change_mil_mm_units
		dety=1000*change_mil_mm_units
		output_printf=nil
		output_printf=sprintf(dummy , "%d" layersum)
		write_layerTxtOri = make_axlTextOrientation(
								?textBlock write_sTxtBlock
								?rotation 0.
								?mirrored nil
								?justify "left"
							);end fill structure
		isCreation = axlDBCreateText(
				output_printf
				list(write_location_x_ori+detx  write_location_y_ori)
				write_layerTxtOri
				"board geometry/dimension"
				nil
				)

		write_location_y=write_location_y_ori-dety
		testing_Etch_Layers=remdq(nil testing_Etch_Layers)
		testing_Etch_Layers=sort(testing_Etch_Layers 'axlStrcmpAlpNum)
		foreach(layeritem testing_Etch_Layers
			detx=1400*change_mil_mm_units
			dety=200*change_mil_mm_units
			write_location_x=write_location_x_ori+detx
			write_location_y=write_location_y-dety
			write_layerTxtOri = make_axlTextOrientation(
									?textBlock write_sTxtBlock
									?rotation 0.
									?mirrored nil
									?justify "left"
								);end fill structure
			isCreation = axlDBCreateText(
					layeritem
					list(write_location_x  write_location_y)
					write_layerTxtOri
					"board geometry/dimension"
					nil
					)
		)
		axlClearSelSet()
		testing_turn_on_layer(select_layer_flag) 
		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:BOARD GEOMETRY/paramLayer:DIMENSION" ))
		Going_On->visible=t
		axlSetParam(Going_On)
		axlUIWRedraw(nil)
		axlUIWUpdate(nil)
		case(car(axlDBGetDesignUnits())	
			("millimeters" view = 37.5)
			("mils" view = 1500  )
		)
		axlWindowBoxSet(list(write_location_x-view:write_location_y-view write_location_x_ori+view:write_location_y_ori+view))
		axlClearSelSet()
		axlUIWRedraw(nil) 
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\265\376\262\343\320\305\317\242\322\321\315\352\263\311"  )
		axlUIWPrint(myform uidisplayer)
		axlClearSelSet()
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;
;写入单线阻抗信息子程序
; input :no  output : no
;;;;;;;;;;;;;;;;;;;;;;;

(defun testing_single_fill ()
    prog( ()
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\265\245\317\337\317\337\277\355\275\370\320\320\326\320")
		axlUIWPrint(myform uidisplayer)
		axlFormSetField( myform "Label_shuoming" "\307\353\321\241\324\361\312\312\265\261\265\304\316\273\326\303\267\305\326\303\301\320\261\355!"  )
		axlMsgPut("Please Select One Point Where The Silkscreen Located")
		main_check_show()
		snappedPoint = axlEnterPoint(?prompts list("Pick origin point") ?gridSnap t)
		move_textbox=snappedPoint
		move_left=nthelem(1 move_textbox)
		move_bottom=nthelem(2 move_textbox)
		axlClearSelSet()
		change_mil_mm_units=0
		case(car(axlDBGetDesignUnits())
		("millimeters"  change_mil_mm_units=0.0254 testing_line1width=0.15)
		("mils"   change_mil_mm_units=0.9999 testing_line1width=6))
		write_location_x=0
		write_location_y=0
		write_count_flag=0
		axlVisibleDesign(nil)
		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:BOARD GEOMETRY/paramLayer:DIMENSION" ))
		Going_On->visible=t
		axlSetParam(Going_On)
		text_list=nil
		axlSetFindFilter(?enabled '("noall"  "text" ) ?onButtons '("noall"  "text" ))
		text_list = axlGetSelSet(axlAddSelectAll())
		axlClearSelSet()
		ddetx=0
		foreach(textitem text_list
			if(rexMatchp("Other Notes For the PCB During Manufacture :"  textitem->text) then
				textitemxy=textitem->xy
				textitem_left=car(nthelem(1 textitem->bBox))
				textitem_top=cadr(nthelem(1 textitem->bBox))
				ddety=2000*change_mil_mm_units
				textblock=textitem->textBlock
				;write_location_x_ori=textitem_left
				;write_location_y_ori=textitem_top-ddety
				write_sTxtBlock=textblock
			)
		)
		write_layerTxtOri = make_axlTextOrientation(
								?textBlock write_sTxtBlock
								?rotation 0.
								?mirrored nil
								?justify "center"
							);end fill structure
		;output_printf=list("LAYER" "Trace Width" "REF-LAYER" "Impendance"   "Precision")
		axlVisibleDesign(nil)
		testing_Etch_Layers=(axlGetParam("paramLayerGroup:ETCH")->groupMembers)
		layersum=length(testing_Etch_Layers)
		cline_segments=nil
		dety=200*change_mil_mm_units
		detx=800*change_mil_mm_units
		write_location_x_ori=move_left
		write_location_y_ori=move_bottom
		output_printf=nil
		output_printf="SINGAL-TRACE INFORMATION"
		isCreation = axlDBCreateText(
						output_printf
						list(write_location_x_ori+2*detx  write_location_y_ori+dety)
						write_layerTxtOri
						"board geometry/dimension"
						nil
					)
		write_location_x_start=0
		write_location_y_start=0
		write_location_x_start=write_location_x_ori-400*change_mil_mm_units
		write_location_y_start=write_location_y_ori+100*change_mil_mm_units
		L0=list(write_location_x_start:write_location_y_start write_location_x_start+5*detx:write_location_y_start)
		axlDBCreateLine(L0 testing_line1width "board geometry/dimension")
		output_printf=nil
		output_printf=list("LAYER" "Trace Width" "REF-LAYER" "Impendance"   "Precision")
		write_location_x=write_location_x_ori
		foreach(output_item output_printf
			isCreation = axlDBCreateText(
							output_item
							list(write_location_x  write_location_y_ori)
							write_layerTxtOri
							"board geometry/dimension"
							nil
						)

			write_location_x=write_location_x+detx
		)
		write_location_x=write_location_x_ori
		write_location_y=write_location_y_ori
		foreach(layeritem testing_Etch_Layers
			axlVisibleDesign(nil)
			axlVisibleLayer( strcat("etch/"  layeritem) t )
			write_location_x_start=write_location_x_ori-400*change_mil_mm_units
			write_location_y_start=write_location_y+100*change_mil_mm_units
			L00=list(write_location_x_start:write_location_y write_location_x_start+4000*change_mil_mm_units:write_location_y)
			axlDBCreateLine(L00 testing_line1width "board geometry/dimension")
			dety=100*change_mil_mm_units
			write_location_x=write_location_x_ori
			write_location_y=write_location_y-dety
			isCreation = axlDBCreateText(
							layeritem 
							list(write_location_x  write_location_y)
							write_layerTxtOri
							"board geometry/dimension"
							nil
						)
			cline_Width_list=nil
			axlSetFindFilter( ?enabled '( "NOALL" "clinesegs" ) ?onButtons '( "NOALL" "clinesegs" ) )  
			cline_segments = axlGetSelSet(axlAddSelectAll())
			axlClearSelSet()
			foreach(clineitem cline_segments
				if(clineitem->net->diffpair==nil then
					if(clineitem->width<20*change_mil_mm_units then
						cline_Width_list=cons(clineitem->width cline_Width_list)
						)
					)
			)
			cline_Width_list=testing_justice_list(cline_Width_list)
			cline_Width_list=remdq(nil cline_Width_list)
			cline_Width_list=sort(cline_Width_list 'lessp)
			if(cline_Width_list!=nil then
				foreach(item cline_Width_list
					write_location_x=write_location_x_ori
					output_printf=nil
					output_printf=list(sprintf(dummy , "%0.1f" item) "L*//L*" "?" "+/-10%")
					foreach(output_item output_printf
						write_location_x=write_location_x+detx
						isCreation = axlDBCreateText(
										output_item
										list(write_location_x  write_location_y)
										write_layerTxtOri
										"board geometry/dimension"
										nil
									)
						)
					write_location_y=write_location_y-dety
				)
			else
				output_printf="NULL"
				write_location_x=write_location_x+detx
				write_location_y=write_location_y
				isCreation = axlDBCreateText(
								output_printf
								list(write_location_x  write_location_y)
								write_layerTxtOri
								"board geometry/dimension"
								nil
							)
			)
		)
		axlClearSelSet()
		testing_turn_on_layer(select_layer_flag) 
		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:BOARD GEOMETRY/paramLayer:DIMENSION" ))
		Going_On->visible=t
		axlSetParam(Going_On)
		case(car(axlDBGetDesignUnits())	
			("millimeters" view = 37.5)
			("mils" view = 1500  )
		)
		axlWindowBoxSet(list(write_location_x_ori-view:write_location_y_ori-view write_location_x+view:write_location_y+view)) 
		axlFormSetField( myform "Label_shuoming" "\321\241\324\361\313\265\303\367"  ) 
		axlClearSelSet()
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\265\245\317\337\317\337\277\355\322\321\315\352\263\311"  )
		axlUIWPrint(myform uidisplayer)
		all_counter=0
		all_counter=round(abs((write_location_y-write_location_y_ori)/dety))
		creat_line_dem(write_location_x_ori write_location_y_ori write_location_x write_location_y all_counter)
		axlUIWRedraw(nil)
		axlUIWUpdate(nil)
		axlClearSelSet()
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)
	)
)


;;;;;;;;;;;;;;;;;;;;;;;
;写入画线位置子程序
; input :write_location_x_ori write_location_y_ori write_location_x write_location_y all_counter  output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun creat_line_dem (write_location_x_ori write_location_y_ori write_location_x write_location_y all_counter)
    prog( ()
		counter_x_n=0
		counter_y_n=0
		L1=nil
		L2=nil
		L01=nil
		detx=800*change_mil_mm_units
		case(car(axlDBGetDesignUnits())
			("millimeters" testing_line1width=0.15)
			("mils" testing_line1width=6)
		)
		while((counter_x_n<6)
			write_location_x_counter=write_location_x_ori-400*change_mil_mm_units+counter_x_n*detx
			write_location_y_counter=write_location_y_ori+100*change_mil_mm_units
			L1=list(write_location_x_counter:write_location_y_counter write_location_x_counter:write_location_y-100*change_mil_mm_units )
			axlDBCreateLine(L1 testing_line1width "board geometry/dimension")
			++counter_x_n
		)
		dety=100*change_mil_mm_units
		while((counter_y_n<=all_counter+2)
			write_location_x_counter=write_location_x_ori+400*change_mil_mm_units
			write_location_y_counter=write_location_y_ori+100*change_mil_mm_units-counter_y_n*dety
			L2=list(write_location_x_counter:write_location_y_counter write_location_x_counter+4*detx:write_location_y_counter)
			axlDBCreateLine(L2 testing_line1width "board geometry/dimension")
			++counter_y_n
		)
		L01=list(write_location_x_counter-detx:write_location_y_counter write_location_x_counter+4*detx:write_location_y_counter)
		axlDBCreateLine(L01 testing_line1width "board geometry/dimension")
	)
)

;;;;;;;;;;;;;;;;;;;;;;;
;写入差分线阻抗信息子程序
; input :no  output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_diff_fill ()
       prog(()
		;testing_next_view_All=nil

		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\262\356\267\326\317\337\277\355\275\370\320\320\326\320"  )
		axlUIWPrint(myform uidisplayer)
		axlFormSetField( myform "Label_shuoming" "\307\353\321\241\324\361\312\312\265\261\265\304\316\273\326\303\267\305\326\303\301\320\261\355!"  )
		axlMsgPut("Please Select One Point Where The Silkscreen Located")
		main_check_show()
		snappedPoint = axlEnterPoint(?prompts list("Pick origin point") ?gridSnap t)
		move_textbox=snappedPoint
		move_left=nthelem(1 move_textbox)
		move_bottom=nthelem(2 move_textbox)
		axlClearSelSet()
		Design = axlDBGetDesign()
		testing_Etch_Layers=(axlGetParam("paramLayerGroup:ETCH")->groupMembers)
		layersum=length(testing_Etch_Layers)
		change_mil_mm_units=0
		case(car(axlDBGetDesignUnits())
		("millimeters"  change_mil_mm_units=0.0254 testing_line1width=0.15)
		("mils"   change_mil_mm_units=0.9999 testing_line1width=6))
		write_location_x=0
		write_location_y=0
		axlVisibleDesign(nil)
		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:BOARD GEOMETRY/paramLayer:DIMENSION" ))
		Going_On->visible=t
		axlSetParam(Going_On)
		text_list=nil
		axlSetFindFilter(?enabled '("noall"  "text" ) ?onButtons '("noall"  "text" ))
		text_list = axlGetSelSet(axlAddSelectAll())
		axlClearSelSet()
		ddetx=0
		foreach(textitem text_list
			if(rexMatchp("Other Notes For the PCB During Manufacture :"  textitem->text) then
				textitemxy=textitem->xy
				textitem_left=car(nthelem(1 textitem->bBox))
				textitem_top=cadr(nthelem(1 textitem->bBox))
				ddety=2000*change_mil_mm_units
				textblock=textitem->textBlock
				write_location_x_ori=textitem_left
				write_location_y_ori=textitem_top-ddety
				write_sTxtBlock=textblock
			)
		)
		write_layerTxtOri = make_axlTextOrientation(
								?textBlock write_sTxtBlock
								?rotation 0.
								?mirrored nil
								?justify "center"
							);end fill structure
		dety=200*change_mil_mm_units
		detx=800*change_mil_mm_units
		write_location_x_ori=move_left
		write_location_y_ori=move_bottom
		output_printf=nil
		output_printf="DiffPair-TRACE INFORMATION"
		isCreation = axlDBCreateText(
						output_printf
						list(write_location_x_ori+2*detx  write_location_y_ori+dety)
						write_layerTxtOri
						"board geometry/dimension"
						nil
					)

		write_location_x_start=0
		write_location_y_start=0
		write_location_x_start=write_location_x_ori-400*change_mil_mm_units
		write_location_y_start=write_location_y_ori+100*change_mil_mm_units
		L0=list(write_location_x_start:write_location_y_start write_location_x_start+5*detx:write_location_y_start)
		axlDBCreateLine(L0 testing_line1width "board geometry/dimension")
		output_printf=nil
		output_printf=list("LAYER" "Lw/Ls/Lw" "REF-LAYER" "Impendance"   "Precision")
		write_location_x=write_location_x_ori
		foreach(output_item output_printf
			isCreation = axlDBCreateText(
							output_item
							list(write_location_x  write_location_y_ori)
							write_layerTxtOri
							"board geometry/dimension"
							nil
						)
			write_location_x=write_location_x+detx
		)
		write_location_x=write_location_x_ori
		write_location_y=write_location_y_ori
		cline_list=nil
		foreach(layeritem testing_Etch_Layers
			axlVisibleDesign(nil)
			axlVisibleLayer( strcat("etch/"  layeritem) t )
			write_location_x_start=write_location_x_ori-400*change_mil_mm_units
			write_location_y_start=write_location_y+100*change_mil_mm_units
			L00=list(write_location_x_start:write_location_y write_location_x_start+4000*change_mil_mm_units:write_location_y)
			axlDBCreateLine(L00 testing_line1width "board geometry/dimension")
			dety=100*change_mil_mm_units
			write_location_x=write_location_x_ori
			write_location_y=write_location_y-dety
			isCreation = axlDBCreateText(
							layeritem 
							list(write_location_x  write_location_y)
							write_layerTxtOri
							"board geometry/dimension"
							nil
						)
			cline_Width_list=nil
			axlSetFindFilter( ?enabled '( "NOALL" "clines" ) ?onButtons '( "NOALL" "clines" ) )  
			cline_list = axlGetSelSet(axlAddSelectAll())
			axlClearSelSet()
			;println(layeritem)
			;testing_next_view_All=layeritem
			;axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
			diff_allboxes=nil
			cline_Width_list=nil
			foreach(clineitem cline_list
				if(clineitem->net->diffpair!=nil then
					diff_allboxes=cons(clineitem  diff_allboxes)
				)
			)
			diff_cline_gap_list=nil
			diff_allboxes=testing_justice_list(diff_allboxes)
			diff_allboxes=remdq(nil diff_allboxes)
			foreach(item diff_allboxes
				item_cline_Width_list=nil
				foreach(segitem item->segments
						segitem_width=segitem->width
						axlSetFindFilter( ?enabled '( "NOALL" "clinesegs" ) ?onButtons '( "NOALL" "clinesegs" ) )
						allboxes=nil  
						if(abs(car(nthelem(1 segitem->startEnd))-car(nthelem(2 segitem->startEnd)))>40*change_mil_mm_units||
						abs(cadr(nthelem(1 segitem->startEnd))-cadr(nthelem(2 segitem->startEnd)))>40*change_mil_mm_units then
							if(axlSingleSelectBox(testing_getbox_diff(segitem))!=nil then
								allboxes = axlGetSelSet()
								axlClearSelSet()
								allboxes=testing_justice_list(allboxes)
								allboxes=remdq(nil allboxes)
								foreach(itemline allboxes
									if(itemline->net!=segitem->net &&
										itemline->net->diffpair->groupMembers==segitem->net->diffpair->groupMembers then
										itemline_width=itemline->width
										itemline_name=itemline->net->name
										axlHighlightObject(itemline->net t)
										axlHighlightObject(segitem->net t)
										diff_gap=nthelem(3 axlAirGap(itemline segitem strcat( "ETCH/" layeritem)))
										if(itemline_width<=6.2*change_mil_mm_units then
											if(itemline_width==segitem_width && diff_gap<=15*change_mil_mm_units then
											diff_cline_Width_dist=list(itemline_width diff_gap segitem_width)
											item_cline_Width_list=cons(diff_cline_Width_dist item_cline_Width_list)
											)
										else
											if(itemline_width==segitem_width && diff_gap<=20*change_mil_mm_units then
											diff_cline_Width_dist=list(itemline_width diff_gap segitem_width)
											item_cline_Width_list=cons(diff_cline_Width_dist item_cline_Width_list)
											)

										)
									)
								)
							)
						)
					)
				item_cline_Width_list=testing_justice_list(item_cline_Width_list)
				item_cline_Width_list=remdq(nil item_cline_Width_list)
				foreach( gap_item item_cline_Width_list
					diff_width=nthelem(1 gap_item)
					diff_gap_min=nthelem(2 gap_item)
					foreach(item1 item_cline_Width_list
						if(nthelem(1 item1)==diff_width then 
							diff_gap_min=min(diff_gap_min nthelem(2 item1))
						)
					)
					diff_cline_Width_dist_string=sprintf(dummy , " %0.1f/%0.1f/%0.1f"  nthelem(1 gap_item) diff_gap_min nthelem(3 gap_item))
					diff_cline_gap_list=cons(diff_cline_Width_dist_string diff_cline_gap_list)
				)
			)
			diff_cline_gap_list=testing_justice_list(diff_cline_gap_list)
			diff_cline_gap_list=remdq(nil diff_cline_gap_list)
			if(diff_cline_gap_list==nil then 
				output_printf="NULL"
				write_location_x=write_location_x+detx
				write_location_y=write_location_y
				isCreation = axlDBCreateText(
								output_printf
								list(write_location_x  write_location_y)
								write_layerTxtOri
								"board geometry/dimension"
								nil
								)
						
			else 
				foreach(item diff_cline_gap_list
					write_location_x=write_location_x_ori
					;write_location_y=write_location_y-dety
					output_printf=nil
					output_printf=list(item "L*//L*" "?" "+/-10%")
					foreach(output_item output_printf
						write_location_x=write_location_x+detx
						isCreation = axlDBCreateText(
										output_item
										list(write_location_x  write_location_y)
										write_layerTxtOri
										"board geometry/dimension"
										nil
									)
					)
					write_location_y=write_location_y-dety
				)
			)
		)

		axlVisibleLayer("BOARD GEOMETRY/DIMENSION"  t)
		axlUIWRedraw(nil)
		axlUIWUpdate(nil)
		case(car(axlDBGetDesignUnits())	
			("millimeters" view = 37.5    )
			("mils" view = 1500  )
		)
		axlWindowBoxSet(list(write_location_x_ori-view:write_location_y_ori-view write_location_x+view:write_location_y+view))
		axlFormSetField( myform "Label_shuoming" "\321\241\324\361\313\265\303\367"  )
		axlClearSelSet()
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\262\356\267\326\317\337\277\355\322\321\315\352\263\311"  )
		axlUIWPrint(myform uidisplayer)
		all_counter=0
		all_counter=round(abs((write_location_y-write_location_y_ori)/dety))
		creat_line_dem(write_location_x_ori write_location_y_ori write_location_x write_location_y all_counter)
		axlClearSelSet()
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;
;写入差分线范围子程序
; input :andline  output : list(left:bottom right:top)
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_getbox_diff (andline)
  prog(()
		left =0 top = 0 right = 0 bottom = 0 diff_clearancesmall=0 diff_clearance=0
		case(car(axlDBGetDesignUnits())
			("millimeters"  diff_clearance=0.75 diff_clearancesmall=0.25 )
			("mils" diff_clearance=30 diff_clearancesmall=10)
		)
		andline_startend=andline->startEnd
		startx=car(nthelem(1 andline_startend))
		starty=cadr(nthelem(1 andline_startend))
		endx=car(nthelem(2 andline_startend))
		endy=cadr(nthelem(2 andline_startend))
		middle_x=(startx+endx)*0.5
		middle_y=(starty+endy)*0.5
		if(andline->lineType="horizontal" then
			left = middle_x-diff_clearancesmall
			top = middle_y+diff_clearance
			right = middle_x+diff_clearancesmall
			bottom = middle_y-diff_clearance
		else
			if(andline->lineType="vertical" then
				left = middle_x - diff_clearance
				top = middle_y- diff_clearancesmall
				right = middle_x+ diff_clearance
				bottom = middle_y+diff_clearancesmall
			)
			if(andline->lineType="odd" then
				left = middle_x - diff_clearancesmall
				top = middle_y- diff_clearancesmall
				right = middle_x+ diff_clearancesmall
				bottom = middle_y+diff_clearancesmall
			)
		)
		return(list(left:bottom right:top))  

	)
)
/*
(defun testing_getbox_diff_old (andline)
  prog(()
 left =0 top = 0 right = 0 bottom = 0 diff_clearancesmall=0
case(car(axlDBGetDesignUnits())
("millimeters"  diff_clearancesmall=0.5)
("mils" diff_clearancesmall=20))
if(andline->lineType="horizontal" then
    left = car(nth(0 andline->bBox)) 
    top = cadr(nth(1 andline->bBox)) + diff_clearancesmall
    right = car(nth(1 andline->bBox)) 
    bottom = cadr(nth(0 andline->bBox))- diff_clearancesmall
else
;if(andline->lineType="vertical" then
    left = car(nth(0 andline->bBox)) - diff_clearancesmall
    top = cadr(nth(1 andline->bBox)) 
    right = car(nth(1 andline->bBox)) + diff_clearancesmall
    bottom = cadr(nth(0 andline->bBox))
)

if(andline->lineType="odd" then
    startx = car(nth(0 andline->startEnd)) 
    starty = cadr(nth(0 andline->startEnd)) 
    endx = car(nth(1 andline->startEnd)) 
    endy = cadr(nth(1 andline->startEnd))
center_x=(startx+endx)*0.5
center_y=(starty+endy)*0.5
left=center_x
top=center_y
right=center_x-diff_clearancesmall
bottom=center_y-diff_clearancesmall
)

    return(list(left:bottom right:top))    
))
*/

;;;;;;;;;;;;;;;;;;;;;;;
;写入塞孔信息子程序
; input :no  output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_oil_fill ()
    prog( ()
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\310\373\277\327\320\305\317\242\314\355\274\323\275\370\320\320\326\320"  )
		axlUIWPrint(myform uidisplayer)
		axlClearSelSet()
		change_mil_mm_units=0
		case(car(axlDBGetDesignUnits())
		("millimeters"  change_mil_mm_units=0.0254 )
		("mils"   change_mil_mm_units=0.9999))
		axlVisibleDesign(nil)
		main_check_show()
		/*
		testing_turn_on_layer(select_layer_flag) 
		Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:VIA CLASS/paramLayer:%s" select_layer_flag))
		Going_On->visible=t
		axlSetParam(Going_On)
		*/
		vias_list=nil
		axlSetFindFilter(?enabled '("noall"  "vias" ) ?onButtons '("noall"  "vias" ))
		vias_list = axlGetSelSet(axlAddSelectAll())
		via_string_list=nil
		stard_via_dia=15.5*change_mil_mm_units
		foreach(viaitem vias_list
			via_dia=viaitem->definition->drillDiameter
			if(via_dia<= stard_via_dia && viaitem->testPoint== nil then
				via_string=sprintf(dummy "%.2f" via_dia) 
				via_string_list=cons(via_string via_string_list)
			)
		)
		via_string_list=remdq(nil via_string_list)
		via_string_list=testing_justice_list(via_string_list)
		println(via_string_list)
		write_location_x=0
		write_location_y=0
		write_location_x_ori=0
		write_location_y_ori=0
		axlSetFindFilter(?enabled '("noall"  "text" ) ?onButtons '("noall"  "text" ))
		text_list = axlGetSelSet(axlAddSelectAll())
		axlClearSelSet()
		foreach(textitem text_list
			if(textitem->text=="FILL-OIL" then
				textblock=textitem->textBlock
				write_location_x_ori=car(textitem->xy)
				write_sTxtBlock=textblock
				write_layerTxtOri = make_axlTextOrientation(
										?textBlock write_sTxtBlock
										?rotation 0.
										?mirrored nil
										?justify "center"
									);end fill structure
			)
		)
		write_location_x=write_location_x_ori
		foreach(string_item via_string_list
			foreach(fill_item text_list
				if(fill_item->text==string_item then
				write_location_y_ori=cadr(fill_item->xy)
				isCreation = axlDBCreateText(
								"FILL"
								list(write_location_x  write_location_y_ori)
								write_layerTxtOri
								"board geometry/dimension"
								nil
							)
				)
			)
		)

		case(car(axlDBGetDesignUnits())	
			("millimeters" view = 37.5    )
			("mils" view = 1500  )
		)
		axlWindowBoxSet(list(write_location_x-view:write_location_y_ori-view write_location_x+view:write_location_y_ori+view))
		axlClearSelSet()
		testing_turn_on_layer(select_layer_flag) 
		main_check_show()
		axlUIWRedraw(nil)  
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\310\373\277\327\320\305\317\242\314\355\274\323\322\321\315\352\263\311"  )
		axlUIWPrint(myform uidisplayer)
		axlClearSelSet()
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;输出dxf信息子程序
; input :no  output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_output_DXF_layer ()
	prog(()
		Design_name=axlCurrentDesign()
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\312\344\263\366\275\370\320\320\326\320\243\254\307\353\311\324\265\310"  )
		axlUIWPrint(myform uidisplayer)
		Script_File = outfile("./andy.scr")
		fprintf(Script_File "version 14.0\n\nsetwindow pcb\ncolor\n")
		fprintf(Script_File "setwindow form.cvf_main\n")
		fprintf(Script_File "FORM cvf_main class_list Stack-Up\n")
		fprintf(Script_File "FORM cvf_main global_vis All Invisible\n") 
		fprintf(Script_File "fillin yes \n")
		fprintf(Script_File "FORM cvf_main class_list Stack-Up\n")
		fprintf(Script_File "FORM cvf_main pin/top/visible YES \n")
		fprintf(Script_File "FORM cvf_main pin/bottom/visible YES \n")
		fprintf(Script_File "FORM cvf_main class_list Geometry \n")
		fprintf(Script_File "FORM cvf_main board_geometry/outline/visible YES \n")
		fprintf(Script_File "FORM cvf_main package_geometry/silkscreen_top/visible YES \n")
		fprintf(Script_File "FORM cvf_main package_geometry/silkscreen_bottom/visible YES \n")
		fprintf(Script_File "FORM cvf_main class_list Areas \n")
		fprintf(Script_File "FORM cvf_main all_visible5 YES \n")
		fprintf(Script_File "FORM cvf_main route_keepout/top/visible YES \n")
		fprintf(Script_File "FORM cvf_main route_keepout/all/visible YES \n")
		fprintf(Script_File "FORM cvf_main route_keepout/all/visible NO \n")
		fprintf(Script_File "FORM cvf_main route_keepout/bottom/visible YES\n") 
		fprintf(Script_File "FORM cvf_main package_keepout/top/visible NO \n")
		fprintf(Script_File "FORM cvf_main package_keepout/bottom/visible NO \n")
		fprintf(Script_File "FORM cvf_main apply  \n")
		fprintf(Script_File "FORM cvf_main ok  \n")
		fprintf(Script_File "setwindow pcb\n")
		fprintf(Script_File "dxf out \n")
		fprintf(Script_File "setwindow form.dxf_out\n")
		;fprintf(Script_File "FORM dxf_out dxffile %s\n" "output") 
		fprintf(Script_File "FORM dxf_out dxffile %s\n" Design_name) 
		fprintf(Script_File "FORM dxf_out units MM \n")
		fprintf(Script_File "FORM dxf_out accuracy 4 \n")
		fprintf(Script_File "FORM dxf_out edit  \n")
		fprintf(Script_File "setwindow form.dxfOutMapping\n")
		fprintf(Script_File "FORM dxfOutMapping selectall YES \n")
		fprintf(Script_File "FORM dxfOutMapping usedefaultlayernames YES \n")
		fprintf(Script_File "FORM dxfOutMapping map  \n")
		fprintf(Script_File "FORM dxfOutMapping done \n") 
		;fprintf(Script_File "fillin yes \n")
		fprintf(Script_File "setwindow form.dxf_out\n")
		fprintf(Script_File "FORM dxf_out execute \n") 
		fprintf(Script_File "FORM dxf_out close \n") 
		fprintf(Script_File "setwindow pcb\n")
		/*
		fprintf(Script_File "color\n") 
		fprintf(Script_File "setwindow form.cvf_main\n")
		fprintf(Script_File "FORM cvf_main class_list Stack-Up\n")
		fprintf(Script_File "FORM cvf_main class_list Geometry \n")
		fprintf(Script_File "FORM cvf_main package_geometry/silkscreen_bottom/visible NO \n")
		fprintf(Script_File "FORM cvf_main board_geometry/silkscreen_top/visible YES \n")
		fprintf(Script_File "FORM cvf_main class_list Components \n")
		fprintf(Script_File "FORM cvf_main ref_des/silkscreen_top/visible YES \n")
		fprintf(Script_File "FORM cvf_main class_list Stack-Up \n")
		fprintf(Script_File "FORM cvf_main pin/soldermask_top/visible YES \n")
		fprintf(Script_File "FORM cvf_main via_class/soldermask_top/visible YES \n")
		fprintf(Script_File "FORM cvf_main pin/top/visible YES \n")
		fprintf(Script_File "FORM cvf_main via_class/top/visible YES \n")
		fprintf(Script_File "FORM cvf_main apply  \n")
		fprintf(Script_File "FORM cvf_main ok \n") 
		fprintf(Script_File "setwindow pcb\n")
		*/
		close(Script_File)
		axlShell("replay ./andy.scr")
		;shell("rm ./andy.scr") 
		deleteFile("./andy.scr")
		testing_turn_on_layer(select_layer_flag) 
		uidisplayer=nil
		;uidisplayer=sprintf(dummy , "\312\344\263\366\263\311\271\246,\316\304\274\376\303\373\316\252\241\261%s\241\260,\307\353\262\351\277\264" "output")
		uidisplayer=sprintf(dummy , "\312\344\263\366\263\311\271\246,\316\304\274\376\303\373\316\252\241\261%s\241\260,\307\353\262\351\277\264" Design_name)
		axlUIWPrint(myform uidisplayer)
		axlClearSelSet()
	)
)
/*
;search via functiong by andyluhero 2010.07.15 one by one times
(defun testing_search_vias_hilight ()
    prog( ()
axlClearSelSet()
main_check_show()
axlSetFindFilter(?enabled '("noall"  "figures" "vias" "pins" ) ?onButtons '("noall"  "figures" "vias" "pins"))
figure_name=car(axlGetSelSet(axlSingleSelectBox()))
if(figure_name->objType=="figure" then
figure_drillFigureName=figure_name->figureName
figure_drillChar=figure_name->drillChar
else
figure_drillFigureName=figure_name->definition->drillFigureName
figure_drillChar=figure_name->definition->drillChar
)
axlClearSelSet()
axlSetFindFilter(?enabled '("noall"  "vias" "pins") ?onButtons '("noall"  "vias" "pins"))
vias_list = axlGetSelSet(axlAddSelectAll())
axlClearSelSet()
vias_figure_list=nil
foreach(via_item vias_list
	via_drillFigureName=via_item->definition->drillFigureName
	via_drillChar=via_item->definition->drillChar
	if(via_drillFigureName==figure_drillFigureName && via_drillChar==figure_drillChar then
		vias_figure_list=cons(via_item vias_figure_list)
 		axlHighlightObject(via_item)
	)
)
vias_figure_list=remdq(nil vias_figure_list)
;println(vias_figure_list)
;axlHighlightObject(vias_figure_list)
;andy=axlDBGetDesign()
	case(car(axlDBGetDesignUnits())	
		("millimeters" view = 5    )
		("mils" view = 200 ))
first_via=car(vias_figure_list)
axlWindowBoxSet(list(car(first_via->xy)-view:cadr(first_via->xy)-view  car(first_via->xy)+view:cadr(first_via->xy)+view))
main_check_show()
axlClearSelSet()
;axlWindowBoxSet(axlExtentDB('obstacle))
println("OK")
axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
axlUIWUpdate(nil)
axlUIWRedraw(nil)
))

*/
;search via functiong by andyluhero 2010.07.15 more times
;;;;;;;;;;;;;;;;;;;;;;;
;寻找孔并将孔高亮主程序
; input :no  output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_search_vias_hilight ()
	prog( () 
		let((mypopup) 
			axlClearSelSet()
			main_check_show()
			;axlFormSetField( myform "Label_shuoming" "\307\353\321\241\324\361\312\312\265\261\265\304\316\273\326\303\267\305\326\303\301\320\261\355!"  )
			mypopup = axlUIPopupDefine(nil 
					'(
						("Done" axlFinishEnterFun) 
						("Cancel" axlCancelEnterFun)
					)
				) 
			axlUIPopupSet(mypopup) 
			axlSetFindFilter(?enabled '("noall"  "figures" "vias" "pins" ) ?onButtons '("noall"  "figures" "vias" "pins"))
			while( axlSingleSelectBox() 	testing_search_vias_list() )
			axlUIPopupSet( axlUIPopupDefine(nil nil))
			;axlWindowBoxSet(axlExtentDB('obstacle))
			vias_figure_list=nil
			println("END of function")
			main_check_show()
			axlClearSelSet()
			axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
			axlUIWUpdate(nil)
			axlUIWRedraw(nil)
		)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;
;寻找孔并将孔高亮子程序
; input :no  output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_search_vias_list ()
    prog( ()
		figure_name=car(axlGetSelSet())
		if(figure_name->objType=="figure" then
			figure_drillFigureName=figure_name->figureName
			figure_drillChar=figure_name->drillChar
		else
			figure_drillFigureName=figure_name->definition->drillFigureName
			figure_drillChar=figure_name->definition->drillChar
		)
		axlClearSelSet()
		axlSetFindFilter(?enabled '("noall"  "vias" "pins") ?onButtons '("noall"  "vias" "pins"))
		vias_list = axlGetSelSet(axlAddSelectAll())
		axlClearSelSet()
		vias_figure_list=nil
		foreach(via_item vias_list
			via_drillFigureName=via_item->definition->drillFigureName
			via_drillChar=via_item->definition->drillChar
			if(via_drillFigureName==figure_drillFigureName && via_drillChar==figure_drillChar then
				vias_figure_list=cons(via_item vias_figure_list)
				axlHighlightObject(via_item)
			)
		)
		vias_figure_list=remdq(nil vias_figure_list)
		;println(vias_figure_list)
		;axlHighlightObject(vias_figure_list)
		;andy=axlDBGetDesign()
		case(car(axlDBGetDesignUnits())	
			("millimeters" view = 5    )
			("mils" view = 200 )
			)
		first_via=car(vias_figure_list)
		axlWindowBoxSet(list(car(first_via->xy)-view:cadr(first_via->xy)-view  car(first_via->xy)+view:cadr(first_via->xy)+view))
		println("OK")
		axlSetFindFilter(?enabled '("noall"  "figures" "vias" "pins" ) ?onButtons '("noall"  "figures" "vias" "pins"))
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;移动字符主程序
; input :no  output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_move_function ()
	prog( () 
		let((mypopup) 
			(mypopup = axlUIPopupDefine(nil 
							list(list("Move" 'subrot_AlignText_move) 
								list("Done" 'subrot_AlignText_done) 
								list("Cancel" 'subrot_AlignText_cancel)
							)
						) 
			)
			axlUIPopupSet(mypopup) 
			axlSetFindFilter(?enabled '("noall" "components") ?onButtons '("noall" "components")) 
			axlOpenFindFilter()
			while(axlSingleSelectBox() subrot_move_center())
			axlUIPopupSet( axlUIPopupDefine(nil nil)) 
			axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
			axlUIWUpdate(nil)
			axlUIWRedraw(nil)
		)
	)
) 
;;;;;;;;;;;;;;;;;;;;;;;
;移动字符中心指引子程序
; input :no  output : no
;;;;;;;;;;;;;;;;;;;;;;;
procedure(subrot_move_center()
	prog( ()
		componentslist=axlGetSelSet()
		axlClearSelSet()
		axlUIWUpdate(nil)
		sub_rotateref(componentslist)
		axlClearSelSet()
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;移动字符结束子程序
; input :no  output : no
;;;;;;;;;;;;;;;;;;;;;;;
procedure(subrot_AlignText_cancel() 
    axlFinishEnterFun() 
    axlClearSelSet() 
    axlFlushDisplay() 
)
;;;;;;;;;;;;;;;;;;;;;;;
;移动字符完成子程序
; input :no  output : no
;;;;;;;;;;;;;;;;;;;;;;;
procedure(subrot_AlignText_done() 
    axlFinishEnterFun() 
    axlClearSelSet() 
    axlFlushDisplay() 
)
;;;;;;;;;;;;;;;;;;;;;;;
;移动字符中心子程序
; input :no  output : no
;;;;;;;;;;;;;;;;;;;;;;;
procedure(subrot_AlignText_move()
	prog( ()
		axlClearSelSet() 
		axlCancelEnterFun()
		subrot_box=nil
		alltextsbox=remdq(nil alltextsbox)
		subrot_box=alltextsbox
		axlCloseFindFilter()
		;println(subrot_box)
		axlMsgPut("Please Select One Point Where The Silkscreen Located")
		snappedPoint = axlEnterPoint(?prompts list("Pick origin point") ?gridSnap t)
		move_textbox=snappedPoint
		move_left=nthelem(1 move_textbox)
		move_bottom=nthelem(2 move_textbox)
		;println(move_textbox)
		move_detroi=car(nthelem(1 subrot_box))->xy
		move_detx=move_left-car(move_detroi)
		move_dety=move_bottom-cadr(move_detroi)
		foreach(textitem subrot_box
			;text_orix=car(car(textitem)->xy)
			;text_oriy=cadr(car(textitem)->xy)
			;println(car(textitem)->xy)
			;move_detx=move_left-text_orix
			;move_dety=move_bottom-text_oriy
			;println(move_detx)
			;println(move_dety)
			axlTransformObject(car(textitem)  ?move  list(move_detx move_dety))
		)
		axlClearSelSet()
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;旋转所有字符子程序
; input :componentslist  output : no
;;;;;;;;;;;;;;;;;;;;;;;
;---command for rotate all refdes---
procedure( sub_rotateref(componentslist)

	l_nTopCompDir = nil
	l_nBtmCompDir = nil
	l_dbTopRefDbid = nil
	l_dbBtmRefDbid = nil
	alltextsbox=nil
	if(axlOKToProceed() != t   then
		axlMsgPut("Finish current command first")
		;return(nil)
	else
		sub_GetRefIDComDir(componentslist)
		if(select_layer_flag="TOP" then
			sub_RotateTopRef(l_dbTopRefDbid l_nTopCompDir)
		)
		if(select_layer_flag="Bottom" then
			sub_RotateBtmRef(l_dbBtmRefDbid l_nBtmCompDir)
		)
	
	)

)
;;;;;;;;;;;;;;;;;;;;;;;
;获得所有字符子程序
; input :componentslist  output : no
;;;;;;;;;;;;;;;;;;;;;;;
procedure( sub_GetRefIDComDir(componentslist)
	;axlSetFindFilter(?enabled '("noall" "components") ?onButtons '("noall" "components")) 
    ;complist = axlGetSelSet(axlAddSelectAll())
	;axlClearSelSet()
	foreach(compitem componentslist
		sym=compitem->symbol
		   if(sym->isMirrored != t ;on top side 	
		   then
				l_nTopCompDir = cons(round(sym->rotation) l_nTopCompDir)
				l_dbAttachedTxt = axlDBGetAttachedText(sym)
				foreach(txt l_dbAttachedTxt
					if(txt->layer == "REF DES/SILKSCREEN_TOP"  then
					   l_dbTopRefDbid = cons(txt l_dbTopRefDbid)
					);end of if 
				);end of foreach
		   else
				l_nBtmCompDir = cons(round(sym->rotation) l_nBtmCompDir)
				l_dbAttachedTxt = axlDBGetAttachedText(sym)
				foreach(txt l_dbAttachedTxt
					if(txt->layer == "REF DES/SILKSCREEN_BOTTOM"  then
						l_dbBtmRefDbid = cons(txt l_dbBtmRefDbid)
					);end of iftxt->layer == "REF DES/SILKSCREEN_BOTTOM"
				);end of foreach txt l_dbAttachedTxt
		   );end of if sym->isMirrored != t ;on top side
	);end of foreach

);end of procedure


;;;;;;;;;;;;;;;;;;;;;;;
;获得所有top面字符子程序
; input :componentslist  output : no
;;;;;;;;;;;;;;;;;;;;;;;
;------------------------------------------------------
;----------Rotate Refdes on Top side----------------------
;------------------------------------------------------

procedure( sub_RotateTopRef(ll_dbTopRef ll_nTopComDir)
		
          foreach((dbTopRef nTopComDir) ll_dbTopRef ll_nTopComDir
                 sRefContent = dbTopRef->text
                 dbParent = dbTopRef->parent
		    dbParentxy=dbParent ->xy
                 ptRefxy = dbTopRef->xy
                 sRefLayer = dbTopRef->layer
                 bMirror = dbTopRef->isMirrored
                 sJustify = dbTopRef->justify
                 sTxtBlock = dbTopRef->textBlock
                     if(abs(nTopComDir-90.0)<=5 || abs(nTopComDir-270.0)<=5  then
                        nRefDir = 90
                     else
                        nRefDir = 0
                     );end of if
                 stTxtOri = make_axlTextOrientation(
                                 ?textBlock sTxtBlock
                                 ?rotation nRefDir
                                 ?mirrored bMirror
                                 ?justify sJustify
                            );end fill structure

                 isCreation = axlDBCreateText(
                            sRefContent
                            dbParentxy
                            stTxtOri
                            sRefLayer
                            dbParent
                            )

               ;  if( isCreation != nil axlDeleteObject( dbTopRef))
		           if( isCreation != nil  then
		axlDeleteObject( dbTopRef)
		axlDBRefreshId(dbTopRef->parent)
		)  
			alltextsbox=append(isCreation alltextsbox)
          );end of foreach

);end of procedure

;;;;;;;;;;;;;;;;;;;;;;;
;获得所有bottom面字符子程序
; input :componentslist  output : no
;;;;;;;;;;;;;;;;;;;;;;;
;---------------------------------------------------------------------------
;----------Rotate Refdes on Btm side----------------------
;---------------------------------------------------------------------------


procedure( sub_RotateBtmRef(ll_dbBtmRef ll_nBtmComDir)
	foreach((dbBtmRef nBtmComDir) ll_dbBtmRef ll_nBtmComDir
		sRefContent = dbBtmRef->text
		dbParent = dbBtmRef->parent
		dbParentxy=dbParent ->xy
		ptRefxy = dbBtmRef->xy
		sRefLayer = dbBtmRef->layer
		bMirror = dbBtmRef->isMirrored
		sJustify = dbBtmRef->justify
		sTxtBlock = dbBtmRef->textBlock
		if(abs(nBtmComDir-90.0)<5 || abs(nBtmComDir-270.0)<5  then
			nRefDir = 270
		else
			nRefDir = 0
		);end of if
		stTxtOri = make_axlTextOrientation(
						?textBlock sTxtBlock
						?rotation nRefDir
						?mirrored bMirror
						?justify sJustify
					);end fill structure

		isCreation = axlDBCreateText(
						sRefContent
						dbParentxy
						stTxtOri
						sRefLayer
						dbParent
					)
	  ;   if( isCreation != nil axlDeleteObject( dbBtmRef))
		if( isCreation != nil  then
			axlDeleteObject( dbBtmRef)
			axlDBRefreshId(dbBtmRef->parent)
		)  
		alltextsbox=append(isCreation alltextsbox)
    );end of foreach
);end of procedure
;;;;;;;;;;;;;;;;;;;;;;;
;获得techfile文件子程序，暂时不用，可考虑调用差分线时使用
; input :componentslist  output : no
;;;;;;;;;;;;;;;;;;;;;;;

  /* generate the techfile,not use */
(defun generate_techfile ()
	axlClearSelSet()
	brd_name = axlCurrentDesign()
	sprintf(techout "tech_%s.out" brd_name)
	axlMsgPut("extracting technology file")
	(command = sprintf(nil "techfile -$ -w %%s %s" techout))
	axlRunBatchDBProgram("techfile" command)
	println("ok")
)
;outlines-offset by andyluhero 2010.07.16,
;;;;;;;;;;;;;;;;;;;;;;;
;内宿shape5mm子程序，
; input :componentslist  output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun shape_offset_drawing ()
    prog( ()
		axlClearSelSet()
		subdist_Delete_object()
		testing_unselect_object()
		subdist_cnt = 0 
		SBlist=nil
		axlClearSelSet()
		change_mil_mm_units=0
		case(car(axlDBGetDesignUnits())
		("millimeters"  change_mil_mm_units=0.0254 )
		("mils"   change_mil_mm_units=0.9999))
		axlVisibleDesign(nil)
		axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t)
		axlUIWRedraw(nil)
		axlUIWUpdate(nil)
		axlSetFindFilter(?enabled '("noall" "lines" "shapes") ?onButtons '("noall" "lines" "shapes" ))
		shapeline_segments =car(axlGetSelSet(axlSingleSelectBox()))
		axlClearSelSet()
		class_data="PACKAGE GEOMETRY"
		subclass_data=strcat("Display_" select_layer_flag)
		shape_offset=196.86*change_mil_mm_units
		shape_path = andylu_BuildShapePath( shapeline_segments->segments )
		andylu_AddShape( shape_path class_data subclass_data shape_offset)
		viewlist=nil
		viewlist=subdist_justice_cap()
		itemx=0
		itemy=0
		viewlist=testing_justice_list(viewlist)
		viewlist=remdq(nil viewlist)
		testing_next_view_num=nil
		if(viewlist==nil then
			testing_next_view_num=cons("OK" testing_next_view_num)
		else
			foreach(symitem viewlist
				if(rexMatchp("^MARK" upperCase(symitem->name)) then
					itemx=car(symitem->xy)
					itemy=cadr(symitem->xy)
					testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->name itemx itemy) testing_next_view_num)
				else
					
					itemx=car(symitem->xy)
					itemy=cadr(symitem->xy)
					testing_next_view_num =cons(sprintf(dummy "%s;  %0.2f;  %0.2f" symitem->refdes itemx itemy) testing_next_view_num)
				)
				++subdist_cnt
			)
		)
		testing_next_view_All=sprintf(dummy, "\274\354\262\351\265\332 2 \317\356: \306\367\274\376\265\275\260\345\261\337\276\340\300\353:\271\262  %d  \317\356" subdist_cnt)
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		testing_next_view_num=remdq(nil testing_next_view_num)
		testing_next_view_All=testing_next_view_num
		axlFormSetField(myform "testing_next_view_All" testing_next_view_All)
		;if(subdist_cnt==0 then axlFormSetField(myform "testing_next_view_All" "OK"))
		uidisplayer=nil
		uidisplayer=sprintf(dummy , "\327\334\271\262  %d  \317\356\306\367\274\376\265\275\260\345\261\337\276\340\300\353"  subdist_cnt)
		axlUIWPrint(myform uidisplayer)
		axlFormDisplay(myform)
		testing_turn_on_layer(select_layer_flag)  
		axlVisibleLayer(strcat("PACKAGE GEOMETRY/Display_" select_layer_flag)  t)
		axlVisibleUpdate(t)
		axlUIWRedraw(nil)
		axlSetFindFilter(?enabled '("noall" ) ?onButtons '("noall" ))
		axlUIWUpdate(nil)
		axlUIWRedraw(nil)
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;获得线的起始属性子程序，
; input :segment_list  output : return_path
;;;;;;;;;;;;;;;;;;;;;;;
defun( andylu_BuildShapePath ( segment_list)
	prog( ()
		let( ( return_path coord_number)
			coordinate_number = nil
			if(coordinate_number == nil then
				foreach(seg segment_list
					when(seg->objType == "line"
						if(coordinate_number == nil then
							coord = car(seg->startEnd)
							return_path = axlPathStart( list(coord)  seg->width)
							return_path = axlPathLine( return_path seg->width car( cdr(seg->startEnd)) )
							coordinate_number = t
						else
							return_path = axlPathLine(return_path seg->width car( cdr(seg->startEnd)) )
						);endif
					);endwhen
					when(seg->objType == "arc"
						if(coordinate_number == nil then
							 coord = car(seg->startEnd)
							 return_path = axlPathStart( list(coord)  seg->width)
							 return_path = axlPathArcCenter( return_path  seg->width car( cdr(seg->startEnd))
											seg->isClockwise seg->xy)
							 coordinate_number = t
						else
							 return_path = axlPathArcCenter( return_path seg->width car( cdr(seg->startEnd))
															seg->isClockwise seg->xy )
						);endif
					);endwhen
				);endforeach
			)
			return( return_path )
		)
	)
);end-defun andylu_BuildShapePath

;;;;;;;;;;;;;;;;;;;;;;;
;添加内缩5mmshape子程序，
; input :shape_path class_data subclass_data shape_offset  output : no
;;;;;;;;;;;;;;;;;;;;;;;
defun( andylu_AddShape (shape_path class_data subclass_data shape_offset)
	let((fill_type net_name clss_sbclss)
		sprintf( clss_sbclss "%s/%s" class_data subclass_data)
		/*
		if( car(shape_dbid)->layer == "ROUTE KEEPIN/ALL" && class_data == "ETCH" then
			fill_type = t
			net_name = axlUIPrompt(" Enter New Net Name" "")
		else
			fill_type = car(shape_dbid)->fill
			net_name = car(shape_dbid)->net->name
		)
		*/
		fill_type=t
		nte_name=nil
		fill_shape=axlDBCreateCloseShape(
			axlDBCreateOpenShape( shape_path
									fill_type
									clss_sbclss
									net_name
									nil
								)
					)
		;aaa= axlPolyExpand(axlPolyFromDB(car(fill_shape)) -shape_offset 'ALL_ARC)
		aaa= axlPolyExpand(axlPolyFromDB(car(fill_shape)) -shape_offset 'ACU_ARC)
		axlDBCreateOpenShape(nthelem(1 aaa),t, strcat("PACKAGE GEOMETRY/Display_" select_layer_flag), nil)
		axlDeleteObject(car(fill_shape))
	)
);end-defun

;;;;;;;;;;;;;;;;;;;;;;;
;检查PCB设计测试点规则子程序
; input :no  output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_check_testpoints_ruler ()
	prog(()
		Script_File = outfile("./andy.scr")
		fprintf(Script_File "version 14.0\n\nsetwindow pcb\ncns space values \n")
		fprintf(Script_File "setwindow form.cns_space_values\n")
		fprintf(Script_File "FORM cns_space_values elements_list Test Via\n")
		fprintf(Script_File "setwindow pcb\n")
		close(Script_File)
		axlShell("replay ./andy.scr")
		deleteFile("./andy.scr")
		axlClearSelSet()
	)
)
;;;;;;;;;;;;;;;;;;;;;;;
;检查PCB设计状态子程序
; input :no  output : no
;;;;;;;;;;;;;;;;;;;;;;;
(defun testing_check_status_ruler ()
	prog(()
		Script_File = outfile("./andy.scr")
		fprintf(Script_File "version 14.0\n\nsetwindow pcb\nstatus \n")
		fprintf(Script_File "setwindow form.status\n")
		fprintf(Script_File "setwindow pcb\n")
		close(Script_File)
		axlShell("replay ./andy.scr")
		deleteFile("./andy.scr")
		axlClearSelSet()
	)
)
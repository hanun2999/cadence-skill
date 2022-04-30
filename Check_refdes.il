; name: check_refdes.il
; author:  Sean	seanhung99@hotmail.com
; version: 1.0
; date: 2009/01/08
;以下為檢查文字的方向
axlCmdRegister( "ch_refrota" '_Check_Refdes_main)

(defun _Check_Refdes_main ()
	prog( ()
		
		units=car(axlDBGetDesignUnits())
	cond(
		(equal(units "mils") 		  (factor=4))
		(equal(units "millimeters") (factor=0.1))
	)
		;factor = 4
		lgs_temp_xy =nil
		silk_zoom = 0
		lgs_errlist =nil
		lgs_errlistxy = nil
		logWindow = nil
		Net_List = nil
	Displayed_RefDes_List = nil
	lRefDes_err = nil
	; lLayer_name = list( "Assembly TOP" "SilkScreen TOP" "Assembly BOTTOM" "SilkScreen BOTTOM" )
	lLayer_name = list("SilkScreen TOP" "SilkScreen BOTTOM" )
	sLayer_active_ref = nil
	setq(allsym axlDBGetDesign()->symbols)
	axlDehighlightObject(allsym)
	; open the form
  	(setq _SilkDir "./")
  	axlShell("zoom fit")
	(_SilkFormBuild)
	;_SilkForm = axlFormCreate( (gensym) _SilkFormFile nil '_SilkCallBack t)
	(axlFormCreate '_SilkForm _SilkFormFile '("east" "outer") '_SilkCallBack t)
	;convform=axlFormCreate( (gensym) convform_file nil 'Conv_Action t)	
	; set the default layer name into the form
	(setq _SilkDegree0 t)
	(setq _SilkDegree45 nil)
	(setq _SilkDegree90 t)
	(setq _SilkDegree135 nil)
	(setq _SilkDegree225 nil)
	(setq _SilkDegree270 t)
	(setq _SilkDegree315 nil)
	(setq _SilkTop nil)
	(setq _SilkBottom nil)
	(setq _SilkBoth nil)
	;ST11 = "  Allegro RefDes Checker Ver:0.5  "
	(axlFormSetField _SilkForm "silk_degree0" _SilkDegree0)
	(axlFormSetField _SilkForm "silk_degree45" _SilkDegree45)
	(axlFormSetField _SilkForm "silk_degree90" _SilkDegree90)
	(axlFormSetField _SilkForm "silk_degree135" _SilkDegree135)
	(axlFormSetField _SilkForm "silk_degree225" _SilkDegree225)
	(axlFormSetField _SilkForm "silk_degree270" _SilkDegree270)
	(axlFormSetField _SilkForm "silk_degree315" _SilkDegree315)
	
	axlFormBuildPopup( _SilkForm "select_layer_name" lLayer_name )
	;axlFormSetField( _SilkForm "select_layer_name" "Assembly TOP" )
	
	(if Displayed_RefDes_List == nil then
			;axlFormSetField(_SilkForm "Displayed_RefDes_List" "No RefDes")
			axlFormDisplay(_SilkForm)
			axlUIWPrint(_SilkForm "Plase select layer.")
		else
			(axlFormCreate '_SilkForm _SilkFormFile '("east" "outer") '_SilkCallBack t)
			Displayed_RefDes_List = sort(Displayed_RefDes_List nil)
			(foreach Ref_Des Displayed_RefDes_List
				axlFormSetField(_SilkForm "Displayed_RefDes_List" Ref_Des)
				axlFormDisplay(_SilkForm)
				axlUIWPrint(_SilkForm "Select Refdes")
			);end foreach Ref_Des Placed_List
		);end if Displayed_Net_List == nil
	
	axlFormSetField( _SilkForm "shadow_factor"  "0%")
	
	;axlFormColorize( _SilkForm "select_layer_name" 'text 'red)
	;axlFormColorize( _SilkForm "ST1" 'text 'green)
	;(axlFormSetField _SilkForm "ST1" ST11)
	
	; and display the form
	(axlFormDisplay _SilkForm)
)
);defun_end
	

;**************************************
; Function _SilkscreenFormCreate()
; Create Silkscreen Check Form
;**************************************
(defun _SilkFormBuild ()
	(let (_SilkForm)
		
		;drain()
		;_SilkFormFile = "SilkForm.form"
		;_SilkForm = outfile( _SilkFormFile "w")
		(setq _SilkFormFile (strcat (makeTempFileName (strcat _SilkDir "SilkForm")) ".form"))
		(setq _SilkForm (outfile _SilkFormFile))
		;FORM START
		fprintf( _SilkForm "FILE_TYPE=FORM_DEFN VERSION=2\n")
		fprintf( _SilkForm "FORM\n")
		fprintf( _SilkForm "FIXED\n")
		fprintf( _SilkForm "PORT 45 44\n")
		fprintf( _SilkForm "HEADER \"Allegro RefDes Checker\"\n")
		fprintf( _SilkForm "\n")
		fprintf( _SilkForm "TILE\n")
		
		fprintf( _SilkForm "POPUP <layers>")
		fprintf( _SilkForm "\"a\"\"a\"")
		fprintf( _SilkForm "\n")
		
		;TEXT Allegro RefDes Checker Ver:0.5
		fprintf( _SilkForm "TEXT \"Allegro RefDes Checker Ver:0.5\"\n")
		fprintf( _SilkForm "TLOC 10 1\n")
		fprintf( _SilkForm "ENDTEXT\n\n")
		
	/*	fprintf( _SilkForm "TEXT \n")
		fprintf( _SilkForm "TLOC 10 1\n")
		fprintf( _SilkForm "INFO ST1 25\n")
		fprintf( _SilkForm "ENDTEXT\n\n")
	*/	
		fprintf( _SilkForm "TEXT \"Select Layer\"\n")
		fprintf( _SilkForm "TLOC 4 3\n")
		fprintf( _SilkForm "ENDTEXT\n")
		
		fprintf( _SilkForm "FIELD select_layer_name\n")
		fprintf( _SilkForm "FLOC 4 5\n")
		fprintf( _SilkForm "ENUMSET 15\n")
		fprintf( _SilkForm "POP \"layers\"\n")
		fprintf( _SilkForm "ENDFIELD\n")
		fprintf( _SilkForm "\n")
		
		fprintf( _SilkForm "TEXT \"Refdes List\"\n")
		fprintf( _SilkForm "TLOC 24 3\n")
		fprintf( _SilkForm "ENDTEXT\n")
		
		fprintf( _SilkForm "FIELD Displayed_RefDes_List\n")
		fprintf( _SilkForm "FLOC 24 5\n")
		fprintf( _SilkForm "LIST \"\" 17 8\n")
		fprintf( _SilkForm "ENDFIELD\n")
		
		fprintf( _SilkForm "TEXT \"Current RefDes Name\"\n")
		fprintf( _SilkForm "TLOC 24 22\n")
		fprintf( _SilkForm "ENDTEXT\n")
		
		fprintf( _SilkForm "FIELD Current_RefDes\n")
		fprintf( _SilkForm "FLOC 24 24\n")
		fprintf( _SilkForm "STRFILLIN 16 10\n")
		fprintf( _SilkForm "ENDFIELD\n")
		;Zoom TrackBar
		fprintf( _SilkForm "TEXT \"Zoom:\"\n")
		fprintf( _SilkForm "TLOC 1 24\n")
		fprintf( _SilkForm "ENDTEXT\n")
		fprintf( _SilkForm "TEXT\n")
		fprintf( _SilkForm "TLOC 20 24\n")
		fprintf( _SilkForm "FGROUP \"Shadow mode\"\n")
		fprintf( _SilkForm "INFO shadow_factor 4\n")
		fprintf( _SilkForm "ENDTEXT\n")
		fprintf( _SilkForm "FIELD shadow_bright\n")
		fprintf( _SilkForm "FLOC 6 24\n")
		fprintf( _SilkForm "TRACKBAR 14 4\n")
		fprintf( _SilkForm "MIN 0\n")
		fprintf( _SilkForm "MAX 100\n")
		fprintf( _SilkForm "ENDFIELD\n")
		;TEXT Rotate:
		fprintf( _SilkForm "TEXT \"Rotate:\"\n")
		fprintf( _SilkForm "TLOC 4 7\n")
		fprintf( _SilkForm "ENDTEXT\n\n")
		;CHECKLIST 0
		fprintf( _SilkForm "FIELD silk_degree0\n")
		fprintf( _SilkForm "FLOC 4 9\n")
		fprintf( _SilkForm "CHECKLIST \" 0\"\n")
		fprintf( _SilkForm "ENDFIELD\n\n")
		;CHECKLIST 45
		fprintf( _SilkForm "FIELD silk_degree45\n")
		fprintf( _SilkForm "FLOC 4 11\n")
		fprintf( _SilkForm "CHECKLIST \" 45\"\n")
		fprintf( _SilkForm "ENDFIELD\n\n")
		;CHECKLIST 90
		fprintf( _SilkForm "FIELD silk_degree90\n")
		fprintf( _SilkForm "FLOC 4 13\n")
		fprintf( _SilkForm "CHECKLIST \" 90\"\n")
		fprintf( _SilkForm "ENDFIELD\n\n")
		;CHECKLIST 135
		fprintf( _SilkForm "FIELD silk_degree135\n")
		fprintf( _SilkForm "FLOC 4 15\n")
		fprintf( _SilkForm "CHECKLIST \" 135\"\n")
		fprintf( _SilkForm "ENDFIELD\n\n")
		;CHECKLIST 225
		fprintf( _SilkForm "FIELD silk_degree225\n")
		fprintf( _SilkForm "FLOC 10 9\n")
		fprintf( _SilkForm "CHECKLIST \" 225\"\n")
		fprintf( _SilkForm "ENDFIELD\n\n")
		;CHECKLIST 270
		fprintf( _SilkForm "FIELD silk_degree270\n")
		fprintf( _SilkForm "FLOC 10 11\n")
		fprintf( _SilkForm "CHECKLIST \" 270\"\n")
		fprintf( _SilkForm "ENDFIELD\n\n")
		;CHECKLIST 315
		fprintf( _SilkForm "FIELD silk_degree315\n")
		fprintf( _SilkForm "FLOC 10 13\n")
		fprintf( _SilkForm "CHECKLIST \" 315\"\n")
		fprintf( _SilkForm "ENDFIELD\n\n")
		;TEXT NOTE0
		fprintf( _SilkForm "TEXT \"TOP\"\n")
		fprintf( _SilkForm "TLOC 4 17\n")
		fprintf( _SilkForm "ENDTEXT\n\n")
		fprintf( _SilkForm "TEXT \"0/45/90/315\"\n")
		fprintf( _SilkForm "TLOC 4 18\n")
		fprintf( _SilkForm "ENDTEXT\n\n")
		;TEXT NOTE1
		fprintf( _SilkForm "TEXT \"BUTTON\"\n")
		fprintf( _SilkForm "TLOC 4 20\n")
		fprintf( _SilkForm "ENDTEXT\n\n")
		fprintf( _SilkForm "TEXT \"0/225/270/315\"\n")
		fprintf( _SilkForm "TLOC 4 21\n")
		fprintf( _SilkForm "ENDTEXT\n\n")
		;TEXT NOTE2
		fprintf( _SilkForm "TEXT \"0/45/90/315\"\n")
		fprintf( _SilkForm "TLOC 4 22\n")
		fprintf( _SilkForm "ENDTEXT\n\n")
		;BUTTOM Check
		fprintf( _SilkForm "FIELD silkscreen_check\n")
		fprintf( _SilkForm "FLOC 4 27\n")
		fprintf( _SilkForm "MENUBUTTON \"Check\" 8 3\n")
		fprintf( _SilkForm "ENDFIELD\n\n")
		;BUTTOM View
		fprintf( _SilkForm "FIELD view\n")
		fprintf( _SilkForm "FLOC 14 27\n")
		fprintf( _SilkForm "MENUBUTTON \"View\" 8 3\n")
		fprintf( _SilkForm "ENDFIELD\n\n")
		;BUTTOM Change
		fprintf( _SilkForm "FIELD silkscreen_change\n")
		fprintf( _SilkForm "FLOC 24 27\n")
		fprintf( _SilkForm "MENUBUTTON \"Change\" 8 3\n")
		fprintf( _SilkForm "ENDFIELD\n\n")
		;BUTTOM Close
		fprintf( _SilkForm "FIELD done\n")
		fprintf( _SilkForm "FLOC 34 27\n")
		fprintf( _SilkForm "MENUBUTTON \"Close\" 8 3\n")
		fprintf( _SilkForm "ENDFIELD\n\n")
		;END	
		fprintf( _SilkForm "ENDTILE\n\n")
		fprintf( _SilkForm "ENDFORM\n")
		close( _SilkForm)
		if( !(isFile _SilkFormFile) then
			axlUIConfirm( strcat( "Unable to Open Form File, Check Permissions on " _SilkDir))
    		_SilkEnd()
		);end of if
	) ; end of let
) ; defun - display form information

;**************************************
; Function _SilkscreenCallBack
;**************************************
defun( _SilkCallBack (form)
	
	; determine which button has been pushed and act accordingly
	(cond
		;POP
		((equal (get form 'curField) "select_layer_name")
			sLayer_active = form->curValue
	 		case( sLayer_active
				( "Assembly TOP"
						axlVisibleDesign( nil )
						axlVisibleLayer( "Board Geometry/Assembly_TOP" t )	
						axlVisibleLayer( "Board Geometry/Outline" t )	
						axlVisibleLayer( "Package Geometry/Assembly_Top" t )	
						axlVisibleLayer( "Ref Des/Assembly_Top" t )	
						sLayer_active_ref = "REF DES/ASSEMBLY_TOP"
						axlUIWPrint(form "Select to rotate angle or press \"Check\" button")
				)
				( "SilkScreen TOP"
						axlVisibleDesign( nil )
						axlVisibleLayer( "Board Geometry/SilkScreen_TOP" t )	
						axlVisibleLayer( "Board Geometry/Outline" t )
						axlVisibleLayer( "Package Geometry/SilkScreen_Top" t )	
						axlVisibleLayer( "Ref Des/SilkScreen_Top" t )	
						axlVisibleLayer( "Pin/Top" t )
						axlVisibleLayer( "Via Class/Top" t )							
						sLayer_active_ref = "REF DES/SILKSCREEN_TOP"
						axlUIWPrint(form "Select to rotate angle or press \"Check\" button")
						
						axlFormSetField(form "silk_degree0" t)
						axlFormSetField(form "silk_degree90" t)
						axlFormSetField(form "silk_degree270" nil)
				)
				( "Assembly BOTTOM"
						; display related layers, assembly or silkscreen Top/Bottom layer
						axlVisibleDesign( nil )
						axlVisibleLayer( "Board Geometry/Assembly_Bottom" t )	
						axlVisibleLayer( "Board Geometry/Outline" t )	
						axlVisibleLayer( "Package Geometry/Assembly_Bottom" t )	
						axlVisibleLayer( "Ref Des/Assembly_Bottom" t )
						sLayer_active_ref = "REF DES/ASSEMBLY_BOTTOM"
						axlUIWPrint(form "Select to rotate angle or press \"Check\" button")
				)
				( "SilkScreen BOTTOM"
						axlVisibleDesign( nil )
						axlVisibleLayer( "Board Geometry/SilkScreen_BOTTOM" t )	
						axlVisibleLayer( "Board Geometry/Outline" t )
						axlVisibleLayer( "Package Geometry/SilkScreen_Bottom" t )	
						axlVisibleLayer( "Ref Des/SilkScreen_Bottom" t )	
						axlVisibleLayer( "Pin/Bottom" t )
						axlVisibleLayer( "Via Class/Bottom" t )						
						sLayer_active_ref = "REF DES/SILKSCREEN_BOTTOM"
						axlUIWPrint(form "Select to rotate angle or press \"Check\" button")
						
						axlFormSetField(form "silk_degree0" t)
						axlFormSetField(form "silk_degree90" nil)
						axlFormSetField(form "silk_degree270" t)						
				; load("Check_refdes.il")
				)
			); end case
			axlFlushDisplay()	
			axlShell( "redisplay" )
  		)
		;List
		((equal (get form 'curField) "Displayed_RefDes_List")
			;axlSetFindFilter(?enabled list("TEXT"  "SYMBOLS") ?onButtons list("TEXT" "SYMBOLS"))
					axlSetFindFilter(?enabled list("text" "components") ?onButtons list("text" "components"))
					refdes1 = axlGetSelSet(axlSingleSelectName("REFDES" strcat(form->curValue)))
					axlHighlightObject(refdes1)
					;axlZoomToDbid(refdes1 t)
					lgs_temp_xy = nth( form->curValueInt lgs_errlistxy)
					silk_zoom_i = 270 - 2.5*silk_zoom
					axlWindowBoxSet(list((car( lgs_temp_xy)-silk_zoom_i*factor):(cadr( lgs_temp_xy)-silk_zoom_i*factor) (car( lgs_temp_xy)+silk_zoom_i*factor):(cadr( lgs_temp_xy)+silk_zoom_i*factor)))
		;	axlWindowBoxSet(list((car( lgs_temp_xy)-20):(cadr( lgs_temp_xy)-20) (car( lgs_temp_xy)+20):(cadr( lgs_temp_xy)+20)))
					axlUIWPrint( form "(%1.0f,%1.0f)  (%d/%d)" car( lgs_temp_xy) cadr( lgs_temp_xy) form->curValueInt+1 length(lgs_errlist))
					
					
					axlFormSetField(form "Current_RefDes" form->curValue)
					t
		);end "Displayed_Net_List"
		; Degree 0
		((equal (get form 'curField) "silk_degree0")
			setq(_SilkDegree0 get(form 'curValue))
			axlUIWPrint(form "Select to rotate angle or press \"Check\" button")
		)
		; Degree 45
		((equal (get form 'curField) "silk_degree45")
			setq(_SilkDegree45 get(form 'curValue))
			axlUIWPrint(form "Select to rotate angle or press \"Check\" button")
		)
		; Degree 90
		((equal (get form 'curField) "silk_degree90")
			setq(_SilkDegree90 get(form 'curValue))
			axlUIWPrint(form "Select to rotate angle or press \"Check\" button")
		)
		; Degree 135
		((equal (get form 'curField) "silk_degree135")
			setq(_SilkDegree135 get(form 'curValue))
			axlUIWPrint(form "Select to rotate angle or press \"Check\" button")
		)
		; Degree 225
		((equal (get form 'curField) "silk_degree225")
			setq(_SilkDegree225 get(form 'curValue))
			axlUIWPrint(form "Select to rotate angle or press \"Check\" button")
		)
		; Degree 270
		((equal (get form 'curField) "silk_degree270")
			setq(_SilkDegree270 get(form 'curValue))
			axlUIWPrint(form "Select to rotate angle or press \"Check\" button")
		)
		; Degree 315
		((equal (get form 'curField) "silk_degree315")
			setq(_SilkDegree315 get(form 'curValue))
			axlUIWPrint(form "Select to rotate angle or press \"Check\" button")
		)
		; Check Button
		((equal (get form 'curField) "silkscreen_check")
			;axlFormSetField(_SilkForm "Displayed_RefDes_List" " ") 
			_SilkCheck()
		)
		; View Button Display the log file in Allegro
		((equal (get form 'curField) "view") 
			axlUIWPrint(_SilkForm "View dir_error.log")
			logWindow=axlUIViewFileCreate("dir_error.log" "dir_error.log" nil)	 
			;axlShell("viewlog dir_error.log" )
		)
		; Check Button
		((equal (get form 'curField) "silkscreen_change")
			axlFormSetField(form "Displayed_RefDes_List" nil)
			axlFormSetField(_SilkForm "Current_RefDes" nil)
			_SilkChange()
		)
		; Close Button
		((equal (get form 'curField) "done") 
			_SilkEnd()
		)
		;Zoom TrackBar
		((equal (get form 'curField) "shadow_bright")
			
			silk_zoom = form->curValue
			silk_zoom_i = 270 - 2.5*silk_zoom
			axlFormSetField( form "shadow_factor"  strcat(sprintf( nil "%d" silk_zoom) "%"))
			if(Displayed_RefDes_List != nil then
				axlWindowBoxSet(list((car( lgs_temp_xy)-silk_zoom_i*factor):(cadr( lgs_temp_xy)-silk_zoom_i*factor) (car( lgs_temp_xy)+silk_zoom_i*factor):(cadr( lgs_temp_xy)+silk_zoom_i*factor)))
				axlUIWPrint(form "Select RefDes or press \"Change\" button")
			else
				axlUIWPrint(form "Select to rotate angle or press \"Check\" button")
			);end if
		)
	) ; cond
	; now, refresh the display so all this stuff REALLY happens
    axlFlushDisplay()
) ; end of _SilkscreenCallBack

;**************************************
; Function _SilkscreenEnd()
;**************************************
defun( _SilkEnd ()
	axlFormClose(_SilkForm)
	;axlDehighlightObject(_SilkHilites)
	if(isFile( _SilkFormFile) then
		deleteFile(_SilkFormFile)
	); end if if
	if( isFile("dir_error.log") then
		deleteFile("dir_error.log")
	);end if 
	if( logWindow != nil then
		axlUIWClose(logWindow)
	);end if
) ; end of Silkscreen display

;**************************************
; Function _SilkscreenCheck()
;**************************************
defun( _SilkCheck ()
	
	
	dircnt = 0
	lRefDes_err = nil
	lgs_errlistxy = nil
	lgs_errlist =nil
	axlUIWPrint( _SilkForm "Please Wait....")
	
	logfile = axlDMOpenLog("dir_error.log")
	fprintf(logfile "#Check the direction errores of refdes . \n\n")
	fprintf(logfile "REF_DES  COORDIRATION   ROTATE\n")
	
		
	setq(allsym axlDBGetDesign()->symbols)
	axlDehighlightObject(allsym)
	
	rotate = 1
	isdegree0 = nil
	isdegree45 = nil
	isdegree90 = nil
	isdegree135 = nil
	isdegree225 = nil
	isdegree270 = nil
	isdegree315 = nil
	if( _SilkDegree0 then isdegree0 = 1	else isdegree0 = 0 	)
	if( _SilkDegree45 then isdegree45 = 1 else isdegree45 = 0 )
	if( _SilkDegree90 then isdegree90 = 1 else isdegree90 = 0 )
	if( _SilkDegree135 then isdegree135 = 1 else isdegree135 = 0 )
	if( _SilkDegree225 then isdegree225 = 1 else isdegree225 = 0 )
	if( _SilkDegree270 then isdegree270 = 1 else isdegree270 = 0 )
	if( _SilkDegree315 then isdegree315 = 1 else isdegree315 = 0 )
	
	;symbol = nth( 0 allsym)
	foreach(symbol allsym 	;n=0 ++n symbol=nthelem(n allsym)
		text= axlDBGetAttachedText(symbol)
		; txt = nth( 3 text)
		;txt = nil
		foreach( txt text
			if(txt != nil && txt->text != nil then
				;axlMsgPut("Processing package : %s " txt->text)
				; Start of Check Top Layer     
				if(txt->layer ==  sLayer_active_ref then   
				;0000000=0
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 0) then 
					fprintf(logfile "TOP\n")
					axlUIWPrint( _SilkForm "Please chose rotate.")
				)
				;0000001=1
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0000010=2
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0000011=3
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 45.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0000100=4
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 90.0 ) < 5.0  then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0000101=5
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0000110=6
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0000111=7
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0001000=8
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 135.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0001001=9
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0001010=10
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0001011=11
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0001100=12
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 135.0 ) < 5.0  || abs(txt->rotation - 90.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0001101=13
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0001110=14
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 || 
						abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0001111=15
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 || 
						abs(txt->rotation - 45.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0010000=16
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 225.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0010001=17
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0010010=18
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0010011=19
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0010100=20
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0010101=21
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0010110=22
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0010111=23
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0011000=24
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0011001=25
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0011010=26
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0011011=27
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0011100=28
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 225.0 ) < 5.0  || abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0011101=29
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 || 
						abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0011110=30
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 || 
						abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0011111=31
				if( (isdegree315 == 0) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 || 
						abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0100000=32
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0100001=33
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0100010=34
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0100011=35
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0100100=36
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0  then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0100101=37
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0100110=38
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 || 
						abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0100111=39
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 || 
						abs(txt->rotation - 45.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0101000=40
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0101001=41
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0101010=42
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 || 
						abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0101011=43
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 || 
						abs(txt->rotation - 45.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0101100=44
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0  || 
						abs(txt->rotation - 90.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0101101=45
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 || 
						abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0101110=46
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 || 
						abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0101111=47
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 || 
						abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0110000=48
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0110001=49
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0110010=50
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
						abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0110011=51
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
						abs(txt->rotation - 45.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0110100=52
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
						abs(txt->rotation - 90.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0110101=53
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
						abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0110110=54
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
						abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0110111=55
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
						abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0111000=56
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
						abs(txt->rotation - 135.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0111001=57
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
						abs(txt->rotation - 135.0 )  < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0111010=58
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
						abs(txt->rotation - 135.0 )  < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0111011=59
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
						abs(txt->rotation - 135.0 )  < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0111100=60
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 270.0 ) < 5.0  || abs(txt->rotation - 225.0 ) < 5.0 || 
						abs(txt->rotation - 135.0 )  < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0111101=61
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
						abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0  || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0111110=62
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
						abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0  || 
						abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;0111111=63
				if( (isdegree315 == 0) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
						abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 || 
						abs(txt->rotation - 45.0 ) < 5.0  || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1000000=64
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1000001=65
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1000010=66
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1000011=67
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1000100=68
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0  then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1000101=69
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1000110=70
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 || 
						abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1000111=71
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 || 
						abs(txt->rotation - 45.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1001000=72
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1001001=73
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1001010=74
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 || 
						abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1001011=75
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1001100=76
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0  || 
						abs(txt->rotation - 90.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1001101=77
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 || 
						abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1001110=78
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 || 
						abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1001111=79
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 || 
						abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1010000=80
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1010001=81
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1010010=82
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
						abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1010011=83
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
						abs(txt->rotation - 45.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1010100=84
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
						abs(txt->rotation - 90.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1010101=85
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
						abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1010110=86
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
						abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1010111=87
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
						abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1011000=88
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
						abs(txt->rotation - 135.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1011001=89
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
						abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1011010=90
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
					abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1011011=91
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
						abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1011100=92
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0  || 
					abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1011101=93
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
					abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1011110=94
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
						abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 || 
						abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1011111=95
				if( (isdegree315 == 1) && (isdegree270 == 0) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 225.0 ) < 5.0 || 
					abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 || 
						abs(txt->rotation - 45.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1100000=96
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1100001=97
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1100010=98
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1100011=99
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 45.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1100100=100
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 90.0 ) < 5.0  then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1100101=101
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1100110=102
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1100111=103
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1101000=104
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 135.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1101001=105
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1101010=106
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1101011=107
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1101100=108
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 135.0 ) < 5.0  || abs(txt->rotation - 90.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1101101=109
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
					abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1101110=110
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 || 
						abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1101111=111
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 0) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 135.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 || 
						abs(txt->rotation - 45.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1110000=112
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 225.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1110001=113
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1110010=114
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1110011=115
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1110100=116
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1110101=117
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1110110=118
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 || 
						abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1110111=119
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 0) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 90.0 ) < 5.0 || 
						abs(txt->rotation - 45.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1111000=120
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1111001=121
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1111010=122
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 || 
						abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1111011=123
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 0) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 || 
						abs(txt->rotation - 45.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1111100=124
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 || 
						abs(txt->rotation - 90.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1111101=125
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 0) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 || 
						abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1111110=126
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 0) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 || 
						abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				;1111111=127
				if( (isdegree315 == 1) && (isdegree270 == 1) && (isdegree225 == 1) && (isdegree135 == 1) && (isdegree90 == 1) && (isdegree45 == 1) && (isdegree0 == 1) then 
					if( abs(txt->rotation - 315.0 ) < 5.0 || abs(txt->rotation - 270.0 ) < 5.0 || 
						abs(txt->rotation - 225.0 ) < 5.0 || abs(txt->rotation - 135.0 ) < 5.0 || 
						abs(txt->rotation - 90.0 ) < 5.0 || abs(txt->rotation - 45.0 ) < 5.0 || 
						abs(txt->rotation - 0.0 ) < 5.0 then
						x = 0
					else
						fprintf(logfile "%-8s %L  %3.1f\n" txt->text symbol->xy txt->rotation)
						lRefDes_err = append1(lRefDes_err symbol)
						++dircnt
					)
				)
				);end of if(txt->layer == sLayer_active_ref
			);End of if(txt != nil && txt->text != nil then
		) ;End foreach
	);End of foreach(symbol allsym
	
    (axlShell "redraw") ; 執行Allegro "redraw"指令(刷新螢幕)
    fprintf(logfile "\nTotal direction error of refdes: %d\n" dircnt)
	axlDMClose(logfile)
	
	axlMsgPut("Total direction error of refdes: %d\n" dircnt)     ;顯示到Allegro command視窗  
	axlMsgPut("Refdes direction error , please view logfile.") 
	if( Displayed_RefDes_List != nil then
		(foreach Ref_Des Displayed_RefDes_List
			axlFormListDeleteItem( _SilkForm "Displayed_RefDes_List" Ref_Des)
			axlFormDisplay(_SilkForm)
		);end foreach Ref_Des Placed_List	
		axlFormSetField(form "Current_RefDes" nil)
		Displayed_RefDes_List = nil
	)
	if(dircnt == 0 then
		axlUIWPrint(_SilkForm "Complete. No Error")
	else
		axlUIWPrint(_SilkForm "Complete. Please select refdes")
	)
	axlFlushDisplay()
	;Item = nth( 0 lRefDes_err)
	(foreach Item lRefDes_err
		(if (Item->refdes != "") then
			Displayed_RefDes_List = cons(Item->refdes Displayed_RefDes_List)
					
			lgs_errlistxy = cons( Item->xy lgs_errlistxy)
			lgs_errlist   = cons(Item->refdes lgs_errlist)
		);if Item->net != nil
	);end foreach Item Net_List
		axlFormSetField(_SilkForm "Displayed_RefDes_List" lgs_errlist)

)  ; end of _SilkscreenCheck() 


defun( _SilkChange ()
	;Item = nth(0 lRefDes_err)
	dircnt1 = 0
	rotation1 = 0.0
	Displayed_RefDes_List_new = nil
	lgs_errlistxy = nil
	lgs_errlist =nil
	lRefDes_err_new =nil
	logfile =  outfile("./dir_error.log" "a")
	fprintf(logfile "\n\n#Change the direction refdes . \n\n")
	fprintf(logfile "REF_DES  COORDIRATION   ROTATE\n")
	(foreach Item lRefDes_err ; Item = nth( 0 lRefDes_err)
		text1= axlDBGetAttachedText(Item)
		(foreach txt1 text1 ;txt1 = nth( 2 text1)
			bText_old_status = txt1
			if( txt1->layer == sLayer_active_ref then
				if(txt1->rotation == 180.0 || txt1->rotation == 225.0 || txt1->rotation == 270.0 || txt1->rotation == 315.0 then
					rotation1 = txt1->rotation - 180.0
					;if( rotation1 == 90 then
					if( rotation1 == 45.0 then ;test 0k
							fDelta_y = ( cadadr( txt1->bBox ) - cadar( txt1->bBox ) )*0.44
						else
							if( rotation1 == 0.0   then ;test ok
								;fDelta_y = ( caadr( txt1->bBox ) - caar( txt1->bBox ) )*0.4
								fDelta_y = ( cadadr( txt1->bBox ) - cadar( txt1->bBox ) )*0.44
							else
								if( rotation1 == 90.0 then ;test ok
									fDelta_y = ( caadr( txt1->bBox ) - caar( txt1->bBox ) )*0.5
								else
									if( rotation1 == 135.0 then
										;fDelta_y = ( caadr( txt1->bBox ) - caar( txt1->bBox ) )*0.5
										fDelta_y = ( cadadr( txt1->bBox ) - cadar( txt1->bBox ) )*0.28
									)
								)
							)
							
						)
					
					lSym_shape_box = txt1->bBox
 					fSym_left_x  = caar( lSym_shape_box )
 					fSym_right_x = caadr( lSym_shape_box )
 					fSym_left_y  = cadar( lSym_shape_box )
 					fSym_right_y = cadadr( lSym_shape_box )
 					fSym_center_x = ( fSym_left_x + fSym_right_x )*0.5
 					fSym_center_y = ( fSym_left_y + fSym_right_y )*0.5	
 									
 					fSym_x = fSym_center_x + fDelta_y*sin( rotation1 * 3.1416 / 180.0 )
					fSym_y = fSym_center_y - fDelta_y*cos( rotation1 * 3.1416 / 180.0 ) 
						
					rText_orient = make_axlTextOrientation(?textBlock txt1->textBlock, ?rotation rotation1, ?mirrored txt1->isMirrored, ?justify "CENTER" ) ;txt1->justify )
					
					fSym_xy = fSym_x : fSym_y
					bText_status = caar( axlDBCreateText( txt1->text, fSym_xy, rText_orient, txt1->layer, Item )	)	
					fprintf(logfile "%-8s %L  %3.1f  \n" Item->refdes, bText_status->xy, bText_status->rotation)
					++dircnt1
		    		;fDelta_y = 	( cadadr( bText_status->bBox ) - cadar( bText_status->bBox ) )*0.32	
		    		axlDeleteObject( list( bText_old_status ) )
		    	else
		    		if(txt1->rotation == 0.0 || txt1->rotation == 45.0 || txt1->rotation == 90.0 || txt1->rotation == 135.0 then
		    			rotation1 = txt1->rotation + 180.0
						if( rotation1 == 180.0 || rotation1 == 270.0 then
							fDelta_y = ( cadadr( txt1->bBox ) - cadar( txt1->bBox ) )*0.5
						else
							if( rotation1 == 225.0 then
								fDelta_y = ( caadr( txt1->bBox ) - caar( txt1->bBox ) )*0.5
							else
								if( rotation1 == 315.0 then  ; test ok
									fDelta_y = ( caadr( txt1->bBox ) - caar( txt1->bBox ) )*0.28
								)
							)
						)
						lSym_shape_box = txt1->bBox
 						fSym_left_x  = caar( lSym_shape_box )
 						fSym_right_x = caadr( lSym_shape_box )
 						fSym_left_y  = cadar( lSym_shape_box )
 						fSym_right_y = cadadr( lSym_shape_box )
 						fSym_center_x = ( fSym_left_x + fSym_right_x )*0.5
 						fSym_center_y = ( fSym_left_y + fSym_right_y )*0.5	
	 					fSym_x = fSym_center_x + fDelta_y*sin( rotation1 * 3.1416 / 180.0 )
						fSym_y = fSym_center_y - fDelta_y*cos( rotation1 * 3.1416 / 180.0 ) 
						rText_orient = make_axlTextOrientation(?textBlock txt1->textBlock, ?rotation rotation1, ?mirrored txt1->isMirrored, ?justify "CENTER" ) ;txt1->justify )
						fSym_xy = fSym_x : fSym_y
						bText_status = caar( axlDBCreateText( txt1->text, fSym_xy, rText_orient, txt1->layer, Item )	)	
						fprintf(logfile "%-8s %L  %3.1f  \n" Item->refdes, bText_status->xy, bText_status->rotation)
						++dircnt1
		    			axlDeleteObject( list( bText_old_status ) )
		    		else
		    			Displayed_RefDes_List_new = cons(Item->refdes Displayed_RefDes_List)
						lgs_errlistxy = cons( Item->xy lgs_errlistxy)
						lgs_errlist   = cons(Item->refdes lgs_errlist)
						lRefDes_err_new = append1(lRefDes_err_new Item)
		    		);end if
				);end if
			);end if
		);end foreach
	);end foreach Item Net_List
	 fprintf(logfile "\nTotal direction refdes: %d\n" dircnt1)
	 close(logfile)
	 
	 if(dircnt1 != 0 then
	 	if( Displayed_RefDes_List != nil then
			(foreach Ref_Des Displayed_RefDes_List
				axlFormListDeleteItem( _SilkForm "Displayed_RefDes_List" Ref_Des)
				axlFormDisplay(_SilkForm)
			);end foreach Ref_Des Placed_List	
			axlFormSetField(form "Current_RefDes" nil)
			Displayed_RefDes_List = nil
		)
		Displayed_RefDes_List = Displayed_RefDes_List_new
		lRefDes_err = lRefDes_err_new
	 	axlFormSetField(_SilkForm "Displayed_RefDes_List" lgs_errlist)
	 )
	 axlFlushDisplay()
	 axlUIWPrint(_SilkForm "Changed %d" dircnt1)
);End defun 
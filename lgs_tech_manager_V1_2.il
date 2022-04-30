;			Tech Manager
;		------------------------------------------------
;
;
;File name: lgs_tech_manager_V1_2.il
;Revision:1.3	
;Date:June 14,2002
;Writen by: 
;LiGuangsheng/24445
;Tel: 6540574
;E_mail: liguangsheng@huawei.com
;CAD Group Fundamental Dept R&D Engineer
;HUAWEI TECHNOLOGIES CO., LTD.



;***************************************************************************************************************************
;		Register Main Function
;***************************************************************************************************************************
axlCmdRegister( "lgs_tech_in" `lgstech)

;***************************************************************************************************************************
;		Main Function
;***************************************************************************************************************************
(defun lgstech ()
setq( lgstechnicsmanagerform "./lgstechmanager.form")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Path to CONSTRAINS_V1.lte;Now direct to /share/pcb/etc/skill/CONSTRAINS_V1.lte 
;You can replace "/home/regul" by the CONSTRAINS_V1.lte file absolute path

;direct to /home/regul/CONSTRAINS_V1.lte ;
;setq( lgstechfiledir "/home/regul")     ;!!! shielded by lijinjun

;direct to /share/pcb/etc/skill/CONSTRAINS_V1.lte ;
;;;;;;;;;Add by lijinjun
sprintf( lgstechfiledir "%s/etc/skill/newdata" axlGetVariable("allegro_install_dir"))   


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


techfile = nil			;var:  select techfile ;number of flowlist/2 -1 (0 1 2...)
techflow = nil			;var:  selsct flow. number of flowlist
lgstechfiledata =nil		;list: all of the tech file data
lgstechfiledata_bak = nil
flowlist = nil			;list: all of flow in select tech file (name linenumber name linenumber...)
informationlist = nil		;list: will be setup to the information window
arealist = nil			;list: all of area file data (name linenumber name linenumber...)
unselectarealist = nil		;list: all of unselect area file data (name linenumber name linenumber...)
selectarealist = nil		;list: all of select area file data (name linenumber name linenumber...)
un_selectarea = nil		;var:  select area. every time if selectarea != nil then un_selectarea must = nil
selectarea =nil			;var:  select area. every time if un_selectarea != nil then selectarea must = nil
lgs_select_type = nil		;var:  select type. must is one of: nil "file" "flow" "area"
lgs_select_line_number = nil
lgs_board_thick = "VIA-TYPE2-"	;var:  board thick. must is one of:  "VIA-TYPE1.6-" "VIA-TYPE2-" "VIA-TYPE2.5-" "VIA-TYPE3-"
lgs_type_or_min = 0		;var:  tech rule type or min. 0:type  1:min

lgs_defaultvia_bakup = nil


if(isDir(lgstechfiledir)==t
  then	techfileList = setof(x getDirFiles(  lgstechfiledir) rexMatchp( "[a-z]*.lte" x))
  else  techfileList = nil
  );end if

if( techfileList != nil
	then
		techfile = car( techfileList)
		lgs_select_type = "file"
	else
		techfile = nil
  );end if 


lgs_techrepfileCallback()

_lgs_Build_Technics_Manager_Form()
axlFormSetField( form "check_technics" techfile)
axlFormSetField( form "selectthick" "VIA-TYPE2-")
axlFormSetField( form "lgstype" 1)
_lgs_setup_flow()
_lgs_setup_information()

);end (defun lgs ()




;***************************************************************************************************************************
;		lgs_techrepfileCallback()
;***************************************************************************************************************************
(defun lgs_techrepfileCallback ()

;axlMsgPut("ok")

techfileport = infile( strcat(lgstechfiledir "/" techfile))		;dir+file name
flowlist = nil
informationlist = nil
lgstechfiledata =nil
;-------------read tech file to lgstechfiledata---------------------------
lgstemp = t
while(lgstemp
	lgstemp1 = gets(line techfileport)
	if(lgstemp1 != nil
	  then
	  	lgstechfiledata = nconc(lgstechfiledata list(car(parseString(lgstemp1 "\n"))))
	  else
	  	lgstemp = nil
	  );end if
      );end while
;-------------back up lgstechfiledata----------------------------------      
lgstechfiledata_bak = lgstechfiledata
;------------get flow and tech information------------------------------
i = 0
foreach(lgstemp  lgstechfiledata
	i++
	lgstemp1 = parseString(lgstemp " ")
	if(length(lgstemp1)>1
	then
	case(car(lgstemp1)				;load keyword
		
		("TECHNICS"
			
			lgstemp2 = ">"
			;axlMsgPut("here12")
			for(j 2 length(lgstemp1)
				lgstemp2=strcat( lgstemp2 " " nthelem(j lgstemp1))
			    );end for
			lgstemp2 = substring(lgstemp2 3 strlen( lgstemp2)-2)    
			;axlMsgPut("here")
			flowlist = nconc(flowlist list(lgstemp2) list(i))	;add the flow and begin line number to flowlist
		
		t)
	  	
		("FILE-INFO"
			lgstemp2 = ">"
			for(j 2 length(lgstemp1)
				lgstemp2=strcat( lgstemp2 " " nthelem(j lgstemp1) )
			    );end for
			lgstemp2 = substring(lgstemp2 3 strlen( lgstemp2)-2)
			informationlist = nconc(informationlist list(lgstemp2))	;add to informationlist
		
		t)
	  	
	     );end case
	   );end if	
	);end foreach	  	
;--------------------------------------------------	  	

);end defun lgs_techrepfileCallback ()
;***************************************************************************************************************************
;		lgs_techrepflowCallback()
;***************************************************************************************************************************
(defun lgs_techrepflowCallback ()
informationlist = nil
arealist = nil
lgstemp = t
i = nthelem( techflow*2+2 flowlist)+1	;get flow begin line number
lgs_select_line_number = i-1
while(lgstemp
	lgstemp1 = nthelem(i++ lgstechfiledata)
	if(lgstemp1 != nil
	  then
		lgstemp1 = parseString( lgstemp1 " ")
		if(length(lgstemp1)>1
		then
		case(car(lgstemp1)				;load keyword
			
			("AREA"
				
				lgstemp2 = ">"
				;axlMsgPut("here12")
				for(j 2 length(lgstemp1)	
					lgstemp2=strcat( lgstemp2 nthelem(j lgstemp1))
				    );end for
				;axlMsgPut(i)
				lgstemp2 = substring(lgstemp2 2 strlen( lgstemp2)-1)
				arealist = nconc(arealist list(lgstemp2) list(i-1))	;add the flow and begin line number to flowlist
		
			t)
	  	
			("TECHNICS-INFO"
				lgstemp2 = ">"
				for(j 2 length(lgstemp1)
					lgstemp2=strcat( lgstemp2 " " nthelem(j lgstemp1))
				    );end for
				lgstemp2 = substring(lgstemp2 2 strlen( lgstemp2)-1)
				informationlist = nconc(informationlist list(lgstemp2))	;add to informationlist
			
			t)
			
			("TECHNICS"
				lgstemp = nil		;all data in this TECHNICS FLOW be read,then end while
			
			t)
	  	
		     );end case
		   );end if(length(lgstemp1)>1	
 	  else
 	  	lgstemp = nil	;all data in the lgstechfiledata be read,then end while
 	 );end if(lgstemp1 != nil






      );end while	



);end defun lgs_techrepflowCallback ()

;***************************************************************************************************************************
;		_lgs_moreinfo_callback()
;***************************************************************************************************************************
(defun _lgs_moreinfo_callback ()
prog(()
lgs_temp = nil
lgs_info_file = outfile( "./LGS_TECH_INFORMATION.TXT")
case(lgs_select_type
	;----------------------------------------------
	(nil
		return(t)
	t)
	;----------------------------------------------
	("file"
		foreach(lgs_temp lgstechfiledata 
			fprintf(lgs_info_file "%s\n" lgs_temp)
			);end foreach
	t)
	;----------------------------------------------
	("flow"
		i = lgs_select_line_number
		fprintf(lgs_info_file "%s\n" nthelem(i lgstechfiledata))
		lgstemp = t
		while(lgstemp	
			lgs_temp = nthelem(++i lgstechfiledata)
			if(lgs_temp != nil
			  then
				lgstemp2 = parseString( lgs_temp " ")
				case(car(lgstemp2)				;load keyword
			
					("TECHNICS"
						lgstemp = nil		;all data in this TECHNICS be read,then end while
					t)
					
				     );end case

			  else 
			  	lgstemp = nil				;last data in lgstechfiledata have be read
		 	 );end if(lgstemp1 != nil
		
			;------------------------
			if(lgstemp != nil
				then	fprintf(lgs_info_file "%s\n" lgs_temp)			
			  );end if
			;------------------------
			  
 		     );end while			


	t);end case-("flow"
	;----------------------------------------------
	("area"
		i = lgs_select_line_number
		fprintf(lgs_info_file "%s\n" nthelem(i lgstechfiledata))
		lgstemp = t
		while(lgstemp	
			lgs_temp = nthelem(++i lgstechfiledata)
			if(lgs_temp != nil
			  then
				lgstemp2 = parseString( lgs_temp " ")
				case(car(lgstemp2)				;load keyword
			
					("TECHNICS"
						lgstemp = nil		;all data in this TECHNICS be read,then end while
					t)
					
					("AREA"
						lgstemp = nil		;all data in this AREA be read,then end while
					t)

					
				     );end case

			  else 
			  	lgstemp = nil				;last data in lgstechfiledata have be read
		 	 );end if(lgstemp1 != nil
		
			;------------------------
			if(lgstemp != nil
				then	fprintf(lgs_info_file "%s\n" lgs_temp)			
			  );end if
			;------------------------
			  
 		     );end while			


	t);end case-("flow"
	;----------------------------------------------

     );end case
close( lgs_info_file)
shell("textedit LGS_TECH_INFORMATION.TXT&")

));end defun _lgs_moreinfo_callback ()


;***************************************************************************************************************************
;		lgs_call_techfile()
;***************************************************************************************************************************
(defun lgs_call_techfile ()

i=nil


);end defun lgs_call_techfile ()

;***************************************************************************************************************************
;		_lgs_setup_flow()
;***************************************************************************************************************************
(defun _lgs_setup_flow ()
axlFormListDeleteAll(form "lgsflow")
if(flowlist != nil
  then
  	for(i 1 length(flowlist)/2
  		axlFormSetField( form "lgsflow" nthelem(2*i-1 flowlist))
  		);end foreach
  		
  	axlFormSetField( form "lgsflow" nil)
   );end if

);end dufun _lgs_setup_flow ()

;***************************************************************************************************************************
;		_lgs_setup_area_information()
;***************************************************************************************************************************
(defun _lgs_setup_area_information ()
informationlist = nil
i = nil
if(selectarea != nil
	then	i = nthelem( selectarea*2+2  selectarealist)
		lgs_select_line_number = i
  );end if

if(un_selectarea != nil
	then	i = nthelem( un_selectarea*2+2  unselectarealist)
		lgs_select_line_number = i
  );end if
if(i != nil
	then

lgstemp = t

while(lgstemp
	lgstemp1 = nthelem(++i lgstechfiledata)
	if(lgstemp1 != nil
	  then
		lgstemp1 = parseString( lgstemp1 " ")
		if(length(lgstemp1)>1
		then
		case(car(lgstemp1)				;load keyword
			
			("AREA"
				lgstemp = nil		;all data in this AREA be read,then end while
			t)
	  	
			("AREA-INFO"
				lgstemp2 = ">"
				for(j 2 length(lgstemp1)
					lgstemp2=strcat( lgstemp2 " " nthelem(j lgstemp1))
				    );end for
				lgstemp2 = substring(lgstemp2 2 strlen( lgstemp2)-1)
				informationlist = nconc(informationlist list(lgstemp2))	;add to informationlist
			
			t)
			
			("TECHNICS"
				lgstemp = nil		;all data in this AREA be read,then end while
			
			t)
	  	
		     );end case
		   );end if(length(lgstemp1)>1	
 	  else
 	  	lgstemp = nil	;all data in the lgstechfiledata be read,then end while
 	 );end if(lgstemp1 != nil

      );end while		

  );end if
_lgs_setup_information()  
);end defun _lgs_get_areainformation ()
;***************************************************************************************************************************
;		_lgs_setup_information()
;***************************************************************************************************************************
(defun _lgs_setup_information ()
axlFormListDeleteAll(form "lgsinformation")
if(lgs_select_type == "file"
	axlFormSetField( form "lgsinformation" "========FILE=====INFORMATION================")
  );end if
if(lgs_select_type == "flow"
	axlFormSetField( form "lgsinformation" "========FLOW=====INFORMATION================")
  );end if
if(lgs_select_type == "area"
	axlFormSetField( form "lgsinformation" "========AREA=====INFORMATION================")
  );end if

if(informationlist != nil
  then
  	foreach(lgstemp informationlist
  		axlFormSetField( form "lgsinformation" lgstemp)
  		);end foreach
  	axlFormSetField( form "lgsinformation" nil)
   );end if
);end defun _lgs_setup_information ()


;***************************************************************************************************************************
;		_lgs_setup_area()
;***************************************************************************************************************************
(defun _lgs_setup_area ()
_lgs_setup_area_unsel()
_lgs_setup_area_sel()
);end defun _lgs_setup_area ()

;***************************************************************************************************************************
;		_lgs_setup_area_unsel()
;***************************************************************************************************************************
(defun _lgs_setup_area_unsel ()
un_selectarea = nil
axlFormListDeleteAll(form "lgsbeselectarea")
if(unselectarealist != nil
  then
  	for(i 1 length(unselectarealist)/2
  		axlFormSetField( form "lgsbeselectarea" nthelem(2*i-1 unselectarealist))
  		);end foreach
  		
  	axlFormSetField( form "lgsbeselectarea" nil)
   );end if
);end (defun _lgs_setup_area_unsel ()

;***************************************************************************************************************************
;		_lgs_setup_area_sel()
;***************************************************************************************************************************
(defun _lgs_setup_area_sel ()
selectarea = nil
axlFormListDeleteAll(form "lgsselectarea")
if(selectarealist != nil
  then
  	for(i 1 length(selectarealist)/2
  		axlFormSetField( form "lgsselectarea" nthelem(2*i-1 selectarealist))
  		);end foreach
  		
  	axlFormSetField( form "lgsselectarea" nil)
  );end if
);end (defun _lgs_setup_area_sel ()

;***************************************************************************************************************************
;		_lgs_setup_area_sel()
;***************************************************************************************************************************
(defun lgs_techrepCallback (form)
;axlMsgPut("ok")
case(form->curField

	("check_technics"
		lgs_select_type = "file"
		techfile = form->curValue
		lgs_techrepfileCallback()
		axlFormSetField( form "check_technics" techfile)
		arealist = nil
		unselectarealist = nil
		selectarealist = nil
		techflow = nil
		_lgs_setup_area()
		_lgs_setup_flow()
		_lgs_setup_information()
		_lgs_area_type_clean()

	t)
	
	("lgsflow"
		lgs_select_type = "flow"
		techflow = form->curValueInt	;number of flowlist/2 -1 (0 1 2...)
		lgs_techrepflowCallback()
		unselectarealist = arealist
		selectarealist = nil
		_lgs_setup_area()
		_lgs_setup_information()
		_lgs_area_type_clean()	
	
	
	t)

	("lgsbeselectarea"
		lgs_select_type = "area"
		un_selectarea = form->curValueInt
		selectarea =nil
		_lgs_setup_area_sel()
		_lgs_setup_area_information()
		
		_lgs_area_type_setup()
		
		;this area add get area information
	t)

	("lgsselectarea"
		lgs_select_type = "area"
		selectarea = form->curValueInt
		un_selectarea =nil
		_lgs_setup_area_unsel()
		_lgs_setup_area_information()
		
		_lgs_area_type_setup()
		
		;this area add get area information
	t)

	("lgsunse_se"
		if((selectarea == nil) && (un_selectarea != nil)
		then
		selectarealist = nconc(selectarealist list(nthelem(un_selectarea*2+1 unselectarealist) nthelem(un_selectarea*2+2 unselectarealist) ))
		unselectarealist = _lgs_del_mum_list(unselectarealist un_selectarea*2+1 2)
		_lgs_setup_area()
		  );end if
	t)

	("lgsse_unse"
		if((selectarea != nil) && (un_selectarea == nil)
		then
		unselectarealist = nconc(unselectarealist list(nthelem(selectarea*2+1 selectarealist) nthelem(selectarea*2+2 selectarealist) ))
		selectarealist = _lgs_del_mum_list(selectarealist selectarea*2+1 2)
		_lgs_setup_area()
		  );end if
	t)

	("lgsunse_seall"
		unselectarealist = nil
		selectarealist = arealist
	       	_lgs_setup_area()
	t)

	("lgsse_unseall"
		unselectarealist = arealist
		selectarealist = nil
	       	_lgs_setup_area()
	t)

	
	("lgstype"
       		if(form->curValue
       		   then	lgs_type_or_min = 0
		   	_lgs_area_type_setup()
	          );end if
	t)
	("lgsmin"
       		if(form->curValue
       		   then	
       		   	if(axlUIYesNo("Warning: This rule just only be used for QA_checking or design reference(minimum).Yes to Continue,No to Canccel.")
       		   	then
       		   	lgs_type_or_min = 1
		  	_lgs_area_type_setup()
		  	else
		  	axlFormSetField( form "lgsmin" 0)
		  	axlFormSetField( form "lgstype" 1)
		  	);end if
	          );end if
	t)
		
	("selectthick"
		lgs_board_thick = form->curValue
	t)			

        ("lgscancel"
          	axlFormClose( form)
            	deleteFile( lgstechnicsmanagerform)
         nil)
			
        ("lgsmoreinformation"
		_lgs_moreinfo_callback()
         t)

        ("lgsload"
          	_lgs_load_callback()
          	;shell("rm lgsloadtechfile.lgc&")
          	axlFormClose( form)
            	deleteFile( lgstechnicsmanagerform)
         t)
         
         ("line_line_all"
         	_lgs_area_type_callback_all("LINE-LINE")
         	axlFormSetField( form "line_line_top" _lgs_area_type_get( "LINE-LINE" 1))
         	axlFormSetField( form "line_line_botm" _lgs_area_type_get( "LINE-LINE" 2))
         	axlFormSetField( form "line_line_inter" _lgs_area_type_get( "LINE-LINE" 3))
         	axlFormSetField( form "line_line_all"  "")
         t)
         
         ("line_line_top"
         	_lgs_area_type_callback("LINE-LINE" 1)
         	axlFormSetField( form "line_line_top" _lgs_area_type_get( "LINE-LINE" 1))
         t)
         
         ("line_line_botm"
         	_lgs_area_type_callback("LINE-LINE" 2)
         	axlFormSetField( form "line_line_botm" _lgs_area_type_get( "LINE-LINE" 2))
         t)
         
         ("line_line_inter"
         	_lgs_area_type_callback("LINE-LINE" 3)
         	axlFormSetField( form "line_line_inter" _lgs_area_type_get( "LINE-LINE" 3))
         t)
         
         ("line_via_all"
         	_lgs_area_type_callback_all("VIA-LINE")
         	axlFormSetField( form "line_via_top" _lgs_area_type_get( "VIA-LINE" 1))
         	axlFormSetField( form "line_via_botm" _lgs_area_type_get( "VIA-LINE" 2))
         	axlFormSetField( form "line_via_inter" _lgs_area_type_get( "VIA-LINE" 3))
         	axlFormSetField( form "line_via_all"  "")
         t)
         
         ("line_via_top"
         	_lgs_area_type_callback("VIA-LINE" 1)
         	axlFormSetField( form "line_via_top" _lgs_area_type_get( "VIA-LINE" 1))
         t)
         
         ("line_via_botm"
         	_lgs_area_type_callback("VIA-LINE" 2)
         	axlFormSetField( form "line_via_botm" _lgs_area_type_get( "VIA-LINE" 2))
         t)
         
         ("line_via_inter"
         	_lgs_area_type_callback("VIA-LINE" 3)
         	axlFormSetField( form "line_via_inter" _lgs_area_type_get( "VIA-LINE" 3))
         t)
         
         ("line_width_all"
         	_lgs_area_type_callback_all("LINE-WIDTH")
         	axlFormSetField( form "line_width_top" _lgs_area_type_get( "LINE-WIDTH" 1))
         	axlFormSetField( form "line_width_botm" _lgs_area_type_get( "LINE-WIDTH" 2))
         	axlFormSetField( form "line_width_inter" _lgs_area_type_get( "LINE-WIDTH" 3))
         	axlFormSetField( form "line_width_all"  "")
         t)
         
         ("line_width_top"
         	_lgs_area_type_callback("LINE-WIDTH" 1)
         	axlFormSetField( form "line_width_top" _lgs_area_type_get( "LINE-WIDTH" 1))
         t)
         
         ("line_width_botm"
         	_lgs_area_type_callback("LINE-WIDTH" 2)
         	axlFormSetField( form "line_width_botm" _lgs_area_type_get( "LINE-WIDTH" 2))
         t)
         
         ("line_width_inter"
         	_lgs_area_type_callback("LINE-WIDTH" 3)
         	axlFormSetField( form "line_width_inter" _lgs_area_type_get( "LINE-WIDTH" 3))
         t)
         
         ("tvia_tvia_botm"
         	_lgs_area_type_callback("TVIA-TVIA" 2)
         	axlFormSetField( form "tvia_tvia_botm" _lgs_area_type_get( "TVIA-TVIA" 2))
         t)
         
	("lgsreset"
		lgs_select_type = "file"
		;techfile = form->curValue
		lgs_techrepfileCallback()
		;axlFormSetField( form "check_technics" techfile)
		arealist = nil
		unselectarealist = nil
		selectarealist = nil
		techflow = nil
		_lgs_setup_area()
		_lgs_setup_flow()
		_lgs_setup_information()
		_lgs_area_type_clean()

	t)
	
	("lgshelp"
		_lgs_Build_Technics_Manager_Help_Form()
	t)
	
         



     );end case
);end defun lgs_techrepCallback ()

;***************************************************************************************************************************
;		_lgs_del_mum_list()
;***************************************************************************************************************************
(defun _lgs_del_mum_list (lgslist i j)
prog(()
k = 1
lgs_templist = nil
foreach(lgs_temp lgslist 
	if((k<i)||(k>=(i+j))
	  then
		lgs_templist = nconc(lgs_templist list(lgs_temp))
	  );end if
	k++
	);end for each
return(lgs_templist)	
));end defun


;***************************************************************************************************************************
;		_lgs_load_callback()
;***************************************************************************************************************************
(defun _lgs_load_callback ()
prog(()
lgs_defaultvia_bakup = nil
lgs_load_scrfile = outfile( "./lgsloadtechfile.lgc")
if(lgs_load_scrfile == nil				;out file error
then
	axlMsgPut("WRITE FILE ERROR")
	axlMsgPut("LOAD TECHNICS CANCEL")
	return( nil)
);end if(lgs_load_scrfile == nil
;---
_lgs_default_area_drcmode_set()				;write default area drc mode to the scr file
							;open cns,but not close

;---
if(techflow == nil					;no flow select
then
	axlMsgPut("WARNING: NO FLOW SELECT")
else
;-----------------------------------------------
_lgs_write_flow_drc_scr(nthelem(techflow*2+2 flowlist))	;setup sold to sold
if(length( selectarealist)>1
then
	axlMsgPut("SETUPING AREA TECH RULE,PLEASE WAIT. ")
	for(i 1 length( selectarealist)/2
		_lgs_write_area_drc_scr( nthelem(2*i selectarealist)  nthelem(2*i-1 selectarealist))
	    );end for
else
	axlMsgPut("WARNING: NO AREA SELECT")
);end if(length( selectarealist)>1
;-----------------------------------------------
);end if(techflow == nil
        fprintf( lgs_load_scrfile "setwindow form.cns \n")
        fprintf( lgs_load_scrfile "FORM cns drc_on YES \n")
        fprintf( lgs_load_scrfile "FORM cns done  \n")
        close( lgs_load_scrfile)
        axlShell("replay lgsloadtechfile.lgc")
        axlMsgPut("LOAD TECHNICS SUCCESSFULLY")
));end defun _lgs_load_callback ()
;***************************************************************************************************************************
;		_lgs_write_area_drc_scr()
;***************************************************************************************************************************
(defun _lgs_write_area_drc_scr (i areaname)
if(areaname != "DEFAULT"
then
        fprintf( lgs_load_scrfile "setwindow pcb\n")
        fprintf( lgs_load_scrfile "trapsize 3318\n")
        fprintf( lgs_load_scrfile "cns space values \n")
        fprintf( lgs_load_scrfile "setwindow form.cns_space_values\n")
        fprintf( lgs_load_scrfile "FORM cns_space_values constraint_name %s \n" areaname)
        fprintf( lgs_load_scrfile "FORM cns_space_values add  \n")
        fprintf( lgs_load_scrfile "FORM cns_space_values done  \n")
        fprintf( lgs_load_scrfile "setwindow pcb\n")
        fprintf( lgs_load_scrfile "cns physical values \n")
        fprintf( lgs_load_scrfile "setwindow form.cns_data_values\n")
        fprintf( lgs_load_scrfile "FORM cns_data_values constraint_name %s \n" areaname)
        fprintf( lgs_load_scrfile "FORM cns_data_values add  \n")
        fprintf( lgs_load_scrfile "FORM cns_data_values done  \n")

);end if(areaname != "DEFAULT"
lgstemp = t
while(lgstemp
	i++
	lgstemp = _lgs_line_processor(i areaname)
);end while
fprintf( lgs_load_scrfile "FORM cns_data_values done  \n")
);end defun _lgs_write_area_drc_scr (i)

;***************************************************************************************************************************
;		_lgs_line_processor()
;***************************************************************************************************************************
(defun _lgs_line_processor (i areaname)
prog(()
lgstemp1 = nthelem(i++ lgstechfiledata)
if(lgstemp1 == nil
   then
	return(nil)
   else	 
	lgstemp1 = parseString( lgstemp1 " ")
	if(length(lgstemp1)>1
	then
	case(car(lgstemp1)				;load keyword
	;---------------------------------------------------------------------------	
		("AREA"
			return(nil)		;all data in this AREA be processor
		t)
		
		("TECHNICS"
			return(nil)		;all data in this AREA be processor
		t)
  	
		("RULE-TYPE"
			case(nthelem(2 lgstemp1)
				("SPACING"
				        fprintf( lgs_load_scrfile "setwindow pcb\n")
				        fprintf( lgs_load_scrfile "cns space values \n")
				        fprintf( lgs_load_scrfile "setwindow form.cns_space_values\n")
				        fprintf( lgs_load_scrfile "FORM cns_space_values constraint_set_name %s \n" areaname)

				t)
				("PHYSICAL"
				        fprintf( lgs_load_scrfile "setwindow pcb\n")
				        fprintf( lgs_load_scrfile "cns physical values \n")
				        fprintf( lgs_load_scrfile "setwindow form.cns_data_values\n")
				        fprintf( lgs_load_scrfile "FORM cns_data_values constraint_set_name %s \n" areaname)


				t)
			     );end case
		t)
		
		("PIN-PIN"
			_lgs_line_write_to_scr("Thru Pin" "_to_thru_pin" lgstemp1)
		t)
		
		("PIN-SMD"
			_lgs_line_write_to_scr("Thru Pin" "_to_smd_pin" lgstemp1)
		t)
		
		("PIN-TPIN"
			_lgs_line_write_to_scr("Thru Pin" "_to_test_pin" lgstemp1)
		t)
		
		("PIN-VIA"
			_lgs_line_write_to_scr("Thru Pin" "_to_thru_via" lgstemp1)
		t)
		
		("PIN-TVIA"
			_lgs_line_write_to_scr("Thru Pin" "_to_test_via" lgstemp1)
		t)
		
		("PIN-BBVIA"
			_lgs_line_write_to_scr("Thru Pin" "_to_bb_via" lgstemp1)
		t)
		
		("PIN-BONDPAD"
			_lgs_line_write_to_scr("Thru Pin" "_to_bondpad" lgstemp1)
		t)
		
		("PIN-LINE"
			_lgs_line_write_to_scr("Thru Pin" "_to_line" lgstemp1)
		t)
		
		("PIN-SHAPE"
			_lgs_line_write_to_scr("Thru Pin" "_to_shape" lgstemp1)
		t)
		
		("SMD-SMD"
			_lgs_line_write_to_scr("Smd Pin" "_to_smd_pin" lgstemp1)
		t)
		
		("SMD-TPIN"
			_lgs_line_write_to_scr("Smd Pin" "_to_test_pin" lgstemp1)
		t)
		
		("SMD-VIA"
			_lgs_line_write_to_scr("Smd Pin" "_to_thru_via" lgstemp1)
		t)
		
		("SMD-TVIA"
			_lgs_line_write_to_scr("Smd Pin" "_to_test_via" lgstemp1)
		t)
		
		("SMD-BBVIA"
			_lgs_line_write_to_scr("Smd Pin" "_to_bb_via" lgstemp1)
		t)
		
		("SMD-BONDPAD"
			_lgs_line_write_to_scr("Smd Pin" "_to_bondpad" lgstemp1)
		t)
		
		("SMD-LINE"
			_lgs_line_write_to_scr("Smd Pin" "_to_line" lgstemp1)
		t)
		
		("SMD-SHAPE"
			_lgs_line_write_to_scr("Smd Pin" "_to_shape" lgstemp1)
		t)
		
		("TPIN-TPIN"
			_lgs_line_write_to_scr("Test Pin" "_to_test_pin" lgstemp1)
		t)
		
		("TPIN-VIA"
			_lgs_line_write_to_scr("Test Pin" "_to_thru_via" lgstemp1)
		t)
		
		("TPIN-TVIA"
			_lgs_line_write_to_scr("Test Pin" "_to_test_via" lgstemp1)
		t)
		
		("TPIN-BBVIA"
			_lgs_line_write_to_scr("Test Pin" "_to_bb_via" lgstemp1)
		t)
		
		("TPIN-BONDPAD"
			_lgs_line_write_to_scr("Test Pin" "_to_bondpad" lgstemp1)
		t)
		
		("TPIN-LINE"
			_lgs_line_write_to_scr("Test Pin" "_to_line" lgstemp1)
		t)
		
		("TPIN-SHAPE"
			_lgs_line_write_to_scr("Test Pin" "_to_shape" lgstemp1)
		t)
		
		("VIA-VIA"
			_lgs_line_write_to_scr("Thru Via" "_to_thru_via" lgstemp1)
		t)
		
		("VIA-TVIA"
			_lgs_line_write_to_scr("Thru Via" "_to_test_via" lgstemp1)
		t)
		
		("VIA-BBVIA"
			_lgs_line_write_to_scr("Thru Via" "_to_bb_via" lgstemp1)
		t)
		
		("VIA-BONDPAD"
			_lgs_line_write_to_scr("Thru Via" "_to_bondpad" lgstemp1)
		t)
		
		("VIA-LINE"
			_lgs_line_write_to_scr("Thru Via" "_to_line" lgstemp1)
		t)
		
		("VIA-SHAPE"
			_lgs_line_write_to_scr("Thru Via" "_to_shape" lgstemp1)
		t)
		
		("TVIA-TVIA"
			_lgs_line_write_to_scr("Test Via" "_to_test_via" lgstemp1)
 		t)
		
		("TVIA-BBVIA"
			_lgs_line_write_to_scr("Test Via" "_to_bb_via" lgstemp1)
		t)
		
		("TVIA-BONDPAD"
			_lgs_line_write_to_scr("Test Via" "_to_bondpad" lgstemp1)
		t)
		
		("TVIA-LINE"
			_lgs_line_write_to_scr("Test Via" "_to_line" lgstemp1)
		t)
		
		("TVIA-SHAPE"
			_lgs_line_write_to_scr("Test Via" "_to_shape" lgstemp1)
		t)
		
		("BBVIA-BBVIA"
			_lgs_line_write_to_scr("B/B Via" "_to_bb_via" lgstemp1)
		t)
		
		("BBVIA-BONDPAD"
			_lgs_line_write_to_scr("B/B Via" "_to_bondpad" lgstemp1)
		t)
		
		("BBVIA-LINE"
			_lgs_line_write_to_scr("B/B Via" "_to_line" lgstemp1)
		t)
		
		("BBVIA-SHAPE"
			_lgs_line_write_to_scr("B/B Via" "_to_shape" lgstemp1)
		t)
				
		("BONDPAD-BONDPAD"
			_lgs_line_write_to_scr("Bondpad" "_to_bondpad" lgstemp1)
		t)
		
		("BONDPAD-LINE"
			_lgs_line_write_to_scr("Bondpad" "_to_line" lgstemp1)
		t)
		
		("BONDPAD-SHAPE"
			_lgs_line_write_to_scr("Bondpad" "_to_shape" lgstemp1)
		t)
		

		("LINE-LINE"
			_lgs_line_write_to_scr("Line" "_to_line" lgstemp1)
		t)
		
		("LINE-SHAPE"
			_lgs_line_write_to_scr("Line" "_to_shape" lgstemp1)
		t)
		
		("SHAPE-SHAPE"
			_lgs_line_write_to_scr("Shape" "_to_shape" lgstemp1)
		t)
		
		("LINE-WIDTH"
        		fprintf( lgs_load_scrfile "FORM cns_data_values subclass ALL ETCH  \n")
        		fprintf( lgs_load_scrfile "FORM cns_data_values min_line_width %s \n" nthelem(lgs_type_or_min+6 lgstemp1))
        		fprintf( lgs_load_scrfile "FORM cns_data_values min_neck_width %s \n" nthelem(lgs_type_or_min+6 lgstemp1))
        		fprintf( lgs_load_scrfile "FORM cns_data_values max_neck_length %s \n" "0")
        		
        		fprintf( lgs_load_scrfile "FORM cns_data_values subclass TOP  \n")
        		fprintf( lgs_load_scrfile "FORM cns_data_values min_line_width %s \n" nthelem(lgs_type_or_min+2 lgstemp1))
        		fprintf( lgs_load_scrfile "FORM cns_data_values min_neck_width %s \n" nthelem(lgs_type_or_min+6 lgstemp1))
        		fprintf( lgs_load_scrfile "FORM cns_data_values max_neck_length %s \n" "0")
        		
        		fprintf( lgs_load_scrfile "FORM cns_data_values subclass BOTTOM  \n")
        		fprintf( lgs_load_scrfile "FORM cns_data_values min_line_width %s \n" nthelem(lgs_type_or_min+4 lgstemp1))
        		fprintf( lgs_load_scrfile "FORM cns_data_values min_neck_width %s \n" nthelem(lgs_type_or_min+6 lgstemp1))
        		fprintf( lgs_load_scrfile "FORM cns_data_values max_neck_length %s \n" "0")
		t)
			
		("VIA-TYPE1.6-TYPE"
			if(lgs_type_or_min == 0
			then
				if(lgs_board_thick == "VIA-TYPE1.6-"
				then
					_lgs_write_via_to_area(lgstemp1 areaname)
				  );end if(lgs_board_thick == "VIA-TYPE1.6-" 
			
			  );end if(lgs_type_or_min == 0		
		t)
		
		("VIA-TYPE1.6-MIN"
			if(lgs_type_or_min == 1
			then
				if(lgs_board_thick == "VIA-TYPE1.6-"
				then
					_lgs_write_via_to_area(lgstemp1 areaname)
				  );end if
			
			  );end if(lgs_type_or_min == 1		
		
		t)
		
		("VIA-TYPE2-TYPE"
			if(lgs_type_or_min == 0
			then
				if(lgs_board_thick == "VIA-TYPE2-"
				then
					_lgs_write_via_to_area(lgstemp1 areaname)
				  );end if
			
			  );end if(lgs_type_or_min == 0		
		
		t)
		
		("VIA-TYPE2-MIN"
			if(lgs_type_or_min == 1
			then
				if(lgs_board_thick == "VIA-TYPE2-"
				then
					_lgs_write_via_to_area(lgstemp1 areaname)
				  );end if
			
			  );end if(lgs_type_or_min == 1	
		
		t)
		
		("VIA-TYPE2.5-TYPE"
			if(lgs_type_or_min == 0
			then
				if(lgs_board_thick == "VIA-TYPE2.5-"
				then
					_lgs_write_via_to_area(lgstemp1 areaname)
				  );end if
			
			  );end if(lgs_type_or_min == 0		
		
		t)
		
		("VIA-TYPE2.5-MIN"
			if(lgs_type_or_min == 1
			then
				if(lgs_board_thick == "VIA-TYPE2.5-"
				then
					_lgs_write_via_to_area(lgstemp1 areaname)
				  );end if
			
			  );end if(lgs_type_or_min == 1		
		
		t)
		
		("VIA-TYPE3-TYPE"
			if(lgs_type_or_min == 0
			then
				if(lgs_board_thick == "VIA-TYPE3-"
				then
					_lgs_write_via_to_area(lgstemp1 areaname)
				  );end if
			
			  );end if(lgs_type_or_min == 0		
		
		t)
		
		("VIA-TYPE3-MIN"
			if(lgs_type_or_min == 1
			then
				if(lgs_board_thick == "VIA-TYPE3-"
				then
					_lgs_write_via_to_area(lgstemp1 areaname)
				  );end if
			
			  );end if(lgs_type_or_min == 1		
		
		t)
		
		
		
  	;----------------------------------------------------------------------------
	     );end case
	 );end if(length(lgstemp1)>1
return(t)	
);end if(lgstemp1 == nil	 
));end defun _lgs_line_processor (i)

;***************************************************************************************************************************
;		_lgs_write_via_to_area()
;***************************************************************************************************************************
(defun _lgs_write_via_to_area (lgstemp1 areaname)

lgstemp1 = cdr( lgstemp1)	;del hotkey
if(lgstemp1 != nil
then
	;-----------------del defout via fro area--------------------------------------
	if(areaname == 	"DEFAULT"
	then
		lgs_defaultvia_bakup = 	lgstemp1
	else
		if(lgs_defaultvia_bakup != nil
		then
			foreach(lgstemp4 lgs_defaultvia_bakup
				fprintf( lgs_load_scrfile "FORM cns_data_values subclass ALL ETCH  \n")
				fprintf( lgs_load_scrfile "FORM cns_data_values via_name %s  \n" lgstemp4)
				fprintf( lgs_load_scrfile "FORM cns_data_values add_via   \n")
				fprintf( lgs_load_scrfile "FORM cns_data_values via_name %s  \n" lgstemp4)
				fprintf( lgs_load_scrfile "FORM cns_data_values delete_via   \n")
				);end for each
		);end if(lgs_defaultvia_bakup != nil
	);end if(areaname == "DEFAULT"
			   
	;-----------------add via to area--------------------------------------		   
	foreach(lgstemp4 lgstemp1
		fprintf( lgs_load_scrfile "FORM cns_data_values subclass ALL ETCH  \n")
	        fprintf( lgs_load_scrfile "FORM cns_data_values via_name %s  \n" lgstemp4)
		fprintf( lgs_load_scrfile "FORM cns_data_values add_via   \n")
		);end for each
);end if(lgstemp1 != nil
);end defun _lgs_write_via_to_area ()
;***************************************************************************************************************************
;		_lgs_line_write_to_scr()
;***************************************************************************************************************************
(defun _lgs_line_write_to_scr (lgs_from lgs_to lgstemp1)
	fprintf( lgs_load_scrfile "FORM cns_space_values elements_list %s \n" lgs_from)
	fprintf( lgs_load_scrfile "FORM cns_space_values subclass ALL ETCH \n")
	fprintf( lgs_load_scrfile "FORM cns_space_values %s %s \n" lgs_to nthelem(lgs_type_or_min+6 lgstemp1))
	fprintf( lgs_load_scrfile "FORM cns_space_values subclass TOP \n")
	fprintf( lgs_load_scrfile "FORM cns_space_values %s %s \n" lgs_to nthelem(lgs_type_or_min+2 lgstemp1))
	fprintf( lgs_load_scrfile "FORM cns_space_values subclass BOTTOM \n")
	fprintf( lgs_load_scrfile "FORM cns_space_values %s %s \n" lgs_to nthelem(lgs_type_or_min+4 lgstemp1))
);end defun _lgs_line_write_to_scr (lgs_from lgs_to lgstemp1)

;***************************************************************************************************************************
;		_lgs_write_flow_drc_scr()
;***************************************************************************************************************************
(defun _lgs_write_flow_drc_scr (i)
lgstemp = t
while(lgstemp
	lgstemp1 = nthelem(++i lgstechfiledata)
	if(lgstemp1 != nil
	  then
		lgstemp1 = parseString( lgstemp1 " ")
		if(length(lgstemp1)>1
		then
		case(car(lgstemp1)				;load keyword

			("RULE-TYPE"
				if(nthelem(2 lgstemp1)=="CONSTRAINTS"
				then
					;open "Design Constraints" window
					fprintf( lgs_load_scrfile "cns design \n")
        				fprintf( lgs_load_scrfile "setwindow form.cns_design\n")
				);end if(nthelem(2 lgstemp1)=="CONSTRAINTS"
			t)

			("PLANE-ISLANDS"
				;write PLANE-ISLANDS setup information
				fprintf( lgs_load_scrfile "FORM cns_design negative_plane_islands.value %s \n" nthelem(2 lgstemp1))
			t)

			("SOLDER-ALIGNMENT"
				;write SOLDER-ALIGNMENT setup information
				fprintf( lgs_load_scrfile "FORM cns_design pad_soldermask_alignment.value %s \n" nthelem(2 lgstemp1))
			t)

			("SOLDER-SOLDER"
				;write SOLDER-SOLDER setup information
				fprintf( lgs_load_scrfile "FORM cns_design pad_soldermask_to_pad_soldermask_spacing.value %s \n" nthelem(2 lgstemp1))
			t)

			("AREA"
				lgstemp = nil		;all data in this AREA be read,then end while
			t)
			
			("TECHNICS"
				lgstemp = nil		;all data in this AREA be read,then end while
			
			t)
	  	
		     );end case
		   );end if(length(lgstemp1)>1	
 	  else
 	  	lgstemp = nil	;all data in the lgstechfiledata be read,then end while
 	 );end if(lgstemp1 != nil

      );end while
fprintf( lgs_load_scrfile "setwindow form.cns  \n")
fprintf( lgs_load_scrfile "FORM cns_design done  \n")      	
);end (defun _lgs_write_flow_drc_scr (i)
;***************************************************************************************************************************
;		_lgs_default_area_drcmode_set()
;***************************************************************************************************************************
(defun _lgs_default_area_drcmode_set ()
        fprintf( lgs_load_scrfile "version 14.1\n")
        fprintf( lgs_load_scrfile "setwindow pcb\n")
        fprintf( lgs_load_scrfile "trapsize 6636\n")
        fprintf( lgs_load_scrfile "cns \n")
        fprintf( lgs_load_scrfile "setwindow form.cns\n")   
        fprintf( lgs_load_scrfile "FORM cns drc_off YES \n")
        fprintf( lgs_load_scrfile "setwindow pcb\n")
        fprintf( lgs_load_scrfile "cns design\n")
        fprintf( lgs_load_scrfile "setwindow form.cns_design\n")
        fprintf( lgs_load_scrfile "FORM cns_design pad_soldermask_to_pad_soldermask_spacing.on YES\n") 
        fprintf( lgs_load_scrfile "setwindow pcb\n")
        fprintf( lgs_load_scrfile "cns simple \n")
        fprintf( lgs_load_scrfile "setwindow form.cns_simple\n")
        fprintf( lgs_load_scrfile "FORM cns_simple same_net_drc On \n")
        fprintf( lgs_load_scrfile "FORM cns_simple done  \n")
        fprintf( lgs_load_scrfile "setwindow pcb\n")
        fprintf( lgs_load_scrfile "cns space values \n")
        fprintf( lgs_load_scrfile "setwindow form.cns_space_values\n")
        fprintf( lgs_load_scrfile "FORM cns_space_values constraint_set_name DEFAULT \n")
        fprintf( lgs_load_scrfile "FORM cns_space_values same_net_drc On \n")
        fprintf( lgs_load_scrfile "FORM cns_space_values done  \n")
        fprintf( lgs_load_scrfile "setwindow pcb\n")
        fprintf( lgs_load_scrfile "cns space modes \n")
        fprintf( lgs_load_scrfile "setwindow form.cns_space_modes\n")
        fprintf( lgs_load_scrfile "FORM cns_space_modes all_spacing_chk Always \n")
        fprintf( lgs_load_scrfile "FORM cns_space_modes length_tolerance Never \n")
        fprintf( lgs_load_scrfile "FORM cns_space_modes secondary_max_len Never \n")
        fprintf( lgs_load_scrfile "FORM cns_space_modes done  \n")
        fprintf( lgs_load_scrfile "setwindow pcb\n")
        fprintf( lgs_load_scrfile "cns physical values \n")
        fprintf( lgs_load_scrfile "setwindow form.cns_data_values\n")
        fprintf( lgs_load_scrfile "FORM cns_data_values constraint_set_name DEFAULT \n")
        fprintf( lgs_load_scrfile "FORM cns_data_values direct_connect Via/Via Allowed \n")
        fprintf( lgs_load_scrfile "FORM cns_data_values direct_connect Not Allowed \n")
        fprintf( lgs_load_scrfile "FORM cns_data_values done  \n")
        fprintf( lgs_load_scrfile "setwindow pcb\n")
        fprintf( lgs_load_scrfile "cns physical modes \n")
        fprintf( lgs_load_scrfile "setwindow form.cns_data_modes\n")
        fprintf( lgs_load_scrfile "FORM cns_data_modes min_line_width Always \n")
        fprintf( lgs_load_scrfile "FORM cns_data_modes direct_connect Always \n")
        fprintf( lgs_load_scrfile "FORM cns_data_modes done  \n")
        fprintf( lgs_load_scrfile "setwindow pcb\n")
        fprintf( lgs_load_scrfile "cns design \n")
        fprintf( lgs_load_scrfile "setwindow form.cns_design\n")
        fprintf( lgs_load_scrfile "FORM cns_design cancel  \n")
);end defun _lgs_default_area_drcmode_set () 
;***************************************************************************************************************************
;		_lgs_Build_Technics_Manager_Form()
;***************************************************************************************************************************
(defun _lgs_Build_Technics_Manager_Form ()
        deleteFile( lgstechnicsmanagerform)
        FORMFILE = outfile( lgstechnicsmanagerform)
        fprintf( FORMFILE "#TECHNICS RULE MANAGER FROM FILE\n")
        fprintf( FORMFILE "#WRITE BY LIGUANGSHENG HUAWEI 24445\n")
        fprintf( FORMFILE "FILE_TYPE=FORM_DEFN VERSION=2\n")
        fprintf( FORMFILE "FORM\n")
        fprintf( FORMFILE "FIXED\n")
        fprintf( FORMFILE "PORT 45 70\n")
        fprintf( FORMFILE "HEADER \"Constrains Input System V1.3\"\n")
        fprintf( FORMFILE "TILE\n")
;-----------build tech file name pop-------------------------------------------------------------
        fprintf( FORMFILE "POPUP <file_Names>")
        if(length(techfileList)>1
          then
        	for(i 1 length(techfileList)-1
        	fprintf( FORMFILE "\"%s\" \"%s\"," nthelem(i techfileList)  nthelem(i techfileList))
        	    );end for
        	fprintf( FORMFILE "\"%s\" \"%s\".\n" nthelem(length(techfileList) techfileList)  nthelem(length(techfileList) techfileList))
          else if(length(techfileList)==1	
          	  then
          	  	fprintf( FORMFILE "\"%s\" \"%s\".\n" car(techfileList)  car(techfileList))
          	  else
          	  	fprintf( FORMFILE "\"\" \"\".\n")
          	  );end else if
           );end if	  
;--------------------------------------------------------------------------------------------------

;        fprintf( FORMFILE "POPUP <file_Names>\"debug.lte\" \"debug.lte\",\"debugtest2.lte\" \"debugtest2.lte\".\n")
;        fprintf( FORMFILE "POPUP <flow_sel>\">WAVE\" \">WAVE\",\">WAVE\" \">WAVE\".\n")
        fprintf( FORMFILE "POPUP <lgspopthick>\"1.6mm\" \"VIA-TYPE1.6-\",\"2mm\" \"VIA-TYPE2-\",\"2.5mm\" \"VIA-TYPE2.5-\",\"3mm\" \"VIA-TYPE3-\".\n")
        fprintf( FORMFILE "GROUP \"SELECT TECHNICS\"\n")
        fprintf( FORMFILE "FLOC 1 0\n")
        fprintf( FORMFILE "FSIZE 27 14\n")
        fprintf( FORMFILE "INFO group\n")
        fprintf( FORMFILE "ENDGROUP\n")
        fprintf( FORMFILE "TEXT \"FILE:\"\n")
        fprintf( FORMFILE "TLOC 2 3\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "TEXT \"FLOW:\"\n")
        fprintf( FORMFILE "TLOC 2 7\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "FIELD check_technics\n")
        fprintf( FORMFILE "FLOC 7 3\n")
        fprintf( FORMFILE "ENUMSET 17\n")
        fprintf( FORMFILE "POP \"file_Names\"\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD lgsflow\n")
        fprintf( FORMFILE "FLOC 7 7\n")
        fprintf( FORMFILE "LIST \"\" 19 4\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "GROUP \"BOARD THICKNESS\"\n")
        fprintf( FORMFILE "FLOC 29 0\n")
        fprintf( FORMFILE "FSIZE 16 6\n")
        fprintf( FORMFILE "INFO group\n")
        fprintf( FORMFILE "ENDGROUP\n")
        fprintf( FORMFILE "TEXT \"THICK:\"\n")
        fprintf( FORMFILE "TLOC 30 3\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "FIELD selectthick\n")
        fprintf( FORMFILE "FLOC 36 3\n")
        fprintf( FORMFILE "ENUMSET 5\n")
        fprintf( FORMFILE "POP \"lgspopthick\"\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "GROUP \"TYPE\"\n")
        fprintf( FORMFILE "FLOC 29 6\n")
        fprintf( FORMFILE "FSIZE 16 8\n")
        fprintf( FORMFILE "INFO group\n")
        fprintf( FORMFILE "ENDGROUP\n")
        fprintf( FORMFILE "FIELD lgstype\n")
        fprintf( FORMFILE "FLOC 30 9\n")
        fprintf( FORMFILE "FGROUP \"lgstype\"\n")
        fprintf( FORMFILE "CHECKLIST \"DESIGN RULE\" \"lgstype\"\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD lgsmin\n")
        fprintf( FORMFILE "FLOC 30 11\n")
        fprintf( FORMFILE "FGROUP \"lgstype\"\n")
        fprintf( FORMFILE "CHECKLIST \"CHECK RULE\" \"lgstype\"\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "GROUP \"SELECT AREA RULE\"\n")
        fprintf( FORMFILE "FLOC 1 14\n")
        fprintf( FORMFILE "FSIZE 44 18\n")
        fprintf( FORMFILE "INFO group\n")
        fprintf( FORMFILE "ENDGROUP\n")
        fprintf( FORMFILE "TEXT \"UNSELECT\"\n")
        fprintf( FORMFILE "TLOC 3 16\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "TEXT \"SELECT\"\n")
        fprintf( FORMFILE "TLOC 25 16\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "FIELD lgsbeselectarea\n")
        fprintf( FORMFILE "FLOC 2 18\n")
        fprintf( FORMFILE "LIST \"\" 20 6\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD lgsselectarea\n")
        fprintf( FORMFILE "FLOC 24 18\n")
        fprintf( FORMFILE "LIST \"\" 20 6\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD lgsunse_seall\n")
        fprintf( FORMFILE "FLOC 3 29\n")
        fprintf( FORMFILE "MENUBUTTON \"ALL>>\" 8 3\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD lgsunse_se\n")
        fprintf( FORMFILE "FLOC 13 29\n")
        fprintf( FORMFILE "MENUBUTTON \">>\" 8 3\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD lgsse_unse\n")
        fprintf( FORMFILE "FLOC 25 29\n")
        fprintf( FORMFILE "MENUBUTTON \"<<\" 8 3\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD lgsse_unseall\n")
        fprintf( FORMFILE "FLOC 35 29\n")
        fprintf( FORMFILE "MENUBUTTON \"<<ALL\" 8 3\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "GROUP \"CHANGE USUAL VALUE\"\n")
        fprintf( FORMFILE "FLOC 1 32\n")
        fprintf( FORMFILE "FSIZE 44 13\n")
        fprintf( FORMFILE "INFO group\n")
        fprintf( FORMFILE "ENDGROUP\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "TEXT \"ALL         TOP       BOTM       INTER\"\n")
        fprintf( FORMFILE "TLOC 16 34\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "TEXT \"Line-Line:\"\n")
        fprintf( FORMFILE "TLOC 3 36\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "TEXT \"Line-Via:\"\n")
        fprintf( FORMFILE "TLOC 3 38\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "TEXT \"Line Width:\"\n")
        fprintf( FORMFILE "TLOC 3 40\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "TEXT \"Test Via-Test Via:\"\n")
        fprintf( FORMFILE "TLOC 3 42\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "FIELD line_line_all                       \n")
        fprintf( FORMFILE "FLOC 13 36                                  \n")
        fprintf( FORMFILE "REALFILLIN 4 6                             \n")
        fprintf( FORMFILE "REALMIN 1                               \n")
        fprintf( FORMFILE "REALMAX 300                                \n")
        fprintf( FORMFILE "ENDFIELD                                    \n")
        fprintf( FORMFILE "           \n")
        fprintf( FORMFILE "FIELD line_line_top                       \n")
        fprintf( FORMFILE "FLOC 21 36                                  \n")
        fprintf( FORMFILE "REALFILLIN 4 6                             \n")
        fprintf( FORMFILE "REALMIN 1                               \n")
        fprintf( FORMFILE "REALMAX 300                                \n")
        fprintf( FORMFILE "ENDFIELD \n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "FIELD line_line_botm                       \n")
        fprintf( FORMFILE "FLOC 29 36                                  \n")
        fprintf( FORMFILE "REALFILLIN 4 6                             \n")
        fprintf( FORMFILE "REALMIN 1                               \n")
        fprintf( FORMFILE "REALMAX 300                                \n")
        fprintf( FORMFILE "ENDFIELD \n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "FIELD line_line_inter                       \n")
        fprintf( FORMFILE "FLOC 37 36                                  \n")
        fprintf( FORMFILE "REALFILLIN 4 6                             \n")
        fprintf( FORMFILE "REALMIN 1                               \n")
        fprintf( FORMFILE "REALMAX 300                                \n")
        fprintf( FORMFILE "ENDFIELD \n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "FIELD line_via_all                       \n")
        fprintf( FORMFILE "FLOC 13 38                                  \n")
        fprintf( FORMFILE "REALFILLIN 4 6                             \n")
        fprintf( FORMFILE "REALMIN 1                               \n")
        fprintf( FORMFILE "REALMAX 300                                \n")
        fprintf( FORMFILE "ENDFIELD                                    \n")
        fprintf( FORMFILE "           \n")
        fprintf( FORMFILE "FIELD line_via_top                       \n")
        fprintf( FORMFILE "FLOC 21 38                                  \n")
        fprintf( FORMFILE "REALFILLIN 4 6                             \n")
        fprintf( FORMFILE "REALMIN 1                               \n")
        fprintf( FORMFILE "REALMAX 300                                \n")
        fprintf( FORMFILE "ENDFIELD \n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "FIELD line_via_botm                       \n")
        fprintf( FORMFILE "FLOC 29 38                                  \n")
        fprintf( FORMFILE "REALFILLIN 4 6                             \n")
        fprintf( FORMFILE "REALMIN 1                               \n")
        fprintf( FORMFILE "REALMAX 300                                \n")
        fprintf( FORMFILE "ENDFIELD \n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "FIELD line_via_inter                       \n")
        fprintf( FORMFILE "FLOC 37 38                                 \n")
        fprintf( FORMFILE "REALFILLIN 4 6                             \n")
        fprintf( FORMFILE "REALMIN 1                               \n")
        fprintf( FORMFILE "REALMAX 300                                \n")
        fprintf( FORMFILE "ENDFIELD \n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "FIELD line_width_all                       \n")
        fprintf( FORMFILE "FLOC 13 40                                  \n")
        fprintf( FORMFILE "REALFILLIN 4 6                             \n")
        fprintf( FORMFILE "REALMIN 1                               \n")
        fprintf( FORMFILE "REALMAX 300                                \n")
        fprintf( FORMFILE "ENDFIELD                                    \n")
        fprintf( FORMFILE "           \n")
        fprintf( FORMFILE "FIELD line_width_top                       \n")
        fprintf( FORMFILE "FLOC 21 40                                  \n")
        fprintf( FORMFILE "REALFILLIN 4 6                             \n")
        fprintf( FORMFILE "REALMIN 1                               \n")
        fprintf( FORMFILE "REALMAX 300                                \n")
        fprintf( FORMFILE "ENDFIELD \n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "FIELD line_width_botm                       \n")
        fprintf( FORMFILE "FLOC 29 40                                  \n")
        fprintf( FORMFILE "REALFILLIN 4 6                             \n")
        fprintf( FORMFILE "REALMIN 1                               \n")
        fprintf( FORMFILE "REALMAX 300                                \n")
        fprintf( FORMFILE "ENDFIELD \n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "FIELD line_width_inter                       \n")
        fprintf( FORMFILE "FLOC 37 40                                 \n")
        fprintf( FORMFILE "REALFILLIN 4 6                             \n")
        fprintf( FORMFILE "REALMIN 1                               \n")
        fprintf( FORMFILE "REALMAX 300                                \n")
        fprintf( FORMFILE "ENDFIELD \n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "FIELD tvia_tvia_botm                       \n")
        fprintf( FORMFILE "FLOC 29 42                                  \n")
        fprintf( FORMFILE "REALFILLIN 4 6                             \n")
        fprintf( FORMFILE "REALMIN 1                               \n")
        fprintf( FORMFILE "REALMAX 300                                \n")
        fprintf( FORMFILE "ENDFIELD \n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "GROUP \"INFORMATION\"\n")
        fprintf( FORMFILE "FLOC 1 45\n")
        fprintf( FORMFILE "FSIZE 44 20\n")
        fprintf( FORMFILE "INFO group\n")
        fprintf( FORMFILE "ENDGROUP\n")
        fprintf( FORMFILE "FIELD lgsinformation\n")
        fprintf( FORMFILE "FLOC 2 47\n")
        fprintf( FORMFILE "LIST \"\" 42 8\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD lgsmoreinformation\n")
        fprintf( FORMFILE "FLOC 3 62\n")
        fprintf( FORMFILE "MENUBUTTON \"MORE INFORMATION\" 40 3\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "FIELD lgsload\n")
        fprintf( FORMFILE "FLOC 2 66\n")
        fprintf( FORMFILE "MENUBUTTON \"LOAD\" 10 3\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD lgscancel\n")
        fprintf( FORMFILE "FLOC 13 66\n")
        fprintf( FORMFILE "MENUBUTTON \"CANCEL\" 10 3\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD lgsreset\n")
        fprintf( FORMFILE "FLOC 24 66\n")
        fprintf( FORMFILE "MENUBUTTON \"RESET\" 10 3\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD lgshelp\n")
        fprintf( FORMFILE "FLOC 35 66\n")
        fprintf( FORMFILE "MENUBUTTON \"HELP\" 10 3\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "ENDTILE\n")
        fprintf( FORMFILE "ENDFORM\n")
        close( FORMFILE)
        form = (axlFormCreate (gensym) lgstechnicsmanagerform `("E" "OUTER") `lgs_techrepCallback t)
        axlFormDisplay( form)
);defun _lgs_Build_Technics_Manager_Form ()

;***************************************************************************************************************************
;		_lgs_area_type_setup()
;***************************************************************************************************************************
(defun _lgs_area_type_setup ()
prog(()
axlFormSetField( form "line_line_top" _lgs_area_type_get( "LINE-LINE" 1))
axlFormSetField( form "line_line_botm" _lgs_area_type_get( "LINE-LINE" 2))
axlFormSetField( form "line_line_inter" _lgs_area_type_get( "LINE-LINE" 3))

axlFormSetField( form "line_via_top" _lgs_area_type_get( "VIA-LINE" 1))
axlFormSetField( form "line_via_botm" _lgs_area_type_get( "VIA-LINE" 2))
axlFormSetField( form "line_via_inter" _lgs_area_type_get( "VIA-LINE" 3))

axlFormSetField( form "line_width_top" _lgs_area_type_get( "LINE-WIDTH" 1))
axlFormSetField( form "line_width_botm" _lgs_area_type_get( "LINE-WIDTH" 2))
axlFormSetField( form "line_width_inter" _lgs_area_type_get( "LINE-WIDTH" 3))

axlFormSetField( form "tvia_tvia_botm" _lgs_area_type_get( "TVIA-TVIA" 2))

));end defun _lgs_area_type_setup ()
;***************************************************************************************************************************
;		_lgs_area_type_clean()
;***************************************************************************************************************************
(defun _lgs_area_type_clean ()
prog(()
axlFormSetField( form "line_line_top" "")
axlFormSetField( form "line_line_botm" "")
axlFormSetField( form "line_line_inter" "")

axlFormSetField( form "line_via_top" "")
axlFormSetField( form "line_via_botm" "")
axlFormSetField( form "line_via_inter" "")

axlFormSetField( form "line_width_top" "")
axlFormSetField( form "line_width_botm" "")
axlFormSetField( form "line_width_inter" "")

axlFormSetField( form "tvia_tvia_botm" "")

));end defun _lgs_area_type_clean ()

;***************************************************************************************************************************
;		_lgs_area_type_get()
;***************************************************************************************************************************
(defun _lgs_area_type_get (area_type area_layer)
prog(()
;------------area_layer(1 2 3)
;-------------check area-----------------------
if(lgs_select_type != "area"
then
	_lgs_area_type_clean()
	return(nil));end if
;-------------get line number-----------------------
lgs_line_number = _lgs_area_write_getline( area_type)
if(lgs_line_number == nil
then
	return(nil));end if
;------------------------------------
lgs_templine = parseString( nthelem(lgs_line_number lgstechfiledata) " ")
return( atof( nthelem(area_layer*2+lgs_type_or_min lgs_templine)))

));end defun _lgs_area_type_get ()


;***************************************************************************************************************************
;		_lgs_area_type_callback()
;***************************************************************************************************************************
(defun _lgs_area_type_callback (area_type area_layer)
prog(()
;------------area_layer(1 2 3)
;-------------check area-----------------------
if(lgs_select_type != "area"
then
	return(nil));end if
;-------------get line number-----------------------
lgs_line_number = _lgs_area_write_getline( area_type)
if(lgs_line_number == nil
then
	return(nil));end if
;------------------------------------
lgs_templine = parseString( nthelem(lgs_line_number lgstechfiledata) " ")
lgs_templine_bak = parseString( nthelem(lgs_line_number lgstechfiledata_bak) " ")
lgs_tempmin = atof( nthelem(area_layer*2+1 lgs_templine_bak))
if(form->curValue < lgs_tempmin
then
	return(nil));end if
;------------------------------------
lgstemp2 = ">"
i = 0
foreach(lgstemp lgs_templine
	i++
	if(i == area_layer*2+lgs_type_or_min
	  then
    	  	sprintf(lgstemp "%1.2f" form->curValue)
    	  );end if
    	lgstemp2=strcat( lgstemp2 " " lgstemp)
    	);end for
	lgstemp2 = substring(lgstemp2 2 strlen( lgstemp2)-1)	

lgstechfiledata = lgswritelistnew(lgstechfiledata lgstemp2 lgs_line_number)

return(t)
));end defun _lgs_linetoline_top_callback (area_type)

;***************************************************************************************************************************
;		_lgs_area_type_callback_all()
;***************************************************************************************************************************
(defun _lgs_area_type_callback_all (area_type)
prog(()

;-------------check area-----------------------
if(lgs_select_type != "area"
then
	return(nil));end if
;-------------get line number-----------------------
lgs_line_number = _lgs_area_write_getline( area_type)
if(lgs_line_number == nil
then
	return(nil));end if
;------------------------------------
lgs_templine = parseString( nthelem(lgs_line_number lgstechfiledata) " ")
lgs_templine_bak = parseString( nthelem(lgs_line_number lgstechfiledata_bak) " ")


;------------------------------------
lgstemp2 = nil
for(area_layer 1 3
lgs_tempmin = atof( nthelem(area_layer*2+1 lgs_templine_bak))
if(form->curValue >= lgs_tempmin
then
lgstemp2 = ">"
i = 0
foreach(lgstemp lgs_templine
	i++
	if(i == area_layer*2+lgs_type_or_min
	  then
    	  	sprintf(lgstemp "%1.2f" form->curValue)
    	  );end if
    	lgstemp2=strcat( lgstemp2 " " lgstemp)
    	);end for
	lgstemp2 = substring(lgstemp2 2 strlen( lgstemp2)-1)	
	lgs_templine = parseString( lgstemp2)
  );end if(form->curValue >= lgs_tempmin
  );end for (area_layer 1 3	
;------------------------------------	
	


if(lgstemp2 != nil
   then
   	lgstechfiledata = lgswritelistnew(lgstechfiledata lgstemp2 lgs_line_number)
  );end if
return(t)
));end defun _lgs_linetoline_top_callback_all (area_type)


;***************************************************************************************************************************
;		_lgs_area_write_getline()
;***************************************************************************************************************************
(defun _lgs_area_write_getline ( area_type)
prog(()

i = nil
if(selectarea != nil
	then	i = nthelem( selectarea*2+2  selectarealist)
		lgs_select_line_number = i
  );end if

if(un_selectarea != nil
	then	i = nthelem( un_selectarea*2+2  unselectarealist)
		lgs_select_line_number = i
  );end if
if(i != nil
	then

lgstemp = t

while(lgstemp
	lgstemp1 = nthelem(++i lgstechfiledata)
	if(lgstemp1 != nil
	  then
		lgstemp1 = parseString( lgstemp1 " ")
		if(length(lgstemp1)>1
		then
		
		;---------------------
		lgstemp1 = car(lgstemp1)
		
		if(lgstemp1 == "AREA"
			then 
			lgstemp = nil		;all data in this AREA be read,then end while
		  );end if
				
		if(lgstemp1 == "TECHNICS"
			then 
			lgstemp = nil		;all data in this AREA be read,then end while
		  );end if
		
		if(lgstemp1 == area_type
			then 
			return(i)
		  );end if
		     
		 ;---------------------    
		   );end if(length(lgstemp1)>1	
 	  else
 	  	lgstemp = nil	;all data in the lgstechfiledata be read,then end while
 	 );end if(lgstemp1 != nil

      );end while		

  );end if
return( nil)




));end defun _lgs_area_write_getline ()


;***************************************************************************************************************************
;		lgswritelistnew()
;***************************************************************************************************************************
(defun lgswritelistnew (list listmember i)
prog(()

	j=0
	lgstemp=nil
	foreach(temp list
		j++
		if(j==i then lgstemp=append( lgstemp list( listmember))
		        else lgstemp=append( lgstemp list( temp))
		  );end if
	);end for
	return( lgstemp)
));end lgswritelist (list i)

;***************************************************************************************************************************
;		_lgs_Build_Technics_Manager_Help_Form()
;***************************************************************************************************************************
(defun _lgs_Build_Technics_Manager_Help_Form ()
	setq( lgstechnicsmanagerhelpform "./lgstechmanagerhelp.form")
        deleteFile( lgstechnicsmanagerhelpform)
        FORMHELPFILE = outfile( lgstechnicsmanagerhelpform)
        fprintf( FORMHELPFILE "#TECHNICS RULE MANAGER V1.3 HELP FROM FILE\n")
        fprintf( FORMHELPFILE "#WRITE BY LIGUANGSHENG HUAWEI 24445\n")
        fprintf( FORMHELPFILE "FILE_TYPE=FORM_DEFN VERSION=2\n")
        fprintf( FORMHELPFILE "FORM\n")
        fprintf( FORMHELPFILE "FIXED\n")
        fprintf( FORMHELPFILE "PORT 33 70\n")
        fprintf( FORMHELPFILE "HEADER \"Constrains Input System V1.3\"\n")
        fprintf( FORMHELPFILE "TILE\n")
        fprintf( FORMHELPFILE "GROUP \"\"\n")
        fprintf( FORMHELPFILE "FLOC 3 0\n")
        fprintf( FORMHELPFILE "FSIZE 28 6\n")
        fprintf( FORMHELPFILE "INFO group\n")
        fprintf( FORMHELPFILE "ENDGROUP\n")
        fprintf( FORMHELPFILE "TEXT \"CONSTRAINS INPUT SYSTEM V1.3\"\n")
        fprintf( FORMHELPFILE "TLOC 5 2\n")
        fprintf( FORMHELPFILE "ENDTEXT\n")
        fprintf( FORMHELPFILE "TEXT \"TECHNICS RULE AUTO INPUT\"\n")
        fprintf( FORMHELPFILE "TLOC 6 4\n")
        fprintf( FORMHELPFILE "ENDTEXT\n")
        fprintf( FORMHELPFILE "TEXT \"Revision:1.2\"\n")
        fprintf( FORMHELPFILE "TLOC 13 6\n")
        fprintf( FORMHELPFILE "ENDTEXT\n")
        fprintf( FORMHELPFILE "TEXT \"Write by:Li Guangsheng/24445\"\n")
        fprintf( FORMHELPFILE "TLOC 6 8\n")
        fprintf( FORMHELPFILE "ENDTEXT\n")
        fprintf( FORMHELPFILE "TEXT \"HUAWEI CAD \"\n")
        fprintf( FORMHELPFILE "TLOC 12 10\n")
        fprintf( FORMHELPFILE "ENDTEXT\n")
        fprintf( FORMHELPFILE "TEXT \"DATA:05/25/2002\"\n")
        fprintf( FORMHELPFILE "TLOC 11 12\n")
        fprintf( FORMHELPFILE "ENDTEXT\n")
        fprintf( FORMHELPFILE "TEXT \"Have any Problem Please Contact Me!\"\n")
        fprintf( FORMHELPFILE "TLOC 4 14\n")
        fprintf( FORMHELPFILE "ENDTEXT\n")
        fprintf( FORMHELPFILE "TEXT \"ADD:1618   TEL:50574\"\n")
        fprintf( FORMHELPFILE "TLOC 8 16\n")
        fprintf( FORMHELPFILE "ENDTEXT\n")
        fprintf( FORMHELPFILE "FIELD lgsok\n")
        fprintf( FORMHELPFILE "FLOC 11 18\n")
        fprintf( FORMHELPFILE "MENUBUTTON \"OK\" 10 3\n")
        fprintf( FORMHELPFILE "ENDFIELD\n")
        fprintf( FORMHELPFILE "ENDTILE\n")
        fprintf( FORMHELPFILE "ENDFORM\n")
        close( FORMHELPFILE)
        helpform = (axlFormCreate (gensym) lgstechnicsmanagerhelpform `("E" "OUTER") `lgs_tech_help_Callback t)
        axlFormDisplay( helpform)
);defun _lgs_Build_Technics_Manager_Help_Form ()

;***************************************************************************************************************************
;		lgs_tech_help_Callback()
;***************************************************************************************************************************
(defun lgs_tech_help_Callback (helpform)
	axlFormClose( helpform)
	deleteFile( lgstechnicsmanagerhelpform)
);end defun lgs_tech_help_Callback (helpform)
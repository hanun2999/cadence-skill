; Grid System
; Rev 1.0: May 1,2002
; Written by:	
; LiGuangsheng/24445
; CAD Group Fundamental Dept R&D Engineer
; HUAWEI TECHNOLOGIES CO., LTD.

;===============REGIST COMMAND LINE=========================================================================================
;===========================================================================================================================
axlCmdRegister( "grid_system" '_lgs_grid_system)
axlCmdRegister("grid_setenv" '_lgs_gridsystem_setenv)

;===============MAIN FUNCTION===============================================================================================
;===========================================================================================================================
(defun _lgs_grid_system ()
	lgssyslist=nil
	lgssyslistfile=nil
	lgsjt=nil
	selectedFile=nil
	typeloadfile=nil
	typesavefile=nil
	lgstab="Setup_Grid_System"
	typedir=nil
	lgsdisplayonline=0
	lgshotkey=0
	setq( lgsgridfileform "./lgsgridsystem.form")
	setq( lgsgridlogfile "./grid.log")
	
	_lgs_Build_gridsystem_Form()
	_lgs_read_logfile()
	_lgs_setfrom()
	setformgidfilelist(lgssyslist "file_list")
	_lgs_setfromtab2()
)

;====================FUNCTION===============================================================================================
;===========================================================================================================================
(defun _lgs_read_logfile ()
	lgs_logfile=infile("./grid.log")
	if(lgs_logfile!=nil
	then
		for(i 1 100
			if(gets(line lgs_logfile)=="ctrl1\n"
			then
				lgshotkey=0
				_lgscreat_syslist()
			t)
			if(gets(line lgs_logfile)=="ctrl2\n"
			then
				lgshotkey=1
				_lgscreat_syslist()
			t)
			if(gets(line lgs_logfile)=="ctrl3\n"
			then
				lgshotkey=2
				_lgscreat_syslist()
			t)
			if(gets(line lgs_logfile)=="ctrl4\n"
			then
				lgshotkey=3
				_lgscreat_syslist()
			t)
			if(gets(line lgs_logfile)=="ctrl5\n"
			then
				lgshotkey=4
				_lgscreat_syslist()
			t)
			if(gets(line lgs_logfile)=="ctrl6\n"
			then
				lgshotkey=5
				_lgscreat_syslist()
			t)
			);endfor	
		close(lgs_logfile)
	else
		lgscreatlogfile()
	);end if

	lgssyslist=reverse(lgssyslist)
	
	if(lgshotkey!=5
		then lgscreatlogfile()
	);end if
	
	lgshotkey = 0
	
);(defun _lgs_read_logfile ()



;=================FORM CALL BACK=====================================================================================
;===========================================================================================================================
(defun _lgs_repCallback (form)
prog(()
    case( form->curField
	    ("tab"
	    	lgstab=form->curValue
	    	;if(lgstab=="Setup_Grid_System"
	    	;  );end if
	     t)

	    ("check_key"
	    	lgs_check_key()
	     t)
	     
	    ("check_grid"
	    	lgs_check_grid()
	        
	     t)

	    ("ctrl_etch_enable"
	        if(form->curValue
	           then	lgswritelist(lgssyslist "1" lgshotkey*11+1)
	        	lgssyslist=lgsjt	        
		   else
   	        	lgswritelist(lgssyslist "0" lgshotkey*11+1)
	        	lgssyslist=lgsjt	        
	          );end if
	         setformgidfilelist(lgssyslist "file_list")
	     t)

	    ("ctrl_nonetch_enable"
	        if(form->curValue
	           then	lgswritelist(lgssyslist "1" lgshotkey*11+6)
	        	lgssyslist=lgsjt	        
		   else
   	        	lgswritelist(lgssyslist "0" lgshotkey*11+6)
	        	lgssyslist=lgsjt	        
	          );end if
	         setformgidfilelist(lgssyslist "file_list")
	     t)
	     
	    ("ctrl_etch_x"
		if( lgsfigfilter(form->curValue 0)	    	
	    		then 
	    			lgs_ctrl_form_in_set(2)
	    		else
		 		axlFormSetField( form "ctrl_etch_x" "")  
		   );end if   
	     t)

	    ("ctrl_etch_y"
		if( lgsfigfilter(form->curValue 0)	    	
	    		then 
	    			lgs_ctrl_form_in_set(3)
	    		else
		 		axlFormSetField( form "ctrl_etch_y" "")  
		   );end if   
	     t)
	    ("ctrl_etch_x_offset"
		if( form->curValue!=nil	    	
	    		then 
	    			lgs_ctrl_form_in_set(4)
	    		else
		 		axlFormSetField( form "ctrl_etch_x_offset" "")  
		   );end if   
	     t)
	    ("ctrl_etch_y_offset"
		if( form->curValue!=nil	    	
	    		then 
	    			lgs_ctrl_form_in_set(5)
	    		else
		 		axlFormSetField( form "ctrl_etch_y_offset" "")  
		   );end if   
	     t)

	    ("getetchoff"
	    	lgs_getetchoff()
	        
	     t)

	    ("ctrl_nonetch_x"
		if( form->curValue!=nil	    	
	    		then 
	    			lgs_ctrl_form_in_set(7)
	    		else
		 		axlFormSetField( form "ctrl_nonetch_x" "")  
		   );end if   
	     t)

	    ("ctrl_nonetch_y"
		if( form->curValue!=nil	    	
	    		then 
	    			lgs_ctrl_form_in_set(8)
	    		else
		 		axlFormSetField( form "ctrl_nonetch_y" "")  
		   );end if   
	     t)

	    ("ctrl_nonetch_x_offset"
		if( form->curValue!=nil	    	
	    		then 
	    			lgs_ctrl_form_in_set(9)
	    		else
		 		axlFormSetField( form "ctrl_nonetch_x_offset" "")  
		   );end if   
	     t)

	    ("ctrl_nonetch_y_offset"
		if( form->curValue!=nil	    	
	    		then 
	    			lgs_ctrl_form_in_set(10)
	    		else
		 		axlFormSetField( form "ctrl_nonetch_y_offset" "")  
		   );end if   
	     t)

	    ("getnoetchoff"
	    	lgs_getnoetchoff()
	        
	     t)

	    ("ctrl_on"
	        if(form->curValue
	           then	lgswritelist(lgssyslist "0" lgshotkey*11+11)
	        	lgssyslist=lgsjt	        
		        setformgidfilelist(lgssyslist "file_list") 
		    else return( t)
	          );end if

	     t)

	    ("ctrl_off"
	        if(form->curValue
	           then	lgswritelist(lgssyslist "1" lgshotkey*11+11)
	        	lgssyslist=lgsjt	        
		        setformgidfilelist(lgssyslist "file_list") 
		    else return( t)		          
	          );end if
	     t)

	    ("ctrl_nochange"
	        if(form->curValue
	           then	lgswritelist(lgssyslist "2" lgshotkey*11+11)
	        	lgssyslist=lgsjt	        
		        setformgidfilelist(lgssyslist "file_list") 
		    else return( t)		          
	          );end if
	     t)

	    ("file_list"
		lgshotkey=form->curValueInt/2
		_lgs_setfrom()
	     t)
     
	    ("apply"
		lgswritelogfile(lgsgridlogfile)
		lgswritescrfile()
	     t)
	    ("ok"
		lgswritelogfile(lgsgridlogfile)
		lgswritescrfile()
		axlFormClose( form)
		deleteFile( lgsgridfileform)
	     t)
	     
            ("cancel"
            	axlFormClose( form)
            	deleteFile( lgsgridfileform)
            nil)
            ("displayonline"
		lgsdisplayonline=form->curValueInt
            t)

            ("logfilelist"
		lgslogfilelist()
            t)

            ("savelog"
		lgswritegidfile()
		_lgs_setfromtab2()
            t)

            ("loadlog"
		if(length(lgssyslistfile)==66
			then
			;axlMsgPut("test done")	
			lgssyslist=lgssyslistfile
			_lgs_setfrom()
			setformgidfilelist(lgssyslist "file_list")
			);end if
            t)
 
            ("savetofile"
		typesavefile=form->curValue
            t)
            ("update"
 		_lgs_setfromtab2()
  	    t)

	);end case

	
	if((lgsdisplayonline==1)&&(lgstab=="Setup_Grid_System")
	then
        	lgswritelogfile(lgsgridlogfile)
		lgswritescrfile()

	    	case(lgshotkey
	    		(0
	    			axlShell("replay lgsgridsystem1.lgc")
	    		t)
	    		(1
	    			axlShell("replay lgsgridsystem2.lgc")
	    		t)
	    		(2
	    			axlShell("replay lgsgridsystem3.lgc")
	    		t)
	    		(3
	    			axlShell("replay lgsgridsystem4.lgc")
	    		t)
	    		(4
	    			axlShell("replay lgsgridsystem5.lgc")
	    		t)
	    		(5
	    			axlShell("replay lgsgridsystem6.lgc")
	    		t)
	    	
	    	);end case
  	);end if	    
));end 	_lgs_repCallback ()
;===========================================================================================================================
(defun lgs_check_key ()
	case(form->curValue
		("Ctrl+1" lgshotkey=0 t)	
		("Ctrl+2" lgshotkey=1 t)	
		("Ctrl+3" lgshotkey=2 t)	
		("Ctrl+4" lgshotkey=3 t)	
		("Ctrl+5" lgshotkey=4 t)	
		("Ctrl+6" lgshotkey=5 t)
	     );end case
	_lgs_setfrom()
);end lgs_check_key ()   

;===========================================================================================================================
(defun  lgs_check_grid ()

	if(form->curValueInt != 0
	then 
	       lgswritelist(lgssyslist form->curValue lgshotkey*11+2)
	       lgssyslist=lgsjt
	       lgswritelist(lgssyslist form->curValue lgshotkey*11+3)
	       lgssyslist=lgsjt
	       _lgs_setfrom()
	       setformgidfilelist(lgssyslist "file_list")
	   );end if  
	   
	axlFormSetField( form "check_grid" " ")  
	
);end defun lgs_check_grid ()

;===========================================================================================================================
(defun lgs_getetchoff ()
	if(form->curValueInt==1
	then    axlSetFindFilter(?enabled `("NOALL" "VIAS") ?onButtons `("VIAS"))
 		axlMsgPut("Please Pick a Via")
	else	axlSetFindFilter(?enabled `("NOALL" "PINS") ?onButtons `("PINS"))
		axlMsgPut("Please Pick a Pin")
	);end if 
                axlClearSelSet()
                axlAddSelectPoint(nil)
                if(axlGetSelSet()!=nil
                then 
                	sprintf(lgstemp "%1.2f" car(car(lgsoffsetxy=axlGetSelSet()~>xy)))
                	lgswritelist(lgssyslist lgstemp lgshotkey*11+4)
                	lgssyslist=lgsjt
                	;axlFormSetField( form "ctrl_etch_x_offset" lgstemp)
                	sprintf(lgstemp "%1.2f" nthelem( 2 car(lgsoffsetxy=axlGetSelSet()~>xy)))
                	lgswritelist(lgssyslist lgstemp lgshotkey*11+5)
                	lgssyslist=lgsjt
                	;axlFormSetField( form "ctrl_etch_y_offset" lgstemp)
                	axlMsgPut("Done")
                	_lgs_setfrom()
                	setformgidfilelist(lgssyslist "file_list")
                	axlClearSelSet()
                 );end if
                 
);end lgs_getetchoff()

;===========================================================================================================================
(defun lgs_getnoetchoff ()
	if(form->curValueInt==1
	then    axlSetFindFilter(?enabled `("NOALL" "VIAS") ?onButtons `("VIAS"))
 		axlMsgPut("Please Pick a Via")
	else	axlSetFindFilter(?enabled `("NOALL" "PINS") ?onButtons `("PINS"))
		axlMsgPut("Please Pick a Pin")
	);end if 
                axlClearSelSet()
                axlAddSelectPoint(nil)
                if(axlGetSelSet()!=nil
                then 
                	sprintf(lgstemp "%1.2f" car(car(lgsoffsetxy=axlGetSelSet()~>xy)))
                	lgswritelist(lgssyslist lgstemp lgshotkey*11+9)
                	lgssyslist=lgsjt
                	;axlFormSetField( form "ctrl_nonetch_x_offset" lgstemp)
                	sprintf(lgstemp "%1.2f" nthelem( 2 car(lgsoffsetxy=axlGetSelSet()~>xy)))
                	;axlFormSetField( form "ctrl_nonetch_y_offset" lgstemp)
                	lgswritelist(lgssyslist lgstemp lgshotkey*11+10)
                	lgssyslist=lgsjt
                	_lgs_setfrom()
                	setformgidfilelist(lgssyslist "file_list")
                	axlMsgPut("Done")
                	axlClearSelSet()
                 );end if
);end lgs_getnoetchoff()


;===========================================================================================================================
(defun 	lgs_ctrl_form_in_set (i)
	if((i!=2)&&(i!=3)
	then
		lgstemp1=nil
		sprintf(lgstemp1 "%1.2f" form->curValue)
	else
		lgstemp1=form->curValue
	  );end if
	lgswritelist(lgssyslist lgstemp1 lgshotkey*11+i)
       	lgssyslist=lgsjt
       	_lgs_setfrom()
       	setformgidfilelist(lgssyslist "file_list")
);end defun lgs_ctrl_form_in_set (i)	    
;===========================================================================================================================
 (defun lgslogfilelist () 
	selectedFile= form->curValue
	if(lgscheckgidfile(selectedFile)==t
	then
		setformgidfilelist(lgssyslistfile "file_list2")
		axlFormSetField( form "loadfromfile" car(parseString(selectedFile ".")))
		axlFormSetField( form "savetofile" car(parseString(selectedFile ".")))
  	);end if
 );end (defun lgslogfilelist ()
   	
;===========================================================================================================================
(defun lgscheckgidfile (selectedFile) 
prog(() 
	lgstemp=infile(selectedFile)
	lgssyslistfiletemp=nil
	if(lgstemp!=nil
	then 
		for(i 1 70   
		lgssyslistfiletemp=cons(car(parseString(gets(line lgstemp) "\n")) lgssyslistfiletemp)
	  	);end for
		lgssyslistfiletemp=reverse(lgssyslistfiletemp)
		i=nthelem(1 lgssyslistfiletemp)=="#GIRD SYSTEM FILE"
		i=i&&(nthelem(2 lgssyslistfiletemp)=="#WRITE BY GIRDY SYSTEM V1.0")
		i=i&&(nthelem(3 lgssyslistfiletemp)=="#HUAWEI LIGUANGSHENG 24445")
		i=i&&(nthelem(70 lgssyslistfiletemp)=="#END SYSTEM FILE")
		if(i==t
		then
			lgssyslistfile=nil
			for(i 4 69
				lgssyslistfile=cons(nthelem(i lgssyslistfiletemp) lgssyslistfile)
		 	   );end for
			lgssyslistfile=reverse(lgssyslistfile)
			return(t)
		else return(nil)
	 	);end if
 	);end if
));end  defun lgscheckgidfile (selectedFile) 	
;===========================================================================================================================
(defun lgsfigfilter (temp lgs_i)
prog(()
	l=0
	if(strlen( temp)==0 then return(nil))
	for(i 1 strlen( temp)
		k=nil
		j=substring(temp i 1)
		if(j=="0" then k=t)
		if(j=="1" then k=t)
		if(j=="2" then k=t)
		if(j=="3" then k=t)
		if(j=="4" then k=t)
		if(j=="5" then k=t)
		if(j=="6" then k=t)
		if(j=="7" then k=t)
		if(j=="8" then k=t)
		if(j=="9" then k=t)
		if(j=="." 
		   then l++
		   	if(i==1 then return( nil))
		   	if(lgsnumberfilter(substring(temp i-1 1))&&lgsnumberfilter(substring(temp i+1 1))
		 	   then 
		 	   	k=t
		 	   else 
		 	   	return( nil)
		 	    );end if
		  );end if
		if((j==" ")&&(lgs_i==0) then l=0 k=t)
		if(l>1  then return( nil))
		if(k!=t then return( nil))
		);end for
	return(t)
));end lgsfigfilter (temp)
;===========================================================================================================================
(defun lgsnumberfilter (temp)
prog(()
	if(temp=="0" then return( t))
	if(temp=="1" then return( t))
	if(temp=="2" then return( t))
	if(temp=="3" then return( t))
	if(temp=="4" then return( t))
	if(temp=="5" then return( t))
	if(temp=="6" then return( t))
	if(temp=="7" then return( t))
	if(temp=="8" then return( t))
	if(temp=="9" then return( t))
	return( nil)
));end

;===========================================================================================================================
(defun lgswritelist (list listmember i)
	j=0
	lgstemp=nil
	foreach(temp list
		j++
		if(j==i then lgstemp=cons(listmember lgstemp)
		        else lgstemp=cons(temp lgstemp)
		  );end if
	);end for
	_lgsconverse(lgstemp)
);end lgswritelist (list i)

;===========================================================================================================================
(defun _lgscreat_syslist ()
	for(i 1 11
	lgssyslist=cons(car(parseString(gets(line lgs_logfile) "\n")) lgssyslist)
	   );end for
);end _lgscreat_syslist

;===========================================================================================================================
(defun _lgsconverse (lgslist)
	lgsjt=nil
	foreach(temp lgslist
	lgsjt=cons(temp lgsjt)
	    )
)

;=============this is the default grid system===============================================================================
;===========================================================================================================================
(defun lgscreatlogfile ()
	lgssyslist=list("1" "1 1 1 1 1" "1 1 1 1 1" "0" "0" "1" "25" "25" "0" "0" "0" 
			"1" "5 5 5 5 5" "5 5 5 5 5" "0" "0" "1" "25" "25" "0" "0" "0" 
			"1" "25 25" "25 25" "0" "0" "1" "25" "25" "0" "0" "0" 
			"1" "50 50" "50 50" "0" "0" "1" "25" "25" "0" "0" "0" 
			"1" "100 100 100 100 100" "100 100 100 100 100" "0" "0" "1" "50" "50" "0" "0" "0" 
			"1" "19.69 19.69" "19.69 19.69" "0" "0" "1" "100" "100" "0" "0" "0")
)
;===========================================================================================================================
(defun _lgs_setfrom ()
   case( lgshotkey
        (0
         axlFormSetField( form "check_key" "Ctrl+1")
         t)
        (1
         axlFormSetField( form "check_key" "Ctrl+2")
         t)
        (2
         axlFormSetField( form "check_key" "Ctrl+3")
         t)
        (3
         axlFormSetField( form "check_key" "Ctrl+4")
         t)
        (4
         axlFormSetField( form "check_key" "Ctrl+5")
         t)
        (5
         axlFormSetField( form "check_key" "Ctrl+6")
         t)
        );end case
	axlFormSetField( form "ctrl_etch_enable" (nthelem(lgshotkey*11+1 lgssyslist)=="1"))  
	axlFormSetField( form "ctrl_etch_x" nthelem(lgshotkey*11+2 lgssyslist)) 
	axlFormSetField( form "ctrl_etch_y" nthelem(lgshotkey*11+3 lgssyslist))
	axlFormSetField( form "ctrl_etch_x_offset" nthelem(lgshotkey*11+4 lgssyslist))
	axlFormSetField( form "ctrl_etch_y_offset" nthelem(lgshotkey*11+5 lgssyslist))
	axlFormSetField( form "ctrl_nonetch_enable" (nthelem(lgshotkey*11+6 lgssyslist)=="1"))  
	axlFormSetField( form "ctrl_nonetch_x" nthelem(lgshotkey*11+7 lgssyslist)) 
	axlFormSetField( form "ctrl_nonetch_y" nthelem(lgshotkey*11+8 lgssyslist))
	axlFormSetField( form "ctrl_nonetch_x_offset" nthelem(lgshotkey*11+9 lgssyslist))
	axlFormSetField( form "ctrl_nonetch_y_offset" nthelem(lgshotkey*11+10 lgssyslist))

   case( nthelem(lgshotkey*11+11 lgssyslist)
   
    	("0"
    	axlFormSetField( form "ctrl_on" 1)
    	t)
    	
    	("1"
    	axlFormSetField( form "ctrl_off" 1)
  	t)
  	
    	("2"
    	axlFormSetField( form "ctrl_nochange" 1)
    	t)
    	
    	);end case
 
);end _lgs_setfrom ()
           
;===========================================================================================================================
(defun _lgs_setfromtab2 ()
	lgsworkdir=getWorkingDir( )
	fileList = setof(x getDirFiles(  lgsworkdir) rexMatchp( "[a-z]*.gid" x))
	axlFormListDeleteAll(form "logfilelist")
	foreach( fileName fileList (axlFormSetField form "logfilelist" fileName))
	axlFormSetField( form "logfilelist" nil)
	axlFormSetField( form "filedir" lgsworkdir)
);end defun _lgs_setfromtab2 ()

;===========================================================================================================================
(defun _lgs_Build_gridsystem_Form ()
        deleteFile( lgsgridfileform)
        FORMFILE = outfile( lgsgridfileform)
        fprintf( FORMFILE "#GIRD SYSTEM FROM FILE\n")
        fprintf( FORMFILE "#WRITE BY LIGUANGSHENG HUAWEI 24445\n")
        fprintf( FORMFILE "FILE_TYPE=FORM_DEFN VERSION=2\n")
        fprintf( FORMFILE "FORM\n")
        fprintf( FORMFILE "FIXED\n")
        fprintf( FORMFILE "PORT 86 70\n")
        fprintf( FORMFILE "HEADER \"GIRD SYSTEM  V1.0\"\n")
        fprintf( FORMFILE "TILE\n")
        fprintf( FORMFILE "TABSET \"tab\"\n")
        fprintf( FORMFILE "OPTIONS tabsetDispatch\n")
        fprintf( FORMFILE "FLOC 2 1\n")
        fprintf( FORMFILE "FSIZE 83 47\n")
        fprintf( FORMFILE "TAB \"Setup Grid System\"\n")
        fprintf( FORMFILE "GROUP \"\"\n")
        fprintf( FORMFILE "FLOC 2 1\n")
        fprintf( FORMFILE "FSIZE 78 21\n")
        fprintf( FORMFILE "INFO group\n")
        fprintf( FORMFILE "ENDGROUP\n")
        fprintf( FORMFILE "TEXT \"Select HotKey\"\n")
        fprintf( FORMFILE "TLOC 6 1\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "TEXT \"Select Grid System\"\n")
        fprintf( FORMFILE "TLOC 30 1\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "FIELD ctrl_on\n")
        fprintf( FORMFILE "FLOC 53 3\n")
        fprintf( FORMFILE "FGROUP \"c1check\"\n")
        fprintf( FORMFILE "CHECKLIST \"ON\" \"c1check\"\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD ctrl_off\n")
        fprintf( FORMFILE "FLOC 60 3\n")
        fprintf( FORMFILE "FGROUP \"c1check\"\n")
        fprintf( FORMFILE "CHECKLIST \"OFF\" \"c1check\"\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD ctrl_nochange\n")
        fprintf( FORMFILE "FLOC 67 3\n")
        fprintf( FORMFILE "FGROUP \"c1check\"\n")
        fprintf( FORMFILE "CHECKLIST \"NO CHANGE\" \"c1check\"\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "POPUP <BUTPOP>\"From Vias\"\"1\",\"From Pins\"\"2\".\n")
        fprintf( FORMFILE "POPUP <key_Names>\"Ctrl+1\" \"Ctrl+1\",\"Ctrl+2\" \"Ctrl+2\",\"Ctrl+3\" \"Ctrl+3\",
        				    \"Ctrl+4\" \"Ctrl+4\",\"Ctrl+5\" \"Ctrl+5\",\"Ctrl+6\" \"Ctrl+6\".\n")
        fprintf( FORMFILE "FIELD check_key\n")
        fprintf( FORMFILE "FLOC 6 3\n")
        fprintf( FORMFILE "ENUMSET 11\n")
        fprintf( FORMFILE "POP \"key_Names\"\n")
        fprintf( FORMFILE "ENDFIELD\n")
        
;===========this field is the grid example==================================================================================
        fprintf( FORMFILE "POPUP <grid_sel>\" \" \" \",\"1 1 1 1 1\" \"1 1 1 1 1\",\"5 5 5 5 5\" \"5 5 5 5 5\",
        				   \"12.5 12.5 12.5 12.5\" \"12.5 12.5 12.5 12.5\",
        				   \"25 25\" \"25 25\",\"50 50\" \"50 50\",
        				   \"100 100 100 100 100\" \"100 100 100 100 100\",\"39.37\" \"39.37\",
        				   \"19.69 19.69\" \"19.69 19.69\",\"31.50\" \"31.50\",
        				   \"15.75 15.75\" \"15.75 15.75\",
        				   \"20 5 5 20\" \"20 5 5 20\",
        				   \"21 5 5 13 5 5 21\" \"21 5 5 13 5 5 21\",
        				   \"33.37 6 6 33.37\" \"33.37 6 6 33.37\".\n")

;===========================================================================================================================
        fprintf( FORMFILE "FIELD check_grid\n")
        fprintf( FORMFILE "FLOC 30 3\n")
        fprintf( FORMFILE "ENUMSET 17\n")
        fprintf( FORMFILE "POP \"grid_sel\"\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "TEXT \"All Etch Grid\"\n")
        fprintf( FORMFILE "TLOC 6 7\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "FIELD ctrl_etch_enable\n")
        fprintf( FORMFILE "FLOC 18 7\n")
        fprintf( FORMFILE "CHECKLIST \"Enable\"\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "TEXT \"x:\"\n")
        fprintf( FORMFILE "TLOC 28 7\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "TEXT \"y:\"\n")
        fprintf( FORMFILE "TLOC 28 9\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "FIELD ctrl_etch_x\n")
        fprintf( FORMFILE "FLOC 30 7\n")
        fprintf( FORMFILE "STRFILLIN 18 80\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD ctrl_etch_y\n")
        fprintf( FORMFILE "FLOC 30 9\n")
        fprintf( FORMFILE "STRFILLIN 18 80\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "TEXT \"offset:\"\n")
        fprintf( FORMFILE "TLOC 51 7\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "TEXT \"offset:\"\n")
        fprintf( FORMFILE "TLOC 51 9\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "TEXT \"Non_Etch Grid\"\n")
        fprintf( FORMFILE "TLOC 6 12\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "FIELD ctrl_nonetch_enable\n")
        fprintf( FORMFILE "FLOC 18 12\n")
        fprintf( FORMFILE "CHECKLIST \"Enable\"\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "TEXT \"x:\"\n")
        fprintf( FORMFILE "TLOC 28 12\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "TEXT \"y:\"\n")
        fprintf( FORMFILE "TLOC 28 14\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "TEXT \"offset:\"\n")
        fprintf( FORMFILE "TLOC 51 12\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "TEXT \"offset:\"\n")
        fprintf( FORMFILE "TLOC 51 14\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "FIELD ctrl_etch_x_offset\n")
        fprintf( FORMFILE "FLOC 56 7\n")
        fprintf( FORMFILE "REALFILLIN 9 9\n")
        fprintf( FORMFILE "REALMIN 0\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD ctrl_etch_y_offset\n")
        fprintf( FORMFILE "FLOC 56 9\n")
        fprintf( FORMFILE "REALFILLIN 9 9\n")
        fprintf( FORMFILE "REALMIN 0\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD ctrl_nonetch_x\n")
        fprintf( FORMFILE "FLOC 30 12\n")
        fprintf( FORMFILE "REALFILLIN 9 9\n")
        fprintf( FORMFILE "REALMIN 0\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD ctrl_nonetch_y\n")
        fprintf( FORMFILE "FLOC 30 14\n")
        fprintf( FORMFILE "REALFILLIN 9 9\n")
        fprintf( FORMFILE "REALMIN 0\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD ctrl_nonetch_x_offset\n")
        fprintf( FORMFILE "FLOC 56 12\n")
        fprintf( FORMFILE "REALFILLIN 9 9\n")
        fprintf( FORMFILE "REALMIN 0\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD ctrl_nonetch_y_offset\n")
        fprintf( FORMFILE "FLOC 56 14\n")
        fprintf( FORMFILE "REALFILLIN 9 9\n")
        fprintf( FORMFILE "REALMIN 0\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "TEXT \"Type HotKey_Grid System:\"\n")
        fprintf( FORMFILE "TLOC 5 23\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "FIELD displayonline\n")
        fprintf( FORMFILE "FLOC 18 19\n")
        fprintf( FORMFILE "CHECKLIST \"Display Online (Warning:If selected all change will not be cancel)\"\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD file_list\n")
        fprintf( FORMFILE "FLOC 2 25\n")
        fprintf( FORMFILE "LIST \"\" 78 10\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "FIELD getetchoff\n")
        fprintf( FORMFILE "FLOC 69 9\n")
        fprintf( FORMFILE "MENUBUTTON \"Get\" 6 3\n")
        fprintf( FORMFILE "POP \"BUTPOP\"\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "FIELD getnoetchoff\n")
        fprintf( FORMFILE "FLOC 69 14\n")
        fprintf( FORMFILE "MENUBUTTON \"Get\" 6 3\n")
        fprintf( FORMFILE "POP \"BUTPOP\"\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "ENDTAB\n")
        fprintf( FORMFILE "TAB \"Load Grid From File\"\n")
        fprintf( FORMFILE "GROUP \"Save Grid to File or Load Grid from File\"\n")
        fprintf( FORMFILE "FLOC 2 1\n")
        fprintf( FORMFILE "FSIZE 78 21\n")
        fprintf( FORMFILE "INFO group\n")
        fprintf( FORMFILE "ENDGROUP\n")
        fprintf( FORMFILE "TEXT \"Grid File List:\"\n")
        fprintf( FORMFILE "TLOC 10 4\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "TEXT \"Type HotKey_Grid System:\"\n")
        fprintf( FORMFILE "TLOC 5 23\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "FIELD logfilelist\n")
        fprintf( FORMFILE "FLOC 7 6\n")
        fprintf( FORMFILE "LIST \"\" 35 8\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD savetofile\n")
        fprintf( FORMFILE "FLOC 48 8\n")
        fprintf( FORMFILE "STRFILLIN 15 25\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD loadfromfile\n")
        fprintf( FORMFILE "FLOC 48 13\n")
        fprintf( FORMFILE "STRFILLIN 15 25\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD filedir\n")
        fprintf( FORMFILE "FLOC 48 18\n")
        fprintf( FORMFILE "STRFILLIN 15 25\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "TEXT \"Save Grid to Flie:\"\n")
        fprintf( FORMFILE "TLOC 49 6\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "TEXT \"Load Grid to File:\"\n")
        fprintf( FORMFILE "TLOC 49 11\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "TEXT \"Update Grid List:\"\n")
        fprintf( FORMFILE "TLOC 49 16\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "FIELD savelog\n")
        fprintf( FORMFILE "FLOC 68 8\n")
        fprintf( FORMFILE "MENUBUTTON \"Save\" 9 3\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD loadlog\n")
        fprintf( FORMFILE "FLOC 68 13\n")
        fprintf( FORMFILE "MENUBUTTON \"Load\" 9 3\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD update\n")
        fprintf( FORMFILE "FLOC 68 18\n")
        fprintf( FORMFILE "MENUBUTTON \"Update\" 9 3\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD file_list2\n")
        fprintf( FORMFILE "FLOC 2 25\n")
        fprintf( FORMFILE "LIST \"\" 78 10\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "ENDTAB\n")
        fprintf( FORMFILE "FIELD ok\n")
        fprintf( FORMFILE "FLOC 7 49\n")
        fprintf( FORMFILE "MENUBUTTON \"OK\" 12 4\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD cancel\n")
        fprintf( FORMFILE "FLOC 27 49\n")
        fprintf( FORMFILE "MENUBUTTON \"Cancel\" 12 4\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD apply\n")
        fprintf( FORMFILE "FLOC 47 49\n")
        fprintf( FORMFILE "MENUBUTTON \"Apply\" 12 4\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "FIELD help\n")
        fprintf( FORMFILE "FLOC 67 49\n")
        fprintf( FORMFILE "MENUBUTTON \"Help\" 12 4\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "ENDTABSET\n")
        fprintf( FORMFILE "ENDTILE\n")
        fprintf( FORMFILE "ENDFORM\n")
        close( FORMFILE)
        form = (axlFormCreate (gensym) lgsgridfileform `("E" "OUTER") `_lgs_repCallback t)
        axlFormDisplay( form)
);end defun _lgs_Build_gridsystem_Form ()

;===========================================================================================================================
(defun lgswritelogfile (filename)
        outlogfile = outfile( filename)
	for(j 1 6
        	fprintf( outlogfile "ctrl%d\n" j)
    		for(i 1 11 
        		fprintf( outlogfile "%s\n" nthelem((j-1)*11+i lgssyslist))
        	);end for
    	);end for
        close(outlogfile)
);end defun lgswritelogfile (filename)

;===========================================================================================================================
(defun lgswritescrfile ()
	for(i 0 5
		case(i
			(0
				outscrfile=outfile("lgsgridsystem1.lgc")	t)
			(1
				outscrfile=outfile("lgsgridsystem2.lgc")	t)
			(2
				outscrfile=outfile("lgsgridsystem3.lgc")	t)
			(3
				outscrfile=outfile("lgsgridsystem4.lgc")	t)
			(4
				outscrfile=outfile("lgsgridsystem5.lgc")	t)
			(5
				outscrfile=outfile("lgsgridsystem6.lgc")	t)
		     );end case
		     
		fprintf( outscrfile "#Write by liguangsheng grid system\n\n")	
		fprintf( outscrfile "version 14.1\n\n")	     
		fprintf( outscrfile "setwindow pcb\n")
		fprintf( outscrfile "trapsize 15382\n")
		fprintf( outscrfile "define grid\n")	     	
		fprintf( outscrfile "setwindow form.grid\n")
		
		if(nthelem(11*i+1 lgssyslist)=="1"
		then 
			fprintf( outscrfile "FORM grid all_etch all_etch_x_grids %s\n" nthelem(11*i+2 lgssyslist)) 
			fprintf( outscrfile "FORM grid all_etch all_etch_y_grids %s\n" nthelem(11*i+3 lgssyslist)) 
			fprintf( outscrfile "FORM grid all_etch all_etch_x_offset %s\n" nthelem(11*i+4 lgssyslist)) 
			fprintf( outscrfile "FORM grid all_etch all_etch_y_offset %s\n" nthelem(11*i+5 lgssyslist)) 
		  );end if
		
		if(nthelem(11*i+6 lgssyslist)=="1"
		then 
			fprintf( outscrfile "FORM grid non_etch non_etch_x_grids %s\n" nthelem(11*i+7 lgssyslist)) 
			fprintf( outscrfile "FORM grid non_etch non_etch_y_grids %s\n" nthelem(11*i+8 lgssyslist)) 
			fprintf( outscrfile "FORM grid non_etch non_etch_x_offset %s\n" nthelem(11*i+9 lgssyslist)) 
			fprintf( outscrfile "FORM grid non_etch non_etch_y_offset %s\n" nthelem(11*i+10 lgssyslist)) 
		  );end if
		  
		if(nthelem(11*i+11 lgssyslist)=="0"
		then
			fprintf( outscrfile "FORM grid display YES\n")
			else if(nthelem(11*i+11 lgssyslist)=="1"
			then 
				fprintf( outscrfile "FORM grid display NO\n")
			);end else if
		   );end if	
		  
		fprintf( outscrfile "FORM grid done\n")
		fprintf( outscrfile "setwindow pcb\n")
		close(outscrfile)
	);end for
);end defun lgswritescrfile ()

;===========================================================================================================================
(defun lgswritegidfile ()
if(typesavefile!=nil
then
	lgsgidfile=outfile(strcat(typesavefile ".gid"))
	fprintf( lgsgidfile "#GIRD SYSTEM FILE\n")
	fprintf( lgsgidfile "#WRITE BY GIRDY SYSTEM V1.0\n")
	fprintf( lgsgidfile "#HUAWEI LIGUANGSHENG 24445\n")

	foreach(lgstemp lgssyslist
		fprintf( lgsgidfile "%s\n" lgstemp)
		);end foreach
	
	fprintf( lgsgidfile "#END SYSTEM FILE\n")
	close(lgsgidfile)
);end if
);end defun lgswritegidfile ()

;===========================================================================================================================
(defun setformgidfilelist (templist filelistname)
	axlFormListDeleteAll(form filelistname)

	for(i 1 6
		if(nthelem(11*i-10 templist)=="1" 
		then 
			lgstempen="EN" 
		else 
			lgstempen="NO")
			
		sprintf(lgstimes "%d" i)
		axlFormSetField( form  filelistname strcat("Ctrl+" lgstimes ":  ETCH    " lgstempen "    X:" 
							nthelem(11*i-9 templist) "    X:" nthelem(11*i-8 templist)
							"    XOFF:" nthelem(11*i-7 templist) "    YOFF:" 
							nthelem(11*i-6 templist)))
		
		if(nthelem(11*i-5 templist)=="1" 
		then 
			lgstempen="EN" 
		else 
			lgstempen="NO")
		if(nthelem(11*i templist)=="0" 
		then 
			lgstimes="ON" 
			else if(nthelem(11*i templist)=="1" 
			then 
				lgstimes="OFF" 
			else 
				lgstimes="NO CHANGE"))
		axlFormSetField( form  filelistname strcat("           NOET    " lgstempen "    X:" nthelem(11*i-4 templist) 
							"    X:" nthelem(11*i-3 templist) "    XOFF:" nthelem(11*i-2 templist) 
							"    YOFF:" nthelem(11*i-1 templist) "       GIRD SHOW:   " lgstimes))
	);end for

	axlFormSetField( form  filelistname nil)
);end defun setformgidfilelist (templist

;===========================================================================================================================
;===========================================================================================================================
(defun _lgs_gridsystem_setenv ()
	lgs_path = nil
	lgs_envfile = infile("~/pcbenv/env")
	lgs_sw = t
	while(lgs_sw
		
		lgs_temp = gets(line lgs_envfile)
		if(lgs_temp == nil 
			then 	lgs_sw = nil)	;end if
		if(lgs_temp == "# THIS AREA WRITE BY LIGUANGSHENG GIRD SYSTEM\n"
			then	lgs_path = "ok")	;end if
		
		);end while
		
	close( lgs_envfile)
	
	if(lgs_path != "ok"
	then	
		lgstempfile = outfile("lgsbatfile")
		fprintf( lgstempfile "cd\n")
		fprintf( lgstempfile "cd pcbenv\n")
		fprintf( lgstempfile "echo \"#--------------------------------------------------------------------\" >> env\n")
	        fprintf( lgstempfile "echo \"# NEW STYLE FUNCTION KEY ALIASES\" >> env\n")
	        fprintf( lgstempfile "echo \"# THIS AREA WRITE BY LIGUANGSHENG GIRD SYSTEM\" >> env\n")
	        fprintf( lgstempfile "echo \"alias ~1 replay lgsgridsystem1.lgc\" >> env\n")
	        fprintf( lgstempfile "echo \"alias ~2 replay lgsgridsystem2.lgc\" >> env\n")
	        fprintf( lgstempfile "echo \"alias ~3 replay lgsgridsystem3.lgc\" >> env\n")
	        fprintf( lgstempfile "echo \"alias ~4 replay lgsgridsystem4.lgc\" >> env\n")
	        fprintf( lgstempfile "echo \"alias ~5 replay lgsgridsystem5.lgc\" >> env\n")
	        fprintf( lgstempfile "echo \"alias ~6 replay lgsgridsystem6.lgc\" >> env\n")
	        close( lgstempfile)
	        shell("chmod 777 lgsbatfile")
	        shell("lgsbatfile")
		axlMsgPut("env setup successfully!")
		axlMsgPut("please restart you allegro!")
		shell("rm lgsbatfile")
	else
		axlMsgPut("env file is already setup!")
		axlMsgPut("if you cant use hotkey please restart you allegro!")
	
	);end if
)   
    
;===========================================================================================================================
;===========================================================================================================================
    
    
    
    
    
    
    
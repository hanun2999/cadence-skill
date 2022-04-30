;              	Change Wave Crest Symbols Reference Designators
;	      	-----------------------------------------------

; load("jkchange_wave_sym.il")
;File name:"jkchange_wave_sym.il"
;Revision:3.1	
;date:05/14/2002
;Writen by: JIAKE/15924
;
;This routine changes the wave crest symbols on PCB bottom . You can type the command: 
;"change wave symbol" at the command line . If the routine runs correctly , you will
;look a prompt: "Input file "change.tel" , then click button "Import"" . Do that,and 
;you will find out the wave crest symbols on bottom are changed . The changeable symbols 
;are following as:
;    1.SC series:
;	SC0603 SC0805 SC2225 SC2220 SC1825 SC1812 SC1808 SC1210 SC1206 
;    2.SR series:
;	SR3218 SR2512 SR2010 SR1210 SR1206 SR0805 SR0603 
;    3.SOP series:
;	SOT89 SOT23 SOT223 SOT143   
;    4.STC series:
;	STC7343 STC6032 STC3528 STC3216 
;    5.SOP series:
;	SOP28-50-400 SOP8-50-208 SOP8-50-173 SOP8-50-150 SOP32-50-400 SOP28-50-350
;	SOP28-50-300 SOP24-50-208 SOP20-50-300 SOP20-50-208 SOP18-50-300 SOP16-50-300
;	SOP16-50-208 SOP16-50-150 SOP14-50-208 SOP14-50-173 SOP14-50-150


;Modify:
;	1. 2002/10/24:    Change the "B" package into "W" package. This routine will 
;read the package list from a file "CrestWavePackage.lst" saved in anyone directory 
;of PSMPATH. 

;	HAVE ANY PROBLEM PLEASE CONTACT ME !
;		ADD: 	#1602
;		TEL:	3492
;		LOTUS:	15924
;========================================================================================
;			Main function: Create netin file
;========================================================================================

axlCmdRegister("ch_wave_sym" '_jkMain ?cmdType "general")
axlCmdRegister("restore_refdes" '_jkRestore ?cmdType "general")

(defun _jkMain ()
prog(()	
	restore = nil
	property = nil
	_jkGetNetlistForm()
))

(defun _jkRestore ()
prog(()	
	restore = t
	property = nil
	_jkGetNetlistForm()
))


defun( getCrestWavePackageFilename ()
let( ( tfile item dirs fileName lstFile)
	fileName = "CrestWavePackage.lst"
	lstFile = nil
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;direct to "PSMPATH"
;dirs = parseString(axlGetVariable("PSMPATH"))     ;shielded  by lijinjun

;;;;;direct to allegro14.1/14.2/share/pcb/etc/skill/newdata ;
;;;;;Add by lijinjun
dirs = parseString(sprintf( dirs_path "%s/etc/skill/newdata" axlGetVariable("allegro_install_dir")))
                        

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;get the file direction and name and save it in lstFile.
	foreach( item dirs 		;i=-1 i++ item=nth(i dirs)
		tfile = strcat( item "/" fileName )
		if(isFile( tfile )
			lstFile = tfile
		)
	)
	lstFile
))


defun( getCrestWavePackageList ( )
let( ( syms line inf item x packages lstFile)

	lstFile = getCrestWavePackageFilename()

	inf = infile( lstFile )
	packages = nil
	if(inf != nil 
	then 
		while( gets( line inf )
			item = car( parseString( line ) )
			packages = cons( upperCase(item) packages )
		)
	else
		axlMsgPut("Can't open list file \"CrestWavePackage.lst\" !" )
	)
	packages 
))

; ====================== Change the wave crest packages ==================================
(defun _jkChangeWaveSym (netlist)
prog(()	
let( (Bsym )
/*	Bsym = list("SC0402" "SC0603" "SC0805" "SC2225" "SC2220" "SC1825" "SC1812" "SC1808" "SC1210" "SC1206" 
	"SR3218" "SR2512" "SR2010" "SR1210" "SR1206" "SR0805" "SR0603" "SR0402" "SOT89" "SOT23" "SOT223" "SOT143"  
	"STC7343" "STC6032" "STC3528" "STC3216" "SOP28-50-400" "SOP8-50-208" "SOP8-50-173" "SOP8-50-150" 
	"SOP32-50-400" "SOP28-50-350" "SOP28-50-300" "SOP24-50-208" "SOP20-50-300" "SOP20-50-208" 
	"SOP18-50-300" "SOP16-50-300" "SOP16-50-208" "SOP16-50-150" "SOP14-50-208" "SOP14-50-173" "SOP14-50-150"
	)
*/		
	Bsym = getCrestWavePackageList()
	segment = nil
	inf = infile(netlist) 
	outf = outfile("change.tel")
	if(inf == nil return())
	
	pLine = nil
	pack = nil
	refL = nil
	refs = nil
	PACKfirst = 0
	alltext = nil
	
	allsyms = axlDBGetDesign()->symbols 

	while(gets(line inf) != nil
		case(substring(line 1 1)
		("$"
			segment = substring(line 2 4)
			;if(segment=="PACK" then )
			PACKfirst++
			if(PACKfirst == 2 then 
				_jkWritePackages( outf pack refs) 
			)
			fprintf(outf "%s" line)
			axlMsgPut("Processing %s ..." substring(line 2 16))							
			t
		)
		("("
			fprintf(outf "%s" line)			
			t
		)
		(t
			if(PACKfirst != 1 || segment != "PACK" 
			then
				fprintf(outf "%s" line)
			else		
				if(substring(line 1 1) != " " && substring(line 1 1) != "\n"
				then	;SC0603 ! C ! 1000P ; C85 C86 C87 C88 C89 ,
					_jkWritePackages( outf pack refs)			
					
					if(stringp(line) then
						pLine = parseString(line ";")						
						pack = parseString(nthelem(1 pLine) "!")
						if(nthelem(2 pLine) != nil then
							refs = parseString(car(parseString(nthelem(2 pLine) ",")))
						)
					)
				else	;	C85 C86 C87 C88 C89 ,
					refL = nil
					if(stringp(line) then
						refL = parseString(car(parseString(line ",")))
					)
					foreach(item refL refs = cons(item refs))
				);End-if(substring(line 1 1)					
			);End-if(segment == "PACK" 			
		)
		);End - case		
	);End-while
	close(inf)
	close(outf)

)));end-defun

; ================== Write changed netlist ==========================
(defun _jkWritePackages ( outf pack refs)
	if(stringp(nthelem(1 pack)) 
	then 	
		package = car(parseString(nthelem(1 pack)))
		
		if(exists( x Bsym (x == package)) !=nil 
		then ;package in Bsym?		
			packG = pack
			sprintf(packb1 "W%s" nthelem(1 pack))			
			sprintf(packb2 " W%s" nthelem(1 pack))	
			if(property == nil 
			then
				packB = cdr(cdr(pack))
				packB = cons(packb2 packB)
				packB = cons(packb1 packB)		
			else
				packB = cdr(pack)			
				packB = cons(packb1 packB)
			)					
			
			refsG = nil
			refsB = nil
			find = nil
			foreach(ref refs	;j=0 j++ ref =nthelem(j refs) ref
				foreach(sym allsyms ;i=0 i++ txt=nthelem(i alltext) txt~>??
					if(ref == sym->refdes && sym->isMirrored == t then find = t)
				)
				if(find == t 
				then 
					refsB = cons(ref refsB)
				else
					refsG = cons(ref refsG)
				)
				find = nil
			)
			if(packG != nil && refsG != nil then
				_jkWriteOnePackage(outf packG refsG)
			)
			if(packB != nil && refsB != nil then
				_jkWriteOnePackage(outf packB refsB)
			)
		else
			_jkWriteOnePackage(outf pack refs)
		)
	)
);end-defun



; ================== Write changed netlist ==========================
(defun _jkWriteOnePackage ( outf pack refs)
	len = 0
	
	if(stringp(nthelem(1 pack)) then
		fprintf(outf "%s" nthelem(1 pack))
		len = strlen(nthelem(1 pack))
	)
	foreach(item cdr(pack)
		if(stringp(item) then
			fprintf(outf "!%s" item)
			len = len + strlen(item)+1
		)	
	)
	fprintf(outf " ; ")
	len = len + 3	
	
	foreach(item refs
		if(stringp(item) 
		then
			if(len>80 
			then
				fprintf(outf ",\n        ")
				len = 8
			)
			fprintf(outf "%s " item)			
			len = len+strlen(item)+1
		)
	)
	fprintf(outf "\n")
	
);end-defun

; =================== Get the refdeses of wave crest packages ========================
defun( getposition ()
prog( ()
	posfile = axlDMOpenLog("change.pos")
	
	fprintf(posfile "REF_DES      COORDIRATION       TOTATION  TEXTBLOCK\n")
	
	allsyms = axlDBGetDesign()->symbols
;	axlMsgPut("%d" length(allsyms))
	foreach(sym allsyms ; i=0 i++ sym=nthelem(i allsyms) sym~>??
		texts = axlDBGetAttachedText(sym)
		foreach(txt texts
			if(txt->objType == "text" &&
			(txt->layer   == "REF DES/SILKSCREEN_BOTTOM" ||
			txt->layer   == "REF DES/SILKSCREEN_TOP") then
				fprintf(posfile "%-8s %10.1f %10.1f %7.1f %8s \n" 
				txt->text car(txt->xy) car(cdr(txt->xy)) 
				txt->rotation txt->textBlock)
			)	
		)
	)
	axlDMClose(posfile)								
))

; ========================== Restore refdeses position ===============================
(defun RestoreRefdesPosition (@optional (logfile "change.pos") )
prog(()	
let( ()
	
	axlClearSelSet()
	inf = infile(logfile)	
	if(inf == nil then return())
	gets(line inf)
	
	allelement_dbid_list = nil
	allsyms = axlDBGetDesign()->symbols
	foreach(sym allsyms ; i=0 i++ sym=nthelem(i allsyms) sym~>??
		texts = axlDBGetAttachedText(sym)
		foreach(txt texts
			if(txt->layer == "REF DES/SILKSCREEN_BOTTOM" ||
			txt->layer == "REF DES/SILKSCREEN_TOP" then
				allelement_dbid_list = cons(txt allelement_dbid_list)
			)	
		)
	)
;	axlSetFindFilter( ?enabled '("noall" "text") ?onButtons '("noall" "text"))
;	allelement_dbid_list = axlGetSelSet( axlAddSelectAll() )
	
	element_dbid_list = nil	
	foreach(element_dbid allelement_dbid_list		
		if(element_dbid->objType == "text" &&
		(element_dbid->layer   == "REF DES/SILKSCREEN_BOTTOM" ||
		element_dbid->layer   == "REF DES/SILKSCREEN_TOP") then
			element_dbid_list = cons(element_dbid element_dbid_list)
		)
	)
	while(gets(line inf) != nil		
		sscanf(line "%s %f %f %f %s" text x y rotation textBlock)
		foreach(element_dbid element_dbid_list		;  element_dbid = nthelem( i element_dbid_list)->??			
			if(text == element_dbid->text then
;axlMsgPut("%s" text)
        			xy          = car(list(x:y))
			        parent_dbid = element_dbid->parent
			        isMirrored  = element_dbid->isMirrored    ; t/nil 
			        justify     = element_dbid->justify       ; "LEFT" "CENTER" "RIGHT"
				
 			       	orientation_text = make_axlTextOrientation(
                        	   	?textBlock textBlock,
	                                ?rotation  rotation,
        	                        ?mirrored  isMirrored,
                	                ?justify   justify 
                	        )
        			status= axlDBCreateText( 
                                	text                    
	                                xy
        	                        orientation_text 
                	                element_dbid->layer
                        	        parent_dbid                                
                                )
				if( status != nil axlDeleteObject( list( element_dbid )))
			);end-if
		);end-foreach
	);end-while
	close(inf)
	;axlClearSelSet()
)))

; ============ inport netlist file and change the wave crest packages ============
defun( definescr ()
prog( ()
	rpt = outfile("./input_net.scr")
;	fprintf(rpt "version 14.1 \n\n")
;	fprintf(rpt "trapsize 5 \n")
	fprintf(rpt "setwindow pcb\n")
;	fprintf(rpt "netin \n")
	fprintf(rpt "netin param \n")
	fprintf(rpt "setwindow form.niparams\n")
	fprintf(rpt "FORM niparams options \n")
	fprintf(rpt "FORM niparams place_always YES \n")
	fprintf(rpt "FORM niparams cmgr_enable NO \n")
	fprintf(rpt "FORM niparams syntax_check_only NO \n")
	fprintf(rpt "FORM niparams supercede YES \n")
	fprintf(rpt "FORM niparams append_device_log YES \n")
	fprintf(rpt "FORM niparams remove_etch NO \n")
	fprintf(rpt "FORM niparams logic_type  \n")
	fprintf(rpt "FORM niparams browse  \n")
	fprintf(rpt "fillin \"change.tel\" \n")
	fprintf(rpt "FORM niparams import\n")
	fprintf(rpt "setwindow pcb\n")
;	fprintf(rpt "done \n")
;	fprintf(rpt "trapsize 5\n")
	close(rpt)

))

; =================== Process User entries in popup menu ==========================
(defun jk_repCallback (form)
(prog ()
    case( form->curField
        ("netlist"            
	    axlMsgPut("Get refdes position ..." )
            getposition()
            
            if(stringp(selectedFile) == nil return(nil))
	    axlMsgPut("Change package ..." ) 	               
	    _jkChangeWaveSym(selectedFile)

	    axlMsgPut("Inport netlist ..." )            
	    definescr()
	    axlShell("replay input_net.scr")
	    shell("rm ./input_net.scr")
	    
     	    RestoreRefdesPosition("change.pos")
	    axlMsgPut("Down")	
            t)
            
	("restore"
	    axlMsgPut("Restore refdes ... " )	
     	    RestoreRefdesPosition(selectedFile)
	    axlMsgPut("Down")	
	    t)
	    
        ("down"
            axlFormClose( form)
            axlCancelEnterFun()
            deleteFile( jbhdelfileform)
            nil)
            
        ("view_file"
            axlFormSetField( form "view_file" form->curValue )
            selectedFile = form->curValue
            t)
            
        ("Property"
            property = form->curValue
            selectedFile = form->curValue
            t)
            
        ("file_list"
            axlFormSetField( form "view_file" form->curValue)
            selectedFile = form->curValue
            t)
    ); case
)); defun jk_repCallback

;=================== build up the form dynamically ==========================
(defun _jkBuildNetlistForm ()
        deleteFile( jbhdelfileform)
        FORMFILE = outfile( jbhdelfileform)
        fprintf( FORMFILE "FILE_TYPE=FORM_DEFN VERSION=2\n")
        fprintf( FORMFILE "FORM\n")
        fprintf( FORMFILE "FIXED\n")
        fprintf( FORMFILE "PORT 50 10\n")
        fprintf( FORMFILE "HEADER \"Browser\"\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "POPUP <PRINTP>\"to File\"\"0\",\"to Printer\"\"1\",\"to Script\"\"2\".\n")
        fprintf( FORMFILE "POPUP <DELFILE>\"Delete\"\"Delete\",\"Keep\"\"Keep\".\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "TILE\n")
        fprintf( FORMFILE "TEXT \"Select File to process\"\n")
        fprintf( FORMFILE "TLOC 12 1\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "TEXT \"File name:\"\n")
        fprintf( FORMFILE "TLOC 5 14\n")
        fprintf( FORMFILE "ENDTEXT\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "FIELD view_file\n")
        fprintf( FORMFILE "FLOC 12 14\n")
        fprintf( FORMFILE "STRFILLIN 26 26\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "FIELD file_list\n")
        fprintf( FORMFILE "FLOC 5 3\n")
        fprintf( FORMFILE "LIST \"\" 40 5\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "\n")

	if(restore == nil then    
	        fprintf( FORMFILE "FIELD Property\n")
	        fprintf( FORMFILE "FLOC  5 17\n")
	        fprintf( FORMFILE "CHECKLIST \"Inport PROPERTIES netlist\" \n")
        	fprintf( FORMFILE "ENDFIELD\n\n")
        
	        fprintf( FORMFILE "FIELD netlist\n")
	        fprintf( FORMFILE "FLOC 10 20\n")
	        fprintf( FORMFILE "MENUBUTTON \"Inport Netlist\" 9 3\n")
        	fprintf( FORMFILE "ENDFIELD\n")
   	     	fprintf( FORMFILE "\n")
        )
       
	if(restore == t then
	        fprintf( FORMFILE "FIELD restore\n")
	        fprintf( FORMFILE "FLOC 10 20\n")
	        fprintf( FORMFILE "MENUBUTTON \"Restore refdes\" 9 3\n")
	        fprintf( FORMFILE "ENDFIELD\n")
	        fprintf( FORMFILE "\n")
	)
	
        fprintf( FORMFILE "FIELD down\n")
        fprintf( FORMFILE "FLOC 30 20\n")
        fprintf( FORMFILE "MENUBUTTON \"Down\" 8 3\n")
        fprintf( FORMFILE "ENDFIELD\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "ENDTILE\n")
        fprintf( FORMFILE "\n")
        fprintf( FORMFILE "ENDFORM\n")
        close( FORMFILE)
) ; end _jkBuildForm


;======================== Create the extract form and function ========================
(defun _jkGetNetlistForm ()
        setq( jbhdelfileform "./netlist.form")
        _jkBuildNetlistForm()
        if(restore == nil then
        	fileList = setof(x getDirFiles(  "./") rexMatchp( "[a-z]*.tel" x)) 
        )
        if(restore == t then
       		fileList = setof(x getDirFiles(  "./") rexMatchp( "change.pos*" x))
       	)
        form = (axlFormCreate (gensym) jbhdelfileform `("E" "OUTER") `jk_repCallback t)
        axlFormTitle( form "Changing Symbol Browser")
        axlFormSetField( form "view_file" (car fileList))
        selectedFile = (car fileList)
        foreach( fileName fileList (axlFormSetField form "file_list" fileName))
        axlFormDisplay( form)
        axlFormSetField( form "Property" property)
); defun myForm
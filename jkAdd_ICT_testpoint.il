; Filename: jkAdd_ICT_testpoint.il
; Rev 1.1: 08-08-2002
; Written by: jiake/15924
; CAD Group Fundamental Dept R&D
; HUAWEI TECHNOLOGIES CO., LTD.

;============================= Registe command ========================================
axlCmdRegister( "add ict" 'jk_TestpointMain ); ?cmdType "general")

;============================= Mian function ==========================================
defun( jk_TestpointMain ()

	selectedFile = nil
	NetList = nil
	viewNum = 1
	toAddTPoint = nil
	jk_GetNO_TESTForm()
)

;================= Add NO_TEST properties to the nets not to add testpoint ==============
defun( jk_SetNotest ( toAddTPoint )
prog( ()
let( ( allnets item x delNO_TEST addNO_TEST )
	allnets = axlDBGetDesign()->nets
	if( allnets != nil then axlDBDeleteProp( allnets '("NO_TEST") ))
	
	foreach(item allnets
		if(exists( x toAddTPoint x->name == item->name ) == nil then
				addNO_TEST = cons(item addNO_TEST)
		)
	)
	if( addNO_TEST != nil then axlDBAddProp( addNO_TEST '("NO_TEST" t) ))

	axlMsgPut( "There is %d nets to try to add testpoint." length( toAddTPoint ) )
)))
	
;============== Get ICT netlist from Allegro.scr file to value "netlist" =============
defun( jk_GetICTnetlist ()
prog( ()
let( ( inf lst namelist netname name line netlist)
	inf = infile( selectedFile )
	if(inf == nil then 
		return(nil)
	)
	netlist = nil
	while( gets(line inf)!= nil
		lst = parseString(line)
		if( length(lst) > 3 then		
			if(nthelem(3 lst) == "objlist" then
				namelist = parseString(nthelem(4 lst) "\\\\")
				netname = car(namelist)
				foreach(name cdr(namelist)
					netname = strcat(netname "\\" name)
				)
				if(substring(netname 1 1) == "'" then 
					netname = substring(netname 2 strlen(netname)-2)
				)
				netlist = cons(netname netlist)
			)
		)
	)
	close(inf)
	return( netlist )
)))


	
;========================== Restore the properties NO_TEST =========================

defun( jk_RestoreNO_TEST ( )
prog( ()
let( ( item x allnets delNotest addNotest )
	allnets = axlDBGetDesign()->nets
	if( allnets != nil then axlDBDeleteProp( allnets '("NO_TEST") ))
)))

;======================== If a net has testpoint ========================
;-------- input  : netid
;-------- output : t/nil

defun( jk_HasTestpoint ( netid )
prog( ()
let( ( branch child )
	foreach( branch netid->branches
		foreach(child branch->children
			if( child->testPoint != nil then
				return( t ) 
			)
		)
	)
	return( nil )
)))

;======================= Hilight all nets without testpint ========================
defun( jk_HiNetNoTpoint ()
prog( ()
let( ( allnets item HilightNets )
	HilightNets = nil
	allnets = axlDBGetDesign()->nets
	foreach( item allnets 
		if( jk_HasTestpoint( item ) == nil then
			HilightNets = cons( item HilightNets )
		)
	)
	return( HilightNets )
)))

;======================= Hilight nets without testpoin in ICT file ================
defun( jk_HiICTNetNoTpoint ()
prog( ()
let( ( allnets item HilightNets x )
	allnets = axlDBGetDesign()->nets
	HilightNets = nil
	NetList = jk_GetICTnetlist()
	foreach( item allnets 
		if( exists( x NetList x == item->name ) != nil 
		&& jk_HasTestpoint( item ) == nil then
			HilightNets = cons( item HilightNets )
		)
	)
	return( HilightNets )
)))

;======================= Hilight nets in ICT file =================================
defun( jk_HiICTNet ()
prog( ()
let( ( HilightNets item allnets x )
	allnets = axlDBGetDesign()->nets
	HilightNets = nil
	NetList = jk_GetICTnetlist()
	foreach( item allnets 
		if( exists( x NetList x == item->name ) != nil then
			HilightNets = cons( item HilightNets )
		)
	)
	return( HilightNets )	
)))

;============================ Dehilight all nets  =================================
defun( jk_DeHighlightAll ()
prog( ()
let( ( allnets )
	allnets = axlDBGetDesign()->nets
	axlDehighlightObject( allnets )
	return( nil )
)))


; =================== Process User entries in popup menu ==========================
(defun jk_testCallback (form)
(prog ()
    case( form->curField
        ("auto"  
            toAddTPoint = jk_GetNetsToAddTPoint()         
	    if( length( toAddTPoint ) > 0 && ( viewNum == 1 || viewNum == 2 || viewNum == 3 ) then 
	    	jk_SetNotest( toAddTPoint )
	    	jk_CreateScrFile()
		axlShell("replay prep.sct")
		shell("rm ./prep.sct")
	    else
	        axlMsgPut( "No net(s) to add testpoint.")
	    )	   
            t)
            
        ("done"
     	        jk_RestoreNO_TEST( ) 
            	axlFormClose( form)
            	axlCancelEnterFun()
            	deleteFile( formfile)
	    	axlMsgPut("Done")     	    
            nil)
            
        ("view_file"
            axlFormSetField( form "view_file" form->curValue )
            selectedFile = form->curValue
            t)
            
        ("file_list"
            axlFormSetField( form "view_file" form->curValue)
            selectedFile = form->curValue
            t)
            
        ("ICTNetNoTpoint"
	    viewNum = 1	
            t)
            
        ("ICTNet"
	    viewNum = 2	
            t)
            
        ("NetNoTpoint"
	    viewNum = 3
            t)
            
        ("deHighlightAll"
	    viewNum = 4	
            t)
            
        ("View_nets"
            jk_DeHighlightAll()
            toAddTPoint = jk_GetNetsToAddTPoint()
            if( toAddTPoint != nil then
            	axlHighlightObject( toAddTPoint )
            )
            axlMsgPut( "There is %d net(s) highlighted." length( toAddTPoint ))
            t)
            
    ); case
)); defun jk_repCallback

;=================== Get netid to add testpoint ================================
defun( jk_GetNetsToAddTPoint ()
prog( ()
let( ( toAddTPoint )
	if( viewNum == 1 then toAddTPoint = jk_HiICTNetNoTpoint() )
	if( viewNum == 2 then toAddTPoint = jk_HiICTNet() )
	if( viewNum == 3 then toAddTPoint = jk_HiNetNoTpoint() )
	if( viewNum == 4 then toAddTPoint = jk_DeHighlightAll() )
	return( toAddTPoint ) 
)))

;=================== build up the form dynamically ==========================
(defun jk_BuildNO_TESTForm ()
        deleteFile( formfile)
        FORMFILE = outfile( formfile)
        fprintf( FORMFILE "FILE_TYPE=FORM_DEFN VERSION=2\n")
        fprintf( FORMFILE "FORM\n")
        fprintf( FORMFILE "FIXED\n")
        fprintf( FORMFILE "PORT 54 10\n")
        fprintf( FORMFILE "HEADER \"Browser\"\n\n")
        
        fprintf( FORMFILE "TILE\n")
        fprintf( FORMFILE "TEXT \"File name:\"\n")
        fprintf( FORMFILE "TLOC 5 14\n")
        fprintf( FORMFILE "ENDTEXT\n\n")
 
        fprintf( FORMFILE "FIELD view_file\n")
        fprintf( FORMFILE "FLOC 13 14\n")
        fprintf( FORMFILE "STRFILLIN 10 20\n")
        fprintf( FORMFILE "ENDFIELD\n\n")

        fprintf( FORMFILE "FIELD file_list\n")
        fprintf( FORMFILE "FLOC 5 4\n")
        fprintf( FORMFILE "LIST \"\" 20 5\n")
        fprintf( FORMFILE "ENDFIELD\n\n")
        
 
        fprintf(FORMFILE "FIELD ICTNetNoTpoint\n")
        fprintf(FORMFILE "FLOC 32 4\n")
        fprintf(FORMFILE "FGROUP \"MoveCom\"\n")
        fprintf(FORMFILE "CHECKLIST \"ICT nets without tpoint\" \"MoveCom\"\n")
        fprintf(FORMFILE "ENDFIELD\n")
      
        fprintf(FORMFILE "FIELD ICTNet\n")
        fprintf(FORMFILE "FLOC 32 6\n")
        fprintf(FORMFILE "FGROUP \"MoveCom\"\n")
        fprintf(FORMFILE "CHECKLIST \"ICT file nets\" \"MoveCom\"\n")
        fprintf(FORMFILE "ENDFIELD\n")

        fprintf(FORMFILE "FIELD NetNoTpoint\n")
        fprintf(FORMFILE "FLOC 32 8\n")
        fprintf(FORMFILE "FGROUP \"MoveCom\"\n")
        fprintf(FORMFILE "CHECKLIST \"Nets without tpoint\" \"MoveCom\"\n")
        fprintf(FORMFILE "ENDFIELD\n")
      
        fprintf(FORMFILE "FIELD deHighlightAll\n")
        fprintf(FORMFILE "FLOC 32 10\n")
        fprintf(FORMFILE "FGROUP \"MoveCom\"\n")
        fprintf(FORMFILE "CHECKLIST \"None\" \"MoveCom\"\n")
        fprintf(FORMFILE "ENDFIELD\n")
   	
        fprintf( FORMFILE "FIELD View_nets\n")
        fprintf( FORMFILE "FLOC 37 14\n")
        fprintf( FORMFILE "MENUBUTTON \"View\" 9 3\n")
        fprintf( FORMFILE "ENDFIELD\n\n")
        

        fprintf( FORMFILE "FIELD auto\n")
        fprintf( FORMFILE "FLOC 10 19\n")
        fprintf( FORMFILE "MENUBUTTON \"Testprep auto...\" 15 3\n")
        fprintf( FORMFILE "ENDFIELD\n\n")

        fprintf( FORMFILE "FIELD done\n")
        fprintf( FORMFILE "FLOC 33 19\n")
        fprintf( FORMFILE "MENUBUTTON \"Done\" 15 3\n")
        fprintf( FORMFILE "ENDFIELD\n\n")
        
	fprintf(FORMFILE "GROUP \"Select ICTnet file\"\nGLOC 2 1\nGSIZE 26 16\nENDGROUP\n\n")
	fprintf(FORMFILE "GROUP \"Testpoint nets control\"\nGLOC 30 1\nGSIZE 23 16\nENDGROUP\n\n")

        fprintf( FORMFILE "ENDTILE\n\n")
        fprintf( FORMFILE "ENDFORM\n")
        close( FORMFILE)
) ; end jk_BuildForm


;======================== Create the extract form and function ========================
(defun jk_GetNO_TESTForm ( )
let( ( x fileList fileName)
        formfile = "./No_test.form"
        jk_BuildNO_TESTForm()
	fileList = setof(x getDirFiles(  "./") rexMatchp( "[a-z]*.scr" x))
	form = axlFormCreate( (gensym) formfile `("E" "OUTER") `jk_testCallback t)
	axlFormTitle( form "Testpoint process form")
        if( exists( x fileList x == "Allegro.scr" ) != nil then
         	selectedFile =  "Allegro.scr"       
        else
        	selectedFile = car( fileList )        
        )
        axlFormSetField( form "view_file" selectedFile)
        foreach( fileName fileList (axlFormSetField form "file_list" fileName))
        axlFormDisplay( form )
        axlFormSetField( form "ICTNetNoTpoint" t )
)); defun myForm

;======================== Create testprep param script file ===========================
(defun jk_CreateScrFile ()
        SCRFILE = outfile( "prep.sct")
	fprintf( SCRFILE "setwindow pcb\n")
	fprintf( SCRFILE "trapsize 7440\n")
	fprintf( SCRFILE "testprep param\n")
	fprintf( SCRFILE "setwindow form.probe_info\n")
	fprintf( SCRFILE "FORM probe_info replace_vias YES\n")
	fprintf( SCRFILE "FORM probe_info execute_increment YES\n")
;	fprintf( SCRFILE "FORM probe_info allow_auto_insert YES\n")
	close( SCRFILE )
)
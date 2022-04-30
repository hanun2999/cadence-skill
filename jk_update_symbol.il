
;              			Update Symbol
;	      	==================================================

;File name:"jk_update_symbol.il"
;Revision:1.0	
;date:07/12/2002
;Writen by: JIAKE/15924

;	HAVE ANY PROBLEM PLEASE CONTACT ME !
;		ADD: 	#1620
;		TEL:	50581
;		LOTUS:	15924


;================ Registe a command ====================================================

axlCmdRegister( "update_symbols" 'main ?cmdType "general" )


;=======================================================================================
;			Main function: Create netin file
;=======================================================================================

defun( main ()
when( axlOKToProceed()
let( ( syms )
	initValue()
	
	listl = GetUpdateSym( )
	jk_biuld_update_symbol_form( listl )
	
	
)))

;================ Initialize global values =============================================

defun( initValue ()
let( ( tfile item dirs fileName )
	locallst = "symlst.lst"
	fileName = "hwlib-update.lst"
	lstFile = nil
	listl = nil
	listr = nil
	syml = nil
	symr = nil

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;direct to "PSMPATH"
;dirs = parseString(axlGetVariable("PSMPATH"))     ;shielded  by lijinjun

;;;;;direct to allegro14.1/14.2/share/pcb/etc/skill/newdata ;
;;;;;Add by lijinjun
dirs = parseString(sprintf( dirs_path "%s/etc/skill/newdata" axlGetVariable("allegro_install_dir")))
                           

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	
	;get the file direction and name and save it in lstFile.
	foreach( item dirs ;i=-1 i++ item=nth(i dirs)
		tfile = strcat( item "/" fileName )
		if(isFile( tfile )
			lstFile = tfile
		)
	)
))

;================ Create script file updating symbols =================================

defun( createScriptFile ( locallst )
let( ( outf )
	outf = outfile("updataSym.scr")
	fprintf(outf " setwindow pcb \n")
	fprintf(outf " trapsize 14536 \n")
	fprintf(outf " refresh symbol \n")
	fprintf(outf " setwindow form.upd_element \n")
	fprintf(outf " FORM upd_element padstacks YES \n")
	fprintf(outf " FORM upd_element browse \n")
	fprintf(outf " fillin \"%s\" \n" locallst)
	fprintf(outf " FORM upd_element refresh \n")
	fprintf(outf " setwindow pcb \n")
	fprintf(outf " trapsize 14536 \n")
	fprintf(outf " setwindow form.upd_element \n")
	fprintf(outf " FORM upd_element close \n")
	close(outf)	
))

;================ Get the update symbols  contents from "update200206.lst" =============

defun( GetUpdateSym ( )
let( ( syms line inf item x updateSym )

	syms = axlDBGetDesign()->symbols
	inf = infile( lstFile )
	updateSym = nil
	if(inf != nil 
	then 
		while( fscanf(inf "%s" item)
		;	gets( line inf )
		;	item = car( parseString( line ) )
			if( exists( x syms (x->name == item) ) then
				updateSym = cons( item updateSym )
			)
		)
	else
		axlMsgPut("Can't open list file in \"%s/%s\"." axlGetVariable("PSMPATH") lstFile )
	)
	updateSym 
))


;================ Create a from file and display it ===================================

defun( jk_biuld_update_symbol_form ( listl )
prog( ()  
let( ( pform formname item )
	formname = "./updatesym.form"
   	pform = outfile(formname "w")
   	fprintf(pform "FILE_TYPE=FORM_DEFN VERSION=2\n")
   	fprintf(pform "FORM\n")
   	fprintf(pform "FIXED\n")
   	fprintf(pform "PORT 43 10\n")
   	fprintf(pform "HEADER \"Update Symbols by Selecting\"\n")
   	fprintf(pform "TILE\n")
   
   	fprintf(pform "TEXT \"Update symbols\"\n")
   	fprintf(pform "TLOC 2 1\n")
   	fprintf(pform "ENDTEXT\n")
      
        fprintf( pform "FIELD update_syml\n")
        fprintf( pform "FLOC 2 3\n")
        fprintf( pform "LIST \"\" 17 7\n")
        fprintf( pform "ENDFIELD\n")
   
   	fprintf(pform "TEXT \"Selected symbol(s) to update\"\n")
   	fprintf(pform "TLOC 25 1\n")
   	fprintf(pform "ENDTEXT\n")    
        fprintf( pform "FIELD update_symr\n")
        fprintf( pform "FLOC 25 3\n")
        fprintf( pform "LIST \"\" 17 7\n")
        fprintf( pform "ENDFIELD\n")
  
   	fprintf(pform "FIELD add\n")
   
   	fprintf(pform "FLOC 20 5\n")
   	fprintf(pform "MENUBUTTON \" > \" 3 3\n")
   	fprintf(pform "ENDFIELD\n")
   	fprintf(pform "FIELD del\n")
   
   	fprintf(pform "FLOC 20 7\n")
   	fprintf(pform "MENUBUTTON \" < \" 3 3\n")
   	fprintf(pform "ENDFIELD\n")
   	fprintf(pform "FIELD addall\n")
   
   	fprintf(pform "FLOC 20 9\n")
   	fprintf(pform "MENUBUTTON \">>\" 3 3\n")
   	fprintf(pform "ENDFIELD\n")
   	fprintf(pform "FIELD delall\n")
   
   	fprintf(pform "FLOC 20 11\n")
   	fprintf(pform "MENUBUTTON \"<<\" 3 3\n")
   	fprintf(pform "ENDFIELD\n")
    
   	fprintf(pform "FIELD done\n")
   	fprintf(pform "FLOC 8 18\n")
   	fprintf(pform "MENUBUTTON \"Done\" 6 3\n")
   	fprintf(pform "ENDFIELD\n")
   	fprintf(pform "FIELD apply\n")
   	fprintf(pform "FLOC 18 18\n")
   	fprintf(pform "MENUBUTTON \"Apply\" 6 3\n")
   	fprintf(pform "ENDFIELD\n")
   	fprintf(pform "FIELD help\n")
   	fprintf(pform "FLOC 28 18\n")
   	fprintf(pform "MENUBUTTON \"Help\" 6 3\n")
   	fprintf(pform "ENDFIELD\n")

   	fprintf(pform "ENDTILE\n")
   	fprintf(pform "ENDFORM\n")
   	close(pform)
   
   	form=axlFormCreate( (gensym) formname `("E" "OUTER") `repCallback t)
   
   	foreach( item listl axlFormSetField( form "update_syml" item))
   	axlFormDisplay(form)
;   	axlFormSetField(form "text_text" text_text)
))) 

;================ Callback function ====================================================

defun( repCallback (form)
prog( ()
let( ( item )
    case( form->curField
        ("update_syml"            
	    	syml = form->curValue
            t)
            
        ("update_symr"            
	    	symr = form->curValue
            t)
            
        ("add"  
        	if( syml != nil          
        	then 
		    	axlMsgPut("Select package: %s." syml)
		else
			axlMsgPut("Please hilight an item in left list." )
		)
	    	if( exists( x listr x == syml ) == nil then 
		    	listr = append1( listr syml )
		)
	    	listl = remd( syml listl )
		oprate_list()
		syml = nil
            t)
        ("del"            
        	if( symr != nil          
        	then 
		    	axlMsgPut("Unselect package: %s." symr)
		else
			axlMsgPut("Please hilight an item in right list." )
		)
	    	if( exists( x listl x == symr ) == nil then 
		    	listl = append1( listl symr )
		)
	    	listr = remd( symr listr )
		oprate_list()
		symr = nil
            t)
        ("addall" 
        	listl = nil 
		listr = GetUpdateSym( )	    	
	    	axlMsgPut("Select all package: %L." listr )
		oprate_list()
            t)
        ("delall"            
		listl = GetUpdateSym( )	    	
   		listr = nil
		axlMsgPut("Unselect all package: %L." listl )
		oprate_list()
            t)
        ("done"   
        	
	    	axlMsgPut("done." )
            	axlFormClose( form)
            	deleteFile( "./updatesym.form" )
            t)
        ("apply"            
	    	axlMsgPut("Update symbols.")
	    	outf = outfile(locallst)
	    	foreach(item listr 
	    		if(stringp(item) then
	    			fprintf(outf "%s\n" item)
	    		)
	    	)
	    	close(outf)
		createScriptFile( locallst )
		axlShell("replay updataSym.scr")
		shell("rm updataSym.scr")
		if( isFile(locallst)
			shell( strcat("rm " locallst ))
		)
		display_refdes_updatesym()
            t)            
    );End-case
)));Edn-defun 

;================ Acoording to values listl and listr, update the list display items ===


defun( oprate_list ()
let( ( item )
	axlFormListDeleteAll( form "update_symr" )
   	axlFormSetField( form "update_symr" nil)
   	foreach( item listr 
   		axlFormSetField( form "update_symr" item)
   	)
	axlFormListDeleteAll( form "update_syml" )
   	axlFormSetField( form "update_syml" nil)
   	foreach( item listl 
   		axlFormSetField( form "update_syml" item)
   	)
))

;================ View the update information ==========================================

defun( display_refdes_updatesym ()
let( (outf syms item count)
	outf = outfile("ref_updateSym.tmp")
	syms = axlDBGetDesign()->symbols
	axlDehighlightObject( syms )
	fprintf( outf "# File name : %s.brd 	Update time : %s \n" 
		axlCurrentDesign() getCurrentTime())
	fprintf( outf "# Updated symbol(s):\n" )
	fprintf( outf "___________________________________________________________________\n" )
	hisyms = nil
	foreach(item listr ;i++ sym=nth(i syms) sym~>??
		;print symbol name
		fprintf( outf "\n\n[ PACKAGE   %s ]" item)
		count = 0
		foreach( sym syms 
			if( item == sym->name && sym->refdes != nil then
			;print refdes
				hisyms = cons( sym hisyms )
				if(mod(count 5)==0 then
					fprintf( outf "\n	%-12s" sym->refdes )
				else
					fprintf( outf "%-12s" sym->refdes )
				)
				count++
			)
		)
	)
	close(outf)
	axlHighlightObject( hisyms )
	axlUIViewFileCreate("ref_updateSym.tmp" "View refdes of symbol updated" nil)
))

;====================================== END ============================================
;		  Move components to the setting grid
;	    ----------------------------------------------


;File name: jkmove_comps_to_grid.il
;Revision:	0	
;date:		11/30/2001
;Writen by: 	JIAKE/15924
;tel: 		6540581
;e_mail: 	jiake@huawei.com

;This routine allowes the user to move components to the grid 
;acoording to user settings . And user can deal with all components 
;or move them by select or by pin count . 
;
;type the command : "comps grid" at the Allegro command line to display 
;the "Moving components to grid" form.
;Notes when you select radio button "By select" , you must press the 
;"Apply" button , then select components in allegro window . After that ,
;press right mouse button , run "Compelete" command .


axlCmdRegister("comps grid" 'DisMoveForm)


;____________________Display form ______________________________________

(defun DisMoveForm ()
	
	_jkInitVar()

    	setq( Moveform "./move_component.form")
    	BuildForm()
    	
    	setq( form (axlFormCreate (gensym) Moveform `("E" "OUTER") `repCallback_movecomps t))
        _jkFormPtr = form
    	axlFormSetField( form "ref_point" ref_point)
    	axlFormSetField( form "move_grid" move_grid)
    	axlFormSetField( form "all" by_All)
    	axlFormSetField( form "bySelect" by_Select)
    	axlFormSetField( form "byPinCount" by_PinCount)
    	
    	axlFormDisplay( form)
); defun myForm

;==================================================================
;			Move Components Function
;==================================================================

defun( _jkMoveComponent (symbol)
prog( ()
	
    foreach(sym symbol		
    
    	if(sym->component->prop->FIXED != t && sym->objType == "symbol" then
    		if(sym->refdes != nil then axlMsgPut("Moving %s" sym->refdes))
    	;___________get component imformation______________________________________
		reftext = sym->refdes
		Cside   = sym->isMirrored	
		Cway    = sym->rotation  
		CXY     = sym->xy 
		CX = nthelem(1 CXY) 
		CY = nthelem(2 CXY)	  	
		
	;__________get refdes imformation_________________________________________
		refdes=axlDBGetAttachedText(sym)
		if(nthelem(1 refdes)->layer == "REF DES/SILKSCREEN_TOP" 
		|| nthelem(1 refdes)->layer == "REF DES/SILKSCREEN_BOTTOM" then
			txt=nthelem(1 refdes) 
		else 
			txt=nthelem(2 refdes) 
		)
		refparent   = txt->parent
		reflayer    = txt->layer
		refblock    = txt->textBlock  
		refway      = txt->rotation
	  	refside     = txt->isMirrored 
  		refposition = txt->justify
	  	RXY         = txt->xy
  		RX = nthelem(1 RXY) 
		RY = nthelem(2 RXY)
		
	;___________convert the parameter________________________________________
	  	
	  	case(ref_point
	  		("Origin" 
	  			CXYoff = sym->xy 
	  			t
			) 	  	
      			("Pin1" 
      				pins = sym->pins
      				foreach(pin1 pins if(pin1->number == "1" CXYoff = pin1->xy))
      				t
      			)
      		)
      		if(CXYoff == nil then	CXYoff = CXY)	
		CXoff = nthelem(1 CXYoff) 
		CYoff = nthelem(2 CXYoff)
		Xoff  = CXoff - round(CXoff/move_grid)*move_grid
		Yoff  = CYoff - round(CYoff/move_grid)*move_grid
		
		Xnc   = CX - Xoff 
		Ync   = CY - Yoff 
		if(RX != nil && RY != nil then 
			Xnr   = RX - Xoff
			Ynr   = RY - Yoff
		)

	
	;___________change component position___________________________________		
		newsymbol = nil
		if(axlDeleteObject(sym) != nil then
			newsymbol=axlDBCreateSymbol(reftext,Xnc:Ync,Cside,Cway)
		else
			axlDehighlightObject( sym)
		)
		
	;__________change refdes position_______________________________________
		if(newsymbol != nil then
			refdes=axlDBGetAttachedText(car(newsymbol))		
			if(nthelem(1 refdes)->layer == "REF DES/SILKSCREEN_TOP" 
			|| nthelem(1 refdes)->layer == "REF DES/SILKSCREEN_BOTTOM" then 
				txt=nthelem(1 refdes) 
			else 
				txt=nthelem(2 refdes) 
			)
			refparent   = txt->parent

	        	if(RX != nil && RY != nil then 
				axlDeleteObject(txt)	
			        myoritent =make_axlTextOrientation( 
        				?textBlock refblock, 
        				?rotation refway, 
		        		?mirrored refside, 
	        			?justify refposition
		        	)
	        		axlDBCreateText(reftext,Xnr:Ynr,myoritent,reflayer,refparent)
	        	)
        	);if(newsymbol != nil
        );if(sym->        
    );foreach
    comps = axlDBGetDesign()->components
    foreach(comp comps  axlDBRefreshId(comp))
;    axlCancelEnterFun()
;    axlUIWRedraw(nil)
))


;-------------------select components by group-----------------------

(defun _jkSelectGrp ()
(prog ()
if( cmpgrp == nil then
	grsel = nil
	i = 0 
	_jkPopUpB()
      	axlSetFindFilter( ?enabled '(noall components ) ?onButtons '(noall components ))
      	axlOpenFindFilter()
	while( (grsel == nil)
       		if( axlSingleSelectPoint( ) == t then
       		        gelem = axlGetSelSet()
       		        axlMsgPut( "Component %L is Selected." car(gelem)->name)
       		        i=0
       		else
       			if( grsel == nil then axlMsgPut( "Nothing Found, Select Again."))
			i++ if(i > 20 return nil)
       		);end-if
		if( (car gelem)->objType == "component" then
			cmpgrp=cons( nthelem( 1 gelem) cmpgrp)
			i=0
		else
			axlMsgPut( "Component Not A PACKAGE Type")
			axlDehighlightObject( gelem)
			i++ if(i > 20 return nil)
		);end-if
		axlClearSelSet()
		axlHighlightObject( cmpgrp)
	);end-while
	return( cmpgrp)
);end-if
axlCancelEnterFun()
);end-prog
);end-defun


(defun _jkSelectWindow ()
(prog ()
if( wintable[1] == nil then
	_jkPopUpA()
	winsel = nil
	num = 1	
	while( winsel == nil 
		wingrp = nil
		axlSetFindFilter(?enabled '(noall components) ?onButtons '(noall components))
		axlOpenFindFilter()
		axlSingleSelectBox()
		allcom = axlGetSelSet()
;		if( allcom == nil then axlMsgPut( "No Elements Found. Try again!"))
		foreach( com allcom
;i=0 ++i  com = nthelem(i allcom)
			if( com->objType == "component" then
				wingrp = cons(com wingrp)
;				axlMsgPut( "Component %L Window Selected . " com->name)
			);end-if
	
		);end-foreqach
		if(wingrp != nil then
			wintable[num]=wingrp
			num++
		)
		axlClearSelSet()
		axlHighlightObject( wingrp)
	);end-while	
	return( wintable)
);end-if	
axlCancelEnterFun()
);end-prog
);end-defun


;______________" Process User entries in popup menu"_________________________

(defun repCallback_movecomps (form)
    case( form->curField
        ("done"
            axlFormClose( form)
            axlCancelEnterFun()

            deleteFile( Moveform)
            axlMsgPut("DONE")
            t)
        ("apply"           
	    if(by_All == t then	    
		symbol = _jkSym_in_Com(axlDBGetDesign()->components)		
		_jkMoveComponent(symbol)
	    )	    
	    if(by_Select == t then
	        if(grsel == t then
	            cmpgrp = nil
		    symbol = _jkSym_in_Com(_jkSelectGrp())
		    _jkMoveComponent(symbol)
		else
		    axlMsgPut("jE- Finish current command first.")
		)
	    )
	    if(by_Window == t then
	        if(winsel == t then
	            wintable = makeTable("atable1" nil)
		    comps = _jktab_to_list(_jkSelectWindow())
		    symbol = _jkSym_in_Com(comps)
		    _jkMoveComponent(symbol)
		else
		    axlMsgPut("jE- Finish current command first.")
		)
	    )
	    if(by_PinCount == t then
	    	allsym = _jkSym_in_Com(axlDBGetDesign()->components)
	    	symbol = nil
	    	foreach(asym allsym
	    	    if( length(asym->pins) >= pin_min && length(asym->pins) <= pin_max then
	    	    	symbol = cons( asym symbol)	    	    	
	    	    )
	    	)
	    	_jkMoveComponent(symbol)
	    )	    	    
            t)
        ("cancel"
            axlFormClose( form)
            axlCancelEnterFun()
            deleteFile( Moveform)
            nil)
            
        ("ref_point"	
            axlMsgPut("Select ref point .")
            ref_point = form->curValue
            t)
        ("move_grid"	
            axlMsgPut("Enter grid of placement .")
            move_grid = form->curValue
            t)
        ("pinmin"	
            axlMsgPut("Enter minimus pin count .")
            pin_min = form->curValue
            t)
        ("pinmax"	
            axlMsgPut("Enter maximus pin count .")
            pin_max = form->curValue
            t)             
        ("all"	
            axlMsgPut("Move all component .")
            by_All = form->curValue
            t)
 	("bySelect"
            axlMsgPut("Move component by select .")
            by_Select = form->curValue            
            t)
 	("byWindow"
            axlMsgPut("Move component by window .")
            by_Window = form->curValue            
            t)
 	("byPinCount"
            axlMsgPut("Move component by pin count .")
            by_PinCount = form->curValue
    	    axlFormSetField( form "pinmin" pin_min)
    	    axlFormSetField( form "pinmax" pin_max)
            t)
    ); case
    
); defun jk_repCallback_movecomps


;____________ build up the form dynamically_______________________

(defun BuildForm ()

	(deleteFile Moveform)
	(setq FORMFILE (outfile Moveform))
	(fprintf FORMFILE "FILE_TYPE=FORM_DEFN VERSION=2\n")

	(fprintf FORMFILE "FORM\n")
	(fprintf FORMFILE "FIXED\n")
	(fprintf FORMFILE "PORT 35 10\n")
	(fprintf FORMFILE "HEADER \"Moving components to grid\"\n")
	(fprintf FORMFILE "\n")	
	fprintf(FORMFILE "POPUP <Layer_Names>")
   	fprintf(FORMFILE "\"Origin\" \"Origin\",\"Pin1\" \"Pin1\".\n")
   	
	fprintf(FORMFILE "POPUP <Packages>")
   	fprintf(FORMFILE "\"P1\" \"P1\",\"P2\" \"P2\".\n")
   	

	(fprintf FORMFILE "TILE\n")
	
   	fprintf(FORMFILE "TEXT \"Refrence point:\"\n")
	fprintf(FORMFILE "TLOC 4 1\n")
   	fprintf(FORMFILE "ENDTEXT\n")
   	fprintf(FORMFILE "FIELD ref_point\n")
   	fprintf(FORMFILE "FLOC 18 1\n")
   	fprintf(FORMFILE "ENUMSET 11\n")
   	fprintf(FORMFILE "POP \"Layer_Names\"\n")
   	fprintf(FORMFILE "ENDFIELD\n")

        fprintf(FORMFILE "TEXT \"Grid of Placement:\"\n")
        fprintf(FORMFILE "TLOC 4 4\n")
        fprintf(FORMFILE "ENDTEXT\n")
        fprintf(FORMFILE "FIELD move_grid\n")
        fprintf(FORMFILE "FLOC 22 4\n")
        fprintf(FORMFILE "REALFILLIN 8 8\n")
        fprintf(FORMFILE "REALMIN 1.0\n")
   	fprintf(FORMFILE "REALMAX 1000.0\n")
        fprintf(FORMFILE "ENDFIELD\n")
   
        fprintf(FORMFILE "FIELD all\n")
        fprintf(FORMFILE "FLOC 4 10\n")
        fprintf(FORMFILE "FGROUP \"MoveCom\"\n")
        fprintf(FORMFILE "CHECKLIST \"All (Excepting fixed components)\" \"MoveCom\"\n")
        fprintf(FORMFILE "ENDFIELD\n")
   
        fprintf(FORMFILE "FIELD byPinCount\n")
        fprintf(FORMFILE "FLOC 4 12\n")
        fprintf(FORMFILE "FGROUP \"MoveCom\"\n")
        fprintf(FORMFILE "CHECKLIST \"By pin count from\" \"MoveCom\"\n")
        fprintf(FORMFILE "ENDFIELD\n")
        
        fprintf(FORMFILE "TEXT \"to\"\n")
        fprintf(FORMFILE "TLOC 25 12\n")
        fprintf(FORMFILE "ENDTEXT\n")
        
        fprintf(FORMFILE "FIELD pinmin\n")
        fprintf(FORMFILE "FLOC 20 12\n")
        fprintf(FORMFILE "INTFILLIN 3 3\n")
        fprintf(FORMFILE "ENDFIELD\n")
        fprintf(FORMFILE "FIELD pinmax\n")
        fprintf(FORMFILE "FLOC 27 12\n")
        fprintf(FORMFILE "INTFILLIN 4 4\n")
        fprintf(FORMFILE "ENDFIELD\n")
        
        fprintf(FORMFILE "FIELD bySelect\n")
        fprintf(FORMFILE "FLOC 4 14\n")
        fprintf(FORMFILE "FGROUP \"MoveCom\"\n")
        fprintf(FORMFILE "CHECKLIST \"By select\" \"MoveCom\"\n")
        fprintf(FORMFILE "ENDFIELD\n")
   	
        fprintf(FORMFILE "FIELD byWindow\n")
        fprintf(FORMFILE "FLOC 4 16\n")
        fprintf(FORMFILE "FGROUP \"MoveCom\"\n")
        fprintf(FORMFILE "CHECKLIST \"By window\" \"MoveCom\"\n")
        fprintf(FORMFILE "ENDFIELD\n")
/*
        fprintf(FORMFILE "FIELD byPackage\n")
        fprintf(FORMFILE "FLOC 4 16\n")
        fprintf(FORMFILE "FGROUP \"MoveCom\"\n")
        fprintf(FORMFILE "CHECKLIST \"By package\" \"MoveCom\"\n")
        fprintf(FORMFILE "ENDFIELD\n")
                
   	fprintf(FORMFILE "FIELD package\n")
   	fprintf(FORMFILE "FLOC 20 16\n")
   	fprintf(FORMFILE "ENUMSET 11\n")
   	fprintf(FORMFILE "POP \"Packages\"\n")
   	fprintf(FORMFILE "ENDFIELD\n")
   	
        fprintf(FORMFILE "FIELD byList\n")
        fprintf(FORMFILE "FLOC 4 18\n")
        fprintf(FORMFILE "FGROUP \"MoveCom\"\n")
        fprintf(FORMFILE "CHECKLIST \"By list\" \"MoveCom\"\n")
        fprintf(FORMFILE "ENDFIELD\n")
        
	(fprintf FORMFILE "FIELD by_list\n")
	(fprintf FORMFILE "FLOC 6 20\n")
	(fprintf FORMFILE "LIST \"\" 24 6\n")
	(fprintf FORMFILE "ENDFIELD\n")
	(fprintf FORMFILE "\n")
*/
	fprintf(FORMFILE "GROUP \"Move components\"\nGLOC 2 7\nGSIZE 32 12\nENDGROUP\n\n")
        
	(fprintf FORMFILE "FIELD done\n")
	(fprintf FORMFILE "FLOC 6 21\n")
	(fprintf FORMFILE "MENUBUTTON \"Down\" 9 3\n")
	(fprintf FORMFILE "ENDFIELD\n")
	(fprintf FORMFILE "\n")
	
	(fprintf FORMFILE "FIELD apply\n")
	(fprintf FORMFILE "FLOC 20 21\n")
	(fprintf FORMFILE "MENUBUTTON \"Apply\" 9 3\n")
	(fprintf FORMFILE "ENDFIELD\n")
	(fprintf FORMFILE "\n")

	(fprintf FORMFILE "ENDTILE\n")
	(fprintf FORMFILE "\n")
	(fprintf FORMFILE "ENDFORM\n")
	(close FORMFILE)
) ; end _jkBuildForm

;--------------- Pop up for window selection --------------------------------
defun( _jkPopUpA ()
	popupA = axlUIPopupDefine( nil
		(list (list "Complete" '_jkcomplete)
			(list "Oops" '_jkwinoops)
			(list "Cancel" '_jkCancel)))
	axlUIPopupSet( popupA )
);end-defun


;--------------- Pop up for group selection --------------------------------
defun( _jkPopUpB ()
	popupB = axlUIPopupDefine( nil
		(list (list "Complete" '_jkcomplete)
			(list "Oops" '_jkoops)
			(list "Cancel" '_jkCancel)))
	axlUIPopupSet( popupB )
);end-defun

;--------------- Cancel Call--------------------------------
defun( _jkCancel ()
(prog ()
	_jkDone()
	axlMsgPut("Cancel")
);end-prog
);endfun

;----------------- DONE Call--------------------------------
defun( _jkDone ()
(prog ()
	setq( grsel t)
	fini == t
	if( cmpgrp != nil then axlDehighlightObject( cmpgrp))
	setq( cmpgrp nil)
	axlCancelEnterFun()
	axlClearSelSet()
	axlCloseFindFilter()
	axlUIPopupSet( nil)
)
);end-fun

;--------------- Complete Picks ----------------------------
defun( _jkcomplete ()
(prog ()
	grsel = t
	winsel = t
	axlCancelEnterFun()
	axlUIPopupSet( nil)
)
);end-defun

;--------------- Oops command-------------------------------
defun( _jkoops ()
(prog ()
	if( cmpgrp != nil then
		axlDehighlightObject( car( cmpgrp))
		cmpgrp = cdr(cmpgrp)
		gelem = nil
	
		axlMsgPut("Oops")	
	);end-if
	axlCancelEnterFun()
	return( cmpgrp)
);endprog
);end-defun		

defun( _jkwinoops ()
(prog ()
	num--
	if( wintable[num] != nil then
		axlDehighlightObject(wintable[num])
		axlMsgPut("Oops")	
		if(num < 1 then
		 	num = 1 
		 	wintable = makeTable("atable1" nil)
		else 
		 	wintable[num] = nil
		)
		
		
	);end-if
	axlCancelEnterFun()
	return( cmpgrp)
);endprog
);end-defun		
;--------------- Initialize value -------------------------------
defun( _jkInitVar ()
(prog ()
	gelem = nil
	grsel = t	
	winsel = t
	by_All = t
	by_Select = nil
	by_Window = nil
	by_PinCount = nil
	ref_point = "Origin"
	move_grid = 50.0
	pin_min = 1
	pin_max = 1000
	_jkFormPtr = nil
	axlUIPopupSet( nil)
	cmpgrp = nil
	fini = nil
	apply = nil
	num = 0
	wintable = makeTable("atable1" nil) 
);end-prog
);end-defun

defun( _jkSym_in_Com (comp)
(prog ()
(let (tsym)
	tsym = nil
	foreach(com comp
		if(com->symbol != nil then
			tsym = cons( com->symbol tsym)	
		)
	)
	return(tsym)
);end-let
);end-prog
);end-defun

defun( _jktab_to_list (table)
(prog ()
(let (tablist )
	tablist = nil	
	foreach(key table
	 	if(table[key] != nil then
			lst = table[key]		
			foreach(com lst
				tablist = cons(com tablist)
			)
		)
	)
	return(tablist)
);end-let
);end-prog
);end-defun



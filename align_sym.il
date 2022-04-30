;+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
;
;	Author: Edward B. Acheson
;		Sr Division AE
;		SPG Division
;		Benchmark Center
;		Cadence Design Systems
;		270 Billerica Road
;		Chelmsford MA 01824
;		(508) 262-6465
;
;	File Name:  align_sym.il
;	Revision 0: December 20,1993
;
;	
;	Purpose: To allow the User to align Component
;		Package symbols by Component Origin or
;		by component pin 1.
;	Usage: Once this file is loaded into the Allegro database
;		enter align_sym<ret> and a form will display
;		Items may be picked by top, bottom or both. Items
;		may be selected by window, group or tolerance. In
;		selecting by group or window, the user may specify
;		choice by class. The tolerance value is the distance
;		to each side of the alignment axis.
;		1. Select Form Options
;		2. Select "Key Componen" to align other symbols to.
;		3. If Group or window is selected, define the window or
;			define group elements, and pick complete in
;			popup window ( middle mouse button).
;		4. Go on to next or hit done.
;	Special notes:
;		1. All Symbol definitions must exist in a Library Path.
;		2. Symbol definition as found in library will
;			be maintained. (this includes alt_symbols).
;
;
;	Other files required:  align_sym.form
;=========================================================
;==================== MAIN ROUTINE =======================
;=========================================================
axlCmdRegister("align_sym" 'align_sym)

procedure( align_sym( )
(prog ()
when( axlOKToProceed() 
_ASInitVar()
_ASCreateFormFile()
_ASInitParmForm()
while( fini == nil
	_ASsetsymmaster()
	if( _ASFormData->group == t && fini == nil then
		_ASselectGrp()
		if( _ASFormData->horizontal == t then
			_ASMoveHorzComp( cmpgrp)
		else
			_ASMoveVertComp( cmpgrp)
		)
		
	)
	if( _ASFormData->tolerance == t && fini == nil then
		if( _ASFormData->horizontal == t then
			_ASHorzSelTol()
			_ASMoveHorzComp( cmpgrp)
		else
			_ASVertSelTol()
			_ASMoveVertComp( cmpgrp)
		)
	)
	if( _ASFormData->window == t && fini == nil then
		_ASWindSel()
		if( _ASFormData->horizontal == t then
			_ASMoveHorzComp( cmpgrp)
		else
			_ASMoveVertComp( cmpgrp)
		)
	)
	cmpgrp = nil
);end-while
axlUIPopupSet( nil)
);endwhen
);end-prog
);endprocedure

;-----------------------define master component location-------------------

(defun _ASsetsymmaster ( )
(prog ()
	_ASPopUpA()
	setq( efound  nil)
while( (efound == nil) && (fini == nil)
	axlMsgPut("Select Key Component.")
	good = nil
	mpinl = nil
	pnloc = nil
	axlSetFindFilter( ?enabled (list "symbols" )
			  ?onButtons (list "symbols"))
	axlOpenFindFilter()
	if( fini ==  nil && axlSingleSelectPoint( ) then
		elem = axlGetSelSet()
		axlMsgPut( "Key Component %L Selected." car(elem)->refdes)
	else
	 	if( fini == nil then axlMsgPut( "Nothing Found, Select Again."))
	);end-if
	if( fini == nil then
		axlHighlightObject( elem)
		if(_ASFormData->top == t && (car elem)->isMirrored == nil then
			good = t
		);endif
		if(_ASFormData->bottom == t && (car elem)->isMirrored == t then
			good = t
		);endif
		
		if(_ASFormData->both == t then good = t)
		if(good == t then
			;---------stor current data
			setq(locat (car elem)->xy)
			setq(cmpid (car elem)->refdes) 
			setq(cmpname (car elem)->name)
			setq(cmptype (car elem)->type)
			setq(cmprot (car elem)->rotation)
			setq(cmpmir (car elem)->isMirrored)
			efound = t
			if( _ASFormData->pin == t then
				r = 1
				setq( mpinl car(elem)->pins)
				while( nthelem( r mpinl) != nil
					if( nthelem( r mpinl)->number == "1" then
						setq( pnloc nthelem( r mpinl)->xy)
					)
				++r
				)
				if( pnloc == nil then
					efound == nil
					axlMsgPut("Component Selected Has No Pin 1.")
					axlMsgPut("Reset Parameters And Try Again.")
				)
			)
					
		else
			axlDehighlightObject( elem)
			axlMsgPut( "Selected Component is not on Selected Layer.")
			axlSubSelectAll()
		);endif
	);endif
);end-while
axlCancelEnterFun()
);end-prog
);end-defun
;-------------------select components by group-----------------------
(defun  _ASselectGrp ()
(prog ()
if( efound == t && cmpgrp == nil then
	grsel = nil
      	_ASPopUpB()
       	axlSetFindFilter( ?enabled (list "symbols" )
       	                  ?onButtons (list "symbols"))
      	axlOpenFindFilter()
	while( (grsel == nil && efound == t) 
       		axlMsgPut("Select Component to be Aligned.")
       		good = nil
		
		if( grsel == nil then
       			if( axlSingleSelectPoint( ) then
       			        setq( gelem axlGetSelSet())
       			        axlMsgPut( "Component %L Group Selected." car(gelem)->refdes)
       			else
       				if( grsel == nil then axlMsgPut( "Nothing Found, Select Again."))
       			);end-if
       		);end-if
       		if(_ASFormData->top == t && (car gelem)->isMirrored == nil then
       		         good = t
       		);endif
       		if(_ASFormData->bottom == t && (car gelem)->isMirrored == t then
       		         good = t
       		);endif
       		if(_ASFormData->both == t then good = t)
		if( grsel == nil then
	       		if(good == t then 
				if( (car gelem)->type == "PACKAGE" then
					cmpgrp=cons( nthelem( 1 gelem) cmpgrp)
					axlHighlightObject( cons( car(elem) cmpgrp))
				else
					axlMsgPut( "Component Not A PACKAGE Type")
					axlDehighlightObject( gelem)
				);end-if

			 else	
				axlMsgPut( "Component Is Not On Appropriate Layer")
				axlDehighlightObject( gelem)
			);endif
		);endif
	);end-while
	return( cmpgrp)
);end-if
axlCancelEnterFun()
);end-prog
);end-defun
;-------------------select by vertical orientation------------------
(defun _ASVertSelTol ()
(prog ()
if( efound == t then
	i = 1
	good = nil
	if( _ASFormData->pin == t then
		mlocat = pnloc
	else
		mlocat = locat
	)
	setq(allsym axlDBGetDesign()->symbols)
	setq(allcmp axlDBGetDesign()->components)
	while( nthelem( i allsym) != nil
		if( nthelem( i allsym)->type == "PACKAGE" && nthelem( i allsym)->refdes != car(elem)->refdes then
			if( _ASFormData->pin == t then
				r = 1
				setq( tpinl nthelem( i allsym)->pins)
				while( nthelem( r tpinl) != nil
					if( nthelem( r tpinl)->number == "1" then
						setq( tlocat nthelem( r tpinl)->xy)
					)
					++r
				)
			else
				setq( tlocat (nthelem(i allsym)->xy))
			)
			if( (car tlocat) <= ( car mlocat)+_ASFormData->tol && (car tlocat) >= ( car mlocat)-_ASFormData->tol then
       		 		if(_ASFormData->top == t && (car gelem)->isMirrored == nil then
       		         		good = t
       		 		);endif
       		 		if(_ASFormData->bottom == t && (car gelem)->isMirrored == t then
       		       		  	good = t
       		 		);endif
       		 		if(_ASFormData->both == t then good = t)
				setq( srefdes (nthelem(i allsym)->refdes))
				h = 1
				while( nthelem( h allcmp) != nil
					if( (nthelem( h allcmp)->name) == srefdes && good == t then
						if( _ASFormData->class == "Any" || nthelem( h allcmp)->class == _ASFormData->class then
							cmpgrp=cons(nthelem( i allsym) cmpgrp)
							axlHighlightObject( cons( car(elem) cmpgrp))
							axlMsgPut( "Component %L Selected." srefdes)
						);end-if
					);endif
					++h	
				);end-while
			);end-if
			good = nil
		);end-if
		++i
	);endwhile
	efound = nil
	fini = nil
);end-if
return( cmpgrp)
);end-prog
);end-defun
;-------------------select by horizontal orientation------------------
(defun _ASHorzSelTol ()
(prog ()
	i = 1
	good = nil
	if( _ASFormData->pin == t then
		mlocat = pnloc
	else
		mlocat = locat
	)
	setq(allsym axlDBGetDesign()->symbols)
	setq(allcmp axlDBGetDesign()->components)
	while( nthelem( i allsym) != nil
		if( nthelem( i allsym)->type == "PACKAGE" then
			if( _ASFormData->pin == t then
				r = 1
				setq( tpinl nthelem( i allsym)->pins)
				while( nthelem( r tpinl) != nil
					if( nthelem( r tpinl)->number == "1" then
						setq( tlocat nthelem( r tpinl)->xy)
					)
					++r
				)
			else
				setq( tlocat (nthelem(i allsym)->xy))
			)
			if((cadr tlocat) <= ( cadr locat)+_ASFormData->tol && (cadr tlocat) >= ( cadr locat)-_ASFormData->tol then
       		 		if(_ASFormData->top == t && (car gelem)->isMirrored == nil then
       		         		good = t
       		 		);endif
       		 		if(_ASFormData->bottom == t && (car gelem)->isMirrored == t then
       		       		  	good = t
       		 		);endif
       		 		if(_ASFormData->both == t then good = t)
				setq( srefdes (nthelem(i allsym)->refdes))
				h = 1
				while( nthelem( h allcmp) != nil
					if( ( nthelem( h allcmp)->name) == srefdes && good == t then
						if( _ASFormData->class == "Any" || nthelem( h allcmp)->class == _ASFormData->class then
							cmpgrp=cons(nthelem( i allsym) cmpgrp)
							axlHighlightObject( cons( car(elem) cmpgrp))
							axlMsgPut( "Component %L Selected" srefdes)
						);end-if
					);end-if
				++h	
				);end-while
			);end-if
		);end-if
		++i
	);end-while
	efound = nil
	fini = nil
	return( cmpgrp)
);end-prog
);end-defun
;-------------------select by window ---------------------------------
(defun _ASWindSel ()
(prog ()
if( efound == t then
	i = 1
	good = nil
	axlSetFindFilter( ?enabled (list "symbols" )
			  ?onButtons (list "symbols"))
	axlOpenFindFilter()
	axlSingleSelectBox()
	allsym = axlGetSelSet()
	if( allsym == nil then axlMsgPut( "No Elements Found."))
	setq(allcmp axlDBGetDesign()->components)
	while( nthelem( i allsym) != nil
		if( nthelem( i allsym)->type == "PACKAGE" then
       		 	if(_ASFormData->top == t && (car gelem)->isMirrored == nil then
       		        	good = t
       		 	);endif
       		 	if(_ASFormData->bottom == t && (car gelem)->isMirrored == t then
       		       	  	good = t
       		 	);endif
       		 	if(_ASFormData->both == t then good = t)
			setq( srefdes (nthelem(i allsym)->refdes))
			h = 1
			while( nthelem( h allcmp) != nil
				if( ( nthelem( h allcmp)->name) == srefdes && good == t then
					if( _ASFormData->class == "Any" || nthelem( h allcmp)->class == _ASFormData->class then
						cmpgrp=cons(nthelem( i allsym) cmpgrp)
						axlHighlightObject( nthelem( i allsym))
						axlMsgPut( "Component %L Window Selected." srefdes)
					);end-if
				);end-if
			++h	
			);end-while
		);end-if
		good = nil
	++i	
	);end-while
);endif
	efound = nil
	return( cmpgrp)
);end-prog
);end-defun
;-------------------relocate vertical position -----------------------
	
(defun _ASMoveVertComp (cmpgrp)
(prog ()
	i = 1
	tmpnew= nil
	ocmpdata=nil
	ocmpmir=nil
	ocmprot=nil
	olocat=nil
	while( nthelem( i cmpgrp) != nil
		if( nthelem( i cmpgrp)->refdes != cmpid then
			cmpdata=nil
			tlocat = nil
			setq(tlocat nthelem( i cmpgrp)->xy)
			setq(tcmpid nthelem( i cmpgrp)->refdes)
			setq(tcmpname nthelem( i cmpgrp)->name)
			setq(tcmptype nthelem( i cmpgrp)->type)
			setq(tcmprot nthelem( i cmpgrp)->rotation)
			setq(tcmpmir nthelem( i cmpgrp)->isMirrored)
			cmpdata=cons(tcmpid cmpdata)
			cmpdata=cons(tcmptype cmpdata)
			cmpdata=cons(tcmpname cmpdata)
			ocmpdata = cons( cmpdata ocmpdata)
			ocmpmir = cons( tcmpmir ocmpmir)
			olocat = cons( tlocat olocat)
			ocmprot = cons( tcmprot ocmprot)
			nlocat=nil
			plocat = nil
			npinl = nil
			axlMsgPut("%L " npinl)
			;-------------define the new vertical orientation
			if( _ASFormData->pin == t then
				r = 1
				npinl=nthelem( i cmpgrp)->pins
				while( nthelem( r npinl) != nil
					if( nthelem( r npinl)->number == "1" then
						plocat= nthelem( r npinl)->xy
						nlocat=cons(nthelem( 2 tlocat) nlocat)
						voffs = (nthelem( 1 tlocat) - nthelem(1 plocat))
						nlocat=cons(( car(pnloc) + voffs) nlocat)
					)
					++r
				)
			else;
				nlocat=cons(nthelem( 2 tlocat) nlocat)
				nlocat=cons(nthelem( 1 locat) nlocat)
			)
			;-------------delete present stuff
			z = 1
			setq( pindat nthelem( i cmpgrp)->pins)
			while( nthelem( z pindat) != nil
				h=1
				setq(pinsel nthelem( z pindat)->branch->children)
				while( nthelem( h pinsel) != nil
					if( nthelem( h pinsel)->objType == "via" then
						dellst = cons( nthelem( h pinsel) dellst)
					)
					if( nthelem( h pinsel)->objType == "path" then
					dellst = cons( nthelem( h pinsel) dellst)
					)
					++h
				);endwhile
				axlDeleteObject(dellst)
				dellst = nil
				++z
			);endwhile
			axlDehighlightObject(nthelem( i cmpgrp))
			axlDeleteObject(nthelem( i cmpgrp))
			if( _ASFormData->pin == t then
				r = 1
				while( nthelem( r npinl) != nil
					axlDBRefreshId( nthelem( r npinl))
					++r
				);end-while
			)
			;-------------add newer symbol
			tmpnew = cons( car(axlDBCreateSymbol( cmpdata nlocat tcmpmir tcmprot)) tmpnew)
		);endif
		++i
	);endwhile
	axlDehighlightObject( elem)
	setq( elem nil)
	setq( grsel nil)
	setq( cmpgrp nil)
);end-prog
);end-defun
;-------------------relocate Hoizontal position ----------------------
	
(defun _ASMoveHorzComp (cmpgrp)
(prog ()
	i = 1
	tmpnew= nil
	ocmpdata=nil
	ocmpmir=nil
	ocmprot=nil
	olocat=nil
	while( nthelem( i cmpgrp) != nil
		if( nthelem( i cmpgrp)->refdes != cmpid then
			cmpdata=nil
			setq(tlocat nthelem( i cmpgrp)->xy)
			setq(tcmpid nthelem( i cmpgrp)->refdes)
			setq(tcmpname nthelem( i cmpgrp)->name)
			setq(tcmptype nthelem( i cmpgrp)->type)
			setq(tcmprot nthelem( i cmpgrp)->rotation)
			setq(tcmpmir nthelem( i cmpgrp)->isMirrored)
			cmpdata=cons(tcmpid cmpdata)
			cmpdata=cons(tcmptype cmpdata)
			cmpdata=cons(tcmpname cmpdata)
			ocmpdata = cons( cmpdata ocmpdata)
			ocmpmir = cons( tcmpmir ocmpmir)
			olocat = cons( tlocat olocat)
			ocmprot = cons( tcmprot ocmprot)
			nlocat=nil
			;-------------define the new horizontal orientation
			if( _ASFormData->pin == t then
				r = 1
				setq( npinl nthelem( i cmpgrp)->pins)
				while( nthelem( r npinl) != nil
					if( nthelem( r npinl)->number == "1" then
						setq( plocat nthelem( r npinl)->xy)
						voffs= nthelem( 2 tlocat) - nthelem(2 plocat)
						nlocat=cons( ( cadr(pnloc) + voffs ) nlocat)
						nlocat=cons( nthelem( 1 tlocat) nlocat)
					);endif
					++r
				);endwhile
			else
				nlocat=cons(nthelem( 2 locat) nlocat)
				nlocat=cons(nthelem( 1 tlocat) nlocat)
			);endif
			;-------------delete present stuff
			z = 1
			setq( pindat nthelem( i cmpgrp)->pins)
			while( nthelem( z pindat) != nil
				h=1
				setq(pinsel nthelem( z pindat)->branch->children)
				while( nthelem( h pinsel) != nil
					if( nthelem( h pinsel)->objType == "via" then
						dellst = cons( nthelem( h pinsel) dellst)
					)
					if( nthelem( h pinsel)->objType == "path" then
						dellst = cons( nthelem( h pinsel) dellst)
					)
					++h
				)
				axlDeleteObject(dellst)
				dellst = nil
				++z
			)
			axlDehighlightObject(nthelem( i cmpgrp))
			axlDeleteObject(nthelem( i cmpgrp))
			if( _ASFormData->pin == t then
				r = 1
				while( nthelem( r npinl) != nil
					axlDBRefreshId( nthelem( r npinl))
					++r
				);end-while
			)
			;-------------add newer symbol
			tmpnew = cons( car(axlDBCreateSymbol( cmpdata nlocat tcmpmir tcmprot)) tmpnew)
		);endif
		++i
	);endwhile
	axlDehighlightObject( elem)
	setq( elem nil)
	setq( grsel nil)
);end-prog
);end-defun

;-------------------Parameter form data ------------------
defun( _ASInitParmForm  () ; 
(prog ()
(let ( form)
	form = axlFormCreate( (gensym) "align_sym.form" '(se outer) '_ASParmCallBk t )
	_ASFormPtr = form
	if( ( _ASFormData == nil ) then
		setq( _ASFormData  t)
		(axlFormBuildPopup form "class" '(("Any" "Any") ("IC" "IC") ("IO" "IO") ("DISCRETE" "DISCRETE")))
		(axlFormSetField form "class" "Any")
		putprop( _ASFormData  "Any" 'class)
		(axlFormSetField form "horizontal" t) 
		putprop( _ASFormData t 'horizontal) 
		(axlFormSetField form "vertical" nil) 
		putprop( _ASFormData nil 'vertical) 
		(axlFormSetField form "pin" nil) 
		putprop( _ASFormData nil 'pin) 
		(axlFormSetField form "origin" t) 
		putprop( _ASFormData t 'origin) 
		(axlFormSetField form "top" t) 
		putprop( _ASFormData t 'top) 
		(axlFormSetField form "bottom" nil) 
		putprop( _ASFormData nil 'bottom) 
		(axlFormSetField form "both" nil) 
		putprop( _ASFormData nil 'both) 
		(axlFormSetField form "group" t) 
		putprop( _ASFormData t 'group) 
		(axlFormSetField form "window" nil) 
		putprop( _ASFormData nil 'window) 
		(axlFormSetField form "tolerance" nil) 
		putprop( _ASFormData nil 'tolerance) 
		(axlFormSetField form "tol" 250.000 )
		putprop( _ASFormData 250.000 'tol) 
	axlFormDisplay( form)
	);end-if
);end-let
);end-prog
);end-defun

;---------------Form Call Back-----------------------------------------------
defun( _ASParmCallBk (form)
 case( get(_ASFormPtr 'curField)
	( "class" putprop( _ASFormData get(_ASFormPtr 'curValue) 'class))
	( "horizontal" putprop( _ASFormData get(_ASFormPtr 'curValue) 'horizontal))	
	( "vertical" putprop( _ASFormData get(_ASFormPtr 'curValue) 'vertical))	
	( "pin" putprop( _ASFormData get(_ASFormPtr 'curValue) 'pin))	
	( "origin" putprop( _ASFormData get(_ASFormPtr 'curValue) 'origin))	
	( "top" putprop( _ASFormData get(_ASFormPtr 'curValue) 'top))	
	( "bottom" putprop( _ASFormData get(_ASFormPtr 'curValue) 'bottom))	
	( "both" putprop( _ASFormData get(_ASFormPtr 'curValue) 'both))	
	( "group" putprop( _ASFormData get(_ASFormPtr 'curValue) 'group))	
	( "window" putprop( _ASFormData get(_ASFormPtr 'curValue) 'window))	
	( "tolerance" putprop( _ASFormData get(_ASFormPtr 'curValue) 'tolerance))	
	( "tol" putprop( _ASFormData get(_ASFormPtr 'curValue) 'tol))	
	( "done" _ASDone() )
	( "cancel"  _ASCancel() )
);case
);end-defun
;--------------- Pop up while selecting but not by group --------------------
defun( _ASPopUpA ()
	popupA = axlUIPopupDefine( nil
			(list (list "Done" '_ASDone)
				(list "Oops" '_ASoops)
				(list "Cancel" '_ASCancel)))
	axlUIPopupSet( popupA )
);end-defun
;--------------- Pop up for group selection --------------------------------
defun( _ASPopUpB ()
	popupB = axlUIPopupDefine( nil
		(list (list "Complete" '_AScomplete)
			(list "Oops" '_ASoops)
			(list "Cancel" '_ASCancel)))
	axlUIPopupSet( popupB )
);end-defun
;--------------- Cancel Call--------------------------------
defun( _ASCancel ()
(prog ()
	i=1
	pindat = nil
	pinsel = nil
	dellst = nil
	while( nthelem( i tmpnew) != nil
		z = 1
		setq( pindat nthelem( i tmpnew)->pins)
		while( nthelem( z pindat) != nil
			h=1
			setq(pinsel nthelem( z pindat)->branch->children)
			while( nthelem( h pinsel) != nil
				if( nthelem( h pinsel)->objType == "via" then
					dellst = cons( nthelem( h pinsel) dellst)
				)
				if( nthelem( h pinsel)->objType == "path" then
					dellst = cons( nthelem( h pinsel) dellst)
				)
				++h
			)
			axlDeleteObject(dellst)
			dellst = nil
			++z
		);endwhile
		axlDeleteObject(nthelem( i tmpnew))
		if( _ASFormData->pin == t then
			r = 1
			while( nthelem( r npinl) != nil
				axlDBRefreshId( nthelem( r npinl))
				++r
			);end-while
		)
		++i
	);end-while
	i = 1
	while( nthelem( i ocmpdata) != nil
			axlDBCreateSymbol( 
			nthelem(i ocmpdata)
			nthelem(i olocat) 
			nthelem(i ocmpmir) 
			nthelem(i ocmprot)
			)
			++i
	);end-while
	elem = nil
	cmpgrp = nil
	_ASDone()
);end-prog
);endfun
;----------------- DONE Call--------------------------------
defun( _ASDone ()
(prog ()
	setq( grsel t)
	if( elem != nil then axlDehighlightObject( elem))
	if( cmpgrp != nil then axlDehighlightObject( cmpgrp))
	setq( grsel t)
	setq( fini t)
	if(isFile("align_sym.form") then
		deleteFile("align_sym.form")
	)
	setq( elem nil)
	setq( cmpgrp nil)
	axlFormClose(_ASFormPtr)
	axlCancelEnterFun()
	axlClearSelSet()
	axlCloseFindFilter()
	axlUIPopupSet( nil)
)
);end-fun
;--------------- Complete Picks ----------------------------
defun( _AScomplete ()
(prog ()
	setq( grsel t)
	axlCancelEnterFun()
	_ASPopUpA()
	setq( efound nil)
)
);end-defun
;--------------- Oops command-------------------------------
defun( _ASoops ()
(prog ()
	if( cmpgrp != nil then
		axlDehighlightObject( car( cmpgrp))
		cmpgrp = cdr(cmpgrp)
		good = nil
		gelem = nil
	else
		axlDehighlightObject( elem)
		elem = nil
		efound = nil
	);end-if
	if( elem == nil then axlMsgPut( "Nothing In Buffer To Oops."))
	axlCancelEnterFun()
	return( cmpgrp)
);endprog
);end-defun		
;--------------- initialize variables -------------------
defun( _ASInitVar ()
(prog ()
elem = nil
mpinl = nil
pnloc = nil
plocat = nil
mlocat = nil
gelem = nil
dellst = nil
pindat = nil
pinsel = nil
tmpnew = nil
ocmpdata=nil
ocmpmir=nil
ocmprot=nil
olocat=nil
_ASFormData = nil
_ASFormPtr = nil
fini = nil
tol = 0
axlUIPopupSet( nil)
fini = nil
cmpgrp = nil
);end-prog
);end-defun
;-----------------create form file -------------
defun( _ASCreateFormFile ()
	
	frmfle = outfile("align_sym.form")
	fprintf( frmfle "FILE_TYPE=FORM_DEFN VERSION=2\nFORM\nFIXED\n")
	fprintf( frmfle "PORT 67 13\nHEADER \"Component Alignment Form\"\n")
	fprintf( frmfle "POPUP <CURSPOP>\"Any\"\"1\",\"IC\"\"2\",\"IO\"\"3\",\"DISCRETE\"\"4\".\n")
	fprintf( frmfle "POPUP <PRINTP>\"to File\"\"0\",\"to Printer\"\"1\",\"to Script\"\"2\".\n")
	fprintf( frmfle "\nTILE\n\n")
	fprintf( frmfle "TEXT \"Class:\"\nTLOC 32 18\nTGROUP \"Select Mode\"\nENDTEXT\n")

	fprintf( frmfle "FIELD top\nFLOC 3 12\n FGROUP\"Alignment Layer\"\nCHECKLIST\"Top\" \"alg\"\n ENDFIELD\n\n")
	fprintf( frmfle "FIELD bottom\nFLOC 3 14\nFGROUP \"Alignment Layer\"\nCHECKLIST \"Bottom\" \"alg\"\nENDFIELD\n\n")
	fprintf( frmfle "FIELD both\nFLOC 3 16\nFGROUP \"Alignment Layer\"\nCHECKLIST \"Both\" \"alg\"\nENDFIELD\n\n")
	fprintf( frmfle "FIELD horizontal\nFLOC 3 5\nFGROUP \"Direction\"\nCHECKLIST \"Horizontal\" \"dirg\"\nENDFIELD\n\n")
	fprintf( frmfle "FIELD vertical\nFLOC 3 7\nFGROUP \"Direction\"\nCHECKLIST \"Vertical\" \"dirg\"\nENDFIELD\n\n")
	fprintf( frmfle "FIELD origin\nFLOC  35 7\nFGROUP \"Alignment Point\" \nCHECKLIST \"Origin\" \"alpg\"\nENDFIELD\n\n")
	fprintf( frmfle "FIELD pin\nFLOC  35 5\nFGROUP \"Alignment Point\" \nCHECKLIST \"Pin 1\" \"alpg\"\nENDFIELD\n\n")
	fprintf( frmfle "FIELD group\nFLOC  25 12\nFGROUP \"Select Mode\"\nCHECKLIST \"Group\" \"slmg\"\nENDFIELD\n\n")
	fprintf( frmfle "FIELD window\nFLOC  25 14\nFGROUP \"Select Mode\"\nCHECKLIST \"Window\" \"slmg\"\nENDFIELD\n\n")
	fprintf( frmfle "FIELD tolerance\nFLOC  25 16\nFGROUP \"Select Mode\"\nCHECKLIST \"Tolerance\" \"slmg\"\nENDFIELD\n\n")
	fprintf( frmfle "FIELD tol\nFLOC  40 16\nFGROUP \"Select Mode\"\nREALFILLIN 10 10\n DECIMAL 4\nENDFIELD\n\n")
	fprintf( frmfle "FIELD class\nFLOC 40 18\nFGROUP \"Select Mode\"\nENUMSET 12\nPOP \"CURSPOP\"\nENDFIELD\n\n")
	fprintf( frmfle "FIELD done\nFLOC 2 22\n MENUBUTTON \"Done\" 9 3\nENDFIELD\n\n")
	fprintf( frmfle "FIELD print\nFLOC 28 22\n MENUBUTTON \"Print\" 9 3\n POP \"PRINTP\"\nENDFIELD\n\n")
	fprintf( frmfle "FIELD cancel\nFLOC 55 22\n MENUBUTTON \"Cancel\" 9 3\nENDFIELD\n\n")
 
	fprintf( frmfle "GROUP \"Alignment Layer\"\nGLOC 2 10\nGSIZE 20 11\nENDGROUP\n\n")
	fprintf( frmfle "GROUP \"Direction\"\nGLOC 2 2\nGSIZE 30 8\nENDGROUP\n\n")
	fprintf( frmfle "GROUP \"Alignment Point\"\nGLOC 34 2\nGSIZE 30  8\nENDGROUP\n")
	fprintf( frmfle "GROUP \"Select Mode\"\nGLOC 24 10\nGSIZE 40 11\nENDGROUP\n\n")
	fprintf( frmfle "\nENDTILE\n\nENDFORM\n")
	close(frmfle)
);end-defun

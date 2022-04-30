	/*
	############################################################################                                                                    
	#                      Command: hlvia                                      #
	#                   Skill File: hlvia.il                                   #
	#                  How To Load: Command> (load("hlvia.il"))               #
	#               How To Execute: Command> hlvia 			           #
	#               Write by Rock.guo@2007.09.13  deargds@163.com              #
	############################################################################
	*/
axlCmdRegister( "hlvia" `hlvia)

( defun hlvia ()
	
	axlLayerCreateNonConductor("BOARD GEOMETRY/NULLVIA")
	axlDBCreatePropDictEntry( "nullvia", "BOOLEAN", list( "lines")) 
	delmark()
	axlClearSelSet() 
	axlVisibleDesign( nil) 
	axlVisibleLayer( "VIA CLASS/TOP" t)
	axlVisibleLayer( "VIA CLASS/BOTTOM" t)
	axlVisibleUpdate(t)
	axlSetFindFilter( ?enabled 
	list("noall" "vias") ?onButtons 
	list("noall" "vias")) 
	axlAddSelectAll() 
	all= axlGetSelSet()
	print(sprintf(nil "Total Vias Count: %L" length(all)))
	foreach( p all
	pn= p->net->name
	if((pn == nil) then
	mark( p->xy)
	))
	axlVisibleDesign( nil)
	axlVisibleLayer( "BOARD GEOMETRY/OUTLINE" t)
	axlVisibleLayer( "PIN/TOP" t)
	axlVisibleLayer( "PIN/BOTTOM" t)
	axlVisibleLayer( "ETCH/TOP" t)
	axlVisibleLayer( "ETCH/BOTTOM" t)
	axlVisibleLayer( "VIA CLASS/TOP" t)
	axlVisibleLayer( "VIA CLASS/BOTTOM" t)
	axlVisibleLayer( "ROUTE KEEPIN/ALL" t)
	axlVisibleLayer( "BOARD GEOMETRY/NULLVIA" t)
	axlClearSelSet()
	axlVisibleUpdate(t)
)
( defun mark ( o )
	
	j= 15
	m= axlDBCreateLine( list((nth(0 o)+j:nth(1 o)) (nth(0 o)-j:nth(1 o)))  5 "BOARD GEOMETRY/NULLVIA")
	axlDBAddProp(car(m) '("nullvia" "TRUE")) 
	n= axlDBCreateLine( list((nth(0 o):nth(1 o)+j) (nth(0 o):nth(1 o)-j))  5 "BOARD GEOMETRY/NULLVIA") 
	axlDBAddProp(car(n) '("nullvia" "TRUE"))
)

( defun delmark ()

	axlClearSelSet() 
	axlVisibleDesign( nil) 
	axlVisibleLayer( "BOARD GEOMETRY/NULLVIA" t)
	axlVisibleUpdate(t)
	axlSetFindFilter( ?enabled 
	list("noall" "lines") ?onButtons 
	list("noall" "lines")) 
	axlAddSelectAll() 
	foreach( dp axlGetSelSet()
	prop = axlDBGetProperties(dp )
	if( caar(prop)== 'NULLVIA then
	axlDeleteObject(dp) 
	))
	axlClearSelSet()
)
;Written by Leon Lee. 2006/02/22
;Modified By Jonathan Dumaresq. 2008/07/17
; Modified by Venkata Ramanan 2008/10/10
; Use the new API for 16.x
; Extract XSection
; Copper Layer, interlayer and thinkness of it.
; USE at your own risk. This is my first skill program.
; to use it, Juste type XSection2 in your skill windows. 

; Comments by Venkata
; Different type of shape for signal and plane
; Display total number of layers
; Add the Dielectric type in the dielectric box


axlCmdRegister( "xs" `XSectionc ?cmdType "interactive")

defun( XSectionc ()
  stack_layer="MANUFACTURING/STACKUP_FIGURE"
  axlClearSelSet() ; Removes all dbids from select set. 
  Display=axlVisibleGet() ; Returns the visibility of the entire design - which layers are visible/invisible. 
  axlVisibleDesign(nil) ;Makes entire design visible or invisible
  axlVisibleLayer(stack_layer t) ; Sets a given layer to visible or invisible t means visible
  axlDBRefreshId(axlDBGetDesign()) ; refresh the dbid
  axlSetFindFilter(?enabled '(noall shapes text) ?onButtons '(noall shapes text));Sets up both the object types to be displayed in the Find Filter
  ; here only shapes and text
  
  axlDeleteObject(axlGetSelSet(axlAddSelectAll()))
  axlVisibleSet(Display)
;  axlShell("redisplay")
l_layer=axlGetXSection() ; get the stackup information
nbLayer = length(l_layer); will return the number of layers

noflayers = nbLayer-2

printf("Number of Layers: %d\n" nbLayer)
;printf("%L" l_layer)

l_DBUnits = axlDBGetDesignUnits(); Get Design units retursn ("mils" 4)
Unit=nth(0 l_DBUnits) ; set the 0th value as unit
case(Unit
	("millimeters" u=1)
	("mils" u=40)
	("inches" u=0.04)
	("microns" u=1000)
	("centimeters" u=0.1)
);end case
; set u depending in the unit value

L=50*u	; Length of bounding box

H=-1*(5+nbLayer*4)*u ; height of bounding box

s_Accuracy = nth(1 l_DBUnits); set accuracy

nLayer=nil
declare( layer[nbLayer]) ; declare an array of nbLayer number of elements
arrayp(layer); check if an object is array
for(lay 0 nbLayer-1 layer[lay]=car( nth( lay l_layer))

;printf("%s \n" layer[lay])
; for x =0 to length(nbLayer)-1, car Returns the first element of a list

	nLayer=append(nLayer list(lay+1 layer[lay]))

	printf("%d  %s \n" lay+1 layer[lay]) ; append lay 0+1 and the equivalent element of layer
	
	if(lay=nbLayer-1
	test = lay+1
				)
	
	axlClearDynamics()
	mypath = axlPathStart(list( 0:0 L:0 L:H 0:H 0:0))
	axlAddSimpleMoveDynamics(0:0 mypath "path" ?ref_point 0:0)
);for

printf("Enter a point to place the X-Section Figure...\n")
;printf("%d \n" test)
if(axlIsLayer(stack_layer)==nil then
	axlLayerCreateNonConductor(stack_layer)
);if
(axlUIWRedraw nil)
axlVisibleLayer(stack_layer t)

pointStart=nil
declare( point[nbLayer])
declare( bBox[nbLayer])
declare( bBox1[nbLayer])
declare( bBox2[nbLayer])

declare( layerName[nbLayer])
declare( layerType[nbLayer])
declare( pointType[nbLayer])

pointStart=axlEnterPoint()
Px=xCoord(pointStart)
Py=yCoord(pointStart)

totalThickness = 0;
for(p 1 nbLayer-2

testlayername =  nth(1 nth( p l_layer))
printf("\n" testlayername)
case( testlayername
  ("DIELECTRIC"  point[p]=list(Px+37*u Py-(p+2)*4*u)
 		pointType[p]=list(Px+22.5*u Py-(p+2)*4*u)
		bBox[p]=list(list(Px+10*u Py-(p+2.5)*4*u) list(Px+35*u Py-(p+2)*4*u+4.2*u))
		axlDBCreateRectangle(bBox[p], nil, stack_layer)
		f_Thickness = ConvertValue(atof(nth(3 nth( p l_layer))) Unit)
		s_Temp = FormatValue(f_Thickness s_Accuracy Unit)
		layerName[p] = strcat( nth(1 nth( p l_layer)) " (" s_Temp ")") 
		myorient=make_axlTextOrientation(?textBlock "4",?rotation 0., ?mirrored nil, ?justify "left")
		myorient1=make_axlTextOrientation(?textBlock "4",?rotation 0., ?mirrored nil, ?justify "center")
		layerType[p]= nth(2 nth( p l_layer))  
		
		axlDBCreateText(layerName[p], point[p], myorient, stack_layer,nil)
		
		axlDBCreateText(layerType[p], pointType[p], myorient1, stack_layer,nil)
		)
("PLANE" 	point[p]=list(Px+45*u Py-(p+2)*4*u)
		bBox[p]=list(list(Px+5*u Py-(p+1.9)*4*u) list(Px+40*u Py-(p+1.9)*4*u+1.5*u))
		axlDBCreateRectangle(bBox[p], t, stack_layer)
		f_Thickness = ConvertValue(atof(nth(3 nth( p l_layer))) Unit)
		s_Temp = FormatValue(f_Thickness s_Accuracy Unit)
		layerName[p]= strcat( car( nth( p l_layer)) " (" s_Temp ")") 
	)

("CONDUCTOR" 	point[p]=list(Px+45*u Py-(p+2)*4*u)
		bBox[p]=list(list(Px+5*u Py-(p+1.9)*4*u) list(Px+15*u Py-(p+1.9)*4*u+1.5*u))
		bBox1[p]=list(list(Px+17.5*u Py-(p+1.9)*4*u) list(Px+27.5*u Py-(p+1.9)*4*u+1.5*u))
		bBox2[p]=list(list(Px+30*u Py-(p+1.9)*4*u) list(Px+40*u Py-(p+1.9)*4*u+1.5*u))
		
		axlDBCreateRectangle(bBox[p], t, stack_layer)
		axlDBCreateRectangle(bBox1[p], t, stack_layer)
		axlDBCreateRectangle(bBox2[p], t, stack_layer)
		
		f_Thickness = ConvertValue(atof(nth(3 nth( p l_layer))) Unit)
		s_Temp = FormatValue(f_Thickness s_Accuracy Unit)
		layerName[p]= strcat( car( nth( p l_layer)) " (" s_Temp ")") 
	)
	);end case

	myorient=make_axlTextOrientation(?textBlock "4",?rotation 0., ?mirrored nil, ?justify "left")
	axlDBCreateText(layerName[p], point[p], myorient, stack_layer,nil)
	totalThickness = totalThickness + f_Thickness
);for

	printf("total thickness = %s \n" FormatValue(totalThickness s_Accuracy Unit))

; Added this case for Counting the number of Layers

	case(test
	(5 textx="STACKUP: 2 LAYERS")
	(9 textx="STACKUP: 4 LAYERS")
	(13 textx="STACKUP: 6 LAYERS")
	(17 textx="STACKUP: 8 LAYERS")
	(21 textx="STACKUP: 10 LAYERS")
	(25 textx="STACKUP: 12 LAYERS")
	(29 textx="STACKUP: 14 LAYERS")
	(33 textx="STACKUP: 16 LAYERS")
	(37 textx="STACKUP: 18 LAYERS")
	(41 textx="STACKUP: 20 LAYERS")
	(45 textx="STACKUP: 22 LAYERS")
	(49 textx="STACKUP: 24 LAYERS")
	(53 textx="STACKUP: 26 LAYERS")
	(57 textx="STACKUP: 28 LAYERS")
	(61 textx="STACKUP: 30 LAYERS")
	(65 textx="STACKUP: 32 LAYERS")
	(69 textx="STACKUP: 34 LAYERS")
	(73 textx="STACKUP: 36 LAYERS")
	(77 textx="STACKUP: 38 LAYERS")
	(81 textx="STACKUP: 40 LAYERS")
	(85 textx="STACKUP: 42 LAYERS")
	(89 textx="STACKUP: 44 LAYERS")
	(93 textx="STACKUP: 46 LAYERS")
	(97 textx="STACKUP: 48 LAYERS")
	(101 textx="STACKUP: 50 LAYERS")
	
);end case
	
	
	
	axlDBCreateText(textx,list(Px+3*u Py-4*u), myorient, stack_layer,nil)
	axlDBCreateRectangle(list(list(Px Py) list(Px+100*u yCoord(point[nbLayer-2])-5*u)), nil, stack_layer)
sTotalThickness = FormatValue(totalThickness s_Accuracy Unit)
sTotalThickness = strcat(sTotalThickness " +/-10%")

	axlDBCreateText(strcat("TOTAL THICKNESS: " sTotalThickness ),list(Px+3*u Py-4*u*(nbLayer+1)), myorient, stack_layer,nil)
);defun
;
; Format a value to string with user Accuracy
defun( FormatValue ( f Accuracy sUnit)
case(Accuracy
	("0" sprintf( nil "%.0f %s" f sUnit) )
	("1" sprintf( nil "%.1f %s" f sUnit) )
	("2" sprintf( nil "%.2f %s" f sUnit) )
	("3" sprintf( nil "%.3f %s" f sUnit) )
	("4" sprintf( nil "%.4f %s" f sUnit) )
	("5" sprintf( nil "%.5f %s" f sUnit) )
	("6" sprintf( nil "%.6f %s" f sUnit) )
	(0 sprintf( nil "%.0f %s" f sUnit) )
	(1 sprintf( nil "%.1f %s" f sUnit) )
	(2 sprintf( nil "%.2f %s" f sUnit) )
	(3 sprintf( nil "%.3f %s" f sUnit) )
	(4 sprintf( nil "%.4f %s" f sUnit) )
	(5 sprintf( nil "%.5f %s" f sUnit) )
	(6 sprintf( nil "%.6f %s" f sUnit) )
);end case
);defun
; Convert the thickness from default, mils, to user units
defun( ConvertValue ( f sUnit)
case(sUnit
	("millimeters" f/39.37)
	("mils" f/1)
	("inches" f/1000)
	("microns" f/39370)
	("centimeters" f/393.7)
);end case
);defun

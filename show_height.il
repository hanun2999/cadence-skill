;***********************************************
;
;                Show Height Text
;
;
;THIS PROGRAM IS PROVIDED "AS IS", AND IS NOT SUPPORTED BY
;CADENCE DESIGN SYSTEMS.
;
; Starting with version 14.0 the height text was changed from
;plain text to a property attached to the place bound shape.
;As a result of this change users were no longer able to
;generate plots that showed the component heights.
;
;This program will search for component height properties
;attached to place bound shapes. The value of the properties 
;will be entered as text and placed next to the place bound
;shape. Users will then be able to print drawings with the 
;height of the components visible. If the program is run on
;a design a second time any height text that has been added
;will be deleted and regenerated.
;
; To use this program load this file show_height.il and from
;the Allegro/APD command line use the command  show_height
;
;
;Author: Ron Guthrie
;	Principal Support AE
;	Cadence Design Systems
;	
;Date: August 2002.
;
;Version 1.0 - Initial release.
;	   1.01- (RG) Correction for place_bot in Allegro
;	   1.02- (RG) Change subclass from HEIGHT_TEXT_BOT to be HEIGHT_TEXT_BOTTOM
;		This change is to prevent errors when mirroring components
;
;***********************************************
;
defun(show_height ()
  visibility=axlVisibleGet()	;Save layer visibility
; turn all colors off
  axlVisibleDesign(nil)
; turn color on for place bounds
;


;=================================================
;To Do
;
;If the layer does not exist then create the layer
;
;=================================================
;Initialize variables
t_block="1"
t_rotate = 0.0
t_mirror_top=nil
t_mirror_bot=t
t_just="right"
max_offset=0.0
min_offset=0.0
max = "PACKAGE_HEIGHT_MAX"
min = "PACKAGE_HEIGHT_MIN"

;Check to see which editor is being used APD or Allegro

if( axlDesignType(t)=="MCM"
then		;running APD
	place_top = "PART GEOMETRY/PLACE_BOUND_TOP"
	place_bot = "PART GEOMETRY/PLACE_BOUND_BOTTOM"
	t_layer_top="PART GEOMETRY/HEIGHT_TEXT_TOP"
	t_layer_bot="PART GEOMETRY/HEIGHT_TEXT_BOTTOM"
	
else		;running Allegro
	place_top = "PACKAGE GEOMETRY/PLACE_BOUND_TOP"
	place_bot = "PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM"
	t_layer_top="PACKAGE GEOMETRY/HEIGHT_TEXT_TOP"
	t_layer_bot="PACKAGE GEOMETRY/HEIGHT_TEXT_BOTTOM"
);endif tool check


;If the layer exists then warn the user the existing
;text will be deleted. Otherwise just create the layers.
if( axlIsLayer(t_layer_top) 
then
	axlUIConfirm( "show_height has been run on this design. Any text on the HEIGHT_TEXT layers will be deleted.\n")
	axlClearSelSet()
	axlVisibleLayer(t_layer_top t)  
	axlVisibleLayer(t_layer_bot t)
	axlSetFindFilter(?enabled '(noall text) ?onButtons '(noall text))
	axlVisibleLayer(t_layer_top t)  
	axlVisibleLayer(t_layer_bot t)
	axlAddSelectAll()
	l_text=axlGetSelSet()
	axlDeleteObject(l_text)
else  ;Create the layers and make them visible.
	axlLayerCreateNonConductor(t_layer_top)
	axlLayerCreateNonConductor(t_layer_bot)
	axlVisibleLayer(t_layer_top t)  
	axlVisibleLayer(t_layer_bot t)
);endif layer check

axlVisibleLayer(place_top t)  
axlVisibleLayer(place_bot t)

units = axlDBGetDesignUnits()	;Find the design units to set the offset values

case( car(units)
	( "mils"
	  max_offset=5
	  min_offset=40
	)
	( "inches"
	  max_offset=0.005
	  min_offset=0.040
	)
	( "millimeters"
	  max_offset=0.127
	  min_offset=1.016
	)
	( "centimeters"
	  max_offset=0.0127
	  min_offset=0.1016
	)
	( t
	  println( "Not set up for Microns")
	)
);case

axlSetFindFilter(?enabled '(noall shapes) ?onButtons '(noall shapes))
board_ext = axlExtentLayout()
axlSingleSelectBox(board_ext)		;select all of the shapes within the board outline
l_shapes=axlGetSelSet()

txt_orient_top=make_axlTextOrientation(?textBlock t_block ?rotation t_rotate ?mirrored t_mirror_top ?justify t_just)
txt_orient_bot=make_axlTextOrientation(?textBlock t_block ?rotation t_rotate ?mirrored t_mirror_bot ?justify t_just)

foreach( shape l_shapes
	ur=upperRight(shape->bBox)
	x=car(ur)
	y1=cadr(ur)
	l_props=shape->prop->??

	if( l_props!=nil 
	then		;check to make sure there are attached properties.
		foreach( prop l_props		;step through each property
			sprintf(s_prop "%s", prop)
			if( s_prop == max 
			then
				if( length(l_props)>2	;Are both min and max defined?
				then
					max_ht=cadr(l_props->?)
				else
					max_ht=car(l_props->?)
				);endif length
				
				y=y1+max_offset
				if( shape->layer== place_top
				then
					axlDBCreateText( max_ht x:y txt_orient_top t_layer_top shape)
				else
					axlDBCreateText( max_ht x:y txt_orient_bot t_layer_bot shape)
				);endif layer
			else
			  if( s_prop == min 
			  then
				shape_layer=shape->layer
				min_ht=car(l_props->?)
				y=y1+min_offset
				if( shape->layer == place_top
				then
					axlDBCreateText( min_ht x:y txt_orient_top t_layer_top shape)
				else
					axlDBCreateText( min_ht x:y txt_orient_bot t_layer_bot shape)
				);endif layer
			  );end if prop min
			);end if prop max
		);end foreach
	);end if
);end foreach

;reset the display back to what it was.
axlVisibleSet(visibility)
axlClearSelSet()
);end defun

;Register the command show_height.
axlCmdRegister("show_height" 'show_height )

axlCmdRegister( "r2c" 'RefDestoCenter ?cmdType "interactive" ?doneCmd  'ps_RefDestoCenterstop ?cancelCmd 'ps_RefDestoCenterstop )

procedure( RefDestoCenter( )
	let(
		( lLayer_name
			PI
			ps_RefDestoCenter_From_file
			ps_RefDestoCenter_From
			sPackageLayer
			bStop 
			lBlock 
			bSym
			bLayer
			lSym
			lText
			bText_status
			dShape
			dShape_temp
			fDelta_y
			fSym_center_x
			fSym_center_y
			fSym_left_x
			fSym_left_y
			fSym_right_x
			fSym_right_y
			fSym_x
			fSym_y
			fSym_xy
			fText_rot
			lShape
			lSym_shape_box
			rText_orient
		)
		if( compareTime("Dec 12 16:35:55 2020" getCurrentTime() )>0 && compareTime("Aug 10 16:35:55 2009" getCurrentTime() )<0 then

			PI = 3.1415926 
			bStop = t
			lBlock 		
			lLayer_name = list( "Assembly TOP" "SilkScreen TOP" "Assembly BOTTOM" "SilkScreen BOTTOM" "Move All" )
	
			ps_RefDestoCenter_From_file = strcat( axlTempDirectory() "./ps_RefDestoCenter_From.form" )
	    
	    ; create the Move RefDes To Body Center form
	    ps_RefDestoCenter_From = outfile( ps_RefDestoCenter_From_file "w" )
	  	fprintf( ps_RefDestoCenter_From "FILE_TYPE=FORM_DEFN VERSION=2\n" )
			fprintf( ps_RefDestoCenter_From "FORM\n" )
			fprintf( ps_RefDestoCenter_From "FIXED\n" )
			fprintf( ps_RefDestoCenter_From "PORT 29 20\n" )
			fprintf( ps_RefDestoCenter_From "HEADER \"ps_RefDestoCenter\"\n" )
		
			fprintf( ps_RefDestoCenter_From "POPUP <select_layer_name_p>" )
			fprintf( ps_RefDestoCenter_From "\"a\"\"a\"" )
			fprintf( ps_RefDestoCenter_From "\n" )
			
			fprintf( ps_RefDestoCenter_From "TILE\n" )
	
	  	fprintf( ps_RefDestoCenter_From "TEXT \"Select visible layer:\"\n" )
			fprintf( ps_RefDestoCenter_From "TLOC 2 1\n" )
			fprintf( ps_RefDestoCenter_From "ENDTEXT\n" )	
			
		 	fprintf( ps_RefDestoCenter_From "FIELD select_layer_name\n" )
	   	fprintf( ps_RefDestoCenter_From "FLOC 11 3\n" )
	   	fprintf( ps_RefDestoCenter_From "ENUMSET 13\n" )
	   	fprintf( ps_RefDestoCenter_From "POP \"select_layer_name_p\"\n" )
	   	fprintf( ps_RefDestoCenter_From "ENDFIELD\n" )
	
			fprintf( ps_RefDestoCenter_From "TEXT \"Move mode:\"\n" )
			fprintf( ps_RefDestoCenter_From "TLOC 2 5\n" )
			fprintf( ps_RefDestoCenter_From "ENDTEXT\n" )	
			
			fprintf( ps_RefDestoCenter_From "FIELD Layer_mode\n" )
	   	fprintf( ps_RefDestoCenter_From "FLOC 11 5\n" )
	  	fprintf( ps_RefDestoCenter_From "CHECKLIST \"By Layer\" \"radioLabel\"\n" )
	  	fprintf( ps_RefDestoCenter_From "ENDFIELD\n" )
			
			fprintf( ps_RefDestoCenter_From "FIELD Sym_mode\n" )
	  	fprintf( ps_RefDestoCenter_From "FLOC 11 7\n" )
	  	fprintf( ps_RefDestoCenter_From "CHECKLIST \"By Symbol\" \"radioLabel\"\n" )
	  	fprintf( ps_RefDestoCenter_From "ENDFIELD\n" )
			
			fprintf( ps_RefDestoCenter_From "FIELD aspcRun\n" )
			fprintf( ps_RefDestoCenter_From "FLOC 16 9\n" )
			fprintf( ps_RefDestoCenter_From "MENUBUTTON \"Run\" 11 3\n" )
			fprintf( ps_RefDestoCenter_From "ENDFIELD\n" )
	
			fprintf( ps_RefDestoCenter_From "FIELD aspcHelp\n" )
			fprintf( ps_RefDestoCenter_From "FLOC 2 9\n" )
			fprintf( ps_RefDestoCenter_From "MENUBUTTON \"Help\" 11 3\n" )
			fprintf( ps_RefDestoCenter_From "ENDFIELD\n" )		
			fprintf( ps_RefDestoCenter_From "ENDTILE\n" )
			fprintf( ps_RefDestoCenter_From "ENDFORM\n" )
			close( ps_RefDestoCenter_From )
	
			ps_RefDestoCenter_From = axlFormCreate( (gensym) ps_RefDestoCenter_From_file '(e inner) 'ps_RefDestoCenter_Routine t )
			ps_RefDestoCenter_From = axlMiniStatusLoad( (gensym) ps_RefDestoCenter_From_file  'ps_RefDestoCenter_Routine )
			
			; set default value to form field
			axlFormBuildPopup( ps_RefDestoCenter_From "select_layer_name" lLayer_name )
			axlFormSetField( ps_RefDestoCenter_From "select_layer_name" "Assembly TOP" )
			axlFormSetField( ps_RefDestoCenter_From "Sym_mode" t )
			axlFormSetFieldVisible( ps_RefDestoCenter_From "aspcRun" 0 )
			axlFormDisplay( ps_RefDestoCenter_From )
			deleteFile( ps_RefDestoCenter_From_file )
	
			; default visible layer is Assembly Top
			axlVisibleDesign( nil )
			axlVisibleLayer( "Board Geometry/Assembly_TOP" t )	
			axlVisibleLayer( "Board Geometry/Outline" t )	
			axlVisibleLayer( "Drawing Format/Title_Block" t )					
			axlVisibleLayer( "Drawing Format/Outline" t )	
			axlVisibleLayer( "Package Geometry/Assembly_Top" t )	
			axlVisibleLayer( "Ref Des/Assembly_Top" t )	
			axlVisibleLayer( "Pin/Top" t )		
			axlFlushDisplay()					
			
			sPackageLayer = "PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM"						
			axlMsgPut( "Please select a symbol to move its Refdes in By Symbol mode;" )
			axlMsgPut( "or select a layer to move all the Refdes in By Layer mode!" )
			
			while( bStop
					bSym = axlFormGetField( ps_RefDestoCenter_From "Sym_mode" )
					bLayer = !bSym
					while( bStop && bSym
							axlFormSetFieldVisible( ps_RefDestoCenter_From "aspcRun" 0 )
							axlSetFindFilter(?enabled '("NOALL" "symbols" ) ?onButtons '("symbols" ))
							axlMsgPut( "Please select a symbol to Move its Refdes." )
							if(	axlSelect() then
									lSym = axlGetSelSet( )
									
									axlClearSelSet()
									axlSetFindFilter( ?enabled ( list "NOALL"  "TEXT" ) ?onButtons ( list "NOALL" "TEXT" ) )
			    				lText = axlGetSelSet( axlAddSelectAll( ) )								
			    				axlClearSelSet()
									
									; get text block info, store them in a list
									; if some block text are not rotate 0, 90, 180 or 270 degree, then need to re-create a some block text
									; and get its block info
									lBlock = nil
									foreach( dText lText
											unless( member( dText->textBlock lBlock )
													lBlock = cons( dText->textBlock lBlock )
													if( dText->rotation == 0.0 || dText->rotation == 180.0 
													then
															fDelta_y = ( cadadr( dText->bBox ) - cadar( dText->bBox ) )*0.32
													else
															if( dText->rotation == 90.0 || dText->rotation == 270.0 
															then
																	fDelta_y = ( caadr( dText->bBox ) - caar( dText->bBox ) )*0.32
															else
			    												rText_orient = make_axlTextOrientation(
																					?textBlock dText->textBlock, ?rotation 0.0,
																					?mirrored dText->isMirrored, ?justify dText->justify 
																	)
			    												bText_status = caar( axlDBCreateText( dText->text, 0:0, rText_orient, dText->layer, nil )	)	
			    												fDelta_y = 	( cadadr( bText_status->bBox ) - cadar( bText_status->bBox ) )*0.32	
			    												axlDeleteObject( list( bText_status ) )													
															)
													); end if
													lBlock = cons( fDelta_y lBlock )
											)
									); end foreach		    
									lBlock = reverse( lBlock )
					
									; move RefDes to Symbol Body Center
									foreach( dSym lSym
											lShape = nil
											sPackageLayer = "PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM"		
											unless( dSym->isMirrored 
													sPackageLayer = "PACKAGE GEOMETRY/PLACE_BOUND_TOP"
											)
											foreach( dChild dSym->children
													when( dChild->objType == "shape" && dChild->layer == sPackageLayer  	
															lShape = cons( dChild	lShape )											
													)
											); end foreach child
															
											; when one symbol got more than one place boundry shapes,
											; need to find the largest one.
											when( lShape
													dShape_temp = car( lShape )
													unless( onep( length( lShape ) )
															for( n 1 length( lShape ) - 1
																	dShape = nth( n lShape )
																	unless(	axlDistance( car( dShape->bBox ) cadr( dShape->bBox ) ) < \
																					axlDistance( car( dShape_temp->bBox ) cadr( dShape_temp->bBox ) ) 
																					dShape_temp = dShape
																	)
															); end for		
													); end unless
													
													; get Shape center
													lSym_shape_box = dShape_temp->bBox
	 												fSym_left_x  = caar( lSym_shape_box )
	 												fSym_right_x = caadr( lSym_shape_box )
	 												fSym_left_y  = cadar( lSym_shape_box )
	 												fSym_right_y = cadadr( lSym_shape_box )
	 												fSym_center_x = ( fSym_left_x + fSym_right_x )*0.5
	 												fSym_center_y = ( fSym_left_y + fSym_right_y )*0.5		
													
													; get symbol RefDes, and move it to this shape center
	
			    								foreach( dText lText
			    										when( dText->parent == dSym && dText->text == dSym->refdes && substring( dText->layer 1 7 ) == "REF DES"
			    												
			    												; here still need to check original text orientation, and adjust text coordinate about 0.32 times
			    												fDelta_y = cadr( member( dText->textBlock lBlock ) )		
																	if( dText->isMirrored then
																			; if do not care some special degrees, like 90.287
																			; it will be easy
																			caseq( round( dSym->rotation / 45.0 )
																				(		( 0 1 2 7 )
																						fText_rot = round( dSym->rotation / 45.0 ) * 45.0
																				)
																				(		( 3 4 5 6 )
																						fText_rot = round( dSym->rotation / 45.0 ) * 45.0 + 180.0
																				)					
																			);end case	
																	else
																			caseq( round( dSym->rotation / 45.0 )
																				(		( 0 1 2 7 )
																						fText_rot = round( dSym->rotation / 45.0 ) * 45.0
																				)	
																				(		( 3 4 5 6	)
																						fText_rot = round( dSym->rotation / 45.0 ) * 45.0 + 180.0
																				)						
																			);end case						
																	);end if
																	
																	fSym_x = fSym_center_x + fDelta_y*sin( fText_rot * PI / 180.0 )
																	fSym_y = fSym_center_y - fDelta_y*cos( fText_rot * PI / 180.0 ) 
			    												
			    												rText_orient = make_axlTextOrientation(
																					?textBlock dText->textBlock, ?rotation fText_rot,
																					?mirrored dText->isMirrored, ?justify dText->justify 
																	)
			    														    												
			    												fSym_xy = fSym_x : fSym_y
			    												
			    												bText_status = car( axlDBCreateText( dText->text, fSym_xy, rText_orient, dText->layer, dSym )	)
			    												when( bText_status
			    														axlDeleteObject(  dText  )
			    												)
			    										); end when
			    								); end foreach
											); end when
									); end foreach dSym
							else
									unless( !bStop || axlFormGetField( ps_RefDestoCenter_From "Layer_mode" )
											axlMsgPut( "Wrong select, please select symbol!" )
									)
							); end if
							bSym = axlFormGetField( ps_RefDestoCenter_From "Sym_mode" )
					); end Symbol mode
					
					while( bStop && bLayer
							; in Layer mode, should set Run Button active
							axlFormSetFieldVisible( ps_RefDestoCenter_From "aspcRun" 1 )
							
							axlSetFindFilter(?enabled '("NOALL" "symbols" ) ?onButtons '("symbols" ))
							unless( !bStop || axlFormGetField( ps_RefDestoCenter_From "Sym_mode" )
									axlMsgPut( "Please select a layer, then click Run Button to move those RefDes on the layer!" )
							)
							when(	axlSelect(?prompt nil) 
									lSym = axlGetSelSet( )
									axlClearSelSet( )
							)
							bLayer = axlFormGetField( ps_RefDestoCenter_From "Layer_mode" )
					); end layer mode
			); end global while loop
		else
    	axlUIConfirm("E- the tool is expired, please contact EDA team")
    )
		axlMsgPut( "Done!" )
	)
); end procedure ps_RefDestoCenter

procedure( ps_RefDestoCenter_Routine( ps_RefDestoCenter_From )
  
  let(
    ( sLayer_active
			PI
			lBlock
			lSym
			lText
			sPackageLayer
			bText_status
			dShape
			dShape_temp
			fDelta_y
			fSym_center_x
			fSym_center_y
			fSym_left_x
			fSym_left_y
			fSym_right_x
			fSym_right_y
			fSym_x
			fSym_y
			fSym_xy
			fText_rot
			lShape
			lSym_shape_box
			rText_orient
			nCheck_All
    )
    PI = 3.1415926 
  	case( ps_RefDestoCenter_From->curField
  		( "select_layer_name"
				;axlCancelEnterFun( )
				;axlClearSelSet( )

  			sLayer_active = ps_RefDestoCenter_From->curValue
	 			case( sLayer_active
					( "Assembly TOP"
						axlVisibleDesign( nil )
						axlVisibleLayer( "Board Geometry/Assembly_TOP" t )	
						axlVisibleLayer( "Board Geometry/Outline" t )	
						axlVisibleLayer( "Package Geometry/Assembly_Top" t )	
						axlVisibleLayer( "Ref Des/Assembly_Top" t )
						axlVisibleLayer( "Pin/Top" t )		
					)
					( "SilkScreen TOP"
						axlVisibleDesign( nil )
						axlVisibleLayer( "Board Geometry/SilkScreen_TOP" t )	
						axlVisibleLayer( "Board Geometry/Outline" t )
						axlVisibleLayer( "Package Geometry/SilkScreen_Top" t )	
						axlVisibleLayer( "Pin/Top" t )
						axlVisibleLayer( "Ref Des/SilkScreen_Top" t )				
						axlVisibleLayer( "Route Keepin/All" t )		
						axlVisibleLayer( "Route Keepout/Top" t )	
						
						
					)
					( "Assembly BOTTOM"
						; display related layers, assembly or silkscreen Top/Bottom layer
						axlVisibleDesign( nil )
						axlVisibleLayer( "Board Geometry/Assembly_Bottom" t )	
						axlVisibleLayer( "Board Geometry/Outline" t )	
						axlVisibleLayer( "Package Geometry/Assembly_Bottom" t )	
						axlVisibleLayer( "Ref Des/Assembly_Bottom" t )
						axlVisibleLayer( "Pin/Bottom" t )
					)
					( "SilkScreen BOTTOM"
						axlVisibleDesign( nil )
						axlVisibleLayer( "Board Geometry/SilkScreen_BOTTOM" t )	
						axlVisibleLayer( "Board Geometry/Outline" t )
						axlVisibleLayer( "Package Geometry/SilkScreen_Bottom" t )	
						axlVisibleLayer( "Pin/Bottom" t )
						axlVisibleLayer( "Ref Des/SilkScreen_Bottom" t )				
						axlVisibleLayer( "Route Keepin/All" t )		
						axlVisibleLayer( "Route Keepout/BOTTOM" t )	
						
					)
					( "Move All"
						axlCancelEnterFun( )
						axlClearSelSet( )
						axlFormSetField( ps_RefDestoCenter_From "Layer_mode" t )
						axlVisibleDesign( nil )
						axlVisibleLayer( "Board Geometry/Assembly_TOP" t )	
						axlVisibleLayer( "Board Geometry/Outline" t )	
						axlVisibleLayer( "Package Geometry/Assembly_Top" t )	
						axlVisibleLayer( "Ref Des/Assembly_Top" t )		
						axlVisibleLayer( "Board Geometry/SilkScreen_TOP" t )	
						axlVisibleLayer( "Package Geometry/SilkScreen_Top" t )	
						axlVisibleLayer( "Pin/Top" t )
						axlVisibleLayer( "Ref Des/SilkScreen_Top" t )				
						axlVisibleLayer( "Route Keepin/All" t )		
						axlVisibleLayer( "Route Keepout/Top" t )	
						axlVisibleLayer( "Board Geometry/Assembly_Bottom" t )	
						axlVisibleLayer( "Package Geometry/Assembly_Bottom" t )	
						axlVisibleLayer( "Ref Des/Assembly_Bottom" t )
						axlVisibleLayer( "Board Geometry/SilkScreen_BOTTOM" t )	
						axlVisibleLayer( "Package Geometry/SilkScreen_Bottom" t )	
						axlVisibleLayer( "Pin/Bottom" t )
						axlVisibleLayer( "Ref Des/SilkScreen_Bottom" t )				
						axlVisibleLayer( "Route Keepin/All" t )		
						axlVisibleLayer( "Route Keepout/BOTTOM" t )	
					)					
				); end case
				axlFlushDisplay()	
				axlShell( "redisplay" )
  		)
  		( "Sym_mode"
				axlCancelEnterFun( )
				axlClearSelSet( )
  		)
  		( "Layer_mode"
				axlCancelEnterFun( )
				axlClearSelSet( )
  		)
  		( "aspcRun"
				axlCancelEnterFun( )
				axlClearSelSet( )
				sLayer_active = axlFormGetField( ps_RefDestoCenter_From	 "select_layer_name" )
				
				nCheck_All = 3
				unless( sLayer_active == "Move All"
						nCheck_All = 0
				)
				for( i 0 nCheck_All
					case( i
						( 0
						)
						( 1
							axlVisibleDesign( nil )
							axlVisibleLayer( "Board Geometry/SilkScreen_TOP" t )	
							axlVisibleLayer( "Board Geometry/Outline" t )
							axlVisibleLayer( "Package Geometry/SilkScreen_Top" t )	
							axlVisibleLayer( "Pin/Top" t )
							axlVisibleLayer( "Ref Des/SilkScreen_Top" t )				
							axlVisibleLayer( "Route Keepin/All" t )		
							axlVisibleLayer( "Route Keepout/Top" t )
							axlFlushDisplay()
						)
						( 2
							; display related layers, assembly or silkscreen Top/Bottom layer
							axlVisibleDesign( nil )
							axlVisibleLayer( "Board Geometry/Assembly_Bottom" t )	
							axlVisibleLayer( "Board Geometry/Outline" t )	
							axlVisibleLayer( "Package Geometry/Assembly_Bottom" t )	
							axlVisibleLayer( "Ref Des/Assembly_Bottom" t )
							axlFlushDisplay()
						)
						( 3
							axlVisibleDesign( nil )
							axlVisibleLayer( "Board Geometry/SilkScreen_BOTTOM" t )	
							axlVisibleLayer( "Board Geometry/Outline" t )
							axlVisibleLayer( "Package Geometry/SilkScreen_Bottom" t )	
							axlVisibleLayer( "Pin/Bottom" t )
							axlVisibleLayer( "Ref Des/SilkScreen_Bottom" t )				
							axlVisibleLayer( "Route Keepin/All" t )		
							axlVisibleLayer( "Route Keepout/BOTTOM" t )	
							axlFlushDisplay()
						)
					); end case 			
					
		 			axlClearSelSet()
		 			axlSetFindFilter(?enabled '("NOALL" "symbols" ) ?onButtons '("symbols" ))
					lSym = axlGetSelSet( axlAddSelectAll( ) )
								
					axlClearSelSet()			
					axlSetFindFilter( ?enabled ( list "NOALL"  "TEXT" ) ?onButtons ( list "NOALL" "TEXT" ) )
		    	lText = axlGetSelSet( axlAddSelectAll( ) )								
		    				
					; get text block info, store them in a list
					; if some block text are not rotate 0, 90, 180 or 270 degree, then need to re-create a some block text
					; and get its block info
					lBlock = nil
					foreach( dText lText
							unless( member( dText->textBlock lBlock )
									lBlock = cons( dText->textBlock lBlock )
									if( dText->rotation == 0.0 || dText->rotation == 180.0 then
											fDelta_y = ( cadadr( dText->bBox ) - cadar( dText->bBox ) )*0.32
									else
											if( dText->rotation == 90.0 || dText->rotation == 270.0 then
													fDelta_y = ( caadr( dText->bBox ) - caar( dText->bBox ) )*0.32
											else
		    									rText_orient = make_axlTextOrientation(
																	?textBlock dText->textBlock, ?rotation 0.0,
																	?mirrored dText->isMirrored, ?justify dText->justify 
													)
		    									bText_status = caar( axlDBCreateText( dText->text, 0:0, rText_orient, dText->layer, nil )	)	
		    									fDelta_y = 	( cadadr( bText_status->bBox ) - cadar( bText_status->bBox ) )*0.32	
		    									axlDeleteObject( list( bText_status ) )													
											)
									); end if
									lBlock = cons( fDelta_y lBlock )
							)
					); end foreach		    
					lBlock = reverse( lBlock )
				
					; move RefDes to Symbol Body Center
					foreach( dSym lSym
							lShape = nil
							sPackageLayer = "PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM"		
							unless( dSym->isMirrored 
									sPackageLayer = "PACKAGE GEOMETRY/PLACE_BOUND_TOP"
							)
							foreach( dChild dSym->children
									when( dChild->objType == "shape" && dChild->layer == sPackageLayer  	
											lShape = cons( dChild	lShape )											
									)
							); end foreach child
														
							; when one symbol got more than one place boundry shapes,
							; need to find the largest one.
							when( lShape
									dShape_temp = car( lShape )
									unless( onep( length( lShape ) )
											for( n 1 length( lShape ) - 1
													dShape = nth( n lShape )
													unless(	axlDistance( car( dShape->bBox ) cadr( dShape->bBox ) ) < \
															axlDistance( car( dShape_temp->bBox ) cadr( dShape_temp->bBox ) ) 
															dShape_temp = dShape
													)
											); end for		
									); end unless
										
									; get Shape center
									lSym_shape_box = dShape_temp->bBox
 									fSym_left_x  = caar( lSym_shape_box )
 									fSym_right_x = caadr( lSym_shape_box )
 									fSym_left_y  = cadar( lSym_shape_box )
 									fSym_right_y = cadadr( lSym_shape_box )
 									fSym_center_x = ( fSym_left_x + fSym_right_x )*0.5
 									fSym_center_y = ( fSym_left_y + fSym_right_y )*0.5		
										
									; get symbol RefDes, and move it to this shape center
		    					foreach( dText lText
		    							when( dText->parent == dSym && dText->text == dSym->refdes && substring( dText->layer 1 7 ) == "REF DES"
		    									
		    									; here still need to check original text orientation, and adjust text coordinate about 0.32 times
		    									fDelta_y = cadr( member( dText->textBlock lBlock ) )		
													if( dText->isMirrored then
															; if do not care some special degrees, like 90.287
															; it will be easy
															caseq( round( dSym->rotation / 45.0 )
																(		( 0 1 2 7 )
																		fText_rot = round( dSym->rotation / 45.0 ) * 45.0
																)
																(		( 3 4 5 6 )
																		fText_rot = round( dSym->rotation / 45.0 ) * 45.0 + 180.0
																)					
															);end case	
													else
															caseq( round( dSym->rotation / 45.0 )
																(		( 0 1 2 7 )
																		fText_rot = round( dSym->rotation / 45.0 ) * 45.0
																)	
																(		( 3 4 5 6	)
																		fText_rot = round( dSym->rotation / 45.0 ) * 45.0 + 180.0
																)						
															);end case						
													);end if
																
													fSym_x = fSym_center_x + fDelta_y*sin( fText_rot * PI / 180.0 )
													fSym_y = fSym_center_y - fDelta_y*cos( fText_rot * PI / 180.0 ) 
		    										
		    									rText_orient = make_axlTextOrientation(
																	?textBlock dText->textBlock,?rotation fText_rot,
																	?mirrored dText->isMirrored,?justify "center"
													)  
													; ?justify dText->justify
		    													    												
		    									fSym_xy = fSym_x : fSym_y
		    										
		    									bText_status = car( axlDBCreateText( dText->text, fSym_xy, rText_orient, dText->layer, dSym )	)
		    									when( bText_status
		    											axlDeleteObject(  dText  )
		    									)
		    							); end when
		    					); end foreach
							); end when
					); end foreach dSym
				); end for
				
				; load("MoveRefDestoBodyCenter.il")             r2c   RefDestoCenter 
				
				when( nCheck_All > 0 
		  			axlVisibleDesign( nil )
						axlVisibleLayer( "Board Geometry/Assembly_TOP" t )	
						axlVisibleLayer( "Board Geometry/Outline" t )	
						axlVisibleLayer( "Package Geometry/Assembly_Top" t )	
						axlVisibleLayer( "Ref Des/Assembly_Top" t )		
						axlVisibleLayer( "Board Geometry/SilkScreen_TOP" t )	
						axlVisibleLayer( "Package Geometry/SilkScreen_Top" t )	
						axlVisibleLayer( "Pin/Top" t )
						axlVisibleLayer( "Ref Des/SilkScreen_Top" t )				
						axlVisibleLayer( "Route Keepin/All" t )		
						axlVisibleLayer( "Route Keepout/Top" t )
						axlVisibleLayer( "Board Geometry/Assembly_Bottom" t )	
						axlVisibleLayer( "Package Geometry/Assembly_Bottom" t )	
						axlVisibleLayer( "Ref Des/Assembly_Bottom" t )
						axlVisibleLayer( "Board Geometry/SilkScreen_BOTTOM" t )	
						axlVisibleLayer( "Package Geometry/SilkScreen_Bottom" t )	
						axlVisibleLayer( "Pin/Bottom" t )
						axlVisibleLayer( "Ref Des/SilkScreen_Bottom" t )				
						axlVisibleLayer( "Route Keepin/All" t )		
						axlVisibleLayer( "Route Keepout/BOTTOM" t )	
						axlFlushDisplay()
						axlShell( "redisplay" )			
				)				
			); end aspcRun
  		( "aspcHelp"
				axlCancelEnterFun( )
				axlClearSelSet( )
				nvhtmBrowser( nvmmrbc_HELPPAGE )
  		)
  	); end case
 	); end let
); end ps_RefDestoCenter_Routine


procedure( ps_RefDestoCenterstop()

  axlFormClose( ps_RefDestoCenter_From )
	axlCancelEnterFun( )
	axlClearSelSet( )
	axlFlushDisplay( )
	axlShell( "redisplay" )
	bStop = nil
)
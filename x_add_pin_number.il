/*
############################################################################                                                                    
#                				                           #
#               add pin_number      command: apn			   #
#                    							   #
#               Write by deargds@2009.07.30  deargds@163.com    	   #
#                 							   #
############################################################################
*/
axlCmdRegister( "apn" 'x_add_pin_number )

defun( x_add_pin_number ()
let((p allsel)
	axlSetFindFilter( ?enabled 
	list("noall" "pins") ?onButtons 
	list("noall" "pins")) 
	    
	while( axlSelect() 
		axlHighlightObject(axlGetSelSet())
		allsel = axlGetSelSet()
	)
	case( axlUIGetUserData() -> doneState
		(done
		when( allsel != nil 
			foreach( p allsel
				when( p -> number == ""
					axlDBCreateText( 
						"?"                    
						p -> xy
						make_axlTextOrientation(
								?textBlock "1" ,
								?rotation  0 ,
								?mirrored  nil ,
								?justify  "CENTER" 
								) 
						"PACKAGE GEOMETRY/PIN_NUMBER"
						p
						)
				)
			)
		)
		)
		(cancel
			axlUIWPrint(nil "cancel")
		)
	)
))
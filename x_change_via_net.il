/*
################################################################################                                                                    
#                               by deargds                                     #
#                            deargds@163.com                                   #
################################################################################
*/
axlCmdRegister( "cvia" 'x_change_via_net)

defun( x_change_via_net ()
prog((p all vnet n_pad n_xy ch_via_logfile ch_via_logport flag)
		
	axlSetFindFilter( ?enabled 
	list("noall" "vias") ?onButtons 
	list("noall" "vias")) 
	    
	while( axlSelect() 
		axlHighlightObject(axlGetSelSet())
		all = axlGetSelSet()
	)
	
	case( axlUIGetUserData()->doneState
	
	(done
		when( all == nil then
			axlUIConfirm("You have select nothing!")
			return(nil)
		)
		
		vnet = axlUIDataBrowse('NET '(RETRIEVE_OBJECT) "Please select net" t)
		when( vnet == nil return(nil))
		
		ch_via_logfile = axlTempFile()
		ch_via_logport = outfile(ch_via_logfile) 
		flag = nil
		foreach( p all
			n_pad = p -> name
			n_xy = p -> xy
			if( axlDBIsFixed(p) then
				fprintf(ch_via_logport, "Ignore Change FIXED VIA @ %L\n" , p -> xy )
				flag = t
			else
				when( axlDBCreateVia(n_pad n_xy car(vnet))
					axlDeleteObject(p)
				)
			)
		)
		close(ch_via_logport) 
		when( flag axlUIWExpose(axlUIViewFileCreate(ch_via_logfile "Change Via Net Log" nil)))
	)
	
	(cancel
		axlUIWPrint(nil "cancel")
	)
	)
))
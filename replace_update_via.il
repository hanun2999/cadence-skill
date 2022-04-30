;*****************************************************
;
; Interactive command for replace via padstack definitions.
;
;
; The "replace_via" command allows the user to select
; multiple vias through a find by window.  If more than
; one via padstack name is found, the command will prompt
; the user for which via padstack name they wish to replace.
; The default text will be "***". This selection tells the
; command to replace all the vias found, regardless of the
; padstack name.  The command then prompts the user for
; the name of the new padstack.  It then replaces the vias.
;
;
; The "update_via" command is only useful in conjunction
; with the "replace_via" command.  Update via expects the
; user to select a single via.  It will then replace that
; via using the name of the new padstack supplied by the user
; the last time the "replace_via" command was executed.  If
; the "replace_via" command has not been run, "update_via"
; will do nothing.
;
;*****************************************************


axlCmdRegister("replace_via" `rplc_via)
axlCmdRegister("update_via" `update_via)

RPV_pstk_name = nil

;=========================================================
;==================== MAIN ROUTINE =======================
;=========================================================


(defun rplc_via ()
   (let ( box vias status )

	axlClearSelSet()
	axlSetFindFilter(?enabled `("NOALL" "VIAS")
			 ?onButtons `("VIAS"))

	box = axlEnterBox( ?prompts `("Select vias to replace."
				      "Complete Box"))

	if( RPV_pstk_name then
	    RPV_pstk_name = upperCase(axlUIPrompt(
			    "New Padstack Name:" RPV_pstk_name ))
	else
	    RPV_pstk_name = upperCase(axlUIPrompt( "New Padstack Name:" ))
	)

	if( RPV_pstk_name then
	    if( axlSingleSelectBox(box) then
		vias = axlGetSelSet()
		status = _RPVdoReplacement( vias )
	    else
		axlMsgPut( "No vias were found.")
	    )
	)

	axlClearSelSet()
	axlFinishEnterFun()

   );let
) ;end-defun




(defun update_via ()
   (let ( box vias status )

      if( (RPV_pstk_name != nil) then

	axlClearSelSet()
	axlSetFindFilter(?enabled `("NOALL" "VIAS")
			 ?onButtons `("VIAS"))

	point = axlEnterPoint( ?prompts "Select via to update.")

	if( axlSingleSelectPoint(point) then
	    vias = axlGetSelSet()
	    status = _RPVdoReplacement( vias )
	else
	    axlMsgPut( "No via was found.")
	)

	axlClearSelSet()
	axlFinishEnterFun()

      ); end if not nil

   );let
) ;end-defun




(defun _RPVdoReplacement ( vias )
 
 (prog (count prevPstk save_xy save_name match_list match_name status )

    count = 0
    match_name = "***"
    save_name = car(vias)->name
    match_list = cdr(vias)

    while( match_list
	if( ( car(match_list)->name != save_name ) then
	    match_name = upperCase(axlUIPrompt("Old Padstack Name:" "***"))
	    match_list = nil
	else
	    match_list = cdr(match_list)
	)
    )

    foreach( prevPstk vias

	if( (( match_name == "***" ) ||
	     ( match_name == upperCase(prevPstk->name) )) then

	    save_name = prevPstk->name
	    save_xy   = prevPstk->xy
	    axlDeleteObject( prevPstk )
	    status = axlDBCreateVia(RPV_pstk_name save_xy)

	    if( status == nil then
		axlMsgPut("Not able to add new padstack. Please check name.")
		status = axlDBCreateVia(save_name save_xy)
		return( nil )
	    else
		count = count + 1
	    )
	)
    )

    axlClearSelSet()  
    axlFlushDisplay()
    if( count == 0 then
	axlMsgPut("No vias were replaced. Please check padstack names.")
    )
    if( count > 1 then
	axlMsgPut("%d vias were replaced." count)
    )
    return( t )

 ) ;prog
) ;end-defun


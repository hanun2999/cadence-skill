;		Delete isolating vias Reference Designators
;	  	-------------------------------------------

;File name: jkdelete_isolating_vias.il
;Revision:0	
;date:07/13/2001
;Writen by: JIAKE/15924
;tel: 6540492
;e_mail: jiake@huawei.com

;This routine allowes the user to delete isolating vias .

;==================================================================
;			Main Function
;==================================================================


axlCmdRegister("del_via" `delete_via)	
(defun delete_via ()
	axlClearSelSet()
	axlSetFindFilter(?enabled `("NOALL" "VIAS") ?onButtons `("VIAS"))
	vias = axlGetSelSet(axlAddSelectAll())

	axlMsgPut("Processing vias ...") 
	i = 0
	foreach(via vias
		if(via->net == nil then
			axlDeleteObject(via)
			++i
		)
	)
	if(i != 0 then
		axlMsgPut("Removed %d isolating vias ." i) 
	else
		axlMsgPut("No find isolating via .")
	)
	axlClearSelSet()

);end_defun








;              	Check Refdes Direction Reference Designators
;	      	--------------------------------------------


;File name: jkcheck_no_refdes.il
;Revision:0	
;date:08/04/2001 
;Writen by: JIAKE/15924
;tel: 6540492

;
;This routine check the refdes direction . You can only type the command "ch_dir" , 
;and it will hilight the component which refdes is illegal to be placed.

;=====================================================================================


axlCmdRegister( "ch_noref" 'jkCheck_No_Refdes)

defun( jkCheck_No_Refdes ()

        axlVisibleDesign(nil)
 	axlVisibleLayer( "BOARD GEOMETRY/OUTLINE" t )
	axlVisibleLayer( "PIN/TOP" t )
	axlVisibleLayer( "PIN/BOTTOM" t )
	axlVisibleLayer( "REF DES/SILKSCREEN_TOP" t )
	axlVisibleLayer( "REF DES/SILKSCREEN_BOTTOM" t )
	axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_TOP" t )
	axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" t )

	logfile = axlDMOpenLog("no_refdes.log")
	fprintf(logfile "#Check the component without refdes . \n\n")
	fprintf(logfile "REF_DES  COORDIRATION\n")

	setq(allsym axlDBGetDesign()->symbols)
	axlDehighlightObject(allsym)
	noref = nil
	norefcnt = 0
	foreach(symbol allsym 
		text= axlDBGetAttachedText(symbol)
		txt = nil
		foreach(find text
			if(find->layer == "REF DES/SILKSCREEN_TOP" || 
			find->layer == "REF DES/SILKSCREEN_BOTTOM" then 									
				txt = find			
			)								
		)
		if(txt == nil && symbol->refdes != nil then 
			axlHighlightObject(symbol)
			fprintf(logfile "%-8s %L\n" symbol->refdes symbol->xy)
			;noref = cons(symbol->refdes noref)
			++norefcnt
		)
	);foreach-end

	fprintf(logfile "\nTotal of no refdes: %d\n" norefcnt)
	axlDMClose(logfile)
	
	axlMsgPut("Total component without refdes: %d\n" norefcnt)
	axlMsgPut("Components without refdes , please view logfile.")        
);defun_end


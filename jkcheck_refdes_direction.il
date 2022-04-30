;              	Check Refdes Direction Reference Designators
;	      	--------------------------------------------

; run load "jkcheck_refdes_direction.il"
;File name: jkcheck_refdes_direction.il
;Revision:1	
;date:08/04/2001 
;Writen by: JIAKE/15924
;tel: 6540492

;
;This routine check the refdes direction . You can only type the command "ch_dir" , 
;and it will hilight the component which refdes is illegal to be placed.

;=====================================================================================


axlCmdRegister( "ch_dir" 'jkCheck_Refdes_Direction)

defun( jkCheck_Refdes_Direction ()

        axlVisibleDesign(nil)
 	axlVisibleLayer( "BOARD GEOMETRY/OUTLINE" t )
	axlVisibleLayer( "PIN/TOP" t )
	axlVisibleLayer( "PIN/BOTTOM" t )
	axlVisibleLayer( "REF DES/SILKSCREEN_TOP" t )
	axlVisibleLayer( "REF DES/SILKSCREEN_BOTTOM" t )
	axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_TOP" t )
	axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" t )

	logfile = axlDMOpenLog("dir_error.log")
	fprintf(logfile "#Check the direction errores of refdes . \n\n")
	fprintf(logfile "REF_DES  COORDIRATION\n")
	
	setq(allsym axlDBGetDesign()->symbols)
	axlDehighlightObject(allsym)
	dir = nil	
	dircnt = 0
;	noref = nil
;	norefcnt = 0
	foreach(symbol allsym 	;n=0 ++n symbol=nthelem(n allsym)
		text= axlDBGetAttachedText(symbol)
		txt = nil
		foreach(find text
			if(find->layer == "REF DES/SILKSCREEN_TOP" || 
			find->layer == "REF DES/SILKSCREEN_BOTTOM" then 									
				txt = find			
			)								
		)
/*		if(txt == nil && symbol->refdes != nil then 
			axlHighlightObject(symbol)
			noref = cons(symbol->refdes noref)
			++norefcnt
		)
*/		if(txt != nil && txt->text != nil then
			axlMsgPut("Processing package : %s " txt->text)        
			if(txt->layer == "REF DES/SILKSCREEN_TOP" then
				if(abs(txt->rotation - 0.0) < 5.0 || abs(txt->rotation - 90.0) < 5.0 || 
				abs(txt->rotation - 360.0) < 5.0 then
				x = 0
				else
					axlHighlightObject(symbol)
					;dir = cons(symbol->refdes dir)
					fprintf(logfile "%-8s %L\n" txt->text symbol->xy)
					++dircnt
				)
			else if(txt->layer == "REF DES/SILKSCREEN_BOTTOM" then
				if(abs(txt->rotation - 0.0) < 5.0 || abs(txt->rotation - 270.0) < 5.0 || 
				abs(txt->rotation - 360.0) < 5.0 then
				x = 0
				else
					axlHighlightObject(symbol)
					;dir = cons(symbol->refdes dir)
					fprintf(logfile "%-8s %L\n" txt->text symbol->xy)
					++dircnt
				)
				)			
			)
			if(txt->isMirrored == t then
				if(txt->parent->isMirrored != t then				
					axlHighlightObject(symbol)
					;dir = cons(symbol->refdes dir)
					fprintf(logfile "%-8s %L\n" txt->text symbol->xy)
					++dircnt
				)
			else
				if(txt->parent->isMirrored == t then
					axlHighlightObject(symbol)
					;dir = cons(symbol->refdes dir)
					fprintf(logfile "%-8s %L\n" txt->text symbol->xy)
					++dircnt			
				)				
			)
		);if_end
		
	);foreach-end

	fprintf(logfile "\nTotal direction error of refdes: %d\n" dircnt)
	axlDMClose(logfile)
	
	axlMsgPut("Total direction error of refdes: %d\n" dircnt)       
	axlMsgPut("Refdes direction error , please view logfile.") 
;	axlMsgPut("Total of components without refdes is : %d %L .\nDone" norefcnt noref)        
);defun_end


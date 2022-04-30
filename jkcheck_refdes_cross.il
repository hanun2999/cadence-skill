;	Check the Interchange Refdes Reference Designators
;	  ----------------------------------------------


;File name: jkCheck_Refdes_Cross.il
;Revision:0	
;date:07/01/2001
;Writen by: JIAKE/15924
;tel: 6540492
;e_mail: jiake@huawei.com

;This routine allowes the user to checkes the interchange refdes and 
;display the yellow cross . Once this file is loaded and the user can 
;type the command : "ch_cross" at the Allegro command line , and it 
;will compelete the program to check the cross refdeses. Notes the 
;yellow crosses are saved on the layer : "MANUFACTURING/REFDES 
;DRC".If the user wants the refdes crosses out of the view, run the 
;command again or close the "MANUFACTURING/REFDES DRC" layer .

;==================================================================
;			Main Function
;==================================================================
axlCmdRegister( "ch_cross" 'jkCheck_Refdes_Cross)
defun( jkCheck_Refdes_Cross ()
        axlVisibleDesign(nil)
        
	axlVisibleLayer( "BOARD GEOMETRY/OUTLINE" t )
	axlVisibleLayer( "PIN/TOP" t )
	axlVisibleLayer( "PIN/BOTTOM" t )
	axlVisibleLayer( "REF DES/SILKSCREEN_TOP" t )
	axlVisibleLayer( "REF DES/SILKSCREEN_BOTTOM" t )
	axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_TOP" t )
	axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" t )

	unless( axlIsLayer( "MANUFACTURING/REFDES TOP DRC")
		axlMsgPut("Creating Layer MANUFACTURING/REFDES TOP DRC")
		axlLayerCreateNonConductor("MANUFACTURING/REFDES TOP DRC")
	)
	unless( axlIsVisibleLayer( "MANUFACTURING/REFDES TOP DRC")
		axlMsgPut("Displaying Layer MANUFACTURING/REFDES TOP DRC")
		axlVisibleLayer( "MANUFACTURING/REFDES TOP DRC" t )
        )
        
	unless( axlIsLayer( "MANUFACTURING/REFDES BOTTOM DRC")
		axlMsgPut("Creating Layer MANUFACTURING/REFDES BOTTOM DRC")
		axlLayerCreateNonConductor("MANUFACTURING/REFDES BOTTOM DRC")
	)
	unless( axlIsVisibleLayer( "MANUFACTURING/REFDES BOTTOM DRC")
		axlMsgPut("Displaying Layer MANUFACTURING/REFDES BOTTOM DRC")
		axlVisibleLayer( "MANUFACTURING/REFDES BOTTOM DRC" t )
        )
        ;_____________ set color ____________________________________________
        
	rpt = outfile("./setColor.scr")
	fprintf(rpt "version 14.0\n\nsetwindow pcb\ncolor \n")
	fprintf(rpt "setwindow form.cvf_main \n")
	fprintf(rpt "FORM cvf_main class_list Geometry \n")
	fprintf(rpt "FORM cvf_main class_list Manufacturing \n")
	fprintf(rpt "FORM cvf_main manufacturing/refdes_top_drc/visible YES \n")
	fprintf(rpt "FORM cvf_main manufacturing/refdes_bottom_drc/visible YES \n")
	fprintf(rpt "FORM cvf_main color8 7 \n")
	fprintf(rpt "FORM cvf_main manufacturing/refdes_top_drc/color 8 \n")
	fprintf(rpt "FORM cvf_main manufacturing/refdes_bottom_drc/color 13 \n")
	fprintf(rpt "FORM cvf_main apply \n")
	fprintf(rpt "FORM cvf_main ok \n")
	close(rpt)
	
	axlShell("replay ./setColor.scr")
	shell("rm ./setColor.scr")      

	axlMsgPut("Removing Old Refdes Cross DRC Holders .\nPlease wait ...") 
        drc_arc_list = jkSel_Drc_Line()	
        axlUIWRedraw(nil)
        
	if( drc_arc_list then
        	axlDeleteObject( drc_arc_list )	
        )
        axlUIWRedraw(nil)
        
	axlMsgPut("Display new Refdes Cross DRC .\nPlease wait ...")        
	;------------Display the error-----------------------------------
	axlSetFindFilter(?enabled '(noall text) ?onButtons '(noall text))
	text = axlGetSelSet(axlAddSelectAll())
	axlUIWRedraw(nil)

	textt = nil
	textb = nil
	cnt = 1
	foreach(txt text 
		if(txt->text != nil then
			if(txt->isMirrored == nil then
				if(txt->layer == "REF DES/SILKSCREEN_TOP"  then
					textt=cons(txt textt)
					cnt++
				)
			else
				if(txt->layer == "REF DES/SILKSCREEN_BOTTOM"  then
					textb=cons(txt textb)
					cnt++
				)
			)
		)		
	)
        axlUIWRedraw(nil)

	axlClearSelSet()
	topcom = 0
	err = jkLayer_Error(textt) + jkLayer_Error(textb)
	axlMsgPut("Total of refdes crosses is :  %8d" err)        
	axlClearSelSet()
        axlUIWRedraw(nil)

	axlMsgPut("Done")
);end-defun

;============================================================
;This function draws the silkscreen crosses at top or bottom 
;============================================================
defun( jkLayer_Error ( text)
prog( ()
let( ( error )
	i = 1
	error = 0
	while(nthelem(i text)->text != nil
		axlMsgPut("Process refdes : %s .  Count: %d/%d ." nthelem(i text)->text i+topcom cnt)
 		if(nthelem(i text)->parent->xy != nil 
		&& nthelem(i text)->xy != nil then
			c1 = nthelem(i text)->parent->xy
			t1 = nthelem(i text)->xy
		
			j = i + 1
			while(nthelem(j text) != nil
				if(nthelem(j text)->parent->xy != nil 
				&& nthelem(j text)->xy != nil then
					c2 = nthelem(j text)->parent->xy
					t2 = nthelem(j text)->xy
				)
				if(abs(nthelem(1 c1) - nthelem(1 c2)) < 500
				&& abs(nthelem(2 c1) - nthelem(2 c2)) < 500 then		
					if(jkIs_Cross( c1 t1 c2 t2) == t then				
						jkDraw_Error(c1 t1 c2 t2 nthelem(i text)->isMirrored)
						++error
					)
				)
				++j
			)
		);if
		++i
	);while
	topcom = i
	return(error)
)));end-defun

;------------------------------------------------------------
;Judge silkscreens interchange or not 
;===================================================================
defun( jkIs_Cross ( point1 point2 point3 point4)
prog( ()
let( ( k1 k2 )
	

	
/*	if(nthelem(2 point1) < nthelem(2 point2) then
		dx1 = nthelem(1 point1)
		dy1 = nthelem(2 point1)
		ux1 = nthelem(1 point2)
		uy1 = nthelem(2 point2)
	else
		dx1 = nthelem(1 point2)
		dy1 = nthelem(2 point2)
		ux1 = nthelem(1 point1)
		uy1 = nthelem(2 point1)
	)	
	if(nthelem(2 point3) < nthelem(2 point4) then
		dx2 = nthelem(1 point3)
		dy2 = nthelem(2 point3)
		ux2 = nthelem(1 point4)
		uy2 = nthelem(2 point4)
	else
		dx2 = nthelem(1 point4)
		dy2 = nthelem(2 point4)
		ux2 = nthelem(1 point3)
		uy2 = nthelem(2 point3)
	)	
	if(ux1 != dx1 then
		k1 = (1.0*uy1 - dy1)/(ux1 - dx1)
	else
		k1 = 1000
	)
	if(ux2 != dx2 then
		k2 = (1.0*uy2 - dy2)/(ux2 - dx2)
	else
		k2 = 1000
	)
	if(k1 != k2 then
		if(ux1 != dx1 && ux2 != dx2 then
		        y = (k1*k2*(dx2 - dx1) + k2*dy1 - k1*dy2)/(k2 - k1)
			if(uy1 > y && uy2 > y && dy1 < y && dy2 < y && point1 != point3 then 
				return(t)
			)
		)
		if(ux1 == dx1 && ux2 != dx2 then
		        y = k2*(ux1 - dx2) + dy2
			if(uy1 > y && uy2 > y && dy1 < y && dy2 < y && point1 != point3 then 
				return(t)
			)
		)
                if(ux1 != dx1 && ux2 == dx2 then
			y = k1*(ux2 - dx1) + dy1 
			if(uy1 > y && uy2 > y && dy1 < y && dy2 < y && point1 != point3 then 
				return(t)
		        )
		)
	)
	
*/
	
	if(nthelem(2 point1) < nthelem(2 point2) then
		dx1 = nthelem(1 point1)
		dy1 = nthelem(2 point1)
		ux1 = nthelem(1 point2)
		uy1 = nthelem(2 point2)
	else
		dx1 = nthelem(1 point2)
		dy1 = nthelem(2 point2)
		ux1 = nthelem(1 point1)
		uy1 = nthelem(2 point1)
	)	
	if(nthelem(2 point3) < nthelem(2 point4) then
		dx2 = nthelem(1 point3)
		dy2 = nthelem(2 point3)
		ux2 = nthelem(1 point4)
		uy2 = nthelem(2 point4)
	else
		dx2 = nthelem(1 point4)
		dy2 = nthelem(2 point4)
		ux2 = nthelem(1 point3)
		uy2 = nthelem(2 point3)
	)
	if(nthelem(2 point1) == nthelem(2 point2) then
		if(nthelem(1 point1) > nthelem(1 point2)
		then
			dx1 = nthelem(1 point2)
			dy1 = nthelem(2 point2)
			ux1 = nthelem(1 point1)
			uy1 = nthelem(2 point1)
			
		else
			dx1 = nthelem(1 point1)
			dy1 = nthelem(2 point1)
			ux1 = nthelem(1 point2)
			uy1 = nthelem(2 point2)
		)
	)	
	if(nthelem(2 point3) == nthelem(2 point4) then
		if(nthelem(1 point3) > nthelem(1 point4)
		then
			dx2 = nthelem(1 point4)
			dy2 = nthelem(2 point4)
			ux2 = nthelem(1 point3)
			uy2 = nthelem(2 point3)
			
		else
			dx2 = nthelem(1 point3)
			dy2 = nthelem(2 point3)
			ux2 = nthelem(1 point4)
			uy2 = nthelem(2 point4)
		)
	)	
	if(nthelem(1 point1) == nthelem(1 point2) then
		if(nthelem(2 point1) > nthelem(2 point2)
		then
			dx1 = nthelem(1 point2)
			dy1 = nthelem(2 point2)
			ux1 = nthelem(1 point1)
			uy1 = nthelem(2 point1)
			
		else
			dx1 = nthelem(1 point1)
			dy1 = nthelem(2 point1)
			ux1 = nthelem(1 point2)
			uy1 = nthelem(2 point2)
		)
	)	
	if(nthelem(1 point3) == nthelem(1 point4) then
		if(nthelem(2 point3) > nthelem(2 point4)
		then
			dx2 = nthelem(1 point4)
			dy2 = nthelem(2 point4)
			ux2 = nthelem(1 point3)
			uy2 = nthelem(2 point3)
			
		else
			dx2 = nthelem(1 point3)
			dy2 = nthelem(2 point3)
			ux2 = nthelem(1 point4)
			uy2 = nthelem(2 point4)
		)
	)	
	ux1 = round(ux1)
	uy1 = round(uy1)
	dx1 = round(dx1)
	dy1 = round(dy1)
	ux2 = round(ux2)
	uy2 = round(uy2)
	dx2 = round(dx2)
	dy2 = round(dy2)
	
	if(ux1 != dx1 then
		k1 = (1.0*uy1 - dy1)/(ux1 - dx1)
	else
		k1 = 10000		
	)
	if(ux2 != dx2 then
		k2 = (1.0*uy2 - dy2)/(ux2 - dx2)
	else
		k2 = 10000
	)   

	if(k1 != k2 then  
		if(ux1 != dx1 && ux2 != dx2 then  
		        y = (k1*k2*(dx2 - dx1) + k2*dy1 - k1*dy2)/(k2 - k1)
			if(uy1 > y && uy2 > y && dy1 < y && dy2 < y && point1 != point3 then 
				return(t)
			)
		)
		if(ux1 == dx1 && ux2 != dx2  then
		        y = k2*(ux1 - dx2) + dy2
			if(uy1 > y && uy2 > y && dy1 < y && dy2 < y && point1 != point3 then 
				return(t)
			)
		)
                if(ux1 != dx1 && ux2 == dx2  then
			y = k1*(ux2 - dx1) + dy1 
			if(uy1 > y && uy2 > y && dy1 < y && dy2 < y && point1 != point3 then 
				return(t)
		        )
		)
		if(k2 == 0 && k1 != 0 then
			x = round((y - dy1)/k1 + dx1)
			if(ux1 >= x && ux2 >= x && dx1 <= x && dx2 <= x then
				return(t)
			)
		)
		if(k1 == 0 && k2 != 0 then
			x = round((y - dy2)/k2 + dx2)
			if(ux1 >= x && ux2 >= x && dx1 <= x && dx2 <= x then
				return(t)
			)
		)
	)
	return(nil)
)));end-defun



;============================================================
;this function draws a cross line on the MANUFACTURING/REFDES DRC
;  layer.
;============================================================

defun( jkDraw_Error (c1 t1 c2 t2 mirror)
let( ()	
		L1 = list(c1 t1)
		L2 = list(c2 t2)
	if(mirror != t then	
		axlDBCreateLine(L1 0 "MANUFACTURING/REFDES TOP DRC")
		axlDBCreateLine(L2 0 "MANUFACTURING/REFDES TOP DRC")
	else
		axlDBCreateLine(L1 0 "MANUFACTURING/REFDES BOTTOM DRC")
		axlDBCreateLine(L2 0 "MANUFACTURING/REFDES BOTTOM DRC")
	)		
));end-defun

;============================================================
;This Function returns a list of dbids for all of the lines 
;   on the "Manufactuing/ref_position drc" layer.
;============================================================
defun( jkSel_Drc_Line ()
prog( ()
let( ( sel_arc_lst arc_lst)
	sel_arc_lst = nil
	arc_lst = nil
        axlClearSelSet()
        axlSetFindFilter( ?enabled '("NOALL" "LINESEGS") ?onButtons '("LINESEGS"))
        sel_lst = axlGetSelSet(axlAddSelectAll())
	axlMsgPut("Get lines in the board .")        
	foreach( id sel_lst
		if( id->objType == "line" arc_lst = cons( id arc_lst))
	)

	axlMsgPut("Get lines on the \"MANUFACTURING/REFDES DRC\" layer .\nPlease wait for a few minutes .")        
	foreach( id arc_lst
		if(id->layer == "MANUFACTURING/REFDES TOP DRC" 
		|| id->layer == "MANUFACTURING/REFDES BOTTOM DRC" then
			sel_arc_lst = cons( id sel_arc_lst)
		)
	)
        return( sel_arc_lst )
)));end - defun

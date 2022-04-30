;==========================================================================
;
;				scalpel.il
;
;==========================================================================
;
; Author:		Richard Moffat
;				richard.moffat@alliedtelesyn.co.nz
; Date:			1-Feb-2001
; Copyright Allied Telesis Labs Ltd, 2006
;
; Software parent:  
;	allegro v15.2 (should work from 14.x onwards)
;
; Dependencies:
;	none
;
; Description:
;	Allows the user to draw a path through clines, and have a channel cut through them.
;	Kinda like a scalpel, hence the name.
;
;
; History:
;	Rev	1.0		 1-Feb-2001	RBM		Original, put online.
;	Rev	2.0		29-Mar-2004	RBM		Added more efficient line_x_line
;	Rev	2.1		30-Mar-2004	RBM		Various bug fixes
;	Rev	2.2		30-Mar-2004	RBM		Added cancel function
;	Rev	2.3		01-Apr-2004	RBM		Added option for cut width input and help output
;
; Preparation: 
;	Position this file (scalpel.il) in the directory path where all other 
;	skill routines are located. In the allegro.ilinit file include the line 
;	load("scalpel.il")
;
; Usage: 
;	Type scalpel or scalpel n into the allegro command line, where 'n' is a number
;	eg
;	Command> scalpel
;	or 
;	Command> scalpel 20
;	where 'n' is the cutting width.  The default width is 12mils or 0.3mm.
;	When run, the user can left-click a path through clines, ending with either 
;	a double-click or right-button "Done".  Right-button "Cancel" cancels the function
;	with no cuts made at all.
;	According to the user defined cut_width variable (below), or 'n' as an input,
;	a path is cleared through any cline that is visible.
;	
; Program Notes:
;	This is written c-based rather than lisp-based.  I believe this makes it easier 
;	for non-lisp people to read, ie more psudocode style.
;
; Other Stuff:
;	This code is copyright to the authors.  However, it may be freely modified and improved.
;	There can obviously be some improvements made. If improvements are made, it would 
;	be courteous (and appreciated) to send a copy to the authors.
;	This software is not to be commercialised, ie not sold to further parties.  It is to 
;	remain free.
;	This software must keep all header information.
;
; Disclaimer:
;	Don't blame the author(s) or Allied Telesyn Research for anything 
;	that goes wrong from using this software.  
;	You have no rights; none, naught, nil, nada, nothing, nix, zero, 
;	zilch, zip, and/or zot.  In other words, use at your own risk.
;
;
;==========================================================================

;==========================================================================

axlCmdRegister( "scalpel" 'scalpel)


procedure( scalpel(@optional input)

	; default cut widths - you may change these:
	cut_width_MILS = 12
	cut_width_INCHES = 0.012
	cut_width_MICRONS = 300
	cut_width_MILLIMETERS = 0.300
	cut_width_CENTIMETERS = 0.0300

	
	ok_to_proceed = nil
	width_ok = nil
	if( ! input then
		units = car(axlDBGetDesignUnits())
		case(units
				("mils" cut_width = cut_width_MILS, width_ok = t)
				("inches" cut_width = cut_width_INCHES, width_ok = t)	
				("microns" cut_width = cut_width_MICRONS, width_ok = t)
				("millimeters" cut_width = cut_width_MILLIMETERS, width_ok = t)
				("centimeters" cut_width = cut_width_CENTIMETERS, width_ok = t)
				(t width_ok = nil)
		)
	)
	if( type(input) == 'string then
		width_ok = nil
		cond( 
			(rexMatchp("^[0-9]+$" input) 
				cut_width = evalstring(input)
				width_ok = t
			)
			(rexMatchp("help" input)
				rbm_print_scalpel_help()
			)
			(rexMatchp("ver" input)
				rbm_print_scalpel_version()
			)
			( t rbm_print_scalpel_help()
			)
		)
	)
		
	if( width_ok then
		
		if( ! axlOKToProceed() then
			axlShell("done")
		)
	
		design_dbid = axlDBGetDesign()
		design_path_and_name = axlGetDrawingName()
		
		; Create and display cutting layer
		axlLayerCreateNonConductor("BOARD GEOMETRY/SCALPEL")
		axlVisibleLayer("BOARD GEOMETRY/SCALPEL" t)
		axlVisibleUpdate(t)
		
		rbm_cut_path_data = rbm_draw_cut_path()
		if( ! cancelled then
			rbm_cut_traces(cut_path_data)
		)
		rbm_tidy_up()
	)
); end scalpel
;==========================================================================

procedure( rbm_print_scalpel_version()
	axlUIConfirm("SCALPEL - Version 2.3\n\nCopyright Allied Telesyn Research Ltd, 2004\n")
)

procedure(  rbm_print_scalpel_help()
	fout = outfile("scalpel_help_file.txt")
	fprintf(fout "scalpel\n\n")
	fprintf(fout "Allegro Skill utility\n\n")
	fprintf(fout "Copyright Allied Telesyn Research Ltd, 2004\n")
	fprintf(fout "\n")
	fprintf(fout "Description\n")
	fprintf(fout "Allows the user to draw a path through clines, and have a channel cut ")
	fprintf(fout "through them\n\n.")
	fprintf(fout "Usage: \n")
	fprintf(fout "Type scalpel or scalpel n into the allegro command line, where n is a number \n")
	fprintf(fout "eg\n")
	fprintf(fout "Command> scalpel\n")
	fprintf(fout "or \n")
	fprintf(fout "Command> scalpel 20\n")
	fprintf(fout "where 20 is the cutting width.  The default width is 12mils or 0.3mm.\n\n")
	fprintf(fout "When run, the user can left-click a path through clines, ending with either \n")
	fprintf(fout "a double-click or right-button 'Done'.  Right-button 'Cancel' cancels the\n")
	fprintf(fout "function with no cuts made at all.\n")
	fprintf(fout "According to the user defined cut_width variable within the script, or n as an\n")
	fprintf(fout "input, a path is cleared through any cline that is visible.	\n\n")
	fprintf(fout "Help is obtained by\n")
	fprintf(fout "scalpel help\n")
	fprintf(fout "Version info is obtained by\n")
	fprintf(fout "scalpel ver\n\n")
	fprintf(fout "This software is not to be commercialised and not sold to further parties. \n")
	fprintf(fout "It is to remain free.\n\n")
	fprintf(fout "Disclaimer:\n")
	fprintf(fout "Don't blame the author(s) or Allied Telesyn Research for anything \n")
	fprintf(fout "that goes wrong from using this software.  \n")
	fprintf(fout "You have no rights; none, naught, nil, nada, nothing, nix, zero, \n")
	fprintf(fout "zilch, zip, and/or zot.  In other words, use at your own risk.\n\n")
	fprintf(fout "Thanks to Chris Walters (2002/06/19) for finding a more efficient method of\n")
	fprintf(fout "finding crossing line intersections.\n")
	close(fout)
	axlUIViewFileCreate("scalpel_help_file.txt" "Scalpel Help" t)
	
) ; end scalpel_help



procedure(  rbm_cut_traces(cut_path_data)
	; these vars are global
	total_path = car(cut_path_data)
	
	foreach( path_seg total_path
		x3 = caar(path_seg)
		y3 = cadar(path_seg)
		x4 = caadr(path_seg)
		y4 = cadadr(path_seg)
		
		boxed_clines = rbm_find_clines_in_extents_box(caadr(cut_path_data) cadadr( cut_path_data))
		
		foreach( boxed_cline boxed_clines

			cline_seg = boxed_cline->startEnd
			x1 = caar(boxed_cline->startEnd)
			y1 = cadar(boxed_cline->startEnd)
			x2 = caadr(boxed_cline->startEnd)
			y2 = cadadr(boxed_cline->startEnd)
			cline_seg = boxed_cline->startEnd
			if( cline_seg && path_seg then
				intersect_data = cdw_axlLineXLine( cline_seg path_seg)
				if( car(intersect_data) then ; intersect point exists
					xp = caadr( intersect_data)
					yp = cadadr( intersect_data)
					if( x1<x2 then 
						x_mult = 1
					)
					if( x1>x2 then 
						x_mult = -1
					)
					if( y1<y2 then 
						y_mult = 1
					)
					if( y1>y2 then 
						y_mult = -1
					)
					half_cut_width = cut_width / 2
					; vertical trace
					if( x1==x2 then		
						new_x1 = xp
						new_x2 = xp
						new_y1 = yp - y_mult * half_cut_width
						new_y2 = yp + y_mult * half_cut_width
					)
					; horizontal trace
					if( y1==y2 then		
						new_y1 = yp
						new_y2 = yp
						new_x1 = xp - x_mult * half_cut_width
						new_x2 = xp + x_mult * half_cut_width
					)		
					if(x1!=x2 && y1!=y2 then
						new_x1 = xp - x_mult * half_cut_width
						new_x2 = xp + x_mult * half_cut_width
						new_y1 = yp - y_mult * half_cut_width
						new_y2 = yp + y_mult * half_cut_width
					)
					if( (x1<new_x1 && x2<new_x1) || (x1>new_x1 && x2>new_x1) || (y1<new_y1 && y2<new_y1) || (y1>new_y1 && y2>new_y1) ||
						(x1<new_x2 && x2<new_x2) || (x1>new_x2 && x2>new_x2) || (y1<new_y2 && y2<new_y2) || (y1>new_y2 && y2>new_y2) then
						seg_too_short = t
					else
						seg_too_short = nil
					)
					cline_layer = boxed_cline->layer
					cline_width = boxed_cline->width
					axlDeleteObject(boxed_cline)
					line_length = sqrt((y2-yp)**2 + (x2-xp)**2)				
					if( line_length >=cut_width && ! seg_too_short then
						line_res = axlDBCreateLine(list(x1:y1 new_x1:new_y1) cline_width cline_layer)
						line_res = axlDBCreateLine(list(x2:y2 new_x2:new_y2) cline_width cline_layer)
					)
				)
			)
		)

	)

) ; end cut_traces

procedure( rbm_tidy_up()
	foreach( cut_trace all_cut_traces
		axlDeleteObject(cut_trace)
	)
	axlShell("dehilight")
)

(defun  rbm_axlMyCancel ()
	axlClearDynamics()
	cancelled = axlCancelEnterFun()
	axlUIPopupSet(nil)
)
 
(defun  rbm_axlMyDone ()
	axlClearDynamics()
	axlFinishEnterFun()
	axlUIPopupSet(nil)
)

procedure(  rbm_draw_cut_path()
	; these vars are global
	tot_path = nil

	cut_path = nil
	x_list = nil
	y_list = nil
	total_path = nil
	all_cut_traces = nil
	cancelled = nil
	
	mypopup = axlUIPopupDefine( nil
		(list (list "Done" `rbm_axlMyDone)
		(list "Cancel" `rbm_axlMyCancel)
		)
	)
	
	axlUIPopupSet( mypopup)
	axlClearDynamics()
	while( cut_path = axlEnterPath(?lastPath cut_path)
			progn( cut_id = caar(axlDBCreatePath(cut_path, "BOARD GEOMETRY/SCALPEL")))
			all_cut_traces = cons( cut_id all_cut_traces)
			cut_segs = cut_id->segments
	
			line1 = car(cut_segs)->startEnd
			if(line1 then
				total_path = rbm_find_total_path(line1)
			)
			line2 = cadr(cut_segs)->startEnd
			if(line2 then
				total_path = rbm_find_total_path(line2)
			)
	)
	xs_list = sort(x_list 'lessp)
	ys_list = sort(y_list 'lessp)
	min_x = nth( 0 xs_list)
	min_y = nth( 0 ys_list)
	max_x = car(last(xs_list))
	max_y = car(last(ys_list))
	min_coord = list(min_x min_y)
	max_coord = list(max_x max_y)
	cut_path_data = list(total_path list(min_coord max_coord))
) ; end draw_cut_path


procedure(	 rbm_find_total_path(line)
	; these vars are global
	x_list = cons( caar(line) x_list)
	y_list = cons( cadar(line) y_list)
	x_list = cons( caadr(line) x_list)
	y_list = cons( cadadr(line) y_list)
	total_path = cons( line total_path)
) ; end find_total_path



procedure( rbm_find_clines_in_extents_box(min_coord max_coord)

	let((boxed_clines )
		axlSetFindFilter(?enabled list("noall" "clinesegs") ?onButtons list("noall" "clinesegs"))
		axlSingleSelectBox(list(min_coord max_coord))
		boxed_clines = axlGetSelSet()
	) ; end let
)



; line segment intersection determining  SKILL function
; Written by: Chris Walters		Nvidia		2002/06/19
;
; Description:
; This SKILL function will determine whether two 2D line segments intersect 
; and if so where. A boolean tells whether the intersection point lies on both 
; both segments (t) or not (nil) 
; 
; It is based upon the Liang-Barsky line-clipping algorithm and so works even if 
; one or both segments are parallel to an axis, unlike the axlLineXLine function 
; shipped with PSD14.1 
; 
; Preparation: 
;     Position this file (cdw_axlLineXLine.il) in the directory path where all other 
;     skill routines are located. In the allegro.ilinit file include the line 
;    load("cdw_axlLineXLine.il") ; 
; Usage: 
;     cdw_axlLineXLine( seg_1 seg_2) 
;        arguments 
;             seg_1 and seg_2 are lists containing start and endpoints for the segments 
; 
;        returns 
;            '(nil ( nil nil))  if lines segments are on are parallel 
;            '(nil ( xxx yyy))  if lines segments are on intersect but the point does not lie on both segments 
;             '(t   ( xxx yyy))  if lines segments are on intersect and the point does lie on both segments 
;                      where (xxx yyy) is the intersection point 
; 
; Associated files: 
;     None 
; 
; Revision History ;    --		2002/06/19  Chris Walters	Initial release
;==========================================================================
 
defun( cdw_axlLineXLine ( line_AB line_CD)	
; based upon Liang-Barsky line-clipping algorithm, 			
; works even if one or both segments are parallel			
; to either horizontal or vertical axis 

let(( pt_A_x pt_A_y pt_B_x pt_B_y
pt_C_x pt_C_y pt_D_x pt_D_y
u_AB u_CD denom cross_x cross_y return_val )


pt_A_x =   caar( line_AB)
pt_A_y =  cadar( line_AB)
pt_B_x =  caadr( line_AB)
pt_B_y = cadadr( line_AB)
pt_C_x =   caar( line_CD)
pt_C_y =  cadar( line_CD)
pt_D_x =  caadr( line_CD)
pt_D_y = cadadr( line_CD)

denom =  ((pt_D_y - pt_C_y)*(pt_B_x - pt_A_x) - (pt_D_x - pt_C_x)*(pt_B_y - pt_A_y))

true_intersect_exists = nil
if( denom == 0.0 then        
; lines are parallel, either no points intersect or ALL points intersect
    true_intersect_exists = nil    ; 
else	
; an intersection exists but it may not lie on the segments

 u_AB = (((pt_D_x - pt_C_x)*(pt_A_y - pt_C_y) - (pt_D_y - pt_C_y)*(pt_A_x - pt_C_x)) / denom) 
 
 u_CD = (((pt_B_x - pt_A_x)*(pt_A_y - pt_C_y) - (pt_B_y - pt_A_y)*(pt_A_x - pt_C_x)) / denom)

 cross_x = pt_A_x + u_AB * (pt_B_x - pt_A_x)
 cross_y = pt_A_y + u_AB * (pt_B_y - pt_A_y)
    if( (u_AB >= 0.0 && u_AB <= 1.0) && (u_CD >= 0.0 && u_CD <= 1.0) then
        true_intersect_exists = t
    else
        true_intersect_exists = nil
    );end-if
);end-if

return_val = list( true_intersect_exists list( cross_x cross_y))

 );end-let


);end-defun

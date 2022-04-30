;                      Add Assembly Rulers 
;                      -------------------
;
; This routine extracts the board outline from either a .brd or 
; a .dra database, and adds numbered rulers around all four sides. 
; Currently, the program adds a line every centimetre, with every 
; fifth ruling being slightly longer. If different units are
; required, the program should be easy to modify.
 
; It doesn't matter what units the database is in, because all 
; numbers are converted at the start of the routine to the current
; database units. 
 
; Text Block 3 is used, which is assumed to be set to 38 50 75 8 13 
; (mils). If the text width and height are substantially different 
; to this, the output may appear distorted.
 
; The ruler lines and text are added to the Board Geometry/Place_Grid_ 
; Top and Place_Grid_Bottom subclasses.
 
; The text "SIDE A" is also added to the top side and "SIDE B" is
; added to the bottom side. This could be altered/deleted as desired.
 
; To run the program type "ruler" on the Allegro command line.

; -----------------------------------------------------------------
 
; Tested on Allegro 11.0
 
; Written by:
 
; Pete Court
; PCB Design Engineer
; While working at:

; Fujitsu Telecommunications Europe Limited
; Solihull Parkway
; Birmingham Business Park
; Birmingham
; B37 7YU
; UK

; I can now be reached at the following address:

; E-Mail: pc@earthling.net
 
; -----------------------------------------------------------------
; Version 2: Modified to calculate min and max dimensions without 
;            using axlExtractToFile.
; -----------------------------------------------------------------
; Version 3: Added '?' before rotation paramater to solve some
;            incompatability problems.
; -----------------------------------------------------------------

(defun ruler ()
 
x_list = ()
y_list = ()

; convert to current database units
; ---------------------------------

line_length_normal = axlMKSConvert(125 "MILS")
line_length_long = axlMKSConvert(175 "MILS")
spacing = axlMKSConvert(393.7 "MILS" )
text_offset = axlMKSConvert(25 "MILS")
line_width = axlMKSConvert(10 "MILS")
text_height = axlMKSConvert(50 "MILS")
side_loc = axlMKSConvert(250 "MILS")

; find min and max dimensions
; ---------------------------

axlClearSelSet()
vis_list = axlVisibleGet() 
axlVisibleDesign(nil)
axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t) 
axlSetFindFilter(?enabled list("noall" "linesegs")
        ?onButtons list("noall" "linesegs"))
axlAddSelectAll() 
axlVisibleSet(vis_list)
lines = axlGetSelSet() 
    foreach( line_db lines 
        line_layer = line_db->layer
        if( equal(line_layer "BOARD GEOMETRY/OUTLINE") then 
            line_xy = line_db->startEnd
            line_start = car(line_xy)  
            line_end = nth(1 line_xy) 
            line_x = car(line_start) 
            x_list = cons(line_x x_list) 
            line_x = car(line_end)
            x_list = cons(line_x x_list) 
            line_y = nth(1 line_start)  
            y_list = cons(line_y y_list)  
            line_y = nth(1 line_end) 
            y_list = cons(line_y y_list) 
        ) ; end of if
    ) ; end of foreach

x_list = sort(x_list 'lessp) 
y_list = sort(y_list 'lessp)
x_min = car(x_list)
x_max = car(last(x_list))
y_min = car(y_list)
y_max = car(last(y_list))
x_line = x_min
y_line = y_min
x_text = 0
y_text = 0
x_count = 4
y_count = 4

; set text blocks
; ---------------

top_text = make_axlTextOrientation(
						?textBlock "3", ?rotation 0.,
						?mirrored nil , ?justify "left")

bottom_text = make_axlTextOrientation(
                        ?textBlock "3", ?rotation 0.,
                        ?mirrored t , ?justify "right")

right_top_text = make_axlTextOrientation(
                        ?textBlock "3", ?rotation 0.,
                        ?mirrored nil , ?justify "right")

right_bottom_text = make_axlTextOrientation(
                        ?textBlock "3", ?rotation 0.,
                        ?mirrored t , ?justify "left")

top_center = make_axlTextOrientation(
                        ?textBlock "3", ?rotation 0.,
                        ?mirrored nil , ?justify "center")

bottom_center = make_axlTextOrientation(
                        ?textBlock "3", ?rotation 0.,
                        ?mirrored t , ?justify "center")

; add lines/text in x direction
; -----------------------------

while( (x_line <= x_max)

	x_count = x_count+1
		if( equal(x_count 5) then
			line_length = line_length_long
			x_count = 0
		else
			line_length = line_length_normal
		) ; end of if

	x_text_loc = (x_line + text_offset):(y_min-line_length)
	x_text_loc2 = (x_line + text_offset):(y_max+line_length-text_height)
	sprintf(x_text_string "%d" , x_text)
	x_loc_lower = x_line:(y_min-line_length)
	x_loc_upper = x_line:y_min
	x_loc_lower2 = x_line:(y_max+line_length)
	x_loc_upper2 = x_line:y_max

	axlDBCreateLine(list(x_loc_upper x_loc_lower), line_width , "board geometry/place_grid_top")
	axlDBCreateLine(list(x_loc_upper x_loc_lower), line_width , "board geometry/place_grid_bottom") 
	axlDBCreateLine(list(x_loc_upper2 x_loc_lower2), line_width , "board geometry/place_grid_top")
	axlDBCreateLine(list(x_loc_upper2 x_loc_lower2), line_width , "board geometry/place_grid_bottom")

	axlDBCreateText(x_text_string , x_text_loc , top_text , "board geometry/place_grid_top")
	axlDBCreateText(x_text_string , x_text_loc , bottom_text , "board geometry/place_grid_bottom")
	axlDBCreateText(x_text_string , x_text_loc2 , top_text , "board geometry/place_grid_top")
	axlDBCreateText(x_text_string , x_text_loc2 , bottom_text , "board geometry/place_grid_bottom")

	x_line = x_line + spacing
	x_text = x_text + 1
	
) ; end of while

; add lines/text in y direction 
; ----------------------------- 

while( (y_line <= y_max)

	y_count = y_count+1
        if( equal(y_count 5) then
            line_length = line_length_long
            y_count = 0   
        else
            line_length = line_length_normal
        ) ; end of if

	y_text_loc = (x_min-line_length):(y_line+text_offset)
	y_text_loc2 = (x_max+line_length):(y_line+text_offset)
	sprintf(y_text_string "%d" , y_text)
    y_loc_left = (x_min-line_length):y_line
    y_loc_right = x_min:y_line 
	y_loc_left2 = (x_max+line_length):y_line
	y_loc_right2 = x_max:y_line

    axlDBCreateLine(list(y_loc_left y_loc_right), line_width , "board geometry/place_grid_top") 
	axlDBCreateLine(list(y_loc_left y_loc_right), line_width , "board geometry/place_grid_bottom")
	axlDBCreateLine(list(y_loc_left2 y_loc_right2), line_width , "board geometry/place_grid_top")
	axlDBCreateLine(list(y_loc_left2 y_loc_right2), line_width , "board geometry/place_grid_bottom")

	axlDBCreateText(y_text_string , y_text_loc , top_text , "board geometry/place_grid_top")
	axlDBCreateText(y_text_string , y_text_loc , bottom_text , "board geometry/place_grid_bottom")
	axlDBCreateText(y_text_string , y_text_loc2 , right_top_text , "board geometry/place_grid_top")
	axlDBCreateText(y_text_string , y_text_loc2 , right_bottom_text , "board geometry/place_grid_bottom")

    y_line = y_line + spacing   
	y_text = y_text + 1
) ; end of while

; add side a/side b labels
; ------------------------

side_text_loc = (((x_max-x_min)/2)+x_min):(y_max+side_loc)
axlDBCreateText("SIDE A" , side_text_loc , top_center , "board geometry/place_grid_top")
axlDBCreateText("SIDE B" , side_text_loc , bottom_center , "board geometry/place_grid_bottom")

) ; end of function  

axlFlushDisplay()

axlCmdRegister( "ruler" `ruler)

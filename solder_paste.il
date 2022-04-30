;                    Solder Paste Information
;                    ------------------------

; This routine extracts solder paste information from a .brd,
; giving a count of the number of paste pads and the total pad
; area in square mils on each side of the board. This information
; is useful to assembly departments, because the amount of paste
; required can be calculated using the pad area.

; In addition to the total count and area, a pad count for each
; different pad size is also given. 'Shape' and 'Oblong' pads
; are treated as rectangles.

; The database can be in any units, but the output will always be
; given in mils.

; An output file is created (and displayed on screen), the name
; of which is the current board name with the extension '.pas'.

; To run the program type "paste" on the Allegro command line.

; -----------------------------------------------------------------

; Tested on Allegro 11.0

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

(defun paste_area ()

printf("\n%s\n" , "Solder paste information will take a few seconds to calculate. Please wait....")
drain(poport)

; sets variables
; --------------

boardname = axlCurrentDesign() 
units = axlDBGetDesignUnits()
units = car(units)
pad_area_top = 0
pad_area_bottom = 0
pad_count_top = 0
pad_count_bottom = 0
null_string = "    "
count_size_list_top = ()
count_size_list_bottom = ()

out_name = strcat(boardname ".pas")
outport = outfile(out_name)
 
fprintf(outport , "%s%s%s\n\n", "Solder Paste Information for " , boardname , ".brd" )

; selects pins
; ------------

drain()
axlClearSelSet()
vis_list = axlVisibleGet()
axlVisibleDesign(nil)
axlVisibleLayer("PIN/PASTEMASK_TOP" t)
axlSetFindFilter(?enabled list("noall" "pins")
        ?onButtons list("noall" "pins"))
axlAddSelectAll()
pp_top_list = axlGetSelSet()
axlClearSelSet() 
axlVisibleDesign(nil) 
axlVisibleLayer("PIN/PASTEMASK_BOTTOM" t) 
axlSetFindFilter(?enabled list("noall" "pins") 
        ?onButtons list("noall" "pins"))   
axlAddSelectAll() 
pp_bottom_list = axlGetSelSet() 
axlVisibleSet(vis_list)

; creates a table for count/size
; ------------------------------

padname_table_top = makeTable("pad_table_top" nil)

; gets shape and size of pad
; --------------------------

foreach(pp_top_db pp_top_list
	pad = axlDBGetPad(pp_top_db "pin/pastemask_top" "regular")
	pad_shape = pad-> figureName
	boundary = pad->bBox
	llx = caar(boundary)
	urx = caadr(boundary)
	ury = cadadr(boundary)
	lly = cadar(boundary)
	x_dim = urx-llx
	x_dim = axlMKSConvert(x_dim units "MILS")
	y_dim = ury-lly
	y_dim = axlMKSConvert(y_dim units "MILS")
	
	; calculates area of circular pads
	; --------------------------------

	if( equal(pad_shape "CIRCLE") then
		sprintf(pad_size "%.0f%s" x_dim, "cir")
		pad_radius = x_dim/2
		pad_area = 3.14*(pad_radius**2)

	else

		; ensures all pads are the same rotation
		; --------------------------------------

		if( (x_dim>y_dim) then
			dim_temp = x_dim
			x_dim = y_dim
			y_dim = dim_temp
		) ; end of if

	sprintf(pad_size "%.0f%s%.0f" x_dim, "x", y_dim)

	; calculates area of non-circular pads
	; ------------------------------------

	pad_area = x_dim*y_dim
	) ; end of if	

	; adds pad area and count to total
	; --------------------------------

	pad_area_top=pad_area_top+pad_area
	pad_count_top = pad_count_top+1

	; checks if pad size already exists
	; ---------------------------------

	padcount = padname_table_top[pad_size]

	; if pad exists add to table with a count of 1
	; --------------------------------------------

	if( eq(padcount nil) then
		padname_table_top[pad_size] = 1
	else
		
		; if pad doesn't exist increment existing count by 1
		; --------------------------------------------------

		padcount = padcount+1
		padname_table_top[pad_size] = padcount
	) ; end of if
 
) ; end of foreach

; creates a list of pad count/size
; --------------------------------

foreach( pad_size padname_table_top
	count_size = list( padname_table_top[ pad_size ] pad_size )
	count_size_list_top = cons(count_size count_size_list_top)
) ; end of foreach

; sorts list
; ----------

count_size_list_top = sortcar(count_size_list_top 'lessp)
count_size_list_top = reverse(count_size_list_top)

; checks if solder paste pads exist and creates output file
; ---------------------------------------------------------

if( eq(count_size_list_top nil) then
	fprintf(outport, "%s\n\n" , "There are no solder paste pads on side A")
else
	fprintf(outport , "%s\n" , "SOLDER PASTE PADS FOR SIDE A:")
	fprintf(outport , "%s\n\n" , "-----------------------------")
	fprintf(outport , "%s\n" , "Count   Size")
	fprintf(outport , "%s\n" , "-----   ----")
    foreach( count_size count_size_list_top
        count = car(count_size)
        sprintf(count "%n" count)
        size = nth(1 count_size)
        count_length = strlen(count)
        if( count_length<5 then
            count = strcat(substring(null_string 1 (5-count_length)) count)
        ) ; end of if
        fprintf(outport , "%s%s%s\n" , count, "   ",size)
	) ; end of foreach
	
	fprintf(outport , "\n%s%.0f%s\n" , "Solder Paste Area For Side A: " , pad_area_top, " sq. mils" )
	fprintf(outport , "%s%n\n\n" , "Solder Paste Pad Count For Side A: " , pad_count_top)
) ; end of foreach

; creates a table for count/size
; ------------------------------

padname_table_bottom = makeTable("pad_table_bottom" nil)

; gets shape and size of pad
; --------------------------

foreach(pp_bottom_db pp_bottom_list
	pad = axlDBGetPad(pp_bottom_db "pin/pastemask_bottom" "regular")
	pad_shape = pad-> figureName
	boundary = pad->bBox
	llx = caar(boundary)
	urx = caadr(boundary)
	ury = cadadr(boundary)
	lly = cadar(boundary)
	x_dim = urx-llx
	x_dim = axlMKSConvert(x_dim units "MILS")
	y_dim = ury-lly
	y_dim = axlMKSConvert(y_dim units "MILS")
		
	; calculates area of circular pads
	; --------------------------------

	if( equal(pad_shape "CIRCLE") then
		sprintf(pad_size "%.0f%s" x_dim, "cir")
		pad_radius = x_dim/2
		pad_area = 3.14*(pad_radius**2)

	else

		; ensures all pads are the same rotation
		; --------------------------------------

		if( (x_dim>y_dim) then
			dim_temp = x_dim
			x_dim = y_dim
			y_dim = dim_temp
		) ; end of if

	sprintf(pad_size "%.0f%s%.0f" x_dim, "x", y_dim)

	; calculates area of non-circular pads
	; ------------------------------------

	pad_area = x_dim*y_dim
	) ; end of if	

	; adds pad area and count to total
	; --------------------------------

	pad_area_bottom=pad_area_bottom+pad_area
	pad_count_bottom=pad_count_bottom+1

	; checks if pad size already exists
	; ---------------------------------

	padcount = padname_table_bottom[pad_size]

	; if pad exists add to table with a count of 1
	; --------------------------------------------

	if( eq(padcount nil) then
		padname_table_bottom[pad_size] = 1
	else
		
		; if pad doesn't exist increment existing count by 1
		; --------------------------------------------------

		padcount = padcount+1
		padname_table_bottom[pad_size] = padcount
	) ; end of if
 
) ; end of foreach

; creates a list of pad count/size
; --------------------------------

foreach( pad_size padname_table_bottom
	count_size = list( padname_table_bottom[ pad_size ] pad_size )
	count_size_list_bottom = cons(count_size count_size_list_bottom)
) ; end of foreach

; sorts list
; ----------

count_size_list_bottom = sortcar(count_size_list_bottom 'lessp)
count_size_list_bottom = reverse(count_size_list_bottom)

; checks if solder paste pads exist and creates output file
; ---------------------------------------------------------

if( eq(count_size_list_bottom nil) then
	fprintf(outport, "%s\n\n" , "There are no solder paste pads on side B")
else
	fprintf(outport , "%s\n" , "SOLDER PASTE PADS FOR SIDE B:")
	fprintf(outport , "%s\n\n" , "-----------------------------")
	fprintf(outport , "%s\n" , "Count   Size")
	fprintf(outport , "%s\n" , "-----   ----")
	foreach( count_size count_size_list_bottom
		count = car(count_size)
        sprintf(count "%n" count)
        size = nth(1 count_size)
        count_length = strlen(count)
        if( count_length<5 then
            count = strcat(substring(null_string 1 (5-count_length)) count)
        ) ; end of if
        fprintf(outport , "%s%s%s\n" , count, "   ",size)
	) ; end of foreach
	
	fprintf(outport , "\n%s%.0f%s\n" , "Solder Paste Area For Side B: " , pad_area_bottom, " sq. mils" )
	fprintf(outport , "%s%n\n\n" , "Solder Paste Pad Count For Side B: " , pad_count_bottom)
) ; end of foreach
close( outport)

; view output file
; ----------------

printf("\n%s%s%s\n" , "The file " boardname ".pas has been created.")
axlUIViewFileCreate(out_name "SOLDER PASTE PADS" nil 55:30)

) ; end of paste_area

; registers command with allegro
; ------------------------------

axlCmdRegister( "paste" `paste_area)

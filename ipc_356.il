;                    ---------------------------

; This routine extracts a netlist in IPC-D-356 format from an
; Allegro database.

; The program has the following features:

;	* Adds date/time stamp to file header
;	* Adds board filename to file header
;	* Converts output to correct units regardless of database units
;	* Shortens netnames over 14 characters long to suit IPC format

; The IPC-D-356 format only allows for netnames up to 14 characters
; long. Because netnames in Allegro can often exceed this length, 
; the routine renames them to the form: 'NNAME#####'. A conversion
; list is displayed showing new and old netnames which can be saved
; and/or printed for reference if required. It is also included at
; the end of the netlist file. Netnames 14 characters long or less
; are left unchaged.

; If there is a specific padstack which is always used for a 
; tooling hole, TOOL_PAD on the following line should be replaced
; with the padstack name. The .pad extension should not be included.
; The inverted commas should be left, and the name should be upper
; case. If there is no specific tooling pad, leave the following 
; line untouched.

tooling_pad = "TOOL_PAD"

; No 'mid-point' data is included in the output.

; If the origin for the netlist data is required to be the same as
; the origin for gerber data, be sure to alter the board origin to
; match the gerber origin before generating the netlist.

; For a large board, the netlist can take a couple of minutes to
; create, so be prepared to wait a while! A running count of the
; number of test records generated is given.

; The output filename is the current database filename with the 
; extension '.ipc'

; To run the program type "ipc_356" on the Allegro command line.

; -----------------------------------------------------------------

; Tested on Allegro 11.5

; Written by:

; Pete Court
; PCB Design Engineer
; Fujitsu Telecommunications Europe Limited
; Solihull Parkway
; Birmingham Business Park
; Birmingham
; B37 7YU
; UK

; E-Mail: pc@ftel.co.uk
 
; -----------------------------------------------------------------
; Version 2: Now gives pad sizes of circular SMD pads as well as 
;            rectangular ones.
;            Header information modified.
; -----------------------------------------------------------------
; Version 3: Now gives a running count of how many test records
;            have been generated.
; -----------------------------------------------------------------
; Version 4: Now gives pad rotation in columns 68-71
; -----------------------------------------------------------------
; Version 5: Now gives actual padstack dimensions instead of
;            absolute dimensions of padstack in artwork. Works
;            in conjunction with rotation 
; -----------------------------------------------------------------
; Version 6: fixed minor bug that causes routine to crash when
;            encountering an exploded pin
; -----------------------------------------------------------------
; Version 7: corrected the variable that was causing an improper 
;            rotation value. (tested with version 13.6)
;            Ron Guthrie, Cadence Design Systems Feb. 2001
; -----------------------------------------------------------------
; Version 8: Modified the Testpoint Access section (c40_41) to report 
;            the proper layer for testpoint access. Previously it 
;            would report 02 for access layer greater than 01
;            Ron Guthrie, Cadence Design Systems Mar. 26, 2001
; -----------------------------------------------------------------
; Version 9: Modified drill and rotation sections to use a unique 
;	     for the string format of the value. Also changed code
;	     so original value from database is not modified since 
;	     they may be used later in program.  Removed "through" 
;	     variable since it is equivalent to "drill>0".
;	     Ron Dallas, Teradyne Aug 27, 2001
;		Tested with Allegro v13.6 and v14.0. Ron Guthrie, Cadence. 9/10/01
;
; Version 9.1:Ammended Rotation to output Radians for SI units - Bob Doe Cadence 3-Apr-02
;
; -----------------------------------------------------------------
;
(defun ipc_356 ()

printf("\n%s\n" , "IPC-D-356 netlister (Version 9.1)")
printf("%s\n" , "A netlist in IPC-D-356 format is being created. Please wait....")
drain(poport)

; Find the number of layers in the board	- version 8 
; --------------------------------------
 layer_count= axlGetParam("paramLayerGroup:etch")->nChildren
 if( layer_count<10 then
     sprintf(secondary "0%1d" layer_count)     /* fill out to two columns */
 else
     sprintf(secondary "%2d" layer_count)      /* just convert to a string */
 );end if

; selects pins and vias
; ---------------------

drain()
axlClearSelSet()
vis_list = axlVisibleGet()
axlVisibleDesign(nil)
axlVisibleLayer("PIN/TOP" t)
axlVisibleLayer("PIN/BOTTOM" t)
axlVisibleLayer("PIN/SOLDERMASK_TOP" t)
axlVisibleLayer("PIN/SOLDERMASK_BOTTOM" t)
axlVisibleLayer("VIA CLASS/TOP" t)
axlVisibleLayer("VIA CLASS/BOTTOM" t)
axlVisibleLayer("MANUFACTURING/NCDRILL_FIGURE" t)
axlSetFindFilter(?enabled list("noall" "pins" "vias")
        ?onButtons list("noall" "pins" "vias"))
axlAddSelectAll()
pin_list = axlGetSelSet()
axlClearSelSet()
axlVisibleSet(vis_list)

; sets constant fields
; --------------------

c1 = "3"
c3 = "7"
c18_20 = "   "
c27 = "-"
c32 = " "
c39 = "A"
c42 = "X"
c50 = "Y"
c68_71 = "    "
c72 = " "
c73 = "S"
c75_80 = "      "
null_string = "              "
zero_string = "000000"
long_net_table = makeTable("long_net_table" nil)
shortened_net_list = ()
long_net_number = 10000
count = 0
count2 = 100

; gets board name and opens output file
; -------------------------------------

boardname = axlCurrentDesign()
out_name = strcat(boardname ".ipc")
outport = outfile(out_name)

; starts file header
; ------------------

fprintf(outport , "%s%s%s\n", "P  JOB   ",  boardname,  ".brd")

; creates conversion factors for different db units
; -------------------------------------------------
; BD 3-Apr-02 : added angle_factor
;
units = axlDBGetDesignUnits()
units = car(units)
cond(
	(equal(units "mils") (conv_factor = 10)
	fprintf(outport , "%s\n", "P  UNITS CUST ") (angle_factor = 1.0)
	) ; end of equal
	(equal(units "inches") (conv_factor = 10000) (angle_factor = 1.0)
	fprintf(outport , "%s\n", "P  UNITS CUST ")
	) ; end of equal
	(equal(units "microns") (conv_factor = 1)
	fprintf(outport , "%s\n", "P  UNITS SI ") (angle_factor = 1.74532925)
	) ; end of equal
	(equal(units "millimeters") (conv_factor = 1000) (angle_factor = 1.74532925)
	fprintf(outport , "%s\n", "P  UNITS SI ")
	) ; end of equal
	(equal(units "centimeters") (conv_factor = 10000) (angle_factor = 1.74532925)
	fprintf(outport , "%s\n", "P  UNITS SI ")
	) ; end of equal
) ; end of cond

fprintf(outport , "%s\n%s\n%s%s\n%s\n", "P  DIM   N", "C  ",  "C  ",  getCurrentTime(), "C  " )
fprintf(outport , "%s\n%s\n", "C  IPC-D-356 Netlist From Allegro" "C  ")

; gets information from pad
; --------------------------

foreach(pin_db pin_list

	count=count+1
	if( eq(count 100) then
	  printf("\n%n%s\n" , count2, " Test Records Generated.")
	  drain(poport)
	  count=0
	  count2=count2+100
	) ; end of if

	number = pin_db->number
	xy = pin_db->xy
	layer = pin_db->startEnd

        net_db = pin_db->net 
	pad_type = pin_db->objType
        net_name = net_db->name

	symbol_db = pin_db->parent
	refdes = symbol_db->refdes
	rotation = pin_db->rotation             /* added version 4 */

	padstack_db = pin_db->definition
	drill = padstack_db->drillDiameter
;	if( drill>0 then    /* "through" variable deleted - version 9 */
;	  through = t
;	else
;	  through = nil
;	) ; end of if
	pad_name = padstack_db->name
	plating = axlDBGetDrillPlating(pad_name)

	; checks if surface mount/through hole/tooling hole
	; -------------------------------------------------
    ; Note: does not handle blind/buried vias  /*added comment - version 9 */
	if( drill>0 then   /* change test to use "drill" - verion 9 */
	  c2 = "1"         /* through hole */
	else
	  c2 = "2"         /* SMT */
	) ; end of if
	if( equal(pad_name tooling_pad) then
	  c2 = "6"
	) ; end of if

	; get x:y of rectangular pads
	; ---------------------------

	top_pad_db = axlDBGetPad(padstack_db "etch/top" "regular")        /* changed version 5 */
	bottom_pad_db = axlDBGetPad(padstack_db "etch/bottom" "regular")  /* changed version 5 */
	c58 = " "
	c59_62 = "    "
	c63 = " "
	c64_67 = "    "
	c68_71 = "    "                                         /* resets rotation - version 5 */

	top_pad_shape = top_pad_db-> figureName
	if( nequal(top_pad_shape "NULL") then
	  if( equal(c2 "2") then
	    c58 = "X"
	    c63 = "Y"
    	    boundary = top_pad_db->bBox
    	    llx = caar(boundary)
    	    urx = caadr(boundary)
    	    ury = cadadr(boundary)
    	    lly = cadar(boundary)
    	    x_top_dim = urx-llx
    	    y_top_dim = ury-lly
		
	    x_top_dim = round(x_top_dim*conv_factor)
	    sprintf(c59_62 "%n" x_top_dim)
	    x_top_dim_length = strlen(c59_62)
	    if( nequal( x_top_dim_length 4) then
	      if( x_top_dim_length<4 then
		c59_62 = strcat( substring(zero_string 1 (4-x_top_dim_length)) c59_62)
	      else
		c59_62 = " ERR  "
	      ) ; end of if
	    ) ; end of if

	    y_top_dim = round(y_top_dim*conv_factor) 
	    sprintf(c64_67 "%n" y_top_dim) 
	    y_top_dim_length = strlen(c64_67)
	    if( nequal( y_top_dim_length 4) then 
	      if( y_top_dim_length<4 then 
		c64_67 = strcat( substring(zero_string 1 (4-y_top_dim_length)) c64_67)
	      else
		c64_67 = " ERR  "
	      ) ; end of if
	    ) ; end of if
            if( rotation>0 then            /* calculates rotation - version 5 */
; BD 3-Apr-02 : Use angle_factor in calculation
            rotation = rotation * angle_factor	/* convert to radians as required */
 	      sprintf(rotstr "%4.0f" (rotation+1000) )  /* use different variables for values of different type - version 6 */
	      rotstr   = substring(rotstr 2 4)          /* save as string - V9 */
	      c68_71 = strcat( "R" rotstr )   /* change rotstr to rotation - version 7 */
					      /* back to rotstr - version 9 */
	    else
	      c68_71 = "    "
	    ) ; end of if
 
	  ) ; end of if
	) ; end of if

        bottom_pad_shape = bottom_pad_db-> figureName 
        if( nequal(bottom_pad_shape "NULL") then
	  if( equal(c2 "2") then
	    c58 = "X"
	    c63 = "Y"
            boundary = bottom_pad_db->bBox
	    llx = caar(boundary)
	    urx = caadr(boundary)
	    ury = cadadr(boundary)
	    lly = cadar(boundary)
	    x_bottom_dim = urx-llx
	    y_bottom_dim = ury-lly
           
	    x_bottom_dim = round(x_bottom_dim*conv_factor)
	    sprintf(c59_62 "%n" x_bottom_dim)
	    x_bottom_dim_length = strlen(c59_62)
	    if( nequal( x_bottom_dim_length 4) then
	      if( x_bottom_dim_length<4 then
	        c59_62 = strcat( substring(zero_string 1 (4-x_bottom_dim_length)) c59_62)
	      else
	        c59_62 = " ERR  "
	      ) ; end of if
	    ) ; end of if
 
            y_bottom_dim = round(y_bottom_dim*conv_factor)
	    sprintf(c64_67 "%n" y_bottom_dim)
	    y_bottom_dim_length = strlen(c64_67)
	    if( nequal( y_bottom_dim_length 4) then
	      if( y_bottom_dim_length<4 then
	        c64_67 = strcat( substring(zero_string 1 (4-y_bottom_dim_length)) c64_67)
	      else
	        c64_67 = " ERR  "
	      ) ; end of if
	    ) ; end of if
            if( rotation>0 then            /* calculates rotation - version 5 */
;    	      rotation = rotation + 1000   /* moved to sprintf in v9 */
; OE Added BD change as of 3-Apr-02 : Use angle_factor in calculation
            rotation = rotation * angle_factor	/* convert to radians as required */
 	      sprintf(rotstr "%4.0f" (rotation + 1000) )  /* use different variables for values of different type - version 6 */
	   ;  rotation = substring(rotstr 2 4) /* deleted - V9 */
	      rotstr   = substring(rotstr 2 4) /* save as the string type - V9 */
	      c68_71 = strcat( "R" rotstr )    /* Corrected the variable to get the proper rotation. */
	    else
	      c68_71 = "    "
	    ) ; end of if
 
          ) ; end of if
        ) ; end of if

	; check if soldermask is present
	; ------------------------------

	top_mask_db = axlDBGetPad(pin_db "pin/soldermask_top" "regular")
	bottom_mask_db = axlDBGetPad(pin_db "pin/soldermask_bottom" "regular")
        top_mask_shape = top_mask_db-> figureName
        if( nequal(top_mask_shape "NULL") then
	  top_mask = 0
	else
	  top_mask = 1
	) ; end of if

        bottom_mask_shape = bottom_mask_db-> figureName
        if( nequal(bottom_mask_shape "NULL") then
          bottom_mask = 0
	else
	  bottom_mask = 2
        ) ; end of if

	; generates net name
	; ------------------
	
	cond( 
		(equal(net_name nil) (net_name = "N/C           "))
		(equal(net_name "") (net_name = "N/C           "))
		(net_length = strlen(net_name)
			if( nequal( net_length 14) then
				if( net_length<14 then
					net_name = strncat( net_name null_string 14-net_length)
				else
					net_exists = long_net_table[net_name]
					if( eq(net_exists nil) then
						long_net_table[net_name] = long_net_number
						sprintf(long_net_number_string "%n" long_net_number)
						net_name = strcat("NNAME" long_net_number_string "    ")
						long_net_number = long_net_number+1
					else
						sprintf(long_net_number_string "%n" net_exists)
						net_name = strcat("NNAME" long_net_number_string "    ")
					) ; end of if
				) ; end of if
			) ; end of if
		) ; end of net not n/c
	) ; end of cond

	c4_17 = net_name

	; generates reference designator
	; ------------------------------

	cond(
		(equal(pad_type "via") (refdes = "VIA   "))
		(equal(refdes nil) (refdes = "      "))
		(refdes_length = strlen(refdes)
			if( nequal( refdes_length 6) then
				if( refdes_length<6 then
					refdes = strncat( refdes null_string 6-refdes_length)
				else
					refdes = substring(refdes refdes_length-5 6)
				) ; end of if
			) ; end of if	
		) ; end of refdes not 6
	) ; end of cond

	c21_26 = refdes

	; generates pin number
	; --------------------

	if( equal(number nil) then
		number = "    "
	else
		number_length = strlen(number)
		if( nequal( number_length 4) then
			if( number_length<4 then
				number = strncat( number null_string 4-number_length)
			else
				number = substring(number number_length-3 4)
			) ; end of if
		) ; end of if
	) ; end of if

	c28_31 = number

	; generates drill size and plating
	; --------------------------------

	if( drill>0 then    /* removed spaces for consitency */
		drill = round(drill*conv_factor)
	;	sprintf(drill "%n" drill)          /* deleted - V9 */ 
		sprintf(drillstr "%n" drill) /* use "drillstr" in following code - V9*/
		drill_length = strlen(drillstr)
		if( nequal( drill_length 4) then
			if( drill_length<4 then
				drillstr = strcat( substring(zero_string 1 (4-drill_length)) drillstr) 
			else
				drillstr = " ERR"
			) ; end of if
		) ; end of if
		c33 = "D"
		c34_37 = drillstr
	else
		c33 = " "
		c34_37 = "    "
	) ; end of if

	cond(
		(equal(c2 "2") (c38 = " "))
		(equal(plating "PLATED") (c38 = "P"))
		(t (c38 = "U"))
	) ; end of cond

	; Test point access field  ( modified in version 8 )
	; -----------------------

	if( drill>0 then  /* remove spaces for consitency - V9 */
		c40_41 = "00"                /* Through hole access from either side */
	else
		start_layer = car(layer)
		end_layer = nth(1 layer)
		top = nil
		if( equal(start_layer "ETCH/TOP") then
			top = t
		) ; end of if
		if( equal(end_layer "ETCH/TOP") then
			c40_41 = "01"                /* Access from the primary side */
		else
                  if( equal(end_layer "ETCH/BOTTOM") 
			     c40_41 = secondary      /* Access from the secondary side */
                  ) ; end if
		) ; end of if
	) ; end of if

	; generates x co-ordinate
	; -----------------------

	x = car(xy)
	if( x < 0 then
		c43 = "-"
	else
		c43 = "+"
	) ; end of if

	x = round(x*conv_factor)
	x = abs(x)
	sprintf(c44_49 "%n" x)
	x_length = strlen(c44_49)
	if( nequal( x_length 6) then
		if( x_length<6 then
			c44_49 = strcat( substring(zero_string 1 (6-x_length)) c44_49)
		else
			c44_49 = " ERR  "
		) ; end of if
	) ; end of if

	; generates y co-ordinate
	; -----------------------

    y = nth(1 xy)
    if( y < 0 then
        c51 = "-"
    else
        c51 = "+"
    ) ; end of if
 
	y = round(y*conv_factor)
	y = abs(y) 
	sprintf(c52_57 "%n" y) 
	y_length = strlen(c52_57) 
	if( nequal( y_length 6) then
		if( y_length<6 then
			c52_57 = strcat( substring(zero_string 1 (6-y_length)) c52_57)
		else 
			c52_57 = " ERR  " 
		) ; end of if    
	) ; end of if  

	; generates solder mask information
	; ---------------------------------

	c74 = top_mask+bottom_mask
	
	sprintf(c74 "%n" c74)

	; adds all data to output string
	; ------------------------------

	out = strcat( c1 c2 c3 c4_17 c18_20 c21_26 c27 c28_31 c32 \
	c33 c34_37 c38 c39 c40_41 c42 c43 c44_49 c50 c51 c52_57 \
	c58 c59_62 c63 c64_67 c68_71 c72 c73 c74 c75_80)

	; adds data to file
	; -----------------

	fprintf(outport , "%s\n", out)
		
) ; end of foreach

; creates a list of shortened nets
; --------------------------------
 
foreach( long_net long_net_table
	shortened_net = list( long_net_table[ long_net ] long_net )
	shortened_net_list = cons(shortened_net shortened_net_list)
) ; end of foreach

shortened_net_list = sortcar(shortened_net_list 'lessp)

if( neq(shortened_net_list nil) then

	outport2 = outfile("ipc_356.log")

	fprintf(outport2, "\n%s\n", "The IPC-D-356 format only allows netnames")
	fprintf(outport2, "%s\n", "up to 14 characters long. The following")
	fprintf(outport2, "%s\n\n", "netnames have therefore been changed.")
	fprintf(outport2, "%s\n", "This list has been added to the end of")
	fprintf(outport2, "%s\n\n", "the netlist for reference.")
	fprintf(outport2, "%s\n", "To:          From:")
 
	foreach(shortened_net shortened_net_list
		number = car(shortened_net)
		net = nth(1 shortened_net)
		fprintf(outport, "%s%n%s%s\n", "P  NNAME", number, " ", net)
		fprintf(outport2, "%s%n%s%s\n", " NNAME", number, "   ", net) 
	) ; end of foreach

	close(outport2)

	axlUIViewFileCreate("ipc_356.log" "IPC-D-356 Log File" t 50:30)

) ; end of if

; end of file marker
; ------------------
 
fprintf(outport , "%s\n", "999")

close(outport)

printf("\n%s%s%s\n" , "The file " boardname ".ipc has been created.")


) ; end of ipc

; registers command with allegro
; ------------------------------

axlCmdRegister( "ipc_356" `ipc_356)


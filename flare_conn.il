
;*******************************************************************
;
; Command to flare a design's circular vias through table driven values.
; 
; NOTICE: For proper operation on these commands, the following
;	  2 tasks must be completed first.
;
;		1. "FLR_flareTbl" must be setup to reflect your
;		   design's via sizes and desired flare sizes and
;		   locations relative to the pad they are flaring.
;
;		2. All of the padstack "*.pad" files required by these
;		   commands must be created initially.  For internal
;		   layers, these padstacks must be editted while a
;		   design with an appropriate cross section is open.
;
; ALSO:   This executable is currently setup to flare ONLY circular vias.
;	  To flare both vias and pins, replace the axlSetFindFilter() call
;	  and the strcat() call in "FLR_findAllVias" with the following
;	  2 calls.
;
; axlSetFindFilter(?enabled '("NOALL" "VIAS" "PINS" "INVISIBLE")
;                  ?onButtons '("ALL"))
;
; viacntstring = strcat( "Total Number of Vias and Pins is " viastring "\n"\
;                        "Estimated Number of Flares is " flarestring)
;
;*******************************************************************

axlCmdRegister("flareBoard"   `FLR_flare)
axlCmdRegister("unflareBoard" `FLR_unflare)
axlCmdRegister("flareLayer"   `FLR_flareLayer)
axlCmdRegister("unflareLayer" `FLR_unflareLayer)

FLR_layer = nil
FLR_count = 0
FLR_fileptr = nil

;	land_size  flare_offset  flare_size
FLR_flareTbl = list( list( 18 5  18 )
		     list( 24 8  18 )
	             list( 30 11 18 )
	             list( 36 14 18 )
		)


;==============================================================
;====================== MAIN ROUTINES =========================
;==============================================================


(defun FLR_flare ()
   (let ( net_names test_list pstk_list )

	axlMsgPut( "Searching database for nets..." )
        FLR_fileptr = outfile("flare")
	FLR_count = 0
        FLR_layer = nil
	net_names = FLR_findNetNames()

	foreach( net_name net_names
	    if( net_name != "" then
		pstk_list = FLR_findNetVias( net_name )
		FLR_flareProcess(pstk_list)
	    )
	)

	axlFlushDisplay()
	sprintf( message "Total flares added = %d." FLR_count )
	axlMsgPut( message )
	axlMsgPut( "Flare process complete." )
        close(FLR_fileptr)

   );end let
);end defun


(defun FLR_unflare ()
   (let ( pstk_list )

	FLR_layer = nil
	pstk_list = list()

	pstk_list = FLR_findFlares( )
	sprintf( message "Removing %d flares from the design." 
		 length( pstk_list ) )

	axlMsgPut( message )
	axlMsgPut( "Please wait ..." )
	axlDeleteObject( pstk_list )
	axlMsgPut( "Flare process complete." )

   );end let
);end defun


(defun FLR_flareLayer ()
   (let ( sclass message net_names test_list pstk_list )

        FLR_fileptr = outfile("flare")

	FLR_layer = nil
	sclass = upperCase(axlUIPrompt("Subclass to flare: "))
	FLR_layer = strcat( "ETCH/" sclass )

	axlMsgPut( "Searching database for nets..." )
	FLR_count = 0
	net_names = FLR_findNetNames()

 	foreach( net_name net_names
	    pstk_list = FLR_findNetVias( net_name )
	    FLR_flareProcess(pstk_list)
	)

	axlFlushDisplay()
	sprintf( message "Total flares added to the %s subclass = %d."
		 sclass FLR_count )
	axlMsgPut( message )
	axlMsgPut( "Flare process complete." )
        close(FLR_fileptr)

   );end let
);end defun


(defun FLR_unflareLayer ()
   (let ( sclass message )

	FLR_layer = nil
	sclass = upperCase(axlUIPrompt("Subclass to unflare: "))
	FLR_layer = strcat( "ETCH/" sclass )

	pstk_list = FLR_findFlares( )
	sprintf( message "Removing %d flares from the %s subclass." 
		 length( pstk_list ) sclass )

	axlMsgPut( message )
	axlMsgPut( "Please wait ..." )
	axlDeleteObject( pstk_list )
	axlMsgPut( "Flare process complete." )

   );end let
);end defun


;==============================================================
;====================== FIND FUNCTIONS ========================
;==============================================================


(defun FLR_findNetNames ( )
   (prog ( net_list net_names net_dbid )

	axlClearSelSet()
        axlSetFindFilter(?enabled '("NOALL" "NETS")
                         ?onButtons '("NETS"))
        axlAddSelectAll()
        net_list = axlGetSelSet()
	net_names = list()
	foreach( net_dbid net_list
	  if( (net_dbid->name != "") then
	    net_names = cons( net_dbid->name net_names)
	  )
	)

	return( net_names )

   );end prog
);end defun

(defun FLR_findAllVias ()
   (prog ( via_list )

        designId = axlDBGetDesign()
        axlSetFindFilter(?enabled '("NOALL" "VIAS" "INVISIBLE")
                         ?onButtons '("ALL"))
        axlSingleSelectBox(designId->bBox)
        via_list = axlGetSelSet()
        via_cnt  = length( via_list )
        sprintf( viastring "%L" via_cnt )
        sprintf( flarestring "%L" via_cnt*2.2 )
        viacntstring = strcat( "Total Number of Vias is " viastring "\n"\
                               "Estimated Number of Flares is " flarestring)
        axlUIYesNo( viacntstring )

   );end prog
);end defun


(defun FLR_findNetVias ( net_name )
   (prog ( via_list )

        axlSetFindFilter(?enabled '("NOALL" "EQUIVLOGIC" "NETS" "VIAS" "INVISIBLE")
                         ?onButtons '("ALL"))
        axlSingleSelectName("NET" net_name )
        via_list = axlGetSelSet()

	return( via_list )

   );end prog
);end defun


(defun FLR_findFlares ( )
   (prog ( dbid_list build_list pad_layer via_dbid pad_dbid )

        axlClearSelSet()
        axlSetFindFilter(?enabled '("NOALL" "VIAS" "INVISIBLE")
                         ?onButtons '("VIAS"))
        axlAddSelectAll()
        dbid_list = axlGetSelSet()
	build_list = list()

	foreach( via_dbid dbid_list
	    if( (strncmp("LEF" via_dbid->definition->name 3) == 0) then
		build_list = cons( via_dbid build_list )
	    )
	)

	if( FLR_layer then
	    dbid_list = list()
	else
	    return( build_list )
	)

	foreach( via_dbid build_list

	    foreach( pad_dbid via_dbid->definition->pads

		if( ((pad_dbid->type == "REGULAR") &&
		     (pad_dbid->figureName == "CIRCLE") &&
		     (pad_dbid->figure != nil)) then

		    pad_layer = pad_dbid->layer
		)
	    )

	    if( (FLR_layer == pad_layer) then
		dbid_list = cons( via_dbid dbid_list )
	    )
	)

	return( dbid_list )

   );end prog
);end defun



(defun FLR_flareProcess ( pstk_list )
   (let ( pad_dbid pad_size message distance dX dY
	  start_end cline_seg_dbid cline_seg_list )

        foreach( pstk_dbid pstk_list

	  if( strncmp("LEF" pstk_dbid->definition->name 3) then

	    axlClearSelSet()
	    axlSetFindFilter(?enabled '("NOALL" "CLINESEGS" "INVISIBLE")
			     ?onButtons '("CLINESEGS"))
	    axlAddSelectBox( list(list(xCoord(pstk_dbid->xy) - 12
			               yCoord(pstk_dbid->xy) - 12)
			          list(xCoord(pstk_dbid->xy) + 12
                                       yCoord(pstk_dbid->xy) + 12)) )
	    cline_seg_list = axlGetSelSet()

	    foreach( cline_seg_dbid cline_seg_list

	      foreach( pad_dbid pstk_dbid->definition->pads

		if( ((pad_dbid->type == "REGULAR") &&
		     (pad_dbid->figureName == "CIRCLE") &&
		     (pad_dbid->figure != nil)) then

		  pad_layer = pad_dbid->layer

		  if( (pad_layer == cline_seg_dbid->layer) then

		    if( ((FLR_layer == pad_layer) ||
			 (FLR_layer == nil)) then

		      start_end = cline_seg_dbid->startEnd
		      dX = xCoord(car(start_end)) - xCoord(cadr(start_end))
		      dY = yCoord(car(start_end)) - yCoord(cadr(start_end))
		      distance = sqrt( (dX * dX) + (dY * dY) )

		      pad_size = abs(xCoord(car(pad_dbid->bBox)) -
				     xCoord(cadr(pad_dbid->bBox)))

		      if( distance >= (pad_size / 2) then
		         FLR_addFlares( cline_seg_dbid
				        pad_size
				        pstk_dbid->xy
				      )
		      )

		      if( FLR_count == 1 then
			axlMsgPut( "Flares are now being added. Please wait..." )
		      )
		      if( ((mod(FLR_count 100)==0) && (FLR_count>0)) then
			sprintf(message "%d flares added." FLR_count)
			axlMsgPut(message)
		      )
		    )
		  )
		)
	      );end foreach pad
	    );end foreach cline
	  );if it is not a flare
        );end foreach pstk

   );end let
);end defun


;==============================================================
;================== DATABASE ALGORITHMS =======================
;==============================================================


(defun FLR_getFlareLocation ( seg_dbid origin offset )
   (prog ( x_location y_location other_pt slope radians deltaX deltaY
	   deltaLocationX deltaLocationY )

	if( (car(seg_dbid->startEnd) == origin) then
	    other_pt = cadr(seg_dbid->startEnd)
	else
	    other_pt = car(seg_dbid->startEnd)
	)


	if( xCoord(other_pt) == xCoord(origin) then

	    x_location = xCoord(origin)

	    if( yCoord(other_pt) > yCoord(origin) then
		y_location = yCoord(origin) + offset
	    else
		y_location = yCoord(origin) - offset
	    )

	    return( list( x_location y_location) )
	)
	if( yCoord(other_pt) == yCoord(origin) then

	    y_location = yCoord(origin)

	    if( xCoord(other_pt) > xCoord(origin) then
		x_location = xCoord(origin) + offset
	    else
		x_location = xCoord(origin) - offset
	    )

	    return( list( x_location y_location) )
	)

	deltaX = xCoord(other_pt) - xCoord(origin)
	deltaY = yCoord(other_pt) - yCoord(origin)
	slope = deltaY / deltaX
	radians = abs( atan( slope ) )
	deltaLocationX = offset * cos( radians )
	deltaLocationY = offset * sin( radians )

	if( xCoord(other_pt) > xCoord(origin) then
	    if( yCoord(other_pt) > yCoord(origin) then
		x_location = xCoord(origin) + deltaLocationX
		y_location = yCoord(origin) + deltaLocationY
	    else
		x_location = xCoord(origin) + deltaLocationX
		y_location = yCoord(origin) - deltaLocationY
	    )

	    return( list( x_location y_location) )
	)
	if( xCoord(other_pt) < xCoord(origin) then
	    if( yCoord(other_pt) < yCoord(origin) then
		x_location = xCoord(origin) - deltaLocationX
		y_location = yCoord(origin) - deltaLocationY
	    else
		x_location = xCoord(origin) - deltaLocationX
		y_location = yCoord(origin) + deltaLocationY
	    )

	    return( list( x_location y_location) )
	)


   );end prog
);end defun


(defun FLR_addFlares ( segment_dbid pad_size pad_location )
   (let ( flare_size flare_offset flare_loc sclass pstk_name )

	flare_offset = nil
	flare_size = nil

	foreach( item FLR_flareTbl
	    if( (car(item) == pad_size) then
		sprintf( flare_size "%d" caddr(item))
		flare_offset = cadr(item)
	    )
	)

	if( (flare_offset == nil || flare_size == nil) then
	    axlMsgPut( "No entry in table for %2.0f size pad." pad_size)
	else
	    flare_loc = FLR_getFlareLocation( segment_dbid
					      pad_location
					      flare_offset
		        )
	    sclass = utl_subclassName( segment_dbid->layer )
	    sprintf( pstk_name "LEF%s_%s" flare_size sclass)

	    if( axlDBCreateVia( pstk_name flare_loc ) then
		fprintf(FLR_fileptr "Flare %s added %L on %s.\n"
			pstk_name pad_location sclass)
		FLR_count = FLR_count + 1
	    )

	)

   );end let
);end defun



defun( utl_subclassName ( layerName )
 
   prog( ( subclass_name letter letter_list build_subclass_name )
 
        subclass_name = ""
        build_subclass_name = nil
        letter_list = parseString( layerName "" )
 
        foreach( letter letter_list
 
            if( build_subclass_name then
                subclass_name = strcat( subclass_name letter )
            )
 
            if( letter == "/" then
                build_subclass_name = t
            )
        )
 
        return( subclass_name )
 
   ) ; end prog
) ; End of defun



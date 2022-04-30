;                Add Assembly Reference Designators
;                ----------------------------------
 
; This routine adds reference designator text to Package Geometry/
; Display_Top. The designators are positioned to be at the centre
; of the Place_Bound_Top rectangle(s) for each component. If the
; component is rotated so that the width is less than 129 mils
; (or it's equivalent in the current database units) the text is
; rotated to achieve a better fit. This will make the assembly
; drawing easier to read than having text at all four rotations.

; Any text already on the Package Geometry/Display_Top layer is
; deleted, so if this layer is used, modify the routine to add the
; text to an unused layer.

; It doesn't matter what units the database is in, because all
; numbers are converted at the start of the routine to the current
; database units.

; Text Block 2 is used, which is assumed to be set to 25 35 75 8 8
; (mils). If the text width and height are substantially different
; to this, the output may appear distorted.

; To run the program type "assembly" on the Allegro command line.

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
; Version 2: Added '?' before rotation paramater to solve some
;            incompatability problems.
; -----------------------------------------------------------------
;
; RBG 05-05-2004
;  - Fixed table definition for reftable 
;  - Turn on subclass PACKAGE GEOMETRY/DISPLAY_TOP when done.
;  - Tested on version 15.1
; -----------------------------------------------------------------

(defun assembly ()

; converts to current database units
; ----------------------------------

min_width = axlMKSConvert(129 "MILS")
text_offset = axlMKSConvert(18 "MILS")

; creates table
; -------------

reftable = makeTable("retfable" nil)

; defines text blocks
; -------------------

rotate_no = make_axlTextOrientation(
                ?textBlock "2", ?rotation 0.,
                ?mirrored nil, ?justify "center")
rotate_yes = make_axlTextOrientation(
                ?textBlock "2", ?rotation 270.,
                ?mirrored nil, ?justify "center")

; deletes text on package geometry/display_top
; --------------------------------------------

drain()
axlClearSelSet()
vis_list = axlVisibleGet()
axlVisibleDesign(nil)
axlVisibleLayer("PACKAGE GEOMETRY/DISPLAY_TOP" t)
axlSetFindFilter(?enabled list("noall" "text")
        ?onButtons list("noall" "text"))
axlAddSelectAll()
axlDeleteObject(axlGetSelSet())
 
; selects symbols
; ---------------

axlClearSelSet()
axlVisibleDesign(nil)
axlVisibleLayer("PACKAGE GEOMETRY/ASSEMBLY_TOP" t)
axlSetFindFilter(?enabled list("noall" "symbols")
        ?onButtons list("noall" "symbols"))
axlAddSelectAll()
axlVisibleSet(vis_list)
symbol_db_list = axlGetSelSet()
axlClearSelSet()
foreach(symbol_db symbol_db_list
	refdes = symbol_db->refdes
	mir = symbol_db->isMirrored

	; checks if symbol is mirrored
    ; ----------------------------

	if( eq(mir nil) then
		children_db_list = symbol_db->children
	
		; checks if symbol has attached shapes
		; ------------------------------------

		if( neq(children_db_list nil) then
			foreach(children_db children_db_list
				isShape = children_db->objType
				shape_layer = children_db->layer
					if( equal(isShape "shape") then

						; checks if shape is on package geometry/place_bound_top
						; ------------------------------------------------------

						if( equal(shape_layer "PACKAGE GEOMETRY/PLACE_BOUND_TOP") then
							boundary = children_db->bBox
							ref_exists = reftable[refdes]

							; checks if shape already exists for refdes
							; -----------------------------------------

							if( equal(ref_exists nil) then

								; adds refdes/boundary box to table
								; ---------------------------------

								reftable[refdes] = boundary
							else

								; calculates maximum size box
								; ----------------------------

								old_boundary = reftable[refdes]
								old_llx = caar(old_boundary)
								old_urx = caadr(old_boundary)
								old_ury = cadadr(old_boundary)
								old_lly = cadar(old_boundary)
								boundary = children_db->bBox
								llx = caar(boundary)
								urx = caadr(boundary)
								ury = cadadr(boundary)
								lly = cadar(boundary)
								llx = min(llx old_llx)
								urx = max(urx old_urx)
								ury = max(ury old_ury)
								lly = min(lly old_lly)
								boundary = list(llx:lly urx:ury)
								reftable[refdes] = boundary
							) ; end of if ref exists
						) ; end of package geometry
					) ; end of is shape
			) ; end of foreach
		) ; end of if children
	) ; end or if mir
) ; end of foreach symbol_db

; reads each refdes/boundary box pair
; -----------------------------------

foreach( refdes reftable
	if( neq(refdes nil) then	
		boundary = reftable[refdes]
		llx = caar(boundary)
    	urx = caadr(boundary)
    	ury = cadadr(boundary)
    	lly = cadar(boundary)
 		width = urx-llx
    	refpos_x = (width/2)+llx
    	height = ury-lly
    	refpos_y = (height/2)+lly

					; if width > 129 mils text is at 0 degrees
					; ----------------------------------------
	 
                    if((width > min_width) then
 
                        refpos_y = refpos_y - text_offset
                        refpos = refpos_x:refpos_y
                        axlDBCreateText(refdes , refpos , rotate_no ,
                                        "package geometry/display_top" )
                    else

                    ; if width <= 129 mils text is at 270 degrees
                    ; -------------------------------------------

                        refpos_x = refpos_x - text_offset
                        refpos = refpos_x:refpos_y
                        axlDBCreateText(refdes , refpos , rotate_yes ,
                                        "package geometry/display_top" ))

	) ; end of if
) ;end of foreach
axlVisibleLayer("PACKAGE GEOMETRY/DISPLAY_TOP" t)

) ; end of function assembly

; registers command assembly with Allegro
; ---------------------------------------

axlCmdRegister( "assembly" `assembly)

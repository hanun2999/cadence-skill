;                    Show Component Heights 
;                    ----------------------
;
; This program extracts the 'Height Place Text' value from the
; PLACE_BOUND of each component and generates a sorted list for 
; either the top or the bottom of the board, showing the component
; name and height. Components above a specific height can be 
; highlighted if required.

; The program requires that 'Height Place Text' is included
; on any components where the height is significant. This version
; shows the height in the same units in which it appears on the
; symbol, eg. mils or mm, but it is possible to convert the output
; to different units.

; Components with more than one item of 'Height Place Text' will
; appear in the list once for every occurence of the property.
; Where there is a minimum and maximum height, only the maximum 
; height is given.

; To run the program type "height" on the Allegro command line.

; -----------------------------------------------------------------

; Tested on Allegro 11.0

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
; Version 2: Modified to obtain data without using axlExtractToFile.
; -----------------------------------------------------------------
 
(defun component_height ()

; set variables
; -------------

hetop = t
hebot = nil
hl = nil
run_once = nil
text_bound = nil
hl_height = 0
height_ref_list_top = ()
height_ref_list_bottom = ()

; call for form
; -------------

createheightform()
heightform()

) ; end of function component_height

; create form
; -----------

(defun createheightform ()

drain()
heightform_file = "height.form"
heightform = outfile(heightform_file "w")

fprintf(heightform "FILE_TYPE=FORM_DEFN VERSION=2\n")
fprintf(heightform "FORM\n")
fprintf(heightform "FIXED\n")
fprintf(heightform "PORT 35 18\n")
fprintf(heightform "HEADER \"Component Height Utility\"\n")
fprintf(heightform "\n")

fprintf(heightform "ACTIVEFIELD \"height_do\"\n")
fprintf(heightform "\n")

fprintf(heightform "TILE\n")
fprintf(heightform "TEXT \"Components on\"\n")
fprintf(heightform "TLOC 1 2\n")
fprintf(heightform "ENDTEXT\n")
fprintf(heightform "\n")

fprintf(heightform "FIELD hetop\n")
fprintf(heightform "FLOC 16 2\n")
fprintf(heightform "CHECKLIST \"TOP\" \"tb\"\n")
fprintf(heightform "ENDFIELD\n")
fprintf(heightform "\n")

fprintf(heightform "FIELD hebot\n")
fprintf(heightform "FLOC 24 2\n")
fprintf(heightform "CHECKLIST \"BOTTOM\" \"tb\"\n")
fprintf(heightform "ENDFIELD\n")
fprintf(heightform "\n")
 
fprintf(heightform "FIELD hl\n")
fprintf(heightform "FLOC 1 6\n")
fprintf(heightform "CHECKLIST \"Hilite Comps Above\"\n")
fprintf(heightform "ENDFIELD\n")
fprintf(heightform "\n")
 
fprintf(heightform "FIELD hl_height\n")
fprintf(heightform "FLOC 24 6\n")
fprintf(heightform "STRFILLIN 7 7\n")
fprintf(heightform "ENDFIELD\n")
fprintf(heightform "\n")
 
fprintf(heightform "FIELD height_do\n")
fprintf(heightform "FLOC 6 10\n")
fprintf(heightform "MENUBUTTON \"Do\" 9 3\n")
fprintf(heightform "ENDFIELD\n")
fprintf(heightform "\n")

fprintf(heightform "FIELD height_finish\n")
fprintf(heightform "FLOC 20 10\n")
fprintf(heightform "MENUBUTTON \"Finish\" 9 3\n")
fprintf(heightform "ENDFIELD\n")
fprintf(heightform "\n")

fprintf(heightform "FIELD output_list\n")
fprintf(heightform "FLOC 5 14\n")
fprintf(heightform "LIST \"\" 25 10\n")
fprintf(heightform "ENDFIELD\n")
 
fprintf(heightform "\n")
fprintf(heightform "ENDTILE\n")
fprintf(heightform "\n")
 
fprintf(heightform "ENDFORM\n")
close( heightform)

) ; end of function createheightform

; display form
; ------------

(defun heightform ()

heightform=axlFormCreate( (gensym) heightform_file nil 'Height_Action t )
axlFormDisplay(heightform)
axlFormSetField(heightform "hetop" t)
axlFormSetField(heightform "output_list" " ")
axlUIWPrint(heightform "Press 'DO' To Start")
 
) ; end function heightform

; what to do with form actions
; ----------------------------

(defun Height_Action (heightform)
 
(case heightform->curField
 
	("height_do"
        axlFormListDeleteAll(heightform "output_list")
		hilite_list = ()
			if( eq(run_once nil)
        		do_height_extract()
			) ; end of if
		run_once = t
		do_height_print()
        nil
    )

    ("height_finish"
        axlFormClose(heightform)
	
		; tidies up output files
		; may be incompatible with some platforms
		; ---------------------------------------
        shell("rm -f height.form")

        nil
    )
 
    ("hetop"
    hetop=(heightform->curValue)
	)
 
    ("hl"
    hl=(heightform->curValue)
	)

    ("hl_height"
    hl_height=(heightform->curValue)
	hl_height=evalstring(hl_height)
    )

) ; end case

) ; end function Height_Action

; creates lists of height and refdes
; ----------------------------------

(defun do_height_extract ()

axlUIWPrint(heightform "Please Wait....")

axlClearSelSet()
vis_list = axlVisibleGet()
axlVisibleDesign(nil)
axlVisibleLayer("PACKAGE GEOMETRY/PLACE_BOUND_TOP" t)
axlVisibleLayer("PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM" t)
axlSetFindFilter(?enabled list("noall" "text")
        ?onButtons list("noall" "text"))
axlAddSelectAll()
axlVisibleSet(vis_list)
text_db_list = axlGetSelSet()
    foreach( text_db text_db_list
        text_layer = text_db->layer
        if( equal(text_layer "PACKAGE GEOMETRY/PLACE_BOUND_TOP") then
            place_bound_text = text_db->text
            parent = text_db->parent
            if( neq(parent nil) then
                shape = parent->objType
                shape = parent->parent
                refdes = shape->refdes
                if( neq(refdes nil) then
                    comp_height_top = place_bound_text
	
					; checks for text instead of numbers
                    text_bound = rexMatchp("[A-Za-z]+" comp_height_top)

                    	if( eq(text_bound t) then
                                comp_height_top = "0"
                                text_bound = nil)
    
					comp_height_top = evalstring(comp_height_top)
                        if( (comp_height_top > 0) then
                                height_ref_top = list(comp_height_top refdes)
                                height_ref_list_top = cons(height_ref_top height_ref_list_top)
                        ) ; end if
                ) ; end of if
            ) ; end of if
        ) ; end of if

        if( equal(text_layer "PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM") then
            place_bound_text = text_db->text
            parent = text_db->parent
            if( neq(parent nil) then
                shape = parent->objType
                shape = parent->parent
                refdes = shape->refdes
                if( neq(refdes nil) then
                    comp_height_bottom = place_bound_text

					; checks for text instead of numbers
                    text_bound = rexMatchp("[A-Za-z]+" comp_height_bottom)

						if( eq(text_bound t) then
                                comp_height_bottom = "0"
                                text_bound = nil)
 
                comp_height_bottom = evalstring(comp_height_bottom)
                        if( (comp_height_bottom > 0) then
                                height_ref_bottom = list(comp_height_bottom refdes)
                                height_ref_list_bottom = cons(height_ref_bottom height_ref_list_bottom)
                        ) ; end if
                ) ; end of if
            ) ; end of if
        ) ; end of if
 
    ) ; end of foreach

height_ref_list_top = sortcar(height_ref_list_top 'lessp)
height_ref_list_top = reverse(height_ref_list_top)
height_ref_list_bottom = sortcar(height_ref_list_bottom 'lessp)
height_ref_list_bottom = reverse(height_ref_list_bottom)

) ; end of function do_height_extract

; prints data
; -----------

(defun do_height_print ()

axlUIWPrint(heightform "Please Wait....")

if( eq(hetop t) then
outport = outfile("top_list")
		foreach(heightref_top height_ref_list_top
			height_top = car(heightref_top)
			ref_top = nth(1 heightref_top)
				if( eq(hl t) then
					if( (height_top > hl_height) then
						hilite_list = cons(ref_top hilite_list)
					) ; end if
				) ; end if	

			is_fixed = fixp(height_top)
			if( eq(is_fixed t) then
				sprintf(list_out , "%s %s %n" , ref_top , "is" , height_top)
				fprintf(outport , "%s %s %n\n" , ref_top , "is" , height_top)
			else
				sprintf(list_out , "%s %s %g" , ref_top , "is" , height_top)	
				fprintf(outport , "%s %s %g\n" , ref_top , "is" , height_top)
			) ; end of if
			axlFormSetField(heightform "output_list" list_out)
		) ; end of foreach	
close(outport)

else
outport = outfile("bottom_list")
        foreach(heightref_bottom height_ref_list_bottom
            height_bottom = car(heightref_bottom)
            ref_bottom = nth(1 heightref_bottom)
               if( eq(hl t) then
                    if( (height_bottom >= hl_height) then
                        hilite_list = cons(ref_bottom hilite_list)
                    ) ; end if
                ) ; end if 

			is_fixed = fixp(height_bottom) 
            if( eq(is_fixed t) then 
           		sprintf(list_out , "%s %s %n" , ref_bottom , "is" , height_bottom)
			fprintf(outport , "%s %s %n\n" , ref_bottom , "is" , height_bottom)
			else
				sprintf(list_out , "%s %s %g" , ref_bottom , "is" , height_bottom)
				fprintf(outport , "%s %s %g\n" , ref_bottom , "is" , height_bottom)	
			) ; end of if

			axlFormSetField(heightform "output_list" list_out)
        ) ; end of foreach
close(outport)
) ; end of if

 axlClearSelSet()
         axlSetFindFilter(?enabled '(noall components) ?onButtons '(noall components))
 
    axlAddSelectAll()
    allcomps = axlGetSelSet()
	axlDehighlightObject(allcomps)
	axlClearSelSet()

; highlights components if required
; ---------------------------------

if( eq(hl t) then

        axlSetFindFilter(?enabled '(noall components) ?onButtons '(noall components))
	axlSingleSelectName( "COMPONENT" hilite_list)
	tohilite = axlGetSelSet()
	axlHighlightObject(tohilite)

) ; end of if

axlFormSetField(heightform "output_list" "--END--")
axlFormDisplay(heightform)
axlUIWPrint(heightform "Complete.")
axlFlushDisplay()

) ; end of function do_height_print

; registers command with allegro
; ------------------------------

axlCmdRegister( "height" `component_height)

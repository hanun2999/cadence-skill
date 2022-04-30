
axlCmdRegister( "ch_text_overlap" `check_text_overlap)

layer = "TOP"
clearance = 3
text_pad = t
text_testpoint = nil
text_text = nil
barcode_overlap = nil
refdes_component = nil
formname = nil
location = makeTable("loc" 0)
num = 0
cnt = 0

(defun check_text_overlap ()
    axlVisibleDesign(nil)
    turn_on_layer( layer)
    formname = "./refdes_over.form"
    biuld_form(formname)
)

(defun biuld_form (formname)
(prog ()
   pform = outfile(formname "w")

   fprintf(pform "FILE_TYPE=FORM_DEFN VERSION=2\n")

   fprintf(pform "FORM\n")

   fprintf(pform "FIXED\n")

   fprintf(pform "PORT 26 10\n")

   fprintf(pform "HEADER \"Checking Text Overlap Form\"\n")

   fprintf(pform "POPUP <Layer_Names>")

   fprintf(pform "\"TOP\" \"TOP\",\"BOTTOM\" \"BOTTOM\".\n")

   fprintf(pform "TILE\n")


   fprintf(pform "TEXT \"Select Checking Layer:\"\n")

   fprintf(pform "TLOC 3 1\n")

   fprintf(pform "ENDTEXT\n")

   fprintf(pform "FIELD check_layer\n")

   fprintf(pform "FLOC 6 3\n")

   fprintf(pform "ENUMSET 11\n")

   fprintf(pform "POP \"Layer_Names\"\n")

   fprintf(pform "ENDFIELD\n")


   fprintf(pform "TEXT \"Clearance:\"\n")

   fprintf(pform "TLOC 3 6\n")

   fprintf(pform "ENDTEXT\n")

   fprintf(pform "FIELD clearance\n")

   fprintf(pform "FLOC 12 6\n")

   fprintf(pform "REALFILLIN 6 6\n")

   fprintf(pform "REALMIN -50.0\n")

   fprintf(pform "REALMAX 100.0\n")

   fprintf(pform "ENDFIELD\n")


   fprintf(pform "FIELD text_pad\n")

   fprintf(pform "FLOC 6 9\n")

   fprintf(pform "FGROUP \"Overlap\"\n")

   fprintf(pform "CHECKLIST \"Text to Pin\" \"overlap\"\n")

   fprintf(pform "ENDFIELD\n")

   fprintf(pform "FIELD text_testpoint\n")

   fprintf(pform "FLOC 6 11\n")

   fprintf(pform "FGROUP \"Overlap\"\n")

   fprintf(pform "CHECKLIST \"Text to Testpoint\" \"overlap\"\n")

   fprintf(pform "ENDFIELD\n")

   fprintf(pform "FIELD text_text\n")

   fprintf(pform "FLOC 6 13\n")

   fprintf(pform "FGROUP \"Overlap\"\n")

   fprintf(pform "CHECKLIST \"Text to Text\" \"overlap\"\n")

   fprintf(pform "ENDFIELD\n")

   fprintf(pform "FIELD refdes_component\n")

   fprintf(pform "FLOC 6 15\n")

   fprintf(pform "FGROUP \"Overlap\"\n")

   fprintf(pform "CHECKLIST \"Refdes to component\" \"overlap\"\n")

   fprintf(pform "ENDFIELD\n")

   fprintf(pform "FIELD barcode_overlap\n")

   fprintf(pform "FLOC 6 17\n")

   fprintf(pform "FGROUP \"Overlap\"\n")

   fprintf(pform "CHECKLIST \"Bar Code Overlap\" \"overlap\"\n")

   fprintf(pform "ENDFIELD\n")


   fprintf(pform "TEXT \"View error:\"\n")

   fprintf(pform "TLOC 3 20\n")

   fprintf(pform "ENDTEXT\n")

   fprintf(pform "FIELD next_view\n")

   fprintf(pform "FLOC 6 22\n")

   fprintf(pform "STRFILLIN 10 20\n")

   fprintf(pform "ENDFIELD\n")

   fprintf(pform "FIELD prv_ctl\n")

   fprintf(pform "FLOC 18 22\n")

   fprintf(pform "MENUBUTTON \"<<\" 3 3\n")

   fprintf(pform "ENDFIELD\n")

   fprintf(pform "FIELD next_ctl\n")

   fprintf(pform "FLOC 22 22\n")

   fprintf(pform "MENUBUTTON \">>\" 3 3\n")

   fprintf(pform "ENDFIELD\n")


   fprintf(pform "FIELD done\n")

   fprintf(pform "FLOC 2 26\n")

   fprintf(pform "MENUBUTTON \"Done\" 5 3\n")

   fprintf(pform "ENDFIELD\n")

   fprintf(pform "FIELD check\n")

   fprintf(pform "FLOC 8 26\n")

   fprintf(pform "MENUBUTTON \"Check\" 5 3\n")

   fprintf(pform "ENDFIELD\n")

   fprintf(pform "FIELD unselect\n")

   fprintf(pform "FLOC 15 26\n")

   fprintf(pform "MENUBUTTON \"unSelect\" 6 3\n")

   fprintf(pform "ENDFIELD\n")


   fprintf(pform "ENDTILE\n")

   fprintf(pform "ENDFORM\n")

   close(pform)


   form=axlFormCreate( (gensym) "refdes_over.form"
   `(e inner) `pform_Action t)


   axlFormDisplay(form)

   axlFormSetField(form "check_layer" layer)

   axlFormSetField(form "clearance" clearance)

   axlFormSetField(form "text_pad" text_pad)

   axlFormSetField(form "text_testpoint" text_testpoint)

   axlFormSetField(form "text_text" text_text)

   axlFormSetField(form "barcode_overlap" barcode_overlap)

   axlFormSetField(form "refdes_component" refdes_component)

))

(defun pform_Action (form)


 axlDBRefreshId(axlDBGetDesign())
   (case form->curField


   	("done"

    	    axlFormClose(form)

    	    axlCancelEnterFun()

    	    deleteFile(formname)
   	    axlMsgPut("Done")
    	    nil

   	)

   	("check"
   	    init_loc_text()
   	    axlMsgPut("Cheching overlapping text .")
     	    turn_on_layer(layer)
   	    refdes_on_pad()
   	    axlFormSetField(form "next_view" sprintf(dummy "Tatol: %d" cnt))
   	    t
   	)
   	("unselect"
   	    axlMsgPut("unSelect all objects.")
   	    unselect_object()
   	    t
   	)
   	("next_ctl"
   	    axlMsgPut("Location the next position.")
   	    location_text(location)
   	    t
   	)
   	("prv_ctl"
   	    axlMsgPut("Location the previous position.")
   	    location_prv(location)
   	    t
   	)

   	("check_layer"
   	    layer = form->curValue
     	    turn_on_layer(layer)	;turn on the layer etch : etch pin via
   	    axlMsgPut("Select %s layer" layer)
   	    t
   	)
   	("clearance"

    	    clearance = form->curValue
   	    axlMsgPut("Set clearance : %f" clearance)
    	    t

   	)
   	("text_pad"
    	    text_pad = form->curValue

   	    if(text_pad then
   	     	axlMsgPut("Check text on pad." )
   	    else
   	     	axlMsgPut("Don't check text on pad." )
   	    )
    	    t

   	)
   	("text_testpoint"
    	    text_testpoint = form->curValue
    	    if(layer == "TOP" then
    	        if(text_testpoint axlMsgPut("Top side hasn't testpointes." ))
    	    else
   	    	if(text_testpoint then
  	    	    axlMsgPut("Check text on testpoint." )
   	    	else
   	    	    axlMsgPut("Don't check text on testpoint." )
   	        )
    	    )
    	    t

   	)
  	("barcode_overlap"
    	    barcode_overlap = form->curValue

   	    if(barcode_overlap then
   	    	axlMsgPut("Check bar code ." )
   	    else
   	    	axlMsgPut("Don't check bar code ." )
   	    )
    	    t

   	)

   	("refdes_component"
    	    refdes_component = form->curValue

   	    if(refdes_component then
   	    	axlMsgPut("Check refdes on component." )
   	    else
   	    	axlMsgPut("Don't check refdes on component." )
   	    )
    	    t

   	)

 	("text_text"
    	    text_text = form->curValue

   	    if(text_text then
   	    	axlMsgPut("Check text on text." )
   	    else
   	    	axlMsgPut("Don't check text on text." )
   	    )
    	    t

   	)

    )
)

(defun refdes_on_pad ()

    if(barcode_overlap then
    	Going_On=axlGetParam("paramLayerGroup:PACKAGE GEOMETRY/paramLayer:SILKSCREEN_TOP")

    	Going_On->visible=t

    	axlSetParam(Going_On)
    	Going_On=axlGetParam("paramLayerGroup:PACKAGE GEOMETRY/paramLayer:SILKSCREEN_BOTTOM")

    	Going_On->visible=t

    	axlSetParam(Going_On)

    	axlUIWRedraw(nil)
    	axlClearSelSet()

    )

    unselect_object()
    axlSetFindFilter(?enabled '(noall text) ?onButtons '(noall text))

    alltexts = axlGetSelSet(axlAddSelectAll())


    if(text_pad then
    	cnt = 0
    	if(layer == "TOP" then
  	    axlSetFindFilter(?enabled '(noall pins)

  	    ?onButtons '(noall pins))
    	else
  	    axlSetFindFilter(?enabled '(noall pins)

  	    ?onButtons '(noall pins))
    	)
    	foreach(txt alltexts text_on_pad(txt))
    	axlMsgPut("Total of text on %s pad : %d" layer cnt)
    )
    if(text_testpoint then
    	cnt = 0
    	if(layer == "TOP" then
  	    axlSetFindFilter(?enabled '(noall )

  	    ?onButtons '(noall ))
    	else
  	    axlSetFindFilter(?enabled '(noall vias)

  	    ?onButtons '(noall vias))
    	)
    	foreach(txt alltexts text_on_testpoints(txt))
    	axlMsgPut("Total of text on %s testpoint : %d" layer cnt)
    )
    if(text_text then
    	cnt = 0
        allseltext = nil
    	axlSetFindFilter(?enabled '(noall text) ?onButtons '(noall text))

    	foreach(txt alltexts text_overlap_text(txt))
        axlHighlightObject( allseltext)
    	axlMsgPut("Total of text on %s text : %d" layer cnt)
    )
    if(refdes_component then
        allselcom = nil
    	cnt = 0
	axlSetFindFilter(?enabled '(noall shapes) ?onButtons '(noall shapes))

    	foreach(txt alltexts refdes_overlap_component(txt))
        axlHighlightObject( allselcom)
    	axlMsgPut("Total of refdes on %s component : %d" layer cnt)
    )
    if(barcode_overlap then
    	axlSetFindFilter(?enabled '(noall pins vias text) ?onButtons '(noall pins vias text ))

        allselcom = nil
    	cnt = 0
    	foreach(txt alltexts  	; i=0 j=0 k=0 n=0 ++i txt = nthelem(i alltexts)
	   if(txt->text == "BAR  CODE" then
	   	barcode_overlap_atom(txt)
	   )
    	)
        axlHighlightObject( allselcom)
    	axlMsgPut("Bar code overlaps other item.")

    	Going_On=axlGetParam("paramLayerGroup:PACKAGE GEOMETRY/paramLayer:SILKSCREEN_TOP")

    	Going_On->visible=nil

    	axlSetParam(Going_On)
    	Going_On=axlGetParam("paramLayerGroup:PACKAGE GEOMETRY/paramLayer:SILKSCREEN_BOTTOM")

    	Going_On->visible=nil

    	axlSetParam(Going_On)
    	Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:PACKAGE GEOMETRY/paramLayer:SILKSCREEN_%s" layer))

    	Going_On->visible=t

    	axlSetParam(Going_On)

    	axlUIWRedraw(nil)
    	axlClearSelSet()

    )
)

(defun barcode_overlap_atom (txt)
(prog ()

    bars = txt->parent->name
    barx = txt->parent->name
    if(txt->layer == strcat( "PACKAGE GEOMETRY/SILKSCREEN_" layer)
    || (txt->layer != strcat( "PACKAGE GEOMETRY/SILKSCREEN_" layer)
    && index(barx "X") == "X") then
	if(axlSingleSelectBox(get_bar_code_box(txt)) != nil then
	    allboxes = axlGetSelSet()
	    axlClearSelSet()
	    have = nil
	    foreach(item allboxes ;++k item = nthelem(k allboxes)
	        if(txt->text != item->text && (item->objType != "via"
	        || item->testPoint != nil)  then
	            allselcom = cons(item allselcom)
	       	    allselcom = cons(txt->parent allselcom)
		    have = t
		)
	    )
	    if(have then ++cnt add_loc_text(txt))
	)
    )
))

(defun refdes_overlap_component ( txt)
(prog ()
let( (item allbox)

    if(txt->layer == strcat( "REF DES/SILKSCREEN_" layer) then
	if(axlSingleSelectBox(getbox(txt)) != nil then
	    allboxes = axlGetSelSet()
	    axlClearSelSet()
	    have = nil
	    foreach(item allboxes ;++k item = nthelem(k allboxes)
	        if(item->objType == "shape" &&
	        item->layer == strcat( "PACKAGE GEOMETRY/PLACE_BOUND_" layer) then
	            allselcom = cons(item allselcom)
	       	    allselcom = cons(txt allselcom)
	       	    have = t
		)
	    )
	    if(have then ++cnt add_loc_text(txt))
	)
    )
)))

(defun text_overlap_text ( txt)
(prog ()
let( (item allbox)

	if(txt->layer == strcat( "REF DES/SILKSCREEN_" layer)
	|| txt->layer == strcat( "PACKAGE GEOMETRY/SILKSCREEN_" layer) then
	    if(axlSingleSelectBox(getbox(txt)) != nil then
	    	allboxes = axlGetSelSet()
		axlClearSelSet()
		allbox = nil
		foreach(item allboxes	;++n item = nthelem(n allboxes)
		    if(item->text != txt->text then
		        allbox = cons(item allbox)
		    )
		)
		have = nil
	    	foreach(item allbox ;++k item = nthelem(k allbox)
		    if(item->objType == "text" then
		        if(text_on_text(txt item) != nil then
		        allseltext = cons(item allseltext)
		    	allseltext = cons(txt allseltext)
		    	have = t
		        )
		    )
		)
		if(have then ++cnt add_loc_text(txt))
	    )
	)
)))

(defun text_on_pad (txt)
(prog ()
let( (item allbox)

    	if(txt->layer == strcat( "REF DES/SILKSCREEN_" layer)
    	|| txt->layer == strcat( "PACKAGE GEOMETRY/SILKSCREEN_" layer) then
	    if(axlSingleSelectBox(getbox(txt)) != nil then
	    	allboxes = axlGetSelSet()
		axlClearSelSet()
		allbox = nil
		foreach(item allboxes	;++n item = nthelem(n allboxes)
		    if(item->text != txt->text then
		        allbox = cons(item allbox)
		    )
		)
		have = nil
	    	foreach(item allbox ;++k item = nthelem(k allbox)
		    if(item->objType == "pin" then
			;allselpad = cons(txt allselpad)
			axlHighlightObject(list(txt item))
			have = t
		    )
		)
		if(have then ++cnt add_loc_text(txt))
	    )
	)
)))

(defun text_on_testpoints (txt)
(prog ()
let( (item allbox)

    	if(txt->layer == strcat( "REF DES/SILKSCREEN_" layer)
    	|| txt->layer == strcat( "PACKAGE GEOMETRY/SILKSCREEN_" layer) then
	    if(axlSingleSelectBox(getbox(txt)) != nil then
	    	allboxes = axlGetSelSet()
		axlClearSelSet()
		allselvia = nil
		have = nil
	    	foreach(item allboxes ;++k item = nthelem(k allbox)
		    if(layer == "BOTTOM" && item->objType == "via" && item->testPoint != nil then
			allselvia = cons(txt allselvia)
		        axlHighlightObject(list(item txt))
		        have = t
		    )
		)
		if(have then ++cnt add_loc_text(txt))
	    )
	)
)))

(defun get_bar_code_box (txt)
(prog ()
    if(txt->text == "BAR  CODE"  then
    	box = txt->parent->bBox
    	bleft   = car( nth(0 box)) - clearance
    	btop    = cadr(nth(1 box)) + clearance
    	bright  = car( nth(1 box)) + clearance
    	bbottom = cadr(nth(0 box)) - clearance
    	return(list(bleft:btop bright:bbottom))
    )
    return(nil)
))

(defun getbox (txt)
(prog ()
    loff = 3 toff = 0 roff = -4 boff = 16
    left = car(nth(0 txt->bBox)) - clearance
    top = cadr(nth(1 txt->bBox)) + clearance
    right = car(nth(1 txt->bBox)) + clearance
    bottom = cadr(nth(0 txt->bBox)) - clearance
;    boff = round((top - bottom)/5)+3
    if(layer == "TOP" then
    	case(round(txt->rotation)
    	    (0
    	    	boff = round(abs(top - bottom)/5)+3
    	     	left = left + loff 	top = top + toff
    	    	right = right + roff  	bottom = bottom + boff
    	  	t
    	    )
    	    (90
    	    	boff = round(abs(right - left)/5)+3
    	     	left = left - toff 	top = top + roff
    	    	right = right - boff  	bottom = bottom + loff
    	  	t
    	    )
    	    (180
    	    	boff = round(abs(top - bottom)/5)+3
    	     	left = left - roff 	top = top - boff
    	    	right = right - loff  	bottom = bottom - toff
    	  	t
    	    )
    	    (270
    	    	boff = round(abs(right - left)/5)+3
    	     	left = left + boff 	top = top - loff
    	    	right = right + toff  	bottom = bottom - roff
    	  	t
    	    )
    	)
    )
    if(layer == "BOTTOM" then
    	case(round(txt->rotation)
    	    (0
    	    	boff = round(abs(top - bottom)/5)+3
    	     	left = left - roff 	top = top + toff
    	    	right = right - loff  	bottom = bottom + boff
    	  	t
    	    )
    	    (90
    	    	boff = round(abs(right - left)/5)+3
    	     	left = left - toff 	top = top - loff
    	    	right = right - boff  	bottom = bottom - roff
    	  	t
    	    )
    	    (180
    	    	boff = round(abs(top - bottom)/5)+3
    	     	left = left + loff 	top = top - boff
    	    	right = right + roff  	bottom = bottom - toff
    	  	t
    	    )
    	    (270
    	    	boff = round(abs(right - left)/5)+3
    	     	left = left + boff 	top = top + roff
    	    	right = right + toff  	bottom = bottom + loff
    	  	t
    	    )
    	);case
    )
    return(list(left:top right:bottom))
))

(defun text_on_text (text item)
(prog ()
(let (tt1 tt2 left top right bottom lt tp rt bm )

    tt2 = getbox(item)
    lt  = car(nth(0 tt2))
    tp  = cadr(nth(0 tt2))
    rt  = car(nth(1 tt2))
    bm  = cadr(nth(1 tt2))

    tt1    = getbox(text)
    left   = car(nth(0 tt1))
    top    = cadr(nth(0 tt1))
    right  = car(nth(1 tt1))
    bottom = cadr(nth(1 tt1))

    if(lt>=left && lt<=right && tp<=top && tp>=bottom return(t) )
    if(lt>=left && lt<=right && bm<=top && bm>=bottom return(t) )
    if(rt>=left && rt<=right && bm<=top && bm>=bottom return(t) )
    if(rt>=left && rt<=right && tp<=top && tp>=bottom return(t) )

    return(nil)
)))

(defun unselect_object ()
(let (allsel)
    axlSetFindFilter(?enabled '(noall shapes pins vias text) ?onButtons '(noall shapes pins vias text))

   ; axlSetFindFilter(?enabled '(all) ?onButtons '(all))

    allsel = axlGetSelSet(axlAddSelectAll())

    axlClearSelSet()

    axlSetFindFilter(?enabled '(noall symbols) ?onButtons '(noall symbols))

    allsel = axlGetSelSet(axlAddSelectAll())

    axlClearSelSet()

))

(defun turn_on_layer ( layer)
    axlVisibleDesign(nil)

    Going_On=axlGetParam("paramLayerGroup:BOARD GEOMETRY/paramLayer:OUTLINE")

    Going_On->visible=t

    axlSetParam(Going_On)


    Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:VIA CLASS/paramLayer:%s" layer))

    if(layer == "BOTTOM" then
    	Going_On->visible=t

    else
    	Going_On->visible=nil
    )
    axlSetParam(Going_On)


    Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:PIN/paramLayer:%s" layer))

    Going_On->visible=t

    axlSetParam(Going_On)

    Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:PACKAGE GEOMETRY/paramLayer:SILKSCREEN_%s" layer))

    Going_On->visible=t

    axlSetParam(Going_On)
    Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:REF DES/paramLayer:SILKSCREEN_%s" layer))

    Going_On->visible=t

    axlSetParam(Going_On)


    Going_On = axlGetParam(sprintf(dummy "paramLayerGroup:PACKAGE GEOMETRY/paramLayer:PLACE_BOUND_%s" layer))

    Going_On->visible = refdes_component
    axlSetParam(Going_On)


    axlUIWRedraw(nil)
    axlClearSelSet()

)

(defun init_loc_text ()
    location = makeTable("loc" 0)
    num = 0
)

(defun add_loc_text (item)
    if(item != nil then		;i = 0 i++ item = nthelem(i alltexts)
    	++num
    	x = nthelem(1 item->xy)
    	y = nthelem(2 item->xy)
    	location[num] = sprintf(dummy "%s,%f,%f" item->text x y)
    )
)

(defun location_text ( location)
    viewx = 400
    viewy = 300

    if(tablep(location) == t && length(location) > 0 then
    	if(num < length(location) then
    	    ++num
    	else
    	    num = 1
    	)
        lst = parseString(location[num] ",")
    	refdes = sprintf(dummy " %d/%d : %s" num length(location) nthelem(1 lst))
    	x = atoi(nthelem(2 lst))
    	y = atoi(nthelem(3 lst))
    	;Display the refdes on the interface.
    	axlFormSetField(form "next_view" refdes)
	axlWindowBoxSet(list(x-viewx:y-viewy x+viewx:y+viewy))
    )
)
(defun location_prv ( location)
    viewx = 400
    viewy = 300

    if(tablep(location) == t && length(location) > 0 then
    	if(num > 1 then
    	   --num
    	else
    	   num = length(location)
    	)
        lst = parseString(location[num] ",")
    	refdes = sprintf(dummy " %d/%d : %s" num length(location) nthelem(1 lst))
    	x = atoi(nthelem(2 lst))
    	y = atoi(nthelem(3 lst))
    	;Display the refdes on the interface.
    	axlFormSetField(form "next_view" refdes)
	axlWindowBoxSet(list(x-viewx:y-viewy x+viewx:y+viewy))
    )
)

;			Create layer list
;	  ----------------------------------------------


;File name: 	jkImpedence_List.il
;Revision:	1	
;date:		06/14/2002
;Writen by: 	JIAKE/15924
;tel: 		6540581
;e_mail: 	jiake@huawei.com

;Run this routine to add a layer_list into drill.art layer automatically .
;And the parameters , such as "MATERIAL" "LAYER NAME" "THICKNESS", will 
;be setted acoording to Cross_Section setting . If you have changed the 
;parameters of Cross_Section , you only need run this routine (command :
;layer list ) again , and it isn't necessary to delete the layer_list first . 
;If an old layer_list exist before adding a new one , the new layer_list 
;will be added at the old position . Otherwise , a new layer_list will be 
;placed aoutmaitcally in a suitable area at board right side . If the area 
;isn't right , you can move the layer_list together by selecting symbol .

;==================================================================
;			Main Function
;==================================================================
axlCmdRegister( "layer list" 'layer_list ?cmdType "general" )

defun( layer_list ()
when( axlOKToProceed()
let( ( xy )

	initAddLayerListValue()
	
	axlMsgPut("Delete old layer symbol . ")
	delOldLayer()
	
	axlMsgPut("Extract layer to a file.")
	extractLayerToFile()
	
	axlMsgPut("Get layer information . ")
	layercount = getLayerInformation()

	axlMsgPut("Get the position to place layer_symbol . ")
	if(layerxy != nil 
	then
		xy = getPlaceLayerxy()
		axlMsgPut("xy = %L" xy)
		if(nthelem( 2 xy ) < nthelem( 2 layerxy) then
			xy = layerxy
		)
		axlMsgPut("layerxy = %L" layerxy)
		createSCR( xy )
	else	
		axlMsgPut("No old layer. ")
		xy = getPlaceLayerxy()
		axlMsgPut("Run script . ")
		createSCR( xy )		
	)
	
	axlMsgPut("Run script file..." )
	axlShell("replay layer.scr")
	
	axlMsgPut("Delete layer_list too many . ")
	delMoreLayer( layercount )
	
	axlMsgPut("Modify the text.")
	ChangeTexts()
	shell("rm layer.scr")
	shell("rm layer.txt")
	shell("rm layerfile.txt")
)))

;========================== Initialize value =============================
defun( initAddLayerListValue ()
	layertable = makeTable("layer1" nil)
	layercount = 0
	layerid = nil
	layerxy = nil
	layerSymName = "LAYER"
	layerHeight = 6300
	layerwidth = 2100
)


;=========== Get a coordiration of area to place LAYER_symbol ============
defun( getPlaceLayerxy ()
prog( ( )
let( ( top bottom left right designParam SelBoardOutline selBox i j xy step )
	
	designParam = axlGetParam("paramDesign")
	top = nthelem( 2 nthelem( 2 designParam->bBox ))
	right = nthelem( 1 nthelem( 2 designParam->bBox )) - layerwidth - 100
	bottom = nthelem( 2 designParam->xy ) + layerHeight + 100
	axlVisibleDesign(nil)
	axlVisibleLayer( "BOARD GEOMETRY/OUTLINE" t )
	axlUIWRedraw(nil)	
	
	axlSetFindFilter( ?enabled '("noall" "lines" "shapes") ?onButtons '("noall" "lines" "shapes"))
	axlOpenFindFilter()
	SelBoardOutline = axlGetSelSet(axlAddSelectAll( ))
	left = 0
	btmmin = 1000000000
	foreach( item SelBoardOutline
		if( left < car(nthelem( 2 item->bBox )) then
			left = car(nthelem( 2 item->bBox ))
		)
		if( btmmin > nthelem( 2 nthelem( 1 item->bBox)) then 
			btmmin = nthelem( 2 nthelem( 1 item->bBox)) 
		)
	)
	btmmin = btmmin + 400 + 100*layercount 
	left = left + 1200
	if( bottom < btmmin then  bottom = btmmin )
	
	axlVisibleLayer( "BOARD GEOMETRY/DIMENSION" t )
	axlVisibleLayer( "MANUFACTURING/NCDRILL_LEGEND" t )
	axlVisibleLayer( "MANUFACTURING/NCDRILL_FIGURE" t )
	axlUIWRedraw(nil)
	i = 0
	j = 0 
	axlSetFindFilter( ?enabled '("all") ?onButtons '("all"))
	axlOpenFindFilter()
	step = 200
	while( bottom+j*step < top	
		while( left+i*step < right
			selBox = getLayerBox( (left+i*step):(bottom+j*step) layercount+2 )
			if( axlGetSelSet(axlSingleSelectBox( selBox )) == nil then
				xy = (left+i*step):(bottom+j*step)
				return( xy )
			)
			i++
		)
		j++
	)
	xy
)))

;========================== Create a script file =============================
defun( createSCR ( xy )
let( ( outf )
	outf = outfile("layer.scr")
	fprintf(outf " setwindow pcb \n")
	fprintf(outf " trapsize 5215 \n")
	fprintf(outf " place manual \n")
	fprintf(outf " setwindow form.plc_manual \n")
	fprintf(outf " FORM plc_manual advanced_settings \n")
	fprintf(outf " FORM plc_manual database YES \n")
	fprintf(outf " FORM plc_manual library YES \n")
	fprintf(outf " FORM plc_manual placement_list \n")
	fprintf(outf " FORM plc_manual tree  'Format symbols' \n")
	fprintf(outf " FORM plc_manual tree 'MULTISEL YES' %s 'Format symbols' \n" layerSymName)
	fprintf(outf " FORM plc_manual tree  %s 'Format symbols' \n" layerSymName)
	fprintf(outf " setwindow pcb \n")
	fprintf(outf " pick grid %d %d \n" round(nthelem( 1 xy )) round(nthelem( 2 xy )))
	fprintf(outf " setwindow form.plc_manual \n")
	fprintf(outf " FORM plc_manual done \n")
	close(outf)
))

;======= Get the actual layer box according to given xy ==========
defun( getLayerBox ( xy layercount )
let( ( xys xye selBox )
	
	xys = nil
	xys = cons(( nthelem( 2 xy ) - 100*layercount - 400 ) xys )
	xys = cons( nthelem( 1 xy ) xys )
	
	xye = nil
	xye = cons( nthelem( 2 xy ) xye )
	xye = cons( nthelem( 1 xy ) + layerwidth xye )
	
	selBox = nil 
	selBox = cons( xye selBox )
	selBox = cons( xys selBox )

))

;================ Get the origin layer_symbol box ==============
defun( getLayerBoxAfter ( layercount )
let( ( syms sym xy xys xye xyet selBox )
	
	;Get Tlayer origin coordiration
	syms = axlDBGetDesign()->symbols
	foreach( sym syms
		if( sym->type == "FORMAT" && sym->name == layerSymName then
			layerid = sym
			xys = nthelem( 1 sym->bBox )
			xyet = nthelem( 2 sym->bBox )
		)
	)
	
	;Count the delete position
	xye = nil
	xye = cons(( nthelem( 2 xyet ) - 100*layercount - 450 ) xye )
	xye = cons( nthelem( 1 xyet ) xye )
	selBox = nil 
	if( xye != nil && xys != nil then
		selBox = cons( xye selBox )
		selBox = cons( xys selBox )
	)
	selBox
))

;========================== Delete old layer_symbol =============================
defun( delOldLayer ()
prog( ()
let( ( sym syms )
	layerxy = nil
	syms = axlDBGetDesign()->symbols
	foreach( sym syms
		if( sym->type == "FORMAT" && sym->name == layerSymName 
		then
			layerxy = sym->xy
			axlDeleteObject( sym )
		)
	)
	layerxy
)))

;========================== Select texts to modify =============================
defun( selTextInBox ()
let( ( selBox selInLayer )
	selBox = getLayerBoxAfter( 0 )

	;Get texts to delete in the area
	axlSetFindFilter( ?enabled '("noall" "text" ) ?onButtons '("noall" "text" ))
	axlOpenFindFilter()
	selInLayer = axlGetSelSet(axlSingleSelectBox( selBox ))
))

;========================== Modify the text selected =========================
defun( delMoreLayer ( layercount )
let( ( selBox selInLayer )
	;Get the box to delete
	selBox = getLayerBoxAfter( layercount )
	;Get texts and lines to delete in the area
	axlSetFindFilter( ?enabled '("noall" "text" "lines") ?onButtons '("noall" "text" "lines"))
	axlOpenFindFilter()
	selInLayer = axlGetSelSet(axlSingleSelectBox( selBox ))
	delitem = nil
	foreach( item selInLayer 
		if( item->layer == "BOARD GEOMETRY/DIMENSION" then
			if(( item->objType == "text" && item->parent->name == layerSymName )
			|| ( item->objType == "path" && axlDBGetProperties(item) == '((CLIP_DRAWING "CLIP_1"))) 
			then
				delitem = cons( item delitem )
			)
		)
	)
	;Delete the texts and lines in the area 
	axlDeleteObject( delitem )
	axlDBRefreshId( nil )
))

;========================== Extractor information from PCB =============================
defun( extractLayerToFile ()
let( ( outf comfname )
	comfname = "layer.txt"
	outf = outfile( comfname )
	fprintf(outf "LAYER\n    LAYER_SORT\n    LAYER_MATERIAL\n")
	fprintf(outf "    LAYER_CONDUCTOR\n    LAYER_THICKNESS\n")
	fprintf(outf "    LAYER_SUBCLASS\n    LAYER_ARTWORK\nEND\n")
	close(outf)
	axlExtractToFile( comfname  "layerfile.txt")
))

;========================== Get PCB cross_section information =============================
defun( getLayerInformation ()
let( ( inf num line )
	inf = infile( "layerfile.txt" )
	num = 0
	while( gets( line inf )
		tline = parseString(line "!")
		if( nthelem( 1 tline ) == "S" && nthelem( 3 tline ) != "AIR" then
			layertable[++num] = tline
		)
	)
	layercount = num
))

;========================== Modify a text =============================
defun( modifyText ( txtid text )
let( ( txt refparent reflayer refblock refway refside refjustify xy myoritent )
	if( txtid->layer == "BOARD GEOMETRY/DIMENSION" 
	&& txtid->parent->name == layerSymName then
		refparent   = txtid->parent
		reflayer    = txtid->layer
		refblock    = txtid->textBlock  
		refway      = txtid->rotation
	  	refside     = txtid->isMirrored 
		refjustify  = txtid->justify
		xy          = txtid->xy
	
		axlDeleteObject( txtid )
			
		myoritent =make_axlTextOrientation( 
        		?textBlock refblock, 
        		?rotation refway, 
			?mirrored refside, 
			?justify refjustify
		)
		
		txt = axlDBCreateText(text,xy,myoritent,reflayer,refparent)
		axlDBRefreshId(txt)
	)
	t
))


;====== According to the text position , change texts in layer_symbol =======
defun( ChangeTexts ( )
let((); row col txy lxy tx ty lx ly text )

	text = nil
	texts = selTextInBox()
	i = 1
	foreach( txtid texts
		i++
		txy = txtid->xy
		lxy = layerid->xy
		tx = nthelem( 1 txy )
		ty = nthelem( 2 txy )
		lx = nthelem( 1 lxy )
		ly = nthelem( 2 lxy )
		row = fix(( ly - ty )/100 - 3 )
		col = fix(( tx - lx )/600 + 1 )
		text = nil
		case( col
		(1
			text = nthelem( 3 layertable[row] )
			t
		);END-1
		(2
			if( mod( row 4 ) == 0
			then
				text = "CORE"
			else
				if( mod( row 2 ) == 0 
				then
					text = "PREPREG"
				else
					if( row == 1 then
						text = "ARTWORK TOP"
					)
					if( row == layercount then
						text = "ARTWORK BOTTOM"
					)
					if( row != 1 && row != layercount then
						if( nthelem( 7 layertable[row]) == "NEGATIVE"
						then
							if(substring(nthelem( 6 layertable[row]) 1 1 ) == "G"
							then
								sprintf( text "GROUND PLANE%02d" row/2+1) 
							else
								sprintf( text "POWER PLANE%02d" row/2+1) 
							)
						else
							sprintf( text "ARTWORK LAYER%02d" row/2+1) 
						)	
					)
				)
			)
			t
		);END-2
		(3
			text = nthelem( 5 layertable[row] )
			t
		);END-3				
		);END-case

		if( text != nil then
			modifyText( txtid text)
		)
	);END-foreach
	t
))

;========================== END =============================











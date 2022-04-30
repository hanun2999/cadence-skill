;**************************************************************

;   Copyright (c),2002-2012, Huawei Tech. Co.,Ltd.

;**************************************************************

;   File Name     : jfh_refdes_location.il
;   Version       : 1.0
;   Author        : Jingfenghua/24245
;   Created       : 2002/10/12
;   Last Modified :
;   Function List :
;   History       :
;                 1.Jingfenghua 2002/10/10 Create file


;**************************************************************


;**************************************************************

;   Prototype     :  jfhGetAllCompsDBid()
;   Description   :  This function will get all components DBID
;                    in the PCB board
;   Input Param   :  nil
;   Output        :  g_l_dbAllComps
;   Return Value  :  g_l_dbAllComps
;   Calls         :  nil
;   Called by     :  jfhMoveRefdes(),the main function
;   History       :
;                 1.Jingfenghua   2002/10/10  Created Function

;**************************************************************


procedure( jfhGetAllCompsDBid()

            axlSetFindFilter( ?enabled (list "noall" "Symbols") ?onButtons (list "noall" "Symbols"))
            g_l_dbAllComps = axlGetSelSet( axlAddSelectAll() )
            axlCloseFindFilter()
         
         );end of procedure( jfhGetAllCompsDBid()




;**************************************************************

;   Prototype     :  jfhChgAllRefdesTxtBlock()
;   Description   :  info about function
;   Inoput Param  :  nil
;   Output        :  nil
;   Return Value  :  nil
;   Calls         :  jfhGetRefdesDBid()
;   Called by     :  jfhMoveRefdes(),the main function
;   History       :
;                 1.Jingfenghua   2002/07/10  Created Function

;**************************************************************


procedure( jfhChgAllRefdesTxtBlock( l_g_l_dbAllComps )

     prog( ( );l_id_comp l_id_refdes l_g_l_dbAllComps 
     foreach(l_id_comp l_g_l_dbAllComps
              ;println("1")
              if(stringp(l_id_comp->refdes);if read something unknown,skip the following steps    
                then
                ;println("2")
                l_id_refdes = jfhGetRefdesDBid(l_id_comp)
                ;println("3")
                ;println(l_id_refdes)
                if(l_id_refdes == nil return(nil))
                
                ;get information no need to modify
                sRefContent   = l_id_refdes->text
                ;println(sRefContent)
                dbParent      = l_id_refdes->parent
                ptRefxy       = l_id_refdes->xy
                sRefLayer     = l_id_refdes->layer
                bMirror       = l_id_refdes->isMirrored
                sJustify      = l_id_refdes->justify
                nRefRotation  = round(l_id_refdes->rotation)
                
                sTxtBlock     = "3";change all refdes block to 3

                ;fill the text structure r_textOrientation
                stTxtPara = make_axlTextOrientation(
                             ?textBlock sTxtBlock
                             ?rotation nRefRotation
                             ?mirrored bMirror
                             ?justify sJustify
                            );end fill structure 
                            
               isCreation = axlDBCreateText(
                            sRefContent
                            ptRefxy
                            stTxtPara
                            sRefLayer
                            dbParent
                            )
                 
               if( isCreation != nil axlDeleteObject( l_id_refdes))

                );end of if(stringp(sym->refdes)

            );end of foreach(sym ll_dbTopComps
            
         );prog
         );end of procedure( jfhInitialize()



;**************************************************************

;   Prototype     :  jfhGetRefdesDBid()
;   Description   :  This function get all component's refdes's DBID
;   Input Param   :  one of the elements in list g_l_dbAllComps
;   Output        :  nil
;   Return Value  :  l_id_refdes
;   Calls         :  nil
;   Called by     :  jfhChgAllRefdesTxtBlock()
;   History       :
;                 1.Jingfenghua   2002/07/10  Created Function

;**************************************************************


procedure( jfhGetRefdesDBid(l_id_comp)

           prog( ();l_id_comp l_id_refdes l_l_dbAttachedTxt 
           
           l_l_dbAttachedTxt = axlDBGetAttachedText(l_id_comp)
           
           foreach(l_id_refdes l_l_dbAttachedTxt
                   
                       if(l_id_refdes->layer == "REF DES/SILKSCREEN_TOP" || l_id_refdes->layer == "REF DES/SILKSCREEN_BOTTOM" 
                         
                          then 
                             return(l_id_refdes)
                         
                         );end of if(l_id_refdes->layer == "REF DES/SILKSCREEN_TOP"
                  
                  );end of foreach(l_id_refdes l_l_dbAttachedTxt

               );end of prog( (l_id_refdes)
         );end of procedure( jfhGetRefdesDBid(l_id_comp)


;**************************************************************

;   Prototype     :  jfhGetCompShadow()
;   Description   :  This function get the components shadow area
;   Inoput Param  :  l_id_comp
;   Output        :  l_pt_area
;   Return Value  :  l_pt_area
;   Calls         :  nil
;   Called by     :  nil
;   History       :
;                 1.Jingfenghua   2002/10/12  Created Function

;**************************************************************

procedure( jfhGetCompShadow( l_id_comp )
         
         prog( ( l_l_CompShadow );l_id_comp
         
               l_l_id_children = l_id_comp->children
               ;children of a component,include refdes,device_name,line_segments,etc
               
               l_l_id_LineSegments = nil
               
               ;the following foreach get place bound shadow and return a list filled with
               ;ids of line segments
               foreach( l_id_child l_l_id_children
                      if( l_id_child->objType == "shape" || l_id_child->objType == "path"
                          then
                             if( l_id_child->layer != "PACKAGE GEOMETRY/ASSEMBLY_TOP" && l_id_child->layer != "PACKAGE GEOMETRY/ASSEMBLY_BOTTOM"
                                 then
                                    l_l_id_LineSegments = cons( l_id_child l_l_id_LineSegments )
                               );end of 
                        );end of if( l_id_child->objType == "shape" || "path"
                      );end of foreach( l_id_child l_l_id_children
                
                l_id_FstSeg = nthelem(1 l_l_id_LineSegments)
                l_l_FstSeg_Shadow = l_id_FstSeg->bBox
                
                ;lowleft
                l_f_FarWest  = xCoord(nthelem(1 l_l_FstSeg_Shadow))
                l_f_FarSouth = yCoord(nthelem(1 l_l_FstSeg_Shadow))
                ;upright
                l_f_FarEast  = xCoord(nthelem(2 l_l_FstSeg_Shadow))
                l_f_FarNorth = yCoord(nthelem(2 l_l_FstSeg_Shadow))
                
                ;the following foreach get silkscreen outline shadow
                foreach( l_id_LineSeg l_l_id_LineSegments
                
                        l_l_Seg_Shadow = l_id_LineSeg->bBox
                        
                        l_f_West  = xCoord(nthelem(1 l_l_Seg_Shadow))
                        l_f_South = yCoord(nthelem(1 l_l_Seg_Shadow))
                        l_f_East  = xCoord(nthelem(2 l_l_Seg_Shadow))
                        l_f_North = yCoord(nthelem(2 l_l_Seg_Shadow))
                        
                        if( l_f_West < l_f_FarWest
                              l_f_FarWest = l_f_West
                          )
                        if( l_f_South < l_f_FarSouth
                              l_f_FarSouth = l_f_South
                          )
                        if( l_f_East > l_f_FarEast
                              l_f_FarEast = l_f_East
                          )
                        if( l_f_North > l_f_FarNorth
                              l_f_FarNorth = l_f_North
                          )    
                       );end of foreach( l_id_LineSeg l_l_id_LineSegments
                       
                       l_l_CompShadow = list( l_f_FarWest:l_f_FarSouth l_f_FarEast:l_f_FarNorth)
                       
                       return( l_l_CompShadow )

             );end of prog

         );end of procedure( jfhGetCompShadow()
         

;**************************************************************

;   Prototype     :  jfhSplitComps()
;   Description   :  This function generate two lists which have the content
;                    of top side components' and btm side components' DBID
;   Input Param   :  l_l_dbAllComps
;   Output        :  g_l_dbTopComps,g_l_dbBtmComps
;   Return Value  :  g_l_dbTopComps,g_l_dbBtmComps
;   Calls         :  nil
;   Called by     :  jfhRefdesLocate(),the main function
;   History       :
;                 1.Jingfenghua   2002/10/14  Created Function

;**************************************************************

procedure( jfhSplitComps(l_l_dbAllComps)
         
           foreach(sym l_l_dbAllComps
                   
                   if(stringp(sym->refdes);if read something unknown,skip to the following steps    
                   
                       then  
                   
                         if(sym->isMirrored != t ;on top side
                  
                             then
                                g_l_dbTopComps = cons(sym g_l_dbTopComps)
                             
                             else
                                g_l_dbBtmComps = cons(sym g_l_dbBtmComps)
                     
                           );end of if(sym->isMirrored != t 
                     
                     );end of if(stringp(sym->refdes)
                  
                  );end of foreach(sym g_l_dbAllComps)      
         
         );end of procedure( jfhSplitComps(l_l_dbAllComps)         
         

;**************************************************************

;   Prototype     :  jfhDBCreateRefdes()
;   Description   :  This function will add a new refdes DBID.If success,delete 
;                    the origin refdes DBID
;   Input  Param  :  dbRefdesOrg(original DBID of a refdes),ptRefdesPosition(new position of the refdes)
;   Output        :  new DBID of a refdes
;   Return Value  :  nil
;   Calls         :  nil
;   Called by     :  jfhPlaceTopRefdes();jfhPlaceBtmRefdes()
;   History       :
;                 1.Jingfenghua   2002/07/10  Created Function

;**************************************************************


procedure( jfhDBCreateRefdes(dbRefdesOrg ptRefdesPosition)
prog( ()
            if(dbRefdesOrg == nil return(nil))
           
           
           ;get information no need to modify
           sRefContent = dbRefdesOrg->text
           dbParent = dbRefdesOrg->parent
           ;ptRefxy = dbRefdesOrg->xy
           sRefLayer = dbRefdesOrg->layer
           bMirror = dbRefdesOrg->isMirrored
           sJustify = dbRefdesOrg->justify
           sTxtBlock = dbRefdesOrg->textBlock
           ;axlMsgPut("6")
           ;println(dbRefdesOrg)
           ;println(dbRefdesOrg->xy)
           nRefRotation = round(dbRefdesOrg->rotation)
           
           
           ;fill the text structure r_textOrientation
           stTxtPara = make_axlTextOrientation(
                             ?textBlock sTxtBlock
                             ?rotation nRefRotation
                             ?mirrored bMirror
                             ?justify sJustify
                            );end fill structure 
                            
           isCreation = axlDBCreateText(
                            sRefContent
                            ptRefdesPosition
                            stTxtPara
                            sRefLayer
                            dbParent
                            )
                 
           if( isCreation != nil axlDeleteObject( dbRefdesOrg))                            

         );end of prog
         );end of procedure( jfhDBCreateRefdes(dbRefdesOrg ptRefdesPosition)      
         
         
;**************************************************************

;   Prototype     :  jfhPlaceTopRefdes()
;   Description   :  This function will move all TOP side components'
;                    refdes to a right place
;   Inoput Param  :  l_l_dbTopComps
;   Output        :  nil
;   Return Value  :  t
;   Calls         :  jfhDBCreateRefdes();jfhGetRefdesDBid()
;   Called by     :  jfhMoveRefdes(),the main function
;   History       :
;                 1.Jingfenghua   2002/07/10  Created Function

;**************************************************************


procedure( jfhPlaceTopRefdes(l_l_dbTopComps)

           foreach(sym l_l_dbTopComps
                    
                    
                    ;axlMsgPut("1")
                    l_SymRotation = round(sym->rotation)
                    
                    if( l_SymRotation > 85 && l_SymRotation < 95 || l_SymRotation > 265 && l_SymRotation < 275
                        
                        then;a component is 90 degree 
                           
                           bBoxComp = jfhGetCompShadow(sym)
                           ptLowLeft = nthelem(1 bBoxComp)
                           ptUpRight = nthelem(2 bBoxComp)
                           
                           ;create components shadow shape 
                           axlDBCreateRectangle(bBoxComp t "PACKAGE GEOMETRY/COMPS SHADOW TOP" nil sym)                          
                           
                           ;axlMsgPut("2")
                           ptReference = round(xCoord(ptUpRight)+1):round(yCoord(ptLowLeft)+1)
                           
                           ;axlMsgPut("3")
                           dbRefdes = jfhGetRefdesDBid(sym)
                                                      
                           bBoxRefdes = dbRefdes->bBox
                          
                          ;axlMsgPut("4")                            
                           ptOffset = 0:round(yCoord(nthelem(2 bBoxRefdes)) - yCoord(nthelem(1 bBoxRefdes)) + 1)
                           
                           ptRefdesPositionNew = (xCoord(ptReference) - xCoord(ptOffset)):(yCoord(ptReference) - yCoord(ptOffset))
                           
                           jfhDBCreateRefdes(dbRefdes ptReference)
                        
                        else;a component is 0 degree
                        
                           bBoxComp = jfhGetCompShadow(sym)
                           ptLowLeft = nthelem(1 bBoxComp)
                           ptUpRight = nthelem(2 bBoxComp)
                           
                           ;create components shadow shape 
                           axlDBCreateRectangle(bBoxComp t "PACKAGE GEOMETRY/COMPS SHADOW TOP" nil sym)                          
                           
                           ptReference = ptLowLeft
                           
                           dbRefdes = jfhGetRefdesDBid(sym)
                           
                           bBoxRefdes = dbRefdes->bBox
                           
                          ; axlMsgPut("5")
                           ptOffset = round(xCoord(nthelem(2 bBoxRefdes)) - xCoord(nthelem(1 bBoxRefdes)) + 1):0
                           
                           ptRefdesPositionNew = (xCoord(ptReference) - xCoord(ptOffset)):(yCoord(ptReference) - yCoord(ptOffset))
                           
                           jfhDBCreateRefdes(dbRefdes ptReference)
                        
                      );end of if( l_SymRotation > 85 && l_SymRotation < 95 ||....  
           
                  );end of foreach(sym ll_dbTopComps
           
           
           
         );end of procedure( jfhPlaceTopRefdes(ll_dbComps)            


;**************************************************************

;   Prototype     :  jfhPlaceBtmRefdes()
;   Description   :  This function will move all TOP side components'
;                    refdes to a right place
;   Inoput Param  :  l_l_dbTopComps
;   Output        :  nil
;   Return Value  :  t
;   Calls         :  jfhDBCreateRefdes();jfhGetRefdesDBid()
;   Called by     :  jfhMoveRefdes(),the main function
;   History       :
;                 1.Jingfenghua   2002/07/10  Created Function

;**************************************************************


procedure( jfhPlaceBtmRefdes(l_l_dbBtmComps)

           foreach(sym l_l_dbBtmComps
                    
                    
                    ;axlMsgPut("1")
                    l_SymRotation = round(sym->rotation)
                    
                    if( l_SymRotation > 85 && l_SymRotation < 95 || l_SymRotation > 265 && l_SymRotation < 275
                        
                        then;a component is 90 degree 
                           
                           bBoxComp = jfhGetCompShadow(sym)
                           ptLowLeft = nthelem(1 bBoxComp)
                           ptUpRight = nthelem(2 bBoxComp)
                           
                            ;create components shadow shape 
                           axlDBCreateRectangle(bBoxComp t "PACKAGE GEOMETRY/COMPS SHADOW BTM" nil sym)
                           
                           ;axlMsgPut("2")
                           ;ptReference = round(xCoord(ptLowLeft)+1):round(yCoord(ptLowLeft)+1)
                           ptReference = ptLowLeft
                           
                           ;axlMsgPut("3")
                           dbRefdes = jfhGetRefdesDBid(sym)
                           
                           bBoxRefdes = dbRefdes->bBox
                          
                          ;axlMsgPut("4")                            
                           ptOffset = 0:round(yCoord(nthelem(2 bBoxRefdes)) - yCoord(nthelem(1 bBoxRefdes)) + 1)
                           
                           ptRefdesPositionNew = (xCoord(ptReference) - xCoord(ptOffset)):(yCoord(ptReference) - yCoord(ptOffset))
                           
                           jfhDBCreateRefdes(dbRefdes ptReference)
                        
                        else;a component is 0 degree
                        
                           bBoxComp = jfhGetCompShadow(sym)
                           ptLowLeft = nthelem(1 bBoxComp)
                           ptUpRight = nthelem(2 bBoxComp)
                           
                           ;create components shadow shape 
                           axlDBCreateRectangle(bBoxComp t "PACKAGE GEOMETRY/COMPS SHADOW BTM" nil sym)
                           
                           ptReference = ptLowLeft
                           
                           dbRefdes = jfhGetRefdesDBid(sym)
                           
                           bBoxRefdes = dbRefdes->bBox
                           
                          ; axlMsgPut("5")
                           ;ptOffset = 2:0
                           ptOffset = round(xCoord(nthelem(2 bBoxRefdes)) - xCoord(nthelem(1 bBoxRefdes)) + 1):0
                           
                           ptRefdesPositionNew = (xCoord(ptReference) + xCoord(ptOffset)):yCoord(ptReference)
                           
                           jfhDBCreateRefdes(dbRefdes ptRefdesPositionNew)
                        
                      );end of if( l_SymRotation > 85 && l_SymRotation < 95 ||....  
           
                  );end of foreach(sym ll_dbBtmComps
           
           
           
         );end of procedure( jfhPlaceBtmRefdes(ll_dbComps)    
         
         
         
;**************************************************************

;   Prototype     :  jfhCreateMacroFile()
;   Description   :  This function create the mcaro file to change text block
;   Inoput Param  :  nil
;   Output        :  nil
;   Return Value  :  nil
;   Calls         :  nil
;   Called by     :  the main function
;   History       :
;                 1.Jingfenghua   2002/07/10  Created Function

;**************************************************************

procedure( jfhCreateMacroFile()
             l_f_macro = outfile("txtsize3.scr" "w")

             fprintf(l_f_macro "# Allegro script\n")
             fprintf(l_f_macro "#	file: txtsize3.scr\n")
             fprintf(l_f_macro "#	start time: Thu Oct 10 17:15:06 2002\n")
             fprintf(l_f_macro "version 14.1\n")
             fprintf(l_f_macro "\n")
             fprintf(l_f_macro "setwindow pcb\n")
             fprintf(l_f_macro "trapsize 11349\n")
             fprintf(l_f_macro "# Macro file: coordinates are relative to pick on replay.\n")
             fprintf(l_f_macro "define text\n")
             fprintf(l_f_macro "setwindow form.textblock\n")
             fprintf(l_f_macro "FORM textblock 3 width 30.00 \n")
             fprintf(l_f_macro "FORM textblock 3 height 30.00 \n")
             fprintf(l_f_macro "FORM textblock 3 line_spacing 0.00 \n")
             fprintf(l_f_macro "FORM textblock 3 photoplot_width 6.00 \n")
             fprintf(l_f_macro "FORM textblock 3 character_spacing 0.00 \n")
             fprintf(l_f_macro "FORM textblock done  \n")
             fprintf(l_f_macro "\n")
             fprintf(l_f_macro "#	stop time: Thu Oct 10 17:15:26 2002\n")
             
             close(l_f_macro)

         );end of procedure( jfhCreateMacroFile()
              


;;; globle value , you can modify them, or move them into function.
	
	;visibleLayer = nil

;;;===========================================================================
;;; function name : jfhRefdesOverlapItem
;;; input  : symbolid, ID of symbol
;;;	     priority, 0 --> 4 means that priority is from low to high.
;;;	     extend, extending size along side of symbol 
;;;
;;; return : nil , can't place refdes along side
;;;	     list , return list 
;;;		"(nil 'top top 'bottom bottom 'left left 'right right )"
;;;	     you can get the information as following, for example:
;;; 		symlst->top    => t
;;;		symlst->bottom => nil
;;;		symlst->left   => t 
;;;		symlst->right  => t
;;;	     
;;; function :
;;;	as to input ID, get the overlapped item(s) 
;;;===========================================================================

(defun jfhRefdesOverlapItem ( symbolid priority extend)
(let ( text refdes find width high box item 
	x1 x2 y1 y2 current left top right bottom ret
	sBox tBox bBox lBox rBox )
    if(symbolid->refdes != nil
    then
    	/*if( visibleLayer == nil then
	axlVisibleDesign(nil)
	axlVisibleLayer( "REF DES/SILKSCREEN_TOP" t )
	axlVisibleLayer( "PIN/TOP" t )
	axlVisibleLayer( "VIA CLASS/TOP" t )
	axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_TOP" t )
	axlVisibleLayer( "BORAD GEOMETRY/SILKSREEN_TOP" t )
	axlVisibleLayer( "REF DES/SILKSCREEN_BOTTOM" t )
	axlVisibleLayer( "PIN/BOTTOM" t )
	axlVisibleLayer( "VIA CLASS/BOTTOM" t )
	axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" t )
	axlVisibleLayer( "BORAD GEOMETRY/SILKSREEN_BOTTOM" t )
	axlVisibleLayer( "BOARD GEOMETRY/OUTLINE" t )
	axlVisibleLayer( tshapelayer t )
	axlVisibleLayer( bshapelayer t )	
	axlUIWRedraw(nil)	
	
	visibleLayer = t
	)*/
	;;;get refdes id
	text= axlDBGetAttachedText(symbolid)
	refdes = nil
	foreach(find text
		if(find->layer == "REF DES/SILKSCREEN_TOP" || 
		find->layer == "REF DES/SILKSCREEN_BOTTOM" then 									
			refdes = find			
		)								
	)	
	;;;get width and high of refdes
/*	width = 0
	high  = 0 
	if(refdes != nil then
	    	text = axlGetParam(strcat("paramTextBlock:" refdes->textBlock))
    		width = strlen(refdes->text) * (text->charSpace + text->width) - text->charSpace
	    	high = text->height
	)
*/	
	box = getTextBox_hw(refdes)
	width = abs(caadr(box) - caar(box))
	high = abs(cadadr(box) - cadar(box))
	
	;;;get shape of symbol 
	sBox = jfhGetCompShadow(symbolid)
	if(extend < 4 then extend = 4)
	x1 = caar(sBox) - extend
	y1 = cadar(sBox) - extend
	x2 = caadr(sBox) + extend
	y2 = cadadr(sBox) + extend
	
	;;;judge current area of refdes 
	if(jfhBoxOverlapItem( box refdes->layer priority ) == nil
	then 
		current = t
	else
		current = nil
	)
	
	;;;judge the left side area
	lBox = list( x1-width:(y1+y2-high)/2 x1:(y1+y2+high)/2 )	
	if(jfhBoxOverlapItem( lBox refdes->layer priority ) == nil
	then 
		left = t
	else
		left = nil
	)
	
	;;;judge the top side area
	tBox = list( (x1+x2-width)/2:y2 (x1+x2+width)/2:(y2+high) )
	if(jfhBoxOverlapItem( tBox refdes->layer priority ) == nil
	then 
		top = t
	else
		top = nil
	)
	
	;;;judge the right side area
	rBox = list( x2:(y1+y2-high)/2 (x2+width):(y1+y2+high)/2 )	
	if(jfhBoxOverlapItem( rBox refdes->layer priority ) == nil
	then 
		right = t
	else
		right = nil
	)
	
	;;;judge the bottom side area
	bBox = list( (x1+x2-width)/2:(y1-high) (x1+x2+width)/2:y1 )	
	if(jfhBoxOverlapItem( bBox refdes->layer priority ) == nil
	then 
		bottom = t
	else
		bottom = nil
	)
	
	ret = list(nil 'current current 'cbox sBox 'top top 'tbox tBox 'bottom bottom 'bbox bBox 'left left 'lbox lBox 'right right 'rbox rBox)
    else
    	ret = nil
    )
    ret 
))

;;;=============================================================================
;;; input : txt , ID of text
;;; return : bBox , truthful box of text 
;;;=============================================================================
procedure( getTextBox_hw( txt )
let( (text top right left bottom xy long high clearance)

    text = axlGetParam(strcat("paramTextBlock:" txt->textBlock))
    
    clearance = 3
    
    xy = txt->xy
    long = strlen(txt->text) * (text->charSpace + text->width) - text->charSpace
    high = text->height
    

    if(last( parseString(txt->layer "_")) == '("TOP") then
    	case(round(txt->rotation/90)
    	    (0
    	     	left = car(xy) 		top = cadr(xy)+high 	
    	    	right = car(xy)+long  	bottom = cadr(xy)
    	  	t 
    	    )
    	    (1
    	     	left = car(xy)-high 	top = cadr(xy)+long 	
    	    	right = car(xy)  	bottom = cadr(xy)
    	  	t 
    	    )
    	    (2
    	     	left = car(xy)-long 	top = cadr(xy) 	
    	    	right = car(xy)  	bottom = cadr(xy)-high
    	  	t 
    	    )
    	    (3
    	     	left = car(xy) 		top = cadr(xy) 	
    	    	right = car(xy)+high  	bottom = cadr(xy)-long
    	  	t 
    	    )
    	)
    )	    
    if(last( parseString(txt->layer "_")) == '("BOTTOM") then
    	case(round(txt->rotation/90)
    	    (0
    	     	left = car(xy)-long 	top = cadr(xy)+high 	
    	    	right = car(xy)  	bottom = cadr(xy)
     	  	t 
    	    )
    	    (1
    	     	left = car(xy)-high 	top = cadr(xy) 	
    	    	right = car(xy)  	bottom = cadr(xy)+long
    	  	t 
    	    )
    	    (2
    	     	left = car(xy) 		top = cadr(xy) 	
    	    	right = car(xy)+long  	bottom = cadr(xy)-high
    	  	t 
    	    )
    	    (3
    	     	left = car(xy) 		top = cadr(xy)+long 	
    	    	right = car(xy)+high  	bottom = cadr(xy)
    	  	t 
    	    )	    	    
    	);case	    
    )
    list(left:bottom right:top)		   
))
  
;;;=================================================================================
;;; intput : txtBox, truthful box of text
;;;	     reflayer, layer which refdes is on. It's "REF DES/SILKSCREEN_TOP" or 
;;;                    "REF DES/SILKSCREEN_TOP".
;;; 	     priority  shape    pin  testpoint  text    via
;;;	    	0   	Y		
;;;    		1	Y	Y		
;;;    		2	Y 	Y	Y		
;;;    		3	Y 	Y	Y	Y
;;;    		4	Y	Y	Y	Y	Y	
;;;   		...		... 		...
;;; return : t , if refdes overlaps item(s)
;;;	     nil , if refdes overlaps nothing.
;;;=================================================================================
defun( jfhBoxOverlapItem ( txtBox reflayer priority )
(let ( ret items symcount textcount viacount tpcount pincount selitem item )
	
	symcount = 0
	textcount = 0
	viacount = 0 
	tpcount = 0
	pincount = 0
	
	if(txtBox != nil then
		;;;filter shapes , refdes & vias
		axlSetFindFilter(?enabled '(noall shapes text vias pins) 
		?onButtons '(noall shapes text vias pins))

		;;;select item by truthful refdes' box and save to items
		axlOpenFindFilter()
		axlSingleSelectBox(txtBox)
;;;test code
;		axlSingleSelectPoint()
;		item= car(axlGetSelSet())

		selitem = axlGetSelSet()
		axlClearSelSet()
		
		selitem = remd(refdes selitem)
	
		foreach(item selitem ; i=0 i++ item = nthelem(i selitem)
			;;;if item is symbol, then add 1 to symcount
			if(priority >= 0 && item->objType == "shape"
				if((item->layer == tshapelayer && refdes->isMirrored == nil)||
				 (item->layer == bshapelayer && refdes->isMirrored == t)
					symcount++
				)
			)
			if(priority >= 1 && item->objType == "pin" 
				if(item->isThrough == t
				then
					pincount++
				else					
					if(item->isMirrored == refdes->isMirrored 
						pincount++
				 	)
				)
			)	
			;;;if item is via , then add 1 to viacount
			if(priority >= 2 && item->objType == "via" && item->testPoint == "ETCH/BOTTOM"
			&& reflayer == "REF DES/SILKSCREEN_BOTTOM" 
				tpcount++
			)		
			if(priority >= 2 && (item->layer == reflayer) 
				tpcount++
			)
			;;;if item is refdes or text, then add 1 to textcount
			if(priority >= 3 && refdes->isMirrored == item->isMirrored && item->objType == "text" 
				textcount++
			)
			;;;if item is testpoint , then add 1 to tpcount
			if(priority >= 4 && item->objType == "via" && (item->testPoint == nil || 
			(item->testPoint == "ETCH/BOTTOM" && reflayer == "REF DES/SILKSCREEN_TOP"))
				viacount++
			)	
		)
	)

	;return symbol list
	if( symcount + pincount + textcount + viacount + tpcount == 0 
	then	
		ret = nil
	else
		;ret = list(nil 'symbol symcount 'text textcount 'via viacount 'testpoint tpcount)
		ret = t
	)
	ret 
))


;**************************************************************

;   Prototype     :  jfhPlaceTopRefdesAgain()
;   Description   :  This function will move all TOP side components'
;                    refdes to a right place
;   Inoput Param  :  l_l_dbTopComps
;   Output        :  nil
;   Return Value  :  t
;   Calls         :  jfhDBCreateRefdes();jfhGetRefdesDBid()
;   Called by     :  the main function
;   History       :
;                 1.Jingfenghua   2002/12/04  Created Function

;**************************************************************


procedure( jfhPlaceTopRefdesAgain(l_l_dbTopComps)

           foreach(sym l_l_dbTopComps
                    
                    
                    ;axlMsgPut("1")
                    l_SymRotation = round(sym->rotation)
                    
                    if( l_SymRotation > 85 && l_SymRotation < 95 || l_SymRotation > 265 && l_SymRotation < 275
                        
                        then;a component is 90 degree 
                           
                           ;axlMsgPut("3")
                           dbRefdes = jfhGetRefdesDBid(sym)
                           
                           l_l_overflags = jfhRefdesOverlapItem( sym g_n_priority g_n_ExtentValue)
                           
                       if( l_l_overflags->current == t
                         then
                         temp = 1;do nothing here
                         else  
                           if( l_l_overflags->top == t
                              then
                                 ptRefdesPositionNew = xCoord(nthelem(2 l_l_overflags->tbox)):yCoord(nthelem(1 l_l_overflags->tbox))
                                 jfhDBCreateRefdes(dbRefdes ptRefdesPositionNew)
                              else
                                 if( l_l_overflags->bottom == t
                                   then
                                      ptRefdesPositionNew = xCoord(nthelem(2 l_l_overflags->bbox)):yCoord(nthelem(1 l_l_overflags->bbox))
                                      jfhDBCreateRefdes(dbRefdes ptRefdesPositionNew)
                                   else
                                      if( l_l_overflags->left == t
                                         then
                                            ptRefdesPositionNew = xCoord(nthelem(2 l_l_overflags->lbox)):yCoord(nthelem(1 l_l_overflags->lbox))
                                            jfhDBCreateRefdes(dbRefdes ptRefdesPositionNew)
                                         else
                                            if( l_l_overflags->right == t
                                               then
                                                  ptRefdesPositionNew = xCoord(nthelem(2 l_l_overflags->rbox)):yCoord(nthelem(1 l_l_overflags->rbox))
                                                  jfhDBCreateRefdes(dbRefdes ptRefdesPositionNew)
                                              );end if( l_l_overflags->right == t
                                        );end if( l_l_overflags->left == t
                                   );end if( l_l_overflags->bottom == t
                             );end if( l_l_overflags->top == t
                        );end of if( l_l_overflags->current == t

                        else;a component is 0 degree
                           dbRefdes = jfhGetRefdesDBid(sym)
                           
                           l_l_overflags = jfhRefdesOverlapItem( sym g_n_priority g_n_ExtentValue)
                        if( l_l_overflags->current == t
                         then
                         temp = 1;do nothing here
                         else    
                           if( l_l_overflags->left == t
                              then
                                 ptRefdesPositionNew = xCoord(nthelem(1 l_l_overflags->lbox)):yCoord(nthelem(1 l_l_overflags->lbox))
                                 jfhDBCreateRefdes(dbRefdes ptRefdesPositionNew)
                              else
                                 if( l_l_overflags->right == t
                                   then
                                      ptRefdesPositionNew = xCoord(nthelem(1 l_l_overflags->rbox)):yCoord(nthelem(1 l_l_overflags->rbox))
                                      jfhDBCreateRefdes(dbRefdes ptRefdesPositionNew)
                                   else
                                      if( l_l_overflags->top == t
                                         then
                                            ptRefdesPositionNew = xCoord(nthelem(1 l_l_overflags->tbox)):yCoord(nthelem(1 l_l_overflags->tbox))
                                            jfhDBCreateRefdes(dbRefdes ptRefdesPositionNew)
                                         else
                                            if( l_l_overflags->bottom == t
                                               then
                                                  ptRefdesPositionNew = xCoord(nthelem(1 l_l_overflags->bbox)):yCoord(nthelem(1 l_l_overflags->bbox))
                                                  jfhDBCreateRefdes(dbRefdes ptRefdesPositionNew)
                                              );end if( l_l_overflags->bottom == t
                                        );end if( l_l_overflags->top == t
                                   );end if( l_l_overflags->right == t
                             );end if( l_l_overflags->left == t
                        );end of if( l_l_overflags->current == t
                          
                        
                      );end of if( l_SymRotation > 85 && l_SymRotation < 95 ||....  
           
                  );end of foreach(sym ll_dbTopComps
           
           
           
         );end of procedure( jfhPlaceTopRefdesAgain(l_l_dbTopComps)
         


;**************************************************************

;   Prototype     :  jfhPlaceBtmRefdesAgain()
;   Description   :  This function will move all TOP side components'
;                    refdes to a right place
;   Inoput Param  :  l_l_dbTopComps
;   Output        :  nil
;   Return Value  :  t
;   Calls         :  jfhDBCreateRefdes();jfhGetRefdesDBid()
;   Called by     :  the main function
;   History       :
;                 1.Jingfenghua   2002/12/04  Created Function

;**************************************************************


procedure( jfhPlaceBtmRefdesAgain(l_l_dbBtmComps)

           foreach(sym l_l_dbBtmComps
                    
                    
                    ;axlMsgPut("1")
                    l_SymRotation = round(sym->rotation)
                    
                    if( l_SymRotation > 85 && l_SymRotation < 95 || l_SymRotation > 265 && l_SymRotation < 275
                        
                        then;a component is 90 degree 
                           
                           ;axlMsgPut("3")
                           dbRefdes = jfhGetRefdesDBid(sym)
                           
                           l_l_overflags = jfhRefdesOverlapItem( sym g_n_priority g_n_ExtentValue)
                           
                       if( l_l_overflags->current == t
                         then
                         temp = 1;do nothing here
                         else  
                           if( l_l_overflags->top == t
                              then
                                 ptRefdesPositionNew = xCoord(nthelem(1 l_l_overflags->tbox)):yCoord(nthelem(1 l_l_overflags->tbox))
                                 jfhDBCreateRefdes(dbRefdes ptRefdesPositionNew)
                              else
                                 if( l_l_overflags->bottom == t
                                   then
                                      ptRefdesPositionNew = xCoord(nthelem(1 l_l_overflags->bbox)):yCoord(nthelem(1 l_l_overflags->bbox))
                                      jfhDBCreateRefdes(dbRefdes ptRefdesPositionNew)
                                   else
                                      if( l_l_overflags->left == t
                                         then
                                            ptRefdesPositionNew = xCoord(nthelem(1 l_l_overflags->lbox)):yCoord(nthelem(1 l_l_overflags->lbox))
                                            jfhDBCreateRefdes(dbRefdes ptRefdesPositionNew)
                                         else
                                            if( l_l_overflags->right == t
                                               then
                                                  ptRefdesPositionNew = xCoord(nthelem(1 l_l_overflags->rbox)):yCoord(nthelem(1 l_l_overflags->rbox))
                                                  jfhDBCreateRefdes(dbRefdes ptRefdesPositionNew)
                                              );end if( l_l_overflags->right == t
                                        );end if( l_l_overflags->left == t
                                   );end if( l_l_overflags->bottom == t
                             );end if( l_l_overflags->top == t
                        );end of if( l_l_overflags->current == t

                        else;a component is 0 degree
                           dbRefdes = jfhGetRefdesDBid(sym)
                           
                           l_l_overflags = jfhRefdesOverlapItem( sym g_n_priority g_n_ExtentValue)
                        if( l_l_overflags->current == t
                         then
                         temp = 1;do nothing here
                         else    
                           if( l_l_overflags->left == t
                              then
                                 ptRefdesPositionNew = xCoord(nthelem(2 l_l_overflags->lbox)):yCoord(nthelem(1 l_l_overflags->lbox))
                                 jfhDBCreateRefdes(dbRefdes ptRefdesPositionNew)
                              else
                                 if( l_l_overflags->right == t
                                   then
                                      ptRefdesPositionNew = xCoord(nthelem(2 l_l_overflags->rbox)):yCoord(nthelem(1 l_l_overflags->rbox))
                                      jfhDBCreateRefdes(dbRefdes ptRefdesPositionNew)
                                   else
                                      if( l_l_overflags->top == t
                                         then
                                            ptRefdesPositionNew = xCoord(nthelem(2 l_l_overflags->tbox)):yCoord(nthelem(1 l_l_overflags->tbox))
                                            jfhDBCreateRefdes(dbRefdes ptRefdesPositionNew)
                                         else
                                            if( l_l_overflags->bottom == t
                                               then
                                                  ptRefdesPositionNew = xCoord(nthelem(2 l_l_overflags->bbox)):yCoord(nthelem(1 l_l_overflags->bbox))
                                                  jfhDBCreateRefdes(dbRefdes ptRefdesPositionNew)
                                              );end if( l_l_overflags->bottom == t
                                        );end if( l_l_overflags->top == t
                                   );end if( l_l_overflags->right == t
                             );end if( l_l_overflags->left == t
                        );end of if( l_l_overflags->current == t
                          
                        
                      );end of if( l_SymRotation > 85 && l_SymRotation < 95 ||....  
           
                  );end of foreach(sym ll_dbTopComps
           
           
           
         );end of procedure( jfhPlaceBtmRefdesAgain(l_l_dbBtmComps)



;**************************************************************

;   Prototype     :  jfhCreateExtentInputForm()
;   Description   :  This function create the extent input form file
;   Inoput Param  :  nil
;   Output        :  nil
;   Return Value  :  nil
;   Calls         :  nil
;   Called by     :  the main function
;   History       :
;                 1.Jingfenghua   2002/12/25  Created Function

;**************************************************************

;procedure( jfhCreateExtentInputForm()
;             l_p_formfile = outfile("extentvalue.form" "w")
;
;             fprintf(l_p_formfile "FILE_TYPE=FORM_DEFN VERSION=2\n")
;             fprintf(l_p_formfile "FORM\n")
;             fprintf(l_p_formfile "FIXED\n")
;             fprintf(l_p_formfile "PORT 36 20\n")
;             fprintf(l_p_formfile "HEADER \"Input Extent Form\"\n")
;             
;             fprintf(l_p_formfile "TEXT \"Please input the value refdes to component:\"\n")
;             fprintf(l_p_formfile "TLOC 3 1\n")
;             fprintf(l_p_formfile "ENDTEXT\n")
;             
;             fprintf(l_p_formfile "FIELD disR2C\n")
;             fprintf(l_p_formfile "FLOC 12 6\n")
;             fprintf(l_p_formfile "INTFILLIN 6 6\n")
;             fprintf(l_p_formfile "INTMIN 0\n")
;             fprintf(l_p_formfile "INTMAX 200\n")
;             fprintf(l_p_formfile "ENDFIELD\n")
;             
;             
;             fprintf(l_p_formfile "FIELD ok\")
;             fprintf(l_p_formfile "FLOC 2 26\n")
;             fprintf(l_p_formfile "MENUBUTTON \"OK\" 5 3\n")
;             fprintf(l_p_formfile "ENDFIELD\n")
;             
;             fprintf(l_p_formfile "FIELD cancel\")
;             fprintf(l_p_formfile "FLOC 8 26\n")
;             fprintf(l_p_formfile "MENUBUTTON \"Cancel\" 5 3\n")
;             fprintf(l_p_formfile "ENDFIELD\n")
;             
;             fprintf(l_p_formfile "ENDTITLE\n")
;             
;             fprintf(l_p_formfile "ENDFORM\n")
;             
;             close(l_p_formfile)
;
;         );end of procedure( jfhCreateExtentInputForm()




;**************************************************************

;   Prototype     :  jfhInitialization()
;   Description   :  First time placing refdes
;   Inoput Param  :  nil
;   Output        :  nil
;   Return Value  :  nil
;   Calls         :  jfhPlaceTopRefdes(),jfhPlaceBtmRefdes()
;   Called by     :  main function
;   History       :
;                 1.Jingfenghua   2002/12/25  Created Function

;**************************************************************

procedure( jfhInitialization()
           prog( (l_n_refdesmodifytimes)
             l_l_DesignProperty = axlDBGetProperties(axlDBGetDesign() "user" )
             
             foreach( l_property l_l_DesignProperty
             
                    if( symbolToString(nthelem(1 l_property)) == "REFDESMODIFYTIMES"
                       then
                          l_n_refdesmodifytimes = atoi(nthelem(2 l_property)) + 1
                          axlDBAddProp(axlDBGetDesign() list( "REFDESMODIFYTIMES" l_n_refdesmodifytimes))
                          
                          if( l_n_refdesmodifytimes > 6 
                          then
                              axlMsgPut("You have used this programe 7 times,please send 7$ to www.heaven.com,thank you!")
                              axlDBAddProp(axlDBGetDesign() list( "REFDESMODIFYTIMES" 1))
                            );end of if( l_n_refdesmodifytimes > 4 == t
                          return(l_n_refdesmodifytimes)
                       else
                          temp = 1;do nothig
                          ;axlMsgPut("1")   
                      );end of if( nthelem(1 l_property) == "REFDESMODIFYTIMES"

                    );end of foreach( l_property l_l_DesignProperty

;             axlShell("jfhrotateref")
       
             jfhPlaceTopRefdes(g_l_dbTopComps)
             jfhPlaceBtmRefdes(g_l_dbBtmComps)
             axlMsgPut("Finish Initialization!")
             
             axlDBCreatePropDictEntry( "REFDESMODIFYTIMES", "integer", list( "designs")) 
             axlDBAddProp(axlDBGetDesign() list( "REFDESMODIFYTIMES" 1))
            );end of prog( (l_n_refdesmodifytimes)
          );end of procedure( jfhInitialization()    


;**************************************************************

;   Prototype     :  jfhRefdesLocate()
;   Description   :  Main function which will be defined as a command
;   Inoput Param  :  nil
;   Output        :  nil
;   Return Value  :  nil
;   Calls         :  nil
;   Called by     :  nil
;   History       :
;                 1.Jingfenghua   2002/07/10  Created Function

;**************************************************************

procedure( jfhRefdesLocate()


 		
           axlVisibleDesign(nil)
           axlVisibleLayer( "REF DES/SILKSCREEN_TOP" t )
           axlVisibleLayer( "PIN/TOP" t )
           axlVisibleLayer( "VIA CLASS/TOP" t )
           axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_TOP" t )
           axlVisibleLayer( "BORAD GEOMETRY/SILKSREEN_TOP" t )
           axlVisibleLayer( "REF DES/SILKSCREEN_BOTTOM" t )
           axlVisibleLayer( "PIN/BOTTOM" t )
           axlVisibleLayer( "VIA CLASS/BOTTOM" t )
	   axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" t )
           axlVisibleLayer( "BORAD GEOMETRY/SILKSREEN_BOTTOM" t )
           axlVisibleLayer( "BOARD GEOMETRY/OUTLINE" t )
           
           
           g_l_dbAllComps = nil
           g_l_dbTopComps = nil
           g_l_dbBtmComps = nil
           
           g_n_ExtentValue = 30;default distance from refdes to component
           g_n_priority    = 4
           
           
           
              

           
                     
           ;create two shadow subclass
           axlLayerCreateNonConductor("PACKAGE GEOMETRY/COMPS SHADOW TOP")
           axlLayerCreateNonConductor("PACKAGE GEOMETRY/COMPS SHADOW BTM")
           
           tshapelayer = "PACKAGE GEOMETRY/COMPS SHADOW TOP"
           bshapelayer = "PACKAGE GEOMETRY/COMPS SHADOW BTM"
           axlVisibleLayer( tshapelayer t )
	   axlVisibleLayer( bshapelayer t )



           if(axlOKToProceed() != t 
              then
                 axlMsgPut("Finish current command first")
                 ;return(nil)
              else
                 if(axlUIYesNo("Is your board a newly designed one?") != t
                    then
                       axlMsgPut("This program only fits newly designed board!")
                    else
                 
                      ;jfhCreateMacroFile()
                      ;axlShell("replay txtsize3.scr");set block 3 text size
                      ;axlMsgPut("Macro OK!")                 
                      ;axlShell("rm txtsize3.scr")
                    
                    g_str_extentvalue = axlUIPrompt( "Enter Extent Value(From 0 to 200)" "30" )
                    g_n_ExtentValue = atoi(g_str_extentvalue)
                      
                    while( (g_n_ExtentValue < 0 || g_n_ExtentValue > 200)
                           axlMsgPut("Please input value from 0 to 200!")
                           g_str_extentvalue = axlUIPrompt( "Enter Extent Value(From 0 to 200)" "30" )
                           g_n_ExtentValue = atoi(g_str_extentvalue)
                         )   
           
                    g_str_prioritylevel = axlUIPrompt( "Enter Priority Level(From 0 to 4)" "4" )
                    g_n_priority = atoi(g_str_prioritylevel)
           
                    while( (g_n_priority < 0 || g_n_priority > 4)
                           axlMsgPut("Please input value from 0 to 4!")
                           g_str_prioritylevel = axlUIPrompt( "Enter Priority Level(From 0 to 4)" "4" )
                           g_n_priority = atoi(g_str_prioritylevel)
                         )
                      
                      
                      g_db_TxtBlockParam = axlGetParam("paramTextBlock:3")
                      g_db_TxtBlockParam->width = 30
                      g_db_TxtBlockParam->photoWidth = 6
                      g_db_TxtBlockParam->lineSpace = 0
                      g_db_TxtBlockParam->height = 30
                      g_db_TxtBlockParam->charSpace = 0
                      axlSetParam(g_db_TxtBlockParam)
                      
                      
                      
                      jfhGetAllCompsDBid();fill globe list g_l_dbAllComps with ids of all the components
                      jfhChgAllRefdesTxtBlock( g_l_dbAllComps )
;                      axlMsgPut("change text block size OK!")
                      jfhSplitComps(g_l_dbAllComps)
                      
                      ;jfhPlaceTopRefdes(g_l_dbTopComps)
;                      axlMsgPut("Top side complete!")
                      ;jfhPlaceBtmRefdes(g_l_dbBtmComps)
;                      axlMsgPut("Bottom side complete!")
                      jfhInitialization() 
                      
                      jfhPlaceTopRefdesAgain(g_l_dbTopComps)
                      jfhPlaceBtmRefdesAgain(g_l_dbBtmComps)

                      
                      ;axlSetFindFilter(?enabled list("noall" "Symbols") ?onButtons list("noall" "Symbols"))
                      axlClearSelSet()
                      
                      ;jfhGetAllCompsDBid()
                      ;axlDehighlightObject(g_l_dbAllComps)
                      axlMsgPut("Placing refdes function complete!")
                      axlMsgPut("Version 2.0")
                 
                  );end of if(axlUIYesNo("Is your board a new one?")
              );end of if(axlOKToProceed() != t 
           
         );end of procedure( jfhRefdesLocate()
         
         
axlCmdRegister( "jfh_refdeslocate" 'jfhRefdesLocate)

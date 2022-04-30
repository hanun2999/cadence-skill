/* 
©À©¤ 
©¦ ©À©¤        ³ÌÐòÃû³Æ£º quick_danglings.il
©¦ ©À©¤        ³ÌÐò¹¦ÄÜ£ºÉ¾³ý¶ÏÍ·Ïß£¬Ðü¿ÕµÄ¹ý¿×£¬ÒÔ¼°¹Âµº
©¦ ©À©¤        ´´½¨Ê±¼ä£º2014Äê01ÔÂ26ÈÕ 
©¦ ©À©¤        ×÷    Õß£ºÍ??
©À©¤ 

*/ 

axlCmdRegister( "quick_dangling" 'quick_danglings ?cmdType "general" ) 

defvar( psmddo_HELPPAGE "http://www.eda365.com/")


; load("quick_danglings.il")

procedure( quick_danglings(  )
  let(
    ( lDanglingLine
      lDanglingVia
      lIslandShape
      ps_DanglingForm
      ps_DanglingForm_file
      ps_DanglingForm_Port
      lDanglingObject
    )
 
    when( axlOKToProceed()
        axlMsgPut("quick_danglings from www.eda365.com" )
 
        lDanglingObject = ps_ddoCheck()
        lDanglingLine = car(lDanglingObject)
        lDanglingVia = cadr(lDanglingObject)
        lIslandShape = caddr(lDanglingObject)
 
        if( lDanglingVia || lDanglingLine || lIslandShape then                  
          ps_DanglingForm_file = strcat( axlTempDirectory() "./ps_DanglingForm.form" )
          ps_DanglingForm_Port= outfile( ps_DanglingForm_file "w" )       
          fprintf( ps_DanglingForm_Port "FILE_TYPE=FORM_DEFN VERSION=2\n" )
          fprintf( ps_DanglingForm_Port "FORM\n" )
          fprintf( ps_DanglingForm_Port "FIXED\n" )
          fprintf( ps_DanglingForm_Port "PORT 42 42\n" )
          fprintf( ps_DanglingForm_Port "HEADER \"Delete Dangling Design Objects\"\n" )
          fprintf( ps_DanglingForm_Port "TILE\n" )
 
          fprintf( ps_DanglingForm_Port "FIELD ddoRefresh\n" )
          fprintf( ps_DanglingForm_Port "FLOC 2 39\n" )
          fprintf( ps_DanglingForm_Port "MENUBUTTON \"Refresh\" 10 3\n" )
          fprintf( ps_DanglingForm_Port "ENDFIELD\n" )  
 
          fprintf( ps_DanglingForm_Port "FIELD ddoHelp\n" )
          fprintf( ps_DanglingForm_Port "FLOC 16 39\n" )
          fprintf( ps_DanglingForm_Port "MENUBUTTON \"Help\" 10 3\n" )
          fprintf( ps_DanglingForm_Port "ENDFIELD\n" ) 
 
          fprintf( ps_DanglingForm_Port "FIELD ddoClose\n" )
          fprintf( ps_DanglingForm_Port "FLOC 30 39\n" )
          fprintf( ps_DanglingForm_Port "MENUBUTTON \"Close\" 10 3\n" )
          fprintf( ps_DanglingForm_Port "ENDFIELD\n" )
 
          fprintf( ps_DanglingForm_Port "TEXT \"Tool from www.eda365.com\"\n" )
          fprintf( ps_DanglingForm_Port "FLOC 2 1\n" )
          fprintf( ps_DanglingForm_Port "ENDTEXT\n" )
 
          fprintf( ps_DanglingForm_Port "TABSET tset\n     FLOC 2 3\n      FSIZE 39 35\n")
		  
		  
		  ;cline
          fprintf( ps_DanglingForm_Port "TAB \"Dangling Lines\" \n")
          fprintf( ps_DanglingForm_Port "TEXT \"Dangling Line:\"\n" )
          fprintf( ps_DanglingForm_Port "TLOC 2 1\n" )
          fprintf( ps_DanglingForm_Port "ENDTEXT\n" )
 
          fprintf( ps_DanglingForm_Port "TEXT \n" )
          fprintf( ps_DanglingForm_Port "FLOC 12 1\n" )
          fprintf( ps_DanglingForm_Port "INFO ddoLineInfo 10\n" )
          fprintf( ps_DanglingForm_Port "ENDTEXT\n" ) 
 
          fprintf( ps_DanglingForm_Port "FIELD ddoLineList\n" )
          fprintf( ps_DanglingForm_Port "FLOC 2 3\n" )
          fprintf( ps_DanglingForm_Port "LIST \"\" 34 14\n" )
          fprintf( ps_DanglingForm_Port "OPTIONS multiselect\n" )
          fprintf( ps_DanglingForm_Port "ENDFIELD\n" )
 
          fprintf( ps_DanglingForm_Port "FIELD ddoLinesDel\n" )
          fprintf( ps_DanglingForm_Port "FLOC 13 30\n" )
          fprintf( ps_DanglingForm_Port "MENUBUTTON \"Delete\" 12 3\n" )
          fprintf( ps_DanglingForm_Port "ENDFIELD\n" )                    
 
          fprintf(ps_DanglingForm_Port "ENDTAB\n")
		  
		  
		  
		  ;via
 
          fprintf(ps_DanglingForm_Port "TAB \"Dangling Vias\" \n")
          fprintf( ps_DanglingForm_Port "TEXT \"Dangling Vias:\"\n" )
          fprintf( ps_DanglingForm_Port "TLOC 2 1\n" )
          fprintf( ps_DanglingForm_Port "ENDTEXT\n" )
 
          fprintf( ps_DanglingForm_Port "TEXT \n" )
          fprintf( ps_DanglingForm_Port "FLOC 12 1\n" )
          fprintf( ps_DanglingForm_Port "INFO ddoViaInfo 10\n" )
          fprintf( ps_DanglingForm_Port "ENDTEXT\n" ) 
 
          fprintf( ps_DanglingForm_Port "FIELD ddoViaList\n" )
          fprintf( ps_DanglingForm_Port "FLOC 2 3\n" )
          fprintf( ps_DanglingForm_Port "LIST \"\" 34 14\n" )
          fprintf( ps_DanglingForm_Port "OPTIONS multiselect\n" )
          fprintf( ps_DanglingForm_Port "ENDFIELD\n" )
 
          fprintf( ps_DanglingForm_Port "FIELD ddoViasDel\n" )
          fprintf( ps_DanglingForm_Port "FLOC 2 30\n" )
          fprintf( ps_DanglingForm_Port "MENUBUTTON \"Delete\" 12 3\n" )
          fprintf( ps_DanglingForm_Port "ENDFIELD\n" )                    
 
          fprintf( ps_DanglingForm_Port "FIELD ddoAssign\n" )
          fprintf( ps_DanglingForm_Port "FLOC 24 30\n" )
          fprintf( ps_DanglingForm_Port "MENUBUTTON \"Change Net\" 12 3\n" )
          fprintf( ps_DanglingForm_Port "ENDFIELD\n" ) 
 
          fprintf(ps_DanglingForm_Port "ENDTAB\n")
		  
		  ;shape
 
          fprintf(ps_DanglingForm_Port "TAB \"Island Shapes\" \n")
          fprintf( ps_DanglingForm_Port "TEXT \"Island Shapes:\"\n" )
          fprintf( ps_DanglingForm_Port "TLOC 2 1\n" )
          fprintf( ps_DanglingForm_Port "ENDTEXT\n" )
 
          fprintf( ps_DanglingForm_Port "TEXT \n" )
          fprintf( ps_DanglingForm_Port "FLOC 12 1\n" )
          fprintf( ps_DanglingForm_Port "INFO ddoShapeInfo 10\n" )
          fprintf( ps_DanglingForm_Port "ENDTEXT\n" ) 
 
          fprintf( ps_DanglingForm_Port "FIELD ddoShapeList\n" )
          fprintf( ps_DanglingForm_Port "FLOC 2 3\n" )
          fprintf( ps_DanglingForm_Port "LIST \"\" 34 14\n" )
          fprintf( ps_DanglingForm_Port "OPTIONS multiselect\n" )
          fprintf( ps_DanglingForm_Port "ENDFIELD\n" )
 
          fprintf( ps_DanglingForm_Port "FIELD ddoShapesDel\n" )
          fprintf( ps_DanglingForm_Port "FLOC 13 30\n" )
          fprintf( ps_DanglingForm_Port "MENUBUTTON \"Delete\" 12 3\n" )
          fprintf( ps_DanglingForm_Port "ENDFIELD\n" )                    
 
          fprintf(ps_DanglingForm_Port "ENDTAB\n")
 
          fprintf(ps_DanglingForm_Port "ENDTABSET\n")
 
          fprintf( ps_DanglingForm_Port "ENDTILE\n" )
          fprintf( ps_DanglingForm_Port "ENDFORM\n" )
 
          close( ps_DanglingForm_Port )
 
          ps_DanglingForm = axlFormCreate( (gensym) ps_DanglingForm_file '(e outer) 'ps_DanglingForm_action t)
          axlFormSetField( ps_DanglingForm "ddoLineList" lDanglingLine )
          axlFormSetField( ps_DanglingForm "ddoViaList" lDanglingVia )
          axlFormSetField( ps_DanglingForm "ddoShapeList" lIslandShape )
          axlFormSetField( ps_DanglingForm "ddoLineInfo" length(lDanglingLine) )
          axlFormSetField( ps_DanglingForm "ddoViaInfo" length(lDanglingVia) )
          axlFormSetField( ps_DanglingForm "ddoShapeInfo" length(lIslandShape) )
          axlFormColorize( ps_DanglingForm "ddoLineInfo" 'text 'red )
          axlFormColorize( ps_DanglingForm "ddoViaInfo" 'text 'red )
          axlFormColorize( ps_DanglingForm "ddoShapeInfo" 'text 'red )
 
          axlFormDisplay( ps_DanglingForm )
          when( lDanglingLine
            axlMsgPut(sprintf(nil "E- %d Dangling Lines, check Dangling Lines Tab" length(lDanglingLine) ))
          )
          when( lDanglingVia
            axlMsgPut(sprintf(nil "E- %d Dangling Via, check Dangling Vias Tab" length(lDanglingVia) ))
          )
          when( lIslandShape
            axlMsgPut(sprintf(nil "E- %d Island Shape, check Island Shapes Tab" length(lIslandShape) ))
          )
          axlUIWPrint( ps_DanglingForm "Select Dangling, Island Line/Via/Shape..." )
          axlUIWDisableQuit(ps_DanglingForm)
          deleteFile(ps_DanglingForm_file)
        else
          axlMsgPut("I- No dangling, island line/via/shape problems")
        ); end if lDanglingVia || lDanglingLine || lIslandShape
    ); end when
  ); end let
); end quick_danglings
 
procedure( ps_DanglingForm_action( ps_DanglingForm1 )
  let(
    ( lDanglingVia
      lDanglingLine
      lIslandShape
      lIssueCline
      lTemp
      sLayer
      fStartX
      fStartY
      fEndX
      fEndY
      sStart
      sEnd
      lSeg
      lStartA
      lStartB
      lEndA
      lEndB
      sStartTempA
      sStartTempB
      sEndTempA
      sEndTempB
      fCoordX
      fCoordY
      dVia
      lVia
      fFindRange
      lClines
      sNet
      sMessage
      lViaInfo
      lShapeInfo
      lShape
      dShape
      lDanglingObject
      lSys
      lCoord
      bShape
      bDRC
    )
    fFindRange = axlMKSConvert(1 "MILS")
    case( ps_DanglingForm1->curField
      ( "ddoRefresh"
        axlClearSelSet()        
        lDanglingObject = ps_ddoCheck()
        lDanglingLine = car(lDanglingObject)
        lDanglingVia = cadr(lDanglingObject)
        lIslandShape = caddr(lDanglingObject)
 
        if( lDanglingLine || lDanglingVia || lIslandShape then
          when( lDanglingLine
            axlMsgPut(sprintf(nil "E- %d Dangling Lines, check Dangling Lines Tab" length(lDanglingLine) ))
          )
          when( lDanglingVia
            axlMsgPut(sprintf(nil "E- %d Dangling Via, check Dangling Vias Tab" length(lDanglingVia) ))
          )
          when( lIslandShape
            axlMsgPut(sprintf(nil "E- %d Island Shape, check Island Shapes Tab" length(lIslandShape) ))
          )
        else
          axlMsgPut("I- No Dangling, Island Lines/Vias/Shapes")
        )
        axlFormListDeleteAll( ps_DanglingForm1 "ddoLineList" )
        axlFormListDeleteAll( ps_DanglingForm1 "ddoViaList" )
        axlFormListDeleteAll( ps_DanglingForm1 "ddoShapeList" )
        axlFormSetField( ps_DanglingForm1 "ddoLineList" lDanglingLine )
        axlFormSetField( ps_DanglingForm1 "ddoViaList" lDanglingVia )
        axlFormSetField( ps_DanglingForm1 "ddoShapeList" lIslandShape )
        axlFormSetField( ps_DanglingForm1 "ddoLineInfo" length(lDanglingLine) )
        axlFormSetField( ps_DanglingForm1 "ddoViaInfo" length(lDanglingVia) )
        axlFormSetField( ps_DanglingForm1 "ddoShapeInfo" length(lIslandShape) )
        axlFormColorize(ps_DanglingForm1 "ddoLineInfo" 'text 'red)
        axlFormColorize(ps_DanglingForm1 "ddoViaInfo" 'text 'red)
        axlFormColorize(ps_DanglingForm1 "ddoShapeInfo" 'text 'red)
      )
      ( "ddoLineList"
        lDanglingLine = axlFormListGetSelItems(ps_DanglingForm1 "ddoLineList")  
        axlClearSelSet()        
        axlSetFindFilter( ?enabled  '("noall" "clines") ?onButtons '("clines") )        
        lIssueCline = nil
        axlVisibleDesign(nil)
        foreach( sline lDanglingLine
          lTemp = parseString( sline "," )          
          sLayer = car( lTemp )
          lCoord = parseString(caddr(lTemp) " ()to")
          fStartX = atof(car(lCoord))
          fStartY = atof(cadr(lCoord))
          fEndX = atof(caddr(lCoord))
          fEndY = atof(nth(3 lCoord))
          axlVisibleLayer(strcat("etch/" sLayer) t)         
          axlVisibleLayer(strcat("via class/" sLayer) t)  
          axlVisibleLayer(strcat("pin/" sLayer) t)      
          sStart = sprintf(nil "x%0.3fy%0.3f" fStartX fStartY)
          sEnd = sprintf(nil "x%0.3fy%0.3f" fEndX fEndY)
          lClines = axlGetSelSet(
                      axlSingleSelectBox(
                        list((fStartX-fFindRange):(fStartY-fFindRange) 
                          (fStartX+fFindRange):(fStartY+fFindRange))      
                      ))
          axlClearSelSet()          
          if( lClines then
            foreach( cline lClines
              lSeg = cline->segments
              lStartA = car(car(lSeg)->startEnd)
              lEndA = cadr(car(last(lSeg))->startEnd)
              sStartTempA = sprintf( nil "x%0.3fy%0.3f" car(lStartA) cadr(lStartA))
              sEndTempA = sprintf( nil "x%0.3fy%0.3f" car(lEndA) cadr(lEndA))
 
              lStartB = car(car(last(lSeg))->startEnd)
              lEndB = cadr(car(lSeg)->startEnd)
              sStartTempB = sprintf( nil "x%0.3fy%0.3f" car(lStartB) cadr(lStartB))
              sEndTempB = sprintf( nil "x%0.3fy%0.3f" car(lEndB) cadr(lEndB))
 
              when( (sStartTempA==sStart && sEndTempA==sEnd) ||
                  (sStartTempA==sEnd && sEndTempA==sStart) ||
                  (sStartTempB==sStart && sEndTempB==sEnd) ||
                  (sStartTempB==sEnd && sEndTempB==sStart) 
                lIssueCline = cons( cline lIssueCline )
              )
            )           
          else
            axlUIWPrint( ps_DanglingForm1 "Can not find the cline, find it manually..." )
          )
        )
        axlHighlightObject(lIssueCline)
        axlZoomToDbid(lIssueCline t)    
      )
      ( "ddoViaList"
 
        when( lDanglingVia = axlFormListGetSelItems(ps_DanglingForm1 "ddoViaList")  
 
          axlClearSelSet()        
          axlSetFindFilter( ?enabled  '("noall" "vias") ?onButtons '("vias") )
          lVia = nil
          axlVisibleDesign(nil)
          foreach( svia lDanglingVia
            lViaInfo = parseString(svia ",")
            axlVisibleLayer(strcat("via class/" car(lViaInfo)) t)
            axlVisibleLayer(strcat("etch/" car(lViaInfo)) t)
            axlVisibleLayer(strcat("pin/" car(lViaInfo)) t)
            lCoord = parseString(caddr(lViaInfo) " ()")
            fCoordX = atof(car(lCoord))
            fCoordY = atof(cadr(lCoord))
            dVia = car(axlGetSelSet(axlSingleSelectPoint(fCoordX:fCoordY)))
            axlClearSelSet()
            when( dVia
              lVia = cons( dVia lVia)
            )
          )
          axlHighlightObject(lVia)
          axlZoomToDbid(lVia t)     
        )
      )
      ( "ddoShapeList"
 
        when( lIslandShape = axlFormListGetSelItems(ps_DanglingForm1 "ddoShapeList")  
 
          axlClearSelSet()        
          axlSetFindFilter( ?enabled  '("noall" "shapes") ?onButtons '("shapes") )
          lShape = nil
          axlVisibleDesign(nil)
          foreach( shape lIslandShape
            lShapeInfo = parseString(shape ",")
            axlVisibleLayer(strcat("via class/" car(lShapeInfo)) t)
            axlVisibleLayer(strcat("etch/" car(lShapeInfo)) t)
            axlVisibleLayer(strcat("pin/" car(lShapeInfo)) t)
            lCoord = parseString(caddr(lShapeInfo) " ()")
            fCoordX = atof(car(lCoord))
            fCoordY = atof(cadr(lCoord))
            dShape = car(axlGetSelSet(axlSingleSelectPoint(fCoordX:fCoordY)))
            axlClearSelSet()
            when( dShape
              lShape = cons( dShape lShape )
            )
          )
          axlHighlightObject(lShape)
          axlZoomToDbid(lShape t)     
        )
      )
      ( "ddoLinesDel"
        when( lDanglingLine = axlFormListGetSelItems(ps_DanglingForm1 "ddoLineList")  
          axlClearSelSet()        
          axlSetFindFilter( ?enabled  '("noall" "clines") ?onButtons '("clines") )    
          lIssueCline = nil
          axlVisibleDesign(nil)
          foreach( sline lDanglingLine
            lTemp = parseString( sline "," )          
            sLayer = car( lTemp )
            lCoord = parseString(caddr(lTemp) " ()to")
            fStartX = atof(car(lCoord))
            fStartY = atof(cadr(lCoord))
            fEndX = atof(caddr(lCoord))
            fEndY = atof(nth(3 lCoord))
            axlVisibleLayer(strcat("etch/" sLayer) t)         
            axlVisibleLayer(strcat("via class/" sLayer) t)  
            axlVisibleLayer(strcat("pin/" sLayer) t)      
            sStart = sprintf(nil "x%0.3fy%0.3f" fStartX fStartY)
            sEnd = sprintf(nil "x%0.3fy%0.3f" fEndX fEndY)
            lClines = axlGetSelSet(
                      axlSingleSelectBox(
                        list((fStartX-fFindRange):(fStartY-fFindRange) 
                          (fStartX+fFindRange):(fStartY+fFindRange))      
                      ))
            axlClearSelSet()          
            when( lClines 
              foreach( cline lClines
                lSeg = cline->segments
                lStartA = car(car(lSeg)->startEnd)
                lEndA = cadr(car(last(lSeg))->startEnd)
                sStartTempA = sprintf( nil "x%0.3fy%0.3f" car(lStartA) cadr(lStartA))
                sEndTempA = sprintf( nil "x%0.3fy%0.3f" car(lEndA) cadr(lEndA))
                lStartB = car(car(last(lSeg))->startEnd)
                lEndB = cadr(car(lSeg)->startEnd)
                sStartTempB = sprintf( nil "x%0.3fy%0.3f" car(lStartB) cadr(lStartB))
                sEndTempB = sprintf( nil "x%0.3fy%0.3f" car(lEndB) cadr(lEndB))
                when( (sStartTempA==sStart && sEndTempA==sEnd) ||
                    (sStartTempA==sEnd && sEndTempA==sStart) ||
                    (sStartTempB==sStart && sEndTempB==sEnd) ||
                    (sStartTempB==sEnd && sEndTempB==sStart) 
                  lIssueCline = cons( cline lIssueCline )
                )
              )
            ); end when lClines           
          ); end foreach
          axlDeleteObject(lIssueCline)
          axlFormListDeleteItem(ps_DanglingForm1 "ddoLineList" lDanglingLine)  
          axlMsgPut("I- Dangling Line was deleted")
        ); end when dline 
      )
      ( "ddoViasDel"
        bDRC = axlDBControl('drcEnable nil)
        bShape = axlDBControl( 'dynamicFillMode nil )
        if( lDanglingVia = axlFormListGetSelItems(ps_DanglingForm1 "ddoViaList")  then
          axlClearSelSet()        
          axlSetFindFilter( ?enabled  '("noall" "vias") ?onButtons '("vias") )
          lVia = nil
          lSys = axlVisibleGet()
          axlVisibleDesign(nil)
          foreach( svia lDanglingVia
            lViaInfo = parseString(svia ",")
            axlVisibleLayer(strcat("via class/" car(lViaInfo)) t)
            lCoord = parseString(caddr(lViaInfo) " ()")
            fCoordX = atof(car(lCoord))
            fCoordY = atof(cadr(lCoord))
            dVia = car(axlGetSelSet(axlSingleSelectPoint(fCoordX:fCoordY)))
            axlClearSelSet()
            when( dVia
              lVia = cons( dVia lVia)
            )
            axlVisibleLayer(strcat("via class/" car(lViaInfo)) nil)
          )
          axlDeleteObject(lVia)
          axlFormListDeleteItem(ps_DanglingForm1 "ddoViaList" lDanglingVia)  
          axlMsgPut("I- Dangling Via was deleted")
          axlVisibleSet(lSys)
        else
          axlUIConfirm("E- Pick a item from the list before cilck on Delete button")
        ) 
        axlDBControl('drcEnable bDRC)        
        axlDBControl( 'dynamicFillMode bShape )   
      )
      ( "ddoShapesDel"
        axlMsgPut("R- if delete shape on this form is too slow, please use Shape->Delete Islands to delete all island shape and use this tool to double confirm")
        bDRC = axlDBControl('drcEnable nil)
        bShape = axlDBControl( 'dynamicFillMode nil )
        if( lIslandShape = axlFormListGetSelItems(nv_DanglingForm1 "ddoShapeList")  then
          axlClearSelSet()        
          axlSetFindFilter( ?enabled  '("noall" "shapes") ?onButtons '("shapes") )
          lShape = nil
          lSys = axlVisibleGet()
          axlVisibleDesign(nil)
          foreach( shape lIslandShape
            lShapeInfo = parseString(shape ",")
            axlVisibleLayer(strcat("via class/" car(lShapeInfo)) t)
            axlVisibleLayer(strcat("etch/" car(lShapeInfo)) t)
            axlVisibleLayer(strcat("pin/" car(lShapeInfo)) t)
            lCoord = parseString(caddr(lShapeInfo) " ()")
            fCoordX = atof(car(lCoord))
            fCoordY = atof(cadr(lCoord))
            dShape = car(axlGetSelSet(axlSingleSelectPoint(fCoordX:fCoordY)))
            axlClearSelSet()
            when( dShape
              if( dShape->shapeBoundary then
                ;  need to use current dynamic shape and void this island shape
                dVoidPoly=car(axlPolyFromDB(dShape))   ; to be void poly
                dDynaShapePoly=car(axlPolyFromDB(dShape->shapeBoundary))  ; dynamic shape poly
                dNewPoly  = car(axlPolyOperation(dDynaShapePoly dVoidPoly 'ANDNOT))  ; new shape poly
                sNet = dShape->net->name  
                sLayer = dShape->shapeBoundary->layer
                lDynShapeGroup = car(dShape->parentGroups)
                axlDeleteObject(dShape->shapeBoundary)  ; delete original shape
                dNewShape = car(axlDBCreateShape(dNewPoly t sLayer sNet))  ; create new shape
                dParent=car(car(dNewShape->shapeAuto)->parentGroups)
                axlShapeDynamicUpdate(dNewShape, t) ;update the shape, this is a time causing step            
              else
                lShape = cons( dShape lShape )
              )
            )
            axlVisibleLayer(strcat("etch/" car(lShapeInfo)) nil)
          )
          axlDeleteObject(lShape) ; delete static/whole dynamic shape
          axlFormListDeleteItem(nv_DanglingForm1 "ddoShapeList" lIslandShape)  
          axlMsgPut("I- Island Shape was deleted")
          axlVisibleSet(lSys)
          axlFlushDisplay()
        else
          axlUIConfirm("E- Pick a item from the list before cilck on Delete button")
        ) 
        axlDBControl('drcEnable bDRC)        
        axlDBControl( 'dynamicFillMode bShape )   
      )
      ( "ddoClose"
        axlFormClose( ps_DanglingForm1 )
        axlClearSelSet()
        axlFlushDisplay()
        axlEndSkillMode()
        axlMsgPut("Done, Please update DRC and refresh shapes")
      )
      ( "ddoAssign"
        bDRC = axlDBControl('drcEnable nil)
        bShape = axlDBControl( 'dynamicFillMode nil )
        if( lDanglingVia = axlFormListGetSelItems(ps_DanglingForm1 "ddoViaList")  then
          axlClearSelSet()        
          axlSetFindFilter( ?enabled  '("noall" "vias") ?onButtons '("vias") )
          lVia = nil
          lSys = axlVisibleGet()
          axlVisibleDesign(nil)
          foreach( svia lDanglingVia
            lViaInfo = parseString(svia ",")
            axlVisibleLayer(strcat("via class/" car(lViaInfo)) t)
            lCoord = parseString(caddr(lViaInfo) " ()")
            fCoordX = atof(car(lCoord))
            fCoordY = atof(cadr(lCoord))
            dVia = car(axlGetSelSet(axlSingleSelectPoint(fCoordX:fCoordY)))
            axlClearSelSet()
            when( dVia
              lVia = cons( dVia lVia)
            )
            axlVisibleLayer(strcat("via class/" car(lViaInfo)) nil)
          )
          axlMsgPut("I- Select a net by click in the design")
          axlVisibleSet(lSys)
 
          axlSetFindFilter( ?enabled  '("noall" "nets") ?onButtons '("nets") )
          if( axlSingleSelectPoint() then
            sNet = car(axlGetSelSet())->name
            axlClearSelSet()
            foreach( item lVia
              axlDBCloak( 'axlDBCreateVia( item->name item->xy sNet ) 'shape )
              if( item->net->name then
                  sMessage = sprintf( nil "I- Change via net from %s to %s" item->net->name sNet )
              else
                  sMessage = sprintf( nil "I- Change via net from nil to %s" sNet )
              ); end if                       
              axlMsgPut( sMessage )
            )
            axlDeleteObject(lVia)
            axlFormListDeleteItem(ps_DanglingForm1 "ddoViaList" lDanglingVia)  
            ;axlMsgPut("I- Dangling Via net was changed")
          else
            axlMsgPut("E- Dummy net was selected, no changes")
          ); end when
        else
          axlUIConfirm("E- Pick a item from the list before cilck on Assign Net button")
        ) 
        axlDBControl('drcEnable bDRC)        
        axlDBControl( 'dynamicFillMode bShape )
      )
      ( "ddoHelp"
        axlHttp( psmddo_HELPPAGE )
      )
    )
  )
)
 
procedure( ps_ddoCheck()
  let(
    ( lClines
      lVias
      sNet
      sVia
      lDanglingLine
      bIgnore
      lDanglingVia
      lIslandShape
      sShape
      sLine
    )
    axlClearSelSet()        
    axlSetFindFilter( ?enabled  '("noall" "invisible" "clines" ) ?onButtons '("clines" ) ) 
    lClines = axlGetSelSet(axlAddSelectAll())
    axlClearSelSet()
    axlSetFindFilter( ?enabled  '("noall" "invisible"  "vias") ?onButtons '( "vias") ) 
    lVias = axlGetSelSet(axlAddSelectAll())
    axlClearSelSet()
    foreach( cline lClines
      when( length(axlDBGetConnect( cline t ))<2
        unless(cline->prop->FILLET||cline->symbolEtch 
          if(cline->net then
            sNet = cline->net->name
          else
            sNet = "Dummy"
          ) 
          sLine = sprintf(nil "%s, %s, %L to %L"
            cadr(parseString(cline->layer "/"))
            sNet
            car(car(cline->segments)->startEnd)
            cadr(car(last(cline->segments))->startEnd)
          )
          lDanglingLine = cons( sLine lDanglingLine )
        )
      )
    )
 
    lDanglingLine = reverse(sort(lDanglingLine nil))
    foreach( via lVias
      unless( via->symbolEtch ;;; ignore symbol type via
        bIgnore = nil
        if(via->net then
          sNet = via->net->name
          when( rexMatchp("^SNN_" sNet)
            bIgnore = t
          )
        else
          sNet = "Dummy"
        ) 
        sVia = sprintf( nil "%s, %s, %L"
          cadr(parseString(car(via->startEnd) "/"))
          sNet
          via->xy
        )
        unless( bIgnore 
          when( onep(length(axlDBGetConnect( via t )))
            unless( via->testPoint || rexMatchp("_VOID$" via->name )
              lDanglingVia = cons( sVia lDanglingVia )
            )
          )
          when( zerop(length(axlDBGetConnect( via t )))
             lDanglingVia = cons( sVia lDanglingVia )
          ); end when
        ); end unless bIgnore
      ); end unless
    )
    lDanglingVia = reverse(sort(lDanglingVia nil))
    foreach( shape axlDBGetShapes("etch")
      when( length(axlDBGetConnect(shape t))<2
        unless( shape->symbolEtch
          sNet = "Dummy"
          when( shape->net && shape->net->name != ""
            sNet = shape->net->name
          )
          sShape = sprintf(nil "%s, %s, %L"
              cadr(parseString(shape->layer "/"))
              sNet
              car(car(shape->segments)->startEnd)
            )
          lIslandShape = cons( sShape lIslandShape )
        ); end unless
      ); end when
    )
    foreach(net axlDBGetDesign()->nets
      when( net->nBranches > 1
        foreach( branch cdr(net->branches)
          foreach( obj branch->children
            when( obj->objType == "shape"
              sShape = sprintf(nil "%s, %s, %L"
                  cadr(parseString(obj->layer "/"))
                  net->name
                  car(car(obj->segments)->startEnd)
                )
              unless( member( sShape lIslandShape )
                lIslandShape = cons( sShape lIslandShape )
              )
            )
          ); end obj
        ); end branch
      ); end when
    ); end foreach
 
    lIslandShape = reverse(sort(lIslandShape nil))
    list(lDanglingLine lDanglingVia lIslandShape)
  ); end let
); end ps_ddoCheck
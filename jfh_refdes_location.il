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
                            l_l_id_LineSegments = cons( l_id_child l_l_id_LineSegments )
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
                           
                           ;axlMsgPut("2")
                           ptReference = round(xCoord(ptUpRight)+1):round(yCoord(ptLowLeft)+1)
                           
                           ;axlMsgPut("3")
                           dbRefdes = jfhGetRefdesDBid(sym)
                           
                           bBoxRefdes = dbRefdes->bBox
                          
                          ;axlMsgPut("4")                            
                           ptOffset = 0:round(yCoord(nthelem(2 bBoxRefdes)) - yCoord(nthelem(1 bBoxRefdes)) + 1)
                           
                           ptRefdesPositionNew = (xCoord(ptReference) - xCoord(ptOffset)):(yCoord(ptReference) - yCoord(ptOffset))
                           
                           jfhDBCreateRefdes(dbRefdes ptRefdesPositionNew)
                        
                        else;a component is 0 degree
                        
                           bBoxComp = jfhGetCompShadow(sym)
                           ptLowLeft = nthelem(1 bBoxComp)
                           ptUpRight = nthelem(2 bBoxComp)
                           
                           ptReference = ptLowLeft
                           
                           dbRefdes = jfhGetRefdesDBid(sym)
                           
                           bBoxRefdes = dbRefdes->bBox
                           
                          ; axlMsgPut("5")
                           ptOffset = round(xCoord(nthelem(2 bBoxRefdes)) - xCoord(nthelem(1 bBoxRefdes)) + 1):0
                           
                           ptRefdesPositionNew = (xCoord(ptReference) - xCoord(ptOffset)):(yCoord(ptReference) - yCoord(ptOffset))
                           
                           jfhDBCreateRefdes(dbRefdes ptRefdesPositionNew)
                        
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
                           
                           ;axlMsgPut("2")
                           ;ptReference = round(xCoord(ptLowLeft)+1):round(yCoord(ptLowLeft)+1)
                           ptReference = ptLowLeft
                           
                           ;axlMsgPut("3")
                           dbRefdes = jfhGetRefdesDBid(sym)
                           
                           bBoxRefdes = dbRefdes->bBox
                          
                          ;axlMsgPut("4")                            
                           ptOffset = 0:round(yCoord(nthelem(2 bBoxRefdes)) - yCoord(nthelem(1 bBoxRefdes)) + 1)
                           
                           ptRefdesPositionNew = (xCoord(ptReference) - xCoord(ptOffset)):(yCoord(ptReference) - yCoord(ptOffset))
                           
                           jfhDBCreateRefdes(dbRefdes ptRefdesPositionNew)
                        
                        else;a component is 0 degree
                        
                           bBoxComp = jfhGetCompShadow(sym)
                           ptLowLeft = nthelem(1 bBoxComp)
                           ptUpRight = nthelem(2 bBoxComp)
                           
                           ptReference = ptLowLeft
                           
                           dbRefdes = jfhGetRefdesDBid(sym)
                           
                           bBoxRefdes = dbRefdes->bBox
                           
                          ; axlMsgPut("5")
                           ptOffset = 2:0
                           
                           ptRefdesPositionNew = (xCoord(ptReference) - xCoord(ptOffset)):(yCoord(ptReference) - yCoord(ptOffset))
                           
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


           g_l_dbAllComps = nil
           g_l_dbTopComps = nil
           g_l_dbBtmComps = nil


           if(axlOKToProceed() != t 
              then
                 axlMsgPut("Finish current command first")
                 ;return(nil)
              else
                 if(axlUIYesNo("Is your board a new designed one?") != t
                    then
                       axlMsgPut("This program only fits new designed board!")
                    else
                 
                      ;jfhCreateMacroFile()
                      ;axlShell("replay txtsize3.scr");set block 3 text size
                      ;axlMsgPut("Macro OK!")                 
                      ;axlShell("rm txtsize3.scr")
                      
                      g_db_TxtBlockParam = axlGetParam("paramTextBlock:3")
                      g_db_TxtBlockParam->width = 30
                      g_db_TxtBlockParam->photoWidth = 6
                      g_db_TxtBlockParam->lineSpace = 0
                      g_db_TxtBlockParam->height = 30
                      g_db_TxtBlockParam->charSpace = 0
                      axlSetParam(g_db_TxtBlockParam)
                      
                      
                      
                      jfhGetAllCompsDBid();fill globe list g_l_dbAllComps with ids of all the components
                      jfhChgAllRefdesTxtBlock( g_l_dbAllComps )
                      
                      axlMsgPut("change text block size OK!")
                      
                      jfhSplitComps(g_l_dbAllComps)
                      
                      jfhPlaceTopRefdes(g_l_dbTopComps)
                      axlMsgPut("Top side complete!")
                      
                      jfhPlaceBtmRefdes(g_l_dbBtmComps)
                      axlMsgPut("Bottom side complete!")
                      
                      ;axlSetFindFilter(?enabled list("noall" "Symbols") ?onButtons list("noall" "Symbols"))
                      axlClearSelSet()
                      
                      ;jfhGetAllCompsDBid()
                      ;axlDehighlightObject(g_l_dbAllComps)
                      axlMsgPut("Placing refdes function complete!")
                      axlMsgPut("Version 1.0")
                 
                  );end of if(axlUIYesNo("Is your board a new one?")
              );end of if(axlOKToProceed() != t 
           
         );end of procedure( jfhRefdesLocate()
         
         
axlCmdRegister( "ch_refdeslocate" 'jfhRefdesLocate)

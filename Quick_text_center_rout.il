/* 
├─ 
│ ├─        程序名称：Quick_text_center_rout.il
│ ├─        程序功能：快速切换层面显示，方便设计
│ ├─        创建时间：2013年12月11日 
│ ├─        作    者：kevin wong
│ ├─        Q      Q：263350809
├─ 




*/

; axlCmdRegister( "text_center_rout" `text_center_rout)
; load("Quick_text_center_rout.il")



axlVisibleDesign(nil)
axlVisibleLayer( "BOARD GEOMETRY/OUTLINE" t )
axlVisibleLayer( "PIN/TOP" t )
axlVisibleLayer( "PIN/BOTTOM" t )
axlVisibleLayer( "REF DES/SILKSCREEN_TOP" t )
axlVisibleLayer( "REF DES/SILKSCREEN_BOTTOM" t )
; axlVisibleLayer( "COMPONENT VALUE/SILKSCREEN_TOP" t )
; axlVisibleLayer( "COMPONENT VALUE/SILKSCREEN_BOTTOM" t )
axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_TOP" t )
axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" t )




;---Function jfhGetRefIDComDir() will get standard information which is need to rotate the REF
;---Include top side components direction (l_nTopCompDir),
;---bottom side components direction (l_nBtmCompDir),
;---top side components' REFDES DBID list(l_dbTopRefDbid),
;---bottom side components' REFDES DBID list(l_dbBtmRefDbid),






procedure( jfhGetRefIDComDir()
           dbCurrentDesignn = axlDBGetDesign()
           J_dbAllSyms = dbCurrentDesignn->symbols

;---fill l_nTopCompDir and l_nBtmCompDir with components' direction


           foreach(symb J_dbAllSyms
               if(stringp(symb->refdes);if read something unknown,skip the following steps    
                 then
                   if(symb->isMirrored != t ;on top side

                   then
                        l_nTopCompDir = cons(round(symb->rotation) l_nTopCompDir)
                        l_dbAttachedTxt = axlDBGetAttachedText(symb)

                        foreach(txt l_dbAttachedTxt

                                if(txt->layer == "COMPONENT VALUE/SILKSCREEN_TOP"
                                then
                                   l_dbTopRefDbid = cons(txt l_dbTopRefDbid)
                                );end of if (txt->layer != "COMPONENT VALUE/SILKSCREEN_TOP"
                        );end of foreach(txt l_dbAttachedTxt

                   else
                        l_nBtmCompDir = cons(round(symb->rotation) l_nBtmCompDir)
                        l_dbAttachedTxt = axlDBGetAttachedText(symb)

                        foreach(txt l_dbAttachedTxt

                                if(txt->layer == "COMPONENT VALUE/SILKSCREEN_BOTTOM"
                                then
                                   l_dbBtmRefDbid = cons(txt l_dbBtmRefDbid)
                                );end of if(txt->layer == "COMPONENT VALUE/SILKSCREEN_BOTTOM"
                        );end of foreach(txt l_dbAttachedTxt

                   );end of if (symb->isMirrored != t ;on top side
                 else

               );end of if(stringp(symb->refdes)

           );end of foreach(symb l_dbAllSyms

);end of procedure( jfhGetRefIDComDir()







;------------------------------------------------------
;----------Rotate Refdes on Top side----------------------
;------------------------------------------------------
;---local variable ll_dbTopRef and ll_fTopComDir
;---the index "ll_" means list local



procedure( jfhRotateTopRef(ll_dbTopRef ll_nTopComDir)
p = outfile("out.txt")
          foreach((dbTopRef nTopComDir) ll_dbTopRef ll_nTopComDir

                 ;get information no need to modify
                 sRefContent = dbTopRef->text
                 dbParent = dbTopRef->parent
                 xy = dbTopRef->parent->xy
                 sRefLayer = dbTopRef->layer
                 bMirror = dbTopRef->isMirrored
                 sJustify = dbTopRef->justify
                 sTxtBlock = dbTopRef->textBlock
                 ;nRefOri = round(dbTopRef->rotation)
	nTopComDir = round(dbParent->rotation)
                 ;if components' direction is not 90 and 270 degree,its REF degree is 0,otherwise is 90
                 ;and if the original refdes's direction is right,skip it
                 ;if(nRefOri != 90 && nRefOri != 0
                   ;then
                     if((nTopComDir > 75 && nTopComDir < 105) || (nTopComDir > 255 && nTopComDir < 285)
                     then
                        nRefDir = 90
                        ptRefxy = list(nth(0,xy)+10 nth(1,xy)-30)
                     else
                        nRefDir = 0
                        ptRefxy = list(nth(0,xy)-30 nth(1,xy)-10)

                     );end of if(nTopComDir > 85 && nTopComDir < 95 || nTopComDir > 265 && nTopComDir < 275

                   ;else
                    ; nRefDir = nRefOri
                 ;);end of if(nRefOri != 90 && nRefOri != 0

                 ;fill the text structure r_textOrientation
                 stTxtOri = make_axlTextOrientation(
                                 ?textBlock sTxtBlock
                                 ?rotation nRefDir
                                 ?mirrored bMirror
                                 ?justify sJustify
                            );end fill structure

                 isCreation = axlDBCreateText(
                            sRefContent
                            ptRefxy
                            stTxtOri
                            sRefLayer
                            dbParent
                            )

                 if( isCreation != nil axlDeleteObject( dbTopRef))

          );end of foreach((dbTopRef nTopComDir) ll_dbTopRef ll_nTopComDir
close(p)
);end of procedure( jfhRotateTopRef(ll_dbTopRef ll_nTopComDir)


;---------------------------------------------------------------------------
;----------Rotate Refdes on Btm side----------------------
;---------------------------------------------------------------------------


procedure( jfhRotateBtmRef(ll_dbBtmRef ll_nBtmComDir)
          foreach((dbBtmRef nBtmComDir) ll_dbBtmRef ll_nBtmComDir

                 ;get information no need to modify
                 sRefContent = dbBtmRef->text
                 dbParent = dbBtmRef->parent
                 xy = dbBtmRef->parent->xy
                 sRefLayer = dbBtmRef->layer
                 bMirror = dbBtmRef->isMirrored
                 sJustify = dbBtmRef->justify
                 sTxtBlock = dbBtmRef->textBlock
                 ;nRefOri = round(dbBtmRef->rotation)

	nBtmComDir = round(dbParent->rotation)
                 ;if components' direction is not 90 and 270 degree,its REF degree is 0,otherwise is 90
                 ;and if the original refdes's direction is right,skip it
                 ;if(nRefOri != 270 && nRefOri != 0
                   ;then
                     if(nBtmComDir > 85 && nBtmComDir < 95 || nBtmComDir > 265 && nBtmComDir < 275

                     then
                        nRefDir = 270
                        ptRefxy = list(nth(0,xy)-10 nth(1,xy)-30)
                     else
                        nRefDir = 0
                        ptRefxy = list(nth(0,xy)+30 nth(1,xy)-10)

                     );end of if(nBtmComDir > 85 && nBtmComDir < 95 || nBtmComDir > 265 && nBtmComDir < 275

                   ;else
                     ;nRefDir = nRefOri
                 ;);end of if(nRefOri != 270 && nRefOri != 0

                 ;fill the text structure r_textOrientation
                 stTxtOri = make_axlTextOrientation(
                                 ?textBlock sTxtBlock
                                 ?rotation nRefDir
                                 ?mirrored bMirror
                                 ?justify sJustify
                            );end fill structure

                 isCreation = axlDBCreateText(
                            sRefContent
                            ptRefxy
                            stTxtOri
                            sRefLayer
                            dbParent
                            )

                 if( isCreation != nil axlDeleteObject( dbBtmRef))

          );end of foreach((dbBtmRef nBtmComDir) ll_dbBtmRef ll_nBtmComDir

);end of procedure( jfhRotateTopRef(ll_dbBtmRef ll_nBtmComDir)


;------------------------------------------------------
;----------Rotate Refdes on Top side skip right--------
;------------------------------------------------------
;---local variable ll_dbTopRef and ll_fTopComDir
;---the index "ll_" means list local



procedure( jfhRotateTopRefIr(ll_dbTopRef ll_nTopComDir)
          foreach((dbTopRef nTopComDir) ll_dbTopRef ll_nTopComDir

                 ;get information no need to modify
                 sRefContent = dbTopRef->text
                 dbParent = dbTopRef->parent
                 ptRefxy = dbTopRef->parent->xy
                 sRefLayer = dbTopRef->layer
                 bMirror = dbTopRef->isMirrored
                 sJustify = dbTopRef->justify
                 sTxtBlock = dbTopRef->textBlock
                 nRefOri = round(dbTopRef->rotation)

                 ;if components' direction is not 90 and 270 degree,its REF degree is 0,otherwise is 90
                 ;and if the original refdes's direction is right,skip it
                 if(nRefOri != 90 && nRefOri != 0
                   then

                     if(nTopComDir > 85 && nTopComDir < 95 || nTopComDir > 265 && nTopComDir < 275

                     then
                        nRefDir = 90

                     else
                        nRefDir = 0

                     );end of if(nTopComDir > 85 && nTopComDir < 95 || nTopComDir > 265 && nTopComDir < 275

                   else
                     nRefDir = nRefOri
                 );end of if(nRefOri != 90 && nRefOri != 0

                 ;fill the text structure r_textOrientation
                 stTxtOri = make_axlTextOrientation(
                                 ?textBlock sTxtBlock
                                 ?rotation nRefDir
                                 ?mirrored bMirror
                                 ?justify sJustify
                            );end fill structure

                 isCreation = axlDBCreateText(
                            sRefContent
                            ptRefxy
                            stTxtOri
                            sRefLayer
                            dbParent
                            )

                 if( isCreation != nil axlDeleteObject( dbTopRef))

          );end of foreach((dbTopRef nTopComDir) ll_dbTopRef ll_nTopComDir

);end of procedure( jfhRotateTopRefIr(ll_dbTopRef ll_nTopComDir)


;---------------------------------------------------------------------------
;----------Rotate REF on Btm side skip right----------------------
;---------------------------------------------------------------------------


procedure( jfhRotateBtmRefIr(ll_dbBtmRef ll_nBtmComDir)
          foreach((dbBtmRef nBtmComDir) ll_dbBtmRef ll_nBtmComDir

                 ;get information no need to modify
                 sRefContent = dbBtmRef->text
                 dbParent = dbBtmRef->parent
                 ptRefxy = dbBtmRef->parent->xy
                 sRefLayer = dbBtmRef->layer
                 bMirror = dbBtmRef->isMirrored
                 sJustify = dbBtmRef->justify
                 sTxtBlock = dbBtmRef->textBlock
                 nRefOri = round(dbBtmRef->rotation)

                 ;if components' direction is not 90 and 270 degree,its REF degree is 0,otherwise is 90
                 ;and if the original refdes's direction is right,skip it
                 if(nRefOri != 270 && nRefOri != 0
                   then
                     if(nBtmComDir > 85 && nBtmComDir < 95 || nBtmComDir > 265 && nBtmComDir < 275

                     then
                        nRefDir = 270
                     else
                        nRefDir = 0

                     );end of if(nBtmComDir > 85 && nBtmComDir < 95 || nBtmComDir > 265 && nBtmComDir < 275

                   else
                     nRefDir = nRefOri
                 );end of if(nRefOri != 270 && nRefOri != 0

                 ;fill the text structure r_textOrientation
                 stTxtOri = make_axlTextOrientation(
                                 ?textBlock sTxtBlock
                                 ?rotation nRefDir
                                 ?mirrored bMirror
                                 ?justify sJustify
                            );end fill structure

                 isCreation = axlDBCreateText(
                            sRefContent
                            ptRefxy
                            stTxtOri
                            sRefLayer
                            dbParent
                            )

                 if( isCreation != nil axlDeleteObject( dbBtmRef))

          );end of foreach((dbBtmRef nBtmComDir) ll_dbBtmRef ll_nBtmComDir

);end of procedure( jfhRotateTopRefIr(ll_dbBtmRef ll_nBtmComDir)


;--------Registe Commands--------------------------------------------------------------


axlCmdRegister("val_c" 'ref)
axlCmdRegister("val_o" 'jfhrotaterefIr)

;---command for rotate all refdes---
procedure(ref()

   l_nTopCompDir = nil
   l_nBtmCompDir = nil
   l_dbTopRefDbid = nil
   l_dbBtmRefDbid = nil

   if(axlOKToProceed() != t
        then
            axlMsgPut("Finish current command first")
            ;return(nil)
        else
            jfhGetRefIDComDir()
            jfhRotateTopRef(l_dbTopRefDbid l_nTopCompDir)
            jfhRotateBtmRef(l_dbBtmRefDbid l_nBtmCompDir)
            axlMsgPut("OK")
   );if(axlOKToProceed() != t
)

;------command for rotate refdes which are at wrong direction---

procedure(jfhrotaterefIr()

   l_nTopCompDir = nil
   l_nBtmCompDir = nil
   l_dbTopRefDbid = nil
   l_dbBtmRefDbid = nil

   if(axlOKToProceed() != t
        then
            axlMsgPut("Finish current command first")
            ;return(nil)
        else
            jfhGetRefIDComDir()
            jfhRotateTopRefIr(l_dbTopRefDbid l_nTopCompDir)
            jfhRotateBtmRefIr(l_dbBtmRefDbid l_nBtmCompDir)
            axlMsgPut("OK")
   );if(axlOKToProceed() != t
)
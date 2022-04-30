;---rotate components' refdes to right direction---


;File name: jfh_refdes_rotate.il
;Revision:1.0
;date:2002-05-15
;Writen by: jingfenghua/24245





axlVisibleDesign(nil)
axlVisibleLayer( "BOARD GEOMETRY/OUTLINE" t )
axlVisibleLayer( "PIN/TOP" t )
axlVisibleLayer( "PIN/BOTTOM" t )
axlVisibleLayer( "REF DES/SILKSCREEN_TOP" t )
axlVisibleLayer( "REF DES/SILKSCREEN_BOTTOM" t )
axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_TOP" t )
axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" t )



;---Function jfhGetRefIDComDir() will get standard information which is need to rotate the REF
;---Include top side components direction (l_nTopCompDir),
;---bottom side components direction (l_nBtmCompDir),
;---top side components' REFDES DBID list(l_dbTopRefDbid),
;---bottom side components' REFDES DBID list(l_dbBtmRefDbid),






procedure( jfhGetRefIDComDir()
           dbCurrentDesign = axlDBGetDesign()
           l_dbAllSyms = dbCurrentDesign->symbols

;---fill l_nTopCompDir and l_nBtmCompDir with components' direction


           foreach(sym l_dbAllSyms
               if(stringp(sym->refdes);if read something unknown,skip the following steps
                 then
                   if(sym->isMirrored != t ;on top side

                   then
                        l_nTopCompDir = cons(round(sym->rotation) l_nTopCompDir)
                        l_dbAttachedTxt = axlDBGetAttachedText(sym)

                        foreach(txt l_dbAttachedTxt

                                if(txt->layer == "REF DES/SILKSCREEN_TOP"
                                then
                                   l_dbTopRefDbid = cons(txt l_dbTopRefDbid)
                                );end of if (txt->layer == "REF DES/SILKSCREEN_TOP"
                        );end of foreach(txt l_dbAttachedTxt

                   else
                        l_nBtmCompDir = cons(round(sym->rotation) l_nBtmCompDir)
                        l_dbAttachedTxt = axlDBGetAttachedText(sym)

                        foreach(txt l_dbAttachedTxt

                                if(txt->layer == "REF DES/SILKSCREEN_BOTTOM"
                                then
                                   l_dbBtmRefDbid = cons(txt l_dbBtmRefDbid)
                                );end of if(txt->layer == "REF DES/SILKSCREEN_BOTTOM"
                        );end of foreach(txt l_dbAttachedTxt

                   );end of if (sym->isMirrored != t ;on top side
                 else

               );end of if(stringp(sym->refdes)

           );end of foreach(sym l_dbAllSyms

);end of procedure( jfhGetRefIDComDir()







;------------------------------------------------------
;----------Rotate Refdes on Top side----------------------
;------------------------------------------------------
;---local variable ll_dbTopRef and ll_fTopComDir
;---the index "ll_" means list local



procedure( jfhRotateTopRef(ll_dbTopRef ll_nTopComDir)
          foreach((dbTopRef nTopComDir) ll_dbTopRef ll_nTopComDir

                 ;get information no need to modify
                 sRefContent = dbTopRef->text
                 dbParent = dbTopRef->parent
                 ptRefxy = dbTopRef->xy
                 sRefLayer = dbTopRef->layer
                 bMirror = dbTopRef->isMirrored
                 sJustify = dbTopRef->justify
                 sTxtBlock = dbTopRef->textBlock
                 ;nRefOri = round(dbTopRef->rotation)

                 ;if components' direction is not 90 and 270 degree,its REF degree is 0,otherwise is 90
                 ;and if the original refdes's direction is right,skip it
                 ;if(nRefOri != 90 && nRefOri != 0
                   ;then

                     if(nTopComDir > 85 && nTopComDir < 95 || nTopComDir > 265 && nTopComDir < 275

                     then
                        nRefDir = 90

                     else
                        nRefDir = 0

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

);end of procedure( jfhRotateTopRef(ll_dbTopRef ll_nTopComDir)


;---------------------------------------------------------------------------
;----------Rotate Refdes on Btm side----------------------
;---------------------------------------------------------------------------


procedure( jfhRotateBtmRef(ll_dbBtmRef ll_nBtmComDir)
          foreach((dbBtmRef nBtmComDir) ll_dbBtmRef ll_nBtmComDir

                 ;get information no need to modify
                 sRefContent = dbBtmRef->text
                 dbParent = dbBtmRef->parent
                 ptRefxy = dbBtmRef->xy
                 sRefLayer = dbBtmRef->layer
                 bMirror = dbBtmRef->isMirrored
                 sJustify = dbBtmRef->justify
                 sTxtBlock = dbBtmRef->textBlock
                 ;nRefOri = round(dbBtmRef->rotation)

                 ;if components' direction is not 90 and 270 degree,its REF degree is 0,otherwise is 90
                 ;and if the original refdes's direction is right,skip it
                 ;if(nRefOri != 270 && nRefOri != 0
                   ;then
                     if(nBtmComDir > 85 && nBtmComDir < 95 || nBtmComDir > 265 && nBtmComDir < 275

                     then
                        nRefDir = 270


                     else
                        nRefDir = 0

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
                 ptRefxy = dbTopRef->xy
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
                 ptRefxy = dbBtmRef->xy
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


axlCmdRegister("ch_ref" 'jfhrotateref)
axlCmdRegister("ch_refskip" 'jfhrotaterefIr)

;---command for rotate all refdes---
procedure(jfhrotateref()

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
;*****************************************************************************
/*
* Author:      Patrick DOS SANTOS
* =======      Senior Application Engineer MCM
*              Cadence Design Systems-France
*              patdoss cadence.com
*
* Date:        02/15/95
* File:        Mirror_Text.il
* Revision:    1.0
* Operates:    Allegro 8.x 10.x 11.x
*
* purpose:     Mirrored any Texts (Ref des, Test points....) 
*
*****************************************************************************
* Type in allegro.
* mirror_text "MANUFACTURING/PROBE_BOTTOM"
*/
;*****************************************************************************
 ; WARRANTY:
 ; NONE. NONE. NONE.
 ; Use all material in this code at your own risk.  Cadence Design Systems 
 ; makes no claims about any material in this archive.  These examples may
 ; not function or may only function in specific instances. We'd like to hear 
 ; what you think of our approach to this, and how we can improve it.
;*****************************************************************************

axlCmdRegister("mirror_text" 'Mirror_Test_Point ?cmdType "general")
 
; Global variables
; ----------------
 
;=========================================================
;=============== COMMAND INITIALIZATION ==================
;=========================================================
 
;*******************************
(defun Mirror_Test_Point ( Text_Layer )
;*******************************
(let (element_dbid_list) 

 if( axlOKToProceed() then
 
  element_dbid_list = nil 

    axlClearSelSet() 
    axlSetFindFilter( ?enabled (list "noall" "invisible" "text")
                      ?onButtons (list "text")
                    )
       element_dbid_list = axlGetSelSet( axlAddSelectAll() )

       if( length( element_dbid_list ) != 0 then
         Mirror_Processing( element_dbid_list Text_Layer )
       );end-if 

    ;***** Clean and refresh
      axlClearSelSet()
      axlFlushDisplay()
      axlMsgPut("End.")
 
  else
   printf("E- Please terminate your interactive command .\n")
  );end-if
 
 );end-let
);end_defun
 
;*******************************
(defun  Mirror_Processing ( element_dbid_list Text_Layer )
;*******************************
(let ( element_dbid xy text textBlock rotation parent_dbid isMirrored justify
       orientation_text status mirror_status) 

   foreach( element_dbid element_dbid_list
     if( element_dbid->objType == "text" &&
         element_dbid->layer   == Text_Layer 
        then 
        ;#### I need first to save the text parameters ####
         xy          = element_dbid->xy
         text        = element_dbid->text
         textBlock   = element_dbid->textBlock   
         rotation    = element_dbid->rotation
         parent_dbid = element_dbid->parent
         isMirrored  = element_dbid->isMirrored    ; t/nil 
         justify     = element_dbid->justify       ; "LEFT" "CENTER" "RIGHT"

         if( isMirrored == nil then mirror_status = t else mirror_status nil)
         if( justify == "LEFT"   then justify = "RIGHT")
         if( justify == "RIGHT"  then justify = "LEFT") 

             orientation_text = make_axlTextOrientation(
                                ?textBlock textBlock,
                                ?rotation  rotation,
                                ?mirrored  mirror_status,
                                ?justify   justify 
                                )

             status= axlDBCreateText( 
                                text                    
                                xy
                                orientation_text 
                                element_dbid->layer
                                parent_dbid
                                ) 
            if( status != nil then
              axlDeleteObject( list( element_dbid ))
            );end-if

     );end-if
   );end-foreach


 );end-let
);end_defun


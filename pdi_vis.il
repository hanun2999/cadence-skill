;===============================================================================;
;	pdi_vis.il - Display Visibility Control V2.1 for Allegro v11.0+		;
;-------------------------------------------------------------------------------;
; Install the routine in your allegro.ilinit file by adding load("pdi_vis.il")	;
; or by typing (load("pdi_vis.il")) at the Allegro prompt.			;
;										;
; Start the routine by typing 'etch visibility' at the Allegro prompt. 		;
;										;
; See the help button for credits and questions.				;
;-------------------------------------------------------------------------------;
;                              Modification History                             ;
;										;
; Ver 1.0	Released					09MAY96 - GHP	;
;										;
; Ver 2.0	Added "Plot" button to generate an IPF file			;
;		of the screen and call "allegro_plot" to			;
;		generate a plot.				20MAY96 - GHP	;
;
; Ver 2.1	Added DRC button				03JUN96 - GHP
;										;
;===============================================================================;
axlCmdRegister( "visibility" `pdiVisibility)

;===============================================;
;						;
; Main Routine - Called when program is started ;
;						;
;===============================================;
(defun pdiVisibility ()
  Pin_Control_Value=nil
  Via_Control_Value=nil
  Etch_Control_Value=nil
  DRC_Control_Value=nil
  TAssyControl_Value=nil
  BAssyControl_Value=nil
  TSilkControl_Value=nil
  BSilkControl_Value=nil
  TMaskControl_Value=nil
  BMaskControl_Value=nil
  TPasteControl_Value=nil
  BPasteControl_Value=nil
  TPgridControl_Value=nil
  BPgridControl_Value=nil
  KOControl_Value=nil
  EtchKO_Control_Value=nil
  Etch_Layers=(axlGetParam("paramLayerGroup:ETCH")->groupMembers)
  (foreach Layer Etch_Layers
    set(concat(Layer "_Control_Value") nil)
  ); end foreach Layer Etch_Layers
  (pdiVisForm)
  Form=axlFormCreate( (gensym) "pdiVis.form" '(e outer) 'pdiAction t)
  (axlFormDisplay Form)
); end defun pdiVisibility
 
;===============================================;
;						;
; Create the form file				;
;						;
;===============================================;
(defun pdiVisForm ()
  Num_Lay=0
  (foreach Item Etch_Layers
    Num_Lay=Num_Lay + 1
  ); end foreach Item Etch_Layers
  Port_Size=Num_Lay + 15
  Visibility_Control_Form=outfile("pdiVis.form" "w")
  (fprintf Visibility_Control_Form "FILE_TYPE=FORM_DEFN VERSION=2\n")
  (fprintf Visibility_Control_Form "FORM\n")
  (fprintf Visibility_Control_Form "FIXED\n")
  (fprintf Visibility_Control_Form "PORT 22 %d\n" Port_Size)
  (fprintf Visibility_Control_Form "HEADER \"Visibility\"\n")
  (fprintf Visibility_Control_Form "TILE\n")
  ;------------------------------;
  ; Set the Features Group       ;
  ;------------------------------;
  (fprintf Visibility_Control_Form "GROUP \"Etch Features\"\n")
  (fprintf Visibility_Control_Form "GLOC 1 1\n")
  (fprintf Visibility_Control_Form "GSIZE 20 6\n")
  (fprintf Visibility_Control_Form "ENDGROUP\n")
  ;------------------------------;
  ; Set the "P" toggle button    ;
  ;------------------------------;
  (fprintf Visibility_Control_Form "FIELD Pin_Control\n")
  (fprintf Visibility_Control_Form "FLOC 2 3\n")
  (fprintf Visibility_Control_Form "FGROUP \"Etch Features\"\n")
  (fprintf Visibility_Control_Form "CHECKLIST \"P\"\n")
  (fprintf Visibility_Control_Form "ENDFIELD\n")
  ;------------------------------;
  ; Set the "V" toggle button    ;
  ;------------------------------; 
  (fprintf Visibility_Control_Form "FIELD Via_Control\n")
  (fprintf Visibility_Control_Form "FLOC 8 3\n")
  (fprintf Visibility_Control_Form "FGROUP \"Etch Features\"\n")
  (fprintf Visibility_Control_Form "CHECKLIST \"V\"\n")
  (fprintf Visibility_Control_Form "ENDFIELD\n")
  ;------------------------------;
  ; Set the "E" toggle button    ;
  ;------------------------------; 
  (fprintf Visibility_Control_Form "FIELD Etch_Control\n")
  (fprintf Visibility_Control_Form "FLOC 14 3\n")
  (fprintf Visibility_Control_Form "FGROUP \"Etch Features\"\n")
  (fprintf Visibility_Control_Form "CHECKLIST \"E\"\n")
  (fprintf Visibility_Control_Form "ENDFIELD\n")
  ;------------------------------;
  ; Set the Keep-Out/In Button   ;
  ;------------------------------;
  (fprintf Visibility_Control_Form "FIELD EtchKO_Control\n")
  (fprintf Visibility_Control_Form "FLOC 4 5\n")
  (fprintf Visibility_Control_Form "CHECKLIST \"KO\"\n")
  (fprintf Visibility_Control_Form "ENDFIELD\n")
  ;------------------------------;
  ; Set the DRC Button		 ;
  ;------------------------------;
  (fprintf Visibility_Control_Form "FIELD DRC_Control\n")
  (fprintf Visibility_Control_Form "FLOC 11 5\n")   
  (fprintf Visibility_Control_Form "CHECKLIST \"DRC\"\n")
  (fprintf Visibility_Control_Form "ENDFIELD\n")  
  ;------------------------------;
  ; Set the Layers Group         ;
  ;------------------------------;
  (fprintf Visibility_Control_Form "GROUP \"Etch Layers\"\n")
  (fprintf Visibility_Control_Form "GLOC 1 7\n")
  (fprintf Visibility_Control_Form "GSIZE 20 %d\n" Num_Lay * 2 + 2 )
  (fprintf Visibility_Control_Form "ENDGROUP\n")
  ;-------------------------------; 
  ; Set the layer toggle buttons  ; 
  ;-------------------------------;
  Text_Loc=9
  (foreach Item Etch_Layers
    (fprintf Visibility_Control_Form "TEXT \"%s\"\n" Item)
    (fprintf Visibility_Control_Form "TLOC 5 %d\n" Text_Loc)
    (fprintf Visibility_Control_Form "ENDTEXT\n")
    (fprintf Visibility_Control_Form "FIELD %s_Control\n" Item)
    (fprintf Visibility_Control_Form "FLOC 2 %d\n" Text_Loc)
    (fprintf Visibility_Control_Form "CHECKLIST\n")
    (fprintf Visibility_Control_Form "ENDFIELD\n")
    Text_Loc=Text_Loc + 2
  ); end foreach Item Etch_Layers
  ;------------------------------;
  ; Set the Non-Etch Group       ;
  ;------------------------------;
  (fprintf Visibility_Control_Form "GROUP \"Non-Etch\"\n")
  (fprintf Visibility_Control_Form "GLOC 1 %d\n" Text_Loc)
  (fprintf Visibility_Control_Form "GSIZE 20 14\n")
  (fprintf Visibility_Control_Form "ENDGROUP\n")
  ;------------------------------; 
  ; Set the Assy Buttons         ; 
  ;------------------------------; 
  (fprintf Visibility_Control_Form "FIELD TAssyControl\n")
  (fprintf Visibility_Control_Form "FLOC 2 %d\n" Text_Loc + 2)
  (fprintf Visibility_Control_Form "CHECKLIST \"TAsy\"\n")
  (fprintf Visibility_Control_Form "ENDFIELD\n")
  (fprintf Visibility_Control_Form "FIELD BAssyControl\n")
  (fprintf Visibility_Control_Form "FLOC 12 %d\n" Text_Loc + 2)
  (fprintf Visibility_Control_Form "CHECKLIST \"BAsy\"\n")
  (fprintf Visibility_Control_Form "ENDFIELD\n")
  ;------------------------------; 
  ; Set the Silk Buttons         ; 
  ;------------------------------; 
  (fprintf Visibility_Control_Form "FIELD TSilkControl\n")
  (fprintf Visibility_Control_Form "FLOC 2 %d\n" Text_Loc + 4)
  (fprintf Visibility_Control_Form "CHECKLIST \"TSlk\"\n")
  (fprintf Visibility_Control_Form "ENDFIELD\n")
  (fprintf Visibility_Control_Form "FIELD BSilkControl\n")
  (fprintf Visibility_Control_Form "FLOC 12 %d\n" Text_Loc + 4)
  (fprintf Visibility_Control_Form "CHECKLIST \"BSlk\"\n")
  (fprintf Visibility_Control_Form "ENDFIELD\n")
  ;------------------------------;
  ; Set the Mask Buttons         ;
  ;------------------------------;
  (fprintf Visibility_Control_Form "FIELD TMaskControl\n")
  (fprintf Visibility_Control_Form "FLOC 2 %d\n" Text_Loc + 6)
  (fprintf Visibility_Control_Form "CHECKLIST \"TMsk\"\n")
  (fprintf Visibility_Control_Form "ENDFIELD\n")
  (fprintf Visibility_Control_Form "FIELD BMaskControl\n")
  (fprintf Visibility_Control_Form "FLOC 12 %d\n" Text_Loc + 6)
  (fprintf Visibility_Control_Form "CHECKLIST \"BMsk\"\n")
  (fprintf Visibility_Control_Form "ENDFIELD\n")
  ;------------------------------;
  ; Set the Paste Buttons        ;
  ;------------------------------;
  (fprintf Visibility_Control_Form "FIELD TPasteControl\n")
  (fprintf Visibility_Control_Form "FLOC 2 %d\n" Text_Loc + 8)
  (fprintf Visibility_Control_Form "CHECKLIST \"TPst\"\n")
  (fprintf Visibility_Control_Form "ENDFIELD\n")
  (fprintf Visibility_Control_Form "FIELD BPasteControl\n")
  (fprintf Visibility_Control_Form "FLOC 12 %d\n" Text_Loc + 8)
  (fprintf Visibility_Control_Form "CHECKLIST \"BPst\"\n")
  (fprintf Visibility_Control_Form "ENDFIELD\n")
  ;------------------------------;
  ; Set the Place Grid Buttons   ;
  ;------------------------------;
  (fprintf Visibility_Control_Form "FIELD TPgridControl\n")
  (fprintf Visibility_Control_Form "FLOC 2 %d\n" Text_Loc + 10)
  (fprintf Visibility_Control_Form "CHECKLIST \"TPgr\"\n")
  (fprintf Visibility_Control_Form "ENDFIELD\n")
  (fprintf Visibility_Control_Form "FIELD BPgridControl\n")
  (fprintf Visibility_Control_Form "FLOC 12 %d\n" Text_Loc + 10)
  (fprintf Visibility_Control_Form "CHECKLIST \"BPgr\"\n")
  (fprintf Visibility_Control_Form "ENDFIELD\n")
  ;------------------------------;
  ; Set the Keep-Out/In Button   ;
  ;------------------------------;
  (fprintf Visibility_Control_Form "FIELD KOControl\n")
  (fprintf Visibility_Control_Form "FLOC 2 %d\n" Text_Loc + 12)
  (fprintf Visibility_Control_Form "CHECKLIST \"Keep Out/In\"\n")
  (fprintf Visibility_Control_Form "ENDFIELD\n")
  ;------------------------------;
  ; Set the Action Buttons       ;
  ;------------------------------;
  (fprintf Visibility_Control_Form "FIELD Refresh_Graphics\n")
  (fprintf Visibility_Control_Form "FLOC 1 %d\n" Text_Loc + 15)
  (fprintf Visibility_Control_Form "MENUBUTTON \"Refresh\" 10 3\n")
  (fprintf Visibility_Control_Form "ENDFIELD\n")
  (fprintf Visibility_Control_Form "FIELD PlotScreen\n")
  (fprintf Visibility_Control_Form "FLOC 11 %d\n" Text_Loc + 15)
  (fprintf Visibility_Control_Form "MENUBUTTON \"Plot\" 10 3\n")
  (fprintf Visibility_Control_Form "ENDFIELD\n")
  (fprintf Visibility_Control_Form "FIELD Quit\n")
  (fprintf Visibility_Control_Form "FLOC 1 %d\n" Text_Loc + 18)
  (fprintf Visibility_Control_Form "MENUBUTTON \"Quit\" 10 3\n")
  (fprintf Visibility_Control_Form "ENDFIELD\n")
  (fprintf Visibility_Control_Form "FIELD Help\n")
  (fprintf Visibility_Control_Form "FLOC 11 %d\n" Text_Loc + 18)
  (fprintf Visibility_Control_Form "MENUBUTTON \"Help!\" 10 3\n")
  (fprintf Visibility_Control_Form "ENDFIELD\n")
  (fprintf Visibility_Control_Form "ENDTILE\n")
  (fprintf Visibility_Control_Form "ENDFORM\n")
  close(Visibility_Control_Form)
 ); end defun pdiVisForm
 
;===============================================;
;						;
; Define the action of the form buttons		;
;						;
;===============================================;
(defun pdiAction (Visibility_Control_Form)
  (case Visibility_Control_Form->curField
    ("Help"
      pdiVisHelp()
    ); end "Help"
    ("Quit"
      (axlFormClose Visibility_Control_Form)
      (axlCancelEnterFun)
      (if isFile("pdiVis.form") then deleteFile("pdiVis.form"))
      nil
    ); end "Quit"
    ("Refresh_Graphics"
      pdiVisUpdate()
      t
    ); end "Refresh_Graphics"
    ("PlotScreen"
      pdiPlotScreen()
      t
    ); end "Refresh_Graphics"
    ("Pin_Control"
      Pin_Control_Value=(Visibility_Control_Form->curValue)
      t
    ); end "Pin_Control"
    ("Via_Control"
      Via_Control_Value=(Visibility_Control_Form->curValue)
      t
    ); end "Via_Control"
    ("Etch_Control"
      Etch_Control_Value=(Visibility_Control_Form->curValue)
      t
    ); end "Etch_Control"
    ("EtchKO_Control"
      EtchKO_Control_Value=(Visibility_Control_Form->curValue)
      t
    ); end "EtchKO_Control"
    ("DRC_Control"
      DRC_Control_Value=(Visibility_Control_Form->curValue)
      t
    ); end "DRC_Control"
    ("TAssyControl"    
      TAssyControl_Value=(Visibility_Control_Form->curValue)
      t
    ); end "TAssyControl"
    ("BAssyControl"    
      BAssyControl_Value=(Visibility_Control_Form->curValue)
      t
    ); end "BAssyControl"
    ("TSilkControl"     
      TSilkControl_Value=(Visibility_Control_Form->curValue) 
      t 
    ); end "TSilkControl" 
    ("BSilkControl"     
      BSilkControl_Value=(Visibility_Control_Form->curValue) 
      t 
    ); end "BSilkControl" 
    ("TMaskControl"     
      TMaskControl_Value=(Visibility_Control_Form->curValue) 
      t 
    ); end "TMaskControl" 
    ("BMaskControl"     
      BMaskControl_Value=(Visibility_Control_Form->curValue) 
      t 
    ); end "BMaskControl" 
    ("TPasteControl"     
      TPasteControl_Value=(Visibility_Control_Form->curValue) 
      t 
    ); end "TPasteControl" 
    ("BPasteControl"     
      BPasteControl_Value=(Visibility_Control_Form->curValue) 
      t 
    ); end "BPasteControl" 
    ("TPgridControl"     
      TPgridControl_Value=(Visibility_Control_Form->curValue) 
      t 
    ); end "TPgridControl" 
    ("BPgridControl"     
      BPgridControl_Value=(Visibility_Control_Form->curValue) 
      t 
    ); end "BPgridControl" 
    ("KOControl"
      KOControl_Value=(Visibility_Control_Form->curValue)
      t  
    ); end "KOControl"
    ("LKOControl"
      LKOControl_Value=(Visibility_Control_Form->curValue)
      t  
    ); end "LKOControl"
  ); end case Visibility_Control_Form->curField
); end defun pdiAction

;===============================================;
;                                               ;
; Generate plot files and send them out.	;
;                                               ;
;===============================================;
(defun pdiPlotScreen ()
  (axlShell "create plot screen_plot" )
  (axlShell "run allegro_plot screen_plot" )
  (axlShell "shell rm screen_plot.{plt,ctl}" )
); end defun pdiPlotScreen

;===============================================;
;                                               ;
; Define the Help routine                       ;
;                                               ;
;===============================================;
(defun pdiVisHelp ()
  pdiHelpFile=outfile("pdiVis.help" "w")
    (fprintf pdiHelpFile "     /\\\n")
    (fprintf pdiHelpFile "    /\\/\\\n")
    (fprintf pdiHelpFile "   /\\/\\/\\\n")
    (fprintf pdiHelpFile "  /\\/\\/\\/\\\n")
    (fprintf pdiHelpFile "  ---------                Praegitzer Design, Inc.  -  The Fine Line in Design\n")
    (fprintf pdiHelpFile "==============================================================================\n")
    (fprintf pdiHelpFile "                   pdi_vis.il - Display Control Window V2.1\n")
    (fprintf pdiHelpFile "==============================================================================\n")
    (fprintf pdiHelpFile "This routine lets the user easily select what to see on the screen.  It will\n")
    (fprintf pdiHelpFile "selectively show pads, vias, etch, DRCs, and keepouts for any ETCH subclass \n")
    (fprintf pdiHelpFile "defined.  It will also show non-etch subclasses such as the top silkscreen\n")
    (fprintf pdiHelpFile "without being required to turn them all on individually.\n")
    (fprintf pdiHelpFile "==============================================================================\n")
    (fprintf pdiHelpFile "            Buttons in the 'Etch Features' and 'Etch Layers' boxes\n")
    (fprintf pdiHelpFile "------------------------------------------------------------------------------\n")
    (fprintf pdiHelpFile "When one of these buttons is pressed (darker than the background) with a layer\n")
    (fprintf pdiHelpFile "and 'Refresh' is pressed, the entities associated with the button will display\n")
    (fprintf pdiHelpFile "on the screen.  The 'P' button is for pads, the 'V' button is for vias, the\n")
    (fprintf pdiHelpFile "'E' button is for etch, the 'KO' button is for Keepout and Keepin areas, the\n")
    (fprintf pdiHelpFile "'DRC' button is for the DRC subclasses.  The 'Layers' box will have layers\n")
    (fprintf pdiHelpFile "currently defined shown, unless the form was showing when layers were added.\n")
    (fprintf pdiHelpFile "If this is the case, quitting then restarting will show the new layers.\n")
    (fprintf pdiHelpFile "==============================================================================\n")
    (fprintf pdiHelpFile "                         Buttons in the 'Non-Etch' box\n")
    (fprintf pdiHelpFile "------------------------------------------------------------------------------\n")
    (fprintf pdiHelpFile "These are other entities that are useful to turn on and off during design.\n")
    (fprintf pdiHelpFile "When one of these buttons are pressed the selected layers will be displayed\n")
    (fprintf pdiHelpFile "after 'Refresh' is pressed.\n")
    (fprintf pdiHelpFile "   'TAsy' is top assembly         'BAsy' is bottom assembly\n")
    (fprintf pdiHelpFile "   'TSlk' is top silkscreen       'BSlk' is bottom silkscreen\n")
    (fprintf pdiHelpFile "   'TMsk' is top soldermask       'BMsk' is bottom soldermask\n")
    (fprintf pdiHelpFile "   'TPst' is top solderpaste      'BPst' is bottom solderpaste\n")
    (fprintf pdiHelpFile "   'TPgr' is top place grid       'BPgr' is bottom place grid\n")
    (fprintf pdiHelpFile "Press 'Plot' to generate a pen plot of the screen.  Exit by pressing 'Quit.'\n")
    (fprintf pdiHelpFile "This closes and deletes the form, but DOES NOT refresh the screen.\n")
    (fprintf pdiHelpFile "==============================================================================\n")
    (fprintf pdiHelpFile "This program was adapted from a routine originally written by:\n")
    (fprintf pdiHelpFile "                    David J. Scheuring\n")
    (fprintf pdiHelpFile "                    Sr. Applications Eng.\n")
    (fprintf pdiHelpFile "                    Cadence Design Systems\n")
    (fprintf pdiHelpFile "                    Dec. 8, 1994\n")
    (fprintf pdiHelpFile "------------------------------------------------------------------------------\n")
    (fprintf pdiHelpFile "Modifications to add non etch layers and re-format the form were written by:\n")
    (fprintf pdiHelpFile "                    George H. Patrick III\n")
    (fprintf pdiHelpFile "                    Sr. PCB Designer\n")
    (fprintf pdiHelpFile "                    Praegitzer Design, Inc.\n")
    (fprintf pdiHelpFile "                    George.Patrick@pii.com\n")
    (fprintf pdiHelpFile "                    gpatrick@aracnet.com\n")
    (fprintf pdiHelpFile "                    03JUN96\n")
    (fprintf pdiHelpFile "==============================================================================\n")
    (fprintf pdiHelpFile "NOTE:  This has been tested extensively in version 11 of Allegro.  Although \n")   
    (fprintf pdiHelpFile "       it may work under other versions it was not written for compatability.\n") 
    (fprintf pdiHelpFile "       No responsibility is assumed by Praegitzer Design, it's owners, it's\n") 
    (fprintf pdiHelpFile "       employees, or the writer for any problems introduced by use of this\n") 
    (fprintf pdiHelpFile "       program.\n") 
    (fprintf pdiHelpFile "==============================================================================\n")
    (fprintf pdiHelpFile "              Comments and suggestions are always encouraged ;->\n")
  close(pdiHelpFile)
  axlUIViewFileCreate( "pdiVis.help" "Visibility - Help" nil)
  deleteFile( "pdiVis.help" )
) ; end defun pdiVisHelp
 
;===============================================;
;						; 
; Define the Update routine			;
;						;
;===============================================;
(defun pdiVisUpdate ()
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:PACKAGE KEEPIN/paramLayer:ALL" ))
    (Going_On->visible=t)
    axlSetParam(Going_On)
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:PACKAGE KEEPIN/paramLayer:ALL" ))
    (Going_Off->visible=nil)
    axlSetParam(Going_Off)
  ;------------------------------;
  ; Look at the "TAsy" button    ;
  ;------------------------------;
  (if TAssyControl_Value == t then
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:PACKAGE GEOMETRY/paramLayer:ASSEMBLY_TOP"))
    (Going_On->visible=t)
    axlSetParam(Going_On)
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:REF DES/paramLayer:ASSEMBLY_TOP")) 
    (Going_On->visible=t) 
    axlSetParam(Going_On) 
  else
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:PACKAGE GEOMETRY/paramLayer:ASSEMBLY_TOP")) 
    (Going_Off->visible=nil) 
    axlSetParam(Going_Off) 
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:REF DES/paramLayer:ASSEMBLY_TOP"))  
    (Going_Off->visible=nil)  
    axlSetParam(Going_Off)
  ); end TAssyControl_Value == t
  ;------------------------------;
  ; Look at the "BAsy" button    ;
  ;------------------------------;
  (if BAssyControl_Value == t then
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:PACKAGE GEOMETRY/paramLayer:ASSEMBLY_BOTTOM")) 
    (Going_On->visible=t) 
    axlSetParam(Going_On) 
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:REF DES/paramLayer:ASSEMBLY_BOTTOM")) 
    (Going_On->visible=t) 
    axlSetParam(Going_On) 
  else   
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:PACKAGE GEOMETRY/paramLayer:ASSEMBLY_BOTTOM"))  
    (Going_Off->visible=nil)  
    axlSetParam(Going_Off)   
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:REF DES/paramLayer:ASSEMBLY_BOTTOM"))  
    (Going_Off->visible=nil)  
    axlSetParam(Going_Off)
  ); end BAssyControl_Value == t 
  ;------------------------------;
  ; Look at the "TSlk" button    ;
  ;------------------------------;
  (if TSilkControl_Value == t then
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:BOARD GEOMETRY/paramLayer:SILKSCREEN_TOP")) 
    (Going_On->visible=t) 
    axlSetParam(Going_On) 
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:PACKAGE GEOMETRY/paramLayer:SILKSCREEN_TOP")) 
    (Going_On->visible=t) 
    axlSetParam(Going_On) 
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:REF DES/paramLayer:SILKSCREEN_TOP")) 
    (Going_On->visible=t) 
    axlSetParam(Going_On) 
  else   
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:BOARD GEOMETRY/paramLayer:SILKSCREEN_TOP"))  
    (Going_Off->visible=nil)  
    axlSetParam(Going_Off)   
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:PACKAGE GEOMETRY/paramLayer:SILKSCREEN_TOP"))  
    (Going_Off->visible=nil)  
    axlSetParam(Going_Off)   
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:REF DES/paramLayer:SILKSCREEN_TOP"))  
    (Going_Off->visible=nil)  
    axlSetParam(Going_Off)
  ); end TSilkControl_Value == t 
  ;------------------------------;
  ; Look at the "BSlk" button    ;
  ;------------------------------;
  (if BSilkControl_Value == t then
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:BOARD GEOMETRY/paramLayer:SILKSCREEN_BOTTOM")) 
    (Going_On->visible=t) 
    axlSetParam(Going_On) 
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:PACKAGE GEOMETRY/paramLayer:SILKSCREEN_BOTTOM")) 
    (Going_On->visible=t) 
    axlSetParam(Going_On) 
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:REF DES/paramLayer:SILKSCREEN_BOTTOM")) 
    (Going_On->visible=t) 
    axlSetParam(Going_On) 
  else   
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:BOARD GEOMETRY/paramLayer:SILKSCREEN_BOTTOM"))  
    (Going_Off->visible=nil)  
    axlSetParam(Going_Off)   
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:PACKAGE GEOMETRY/paramLayer:SILKSCREEN_BOTTOM"))  
    (Going_Off->visible=nil)  
    axlSetParam(Going_Off)   
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:REF DES/paramLayer:SILKSCREEN_BOTTOM"))  
    (Going_Off->visible=nil)  
    axlSetParam(Going_Off)
  ); end BSilkControl_Value == t 
  ;------------------------------;
  ; Look at the "TMsk" button    ;
  ;------------------------------;
  (if TMaskControl_Value == t then
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:BOARD GEOMETRY/paramLayer:SOLDERMASK_TOP"))
    (Going_On->visible=t)                                                                                    
    axlSetParam(Going_On)
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:PACKAGE GEOMETRY/paramLayer:SOLDERMASK_TOP"))
    (Going_On->visible=t)
    axlSetParam(Going_On)
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:PIN/paramLayer:SOLDERMASK_TOP"))
    (Going_On->visible=t)
    axlSetParam(Going_On)
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:VIA CLASS/paramLayer:SOLDERMASK_TOP"))
    (Going_On->visible=t)
    axlSetParam(Going_On)
  else
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:BOARD GEOMETRY/paramLayer:SOLDERMASK_TOP"))
    (Going_Off->visible=nil)
    axlSetParam(Going_Off)
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:PACKAGE GEOMETRY/paramLayer:SOLDERMASK_TOP"))
    (Going_Off->visible=nil)
    axlSetParam(Going_Off)
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:PIN/paramLayer:SOLDERMASK_TOP"))
    (Going_Off->visible=nil)
    axlSetParam(Going_Off)
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:VIA CLASS/paramLayer:SOLDERMASK_TOP"))
    (Going_Off->visible=nil)                                                                                 
    axlSetParam(Going_Off)
  ); end TMaskControl_Value == t 
  ;------------------------------;
  ; Look at the "BMsk" buttonn   ;
  ;------------------------------;
  (if BMaskControl_Value == t then
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:BOARD GEOMETRY/paramLayer:SOLDERMASK_BOTTOM"))
    (Going_On->visible=t)                                                                                    
    axlSetParam(Going_On)
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:PACKAGE GEOMETRY/paramLayer:SOLDERMASK_BOTTOM"))
    (Going_On->visible=t)
    axlSetParam(Going_On)
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:PIN/paramLayer:SOLDERMASK_BOTTOM"))
    (Going_On->visible=t)
    axlSetParam(Going_On)
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:VIA CLASS/paramLayer:SOLDERMASK_BOTTOM")) 
    (Going_On->visible=t) 
    axlSetParam(Going_On) 
  else    
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:BOARD GEOMETRY/paramLayer:SOLDERMASK_BOTTOM"))
    (Going_Off->visible=nil)
    axlSetParam(Going_Off) 
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:PACKAGE GEOMETRY/paramLayer:SOLDERMASK_BOTTOM"))
    (Going_Off->visible=nil)
    axlSetParam(Going_Off) 
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:PIN/paramLayer:SOLDERMASK_BOTTOM"))
    (Going_Off->visible=nil)                                                                                 
    axlSetParam(Going_Off)                                                                                   
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:VIA CLASS/paramLayer:SOLDERMASK_BOTTOM")) 
    (Going_Off->visible=nil)                                                                                  
    axlSetParam(Going_Off) 
  ); end BMaskControl_Value == t 
  ;------------------------------;
  ; Look at the "TPst" button    ;
  ;------------------------------;
  (if TPasteControl_Value == t then
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:PIN/paramLayer:PASTEMASK_TOP"))
    (Going_On->visible=t)
    axlSetParam(Going_On)
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:VIA CLASS/paramLayer:PASTEMASK_TOP"))
    (Going_On->visible=t)
    axlSetParam(Going_On)
  else
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:PIN/paramLayer:PASTEMASK_TOP"))
    (Going_Off->visible=nil)
    axlSetParam(Going_Off)
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:VIA CLASS/paramLayer:PASTEMASK_TOP"))
    (Going_Off->visible=nil)
    axlSetParam(Going_Off)
  ); end TPasteControl_Value == t
  ;------------------------------;
  ; Look at the "BPst" button    ;
  ;------------------------------;
  (if BPasteControl_Value == t then
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:PIN/paramLayer:PASTEMASK_BOTTOM"))
    (Going_On->visible=t)
    axlSetParam(Going_On)
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:VIA CLASS/paramLayer:PASTEMASK_BOTTOM"))
    (Going_On->visible=t)
    axlSetParam(Going_On)
  else
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:PIN/paramLayer:PASTEMASK_BOTTOM"))
    (Going_Off->visible=nil)
    axlSetParam(Going_Off)
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:VIA CLASS/paramLayer:PASTEMASK_BOTTOM"))
    (Going_Off->visible=nil)
    axlSetParam(Going_Off)
  ); end BPasteControl_Value == t
  ;------------------------------;
  ; Look at the "TPgr" button    ;
  ;------------------------------;
  (if TPgridControl_Value == t then
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:BOARD GEOMETRY/paramLayer:PLACE_GRID_TOP"))
    (Going_On->visible=t)
    axlSetParam(Going_On)
  else   
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:BOARD GEOMETRY/paramLayer:PLACE_GRID_TOP"))
    (Going_Off->visible=nil)
    axlSetParam(Going_Off) 
  ); end TPgridControl_Value == t
  ;------------------------------;
  ; Look at the "BPgr" button    ;
  ;------------------------------;
  (if BPgridControl_Value == t then
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:BOARD GEOMETRY/paramLayer:PLACE_GRID_BOTTOM"))
    (Going_On->visible=t)
    axlSetParam(Going_On)
  else   
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:BOARD GEOMETRY/paramLayer:PLACE_GRID_BOTTOM"))
    (Going_Off->visible=nil)
    axlSetParam(Going_Off) 
  ); end BPgridControl_Value == t
  ;------------------------------;
  ; Look at the "KO" button      ;
  ;------------------------------;
  (if KOControl_Value == t then
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:PACKAGE KEEPIN/paramLayer:ALL"))
    (Going_On->visible=t)
    axlSetParam(Going_On)
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:PACKAGE KEEPOUT/paramLayer:ALL"))
    (Going_On->visible=t)
    axlSetParam(Going_On)
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:ROUTE KEEPIN/paramLayer:ALL"))
    (Going_On->visible=t)
    axlSetParam(Going_On)
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:ROUTE KEEPOUT/paramLayer:ALL"))
    (Going_On->visible=t)
    axlSetParam(Going_On)
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:VIA KEEPOUT/paramLayer:ALL"))
    (Going_On->visible=t)
    axlSetParam(Going_On)
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:PACKAGE KEEPOUT/paramLayer:TOP"))
    (Going_On->visible=t)   
    axlSetParam(Going_On)
    Going_On=axlGetParam(sprintf(String "paramLayerGroup:PACKAGE KEEPOUT/paramLayer:BOTTOM")) 
    (Going_On->visible=t)
    axlSetParam(Going_On)
  else
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:PACKAGE KEEPIN/paramLayer:ALL"))
    (Going_Off->visible=nil)
    axlSetParam(Going_Off)
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:PACKAGE KEEPOUT/paramLayer:ALL"))
    (Going_Off->visible=nil)
    axlSetParam(Going_Off)
    axlSetParam(Going_Off)
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:ROUTE KEEPIN/paramLayer:ALL"))
    (Going_Off->visible=nil)
    axlSetParam(Going_Off)
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:ROUTE KEEPOUT/paramLayer:ALL"))
    (Going_Off->visible=nil)
    axlSetParam(Going_Off)
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:VIA KEEPOUT/paramLayer:ALL"))
    (Going_Off->visible=nil)
    axlSetParam(Going_Off)
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:PACKAGE KEEPOUT/paramLayer:TOP")) 
    (Going_Off->visible=nil)    
    axlSetParam(Going_Off)  
    Going_Off=axlGetParam(sprintf(String "paramLayerGroup:PACKAGE KEEPOUT/paramLayer:BOTTOM"))
    (Going_Off->visible=nil)    
    axlSetParam(Going_Off)  
  ); end KOControl_Value == t
  ;------------------------------;
  ; Look at the "E" button       ;
  ;------------------------------;
  (if Etch_Control_Value == t then
    (foreach Layer Etch_Layers
      (if axlFormGetField(Form strcat(Layer "_control")) == t then
       Going_On=axlGetParam(sprintf(String "paramLayerGroup:ETCH/paramLayer:%s" Layer))
       (Going_On->visible=t)
       axlSetParam(Going_On)
      else
        Going_Off=axlGetParam(sprintf(String "paramLayerGroup:ETCH/paramLayer:%s" Layer))
        (Going_Off->visible=nil)
        axlSetParam(Going_Off)
      ); end if axlFormGetField(Form strcat(Layer "_control")) == t then
    ); end foreach Layer Etch_Layers
  ); end if Etch_Control_Value == t
  ;------------------------------;
  ; Look at the "P" button       ;
  ;------------------------------;
  (if Pin_Control_Value == t then
    (foreach Layer Etch_Layers
      (if axlFormGetField(Form strcat(Layer "_control")) == t then
        Going_On=axlGetParam(sprintf(String "paramLayerGroup:PIN/paramLayer:%s" Layer))
        (Going_On->visible=t)
        axlSetParam(Going_On)
      else
        Going_Off=axlGetParam(sprintf(String "paramLayerGroup:PIN/paramLayer:%s" Layer))
        (Going_Off->visible=nil)
        axlSetParam(Going_Off)
      ); end if axlFormGetField(Form strcat(Layer "_control")) == t then
    ); end foreach Layer Etch_Layers
  ); end if Pin_Control_Value == t
  ;------------------------------;
  ; Look at the "V" button       ;
  ;------------------------------;
  (if Via_Control_Value == t then
    (foreach Layer Etch_Layers  
      (if axlFormGetField(Form strcat(Layer "_control")) == t then
        Going_On=axlGetParam(sprintf(String "paramLayerGroup:VIA CLASS/paramLayer:%s" Layer))
        (Going_On->visible=t)
        axlSetParam(Going_On)
      else       
        Going_Off=axlGetParam(sprintf(String "paramLayerGroup:VIA CLASS/paramLayer:%s" Layer))
        (Going_Off->visible=nil)
        axlSetParam(Going_Off) 
      ); end if axlFormGetField(Form strcat(Layer "_control")) == t then
    ); end foreach Layer Etch_Layers
  ); end if Via_Control_Value == t 
  ;------------------------------;
  ; Look at the Keep Out/In Btn  ;
  ;------------------------------;
  (if EtchKO_Control_Value == t then
    (foreach Layer Etch_Layers
      (if axlFormGetField(Form strcat(Layer "_control")) == t then
       Going_On=axlGetParam(sprintf(String "paramLayerGroup:ROUTE KEEPOUT/paramLayer:%s" Layer))
       (Going_On->visible=t)
       axlSetParam(Going_On)
       Going_On=axlGetParam(sprintf(String "paramLayerGroup:VIA KEEPOUT/paramLayer:%s" Layer))
       (Going_On->visible=t)
       axlSetParam(Going_On)
      else
        Going_Off=axlGetParam(sprintf(String "paramLayerGroup:ROUTE KEEPOUT/paramLayer:%s" Layer))
        (Going_Off->visible=nil)
        axlSetParam(Going_Off)
        Going_Off=axlGetParam(sprintf(String "paramLayerGroup:VIA KEEPOUT/paramLayer:%s" Layer))
        (Going_Off->visible=nil)
        axlSetParam(Going_Off) 
      ); end if axlFormGetField(Form strcat(Layer "_control")) == t then
    ); end foreach Layer Etch_Layers
  ); end if EtchKO_Control_Value == t
  ;------------------------------;
  ; Look at the DRC Button	 ;
  ;------------------------------;
  (if DRC_Control_Value == t then
    (foreach Layer Etch_Layers
      (if axlFormGetField(Form strcat(Layer "_control")) == t then
        Going_On=axlGetParam(sprintf(String "paramLayerGroup:DRC ERROR CLASS/paramLayer:%s" Layer))
        (Going_On->visible=t)
        axlSetParam(Going_On)
      else
        Going_Off=axlGetParam(sprintf(String "paramLayerGroup:DRC ERROR CLASS/paramLayer:%s" Layer))
        (Going_Off->visible=nil)
        axlSetParam(Going_Off)
      ); end if axlFormGetField(Form strcat(Layer "_control")) == t then
    ); end foreach Layer Etch_Layers
  ); end if DRC_Control_Value == t
  ;------------------------------;
  ; Refresh the display          ;
  ;------------------------------;
  axlFlushDisplay()
  axlShell("redisplay")
); end defun pdiVisUpdate
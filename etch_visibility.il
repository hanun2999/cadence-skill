; ###############################################################################

;               Pin, Via, and Etch layer visibility Control

;  This routine will open a form which contains a toggle button for each currently
;  define etch subclass. The form also contains three toggles labeled:   P(pin),
;  V(via), and E(etch), and two buttons labeled Refresh and Done. This form is used
;  to control the visibility of the pin, via, and etch subclasses.

;  The action of the form is as follows:
;  >  The 3 toggles, P, V, and E, are used to determine whether their respective
;     subclasses are affected when the refresh button is pushed.
;  >  The etch subclass toggles determine whether a subclass is made visible or
;     invisible when the refresh button is pushed.
;  >  The Refresh button causes Allegro to reset the visibility of the subclasses
;     depending on the current setting of the P, V, and E and the subclass toggles
;     and then refresh the graphic display.
;  >  The Done button closes the form.
;  >  Toggles are ON when filled (grey toned).

;  Caveats:
;  >  The form content is NOT dynamically updated. If an etch subclass is added or
;     deleted the form must be closed and reopened.

;  To open the form in Allegro type "etch visibility"


;  Written by David J. Scheuring
;  Sr. Applications Eng. Cadence Design Systems
;  Dec. 8, 1994



axlCmdRegister( "etch visibility" `Etch_Edit_Visibility)

; ########################################
; Define the routine to get things started
; ########################################
(defun Etch_Edit_Visibility ()
   Pin_Control_Value=nil
   Via_Control_Value=nil
   Etch_Control_Value=nil
   ; ###########################
   ; Determine what layers exist
   ; ###########################
   Etch_Layers=(axlGetParam("paramLayerGroup:ETCH")->groupMembers)
   (foreach Layer Etch_Layers
      set(concat(Layer "_Control_Value") nil)
   ); end foreach Layer Etch_Layers
   Etch_Edit_Visibility_Form()
   Form=axlFormCreate( (gensym) "Visibility_Control_Form.form" '(e outer) 'Visibility_Control_Form_Action t)
   axlFormDisplay(Form)
); end defun Etch_Edit_Visibility
 
; ####################
; Create the form file
; ####################
(defun Etch_Edit_Visibility_Form ()
   Port_Size=7
   (foreach Item Etch_Layers
      Port_Size=Port_Size + 1
   ); end foreach Item Etch_Layers
   Visibility_Control_Form=outfile("Visibility_Control_Form.form" "w")
   fprintf(Visibility_Control_Form "FILE_TYPE=FORM_DEFN VERSION=2\n")
   fprintf(Visibility_Control_Form "FORM\n")
   fprintf(Visibility_Control_Form "FIXED\n")
   fprintf(Visibility_Control_Form "PORT 18 %d\n" Port_Size)
   fprintf(Visibility_Control_Form "HEADER \"Etch On/Off\"\n")
   fprintf(Visibility_Control_Form "TILE\n")
   fprintf(Visibility_Control_Form "TEXT \"P\"\n")
   fprintf(Visibility_Control_Form "TLOC 3 3\n")
   fprintf(Visibility_Control_Form "ENDTEXT\n")
   fprintf(Visibility_Control_Form "TEXT \"|\"\n")
   fprintf(Visibility_Control_Form "TLOC 3 2\n")
   fprintf(Visibility_Control_Form "ENDTEXT\n")
   fprintf(Visibility_Control_Form "FIELD Pin_Control\n")
   fprintf(Visibility_Control_Form "FLOC 3 1\n")
   fprintf(Visibility_Control_Form "CHECKLIST\n")
   fprintf(Visibility_Control_Form "ENDFIELD\n")
   fprintf(Visibility_Control_Form "TEXT \"V\"\n")
   fprintf(Visibility_Control_Form "TLOC 8 3\n")
   fprintf(Visibility_Control_Form "ENDTEXT\n")
   fprintf(Visibility_Control_Form "TEXT \"|\"\n")
   fprintf(Visibility_Control_Form "TLOC 8 2\n")
   fprintf(Visibility_Control_Form "ENDTEXT\n")
   fprintf(Visibility_Control_Form "FIELD Via_Control\n")
   fprintf(Visibility_Control_Form "FLOC 8 1\n")
   fprintf(Visibility_Control_Form "CHECKLIST\n")
   fprintf(Visibility_Control_Form "ENDFIELD\n")
   fprintf(Visibility_Control_Form "TEXT \"E\"\n")
   fprintf(Visibility_Control_Form "TLOC 13 3\n")
   fprintf(Visibility_Control_Form "ENDTEXT\n")
   fprintf(Visibility_Control_Form "TEXT \"|\"\n")
   fprintf(Visibility_Control_Form "TLOC 13 2\n")
   fprintf(Visibility_Control_Form "ENDTEXT\n")
   fprintf(Visibility_Control_Form "FIELD Etch_Control\n")
   fprintf(Visibility_Control_Form "FLOC 13 1\n")
   fprintf(Visibility_Control_Form "CHECKLIST\n")
   fprintf(Visibility_Control_Form "ENDFIELD\n")
   Text_Loc=5
   (foreach Item Etch_Layers
      fprintf(Visibility_Control_Form "TEXT \"%s\"\n" Item)
      fprintf(Visibility_Control_Form "TLOC 5 %d\n" Text_Loc)
      fprintf(Visibility_Control_Form "ENDTEXT\n")
      fprintf(Visibility_Control_Form "FIELD %s_Control\n" Item)
      fprintf(Visibility_Control_Form "FLOC 2 %d\n" Text_Loc)
      fprintf(Visibility_Control_Form "CHECKLIST\n")
      fprintf(Visibility_Control_Form "ENDFIELD\n")
      Text_Loc=Text_Loc + 2
   ); end foreach Item Etch_Layers
   fprintf(Visibility_Control_Form "FIELD Refresh_Graphics\n")
   fprintf(Visibility_Control_Form "FLOC 2 %d\n" Text_Loc + 1)
   fprintf(Visibility_Control_Form "MENUBUTTON \"Refresh\" 14 3\n")
   fprintf(Visibility_Control_Form "ENDFIELD\n")
   fprintf(Visibility_Control_Form "FIELD Done\n")
   fprintf(Visibility_Control_Form "FLOC 4 %d\n" Text_Loc + 4)
   fprintf(Visibility_Control_Form "MENUBUTTON \"Done\" 10 3\n")
   fprintf(Visibility_Control_Form "ENDFIELD\n")
   fprintf(Visibility_Control_Form "ENDTILE\n")
   fprintf(Visibility_Control_Form "ENDFORM\n")
   close(Visibility_Control_Form)
); end defun Etch_Edit_Visibility_Form
 
 
; #################################
; Define action of the form buttons
; #################################
(defun Visibility_Control_Form_Action (Visibility_Control_Form)
  (case Visibility_Control_Form->curField
     ("Done"
        axlFormClose(Visibility_Control_Form)
        axlCancelEnterFun()
        nil
     ); end "Done"
     ("Refresh_Graphics"
        Visibility_Update()
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
  ); end case Visibility_Control_Form->curField
); end defun Visibility_Control_Form_Action
 
 
; ####################################
; Define the Visibility_Update routine
; ####################################
(defun Visibility_Update ()
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
   axlFlushDisplay()
   axlShell("redisplay")
); end defun Visibility_Update



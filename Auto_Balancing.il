; ##########################################################################
;
;                    Automatic Copper Balancing for Allegro
;
;   This routine will add filled rectangles on an etch layer to provide balance
;   during the plating process of manufacturing.

;   This routine requires a "MANUFACTURING/BALANCE" subclass with a rectangle
;   that encloses the area in which the balance figures are to be added.

;   The procedure will check each point, on the grid, for any existing features,
;   and build a list of the x/y coordinates that are available. The filled rect-
;   angles are added after checking the entire board. On large boards the checking
;   process may take a couple of minutes, and there is no visual indication that
;   the routine is working (no busy light).

;   The operator is presented with a "Balance Parameters" form. This form is used
;   to define the following:
;      Balancing Layer - The layer on which the figures are to be added.
;      Figure Size - The size of the square that is to be added
;      Clearance - The closest (edge to edge) that a figure can be added to existing
;                  features.
;      Mask Grid - The grid used for adding the figures.
;      Half Density - Yes/No toggle. If set to YES then only every other grid point
;                     is used creating a "checker board" pattern.

;   To run the routine within Allegro type "auto balance".

;   Written by David J. Scheuring
;   Sr. Applications Eng. Cadence Design Systems
;   May 18, 1994

;   Rev. A - Sept. 15, 1994
;   Added function to record and reset the visibility 

;   Rev. B - Jan. 4, 1995
;   Added function to print "Checking etch elements" and "Adding balancing figures"

axlCmdRegister( "auto balance" `Auto_Balance ?cmdType "interactive")

; ########################
; Set the global variables
; ########################

Mask_Layer="TOP"
Figure_Size=40.0
Clearance=25.0
Mask_Grid=50.0
Half_Density=t

(defun Auto_Balance ()

 ; #################
 ; Declare variables
 ; #################

 (let (Boundary
       Boundary_Layer
       Balance_Form
       Available_Layers)

  ; ###############
  ; Clear variables
  ; ###############

  axlDBRefreshId(axlDBGetDesign())
  Boundary=nil
  Boundary_Layer=nil
  Balancing_Form=nil
  Available_Layers=nil

  ; ########################################################
  ; Check for the existence of "Manufaturing/Balancing" layer
  ; ########################################################

  Boundary="paramLayerGroup:MANUFACTURING"

  foreach(Item (axlGetParam(Boundary)->groupMembers)

   if(Item=="BALANCE" then

    Boundary=strcat(Boundary "/paramLayer:BALANCE")

   ); end if Item=="BALANCE"

  ); end foreach Item (axlGetParam(Boundary)->groupMembers)

  if(Boundary=="paramLayerGroup:MANUFACTURING" then

   axlUIConfirm("You must have a\"Manufaturing/Balance\" subclass with a balancing boundary defined")

   else

   ; #########################
   ; Find the available layers
   ; #########################

   Boundary_Layer=axlGetParam(Boundary)
   Available_Layers=(axlGetParam("paramLayerGroup:ETCH")->groupMembers)
   Last_Layer="BOTTOM"

   ; #######################
   ; Build the Balancing form
   ; #######################

   Balancing_Form=outfile("./Balancing_Form.form" "w")
   fprintf(Balancing_Form "FILE_TYPE=FORM_DEFN VERSION=2\n")
   fprintf(Balancing_Form "FORM\n")
   fprintf(Balancing_Form "FIXED\n")
   fprintf(Balancing_Form "PORT 29 10\n")
   fprintf(Balancing_Form "HEADER \"Auto Balancing Form\"\n")
   fprintf(Balancing_Form "POPUP <Layer_Names>")

   foreach(Item Available_Layers

    if(Item==Last_Layer then

     (fprintf Balancing_Form "\"%s\"" Item)
     (fprintf Balancing_Form "\"%s\".\n" Item)

     else

     (fprintf Balancing_Form "\"%s\"" Item)
     (fprintf Balancing_Form "\"%s\"," Item)

    ); end if Item==Last_Layer

   ); end foreach Item Available_Layers

   fprintf(Balancing_Form "TILE\n")
   fprintf(Balancing_Form "TEXT \"Select Balancing Layer:\"\n")
   fprintf(Balancing_Form "TLOC 3 1\n")
   fprintf(Balancing_Form "ENDTEXT\n")
   fprintf(Balancing_Form "FIELD Existing_Layer_Names\n")
   fprintf(Balancing_Form "FLOC 2 3\n")
   fprintf(Balancing_Form "ENUMSET 23\n")
   fprintf(Balancing_Form "POP \"Layer_Names\"\n")
   fprintf(Balancing_Form "ENDFIELD\n")
   fprintf(Balancing_Form "TEXT \"Figure Size:\"\n")
   fprintf(Balancing_Form "TLOC 3 6\n")
   fprintf(Balancing_Form "ENDTEXT\n")
   fprintf(Balancing_Form "FIELD Figure_Size\n")
   fprintf(Balancing_Form "FLOC 16 6\n")
   fprintf(Balancing_Form "REALFILLIN 6 6\n")
   fprintf(Balancing_Form "REALMIN 10.0\n")
   fprintf(Balancing_Form "REALMAX 100.0\n")
   fprintf(Balancing_Form "ENDFIELD\n")
   fprintf(Balancing_Form "TEXT \"Clearance:\"\n")
   fprintf(Balancing_Form "TLOC 3 8\n")
   fprintf(Balancing_Form "ENDTEXT\n")
   fprintf(Balancing_Form "FIELD Clearance\n")
   fprintf(Balancing_Form "FLOC 16 8\n")
   fprintf(Balancing_Form "REALFILLIN 6 6\n")
   fprintf(Balancing_Form "REALMIN 1.0\n")
   fprintf(Balancing_Form "REALMAX 50.0\n")
   fprintf(Balancing_Form "ENDFIELD\n")
   fprintf(Balancing_Form "TEXT \"Mask Grid:\"\n")
   fprintf(Balancing_Form "TLOC 4 11\n")
   fprintf(Balancing_Form "ENDTEXT\n")
   fprintf(Balancing_Form "FIELD Mask_Grid\n")
   fprintf(Balancing_Form "FLOC 15 11\n")
   fprintf(Balancing_Form "REALFILLIN 6 6\n")
   fprintf(Balancing_Form "REALMIN 0.0\n")
   fprintf(Balancing_Form "REALMAX 500.0\n")
   fprintf(Balancing_Form "ENDFIELD\n")
   fprintf(Balancing_Form "FIELD Half_Density\n")
   fprintf(Balancing_Form "FLOC 6 13\n")
   fprintf(Balancing_Form "CHECKLIST \"Half Density\"\n")
   fprintf(Balancing_Form "ENDFIELD\n")
   fprintf(Balancing_Form "FIELD done\n")
   fprintf(Balancing_Form "FLOC 2 16\n")
   fprintf(Balancing_Form "MENUBUTTON \"Done\" 9 3\n")
   fprintf(Balancing_Form "ENDFIELD\n")
   fprintf(Balancing_Form "FIELD Add\n")
   fprintf(Balancing_Form "FLOC 20 16\n")
   fprintf(Balancing_Form "MENUBUTTON \"Add\" 6 3\n")
   fprintf(Balancing_Form "ENDFIELD\n")
   fprintf(Balancing_Form "ENDTILE\n")
   fprintf(Balancing_Form "ENDFORM\n")
   close(Balancing_Form)

   Balancing_Form=axlFormCreate( (gensym) "Balancing_Form.form" '(e inner) 'Balancing_Form_Action t)
   axlFormDisplay(Balancing_Form)
   axlFormSetField(Balancing_Form "Existing_Layer_Names" Mask_Layer)
   axlFormSetField(Balancing_Form "Figure_Size" Figure_Size)
   axlFormSetField(Balancing_Form "Clearance" Clearance)
   axlFormSetField(Balancing_Form "Mask_Grid" Mask_Grid)
   axlFormSetField(Balancing_Form "Half_Density" Half_Density)

  ); end if Boundary=="paramLayerGroup:MANUFACTURING"

 ); end Let

); end defun Auto_Balancing

; ###############################
; Define the Balancing form action
; ###############################
 
(defun Balancing_Form_Action (Balancing_Form)
 
 ; #################
 ; Declare variables
 ; #################
 
 (let (Visibility_Script
  Bound_Box
  Outline
  Outline_LeftX
  Outline_RightX
  Outline_LowerY
  Outline_UpperY
  Current_X
  Current_Y
  Y_Grid_Counter
  Current_Search_Area
  To_Do_List)
 
  ; ###############
  ; Clear variables
  ; ###############
 
  axlDBRefreshId(axlDBGetDesign())
  Visibility_Script=nil
  Bound_Box=nil
  Outline=nil
  Outline_LeftX=nil
  Outline_RightX=nil
  Outline_LowerY=nil
  Outline_UpperY=nil
  Current_X=nil
  Current_Y=nil
  Y_Grid_Counter=nil
  Current_Search_Area=nil
  To_Do_List=nil
 
  ; #################
  ; Begin form action
  ; #################
 
  (case Balancing_Form->curField
 
   ("done"
    axlFormClose(Balancing_Form)
    axlCancelEnterFun()
    shell("rm Balancing_Form.form")
    nil
   ); end "done"
 
   ("Existing_Layer_Names"
    Mask_Layer=(Balancing_Form->curValue)
    t
   ); end "Existing_Layer_Names"
 
   ("Figure_Size"
    Figure_Size=(Balancing_Form->curValue)
    t
   ); end "Figure_Size"
 
   ("Clearance"
    Clearance=(Balancing_Form->curValue)
    t
   ); end "Clearance"
 
   ("Mask_Grid"
    Mask_Grid=(Balancing_Form->curValue)
    t
   ); end "Mask_Grid"
 
   ("Half_Density"
    Half_Density=(Balancing_Form->curValue)
    t
   ); end "Half_Density"
 
   ("Add"
    Balancing_Adder()
   ); end Add
 
  ); end case Balancing_Form->curField
 
 ); end let
 
); end defun Balancing_Form_Action
 
; ##############################################
; Define the routine to add the balancing figures
; ##############################################

(defun Balancing_Adder ()

 ; ############################
 ; Check for Balancing Bound Box
 ; ############################
 
 Going_On=axlGetParam("paramLayerGroup:MANUFACTURING/paramLayer:BALANCE")
 Going_On->visible=t
 axlSetParam(Going_On)

 axlSetActiveLayer("MANUFACTURING/BALANCE")
 axlClearSelSet()
 axlSetFindFilter(?enabled '(noall shapes) ?onButtons '(noall shapes))
 Outline=axlGetSelSet(axlAddSelectAll())
 
 foreach(Item Outline

  if(Item->layer=="MANUFACTURING/BALANCE"
   Bound_Box=Item->bBox
  ); end if Item->layer=="MANUFACTURING/BALANCE"

 );end foreach Item Outline

 if(Bound_Box==nil then
  axlUIConfirm("You must have a rectangle defined on the balance subclass that encloses the balancing area")
  else
  ;axlFormClose(Balancing_Form)
  ;axlCancelEnterFun()

  ; ###################
  ; Clear the variables
  ; ###################

  Classes=nil
  Class=nil
  SubClasses=nil
  SubClass=nil
  Param=nil
  Param_List=nil
  Visible=nil
  Visible_List=nil
  Going_off=nil
  Going_On=nil

  ; ########################################################################
  ; Go thru all the class/subclass combinations and determine what's visible
  ; ########################################################################

  Classes=axlGetParam("paramLayerGroup")->groupMembers
  foreach(Class Classes
   SubClasses=axlGetParam(sprintf(String "paramLayerGroup:%s/paramLayer" Class))->groupMembers
   foreach(SubClass SubClasses
    if(axlGetParam(sprintf(String "paramLayerGroup:%s/paramLayer:%s" Class SubClass))->visible==t then
     Visible=list(Class SubClass)
     if(Visible_List==nil then
      Visible_List=list(Visible)
      else
      Visible_List=cons(Visible Visible_List)
     ); end if axlGetParam(sprintf(String ...))->visible==t

     ; #######################
     ; Reset visibility to off
     ; #######################

     Going_Off=axlGetParam(sprintf(String "paramLayerGroup:%s/paramLayer:%s" Class SubClass))
     Going_Off->visible=nil
     axlSetParam(Going_Off)
    ); end if axlGetParam(sprintf(String ...))->visible==t
   ); end foreach SubClass SubClasses
  ); end foreach Class Classes

  ; ##############################################################
  ; Set the visibility to ON for the Etch, Pin, and Via subclasses
  ; ##############################################################

  Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:ETCH/paramLayer:%s" Mask_Layer))
  Going_On->visible=t
  axlSetParam(Going_On)
  Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:VIA CLASS/paramLayer:%s" Mask_Layer))
  Going_On->visible=t
  axlSetParam(Going_On)
  Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:PIN/paramLayer:%s" Mask_Layer))
  Going_On->visible=t
  axlSetParam(Going_On)
  Outline_LeftX=car(car(Bound_Box))
  Outline_RightX=car(car(cdr(Bound_Box)))
  Outline_LowerY=car(cdr(car(Bound_Box)))
  Outline_UpperY=car(cdr(car(cdr(Bound_Box))))
  Current_X=(Mask_Grid*fix(Outline_LeftX/Mask_Grid))
  Current_Y=(Mask_Grid*fix(Outline_LowerY/Mask_Grid)+Mask_Grid)

  ; ########################################
  ; Querry the Vertices and add the balancing
  ; ########################################

  axlUIWPrint(Balancing_Form "Checking etch elements")
  axlSetActiveLayer(strcat( "ETCH/" Mask_Layer))
  axlClearSelSet()
  axlSetFindFilter(?enabled '(noall pins clines vias shapes lines figures text)
                   ?onButtons '(noall pins clines vias shapes lines figures text))
  if(Half_Density==t then

   ; ##########################
   ; Do the add at half density
   ; ##########################

   Y_Grid_Counter=0
   To_Do_List=nil
   while((Current_Y < Outline_UpperY)
    if(evenp(Y_Grid_Counter)==t then
     Current_X=((Mask_Grid*fix(Outline_LeftX/Mask_Grid))+Mask_Grid)
     else
     Current_X=((Mask_Grid*fix(Outline_LeftX/Mask_Grid))+(Mask_Grid*2))
    ); end if evenp(Y_Grid_Counter)==t
    while((Current_X < Outline_RightX)
     Current_Search_Area=axlSingleSelectBox(list(Current_X-(Clearance+(Figure_Size/2)) :Current_Y-(Clearance+(Figure_Size/2)) Current_X+(Clearance+(Figure_Size/2)) :Current_Y+(Clearance+(Figure_Size/2))))
     if(Current_Search_Area==nil then
      To_Do_List=cons(list(Current_X Current_Y) To_Do_List)
      Current_X = Current_X+(Mask_Grid*2)
      else
      Current_X = Current_X+(Mask_Grid*2)
     ); end if Current_Search_Area==nil
    ); end while Current_X < Outline_RightX
    Current_Y = Current_Y+Mask_Grid
    Y_Grid_Counter=Y_Grid_Counter+1
   ); end while (Current_Y < Outline_UpperY)
   else

   ; ##########################
   ; Do the add at full density
   ; ##########################

   To_Do_List=nil
   while((Current_Y < Outline_UpperY)
    Current_X=((Mask_Grid*fix(Outline_LeftX/Mask_Grid))+Mask_Grid)
    while((Current_X < Outline_RightX)
     Current_Search_Area=axlSingleSelectBox(list(Current_X-(Clearance+(Figure_Size/2)):Current_Y-(Clearance+(Figure_Size/2)) Current_X+(Clearance+(Figure_Size/2)):Current_Y+(Clearance+(Figure_Size/2))))
     if(Current_Search_Area==nil then
      To_Do_List=cons(list(Current_X Current_Y) To_Do_List)
      Current_X = Current_X+Mask_Grid
      else
      Current_X = Current_X+Mask_Grid
     ); end if Current_Search_Area==nil
    ); end while Current_X < Outline_RightX
    Current_Y = Current_Y+Mask_Grid
   ); end while (Current_Y < Outline_UpperY)
  ); end if Half_Density==t
  axlUIWPrint(Balancing_Form "Adding balancing figures")
  foreach(Item To_Do_List
   axlDBCreateRectangle( list(car(Item)-(Figure_Size/2):car(cdr(Item))-(Figure_Size/2)
   car(Item)+(Figure_Size/2):car(cdr(Item))+(Figure_Size/2)) t)
  ); end foreach Item To_Do_List
  To_Do_List=nil

  ; ################################################
  ; Reset visibility to what it was when you started
  ; ################################################

  foreach(Visible Visible_List
   Class=car(Visible)
   SubClass=car(cdr(Visible))
   Going_On=axlGetParam(sprintf(dummy "paramLayerGroup:%s/paramLayer:%s" Class SubClass))
   Going_On->visible=t
   axlSetParam(Going_On)
  ); end foreach Visible Visible_List
 ); end if Bound_Box==nil
 axlUIWPrint(Balancing_Form "Auto balancing Complete")
 axlShell("redisplay")

); end defun Balancing_Adder

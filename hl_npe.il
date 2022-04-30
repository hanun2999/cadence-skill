;
; Hilight Missing Pin Escapes
; Revision 0: June 1,1994
; Written by:
;   Edward B. Acheson
;  Sr. Benchmark Systems Engineer
;  Cadence Design Systems
;  Chelmsford Mass.
;
; Description:
; This SKILL file will search the current database for all pins
; and hilight any pin that does not have a via or throught pin attached
; to it by a path (connect line). This program will verify pin escapes
; for any component or pin with the PIN_ESCAPE or NO_PIN_ESCAPE property
; attached to it. Any Net that has a NO_ROUTE Property will be
; excluded in the pin escape search. Any pin which does not have a pin
; number or net attached will be ignored as well.
;
; Limitations:
;   - This SKILL program must be run on Allegro Revision 8.1 or higher.
;   - A no route property attached to a component is not verified.
;
;Execution:
;        Locate this file (hl_npe.il) in the directory path where all other
;       skill routines are located. In the allegro.ilinit file include the line
;       load("hl_npe.il")
;       To Execute the command in the Allegro command window enter hl_npe
;
;
;
axlCmdRegister( "hl_npe" '_HNPE_Run ?cmdType "general")
;
;========================Startup Command Funtion ===========================
; The function begins the hi lite command sequence
;===========================================================================
   defun( _HNPE_Run ()
    pinlist = nil
    pingrp = nil
    hlpinl = nil
    counter = 0
    subcounter = 0

 ; get pin data list
    axlMsgPut("Building Pin Table")
    _HNPE_Bldlist()
 
 ; find pins with no pin escape
    axlMsgPut("Searching  Pin Table")
    _HNPE_Mk_Pin_List()
 
 ;check for Component properties
    _HNPE_CmpPrpChk()
 
; Clean up
    axlClearSelSet()
    axlFlushDisplay()
    axlMsgPut("%d Pins were Highlighted With Missing Pin Escapes" counter)
);enddefun
;============================== Get Pins and build a list =================
; this segment retrives all pins in the database and store the data into
; the "pinlist" variable.
;==========================================================================
defun( _HNPE_Bldlist ()
 axlSetFindFilter( ?enabled (list "noall" "pins") ?onButtons (list "pins"))
 pinlist = axlGetSelSet(axlAddSelectAll())
);enddefun
;============= Check Pins for Properties and net names =====================
; properties checked for and verified (ok=include in list, no=do not include)
; net name = "" : no NO_ROUTE = t : no  net->nBranches 1: no
; NO_PIN_ESCAPE = t : no PIN_ESCAPE =  t ; ok
; branch with through hole, and no PIN_ESCAPE added : no
;===========================================================================
defun( _HNPE_Mk_Pin_List ()
   pincount = 0
   gcount = 0
   foreach( pin pinlist
    pincount++
    notpin = nil
    yestpin = nil
    yesvia = nil
    unless( pin->number == "" ; no pin number, no check
;    no net name & no route, no check
     unless( pin->net->name == "" || pin->net->prop->NO_ROUTE == t
      if( pin->prop->NO_PIN_ESCAPE == t then notpin = t) ; no-pin-escape, no check
      if( pin->net->nBranches == 1 then notpin = t) ; if 1, net all connected, no check
      if( pin->net->isThrough == t then notpin = t) ; through hole pin, ignore
      if( pin->prop->PIN_ESCAPE == t then notpin = nil) ; Pin has pin-escape property,
                                                        ; verfiy for pin escape
      unless( notpin == t
       pinkids = pin->branch->children
       x = 1
;check for via and thru hole pin in branch and PIN_escape
;property
       while( nthelem(x pinkids ) != nil && notpin == nil
;This segment check for a via in the branch
        if(nthelem(x pinkids)->objType == "via" then
         notpin = t
         yesvia = t)
; this segment check for pins, then verifies the pin is
; a through pin.
        if(nthelem(x pinkids)->objType == "pin" then
         if(nthelem(x pinkids)->isThrough then
         notpin = t
         yestpin = t
         )
        );end-if
; check to see if no via found on any through hole pin
        if( notpin == nil && pin->prop->PIN_ESCAPE == t then
         notpin = nil
        );end-if
        x++
       );end-while
; check to see if any pin has a pin escape prop, and identify it
       if( yestpin == t && yesvia == nil then
        if( pin->prop->PIN_ESCAPE == t then
         notpin = nil
        )
       )
;If pin is ok, and no via exists, then include in list
       when( notpin == nil
        counter++
        axlHighlightObject( pin t)
        hlpinl = cons( pin hlpinl)
       );end-when
      );end-unless
     );end-unless
    );end-unless
    when( pincount == 100
     gcount++
     axlMsgPut( "%d out of %d found",counter,pincount*gcount )
     pincount = 0
    )
   );end-foreach
);end-defun
;=================================================================================
;
;       Check for Components with Pin_Escape property added
;
;=================================================================================
defun( _HNPE_CmpPrpChk ()
   cmpcnt = 0
   pcount = 0
   axlMsgPut(" Checking Components For Pin Escape Property")
     axlSetFindFilter( ?enabled (list "noall" "components") ?onButtons (list "components"))
     cmplist = axlGetSelSet(axlAddSelectAll())
     foreach( cmp cmplist
       if( cmp->prop->PIN_ESCAPE == t then
         cmpcnt++
         pinlist = cmp->symbol->pins
         foreach( pin pinlist
           notpin = nil
           yestpin = nil
           yesvia = nil
           unless( pin->number == ""
             unless( pin->net->name == "" || pin->net->prop->NO_ROUTE == t
               if( pin->prop->NO_PIN_ESCAPE == t then notpin = t)
                 unless( notpin == t
                   pinkids = pin->branch->children
                   x = 1
 ;check for via and thru hole pin in branch and PIN_escape
 ;property
                   while( nthelem(x pinkids ) != nil && notpin == nil
 ;This segment check for a via in the branch
                     if(nthelem(x pinkids)->objType == "via" then
                       notpin = t
                       yesvia = t
                     );end-if
                     x++
                   );end-while
 ;If pin is ok, and no via exists, then include in list
                   when( notpin == nil
                     axlHighlightObject( pin t)
                     hlpinl = cons( pin hlpinl);list for hilited pins
                     pcount++
                     counter++
                   );end-when
                 );end-unless
               );end-unless
             );end-unless
           );end-foreach
         );endif
       );end-foreach
   if( cmpcnt < 1 then
     axlMsgPut( "No Components With PIN_ESCAPE Property Found!")
   else
     axlMsgPut( "%d Components With PIN_ESCAPE Property Found!", cmpcnt)
     axlMsgPut( "Of These, There were %d Missing Pin Escapes.\n",pcount)
   );end if
;--------------------------------- Check for No_pin_escape prop ---------------------
; This segment will verify for NO_PIN_ESCAPE property on Components, and if any
; Pins ar found to be hilighted , it will dehilight them.
;--------------------------------------------------------------------------------
   foreach( cmp cmplist
     if( cmp->prop->NO_PIN_ESCAPE == t then
       pinlist = cmp->symbol->pins
       foreach(pin pinlist
         if( memq( pin hlpinl) then
           axlDehighlightObject( pin t)
           counter--; remove count for hilited pins
         );end-if
       );end-foreach
     );endif
   );end foreach
);end-defun
;+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+ End Of SKILL Program  +=+=+=+=+=+=+=+=+=+=+=+=+=



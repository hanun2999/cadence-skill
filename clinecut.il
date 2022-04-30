/*
################################################################################
#                                                                              #
#                      Command: clinecut                                       #
#                   Skill File: clinecut.il                                    #
#                  How To Load: Command> (load("clinecut.il"))                 #
#               How To Execute: Command> clinecut          OR                  #
#                                        clinecut [-]help  OR                  #
#                                        clinecut [-]h     OR                  #
#                                                                              #
#                       Author: Larry Bowman, Cadence Design Systems           #
#                        Email: bowman@cadence.com                             #
#                    Telephone: 512-349-1109                                   #
#                Creation Date: 11/21/2001                                     #
#                                                                              #
################################################################################

################################################################################
#  DISCLAIMER:                                                                 #
#       The user of this command assumes all responsibility and does not       #
#       hold Cadence Design Systems nor the author of this code for any        #
#       unwarranted results or problems due to the use of this code.           #
#                                                                              #
#       This is non-supported code and the user may modify it as needed.       #
#                                                                              #
################################################################################
*/

;###########################################################
;#                                                         #
;#                Main Program lcb_clinecut                #
;#                                                         #
;###########################################################
axlCmdRegister("clinecut" 'lcb_clinecut ?cmdType "interactive"
 ?doneCmd '_lcb_ccCancel ?cancelCmd '_lcb_ccCancel)


(defun lcb_clinecut (@optional (args ""))
 prog( ()


lhelpargs = list("help" "h" "-h" "-help" "debug" "d" "-debug" "-d")
debug = nil

;; Check for command line arguments
if(args != "" then
  case(lowerCase(args)
   ( ("help" "h" "-h" "-help")
    axlUIWPrint(nil " - Displaying Info file. -")
    ;;; ### Insert function for Info file here.
    clinecut_info_createInfo()
    return()
   ); end help
   ( ("debug" "d" "-debug" "-d")
     ;; 
     debug = t
   ); end debug
   (t
    axlUIWPrint(nil "*** Error, you entered ->%s<-" args)
    axlUIWPrint(nil "     Only arguments accepted are:")
    axlUIWPrint(nil "     %L" lhelpargs)
    return()
   ); incorrect argument
  ); end case
); endif

;; find width of all clines and use smallest width * 2 for the minvalue
if( lallclinesegs = ashFindAllClinesegs() then
 defclinewidth = nthelem(1 lallclinesegs)->width
 foreach(one lallclinesegs
   if(one->width < defclinewidth then
     defclinewidth = one->width
  ); endif
 ); end foreach
else
 ;; no clinesegs in layout
 axlUIWPrint(nil " - Exiting, No Cline Segs in layout.")
 return()
);endif



;; initialize variables
 notdone = t
 dbaccuracy = nthelem(2 axlDBGetDesignUnits())
 dbunits = nthelem(1 axlDBGetDesignUnits())
 mincutvalue = defclinewidth * 2
 ;sprintf(mincutvalue "%L %s" mincutvalue dbunits)
 maxcutvalue = "1000 mils"
 minvalue = axlMKSConvert(mincutvalue dbunits) 
 maxvalue = axlMKSConvert(maxcutvalue dbunits)
 if(dbaccuracy == 0 then
  formatacc = 0
 else
  formatacc = dbaccuracy - 1
 ); endif

;; Set a user defined subclass to draw the user's window selection.
class_sub = "manufacturing/cutline"
axlLayerCreateNonConductor(class_sub)
axlVisibleLayer(class_sub t)
axlVisibleUpdate(t)

;; Set the Control Panel to the Options tab
axlControlRaise('options)

_createForm_clinecut()


clinecut_Form=axlMiniStatusLoad( (gensym) clinecut_form_file 'clinecut_Form_Action t)

;; Set form default values
axlFormSetFieldLimits(clinecut_Form "cutwidth" minvalue maxvalue)
axlFormSetField(clinecut_Form "units" dbunits)
axlFormSetField(clinecut_Form "dbunits" dbunits)
sprintf(format "%%.%df" formatacc)
if(boundp('cutwidth) then
  if(cutwidth < minvalue  || cutwidth > maxvalue then
     cutwidth = axlMKSConvert(lastvalue dbunits)
     maxvalue = axlMKSConvert(maxcutvalue dbunits)
  ); endif
else
 cutwidth = evalstring(sprintf(cut_text format minvalue))
); endif
axlFormSetField(clinecut_Form "cutwidth" cutwidth)
axlFormColorize(clinecut_Form "tcut" 'text 'red)
axlFormColorize(clinecut_Form "tcut" 'background 'button)
axlFormSetField(clinecut_Form "minvalue" cut_text)
axlFormSetField(clinecut_Form "maxvalue" maxvalue)
axlFormColorize(clinecut_Form "minvalue" 'text 'yellow)
axlFormColorize(clinecut_Form "minvalue" 'background 'black)
axlFormColorize(clinecut_Form "maxvalue" 'text 'yellow)
axlFormColorize(clinecut_Form "maxvalue" 'background 'black)



;;; Create graphics in form.
ghandle = axlGRPDrwInit(clinecut_Form "drawarea" '_lcb_cutcline_graphic)
axlGRPDrwUpdate(ghandle)

if(isFile(clinecut_form_file)
 deleteFile(clinecut_form_file)
);endif

 while(notdone
   _lcb_ccgetpicks()
 ); end while

 ); end prog
); end defun
;###########################################################
;#                                                         #
;#      End of Main Program lcb_clinecut                   #
;#                                                         #
;###########################################################

;###########################################################
;#                                                         #
;#            _lcb_ccgetpicks                              #
;#                                                         #
;###########################################################
defun( _lcb_ccgetpicks ()
  
  axlClearSelSet()
  axlSetFindFilter(?enabled list("noall" "clinesegs") ?onButtons list("clinesegs"))
  _lcb_ccPopUp()

  cutbox = axlEnterBox(?prompts list(" - Enter First Window point -"
                                     " - Enter Second Window point -"))

 lcsegsignore = list()
 lhorcsegs = list()
 lvertcsegs = list()
 lslopecsegs = list()


  if(cutbox then

    ;; get clineseg dbids
    axlSingleSelectBox(cutbox)
    cc_lclinesegs = axlGetSelSet()

    ;; get boundary lines drawn by user
    _lcb_ccGetBoundaryLines()

    ;; Ignore clines within boundary and
    ;; sort clinesegs by horizontal, vertical, or sloped
    _lcb_ccSortclinesegs()

    ;; Highlight those clinesegs to be cut and give user
    ;; a final chance to abort.
    ;_lcb_ccHighlight()

    ;; Cut the clinesegs that cross the boundary
    ;; Input to function is a list of csegdbids.
    ;; Also already know type of line (H,V,S), so pass it on.
    if(lhorcsegs then
     _lcb_ccCutclinesegs(lhorcsegs "h")
    );endf
    if(lvertcsegs then
     _lcb_ccCutclinesegs(lvertcsegs "v")
    ); endif
    if(lslopecsegs then
     _lcb_ccCutclinesegs(lslopecsegs "s")
    ); endif
  /*
  else
    axlUIWPrint(nil " - Closed -")
  */
  );

); end defun
;###########################################################
;#                                                         #
;#            End of _lcb_ccgetpicks                       #
;#                                                         #
;###########################################################

;###########################################################
;#                                                         #
;#            _lcb_ccCutclinesegs                          #
;#                                                         #
;###########################################################
defun( _lcb_ccCutclinesegs (listcsegs mode)
  
  case(mode
   ("h"

      ;; create variables for cseg end points.
      ;; the cseg may start left to right, right to left,
      ;; top to bottom, or bottom to top.


     foreach(cseg listcsegs

      ;; create variables for cseg end points.
      ;; the cseg may start left to right, right to left,
      ;; top to bottom, or bottom to top.

      cXbeg = nthelem(1 nthelem(1 cseg->startEnd))
      cYbeg = nthelem(2 nthelem(1 cseg->startEnd))
      cXend = nthelem(1 nthelem(2 cseg->startEnd))
      cYend = nthelem(2 nthelem(2 cseg->startEnd))
      p1x = cXbeg
      p1y = cYbeg
      p4x = cXend
      p4y = cYend


      cond( ;; Crosses both Vertical lines
       ( (vlx > p1x && vlx < p4x || vlx > p4x && vlx < p1x) &&
         (vrx > p1x && vrx < p4x || vrx > p4x && vrx < p1x)
  
        if(debug then
         axlUIWPrint(nil " - Crosses Both V lines")
        ); endif
        if(nthelem(1 nthelem(1 cseg->startEnd)) < nthelem(1 nthelem(2 cseg->startEnd)) then
          cline1 = list(nthelem(1 cseg->startEnd) list(vlx nthelem(2 nthelem(1 cseg->startEnd))))
          cline2 = list(list(vlx + cutwidth nthelem(2 nthelem(1 cseg->startEnd))) list(vrx - cutwidth nthelem(2 nthelem(1 cseg->startEnd))))
          cline3 = list(list(vrx nthelem(2 nthelem(1 cseg->startEnd))) nthelem(2 cseg->startEnd))
        p3x = nthelem(1 nthelem(1 cline2))
        p5x = nthelem(1 nthelem(2 cline2))

        else
          cline1 = list(nthelem(1 cseg->startEnd) list(vrx nthelem(2 nthelem(1 cseg->startEnd))))
          cline2 = list(list(vrx - cutwidth nthelem(2 nthelem(1 cseg->startEnd))) list(vlx + cutwidth nthelem(2 nthelem(1 cseg->startEnd))))
          cline3 = list(list(vlx nthelem(2 nthelem(1 cseg->startEnd))) nthelem(2 cseg->startEnd))
        p3x = nthelem(1 nthelem(2 cline2))
        p5x = nthelem(1 nthelem(1 cline2))

        ); endif

        etchlayer = cseg->layer
        segnetname = cseg->net->name
        segwidth = cseg->width
        axlDeleteObject(cseg)


        axlDBCreateLine(cline1 segwidth etchlayer segnetname)
        if(p3x < p5x then
         axlDBCreateLine(cline2 segwidth etchlayer segnetname)
        ); endif
        axlDBCreateLine(cline3 segwidth etchlayer segnetname)
         
        ); cond 1 - end of one segment crossing both vertical boundary lines

       ( ;; Crosses just the left vertical line
         vlx > p1x && vlx < p4x || vlx > p4x && vlx < p1x
         
         if(debug then  
          axlUIWPrint(nil " - Crosses Left Vline")
         ); endif
         ;; segment ends do not always go from left-to-right but may go right-to-left.
         if(nthelem(1 nthelem(1 cseg->startEnd)) > nthelem(1 nthelem(2 cseg->startEnd)) then
          cline1 = list(nthelem(2 cseg->startEnd) list(vlx nthelem(2 nthelem(2 cseg->startEnd))))
          cline2 = list(list(vlx + cutwidth nthelem(2 nthelem(2 cseg->startEnd))) nthelem(1 cseg->startEnd))
         else
          cline1 = list(nthelem(1 cseg->startEnd) list(vlx nthelem(2 nthelem(1 cseg->startEnd))))
          cline2 = list(list(vlx + cutwidth nthelem(2 nthelem(1 cseg->startEnd))) nthelem(2 cseg->startEnd))
         ); endif
         etchlayer = cseg->layer
         segnetname = cseg->net->name
         segwidth = cseg->width
         axlDeleteObject(cseg)
         p3x = nthelem(1 nthelem(1 cline2))
         axlDBCreateLine(cline1 segwidth etchlayer segnetname)
         if(p3x < p4x then
          axlDBCreateLine(cline2 segwidth etchlayer segnetname)
         ); endif

       ); cond 2 - end of crossing left vertical  boundary line

       (;; Crosses Right Vertical line only

        vrx > p1x && vrx < p4x || vrx > p4x && vrx < p1x

         if(debug then
          axlUIWPrint(nil " - Crosses Right Vline")
         ); endif
         ;; segment ends do not always go from left-to-right but may go right-to-left.
         if(nthelem(1 nthelem(1 cseg->startEnd)) > nthelem(1 nthelem(2 cseg->startEnd)) then
          cline1 = list(nthelem(2 cseg->startEnd) list(vrx - cutwidth nthelem(2 nthelem(2 cseg->startEnd))))
          cline2 = list(list(vrx nthelem(2 nthelem(2 cseg->startEnd))) nthelem(1 cseg->startEnd))
          p1x = nthelem(1 nthelem(1 cline1))
         else
          cline1 = list(nthelem(1 cseg->startEnd) list(vrx - cutwidth nthelem(2 nthelem(1 cseg->startEnd))))
          cline2 = list(list(vrx nthelem(2 nthelem(1 cseg->startEnd))) nthelem(2 cseg->startEnd))
         ); endif
         etchlayer = cseg->layer
         segnetname = cseg->net->name
         segwidth = cseg->width
         axlDeleteObject(cseg)

         p2x = nthelem(1 nthelem(2 cline1))
         if( p2x > p1x then
          axlDBCreateLine(cline1 segwidth etchlayer segnetname)
         ); endif
         axlDBCreateLine(cline2 segwidth etchlayer segnetname)

       ); cond 3 - end of crossing right vertical boundary line
      ); end cond
     ); end foreach
    ); end "h"

   ("v"
     foreach(cseg listcsegs

      ;; create variables for cseg end points.
      ;; the cseg may start left to right, right to left,
      ;; top to bottom, or bottom to top.

      cXbeg = nthelem(1 nthelem(1 cseg->startEnd))
      cYbeg = nthelem(2 nthelem(1 cseg->startEnd))
      cXend = nthelem(1 nthelem(2 cseg->startEnd))
      cYend = nthelem(2 nthelem(2 cseg->startEnd))
      p1x = cXbeg
      p1y = cYbeg
      p4x = cXend
      p4y = cYend
   /*
      p2x = p1x
      p2y = hty
      p3x = p1x
      p3y = hty - cutwidth
      p5x = p1x
      p5y = hby + cutwidth
      p6x = h1x
      p6y = hby + cutwidth
*/
      cond( ;; Crosses both horizontal lines
       ( (hby > p1y && hby < p4y || hby > p4y && hby < p1y) &&
         (hty > p1y && hty < p4y || hty > p4y && hty < p1y)

        if(debug then
         axlUIWPrint(nil " - Crosses Both H lines")
        ); endif
        if(nthelem(2 nthelem(1 cseg->startEnd)) > nthelem(2 nthelem(2 cseg->startEnd)) then

         cline1 = list(nthelem(1 cseg->startEnd) list(nthelem(1 nthelem(1 cseg->startEnd)) hty))
         cline2 = list(list(nthelem(1 nthelem(1 cseg->startEnd)) hty - cutwidth) list(nthelem(1 nthelem(1 cseg->startEnd)) hby + cutwidth))
         cline3 = list(list(nthelem(1 nthelem(1 cseg->startEnd)) hby) nthelem(2 cseg->startEnd))
         
         p3y = nthelem(2 nthelem(1 cline2))
         p5y = nthelem(2 nthelem(2 cline2))
         if( p3y > p5y then
           cline2seg = t
         else
           cline2seg = nil
         ); endif     
   
        else
        
         cline1 = list(nthelem(1 cseg->startEnd) list(nthelem(1 nthelem(1 cseg->startEnd)) hby))
         cline2 = list(list(nthelem(1 nthelem(1 cseg->startEnd)) hby + cutwidth) list(nthelem(1 nthelem(1 cseg->startEnd)) hty - cutwidth))
         cline3 = list(list(nthelem(1 nthelem(1 cseg->startEnd)) hty) nthelem(2 cseg->startEnd))
         p3y = nthelem(2 nthelem(1 cline2))
         p5y = nthelem(2 nthelem(2 cline2))
         if( p5y > p3y then
           cline2seg = t
         else
           cline2seg = nil
         ); endif
               
        ); endif
        etchlayer = cseg->layer
        segnetname = cseg->net->name
        segwidth = cseg->width
        axlDeleteObject(cseg)

 
        axlDBCreateLine(cline1 segwidth etchlayer segnetname)
        if(cline2seg then
         axlDBCreateLine(cline2 segwidth etchlayer segnetname)
        ); endif
        axlDBCreateLine(cline3 segwidth etchlayer segnetname)
       
        ); cond 1 - end of one segment crossing both horizontal boundary lines

       ( ;; Crosses Bottom Horizontal line
         hby > p1y && hby < p4y || hby > p4y && hby < p1y

         if(debug then
          axlUIWPrint(nil " - Crosses Bottom Hline")
         ); endif
         
         ;; segment ends do not always go from top-to-bottom but may go bottom-to-top.
         if(nthelem(2 nthelem(1 cseg->startEnd)) > nthelem(2 nthelem(2 cseg->startEnd)) then
          cline1 = list(nthelem(1 cseg->startEnd) list(nthelem(1 nthelem(2 cseg->startEnd)) hby + cutwidth))
          cline2 = list(list(nthelem(1 nthelem(2 cseg->startEnd)) hby) nthelem(2 cseg->startEnd))
           p2y = nthelem(2 nthelem(2 cline1))
           p1y = nthelem(2 nthelem(1 cline1))
         else
          cline1 = list(nthelem(1 cseg->startEnd) list(nthelem(1 nthelem(1 cseg->startEnd)) hby))
          cline2 = list(list(nthelem(1 nthelem(1 cseg->startEnd)) hby + cutwidth) nthelem(2 cseg->startEnd))
           p2y = nthelem(2 nthelem(1 cline2))
           p1y = nthelem(2 nthelem(2 cline2))           
         ); endif
         etchlayer = cseg->layer
         segnetname = cseg->net->name
         segwidth = cseg->width
         axlDeleteObject(cseg)

         p3y = nthelem(2 nthelem(1 cline2))
         axlDBCreateLine(cline1 segwidth etchlayer segnetname)
         if(p2y < p1y then
          axlDBCreateLine(cline2 segwidth etchlayer segnetname)
         ); endif
        
       ); cond 2 - end of crossing bottom horizontal  boundary line

       (;; Crosses Top Horizontal line
         hty > p1y && hty < p4y || hty > p4y && hty < p1y

         if(debug then
          axlUIWPrint(nil " - Crosses Top Hline")
         ); endif
         
         ;; segment ends do not always go from left-to-right but may go right-to-left.
         if(nthelem(2 nthelem(1 cseg->startEnd)) > nthelem(2 nthelem(2 cseg->startEnd)) then
          cline1 = list(nthelem(2 cseg->startEnd) list(nthelem(1 nthelem(2 cseg->startEnd)) hty - cutwidth))
          cline2 = list(list(nthelem(1 nthelem(2 cseg->startEnd)) hty) nthelem(1 cseg->startEnd))
          p1y = nthelem(2 nthelem(1 cline1))
          p2y = nthelem(2 nthelem(2 cline2))
         else
          cline1 = list(nthelem(1 cseg->startEnd) list(nthelem(1 nthelem(1 cseg->startEnd)) hty - cutwidth))
          cline2 = list(list(nthelem(1 nthelem(1 cseg->startEnd)) hty) nthelem(2 cseg->startEnd))
          p1y = nthelem(2 nthelem(1 cline1))
          p2y = nthelem(2 nthelem(2 cline2))
         ); endif
         etchlayer = cseg->layer
         segnetname = cseg->net->name
         segwidth = cseg->width
         axlDeleteObject(cseg)
         p2y = nthelem(2 nthelem(2 cline1))
         if( p2y > p1y then
          axlDBCreateLine(cline1 segwidth etchlayer segnetname)
         ); endif
         axlDBCreateLine(cline2 segwidth etchlayer segnetname)
        
       ); cond 3 - end of crossing top horizontal boundary line
      ); end cond
     ); end foreach


   ); end vertical

   ("s"
    ;i = 1
    foreach(cseg listcsegs
      ;; create variables for cseg end points.
      ;; the cseg may start left to right, right to left,
      ;; top to bottom, or bottom to top.

      cXbeg = nthelem(1 nthelem(1 cseg->startEnd))
      cYbeg = nthelem(2 nthelem(1 cseg->startEnd))
      cXend = nthelem(1 nthelem(2 cseg->startEnd))
      cYend = nthelem(2 nthelem(2 cseg->startEnd))

      if(cXend < cXbeg then
       cXbeg = nthelem(1 nthelem(2 cseg->startEnd))
       cYbeg = nthelem(2 nthelem(2 cseg->startEnd))
       cXend = nthelem(1 nthelem(1 cseg->startEnd))
       cYend = nthelem(2 nthelem(1 cseg->startEnd))
      ); endif

      ;; Make some possible intersection calculations.
      cslope = axlLineSlope(cseg->startEnd)

      ;; Y intersection on the vertical boundary lines.
      if(cslope < 0 then
        ylint = cYend + (abs(cslope) *  (cXend - vlx))
        yrint = cYend + (abs(cslope) * (cXend - vrx))
      else
        yrint = cYbeg + (cslope * (vrx - cXbeg))
        ylint = cYbeg + (cslope * (vlx - cXbeg))
      ); endif

     ;; X intersection on the horizontal boundary lines.
      if(cslope < 0 then
        xtint = ((cYbeg - hty) / abs(cslope)) + cXbeg
        xbint = cXend - ( (hby - cYend)/abs(cslope) )       
      else
        xtint = cXend - ( (cYend - hty) / cslope)
        xbint = ((hby - cYbeg) / cslope) + cXbeg
      ); endif

          ;axlUIWPrint(nil " - Cseg %n " i)
      
    cond(

      ( ;; Slope Crosses Left Vertical Boundary Line ONLY.
        (cXbeg < vlx && cXend > vlx) && cYend < hty && cYend > hby &&
        (cXend < vrx) && (ylint > hby && ylint < hty)

        if(debug then
         axlUIWPrint(nil " - Slope crosses left vertical boundary line")
        ); endif
 
       
        p1x = cXbeg
        p1y = cYbeg
        p4x = cXend
        p4y = cYend
        p2x = vlx
        p2y = p1y + (cslope * (vlx - p1x))
        p3x = cutwidth + vlx
        p3y = p2y + (cslope * cutwidth)
        cline1 = list(list(p1x p1y) list(p2x p2y))
        cline2 = list(list(p3x p3y) list(p4x p4y))

        ;; End of left side of boundary line.

        etchlayer = cseg->layer
        segnetname = cseg->net->name
        segwidth = cseg->width
        axlDeleteObject(cseg)

        if(p3x < p4x then
         axlDBCreateLine(cline1 segwidth etchlayer segnetname)
         axlDBCreateLine(cline2 segwidth etchlayer segnetname)
        else
         axlDBCreateLine(cline1 segwidth etchlayer segnetname) 
        ); endif

       ); end left vertical boundary line

    ( ;; Slope Crosses Right Vertical Boundary Line ONLY.
      (cXbeg < vrx && cXend > vrx) && cYbeg < hty && cYbeg > hby &&
      (cXbeg > vlx) &&  (yrint > hby && yrint < hty)

      if(debug then
       axlUIWPrint(nil " - Slope Crosses Right Vline")
      ); endif

      p1x = cXbeg
      p1y = cYbeg
      p4x = cXend
      p4y = cYend
      p2x = vrx - cutwidth
      p2y = p1y + cslope * (p2x - p1x)
      p3x = vrx
      p3y = (cslope * cutwidth) + p2y
      cline1 = list(list(p1x p1y) list(p2x p2y))
      cline2 = list(list(p3x p3y) list(p4x p4y))

      ;; End of right side of boundary line.
      etchlayer = cseg->layer
      segnetname = cseg->net->name
      segwidth = cseg->width
      axlDeleteObject(cseg)

      if(p1x < p2x then
        axlDBCreateLine(cline1 segwidth etchlayer segnetname)
        axlDBCreateLine(cline2 segwidth etchlayer segnetname)
      else
        axlDBCreateLine(cline2 segwidth etchlayer segnetname)
      ); endif


    ); end of right vertical boundary line

   
    ( ;; Slope Crosses  Positive Top Horizontal Boundary Line ONLY.
     (cXbeg > vlx && cXbeg < vrx && cYbeg > hby && cYbeg < hty && cYend > hty) 
        if(debug then
         axlUIWPrint(nil " - Slope Crosses TOP horizontal line")
        ); endif
      
        p1x = cXbeg
        p1y = cYbeg
        p4x = cXend
        p4y = cYend
        p3x = p1x + ((hty - p1y)/cslope)
        p3y = hty
        p2x = p3x - (cutwidth / cslope)
        p2y = hty - cutwidth
        cline1 = list(list(p1x p1y) list(p2x p2y))
        cline2 = list(list(p3x p3y) list(p4x p4y))

        
        etchlayer = cseg->layer
        segnetname = cseg->net->name
        segwidth = cseg->width
        axlDeleteObject(cseg)
     
       if(p1x < p2x then
        axlDBCreateLine(cline1 segwidth etchlayer segnetname)
        axlDBCreateLine(cline2 segwidth etchlayer segnetname)
       else
        axlDBCreateLine(cline2 segwidth etchlayer segnetname)
       ); endif
     
      
    ); end cond of top boundary
   (;; Slope Crosses Negative Top Horizontal Boundary line.
     (cXend > vlx && cXend < vrx && cYend > hby && cYend < hty && cYbeg > hty)
      if(debug then
       axlUIWPrint(nil " - Found NEGative line crossing TOP Horizontal line. -")
      ); endif

        p1x = cXbeg
        p1y = cYbeg
        p4x = cXend
        p4y = cYend
        p2x = p1x + ((hty - p1y)/cslope)
        p2y = hty
        p3x = p2x - (cutwidth / cslope)
        p3y = hty - cutwidth
        cline1 = list(list(p1x p1y) list(p2x p2y))
        cline2 = list(list(p3x p3y) list(p4x p4y))

      
        etchlayer = cseg->layer
        segnetname = cseg->net->name
        segwidth = cseg->width
        axlDeleteObject(cseg)
     

       if(p3x < p4x  then
        axlDBCreateLine(cline1 segwidth etchlayer segnetname)
        axlDBCreateLine(cline2 segwidth etchlayer segnetname)
       else
        axlDBCreateLine(cline1 segwidth etchlayer segnetname)
       ); endif

  
   ); end of negative top boundary line
 
   (;; Slope Crosses Positive Bottom Horizontal Boundary line.
     (cXend > vlx && cXend < vrx && cYend > hby && cYend < hty && cYbeg < hby)
      if(debug then
       axlUIWPrint(nil " - Found Positive line crossing BOTTOM Horizontal line. -")
      ); endif

        p1x = cXbeg
        p1y = cYbeg
        p4x = cXend
        p4y = cYend
        p2x = p1x + ((hby - p1y)/cslope)
        p2y = hby
        p3x = p2x + (cutwidth / cslope)
        p3y = hby + cutwidth
         cline1 = list(list(p1x p1y) list(p2x p2y))
         cline2 = list(list(p3x p3y) list(p4x p4y))

      
        etchlayer = cseg->layer
        segnetname = cseg->net->name
        segwidth = cseg->width
        axlDeleteObject(cseg)

        ;; if the boundary line crosses too close to the end
        ;; of the cline segment the intermediate x/y location (P3x,P3y)
        ;; may be greater than the end of the segment (p4x,p4y).  If
        ;; this is the case then just delete the entire section from the
        ;; boundary line.
        if( p4x > p3x then
         axlDBCreateLine(cline1 segwidth etchlayer segnetname)
         axlDBCreateLine(cline2 segwidth etchlayer segnetname)
        else
         axlDBCreateLine(cline1 segwidth etchlayer segnetname)
        ); endif

     
     ); End positive slope crossing bottom horizontal boundary line.
   (;; Slope Crosses Negative Bottom Horizontal Boundary line.
     (cXbeg > vlx && cXbeg < vrx && cYbeg < hty && cYbeg > hby && cYend < hby)
      if(debug then
       axlUIWPrint(nil " - Found Negative line crossing BOTTOM Horizontal line. -")
      ); endif

        p1x = cXbeg
        p1y = cYbeg
        p4x = cXend
        p4y = cYend

        p3x = p4x - ( (hby - p4y) / abs(cslope))
        p3y = hby

        p2x = p3x - (cutwidth / abs(cslope))
        p2y = p3y + cutwidth
         
        cline1 = list(list(p1x p1y) list(p2x p2y))
        cline2 = list(list(p3x p3y) list(p4x p4y))    


        etchlayer = cseg->layer
        segnetname = cseg->net->name
        segwidth = cseg->width
        axlDeleteObject(cseg)
            
        if(p1x < p2x then   
         axlDBCreateLine(cline1 segwidth etchlayer segnetname)
         axlDBCreateLine(cline2 segwidth etchlayer segnetname)
        else
         axlDBCreateLine(cline2 segwidth etchlayer segnetname)
        ); endif

       

 
     ); End negative slope crossing bottom horizontal boundary line.
    (;; slope crosses both vertical lines

         
     (cXbeg < vlx && cXend > vrx) &&
     (ylint > hby && ylint < hty) &&
     (yrint > hby && yrint < hty)
     
      if(debug then
       axlUIWPrint(nil " - Crosses BOTH Vertical Lines")
      ); endif


      ;; crosses left vline
        p1x = cXbeg
        p1y = cYbeg
        p4x = cXend
        p4y = cYend
        p2x = vlx
        p2y = p1y + (cslope * (vlx - p1x))
        p3x = cutwidth + vlx
        p3y = p2y + (cslope * cutwidth)

      ;; crosses right vline
      p5x = vrx - cutwidth
      p5y = p1y + cslope * (p5x - p1x)
      p6x = vrx
      p6y = (cslope * cutwidth) + p5y
      cline1 = list(list(p1x p1y) list(p2x p2y))
      cline2 = list(list(p3x p3y) list(p5x p5y))
      cline3 = list(list(p6x p6y) list(p4x p4y))

      etchlayer = cseg->layer
      segnetname = cseg->net->name
      segwidth = cseg->width
      axlDeleteObject(cseg)


      axlDBCreateLine(cline1 segwidth etchlayer segnetname)
      if(p3x < p5x then
       axlDBCreateLine(cline2 segwidth etchlayer segnetname)
      ); endif
      axlDBCreateLine(cline3 segwidth etchlayer segnetname)

      
     ); end of slope crosses both vertical lines


    (;;  positive slope crosses both horizontal lines
       
       cYbeg < hby && cYend > hty && xtint > vlx && xtint < vrx && xbint > vlx && xbint < vrx

       if(debug then
        axlUIWPrint(nil " - Positive slope Crosses BOTH top and bottom horizontal lines.")
       ); endif
       
        p1x = cXbeg
        p1y = cYbeg
        p4x = cXend
        p4y = cYend
        p2x = xbint
        p2y = hby
        p3y = cutwidth + p2y
        p3x = ((p3y - p2y) / cslope) + p2x
        p5y = hty - cutwidth
        p5x = xtint - (cutwidth / cslope)
        p6x = xtint
        p6y = hty

        cline1 = list(list(p1x p1y) list(p2x p2y))
        cline2 = list(list(p3x p3y) list(p5x p5y))
        cline3 = list(list(p6x p6y) list(p4x p4y))

        etchlayer = cseg->layer
        segnetname = cseg->net->name
        segwidth = cseg->width
        axlDeleteObject(cseg)

        axlDBCreateLine(cline1 segwidth etchlayer segnetname)
        if( p3y < p5y then
          axlDBCreateLine(cline2 segwidth etchlayer segnetname)
        ); endif
        axlDBCreateLine(cline3 segwidth etchlayer segnetname)
 


    ); end of positive slope crosses both horizontal lines
    (;; negative slope crosses both horizontal lines
       cYbeg > hty && cYend < hby && xtint > vlx && xtint < vrx && xbint > vlx && xbint < vrx
       if(debug then
        axlUIWPrint(nil " - Negative slope crosses both top and bottom horizontal lines.")
       ); endif

        p1x = cXbeg
        p1y = cYbeg
        p4x = cXend
        p4y = cYend
        p2x = xtint
        p2y = hty
        p3y = p2y - cutwidth
        p3x = ((p2y - p3y) / abs(cslope)) + p2x
        p5y = hby + cutwidth
        p5x = xbint - (cutwidth / abs(cslope))
        p6x = xbint
        p6y = hby

        cline1 = list(list(p1x p1y) list(p2x p2y))
        cline2 = list(list(p3x p3y) list(p5x p5y))
        cline3 = list(list(p6x p6y) list(p4x p4y))

        etchlayer = cseg->layer
        segnetname = cseg->net->name
        segwidth = cseg->width
        axlDeleteObject(cseg)

        axlDBCreateLine(cline1 segwidth etchlayer segnetname)
        if( p3y > p5y then
          axlDBCreateLine(cline2 segwidth etchlayer segnetname)
        ); endif
        axlDBCreateLine(cline3 segwidth etchlayer segnetname)
     ); end negative slope
     (;; slope crosses left vline AND top hline
      ylint < hty && ylint > hby && xtint > vlx && xtint < vrx
      if(debug then
       axlUIWPrint(nil " - Slope crosses LEFT vline and TOP hline")
      ); endif

        p1x = cXbeg
        p1y = cYbeg
        p4x = cXend
        p4y = cYend
        p2x = vlx
        p2y = ylint
        p3x = vlx + cutwidth
        p3y = p2y + ((p3x - p2x) * cslope)
        p6y = hty
        p6x = p4x - ( (p4y - p6y)/cslope )
        p5y = hty - cutwidth
        p5x = p6x - ( (p6y - p5y)/cslope )
        
        cline1 = list(list(p1x p1y) list(p2x p2y))
        cline2 = list(list(p3x p3y) list(p5x p5y))
        cline3 = list(list(p6x p6y) list(p4x p4y))

        etchlayer = cseg->layer
        segnetname = cseg->net->name
        segwidth = cseg->width
        axlDeleteObject(cseg)

        axlDBCreateLine(cline1 segwidth etchlayer segnetname)
        if( p5x > p3x then
          axlDBCreateLine(cline2 segwidth etchlayer segnetname)
        ); endif
        axlDBCreateLine(cline3 segwidth etchlayer segnetname)

      
     ); end slope crossing left vline and top hline
     ( ;; slope crosses left vline and bottom hline
      ylint < hty && ylint > hby && xbint > vlx && xbint < vrx && cYend < hby
      if(debug then
       axlUIWPrint(nil " - Slope crosses LEFT vline and BOTTOM hline")
      ); endif
       
        p1x = cXbeg
        p1y = cYbeg
        p4x = cXend
        p4y = cYend
        p2x = vlx
        p2y = ylint
        p3x = vlx + cutwidth
        p3y = p2y - ((p3x - p2x) * abs(cslope))
        p6y = hby
        p6x = p4x - ( (p6y - p4y)/abs(cslope) )
        p5y = hby + cutwidth
        p5x = p6x - ( (p5y - p6y)/abs(cslope) )


        cline1 = list(list(p1x p1y) list(p2x p2y))
        cline2 = list(list(p3x p3y) list(p5x p5y))
        cline3 = list(list(p6x p6y) list(p4x p4y))

        etchlayer = cseg->layer
        segnetname = cseg->net->name
        segwidth = cseg->width
        axlDeleteObject(cseg)

        axlDBCreateLine(cline1 segwidth etchlayer segnetname)
        if( p5x > p3x then
          axlDBCreateLine(cline2 segwidth etchlayer segnetname)
        ); endif
        axlDBCreateLine(cline3 segwidth etchlayer segnetname)

     ); end of slope crossing left vline and top hline

     ( ;; slope crossing right vline and top hline
       yrint < hty && yrint > hby && xtint > vlx && xtint < vrx && cYbeg > hty && cXend > vrx
       if(debug then
         axlUIWPrint(nil " - Slope crosses RIGHT vline and TOP hline")
       ); endif

        p1x = cXbeg
        p1y = cYbeg
        p4x = cXend
        p4y = cYend
        p2x = xtint
        p2y = hty
        p3x = p2x + (cutwidth / abs(cslope))
        p3y = p2y - cutwidth
        p6y = yrint
        p6x = vrx
        p5x = p6x - cutwidth
        p5y = p6y + (abs(cslope) * cutwidth)


        cline1 = list(list(p1x p1y) list(p2x p2y))
        cline2 = list(list(p3x p3y) list(p5x p5y))
        cline3 = list(list(p6x p6y) list(p4x p4y))

        etchlayer = cseg->layer
        segnetname = cseg->net->name
        segwidth = cseg->width
        axlDeleteObject(cseg)

        axlDBCreateLine(cline1 segwidth etchlayer segnetname)
        if( p5x > p3x then
          axlDBCreateLine(cline2 segwidth etchlayer segnetname)
        ); endif
        axlDBCreateLine(cline3 segwidth etchlayer segnetname)


     );; end slope crossing right vline and top hline
  
     ( ;; slope crossing right vline and bottom hline ( positive slope )
       yrint < hty && yrint > hby && xbint > vlx && xbint < vrx && cYbeg < hby && cXend > vrx
       if(debug then
         axlUIWPrint(nil " - Slope crosses RIGHT vline and BOTTOM hline")
       ); endif
       
        p1x = cXbeg
        p1y = cYbeg
        p4x = cXend
        p4y = cYend
        p2x = xbint
        p2y = hby
        p3x = p2x + (cutwidth / cslope)
        p3y = p2y + cutwidth
        p6y = yrint
        p6x = vrx
        p5x = p6x - cutwidth
        p5y = p6y - (cslope * cutwidth)


        cline1 = list(list(p1x p1y) list(p2x p2y))
        cline2 = list(list(p3x p3y) list(p5x p5y))
        cline3 = list(list(p6x p6y) list(p4x p4y))

        etchlayer = cseg->layer
        segnetname = cseg->net->name
        segwidth = cseg->width
        axlDeleteObject(cseg)

        axlDBCreateLine(cline1 segwidth etchlayer segnetname)
        if( p5x > p3x then
          axlDBCreateLine(cline2 segwidth etchlayer segnetname)
        ); endif
        axlDBCreateLine(cline3 segwidth etchlayer segnetname)

     );; end slope crossing right vline and bottom hline


    ); end cond

    ;i++
    ); end foreach
   ); end sloped
  ); end case

); end defun
;###########################################################
;#                                                         #
;#            End of _lcb_ccCutclinesegs                   #
;#                                                         #
;###########################################################



;###########################################################
;#                                                         #
;#            _lcb_ccSortclinesegs                         #
;#                                                         #
;###########################################################
defun( _lcb_ccSortclinesegs ()

  ;; First remove all clineseg dbids that are within
  ;; the area boundary
  foreach(cseg cc_lclinesegs
    if(axlIsPointInsideBox(nthelem(1 cseg->startEnd) cutbox) && 
       axlIsPointInsideBox(nthelem(2 cseg->startEnd) cutbox) then
       cc_lclinesegs = remd(cseg cc_lclinesegs)

       ;; for debug purposes make list of those clinesegs that are
       ;; within the box for displaying purposes
       lcsegsignore = cons(cseg lcsegsignore)

    ); endif
  ); end foreach

  ;; Remaining list contains only those that cross the boundary.
  ;; Make a list of clinesegs by horizontal, vertical, and slope
  ;; for easier manipulation.
  ;; Results of axlLineSlope() are:
  ;;  0   - Horizontal line
  ;;  nil - Vertical line
  ;;  <n> - Sloped line, where <n> may be positive or negative number.
  foreach(cseg cc_lclinesegs
    case(axlLineSlope(cseg->startEnd)
      ( (0.0 0)
        ;; Horizontal segment
        lhorcsegs = cons(cseg lhorcsegs)
      ); end 0
      (nil
        ;; Vertical segment
        lvertcsegs = cons(cseg lvertcsegs)
      ); end nil
      (t
       ;; sloped lines
       lslopecsegs = cons(cseg lslopecsegs)
      ); end t
    ); end case
  ); end foreach
 


); end defun
;###########################################################
;#                                                         #
;#            End of _lcb_ccSortclinesegs                  #
;#                                                         #
;###########################################################

;###########################################################
;#                                                         #
;#            _lcb_ccGetBoundaryLines                      #
;#                                                         #
;###########################################################
defun( _lcb_ccGetBoundaryLines ()

   first = nthelem(1 cutbox)
   second = nthelem(2 cutbox)


   ;; The user may draw the window from left to right,
   ;; right to left, top to bottom, or bottom to top.
   ;; Must make sure which side is which.
   if(nthelem(1 first) < nthelem(1 second) then
     firstcoord = nthelem(1 cutbox)
     secondcoord = nthelem(2 cutbox)     
   else
     firstcoord = nthelem(2 cutbox)
     secondcoord = nthelem(1 cutbox)
   ); endif
   ; Check Y coord and make the highest one top   
   if(nthelem(2 firstcoord) > nthelem(2 secondcoord) then
     htop = list(firstcoord list(nthelem(1 secondcoord) nthelem(2 firstcoord)))
     hbot = list(list(nthelem(1 firstcoord) nthelem(2 secondcoord)) secondcoord)
   else
     htop = list(list(nthelem(1 firstcoord) nthelem(2 secondcoord)) secondcoord)
     hbot = list(firstcoord list(nthelem(1 secondcoord) nthelem(2 firstcoord)))
   ); endif


   
   htopbegin = nthelem(1 htop)
   htopend = nthelem(2 htop)
   hty = nthelem(2 htopbegin)
   htopbeginx = nthelem(1 htopbegin)

   hbotbegin = nthelem(1 hbot)
   hbotend = nthelem(2 hbot)
   hby = nthelem(2 hbotend)

   vleftbegin = htopbegin
   vleftend = hbotbegin
   vleft = list(vleftbegin vleftend)
   vlx = nthelem(1 vleftbegin)

   vrightbegin = htopend
   vrightend = hbotend
   vright = list(htopend hbotend)
   vrx = nthelem(1 vrightbegin)

   ;; draw boundary lines for visual inspection
   lwidth = 0
   ;class_sub = "board geometry/cutline"  
   axlDBCreateLine(list(htopbegin htopend) lwidth class_sub)
   axlDBCreateLine(list(vrightbegin vrightend) lwidth class_sub)
   axlDBCreateLine(list(hbotbegin hbotend) lwidth class_sub)
   axlDBCreateLine(list(vleftbegin vleftend) lwidth class_sub)

); end defun
;###########################################################
;#                                                         #
;#            End of _lcb_ccGetBoundaryLines               #
;#                                                         #
;###########################################################

;###########################################################
;#                                                         #
;#                 _lcb_ccPopUp                            #
;#                                                         #
;###########################################################
defun( _lcb_ccPopUp ()
      sprintf(pm1 "- Exit -")
   popup_cc = axlUIPopupDefine( nil (list
      (list "- Oops -" '_lcb_ccOops)
      (list pm1 '_lcb_ccCancel)
      ;(list "Cancel (same as above)" '_lcb_ccCancel)
      ))
   axlUIPopupSet(popup_cc)
); end defun
;###########################################################
;#                                                         #
;#                 End of _lcb_ccPopUp                     #
;#                                                         #
;###########################################################

;###########################################################
;#                                                         #
;#                 _lcb_ccOops                             #
;#                                                         #
;###########################################################
defun( _lcb_ccOops ()
 
 axlUIWPrint(nil " - Selected RMB Oops")
 axlCancelEnterFun()
 
); end defun
;###########################################################
;#                                                         #
;#                 End of _lcb_ccOops                      #
;#                                                         #
;###########################################################



;###########################################################
;#                                                         #
;#                 _lcb_ccCancel                           #
;#                                                         #
;###########################################################
defun( _lcb_ccCancel ()

 axlUIWPrint(nil " - Selected RMB Exit")
 notdone = nil
 axlCancelEnterFun()
 
); end defun
;###########################################################
;#                                                         #
;#                 End of _lcb_ccCancel                    #
;#                                                         #
;###########################################################



;###########################################################
;#                                                         #
;#                  clinecut_Form_Action                  #
;#                                                         #
;###########################################################
(defun clinecut_Form_Action (clinecut_Form)
 (case clinecut_Form->curField
  ("cutwidth"     
    lastvalue = strcat(clinecut_Form->curValue " " dbunits)
    cutwidth = evalstring(clinecut_Form->curValue) ;; bug in axlMiniStatusLoad
    axlGRPDrwUpdate(ghandle)   
    axlUIWPrint(nil " - Cut Distance is %L %s" cutwidth dbunits)
  )
  ("info" axlUIWPrint(clinecut_Form "Info Button")
       clinecut_info_createInfo()
       ;axlGRPDrwUpdate(ghandle)   
  )
  ("close"
     axlUIWPrint(nil " - Selected CLOSE button")
     axlCancelEnterFun()
     notdone = nil
  ); end cancel
 ); end case
);end defun
;###########################################################
;#                                                         #
;#               End of clinecut_Form_Action               #
;#                                                         #
;###########################################################

;###########################################################
;#                                                         #
;#                  _lcb_cutcline_graphic                  #
;#                                                         #
;###########################################################
(defun _lcb_cutcline_graphic (handle)


axlGRPDrwMapWindow(ghandle 1800 1200)

  ;; draw board outline
  putprop(handle "unfilled" 'fill)
  putprop(handle "gray" 'color)
  putprop(handle 30 'width)
  axlGRPDrwPoly(handle list('(1 1) '(1790 1) '(1790 1000)
   '(1700 1000) '(1700 1200) '(90 1200) '(90 1000) '(1 1000) '(1 1)))


  ; draw symbol pins
  putprop(handle "filled" 'fill)
  putprop(handle "green" 'color)
  putprop(handle 1 'width)
  axlGRPDrwCircle(handle '(700 400) 50)
  axlGRPDrwCircle(handle '(1100 400) 50)
  axlGRPDrwCircle(handle '(700 500) 50)
  axlGRPDrwCircle(handle '(1100 500) 50)
  axlGRPDrwCircle(handle '(700 600) 50)
  axlGRPDrwCircle(handle '(1100 600) 50)
  axlGRPDrwCircle(handle '(700 700) 50)
  axlGRPDrwCircle(handle '(1100 700) 50)
  axlGRPDrwCircle(handle '(700 800) 50)
  axlGRPDrwCircle(handle '(1100 800) 50)
  axlGRPDrwCircle(handle '(700 900) 50)
  axlGRPDrwCircle(handle '(1100 900) 50)

  ; draw symbol
  putprop(handle "unfilled" 'fill)
  putprop(handle "black" 'color)
  putprop(handle 20 'width)
  axlGRPDrwRectangle(handle '(750 300) '(1050 1000))


  ; draw lines from pins
  putprop(handle "blue" 'color)
  putprop(handle 30 'width)
  axlGRPDrwLine(handle list('(700 400) '(100 400)))
  axlGRPDrwLine(handle list('(1100 400) '(1700 400)))
  axlGRPDrwLine(handle list('(700 500) '(100 500)))
  axlGRPDrwLine(handle list('(1100 500) '(1700 500)))
  axlGRPDrwLine(handle list('(700 600) '(100 600)))
  axlGRPDrwLine(handle list('(1100 600) '(1700 600)))
  axlGRPDrwLine(handle list('(700 700) '(100 700)))
  axlGRPDrwLine(handle list('(1100 700) '(1700 700)))
  axlGRPDrwLine(handle list('(700 800) '(100 800)))
  axlGRPDrwLine(handle list('(1100 800) '(1700 800)))
  axlGRPDrwLine(handle list('(700 900) '(100 900)))
  axlGRPDrwLine(handle list('(1100 900) '(1700 900)))

  ; draw user selection window
  putprop(handle "unfilled" 'fill)
  putprop(handle "white" 'color)
  putprop(handle 1 'width)
  axlGRPDrwRectangle(handle '(200 200) '(1500 1100))

  ; draw plus sign to indicate start of window
  putprop(handle 20 'width)
  axlGRPDrwLine(handle list('(100 200) '(300 200)))
  axlGRPDrwLine(handle list('(200 300) '(200 100)))

  ; draw dimension lines
  putprop(handle 1 'width)
  putprop(handle "black" 'color)
  axlGRPDrwLine(handle list('(1500 150) '(1500 50)))
  axlGRPDrwLine(handle list('(1400 400) '(1400 50)))

  ;; draw dotted cut line
  putprop(handle 1 'width)
  putprop(handle "black" 'color)
  ;; right side of graphic
  axlGRPDrwLine(handle list('(1400 450) '(1400 550)))
  axlGRPDrwLine(handle list('(1400 575) '(1400 625)))
  axlGRPDrwLine(handle list('(1400 650) '(1400 725)))
  axlGRPDrwLine(handle list('(1400 750) '(1400 825)))
  axlGRPDrwLine(handle list('(1400 875) '(1400 950)))
  ;; left side of graphic
  axlGRPDrwLine(handle list('(300 375) '(300 425)))
  axlGRPDrwLine(handle list('(300 450) '(300 550)))
  axlGRPDrwLine(handle list('(300 575) '(300 625)))
  axlGRPDrwLine(handle list('(300 650) '(300 725)))
  axlGRPDrwLine(handle list('(300 750) '(300 825)))
  axlGRPDrwLine(handle list('(300 875) '(300 950)))


  ; draw arrow leaders
  putprop(handle "filled" 'fill)
  axlGRPDrwPoly(handle list('(1500 100) '(1600 75) '(1600 125)))
  axlGRPDrwPoly(handle list('(1400 100) '(1300 75) '(1300 125)))
  axlGRPDrwLine(handle list('(1300 100) '(1100 100)))
  axlGRPDrwLine(handle list('(1600 100) '(1700 100)))

  ; add text
  putprop(handle "red" 'color)
  putprop(handle "transparent" 'text_bkmode)
  axlGRPDrwText(handle '(250 25) "Cut Distance")

  ; add line to indicate area to be cut.
  putprop(handle 30 'width)
  ;; right side
  axlGRPDrwLine(handle list('(1400 400) '(1500 400)))
  ;; left side
  axlGRPDrwLine(handle list('(200 400) '(300 400)))

  ; add text
  putprop(handle "black" 'color)
  putprop(handle "transparent" 'text_bkmode)
  axlGRPDrwText(handle '(800 400) "U1")

  ; add entry from cut distance
  putprop(handle "black" 'color)
  putprop(handle "transparent" 'text_bkmode)
  ; right side
  axlGRPDrwText(handle '(1400 200) sprintf(dist "%L" cutwidth))
  ;; left side
  axlGRPDrwText(handle '(200 200) sprintf(dist "%L" cutwidth))

); end defun
;###########################################################
;#                                                         #
;#                  End of _lcb_cutcline_graphic           #
;#                                                         #
;###########################################################

;########################################################################
;#                                                                      #
;#                Function _saveSelSet                                  #
;#                                                                      #
;########################################################################
(defun _saveSelSet ()
    (list (axlGetSelSet) (axlGetFindFilter nil) (axlGetFindFilter t)))

;########################################################################
;#                                                                      #
;#                Function _restoreSelSet                               #
;#                                                                      #
;########################################################################
(defun _restoreSelSet (oldSelSet "l")
    (axlSetFindFilter ?enabled (cons "noall" (nth 1 oldSelSet))
		      ?onButtons (cons "noall" (nth 2 oldSelSet)))
    (axlSingleSelectObject (car oldSelSet))
    t)


;########################################################################
;#                                                                      #
;#                Function findAllOfType                                #
;#                                                                      #
;########################################################################
(defun findAllOfType (findType "t")
    (let (selSet oldSetData)
	(setq oldSetData (_saveSelSet))
	(axlClearSelSet)
	(axlSetFindFilter ?enabled  (list "noall" findType "invisible")
			  ?onButtons  (list "noall" findType))
	(axlAddSelectAll)
	(setq selSet (axlGetSelSet))
	(_restoreSelSet oldSetData)

	selSet))

;########################################################################
;#                                                                      #
;#                Function ashFindAllClines                             #
;#                                                                      #
;########################################################################
(defun ashFindAllClines ()
    (findAllOfType "CLINES")
); end ashFindAllClines

;########################################################################
;#                                                                      #
;#                Function ashFindAllClinesegs                          #
;#                                                                      #
;########################################################################
(defun ashFindAllClinesegs ()
    (findAllOfType "CLINESEGS"))


;###########################################################
;#                                                         #
;#                  _createForm_clinecut                  #
;#                                                         #
;###########################################################
(defun _createForm_clinecut ()
 prog( ()
  clinecut_form_file = "./clinecut.form"
  clinecut_form = outfile(clinecut_form_file "w")
  fprintf(clinecut_form "FILE_TYPE=FORM_DEFN VERSION=2\n")
  fprintf(clinecut_form "FORM \n")
  fprintf(clinecut_form "FIXED\n")
  fprintf(clinecut_form "PORT 36 19\n")
  fprintf(clinecut_form "HEADER \"name\"\n")
  fprintf(clinecut_form "\n")
  fprintf(clinecut_form "TILE\n")
  fprintf(clinecut_form "TEXT \"Cut Distance:\" tcut\n")
  fprintf(clinecut_form "TLOC 2 6\n")
  fprintf(clinecut_form "TGROUP \"Cut_Clines_By_Window\"\n")
  fprintf(clinecut_form "ENDTEXT\n")
  fprintf(clinecut_form "\n")
  fprintf(clinecut_form "TEXT\n")
  fprintf(clinecut_form "TLOC 19 6\n")
  fprintf(clinecut_form "INFO units 8\n")
  fprintf(clinecut_form "TGROUP \"Cut_Clines_By_Window\"\n")
  fprintf(clinecut_form "ENDTEXT\n")
  fprintf(clinecut_form "\n")
  fprintf(clinecut_form "TEXT \"Range:\" range\n")
  fprintf(clinecut_form "TLOC 2 8\n")
  fprintf(clinecut_form "TGROUP \"Cut_Clines_By_Window\"\n")
  fprintf(clinecut_form "ENDTEXT\n")
  fprintf(clinecut_form "\n")
  fprintf(clinecut_form "TEXT\n")
  fprintf(clinecut_form "TLOC 8 8\n")
  fprintf(clinecut_form "INFO minvalue 8\n")
  fprintf(clinecut_form "TGROUP \"Cut_Clines_By_Window\"\n")
  fprintf(clinecut_form "ENDTEXT\n")
  fprintf(clinecut_form "\n")
  fprintf(clinecut_form "TEXT \"to\" to\n")
  fprintf(clinecut_form "TLOC 11 8\n")
  fprintf(clinecut_form "TGROUP \"Cut_Clines_By_Window\"\n")
  fprintf(clinecut_form "ENDTEXT\n")
  fprintf(clinecut_form "\n")
  fprintf(clinecut_form "TEXT\n")
  fprintf(clinecut_form "TLOC 13 8\n")
  fprintf(clinecut_form "INFO maxvalue 8\n")
  fprintf(clinecut_form "TGROUP \"Cut_Clines_By_Window\"\n")
  fprintf(clinecut_form "ENDTEXT\n")
  fprintf(clinecut_form "\n")
  fprintf(clinecut_form "TEXT\n")
  fprintf(clinecut_form "TLOC 20 8\n")
  fprintf(clinecut_form "INFO dbunits 8\n")
  fprintf(clinecut_form "TGROUP \"Cut_Clines_By_Window\"\n")
  fprintf(clinecut_form "ENDTEXT\n")
  fprintf(clinecut_form "\n")
  fprintf(clinecut_form "FIELD cutwidth\n")
  fprintf(clinecut_form "FLOC 12 6\n")
  fprintf(clinecut_form "FGROUP \"Cut_Clines_By_Window\"\n")
  fprintf(clinecut_form "REALFILLIN 5 5\n")
  fprintf(clinecut_form "REALMIN 1.0\n")
  fprintf(clinecut_form "REALMAX 1000.000000\n")
  fprintf(clinecut_form "DECIMAL %n\n" dbaccuracy )
  fprintf(clinecut_form "ENDFIELD\n")
  fprintf(clinecut_form "\n")
  fprintf(clinecut_form "FIELD drawarea\n")
  fprintf(clinecut_form "THUMBNAIL\n")
  fprintf(clinecut_form "FLOC 4 12\n")
  fprintf(clinecut_form "FSIZE 25 10\n")
  fprintf(clinecut_form "FGROUP \"Cut_Clines_By_Window\"\n")
  fprintf(clinecut_form "ENDFIELD\n")
  fprintf(clinecut_form "\n")
  fprintf(clinecut_form "FIELD close\n")
  fprintf(clinecut_form "FLOC 3 23\n")
  fprintf(clinecut_form "FGROUP \"Cut_Clines_By_Window\"\n")
  fprintf(clinecut_form "MENUBUTTON \"Close\" 13 3\n")
  fprintf(clinecut_form "ENDFIELD\n")
  fprintf(clinecut_form "\n")
  fprintf(clinecut_form "FIELD info\n")
  fprintf(clinecut_form "FLOC 17 23\n")
  fprintf(clinecut_form "FGROUP \"Cut_Clines_By_Window\"\n")
  fprintf(clinecut_form "MENUBUTTON \"Info\" 10 3\n")
  fprintf(clinecut_form "ENDFIELD\n")
  fprintf(clinecut_form "\n")
  fprintf(clinecut_form "GROUP \"Cut_Clines_By_Window\"\n")
  fprintf(clinecut_form "GLOC 1 2\n")
  fprintf(clinecut_form "GSIZE 33 25\n")
  fprintf(clinecut_form "ENDGROUP\n")
  fprintf(clinecut_form "\n")
  fprintf(clinecut_form "ENDTILE\n")
  fprintf(clinecut_form "\n")
  fprintf(clinecut_form "ENDFORM\n")
  close(clinecut_form)
  ); end prog
); end defun
;###########################################################
;#                                                         #
;#               End of _createForm_clinecut               #
;#                                                         #
;###########################################################

(defun clinecut_info_createInfo ()
  clinecut_info_helpfile = "./clinecut_info_info.txt"
  clinecut_info_info = outfile(clinecut_info_helpfile "w")
  fprintf(clinecut_info_info "################################################################################\n")
  fprintf(clinecut_info_info "#                                                                              #\n")
  fprintf(clinecut_info_info "#                      Command: clinecut                                       #\n")
  fprintf(clinecut_info_info "#                   Skill File: clinecut.il                                    #\n")
  fprintf(clinecut_info_info "#                  How To Load: Command> (load(\"clinecut.il\"))                 #\n")
  fprintf(clinecut_info_info "#               How To Execute: Command> clinecut          OR                  #\n")
  fprintf(clinecut_info_info "#                                        clinecut [-]help  OR                  #\n")
  fprintf(clinecut_info_info "#                                        clinecut [-]h     OR                  #\n")
  fprintf(clinecut_info_info "#                                                                              #\n")
  fprintf(clinecut_info_info "#                       Author: Larry Bowman, Cadence Design Systems           #\n")
  fprintf(clinecut_info_info "#                        Email: bowman@cadence.com                             #\n")
  fprintf(clinecut_info_info "#                    Telephone: 512-349-1109                                   #\n")
  fprintf(clinecut_info_info "#                Creation Date: 11/21/2001                                     #\n")
  fprintf(clinecut_info_info "#                                                                              #\n")
  fprintf(clinecut_info_info "################################################################################\n")
  fprintf(clinecut_info_info "\n")
  fprintf(clinecut_info_info "################################################################################\n")
  fprintf(clinecut_info_info "#  DISCLAIMER:                                                                 #\n")
  fprintf(clinecut_info_info "#       The user of this command assumes all responsibility and does not       #\n")
  fprintf(clinecut_info_info "#       hold Cadence Design Systems nor the author of this code for any        #\n")
  fprintf(clinecut_info_info "#       unwarranted results or problems due to the use of this code.           #\n")
  fprintf(clinecut_info_info "#                                                                              #\n")
  fprintf(clinecut_info_info "#       This is non-supported code and the user may modify it as needed.       #\n")
  fprintf(clinecut_info_info "#                                                                              #\n")
  fprintf(clinecut_info_info "################################################################################\n")
  fprintf(clinecut_info_info "\n")
  fprintf(clinecut_info_info "################################################################################\n")
  fprintf(clinecut_info_info "#                                                                              #\n")
  fprintf(clinecut_info_info "# DESCRIPTION:                                                                 #\n")
  fprintf(clinecut_info_info "#      This program will cut cline segments based a user defined window        #\n")
  fprintf(clinecut_info_info "#      boundary.  The distance to cut will be based on the user's input        #\n")
  fprintf(clinecut_info_info "#      in the form.  This distance is always orthogonal to the boundary        #\n")
  fprintf(clinecut_info_info "#      line drawn by the user.                                                 #\n")
  fprintf(clinecut_info_info "#                                                                              #\n")
  fprintf(clinecut_info_info "#      A new subclass, CUTLINE, will be created under the MANUFACTURING class. #\n")
  fprintf(clinecut_info_info "#      This is used for a visual inspection of how the cline segments were     #\n")
  fprintf(clinecut_info_info "#      cut from the window drawn by the user.                                  #\n")
  fprintf(clinecut_info_info "#                                                                              #\n")
  fprintf(clinecut_info_info "#      The minimum cut distance is calculated to be twice the smallest         #\n")
  fprintf(clinecut_info_info "#      trace width in the design.  The maximum cut distance was arbitrarily    #\n")
  fprintf(clinecut_info_info "#      set to be 1 inch.                                                       #\n")
  fprintf(clinecut_info_info "#                                                                              #\n")
  fprintf(clinecut_info_info "#      This is a destructive operation so it may be wise to save the design    #\n")
  fprintf(clinecut_info_info "#      before issuing this command.  The algorithm looks at all cline segments #\n")
  fprintf(clinecut_info_info "#      that crosses the boundary lines.  It then deletes the original cline    #\n")
  fprintf(clinecut_info_info "#      segment and replaces it with two new cline segments.  The distance      #\n")
  fprintf(clinecut_info_info "#      between these new cline segments will be the orthogonal \"cut distance\"  #\n")
  fprintf(clinecut_info_info "#      as specified in the form.                                               #\n")
  fprintf(clinecut_info_info "#                                                                              #\n")
  fprintf(clinecut_info_info "#      If the new cline segment within the window boundary will be longer      #\n")
  fprintf(clinecut_info_info "#      than the original cline segment then only one cline segment will be     #\n")
  fprintf(clinecut_info_info "#      generated.  This one cline segment will end at the window boundary.     #\n")
  fprintf(clinecut_info_info "#                                                                              #\n")
  fprintf(clinecut_info_info "#      Thus if the \"Cut Distance\" is larger than the window boundary drawn     #\n")
  fprintf(clinecut_info_info "#      by the user than no cline segments will remain within the window        #\n")
  fprintf(clinecut_info_info "#      boundary.                                                               #\n")
  fprintf(clinecut_info_info "#                                                                              #\n")
  fprintf(clinecut_info_info "#      It is also possible as well as probable that there will be dangling     #\n")
  fprintf(clinecut_info_info "#      clines as a result of this operation.  That is there may be cline       #\n")
  fprintf(clinecut_info_info "#      segments without any net name association.  It is up to the user to     #\n")
  fprintf(clinecut_info_info "#      rectify this condition.                                                 #\n")
  fprintf(clinecut_info_info "#                                                                              #\n")
  fprintf(clinecut_info_info "#      This operation may also cause a Line-Line DRC violation.  Again, it     #\n")
  fprintf(clinecut_info_info "#      is the user's responsibility to correct this condition.                 #\n")
  fprintf(clinecut_info_info "#                                                                              #\n")
  fprintf(clinecut_info_info "################################################################################\n")
  fprintf(clinecut_info_info "\n")
  close(clinecut_info_info)
  axlUIViewFileCreate(clinecut_info_helpfile "Info" t list(82 20))
  deleteFile(clinecut_info_helpfile)
); end defun

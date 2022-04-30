; Written by: 	John Horner
;		Cadence Design Systems
;		horner@cadence.com
;
;		Run with Application: Allegro, APD
;		Tested against versions 11 and 12
;
; This routine will remove all Externally generated DRCs from the design
axlCmdRegister( "rmxdrc" `_jbhrmvallxDRCs)
; ########################################
; Define the routine to remove the markers
; ########################################
;
(defun _jbhrmvallxDRCs ()
 
   axlClearSelSet()
   axlDBRefreshId(axlDBGetDesign())
 
   ; ###############################
   ; Remove any existing DRC markers
   ; ###############################
 
   axlSetFindFilter( ?enabled '(noall drcs) ?onButtons '(drcs))
   Markers=axlGetSelSet(axlAddSelectAll())
   (foreach Drc Markers
      (if Drc->name == "Externally Determined Violation" then
            axlDeleteObject(Drc)
      ); end if Drc->name == "....
   ); end foreach Drc Markers
   axlFlushDisplay()
); end defun _jbhrmvallxDRCs



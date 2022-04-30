/*
################################################################################
#                                                                              #
#                      Command: cutshape                                       #
#                   Skill File: cutshape.il                                    #
#                  How To Load: Command> (load("cutshape.il"))                 #
#               How To Execute: Command> cutshape  or cutshape h               #
#                       Author: Larry Bowman, Cadence Design Systems           #
#                        Email: bowman@cadence.com                             #
#                    Telephone: 512-349-1109                                   #
#                Creation Date: 02/18/2004                                     #
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

################################################################################
#                                                                              #
#  This program is intended to split power rings in APD.                       #
#  In reality this program is going to 'ANDNOT all the shapes                  #
#  selected by the user based on the box drawn by the user.                    #
#                                                                              #
#  Thus this program may be used to cut any filled shape,                      #
#  such as soldermask shapes.                                                  #
#                                                                              #
#                                                                              #
################################################################################

################################################################################
#                                                                              #
#  Version 1.3 - August 2, 2004.                                               #
#    Getting axlPolyFromDB error message due to out of scope dbid. - Corrected.#
#                                                                              #
#                                                                              #
################################################################################

################################################################################
#                                                                              #
#  Version 1.2 - March 1, 2004.                                                #
#    Registered "splitring" as a command for this program as well.             #
#                                                                              #
#                                                                              #
################################################################################

################################################################################
#                                                                              #
#  Version 1.1 - February 19, 2004.                                            #
#    Added garbage collection function (gc) to release memory allocation.      #
#                                                                              #
#                                                                              #
################################################################################
*/


axlCmdRegister("cutshape" 'LCB_cutShape ?cmdType "interactive"
               ?doneCmd 'LCB_Done ?cancelCmd 'LCB_Cancel)
               
axlCmdRegister("splitring" 'LCB_cutShape ?cmdType "interactive"
               ?doneCmd 'LCB_Done ?cancelCmd 'LCB_Cancel)               


;################################################################################
;#                                                                              #
;#		Main Program  LCB_cutShape                                      #
;#                                                                              #
;################################################################################
procedure(LCB_cutShape(@optional (cutshapeargs ""))
 prog( (notdone LCBstartMark LCBpopup cutshapeversion)
  
  cutshapeversion = "Version 1.3 - August 2, 2004"
  
  unless(cutshapeargs == ""
   axlUIWPrint(nil "%s" cutshapeversion)
   axlUIWPrint(nil "-- To split a power ring, click and drag a rectangular window across the shape.")
   return(nil)
  ); end unless cutshapeargs
  
  unless(axlOKToProceed()
    return(nil)
  ); end unless
    
 axlSetFindFilter(?enabled list("noall" "shapes") 
                  ?onButtons list("noall" "shapes"))
 LCBpopup = axlUIPopupDefine( nil (list
    (list "Undo" 'LCB_unDo)
    (list "Done" 'LCB_Done)
    (list "Cancel" 'LCB_Cancel)
     ))
 axlUIPopupSet(LCBpopup)
    
    notdone = t
    LCBstartMark = axlDBTransactionStart()
    while(notdone
      LCB_getUserInput()
    ); end while
    
    
); end prog
); end procedure
;################################################################################
;#                                                                              #
;#		End of Main Program LCB_cutShape                                #
;#                                                                              #
;################################################################################


;################################################################################
;#                                                                              #
;#		LCB_getUserInput                                                #
;#                                                                              #
;################################################################################
procedure(LCB_getUserInput()
  prog( (cutbox lshapes lshapedbids lselshapes rectlayer rectcut shapelayer shapenet
         shapepoly splitpolylist shapecutlist rectcutpoly errmsg shapedbid)
  
    axlClearSelSet()
    
    
    cutbox = axlEnterBox(?prompts list(" - Left Click, Release, & Drag to start rectangular cut. -"
                                     " - Click to complete rectangular cut. -"))

    rectlayer = "substrate geometry/dimension"

    axlDBTransactionMark(LCBstartMark)
    when(cutbox
    
      ;; Create Rectangle as the area to remove from the shape.
      rectcut = car(axlDBCreateRectangle(cutbox nil rectlayer nil nil))
      rectcutpoly = axlPolyFromDB(rectcut)
      
      ;; Debug Print Statement   
      ;axlUIWPrint(nil "### User rectcutpoly is %L" rectcutpoly)
          
      axlSingleSelectBox(cutbox)
      lselshapes = axlGetSelSet()
      ;; get only  Filled Shapes and not Polygons (like component outline, etc.)
      lshapes = setof(shp lselshapes shp->objType == "shape")
      ;; Remove any shapes on the BOUNDARY class from the list.
      ;; This happened when creating Prings in 15.2
      lshapes = setof(shp lshapes nthelem(1 parseString(shp->layer "/")) != "BOUNDARY")
      ;; Debug Print Statement
      ;axlUIWPrint(nil "### Number of Shapes are %L" lshapes)
      if(lshapes then
        ;; do the cut
        foreach(shape lshapes
          if(shape->shapeBoundary then
            ;; we have a dynamic shape.
            shapedbid = shape->shapeBoundary
          else
            ;; we have a static shape.
            shapedbid = shape
          ); endif shape->shapeBoundary
          lshapedbids = cons(shapedbid lshapedbids)
          ;; Debug Print Statement
          ;axlUIWPrint(nil "### Shape dbid is %L" shapedbid)
          shapelayer = shapedbid->layer
          shapenet = shape->net->name
          shapepoly = axlPolyFromDB(shapedbid)
          ;; Debug Print Statement
          ;axlUIWPrint(nil "### ShapePoly is %L" shapepoly)
          splitpolylist = axlPolyOperation(shapepoly rectcutpoly 'ANDNOT)
          ;; Debug Print Statement
          ;axlUIWPrint(nil "###  SplitPolyList is %L" splitpolylist)
          if(! member(nil splitpolylist) then 
            ;; Debug Print Statement 
            ;axlUIWPrint(nil "*** lshapes before delete is %L" lshapes)
            ;; Debug Print Statement
            ;axlUIWPrint(nil "*** lshapes after delete is %L" lshapes)
            foreach(newpoly splitpolylist
             shapecutlist = axlDBCreateShape(newpoly t shapelayer shapenet nil)
             ;; Debug Print Statements
             ;axlUIWPrint(nil "### Shapecutlist is %L" shapecutlist)
             ;axlUIWPrint(nil "*** lshapes is now %L" lshapes)
             if(shapecutlist then
             	if(nthelem(2 shapecutlist) then
             	  axlUIWPrint(nil "-- Created DRC errors. Please Correct.")
             	else
                  axlUIWPrint(nil "-- No DRC errors.")
                ); endif cdr
             else
             	;; Oops out.
             	axlUIWPrint(nil "-- Error. Could not cut shape.")
             	axlDBTransactionOops(LCBstartMark)
             );endif shapecutlist
            ); end foreach newpoly
          else
            if(errmsg = axlPolyErrorGet() then
             axlUIWPrint(nil "-- Error. %L" errmsg)
            else
             axlUIWPrint(nil "-- Error. Cut area larger than shape. Try again.")
            ); endif errmsg
          ); endif splitpolylist
        ); end foreach shape
        
        ;; Do the delete of the original shape(s) after all the new ones were created.
        ;; This was necessary in version 15.2.  The list of dbids were going out of
        ;; scope when doing the delete command prior to creating the new shape.
        when(lshapedbids
          axlDeleteObject(lshapedbids)
        );; end when
 
      else
      	;; no shape selected
      	axlUIWPrint(nil "-- No Shape Selected. Try again.")
      ); end if lshapes
      
    ); end when cutbox
    
    ;; now remove the rectangle used to cut the shape
    when(rectcut
      axlDeleteObject(rectcut)                                   
    ); end when rectcut
  
   
  ); end prog
); end procedure
;################################################################################
;#                                                                              #
;#		End of LCB_getUserInput                                         #
;#                                                                              #
;################################################################################

;################################################################################
;#                                                                              #
;#		LCB_unDo                                                        #
;#                                                                              #
;################################################################################
procedure(LCB_unDo()
let( ()
  if(! axlDBTransactionOops(LCBstartMark) then
    axlUIWPrint(nil "-- Nothing Left To Undo. --")
  else
    axlUIWPrint(nil "")
    axlUIWPrint(nil "-- Restoring Shapes. --")
  ); endif
  axlClearSelSet()
)); end let procedure
;################################################################################
;#                                                                              #
;#		End of LCB_unDo                                                 #
;#                                                                              #
;################################################################################

;################################################################################
;#                                                                              #
;#		LCB_Cancel                                                      #
;#                                                                              #
;################################################################################
procedure(LCB_Cancel()
let( ()
  axlUIWPrint(nil "** Cancelled Program. **")
  axlDBTransactionRollback(LCBstartMark)
  notdone = nil
  axlClearSelSet()
  axlCancelEnterFun()
  ;; Release Memory Allocation
  gc()

)); end let procedure
;################################################################################
;#                                                                              #
;#		End of LCB_Cancel                                               #
;#                                                                              #
;################################################################################

;################################################################################
;#                                                                              #
;#		LCB_Done                                                        #
;#                                                                              #
;################################################################################
procedure(LCB_Done()
 let( ()
  axlUIWPrint(nil "- Done -")
  axlDBTransactionCommit(LCBstartMark)
  notdone = nil
  axlCancelEnterFun()
  ;; Release Memory Allocation
  gc()
   
)); end let and procedure
;################################################################################
;#                                                                              #
;#		End of LCB_Done                                                 #
;#                                                                              #
;################################################################################

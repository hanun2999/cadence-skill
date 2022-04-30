;---- Feb  6 11:57 96 day 75  -------------------------------------------
; draw_targets.il
; Revision 1.0: June 24,1994
; Revision 2.0: Feb 6,1996
; Allegro version 8, 10, and 11
; Written by:
;       Michael C. Day
;       Sr. CAD Designer
;	Convex Technology Center of Hewlett-Packard
;       E-mail day@convex.com
;       3000 Waterview Parkway
;	Richardson TX 75083
;
; Do you draw targets in your Allegro database in order to line up the paper/film
; plots to each other later? Then this skill code is for you, it will place three 
; targets consisting of a circle with a cross hair in it. 
;
; The targets are placed in the upper left, lower left, and lower right corners 
; of the board outline on BOARD GEOMETRY/TOOLING_CORNERS.  
;
; This SKILL code works off of the concept that:
; 1. The board outline is on the class BOARD GEOMETRY and subclass OUTLINE.
; 2. The board is laid out in units of mil's or inches.
;
; Install this file in to your master skill directory then add 
; load( "draw_targets.il") to the allegro.ilinit file in your pcbenv directory. 
; To start the command type in "draw targets" at the allegro command line.
;
;procedure(ld() load("draw_targets.il"))

axlCmdRegister( "draw targets" '_AddTargets)

procedure(_AddTargets()

; turn all colors off
  axlVisibleDesign(nil)
; turn color on for board outline and tooling corners
  axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t)  
  axlVisibleLayer("BOARD GEOMETRY/TOOLING_CORNERS" t)  
  axlShell("redisplay")
  
; start list
  setplist( 'll    '(x 0 y 0))
  setplist( 'ur    '(x 0 y 0))
  setplist( 'ul    '(x 0 y 0))
  setplist( 'lr    '(x 0 y 0))
  setplist( 'start '(x 0 y 0))
  setplist( 'end   '(x 0 y 0))
	
  axlSetFindFilter(?enabled (list "noall" "lines") ?onButtons (list "noall" "lines"))
  axlAddSelectAll()
  foreach(line axlGetSelSet()
     tmp = line
     when(line->layer == "BOARD GEOMETRY/OUTLINE"
	foreach(seg  line->segments
	   startEnd = seg->startEnd
	   start    = nthelem(1 startEnd)
	   end      = nthelem(2 startEnd)
	   start.x  = nthelem(1 start)
	   start.y  = nthelem(2 start)
	   end.x    = nthelem(1 end)
	   end.y    = nthelem(2 end)
	   
	   ll.x = min(ll.x start.x)
	   ll.y = min(ll.y start.y)
	   ll.x = min(ll.x end.x)
	   ll.y = min(ll.y end.y)
	   
	   ur.x = max(ur.x start.x)
	   ur.y = max(ur.y start.y)
	   ur.x = max(ur.x end.x)
	   ur.y = max(ur.y end.y)
	   
	   lr.x = max(lr.x start.x)
	   lr.y = min(lr.y start.y)
	   lr.x = max(lr.x end.x)
	   lr.y = min(lr.y end.y)
	   
	   ul.x = min(ul.x start.x)
	   ul.y = max(ul.y start.y)
	   ul.x = min(ul.x end.x)
	   ul.y = max(ul.y end.y)
	);end foreach
     );end when
  );foreach

  case(car(axlDBGetDesignUnits())
     ("inches" CircleCenterPoint = .500
      Line1Distance = .650
      Line2Distance = .350
      CirSize = .100
      LineWidth = .010
     )
     ("mils" CircleCenterPoint = 500
      Line1Distance = 650
      Line2Distance = 350
      CirSize = 100
      LineWidth = 10
     )
  ) ; ** case car **

; create Lower Left target		
  axlDBCreateLine( (list ll.x - Line1Distance:ll.y - CircleCenterPoint ll.x - Line2Distance:ll.y - CircleCenterPoint),
		   LineWidth "BOARD GEOMETRY/TOOLING_CORNERS",
		   nil)
  axlDBCreateLine( (list ll.x - CircleCenterPoint:ll.y - Line1Distance ll.x - CircleCenterPoint:ll.y - Line2Distance),
		   LineWidth "BOARD GEOMETRY/TOOLING_CORNERS",
		   nil)
  axlDBCreateCircle( (list ll.x - CircleCenterPoint:ll.y - CircleCenterPoint CirSize),
		     LineWidth,  "BOARD GEOMETRY/TOOLING_CORNERS")
  
; create Upper Left target		
  axlDBCreateLine( (list ul.x - Line1Distance:ul.y + CircleCenterPoint ul.x - Line2Distance:ul.y + CircleCenterPoint),
		   LineWidth "BOARD GEOMETRY/TOOLING_CORNERS",
		   nil)
  axlDBCreateLine( (list ul.x - CircleCenterPoint:ul.y + Line1Distance ul.x - CircleCenterPoint:ul.y + Line2Distance),
		   LineWidth "BOARD GEOMETRY/TOOLING_CORNERS",
		   nil)
  axlDBCreateCircle( (list ul.x - CircleCenterPoint:ul.y + CircleCenterPoint CirSize),
		     LineWidth,  "BOARD GEOMETRY/TOOLING_CORNERS")
  
; create Lower Right left target		
  axlDBCreateLine( (list lr.x + Line1Distance:lr.y - CircleCenterPoint lr.x + Line2Distance:lr.y - CircleCenterPoint),
		   LineWidth "BOARD GEOMETRY/TOOLING_CORNERS",
		   nil)
  axlDBCreateLine( (list lr.x + CircleCenterPoint:lr.y - Line1Distance lr.x + CircleCenterPoint:lr.y - Line2Distance),
		   LineWidth "BOARD GEOMETRY/TOOLING_CORNERS",
		   nil)
  axlDBCreateCircle( (list lr.x + CircleCenterPoint:lr.y - CircleCenterPoint CirSize),
		     LineWidth,  "BOARD GEOMETRY/TOOLING_CORNERS")
) ; ** procedure  **




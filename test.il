/* 
├─ 
│ ├─        程序名称：quick_grids
│ ├─        程序功能：快速切换格点，方便设计
│ ├─        创建时间：2014年4月23日 
│ ├─        作    者：kevin wong
│ ├─        Q      Q：263350809
├─ 


1，2013.12.11基本功能基于“grids”设置修改；

*/ 

axlCmdRegister( "quick_grids" `Quick_Grids)

axlSetFunckey("sg" "quick_grids")

/* ---------------------------------
define main function
--------------------------------- */

; load("quick_grids.il")


defun( Quick_Grids ()
	   GridsZoomListmil = '(1 5 10 20 50 100)
	   GridsZoomListmm = '(0.05 0.1 0.25 0.5 1 2.5)
       curdsn_unit = axlGetParam("paramDesign")->units
		gridsetform()
	   )

defun( gridsetform ()
	  let( ()
        GridFormfile = "GridForm.form"
		formport = outfile(GridFormfile "w")
		fprintf(formport "FILE_TYPE=FORM_DEFN VERSION=2\n")
        fprintf(formport "FORM\n") 
        fprintf(formport "FIXED\n")
        fprintf(formport "PORT 42 6\n")
        fprintf(formport "HEADER \"Grids\"\n")
        fprintf(formport "TILE\n")
		
		fprintf(formport "\n")
		fprintf(formport "TEXT \"mil:\"\n")
		fprintf(formport "TLOC 2 1\n")
		fprintf(formport "ENDTEXT\n")
		
		fprintf(formport "\n")
		fprintf(formport "TEXT \"mm:\"\n")
		fprintf(formport "TLOC 2 3\n")
		fprintf(formport "ENDTEXT\n")
		
        a = 6
		foreach(curgird GridsZoomListmil  
        fprintf(formport "FIELD %L_mil\n" curgird)
        fprintf(formport "FLOC %d 1\n" a)
        fprintf(formport "FGROUP \"displayunit\"\n")
        fprintf(formport "CHECKLIST %L\"displayunit\"\n" curgird)
        fprintf(formport "ENDFIELD\n")
		a = a+6
		       )      
	  
        a = 6
		foreach(curgird GridsZoomListmm 
        fprintf(formport "FIELD %L_mm\n" curgird)
        fprintf(formport "FLOC %d 3\n" a)
        fprintf(formport "FGROUP \"displayunit\"\n")
        fprintf(formport "CHECKLIST %L\"displayunit\"\n" curgird)
        fprintf(formport "ENDFIELD\n")
		a = a+6
		       )  	  
	  
	  
	  fprintf(formport "ENDTILE\n")
      fprintf(formport "ENDFORM\n") 
	  
      close(formport)
	  displaygrdform = axlFormCreate((gensym) GridFormfile '(se inner) 'Grid_act t)
	  axlFormDisplay(displaygrdform)
	  deleteFile("GridForm.form")	  
	  ))
	  
	  
	  ; axlFormMsg(displaygrdform "abc")
	   
defun( Grid_act (displaygrdform)

      grid_set = displaygrdform->curField 
	  setgrid = atof(car(parseString(grid_set "_")))
	  
	  if(car(reverse(parseString(grid_set "_"))) == "mil"
	  then

		   case(curdsn_unit
	        ("mils"  setgrid)
		    ("millimeters" setgrid = setgrid/39.37)
			("inches" setgrid = setgrid/1000)
			("centimeters" setgrid = setgrid/393.7)
			("microns" setgrid = setgrid* 25.4 )
		      )
	  SetCurGrid(setgrid)
	  else
	  if(car(reverse(parseString(grid_set "_"))) == "mm"
	  then	  
	  ; setgrid = atof(car(parseString(grid_set "_")))	  
		   case(curdsn_unit
	        ("mils"  setgrid = setgrid* 39.37)
		    ("millimeters" setgrid)
			("inches" setgrid = setgrid* 0.03937)
			("centimeters" setgrid = setgrid/10)
			("microns" setgrid = setgrid* 1000)
		      )    
	  SetCurGrid(setgrid)
	     )
	    )

	  )

; load("quick_grids.il")
	  
; defun( Grid_act (displaygrdform)
       ; SetCurGrid(5)
	   ; )	  
	   
defun( SetCurGrid (gridnum)	  
	  grid = axlDBGridGet("TOP")
	  grid->name = 'all
	  grid->xGrids = gridnum
	  grid->yGrids = gridnum
	  axlDBGridSet(grid)
	  ) 
	   
	   
	   
	   
	   
	   
	   
	   

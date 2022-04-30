; Thanks for Uri Chaplin, modify/add some func to support grids control better.
; Richard L.:  fpmontreal@gmail.com
;---------------------------------
; Program Name: grids.il
; Author:	Uri Chaplin, chaplin_u@email.com
;  1.0	01-March-04 UC	Created.
;  2.0  17-March-04 UC  Added feature to enable using different db units
;  2.1  21-March-04 UC  Improvements
;  2.2? 04-Nov-04   RichardL. add/modified some funcs to make it better
;  2.2? 15-Sept-07  RichardL. fit for FPM project
;---------------------------------

; two global var, (not good idea, but...) you can change what ever you want

GridsZoomList='(1 2 4 5 10 20  50 100 1000) 
GridsZoomName=nil

/* ---------------------------------
CreateFormForGrids()
--------------------------------- */
defun(CreateFormForGrids (units)
	MainFormFile=axlTempFile()
	p=outfile(MainFormFile "w")

	GridsZoomName=nil
	for(i 0 length(GridsZoomList)-1
		sprintf(filename,"%g",cnv_factor/nth(i GridsZoomList))
		GridsZoomName=cons(filename,GridsZoomName)
	)

	totalWidth=0
	for(i 0 length(GridsZoomName)-1
		totalWidth=totalWidth+strlen(nth(i GridsZoomName))+3
	)
	
	sprintf(title,"GridsA - by Richard L.    %s",units)
	f_FormBegin(p totalWidth,0,title,"TOOLWINDOW")
	xpos=0
	for(i 0 length(GridsZoomList)-1
		f_CheckList(p nth(i GridsZoomName) xpos 0 nth(i GridsZoomName) "gg")
		xpos=xpos+strlen(nth(i GridsZoomName))+3
	)
	f_FormEnd(p)

	close(p)
	MainFormFile
)
defun(grids ()

units=car(axlDBGetDesignUnits())
	cond(
		(equal(units "microns") 	(cnv_factor=1000.00))
		(equal(units "mils") 		  (cnv_factor=100.00))
		(equal(units "inches") 		(cnv_factor=0.10))
		(equal(units "millimeters") (cnv_factor=1.0))
		(equal(units "centimeters") (cnv_factor=0.254))
	)

	drain()
	gform_file=CreateFormForGrids(units)
	gridsform=axlFormCreate((gensym) gform_file '("NE" "msglines" 0) 'g_Action t nil)
	axlUIWPerm(gridsform t)
	axlFormDisplay(gridsform)
	deleteFile(gform_file)
)

defun(g_Action (gridsform)
	for(i 0 length(GridsZoomList)-1
		if(evalstring(gridsform->curField)==cnv_factor/nth(i GridsZoomList) 
		UC_grids_script_create(cnv_factor/nth(i GridsZoomList)) 	
		)
	)
)


defun(UC_grids_script_create (cur_grid )
	ScriptFileName=axlTempFile()
	Script_File=outfile(ScriptFileName "w")
	fprintf(Script_File "scriptmode +i\n")
	fprintf(Script_File "define grid \nsetwindow form.grid\n")
	fprintf(Script_File "FORM grid non_etch non_etch_x_grids %n \n" cur_grid)
	fprintf(Script_File "FORM grid non_etch non_etch_y_grids %n \n" cur_grid)
	fprintf(Script_File "FORM grid all_etch all_etch_x_grids %n \n" cur_grid)
	fprintf(Script_File "FORM grid all_etch all_etch_y_grids %n \n" cur_grid)
	fprintf(Script_File "FORM grid done\n")
	close(Script_File)
	sprintf(runScript,"replay %s",ScriptFileName)
	axlShell(runScript)
	axlUIWPrint(gridsform axlPPrint(units)) 
	deleteFile(ScriptFileName)
)

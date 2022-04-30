axlCmdRegister("~2" 'diff_Check_Routine ?cmdType "interactive")
defun(diff_Check_Routine ()
; sets variables
;boardname = axlCurrentDesign() 
	;units = axlDBGetDesignUnits()
	;units = car(units)


  ; Clear the variables
  ; ###################
  i=0 ii=0 i3=0 i4=0
  pad1=nil pad2=nil pad3=nil pad4=nil pad5=nil pad6=nil pad7=nil pad8=nil
	c=nil cc=nil c3=nil c4=nil
	b=nil bb=nil b3=nil b4=nil
  d1=nil d2=nil d3=nil d4=nil
  pp_top_db=nil pp_bot_db=nil osp_top_db=nil osp_bot_db=nil
  osp_top_list=nil osp_bot_list=nil
  kk=nil k=nil k3=nil k4=nil
  m=nil mm=nil m3=nil m4=nil
  nn=nil n=nil n3=nil n4=nil
  Date=(getCurrentTime); This variable records the date for the log file
  real_pp_top_list=nil
  real_pp_bot_list=nil
  real_osp_top_list=nil
  real_osp_bot_list=nil
  r=0 e=nil g1=nil
  r2=0 e2=nil  g2=nil

	; selects pins
	; ------------

	axlClearSelSet()
	vis_list = axlVisibleGet()
	axlVisibleDesign(nil)
	axlVisibleLayer("PIN/PASTEMASK_TOP" t)
	axlSetFindFilter(?enabled list("noall" "pins") ?onButtons list("noall" "pins"))
	axlVisibleLayer("PIN/SOLDERMASK_TOP" t)
	axlSetFindFilter(?enabled list("noall" "pins")  ?onButtons list("noall" "pins"))
	axlAddSelectAll()
	pp_top_list = axlGetSelSet()
	

   ; Open the log file and print the header info
   ; ###########################################
   	diff_Log_File=outfile("./diff.log" "w")
  	fprintf(diff_Log_File "\n\n\n\t%s\n\n" Date)
  	fprintf(diff_Log_File "\t\tdiff Logfile\n")
  	fprintf(diff_Log_File "Without pastemask at top\n")
   ; Check if there are any diff. and update the log file
	;####################
	foreach(pp_top_db pp_top_list
	k=pp_top_db->parent->refdes	
	if(k!=nil&&pp_top_db->isThrough==nil&&substring(pp_top_db->parent->refdes 1 3)!="KSW" then
		real_pp_top_list=cons(pp_top_db real_pp_top_list)
			);end if
			);end foreach
;##################
	foreach(pp_top_db real_pp_top_list
	pad1=axlDBGetPad(pp_top_db "pin/pastemask_top" "regular")
	m=pad1-> figureName
	pad3=axlDBGetPad(pp_top_db "pin/soldermask_top" "regular")
	n=pad3-> figureName
	c=pp_top_db->parent
	b=c->refdes
	x=equal(m n)
	if(x==nil then i=i+1
		d1=cons(pp_top_db d1) 
		fprintf(diff_Log_File "\t%n %s %L\n" i b pp_top_db->xy)
		);end if
		);end foreach
			if(d1==nil then
	fprintf(diff_Log_File "\t No difference Found\n")
			);end if
 
;####################
  axlClearSelSet() 
	axlVisibleDesign(nil) 
  axlVisibleLayer("PIN/PASTEMASK_BOTTOM" t) 
	axlSetFindFilter(?enabled list("noall" "pins")  ?onButtons list("noall" "pins")) 
	axlVisibleLayer("PIN/SOLDERMASK_BOTTOM" t)
	axlSetFindFilter(?enabled list("noall" "pins")   ?onButtons list("noall" "pins"))  
	axlAddSelectAll() 
	pp_bot_list = axlGetSelSet()
;##################
foreach(pp_bot_db pp_bot_list
	kk=pp_bot_db->parent->refdes
	if(kk!=nil&&pp_bot_db->isThrough==nil&&substring(pp_bot_db->parent->refdes 1 3)!="KSW" then
		real_pp_bot_list=cons(pp_bot_db real_pp_bot_list)
			);end if
			);end foreach
;##############
fprintf(diff_Log_File "\n\nWithout pastemask at BOT\n") 
foreach(pp_bot_db real_pp_bot_list
	pad2=axlDBGetPad(pp_bot_db "pin/pastemask_bottom" "regular")
	mm=pad2-> figureName
	pad4=axlDBGetPad(pp_bot_db "pin/soldermask_bottom" "regular")
	nn=pad4-> figureName
	cc=pp_bot_db->parent
	bb=cc->refdes
	xx=equal(mm nn)
	if(xx==nil then ii=ii+1
		d2=cons(pp_bot_db d2)
		fprintf(diff_Log_File "\t%n %s %L\n" ii bb pp_bot_db->xy)
		);end if
		);end foreach
		
		if(d2==nil then
	fprintf(diff_Log_File "\t No difference Found\n")
		);end if
;###################
  axlClearSelSet()
	vis_list = axlVisibleGet()
	axlVisibleDesign(nil)
	axlVisibleLayer("PIN/FILMMASKTOP" t)
	axlSetFindFilter(?enabled list("noall" "pins") ?onButtons list("noall" "pins"))
	axlVisibleLayer("PIN/SOLDERMASK_TOP" t)
	axlSetFindFilter(?enabled list("noall" "pins")  ?onButtons list("noall" "pins"))
	axlAddSelectAll()
	osp_top_list = axlGetSelSet()
	fprintf(diff_Log_File "\n\nWithout OSP at top\n")
; Check if there are any diff. and update the log file
;####################
	foreach(osp_top_db osp_top_list
	k3=osp_top_db->parent->refdes
	if(k3!=nil&&osp_top_db->isThrough==nil&&substring(osp_top_db->parent->refdes 1 3)!="KSW" then
		real_osp_top_list=cons(osp_top_db real_osp_top_list)
			);end if
			);end foreach
;##################
	foreach(osp_top_db real_osp_top_list
	pad5=axlDBGetPad(osp_top_db "pin/FILMMASKTOP" "regular")
	m3=pad5-> figureName
	pad6=axlDBGetPad(osp_top_db "pin/soldermask_top" "regular")
	n3=pad6-> figureName
	c3=osp_top_db->parent
	b3=c3->refdes
	x3=equal(m3 n3)
	if(x3==nil then i3=i3+1
		d3=cons(osp_top_db d3) 
		fprintf(diff_Log_File "\t%n %s %L\n" i3 b3 osp_top_db->xy)
		);end if
		);end foreach
		
		if(d3==nil then
	fprintf(diff_Log_File "\t No difference Found\n")
		);end if
;############
  axlClearSelSet()
	vis_list = axlVisibleGet()
	axlVisibleDesign(nil)
	axlVisibleLayer("PIN/filmmaskbottom" t)
	axlSetFindFilter(?enabled list("noall" "pins") ?onButtons list("noall" "pins"))
	axlVisibleLayer("PIN/SOLDERMASK_BOTTOM" t)
	axlSetFindFilter(?enabled list("noall" "pins")  ?onButtons list("noall" "pins"))
	axlAddSelectAll()
	osp_bot_list = axlGetSelSet()
	fprintf(diff_Log_File "\n\nWithout OSP at BOT\n")
; Check if there are any diff. and update the log file
;####################
	foreach(osp_bot_db osp_bot_list
	k4=osp_bot_db->parent->refdes
	if(k4!=nil&&osp_bot_db->isThrough==nil&&substring(osp_bot_db->parent->refdes 1 3)!="KSW" then
		real_osp_bot_list=cons(osp_bot_db real_osp_bot_list)
			);end if
			);end foreach
;##################
	foreach(osp_bot_db real_osp_bot_list
	pad7=axlDBGetPad(osp_bot_db "pin/filmmaskbottom" "regular")
	m4=pad7-> figureName
	pad8=axlDBGetPad(osp_bot_db "pin/soldermask_bottom" "regular")
	n4=pad8-> figureName
	c4=osp_bot_db->parent
	b4=c4->refdes
	x4=equal(m4 n4)
	if(x4==nil then i4=i4+1
		d4=cons(osp_bot_db d4) 
		fprintf(diff_Log_File "\t%n %s %L\n" i4 b4 osp_bot_db->xy)
		);end if
		);end foreach
		
		if(d4==nil then
	fprintf(diff_Log_File "\t No difference Found\n")
		)
;############
	fprintf(diff_Log_File "\n\nNOT MOBILE SYMBOL AT TOP\n")
	foreach(pp_top_db pp_top_list
	e=pp_top_db->parent->name
	f=substring(e strlen(e) 1)
	if(f!="M" then r=r+1
		g1=cons(pp_top_db g1)
		fprintf(diff_Log_File "\t%n %s %L\n" r pp_top_db->parent->refdes pp_top_db->xy)
		);end end if
		);end foreach
	if(g1==nil then
		fprintf(diff_Log_File "\tNothing Found\n")
		);end if
	
		axlClearSelSet() 
;##############
fprintf(diff_Log_File "\n\nNOT MOBILE SYMBOL at BOT\n")
foreach(pp_bot_db pp_bot_list
	e2=pp_bot_db->parent->name
	f2=substring(e2 strlen(e2) 1)
	if(f2!="M" then r2=r2+1
		g2=cons(pp_bot_db g2)
		fprintf(diff_Log_File "\t%n %s %L\n" r2 pp_bot_db->parent->refdes pp_bot_db->xy)
		);end end if
		);end foreach
	if(g2==nil then
		fprintf(diff_Log_File "\tNothing Found\n")
		);end if
	
	   ; Close the log file, refresh the graphics, and open a viewlog
   ; ############################################################
  axlClearSelSet() 
  axlHighlightObject(d1) 
  axlHighlightObject(d2)
  axlHighlightObject(d3)
  axlHighlightObject(d4)
  axlHighlightObject(g1)
  axlHighlightObject(g2)
  close(diff_Log_File) 
	axlShell("redisplay")
  axlShell("viewlog ./diff.log")
	); end defun diff_Check_Routine

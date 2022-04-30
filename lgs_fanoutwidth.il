axlCmdRegister( "ch_fanoutwidth" `lgs  ?cmdType "general")

setq( lgslinewidthform "./lgslinewidth.form")


(defun lgs ()
lgs_change_allnet = 1
lgs_belgs_select_net_list = nil
lgs_beselect_net_list_name = nil
lgs_select_net_list = nil		;id width percent allnet
pick_net_mode = t
lgs_select_net_id = nil
lgs_select_net_width = 15.00
lgs_select_net_percent = 100.00
lgs_net_filter = "*"

_lgs_Build_linewidth_Form()		;build form



axlFormSetField( linewidth_form "width_filter" lgs_net_filter)
_lgs_mach_net()
axlFormSetField( linewidth_form "width_netlist" lgs_beselect_net_list_name)
axlFormSetField( linewidth_form "width_net_width" lgs_select_net_width)
axlFormSetField( linewidth_form "width_net_percent" lgs_select_net_percent)
axlFormSetField( linewidth_form "width_allnet" lgs_change_allnet)


_lgs_pick_net()

)
;=========================================================================
;=========================================================================
(defun _lgs_mach_net ()
lgs_beselect_net_list = nil
lgs_beselect_net_list_name = nil
axlSetFindFilter(?enabled '(noall nets) ?onButtons '(noall nets))
lgs_beselect_net_list = axlGetSelSet(axlSingleSelectName("NET" lgs_net_filter))
axlClearSelSet()
;lgs_beselect_net_list = axlDBGetDesign()->nets
foreach(lgstemp lgs_beselect_net_list
	lgs_beselect_net_list_name = append(lgs_beselect_net_list_name list(lgstemp->name))
	);end foreach
;????????????????????????????????????????????????????????????????????????????????

);
;=========================================================================
(defun _lgs_pick_net ()
lgs_pick_net_i = 0
while((pick_net_mode == t)
axlClearSelSet()
axlSetFindFilter(?enabled '(noall Nets) ?onButtons '(noall Nets))
axlAddSelectPoint()
lgs_select_net_id = car( axlGetSelSet())
axlClearSelSet()
if(lgs_select_net_id == nil
then
	if(lgs_pick_net_i == 1
	then
		if(axlUIYesNo("no net find,are you go on?") == nil
		then
			pick_net_mode = nil
		);end if
	else
		lgs_pick_net_i++
	);end if
else
	lgs_pick_net_i = 0
	_lgs_back_add()
);end if
;axlFormSetField( linewidth_form "width_selectnet" lgs_select_net_id ~> name)

);end while
);end defun _lgs_pick_net ()

;=========================================================================





(defun _lgs_line_width_ok ()
pick_net_mode = nil
axlShell("done")
if(length( lgs_select_net_list) > 3
then

	;for(i 1 length( lgs_select_net_list)/4

		;lgs_temp_net_id = nthelem(i*4-3 lgs_select_net_list)
		;lgs_temp_net_width = nthelem(i*4-2 lgs_select_net_list)
		;lgs_temp_net_percent = nthelem(i*4-1 lgs_select_net_list)
		;lgs_temp_net_allnet = nthelem(i*4 lgs_select_net_list)

_ljj_chwidth( lgs_select_net_list)

;lgs_select_net_list
	  ; );end for
);end if(length( lgs_select_net_list) > 3
axlFormClose( linewidth_form)
);end defun _lgs_line_width_ok ()

;=========================================================================
(defun _lgs_pick_net_mode ()
pick_net_mode = linewidth_form->curValueInt


);end defun _lgs_pick_net_mode ()
;=========================================================================
(defun _lgs_back_add ()
;axlMsgPut("here")
if( (lgs_select_net_id != nil)&&(length( lgs_select_net_list)>3)
  then
  	j = 0
  	lgstemplist = nil
  	foreach(lgstemp lgs_select_net_list
  		if(j == 0
  		   then
  		     	if(lgstemp == lgs_select_net_id
  		     	  then
  		     	  	j = 3
  		     	  else
  		     	  	lgstemplist = append(lgstemplist list( lgstemp))
  		     	  );end if
  		   else
  		   	j--
  		   );end if

  	   );end for

lgs_select_net_list = lgstemplist

;_lgs_redraw_select_netlist()

);end if


if(lgs_select_net_id != nil
  then
  	axlHighlightObject( list(lgs_select_net_id))
	lgs_select_net_list = cons( lgs_change_allnet lgs_select_net_list)
	lgs_select_net_list = cons( lgs_select_net_percent lgs_select_net_list)
	lgs_select_net_list = cons( lgs_select_net_width lgs_select_net_list)
	lgs_select_net_list = cons( lgs_select_net_id lgs_select_net_list)

);end if

_lgs_redraw_select_netlist()

);end defun _lgs_back_add ()
;=========================================================================
(defun _lgs_back_del ()
if( (lgs_select_net_id != nil)&&(length( lgs_select_net_list)>3)
  then
  	j = 0
  	lgstemplist = nil
  	foreach(lgstemp lgs_select_net_list
  		if(j == 0
  		   then
  		     	if(lgstemp == lgs_select_net_id
  		     	  then
  		     	  	j = 3
  		     	  else
  		     	  	lgstemplist = append(lgstemplist list( lgstemp))
  		     	  );end if
  		   else
  		   	j--
  		   );end if

  	   );end for

lgs_select_net_list = lgstemplist

_lgs_redraw_select_netlist()

);end if
);end defun _lgs_back_del ()


;=========================================================================
(defun _lgs_redraw_select_netlist ()

lgstemplist = nil
if(length( lgs_select_net_list) > 3
  then
  for(i 1 length( lgs_select_net_list)/4
  	lgstemp1 = strcat( 	nthelem(i*4-3 lgs_select_net_list)->name
  				;"----"
  				;sprintf(lgstemp "%1.1f" nthelem(i*4-2 lgs_select_net_list))
  				;"mil--"
  				;sprintf(lgstemp "%1.0f" nthelem(i*4-1 lgs_select_net_list))
  				;"%--"
  				;sprintf(lgstemp "%d" nthelem(i*4 lgs_select_net_list))
  	      		);end strcat
	lgstemplist = append(lgstemplist list(lgstemp1))
      );end for
  );end if
  axlFormListDeleteAll( linewidth_form "width_selectnet_list")
  axlFormSetField( linewidth_form "width_selectnet_list" lgstemplist)
  axlFormSetField( linewidth_form "width_selectnet_list" nil)
  axlFormSetField( linewidth_form "width_selectnet"  "")
  lgs_select_net_id = nil


);end defun _lgs_redraw_select_netlist ()
;=========================================================================
;=========================================================================
(defun lgs_repCallback (linewidth_form)
case(linewidth_form->curField

	("width_filter"
		lgs_net_filter = linewidth_form->curValue
		_lgs_mach_net()
		axlFormListDeleteAll( linewidth_form "width_netlist")
		axlFormSetField( linewidth_form "width_netlist" lgs_beselect_net_list_name)
		axlFormListDeleteAll( linewidth_form "")
	t)

	("width_netlist"
		lgs_select_net_id = nthelem( linewidth_form->curValueInt+1 lgs_beselect_net_list)
		;axlFormSetField( linewidth_form "width_selectnet" lgs_select_net_id ~> name)
		_lgs_back_add()
	t)

	("width_selectnet_list"
		lgs_select_net_id = nthelem( (linewidth_form->curValueInt+1)*4-3 lgs_select_net_list)
		_lgs_back_del()

	t)

	("ok"
		_lgs_line_width_ok()
	t)


	("cancel"
		pick_net_mode = nil
		axlShell("done")
		axlFormClose( linewidth_form)
	t)

    );end case
)





;=========================================================================
(defun _lgs_Build_linewidth_Form ()
        deleteFile( lgslinewidthform)
        LINEWIDTHFORMFILE = outfile( lgslinewidthform)
        fprintf( LINEWIDTHFORMFILE "#LINE WIDTH FROM FILE		\n")
        fprintf( LINEWIDTHFORMFILE "#WRITE BY LIGUANGSHENG HUAWEI 24445 \n")
        fprintf( LINEWIDTHFORMFILE "FILE_TYPE=FORM_DEFN VERSION=2       \n")
        fprintf( LINEWIDTHFORMFILE "FORM                                \n")
        fprintf( LINEWIDTHFORMFILE "FIXED                               \n")
        fprintf( LINEWIDTHFORMFILE "PORT 28 70                          \n")
        fprintf( LINEWIDTHFORMFILE "HEADER \"Change Line Width\"        \n")
        fprintf( LINEWIDTHFORMFILE "TILE                                \n")
        fprintf( LINEWIDTHFORMFILE "                                    \n")
        fprintf( LINEWIDTHFORMFILE "GROUP \"Net List\"                  \n")
        fprintf( LINEWIDTHFORMFILE "FLOC 1 0                            \n")
        fprintf( LINEWIDTHFORMFILE "FSIZE 27 19                         \n")
        fprintf( LINEWIDTHFORMFILE "INFO group                          \n")
        fprintf( LINEWIDTHFORMFILE "ENDGROUP                            \n")
        fprintf( LINEWIDTHFORMFILE "                                    \n")
        fprintf( LINEWIDTHFORMFILE "TEXT \"Filter:\"                    \n")
        fprintf( LINEWIDTHFORMFILE "TLOC 2 2                            \n")
        fprintf( LINEWIDTHFORMFILE "ENDTEXT                             \n")
        fprintf( LINEWIDTHFORMFILE "                                    \n")
        fprintf( LINEWIDTHFORMFILE "FIELD width_filter                  \n")
        fprintf( LINEWIDTHFORMFILE "FLOC 7 2                            \n")
        fprintf( LINEWIDTHFORMFILE "STRFILLIN 18 15                     \n")
        fprintf( LINEWIDTHFORMFILE "ENDFIELD                            \n")
        fprintf( LINEWIDTHFORMFILE "                                    \n")
        fprintf( LINEWIDTHFORMFILE "FIELD width_netlist                 \n")
        fprintf( LINEWIDTHFORMFILE "FLOC 2 5                            \n")
        fprintf( LINEWIDTHFORMFILE "LIST \"\" 25 7                      \n")
        fprintf( LINEWIDTHFORMFILE "ENDFIELD                            \n")
        fprintf( LINEWIDTHFORMFILE "                                    \n")
        fprintf( LINEWIDTHFORMFILE "GROUP \"Change Net\"                \n")
        fprintf( LINEWIDTHFORMFILE "FLOC 1 19                           \n")
        fprintf( LINEWIDTHFORMFILE "FSIZE 27 16                         \n")
        fprintf( LINEWIDTHFORMFILE "INFO group                          \n")
        fprintf( LINEWIDTHFORMFILE "ENDGROUP                            \n")
        fprintf( LINEWIDTHFORMFILE "                                    \n")
        fprintf( LINEWIDTHFORMFILE "                                    \n")
        fprintf( LINEWIDTHFORMFILE "FIELD width_selectnet_list          \n")
        fprintf( LINEWIDTHFORMFILE "FLOC 2 21                           \n")
        fprintf( LINEWIDTHFORMFILE "LIST \"\" 25 7                      \n")
        fprintf( LINEWIDTHFORMFILE "ENDFIELD                            \n")
        fprintf( LINEWIDTHFORMFILE "                                    \n")
        fprintf( LINEWIDTHFORMFILE "                                    \n")
        fprintf( LINEWIDTHFORMFILE "                                    \n")
        fprintf( LINEWIDTHFORMFILE "FIELD ok                            \n")
        fprintf( LINEWIDTHFORMFILE "FLOC 2 36                           \n")
        fprintf( LINEWIDTHFORMFILE "MENUBUTTON \"OK\" 10 3              \n")
        fprintf( LINEWIDTHFORMFILE "ENDFIELD                            \n")
        fprintf( LINEWIDTHFORMFILE "                                    \n")
        fprintf( LINEWIDTHFORMFILE "FIELD cancel                        \n")
        fprintf( LINEWIDTHFORMFILE "FLOC 16 36                          \n")
        fprintf( LINEWIDTHFORMFILE "MENUBUTTON \"Cancel\" 8 3           \n")
        fprintf( LINEWIDTHFORMFILE "ENDFIELD                            \n")
        fprintf( LINEWIDTHFORMFILE "                                    \n")
        fprintf( LINEWIDTHFORMFILE "ENDTILE                             \n")
        fprintf( LINEWIDTHFORMFILE "ENDFORM                             \n")
        close( LINEWIDTHFORMFILE)
        linewidth_form = (axlFormCreate (gensym) lgslinewidthform `("E" "OUTER") `lgs_repCallback t)
        axlFormDisplay( linewidth_form)
);end _lgs_Build_linewidth_Form ()


;=========================================================================
;=========================================================================
;=========================================================================
;=========================================================================
(defun _ljj_chwidth ( netpara)
	ch_width = 0
	llx = 0
	lly = 0
	ury = 0
	urx = 0

	;ch_Percent = 0.66
	ch_Maxwidth = 25
	ch_alllines = 0
	Min_width = 15
	templist = nil
 	top_list =  nil
	botm_list = nil
	linelist =  nil
	ch_netnamelst = nil
	if(length( netpara) > 3
		then
		n =0
		ch_file=outfile("./ch_fanoutwidth.log" "w")
		;Get change Data from netpara
		for(m 1 length( netpara)/4
			ch_net = nthelem(m*4-3  netpara)
			;ch_Maxwidth = 25
			;ch_Percent = nthelem(m*4-1  netpara)/100
	 		;ch_alllines = nthelem(m*4  netpara)
			if( ch_alllines == 1
				then
				ch_Maxwidth = fix( ch_Maxwidth)
				templist =list( ch_Maxwidth ch_net->name)
				ch_netnamelst=cons(templist ch_netnamelst )
			);end of if( ch_alllines ==1
			fprintf(ch_file "\nChange fanout linewidth and  Minwidth is 15 mils\n")
			fprintf(ch_file "\n++++++NET: %s++++++ \n" ch_net->name)
			foreach(ch_branch ch_net->branches 	;n1=0 ++n ch_branch=nthelem(n ch_net->branches)
				foreach(ch_children ch_branch->children ;m1=0 ++m ch_children=nthelem(m ch_branch->children)
					if( ch_children->objType == "pin" && ch_children->isThrough== nil && ch_children->startEnd == '("ETCH/TOP" "ETCH/TOP")
						then
						xpoint_x = nthelem(1 ch_children->xy)
						xpoint_y = nthelem(2  ch_children->xy)
						foreach(temppad ch_children->definition->pads
							if(temppad->layer=="ETCH/TOP" && temppad->figureName!="NULL" && temppad->figure!=nil && temppad->type=="REGULAR"
								then
								bBox=temppad->bBox
								llx = caar( bBox)
								lly = cadar( bBox)
								urx = caadr( bBox)
								ury = cadadr( bBox)
								ch_width = min( abs( urx - llx)  abs( ury - lly ))
								ch_width = if(ch_width<=Min_width ch_width-Min_width ch_width*2/3)
								ch_width = if(ch_width >=ch_Maxwidth ch_Maxwidth ch_width)
								ch_width = if(ch_width >=Min_width*2/3 && ch_width<Min_width Min_width ch_width)
								ch_width = if(ch_width<=0 ch_width+Min_width ch_width)
								ch_width=fix(ch_width )
								printf( "### FOUND: %n  ETCH/TOP the change ppoint is %n %n %n\n" ++n xpoint_x xpoint_y ch_width)
								fprintf(ch_file "### FOUND: %n  ETCH/TOP the change ppoint is %n %n %n\n" n xpoint_x xpoint_y  ch_width)
								templist = list(ch_width xpoint_x xpoint_y)
								top_list = cons(templist top_list )
							);end of if(temppad->layer=="ETCH/TOP"
						);end of foreach(temppad ch_children->definition->pads
					);end of if( ch_children->objType == "pin"

					if( ch_children->objType == "pin" && ch_children->isThrough== nil && ch_children->startEnd == '( "ETCH/BOTTOM"   "ETCH/BOTTOM")
						then
						xpoint_x = nthelem(1 ch_children->xy)
						xpoint_y = nthelem(2  ch_children->xy)
						foreach(temppad ch_children->definition->pads
							if(temppad->layer=="ETCH/TOP" && temppad->figureName!="NULL" && temppad->figure!=nil && temppad->type=="REGULAR"
								then
								bBox=temppad->bBox
								llx = caar( bBox)
								lly = cadar( bBox)
								urx = caadr( bBox)
								ury = cadadr( bBox)
								ch_width = min( abs( urx - llx)  abs( ury - lly ))
								ch_width = if(ch_width<=Min_width ch_width-Min_width ch_width*2/3)
								ch_width = if(ch_width >=ch_Maxwidth ch_Maxwidth ch_width)
								ch_width = if(ch_width >=Min_width*2/3 && ch_width<Min_width Min_width ch_width)
								ch_width = if(ch_width<=0 ch_width+Min_width ch_width)
								printf( "### FOUND :%n ETCH/BOTTOM  ppoint is %n %n  %n\n" ++n xpoint_x xpoint_y  ch_width)
								fprintf(ch_file "### FOUND :%n ETCH/BOTTOM  ppoint is %n %n  %n\n" n xpoint_x xpoint_y  ch_width)
								ch_width =fix(ch_width	)
								templist = list(ch_width xpoint_x xpoint_y)
								botm_list = cons(templist botm_list )
							);end of if(temppad->layer=="ETCH/TOP"
						);end of foreach(temppad ch_children->definition->pads
					);end of if( ch_children->objType == "pin"

					if( ch_children->objType == "path"
						then
						foreach(chseg ch_children->segments
							ch_width = fix(chseg->width)
							if(ch_width < Min_width
								then
								templist = list(Min_width chseg->startEnd chseg->layer)
								linelist = cons(templist linelist)
							printf( "### FOUND :%n  %s layer and  bBox : %B  %n\n"  ++n chseg->layer  chseg->startEnd chseg->width)
							fprintf(ch_file "### FOUND :%n  %s layer and  bBox: %B  %n \n"  n chseg->layer chseg->startEnd  chseg->width)
							);end of if(chseg->width< Min_width
						);end of foreach(chseg ch_children->segments
					);end of if( ch_children->objType == "path"
				);end of foreach(ch_children ch_branch->children
   			);end of foreach(ch_branch ch_net->branches
		);end of for(m 1 length( netpara)/4


		;Change  begin
		i = 0 ;change number
		;Change all lines with width less than Min_width
		if( linelist !=nil
			then
			axlShell( "setwindow pcb ")
			axlShell( "change ")
			axlShell( "setwindow form.find")
			axlShell( "FORM find all_off ")
			axlShell( "FORM find clines YES  ")
			templist =nil
			foreach(templist linelist
				axlVisibleDesign(nil)
				sprintf(slayer "%s"  nthelem(3 templist))
				axlVisibleLayer( slayer t )
				ch_width = car(templist)
				bBox = nthelem(2 templist)
				llx = xCoord(car(bBox))
				lly = yCoord(car(bBox))
				urx = xCoord(cadr(bBox))
				ury = yCoord(cadr(bBox))
				printf("###  CHANGE :%n  %s layer %n : %n  line_width %n\n"  ++i slayer (llx+urx)/2  (lly+ury)/2 ch_width)
				sprintf( clinewidth "FORM mini line_width %n " ch_width )
				sprintf( ppoint "pick grid %n %n  "  (llx+urx)/2  (lly+ury)/2 )
				fprintf(ch_file "\n###  CHANGE: %n  %s  %n : %n  line_width %n\n"  i slayer (llx+urx)/2  (lly+ury)/2   ch_width)
				axlShell( "setwindow form.mini")
				axlShell( "FORM mini apply_subclass NO ")
				axlShell( "FORM mini apply_width YES ")
				axlShell( clinewidth)
				axlShell( "setwindow pcb")
				axlShell( ppoint)
			);end of foreach(templist linelist
		axlShell( "done")
		);end of if( linelist !=nil

		;Change all Net
		if( length( ch_netnamelst) >= 1
			then
			;ch_netnamelst = sortcar( ch_netnamelst 'greaterp)
			foreach( templist  ch_netnamelst
				;templist = nthelem( 2 templist)
				; Change all clines to Max_width
				ch_Maxwidth = nthelem( 1 templist)
				printf("## Change all cline to Max width : %n \n"  ch_Maxwidth)
				sprintf( findnet "FORM find find_name  %s "  nthelem(2 templist ))
				sprintf( changewidth "FORM mini line_width %n "  ch_Maxwidth )
				axlShell( "setwindow pcb ")
				axlShell( "change ")
				axlShell( "setwindow form.mini ")
				axlShell( "FORM mini apply_subclass NO ")
				axlShell( "FORM mini apply_size NO  ")
				axlShell( "FORM mini apply_justification NO ")
				axlShell( "FORM mini apply_width YES ")
				axlShell( changewidth )
				axlShell( "setwindow form.find ")
				axlShell( "FORM find all_off ")
				axlShell( "FORM find nets YES ")
				axlShell( findnet )
				axlShell( "setwindow pcb ")
				axlShell( "done ")
			);end of   for(templist  ch_netnamelst
		);end of if( ch_netnamelst!=nil
		;end of Change all Net

		;change top cline

		if( top_list != nil
			then
			axlVisibleDesign(nil)
			axlVisibleLayer( "ETCH/TOP" t )
			axlSetActiveLayer( "ETCH/TOP")
			axlFlushDisplay()
			top_list = sortcar( top_list 'greaterp)
			axlShell( "setwindow pcb ")
			axlShell( "change ")
			axlShell( "setwindow form.find")
			axlShell( "FORM find all_off ")
			axlShell( "FORM find clines YES ")
			templist =nil
			foreach( templist top_list
				ch_width = car(templist)
				xpoint_x = nthelem(2 templist)
				xpoint_y = nthelem(3 templist)
				sprintf( clinewidth "FORM mini line_width %n " ch_width )
				sprintf( pstart "drag_start grid %n %n  "  xpoint_x-3 xpoint_y-3 )
				sprintf( pstop "drag_stop %n %n "  xpoint_x+3  xpoint_y+3 )
				axlShell( "setwindow form.mini")
				axlShell( "FORM mini apply_subclass NO ")
				axlShell( "FORM mini apply_width YES ")
				axlShell( clinewidth)
				axlShell( "setwindow pcb")
				axlShell( pstart)
				axlShell( pstop)
				printf("\nCHANGE: %n  ETCH/TOP  ( %n:%n   %n:%n ) and  the width is %n mil  \n"  ++i xpoint_x-3 xpoint_y-3   xpoint_x+3  xpoint_y+3 ch_width)
				fprintf(ch_file "\nCHANGE: %n  ETCH/TOP ( %n:%n   %n:%n ) and  the width is %n mil  \n"  i  xpoint_x-3 xpoint_y-3   xpoint_x+3  xpoint_y+3 ch_width)
			);end of foreach( templist top_list
		axlShell( "done")
		);end of if( top_list != nil

		;Change Bottom clines
		if( botm_list != nil
			then
			axlVisibleDesign(nil)
			axlVisibleLayer( "ETCH/BOTTOM" t )
			axlSetActiveLayer( "ETCH/BOTTOM")
			axlFlushDisplay()
			botm_list =sortcar( botm_list 'greaterp)
			axlShell( "setwindow pcb ")
			axlShell( "change ")
			axlShell( "setwindow form.find")
			axlShell( "FORM find all_off ")
			axlShell( "FORM find clines YES ")
			templist =nil
			foreach( templist botm_list
				ch_width = car(templist)
				xpoint_x = nthelem(2 templist)
				xpoint_y = nthelem(3 templist)
				sprintf( clinewidth "FORM mini line_width %n" ch_width )
				sprintf( pstart "drag_start grid %n %n  "  xpoint_x-3 xpoint_y-3 )
				sprintf( pstop "drag_stop %n %n "  xpoint_x+3  xpoint_y+3 )
				axlShell( "setwindow form.mini")
				axlShell( "FORM mini apply_subclass NO ")
				axlShell( "FORM mini apply_width YES ")
				axlShell( clinewidth)
				axlShell( "setwindow pcb")
				axlShell( pstart)
				axlShell( pstop)
				printf("\nCHANGE: %n  ETCH/BOTTOM  ( %n:%n  %n:%n ) and  the width : %n mil  \n"  ++i xpoint_x-3 xpoint_y-3   xpoint_x+3  xpoint_y+3 ch_width)
				fprintf(ch_file "CHANGE: %n  ETCH/BOTTOM  ( %n:%n  %n:%n ) and the width : %n mil\n" i xpoint_x-3 xpoint_y-3   xpoint_x+3  xpoint_y+3 ch_width)

			);end of foreach( templist botm_list
		axlShell( "done")
		);end of if( botm_list != nil
		if( i==n printf("==Net fanoutwidth is finished ! ok==\n")  printf("==Net fanoutwidth has error! \n Pls email to lijinjun 15923 or tel: 6540578 ==\n"))
		if( i==n fprintf(ch_file "==Net fanoutwidth  is finished ! ok==\n")  fprintf(ch_file "\n==change has error! \n Pls email to lijinjun 15923 or tel: 6540578 ==\n") )
		axlVisibleDesign(nil)
		axlVisibleLayer( "BOARD GEOMETRY/OUTLINE" t )
		axlVisibleLayer( "PIN/TOP" t )
		axlVisibleLayer( "PIN/BOTTOM" t )
		axlVisibleLayer( "ETCH/TOP" t )
		axlVisibleLayer( "ETCH/BOTTOM" t )
		axlVisibleLayer( "VIA CLASS/TOP" t )
		axlVisibleLayer( "VIA CLASS/BOTTOM" t )
		axlFlushDisplay()
		;axlClearSelSet()
		axlShell("redraw")
		;axlCloseFindFilter()
		;axlShell("done")
		fprintf(ch_file "----Please check all ETCH DRCs because of fanoutwidth !!----\n")
		printf("----Please check all ETCH DRCs because of fanoutwidth !----\n")

		close(ch_file)
	);end of if(length( netpara) > 3
);end of (defun _ljj_chwidth (netpara)


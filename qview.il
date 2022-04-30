;DESCRIPTION: 2 layers PCB quick layer/colour view switch
;AUTHOR: Richard L.   fpmontreal@gmail.com
;
;some pre-define color, legal numbers are 1 to 24
c_white =1 c_qing   =6 	c_ltgreen=12 c_dkzi =17
c_ltblue=2 c_red    =7		c_golden =13 c_gray =19
c_pink  =3 c_yellow =8 	c_ltpink =14 c_jiang=22
c_cyan  =4 c_dkblue =9 	c_mud    =15 c_black=23
c_zi    =5 c_dkgray =11	c_blue   =16

; you may add many layers as you want:)
;  q_name            q_layers



displayetchlayerlist1='(
("TOP_SILK"            ("VIA CLASS/TOP" "PIN/TOP" "PACKAGE GEOMETRY/SILKSCREEN_TOP" "BOARD GEOMETRY/SILKSCREEN_TOP" "REF DES/SILKSCREEN_TOP" "BOARD GEOMETRY/OUTLINE"))
("BOTTOM_SILK"          ("VIA CLASS/BOTTOM" "PIN/BOTTOM" "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" "BOARD GEOMETRY/SILKSCREEN_BOTTOM" "REF DES/SILKSCREEN_BOTTOM" "BOARD GEOMETRY/OUTLINE"))
("TOP_PLACE"           ("ETCH/TOP" "VIA CLASS/TOP" "PACKAGE GEOMETRY/SILKSCREEN_TOP" "PACKAGE GEOMETRY/PLACE_BOUND_TOP" "BOARD GEOMETRY/OUTLINE"))
("BOTTOM_PLACE"         ("ETCH/BOTTOM" "VIA CLASS/BOTTOM" "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" "PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM" "BOARD GEOMETRY/OUTLINE"))
("ALL_VIEW"        ("PACKAGE GEOMETRY/SILKSCREEN_TOP" "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" "PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM"  "PACKAGE GEOMETRY/PLACE_BOUND_TOP" "REF DES/SILKSCREEN_TOP" "BOARD GEOMETRY/SILKSCREEN_TOP" "BOARD GEOMETRY/SILKSCREEN_BOTTOM" "REF DES/SILKSCREEN_BOTTOM" "ETCH/TOP" "VIA CLASS/TOP" 
                   "ETCH/BOTTOM" "VIA CLASS/BOTTOM" "ROUTE KEEPIN/ALL" "ROUTE KEEPOUT/ALL" "ROUTE KEEPOUT/TOP" "ROUTE KEEPOUT/BOTTOM" "PIN/TOP" "PIN/TOP" "PIN/BOTTOM" "BOARD GEOMETRY/OUTLINE"))
("ALL_LAYOUT"      ("ETCH/TOP" "VIA CLASS/TOP" "PACKAGE GEOMETRY/SILKSCREEN_TOP" "ETCH/BOTTOM" "VIA CLASS/BOTTOM" "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" "ROUTE KEEPIN/ALL" "ROUTE KEEPOUT/ALL" "ROUTE KEEPOUT/TOP" "ROUTE KEEPOUT/BOTTOM" "PIN/TOP" "PIN/BOTTOM" "BOARD GEOMETRY/OUTLINE"))
("TOP_LAYOUT"          ("ETCH/TOP" "VIA CLASS/TOP" "PACKAGE GEOMETRY/SILKSCREEN_TOP" "ROUTE KEEPIN/ALL" "ROUTE KEEPOUT/ALL" "ROUTE KEEPOUT/TOP" "PIN/TOP" "BOARD GEOMETRY/OUTLINE" "Drc Error Class/TOP" "Drc Error Class/PASTEMASK_TOP" "Drc Error Class/SOLDERMASK_TOP" "Drc Error Class/PACKAGE_TOP" "Drc Error Class/ALL"))
("GND_LAYOUT"          ("ETCH/GND" "VIA CLASS/GND" "PACKAGE GEOMETRY/SILKSCREEN_GND" "ROUTE KEEPIN/ALL" "ROUTE KEEPOUT/ALL" "ROUTE KEEPOUT/GND" "PIN/GND" "BOARD GEOMETRY/OUTLINE" "Drc Error Class/GND"))
("POWER_LAYOUT"          ("ETCH/POWER" "VIA CLASS/POWER" "PACKAGE GEOMETRY/SILKSCREEN_POWER" "ROUTE KEEPIN/ALL" "ROUTE KEEPOUT/ALL" "ROUTE KEEPOUT/POWER" "PIN/POWER" "BOARD GEOMETRY/OUTLINE" "Drc Error Class/POWER"))
("BOTTOM_LAYOUT"        ("ETCH/BOTTOM" "VIA CLASS/BOTTOM" "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" "ROUTE KEEPIN/ALL" "ROUTE KEEPOUT/ALL" "ROUTE KEEPOUT/BOTTOM" "PIN/BOTTOM" "BOARD GEOMETRY/OUTLINE" "Drc Error Class/BOTTOM" "Drc Error Class/PASTEMASK_BOTTOM" "Drc Error Class/SOLDERMASK_BOTTOM" "Drc Error Class/PACKAGE_BOTTOM"))
)

/*

	  fixlayerfirst = list( 
	                 '("TOP_SILK"            '("VIA CLASS/TOP" "PIN/TOP" "PACKAGE GEOMETRY/SILKSCREEN_TOP" 
	                   "BOARD GEOMETRY/SILKSCREEN_TOP" "REF DES/SILKSCREEN_TOP" "BOARD GEOMETRY/OUTLINE"))
                     '("BOTTOM_SILK"          '("VIA CLASS/BOTTOM" "PIN/BOTTOM" "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" 
					  "BOARD GEOMETRY/SILKSCREEN_BOTTOM" "REF DES/SILKSCREEN_BOTTOM" "BOARD GEOMETRY/OUTLINE"))
                     '("TOP_PLACE"           '("ETCH/TOP" "VIA CLASS/TOP" "PACKAGE GEOMETRY/SILKSCREEN_TOP" 
					  "PACKAGE GEOMETRY/PLACE_BOUND_TOP" "BOARD GEOMETRY/OUTLINE"))
                     '("BOTTOM_PLACE"         '("ETCH/BOTTOM" "VIA CLASS/BOTTOM" "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" 
					  "PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM" "BOARD GEOMETRY/OUTLINE"))
                     '("TOP_LAYOUT"          '("ETCH/TOP" "VIA CLASS/TOP" "PACKAGE GEOMETRY/SILKSCREEN_TOP" "ROUTE KEEPIN/ALL" 
					  "ROUTE KEEPOUT/ALL" "ROUTE KEEPOUT/TOP" "PIN/TOP" "BOARD GEOMETRY/OUTLINE" "Drc Error Class/TOP" 
					  "Drc Error Class/PASTEMASK_TOP" "Drc Error Class/SOLDERMASK_TOP" "Drc Error Class/PACKAGE_TOP" "Drc Error Class/ALL"))
					  )

	  fixlayerlast = list(
	                  '("BOTTOM_LAYOUT"        '("ETCH/BOTTOM" "VIA CLASS/BOTTOM" "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" "ROUTE KEEPIN/ALL" 
	                  "ROUTE KEEPOUT/ALL" "ROUTE KEEPOUT/BOTTOM" "PIN/BOTTOM" "BOARD GEOMETRY/OUTLINE" "Drc Error Class/BOTTOM" 
					  "Drc Error Class/PASTEMASK_BOTTOM" "Drc Error Class/SOLDERMASK_BOTTOM" "Drc Error Class/PACKAGE_BOTTOM"))
					  )
	
        etchlayerlist = reverse(cdr(reverse(cdr(car(list(axlGetParam("paramLayerGroup:ETCH")->groupMembers))))))
		
		etchlayerlistneed = list()
		foreach(layer etchlayerlist
		        a = strcat(layer "_LAYOUT")
				b = strcat("ETCH/" layer)
				c = strcat("VIA CLASS/" layer)
				d = strcat("ROUTE KEEPOUT/" layer)
				e = strcat("PIN/" layer)
				f = strcat("Drc Error Class/" layer)
				curetchlayer = list('(a '(b c d e f "BOARD GEOMETRY/OUTLINE" "ROUTE KEEPIN/ALL" "ROUTE KEEPOUT/ALL")))
				etchlayerlistneed = append(etchlayerlistneed curetchlayer)
				)

	  ;displayetchlayerlist = append(fixlayerfirst car(append(etchlayerlistneed fixlayerlast)))
	  
	  displayetchlayerlist = etchlayerlistneed
	  ;displayetchlayerlist = append(fixlayerfirst fixlayerlast))
	  
*/
axlCmdRegister( "qview" `QView)

/* ---------------------------------
ChangeColor()
--------------------------------- */
defun( ChangeColor (whichone)
	axlVisibleDesign(nil)

	foreach(one displayetchlayerlist1 
		if(whichone==car(one) then
			foreach(lName cadr(one)
				l_sep = parseString(lName "/")   ; "ETCH" "BOTTOM"
				;parseString(lName "/")
				sprintf(strOrg,"paramLayerGroup:%s/paramLayer:%s",car(l_sep),cadr(l_sep))
				
				
				p = axlGetParam(strOrg)
				if(p then 
					p->visible=t 
					c1=1
					cond(
					(rexMatchp("AUTOSILK" lName)                   c1=c_gray   )
					(rexMatchp("PIN/TOP" lName)                    c1=c_golden )
					(rexMatchp("VIA CLASS/TOP" lName)              c1=c_golden )
					(rexMatchp("ETCH/TOP" lName)                   c1=c_golden )
					(rexMatchp("PIN/BOTTOM" lName)                 c1=c_ltgreen)
					(rexMatchp("VIA CLASS/BOTTOM" lName)           c1=c_ltgreen)
					(rexMatchp("ETCH/BOTTOM" lName)                c1=c_ltgreen)

					(rexMatchp("VALUE" lName)                      c1=c_pink)
					(rexMatchp("REF DES" lName)                    c1=c_cyan)
					(rexMatchp("PACKAGE GEOMETRY/ASSEMBLY_" lName) c1=c_gray)
					(rexMatchp("BOARD GEOMETRY/ASSEMBLY_" lName)   c1=c_gray)
					(rexMatchp("COMPONENT VALUE/ASSEMBLY_" lName)  c1=c_gray)
					(rexMatchp("OUTLINE" lName)                    c1=c_red )
					)                                                         
					;p->color=c1  
					;如果要修改颜色函数生效,请删除上一行的分号。
					axlSetParam(p)
				)
			)
		)
	)
	axlUIWRedraw(nil)
)

/* ---------------------------------
CreateQViewForm()
--------------------------------- */
defun( CreateQViewForm ()
	fn = axlTempFile()
	p = outfile(fn "w")
	f_FormBegin(p 16 16 "QView." "TOOLWINDOW")

	i=0
	foreach(onec displayetchlayerlist1 f_CheckList(p car(onec) 0 i car(onec) "cg") i=i+2)

	f_FormEnd(p)
	close(p)
	fn
)


defun( QView ()
	QVFormFile = CreateQViewForm()	
	fw = axlFormCreate((gensym) QVFormFile '("NE" "msglines" 0) 'QViewAction t nil)
	axlUIWPerm(fw t)
	axlFormDisplay(fw)
	axlTempFileRemove(QVFormFile)
)

defun( QViewAction (fw)
	if(fw->curField then 
		foreach(onec displayetchlayerlist1 if(fw->curField==car(onec) ChangeColor(fw->curField)))
	)
)

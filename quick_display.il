/* 
├─ 
│ ├─        程序名称：quick_display
│ ├─        程序功能：快速切换层面显示，方便设计
│ ├─        创建时间：2013年12月11日 
│ ├─        作    者：kevin wong
│ ├─        Q      Q：263350809
├─ 


1，2013.12.11基本功能基于“qview”设置修改，删除颜色修改部分（单独），适用于任意层板；
1，2014.4.9添加按钮开关单独层功能，但仍然保留原来的小界面；
*/ 

axlCmdRegister( "quick_display" `Quick_Display)
axlCmdRegister( "Quick_Displaymini" `Quick_Displaymini)

axlSetFunckey("ssq" "quick_display")
axlSetFunckey("sq" "quick_displaymini")

/* ---------------------------------
define all the layers
--------------------------------- */


defun( crlistneed ()
      let((fixlayerfirst etchlayerlistneed)
fixlayerfirst = list( 
	                  list("TOP_SILK" "VIA CLASS/TOP" "PIN/TOP" "PACKAGE GEOMETRY/SILKSCREEN_TOP" 
	                   "BOARD GEOMETRY/SILKSCREEN_TOP" "REF DES/SILKSCREEN_TOP" "BOARD GEOMETRY/OUTLINE")
					   
                      list("BOTTOM_SILK" "VIA CLASS/BOTTOM" "PIN/BOTTOM" "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" 
					   "BOARD GEOMETRY/SILKSCREEN_BOTTOM" "REF DES/SILKSCREEN_BOTTOM" "BOARD GEOMETRY/OUTLINE")

                      list("TOP_PLACE" "PIN/TOP" "VIA CLASS/TOP" "PACKAGE GEOMETRY/SILKSCREEN_TOP" "PACKAGE GEOMETRY/PLACE_BOUND_TOP" 
                       "PACKAGE KEEPIN/ALL" "PACKAGE KEEPOUT/ALL" "PACKAGE KEEPOUT/TOP" "BOARD GEOMETRY/OUTLINE")
					   
                      list("BOTTOM_PLACE" "PIN/BOTTOM" "VIA CLASS/BOTTOM" "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" "PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM" 
					   "PACKAGE KEEPIN/ALL" "PACKAGE KEEPOUT/ALL" "PACKAGE KEEPOUT/BOTTOM" "BOARD GEOMETRY/OUTLINE")
					   
                      list("ALL_PLACE" "PIN/TOP" "VIA CLASS/TOP" "PACKAGE GEOMETRY/SILKSCREEN_TOP" "PACKAGE GEOMETRY/PLACE_BOUND_TOP" 
                       "PACKAGE KEEPIN/ALL" "PACKAGE KEEPOUT/ALL" "PACKAGE KEEPOUT/TOP" "BOARD GEOMETRY/OUTLINE" 
					   "PIN/BOTTOM" "VIA CLASS/BOTTOM" "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" "PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM" "PACKAGE KEEPOUT/BOTTOM")			   
					   
                      list("ALL_VIEW" "PACKAGE GEOMETRY/SILKSCREEN_TOP" "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" "PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM"  
					  "PACKAGE GEOMETRY/PLACE_BOUND_TOP" "REF DES/SILKSCREEN_TOP" "BOARD GEOMETRY/SILKSCREEN_TOP" "BOARD GEOMETRY/SILKSCREEN_BOTTOM" "REF DES/SILKSCREEN_BOTTOM" 
					  "ETCH/TOP" "VIA CLASS/TOP" "ETCH/BOTTOM" "VIA CLASS/BOTTOM" "ROUTE KEEPIN/ALL" "ROUTE KEEPOUT/ALL" "ROUTE KEEPOUT/TOP" "ROUTE KEEPOUT/BOTTOM" "PIN/TOP" 
					  "PIN/TOP" "PIN/BOTTOM" "BOARD GEOMETRY/OUTLINE"
					   )	
                      list("TB_LAYOUT" "ETCH/TOP" "VIA CLASS/TOP" "PACKAGE GEOMETRY/SILKSCREEN_TOP" "ETCH/BOTTOM" "VIA CLASS/BOTTOM" "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" 
					  "ROUTE KEEPIN/ALL" "ROUTE KEEPOUT/ALL" "ROUTE KEEPOUT/TOP" "ROUTE KEEPOUT/BOTTOM" "PIN/TOP" "PIN/BOTTOM" "BOARD GEOMETRY/OUTLINE"
					   )					   			    
					   )					   
		etchlayerlist = axlGetParam("paramLayerGroup:ETCH")->groupMembers
 		etchlayerlistneed = list()
		foreach(onel etchlayerlist 
				curetchlayer = list(list(strcat(onel "_LAYOUT") strcat("ETCH/" onel) strcat("VIA CLASS/" onel) strcat("ROUTE KEEPOUT/" onel) strcat("PIN/" onel)
				strcat("Drc Error Class/" onel) strcat("PACKAGE GEOMETRY/SILKSCREEN_" onel) "BOARD GEOMETRY/OUTLINE" "ROUTE KEEPIN/ALL" "ROUTE KEEPOUT/ALL"))
							   
			    etchlayerlistneed = append(etchlayerlistneed curetchlayer)
				)
		aaa = append(fixlayerfirst etchlayerlistneed)
	))
	
	; load("quick_display.il")
	
/* ---------------------------------
define other layers
--------------------------------- */
defun( onofflistneed ()
      let((fixlayerfirst1 AllEtchlist AllDRClist AllAntlist Etchlist)	
	  fixlayerfirst1 = list(
	             '("SilkT" "BOARD GEOMETRY/SILKSCREEN_TOP" "PACKAGE GEOMETRY/SILKSCREEN_TOP" "REF DES/SILKSCREEN_TOP")
				 '("SilkB" "BOARD GEOMETRY/SILKSCREEN_BOTTOM" "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" "REF DES/SILKSCREEN_BOTTOM")
				 '("PlacT" "PACKAGE GEOMETRY/PLACE_BOUND_TOP")
				 '("PlacB" "PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM")
				 ; AllAntlist
				 ; AllDRClist
				 ; AllEtchlist
				 )
		
        AllEtchlist = list("AllEtch")
        AllDRClist = list("AllDrc" "Drc Error Class/ALL" "Drc Error Class/PASTEMASK_BOTTOM" "Drc Error Class/PASTEMASK_TOP" "Drc Error Class/WIRE" "Drc Error Class/SOLDERMASK_BOTTOM" 
		           "Drc Error Class/SOLDERMASK_TOP" "Drc Error Class/PACKAGE_BOTTOM" "Drc Error Class/PACKAGE_TOP")		   
		AllAntlist = list("Allant" "ANTI ETCH/ALL")
		
		Etchlist = list()
		
		foreach(onel etchlayerlist 
		        curEtchl =  list(strcat("ETCH/" onel) strcat("PIN/" onel) strcat("VIA CLASS/" onel))
				AllEtchlist = append(AllEtchlist curEtchl)
		        )				
		foreach(onel etchlayerlist 
		        curDrcl =  strcat("Drc Error Class/" onel)
				AllDRClist = append1(AllDRClist curDrcl)
		        )
		foreach(onel etchlayerlist 
		        curAntl =  strcat("ANTI ETCH/" onel)
				AllAntlist = append1(AllAntlist curAntl)
		        )
				
		foreach(onel etchlayerlist 
	           	curetchlayer = list(list(onel strcat("ETCH/" onel) strcat("VIA CLASS/" onel)  strcat("PIN/" onel) strcat("ANTI ETCH/" onel)))
				Etchlist = append(Etchlist curetchlayer)
				)				
			  onoffalllist = append(append(append(append(fixlayerfirst1 list(AllAntlist)) list(AllDRClist)) list(AllEtchlist)) Etchlist)
	  ))

	
	
	
/* ---------------------------------
Create the main function
--------------------------------- */

defun(Quick_Display ()
	  Quick_Displayform()
	  
	  )


defun(Quick_Displaymini ()
	  Quick_Displayformmini()
	  
	  )	  
	  
defun(Quick_Displayformmini ()
disetchlayerlist = crlistneed()
        DisplayFormfile = "artformcreat.form"
		formport = outfile(DisplayFormfile "w")
		fprintf(formport "FILE_TYPE=FORM_DEFN VERSION=2\n")
        fprintf(formport "FORM\n") 
        fprintf(formport "FIXED\n")
        fprintf(formport "PORT 20 6\n")
        fprintf(formport "HEADER \"Quick Display - kevin\"\n")
        fprintf(formport "TILE\n")   	
		
		fprintf(formport "\n")
		fprintf(formport "TEXT \"Please Choose The\"\n")
		fprintf(formport "TLOC 3 1\n")
		fprintf(formport "ENDTEXT\n")
		
		fprintf(formport "\n")
		fprintf(formport "TEXT \"Layers Below:\"\n")   
		fprintf(formport "TLOC 3 2\n")
		fprintf(formport "ENDTEXT\n")
		
        a = 4
		foreach(curlayerlist disetchlayerlist  
		        cur_checklist = car(curlayerlist)
        fprintf(formport "FIELD %L\n" cur_checklist)
        fprintf(formport "FLOC 3 %d\n" a)
        fprintf(formport "FGROUP \"displayl\"\n")
        fprintf(formport "CHECKLIST %L\"displayl\"\n" cur_checklist)
        fprintf(formport "ENDFIELD\n")
		a = a+2
		       )

			   
		fprintf(formport "ENDTILE\n")
        fprintf(formport "ENDFORM\n") 
        close(formport)
		displayform = axlFormCreate((gensym) DisplayFormfile '(se inner) 'Display_currentmini t)
		axlFormDisplay(displayform)
		axlUIWPrint(displayform "Kevin Wong") 
		deleteFile("artformcreat.form")
)
	  

defun( Display_currentmini (displayform)
      let(()
disetchlayerlist = crlistneed()
	if(displayform->curField 
	then 
	axlUIWPrint(displayform "Kevin Wong") 
		foreach(onec disetchlayerlist 
		       if(displayform->curField == car(onec) 
			    ; axlUIWPrint(displayform car(onec)) 			   
		       Display_currentls(displayform->curField)
			   
		         )
		       )
	  )
     ))
	  
	  


defun(Quick_Displayform ()
disetchlayerlist = crlistneed()
onofflistneed()
        DisplayFormfile = "artformcreat.form"
		formport = outfile(DisplayFormfile "w")
		fprintf(formport "FILE_TYPE=FORM_DEFN VERSION=2\n")
        fprintf(formport "FORM\n") 
        fprintf(formport "FIXED\n")
        fprintf(formport "PORT 40 6\n")
        fprintf(formport "HEADER \"Quick Display\"\n")
        fprintf(formport "TILE\n")   	
		
		fprintf(formport "\n")
		fprintf(formport "TEXT \"Please Choose The\"\n")
		fprintf(formport "TLOC 3 1\n")
		fprintf(formport "ENDTEXT\n")
		
		fprintf(formport "\n")
		fprintf(formport "TEXT \"Layers Below:\"\n")   
		fprintf(formport "TLOC 3 2\n")
		fprintf(formport "ENDTEXT\n")
		
        a = 4
		foreach(curlayerlist disetchlayerlist  
		        cur_checklist = car(curlayerlist)
        fprintf(formport "FIELD %L\n" cur_checklist)
        fprintf(formport "FLOC 3 %d\n" a)
        fprintf(formport "FGROUP \"displayl\"\n")
        fprintf(formport "CHECKLIST %L\"displayl\"\n" cur_checklist)
        fprintf(formport "ENDFIELD\n")
		a = a+2
		       )
	    ;buttons	
		fprintf(formport "\n")
		fprintf(formport "TEXT \"You can on/off the\"\n")
		fprintf(formport "TLOC 22 1\n")
		fprintf(formport "ENDTEXT\n")
		
		fprintf(formport "\n")
		fprintf(formport "TEXT \"layers below\"\n")
		fprintf(formport "TLOC 22 2\n")
		fprintf(formport "ENDTEXT\n")		
		
        fprintf(formport "FIELD SilkT\n")
        fprintf(formport "FLOC 22 4\n")
        fprintf(formport "MENUBUTTON \"SilkTop_On/Off\" 15 2\n")
        fprintf(formport "ENDFIELD \n\n")
			   
        fprintf(formport "FIELD SilkB\n")
        fprintf(formport "FLOC 22 6\n")
        fprintf(formport "MENUBUTTON \"SilkBot_On/Off\" 15 2\n")
        fprintf(formport "ENDFIELD \n\n")

        fprintf(formport "FIELD PlacT\n")
        fprintf(formport "FLOC 22 8\n")
        fprintf(formport "MENUBUTTON \"PlacTop_On/Off\" 15 2\n")
        fprintf(formport "ENDFIELD \n\n")
			   
        fprintf(formport "FIELD PlacB\n")
        fprintf(formport "FLOC 22 10\n")
        fprintf(formport "MENUBUTTON \"PlacBot_On/Off\" 15 2\n")
        fprintf(formport "ENDFIELD \n\n")		

        fprintf(formport "FIELD Allant\n")
        fprintf(formport "FLOC 22 12\n")
        fprintf(formport "MENUBUTTON \"AllAnt_On/Off\" 15 2\n")
        fprintf(formport "ENDFIELD \n\n")
			   
        fprintf(formport "FIELD AllDrc\n")
        fprintf(formport "FLOC 22 14\n")
        fprintf(formport "MENUBUTTON \"AllDRC_On/Off\" 15 2\n")
        fprintf(formport "ENDFIELD \n\n")					   
			   
        fprintf(formport "FIELD AllEtch\n")
        fprintf(formport "FLOC 22 16\n")
        fprintf(formport "MENUBUTTON \"AllEtch_On/Off\" 15 2\n")
        fprintf(formport "ENDFIELD \n\n")					   
			   
	    b = 18
		foreach(curlayer etchlayerlist
		         curbtn = strcat(curlayer "_On/Off")
        fprintf(formport "FIELD %s\n" curlayer)  ;top
        fprintf(formport "FLOC 22 %d\n" b)
        fprintf(formport "MENUBUTTON \"%s\" 15 2\n" curbtn)		
        fprintf(formport "ENDFIELD\n\n")
		b = b+2
		       )

			; printf("FIELD %s\n" cur_checklist)
			; printf("FIELD %s\n" curlayer)
   
			   
		fprintf(formport "ENDTILE\n")
        fprintf(formport "ENDFORM\n") 
        close(formport)
		
		displayform = axlFormCreate((gensym) DisplayFormfile '("NE" "Outer" "Canvas" "NoBorder" "msglines" 1) 'Display_current t)
		axlFormDisplay(displayform)
		axlUIWPrint(displayform "Kevin Wong") 
		deleteFile("artformcreat.form")
)

/* ---------------------------------
Display_current layer
--------------------------------- */

; load("quick_dis.il")


defun( Display_current (displayform)
      let(()  
    disetchlayerlist = crlistneed()

	
	
	if( or((car(reverse(parseString(displayform->curField "_"))) == "LAYOUT") (car(reverse(parseString(displayform->curField "_"))) == "SILK")
	(car(reverse(parseString(displayform->curField "_"))) == "PLACE") (car(reverse(parseString(displayform->curField "_"))) == "VIEW"))
	
	   then
	   if(displayform->curField 
       then 
	   axlUIWPrint(displayform "Kevin Wong") 
		foreach(onec disetchlayerlist 
		       if(displayform->curField == car(onec)		   
			    ; axlUIWPrint(displayform car(onec)) 
			   then
	           ; axlDBDisplayControl('filledPadsEnable nil)
	           ; axlDBDisplayControl('endcapsEnable t)			   
		       Display_currentls(displayform->curField)	   
	   )))
	   else
	   if(displayform->curField 
       then 
	   axlUIWPrint(displayform "Kevin Wong") 
		foreach(onec onoffalllist 
		       if(displayform->curField == car(onec) 
			    ; axlUIWPrint(displayform car(onec)) 
			   then
		       OporCllayer(cdr(onec))
	           ; axlDBDisplayControl('filledPadsEnable nil)
	           ; axlDBDisplayControl('endcapsEnable t)			   
			   ; axlUIWRedraw(nil)	
			   axlVisibleUpdate(t)
			   
			   
			   ))
	     ))
		 ))
	 
/* ---------------------------------
open/close the layer
--------------------------------- */	  
defun( OporCllayer (onelayerlist)
      
	  if(axlIsVisibleLayer(car(onelayerlist))
	     then
		 foreach(onelayer onelayerlist
		 axlVisibleLayer(onelayer nil)
		 )
		 else
		 foreach(onelayer onelayerlist
		 axlVisibleLayer(onelayer t)
		 )		 
		 )
      )
	  
	  
	  
	  
	  
/* ---------------------------------
Create the display layer list
--------------------------------- */

defun( Display_currentls (curlayers)
      let(()
    disetchlayerlist = crlistneed()
	axlVisibleDesign(nil)
	foreach(one disetchlayerlist 
		if(
		    curlayers == car(one)
		    then
		    willdl = cdr(one)
		      foreach(dl willdl
		      axlVisibleLayer(dl t)
				     )
	           ; axlDBDisplayControl('filledPadsEnable nil)
	           ; axlDBDisplayControl('endcapsEnable t)					 
			  axlUIWRedraw(nil)			 
		  )
		  )
     ))




	  

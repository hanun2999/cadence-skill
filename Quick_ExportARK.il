/*
├─
│ ├─        程序名称： Quick_ExportARK
│ ├─        程序功能：一键/手动 输出GEBER文件，并保存到当前目录ART文件夹内,附带2个子功能，具体见命令
│ ├─        创建时间：2013年12月16日
│ ├─        作    者：王凯
│ ├─        Q      Q:263350809
├─
1，20131202：基本功能实现。
2，20131228：添加手动功能
3，20131230：添加选择界面，并添加quicktext和quickart至程序内，不用另外加载这2个skill




注意：手动方式创建，如果没有操作完成，中途修改PCB，需要重新走一遍流程，不然会出错，请自行注意。


    本程序目前测试尚未发现问题，但不表示没有BUG。
*/




axlCmdRegister("UIchoose" 'Quick_ExportARTCh)    ;选择手动/自动方式

axlCmdRegister("quickexart" 'Quick_ExportART)    ;自动

axlCmdRegister("quickexartw" 'Quick_ExportARK_Wizard)   ;手动按步骤操作

axlCmdRegister("quick_textset" 'quicktext)  ; 子功能，字体设置

axlCmdRegister("quickart" 'quickart)    ;子功能，GEBER设置

axlCmdRegister("opclspfill" 'OpenCloseSpfl)    ;子功能，GEBER设置


defun( Quick_ExportARTCh ()
let( ()
        chform = "./expart.form"
        chff = outfile(chform "w")
        fprintf(chff "FILE_TYPE=FORM_DEFN VERSION=2\n")
		
        fprintf(chff "FORM\n")
        fprintf(chff "FIXED\n")
        fprintf(chff "PORT 30 6\n")
        fprintf(chff "HEADER \"ART choose\"\n")
        fprintf(chff "TILE\n")   ;tile begin
		
		fprintf(chff "\n")
		fprintf(chff "TEXT \"Please make a choice: \"\n")
		fprintf(chff "TLOC 5 1\n")
		fprintf(chff "ENDTEXT\n\n")		
		
		
        fprintf(chff "FIELD expart\n")
        fprintf(chff "FLOC 3 4\n")
        fprintf(chff "MENUBUTTON \"Export ART\" 10 4\n")  ;
        fprintf(chff "ENDFIELD\n")
 		
		
        fprintf(chff "FIELD expartw\n")
        fprintf(chff "FLOC 18 4\n")
        fprintf(chff "MENUBUTTON \"Export wzd\" 10 4\n")
        fprintf(chff "ENDFIELD\n")
		
        fprintf(chff "FIELD exit\n")
        fprintf(chff "FLOC 5 8\n")
        fprintf(chff "MENUBUTTON \"Exit\" 20 4\n")
        fprintf(chff "ENDFIELD\n")		
	 
        fprintf(chff "ENDTILE\n") 
        fprintf(chff "ENDFORM\n") 
        close( chff)
		
		
		
		  art_form = axlFormCreate( (gensym) chform nil 'uich_ac t)
		  axlFormDisplay(art_form)	
		  deleteFile("expart.form")
	 
	 
	 ))
;load("Quick_ExportARK.il")            Quick_ExportARTCh
	 
	 defun( uich_ac (art_form)
      let( ()	
	  case(art_form->curField
		   ("expart"
		   Quick_ExportART()
		   
		   )
		   ("expartw"
		   Quick_ExportARK_Wizard()
		   )
		   ("exit"
             axlFormClose(art_form)
             deleteFile(chform)		   
		   )
		   )
		   ))
		   
	 

/* ---------------------------------
define the main function
--------------------------------- */
defun( Quick_ExportART ()
let( ()
		  curdsnunit = axlGetParam("paramDesign")->units
		  curacc = axlGetParam("paramDesign")->accuracy
		   case(curdsnunit
	        ("mils"  dounit = 1 unitmode = "units_english")
		    ("millimeters" dounit = 40  unitmode = "units_metric")
			;(u can add other units)
		      )		
		quicktext()
        cr_expart_form()


    ))


defun( cr_expart_form ()
let( ()
        pform = "./expart.form"
        formc = outfile(pform "w")
        fprintf(formc "FILE_TYPE=FORM_DEFN VERSION=2\n")
		
        fprintf(formc "FORM\n")
        fprintf(formc "FIXED\n")
        fprintf(formc "PORT 30 6\n")
        fprintf(formc "HEADER \"Quick Exp_ARK\"\n")
        fprintf(formc "TILE\n")   ;tile begin
		
		
		fprintf(formc "\n")
		fprintf(formc "TEXT \"Art dir name: \"\n")
		fprintf(formc "TLOC 1 1\n")
		fprintf(formc "ENDTEXT\n\n")

		fprintf(formc "\n")
		fprintf(formc "TEXT \"Zero line width: \"\n")
		fprintf(formc "TLOC 1 4\n")
		fprintf(formc "ENDTEXT\n\n")

		
		fprintf(formc "\n")
		fprintf(formc "TEXT \"Int_places: \"\n")		
		fprintf(formc "TLOC 1 7\n")
		fprintf(formc "ENDTEXT\n\n")

		fprintf(formc "\n")
		fprintf(formc "TEXT \"Dec_places: \"\n")	
		fprintf(formc "TLOC 1 10\n")
		fprintf(formc "ENDTEXT\n\n\n")

		
		
		
		fprintf(formc "TEXT %L\n" curdsnunit) 
		;fprintf(artform "TEXT \"  m \"\n")
		fprintf(formc "TLOC 23 4\n")
		fprintf(formc "ENDTEXT\n")	
		
		
        fprintf(formc,"FIELD dft_dirname\n\n")
        fprintf(formc,"FLOC 13 1\n")     
        fprintf(formc,"STRFILLIN 8 4\n")
        fprintf(formc,"ENDFIELD\n\n")			
		
        fprintf(formc,"FIELD dftlw\n\n")
        fprintf(formc,"FLOC 13 4\n")     
        fprintf(formc,"REALFILLIN 8 4\n")
		; fprintf(formc "MIN 0.0")
		; fprintf(formc "MAX 100.0")		
        fprintf(formc,"ENDFIELD\n\n")		
		
		
        fprintf(formc,"FIELD int_places\n\n")
        fprintf(formc,"FLOC 13 7\n")     
        fprintf(formc,"INTFILLIN 8 4\n")
		; fprintf(formc "MIN 3")
		; fprintf(formc "MAX 5")	
        fprintf(formc,"ENDFIELD\n\n")	


        fprintf(formc,"FIELD dec_places\n\n")
        fprintf(formc,"FLOC 13 10\n")     
        fprintf(formc,"INTFILLIN 8 4\n")
		; fprintf(formc "MIN 3")
		; fprintf(formc "MAX 5")		
        fprintf(formc,"ENDFIELD\n\n")
		

 		
		
        fprintf(formc "FIELD creat\n")
        fprintf(formc "FLOC 4 14\n")
        fprintf(formc "MENUBUTTON \"Creat ART\" 8 4\n")
        fprintf(formc "ENDFIELD\n")

        fprintf(formc "FIELD exit\n")
        fprintf(formc "FLOC 19 14\n")
        fprintf(formc "MENUBUTTON \"Exit\" 8 4\n") 
        fprintf(formc "ENDFIELD\n")		
			
		
        fprintf(formc "ENDTILE\n") 
        fprintf(formc "ENDFORM\n") 
        close( formc)
		
		
		  art_form = axlFormCreate( (gensym) pform nil 'cr_expart_ac t)
		  axlFormDisplay(art_form)
		  deleteFile("expart.form")
		  
		  dftlwidth = 6 * (1.0/ dounit)
		  axlFormSetField(art_form "dftlw" dftlwidth)
		  axlFormSetField(art_form "dft_dirname" "ART")
		  axlFormSetField(art_form "int_places" 2)
		  axlFormSetField(art_form "dec_places" 5)			



    ))

defun( cr_expart_ac (art_form)
let( ()
    case(art_form -> curField
	  
	       ("creat"
		   
		     dft_dirname = axlFormGetField(art_form "dft_dirname")
		     dft_lw = axlFormGetField(art_form "dftlw")
		     int_places = axlFormGetField(art_form "int_places")
		     dec_places = axlFormGetField(art_form "dec_places")
			 

			 ;总体来说，底片的小数位应该比精度大3或者以上，所以精度最大设置应该为2，不应该大于2，不然并无实际意义。

			 if(curacc>2
			   then
			   axlUIConfirm("The accuracy should be less than 2,plese check your design accuracy")
			   else
			      if( and(dec_places-curacc>=1 int_places<6  int_places>1 dec_places<6  dec_places>2)
				     then			 
					 Quick_ExportARTact()
					 axlFormClose(art_form)
					 deleteFile(pform)
					 else
					 axlUIConfirm("The dec_format should be at least 3 greater than the accuracy ,& plese check your input number ")					  
			    ))
		   )
		   
	       ("exit"
             axlFormClose(art_form)
             deleteFile(pform)
		   )

		  ;   load("Quick_ExportARK.il")	Quick_ExportART
	
	     )
	)
	)
	

	
	
defun( Quick_ExportARTact ()
let( ()

          axlPurgePadstacks('padstacks nil)
          axlPurgePadstacks('via t)
		  axlShapeDynamicUpdate(nil nil)
		  
		  old_visList = axlVisibleGet() ;完成后恢复显界面示用
		  
		  
		  
		  	  if(equal(isDir(strcat("./" dft_dirname)) t)
	          then
	          allfilename = cddr(getDirFiles(strcat("./" dft_dirname)))
	          foreach(filename allfilename
	                  deleteFile(sprintf(nil "./%s/%s" dft_dirname filename))
	                  )
					   clearrest = t
	                  else
	                  axlSetVariable("ads_sdart" dft_dirname) ;set ART dir	 
		        ) 
				
				
		  quicktext()      ;quicktext_set function 
          quicksetnccus()	
		  placloc()

	   if(equal(spaist t)
		  then
		  CrPlace_mov()		  
	      quickdrlegend()
	      quickNC_drill_route()
	      quickexart()
		  RecoverDis()
		  else
		  axlUIConfirm("There's not enough space to place the NC figure,Please change the page size & origion")
		  )	  
	  

		
	   )
	   )

	  			  ;load("Quick_ExportARK.il")		  
				  
/* ---------------------------------
define the 2rd main function
--------------------------------- */
 
defun( Quick_ExportARK_Wizard ()
let( ()	
		  curdsnunit = axlGetParam("paramDesign")->units
		  wzdacc = axlGetParam("paramDesign")->accuracy
		   case(curdsnunit
	        ("mils"  dounit = 1 unitmode = "units_english")
		    ("millimeters" dounit = 40  unitmode = "units_metric")
		      )
		  quicktext() 
          cr_expart_wzdform()		  
	))
	  
; /* ---------------------------------
; define the 2rd main form
; --------------------------------- */	  
	  
	  
defun( cr_expart_wzdform ()
let( ()
        wzdform_file = "./artwzd.form"
        formwzd = outfile(wzdform_file "w")
        fprintf(formwzd "FILE_TYPE=FORM_DEFN VERSION=2\n")
		
        fprintf(formwzd "FORM\n")
        fprintf(formwzd "FIXED\n")
        fprintf(formwzd "PORT 30 6\n")
        fprintf(formwzd "HEADER \"Art wizard\"\n")
        fprintf(formwzd "TILE\n")   ;tile begin
		
		fprintf(formwzd "\n")
		fprintf(formwzd "TEXT \"Art dir name: \"\n")
		fprintf(formwzd "TLOC 1 1\n")
		fprintf(formwzd "ENDTEXT\n\n")

		fprintf(formwzd "\n")
		fprintf(formwzd "TEXT \"Zero line width: \"\n")
		fprintf(formwzd "TLOC 1 4\n")
		fprintf(formwzd "ENDTEXT\n\n")

		
		fprintf(formwzd "\n")
		fprintf(formwzd "TEXT \"Int_places: \"\n")		
		fprintf(formwzd "TLOC 1 7\n")
		fprintf(formwzd "ENDTEXT\n\n")

		fprintf(formwzd "\n")
		fprintf(formwzd "TEXT \"Dec_places: \"\n")	
		fprintf(formwzd "TLOC 1 10\n")
		fprintf(formwzd "ENDTEXT\n\n\n")

		
		fprintf(formwzd "TEXT %L\n" curdsnunit) 
		fprintf(formwzd "TLOC 23 4\n")
		fprintf(formwzd "ENDTEXT\n")	
		
		
        fprintf(formwzd,"FIELD dft_dirname\n\n")
        fprintf(formwzd,"FLOC 13 1\n")     
        fprintf(formwzd,"STRFILLIN 8 4\n")
        fprintf(formwzd,"ENDFIELD\n\n")			
		
        fprintf(formwzd,"FIELD dftlw\n\n")
        fprintf(formwzd,"FLOC 13 4\n")     
        fprintf(formwzd,"REALFILLIN 8 4\n")	
        fprintf(formwzd,"ENDFIELD\n\n")		
		
		
        fprintf(formwzd,"FIELD int_places\n\n")
        fprintf(formwzd,"FLOC 13 7\n")     
        fprintf(formwzd,"INTFILLIN 8 4\n")	
        fprintf(formwzd,"ENDFIELD\n\n")	


        fprintf(formwzd,"FIELD dec_places\n\n")
        fprintf(formwzd,"FLOC 13 10\n")     
        fprintf(formwzd,"INTFILLIN 8 4\n")		
        fprintf(formwzd,"ENDFIELD\n\n")
		
		
		; fprintf(formwzd "\n")
		; fprintf(formwzd "TEXT \"Set the env\"\n")		
		; fprintf(formwzd "TLOC 11 13\n")
		; fprintf(formwzd "ENDTEXT\n\n")		
		; fprintf(formwzd "\n")
		; fprintf(formwzd "TEXT \"Set the NC custmz\"\n")		
		; fprintf(formwzd "TLOC 11 17\n")
		; fprintf(formwzd "ENDTEXT\n\n")	
		; fprintf(formwzd "\n")
		; fprintf(formwzd "TEXT \"Place drill legend\"\n")		
		; fprintf(formwzd "TLOC 11 21\n")
		; fprintf(formwzd "ENDTEXT\n\n")	
		; fprintf(formwzd "\n")
		; fprintf(formwzd "TEXT \"Drill & Route\"\n")		
		; fprintf(formwzd "TLOC 11 25\n")
		; fprintf(formwzd "ENDTEXT\n\n")	
		; fprintf(formwzd "\n")
		; fprintf(formwzd "TEXT \"Set & Export ART\"\n")		
		; fprintf(formwzd "TLOC 11 29\n")
		; fprintf(formwzd "ENDTEXT\n\n")	
		; fprintf(formwzd "\n")
		; fprintf(formwzd "TEXT \"Export Placement TXT\"\n")		
		; fprintf(formwzd "TLOC 11 33\n")
		; fprintf(formwzd "ENDTEXT\n\n")			
		
		
        fprintf(formwzd "FIELD setenv\n")
        fprintf(formwzd "FLOC 4 13\n")
        fprintf(formwzd "MENUBUTTON \"STP1:Set the env\" 22 4\n")  ;
        fprintf(formwzd "ENDFIELD\n")
 		
		
        fprintf(formwzd "FIELD nccustmz\n")
        fprintf(formwzd "FLOC 4 17\n")
        fprintf(formwzd "MENUBUTTON \"STP2:Nc custmz\" 22 4\n")
        fprintf(formwzd "ENDFIELD\n") 

        fprintf(formwzd "FIELD drllegend\n")
        fprintf(formwzd "FLOC 4 21\n")
        fprintf(formwzd "MENUBUTTON \"STP3:Drill legend\" 22 4\n") 
        fprintf(formwzd "ENDFIELD\n")		
			
        fprintf(formwzd "FIELD ncdrilroute\n")
        fprintf(formwzd "FLOC 4 25\n")
        fprintf(formwzd "MENUBUTTON \"STP4:Drill & route\" 22 4\n") 
        fprintf(formwzd "ENDFIELD\n")	
		
        fprintf(formwzd "FIELD setexpart\n")
        fprintf(formwzd "FLOC 4 29\n")
        fprintf(formwzd "MENUBUTTON \"STP5:Export art\" 22 4\n") 
        fprintf(formwzd "ENDFIELD\n")	

        fprintf(formwzd "FIELD expplace\n")
        fprintf(formwzd "FLOC 4 33\n")
        fprintf(formwzd "MENUBUTTON \"STP6:Export placement\" 22 4\n") 
        fprintf(formwzd "ENDFIELD\n")	

        fprintf(formwzd "FIELD exit\n")
        fprintf(formwzd "FLOC 11 37\n")
        fprintf(formwzd "MENUBUTTON \"ExiT\" 8 4\n") 
        fprintf(formwzd "ENDFIELD\n")

		
        fprintf(formwzd "ENDTILE\n") 
        fprintf(formwzd "ENDFORM\n") 
        close(formwzd)  
		
		  artwz_form = axlFormCreate((gensym) wzdform_file nil 'cr_expart_wzac t)  ;  cr_expart_wzac
		  axlFormDisplay(artwz_form)
		  deleteFile("artwzd.form")
		  
		  dftlwidth = 6 * (1.0/ dounit)
		  axlFormSetField(artwz_form "dftlw" dftlwidth)
		  axlFormSetField(artwz_form "dft_dirname" "ART")
		  axlFormSetField(artwz_form "int_places" 2)
		  axlFormSetField(artwz_form "dec_places" 5)			

		  ;   load("Quick_ExportARK.il")	cr_expart_wzdform
		  ;   Quick_ExportARK_Wizard
	  ))
/* ---------------------------------
define the 2rd main form function
--------------------------------- */	  
	  
	  defun(cr_expart_wzac (artwz_form)
	  let( ()
	  case(artwz_form -> curField
	  
	       ("setenv"
		      dft_dirname = axlFormGetField(artwz_form "dft_dirname")
		  	  if(equal(isDir(strcat("./" dft_dirname)) t)
	          then
	          allfilename = cddr(getDirFiles(strcat("./" dft_dirname)))
	          foreach(filename allfilename
	                  deleteFile(sprintf(nil "./%s/%s" dft_dirname filename))
	                  )
					   clearrest = t
	                  else
	                  axlSetVariable("ads_sdart" dft_dirname) ;set ART dir	 
		        )
				
              	axlUIConfirm("Set the environment successful")			  
		   )
		   
	       ("nccustmz"
		          if( quicksetnccus()
				  then
				  axlUIConfirm("Set the drill customization successful")
                   else
				   axlUIConfirm("Can't set the drill customization")
				   )				  
		   )		   
		   
		   
		   ("drllegend"
		          placloc()
				  quicktext() 
		          if( quickdrlegend()
				  then
				  axlUIConfirm("Place the drill legend successful")
                   else
				   axlUIConfirm("Can't place the drill customization")
				   )	
		   )
		   
		   
		   ("ncdrilroute"
		          int_places = axlFormGetField(artwz_form "int_places")
		          dec_places = axlFormGetField(artwz_form "dec_places") 
			      wzdacc = axlGetParam("paramDesign")->accuracy
				  if(and(wzdacc<3 dec_places-wzdacc>=1 int_places<6  int_places>1 dec_places<6  dec_places>2) == nil
			       then
			        axlUIConfirm("The accuracy should be less than 2,plese check your design accuracy")
			        else		         
		            if( quickNC_drill_route()
				     then
				      axlUIConfirm("Drill & Route successful")
                       else
				        axlUIConfirm("Fail to Drill & Route")
				   ))				
                  
                  	   
		   )
		  
		   ("setexpart" 
		          dft_lw = axlFormGetField(artwz_form "dftlw")
			      wzdacc = axlGetParam("paramDesign")->accuracy
				  if(and(wzdacc<3 dec_places-wzdacc>=1 int_places<6  int_places>1 dec_places<6  dec_places>2) == nil
			       then
			        axlUIConfirm("The accuracy should be less than 2,plese check your design accuracy")
			        else				  
 		          if( quickexart()
				  then
				  axlUIConfirm("Set & Export the ART files successful")
                   else
				   axlUIConfirm("Fail to Set or Export the ART")
				   ))	                 
                     
		   )
		   
		   ("expplace"
		          dft_dirname = axlFormGetField(artwz_form "dft_dirname")
 		          if( CrPlace_mov()
				  then
				  axlUIConfirm("Create the place file successful")
                   else
				   axlUIConfirm("Fail to Create the place file")
				   )			      
		         
		   )
		   
		   ("exit"
		         axlFormClose(artwz_form)
		         deleteFile(form_file)
		   )		   
		   
		  )
		  )
		  )
/* ---------------------------------
set the drill custm
--------------------------------- */

defun( quicksetnccus ()
let( ()

;get  & set thr padstacks' drillcharactor

          allpadID = axlDBGetDesign()->padstacks
		  allThrpadID = list()
		  foreach(padid allpadID
		           padt = padid->isThrough
				   if( equal(padt t)
				   allThrpadID = append1(allThrpadID padid)
		             )
				  )
		  thrcplist = throplist = thrrplist = list()
		  foreach(one allThrpadID
		           drilltype = one->holeType
				   cond(
				        (equal(drilltype "circle_drill") thrcplist = append1(thrcplist one))
						(equal(drilltype "oval_slot") throplist = append1(throplist one))
						(equal(drilltype "etc") thrrplist = append1(thrrplist one))
						)
				    )
;make a list of the circle drillhole  by the drillDiameter

			 newthrcplist = list()
			 i = 0
			 j = 1
			 oldlength = length(thrcplist)
			 while(i<oldlength
                minp = nth(0 thrcplist)
				minpd = minp->drillDiameter
				j = 1
				while(j<length(thrcplist)
				    temppad = nth(j thrcplist)
					temppadd = temppad->drillDiameter
					if(minpd > temppadd
					   then
					   minp = temppad
					   minpd = minp->drillDiameter
					   )
					j= j +1
					)
			     newthrcplist = append1(newthrcplist minp)
				 thrcplist = remd(minp thrcplist)
				 i = i+1
				 )
	      newThrpadID = append(newthrcplist append(throplist thrrplist))

		  beginint = 65
		  foreach(padtid newThrpadID

		  		if(beginint <= 90
				  then
				  axlPadstackEdit(padtid 'drillChar symbolToString(intToChar(beginint)))
				  beginint = beginint+1
				  else
				  agin = (beginint-64)/26
				  left = mod((beginint-64) 26)
				  firstChar = intToChar(agin+64)
				  secondChar = intToChar(left+64)
				  DoubChar = strcat(symbolToString(firstChar) symbolToString(secondChar))
				  axlPadstackEdit(padtid 'drillChar DoubChar)
				  beginint = beginint+1
				  ;未加判断，因为焊盘类型应该不可能超过“ZZ”
				  )
				  )
     	 ))


 /* ---------------------------------
 calculate the spae to place the figure
 --------------------------------- */

 defun( placloc ()
	  axlVisibleDesign(nil)
 	  axlVisibleLayer("Board Geometry/Outline" t)
 	  axlClearSelSet()
 	  axlSetFindFilter( ?enabled (list "noall" "lines" "shapes") , ?onButtons (list "lines" "shapes"))

 	  alloutline = axlGetSelSet(axlAddSelectAll())   ;may contions more than 1 path or polygon

	  polyoutline = list()
	  foreach(onel alloutline
	          if(equal(onel->objType "polygon")
			     then
			     polyoutline = append1(polyoutline onel)
				 alloutline = remd(onel alloutline)
			     )
			  pathoutlinem = alloutline
			  )
			  
		  
			  pathoutline = list()
			  
	 foreach(ones pathoutlinem
	         onesty = ones->objType
			 if( onesty == "path"
			    then
			    segpath = ones->segments    ;list of line &arc			
				pathoutlinem = remd(ones pathoutlinem)
				pathoutline = append(pathoutline segpath)
				else  ;line arc
				pathoutline = append(pathoutline car(ones))
				)
				)

			  xloclist = yloclist = list()

			  foreach(poly polyoutline
			         curbox = poly->bBox   
					 xlloc = caar(curbox)
					 ylloc = cadar(curbox)
					 xrloc = caadr(curbox)
					 yrloc = cadadr(curbox)
					 xloclist = append1(append1(xloclist xlloc) xrloc)
					 yloclist = append1(append1(yloclist ylloc) yrloc)
					 )
					 
			  foreach(path pathoutline
			  
                    ; curpath = car(path->segments) 
                    curpathtype = path->objType
					
					; path = nth(0 pathoutline)
					

					   
					if(curpathtype == "line"
					then
		            curlinesta = path->startEnd
		            xlloc = caar(curlinesta)
		            ylloc = cadar(curlinesta)
		            xrloc = caadr(curlinesta)
					yrloc = cadadr(curlinesta)
		            xloclist = append1(append1(xloclist xlloc) xrloc)
		            yloclist = append1(append1(yloclist ylloc) yrloc) 
					else
							if(curpathtype == "arc"
							then
						    curarcent = path->xy
		                    curarr = path->radius
		                    xlloc = car(curarcent)-curarr
		                    ylloc = cadr(curarcent)-curarr
		                    xrloc = car(curarcent)+curarr
		                    yrloc = cadr(curarcent)+curarr
		                    xloclist = append1(append1(xloclist xlloc) xrloc)
		                    yloclist = append1(append1(yloclist ylloc) yrloc)
							  )
					   ) ;end if
					 )  ;end foreach
					 
					 
					 
			         boxlx = findmin(xloclist)
					 boxly = findmin(yloclist)
			         boxrx = findmax(xloclist)
					 boxry = findmax(yloclist)
					 


				designbox = axlDBGetDesign()->bBox 
					 dsnxlloc = caar(designbox)
					 dsnylloc = cadar(designbox)
					 dsnxrloc = caadr(designbox)
					 dsnyrloc = cadadr(designbox)
					 
					 
					 lftlx = abs(dsnxlloc-boxlx)
					 lftly = abs(dsnylloc-boxly)
					 lftrx = abs(dsnxrloc-boxrx)
					 lftry = abs(dsnyrloc-boxry)
					 
					 
					 if(lftlx>lftrx
					 then
					 lftx = lftlx
					 ncdlocx = boxlx - 2800*(1.0 / dounit)
					 else
					 lftx = lftrx
					 ncdlocx = boxrx + 300*(1.0 / dounit)
					 )
					 lfty = lftry
					 ncdlocy = boxry + 50*(1.0 / dounit)
					 
					 loccmd = sprintf(nil "pick grid %f %f" ncdlocx ncdlocy)
					 

				; lftxn = 	(1.0 / dounit)*lftx
				; lftyn = 	(1.0 / dounit)*lfty
				
				if( lftx > (1.0 / dounit)* 3000.0
				then
				spaist = t
				else
				spaist = nil
					 )
			 )
			 
	  			  ;   load("Quick_ExportARK.il")		 
 /* ---------------------------------
 set & place the drill legend
 --------------------------------- */
 defun( quickdrlegend ()
 let( ()
         p = outfile("quicklegend.scr\n")
         fprintf(p "setwindow pcb\n")
		 fprintf(p "generaledit\n")
		 fprintf(p "ncdrill legend\n")
		 fprintf(p "setwindow form.nc_drilllegend\n")
		 fprintf(p "FORM nc_drilllegend done\n")
		 fprintf(p "setwindow pcb\n")
		 fprintf(p loccmd)
		 fprintf(p "\n")
		 fprintf(p "generaledit\n")
		 close(p)
		 
		 axlShell("replay quicklegend.scr")
	   ))

 /* ---------------------------------
 make the Drill file & route file
 --------------------------------- */
				
					 
defun( quickNC_drill_route	 ()		  
	   axlShell("setwindow pcb") 
	   axlShell("generaledit") 
	   axlShell("ncdrill param ") 
	   axlShell("generaledit ") 
	   axlShell("setwindow form.nc_parameters") 
	   axlShell(sprintf(nil "FORM nc_parameters integer_places %d " int_places)) 
	   axlShell(sprintf(nil "FORM nc_parameters decimal_places %d " dec_places)) 

	   ; axlShell(pick grid 11981.45 2155.15)
		  ; int_places = 5
		  ; dec_places = 5
		  
	   axlShell("FORM nc_parameters done  ") 
	   axlShell("setwindow pcb") 
	   axlShell("nctape_full ") 
	   axlShell("setwindow form.nc_drill") 
	   axlShell("FORM nc_drill execute  ") 
	   axlShell("FORM nc_drill close  ") 
	   axlShell("setwindow pcb") 
	   axlShell("generaledit ") 
	   axlShell("NCroute ")
	   axlShell("setwindow form.nc_route")
	   axlShell("FORM nc_route execute  ") 
	   axlShell("FORM nc_route close  ") 
	   axlShell("setwindow pcb") 
	   axlShell("generaledit") 
		  )	

 /* ---------------------------------
define the findmin function
 --------------------------------- */							 
defun( findmin (numlist) 
let( ()
	  curlistl = length(numlist)
                mint = nth(0 numlist)
				j = 1
				while(j<curlistl
				    tempt = nth(j numlist)
					if(mint > tempt
					   mint = tempt
					   )
					j= j +1
					)
		curminnum = mint
		 ))
		 
		 

 /* ---------------------------------
define the findmax function
 --------------------------------- */      
defun( findmax (numlist)
let( ()
	  curlistl = length(numlist)
                maxt = nth(0 numlist)
				j = 1
				while(j<curlistl
				    tempt = nth(j numlist)
					if(maxt < tempt
					   maxt = tempt
					   )
					j= j +1
					)
		curmaxnum = maxt
		 ))
 /* ---------------------------------
 set &Export art
 --------------------------------- */
 defun( quickexart ()
      let( ()

	  ;set artwork option
      axlShell("setwindow pcb")
      axlShell("generaledit")	  
      axlShell("quickart ")
      axlShell("generaledit ")
      axlShell("setwindow form.artformcreat")
      axlShell(sprintf(nil "FORM artformcreat l_width %f " dft_lw))	  
      axlShell("FORM artformcreat do  ")
	  
	  ;create artwork
      axlShell("setwindow pcb")
      axlShell("generaledit")
      axlShell("artwork ")
      axlShell("setwindow form.film_control")
      axlShell("FORM film_control general_parameters ") 
	  axlShell(strcat("FORM film_control" strcat(unitmode " YES")))
      axlShell("FORM film_control film_max_x 2400")
      axlShell("FORM film_control film_max_y 1600")
      ; axlShell(strcat("FORM film_control format_int_places " int_places))
	  ; axlShell(strcat("FORM film_control format_dec_places " dec_places))   
      axlShell(sprintf(nil "FORM film_control format_int_places %d" int_places))
	  axlShell(sprintf(nil "FORM film_control format_dec_places %d" dec_places))  


      
	  axlShell("FORM film_control barco_dpf YES ")
	  axlShell("FORM film_control gerber_rs274x YES ")
	  
      axlShell("FORM film_control film_control ")
      axlShell("FORM film_control select_all ") 
      axlShell("FORM film_control create  ") 
      axlShell("setwindow text")
      axlShell("close") 
      axlShell("setwindow form.film_control")
      axlShell("FORM film_control ok  ")
      axlShell("setwindow pcb")
      axlShell("generaledit ")
	   ))
	   
	   
	   
	   
	   
  /* ---------------------------------
Creat the place text and move to dir "ART"
 --------------------------------- */
 
defun( CrPlace_mov ()
   let( () 
		 axlSetVariable("place_text_filename" nil)
         axlShell("setwindow pcb")
         axlShell("generaledit")
         axlShell("plctxt out")
         axlShell("setwindow form.plctxt")	 
         axlShell("FORM plctxt execute")
         axlShell("FORM plctxt cancel")
         axlShell("setwindow pcb")
         axlShell("generaledit")
		 newartln = strcat("./" dft_dirname "/place_txt.txt")
         axlOSFileMove("./place_txt.txt" newartln)		  
	  ))
	  
	  
	  
defun( quicktext ()
let( ()
		  curdsnunittxt = axlGetParam("paramDesign")->units
		   case(curdsnunittxt
	        ("mils"  du = 1)
		    ("millimeters" du = 40)
			;(u can add other units)
		      )


old_visList = axlVisibleGet()

setTextSize()
; RecoverDis()  ;old_visList = axlVisibleGet()
axlVisibleSet(old_visList)
))

;load("quick_textset.il")

defun( setTextSize ()
      let(()
	  ;1,GET 字体
	  Text_need = '("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16")
	  
	  foreach(text_block Text_need
	 	   p = axlGetParam(strcat("paramTextBlock:" text_block))
	 	   block_pl = atoi(text_block) ;change string to num   (1.0/du)
	 	   p->width = (15 + 5*block_pl)*(1.0/du)
	  	   p->height = (20 + 5*block_pl)*(1.0/du)
	  	   p->lineSpace = 25*(1.0/du)
	 	   p->photoWidth = 4*(1.0/du)
	 	   p->charSpace = 5*(1.0/du)
	  	  axlSetParam(p)	
	 	   )
	  ;set the textblock size
	  


	  
	  axlVisibleDesign(nil)
	  axlVisibleLayer("REF DES/SILKSCREEN_TOP" t)
	  axlVisibleLayer("REF DES/SILKSCREEN_BOTTOM" t)
	  axlClearSelSet()
	  axlSetFindFilter( ?enabled (list "noall" "text" "clinesegs") , ?onButtons (list "text"))
	  allrefs = axlGetSelSet(axlAddSelectAll())
	  foreach(oneref allrefs   
	          axlDBChangeText(oneref nil 2)
	          )
	  ;change the resdes
	  
	  axlVisibleDesign(nil)
	  axlVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_TOP" t)
	  ; axlVisibleLayer("BOARD GEOMETRY/SILKSCREEN_TOP" t)
	  axlVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" t)
	  ; axlVisibleLayer("BOARD GEOMETRY/SILKSCREEN_BOTTOM" t)
	  axlClearSelSet()
	  axlSetFindFilter( ?enabled (list "noall" "text" "clinesegs") , ?onButtons (list "text"))
	  alloth_text = axlGetSelSet(axlAddSelectAll())   
	  ;nth(0 alloth_text)   axlDbidName(nth(0 alloth_text))   axlGetParam  nth(0 alloth_text)->xy   nthelem( 1 '(a b c) ) nth(1 '(a b c))
	  foreach(onetext alloth_text 
	           axlDBChangeText(onetext nil 1)
			   )
	  
	  ;change all other text
	  ))
	  
	  
defun( RecoverDis ()
      let(()
	  
	  axlVisibleDesign(nil)
	 foreach(visclass old_visList
	 if(
	 nth(4 visclass) != nil
	 then
	 viscurclass = nth(2 visclass)
	 vissubclasslist = nth(6 visclass)
	 foreach(layername vissubclasslist
	 visiblelaer = strcat(viscurclass "/" car(layername))
	 axlVisibleLayer(visiblelaer cadr(layername))
	 ;recover the layer display
	 )
	 )
	 )
	 ))
	  
	  
defun(quickart ()
     let( ()
	   curdsnunit = axlGetParam("paramDesign")->units
	   old_visList = axlVisibleGet()
        ;l_width = nil
		curdesignunit = axlGetParam("paramDesign")->units		
		artformcreat()
         ))
		 
; ---------------defun the form----------------------
        defun(artformcreat ()
		let( ()
        artform_file = "artformcreat.form"
		;artform_file = axlTempFile()
        artform = outfile(artform_file "w")
        fprintf(artform "FILE_TYPE=FORM_DEFN VERSION=2\n")
		
        fprintf(artform "FORM\n") ;form begin 
        fprintf(artform "FIXED\n")
        fprintf(artform "PORT 28 6\n")
        fprintf(artform "HEADER \"Line width\"\n")
        fprintf(artform "TILE\n\n")   ;tile begin
		
		;------------------define the text
		
		fprintf(artform "\n")
		fprintf(artform "TEXT \"width: \"\n")
		fprintf(artform "TLOC 3 3\n")
		fprintf(artform "ENDTEXT\n")
		
		fprintf(artform "\n")
		
		fprintf(artform "TEXT %L\n" curdesignunit) 
		;fprintf(artform "TEXT \"  m \"\n")
		fprintf(artform "TLOC 20 3\n")
		fprintf(artform "ENDTEXT\n")		
		
		;------------------define the field		
		
        fprintf(artform,"FIELD l_width\n\n");开始写入文本框定义
        fprintf(artform,"FLOC 10 3\n")       ;定义坐标位置
        fprintf(artform,"STRFILLIN 8 4\n");控件尺寸
        fprintf(artform,"ENDFIELD\n\n")
		
		
		;-----------------define the button
		
        fprintf(artform "FIELD do\n") 
        fprintf(artform "FLOC 5 7\n")
        fprintf(artform "MENUBUTTON \"Create\" 8 3\n")
        fprintf(artform "ENDFIELD\n")		
		
        fprintf(artform "FIELD close\n")   
        fprintf(artform "FLOC 16 7\n")
        fprintf(artform "MENUBUTTON \"Exit\" 8 3\n")
        fprintf(artform "ENDFIELD\n")
		
        fprintf(artform "ENDTILE\n") 
		
        fprintf(artform "ENDFORM\n") 
        close( artform)
		

		
		  artworkform = axlFormCreate( (gensym) artform_file '(e inner) 'get_acc_width t)
		  axlFormDisplay(artworkform)
		  deleteFile("artformcreat.form")
		  
		   case(curdsnunit
			   ("mils" dft_lwth = 6)
			   ("millimeters" dft_lwth = 0.15)
			    )
		  
		  
		  axlFormSetField(artworkform "l_width" dft_lwth)		  
		  
		  
        )) ; end defun form 
;-------------------------end--------------- ------------





;-------------------- get_width & creat  ---------------------------
         defun(get_acc_width (artworkform)
		 let( ()
			     case(artworkform -> curField
				 
				        ;load("quick_artwork.il")
				 
				     ("do"
		 				 lwidth = axlFormGetField(artworkform "l_width")				 
							;judge the lwidth fload or int
							xx = equal(strncmp(lwidth "." 1) 1)
						        if(
							      eq(xx t)
								  then
							      deflwidth = atof(lwidth)
							      else
							      deflwidth = atoi(lwidth)
							       )
							x = rexMatchp("[^0-9.]+" lwidth)			   
					      if( eq(x t)
						  then
						       axlFormSetField(artworkform "l_width" "Error")
						       axlUIConfirm("Please input the right number")					 
					      else
						     if( eq(x nil)
							 then
                               quickartset() 
                               axlFormClose(artworkform)
                               deleteFile(artform_file)
							   axlUIConfirm("ART work setup successfully")
							    
							   )					   
							)
					 )
                     ("close"
                         axlFormClose(artworkform)
                         deleteFile(artform_file)
                      )    
			     );end case   
		));end defun
;-----------------------------end--------------------------------------

	  

	  
;-----------------------------Main functoin begin--------------------------------------
procedure(quickartset()
      let(()
	         
             layerlist = car(list(axlGetParam("paramLayerGroup:ETCH")->groupMembers)) 
             layercont = length(layerlist)
             layertotal = layercont
             num = 0

			 delnum = 0
	         oldartlayerlist = car(list(axlGetParam("artwork")->groupMembers)) ;("top" "bottom")
			 oldartlayerlistcount = length(oldartlayerlist)
			 deloldartlayerlist = list()
			 while((oldartlayerlistcount-1 >= delnum)
			 drlid = axlGetParam(strcat("artwork:" nth(delnum oldartlayerlist)))
			 deloldartlayerlist = append1(deloldartlayerlist drlid)
			 delnum = delnum+1
			 )
			 axlDeleteObject(deloldartlayerlist)
			 ;delet done
             namelist = list("01_" "02_" "03_" "04_" "05_" "06_" "07_" "08_" "09_" "10_" "11_" "12_" "13_" "14_" "15_" 
			 "16_" "17_" "18_" "19_" "20_" "21_" "22_" "23_" "24_" "25_" "26_" "27_" "28_" "29_" "30_" "31_" "32_" "33_" "34_" "35_" "36_")
             drilllist = list("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12 " "13" "14" "15" "16" "17" "18" "19" 
			 "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30" "31" "32" "33" "34" "35" "36")
             drilllayer = strcat("MANUFACTURING/NCLEGEND-1-"  nth(layertotal-1 drilllist))
             drilllayerlist = list("BOARD GEOMETRY/OUTLINE" "MANUFACTURING/NCDRILL_LEGEND" "MANUFACTURING/NCDRILL_FIGURE" "MANUFACTURING/PHOTOPLOT_OUTLINE")
             drillname = strcat(nth(layertotal namelist) "DRILL")
             layercheck = axlIsLayer(drilllayer) 
			 
			 ;这一部分是才开始学的时候写的，很多功能不懂，现在也不想改了，功能可以实现就行。
			 
			 ;DO DRILL work or not
			 if((layercheck == nil)
			then 
			axlUIConfirm("Please NC drill first")

			 else
             while((layercont >= 1) 
                     numadd = nth(num namelist)
                     layeradd = list("BOARD GEOMETRY/OUTLINE" strcat("ETCH/",car(layerlist)) 
                                   strcat("VIA CLASS/",car(layerlist)) strcat("PIN/",car(layerlist)))
                     layername = strcat(numadd,car(layerlist))					 
                     Filmcreat(layername layeradd) 
                       layercont = layercont-1
                       layerlist = cdr(layerlist)
                       num = num+1
                   )				   
            ;DRILL   ——————————with B/B VIA         
             posbdrillist = car(list(axlGetParam("paramLayerGroup:MANUFACTURING")->groupMembers))   

			 posbdrilltotal = length(posbdrillist)
			 numdrl = 0
             while((posbdrilltotal-1 >= numdrl)
			 posbdrillayer = nth(numdrl posbdrillist)
			 if(strncmp("NCLEGEND" posbdrillayer 8) == 0
			   drilllayerlist = append1(drilllayerlist strcat("MANUFACTURING/" posbdrillayer))
			   )
			   numdrl = numdrl+1
			   )
			   ; drilllayerlist = append1(drilllayerlist "MANUFACTURING/"
		   Filmcreat(drillname     drilllayerlist)  
           ; PASTEMASK_TOP
           Filmcreat(strcat(nth(layertotal+1 namelist) "PASTEMASK_TOP") '("BOARD GEOMETRY/OUTLINE" "PIN/PASTEMASK_TOP" "PACKAGE GEOMETRY/PASTEMASK_TOP"))
           ; PASTEMASK_BOTTOM
           Filmcreat(strcat(nth(layertotal+2 namelist) "PASTEMASK_BOTTOM") '("BOARD GEOMETRY/OUTLINE" "PIN/PASTEMASK_BOTTOM" "PACKAGE GEOMETRY/PASTEMASK_BOTTOM"))
           ;SOLDERMASK_TOP
           Filmcreat(strcat(nth(layertotal+3 namelist) "SOLDERMASK_TOP") '("BOARD GEOMETRY/OUTLINE" 
		                        "PIN/SOLDERMASK_TOP" "PACKAGE GEOMETRY/SOLDERMASK_TOP" "BOARD GEOMETRY/SOLDERMASK_TOP" ))
           ;SOLDERMASK_BOTTOM
           Filmcreat(strcat(nth(layertotal+4 namelist) "SOLDERMASK_BOTTOM")   '("BOARD GEOMETRY/OUTLINE" 
                                 "PIN/SOLDERMASK_BOTTOM" "PACKAGE GEOMETRY/SOLDERMASK_BOTTOM" "BOARD GEOMETRY/SOLDERMASK_BOTTOM" ))
           ;SILKSCREEN_TOP
           Filmcreat(strcat(nth(layertotal+5 namelist) "SILKSCREEN_TOP")  '("BOARD GEOMETRY/OUTLINE"  
                                "REF DES/SILKSCREEN_TOP" "PACKAGE GEOMETRY/SILKSCREEN_TOP" "BOARD GEOMETRY/SILKSCREEN_TOP" ))
           ;SILKSCREEN_BOTTOM
           Filmcreat(strcat(nth(layertotal+6 namelist) "SILKSCREEN_BOTTOM")  '("BOARD GEOMETRY/OUTLINE"  
                                "REF DES/SILKSCREEN_BOTTOM" "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" "BOARD GEOMETRY/SILKSCREEN_BOTTOM" ))
           ;user preferrence layer1 
          ;Filmcreat(strcat(nth(layertotal+7 namelist) "user preferrence layer1")  '("BOARD GEOMETRY/OUTLINE"  
          ;                     "REF DES/SILKSCREEN_BOTTOM" "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" "BOARD GEOMETRY/SILKSCREEN_BOTTOM" ))
		  			

				; axlShell("artwork")	
				axlVisibleSet(old_visList)
				axlUIWRedraw(nil)
				
         )
		 )
		 )
	 	
;-----------------------------Main functoin end-------------------------------------- 





;-----------------------define the Filmcreat function -------------------------------

procedure( Filmcreat(FilmName artList)
      let(()
	  cur_designacc = axlGetParam("paramDesign")->accuracy
	  cur_unwidth = fix(deflwidth * expt(10 cur_designacc))
	  
			   
	  
     ;judge the N/P to set current layer
		   if( strncmp(nth(1 artList) "ETCH/" 4) == 0 
		       then
		          if(axlIsLayerNegative(nth(1 artList)) == t  
			      then
			      artworknum = 0
			      else
	 			  artworknum = 1
				  );end if
				else
				artworknum = 1 

			 )			 

     ;display & set the art option
           axlVisibleDesign(nil)
           ; foreach( layer artList axlVisibleLayer(layer t))
          (axlfcreate FilmName list(0 0 0 cur_unwidth 0 artworknum 0 0 0 0 0 1 1) artList)
		  
		  
		 )
		 
		 )
		 
	  			  ;load("Quick_ExportARK.il")

;-----------------------define the NOshape Fill function -------------------------------		 
defun( OpenCloseSpfl ()
   let( () 
		 curtype = axlGetVariable("no_etch_shape_display")
		 newtyep = not(curtype) 
		 if(newtyep == t
		 then
		 axlSetVariable("no_etch_shape_display" newtyep)		 
         axlUIWRedraw(nil)		 
		 else
		 if(newtyep == nil
		 then
	     axlSetVariable("no_etch_shape_display" newtyep)		 
           
		 p = outfile("niltheshape.scr\n")
         fprintf(p "setwindow pcb\n")
		 fprintf(p "enved\n")
		 fprintf(p "setwindow form.prfedit\n")
		 fprintf(p "FORM prfedit done\n")
		 fprintf(p "setwindow pcb\n")
		 close(p)
		 
		 axlShell("replay niltheshape.scr")
		 axlUIWRedraw(nil)
		 ))
 ))
 
 	
  
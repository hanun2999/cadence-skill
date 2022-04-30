/* 
├─ 
│ ├─        程序名称：quick_pinnetconnection.il
│ ├─        程序功能：快速输出QFP,QFN，BGA或者其他引脚数量>=80的封装的引脚和网络连接关系
│ ├─        创建时间：2014年08月01日 
│ ├─        作    者：kevin wong
│ ├─        Q      Q：263350809
├─ 


1，2014.08.01添加基本功能；

*/ 

axlCmdRegister( "quick_p2net" `Quick_Pin2Net)

	
/* ---------------------------------
Create the main function
--------------------------------- */
      defun(Quick_Pin2Net ()
	  
	  ; Quick_Pin2Net_form()
	  ; load("quick_pinnetconnection.il")
	  
	  if(writeloc = axlDMFileBrowse("ALLEGRO_TEXT" t ?defaultName "Pin to net connection" ?title "Save as")
	  then
	   writep = outfile(writeloc)
	  allsym = axlDBGetDesign()->components
	  symneedlist = list()
	  foreach(onesymid allsym  
               	onesymname = upperCase(onesymid->package)	
	          if(or(strncmp("BGA" onesymname 3) == 0,strncmp("QFP" onesymname 3) == 0,strncmp("QFN" onesymname 3) == 0,length(onesymid->pins)>=80)
			    then
				symneedlist = append1(symneedlist onesymid)
					)			
				)
			if(symneedlist
			    then
		        foreach(symid symneedlist Excelout(symid))
                else
                axlUIConfirm("there seemed nothing to Export ^!^")
                deleteFile(writeloc)
			   )
         	 
	  ; else
	  ; axlUIConfirm("Please choose the right path !")
	)
	close(writep)
	)
/* ---------------------------------
Create the Excelout function
--------------------------------- */	  
     defun(Excelout (symdbid)
	       comname = symdbid->deviceType   ;EP4CE6F17_7_BGA256P1_(S1+S2+S3)
	       ref = symdbid->name             ;U28
		   package = symdbid->package      ;BGA256P1
		   pinlist = symdbid->pins         ;all the pins' dbid of cursym
		   fprintf(writep,"*******************************************\n" )
		   fprintf(writep,"The connection of the symbol  %s-%s\n" ref comname)
		   fprintf(writep,"symbol    pin                   net\n")
		   foreach(curpin pinlist
				   curpinnetname = curpin->net->name     ;vcc3v3 
			       curpinnum = curpin->number		     ;T12 
           	fprintf(writep,"%s       %s                   %s\n" ref curpinnum curpinnetname)			   
		           )
		   fprintf(writep,"*******************************************\n" )	 
		   )


	  

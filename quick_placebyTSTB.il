/* 
├─ 
│ ├─        程序名称：quick_placebyTSTB
│ ├─        程序功能：根据所在面以及THR/SMD类型导出4种坐标文件，分别为place_TT,place_TS,place_BT,place_BS.
│ ├─        创建时间：2013年12月11日
│ ├─        作    者：kevin wong
│ ├─        Q      Q：263350809
├─ 


1，2012.12.11基本功能设置；
*/ 

axlCmdRegister( "quick_tstb" 'quick_placebyTSTB)


/* ---------------------------------
Create the main function
--------------------------------- */
	 defun(quick_placebyTSTB ()
	 cur_units = axlGetParam("paramDesign")->units
	 outputtitle = strcat("UUNITS = " upperCase(cur_units))
	 
	 writep1 = outfile("./place_ThrBot.txt")
	 writep2 = outfile("./place_ThrTop.txt")
	 writep3 = outfile("./place_SmdBot.txt")
	 writep4 = outfile("./place_SmdTop.txt")
	 fprintf(writep1,outputtitle)
	 fprintf(writep2,outputtitle)
	 fprintf(writep3,outputtitle)
	 fprintf(writep4,outputtitle)
	 fprintf(writep1,"\n")
	 fprintf(writep2,"\n")
	 fprintf(writep3,"\n")
	 fprintf(writep4,"\n")		 
	 close(writep1)
	 close(writep2)
	 close(writep3)
	 close(writep4)
	 
		   allcomDB = axlDBGetDesign()->components
		   foreach(comDB allcomDB
		   cur_compinslist = comDB->pins
		   cur_compin = car(cur_compinslist)		   
		   cur_comTS = cur_compin->isThrough
		   cur_comTB = cur_compin->isMirrored
		   	if(equal(cur_comTS t);thr
			       then
				   if(
				   equal(cur_comTB t);bottom
				   then
				   outputloc(comDB "./place_ThrBot.txt")
				   else
				   outputloc(comDB "./place_ThrTop.txt")
				      )
			     else              ;SMD
				   if(
				   equal(cur_comTB t)
				   then
				   outputloc(comDB "./place_SmdBot.txt")
				   else
				   outputloc(comDB "./place_SmdTop.txt")
				      )			 
	            )

		        )
		  )
		  
/* ---------------------------------
Create output function
--------------------------------- */		  
		  
	 defun(outputloc (compdbid loctiontxt)	
	               cur_comref = compdbid->name                ;string "U52"
	               cur_comloc = compdbid->symbol->xy          ;list    '(x y)   flonum
	               comrot = compdbid->symbol->rotation     ;flonum   90
	               cur_comnam = compdbid->symbol->name         ;string "SO-8"
				   xloc = sprintf(nil "%f" car(cur_comloc))
				   yloc = sprintf(nil "%f" nth(1 cur_comloc))
				   cur_comrot = sprintf(nil "%f" comrot)
				   
	          writep = outfile(loctiontxt "a")
			  fprintf(writep,cur_comref)
			  fprintf(writep,"                   ")
			  fprintf(writep,xloc)
			  fprintf(writep,"       ")
			  fprintf(writep,yloc)
			  fprintf(writep,"       ")
			  fprintf(writep,cur_comrot)
			  fprintf(writep,"    ")
			  fprintf(writep,cur_comnam)
			  fprintf(writep,"\n")
			  close(writep)
		)

/* 
├─ 
│ ├─        程序名称： Quick_Text_set
│ ├─        程序功能：设置1-16号字体大小，并把当前工程的丝印修改为2号字体，封装标号修改为1号。
│ ├─        创建时间：2013年08月20日 
│ ├─        作    者：kevin wong
│ ├─        Q      Q：263350809
├─ 



*/ 
axlCmdRegister("quick_textset" 'quicktext)


;get the old layer display,for recover


defun( quicktext ()
let( (curdsnunit)
		  curdsnunit = axlGetParam("paramDesign")->units
		   case(curdsnunit
	        ("mils"  du = 1)
		    ("millimeters" du = 0.0254 )
			;(u can add other units)
		      )


old_visList = axlVisibleGet()

setTextSize()
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
	  ;if u need other text ,please add below:
	  ;axlVisibleLayer("REF DES/assembly_TOP" t)
	  
	  
	  axlClearSelSet()
	  axlSetFindFilter( ?enabled (list "noall" "text" "clinesegs") , ?onButtons (list "text"))
	  allrefs = axlGetSelSet(axlAddSelectAll())
	  foreach(i allrefs   
	          axlDBChangeText(i nil 2)
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
	  foreach(i alloth_text
	  axlDBChangeText(i nil 1))
	  ;change all other text
	  ))
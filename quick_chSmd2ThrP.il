/* 
├─ 
│ ├─        程序名称： quick_chSmd2ThrP.il
│ ├─        程序功能：检查背面smd器件到THR引脚距离(自定义)，并高亮不符合对象
│ ├─        创建时间：2014年08月12日 
│ ├─        作    者：王凯
│ ├─        Q      Q:263350809
├─

*/
axlCmdRegister("quick_smd2thrp" 'quick_chSmd2ThrP )

;load("quick_chSmd2ThrP.il")
 


/* ---------------------------------
define the main function
--------------------------------- */ 

defun( quick_chSmd2ThrP ()
    let( ()
	  Dehilightall()	
	  ; getallbBox()
      curdsnunit = axlGetParam("paramDesign")->units
	  ; old_display = axlVisibleGet()

	  ; axlVisibleSet(old_display)	  
	  chSmd2ThrPformcreat()
	  ))
	  
	  
; defun(Dehilightall ()
	  ; let( ()
	      ; axlVisibleLayer("PIN/TOP" t)
		  ; axlVisibleLayer("PIN/BOTTOM" t)
	  	  ; axlClearSelSet()
	  	  ; axlSetFindFilter(?enabled '(noall  pins) ?onButtons '(all)) 
	  	  ; allpinsel = axlGetSelSet(axlAddSelectAll())
		  ; axlClearSelSet()
	  	  ; axlSetFindFilter(?enabled '(noall  symbols) ?onButtons '(all)) 
	  	  ; allsymsel = axlGetSelSet(axlAddSelectAll())	
	  	  ; allsel = append(allpinsel allsymsel)
		  ; foreach(one allsel axlDehighlightObject(one)) 
		  ; axlClearSelSet()	  
	      ; ))  
defun(Dehilightall ()	  	  
	 axlShell("dehilight")
	 axlShell("setwindow form.mini")
	 axlShell("FORM mini dhlt_all")
	 axlShell("setwindow pcb")
	 axlShell("done")
	 )
	  
/* ---------------------------------
define the  function form
---------------------------------  */
	  
 defun( chSmd2ThrPformcreat ()
 let( ()
        form_file = "./chSmd2ThrP.form"
        formc = outfile(form_file "w")
        fprintf(formc "FILE_TYPE=FORM_DEFN VERSION=2\n")
		
        fprintf(formc "FORM\n")
        fprintf(formc "FIXED\n")
        fprintf(formc "PORT 29 6\n")
        fprintf(formc "HEADER \"Smd2ThrP check\"\n")
        fprintf(formc "TILE\n")   ;tile begin
		
        ;选择
        fprintf(formc "FIELD TOP\n")
        fprintf(formc "FLOC 5 4\n")
        fprintf(formc "FGROUP \"layer\"\n")
        fprintf(formc "CHECKLIST \"Top\" \"layer\"\n")
        fprintf(formc "ENDFIELD\n")		
		
        fprintf(formc "FIELD BTM\n")
        fprintf(formc "FLOC 15 4\n")
        fprintf(formc "FGROUP \"layer\"\n")
        fprintf(formc "CHECKLIST \"Bottom\" \"layer\"\n")
        fprintf(formc "ENDFIELD\n")
		
		;界面
		fprintf(formc "\n")
		fprintf(formc "TEXT \"The layer to be checked: \"\n")
		fprintf(formc "TLOC 5 1\n")		
		fprintf(formc "ENDTEXT\n\n")
		
		fprintf(formc "\n")
		fprintf(formc "TEXT \"Input the min clearance: \"\n")
		fprintf(formc "TLOC 5 7\n")
		; fprintf(formc "OPTIONS underline\n")		
		fprintf(formc "ENDTEXT\n\n")	 
		
		
		fprintf(formc "TEXT \"Min: \"\n" ) 
		fprintf(formc "TLOC 6 10\n")
		fprintf(formc "ENDTEXT\n")


        fprintf(formc,"FIELD clearance\n\n")  ;输入间距
        fprintf(formc,"FLOC 10 10\n")
        fprintf(formc,"INTFILLIN 8 8\n")	
        fprintf(formc,"ENDFIELD\n\n")


		fprintf(formc "TEXT %L\n" curdsnunit) ;单位
		fprintf(formc "TLOC 20 10\n")
		fprintf(formc "ENDTEXT\n")		
		
		;控制组件  Smd2Tform next_view
        fprintf(formc "FIELD next_view\n")
        fprintf(formc "FLOC 10 13\n")
        fprintf(formc "STRFILLIN 8 8\n")
        fprintf(formc "ENDFIELD\n")

		
        fprintf(formc "FIELD prv_ctl\n")
        fprintf(formc "FLOC 5 13\n")
        fprintf(formc "MENUBUTTON \"<<\" 3 3\n")
        fprintf(formc "ENDFIELD\n")
   

        fprintf(formc "FIELD next_ctl\n")
        fprintf(formc "FLOC 21 13\n")
        fprintf(formc "MENUBUTTON \">>\" 3 3\n")
        fprintf(formc "ENDFIELD\n")
		
		
		;按钮
        fprintf(formc "FIELD check\n")
        fprintf(formc "FLOC 5 16\n")
        fprintf(formc "MENUBUTTON \"Check\" 8 3\n")
        fprintf(formc "ENDFIELD\n")

        fprintf(formc "FIELD exit\n")
        fprintf(formc "FLOC 17 16\n")
        fprintf(formc "MENUBUTTON \"Exit\" 8 3\n") 
        fprintf(formc "ENDFIELD\n")	
        
		
        fprintf(formc "ENDTILE\n") 
        fprintf(formc "ENDFORM\n") 
        close( formc)
		
		
		  Smd2Tform = axlFormCreate( (gensym) form_file `(e inner) 'formc_action t)
		  axlFormDisplay(Smd2Tform)
		  axlUIWPrint(Smd2Tform "Kevin Wong") 
		  axlFormSetField(Smd2Tform "clearance" 120)
		  axlFormSetField(Smd2Tform "BTM" t)
		  
		  
		   
		  
		  
		  
		  
;load("quick_chSmd2ThrP.il")  quick_chSmd2ThrP
        )) ; end defun form 

/* ---------------------------------
define the form action
--------------------------------- */

		
defun( formc_action (Smd2Tform)
      let( ()
	  case(Smd2Tform -> curField
	  
	       ("prv_ctl"
				   axlMsgPut("Location the previous position.")		   
				   axlUIWPrint(Smd2Tform "Kevin Wong") 
				   location_previous()
		           ; axlFormSetField(Smd2Tform next_view )
		   )
		   
	       ("next_ctl"
				   axlMsgPut("Location the next position.")
				   axlUIWPrint(Smd2Tform "Kevin Wong") 
				   location_next()
		          ; axlFormSetField(Smd2Tform next_view )		   
		   )		   
		   
		   
		   ("check"
		          axlUIWPrint(Smd2Tform "Kevin Wong") 
				  Dehilightall()
				  clearance = axlFormGetField(Smd2Tform "clearance")
				  layert = axlFormGetField(Smd2Tform "TOP")
				  layerb = axlFormGetField(Smd2Tform "BTM")
				  if(or(layert layerb) == nil
				     then
				     axlUIConfirm("Please choose the layer first!")
				     else
					   cond(
					       (layert == t layer = "TOP")
						   (layerb == t layer = "BTM")
							)
		               check_highl(layer)
   	                   axlMsgPut("Cheching the clearance .")
					   ref = sprintf(dummy "0/%L" total)
					   axlFormSetField(Smd2Tform "next_view" ref)
                  )					
		   )
		   ("exit"
				  axlMsgPut("Thank you for use my skill!")
                  axlFormClose(Smd2Tform)
				  ; Dehilightall()
                  deleteFile(form_file)

                  				  
		   )
	  )
	  ))

	  
defun(getsymbBox (sym) 
    let( (elemlist one)
	
	 elemlist = sym->symbol->children
	 
	 foreach(one elemlist 
	         if(and(one->objType == "shape" or((one->layer == "PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM") (one->layer == "PACKAGE GEOMETRY/PLACE_BOUND_TOP")))
			    then
			    cursymbox = one->bBox
			    )
			 )
		cursymbox
	 
	 ))     


	 
	  
/* ---------------------------------
define the  function to get allb Boxs of pins&syms
--------------------------------- */

defun(getallbBox (allsym)
      let( ()
	  
	  ; allsym = axlDBGetDesign()->components

	  Toppthsym = list()    ;顶层插件器件ID
	  Topsmdsym2box = list()
      Btmsmdsym = list()	
	  
	  Btmpthsym = list()    ;底层插件器件ID  
	  Btmsmdsym2box = list()
	  Topsmdsym = list()



	  foreach(onesym allsym
	          cursympins = onesym -> pins
			  cursympin1 = car(cursympins)
			  
			if(cursympin1->isThrough
			   then
			   if(cursympin1->isMirrored
			     then
				 Btmpthsym = append1(Btmpthsym onesym)
				 else
				 Toppthsym = append1(Toppthsym onesym)
				 )
			   else
			   if(cursympin1->isMirrored
			     then 
				 onesymbox = getsymbBox(onesym)
				 ; getsymbBox(onesym)
				 Btmcursmdsym2box = cons(onesym onesymbox)
				 Btmsmdsym2box = append1(Btmsmdsym2box Btmcursmdsym2box)				 
				 else
				 onesymbox = getsymbBox(onesym)
				 ; getsymbBox(onesym)
				 Topcursmdsym2box = cons(onesym onesymbox)
				 Topsmdsym2box = append1(Topsmdsym2box Topcursmdsym2box)
				 )
			   )
	        )
			Toppthpin2box = list()         ;顶层表贴引脚ID+box
			Btmpthpin2box = list()         ;底层表贴引脚ID+box
			
	  
	  foreach(pthsym Toppthsym
	           if( or(strcmp(pthsym->name "TP") == 1 strcmp(pthsym->name "MARK") == 1 
			       strcmp(pthsym->name "ID") == 1 strcmp(pthsym->name "REF") == 1 length(pthsym->pins) == 1)
			   then
			   remd(pthsym Toppthsym)
			   else	  
	           cursympins = pthsym->pins
			   curpthpin2box = list()
			   foreach(pin cursympins
			           curpinbox = pin->bBox 
					   curpin2box = cons(pin curpinbox)
					   curpthpin2box = append1(curpthpin2box curpin2box)
					   )
			   Toppthpin2box = append(Toppthpin2box curpthpin2box)
			   )
			   )
	  
	  foreach(pthsym Btmpthsym
	           if( or(strcmp(pthsym->name "TP") == 1 strcmp(pthsym->name "MARK") == 1 strcmp(pthsym->name "ID") == 1 strcmp(pthsym->name "REF") == 1 length(pthsym->pins) == 1)
			   then
			   remd(pthsym Btmpthsym)
			   else
	           cursympins = pthsym->pins
			   curpthpin2box = list()
			   foreach(pin cursympins
			           curpinbox = pin->bBox 
					   curpin2box = cons(pin curpinbox)
					   curpthpin2box = append1(curpthpin2box curpin2box)
					   )
			   Btmpthpin2box = append(Btmpthpin2box curpthpin2box)
			   )
			   )
	   ))
	   
	   
	;load("quick_chSmd2ThrP.il")  quick_chSmd2ThrP   check_highl("BTM")    strcmp("J4" "ID")  strcmp("J4" "MARK") strcmp("J4" "TP")
	
/* ---------------------------------
define the  function to get allb Boxs of pins&syms
--------------------------------- */	   
defun(check_highl (item)      ;check_highl("BTM")
      let( ()	
      allsym = axlDBGetDesign()->components  
	  getallbBox(allsym)
	  ; axlClearSelSet()
	  ; axlDehighlightObject()
	  if(item ==  "TOP" 
		 then pin = Btmpthpin2box sym = Topsmdsym2box
		      axlVisibleDesign(nil)
			  axlVisibleLayer("PIN/TOP" t)
			  axlVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_TOP" t)
			  axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t)
			  axlVisibleLayer("ETCH//TOP" t)
			  axlVisibleLayer("VIA CLASS/TOP" t)
			  axlUIWRedraw(nil)
		 else
			  pin = Toppthpin2box sym = Btmsmdsym2box
			  axlVisibleDesign(nil)
			  axlVisibleLayer("PIN/BOTTOM" t)
			  axlVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" t)
			  axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t)
			  axlVisibleLayer("ETCH//BOTTOM" t)
			  axlVisibleLayer("VIA CLASS/BOTTOM" t)	
              axlUIWRedraw(nil)			  
			 )
		   
	  if(or(pin sym) == nil
	      then 
		  axlUIConfirm("There is no need to check current layer")
		  else
		  n = 1
		  hlloclist = list()
		  hlpin2sym = list()
		  
		  hlpinlist = list()
		  hlsymlist = list()
		    while( (n <= length(pin))

			    curpin = nthelem(n pin)  ;nthelem(2 pin)
				
				curpinhlloclist = list()
				curpinl = list()
				
		       foreach(onesym sym
			          if(
				          sym2pthpin(curpin onesym)		;	curpin = 
				          then
						  axlDBControl('highlightColor 17)
				          axlHighlightObject(car(curpin) t)
				          axlHighlightObject(car(onesym) t)
						  
						  ; hlpinlist = append1(hlpinlist car(curpin))
						  ; hlsymlist = append1(hlsymlist car(onesym))
						  
						  
					      curpinl = append1(curpinl list(car(curpin) car(onesym)))
				          curpinhlloclist = append1(curpinhlloclist curcenter)				  
				          
						  
						  
						  )
			         )
					 
			       hlpin2sym = append(hlpin2sym curpinl)
			       hlloclist = append(hlloclist curpinhlloclist)
			       n = n+1
			  )
			  
			total = length(hlloclist)  
		  )

			 
		))

		
	; load("quick_chSmd2ThrP.il")	

	
defun(sym2pthpin (a b)	
      let( ()
	      tt1 = cdr(a)   
	      tt2 = cdr(b)    
		  
	      left   = car(nth(0 tt1))
	      bottom    = cadr(nth(0 tt1))
	      right  = car(nth(1 tt1))
	      top = cadr(nth(1 tt1))
		  

	      lt  = car(nth(0 tt2))
	      bm  = cadr(nth(0 tt2))
	      rt  = car(nth(1 tt2))
	      tp  = cadr(nth(1 tt2))

            casea = and(lt-clearance>=left lt-clearance<=right)
            caseb = and(bm-clearance<=top bm-clearance>=bottom)
            casec = and(tp+clearance<=top tp+clearance>=bottom)
            cased = and(rt+clearance>=left rt+clearance<=right)
			
			casee = and(lt-clearance<=left rt+clearance>=right)
			casef = and(tp+clearance>=top bm-clearance<=bottom)
			
			caseg = and(lt-clearance<=left rt+clearance>=right tp+clearance>=top bm-clearance<=bottom)
			caseh = and(lt-clearance>=left rt+clearance<=right tp+clearance<=top bm-clearance>=bottom)
			
			result = or(and(casea caseb) and(casea casec) and(cased caseb) and(cased casec) and(caseb casee) and(casec casee) and(casea casef) and(cased casef) caseg caseh)
         if(result
		   then
		   curcenter = list((max(rt right lt left)+ min(rt right lt left))*0.5 (max(tp top bm bottom)+max(tp top bm bottom))*0.5)
		   
            )
	  ))
	  

;load("quick_chSmd2ThrP.il") 

	   
/* ---------------------------------
define the  function location_nx
--------------------------------- */

defun(location_next ()
   let( (curlocnum)
	  if(total ==0
	     then
		 axlUIConfirm("There is no erro at this layer!")
		 else
	    curlocnum = atoi(car(parseString(axlFormGetField(Smd2Tform "next_view") "/")))
		if(curlocnum == total
		   then curlocnum = 1
		   else
		   curlocnum = curlocnum+1
		  )
    	refdes = sprintf(dummy " %d/%d" curlocnum total)
		x = car(nthelem(curlocnum hlloclist))
		y = cadr(nthelem(curlocnum hlloclist))
    	axlFormSetField(Smd2Tform "next_view" refdes)
	    axlWindowBoxSet(list(x-400:y-320 x+400:y+80))

      )
	 )
	)


	
/* ---------------------------------
define the  function location_pr
--------------------------------- */	

defun(location_previous ()
   let( (curlocnum)
	  if(total ==0
	     then
		 axlUIConfirm("There is no erro at this layer!")
		 else	
	    curlocnum = atoi(car(parseString(axlFormGetField(Smd2Tform "next_view") "/")))
		
		if(or(curlocnum == 1 curlocnum == 0)
		   then curlocnum = total
		   else
		   curlocnum = curlocnum-1   
		  )
      	refdes = sprintf(dummy " %d/%d" curlocnum total)
		x = car(nthelem(curlocnum hlloclist))
		y = cadr(nthelem(curlocnum hlloclist))
    	axlFormSetField(Smd2Tform "next_view" refdes)
	    axlWindowBoxSet(list(x-400:y-320 x+400:y+80))

      )
	 )
	)  
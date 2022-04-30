/* 
├─ 
│ ├─        程序名称： Quick_ColorS
│ ├─        程序功能：快速设置颜色
│ ├─        创建时间：2013年12月16日 
│ ├─        作    者：王凯
├─ 

*/ 

axlCmdRegister("quick_colorset" 'Quick_ColorSet)
axlCmdRegister("quick_colorset1" 'Quick_ColorSet1)
axlCmdRegister("quick_colorset2" 'Quick_ColorSet2)

axlSetFunckey("sc" "quick_colorset")
axlSetFunckey("ssc" "quick_colorset1")
axlSetFunckey("s1" "quick_colorset2")


;the color define

white   =  '(255 255 255)  
blank   =  '(0 0 0)
darkred =  '(169 5 18)
lightred=  '(255 0 0)
green   =  '(0 221 0)
blue    =  '(18 18 225)
qingse  =  '(0 255 255)
zise    =  '(255 0 255)





; axlColorSet(41 darkred)
; axlColorSet(41 '(255 0 0))
; axlColorSet(63 '(255 111 255))   ;浅粉色

; axlColorSet(65 zise)
; axlColorSet(91 '(185 241 255))

; axlColorGet(5)
; axlColorGet(41)

; load("Quick_ColorS.il")

defun( Quick_ColorSet ()
 
      etchcolorslist = list(5 41 40 43 36 53 45 65 73 80 111 119 6 10 18 24)
	  Quick_ColorSetTr()
;same
axlColorSet(5 darkred)
axlColorSet(41 '(0 221 0))
axlColorSet(45 '(100 100 255))  ;浅蓝色
; not the same
axlColorSet(63 '(255 111 255)) 	  
	  )

defun( Quick_ColorSet1 ()

      etchcolorslist = list(41 5 43 36 53 45 65 73 80 111 119 6 10 18 24 40)
	  Quick_ColorSetTr()
;same	  
axlColorSet(5 darkred)
axlColorSet(41 '(0 221 0))
axlColorSet(45 '(100 100 255))   ;浅蓝色
; not the same
axlColorSet(63 white)
	  )

defun( Quick_ColorSet2 ()

      etchcolorslist = list(5 41 43 36 53 45 65 73 80 111 119 6 10 18 24 40)
	  Quick_ColorSetTr()
;same
axlColorSet(5 darkred)
axlColorSet(41 '(0 221 0))
axlColorSet(45 '(100 100 255))   ;浅蓝色
; not the same
axlColorSet(63 white)	  
	  )

; defun( Quick_ColorSet3 ()
		
      ; etchcolorslist = list(random(192) random(192) random(192) random(192) random(192) random(192) random(192) 
	  ; random(192) random(192) random(192) random(192) random(192) random(192) random(192) random(192) random(192))
	  ; Quick_ColorSetTr()
	  ; )	 
	  
	  
	  

defun( Quick_ColorSetTr ()
let(()

;Get all the etch/pin/via/boundary/antietch layers    etchcolorslist
etchl = axlGetParam("paramLayerGroup:ETCH")->groupMembers
etchlayers = append(list("BOTTOM") reverse(cdr(reverse(etchl))))
etchlnum = length(etchlayers)



;Get all the DRC layers   17
drclayers = axlGetParam("paramLayerGroup:Drc Error Class")->groupMembers
;Get all the Via layers   66
vialayers = axlGetParam("paramLayerGroup:Via Class")->groupMembers
;Get all the boundary layers 9
boundarylayers = axlGetParam("paramLayerGroup:Boundary")->groupMembers
;Get all the antietch layers 22
antietchlayers = axlGetParam("paramLayerGroup:Anti Etch")->groupMembers

regionlayers = axlGetParam("paramLayerGroup:Constraint Region")->groupMembers

viaoutlayers = axlGetParam("paramLayerGroup:Via Keepout")->groupMembers

rtoutlayers = axlGetParam("paramLayerGroup:Route Keepout")->groupMembers



/* ---------------------------------
change the pins colors
--------------------------------- */
             i = 0
		 while(i < etchlnum
		     cursetlayer = nth(i etchlayers)
			 cursetpinyer = sprintf(nil "PIN/%s" cursetlayer)
			 
			 setcolor = nth(i etchcolorslist)			 
			 crucolor = axlLayerGet(cursetpinyer)
		     crucolor->color=setcolor
			 axlLayerSet(crucolor)
			 axlVisibleUpdate(t)
			 i++
			 )
/* ---------------------------------
change the etch colors
--------------------------------- */
             i = 0			 
		 while(i < etchlnum
		     cursetlayer = nth(i etchlayers)
			 cursetetchlayer = sprintf(nil "ETCH/%s" cursetlayer)
			 setcolor = nth(i etchcolorslist)			 
			 crucolor = axlLayerGet(cursetetchlayer)
		     crucolor->color=setcolor
			 axlLayerSet(crucolor)
			 axlVisibleUpdate(t)
			 i++
			 )
/* ---------------------------------
Drc error class
--------------------------------- */
         foreach(one drclayers	
                  curdrc = 	sprintf(nil "Drc Error Class/%s" one)
                  curdrccolor = axlLayerGet(curdrc)
				  curdrccolor->color=17
			      axlLayerSet(curdrccolor)
			      axlVisibleUpdate(t)	
                )				  
 /* ---------------------------------
Via  class
--------------------------------- */                  				  
         foreach(one vialayers	
                  curvia = 	sprintf(nil "Via Class/%s" one)
                  curviacolor = axlLayerGet(curvia)
				  curviacolor->color=66
			      axlLayerSet(curviacolor)
			      axlVisibleUpdate(t)	
                )				 
 /* ---------------------------------
Boundary
--------------------------------- */                  				  
         foreach(one boundarylayers	
                  curbun = 	sprintf(nil "Boundary/%s" one)
                  curbuncolor = axlLayerGet(curbun)
				  curbuncolor->color=9
			      axlLayerSet(curbuncolor)
			      axlVisibleUpdate(t)	
                )	
/* ---------------------------------
Anti
--------------------------------- */				
         foreach(one antietchlayers	
                  curant = 	sprintf(nil "Anti Etch/%s" one)
                  curantcolor = axlLayerGet(curant)
				  curantcolor->color=22
			      axlLayerSet(curantcolor)
			      axlVisibleUpdate(t)	
                )	

/* ---------------------------------
region
--------------------------------- */				
         foreach(one regionlayers	
                  curant = 	sprintf(nil "Constraint Region/%s" one)
                  curantcolor = axlLayerGet(curant)
				  curantcolor->color=5
			      axlLayerSet(curantcolor)
			      axlVisibleUpdate(t)	
                )

/* ---------------------------------
via keep out
--------------------------------- */				
         foreach(one viaoutlayers	
                  curant = 	sprintf(nil "Via Keepout/%s" one)
                  curantcolor = axlLayerGet(curant)
				  curantcolor->color=40
			      axlLayerSet(curantcolor)
			      axlVisibleUpdate(t)	
                )

/* ---------------------------------
route keepout
--------------------------------- */				
         foreach(one rtoutlayers	
                  curant = 	sprintf(nil "Route Keepout/%s" one)
                  curantcolor = axlLayerGet(curant)
				  curantcolor->color=43
			      axlLayerSet(curantcolor)
			      axlVisibleUpdate(t)	
                )







				
/* ---------------------------------
change other colors
--------------------------------- */					
				
	            q1=axlLayerGet("PACKAGE GEOMETRY/SILKSCREEN_TOP")
	            q1->color=63
	          	axlLayerSet(q1)
				
	            q2=axlLayerGet("PACKAGE GEOMETRY/SILKSCREEN_BOTTOM")
	            q2->color=45
	            axlLayerSet(q2)
				
	            q3=axlLayerGet("BOARD GEOMETRY/SILKSCREEN_TOP")
	            q3->color=63
	            axlLayerSet(q3)
				
	            q4=axlLayerGet("BOARD GEOMETRY/SILKSCREEN_BOTTOM")
	            q4->color=45
	            axlLayerSet(q4)
				
	            q5=axlLayerGet("BOARD GEOMETRY/OUTLINE")
	            q5->color=91
	           	axlLayerSet(q5)
				
                q6=axlLayerGet("REF DES/SILKSCREEN_TOP")
	            q6->color=63
	          	axlLayerSet(q6)
				
	            q7=axlLayerGet("REF DES/SILKSCREEN_BOTTOM")
	            q7->color=45
	            axlLayerSet(q7)
				
				q8=axlLayerGet("ROUTE KEEPIN/ALL")
                q8->color=65
                axlLayerSet(q8)	
				
	            axlVisibleUpdate(t)
; /* ---------------------------------
; change other colors 2rd solution
; --------------------------------- */	 
; otherlayerlist = '("PACKAGE GEOMETRY/SILKSCREEN_TOP" "BOARD GEOMETRY/SILKSCREEN_TOP" "REF DES/SILKSCREEN_TOP" 
                   ; "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" "BOARD GEOMETRY/SILKSCREEN_BOTTOM""REF DES/SILKSCREEN_BOTTOM" 
				   ; "BOARD GEOMETRY/OUTLINE" "ROUTE KEEPIN/ALL" 
				   
				   
				   
				   ; )


				   
	  
	  ))
	  
	  
	  
	  
	  
; load("Quick_ColorS.il")	  
	  

	  
	  
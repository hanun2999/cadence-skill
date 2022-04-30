axlCmdRegister( "colorset" `colorset)

;=================================================
;the color and the corresponding number:
;c_white =1 c_qing   =6 	c_ltgreen=12  c_dkzi =17
;c_ltblue=2 c_red    =7  c_golden =13  c_gray =19
;c_pink  =3 c_yellow =8 	c_ltpink =14  c_jiang=22
;c_cyan  =4 c_dkblue =9 	c_mud    =15  c_black=23
;c_zi    =5 c_dkgray =11	c_blue   =16
;name:
;   colorset.il 
;Description:
;   This is used to setup the color of your design
;Date:
;   2009-11-12 -- Initial release
;QQ group NO. 3590664 
;if have any problem you can contact whith us
;=================================================
procedure( colorset()
	        
	        ;===========================
	        ;set etch subclass layer color
	        ;===========================
	        layers=nil
	        layers = axlGetParam("paramLayerGroup:ETCH")->groupMembers
	        foreach(item layers
	        	p=nil
	        	q=nil
	        	sprintf(q,"paramLayerGroup:ETCH/paramLayer:%s",item)
				    p=axlGetParam(q)
	        	cond(
	        	   (rexMatchp("GND" item)        p->color=36)
	        	   (rexMatchp("POWER" item)      p->color=43)
	        	   (rexMatchp("TOP" item)        p->color=41)
	        	   (rexMatchp("BOTTOM" item)     p->color=5)
	        	   (rexMatchp("L1" item)        p->color=41)
	        	   (rexMatchp("L2" item)        p->color=53)
	        	   (rexMatchp("L3" item)        p->color=45)
	        	   (rexMatchp("L4" item)        p->color=65)
	        	   (rexMatchp("L5" item)        p->color=73)
	        	   (rexMatchp("L6" item)        p->color=80)
	        	   (rexMatchp("L7" item)        p->color=111)
	        	   (rexMatchp("L8" item)        p->color=119)
	        	   );cond 
	             axlSetParam(p) 
	        	);foreach
	        	axlVisibleUpdate(t)
	        ;============================
	        ;set via class/subclass color
	        ;============================
	        layers=nil
	        layers=axlGetParam("paramLayerGroup:VIA CLASS")->groupMembers
	        foreach(item layers
	        	p=nil
	        	q=nil
	        	sprintf(q,"paramLayerGroup:VIA CLASS/paramLayer:%s",item)
				    p=axlGetParam(q)
	        	cond(
	        	   (rexMatchp("GND" item)        p->color=66)
	        	   (rexMatchp("POWER" item)      p->color=66)
	        	   (rexMatchp("TOP" item)        p->color=66)
	        	   (rexMatchp("BOTTOM" item)     p->color=66)
	        	   (rexMatchp("L1" item)        p->color=66)
	        	   (rexMatchp("L2" item)        p->color=66)
	        	   (rexMatchp("L3" item)        p->color=66)
	        	   (rexMatchp("L4" item)        p->color=66)
	        	   (rexMatchp("L5" item)        p->color=66)
	        	   (rexMatchp("L6" item)        p->color=66)
	        	   (rexMatchp("L7" item)        p->color=66)
	        	   (rexMatchp("L8" item)        p->color=66)
	        	  );cond
	        	  axlSetParam(p)
	        	);foreach
	        	  v1=axlLayerGet("PIN/TOP")
	            v1->color=66
	          	axlLayerSet(v1)
	            v2=axlLayerGet("PIN/BOTTOM")
	            v2->color=66
	            axlLayerSet(v2)
	        	  axlVisibleUpdate(t)
	        ;============================
	        ;set PIN class/subclass color
	        ;============================
	        layers=nil
	        layers=axlGetParam("paramLayerGroup:PIN")->groupMembers
	        foreach(item layers
	        	p=nil
	        	q=nil
	        	sprintf(q,"paramLayerGroup:PIN/paramLayer:%s",item)
				    p=axlGetParam(q)
	        	cond(
	        	   (rexMatchp("GND" item)        p->color=36)
	        	   (rexMatchp("POWER" item)      p->color=43)
	        	   (rexMatchp("L1" item)        p->color=99)
	        	   (rexMatchp("L2" item)        p->color=53)
	        	   (rexMatchp("L3" item)        p->color=45)
	        	   (rexMatchp("L4" item)        p->color=65)
	        	   (rexMatchp("L5" item)        p->color=73)
	        	   (rexMatchp("L6" item)        p->color=80)
	        	   (rexMatchp("L7" item)        p->color=111)
	        	   (rexMatchp("L8" item)        p->color=119)
	        	  );cond
	        	 axlSetParam(p)
	        	);foreach
	        	  p1=axlLayerGet("PIN/TOP")
	            p1->color=41
	          	axlLayerSet(p1)
	            p2=axlLayerGet("PIN/BOTTOM")
	            p2->color=5
	            axlLayerSet(p2)
	        	 axlVisibleUpdate(t)
	         ;============================
	         ;set DRC class/subclass color
	         ;============================
	         layers=nil
	         layers=axlGetParam("paramLayerGroup:drc error class")->groupMembers
	         foreach(item layers
	        	p=nil
	        	q=nil
	        	sprintf(q,"paramLayerGroup:drc error class/paramLayer:%s",item)
				    p=axlGetParam(q)
	           p->color=17
	           axlSetParam(p)
	          );foreach
	        	axlVisibleUpdate(t)
	         ;============================
	         ;set boundary class/subclass color
	         ;============================
	         layers=nil
	         layers=axlGetParam("paramLayerGroup:boundary")->groupMembers
	         foreach(item layers
	        	p=nil
	        	q=nil
	        	sprintf(q,"paramLayerGroup:boundary/paramLayer:%s",item)
				    p=axlGetParam(q)
	           p->color=9
	           axlSetParam(p)
	          );foreach
	        	axlVisibleUpdate(t)
	         ;============================
	         ;set ANTI ETCH class/subclass color
	         ;============================
	         layers=nil
	         layers=axlGetParam("paramLayerGroup:ANTI ETCH")->groupMembers
	         foreach(item layers
	        	p=nil
	        	q=nil
	        	sprintf(q,"paramLayerGroup:ANTI ETCH/paramLayer:%s",item)
				    p=axlGetParam(q)
	           p->color=22
	           axlSetParam(p)
	          );foreach
	        	axlVisibleUpdate(t)
	         ;============================
	         ;set SILKSCREEN subclass color
	         ;============================
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
	  );end defun
	        	
	        	
	           
	     
	   
	        	 
	        
	        	 
	        	 
	      
	        
	        
	      
	        
	        
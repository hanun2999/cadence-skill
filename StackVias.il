; -----------------------------------------------------------------------------
; StackVias.il 
; -----------------------------------------------------------------------------
; defir.dong@foxmail.com
; Description:
;     This is used to check stack vias in design
; Date Name and Changes
; 2009-11-09 -- Initial release,
; -----------------------------------------------------------------------------
axlCmdRegister("sv" `Stack_Vias)	
procedure( Stack_Vias()
	 let(
	 	   (vias 
	 	   	lx 
	 	   	ly
	 	   	ux
	 	   	uy
	 	   	StackVias 
	 	   	logfile
	 	   	rep_file
	 	   )
	 axlClearSelSet()
	 axlVisibleDesign(nil) 
	 axlVisibleLayer( "VIA CLASS/TOP" t)
	 axlVisibleLayer( "BOARD GEOMETRY/OUTLINE" t)
	 axlVisibleUpdate(t)
	 axlSetFindFilter(?enabled `("NOALL" "VIAS") ?onButtons `("VIAS"))
	 vias = axlGetSelSet(axlAddSelectAll())
	 StackVias=nil
	 foreach( via  vias
	 	       axlClearSelSet()
	 	       axlSetFindFilter(?enabled `("NOALL" "VIAS") ?onButtons `("VIAS"))
	 	       lx=car(via->xy)-8
	 	       ly=cadr(via->xy)-8
	 	       ux=car(via->xy)+8
	 	       uy=cadr(via->xy)+8
	         axlAddSelectBox(list(lx:ly ux:uy))
	         n=axlGetSelSetCount()
	         if( axlGetSelSetCount()>1  then
	   	       StackVias=cons(via StackVias)
	 	         ); end if
	 	       );end foreach
	 	    
	 	    logfile="./Stack_Vias.txt"
	 	    rep_file=outfile(logfile)
	      fprintf(rep_file "\t Stack Vias Report\n\n Padstack Name\t\tLocation\n\n")
	 foreach( via StackVias
	      fprintf(rep_file "%L\t\t%L\n" via->name , via->xy )
	      	 );end foreach
	      
	 if( length(StackVias)==0 then
	 	   axlMsgPut("No stack via.")
	  else
		   axlMsgPut("%d stack vias exist."  length(StackVias)) 
		  );end if
		 axlClearSelSet()
	   close(rep_file)
	   axlUIViewFileCreate(logfile "Stack Vias Log" t)
	  );end let
	);end defun
		  
	 	    
	 	 
	 	 
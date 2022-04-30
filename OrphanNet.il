;=====================================================================
;OrphanNet.il
;this routine report the Orphan net which do not belong to a ratsnest.
;Date:2009-11-25   
;author:defir.dong
;=====================================================================

axlCmdRegister("OrphanNet" `Orphan_Nets)	
procedure( Orphan_Nets()
	logfile="./Orphan_Nets.log"
	axlClearSelSet()
	axlVisibleDesign( nil) 
	axlVisibleLayer( "PIN/TOP" t)
	axlVisibleLayer( "PIN/BOTTOM" t)
	axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_TOP" t)
	axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" t)
	axlVisibleLayer( "BOARD GEOMETRY/OUTLINE" t)
	axlVisibleUpdate(t)
	axlSetFindFilter(?enabled `("NOALL" "NETS") ?onButtons `("NETS"))
	nets = axlGetSelSet(axlAddSelectAll())
		rep_file=outfile(logfile)
	  fprintf(rep_file "\t Orphan Nets Report\n\n Net Name\t\tLocation\n\n")
	  ntd=nil
	foreach(nt nets  
		  if( nt->name!="" && nt->ratsnest==nil  then
		  	    ntd=cons(nt ntd)
		  	  );if
		  	);foreach
	printf("%L\n" ntd)	  	
	 rats=axlSelectByProperty("net" "RATSNEST_SCHEDULE")
	 ratv=axlSelectByProperty("net" "VOLTAGE")
	 l1=nil
	 l2=nil
	 l1=append(rats ratv)
	 printf("%L\n" l1)
	foreach(nam l1
		     ntd=remove(nam ntd)
		       		 printf("%L\n" ntd)
		       		);foreach
		        
		axlClearSelSet()
	  axlSetFindFilter(?enabled `("NOALL" "PINS") ?onButtons `("PINS"))
	  pins = axlGetSelSet(axlAddSelectAll())
	  pnl=nil
	  foreach(pn pins
	  	     foreach(nt ntd
	 	       if(pn->net->name == nt->name then
	 	        	  px=pn->xy
	 	        	  fprintf(rep_file "%L\t\t%L\n" nt->name,px)
	 	        	  );if
	 	        	 );foreach
	 	        	);foreach

  axlClearSelSet()	
	close(rep_file)
	axlUIViewFileCreate(logfile "Orphan Nets Log" nil)

);end defun








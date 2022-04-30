;              Report symbols with different kinds of pads
;-----------------------------------------------------------------------------
;
; load "jkreport_SMD_rate.il"
;File name: jkreport_SMD_rate.il
;Revision:1.0
;date:05/14/2002 
;Writen by: JIAKE/15924
;tel: 6540581
;
;-----------------------------------------------------------------------------
;Description:
;	This routine report the symbols and component number , at the same 
;time it tells the rate of the components with SMD pad to all components .
;You can view the rerults with "Viewlog..." menu command too . 
;
;========================== Main Routine =====================================

axlCmdRegister("report SMD rate" 'jkReportRate )

defun( jkReportRate ()
	
	total = 0
	smd = 0
	tsmd = 0
	bsmd = 0
	pad = 0
	tpad = 0
	bpad = 0
	smd1 = 0
	pad1 = 0
	spin0 = 0
	spin1 = 0
	
	syms = axlDBGetDesign()->symbols
	total = length( syms )
	
	foreach( item syms ;i=0 i++ item=nthelem(i syms) item~>??
		pins = item->pins
		find = nil
		foreach(pin pins
		if(pin->number == "1" || pin->number == "C3" then
			if(( length(pins) > 1 && substring( pin->name 1 3) == "SMD"  )
			|| ( pin->number == "C3" && substring( pin->name 1 4) == "BALL" ) then 
				if(item->isMirrored == t then 
					bsmd++
				else
					tsmd++
				)
				smd++
				find = t
			)
			if( length(pins) > 1 && substring( pin->name 1 3) == "PAD" then 
				if(item->isMirrored == t then 
					bpad++
				else
					tpad++
				)
				pad++
				find = t
			)
			if( substring( pin->name 1 3) == "SMD" || substring( pin->name 1 2) == "ID" 
			 || substring( pin->name 1 4) == "BALL"  then 
				smd1++
				find = t
			)
			if( substring( pin->name 1 3) == "PAD" then 
				pad1++
				find = t
			)
			if( substring(pin->name 1 3) == "VIA" then 
				pad1++
				spin1++
				find = t
			)
		))
		if( length(pins) == 1 then spin1++ find = t)
		if( length(pins) == 0 then spin0++ find = t)
		
		if(find == nil then 
			axlMsgPut("fail")
			axlMsgPut("%s" item->refdes)
			foreach(pin pins
				axlMsgPut("%s ; %s" pin->number pin->name)
			)
		)
	)
	
	log = "Report_Rate.log"
	logfile = axlDMOpenLog(log)

	fprintf(logfile "           Symbols with different pad report \n")
	fprintf(logfile "---------------------------------------------------------\n\n")

	fprintf(logfile "Total components                     : %d \n" smd+pad )
	fprintf(logfile "  Components with SMD pad                : %d \n" smd )
	fprintf(logfile "       |____ On top                        ___ %d \n" tsmd )
	fprintf(logfile "       |____ On bottom                     ___ %d \n" bsmd )
	fprintf(logfile "  Components with through hole           : %d \n" pad )
	fprintf(logfile "       |____ On top                        ___ %d \n" tpad )
	fprintf(logfile "       |____ On bottom                     ___ %d \n\n" bpad )
	fprintf(logfile "Total symbols                        : %d \n" total )
	fprintf(logfile "  Symbols with SMD pad                   : %d \n" smd1 )
	fprintf(logfile "  Symbols with through hole              : %d \n" pad1 )
;	fprintf(logfile "  Symbols with singal pad                : %d \n" spin1 )
	fprintf(logfile "  Symbols without pad                    : %d \n\n" spin0 )
	
;	fprintf(logfile "  total1 = %d total2 = %d  \n\n" smd+pad+spin1+spin0 smd1+pad1+spin0)
	if(smd+pad == 0 
	then
		fprintf(logfile "  Ratio of component with SMD pad        : NULL \n\n" )
	else
		fprintf(logfile "  Ratio of component with SMD pad           : %.2f%s \n" 100.0*smd/(smd+pad) "%" ) 
		fprintf(logfile "  Ratio of component with SMD pad on top    : %.2f%s \n" 100.0*tsmd/(smd+pad) "%" ) 
		fprintf(logfile "  Ratio of component with SMD pad on bottom : %.2f%s \n\n" 100.0*bsmd/(smd+pad) "%" ) 
	)
	fprintf(logfile "----------------------- End report ----------------------\n")

	axlDMClose(logfile)
	
	axlUIViewFileCreate(log "Report symbols with different pads" nil '(60 24) '(sw outer))
);End-defun


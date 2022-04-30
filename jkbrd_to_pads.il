;File name : load("jkbrd_to_pads.il")

;Written by huqinghu
;This program can translate Allegro BRD file to PADS file.
;Modified by 24245 in 2002-04-17

axlCmdRegister(
	"brd_pads"
	'translate_brd_to_pads
	)

procedure( translate_brd_to_pads( )
(prog ()
	axlMsgPut("Get file name .")
	
	fname = axlGetDrawingName()
	if(fname == nil return(0))
	fname = car(parseString(fname "."))
	name = last(parseString(fname "/"))
	
	axlMsgPut("Translate the components ...")

	;begin the PADS file head
	shell("echo '*PADS-PERFORM-V6-MILS* DESIGN DATABASE ASCII FILE 1.0' > PADS.ASC")
	shell("echo '*PART*       ITEMS' >>PADS.ASC")
	shell("echo ''>>PADS.ASC")
	shell("echo '*REMARK*  REFNM PTYPENM X Y ORI GLUE MIRROR NMX NMY NMORI ALT CLSTID CLSTATTR' >>PADS.ASC")
	shell("echo ''>>PADS.ASC")
	;finish the PADS file head
	
	;begin to get components information
	sprintf(brdpro "report -v cmp %s.brd parts.p" car(name))
	shell(brdpro)  
	shell("grep -v '|' parts.p > parts.p1") 
	shell("echo y|rm parts.p")
	shell("echo y|rm extract.log")
	shell("cut -c1-10,36-90 parts.p1 > parts.p2") 
	shell("echo y|rm parts.p1")
	shell("sed 's/00 Y/  U   M/g' parts.p2 > parts.p3") 
	shell("sed 's/00 N/  U   N/g' parts.p3 > parts.p4")
	;finish to get components information
	
	
	; Make the Pads6 Format Components, $1.parts is Pads6 Components Format.
	inp = infile("parts.p4")
	outp = outfile("package.ASC" "w")
	while(gets(line inp) != nil ;read a line from the file port "inp" which refer to the file "parts.p4
		lst = parseString(line) ;parse the string into a list
		angle = 0.0
		
		if(nthelem(5 lst) == nil then
			;sprintf(pro "No placed package : %s" line)
			axlMsgPut("No placed package : %s" line)
	  	   )
		if(nthelem(7 lst) == "N" then;if the components art on top side,so do nothing
		     fprintf(outp "%-8s %-16s %8s %8s %8s %3s %3s\n" nthelem(1 lst) nthelem(2 lst) nthelem(3 lst) nthelem(4 lst) nthelem(5 lst) nthelem(6 lst) nthelem(7 lst))     
		  )
		if(nthelem(7 lst) == "M" then;if the components art on bottom side,so modify its ORI
		
		     if(atof(nthelem(5 lst)) != 0.0 then angle = 360.0 -  atoi(nthelem(5 lst)))
		     fprintf(outp "%-8s %-16s %8s %8s %8.1f %3s %3s\n" nthelem(1 lst) nthelem(2 lst) nthelem(3 lst) nthelem(4 lst) angle nthelem(6 lst) nthelem(7 lst))
	          ) 
	)
	close(inp)	
	close(outp)
	shell("cat package.ASC >>PADS.ASC")
	
	
	sprintf(brdpro "cp PADS.ASC %s.parts" car(name))
	shell(brdpro)  
	shell("echo y|rm package.ASC")
	shell("echo y|rm parts.p2") 
	shell("echo y|rm parts.p3") 
	shell("echo y|rm parts.p4") 
	
	axlMsgPut("Translate the connections ...")
	shell("echo '*NET*' >> PADS.ASC")
	sprintf(brdpro "report -v net %s.brd nets.c05" car(name))
	shell(brdpro)  
	shell("echo y|rm extract.log")
	shell("grep -v '|' nets.c05 > nets.c04") 
	shell("echo y|rm nets.c05")
	shell("grep -vw ' - ' nets.c04 > nets.c03") 
	shell("echo y|rm nets.c04")
	shell("cut -c1-23 nets.c03 > nets.netname") 
	shell("cut -c24-90 nets.c03 > nets.pins")
	
	; The third letter must not be blank!
	shell("cut -c3 nets.c03 > nets.c02") 	
	shell("echo y|rm nets.c03")
	shell("/usr/ucb/tr \"[0-9][A-Z]\\_+-///*/#\"\\$ \"T\" < nets.c02 > nets.c01") 
	shell("echo y|rm nets.c02")
	shell("sed 's/^T/*SIGNAL*/g' nets.c01 > nets.heads") 	
	shell("echo y|rm nets.c01") 
	
	; nets.c00 is Pads's connections!
	shell("paste -d\" \" nets.heads nets.netname nets.pins > nets.c00")
	shell("echo y|rm nets.heads") 
	shell("echo y|rm nets.pins")
	shell("echo y|rm nets.netname")
	shell("cat nets.c00 >> PADS.ASC") 
	shell("echo '*END*' >> PADS.ASC") 
	shell("echo y|rm nets.c00")
		
	sprintf(brdpro "mv PADS.ASC %s.asc" car(name))
	shell(brdpro)  
	axlMsgPut("done")
	axlMsgPut("Pads formate file is  \"%s.asc\"" car(name))
))
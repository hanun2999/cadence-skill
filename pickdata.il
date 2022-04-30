;           Creates a file with pick and place data that can be
;		backannotated into Capture/Capture CIS
;           ------------------------------------------
;
;		The program runs from the open allegro board
;
;		To run the program type "pickdata" on the Allegro
;		command line
;
;		The program extracts the following properties into a file
;		pickdata.swp
;		REF_DES		: Reference Designator
;		SYM_CENTER_X	: Components center x-origin (BODY_CENTER)
;		SYM_CENTER_Y	: Components center y-origin (BODY_CENTER)
;		SYM_ROTATION	: Components rotation
;		SYM_MIRROR		: YES if component is mirror, otherwise NO
;
;		The properties are backannotated into the following properties
;		in Capture. The properties can be renamed, look in the code.
;		REF_DES		: Does not get back into Capture but is used
;					: to find the correct component to update
;		SYM_CENTER_X	: Pick_X
;		SYM_CENTER_Y	: Pick_Y
;		SYM_ROTATION	: Pick_Rotation
;		SYM_MIRROR		: Pick_Mirror
;
;		USAGE :
;		1. Open board in Allegro (make sure the skill program pickdata.il
;			 is loaded
;		2. Write pickdata at the prompt and press ENTER to generate file
;		3. The file is called pickdata.swp - it is placed in the current
;			directory
;		4. In Capture - open the correct project
;		5. Tools - Backannotate
;		6. Select the Layout tab
;		7. Browse and select the pickdata.swp file
;		8. Press OK and look in the session log to see that all is well
;		9. Now open the schematic design and look at properties on parts
;		10. The pick and place data can now be included in reports
;
;
; To run the program type "pickdata" on the Allegro
; command line.
; -----------------------------------------------------------------
; Tested on Allegro 14.1
; The program is delivered as is and no responisibility is taken.
; Use at own risk

; Written by:

; Ole Ejlersen
; Technical Service Manager
; Nordcad Systems A/S - Representing Cadence in Denmark
; I can be reached at the following address:
; E-Mail: oe@nordcad.dk
;
; Updated: 30/10/2006
;	Modified for use with version 14.2 and later when extract was renamed extracta
;
; -----------------------------------------------------------------

(defun pickdata ()

extract1_exists = nil
drain(poport)
new_name = axlCurrentDesign()
; Create extract command file
outport = outfile("skill_extract_views.txt")
fprintf( outport , "%s\n\n%s\n%s\n%s\n%s\n%s\n\n%s\n%s\n%s\n%s\n%s\n\n%s\n" ,
					"COMPONENT" ,
					"REFDES != ''" , "SYM_CENTER_X != ''" ,
					"SYM_CENTER_Y != ''" , "SYM_ROTATE != ''" , "SYM_MIRROR != ''" ,
					"REFDES" , "SYM_CENTER_X" , "SYM_CENTER_Y" ,
					"SYM_ROTATE" , "SYM_MIRROR" , "END")
close( outport)
;extract data from board with extract file
if(axlVersion('version)<14.2 then
	extract1 = strcat("extract -s -q " new_name " skill_extract_views skill_extract_pickdata")
else
	extract1 = strcat("extracta -s -q " new_name " skill_extract_views skill_extract_pickdata")
);endif version

shell( extract1 )

inport = infile("skill_extract_pickdata.txt")
outport = outfile("pickdata.swp")

;Generate header for swap file
fprintf(outport , ";**************************************************\n")
fprintf(outport , ";Backannotation file with pick and place data\n")
fprintf(outport , ";from Cadence Allegro to Capture and Capture CIS\n")
fprintf(outport , ";**************************************************\n")
fprintf( outport , ".Section3 UpdateProperties Parts\n")
;If you want the pick and place data backannotated to other property names than the default
;then you need to change the names in the next line
fprintf( outport , "\"{Reference}\" \"Pick_X\" \"Pick_Y\" \"Pick_Rotation\" \"Pick_Mirror\"\n")
;shell(extract1)
count = 0
count2 = 100
when( inport
	while(gets( nextline inport)
		nextline = parseString(nextline)
		refdes = car(nextline)
		fprintf( outport, "\"")
		fprintf( outport, "%s", refdes)
		fprintf( outport, "\" ")
		x1 = evalstring(nth(1 nextline))
		fprintf( outport, "\"")
		fprintf( outport, "%n", x1)
		fprintf( outport, "\" ")
		y1 = evalstring(nth(2 nextline))
		fprintf( outport, "\"")
		fprintf( outport, "%n", y1)
		fprintf( outport, "\" ")
		rot = evalstring(nth(3 nextline))
		fprintf( outport, "\"")
		fprintf( outport, "%n", rot)
		fprintf( outport, "\" ")
		mirrorside = cdr(nextline)
		mirrorside = cdr(mirrorside)
		mirrorside = cdr(mirrorside)
		mirrorside = cdr(mirrorside)
		mirrorside = car(mirrorside)
		fprintf( outport, "\"")
		fprintf( outport, "%s", mirrorside)
		fprintf( outport, "\" ")
		fprintf( outport, "\n")
; Counter that reports the number of records created
		count=count+1
		if( eq(count 100) then
		  printf("\n%n%s\n" , count2, " Records Generated.")
		  drain(poport)
		  count=0
		  count2=count2+100
		) ; end of if
	) ; end of while
) ; end of when
fprintf( outport ,".End\n")
; Writes the final component count to the log window
count2=count2+count
printf("\n%n%s\n" , count2, " Records Generated.")

close( inport)
close( outport)
)
; Register pickdata program in Allegro
axlCmdRegister( "pickdata" `pickdata)
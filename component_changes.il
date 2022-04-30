;           Check Any Component Changes Between Boards
;           ------------------------------------------
;
; This routine will compare two .brd files to determine if any
; components have been either added, deleted, or moved. A file is
; created listing the changes. The file name is the current board
; name with the '.changes' extension.

; It is important that the two databases to be compared are both
; in the same units and have the same origin. The routine is most
; useful for checking component changes between two issues of the
; same board. 

; A component with the same x and y position but with a changed
; rotation will be flaged as having moved, but if a different
; symbol is added with the same refdes, x, y, and rotation, the 
; component is ignored.

; A check is made to see if the .brd files need to be UPREVED. 

; To run the program type "component_changes" on the Allegro 
; command line.

; -----------------------------------------------------------------

; Tested on Allegro 11.0

; Written by:

; Pete Court
; PCB Design Engineer
; While working at:

; Fujitsu Telecommunications Europe Limited
; Solihull Parkway
; Birmingham Business Park
; Birmingham
; B37 7YU
; UK

; I can now be reached at the following address:

; E-Mail: pc@earthling.net
;
; Version 2. June 2002
;      Modified to work with 14.2
; 	 Ron Guthrie. Cadence Design Systems.
; -----------------------------------------------------------------

(defun changes ()

drain(poport)
added_list = ()
deleted_list = ()
moved_list = ()
new_name = axlCurrentDesign()
changes_name = strcat(new_name ".changes")
extract1_exists = nil
extract2_exists = nil

createchangesform()
changesform()

) ; end of function changes

; creates changes form
; --------------------

(defun createchangesform ()

drain()
changesform_file = "changes.form"
changesform = outfile(changesform_file "w")

fprintf(changesform "FILE_TYPE=FORM_DEFN VERSION=2\n")
fprintf(changesform "FORM\n")
fprintf(changesform "FIXED\n")
fprintf(changesform "PORT 40 7\n")
fprintf(changesform "HEADER \"Component Changes\"\n")
fprintf(changesform "\n")

fprintf(changesform "ACTIVEFIELD \"old_name\"\n")
fprintf(changesform "\n")

fprintf(changesform "TILE\n")
fprintf(changesform "TEXT \"Old Board:\"\n")
fprintf(changesform "TLOC 4 2\n")
fprintf(changesform "ENDTEXT\n")
fprintf(changesform "\n")

fprintf(changesform "TEXT \"New Board:\"\n")
fprintf(changesform "TLOC 4 5\n")
fprintf(changesform "ENDTEXT\n")
fprintf(changesform "\n")

fprintf(changesform "FIELD old_name\n")
fprintf(changesform "FLOC 15 2\n")
fprintf(changesform "STRFILLIN 15 20\n")
fprintf(changesform "ENDFIELD\n")
fprintf(changesform "\n")

fprintf(changesform "FIELD new_name\n")
fprintf(changesform "FLOC 15 5\n")
fprintf(changesform "STRFILLIN 15 20\n")
fprintf(changesform "ENDFIELD\n")
fprintf(changesform "\n")

fprintf(changesform "FIELD changes_done\n")
fprintf(changesform "FLOC 6 9\n")
fprintf(changesform "MENUBUTTON \"Done\" 10 3\n")
fprintf(changesform "ENDFIELD\n")
fprintf(changesform "\n")

fprintf(changesform "FIELD changes_cancel\n")
fprintf(changesform "FLOC 21 9\n")
fprintf(changesform "MENUBUTTON \"Cancel\" 10 3\n")
fprintf(changesform "ENDFIELD\n")
fprintf(changesform "\n")

fprintf(changesform "ENDTILE\n")
fprintf(changesform "\n")

fprintf(changesform "ENDFORM\n")
close(changesform)

) ; end of function createchangesform

; calls for form
; --------------

(defun changesform ()

changesform=axlFormCreate( (gensym) changesform_file nil 'Changes_Action t )
axlFormDisplay(changesform)

old_name_exists = nil
new_name_test = strcat(new_name ".brd")
new_name_exists = isFile(new_name_test)
if( eq(new_name_exists t) then
	axlFormSetField(changesform "new_name" new_name)
) ; end if
axlUIWPrint(changesform "Enter Board Names (Without .brd)")

) ; end of function changesform

; what to do on form actions
; --------------------------

(defun Changes_Action (changesform)

(case changesform->curField
 
    ("changes_done"

		if( equal(old_name new_name) then
			axlUIWPrint(changesform "Boards Cannot Be The Same")
		else
			if( eq((old_name_exists && new_name_exists) t) then
				do_changes()
  
	        	; tidies up output files
				; may be incompatible with some platforms
				; ---------------------------------------
				shell("rm -f skill_extract_views.txt")
				shell("rm -f skill_extract_changes1.txt")
				shell("rm -f skill_extract_changes2.txt")
				shell("rm -f extract.log extract.log,[1-9]")

				if( eq((extract1_exists && extract2_exists) t) then
					shell("rm -f changes.form")
					axlFormClose(changesform)
				) ; end of if
			) ; end of if
		) ; end of if
	nil
    )
 
    ("changes_cancel"
		axlFormClose(changesform)
   
		; tidies up output files
		; may be incompatible with some platforms
		; ---------------------------------------
		shell("rm -f changes.form")
		shell("rm -f skill_extract_views.txt")
		shell("rm -f skill_extract_changes1.txt")
		shell("rm -f skill_extract_changes2.txt")
		shell("rm -f extract.log extract.log,[1-9]")
        nil
    )

	("old_name"
	old_name=(changesform->curValue)

	old_name_test = strcat(old_name ".brd")
	old_name_exists = isFile(old_name_test)
	if( eq(old_name_exists nil) then
		axlFormSetField(changesform "old_name" "Not Found")
	) ; end of if

	)
	
	("new_name"
	new_name=(changesform->curValue)
	new_name_test = strcat(new_name ".brd")    
	new_name_exists = isFile(new_name_test) 
    if( eq(new_name_exists nil) then
        axlFormSetField(changesform "new_name" "Not Found")
    ) ; end of if

	)

) ; end case

) ; end function Changes_Action

; works out changes
; -----------------

(defun do_changes ()
		
; extracts information from two boards
; ------------------------------------

drain(poport)
outport = outfile("skill_extract_views.txt")
fprintf( outport , "%s\n\n%s\n%s\n%s\n%s\n\n%s\n%s\n%s\n%s\n\n%s\n" , 
					"COMPONENT" , "REFDES != ''" , "SYM_CENTER_X != ''" , 
					"SYM_CENTER_Y != ''" , "SYM_ROTATE != ''" , "REFDES" , 
					"SYM_CENTER_X" , "SYM_CENTER_Y" , "SYM_ROTATE" , "END")
close( outport)

;Modifications to work with PSD14.2. extract.exe was renamed extracta.exe
if(axlVersion('version)==14.2 then
	extract1 = strcat("extracta -s -q " old_name " skill_extract_views skill_extract_changes1")
	extract2 = strcat("extracta -s -q " new_name " skill_extract_views skill_extract_changes2")
else
	extract1 = strcat("extract -s -q " old_name " skill_extract_views skill_extract_changes1")
	extract2 = strcat("extract -s -q " new_name " skill_extract_views skill_extract_changes2")
);end if
axlUIWPrint(changesform strcat("Extracting: " old_name ".brd"))
shell( extract1 )
extract1_exists = isFile("skill_extract_changes1.txt")
if( eq(extract1_exists t) then

	axlUIWPrint(changesform strcat("Extracting: " new_name ".brd"))
	shell( extract2 )
	extract2_exists = isFile("skill_extract_changes2.txt")

	if( eq(extract2_exists t) then

		; creates a table of refdes,x,y,rot for first board
		; -------------------------------------------------

		axlUIWPrint(changesform strcat("Sorting Data...."))

		inport = infile("skill_extract_changes1.txt")
		reftable = makeTable("refdestable" nil)

		when( inport
			while(gets( nextline inport)
				nextline = parseString(nextline)
				refdes = car(nextline)
				x1 = evalstring(nth(1 nextline))
				y1 = evalstring(nth(2 nextline))
				r1 = evalstring(nth(3 nextline))
				reftable[refdes] = list(x1 y1 r1)
			) ; end of while
		) ; end of when

		close( inport)

		; compares table with extract from second board
		; ---------------------------------------------

		inport = infile("skill_extract_changes2.txt")
 
		when( inport
    		while(gets( nextline inport)
        		nextline = parseString(nextline)
        		refdes2 = car(nextline)
				xyr1 = reftable[refdes2]

				; creates list of added components
				; --------------------------------

				if( eq(xyr1 nil) then
					sprintf( added, "%s ", refdes2)
					added_list = cons(added added_list)
				else
					x2 = evalstring(nth(1 nextline))
					y2 = evalstring(nth(2 nextline))
					r2 = evalstring(nth(3 nextline))
					xyr2 = list(x2 y2 r2)

					; creates list of moved components
					; --------------------------------

					if( equal(xyr1 xyr2) then
						reftable[refdes2] = nil
					else
						sprintf( moved, "%s ", refdes2)
						moved_list = cons(moved moved_list)
						reftable[refdes2] = nil
					) ; end of if
				) ; end of if
    		) ; end of while
		) ; end of when
		close(inport)

		; creates list of deleted components
		; ----------------------------------
 
		foreach(refdes reftable
			deleted = reftable[refdes]
			if( neq(deleted nil) then 
				sprintf( deleted, "%s ", refdes)
				deleted_list = cons(deleted deleted_list)
			)
		) ; end of foreach

		; sorts added/moved/deleted lists
		; -------------------------------

		added_list = sort(added_list 'alphalessp)
		moved_list = sort(moved_list 'alphalessp)
		deleted_list = sort(deleted_list 'alphalessp)

		; creates output file
		; -------------------

		changes_name = strcat(new_name ".changes")
		outport = outfile(changes_name)

		fprintf( outport, "%s\n", "CHANGE LIST")
		fprintf( outport, "%s\n\n", "-----------")
		fprintf( outport, "%s%s%s\n", "Old Board: ", old_name, ".brd")
		fprintf( outport, "%s%s%s\n\n", "New Board: ", new_name, ".brd")

		if( neq(added_list nil) then
			fprintf( outport, "%s\n" , "Added:")
			foreach(added added_list
				fprintf( outport, "    %s\n" , added)
			) ; end of foreach
		fprintf( outport, "\n")
		) ; end of if

		if( neq(deleted_list nil) then
			fprintf( outport, "%s\n" , "Deleted:")
			foreach(deleted deleted_list 
   				fprintf( outport, "    %s\n" , deleted)
			) ; end of foreach
		fprintf( outport, "\n")
		) ; end of if 

		if( neq(moved_list nil) then
			fprintf( outport, "%s\n" , "Moved:")
			foreach(moved moved_list 
   				fprintf( outport, "    %s\n" , moved)
			) ; end of foreach
		) ; end of if

		if( eq(added_list nil) then
    		if( eq(deleted_list nil) then
        		if( eq(moved_list nil) then
            		fprintf( outport, "%s\n" , "No Changes")
        		) ; end of if
   			) ; end of if
		) ; end of if
		close(outport)

; display output file
; -------------------

		axlUIViewFileCreate(changes_name changes_name nil 40:20)

	else
		axlUIWPrint(changesform strcat("Uprev: " new_name ".brd"))
	) ; end of if extract1 exists

else
    axlUIWPrint(changesform strcat("Uprev: " old_name ".brd"))
) ; end of if extract2 exists

) ; end of function do_changes

; registers changes as an Allegro command
; ---------------------------------------

axlCmdRegister( "component_changes" `changes)

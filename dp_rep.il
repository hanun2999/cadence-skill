;***********************************************
;
;                Differential Pair Report
;
;
;THIS PROGRAM IS PROVIDED "AS IS", AND IS NOT SUPPORTED BY
;CADENCE DESIGN SYSTEMS.
;
;
;This program will list all of the diff pairs in a design 
;with the nets that belong to the diff pair. As well it will
;list the properties that are attached to the diff pair.
;
; To use this program load this file dp_rep.il and from
;the Allegro/APD command line use the command  dp_rep
;
;
;Author: Ron Guthrie
;	Principal Support AE
;	Cadence Design Systems
;
;Version 1.0 - Initial release. 01/07/2005
;	 1.1 - Include ECSet values. 01/07/2005
;	 1.2 - Include ECSet for diff pairs as well as nets. 01/07/2005
;
;***********************************************
defun(rbg_dp_report ()
	l_diffp=axlDBGetDesign()->diffpair
	repfile=outfile("./diff_pair_report.txt")
	fprintf(repfile "Diff Pair\t\tMember nets\n\n")
	foreach(dp l_diffp	;step through each diff pair in the list
		dp_name=dp->name
		dp_mbr1=car(dp->groupMembers)->name
		dp_mbr2=cadr(dp->groupMembers)->name
		fprintf(repfile "\n%s\t\t%s\t%s\n", dp_name dp_mbr1 dp_mbr2)
		l_dp_props=dp->prop->??
		if(l_dp_props then		;check for attached properties
			fprintf(repfile "\tDiff Pair Properties:\n")
			pcount=3
			foreach(dp_prop l_dp_props
				if(pcount==3 then
					pcount=1
					fprintf(repfile "\t%s = ", dp_prop)
					pcount++
				else
					fprintf(repfile "%s\n", dp_prop)
					pcount++
				);endif pcount
			);end foreach dp_prop
			;Check for diff pair level ECSet
			dp_ecset = dp->prop->ELECTRICAL_CONSTRAINT_SET
			if(dp_ecset then
				fprintf(repfile "Diff-pair level ECSet %s constraints:\n", dp_ecset)
				l_ecs_const=axlCNSEcsetValueGet(dp_ecset 'all t)
				foreach(constraint l_ecs_const
					fprintf(repfile "\t%s = %s\n", car(constraint) cadr(constraint))
				);end foreach constraint
			else
				fprintf(repfile "No ECSet referenced on the diff pair.\n")
			);endif dp
		else
			fprintf(repfile "-- No properties assigned to the diff pair. --\n")
		);endif l_dp_props
		
		;look for ecsets attached to the net
		net_ecset=car(dp->groupMembers)->prop->ELECTRICAL_CONSTRAINT_SET
		if( net_ecset then
			fprintf(repfile "Net level ECSet %s constraints:\n" net_ecset)
			l_ecs_const=axlCNSEcsetValueGet(net_ecset 'all t)
			foreach(constraint l_ecs_const
				fprintf(repfile "\t%s = %s\n", car(constraint) cadr(constraint))
			);end foreach constraint
		else
			fprintf(repfile "No ECSet referenced on the net.\n")
		);endif car
	);end foreach dp
	close(repfile)
)
axlCmdRegister("dp_rep" 'rbg_dp_report)
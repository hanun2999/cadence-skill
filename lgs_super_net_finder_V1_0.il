;			Super Net Finder
;		------------------------------------------------
;
;
;File name: lgs_super_net_finder_V1_0.il
;Revision:1.0
;Date:June 8,2002
;Writen by:
;LiGuangsheng/24445
;Tel: 6540574
;E_mail: liguangsheng@huawei.com
;CAD Group Fundamental Dept R&D Engineer
;HUAWEI TECHNOLOGIES CO., LTD.


;===============REGIST COMMAND LINE=========================================================================================
;===========================================================================================================================

axlCmdRegister( "super_net_finder" `_lgs_super_net_find )

;***************************************************************************************************************************
;		_lgs_super_net_find()
;***************************************************************************************************************************
(defun _lgs_super_net_find ()

lgs_sn_length_min_sw = nil
lgs_sn_length_max_sw = nil
lgs_sn_pmanhattan_min_sw = nil
lgs_sn_pmanhattan_max_sw = nil
lgs_sn_via_min_sw = nil
lgs_sn_via_max_sw = nil

lgs_sn_length_min = 200
lgs_sn_length_max = 2000
lgs_sn_pmanhattan_min = 11
lgs_sn_pmanhattan_max = 1000
lgs_sn_via_min = 4
lgs_sn_via_max = 20

_lgs_build_super_net_find_form()
lgs_sn_mainlist = _lgs_sn_read_data()
lgs_sn_filter_list = lgs_sn_mainlist
_lgs_sn_setform()

);end (defun _lgs_super_net_find ()


;***************************************************************************************************************************
;		_lgs_match_net()
;***************************************************************************************************************************
(defun _lgs_match_net ( netbox)
(prog ()
	if(lgs_sn_length_min_sw
	then
		if(atof( nthelem(2 netbox)) < lgs_sn_length_min
		then
			return( nil)
		);end if
	);end if

	if(lgs_sn_length_max_sw
	then
		if(atof( nthelem(2 netbox)) > lgs_sn_length_max
		then
			return( nil)
		);end if
	);end if

	;----------------------------------------------------------------
	if(lgs_sn_pmanhattan_min_sw
	then
		if(atof( nthelem(3 netbox)) == 0
		then
			return( nil)
		);end if

		if(100*atof( nthelem(2 netbox))/atof( nthelem(3 netbox)) < lgs_sn_pmanhattan_min
		then
			return( nil)
		);end if
	);end if

	if(lgs_sn_pmanhattan_max_sw
	then
		if(atof( nthelem(3 netbox)) == 0
		then
			return( t)
		);end if

		if(100*atof( nthelem(2 netbox))/atof( nthelem(3 netbox)) > lgs_sn_pmanhattan_max
		then
			return( nil)
		);end if
	);end if

	;----------------------------------------------------------------
	if(lgs_sn_via_min_sw
	then
		if(atof( nthelem(4 netbox)) < lgs_sn_via_min
		then
			return( nil)
		);end if
	);end if

	if(lgs_sn_via_max_sw
	then
		if(atof( nthelem(4 netbox)) > lgs_sn_via_max
		then
			return( nil)
		);end if
	);end if


return( t)
));end (defun _lgs_match_net ( netbox)
;***************************************************************************************************************************
;		_lgs_super_net_find_callback()
;***************************************************************************************************************************
(defun _lgs_super_net_find_callback ( super_net_find_Form)

case(super_net_find_Form->curField

	("lgs_min_length_SW"
		lgs_sn_length_min_sw = super_net_find_Form->curValue
	t)

	("lgs_max_length_SW"
		lgs_sn_length_max_sw = super_net_find_Form->curValue
	t)

	("lgs_min_Percent_SW"
		lgs_sn_pmanhattan_min_sw = super_net_find_Form->curValue
	t)

	("lgs_max_Percent_SW"
		lgs_sn_pmanhattan_max_sw = super_net_find_Form->curValue
	t)

	("lgs_min_Via_SW"
		lgs_sn_via_min_sw = super_net_find_Form->curValue
	t)

	("lgs_max_Via_SW"
		lgs_sn_via_max_sw = super_net_find_Form->curValue
	t)

;---------------------------------------------------------------------------------------------------------------------------
	("lgs_min_length"
		lgs_sn_length_min = super_net_find_Form->curValue
	t)

	("lgs_max_length"
		lgs_sn_length_max = super_net_find_Form->curValue
	t)

	("lgs_min_Percent"
		lgs_sn_pmanhattan_min = super_net_find_Form->curValue
	t)

	("lgs_max_Percent"
		lgs_sn_pmanhattan_max = super_net_find_Form->curValue
	t)

	("lgs_min_Via"
		lgs_sn_via_min = super_net_find_Form->curValue
	t)

	("lgs_max_Via"
		lgs_sn_via_max = super_net_find_Form->curValue
	t)

	("lgsdone"
		axlFormClose( super_net_find_Form)
		deleteFile("./lgs_super_net_find_Form.form")

	t)
;---------------------------------------------------------------------------------------------------------------------------
	("Placed_List"
		axlSetFindFilter(?enabled '(noall nets) ?onButtons '(noall nets))
		lgs_netid = axlGetSelSet(axlSingleSelectName( "NET" super_net_find_Form->curValue))
		axlFormSetField(super_net_find_Form "lgs_length" atof( nthelem( 2 nthelem( super_net_find_Form->curValueInt+1 lgs_sn_filter_list))))
		if(atof( nthelem( 3 nthelem( super_net_find_Form->curValueInt+1 lgs_sn_filter_list))) == 0
		then
			axlFormSetField(super_net_find_Form "lgs_Percent" 0)
		else
			axlFormSetField(super_net_find_Form "lgs_Percent" 100*atof( nthelem( 2 nthelem( super_net_find_Form->curValueInt+1 lgs_sn_filter_list)))/atof( nthelem( 3 nthelem( super_net_find_Form->curValueInt+1 lgs_sn_filter_list))))
		);end if
		axlFormSetField(super_net_find_Form "lgs_Via" atof( nthelem( 4 nthelem( super_net_find_Form->curValueInt+1 lgs_sn_filter_list))))
		axlUIWPrint(super_net_find_Form sprintf(temp "NET: %s" super_net_find_Form->curValue))

		Lower_X=car(car(car(lgs_netid)->bBox))-200
		Lower_Y=car(cdr(car(car(lgs_netid)->bBox)))-200
		Upper_X=car(car(cdr(car(lgs_netid)->bBox)))+200
		Upper_Y=car(cdr(car(cdr(car(lgs_netid)->bBox))))+200
		Command=sprintf(dummy "window points;x %f y %f;x %f y %f" Lower_X Lower_Y Upper_X Upper_Y)
		axlShell(Command)


	t)

	("lgs_update"
		_lgs_sn_update()

	t)



);end case
);end (defun _lgs_super_net_find_callback ( super_net_find_Form)

;***************************************************************************************************************************
;		_lgs_sn_update()
;***************************************************************************************************************************
(defun _lgs_sn_update ()
	axlMsgPut("frgsdfgsdfg")
	lgs_sn_filter_list = nil
	foreach(netbox lgs_sn_mainlist
		if(_lgs_match_net( netbox)
		then
			lgs_sn_filter_list = nconc( lgs_sn_filter_list list( netbox))
	 	);end if
	);end foreach

	_lgs_sn_setform()


);end (defun _lgs_sn_update ()
;***************************************************************************************************************************
;		_lgs_sn_setform()
;***************************************************************************************************************************
(defun _lgs_sn_setform ()
let( ( lgs_name_list)
	lgs_name_list = nil

	foreach(lgs_temp lgs_sn_filter_list

		lgs_name_list = nconc( lgs_name_list list( car( lgs_temp)))
	);end for
	axlFormListDeleteAll( super_net_find_Form "Placed_List")
	axlFormSetField(super_net_find_Form "Placed_List" lgs_name_list)

	axlFormSetField(super_net_find_Form "lgs_min_length_SW" lgs_sn_length_min_sw)
	axlFormSetField(super_net_find_Form "lgs_max_length_SW" lgs_sn_length_max_sw)
	axlFormSetField(super_net_find_Form "lgs_min_Percent_SW" lgs_sn_pmanhattan_min_sw)
	axlFormSetField(super_net_find_Form "lgs_max_Percent_SW" lgs_sn_pmanhattan_max_sw)
	axlFormSetField(super_net_find_Form "lgs_min_Via_SW" lgs_sn_via_min_sw)
	axlFormSetField(super_net_find_Form "lgs_max_Via_SW" lgs_sn_via_max_sw)

	axlFormSetField(super_net_find_Form "lgs_min_length" lgs_sn_length_min)
	axlFormSetField(super_net_find_Form "lgs_max_length" lgs_sn_length_max)
	axlFormSetField(super_net_find_Form "lgs_min_Percent" lgs_sn_pmanhattan_min)
	axlFormSetField(super_net_find_Form "lgs_max_Percent" lgs_sn_pmanhattan_max)
	axlFormSetField(super_net_find_Form "lgs_min_Via" lgs_sn_via_min)
	axlFormSetField(super_net_find_Form "lgs_max_Via" lgs_sn_via_max)

	axlUIWPrint(super_net_find_Form sprintf(temp "Find %d Nets." length( lgs_name_list)))

);end let
);end (defun _lgs_sn_setform ()

;***************************************************************************************************************************
;		_lgs_sn_read_data()
;***************************************************************************************************************************
(defun _lgs_sn_read_data ()
(prog ()
	lgs_temp_list = nil
	brd_name = axlGetDrawingName()
	brd_name = last( parseString( brd_name "\\"))	;????? "\"or"/"
	extract_command_file = outfile("./lgs_extract_command_file.txt")
	fprintf( extract_command_file "NET\n  NET_NAME\n  NET_ETCH_LENGTH\n  NET_MANHATTEN_LENGTH\n  NET_VIA_COUNT\nEND\n")
	close( extract_command_file)
	axlExtractToFile( "lgs_extract_command_file.txt" "lgs_extract_data_file.txt")
	;lgstemp = strcat("extract " car( brd_name) " lgs_extract_command_file.txt " " lgs_extract_data_file.txt ")
	;shell( lgstemp)
	datafileport = infile( "lgs_extract_data_file.txt")
	while(((lgstemp = gets(line datafileport)) != nil)

		lgstemp = parseString( car(parseString( lgstemp "\n")) "!")
		if((length( lgstemp) == 5) && (car( lgstemp) == "S")
		then
			lgs_temp_list = nconc( lgs_temp_list list( cdr( lgstemp)))
		);end if

	);end while
	close( datafileport)
	deleteFile("./lgs_extract_command_file.txt")
	deleteFile("./lgs_extract_data_file.txt")
	return( lgs_temp_list)
));end (defun _lgs_sn_read_data ()

;***************************************************************************************************************************
;		_lgs_build_super_net_find_form()
;***************************************************************************************************************************
(defun _lgs_build_super_net_find_form ()
	super_net_find_Form = outfile("./lgs_super_net_find_Form.form" "w")
	fprintf(super_net_find_Form "FILE_TYPE=FORM_DEFN VERSION=2\n")
	fprintf(super_net_find_Form "FORM\n")
	fprintf(super_net_find_Form "FIXED\n")
	fprintf(super_net_find_Form "PORT 24 20\n")
	fprintf(super_net_find_Form "HEADER \"Super Net Finder\"\n")
	fprintf(super_net_find_Form "TILE\n")
	fprintf(super_net_find_Form "GROUP \"NETS LIST\"\n")
	fprintf(super_net_find_Form "FLOC 1 0\n")
	fprintf(super_net_find_Form "FSIZE 23 22\n")
	fprintf(super_net_find_Form "INFO group\n")
	fprintf(super_net_find_Form "ENDGROUP  \n")
	fprintf(super_net_find_Form "FIELD Placed_List\n")
	fprintf(super_net_find_Form "FLOC 2 2\n")
	fprintf(super_net_find_Form "LIST \"\" 21 10\n")
	fprintf(super_net_find_Form "ENDFIELD\n")
	fprintf(super_net_find_Form "###############################\n")
	fprintf(super_net_find_Form "GROUP \"Length Filter\"\n")
	fprintf(super_net_find_Form "FLOC 1 22\n")
	fprintf(super_net_find_Form "FSIZE 23 9\n")
	fprintf(super_net_find_Form "INFO group\n")
	fprintf(super_net_find_Form "ENDGROUP \n")
	fprintf(super_net_find_Form "\n")
	fprintf(super_net_find_Form "FIELD lgs_length\n")
	fprintf(super_net_find_Form "FLOC 10 24\n")
	fprintf(super_net_find_Form "REALFILLIN 10 10\n")
	fprintf(super_net_find_Form "REALMIN 0\n")
	fprintf(super_net_find_Form "ENDFIELD\n")
	fprintf(super_net_find_Form "\n")
	fprintf(super_net_find_Form "FIELD lgs_min_length_SW\n")
	fprintf(super_net_find_Form "FLOC  2 26\n")
	fprintf(super_net_find_Form "CHECKLIST \"MIN\" \n")
	fprintf(super_net_find_Form "ENDFIELD\n")
	fprintf(super_net_find_Form "\n")
	fprintf(super_net_find_Form "FIELD lgs_min_length\n")
	fprintf(super_net_find_Form "FLOC 10 26\n")
	fprintf(super_net_find_Form "REALFILLIN 10 10\n")
	fprintf(super_net_find_Form "REALMIN 0\n")
	fprintf(super_net_find_Form "ENDFIELD\n")
	fprintf(super_net_find_Form "\n")
	fprintf(super_net_find_Form "FIELD lgs_max_length_SW\n")
	fprintf(super_net_find_Form "FLOC  2 28\n")
	fprintf(super_net_find_Form "CHECKLIST \"MAX\" \n")
	fprintf(super_net_find_Form "ENDFIELD\n")
	fprintf(super_net_find_Form "\n")
	fprintf(super_net_find_Form "FIELD lgs_max_length\n")
	fprintf(super_net_find_Form "FLOC 10 28\n")
	fprintf(super_net_find_Form "REALFILLIN 10 10\n")
	fprintf(super_net_find_Form "REALMIN 0\n")
	fprintf(super_net_find_Form "ENDFIELD\n")
	fprintf(super_net_find_Form "###############################\n")
	fprintf(super_net_find_Form "GROUP \"Percent Manhattan Filter\"\n")
	fprintf(super_net_find_Form "FLOC 1 31\n")
	fprintf(super_net_find_Form "FSIZE 23 9\n")
	fprintf(super_net_find_Form "INFO group\n")
	fprintf(super_net_find_Form "ENDGROUP \n")
	fprintf(super_net_find_Form "\n")
	fprintf(super_net_find_Form "FIELD lgs_Percent\n")
	fprintf(super_net_find_Form "FLOC 10 33\n")
	fprintf(super_net_find_Form "REALFILLIN 10 10\n")
	fprintf(super_net_find_Form "REALMIN 0\n")
	fprintf(super_net_find_Form "ENDFIELD\n")
	fprintf(super_net_find_Form "\n")
	fprintf(super_net_find_Form "FIELD lgs_min_Percent_SW\n")
	fprintf(super_net_find_Form "FLOC  2 35\n")
	fprintf(super_net_find_Form "CHECKLIST \"MIN\" \n")
	fprintf(super_net_find_Form "ENDFIELD\n")
	fprintf(super_net_find_Form "\n")
	fprintf(super_net_find_Form "FIELD lgs_min_Percent\n")
	fprintf(super_net_find_Form "FLOC 10 35\n")
	fprintf(super_net_find_Form "REALFILLIN 10 10\n")
	fprintf(super_net_find_Form "REALMIN 0\n")
	fprintf(super_net_find_Form "ENDFIELD\n")
	fprintf(super_net_find_Form "\n")
	fprintf(super_net_find_Form "FIELD lgs_max_Percent_SW\n")
	fprintf(super_net_find_Form "FLOC  2 37\n")
	fprintf(super_net_find_Form "CHECKLIST \"MAX\" \n")
	fprintf(super_net_find_Form "ENDFIELD\n")
	fprintf(super_net_find_Form "\n")
	fprintf(super_net_find_Form "FIELD lgs_max_Percent\n")
	fprintf(super_net_find_Form "FLOC 10 37\n")
	fprintf(super_net_find_Form "REALFILLIN 10 10\n")
	fprintf(super_net_find_Form "REALMIN 0\n")
	fprintf(super_net_find_Form "ENDFIELD\n")
	fprintf(super_net_find_Form "###############################\n")
	fprintf(super_net_find_Form "GROUP \"Via Count Filter\"\n")
	fprintf(super_net_find_Form "FLOC 1 40\n")
	fprintf(super_net_find_Form "FSIZE 23 9\n")
	fprintf(super_net_find_Form "INFO group\n")
	fprintf(super_net_find_Form "ENDGROUP \n")
	fprintf(super_net_find_Form "\n")
	fprintf(super_net_find_Form "FIELD lgs_Via\n")
	fprintf(super_net_find_Form "FLOC 10 42\n")
	fprintf(super_net_find_Form "REALFILLIN 10 10\n")
	fprintf(super_net_find_Form "REALMIN 0\n")
	fprintf(super_net_find_Form "ENDFIELD\n")
	fprintf(super_net_find_Form "\n")
	fprintf(super_net_find_Form "FIELD lgs_min_Via_SW\n")
	fprintf(super_net_find_Form "FLOC  2 44\n")
	fprintf(super_net_find_Form "CHECKLIST \"MIN\" \n")
	fprintf(super_net_find_Form "ENDFIELD\n")
	fprintf(super_net_find_Form "\n")
	fprintf(super_net_find_Form "FIELD lgs_min_Via\n")
	fprintf(super_net_find_Form "FLOC 10 44\n")
	fprintf(super_net_find_Form "REALFILLIN 10 10\n")
	fprintf(super_net_find_Form "REALMIN 0\n")
	fprintf(super_net_find_Form "ENDFIELD\n")
	fprintf(super_net_find_Form "\n")
	fprintf(super_net_find_Form "FIELD lgs_max_Via_SW\n")
	fprintf(super_net_find_Form "FLOC  2 46\n")
	fprintf(super_net_find_Form "CHECKLIST \"MAX\" \n")
	fprintf(super_net_find_Form "ENDFIELD\n")
	fprintf(super_net_find_Form "\n")
	fprintf(super_net_find_Form "FIELD lgs_max_Via\n")
	fprintf(super_net_find_Form "FLOC 10 46\n")
	fprintf(super_net_find_Form "REALFILLIN 10 10\n")
	fprintf(super_net_find_Form "REALMIN 0\n")
	fprintf(super_net_find_Form "ENDFIELD\n")
	fprintf(super_net_find_Form "\n")
	fprintf(super_net_find_Form "FIELD lgs_update\n")
	fprintf(super_net_find_Form "FLOC 1 50\n")
	fprintf(super_net_find_Form "MENUBUTTON \"Update\" 1 3\n")
	fprintf(super_net_find_Form "ENDFIELD\n")
	fprintf(super_net_find_Form "\n")
	fprintf(super_net_find_Form "FIELD lgsdone\n")
	fprintf(super_net_find_Form "FLOC 9 50\n")
	fprintf(super_net_find_Form "MENUBUTTON \"Exit\" 5 3\n")
	fprintf(super_net_find_Form "ENDFIELD\n")
	fprintf(super_net_find_Form "FIELD help\n")
	fprintf(super_net_find_Form "FLOC 17 50\n")
	fprintf(super_net_find_Form "MENUBUTTON \"Help\" 1 3\n")
	fprintf(super_net_find_Form "ENDFIELD\n")
	fprintf(super_net_find_Form "ENDTILE\n")
	fprintf(super_net_find_Form "ENDFORM\n")
	close(super_net_find_Form)
	super_net_find_Form = axlFormCreate( (gensym) "lgs_super_net_find_Form.form" '(e outer) '_lgs_super_net_find_callback t)
	axlFormDisplay( super_net_find_Form)
	axlUIWPrint( super_net_find_Form "Reading Data,Please Wait!")
);end (defun _lgs_build_super_net_find_form ()


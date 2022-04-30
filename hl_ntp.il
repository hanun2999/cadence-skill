; Hilight Missing Test Probes
; Written by:
;   Edward B. Acheson
;  Sr. Applications Engineer
;  Cadence Design Systems
;  Chelmsford Mass.
;
;
; Description:
; This SKILL file will search the current database for a net, pin or via
; which may be missing a probe point after running the test point generation
; command.
; The type of check is determined by a form which will appear at the start
; up of this command.
;
; Limitations:
;   - This SKILL program must be run on Allegro Revision 8.1 or higher.
;   - This SKILL program will not check for NO_TEST properties.
;   - This SKILL program will only test for two test points in node checking.
;       No check is made for end/start of a net.
;Execution:
;        Locate this file (hl_ntp.il) in the directory path where all other
;       skill routines are located. In the allegro.ilinit file include the line
;       load("hl_ntp.il")
;       To Execute the command in the Allegro command window enter hl_ntp
;
;
; REVISION CONTROL
; Revision 0: 1995/01/16	Initial Release
; Revision 1: 1997/12/15	KATHY ANDERSON, TEKTRONIX
;		Fixed the box entries in order to see all the options
;		Modified the Execution command from hl_nte to hl_ntp
; Revision 2: 2001/11/08	CHRIS WALTERS, NVIDIA
;		added ability to handle NO_TEST property
;==========================================================================
;+
;NAME:
;       _HNTP_Bld_Pin_lst
;
;SYNOPSIS:
;       list = _HNTP_Bld_Pin_lst()
;
;DESCRIPTION:
;       This function will generate a list of component pin dbids. This
;       takes no arguments but will return the list to a variable.
;
;       For further information see:
;       axlSetFindFilter, axlAddSelectAll, axlGetSelSet
;
;-
;==========================================================================
defun( _HNTP_Bld_Pin_lst ()
   axlClearSelSet()
   axlSetFindFilter( ?enabled (list "noall" "pins" "invisible") ?onButtons (list "pins"))
   axlGetSelSet(axlAddSelectAll())
);enddefun
;==========================================================================
;+
;NAME:
;       _HNTP_Bld_Via_lst
;
;SYNOPSIS:
;       list = _HNTP_Bld_Via_lst()
;
;DESCRIPTION:
;       This function will generate a list of via dbids. This
;       takes no arguments but will return the list to a variable.
;
;       For further information see:
;       axlSetFindFilter, axlAddSelectAll, axlGetSelSet
;
;-
;==========================================================================
defun( _HNTP_Bld_Via_lst ()
   axlClearSelSet()
   axlSetFindFilter( ?enabled (list "noall" "vias" "invisible") ?onButtons (list "vias"))
   axlGetSelSet(axlAddSelectAll())
);enddefun
;==========================================================================
;+
;NAME:
;       _HNTP_Bld_PinVia_lst
;
;SYNOPSIS:
;       list = _HNTP_Bld_PinVia_lst()
;
;DESCRIPTION:
;       This function will generate a list of component pin and  via dbids.
;       This takes no arguments but will return the list to a variable.
;
;       For further information see:
;       axlSetFindFilter, axlAddSelectAll, axlGetSelSet
;
;-
;==========================================================================
defun( _HNTP_Bld_PinVia_lst ()
   axlClearSelSet()
   axlSetFindFilter( ?enabled (list "noall" "pins" "vias" "invisible")
                     ?onButtons (list "pins" "vias"))
   axlGetSelSet(axlAddSelectAll())
);enddefun
;==========================================================================
;+
;NAME:
;       _HNTP_Bld_Net_lst
;
;SYNOPSIS:
;       list = _HNTP_Bld_Net_lst()
;
;DESCRIPTION:
;       This function will generate a list of Net dbids. This
;       takes no arguments but will return the list to a variable.
;
;       For further information see:
;       axlSetFindFilter, axlAddSelectAll, axlGetSelSet
;
;-
;==========================================================================
defun( _HNTP_Bld_Net_lst ()

prog( ()
let( (clean_net_list)

net_list = nil
;lean_net_list = nil
found_no_test_prop = nil
net_prop_list = nil

axlClearSelSet()
axlSetFindFilter( ?enabled (list "noall" "nets" "invisible") ?onButtons (list "nets" ))
net_list = axlGetSelSet(axlAddSelectAll())

foreach( net_db net_list
	; determine if net has a NO_TEST property
	found_no_test_prop = nil
	if( net_db->prop != nil then	; must check each property present for NO_TEST
		net_prop_list = axlDBGetProperties( net_db)
		foreach( net_prop net_prop_list
			net_prop_name =  car( net_prop)
			net_prop_val  = cadr( net_prop)
			if( alphaNumCmp( net_prop_name "NO_TEST") == 0 && net_prop_val == t then
				found_no_test_prop = t
				;rintf("%s%s\n", "net with NO_TEST prop: " net_db->name)
			);end-if
		);end-foreach
	);end-if
	unless( found_no_test_prop
		clean_net_list = cons( net_db clean_net_list)
	);end-if
);end-foreach

; at this point clean_net_list contains only nets withOUT the NO_TEST property
; so pass this back to calling procedure
return(clean_net_list)

);end-let
);end-prog
);end-defun
;==========================================================================
;+
;NAME:
;       _HNTP_Bld_Inpin_lst
;
;SYNOPSIS:
;       list = _HNTP_Bld_Inpin_lst(list)
;
;DESCRIPTION:
;       This function will generate a list of pin dbids with the PIN_TYPE
;       definition of IN. This function first Generates a text file named
;       temp_extract_list_hntp.txt for use of the extract function
;       capabilites in SKILL.
;       This function takes no parameters. This function will return a list
;       of pin dbid, if any pins match the IN criteria, or nil if no match
;       is found.
;
;       For further information see:
;       axlExtractMap, axlMsgPut
;
;-
;==========================================================================
defun( _HNTP_Bld_Inpin_lst ()
prog( ()
let( ( extract_file return_list)
        extract_file = outfile("temp_extract_list_hntp.txt")
        fprintf( extract_file "COMPONENT_PIN\nPIN_TYPE = \"IN\"\nEND\n")
        close(extract_file)
        if( isFile("temp_extract_list_hntp.txt") then
            return_list = axlExtractMap( "temp_extract_list_hntp.txt")
        else
           axlMsgPut("ERROR 03 : Temp extract not generated!")
           return_list = nil
        ); end - if
        when( isFile("temp_extract_list_hntp.txt") deleteFile("temp_extract_list_hntp.txt"))
        return(return_list)
);end-let
);end-prog
);end-def _HNTP_Bld_Inpin_lst
;==========================================================================
;+
;NAME:
;       _HNTP_Bld_Outpin_lst
;
;SYNOPSIS:
;       list = _HNTP_Bld_Outpin_lst(list)
;
;DESCRIPTION:
;       This function will generate a list of pin dbids with the PIN_TYPE
;       definition of OUT, OCL, or OCA. This function firdt Generates a
;       a text file named temp_extract_list_hntp.txt for use of the extract
;       function capabilites in SKILL.
;       This function takes no parameters. This function will return a list
;       of pin dbid, if any pins match the OUT criteria, or nil if no match
;       is found
;
;       For further information see:
;       axlExtractMap, axlMsgPut
;
;-
;==========================================================================
defun( _HNTP_Bld_Outpin_lst ()
prog( ()
let( ( extract_file return_list)
        extract_file = outfile("temp_extract_list_hntp.txt")
        fprintf( extract_file "COMPONENT_PIN\nPIN_TYPE = \"OUT\"\nEND\n")
        close(extract_file)
        if( isFile("temp_extract_list_hntp.txt") then
            return_list = axlExtractMap( "temp_extract_list_hntp.txt")
        else
           axlMsgPut("ERROR 03 : Temp extract not generated!")
           return_list = nil
        ); end - if
        when( isFile("temp_extract_list_hntp.txt") deleteFile("temp_extract_list_hntp.txt"))
        return(return_list)
);end-let
);end-prog
);end-def _HNTP_Bld_Outpin_lst
;==========================================================================
;+
;NAME:
;       _HNTP_Create_Form_File
;
;SYNOPSIS:
;       _HNTP_Create_Form_File()
;
;DESCRIPTION:
;       This function write text data to a file named nl_ntp.form. The file
;       created is used for paramter form calls. This function takes no
;       parameters. This function returns t if file creation is successful.
;       A nil is returned and a message is printed if file creation failed.
;
;       For further information See:
;       Form Interface Functions in the Allegro SKILL Functions Reference
;       Manual.
;-
;==========================================================================
defun( _HNTP_Create_Form_File ()
prog( ()
   form_file = outfile("hl_ntp.form")
   fprintf( form_file "FILE_TYPE = FORM_DEFN VERSION=2\nFORM\nFIXED\n")
   fprintf( form_file "PORT 46 11\nHEADER \"Highlight Missing Test Points v2.0\"\n")
   fprintf( form_file "POPUP <PRINTP>\"to File\"\"0\",\"to Printer\"\"1\",\"to Script\" \"2\".\n")
   fprintf( form_file "TILE\n")
   fprintf( form_file "GROUP \"Preferences\"\nGLOC 2 1\nGSIZE 20 14\nENDGROUP\n\n")
   fprintf( form_file "GROUP \"Test Method\"\nGLOC 24 1\nGSIZE 20 10\nENDGROUP\n\n")
   fprintf( form_file "GROUP \"Options\"\nGLOC 24 12\nGSIZE 20 6\nENDGROUP\n\n")
   fprintf( form_file "FIELD inpin\nFLOC 3 4\nFGROUP \"Preferences\"\nCHECKLIST \"Input\" \"prefs\"\nENDFIELD\n\n")
   fprintf( form_file "FIELD outpin\nFLOC 3 6\nFGROUP \"Preferences\"\nCHECKLIST \"Output\" \"prefs\"\nENDFIELD\n\n")
   fprintf( form_file "FIELD anypin\nFLOC 3 8\nFGROUP \"Preferences\"\nCHECKLIST \"Any
Pin\" \"prefs\"\n ENDFIELD\n\n")
   fprintf( form_file "FIELD via\nFLOC 3 10\nFGROUP \"Preferences\"\nCHECKLIST \"Via\" \"prefs\"\nENDFIELD\n\n")
   fprintf( form_file "FIELD anypnt\nFLOC 3 12\nFGROUP \"Preferences\"\nCHECKLIST \"Any Point\" \"prefs\"\n ENDFIELD\n\n")
   fprintf( form_file "FIELD single\nFLOC 25 4\nFGROUP \"Test Method\"\nCHECKLIST \"Single\" \"mthd\"\nENDFIELD\n\n")
   fprintf( form_file "FIELD node\nFLOC 25 6\nFGROUP \"Test Method\"\nCHECKLIST \"Node\" \"mthd\"\n ENDFIELD\n\n")
   fprintf( form_file "FIELD flood\nFLOC 25 8\nFGROUP \"Test Method\"\nCHECKLIST \"Flood\" \"mthd\"\nENDFIELD\n\n")
   fprintf( form_file "FIELD unused\nFLOC 25 15\nCHECKLIST \"Unused Pins\"\nFGROUP \"Options\"\nENDFIELD\n\n")
   fprintf( form_file "FIELD execute\nFLOC 2 19\nMENUBUTTON \"Execute\" 9 3\nENDFIELD\n\n")
   fprintf( form_file "FIELD print\nFLOC 17 19\nMENUBUTTON \"Print\" 9 3\nENDFIELD\n\n")
   fprintf( form_file "FIELD cancel\nFLOC 32 19\nMENUBUTTON \"Cancel\" 9 3\nENDFIELD\n\n")
   fprintf( form_file "ENDTILE\nENDFORM\n")
   close( form_file )
   if( isFile("hl_ntp.form") then
        return( t )
   else
        axlMsgPut("ERROR 01: Unable to Open .form file")
        return( nil )
   );end-if
);end_prog
);end-defun _HNTP_Create_Form_File
 
;==========================================================================
;+
;NAME:
;       _HNTP_Init_Form_Display
;
;SYNOPSIS:
;       _HNTP_Init_Form_Display()
;
;DESCRIPTION:
;       This function will create a form and then display the form on the
;       screen. This function requires the hl_ntp.form file to exist and
;       this function requires the _HNTP_Form_CallBack function)
;       This function requires no parameters. This function will return the
;       dbid of the for it created.
;
;       For further information See:
;       axlFormCreate, axlFormSetField, axlFormDisplay
;       Form Interface Functions in the Allegro SKILL Functions Reference
;       Manual.
;-
;==========================================================================
defun( _HNTP_Init_Form_Display ()
prog( ()
let( ( form )
   form = axlFormCreate( (gensym) "hl_ntp.form" '(se outer) '_HNTP_Form_CallBack t)
   HNTP_Form_Ptr = form
 if( (HNTP_Form_Data == nil) then
   setq( HNTP_Form_Data t)
   axlFormSetField( form "outpin" nil)
   putprop( HNTP_Form_Data nil 'outpin)
   axlFormSetField( form "inpint" nil)
   putprop( HNTP_Form_Data nil 'inpin)
   axlFormSetField( form "anypin" nil)
   putprop( HNTP_Form_Data nil 'anypin)
   axlFormSetField( form "via" nil)
   putprop( HNTP_Form_Data nil 'via)
   axlFormSetField( form "anypnt" t)
   putprop( HNTP_Form_Data t 'anypnt)
   axlFormSetField( form "single" t)
   putprop( HNTP_Form_Data t 'single)
   axlFormSetField( form "node" nil)
   putprop( HNTP_Form_Data nil 'node)
   axlFormSetField( form "node" nil)
   putprop( HNTP_Form_Data nil 'flood)
   axlFormSetField( form "unused" nil)
   putprop( HNTP_Form_Data nil 'unused)
   axlFormDisplay( form )
 );end-if
);end-let
);end-prog
);end-defun _HNTP_Init_Form_Display
 
 
;==========================================================================
;+
;NAME:
;       _HNTP_Form_CallBack
;
;SYNOPSIS:
;       _HNTP_Form_CallBack()
;
;DESCRIPTION:
;       This function is used by the _HNTP_Init_Form_Display for the call
;       back required from the axlFormCreate command.
;       This function requires form dbid parameters This function returns no
;       paramteres. This funtion does pass a value to the global dbid
;       defined as HNTP_Form_Data and gets the form dbid number from global
;       variable HNTP_Form_Ptr.
;
;       For further information See:
;       axlFormCreate, axlFormSetField, axlFormDisplay, and
;       Form Interface Functions in the Allegro SKILL Functions Reference
;       Manual.
;-
;==========================================================================
defun( _HNTP_Form_CallBack (form)
case( get( HNTP_Form_Ptr 'curField)
        ("inpin" putprop( HNTP_Form_Data get(HNTP_Form_Ptr 'curValue) 'inpin))
        ("outpin" putprop( HNTP_Form_Data get(HNTP_Form_Ptr 'curValue) 'outpin))
        ("anypin" putprop( HNTP_Form_Data get(HNTP_Form_Ptr 'curValue) 'anypin))
        ("via" putprop( HNTP_Form_Data get(HNTP_Form_Ptr 'curValue) 'via))
        ("anypnt" putprop( HNTP_Form_Data get(HNTP_Form_Ptr 'curValue) 'anypnt))
        ("single" putprop( HNTP_Form_Data get(HNTP_Form_Ptr 'curValue) 'single))
        ("node" putprop( HNTP_Form_Data get(HNTP_Form_Ptr 'curValue) 'node))
        ("flood" putprop( HNTP_Form_Data get(HNTP_Form_Ptr 'curValue) 'flood))
        ("unused" putprop( HNTP_Form_Data get(HNTP_Form_Ptr 'curValue) 'unused))
        ( "execute" _HNTP_Execute() )
        ( "cancel"  _HNTP_Cancel() )
);end-case
);end-defunction _HNTP_Form_CallBack
 
;==========================================================================
;+
;NAME:
;       _HNTP_Cancel
;
;SYNOPSIS:
;       _HNTP_Cancel()
;
;DESCRIPTION:
;       This function called by the _HNTP_Form_CallBack().This funtion closes
;       the open form, deletes the hl_ntp.form file and exits the SKILL
;       process. This function requires the HNTP_Form_Ptr global variable.
;
;       For further information see:
;       axlFormClose, axlClearSelSet,axlCancelEnterFun()
;-
;==========================================================================
defun( _HNTP_Cancel ()
        when( isFile( "hl_ntp.form" )  deleteFile("hl_ntp.form"))
        when( HNTP_Form_Ptr axlFormClose( HNTP_Form_Ptr ))
        axlClearSelSet()
        axlCancelEnterFun()
);end-defun _HNTP_Cancel
 
 
;==========================================================================
;+
;NAME:
;       _HNTP_Flood_No_TP
;
;SYNOPSIS:
;       _HNTP_Flood_No_TP(list)
;
;DESCRIPTION:
;       This function returns a list of pin or via dbids() which have a
;       testPoint value of nil. This function takes in one parameter. The
;       input parameter (list) is a list of pin or via dbids.
;-
;==========================================================================
defun( _HNTP_Flood_No_TP (dbid_list )
prog( ()
let( ( return_list )
        foreach( item dbid_list
            when( item->testPoint == nil
                return_list = cons( item return_list)
            );end-when
        ); end-foreach
        return(return_list)
);end-let
);end-prog
);end-defun _HNTP_Flood_No_TP
 
 
;==========================================================================
;+
;NAME:
;       _HNTP_Single_No_TP
;
;SYNOPSIS:
;       _HNTP_Single_No_TP(pvlist nlist)
;
;DESCRIPTION:
;       This function takes in two parameters. The firat paramter is a
;       list of pin or via dbids (pvlist). The second parameter takes in a list
;       of net dbids (nlist). The function checks the pvlist dbids to determine
;       if the dbid has a  testPoint value of t. If the value t exists, the net
;       dbid number is removed from the nlist. This function returns a list of
;       net dbids which do not have a test point assigned.
;-
;==========================================================================
defun( _HNTP_Single_No_TP (pvlist nlist )
prog( ()
        foreach( item pvlist
            when( item->testPoint != nil
                nlist = remd( item->net nlist)
            );end-when
        ); end-foreach
        return(nlist)
);end-prog
);end-defun _HNTP_Single_No_TP
 
 
;==========================================================================
;+
;NAME:
;       _HNTP_Check_Unused
;
;SYNOPSIS:
;       _HNTP_Check_Unused(list)
;
;DESCRIPTION:
;       This function returns a list of pin dbids which have a valid net name
;       This function takes in one parameter. The input parameter
;       (list) is a list of pin dbids.
;-
;==========================================================================
defun( _HNTP_Check_Unused (dbid_list)
prog( ()
let( (return_list)
        foreach( item dbid_list
            when( item->net->name != ""
                return_list = cons( item return_list)
            );end-when
        ); end-foreach
        return(return_list)
);end-let
);end-prog
);end-defun _HNTP_Check_Unused
 
 
;==========================================================================
;+
;NAME:
;       _HNTP_Check_Unnamed
;
;SYNOPSIS:
;       _HNTP_Check_Unnamed(list)
;
;DESCRIPTION:
;       This function returns a list of net dbids which have a valid net name
;       This function takes in one parameter. The input parameter
;       (list) is a list of net dbids.
;-
;==========================================================================
defun( _HNTP_Check_Unnamed (dbid_list)
prog( ()
let( (return_list)
        foreach( item dbid_list
            when( item->name != ""
                return_list = cons( item return_list)
            );end-when
        ); end-foreach
        return(return_list)
);end-let
);end-prog
);end-defun _HNTP_Check_Unnamed
 
 
;==========================================================================
;+
;NAME:
;       _HNTP_Execute
;
;SYNOPSIS:
;       _HNTP_Execute()
;
;DESCRIPTION:
;       This function is called by the _HNTP_Form_CallBack(). This function
;       begins the execution of the SKILL commands to sort the choices made
;       from the form parameters and execute the functions required to hilight
;       the necessary elements.
;       This function requires no parameters.
;
;       for further information see:
;
;-
;==========================================================================
defun( _HNTP_Execute ()
let( (pin_list via_list net_list hilite_list)
  axlFormClose( HNTP_Form_Ptr )
        ;
        ;identify which list of dbids to obtain
        ;
   pin_list = nil
   via_list = nil
   net_list = nil
 
   if( HNTP_Form_Data->inpin == t  then
        pin_list = _HNTP_Bld_Inpin_lst()
   );end-if
 
   if(  HNTP_Form_Data->outpin == t then
        pin_list = _HNTP_Bld_Outpin_lst()
   );endif
 
   if( HNTP_Form_Data->anypin then
        pin_list = _HNTP_Bld_Pin_lst()
   ); endif
 
   when( HNTP_Form_Data->via == t via_list = _HNTP_Bld_Via_lst())
 
   when( HNTP_Form_Data->anypnt == t
        pin_list = _HNTP_Bld_Pin_lst()
        via_list = _HNTP_Bld_Via_lst()
   );end-when
 
   if( HNTP_Form_Data->flood == nil then
       net_list = _HNTP_Bld_Net_lst()
   );end-if
 
        ;
        ; if test unused pins is not selected, then remove the unused pin
        ; ids from the list
        ;
 
   if(  HNTP_Form_Data->unused == nil then
     when( pin_list != nil pin_list = _HNTP_Check_Unused( pin_list ))
     when( net_list != nil net_list = _HNTP_Check_Unnamed( net_list ))
   );end-if
        
 
        ;
        ; identify Methodology and identify missing test points and then
        ; highlight the proper items.
        ;
 
   when( HNTP_Form_Data->flood == t
        when( via_list != nil  hilite_list= _HNTP_Flood_No_TP(via_list) )
        if( hilite_list == nil then
                axlMsgPut( "No Vias to Highlight")
        else
                axlHighlightObject( hilite_list )
        );end-if
        hilite_list = nil
        when( pin_list != nil  hilite_list= _HNTP_Flood_No_TP(pin_list) )
        if( hilite_list == nil then
                axlMsgPut( "No Pins to Highlight")
        else
                axlHighlightObject( hilite_list t )
        );end-if
   );end-when
 
   when( HNTP_Form_Data->single == t
     if( net_list == nil  then
        axlMsgPut("ERROR 02: No Net dbids found")
     else
        when( via_list != nil net_list = _HNTP_Single_No_TP(via_list net_list))
        when( pin_list != nil net_list = _HNTP_Single_No_TP(pin_list net_list))
        if( net_list == nil then
                axlMsgPut( "No Nets to Highlight")
        else
                axlHighlightObject( net_list t )
        );end-if
     );end-if
   );end-when
 
  when( HNTP_Form_Data->node == t
  let( (used_netid)
     when(pin_list != nil
        foreach( pinid pin_list
        if( pinid->testPoint != nil then
                if( member(pinid->net net_list) then
                    used_netid= cons(pinid->net used_netid)
                    net_list = remd( pinid->net net_list)
                else
                    if( member(pinid->net used_netid) remd( pinid->net used_netid))
                );endif
        );end-if
        );end-foreach
    );end-when
 
     when(via_list != nil
        foreach( via_id via_list
        if( via_id->testPoint != nil then
                if( member(via_id->net net_list) then
                    used_netid= cons(via_id->net used_netid)
                    net_list = remd( via_id->net net_list)
                else
                    if( member(via_id->net used_netid) remd( via_id->net used_netid))
                );endif
        );end-if
        );end-foreach
    );end-when
        
    when( used_netid != nil
        foreach( netid used_netid hilite_list = cons( netid hilite_list))
        )
    when( net_list != nil
        foreach( netid net_list hilite_list = cons( netid hilite_list))
        )
 
    if(hilite_list == nil then
        axlMsgPut( "No Nets to Highlight")
    else
        axlHighlightObject( hilite_list t )
    );end-if
  )
  );end-when
 
   axlMsgPut(" Operation Completed!")
   _HNTP_Cancel()
);end-let
); end-defun _HNTP_Execute
 
;==========================================================================
;+
;NAME:
;       _HNTP_Run
;
;SYNOPSIS:
;       _HNTP_Run()
;
;DESCRIPTION:
;       This function is called at the startup of the SKILL hl_ntp.il program.
;       This function set the global variables HNTP_Form_Ptr and HNTP_Form_Data
;       which are required for Form display and call backs.
;       This function also verifies that all other function are halted before
;       begining this process.
;
;       This function requires no parameters.
;
;       for further information see:
;
;-
;==========================================================================
defun( _HNTP_Run ()
         HNTP_Form_Ptr = nil
         HNTP_Form_Data = nil
         when(axlOKToProceed()
           when(  _HNTP_Create_Form_File()
              _HNTP_Init_Form_Display()
           );end-when
         );end-when
);end-defun _HNTP_Run

; register command with Allegro
axlCmdRegister( "hl_ntp" `_HNTP_Run ?cmdType "general")

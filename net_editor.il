; Interactive Net List Editor
; Revision 0: March 18,1994
; written by:
;               Edward B. Acheson
;               Sr. Benchmark Systems Engineer
;               Cadence Design Systems
;               Chelmsford Mass.
;
;Description:
;        This SKILL file will allow the user to interactivly Pick
;       Nets, pins, or components to alter the netlist. Nets may
;       be deleted or added. Pins may be deleted, added, or changed.
;       Components may be Deleted or Added.
;        Selection of pins, nets, or Packages may also be made by
;       selecting the appropriate option in the popup form.

;Limitations:
;        Information input to the design is through an incremental
;       net list. Care should be taken if the board design is associated
;       with a schematic.
;        All Package input assumes the use of device files. When a package is
;       input, the device file is sought for, and if a symbol name is entered,
;       the symbol is also sought for. Reference designators are verified for
;       duplication, but only for placed and current input list of reference
;       designators. Unplaced reference designators may cause errors.

;Execution:
;        Locate this file (net_editor.il) in the directory path where all other
;       skill routines are located. In the allegro.ilinit file include the line
;       load("net_editor.il")
;       To Execute the command in the Allegro command window enter net_editor
;
;
;
;Revision 1: October 22, 1999
;		Modified to work with Allegro 13.x
;		Changed $done to $end
;
;Revision 2: November 9, 2001
;		Modified to work with the newer Import Logic form 
;		that was introduced in 13.6.
;		Also added some code that stops Allegro from
;		zooming to the world view when done.
;		This code does not work in 14.x. Use the built in
;		net editing capability of version 14.
;
axlCmdRegister( "net_editor" `_INEStart )
;
;
;===========================The Start Up Command ===============================

;This Segment Starts up the form call to Select the net edit options
;-------------------------------------------------------------------------------
defun( _INEStart ()
        unless( isFile("iane_start_up.form") _INEMakeFormFile())
        pingrp = nil
        _INEStartForm()
); enddefun
;============================Startup Form Call =================================
;This segment defines the form dbid, location and call back parameter
;-------------------------------------------------------------------------------
defun( _INEStartForm ()
prog( ()
        when( axlOKToProceed()
        form = nil
        form = axlFormCreate( (gensym) "iane_start_up.form" '(e outer)
                `_INEStartCallBk t)
        _INESFormPtr = form
        axlFormDisplay( form)
);end-when
);end-prog
);enddefun
;============================Form Call Back Commands ==========================
;       This is where the commands are called from the edit net form
;------------------------------------------------------------------------------
defun( _INEStartCallBk (form)
        case( get( _INESFormPtr 'curField)
                ( "addnet" _INENew_Net_Commands() )
                ( "delnet" _INEDel_Net_Commands() )
                ( "delpin" _INEDel_Pin_Commands() )
                ( "addpin" _INEAdd_Pin_Commands() )
                ( "chgpin" _INEChg_Pin_Commands() )
                ( "addpkg" _INEAdd_Pkg_Commands() )
                ( "delpkg" _INEDel_Pkg_Commands() )
                ( "adone" _INECancel() )
        );endcase
);enddefun
;============================Form Call Back Commands ==========================
;       This is where the commands are called from the add Package form
;------------------------------------------------------------------------------
defun( _INEPackCallBack (pform)
        case( get( _INESFormPtr 'curField)
                ( "newrefdes" putprop( _INEPackData get(_INESFormPtr 'curValue) 'newrefdes))
                ( "devfile" putprop( _INEPackData get(_INESFormPtr 'curValue) 'devfile))
                ( "newpkg" putprop( _INEPackData get(_INESFormPtr 'curValue) 'newpkg))
                ( "cmpval" putprop( _INEPackData get(_INESFormPtr 'curValue) 'cmpval))
                ( "cmptol" putprop( _INEPackData get(_INESFormPtr 'curValue) 'cmptol))
                ( "done" _INEMk_Add_Pack_Done() )
                ( "cancel" _INEACancel() )
                ( "nextone" _INEMk_Add_Pack_File() )
        );endcase
);enddefun
;==============================================================================
;===================================Popup Defenitions =========================
;==============================================================================
;-------------------------------Popupaddnet------------------------------------
; this popup is used for selecting pins to add to a net.
;------------------------------------------------------------------------------
defun( _INEPopUpAddNet ()
        popupaddnet = axlUIPopupDefine( nil (list
                (list "Select By Name" '_INEAddNetnameIN)
                (list "Complete" '_INEAddNetPinCompl)
                (list "Oops" '_INEOops)
                (list "Cancel" '_INECancel)
        ))
        axlUIPopupSet( popupaddnet)
);enddefun
;-------------------------------Popupdelnet------------------------------------
; this popup is used for selecting pins to add to a net.
;------------------------------------------------------------------------------
defun( _INEPopUpDelNet ()
        popupdlenet = axlUIPopupDefine( nil (list
                (list "Select By Name" '_INEDelNetname)
                (list "Oops" '_INEDelOops)
                (list "Cancel" '_INECancel)
        ))
        axlUIPopupSet( popupdlenet)
);enddefun
;-------------------------------Popupdelpin------------------------------------
; this popup is used for selecting pins to add to a net.
;------------------------------------------------------------------------------
defun( _INEPopUpDelPin ()
        popupdelpin = axlUIPopupDefine( nil (list
                (list "Select By Name" '_INEDelPinName)
                (list "Oops" '_INEOops)
                (list "Cancel" '_INECancel)
        ))
        axlUIPopupSet( popupdelpin)
);enddefun
;-------------------------------Popupaddpin------------------------------------
; this popup is used for selecting pins to add to a net.
;------------------------------------------------------------------------------
defun( _INEPopUpAddPin ()
        popupaddpin = axlUIPopupDefine( nil (list
                (list "Select By Name" '_INEAdd_Pin_Name)
                (list "Oops" '_INEOops)
                (list "Cancel" '_INECancel)
        ))
        axlUIPopupSet( popupaddpin)
);enddefun
;-------------------------------Popupaddpinnetname-----------------------------
; this popup is used for selecting net name to add pins to a net.
;------------------------------------------------------------------------------
defun( _INEPopUpAddPinNet ()
        popupadpnnm = axlUIPopupDefine( nil (list
                (list "Select By Name" '_INEAddPinNetName)
                (list "Oops" '_INEPinOops)
                (list "Cancel" '_INECancel)
        ))
        axlUIPopupSet( popupadpnnm)
);enddefun
;-------------------------------Popupchgpin------------------------------------
; this popup is used for selecting pins to Change a net on a pin.
;------------------------------------------------------------------------------
defun( _INEPopUpChgPin ()
        popupaddpin = axlUIPopupDefine( nil (list
                (list "Select By Name" '_INEChg_Pin_Name)
                (list "Oops" '_INEPinOops)
                (list "Cancel" '_INECancel)
        ))
        axlUIPopupSet( popupaddpin)
);enddefun
;-------------------------------Popupdelpkg------------------------------------
; this popup is used for selecting pins to Change a net on a pin.
;------------------------------------------------------------------------------
defun( _INEPopUpDelPkg ()
        popupdelpkg = axlUIPopupDefine( nil (list
                (list "Delete By RefDes Name" '_INEDel_Pkg_Name)
                (list "Oops" '_INEPkgOops)
                (list "Cancel" '_INECancel)
        ))
        axlUIPopupSet( popupdelpkg)
);enddefun
;===============================================================================
;===============================Common Init Variables===========================
;===============================================================================
defun( _INEInitVar ()
prog( ()
        allfound = nil
        ooped = nil
        doneit = nil
        pingrp = nil
        oktorun = nil
        axlUIPopupSet(nil)
        axlClearSelSet()
);endprog
);enddefun
;================================================================================
;=================================== Common Escape Functions ====================
;================================================================================
;-----------------------------------Cancel--------------------------------------
defun( _INECancel ()
prog( ()
        axlCancelEnterFun()
        axlFormClose( _INESFormPtr )
        axlClearSelSet()
        axlUIPopupSet(nil)
        axlFlushDisplay()
        setq( doneit t )
        setq( stpprocess t)
        setq( pingrp nil)
        setq( ooped t)
        setq( allfound t)
        when( isFile("iane_start_up.form") deleteFile("iane_start_up.form"))
        when( isFile("iane_add_package.form") deleteFile("iane_add_package.form"))
        return(nil)
);endprog
);enddefun
;-----------------------------------Ooops----------------------------------------
defun( _INEOops ()
prog( ()
        if(pingrp != nil then
                axlDehighlightObject( car(pingrp))
                pingrp = cdr(pingrp)
        else
                axlMsgPut(" Nothing Left To Oops!!!")
                axlCancelEnterFun()
                ooped = t
                allfound = t
                pingrp = nil
                axlUIPopupSet(nil)
        );endif
        return(pingrp)
);endprog
);enddfun
;-----------------------------Delete Ooops --------------------------------------
defun( _INEDelOops ()
prog( ()
        axlCancelEnterFun()
        doneit = t
        allfound = t
        netpickid = nil
        ooped = t
);endprog
);enddfun
;-----------------------------Pin Add Ooops --------------------------------------
defun( _INEPinOops ()
prog( ()
        when(pingrp == nil allfound = t)
        axlDehighlightObject( car(pingrp))
        axlCancelEnterFun()
        pinfound = nil
        pingrp = nil
        ooped = t
);endprog
);enddfun
;-----------------------------Pkg Del Ooops --------------------------------------
defun( _INEPkgOops ()
prog( ()
        axlCancelEnterFun()
        allfound = t
        pkgfound = nil
        ooped = t
);endprog
);enddfun
;-----------------------------------Add Pin Name input-----------------------------
defun( _INEAddNetnameIN ()
prog( ()
        axlCancelEnterFun()
        setq( picknet nil)
);endprog
);enddefun
;-----------------------------------Add Pin Complete ------------------------------
defun( _INEAddNetPinCompl ()
prog( ()
        setq( allfound t)
        axlCancelEnterFun()
        axlUIPopupSet(nil)
);endprog
);enddefun
;================================================================================
;=================================== Add Net Functions ==========================
;================================================================================
;------------------------Function call Sets for new net -------------------------
defun( _INENew_Net_Commands ()
prog( ()
        _INEInitVar()
        picknet = t
        pingrp = nil
        _INEPopUpAddNet()
        while( allfound == nil
                if(picknet == t then
                        _INEAddNetPick()
                else
                        _INEGetPinName()
                );endif
        );end-while
        axlUIPopupSet(nil)
        unless( pingrp == nil
                _INEBldNetFile()
                _INENetIn()
                axlClearSelSet()
        );endunless
        unless( doneit == t
                axlClearSelSet()
                axlFormClose( _INESFormPtr )
                axlFlushDisplay()
                axlUIPopupSet(nil)
                _INEStart()
        );endunless
);endprog
);enddefun
;------------------------Select Pins for adding new net -------------------------
; This function will locate a pin, verify that a net does not already exist and
; then store the data to build a net in file, incremental type, later.
;-------------------------------------------------------------------------------
defun( _INEAddNetPick ()
prog( ( )
        getpin = nil
        axlClearSelSet()
        unless( pingrp == nil axlHighlightObject( pingrp))
        getpin = nil
        axlSetFindFilter( ?enabled (list "noall" "pins") ?onButtons (list "pins"))
        axlMsgPut("Select Pin.")
        axlSingleSelectPoint( )
        setq( getpin axlGetSelSet())
        if( getpin != nil then
                unless( (getpin == nil && allfound == nil)
                        axlMsgPut("%s.%s Selected." car(getpin)->parent->refdes
                                car(getpin)->number)
                        if( car(getpin)->net->name == "" then
                                pingrp = cons( nthelem(1 getpin) pingrp)
                                axlHighlightObject( pingrp)
                                axlClearSelSet()
                        else
                                axlHighlightObject( car(getpin))
                                axlMsgPut(" Pin Assigned to a Net. Select Again.")
                                axlDehighlightObject( car(getpin))
                        );endif
                );endunless
        else
                when( (getpin == nil && allfound == nil)
                        unless( ooped == t  axlMsgPut("No Pin Found, Try Again."))
                );endwhen
        );endif
        return( pingrp)
);endprog
);enddefun
;-------------------------Select Pin by Name to add to new net ------------------
; This function will look for refdes and pin number, then verify if a net exists
; then if not net exists add the selection to the pin group variable set, to be
; input to the incremental net list.
;--------------------------------------------------------------------------------
defun( _INEGetPinName ()
prog( ()
        newpin_name = nil
        pincount = count = nil
        refdesids = nil
        axlClearSelSet()
        axlSetFindFilter( ?enabled (list "noall" "symbols") ?onButtons (list "symbols"))
        axlAddSelectAll()
        refdesids = axlGetSelSet()
        looking = plook = nil
        while( looking == nil && plook == nil
                axlSetFindFilter( ?enabled (list "noall" "pins") ?onButtons (list "pins"))
                newpin_name = axlUIPrompt("Enter Refdes.Pinnum" "")
                if( newpin_name == nil then
                        axlCancelEnterFun()
                        looking = t
                        plook = t
                        _INECancel()
                else
                        if( newpin_name != "" then
                                newpin_name = upperCase(newpin_name)
                                rdpinlst = parseString( newpin_name ".")
                                refdesg = nthelem( 1 rdpinlst)
                                pinidno = nthelem( 2 rdpinlst)
                                count = 1
                                while( nthelem(count refdesids) && looking == nil
                                        if( nthelem(count refdesids)->refdes == refdesg then
                                                pinlist = nthelem( count refdesids)->pins
                                                pcount = 1
                                                while( nthelem(pcount pinlist) && plook == nil
                                                        if( nthelem(pcount pinlist)->number == pinidno then
                                                                if( nthelem(pcount pinlist)->net->name == "" then
                                                                        pingrp = cons(nthelem( pcount pinlist) pingrp)
                                                                        axlMsgPut(" %s Selected" newpin_name)
                                                                else
                                                                        axlMsgPut(" Pin Assigned to a Net. Try Again.")
                                                                );endif
                                                                plook = t
                                                        );endif
                                                        ++pcount
                                                );endwhile
                                                unless( (plook == t) axlMsgPut("Pin Number Not Found. Try Again."))
                                                looking = t
                                        );endif
                                        ++count
                                );endwhile
                                unless( (looking == t) axlMsgPut("RefDes Not Found, Try Again."))
                        );endif
                );endif
                unless(pingrp == nil axlHighlightObject( pingrp))
        );endwhile
        picknet = t
        return( pingrp)
);endprog
);enddefun
;-------------------------Build Net List Data for add net -----------------------
; This funtion will ask for a net name, verify the net name does not exist, then
; verify all selections are correct. After which the load net list is invoked.
;--------------------------------------------------------------------------------
defun( _INEBldNetFile ()
prog( ()
        if(  pingrp != nil && nthelem( 2 pingrp) == nil then
                axlUIConfirm("Only One Pin Selected, No action Taken")
        else
                axlDehighlightObject( pingrp )
                axlUIPopupSet(nil)
                netids = netid = netverify= netverpin = nil
                verifyok = nil
                foundone = t
                tmpname = ""
                axlSetFindFilter( ?enabled ( list "nets" )  ?onButtons ( list "nets" ) )
                axlAddSelectAll()
                netids = axlGetSelSet()
 
                while( foundone == t
                        newnetname = axlUIPrompt(" Enter New Net Name" "")
                        if(newnetname == nil then
                                pingrp = nil
                                 _INECancel()
                                foundone = nil
                                return()
                        else
                                newnetname = upperCase(newnetname)
                                foundone = nil
                                unless( (newnetname == "")
                                        foreach( netid netids
                                                when( netid->name == newnetname foundone = t)
                                        );endforeach
                                        unless( (foundone == nil) axlMsgPut("Net Name Already Exists!"))
                                );endunless
                        );endif
                );endwhile
                unless( newnetname == nil
                        if(newnetname == "" then
                                tmpname = "Un-named"
                        else
                                tmpname = newnetname
                        );endif
                        sprintf( netverify "The Following Pins Will be Attached to\n net name: %s\n" tmpname)
                        foreach( pinid pingrp
                                sprintf( netverpin "%s.%s\n" pinid->parent->refdes pinid->number)
                                netverify = strcat( netverify netverpin)
                        );endforeach
                        verifyok = axlUIYesNo( netverify)
                        unless( (verifyok == nil)
                                netaddfl = outfile("ia_net_edit_tmp_in_file.txt")
                                fprintf( netaddfl "$NETS\n$ADD\n%s ; " newnetname)
                                foreach( pinid pingrp fprintf( netaddfl ",\n %s.%s" pinid->parent->refdes pinid->number))
                                fprintf( netaddfl "\n$END\n")	;This line was changed to END from DONE for PE13.x
                                close( netaddfl)
                        );endunless
                );endunless
        );endif
        when( newnetname == nil
                pingrp = nil
                _INECancel()
        );endwhen
        pingrp = nil
        return(pingrp)
);endprog
);enddefun
;--------------------------Net IN Routine For Add Net ---------------------------
; This funtion Operates the netin scripts, the suspends all funtions and leaves
; a done popup to exit this program
;--------------------------------------------------------------------------------
defun( _INENetIn ()
        when( isFile("ia_net_edit_tmp_in_file.txt")
		    l_bBox=axlWindowBoxGet()	;Save the current window view
                axlMsgPut("Updating Database.")
                axlClearSelSet()
                axlUIPopupSet(nil)
                axlShell("scriptmode +invisible")
                axlShell("scriptmode +noinfo")
                axlShell("setwindow pcb")
                axlShell("netin param")
                axlShell("setwindow form.niparams")
		    axlShell("FORM niparams netin_netlist YES") 
                axlShell("FORM niparams filename ia_net_edit_tmp_in_file.txt")
                axlShell("FORM niparams options")
                axlShell("FORM niparams syntax_check_only NO")
                axlShell("FORM niparams supercede NO")
                axlShell("FORM niparams append_device_log NO")
                axlShell("FORM niparams remove_etch NO")
                axlShell("FORM niparams place_never YES")
                axlShell("FORM niparams Done")
                axlShell("setwindow pcb")
                axlShell("scriptmode -invisible")
                axlShell("scriptmode -noinfo")
                deleteFile( "ia_net_edit_tmp_in_file.txt")
		    axlWindowBoxSet(l_bBox)	;Restore the window view
                return()
        );endwhen
);enddefun
;================================================================================
;================================ Delete Net Functions ==========================
;================================================================================
;------------------------Function call Sets for new net -------------------------
defun( _INEDel_Net_Commands ()
prog( ()
        _INEInitVar()
        stpprocess = nil
        doneit = nil
        picknet = t
        netpickid = nil
        _INEPopUpDelNet()
        while( allfound == nil
                when(picknet == t _INEDelNetPick())
                when(picknet == nil _INEGetNetName())
        );end-while
        axlUIPopupSet(nil)
        unless( doneit == t _INEDelNetIn())
        axlClearSelSet()
        unless( stpprocess == t
                axlFormClose( _INESFormPtr )
                axlFlushDisplay()
                axlUIPopupSet(nil)
                _INEStart()
        );endunless
);endprog
);enddefun
;--------------------------- Find Net By Pick ----------------------------------
;       This function will locate a net by pick.
;-------------------------------------------------------------------------------
defun( _INEDelNetPick ()
prog( ()
        axlSetFindFilter( ?enabled '( "noall" "nets") ?onButtons '("nets"))
        axlSingleSelectPoint()
        netpickid = axlGetSelSet()
        if( car(netpickid)->name == "" || netpickid == nil then
                unless( ooped == t axlMsgPut(" No Net Found. Select again."))
        else
                axlHighlightObject( netpickid)
                sprintf( pmptmess "Net Name %s Will Be Delete!" car(netpickid)->name )
                netdel = axlUIYesNo( pmptmess )
                axlDehighlightObject( netpickid)
                if( netdel == t then
                        netdelfl = outfile("ia_net_edit_tmp_in_file.txt")
                        fprintf( netdelfl "$NETS\n$DELETE\n%s\n$END\n" car(netpickid)->name)
                        close( netdelfl)
                else
                        doneit = t
                );endif
                allfound = t
        );endif
);end-prog
);enddefun
;----------------------------- Delete By Net Name -------------------------------
;       This function will find a net by giving the net name. This will verify
;       if the net name exists first, Verify the nets deletion, the create the
;       proper delete file.
;-------------------------------------------------------------------------------
defun( _INEDelNetname ()
prog( ()
        good = nil
        netname = axlUIPrompt( "Enter Net Name To Be Deleted" "")
        netname = upperCase(netname)
        if( netname != nil then
                netname = upperCase(netname)
                if( netname == "" then
                        axlMsgPut(" No Net Name Selected.")
                        doneit = t
                        allfound = t
                else
                        axlSetFindFilter( ?enabled '( "noall" "nets") ?onButtons '("nets"))
                        axlAddSelectAll()
                        netnamelist = axlGetSelSet()
                        foreach( net netnamelist
                                when( net->name == netname
                                        netid = list( net )
                                        good = t
                                );endwhen
                        );endeach
                        if( good == t then
                                axlHighlightObject( netid )
                                sprintf( pmptmess "Net Name %s Will Be Delete!" netname)
                                netdel = axlUIYesNo( pmptmess )
                                axlDehighlightObject( netid )
                                if( netdel == t then
                                        netdelfl = outfile("ia_net_edit_tmp_in_file.txt")
                                        fprintf( netdelfl "$NETS\n$DELETE\n%s\n$END\n" netname)
                                        close( netdelfl)
                                else
                                        doneit = t
                                );
                        else
                                axlClearSelSet()
                                axlMsgPut(" Net Name Not Found! Try Again!")
                                allfound = t
                        );endif
                );endif
        else
                doneit = t
        );endif
);endprog
);enddfun
;--------------------------Net IN Routine For Deleting  net ---------------------
; This funtion Operates the netin scripts, the suspends all funtions and leaves
; a done popup to exit this program
;--------------------------------------------------------------------------------
defun( _INEDelNetIn ()
        when( isFile("ia_net_edit_tmp_in_file.txt")
		    l_bBox=axlWindowBoxGet()	;Save the current window view
                axlMsgPut("Updating Database.")
                axlClearSelSet()
                axlUIPopupSet(nil)
                axlShell("scriptmode +invisible")
                axlShell("scriptmode +noinfo")
                axlShell("setwindow pcb")
                axlShell("netin param")
                axlShell("setwindow form.niparams")
		    axlShell("FORM niparams netin_netlist YES") 
                axlShell("FORM niparams filename ia_net_edit_tmp_in_file.txt")
                axlShell("FORM niparams options")
                axlShell("FORM niparams syntax_check_only NO")
                axlShell("FORM niparams supercede NO")
                axlShell("FORM niparams append_device_log NO")
                axlShell("FORM niparams remove_etch YES")
                axlShell("FORM niparams place_never YES")
                axlShell("FORM niparams Done")
                axlShell("setwindow pcb")
                axlShell("scriptmode -invisible")
                axlShell("scriptmode -noinfo")
                deleteFile("iane_tmp.txt")
                deleteFile( "ia_net_edit_tmp_in_file.txt")
		    axlWindowBoxSet(l_bBox)	;restore window view
                return()
        );endwhen
);enddefun
;--------------------Select Pin by Pick to Delete Pin from net ------------------
; This function will call routines to find a pin, verify the pin is assigned to a
; net, then verify to the user that the pin will be deleted from the net.
;--------------------------------------------------------------------------------
defun( _INEDel_Pin_Commands ()
prog( ()
        _INEInitVar()
        netdel = nil
        pindel = nil
        _INEPopUpDelPin()
        while( allfound == nil
                axlMsgPut(" Select Pin To Be Deleted.")
                axlSetFindFilter( ?enabled '( "noall" "pins") ?onButtons '("pins"))
                axlSingleSelectPoint()
                when( (allfound == nil && netdel == nil) pingrp = axlGetSelSet())
                if(pingrp != nil && ooped != t then
                        axlHighlightObject( pingrp )
                        if( car(pingrp)->net->name == "" then
                                axlMsgPut("Pin %s.%s Has No Net Assigned. No Action Taken"
                                        car( pingrp )->parent->refdes car(pingrp)->number)
                                axlDehighlightObject( pingrp )
                                pingrp = nil
                        else
                                sprintf( pmptmess "Pin %s.%s Will Be Deleted From\n Net %s."
                                        car( pingrp )->parent->refdes car(pingrp)->number car(pingrp)->net->name)
                                netdel = axlUIYesNo( pmptmess )
                                axlDehighlightObject( pingrp )
                                if(netdel == t then
                                        pindlf = outfile("ia_net_edit_tmp_in_file.txt")
                                        fprintf( pindlf "$PINS\n$DELETE\n%s.%s\n$END\n"
                                        car(pingrp)->parent->refdes car(pingrp)->number)
                                        close( pindlf)
                                        allfound = t
                                else
                                        pingrp = nil
                                        allfound = nil
                                        doneit = t
                                );endif
                        );endif
                else
                        when(ooped == nil axlMsgPut("No Pin Found, Try Again!"))
                        pingrp = nil
                );endif
        );endwhile
        unless( pingrp == nil
                _INENetIn()
        );endunless
        axlUIPopupSet(nil)
        axlClearSelSet()
        unless( doneit == t
                axlFormClose( _INESFormPtr )
                axlFlushDisplay()
                _INEStart()
        );endunless
);endprog
);enddefun
;-------------------------Delete_ Pin From Net By Name -------------------------
defun( _INEDelPinName ()
prog( ()
        axlCancelEnterFun()
        newpin_name = nil
        pincount = count = nil
        refdesids = nil
        axlClearSelSet()
        axlSetFindFilter( ?enabled (list "noall" "symbols") ?onButtons (list "symbols"))
        axlAddSelectAll()
        refdesids = axlGetSelSet()
        looking = plook = nil
        while( looking == nil && plook == nil
                axlSetFindFilter( ?enabled (list "noall" "pins") ?onButtons (list "pins"))
                newpin_name = axlUIPrompt("Enter Refdes.Pinnum" "")
                if( newpin_name == nil then
                        axlCancelEnterFun()
                        plook = t
                        looking = t
                        _INECancel()
                else
                        when( newpin_name != ""
                                newpin_name = upperCase(newpin_name)
                                rdpinlst = parseString( newpin_name ".")
                                refdesg = nthelem( 1 rdpinlst)
                                pinidno = nthelem( 2 rdpinlst)
                                count = 1
                                while( nthelem(count refdesids) && looking == nil
                                        when( nthelem(count refdesids)->refdes == refdesg
                                                pinlist = nthelem( count refdesids)->pins
                                                pcount = 1
                                                while( nthelem(pcount pinlist) && plook == nil
                                                        when( nthelem(pcount pinlist)->number == pinidno
                                                                if( nthelem(pcount pinlist)->net->name != "" then
                                                                        pingrp = list(nthelem( pcount pinlist))
                                                                        netdel = t
                                                                        axlMsgPut(" %s Selected" newpin_name)
                                                                else
                                                                        axlMsgPut(" Pin Not Assigned to a Net. Try Again.")
                                                                );endif
                                                                plook = t
                                                        );endwhen
                                                        ++pcount
                                                );endwhile
                                                unless( (plook == t) axlMsgPut("Pin Number Not Found. Try Again."))
                                                looking = t
                                        );endwhen
                                        ++count
                                );endwhile
                                unless( (looking == t) axlMsgPut("RefDes Not Found, Try Again."))
                        );endwhen
                );endif

                unless(pingrp == nil axlHighlightObject( pingrp))
        );endwhile
        axlClearSelSet()
        return( pingrp)
);endprog
);enddefun
;--------------------Select Pin by Pick to Add Pin To net -----------------------
; This function will call routines to find a pin, verify the pin is not assigned
; to a net. Then request a net name and verify that net exists. then Add pin to
; the net.
;--------------------------------------------------------------------------------
defun( _INEAdd_Pin_Commands ()
prog( ()
        _INEInitVar()
        good = nil
        pinfound = nil
        netfound = nil
        netnme = nil
        _INEPopUpAddPin()
        while( allfound == nil
                axlMsgPut(" Select Pin To Be Added.")
                axlSetFindFilter( ?enabled '( "noall" "pins") ?onButtons '("pins"))
                axlSingleSelectPoint()
                when( pinfound == nil pingrp = axlGetSelSet())
                unless( (pingrp == nil || ooped == t)
                        if( car(pingrp)->net->name != "" then
                                axlMsgPut("Pin %s.%s Is Assigned To A Net. Select Again "
                                        car( pingrp )->parent->refdes car(pingrp)->number)
                                pingrp = nil
                        else
                                axlMsgPut("Pin %s.%s Selected." car( pingrp )->parent->refdes
                                                 car(pingrp)->number)
                                pinfound = t
                        );endif
                );endunless
                while(pingrp != nil && netfound == nil
                        axlClearSelSet()
                        axlHighlightObject( car(pingrp))
                        axlUIPopupSet(nil)
                        _INEPopUpAddPinNet()
                        axlMsgPut(" Select Net to Add Pin To.")
                        axlSetFindFilter( ?enabled '( "noall" "nets") ?onButtons '("nets"))
                        axlSingleSelectPoint()
                        if( ooped == nil then
                                when(netnme == nil
                                        netnme = axlGetSelSet()
                                        good = t
                                );endwhen
                                if( car(netnme)->name  == "" then
                                        axlMsgPut("No Net Name, Please Select Again.")
                                        netfound = nil
                                else
                                        unless( netnme == nil
                                        when( (good == t && nthelem(2 netnme) == nil)
                                                allfound = t
                                                netfound = t
                                        );endwhen
                                        );endunless
                                );endif
                        else
                                ooped = nil
                                pinfound = nil
                        );endif
                );endwhile
        );endwhile
        unless(doneit == t
        when( (netfound == t && pinfound) == t
                sprintf( pmptmess "Pin %s.%s Will Be Added To\n Net %s."
                        car( pingrp )->parent->refdes car(pingrp)->number car(netnme)->name)
                oktorun = axlUIYesNo( pmptmess )
                if(oktorun == t then
                        pindlf = outfile("ia_net_edit_tmp_in_file.txt")
                        fprintf( pindlf "$PINS\n$ADD\n%s ; %s.%s\n$END\n"
                        car(netnme)->name car(pingrp)->parent->refdes car(pingrp)->number)
                        close( pindlf)
                        oktorun = t
                else
                        pingrp = nil
                        allfound = nil
                        netfound = nil
                );endif
        );endwhen
        );ednunless
        unless( oktorun == nil
                _INENetIn()
        );endunless
        axlUIPopupSet(nil)
        axlClearSelSet()
        unless( doneit == t
                axlFormClose( _INESFormPtr )
                axlFlushDisplay()
                _INEStart()
        );endunless
);endprog
);enddfun
;----------------------Add Pin To Net By Pin Name ------------------------------
defun( _INEAdd_Pin_Name ()
prog( ()
        axlCancelEnterFun()
        newpin_name = nil
        pincount = count = nil
        refdesids = nil
        axlClearSelSet()
        axlSetFindFilter( ?enabled (list "noall" "symbols") ?onButtons (list "symbols"))
        axlAddSelectAll()
        refdesids = axlGetSelSet()
        looking = plook = nil
        while( looking == nil && plook == nil
                axlSetFindFilter( ?enabled (list "noall" "pins") ?onButtons (list "pins"))
                newpin_name = axlUIPrompt("Enter Refdes.Pinnum" "")
                if( newpin_name == nil then
                        looking = t
                        plook = t
                        axlCancelEnterFun()
                        _INECancel()
                else
                        when( newpin_name != ""
                                newpin_name = upperCase(newpin_name)
                                rdpinlst = parseString( newpin_name ".")
                                refdesg = nthelem( 1 rdpinlst)
                                pinidno = nthelem( 2 rdpinlst)
                                count = 1
                                while( nthelem(count refdesids) && looking == nil
                                        if( nthelem(count refdesids)->refdes == refdesg then
                                                pinlist = nthelem( count refdesids)->pins
                                                pcount = 1
                                                while( nthelem(pcount pinlist) && plook == nil
                                                        when( nthelem(pcount pinlist)->number == pinidno
                                                                if( nthelem(pcount pinlist)->net->name == "" then
                                                                        pingrp = list(nthelem( pcount pinlist))
                                                                        pinfound = t
                                                                        axlMsgPut(" %s Selected" newpin_name)
                                                                else
                                                                        axlMsgPut(" Pin Assigned to a Net. Try Again.")
                                                                );endif
                                                                plook = t
                                                        );endwhen
                                                        ++pcount
                                                );endwhile
                                                unless( (plook == t) axlMsgPut("Pin Number Not Found. Try Again."))
                                                looking = t
                                        );endif
                                        ++count
                                );endwhile
                                unless( (looking == t) axlMsgPut("RefDes Not Found, Try Again."))
                        );endwhen
                );endif
                unless(pingrp == nil axlHighlightObject( pingrp))
        );endwhile
        axlMsgPut("%L" pingrp )
        axlClearSelSet()
        return( pingrp)
);endprog
);enddefun
;---------------------------------Select Net Name to Add Pin To ----------------
defun( _INEAddPinNetName ()
prog( ()
        axlCancelEnterFun()
        doneit = nil
        good = nil
        netname = axlUIPrompt( "Enter Net Name To Add Pin To." "")
        if( netname != nil then
                netname = upperCase(netname)
                if( netname == "" then
                        axlMsgPut(" No Net Name Selected.")
                        allfound = nil
                else
                        axlSetFindFilter( ?enabled '( "noall" "nets") ?onButtons '("nets"))
                        axlAddSelectAll()
                        netnamelist = axlGetSelSet()
                        foreach( net netnamelist
                                when( net->name == netname
                                        netnme = list(net)
                                        netfound = t
                                        good = t
                                        allfound = t
                                );endwhen
                        );endeach
                        when(good == nil
                                axlMsgPut(" Net Not Found, Try Again.")
                                allfound = nil
                                netfound = nil
                        );endwhen
                );endif
                axlClearSelSet()
                return( netnme )
        else
                axlClearSelSet()
                axlCancelEnterFun()
                _INECancel()
        );endif
);endprog
);enddfun
;--------------------Change Pin by Pick to New Net From Old --------------------
; This function will call routines to find a pin, verify the pin is not assigned
; to a net. Then request a net name and verify that net exists. then Add pin to
; the net.
;--------------------------------------------------------------------------------
defun( _INEChg_Pin_Commands ()
prog( ()
        _INEInitVar()
        good = nil
        pinfound = nil
        netfound = nil
        netnme = nil
        oldnetname = nil
        _INEPopUpChgPin()
        while( allfound == nil
                axlMsgPut(" Select Pin To Be Changed.")
                axlSetFindFilter( ?enabled '( "noall" "pins") ?onButtons '("pins"))
                axlSingleSelectPoint()
                when( pinfound == nil pingrp = axlGetSelSet())
                when(pingrp != nil && ooped != t
                        axlMsgPut("Pin %s.%s Selected." car( pingrp )->parent->refdes
                                         car(pingrp)->number)
                        pinfound = t
                );endwhen
                while(pingrp != nil && netfound == nil
                        axlClearSelSet()
                        axlHighlightObject( car(pingrp))
                        axlUIPopupSet(nil)
                        _INEPopUpAddPinNet()
                        axlMsgPut(" Select Net to Add Pin To.")
                        axlSetFindFilter( ?enabled '( "noall" "nets") ?onButtons '("nets"))
                        axlSingleSelectPoint()
                        if( ooped == nil then
                                when(netnme == nil
                                        netnme = axlGetSelSet()
                                        good = t
                                );endwhen
                                if( car(netnme)->name  == "" then
                                        axlMsgPut("No Net Name, Please Select Again.")
                                        netfound = nil
                                else
                                        unless( netnme == nil
                                        when(good == t && nthelem(2 netnme) == nil
                                                allfound = t
                                                netfound = t
                                        );endwhen
                                        );endunless
                                );endif
                        else
                                ooped = nil
                                pinfound = nil
                        );endif
                );endwhile
        );endwhile
        axlDehighlightObject(pingrp)
        axlUIPopupSet(nil)
        unless(doneit == t
                if(netfound == t && pinfound == t then
                        if( car(pingrp)->net->name == "" then
                                oldnetname = "Un-Named"
                        else
                                oldnetname = car(pingrp)->net->name
                        );endif
                        axlHighlightObject(pingrp)
                        axlHighlightObject( netnme )
                        sprintf( pmptmess "Pin %s.%s Will Changed From\n Old Net %s to New Net %s\n"
                                car( pingrp )->parent->refdes car(pingrp)->number oldnetname car(netnme)->name)
                        oktorun = axlUIYesNo( pmptmess )
                        axlDehighlightObject(pingrp)
                        axlDehighlightObject(netnme)
                        if(oktorun == t then
                                pindlf = outfile("ia_net_edit_tmp_in_file.txt")
                                fprintf( pindlf "$PINS\n")
                                when( car(pingrp)->net->name != ""
                                        fprintf( pindlf "$DELETE\n%s.%s\n" car(pingrp)->parent->refdes car(pingrp)->number)
                                );endwhen
                                fprintf( pindlf "$ADD\n%s ; %s.%s\n$END\n" car(netnme)->name car(pingrp)->parent->refdes car(pingrp)->number)
                                close( pindlf)
                        else
                                pingrp = nil
                                allfound = nil
                                netfound = nil
                        );endif
                );endif
                when( isFile("ia_net_edit_tmp_in_file.txt") _INEDelNetIn())
                axlClearSelSet()
                axlFormClose( _INESFormPtr )
                axlFlushDisplay()
                axlUIPopupSet(nil)
                _INEStart()
        );endunless
);endprog
);enddfun
;-------------------------Change Pin By Pin Name to a New Net ------------------
defun( _INEChg_Pin_Name ()
prog( ()
        axlCancelEnterFun()
        newpin_name = nil
        pincount = count = nil
        refdesids = nil
        axlClearSelSet()
        axlUIPopupSet(nil)
        axlSetFindFilter( ?enabled (list "noall" "symbols") ?onButtons (list "symbols"))
        axlAddSelectAll()
        refdesids = axlGetSelSet()
        looking = plook = nil
        while( looking == nil && plook == nil
                axlSetFindFilter( ?enabled (list "noall" "pins") ?onButtons (list "pins"))
                newpin_name = axlUIPrompt("Enter Refdes.Pinnum" "")
                if( newpin_name == nil then
                        looking = t
                        plook = t
                        axlCancelEnterFun()
                        _INECancel()
                else
                        unless( newpin_name == ""
                                newpin_name = upperCase(newpin_name)
                                rdpinlst = parseString( newpin_name ".")
                                refdesg = nthelem( 1 rdpinlst)
                                pinidno = nthelem( 2 rdpinlst)
                                count = 1
                                while( nthelem(count refdesids) && looking == nil
                                        when( nthelem(count refdesids)->refdes == refdesg
                                                pinlist = nthelem( count refdesids)->pins
                                                pcount = 1
                                                while( nthelem(pcount pinlist) && plook == nil
                                                        when( nthelem(pcount pinlist)->number == pinidno
                                                                pingrp = list(nthelem( pcount pinlist))
                                                                pinfound = t
                                                                axlMsgPut(" %s Selected" newpin_name)
                                                                plook = t
                                                        );endwhen
                                                        ++pcount
                                                );endwhile
                                                unless( (plook == t) axlMsgPut("Pin Number Not Found. Try Again."))
                                                looking = t
                                        );endwhen
                                        ++count
                                );endwhile
                                unless( (looking == t) axlMsgPut("RefDes Not Found, Try Again."))
                        );endunless
                );endif
                unless(pingrp == nil axlHighlightObject( pingrp))
        );endwhile
        axlUIPopupSet(nil)
        axlClearSelSet()
        return( pingrp)
);endprog
);enddefun
;================================================================================
;============================== Delete Package Functions ========================
;================================================================================
;---------------------Function call Ids and Deletes Pakage ----------------------
defun( _INEDel_Pkg_Commands ()
prog( ()
        _INEInitVar()
        pkgdel = nil
        pkgfound = nil
        pkgnme = nil
        _INEPopUpDelPkg()
        while( allfound == nil && ooped == nil
                axlMsgPut("Select Component To Be Deleted From Database.")
                axlSetFindFilter( ?enabled (list "noall" "components") ?onButtons (list "components"))
                axlSingleSelectPoint()
                unless(pkgfound == t pkgnme = axlGetSelSet())
                axlClearSelSet()
                if(pkgnme != nil then
                        unless( pkgnme == ""
                                axlHighlightObject(pkgnme)
                                pkgfound = t
                        );endunless
                                allfound = t
                else
                        unless( ooped == t axlMsgPut("Reference Designator Not Found, Try Again."))
                        allfound = nil
                        pkgfound = nil
                );endif
        );end-while
        axlUIPopupSet(nil)
        unless(pkgfound == nil && ooped == t
                sprintf( pmptmess "Component ReferenceDesignator\n    %s\n Will Be Deleted From The Database."
                        car(pkgnme)->name)
                pkgdel = axlUIYesNo( pmptmess )
                if(pkgdel == t then
                        pindlf = outfile("ia_net_edit_tmp_in_file.txt")
                        fprintf( pindlf "$PACKAGES\n$DELETE\n%s\n$END\n" car(pkgnme)->name)
                        close( pindlf)
                        oktorun = t
                else
                        axlDehighlightObject( pkgnme )
                        axlClearSelSet()
                );endif
                when( oktorun == t _INEDelNetIn())
        );endunless
        axlUIPopupSet(nil)
        axlClearSelSet()
        unless( doneit == t
                axlFormClose( _INESFormPtr )
                axlFlushDisplay()
                _INEStart()
        );endunless
        axlUIPopupSet(nil)
);endprog
);enddefun
;----------------------- Delete By Component RefDes Name ----------------------
;       This function will find a component by giving the Refdes name. This will
; verify if the refdes name exists first, Verify the refdes deletion, the pass the
; Refdes to the delete package section.
;-------------------------------------------------------------------------------
defun( _INEDel_Pkg_Name ()
prog( ()
        good = nil
        rfdnamelist = nil
        rfdname = nil
        axlCancelEnterFun()
        axlUIPopupSet(nil)
        axlClearSelSet()
        rfdname = axlUIPrompt( "Enter Reference Designator Name To Be Deleted" "")
        if( rfdname != nil then
                rfdname = upperCase(rfdname)
                if( rfdname == "" then
                        axlMsgPut(" No Reference Designator Selected.")
                        allfound = t
                else
                        axlSetFindFilter( ?enabled '( "noall" "components") ?onButtons '("components"))
                        axlAddSelectAll()
                        rfdnamelist = axlGetSelSet()
                        foreach( rfd rfdnamelist
                                if( rfd->name == rfdname then
                                        good = t
                                        pkgnme = list(rfd)
                                        pkgfound = t
                                );endif
                        );endeach
                        if( good == nil then
                                pkgfound = t
                                pkgnme = nil
                        );endif
                );endif
        else
                allfound = t
                pkgnme = ""
                ooped = t
                axlUIPopupSet(nil)
                axlClearSelSet()
                _INECancel()
        );endif
        axlClearSelSet()
        axlUIPopupSet(nil)
        return(pkgnme)
);endprog
);enddfun
;==============================This is the add package command set ===============
; This section will allow you to add package symbols to the Allegro database
; on the fly. The Packages are added one by one, but a group may be added by
; hitting the next command button on the menu form.
;=================================================================================
;---------------------------The startup portion ----------------------------------
defun( _INEAdd_Pkg_Commands ()
prog( ()
        newdeslist = nil
        _INEPackData = nil
        axlFormClose( _INESFormPtr )
        deleteFile( "iane_start_up.form")
        _INEInitPackForm()
);endprog
);end-defun
;---------------------------------Forminit for add package -----------------------
defun( _INEInitPackForm ()
prog( ()
(let (pform)
        if( ! isFile("iane_add_package.form") then _INEMakePackFormFile() )
        pform = nil
        pform = axlFormCreate( (gensym) "iane_add_package.form" '(c inner) '_INEPackCallBack t)
        _INESFormPtr = pform
        if( (_INEPackData == nil ) then
                setq( _INEPackData t)
                (axlFormSetField pform "newrefdes" "")
                putprop( _INEPackData "" 'newrefdes)
                (axlFormSetField pform "devfile" "")
                putprop( _INEPackData "" 'devfile)
                (axlFormSetField pform "newpkg" "")
                putprop( _INEPackData "" 'newpkg)
                (axlFormSetField pform "cmpval" "")
                putprop( _INEPackData "" 'cmpval)
                (axlFormSetField pform "cmptol" "")
                putprop( _INEPackData "" 'cmptol)
        axlFormDisplay( pform)
        );endif
);end-let
);end-prog
); enddefun
;---------------------------make netin file -------------------------------------
; This routine will verify if the defined refdes  exists already and verifies if
; the device file entered exists or not.
;--------------------------------------------------------------------------------
defun( _INEMk_Add_Pack_File ()
prog( ()
        devpthdir = nil
        good = nil
        goahead = nil
        foundone = nil
        oktogo = nil
        axlSetFindFilter( ?enabled (list "noall" "components") ?onButtons (list "components"))
        axlAddSelectAll()
        refdeslist = axlGetSelSet()
        foreach( rdlt refdeslist
                if( rdlt->name == upperCase(_INEPackData->newrefdes) then foundone = t));endforeach
                unless( newdeslist == nil
                        if( member( upperCase(_INEPackData->newrefdes) newdeslist) then foundone = t))
        if( foundone == nil then
                newdeslist = cons( upperCase(_INEPackData->newrefdes) newdeslist)
                devpthdir = parseString( axlGetVariable( "devpath") " ")
                foreach( devdir devpthdir
                        if( isFile(strcat( devdir strcat( "/" strcat( _INEPackData->devfile ".txt")))) then
                                good = t);endif
                );endforeach
                if(good == t then
                        when( _INEPackData->newpkg == "" goahead = t)
                        unless( goahead == t
                                axlSetFindFilter( ?enabled (list "noall" "symbols") ?onButtons (list "symbols"))
                                axlClearSelSet()
                                axlAddSelectAll()
                                symlist= axlGetSelSet()
                                foreach( symb symlist
                                        when( symb->type == "PACKAGE" && (upperCase(_INEPackData->newpkg) == symb->name)
                                                goahead = t);endwhen
                                );endforeach
                        );endunless
                        unless(goahead == t
                                sympthdir= parseString( axlGetVariable( "psmpath") " ")
                                foreach( psmdir sympthdir
                                        when( isFile(strcat( psmdir strcat( "/" strcat( _INEPackData->newpkg ".psm"))))
                                        goahead = t);endwhen
                                );endforeach
                        );endunless
                        if(goahead == nil then axlMsgPut("Specified Package Symbol Does Not Exist."))
                        if(good == t && ( _INEPackData->newpkg == "" || goahead == t) then
                                sprintf( pmptmess "The Following Component\nwill be added to the database:\n")
                                pmptmess = strcat( pmptmess "Refence Designator: " upperCase(_INEPackData->newrefdes))
                                pmptmess = strcat(pmptmess "\nDevice File: " upperCase(_INEPackData->devfile))
                                pmptmess = strcat(pmptmess "\n \nOptional Data:\nPackage Name: " upperCase(_INEPackData->newpkg))
                                pmptmess = strcat(pmptmess "\nComponent Value: " _INEPackData->cmpval)
                                pmptmess = strcat(pmptmess "\nComponent Tolerance: " _INEPackData->cmptol)
                                oktogo = axlUIYesNo( pmptmess )
                                unless( oktogo == nil
                                        if( ! isFile("ia_net_edit_tmp_in_file.txt") then
                                                addpkgfl = outfile("ia_net_edit_tmp_in_file.txt")
                                                fprintf( addpkgfl "$PACKAGES\n$ADD\n")
                                        );endif
                                        if( isFile("ia_net_edit_tmp_in_file.txt") then
                                                unless( _INEPackData->newpkg == "" fprintf( addpkgfl "%s"
                                                        upperCase(_INEPackData->newpkg)))
                                                fprintf( addpkgfl "! %s " upperCase(_INEPackData->devfile))
                                                if( _INEPackData->cmpval == "" && _INEPackData->cmptol != "" then
                                                        fprintf( addpkgfl "!"))
                                                unless( _INEPackData->cmpval == "" fprintf( addpkgfl "! %s "
                                                        _INEPackData->cmpval ))
                                                unless( _INEPackData->cmptol == "" fprintf( addpkgfl "! %s "
                                                        _INEPackData->cmptol))
                                                fprintf( addpkgfl "; %s \n" upperCase(_INEPackData->newrefdes))
                                        );endif
                                );endunless
                        );endif
                
                
                else
                        axlMsgPut(" No File Exists For Specified Device!")
                        good = nil
                );endif
        
 
        else
                axlFormRestoreField( _INESFormPtr "newrefdes")
                axlMsgPut(" Reference Designator Already Exists")
                foundone = nil
        );endif
 
); end-prog
); end_defun
;-------------------------------This is the Done function -----------------------
; this funtion will complete the inputed data , close the netin file then
;execute the netin process.
;---------------------------------------------------------------------------------
defun( _INEMk_Add_Pack_Done ()
prog( ()
        unless( (_INEPackData->newrefdes == "" || member( upperCase(_INEPackData->newrefdes) newdeslist))
                _INEMk_Add_Pack_File()
        );endunless
        when( isFile("ia_net_edit_tmp_in_file.txt")
                fprintf( addpkgfl "\n$END\n")
                close( addpkgfl )
                _INEDelNetIn()
        );endwhen
        axlFormClose( _INESFormPtr )
        deleteFile("iane_add_package.form")
        _INEStart()
);endprog
);enddefun
;------------------------------ Add Comp Cancel ---------------------------------
; This function will close the add comp file if open, delete the file from disk
; and cancel out of the program
;---------------------------------------------------------------------------------
defun( _INEACancel ()
prog( ()
        when( isFile("ia_net_edit_tmp_in_file.txt")
                close( addpkgfl )
                deleteFile("ia_net_edit_tmp_in_file.txt")
        );
        _INECancel()
);endprog
);enddefun
;========================This is the Start Form File =============================
;========================This is the Start Form File =============================
defun( _INEMakeFormFile ()
        frmfle = outfile("iane_start_up.form")
        fprintf( frmfle "FILE_TYPE=FORM_DEFN VERSION=2\nFORM\nFIXED\nPORT 45 14\nHEADER \"Interactive Net List Editor Form\"\n")
        fprintf( frmfle "TILE\n")
        fprintf( frmfle "GROUP \"Edit Net\"\nGLOC 2 2\nGSIZE 20 12\nENDGROUP\n")
        fprintf( frmfle "GROUP \"Edit Pin Net\"\nGLOC 22 2\nGSIZE 20 12\nENDGROUP\n")
        fprintf( frmfle "GROUP \"Edit Net Packages\"\nGLOC 2 15\nGSIZE 40 6\nENDGROUP\n")
        fprintf( frmfle "FIELD addnet\nFLOC 5 5\nFGROUP \"Edit Net\"\nMENUBUTTON \"Add\" 11 3\nENDFIELD\n")
        fprintf( frmfle "FIELD delnet\nFLOC 5 8\nFGROUP \"Edit Net\"\nMENUBUTTON \"Delete\" 11 3\nENDFIELD\n")
        ;fprintf( frmfle "FIELD adone\nFLOC 5 11\nFGROUP \"Edit Net\"\nMENUBUTTON \"Done\" 11 3\nENDFIELD\n")
        fprintf( frmfle "FIELD addpin\nFLOC 25 5\nFGROUP \"Edit Pin Net\"\nMENUBUTTON \"Add\" 11 3\nENDFIELD\n")
        fprintf( frmfle "FIELD delpin\nFLOC 25 8\nFGROUP \"Edit Pin Net\"\nMENUBUTTON \"Delete\" 11 3\nENDFIELD\n")
        fprintf( frmfle "FIELD chgpin\nFLOC 25 11\nFGROUP \"Edit Pin Net\"\nMENUBUTTON \"Change\" 11 3\nENDFIELD\n")
        fprintf( frmfle "FIELD addpkg\nFLOC 5 18\nFGROUP \"Edit Net Packages\"\nMENUBUTTON \"Add\" 11 3\nENDFIELD\n")
        fprintf( frmfle "FIELD delpkg\nFLOC 25 18\nFGROUP \"Edit Net Packages\"\nMENUBUTTON \"Delete\" 11 3\nENDFIELD\n")
        fprintf( frmfle "FIELD adone\nFLOC 5 23\nMENUBUTTON \"Done\" 11 3\nENDFIELD\n")
        fprintf( frmfle "FIELD adone\nFLOC 25 23\nMENUBUTTON \"Cancel\" 11 3\nENDFIELD\n")
        fprintf( frmfle "ENDTILE\n")
        fprintf( frmfle "ENDFORM\n")
        close( frmfle)
);enddefun
;========================This is the Package Form File ===========================
defun( _INEMakePackFormFile ()
        pkgfrmfle = outfile("iane_add_package.form")
        fprintf( pkgfrmfle "FILE_TYPE=FORM_DEFN VERSION=2\nFORM\nFIXED\nPORT 45 16\nHEADER \"Add Package Form\"\n")
        fprintf( pkgfrmfle "POPUP <PRINTP>\"to File\"\"0\",\"to Printer\"\"1\",\"to Script\"\"2\".\n\n")
        fprintf( pkgfrmfle "TILE\n\n")
        fprintf( pkgfrmfle "GROUP \"Required Data\"\nGLOC 2 2\nGSIZE 40 10\nENDGROUP\n\n")
        fprintf( pkgfrmfle "GROUP \"Optional Data\"\nGLOC 2 13\nGSIZE 40 13\nENDGROUP\n\n")
        fprintf( pkgfrmfle "TEXT \"Reference Designator:\"\nFGROUP \"Required Data\"\nTLOC 3 5\nENDTEXT\n\n")
        fprintf( pkgfrmfle "FIELD newrefdes\nFLOC 25 5\nFGROUP \"Required Data\"\nSTRFILLIN 12 16\nENDFIELD\n\n")
        fprintf( pkgfrmfle "TEXT \"Device File:\"\nFGROUP \"Required Data\"\nTLOC 3 8\nENDTEXT\n\n")
        fprintf( pkgfrmfle "FIELD devfile\nFLOC 16 8\nFGROUP \"Required Data\"\nSTRFILLIN 21 32\nENDFIELD\n\n")
        fprintf( pkgfrmfle "TEXT \"Package Type:\"\nFGROUP \"Optional Data\"\nTLOC 3 16\nENDTEXT\n\n")
        fprintf( pkgfrmfle "FIELD newpkg\nFLOC 17 16\nFGROUP \"Optional Data\"\nSTRFILLIN 20 32\nENDFIELD\n\n")
        fprintf( pkgfrmfle "TEXT \"Component Value:\"\nFGROUP \"Optional Data\"\nTLOC 3 19\nENDTEXT\n\n")
        fprintf( pkgfrmfle "FIELD cmpval\nFLOC 20 19\nFGROUP \"Optional Data\"\nSTRFILLIN 17 32\nENDFIELD\n\n")
        fprintf( pkgfrmfle "TEXT \"Component Tolerance:\"\nFGROUP \"Optional Data\"\nTLOC 3 22\nENDTEXT\n\n")
        fprintf( pkgfrmfle "FIELD cmptol\nFLOC 24 22\nFGROUP \"Optional Data\"\nSTRFILLIN 13 32\nENDFIELD\n\n")
        fprintf( pkgfrmfle "FIELD nextone\nFLOC 2 28\nMENUBUTTON \"Next\" 8 3\nENDFIELD\n\n")
        fprintf( pkgfrmfle "FIELD done\nFLOC 12 28\nMENUBUTTON \"Done\" 8 3\nENDFIELD\n\n")
        fprintf( pkgfrmfle "FIELD print\nFLOC 22 28\nMENUBUTTON \"Print\" 10 3\nPOP \"PRINTP\"\nENDFIELD\n\n")
        fprintf( pkgfrmfle "FIELD cancel\nFLOC 34 28\nMENUBUTTON \"Cancel\" 8 3\nENDFIELD\n\n")
        fprintf( pkgfrmfle "ENDTILE\n\nENDFORM\n")
        close( pkgfrmfle )
);enddef



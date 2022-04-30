;~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
;
;                   DEVICE FILE CREATOR
;
;                       Version: 2.1
;
;  History: Version 1.0, separate code and form files. 3/14/96
;           Version 2.0, build form inside SKILL code. 3/15/96
;           Version 2.1, fix code to write device file to current
;                        working directory.            7/10/96
;           Version 2.2  in the AddPins() function the dbid has
;                        to be queryed be for an element can be
;                        printed.                      8/26/96
;
;                    Date: July 10, 1996
;
;
;  This program was originally written for Cadence Allegro ver 10.0.
;  It has been update for Cadence Allegro ver 11.5.
;
;                Written By: Marcus V. Johnson
;
;                    Jabil Circuit Inc.
;                   1700 Atlantic Blvd.
;                 PHONE (810) 391-5300 x224
;                    FAX (810) 391-5321
;          
;               E-MAIL: marcus_johnson@jabil.com
;
;     This SKILL program was designed to create quick and simple device
;     files for use with "Third Party" netlist implementations.
;
;     This utility is to be used with the allegro_symbol editor only.
;
;     Implementation instructions:
;     Add load("mkdev.il") to the allegro_symbol.ilinit file.
;     Or, type load("mkdev.il") directly from the skill> prompt.
;
;     type: "make device" from the allegro> prompt to invoke the command.
;
;     The form associated with this program displays:
;
;     Symbol Name: <drawingfile>
;
;     Class: <IC, IO, DISCRETE>
;
;     Value: Input from this field is also used as the filename of the
;            output device file. Therefore, there can be NO spaces or
;            illegal filename characters entered in this field (unex-
;            pected results may occur).
;
;     Pincount: Displays to total number of pins in the symbol drawing.
;
;     WARRANTY: NONE!
;
;     THIS PROGRAM IS PROVIDED WITH NO WARRANTIES OR GUARANTEES, EITHER
;     EXPRESSED, WRITTEN, OR IMPLIED. THE AUTHOR OF THIS PROGRAM AND/OR
;     ANY ASSOCIATE AFFILIATES ACCEPT NO RESPONSIBILITY AND/OR LIABILITY
;     RESULTING FROM THE USE OF THIS UTILITY.
;
;~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
;
;
axlCmdRegister("make device" `DEV_Start)
;
;~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
;
; Start the program. Set default fields. Extract all pins from symbol.
;
;~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
defun( DEV_Start ()

    devform = "./device.form"
    devBuildForm()
    (axlClearSelSet)
    (axlSetFindFilter ?enabled (list "noall" "PINS" "invisible") 
                      ?onButtons (list "noall" "PINS"))
    (axlAddSelectAll)
    sprintf( x "%d" (axlGetSelSetCount))

    form = axlFormCreate( (gensym) "device.form" `("e" "outer") `DEV_CallBack t)
    axlFormDisplay(form)

    prt_name = (axlCurrentDesign)
    pkg_name = (upperCase prt_name)

    axlFormSetInfo(form "pin_count" x)
    axlFormSetInfo(form "sym_name" pkg_name)
    axlFormSetField(form "value" prt_name)
    axlFormSetField(form "class" "IC")
    axlFormTitle(form sprintf(nil "Device File: %s" pkg_name))

    dev_pins = (reverse (axlGetSelSet))

);end-defun

;~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
;
; CallBack Activities for the GUI form
;
;~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
defun( DEV_CallBack (form)

        class_value = axlFormGetField(form "class")
        dev_value = axlFormGetField(form "value")
        axlFormTitle(form sprintf(nil "Device File: %s" dev_value))
        axlFormSetInfo(form "err_message" "")

    case(form->curField
   
    ("help"
        GetHelpFile()
        println("Help option...")
    );end-help

    ("value"
        unless(nindex(dev_value " ") == nil
            axlFormSetInfo(form "err_message" "- ERROR in Value -")
        );end-unless
    );end-value

    ("dev_create"
        GetDeviceFile()
    );end-dev_create

    ("cancel"
        axlFormClose(form)
        (if (isFile devform) then (deleteFile devform))
        t
    );end-cancel

    );end-case
);end-defun

;~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
;
; Create the Device file
;
;~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
defun( GetDeviceFile ()

DevFile = outfile(strcat("./" strcat(dev_value ".txt")))

fprintf(DevFile "(DEVICE FILE: %s)\n" upperCase(dev_value))
fprintf(DevFile "\nPACKAGE %s" upperCase(prt_name))
fprintf(DevFile "\nCLASS %s" class_value)
fprintf(DevFile "\nPINCOUNT %d\n\n" axlGetSelSetCount())

fprintf(DevFile "PINORDER %s" upperCase(prt_name))

AddPins()

fprintf(DevFile "\n\nFUNCTION G1 %s" upperCase(prt_name))

AddPins()

fprintf(DevFile "\n\nEND\n")

axlUIWPrint(form "%s created..." strcat(dev_value ".txt"))
close(DevFile)
axlUIViewFileCreate(strcat("./" strcat(dev_value ".txt"))  strcat(dev_value ".txt")  nil)
);end-defun

;~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
;
; Format the Pin names/numbers in the device file
;
;~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
defun( AddPins ()  
    format_count = 0 
  
    foreach( p dev_pins format_count++ 
        if(mod(format_count 13) != 0 
            then 
                p->??
                fprintf(DevFile " %s" p->number) 
            else 
                p->??
                fprintf(DevFile " %s,\n          " p->number) 
        );end-if 
    );end-foreach 
);end-defun  

;~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
;
; Create the file "devices.hlp" to display when the help button is pushed
;
;~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
defun( GetHelpFile ()

helpfile = outfile("devices.hlp")
fprintf(helpfile "                   DEVICE FILE CREATOR\n\n")
fprintf(helpfile "                       Version: 2.0\n\n")
fprintf(helpfile "                    Date: March 15, 1996\n\n")
fprintf(helpfile "                Written By: Marcus V. Johnson\n\n")
fprintf(helpfile "                    Jabil Circuit Inc.\n")
fprintf(helpfile "                   1700 Atlantic Blvd.\n")
fprintf(helpfile "                 PHONE (810) 391-5300 x224\n")
fprintf(helpfile "                    FAX (810) 391-5321\n")
fprintf(helpfile "               E-MAIL: marcus_johnson@jabil.com\n\n")
fprintf(helpfile "command: \"make device\"\n\n")
fprintf(helpfile "This SKILL program was designed to create quick and simple device\n")
fprintf(helpfile "files for use with \"Third Party\" netlist implementations.\n\n")
fprintf(helpfile "The form associated with this program displays:\n\n")
fprintf(helpfile "Symbol Name: <drawingfile>\n\n")
fprintf(helpfile "Class: <IC, IO, DISCRETE>\n\n")
fprintf(helpfile "Value: Input from this field is also used as the filename of the\n")
fprintf(helpfile "       output device file. Therefore, there can be NO spaces or\n")
fprintf(helpfile "       illegal filename characters entered in this field (unex-\n")
fprintf(helpfile "       pected results may occur).\n\n")
fprintf(helpfile "Pincount: Displays to total number of pins in the symbol drawing.\n\n")
fprintf(helpfile "WARRANTY: NONE\n\n")
fprintf(helpfile "THIS PROGRAM PROVIDES NO WARRANTIES OR GUARANTEES EITHER EXPRESSED,\n")
fprintf(helpfile "WRITTEN OR IMPLIED. THE AUTHOR AND/OR HIS AFFILIATES ACCEPT NO RE-\n")
fprintf(helpfile "SPONSIBILITY, AND/OR LIABILITY RESULTING FROM THE USE OF THIS UTILITY.\n")

close(helpfile)

axlUIViewFileCreate("devices.hlp" "HELP READ ME" t (72:35))

);end-defun

defun( devBuildForm ()

    deleteFile(devform)
    FORMFILE = outfile(devform)

    fprintf(FORMFILE "FILE_TYPE=FORM_DEFN VERSION=2\n")
    fprintf(FORMFILE "FORM\n")
    fprintf(FORMFILE "FIXED\n")
    fprintf(FORMFILE "PORT 35 10\n")
    fprintf(FORMFILE "HEADER \"DEVICE FILE\"\n")
    fprintf(FORMFILE "\n")
    fprintf(FORMFILE "POPUP <class_pop>\"DISCRETE\"\"DISCRETE\",\"IO\"\"IO\",\"IC\"\"IC\".\n")
    fprintf(FORMFILE "\n")
    fprintf(FORMFILE "\n")
    fprintf(FORMFILE "TILE\n")
    fprintf(FORMFILE "TEXT\n")
    fprintf(FORMFILE "TLOC 8 1\n")
    fprintf(FORMFILE "INFO err_message 20\n")
    fprintf(FORMFILE "ENDTEXT\n")
    fprintf(FORMFILE "\n")
    fprintf(FORMFILE "TEXT \"Symbol Name:\"\n")
    fprintf(FORMFILE "TLOC 1 4\n")
    fprintf(FORMFILE "ENDTEXT\n")
    fprintf(FORMFILE "\n")
    fprintf(FORMFILE "TEXT\n")
    fprintf(FORMFILE "TLOC 14 4\n")
    fprintf(FORMFILE "INFO sym_name 20\n")
    fprintf(FORMFILE "ENDTEXT\n")
    fprintf(FORMFILE "\n")
    fprintf(FORMFILE "TEXT \"Class:\"\n")
    fprintf(FORMFILE "TLOC 1 7\n")
    fprintf(FORMFILE "ENDTEXT\n")
    fprintf(FORMFILE "\n")
    fprintf(FORMFILE "TEXT \"Value:\"\n")
    fprintf(FORMFILE "TLOC 1 10\n")
    fprintf(FORMFILE "ENDTEXT\n")
    fprintf(FORMFILE "\n")
    fprintf(FORMFILE "TEXT \"Pincount:\"\n")
    fprintf(FORMFILE "TLOC 1 13\n")
    fprintf(FORMFILE "ENDTEXT\n")
    fprintf(FORMFILE "\n")
    fprintf(FORMFILE "TEXT\n")
    fprintf(FORMFILE "TLOC 11 13\n")
    fprintf(FORMFILE "INFO pin_count 5\n")
    fprintf(FORMFILE "ENDTEXT\n")
    fprintf(FORMFILE "\n")
    fprintf(FORMFILE "FIELD help\n")
    fprintf(FORMFILE "FLOC 1 1\n")
    fprintf(FORMFILE "MENUBUTTON \"?\" 3 2\n")
    fprintf(FORMFILE "ENDFIELD\n")
    fprintf(FORMFILE "\n")
    fprintf(FORMFILE "FIELD class\n")
    fprintf(FORMFILE "FLOC 11 7\n")
    fprintf(FORMFILE "ENUMSET 12\n")
    fprintf(FORMFILE "POP \"class_pop\"\n")
    fprintf(FORMFILE "ENDFIELD\n")
    fprintf(FORMFILE "\n")
    fprintf(FORMFILE "FIELD value\n")
    fprintf(FORMFILE "FLOC 11 10\n")
    fprintf(FORMFILE "STRFILLIN 10 25\n")
    fprintf(FORMFILE "ENDFIELD\n")
    fprintf(FORMFILE "\n")
    fprintf(FORMFILE "FIELD dev_create\n")
    fprintf(FORMFILE "FLOC 1 16\n")
    fprintf(FORMFILE "MENUBUTTON \"Make Device\" 13 3\n")
    fprintf(FORMFILE "ENDFIELD\n")
    fprintf(FORMFILE "\n")
    fprintf(FORMFILE "FIELD cancel\n")
    fprintf(FORMFILE "FLOC 19 16\n")
    fprintf(FORMFILE "MENUBUTTON \"Cancel\" 13 3\n")
    fprintf(FORMFILE "ENDFIELD\n")
    fprintf(FORMFILE "\n")
    fprintf(FORMFILE "ENDTILE\n")
    fprintf(FORMFILE "\n")
    fprintf(FORMFILE "ENDFORM\n")

    close(FORMFILE)
);end-devBuildForm

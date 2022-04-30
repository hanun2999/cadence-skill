;------------------ Cut Here and save to file name, runalgrplt.il ------------
;###########################################################################
;#                                                                         #
;#                      Comment Section                                    #
;#                                                                         #
;###########################################################################
;
;  Author:  Larry Bowman - Technical Services
;   Email:  bowman@cadence.com
; Product:  Allegro
; Version:  11.0
;    Date:  January 8, 1996

; DESCRIPTION:
; ------------
; This program will create an Allegro Plot in one command step.
;
; The semicolon (;) at the beginning of each line is the Skill
; program's delimiter for recognizing that the line is a comment
; and not part of the program.
;
; This program is expected to have a xxx.plt and xxx.ctl file
; already created from the Allegro Create Plot command
; (create plot xxx).  This can be accomplished by manually
; creating the the xxx.plt and xxx.ctl files with the 
; Cr Plot menu pick from the <artwork> menu and filling in
; xxx when prompted for the Plot File name.
;
; This may also be accomplished in one step by modifying
; the process.menu file as follows:
;
;-------------- Start of new process.menu ------------------------
;FILE_TYPE= MENU_DEFN.
;
;{ Modified to have a Plot command create the .plt and .ctl files}
;{ and bring up allegro_plot with one menu selection.}
;{ **************************************************************}
;{    CADENCE -- ALLEGRO MENU FILE -- PROCESS  }
;{ $Header: process.menu,v 1.29.1.1 95/06/28 11:55:36 rsf $ }
;{ **************************************************************}
;dimensions (2,3).
;
;assign_popup <edit> \
;	"Padedit"	"padedit", \
;	"Geometry"	"pgeometry", \
;        "Constraints"   "pcns", \
;	"Place"		"pedplace", \
;	"Etch"		"pedetch", \
;	"Shape"		"pshape", \
;        "Split Plane" "menuload split_plane", \
;	"Draft"		"pdraft" .
;
;assign_popup <thirdparty> \
;        "Netin"		"pnetin", \
;        "Assign"	"passign", \
;        "BackAnnotation"	"pbkannot".
;
;assign_popup <logic> \
;	"3rdParty"     <thirdparty> "", \
;	"Rename"	"prename" .
;
;assign_popup <auto> \
;	"Place"		"pedplace", \
;	"AutoPlace"	"pautoplace", \
;	"Swap"		"pswap", \
;        "Prevail"    "prevail", \
;	"AutoRoute"	"pautoroute", \
;	"Etch"		"pedetch", \
;	"Gloss"		"pgloss" .
;
;assign_popup <analyze> \
;	"Evaluate"	"pevaluate", \
;	"Ecl"		"pecl", \
;	"Thermal"	"pthermal", \
;	"Signal"	"psignal" , \
;        "EMC"           "menuload emc".
;
;assign_popup <mfg> \
;	"Design for Assembly"	"pdfa", \
;	"Testprep"	"ptestprep", \
;	"Silkscreen"	"psilkscreen", \
;	"NcDrill"	"pncdrill", \
;	"Artwork"	"partwork".
;
;assign_popup <demo> \
;	"Prevail"	"run spviewer -s -a15 -f $global/router_demo.avx".
;
;{-----------------------------------------------------}
;
;assign_popup <config> \
;	"Shell"		"shell", \
;	"Palette"	"palette", \
;	"Sysinfo"	"sysinfo", \
;	"Resource"	"resource", \
;	"Images"	"images".
;
;assign_popup <design> \
;	"Plot (Allegro_plot)"	"create plot xxx;runalgrplt", \ {<-- This line was added.}
;	"Edit"		<edit>		"", \
;	"Logic"		<logic>		"", \
;	"Auto"		<auto>		"", \
;	"Analyze"	<analyze>	"", \
;	"Mfg"		<mfg>		"", \
;	"Viewlog"       "viewlog", \
;	"Config"	<config>	"", \
;	"Help"		"help" .
;
;{-----------------------------------------------------}
;{ MENU DEFINITION }
;assign_box (1,1) 13_BOX "Process"	<design>	"".
;assign_box (2,1) 13_BOX "Ministat"	"ministat".
;
;end.
;----------- End of process.menu ------------------------------
;
; The above process.menu may be located in any directory
; structure as long as the Allegro environment variable,
; MENUPATH, includes this directory path as part of its
; value.
;
; This Allegro Skill program may be loaded automatically
; when Allegro is invoked by creating an allegro.ilinit
; file in the user's pcbenv directory (i.e., ~/pcbenv/allegro.ilinit).
;
; The allegro.ilinit file could look like the following:

;----------- Start of allegro.ilinit file -----------------------------
;setSkillPath(". ~/scripts/SKILL.sav /cds/9502/ibm/tools/pcb/etc/skill")
;load("runalgrplt.il")
;----------- End of allegro.ilinit file --------------------------------

; Where the file, runalgrplt.il, is located in one of the directory paths
; as defined by the setSkillPath function.

; Note:  if you ever change the Allegro Skill path with the setSkillPath
;        function as noted above, ALWAYS be sure to include the period(.),
;        which is the current working directory, as part of the search path
;        definition.  There are some Allegro commands that expect to see the
;        current working directory as part of the search path and will fail
;        if it is not part of the search path.
;     
;        Also, most of the Skill functions that do file access will use the
;        setSkillPath value as the directory paths to perform their file
;        reads and writes.
;
; At the end of this program, it will remove the xxx.plt and xxx.ctl files
; that were created by the Allegro "Create Plot" command.
;
; To run this program in the Allegro editor at the command line, you would
; type in the following:
;                       Allegro>  create plot xxx; runalgrplt
;
; To be able to run this program from a menu pick, modify the process.menu
; file as noted above and just select the Process-> "Plot (Allegro_plot)" 
; from the Process menu.
; 
; The line:
; parampath = "allegro_plot_defaults.txt"
; in the program below will need to be modified for your system's set-up.
;
; The allegro_plot_defaults.txt file must be created by the user.  This
; is just a copy of the "allegro_plot_param.txt" file that usually is
; created by the allegro_plot program.  Thus you would bring up allegro_plot
; and set up the Options as you would like to have them as a default and
; then enter in the "Parameter File:" field, the complete rooted file name 
; for the "allegro_plot_defaults.txt" file name.
; Then select the "Save" button to create the allegro_plot_defaults.txt file.

; This would then be the file path name that you would change for the
; parampath variable below.
;
;###########################################################################
;#                                                                         #
;#                      End Of Comment Section                             #
;#                                                                         #
;###########################################################################
;
;###########################################################################
;#                                                                         #
;#                      Main Program - runalgrplt                          #
;#                                                                         #
;###########################################################################
axlCmdRegister("runalgrplt" 'RunAlgrPlt)

(defun RunAlgrPlt ()
  (prog ()

   ; set error log file name
   errlog = "error.log"

   ; get current directory
     curdir = getWorkingDir()

   ; build path to xxx.plt and xxx.ctl files
     pltfile = buildString( cons(curdir '("xxx.plt")) "/")
     ctlfile = buildString( cons(curdir '("xxx.ctl")) "/")

   ; ########################################################################
   ; The parampath below needs to be modified to match your system's directory
   ; structure.
   ; ########################################################################
   parampath = "allegro_plot_defaults.txt"
   
   plotcmd = strcat("run allegro_plot -p " parampath " -m xxx.plt")

   ; Check to see if parampath exists.
   if( isFile(parampath)
     then
     else
       if( isFile(pltfile)
         then
           deleteFile(pltfile)
           deleteFile(ctlfile)
       ); endif

      logfile = axlDMOpenLog(errlog)
      fprintf(logfile "\n")
      fprintf(logfile "**************************************************\n")
      fprintf(logfile "**                                              **\n")
      fprintf(logfile "** Error, Missing allegro_plot parameters.      **\n")
      fprintf(logfile "**   Modify the parampath variable in the       **\n")
      fprintf(logfile "**   runalgrplt.il file.                        **\n")
      fprintf(logfile "**                                              **\n")
      fprintf(logfile "** You can create the allegro_plot parameters   **\n")
      fprintf(logfile "** by entering the complete path name in the    **\n")
      fprintf(logfile "** Allegro_plot form for the \"Parameter File:\"  **\n")
      fprintf(logfile "** entry and then select the \"Save\" button      **\n")
      fprintf(logfile "** to create the file.  You would then need to  **\n")
      fprintf(logfile "** modify the parampath variable with this path **\n")
      fprintf(logfile "** name.                                        **\n")
      fprintf(logfile "**                                              **\n")
      fprintf(logfile "**************************************************\n")
      axlDMClose(logfile)
      axlUIViewFileCreate(errlog "Error Log" t '(60 15) )
      return()
   ); endif



   ; check if .plt file exist and then run allegro_plot
     if( isFile(pltfile) 
        then axlShell(plotcmd) 
        else
            printf("** Error, Missing xxx.plt file         **\n")
            printf("**   Run:  create plot xxx; runalgrplt **\n")
            return()
     ) ; endif

   ; remove the xxx.plt and xxx.ctl files - this will not occur
   ; until the allegro_plot graphic form is DONE by the user
     deleteFile(pltfile)
     deleteFile(ctlfile)

    print("FINISHED . . .")
  
  ); end prog
); end defun
;###########################################################################
;#                                                                         #
;#                      End Of Main Program - runalgrplt                   #
;#                                                                         #
;###########################################################################

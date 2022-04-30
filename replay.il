
/*******************************************************************************
 *                                                                             *
 *       +---_-----------+   Copyright (c) 1999                                *
 *       | c a d e n c e |   Cadence Design Systems Ltd.                       *
 *       +---------------+                                                     *
 *                           All Rights Reserved                               *
 *                                                                             *
 ******************************************************************************/
;This code is unsupported.
 
/*******************************************************************************
 *
 * Filename: replay.il
 * Version: @(#)replay.il	1.2 02/12/99
 * Author: Danny Nelhams
 * Originator: Philips Medical
 * Update: Jos van Gemert	1.3 11/11/2002
 *		Removed double local_scriptpath
 *
 * Creates AllegroForm to allow selection of specific allegro scripts to be run.
 *
 ******************************************************************************/

;-------------------------------------------------------
; Create a ALLEGRO Command and registers it. The rest of
; this SKILL code is a funtion which gets executed when
; the command 'runscript' is invoked.
; Requires the environment variable local_scriptpath to 
; be set to the path where the scripts are stored.
;-------------------------------------------------------

axlCmdRegister("runscript" 'pmCreateScriptForm);

/*******************************************************************************
 *
 * pmCreateScriptForm()
 *
 * Top level function called from registered ALLEGRO command
 *
 ******************************************************************************/

putd('pmCreateScriptForm nil)
(defun pmCreateScriptForm ()

    let( (ScriptForm)

        /*******************************************************************************
         * 
         * pmCreateformDefinitionFile()
         * => t/nil
         *
         * Create a Allegro form definition file for loading script files. 
         *
         ******************************************************************************/

        putd('pmCreateformDefinitionFile nil)
        (defun pmCreateformDefinitionFile ()
 
            let( (formDefinitionFile)

            ;-------------------------------------------------------
            ; Create a temporary form definition file for the replay 
            ; script files selection. 
            ; NOTE we write to CWD else we might write the file 
            ; to another directory in our Skill Path by mistake !!
            ;-------------------------------------------------------

                formDefinitionFile = outfile("./replay.form" "w") 
    
            ;------------------------------------------------------- 
            ; Create form fields and write to form definition file
            ; only if file is writable.
            ;------------------------------------------------------- 

                when( formDefinitionFile 
                    fprintf(formDefinitionFile "FILE_TYPE=FORM_DEFN VERSION=2\n")
                    fprintf(formDefinitionFile "FORM\n")
                    fprintf(formDefinitionFile "FIXED\n")
                    fprintf(formDefinitionFile "PORT 47 8\n")
                    fprintf(formDefinitionFile "HEADER \"Replay Script-Files V 1.0\"\n")
                    fprintf(formDefinitionFile "TILE\n")
                    fprintf(formDefinitionFile "TEXT \"Script (.scr)\"\n")
                    fprintf(formDefinitionFile "TLOC 2 1\n")
                    fprintf(formDefinitionFile "ENDTEXT\n")
                    fprintf(formDefinitionFile "FIELD ScrList\n")
                    fprintf(formDefinitionFile "FLOC 2 3\n")
                    fprintf(formDefinitionFile "LIST \"\" 40 5\n")
                    fprintf(formDefinitionFile "ENDFIELD\n")
                    fprintf(formDefinitionFile "FIELD close\n")
                    fprintf(formDefinitionFile "FLOC 2 13\n")
                    fprintf(formDefinitionFile "MENUBUTTON \"Close\" 10 3\n")
                    fprintf(formDefinitionFile "ENDFIELD\n")
                    fprintf(formDefinitionFile "ENDTILE\n")
                    fprintf(formDefinitionFile "ENDFORM\n")
                    close(formDefinitionFile)
                ); when
            ); let
        ); defun pmCreateformDefinitionFile

        /*******************************************************************************
         *
         * pmGetListOfScriptFiles()
         * => list of scripts/nil
         * 
         * Search through the local_scriptpath and get a list of all the scripts
         * so we can return this list to display in the form
         *
         ******************************************************************************/

        putd('pmGetListOfScriptFiles nil)
        (defun pmGetListOfScriptFiles ( srcdir extension )
            let( (scripts)
                foreach( directory srcdir
                    if((isDir directory) then
                        scripts = append(scripts setof(x (getDirFiles directory) 
                            (rexMatchp strcat(extension "$") x)))
                    ); endif
                ); foreach
                scripts
             ); let
         ); defun pmGetListOfScriptFiles

         /*******************************************************************************
         *
         * pmAddScriptsToForm()
         *
         * If any scripts were found add the list of the scripts to the form.
         * If none were found then add a label to indicate this.
         *
         *******************************************************************************/

         putd('pmAddScriptsToForm nil)
         (defun pmAddScriptsToForm (scripts)
     
             if(zerop(scripts) then
                 axlFormSetField(ScriptForm "ScrList" "No Script-Files Found")
             else
                 foreach(script scripts
                     axlFormSetField(ScriptForm "ScrList" script)
                 ); foreach
             );if

         ); defun pmAddScriptsToForm 
 
        /*******************************************************************************
         *
         * pmCreateFormCallback()
         * => t/nil
         *
         * Create a call back to execute the currently selected script in the form.
         * If NO scripts were found in the Search Path, then write this info to the form.
         *
         ******************************************************************************/

        putd('pmCreateFormCallback nil)
        (defun pmCreateFormCallback (Form)

            let( (scriptname scriptpath scriptcmd)

                (case Form->curField
            
                    ("ScrList"
                        if( Form->curValue != "No Script-Files Found" then
                            axlUIWPrint(Form "Playing Scriptfile  : %s" Form->curValue)
                            scriptname = Form->curValue
                            scriptpath = pmGetScriptLocation( pmGetScriptPath() scriptname)
                            scriptcmd = sprintf(nil "replay %s/%s" scriptpath scriptname)
                            axlShell(scriptcmd)
                            t
                        else
                            axlUIWPrint(Form "No Script files Found.")
                        ); endif
                    ); end ScrList
 
                    ("close"
                        if(axlOKToProceed() then
                            (axlFormClose Form)
                        ); endif
                    ); end close
                ); end case
            ); let

        ); defun pmCreateFormCallback

        /*******************************************************************************
         *
         * pmGetScriptPath()
         *
         * Return the ALLEGRO script search order path
         *
         ******************************************************************************/

         putd('pmGetScriptPath nil)
         (defun pmGetScriptPath ()
 
             let( (local_scriptpath)
 
             ;-------------------------------------------------------
             ; Get the local ALLEGRO script path. This has to set as
             ; a ALLEGRO environment variable by the user.
             ;-------------------------------------------------------
 
                 if(axlGetVariable("local_scriptpath") then
                     local_scriptpath = parseString(axlGetVariable("local_scriptpath"))
                 else
                     error("Allegro Environment Variable local_scriptpath NOT defined")
                 ); if
 
            ); let
 
        ); defun pmGetScriptPath

        /*******************************************************************************
         *
         * pmGetScriptLocation(searchpath script)
         *
         * Work out where to locate Allegro scripts from a supplied search path.
         # Once a script is located along the path stop searching and return
         # the location. If the script is not located on the search path then
         # return nil.
         #
         ******************************************************************************/

        putd('pmGetScriptLocation nil)
        (defun pmGetScriptLocation (searchpath script)
            let( (path)
                path = 'unbound
                foreach(dir searchpath
                    when(isDir(dir)
                        if( car(setof(x getDirFiles(dir) (rexMatchp script x))) == script then
                            ; take only first path found
                            unless(boundp('path) 
                                path = dir
                            ); unless
                        ); if
                    ); when
                ); foreach
                ;-------------------------------------------------------
                ; If we find the script then return the path, else 
                ; return nil
                ;-------------------------------------------------------
                if(boundp('path) then
                    path
                else
                    nil
                );if
            ); let
        ); defun pmGetScriptLocation


        /*******************************************************************************
         *
         * Main Program
         *
         ******************************************************************************/
 
        ;-------------------------------------------------------
        ; Make sure the CWD is set in the Skill Search Path to
        ; enable the Form to work correctly. If not set, add it
        ; to the path
        ;-------------------------------------------------------
 
        if( car(getSkillPath()) != "./" && car(getSkillPath()) != "." then
            axlUIWPrint(nil "** ERROR - Skill Path does not include the current working directory %s.%s **"
                "(" ")")
            axlUIWPrint(nil "** Setting Skill Path to include %s.%s - Please Correct! **" "(" ")")
            setSkillPath(cons("." getSkillPath()))
        ); endif
 
        ;-------------------------------------------------------
        ; Check if old form definition file is present. If found
        ; then remove it.
        ;-------------------------------------------------------
 
        if(isFile(strcat(car(getSkillPath()) "/replay.form")) then
            deleteFile(strcat(car(getSkillPath()) "/replay.form"))
        );endif
 
        ;-------------------------------------------------------
        ; Create the ALLEGRO form definition file
        ;-------------------------------------------------------
 
        unless( pmCreateformDefinitionFile()
            error("Could not create form definition file")
        ); unless
 
        ;-------------------------------------------------------
        ; Display the Replay Script form
        ;-------------------------------------------------------

        ScriptForm = axlFormCreate( (gensym) "replay.form" nil 'pmCreateFormCallback t)
        axlFormDisplay(ScriptForm)

        ;-------------------------------------------------------
        ; Traverse searchpath  and find all script files
        ;-------------------------------------------------------

        axlUIWPrint(nil "** Gathering scripts from %L, please wait. **" pmGetScriptPath() )
        pmAddScriptsToForm(pmGetListOfScriptFiles(pmGetScriptPath() ".scr"))
        axlUIWPrint(nil " - Done - " )

       ;-------------------------------------------------------
       ; Clean up temp files - remove the reply.form file
       ;-------------------------------------------------------

       if(isFile(strcat(car(getSkillPath()) "/replay.form")) then
            deleteFile(strcat(car(getSkillPath()) "/replay.form"))
       );endif

    ); let
); pmCreateScriptForm

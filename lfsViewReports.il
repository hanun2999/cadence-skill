; lfsViewReports.il - Copyright 1994 Loral Federal Systems Owego
;
; NO WARRANTY - This software is made available asis; and may not work
;  as advertised in all environment.
;
; This function will build a list of the report & log files in the
; current directory. User may select one of these, and browse them.
; User has choice of deleting or keeping file after viewing it.
; User menu's FORM is dynamically built in the /tmp directory & removed
; when completed.
; This function builds its form in the /tmp directory
;
;  Created by:    Joe Morrison   joe.morrison@lmco.com
;                 Loral Federal Systems-Owego
;
; This skill program demonstrates the following concepts:
;                 - File I/O
;                 - Asynchronous Forms & Callbacks
;                 - Generating a Directory Listing
;                 - Create a sublist of items matching search criteria
;                 - viewfile creation


(defun _viewr ()
   " Display Selected File in popup browser window "
    (if lfsdelfile=="Delete" then dodel=t else dodel=nil)
    (setq viewr (axlUIViewFileCreate selectedFile "Browser" dodel (80:13) ))
;    (axlUIWClose viewr)
); defun _viewr

(defun _repCallback (form)
   " Process User entries in popup menu"
    (case form->curField
        ("done"
            (axlFormClose form)
            (axlCancelEnterFun)
            (_viewr)
            (deleteFile lfsdelfileform)
            t)
        ("cancel"
            (axlFormClose form)
            (axlCancelEnterFun)
            (deleteFile lfsdelfileform)
            nil)
        ("view_file"
            (if form->curValue
                (progn
                   (axlFormSetField form "view_file" selectedFile)))
            t)
        ("file_list"
            (axlFormSetField form "view_file" form->curValue)
            (setq selectedFile (form->curValue))
            t)
        ("del_file"
            (if form->curValue
                (progn
                   (axlFormSetField form "del_file" form->curValue)))
                   (setq lfsdelfile  (form->curValue))
            t)
    ); case
); defun _repCallback

; build up the form dynamically
(defun _lfsBuildForm ()
"Build form for viewing reports & logs"
(deleteFile lfsdelfileform)
(setq FORMFILE (outfile lfsdelfileform))
(fprintf FORMFILE "FILE_TYPE=FORM_DEFN VERSION=2\n")
(fprintf FORMFILE "FORM\n")
(fprintf FORMFILE "FIXED\n")
(fprintf FORMFILE "PORT 50 10\n")
(fprintf FORMFILE "HEADER \"Browser\"\n")
(fprintf FORMFILE "\n")
(fprintf FORMFILE "POPUP <PRINTP>\"to File\"\"0\",\"to Printer\"\"1\",\"to Script\"\"2\".\n")
(fprintf FORMFILE "POPUP <DELFILE>\"Delete\"\"Delete\",\"Keep\"\"Keep\".\n")
(fprintf FORMFILE "\n")
(fprintf FORMFILE "TILE\n")
(fprintf FORMFILE "TEXT \"Select File to Browse\"\n")
(fprintf FORMFILE "TLOC 12 1\n")
(fprintf FORMFILE "ENDTEXT\n")
(fprintf FORMFILE "\n")
(fprintf FORMFILE "TEXT \"File:\"\n")
(fprintf FORMFILE "TLOC 1 12\n")
(fprintf FORMFILE "ENDTEXT\n")
(fprintf FORMFILE "\n")
(fprintf FORMFILE "FIELD view_file\n")
(fprintf FORMFILE "FLOC 12 12\n")
(fprintf FORMFILE "STRFILLIN 26 26\n")
(fprintf FORMFILE "ENDFIELD\n")
(fprintf FORMFILE "\n")
(fprintf FORMFILE "FIELD file_list\n")
(fprintf FORMFILE "FLOC 5 3\n")
(fprintf FORMFILE "LIST \"\" 40 5\n")
(fprintf FORMFILE "ENDFIELD\n")
(fprintf FORMFILE "\n")
(fprintf FORMFILE "TEXT \"File on Exit\"\n")
(fprintf FORMFILE "TLOC 1  14\n")
(fprintf FORMFILE "ENDTEXT\n")
(fprintf FORMFILE "\n")
(fprintf FORMFILE "FIELD del_file\n")
(fprintf FORMFILE "FLOC 14 14\n")
(fprintf FORMFILE "ENUMSET  6\n")
(fprintf FORMFILE "POP \"DELFILE\"\n")
(fprintf FORMFILE "ENDFIELD\n")
(fprintf FORMFILE "\n")
(fprintf FORMFILE "FIELD cancel\n")
(fprintf FORMFILE "FLOC 5 16\n")
(fprintf FORMFILE "MENUBUTTON \"Cancel\" 8 3\n")
(fprintf FORMFILE "ENDFIELD\n")
(fprintf FORMFILE "\n")
(fprintf FORMFILE "FIELD done\n")
(fprintf FORMFILE "FLOC 25 16\n")
(fprintf FORMFILE "MENUBUTTON \"Browse\" 9 3\n")
(fprintf FORMFILE "ENDFIELD\n")
(fprintf FORMFILE "\n")
(fprintf FORMFILE "ENDTILE\n")
(fprintf FORMFILE "\n")
(fprintf FORMFILE "ENDFORM\n")
(close FORMFILE)
) ; end _lfsBuildForm


; Create the extract form and function
(defun lfsViewReports ()
  "Display list of reports and logs & permit user to select one to be viewed"
    (setq lfsdelfileform "/tmp/report_view.form")
    (_lfsBuildForm)
    (setq lfsdelfile  "Keep")
    (setq fileList setof(x (getDirFiles  "./") (or (rexMatchp ".log$" x)
       (rexMatchp ".rpt$" x))))
    (setq form (axlFormCreate (gensym) lfsdelfileform
        `("E" "OUTER") `_repCallback t))
    (axlFormTitle form "Report & Log Browser")
    (axlFormSetField form "view_file" (car fileList))
    (setq selectedFile (car fileList))
    (axlFormSetField form "del_file" lfsdelfile)
    (foreach fileName fileList (axlFormSetField form "file_list" fileName))
    (axlFormDisplay form)
); defun myForm

; define viewrep as new Allegro command
(axlCmdRegister "viewrep" "lfsViewReports")


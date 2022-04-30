; jbhEditBoard.il 
;
; NO WARRANTY - This software is made available asis; and may not work
;  as advertised in all environment.
;
; This function will build a list of the board files in the
; current directory. User may select one of these, and edit it.
; User menu's FORM is dynamically built in the current directory & removed
; when completed.
;
;  Created by:    John Horner 
;		  Cadence Design
;                 email: horner@cadence.com
;	The majority of this code was borrowed from a program written 
;	by Joe Morrisson Loral Federal Systems
;
; This skill program demonstrates the following concepts:
;                 - File I/O
;                 - Asynchronous Forms & Callbacks
;                 - Generating a Directory Listing
;                 - Create a sublist of items matching search criteria
;                 - viewfile creation


; define editbrd as new Allegro command
(axlCmdRegister "editbrd" "jbhEditBoard")

(defun jbh_viewr ()
   " Edit Selected Board in popup browser window "
    (setq jbhviewr (axlOpenDesign ?design selectedFile ) )
;    (axlUIWClose jbhviewr)
); defun jbh_viewr

(defun jbh_repCallback (form)
   " Process User entries in popup menu"
    (case form->curField
        ("done"
            (axlFormClose form)
            (axlCancelEnterFun)
            (jbh_viewr)
            (deleteFile jbhdelfileform)
            t)
        ("cancel"
            (axlFormClose form)
            (axlCancelEnterFun)
            (deleteFile jbhdelfileform)
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
    ); case
); defun jbh_repCallback

; build up the form dynamically
(defun _jbhBuildForm ()
"Build form for viewing boards"
(deleteFile jbhdelfileform)
(setq FORMFILE (outfile jbhdelfileform))
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
(fprintf FORMFILE "TLOC 2 14\n")
(fprintf FORMFILE "ENDTEXT\n")
(fprintf FORMFILE "\n")
(fprintf FORMFILE "FIELD view_file\n")
(fprintf FORMFILE "FLOC 12 14\n")
(fprintf FORMFILE "STRFILLIN 26 26\n")
(fprintf FORMFILE "ENDFIELD\n")
(fprintf FORMFILE "\n")
(fprintf FORMFILE "FIELD file_list\n")
(fprintf FORMFILE "FLOC 5 3\n")
(fprintf FORMFILE "LIST \"\" 40 5\n")
(fprintf FORMFILE "ENDFIELD\n")
(fprintf FORMFILE "\n")
(fprintf FORMFILE "FIELD cancel\n")
(fprintf FORMFILE "FLOC 7 17\n")
(fprintf FORMFILE "MENUBUTTON \"Cancel\" 8 3\n")
(fprintf FORMFILE "ENDFIELD\n")
(fprintf FORMFILE "\n")
(fprintf FORMFILE "FIELD done\n")
(fprintf FORMFILE "FLOC 30 17\n")
(fprintf FORMFILE "MENUBUTTON \"Edit\" 9 3\n")
(fprintf FORMFILE "ENDFIELD\n")
(fprintf FORMFILE "\n")
(fprintf FORMFILE "ENDTILE\n")
(fprintf FORMFILE "\n")
(fprintf FORMFILE "ENDFORM\n")
(close FORMFILE)
) ; end _jbhBuildForm


; Create the extract form and function
(defun jbhEditBoard ()
  "Display list of boards & permit user to select one to be viewed"
    (setq jbhdelfileform "/tmp/editboard.form")
    (_jbhBuildForm)
    (setq jbhdelfile  "Keep")
    (setq fileList setof(x (getDirFiles  "./") (rexMatchp ".brd$" x)))
	printf( car(fileList))
    (setq form (axlFormCreate (gensym) jbhdelfileform
        `("E" "OUTER") `jbh_repCallback t))
    (axlFormTitle form "Board Browser")
    (axlFormSetField form "view_file" (car fileList))
    (setq selectedFile (car fileList))
    (axlFormSetField form "del_file" jbhdelfile)
    (foreach fileName fileList (axlFormSetField form "file_list" fileName))
    (axlFormDisplay form)
); defun myForm


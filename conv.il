;                     Conversion Utility
;                     ------------------

; This routine is a very simple conversion utility that will
; convert between mils and mm. Simply enter the value to be
; converted in the required box, and the conversion is done.

; The form can be displayed at the same time as other forms
; in Allegro, for example the 'Show Measure' form, so values
; can be typed in directly from one form to the other. 

; To run the utility type "conv" on the Allegro command line.

; -----------------------------------------------------------------

; Tested on Allegro 11.0

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
 
; -----------------------------------------------


 
(defun conv ()
 
mm = nil
mils = nil

; gets date and re-formats it
; ---------------------------

        time = getCurrentTime()
        time = parseString(time)
        day = nth(1 time)
        month = car(time)
        month = upperCase(month)
		year = nth(3 time)
        date = strcat(" Date: " day " " month " " year)

; calls form
; ----------

createconvform()
convertform()

); end of conv

; displays form
; -------------

(defun convertform ()
 
convform = axlFormCreate( (gensym) convform_file nil 'Conv_Action t)
axlFormDisplay(convform)
axlUIWPrint(convform date)
 
) ; end defun convertform 

; creates form
; ------------

(defun createconvform ()

drain()
convform_file = "conv.form"
convform = outfile(convform_file "w")
fprintf(convform "FILE_TYPE=FORM_DEFN VERSION=2\n")
fprintf(convform "FORM\n")
fprintf(convform "FIXED\n")
fprintf(convform "PORT 28 6\n")
fprintf(convform "HEADER \"Conversion Utility\"\n")
fprintf(convform "\n")

fprintf(convform "TILE\n")

fprintf(convform "FIELD mils\n")
fprintf(convform "FLOC 6 1\n")
fprintf(convform "STRFILLIN 10 10\n")
fprintf(convform "ENDFIELD\n")

fprintf(convform "\n")
fprintf(convform "TEXT \"mils \"\n")
fprintf(convform "TLOC 20 1\n")
fprintf(convform "ENDTEXT\n")

fprintf(convform "FIELD mm\n")
fprintf(convform "FLOC 6 4\n")
fprintf(convform "STRFILLIN 10 10\n")
fprintf(convform "ENDFIELD\n")

fprintf(convform "\n")
fprintf(convform "TEXT \"mm\"\n")
fprintf(convform "TLOC 20 4\n")
fprintf(convform "ENDTEXT\n")

fprintf(convform "FIELD Done\n")
fprintf(convform "FLOC 9 8\n")
fprintf(convform "MENUBUTTON \"Done\" 9 3\n")
fprintf(convform "ENDFIELD\n")
fprintf(convform "\n")
 
fprintf(convform "\n")
fprintf(convform "ENDTILE\n")
fprintf(convform "\n")
fprintf(convform "ENDFORM\n")
close( convform)
 
) ;end defun createconvform

; what to do on form actions
; --------------------------
 
(defun Conv_Action (convform)
 
(case convform->curField
 
    ("Done"
        axlFormClose(convform)

		; rm may be incompatible with some platforms
		; ------------------------------------------
		shell("rm -f conv.form")

		nil
    );
 
    ("mils"
    mils=(convform->curValue)
		
		x = rexMatchp("[^0-9.]+" mils)
		if( eq(x t) then
			axlFormSetField(convform "mils" "Error")
			else
    		mils = evalstring(mils)
			if( (mils > 393700787) then
				mm = "Error" else
	    		mm = axlMKSConvert( mils "MILS" "MM")
				sprintf(mm "%.2f" , mm)
			)
			axlFormSetField(convform "mm" mm)
		) ; end of if
	t
    );
 
    ("mm"
    mm=(convform->curValue)

		x = rexMatchp("[^0-9.]+" mm)
        if( eq(x t) then 
            axlFormSetField(convform "mm" "Error") 
            else 
    		mm = evalstring(mm)
			if( (mm > 2539999) then
				mils = "Error" else
    			mils = axlMKSConvert( mm "MM" "MILS")
				sprintf(mils "%.1f" , mils)
			) 
			axlFormSetField(convform "mils" mils)
		) ; end of if
    t
    );
 
); end case
 
); end Conv_Action

; Registers conv as an 'Allegro' command
; --------------------------------------

axlCmdRegister( "conv" `conv)

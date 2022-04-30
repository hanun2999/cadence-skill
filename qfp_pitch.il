;                     QFP Pitch Calculator
;                     --------------------

; This routine is a simple utility, which will calculate a
; suitable pitch and pad length given the maximum outside
; and minimum inside dimensions of a QFP device. These dimensions
; should be obtained from the relevant data sheet, and should
; include all tolerances.

; The pitch and pad length calculated will include sufficient 
; pad area for a good solder fillet to be obtained at both ends
; of the pin.

; Enter dimensions in mils, rounded to the nearest mil.

; To run the utility type "qfp_pitch" on the Allegro command line.

; -----------------------------------------------------------------

; Tested on Allegro 11.0

; Written by:

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

; -----------------------------------------------------------------

(defun qfp_win ()
 
min_in=nil
max_out=nil

createqfpform()
qfpform()

); end of qfp_win 

(defun qfpform ()
 
qfpform=axlFormCreate( (gensym) qfpform_file nil 'qfp_Action t)
axlFormDisplay(qfpform)
axlUIWPrint(qfpform  "Enter data to nearest mil.")
 
) ; end defun qfpform 

; creates form
; ------------

(defun createqfpform ()

drain()
qfpform_file = "qfp.form"
qfpform = outfile(qfpform_file "w")
fprintf(qfpform "FILE_TYPE=FORM_DEFN VERSION=2\n")
fprintf(qfpform "FORM\n")
fprintf(qfpform "FIXED\n")
fprintf(qfpform "PORT 42 10\n")
fprintf(qfpform "HEADER \"QFP Pitch Calculator\"\n")
fprintf(qfpform "\n")

fprintf(qfpform "TILE\n")

fprintf(qfpform "TEXT \"Maximum Outside Dimension\"\n")
fprintf(qfpform "TLOC 1 1\n")
fprintf(qfpform "ENDTEXT\n")
fprintf(qfpform "FIELD max_out\n")
fprintf(qfpform "FLOC 28 1\n")
fprintf(qfpform "INTFILLIN 4 4\n")
fprintf(qfpform "ENDFIELD\n")
fprintf(qfpform "\n")
fprintf(qfpform "TEXT \"mils\"\n")
fprintf(qfpform "TLOC 35 1\n")
fprintf(qfpform "ENDTEXT\n")

fprintf(qfpform "TEXT \"Minimum Inside Dimension\"\n")
fprintf(qfpform "TLOC 1 4\n")
fprintf(qfpform "ENDTEXT\n") 
fprintf(qfpform "FIELD min_in\n")
fprintf(qfpform "FLOC 28 4\n")    
fprintf(qfpform "INTFILLIN 4 4\n")
fprintf(qfpform "ENDFIELD\n")    
fprintf(qfpform "\n")
fprintf(qfpform "TEXT \"mils\"\n")
fprintf(qfpform "TLOC 35 4\n")   
fprintf(qfpform "ENDTEXT\n") 

fprintf(qfpform "TEXT \"Pad Length...............\"\n") 
fprintf(qfpform "TLOC 1 8\n") 
fprintf(qfpform "ENDTEXT\n") 
fprintf(qfpform "FIELD pad_length\n") 
fprintf(qfpform "FLOC 28 8\n")     
fprintf(qfpform "INFO_ONLY\n")
fprintf(qfpform "INTFILLIN 4 4\n") 
fprintf(qfpform "ENDFIELD\n")     
fprintf(qfpform "\n")    
fprintf(qfpform "TEXT \"mils\"\n") 
fprintf(qfpform "TLOC 35 8\n")    
fprintf(qfpform "ENDTEXT\n")

fprintf(qfpform "TEXT \"Pitch....................\"\n")  
fprintf(qfpform "TLOC 1 11\n")    
fprintf(qfpform "ENDTEXT\n")  
fprintf(qfpform "FIELD pitch\n")  
fprintf(qfpform "FLOC 28 11\n")      
fprintf(qfpform "INFO_ONLY\n")    
fprintf(qfpform "INTFILLIN 4 4\n")  
fprintf(qfpform "ENDFIELD\n")       
fprintf(qfpform "\n")     
fprintf(qfpform "TEXT \"mils\"\n")  
fprintf(qfpform "TLOC 35 11\n")     
fprintf(qfpform "ENDTEXT\n") 

fprintf(qfpform "FIELD Done\n")
fprintf(qfpform "FLOC 16 15\n")
fprintf(qfpform "MENUBUTTON \"Done\" 9 3\n")
fprintf(qfpform "ENDFIELD\n")
fprintf(qfpform "\n")
 
fprintf(qfpform "\n")
fprintf(qfpform "ENDTILE\n")
fprintf(qfpform "\n")
fprintf(qfpform "ENDFORM\n")
close( qfpform)
 
) ; end defun createqfpform
 
; what to do on form actions
; --------------------------

(defun qfp_Action (qfpform)
 
(case qfpform->curField
 
    ("Done"
        axlFormClose(qfpform)

		; tidies up output file
        ; may be incompatible with some platforms
		shell("rm -f qfp.form")

		nil
    );
 
    ("max_out"
    max_out=(qfpform->curValue)
		
if( nequal(max_out nil) min_in_true())

	t
    );
 
    ("min_in"
    min_in=(qfpform->curValue)

if( nequal(min_in nil) max_out_true())

    t
    );
 
); end case
 
); end Conv_Action

; checks input
; ------------

(defun max_out_true ()

if( nequal(max_out nil) qfp_calc() )

); end defun max_out_true

(defun min_in_true ()

if( nequal(min_in nil) qfp_calc() )

); end of defun min_in_true

; calculates pitch and pad length
; -------------------------------

(defun qfp_calc () 

max_out = round(max_out)
min_in = round(min_in)
new_max = 0
count = 0

total_max = max_out + 30
 
    while( nequal(total_max new_max)
        count = count + 1
        total_max = total_max - 1
        new_max = total_max/10
        new_max = new_max*10
    ) ; end of while
 
    if( equal(count 10)
        total_max = total_max + 10)
   
new_min = 0
count = 0
 
total_min = min_in - 30
 
    while( nequal(total_min new_min)
        count = count + 1
        total_min = total_min + 1
        new_min = total_min/10
        new_min = new_min*10
    ) ; end of while
 
    if( equal(count 10)
        total_min = total_min - 10)
 
pad_length = total_max - total_min
pad_length = pad_length/2
 
pitch = total_max - pad_length

axlFormDisplay(qfpform)
axlFormSetField(qfpform "pad_length" pad_length)
axlFormSetField(qfpform "pitch" pitch)

) ; end of qfp_calc

; Registers qfp_pitch as an 'Allegro' command
; -------------------------------------------

axlCmdRegister( "qfp_pitch" `qfp_win)

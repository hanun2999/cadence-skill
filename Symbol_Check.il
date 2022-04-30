; ###############################################################################
 
;                          Symbol existence checker

;  This routine will go through the database, gather the names of all the symbols
;  required to place the parts, then check if those symbols exist in the current
;  PSMPATH. Any symbols not found are listed in a "Symbol_Check.log" file, if all
;  symbols are found a line stating "All required symbols have been found" is put
;  in the log file. At completion of the check the log file is opened in a viewlog
;  window in Allegro.

;  This routine is intended to be run after a successful netin or fet2a.

;  To run the checker in Allegro type "symbol check"

;  Written by David J. Scheuring
;  Sr. Applications Eng. Cadence Design Systems
;  May 17, 1995




axlCmdRegister("symbol check" 'Symbol_Check_Routine ?cmdType "interactive")

(defun Symbol_Check_Routine ()

   ; ########################
   ; Set the global variables
   ; ########################
   All_Found=t

   ; ###########################################
   ; Build the extract view file and run extract
   ; ###########################################
   Symbol_List=outfile("./Symbol_List.txt" "w")
   fprintf(Symbol_List "COMPONENT\n")
   fprintf(Symbol_List "COMP_PACKAGE\n")
   close(Symbol_List)

   axlExtractToFile( "./Symbol_List" "./Symbol_list_File")
   
   ; ###########################
   ; Replace the "!" with spaces
   ; ###########################
   Command="sed '1,$s/!/ /g' ./Symbol_list_File.txt | sort -u > ./Symbol_List.txt"
   shell(Command)
   
   ; ###################################################
   ; Open the log file and put in the header information
   ; ###################################################
   Directories=parseString(axlGetVariable("PSMPATH"))
   Log_File=outfile("./Symbol_Check.log" "w")
   Date=(getCurrentTime)
   fprintf(Log_File "\n\n\n")
   fprintf(Log_File "\t%s\n\n" Date)
   fprintf(Log_File "\tSymbol Availability check\n\n\n")
   fprintf(Log_File "\tCurrent PSMPATH consists of:\n")
   (foreach Directory Directories
      fprintf(Log_File "\t%s\n" Directory)
   ); end foreach Directory Directories
   fprintf(Log_File "\n\n")
   
   ; ####################################################################################
   ; Get the PSMPATH and check if the symbols exist somewhere where Allegro can find them
   ; ####################################################################################
   Symbol_List_File=infile("./Symbol_List.txt")
   Current_Line=lineread(Symbol_List_File)
   Current_Line=lineread(Symbol_List_File)
   (while fscanf(Symbol_List_File "%s %s" Char String)!=nil
      Found=nil
      (foreach Directory Directories
         File=sprintf(dummy "%s/%s.psm" Directory lowerCase(String))
         (if isFile(File)==t then
            Found=t
         ); end if isFile(File)==t
      ); end foreach Directory parseString(Directories)
      (if Found!=t then
         fprintf(Log_File "\tSymbol not found in PSMPATH - %s\n" String)
         All_Found=nil
         ; #################################################################
         ; Uncomment the next 2 lines if you want to print the FOUND symbols
         ; #################################################################
         ;else
         ;fprintf(Log_File "\tSymbol Found in PSMPATH - %s\n" String)
      ); end if Found==t
   ); end while Current_Line!=nil

   ; ##############################################
   ; Close the log file and clean up after yourself
   ; ##############################################
   (if All_Found==t then
      fprintf(Log_File "\tAll required symbols have been found\n")
   ); en if All_Found==t
   close(Log_File)

   shell("rm ./Symbol_List.txt ./Symbol_list_File.txt")

   ; ###############################
   ; Display the log file in Allegro
   ; ###############################
   axlShell("viewlog Symbol_Check.log")
); end defun Symbol_Check_Routine

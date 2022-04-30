/*
################################################################################
#                                                                              #
#                      Command: cds2f                                          #
#                   Skill File: cds2f.il                                       #
#                                                                              #
#                                                                              #
#                       Author: Ming Chou, Tony, Huang			       #
#                               Cadence Design Systems, Taiwan                 #
#                        Email: thuang@cadence.com                             #
#                Creation Date: Rev. 0.0	Nov. 8, 2005                   #
#                                                                              #
#                                                                              #
#      This program will create a data file for Fabmaster                      #
#            eM Test Expert 2.0.4 and Fabmaster V8E4 .                         #
#                                                                              #
################################################################################


################################################################################
#  DISCLAIMER:                                                                 #
#       The user of this command assumes all responsibility and does not       #
#       hold Cadence Design Systems nor the author of this code for any        #
#       unwarranted results or problems due to the use of this code.           #
#                                                                              #
#       This is non-supported code and the user may modify it as needed.       #
#                                                                              #
#                                                                              #
#       To use this program load this file cds2f.il and from                   #
#       the Allegro/APD command line use the command  cds2f                    #
#                                                                              #
#                                                                              #
################################################################################
*/
axlCmdRegister( "cds2f" `mycds2f)

/*
###########################################################
#  Function : tbat ()
#  Descript : This function will write a DOS bat file that t.bat
#  Input    : 
#                    
#  Output   : t.bat
#
#
###########################################################
*/
(defun tbat ()
	
   	tbatfile=outfile("t.bat" "w")
   	fprintf(tbatfile "extracta %%1.brd cds2f.txt %%1.1out %%1.2out %%1.3out %%1.4out %%1.5out %%1.6out %%1.7out %%1.8out %%1.9out\n") 
	fprintf(tbatfile "copy %%1.1out+%%1.2out+%%1.3out+%%1.4out+%%1.5out+%%1.6out+%%1.7out+%%1.8out+%%1.9out cds2f_%%1.cad\n") 
        fprintf(tbatfile "del %%1.*out\n") 
    	fprintf(tbatfile "del cds2f.txt\n")
   	fprintf(tbatfile "del t.bat\n")
   	close(tbatfile)
	   
);end defun tbat
/*
###########################################################
#  Function : wr_cds2f ()
#  Descript : This function will write a extracta command file
#  Input    : 
#                    
#  Output   : cds2f.txt
#
#
###########################################################
*/
(defun wr_cds2f ()
	
   	cds2f=outfile("cds2f.txt" "w")
   
	  	
   	fprintf(cds2f "#A!REFDES!COMP_CLASS!COMP_PART_NUMBER!COMP_HEIGHT!COMP_DEVICE_LABEL!COMP_INSERTION_CODE!SYM_TYPE\n")   
	fprintf(cds2f "#!SYM_NAME!SYM_MIRROR!SYM_ROTATE!SYM_X!SYM_Y!COMP_VALUE!COMP_TOL!COMP_VOLTAGE!\n")   
	fprintf(cds2f "COMPONENT \n")   
	
	fprintf(cds2f "REFDES \n")   
	fprintf(cds2f "COMP_CLASS \n")   
	fprintf(cds2f "COMP_PART_NUMBER \n")   
	fprintf(cds2f "COMP_HEIGHT \n")   
	fprintf(cds2f "COMP_DEVICE_LABEL \n")   
	fprintf(cds2f "COMP_INSERTION_CODE \n")   
	fprintf(cds2f "SYM_TYPE \n")   
	fprintf(cds2f "SYM_NAME \n")   
	fprintf(cds2f "SYM_MIRROR \n")   
	fprintf(cds2f "SYM_ROTATE \n")   
	fprintf(cds2f "SYM_X \n")   
	fprintf(cds2f "SYM_Y \n")   
	fprintf(cds2f "COMP_VALUE \n")   
	fprintf(cds2f "COMP_TOL \n")   
	fprintf(cds2f "COMP_VOLTAGE \n")   
	fprintf(cds2f "END\n")   
	fprintf(cds2f "\n")   
	fprintf(cds2f "#A!NET_NAME!REFDES!PIN_NUMBER!PIN_NAME!PIN_GROUND!PIN_POWER!\n")   
	fprintf(cds2f "COMPONENT_PIN \n")   
	fprintf(cds2f "\n")   
	fprintf(cds2f "NET_NAME \n")   
	fprintf(cds2f "REFDES \n")   
	fprintf(cds2f "PIN_NUMBER \n")   
	fprintf(cds2f "PIN_NAME \n")   
	fprintf(cds2f "PIN_GROUND \n")   
	fprintf(cds2f "PIN_POWER \n")   
	fprintf(cds2f "END\n")   
	fprintf(cds2f "\n")   
	fprintf(cds2f "\n")   
	fprintf(cds2f "\n")   
	fprintf(cds2f "#A!CLASS!SUBCLASS!\n")   
	fprintf(cds2f "GEOMETRY \n")   
	fprintf(cds2f "\n")   
	fprintf(cds2f "CLASS!=\"VIA CLASS\" \n")   
	fprintf(cds2f "CLASS!=\"PIN\" \n")   
	fprintf(cds2f "CLASS!=\"PACKAGE GEOMETRY\" \n")   
	fprintf(cds2f "CLASS!=\"ETCH\" \n")   
	fprintf(cds2f "OR \n")   
	fprintf(cds2f "CLASS=\"ETCH\" \n")   
	fprintf(cds2f "CLASS \n")   
	fprintf(cds2f "SUBCLASS \n")   
	fprintf(cds2f "END\n")   
	fprintf(cds2f "\n")   
	fprintf(cds2f "#A!PAD_NAME!REC_NUMBER!LAYER!FIXFLAG!VIAFLAG!PADSHAPE1!PADWIDTH!PADHGHT!PADXOFF!PADYOFF!\n")   
	fprintf(cds2f "#PADFLASH!PADSHAPENAME!TRELSHAPE1!TRELWIDTH!TRELHGHT!TRELXOFF!TRELYOFF!TRELFLASH!TRELSHAPENAME!\n")   
	fprintf(cds2f "#APADSHAPE1!APADWIDTH!APADHGHT!APADXOFF!APADYOFF!APADFLASH!APADSHAPENAME!\n")   
	fprintf(cds2f "PAD_DEF \n")   
	fprintf(cds2f "END\n")   
	fprintf(cds2f "\n")   
	fprintf(cds2f "\n")   
	fprintf(cds2f "#A!GRAPHIC_DATA_NAME!GRAPHIC_DATA_NUMBER!RECORD_TAG!GRAPHIC_DATA_1!GRAPHIC_DATA_2!GRAPHIC_DATA_3!GRAPHIC_DATA_4\n")   
	fprintf(cds2f "#!GRAPHIC_DATA_5!GRAPHIC_DATA_6!GRAPHIC_DATA_7!GRAPHIC_DATA_8!GRAPHIC_DATA_9!SUBCLASS!SYM_NAME!REFDES!\n")   
	fprintf(cds2f "GEOMETRY \n")   
	fprintf(cds2f "CLASS=\"PACKAGE GEOMETRY\" \n")   
	fprintf(cds2f "\n")   
	fprintf(cds2f "GRAPHIC_DATA_NAME \n")   
	fprintf(cds2f "GRAPHIC_DATA_NUMBER \n")   
	fprintf(cds2f "RECORD_TAG \n")   
	fprintf(cds2f "GRAPHIC_DATA_1 \n")   
	fprintf(cds2f "GRAPHIC_DATA_2 \n")   
	fprintf(cds2f "GRAPHIC_DATA_3 \n")   
	fprintf(cds2f "GRAPHIC_DATA_4 \n")   
	fprintf(cds2f "GRAPHIC_DATA_5 \n")   
	fprintf(cds2f "GRAPHIC_DATA_6 \n")   
	fprintf(cds2f "GRAPHIC_DATA_7 \n")   
	fprintf(cds2f "GRAPHIC_DATA_8 \n")   
	fprintf(cds2f "GRAPHIC_DATA_9 \n")   
	fprintf(cds2f "SUBCLASS \n")   
	fprintf(cds2f "SYM_NAME \n")   
	fprintf(cds2f "REFDES \n")   
	fprintf(cds2f "END\n")   
	fprintf(cds2f "\n")   
	fprintf(cds2f "#A!SYM_NAME!SYM_MIRROR!PIN_NAME!PIN_NUMBER!PIN_X!PIN_Y!PAD_STACK_NAME!REFDES!PIN_ROTATION!TEST_POINT!\n")   
	fprintf(cds2f "COMPOSITE_PAD \n")   
	fprintf(cds2f "CLASS!=\"VIA CLASS\" \n")   
	fprintf(cds2f "\n")   
	fprintf(cds2f "SYM_NAME \n")   
	fprintf(cds2f "SYM_MIRROR\n")   
	fprintf(cds2f "PIN_NAME \n")   
	fprintf(cds2f "PIN_NUMBER \n")   
	fprintf(cds2f "PIN_X \n")   
	fprintf(cds2f "PIN_Y \n")   
	fprintf(cds2f "PAD_STACK_NAME \n")   
	fprintf(cds2f "REFDES \n")   
	fprintf(cds2f "PIN_ROTATION\n")   
	fprintf(cds2f "TEST_POINT \n")   
	fprintf(cds2f "END\n")   
	fprintf(cds2f "\n")   
	fprintf(cds2f "#A!VIA_X!VIA_Y!PAD_STACK_NAME!NET_NAME!TEST_POINT!VIA_MIRROR!\n")   
	fprintf(cds2f "\n")   
	fprintf(cds2f "COMPOSITE_PAD \n")   
	fprintf(cds2f "CLASS=\"VIA CLASS\" \n")   
	fprintf(cds2f "\n")   
	fprintf(cds2f "VIA_X \n")   
	fprintf(cds2f "VIA_Y \n")   
	fprintf(cds2f "PAD_STACK_NAME \n")   
	fprintf(cds2f "NET_NAME \n")   
	fprintf(cds2f "TEST_POINT \n")   
	fprintf(cds2f "VIA_MIRROR\n")   
	fprintf(cds2f "END\n")   
	fprintf(cds2f "\n")   
	fprintf(cds2f "\n")   
	fprintf(cds2f "\n")   
	fprintf(cds2f "#A!CLASS!SUBCLASS!GRAPHIC_DATA_NAME!GRAPHIC_DATA_NUMBER!RECORD_TAG!GRAPHIC_DATA_1!\n")   
	fprintf(cds2f "#GRAPHIC_DATA_2!GRAPHIC_DATA_3!GRAPHIC_DATA_4!GRAPHIC_DATA_5!GRAPHIC_DATA_6!GRAPHIC_DATA_7!\n")   
	fprintf(cds2f "#GRAPHIC_DATA_8!GRAPHIC_DATA_9!NET_NAME!\n")   
	fprintf(cds2f "GEOMETRY \n")   
	fprintf(cds2f "CLASS!=\"VIA CLASS\" \n")   
	fprintf(cds2f "CLASS!=\"PIN\" \n")   
	fprintf(cds2f "CLASS!=\"PACKAGE GEOMETRY\" \n")   
	fprintf(cds2f "CLASS!=\"ETCH\" \n")   
	fprintf(cds2f "OR \n")   
	fprintf(cds2f "CLASS=\"ETCH\" \n")   
	fprintf(cds2f "\n")   
	fprintf(cds2f "CLASS \n")   
	fprintf(cds2f "SUBCLASS \n")   
	fprintf(cds2f "GRAPHIC_DATA_NAME \n")   
	fprintf(cds2f "GRAPHIC_DATA_NUMBER \n")   
	fprintf(cds2f "RECORD_TAG \n")   
	fprintf(cds2f "GRAPHIC_DATA_1 \n")   
	fprintf(cds2f "GRAPHIC_DATA_2 \n")   
	fprintf(cds2f "GRAPHIC_DATA_3 \n")   
	fprintf(cds2f "GRAPHIC_DATA_4 \n")   
	fprintf(cds2f "GRAPHIC_DATA_5 \n")   
	fprintf(cds2f "GRAPHIC_DATA_6 \n")   
	fprintf(cds2f "GRAPHIC_DATA_7 \n")   
	fprintf(cds2f "GRAPHIC_DATA_8 \n")   
	fprintf(cds2f "GRAPHIC_DATA_9 \n")   
	fprintf(cds2f "NET_NAME \n")   
	fprintf(cds2f "END\n")   
	fprintf(cds2f "\n")   
	fprintf(cds2f "#A!SUBCLASS!PAD_SHAPE_NAME!GRAPHIC_DATA_NAME!GRAPHIC_DATA_NUMBER!RECORD_TAG!GRAPHIC_DATA_1!\n")   
	fprintf(cds2f "#GRAPHIC_DATA_2!GRAPHIC_DATA_3!GRAPHIC_DATA_4!GRAPHIC_DATA_5!GRAPHIC_DATA_6!GRAPHIC_DATA_7!GRAPHIC_DATA_8!\n")   
	fprintf(cds2f "#GRAPHIC_DATA_9!PAD_STACK_NAME!REFDES!PIN_NUMBER!\n")   
	fprintf(cds2f "FULL_GEOMETRY\n")   
	fprintf(cds2f "REFDES!=\"\"\n")   
	fprintf(cds2f "PAD_STACK_NAME!=\"\"\n")   
	fprintf(cds2f "GRAPHIC_DATA_NAME=\"LINE\"\n")   
	fprintf(cds2f "\n")   
	fprintf(cds2f "SUBCLASS\n")   
	fprintf(cds2f "PAD_SHAPE_NAME\n")   
	fprintf(cds2f "GRAPHIC_DATA_NAME\n")   
	fprintf(cds2f "GRAPHIC_DATA_NUMBER\n")   
	fprintf(cds2f "RECORD_TAG\n")   
	fprintf(cds2f "GRAPHIC_DATA_1\n")   
	fprintf(cds2f "GRAPHIC_DATA_2\n")   
	fprintf(cds2f "GRAPHIC_DATA_3\n")   
	fprintf(cds2f "GRAPHIC_DATA_4\n")   
	fprintf(cds2f "GRAPHIC_DATA_5\n")   
	fprintf(cds2f "GRAPHIC_DATA_6\n")   
	fprintf(cds2f "GRAPHIC_DATA_7\n")   
	fprintf(cds2f "GRAPHIC_DATA_8\n")   
	fprintf(cds2f "GRAPHIC_DATA_9\n")   
	fprintf(cds2f "PAD_STACK_NAME\n")   
	fprintf(cds2f "REFDES\n")   
	fprintf(cds2f "PIN_NUMBER\n")   

close(cds2f)

);end defun wr_cds2f ()
/*
###########################################################
#  Function : mycds2f ()
#  Descript : This function will run t.bat to create data for Fabmaster
#  Input    : 
#                    
#  Output   : cds2f_brdname.cad
#
#
###########################################################
*/
(defun mycds2f ()
a=axlDMFileParts(axlGetDrawingName())
fname=nth(1 a)
tbat()
wr_cds2f()
b=strcat("t " fname)
system(b)
);end defun mycds2f ()



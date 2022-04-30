;			auxitoolshelp Designators
;	  	-------------------------------------------

;File name: ljj_auxitoolshelp.il
;Revision:0
;date:06/14/2002
;Writen by: lijinjun/15923
;use clearit function
;tel: 6540578
;e_mail: lijinjun@huawei.com

;This routine allowes the user to  auto auxitoolshelp .


;==================================================================
;			Main Function
;==================================================================
axlCmdRegister( "auxitools help" '_LJJ_auxitoolshelp  ?cmdType "general")

defun( _LJJ_auxitoolshelp ()
auxipath = (axlGetVariable "allegro_install_root")
sprintf(auxiread "acroread %s/share/pcb/etc/skill/auxitools.pdf" auxipath)
axlShell(auxiread)
printf("\n## Thank you for using it!! ##\n")
);end-defun _LJJ_auxitoolshelp

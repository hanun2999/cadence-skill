  ;			camclear Designators           
;	  	-------------------------------------------  
                                                             
;File name: ljj_camclear.il                                 
;Revision:0	                                             
;date:06/14/2002                                             
;Writen by: lijinjun/15923   
;use clearit function                               
;tel: 6540578                                                
;e_mail: lijinjun@huawei.com                                
                                                             
;This routine allowes the user to  auto camclear .          
                                                             

;==================================================================
;			Main Function
;==================================================================
axlCmdRegister( "cam clear" '_LJJ_camclear  ?cmdType "general")

defun( _LJJ_camclear ()
shell("clearit")
printf("\n----Clear *,* *,log *.txt *.tag *.tap *.art *.jrl on current directory is finished----\n")
printf("\n=== Thank you for using it ===\n")
);end-defun _LJJ_camzip  
                                                                                 

  ;			valorout Designators           
;	  	-------------------------------------------  
                                                             
;File name: ljj_valorout.il                                 
;Revision:0	                                             
;date:06/14/2002                                             
;Writen by: lijinjun/15923   
;use clearit function                               
;tel: 6540578                                                
;e_mail: lijinjun@huawei.com                                
                                                             
;This routine allowes the user to  auto valorout .          
                                                             

;==================================================================
;			Main Function
;==================================================================
axlCmdRegister( "valor out" '_LJJ_valorout  ?cmdType "general")

defun( _LJJ_valorout ()
axlShell("valor extract info")
axlShell("valor film info")
printf("\n=== Valor out is finished ====\n")
printf("\n## Thank you for using it!! ##\n")
);end-defun _LJJ_valorout  
                                                                                 

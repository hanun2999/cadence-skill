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
shell("rm  ./*,*")
shell("rm  ./*.log")
shell("rm ./art_aper.txt")
shell("rm ./art_param.txt")
shell("rm ./nc_param.txt")
shell("rm ./*.val")
shell("rm ./*.tag")
shell("rm ./*.tap")
shell("rm ./*.art")
shell("rm ./*.jrl")
shell("rm ./*.out")
shell("rm ./*.afa")
printf("\n###On current directory *,* *,log  *.val *.tag *.tap *.art *.jrl \n")
printf("###nc_param.txt art_param.txt art_aper.txt *.out *.afa\n###CLEAR is finished ====\n")
printf("\n## Thank you for using it!! ##\n")
);end-defun _LJJ_camclear


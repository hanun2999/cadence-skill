  ;			camout Designators           
;	  	-------------------------------------------  
                                                             
;File name: ljj_camout.il                                 
;Revision:0	                                             
;date:05/29/2002                                             
;Writen by: lijinjun/15923                                  
;tel: 6540578                                                
;e_mail: lijinjun@huawei.com  
;Modified by lijinjun 20020730
;before create cam , art_param.txt should created!                             
                                                             
;This routine allowes the user to  auto camout .          
                                                             

;==================================================================
;			Main Function
;==================================================================
axlCmdRegister( "cam out" '_LJJ_camout  ?cmdType "general")

defun( _LJJ_camout ()
camoutfile = outfile("./camoutfile.scr")
fprintf(camoutfile "# Allegro script \n")
fprintf(camoutfile "version 14.1 \n\n")
fprintf(camoutfile "setwindow pcb\n")
fprintf(camoutfile "# Macro file: coordinates are relative to pick on replay.\n")
fprintf(camoutfile "color \n")
fprintf(camoutfile "setwindow form.cvf_main\n")
fprintf(camoutfile "FORM cvf_main global_vis All Visible \n")
fprintf(camoutfile "fillin yes \n")
fprintf(camoutfile "FORM cvf_main ok  \n")
fprintf(camoutfile "setwindow pcb\n")
fprintf(camoutfile "ncdrill param \n")
fprintf(camoutfile "setwindow form.ncparm\n")
fprintf(camoutfile "FORM ncparm decimal_places 5\n")
fprintf(camoutfile "FORM ncparm repeat_codes NO \n")
fprintf(camoutfile "FORM ncparm done \n") 
fprintf(camoutfile "setwindow pcb\n")
fprintf(camoutfile "ncdrill legend \n")
fprintf(camoutfile "setwindow form.nclegend\n")
fprintf(camoutfile "FORM nclegend done \n") 
fprintf(camoutfile "setwindow pcb\n")
fprintf(camoutfile "pick_origin\n\n")
fprintf(camoutfile "pick rel 0 0\n")
fprintf(camoutfile "nctape_full \n")
fprintf(camoutfile "setwindow form.nctape\n")
fprintf(camoutfile "FORM nctape execute  \n")
fprintf(camoutfile "FORM nctape cancel  \n")
;
fprintf(camoutfile "setwindow pcb\n")
fprintf(camoutfile "film param \n")
fprintf(camoutfile "setwindow form.film_control\n")
fprintf(camoutfile "FORM film_control general_parameters \n") 
fprintf(camoutfile "FORM film_control format_dec_places 5\n") 
fprintf(camoutfile "FORM film_control ok  \n") 
;
fprintf(camoutfile "setwindow pcb\n")
fprintf(camoutfile "film param \n")
fprintf(camoutfile "setwindow form.film_control\n")
fprintf(camoutfile "FORM film_control apertures  \n")
fprintf(camoutfile "setwindow form.apt_wheels\n")
fprintf(camoutfile "FORM apt_wheels 1 delete  \n")
fprintf(camoutfile "FORM apt_wheels add_wheel  \n")
fprintf(camoutfile "FORM apt_wheels 1 edit  \n")
fprintf(camoutfile "setwindow form.apt_stations\n")
fprintf(camoutfile "FORM apt_stations auto Without Rotation \n")
fprintf(camoutfile "FORM apt_stations sort By Station \n")
fprintf(camoutfile "FORM apt_stations apt_done  \n")
fprintf(camoutfile "setwindow form.apt_wheels\n")
fprintf(camoutfile "FORM apt_wheels done  \n")
fprintf(camoutfile "setwindow form.film_control\n")
fprintf(camoutfile "FORM film_control ok \n")
;
fprintf(camoutfile "setwindow pcb\n")
fprintf(camoutfile "film param \n")
fprintf(camoutfile "setwindow form.film_control\n")
fprintf(camoutfile "FORM film_control select_all \n") 
fprintf(camoutfile "FORM film_control create  \n")
fprintf(camoutfile "FORM film_control ok \n")

close(camoutfile)
axlShell("setwindow pcb")
axlShell("replay ./camoutfile.scr")
printf("\n===CAMout is finished !====\n ## Thank you for using it ##\n")
shell("rm   ./camoutfile.scr")


);end-defun _LJJ_camout  
                                                                                 

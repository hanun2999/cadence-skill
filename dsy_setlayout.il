   ;			Add/Sub layeout Designators auto crossection
;	  	-------------------------------------------

;File name: dsy_setlayout.il
;Revision:0	
;date:05/29/2002
;Writen by: daishiyan/22863
;tel: 6540572
;e_mail: daishiyan@huawei.com   

;This routine allowes the user to delete dangline .     

;==================================================================
;			Main Function
;==================================================================
axlCmdRegister("auto crossection" 'DSY_Set_layout)
defun( DSY_Set_layout ()
    SL_SetState_Form_Ptr  = nil
    SL_SetState_Form_Data = nil
         when(axlOKToProceed()
           when(  _SL_SetState_Form_Creat()
                  _SL_SetState_Form_Display()
               );end-when
         );end-when
);end-defun DSY_Set_layout 
;==================================================================
;			_SL_SetState_Form_Creat ()
;==================================================================
(defun _SL_SetState_Form_Creat ()
prog( ()
   form_file = outfile("sl_cn.form")
   fprintf( form_file "FILE_TYPE = FORM_DEFN VERSION=2\nFORM\nFIXED\n")
   fprintf( form_file "PORT 48 28                                  \n")
   fprintf( form_file "HEADER \"Set layout cross section\"         \n")
   fprintf( form_file "TILE                                        \n")
   fprintf( form_file "TEXT \"please input layer_state:\"          \n")
   fprintf( form_file "TLOC 2 2                                    \n")
   fprintf( form_file "ENDTEXT                                     \n")
   fprintf( form_file "FIELD laystate                              \n")
   fprintf( form_file "FLOC 21 2                                   \n")
   fprintf( form_file "STRFILLIN 23 28                             \n")
   fprintf( form_file "ENDFIELD                                    \n")
   fprintf( form_file "TEXT \"Current layer:\"                     \n")
   fprintf( form_file "TLOC 2 4                                    \n")
   fprintf( form_file "ENDTEXT                                     \n")
   fprintf( form_file "FIELD current_layer                         \n")
   fprintf( form_file "FLOC 4 6                                    \n")
   fprintf( form_file "LIST \"\" 42 8                              \n")
   fprintf( form_file "OPTIONS sort                                \n")
   fprintf( form_file "ENDFIELD                                    \n")
   fprintf( form_file "FIELD rename_on                             \n")
   fprintf( form_file "FLOC 4 22                                   \n")
   fprintf( form_file "CHECKLIST \"Selected ,will rename\"         \n")
   fprintf( form_file "ENDFIELD                                    \n")
   fprintf( form_file "FIELD add                                   \n")
   fprintf( form_file "FLOC 6 25                                   \n")
   fprintf( form_file "MENUBUTTON \"Add\" 5 3                      \n")
   fprintf( form_file "ENDFIELD                                    \n")
   fprintf( form_file "FIELD del                                   \n")
   fprintf( form_file "FLOC 18 25                                  \n")
   fprintf( form_file "MENUBUTTON \"Delete\" 5 3                   \n")
   fprintf( form_file "ENDFIELD                                    \n")
   fprintf( form_file "FIELD cancel                                \n")
   fprintf( form_file "FLOC 34 25                                  \n")
   fprintf( form_file "MENUBUTTON \"Exit\" 5 3                     \n")
   fprintf( form_file "ENDFIELD                                    \n")
   fprintf( form_file "ENDTILE                                     \n")
   fprintf( form_file "ENDFORM                                     \n")
   close( form_file )
   if( isFile("sl_cn.form") then
        return( t )
   else
        axlMsgPut("ERROR 01: Unable to Open .form file")
        return( nil )
   );end-if
   );end_prog
) ; end _SL_SetState_Form_Creat
;==================================================================
;			_SL_SetState_Form_Display ()
;==================================================================
defun( _SL_SetState_Form_Display ()
prog( ()
let( ( form )
   form = axlFormCreate( (gensym) "sl_cn.form" '(se outer) '_SL_State_CallBack t)
   SL_SetState_Form_Ptr = form
 if( (SL_SetState_Form_Data == nil) then
   setq( SL_SetState_Form_Data t)
   laystate = strcat("")
   rename_on = nil
   axlFormSetField( form "laystate" laystate)
   putprop( SL_SetState_Form_Data laystate 'laystate)
   _DSY_Changname()
   axlFormSetField(form "current_layer" dislayer_list)
   axlFormDisplay( form )
 );end-if
);end-let
);end-prog
);end-defun _SL_SetState_Form_Display
;==================================================================
;			 _SL_State_CallBack()
;==================================================================
defun( _SL_State_CallBack (form)
prog( ()
    case( form->curField
         ("laystate"	
            axlMsgPut("Enter setup of layer .")
            laystate = form->curValue
         t)   
         ("rename_on"
            axlMsgPut("Enter setup of layer .")
            rename_on = form->curValue
            if(rename_on==t
               then
               _DSY_del_rename()
               );end_if   
            axlFormListDeleteAll(form "current_layer")
            _DSY_Changname()
            axlFormSetField(form "current_layer" dislayer_list)
            axlFormSetField(form "current_layer" nil)
            _DSY_CreatCam()
            _DSY_CreatClp()
         t)   
         ("add"
            plag=0
            plag=_DSY_SL_ADD(laystate)
            if(plag!=1 
               then 
                   axlFormListDeleteAll(form "current_layer")
                   ;layerlist=axlGetParam("paramLayerGroup:etch")->groupMembers
                   ;foreach( selectlayer layerlist (axlFormSetField form "current_layer" selectlayer))
                   _DSY_Changname()
                   axlFormSetField(form "current_layer" dislayer_list)
                   axlFormSetField(form "current_layer" nil)
                   laystate=""
                   laystate = form->curValue
                   _DSY_CreatCam()
                   _DSY_CreatClp()
                   ;_DSY_SL_Cancel()
                   _DSY_cancel_caminit()
                   axlMsgPut("Add Done")
                );end_if   
         t)
         ("current_layer"	
            axlMsgPut("selected layer can be delete.")
            del_layer = form->curValue
         t)            
        ("del"
            _DSY_SL_delete(del_layer)
            if(rename_on==t
               then
               _DSY_del_rename()
               );end_if   
            _DSY_CreatCam()
            axlFormListDeleteAll(form "current_layer")
            ;layerlist=axlGetParam("paramLayerGroup:etch")->groupMembers
            ;foreach( selectlayer layerlist (axlFormSetField form "current_layer" selectlayer))
            _DSY_Changname()
            axlFormSetField(form "current_layer" dislayer_list)
            axlFormSetField(form "current_layer" nil)
            _DSY_CreatCam()
            _DSY_CreatClp()
            ;_DSY_SL_Cancel()
            axlMsgPut("Delete Done")
         t)   
        ("cancel" 
            _DSY_CreatCam()
            _DSY_CreatClp()
            _DSY_SL_Cancel()
         nil)   
	);end-case
    );end_prog	
);end-defunction _SL_State_CallBack()
;==================================================================
;			 _DSY_SL_Cancel()
;==========================================================================
defun( _DSY_SL_Cancel ()
        when( isFile( "sl_cn.form" )  deleteFile("sl_cn.form"))
        when( SL_SetState_Form_Ptr axlFormClose( SL_SetState_Form_Ptr ))
        axlClearSelSet()
        axlCancelEnterFun()
);end-defun _DSY_SL_Cancel
 
;==========================================================================
;                           _DSY_SL_ADD()
;==========================================================================
;defun( _DSY_SL_ADD (statepara)
;prog( ()
;   _DSY_PDGETC_ERR()
;;-------------add layer---------------------
;   layernum=1
;   IsBottom=0
;   while(IsBottom==0
;        i=1
;        if(next_layer=car(all_layer)!=" "
;           then
;              layernum=layernum+1
;              all_layer=cdr(all_layer)
;              if(all_layer==nil
;                 then
;                    IsBottom=1
;                );end_if
;           else
;             loop=1
;             new_Layer_name=nil
;             new_layer_list=nil
;             while(loop==1
;                  i=i+1
;                  next1_layer=nthelem(i all_layer)
;                  layernum=layernum+1
;                  when(next1_layer=="s" 
;                       if(layernum<10
;                          then
;                            sprintf(new_Layer_name,"%s%d","art0",layernum)
;                            new_layer_list=cons(new_Layer_name new_layer_list)
;                          else
;                            sprintf(new_Layer_name,"%s%d","art",layernum)
;                            new_layer_list=cons(new_Layer_name new_layer_list) 
;                          );end_if
;                       );end_when
;                  when(next1_layer=="g" 
;                       if(layernum<10
;                          then
;                            sprintf(new_Layer_name,"%s%d","gnd0",layernum)
;                            new_layer_list=cons(new_Layer_name new_layer_list)
;                          else
;                            sprintf(new_Layer_name,"%s%d","gnd",layernum)
;                            new_layer_list=cons(new_Layer_name new_layer_list) 
;                          );end_if
;                       );end_when 
;                  when(next1_layer=="p" 
;                       if(layernum<10
;                          then
;                            sprintf(new_Layer_name,"%s%d","power0",layernum)
;                            new_layer_list=cons(new_Layer_name new_layer_list)
;                          else
;                            sprintf(new_Layer_name,"%s%d","power",layernum)
;                            new_layer_list=cons(new_Layer_name new_layer_list) 
;                          );end_if
;                       );end_when                    
;                  ;把new_layer放入new_layer_list用when语句
;                  i=i+1
;                  next2_layer=nthelem(i all_layer)
;                  if(next2_layer!=" "
;                     then
;                        loop=0
;                        layernum=layernum+1
;                        i=i+1
;                        next3_layer=nthelem(i all_layer)
;                        if(next3_layer==nil
;                           then
;                              need_layer_name="BOTTOM"
;                              IsBottom=1
;                           else
;                              when(next2_layer=="s" 
;                                   if(layernum<10
;                                      then
;                                        sprintf(need_layer_name,"%s%d","art0",layernum)
;                                      else
;                                        sprintf(need_layer_name,"%s%d","art",layernum)
;                                      );end_if
;                                   );end_when
;                              when(next2_layer=="g" 
;                                   if(layernum<10
;                                      then
;                                        sprintf(need_layer_name,"%s%d","gnd0",layernum)
;                                      else
;                                        sprintf(need_layer_name,"%s%d","gnd",layernum)
;                                      );end_if
;                                   );end_when 
;                              when(next2_layer=="p" 
;                                   if(layernum<10
;                                      then
;                                        sprintf(need_layer_name,"%s%d","power0",layernum)
;                                      else
;                                        sprintf(need_layer_name,"%s%d","power",layernum)
;                                      );end_if
;                                   );end_when  
;                          );end_if
;                        creat_layer_list=reverse(new_layer_list) 
;                        ;foreach(layer_list new_layer_list
;                        ;        creat_layer_list=cons(layer_list creat_layer_list)
;                        ;        );end_foreach     
;                        
;                        foreach(new_Layer_name creat_layer_list
;                                if(getchar(new_Layer_name 1)=='a
;                                    then 
;                                     axlLayerCreateCrossSection(need_layer_name "Conductor" "Copper" new_Layer_name "Positive")              
;                                     ;axlShell("replay ./FR4.scr")
;                                     rpt = outfile("./FR4.scr")
;	                             fprintf(rpt "version 14.0\n\nsetwindow pcb\n\ndefine xsection\n")
;	                             fprintf(rpt "setwindow form.xsection \n")
;	                             fprintf(rpt "FORM xsection %s edit Insert \n" need_layer_name)
;	                             fprintf(rpt "FORM xsection done \n")
;	                             close(rpt)
;	                             axlShell("replay ./FR4.scr")
;	                             shell("rm ./FR4.scr")      
;
;                                   else
;                                     axlLayerCreateCrossSection(need_layer_name "Plane" "Copper" new_Layer_name "Negative")              
;                                     ;axlSell("replay ./FR4.scr")
;                                     rpt = outfile("./FR4.scr")
;	                             fprintf(rpt "version 14.0\n\nsetwindow pcb\n\ndefine xsection\n")
;	                             fprintf(rpt "setwindow form.xsection \n")
;	                             fprintf(rpt "FORM xsection %s edit Insert \n" need_layer_name)
;	                             fprintf(rpt "FORM xsection done \n")
;	                             close(rpt)
;	                             axlShell("replay ./FR4.scr")
;	                             shell("rm ./FR4.scr")      
;                                     
;                                     );end_"p"||"g"
;                                );endach 
;                       for(j 1 i-1        
;                           all_layer=cdr(all_layer)
;                           j++
;                           );end_for    
;                    );end_if next2_layer  
;                 );end_while loop 
;            );end_if next_layer     
;       );end_while isbottom          
;);end-prog
;);end-defun  _DSY_SL_ADD
;============================================================================
                      ;_DSY_PDGETC_ERR
;============================================================================
(defun _DSY_PDGETC_ERR ()
prog( ()
    if(statepara == "ss"||statepara == nil then
      ;_DSY_SL_ERROR()
      axlMsgPut("Don't have the demand of CREATE NEW LAYR") ;输出“没有新建层的要求”
      return(nil)
     );end_if

    alllayer = parseString(statepara "") 
    all_layer=cdr(alllayer)
;---------------------have or not "  "-----------------------------------------------------            
    Err_slash=0
    foreach(Err_letter all_layer
            if(Err_letter==" "
               then
                 Err_slash=Err_slash+1
                 if(Err_slash>1
                    then
                       _DSY_SL_ERROR()
                    );end_if
               else
                Err_slash=0
               );end_if 
           );end_foreach  
;----------------------have or not " s(bottom)"---------------------------------------------------            
    if(nthelem(1 alllayer)!="s"
     then 
         _DSY_SL_ERROR()
    );end_if
    
  Err_bottom=nil
  foreach(letter all_layer 
          Err_bottom=cons(letter Err_bottom)
          );end_foreach 
  if(nthelem(2 Err_bottom)==" "
     then 
         _DSY_SL_ERROR()
    );end_if
    
  if(nthelem(1 Err_bottom)!="s"
     then 
         _DSY_SL_ERROR()
    );end_if
;--------------------------------------------------------------------------------------------                    
   foreach(eachletter all_layer 
          if(eachletter!=" "&&eachletter!="p"&&eachletter!="s"&&eachletter!="g"
             then
                 _DSY_SL_ERROR()
             );end_if    
          );end_foreach 
;---------------ERR END--------------------------------   
));end_defun
;==================================================================
;			_DSY_SL_ERROR Function
;==================================================================
(defun _DSY_SL_ERROR ()
prog( ()
      axlMsgPut("The format of INPUT isn't right") ;输出“输入格式不对”
      return(nil)
);end-prog
);end-defun 
;==================================================================
;           _DSY_SL_delete()
;==================================================================
(defun _DSY_SL_delete (statepara)
prog( ()
    para1 = nthelem(2 parseString(statepara "-"))
    alllayer = parseString(para1 "") 
    all_layer=cdr(alllayer)
;----------get del_layer_list and del_fr4_list-------------  
   layernum=0
   del_fr4_list=nil
   layerlist=axlGetParam("paramLayerGroup:etch")->groupMembers
   foreach(del_fr4 layerlist
           layernum=layernum+1
           if(del_fr4==para1
              then
              sprintf(del_fr4_name,"%s%d","unnamed",layernum*2)
              );end_if
           );end_foreach  
   delete_now_layer=para1                                                                  
   rpt = outfile("./dellayer.scr")                                                                   
   fprintf(rpt "version 14.1\n\nsetwindow pcb\n\ntrapsize 1497\ndefine xsection\n")                                              
   fprintf(rpt "setwindow form.xsection \n")
   fprintf(rpt "FORM xsection %s edit Delete\n" del_fr4_name)
   axlVisibleDesign(nil)
   sprintf(vpin "PIN/%s" delete_now_layer)
   sprintf(vvia "VIA/%s" delete_now_layer)
   sprintf(vetch "ETCH/%s" delete_now_layer)
   sprintf(vantietch "ANTI ETCH/%s" delete_now_layer)
   axlVisibleLayer( vpin t )
   axlVisibleLayer( vetch t )
   axlVisibleLayer( vantietch t )
   axlSetFindFilter(?enabled list("noall" "pins" "vias" "clines" "lines" "Shapes" "text") ?onButtons list("noall" "pins" "vias" "clines" "lines" "Shapes" "text"))
   axlDeleteObject(axlGetSelSet(axlAddSelectAll()))
   fprintf(rpt "FORM xsection %s edit Delete\n" delete_now_layer)
   fprintf(rpt "FORM xsection done \n")                                                          
   close(rpt)                                                                             
   axlShell("replay ./dellayer.scr")                                           
   shell("rm ./dellayer.scr")                                                  
   ;axlFormListDeleteAll(form "current_layer")
   ;layerlist=axlGetParam("paramLayerGroup:etch")->groupMembers
   ;foreach( selectlayer layerlist (axlFormSetField form "current_layer" selectlayer))
 );end_prog	
);end-defunction _DSY_SL_delete()
;====================================================================                                                                               
               ;_DSY_CreatCam
;====================================================================                                                                               
(defun _DSY_CreatCam ()
prog( ()
     _DSY_Getlayer()
     _DSY_CreatCamtxt(_DSY_layername) 
));end__DSY_CreatCam 
;=============================================================================  
                    ;_DSY_Getlayer
;=============================================================================  
(defun _DSY_Getlayer ()
prog( ()
     _DSY_layername=nil
     _DSY_layername=axlGetParam("paramLayerGroup:etch")->groupMembers

));end__DSY_Getlayer     
;=============================================================================  
                    ;_DSY_CreatCamtxt
;=============================================================================  
(defun _DSY_CreatCamtxt (layername)
prog( ()
     deleteFile("./cam.txt")
     if(layername==nil
        then
           axlMsgPut("have not *.teach file.")
        else
           extrac_accuracy=nthelem(2 axlDBGetDesignUnits())
           if(extrac_accuracy==0||extrac_accuracy==1||extrac_accuracy==2||extrac_accuracy==3 
              then
                case(extrac_accuracy
                    (0
                    ExtraAccuracy=8
                    )
                    (1
                     ExtraAccuracy=80
                    t)
                    (2
                     ExtraAccuracy=800
                    t)
                    (3
                     ExtraAccuracy=8000
                    t)
                    );end_case           
                rpt=outfile("./cam.txt")
                i=0
                foreach(eachname layername
                   case(car(parseString(eachname ""))
                       ("T"
                        i=i+1
                        fprintf(rpt "(axlfcreate \"art01\" '(0 0 0 %d 0 1 0 0 0 0 0 0 0) '(\"VIA CLASS/TOP\" \"PIN/TOP\" \"ETCH/TOP\" \"BOARD GEOMETRY/OUTLINE\" ))\n",ExtraAccuracy)
                       t)
                       ("B"
                        i=i+1
                        if(i<10
                           then
                             sprintf(camlayer,"%s%d","art0",i)
                             fprintf(rpt "(axlfcreate \"%s\" '(0 0 0 %d 0 1 1 0 0 0 0 0 0) '(\"VIA CLASS/BOTTOM\" \"PIN/BOTTOM\" \"ETCH/BOTTOM\" \"BOARD GEOMETRY/OUTLINE\" ))\n",camlayer,ExtraAccuracy)
                           else                                                                                                                                                                        
                             sprintf(camlayer,"%s%d","art",i)                                                                                                                                          
                             fprintf(rpt "(axlfcreate \"%s\" '(0 0 0 %d 0 1 1 0 0 0 0 0 0) '(\"VIA CLASS/BOTTOM\" \"PIN/BOTTOM\" \"ETCH/BOTTOM\" \"BOARD GEOMETRY/OUTLINE\" ))\n",camlayer,ExtraAccuracy)
                          );end_if
                       t)   
                       ("A"
                        i=i+1
                        if(i<10
                           then
                             sprintf(camlayer,"%s%d","art0",i)
                             fprintf(rpt "(axlfcreate \"%s\" '(0 0 0 %d 0 1 0 0 0 0 0 0 0) '(\"VIA CLASS/%s\" \"PIN/%s\" \"ETCH/%s\" \"BOARD GEOMETRY/OUTLINE\" ))\n",camlayer,ExtraAccuracy,eachname,eachname,eachname,eachname)
                           else                                                                                                                                                            
                             sprintf(camlayer,"%s%d","art",i)                                                                                                                              
                             fprintf(rpt "(axlfcreate \"%s\" '(0 0 0 %d 0 1 0 0 0 0 0 0 0) '(\"VIA CLASS/%s\" \"PIN/%s\" \"ETCH/%s\" \"BOARD GEOMETRY/OUTLINE\" ))\n",camlayer,ExtraAccuracy,eachname,eachname,eachname,eachname)
                          );end_if
                       t)
                       ("P"
                        i=i+1
                        if(i<10
                           then
                             sprintf(camlayer,"%s%d","pgp0",i)
                             fprintf(rpt "(axlfcreate \"%s\" '(0 0 0 %d 0 0 0 0 0 0 0 0 0) '(\"ANTI ETCH/%s\" \"VIA CLASS/%s\" \"PIN/%s\" \"ETCH/%s\" \"BOARD GEOMETRY/OUTLINE\" \"ANTI ETCH/ALL\" ))\n",camlayer,ExtraAccuracy,eachname,eachname,eachname,eachname)
                           else                                                                                                                                                                                               
                             sprintf(camlayer,"%s%d","pgp",i)                                                                                                                                                                 
                             fprintf(rpt "(axlfcreate \"%s\" '(0 0 0 %d 0 0 0 0 0 0 0 0 0) '(\"ANTI ETCH/%s\" \"VIA CLASS/%s\" \"PIN/%s\" \"ETCH/%s\" \"BOARD GEOMETRY/OUTLINE\" \"ANTI ETCH/ALL\" ))\n",camlayer,ExtraAccuracy,eachname,eachname,eachname,eachname)
                          );end_if                                                                                                                                                                                            
                       t)                                                                                                                                                                                                     
                       ("G"                                                                                                                                                                                                   
                        i=i+1                                                                                                                                                                                                 
                        if(i<10                                                                                                                                                                                               
                           then                                                                                                                                                                                               
                             sprintf(camlayer,"%s%d","pgp0",i)                                                                                                                                                                
                             fprintf(rpt "(axlfcreate \"%s\" '(0 0 0 %d 0 0 0 0 0 0 0 0 0) '(\"ANTI ETCH/%s\" \"VIA CLASS/%s\" \"PIN/%s\" \"ETCH/%s\" \"BOARD GEOMETRY/OUTLINE\" \"ANTI ETCH/ALL\" ))\n",camlayer,ExtraAccuracy,eachname,eachname,eachname,eachname)
                           else                                                                                                                                                                                               
                             sprintf(camlayer,"%s%d","pgp",i)                                                                                                                                                                 
                             fprintf(rpt "(axlfcreate \"%s\" '(0 0 0 %d 0 0 0 0 0 0 0 0 0) '(\"ANTI ETCH/%s\" \"VIA CLASS/%s\" \"PIN/%s\" \"ETCH/%s\" \"BOARD GEOMETRY/OUTLINE\" \"ANTI ETCH/ALL\" ))\n",camlayer,ExtraAccuracy,eachname,eachname,eachname,eachname)
                          );end_if
                       t)         
                     );end_case
                  );end_foreach   
                fprintf(rpt "(axlfcreate \"adt\" '(0 0 0 %d 0 1 0 0 0 0 0 0 0) '(\"REF DES/SILKSCREEN_TOP\" \"PIN/TOP\" \"PACKAGE GEOMETRY/ASSEMBLY_TOP\" \"PACKAGE GEOMETRY/SILKSCREEN_TOP\" \"BOARD GEOMETRY/SILKSCREEN_TOP\" \"BOARD GEOMETRY/OUTLINE\" ))\n",ExtraAccuracy)
                fprintf(rpt "(axlfcreate \"adb\" '(0 0 0 %d 0 1 1 0 0 0 0 0 0) '(\"REF DES/SILKSCREEN_BOTTOM\" \"PIN/BOTTOM\" \"PACKAGE GEOMETRY/ASSEMBLY_BOTTOM\" \"PACKAGE GEOMETRY/SILKSCREEN_BOTTOM\" \"BOARD GEOMETRY/SILKSCREEN_BOTTOM\" \"BOARD GEOMETRY/OUTLINE\" ))\n",ExtraAccuracy)
                fprintf(rpt "(axlfcreate \"silktop\" '(0 0 0 %d 0 1 0 0 0 0 0 0 0) '(\"REF DES/SILKSCREEN_TOP\" \"PACKAGE GEOMETRY/SILKSCREEN_TOP\" \"BOARD GEOMETRY/SILKSCREEN_TOP\" \"BOARD GEOMETRY/OUTLINE\" ))\n",ExtraAccuracy)
                fprintf(rpt "(axlfcreate \"silkbotm\" '(0 0 0 %d 0 1 1 0 0 0 0 0 0) '(\"REF DES/SILKSCREEN_BOTTOM\" \"PACKAGE GEOMETRY/SILKSCREEN_BOTTOM\" \"BOARD GEOMETRY/SILKSCREEN_BOTTOM\" \"BOARD GEOMETRY/OUTLINE\" ))\n",ExtraAccuracy)
                fprintf(rpt "(axlfcreate \"soldtop\" '(0 0 0 %d 0 1 0 0 0 0 0 0 0) '(\"VIA CLASS/SOLDERMASK_TOP\" \"PIN/SOLDERMASK_TOP\" \"PACKAGE GEOMETRY/SOLDERMASK_TOP\" \"BOARD GEOMETRY/OUTLINE\" \"BOARD GEOMETRY/SOLDERMASK_TOP\" ))\n",ExtraAccuracy)
                fprintf(rpt "(axlfcreate \"soldbotm\" '(0 0 0 %d 0 1 1 0 0 0 0 0 0) '(\"VIA CLASS/SOLDERMASK_BOTTOM\" \"PIN/SOLDERMASK_BOTTOM\" \"PACKAGE GEOMETRY/SOLDERMASK_BOTTOM\" \"BOARD GEOMETRY/OUTLINE\" \"BOARD GEOMETRY/SOLDERMASK_BOTTOM\" ))\n",ExtraAccuracy)
                fprintf(rpt "(axlfcreate \"pasttop\" '(0 0 0 %d 0 1 0 0 0 0 0 0 0) '(\"PIN/PASTEMASK_TOP\" \"PACKAGE GEOMETRY/DISPLAY_TOP\" \"BOARD GEOMETRY/OUTLINE\" ))\n",ExtraAccuracy)
                fprintf(rpt "(axlfcreate \"pastbotm\" '(0 0 0 %d 0 1 1 0 0 0 0 0 0) '(\"PIN/PASTEMASK_BOTTOM\" \"PACKAGE GEOMETRY/DISPLAY_BOTTOM\" \"BOARD GEOMETRY/OUTLINE\" ))\n",ExtraAccuracy)
                fprintf(rpt "(axlfcreate \"drill\" '(0 0 0 %d 0 1 0 0 0 0 0 1 1) '(\"MANUFACTURING/NCDRILL_LEGEND\" \"MANUFACTURING/NCDRILL_FIGURE\" \"BOARD GEOMETRY/OUTLINE\" \"BOARD GEOMETRY/DIMENSION\" ))\n",ExtraAccuracy)
                close(rpt) 
            else
                axlMsgPut("Please set accuracy with 0 1 2 3") 
           );end_if
     );end_if
));end_defun _DSY_CreatCamtxt  
;===================================================================
;           _DSY_CreatClp
;===================================================================
(defun _DSY_CreatClp () 
prog( ()  
     board_name=axlCurrentDesign()
     boardname=upperCase(board_name)
     vers="1"
     sprintf(clptxt,"./%s.clp",boardname)
     rpt=outfile(clptxt)
     fprintf(rpt "(setq _clp_lay_drw (axlDesignType nil))                                                             \n")
     fprintf(rpt "(setq _clp_sym nil)                                                                                 \n")
     fprintf(rpt "(setq _clp_pbuf nil)                                                                                \n")
     fprintf(rpt "(setq _clp_cinfo (make_clp_coord_info))                                                             \n")
     fprintf(rpt "(putprop _clp_cinfo 0.0 'f_rotation)                                                                \n")
     fprintf(rpt "(putprop _clp_cinfo '(0.0 0.0) 'l_origin)                                                           \n")
     fprintf(rpt "(setq _clp_text_orient (make_axlTextOrientation))                                                   \n")
     fprintf(rpt "(setq _clp_pin_text (make_axlPinText))                                                              \n")
     fprintf(rpt "(putprop _clp_cinfo  \"mils\" 't_from_units)                                                        \n")
     fprintf(rpt "(putprop _clp_cinfo (car (axlDBGetDesignUnits)) 't_to_units)                                        \n")
     fprintf(rpt "(setq _clp_group_info (make_clp_group_info))                                                        \n")
     fprintf(rpt "(putprop _clp_cinfo _clp_group_info 'group_info)                                                    \n")
     fprintf(rpt "(setq _clp_accuracy 1)                                                                              \n")
     fprintf(rpt "(_clpCheckAccuracy _clp_accuracy (get _clp_cinfo 't_from_units)	 (get _clp_cinfo 't_to_units))\n")
     fprintf(rpt "(putprop _clp_cinfo (list (_clpAdjustPt -2275:-948.3 _clp_cinfo)                                \n")
     fprintf(rpt "	(_clpAdjustPt 2175:600 _clp_cinfo)) 'l_extents)                                         \n")
     fprintf(rpt "(putprop _clp_cinfo (_clpAdjustPt '(0 -1118.25) _clp_cinfo) 'l_zeropt)                              \n")
     fprintf(rpt "(unless (_clpSelectRotOrg _clp_cinfo)                                                               \n")
     fprintf(rpt " (error \"CANCEL\"))                                                                                  \n")

     fprintf(rpt " (setq _clp_clip_prop_value (_clpGetClipPropValue))                                                 \n")
     fprintf(rpt "(_clpInitTextOrientation _clp_text_orient \"LEFT\" nil (get _clp_cinfo 'f_rotation) + 0.000000 \"8\" )  \n")
     fprintf(rpt "(setq _clp_dbid (_clpDBCreateText \"%s.%s\"                                                           \n",boardname, vers)
     fprintf(rpt "(_clpAdjustPt 100:300 _clp_cinfo)  _clp_text_orient                                                \n")
     fprintf(rpt "\"PACKAGE GEOMETRY/SILKSCREEN_TOP\" _clp_sym))                                                        \n")
     fprintf(rpt "(_clpInitTextOrientation _clp_text_orient \"LEFT\" nil (get _clp_cinfo 'f_rotation) + 0.000000 \"8\" )  \n")

     _DSY_Getlayer();_DSY_layername
     i=0 
     j=300
     foreach(everylayer _DSY_layername 
            i=i+1                
             j=j-200
             if(car(parseString(everylayer ""))=="T"
                then 
                   fprintf(rpt "(_clpInitTextOrientation _clp_text_orient \"LEFT\" nil (get _clp_cinfo 'f_rotation) + 0.000000 \"8\" )  \n")
                   fprintf(rpt "(_clpInitTextOrientation _clp_text_orient \"LEFT\" nil (get _clp_cinfo 'f_rotation) + 0.000000 \"8\" )  \n")
                   fprintf(rpt "(setq _clp_dbid (_clpDBCreateText \"%s.%s ARTWORK TOP\"                                               \n",boardname, vers)
                   fprintf(rpt "(_clpAdjustPt 100:%d _clp_cinfo)  _clp_text_orient                                                   \n",j)
                   fprintf(rpt "\"ETCH/TOP\" _clp_sym))                                                                               \n")
               );end_if
               
             if(car(parseString(everylayer ""))=="A" 
                then 
                  fprintf(rpt "(_clpInitTextOrientation _clp_text_orient \"LEFT\" nil (get _clp_cinfo 'f_rotation) + 0.000000 \"8\" )  \n")
                  if(i<10
                     then 
                       sprintf(camlayer,"%s%d","LAYER0",i)  
                     else
                       sprintf(camlayer,"%s%d","LAYER",i)  
                    );end_if
                  fprintf(rpt "(setq _clp_dbid (_clpDBCreateText \"%s.%s ARTWORK %s\"                                             \n",boardname, vers,camlayer)
                   fprintf(rpt "(_clpAdjustPt 100:%d _clp_cinfo)  _clp_text_orient                                                   \n",j)
                  fprintf(rpt "\"ETCH/%s\" _clp_sym))                                                                             \n",everylayer)
                );end_if
                
             if(car(parseString(everylayer ""))=="P"
                then 
                  fprintf(rpt "(_clpInitTextOrientation _clp_text_orient \"LEFT\" nil (get _clp_cinfo 'f_rotation) + 0.000000 \"8\" )  \n")
                  if(i<10
                     then 
                       sprintf(camlayer,"%s%d","PLANE0",i)  
                     else
                       sprintf(camlayer,"%s%d","PLANE",i)  
                    );end_if
                   fprintf(rpt "(setq _clp_dbid (_clpDBCreateText \"%s.%s POWER %s\"                                             \n",boardname, vers,camlayer)
                   fprintf(rpt "(_clpAdjustPt 100:%d _clp_cinfo)  _clp_text_orient                                                   \n",j)
                   fprintf(rpt "\"ETCH/%s\" _clp_sym))                                                                           \n",everylayer)
                );end_if
                
             if(car(parseString(everylayer ""))=="G"
                then 
                  fprintf(rpt "(_clpInitTextOrientation _clp_text_orient \"LEFT\" nil (get _clp_cinfo 'f_rotation) + 0.000000 \"8\" )  \n")
                  if(i<10
                     then 
                       sprintf(camlayer,"%s%d","PLANE0",i)  
                     else
                       sprintf(camlayer,"%s%d","PLANE",i)  
                    );end_if
                   fprintf(rpt "(setq _clp_dbid (_clpDBCreateText \"%s.%s GROUND %s\"                                              \n",boardname, vers,camlayer)
                   fprintf(rpt "(_clpAdjustPt 100:%d _clp_cinfo)  _clp_text_orient                                                   \n",j)
                   fprintf(rpt "\"ETCH/%s\" _clp_sym))                                                                             \n",everylayer)
                );end_if
                
             if(car(parseString(everylayer ""))=="B" 
                then                
                   fprintf(rpt "(_clpInitTextOrientation _clp_text_orient \"LEFT\" t (get _clp_cinfo 'f_rotation) + 0.000000 \"8\" )  \n")
                   fprintf(rpt "(setq _clp_dbid (_clpDBCreateText \"%s.%s ARTWORK BOTTOM\"                                            \n",boardname, vers)
                   fprintf(rpt "(_clpAdjustPt -100:%d _clp_cinfo)  _clp_text_orient                                                   \n",j)
                   fprintf(rpt "\"ETCH/BOTTOM\" _clp_sym))                                                                            \n")
                );end_if
           );end_foreach

     j=j-200
     fprintf(rpt "(_clpInitTextOrientation _clp_text_orient \"LEFT\" nil (get _clp_cinfo 'f_rotation) + 0.000000 \"8\" )  \n")
     fprintf(rpt "(setq _clp_dbid (_clpDBCreateText \"%s.%s SOLDMASK TOP\"                                              \n",boardname, vers)
     fprintf(rpt "(_clpAdjustPt 100:%d _clp_cinfo)  _clp_text_orient                                                 \n",j)
     fprintf(rpt "\"PACKAGE GEOMETRY/SOLDERMASK_TOP\" _clp_sym))                                                        \n")

     fprintf(rpt "(_clpInitTextOrientation _clp_text_orient \"LEFT\" t (get _clp_cinfo 'f_rotation) + 0.000000 \"8\" )    \n")
     fprintf(rpt "(setq _clp_dbid (_clpDBCreateText \"%s.%s SOLDMASK BOTTOM\"                                           \n",boardname, vers)
     fprintf(rpt "(_clpAdjustPt -100:%d _clp_cinfo)  _clp_text_orient                                                 \n",j)
     fprintf(rpt "\"PACKAGE GEOMETRY/SOLDERMASK_BOTTOM\" _clp_sym))                                                     \n")

     j=j-200
     fprintf(rpt "(_clpInitTextOrientation _clp_text_orient \"LEFT\" nil (get _clp_cinfo 'f_rotation) + 0.000000 \"8\" )  \n")
     fprintf(rpt "(setq _clp_dbid (_clpDBCreateText \"%s.%s PASTEMASK TOP\"                                             \n",boardname, vers)
     fprintf(rpt "(_clpAdjustPt 100:%d _clp_cinfo)  _clp_text_orient                                                 \n",j)
     fprintf(rpt "\"PACKAGE GEOMETRY/DISPLAY_TOP\" _clp_sym))                                                           \n")

     fprintf(rpt "(_clpInitTextOrientation _clp_text_orient \"LEFT\" t (get _clp_cinfo 'f_rotation) + 0.000000 \"8\" )    \n")
     fprintf(rpt "(setq _clp_dbid (_clpDBCreateText \"%s.%s PASTEMASK BOTTOM\"                                          \n",boardname, vers)
     fprintf(rpt "(_clpAdjustPt -100:%d _clp_cinfo)  _clp_text_orient                                                 \n",j)
     fprintf(rpt "\"PACKAGE GEOMETRY/DISPLAY_BOTTOM\" _clp_sym))                                                      \n")

     j=j-200
     fprintf(rpt "(_clpInitTextOrientation _clp_text_orient \"LEFT\" nil (get _clp_cinfo 'f_rotation) + 0.000000 \"8\" )  \n")
     fprintf(rpt "(setq _clp_dbid (_clpDBCreateText \"%s.%s SILKSCREEN TOP\"                                            \n",boardname, vers)
     fprintf(rpt "(_clpAdjustPt 100:%d _clp_cinfo)  _clp_text_orient                                                 \n",j)
     fprintf(rpt "\"PACKAGE GEOMETRY/SILKSCREEN_TOP\" _clp_sym))                                                        \n")

     fprintf(rpt "(_clpInitTextOrientation _clp_text_orient \"LEFT\" t (get _clp_cinfo 'f_rotation) + 0.000000 \"8\" )    \n")
     fprintf(rpt "(setq _clp_dbid (_clpDBCreateText \"%s.%s SILKSCREEN BOTTOM\"                                         \n",boardname, vers)
     fprintf(rpt "(_clpAdjustPt -100:%d _clp_cinfo)  _clp_text_orient                                                 \n",j)
     fprintf(rpt "\"PACKAGE GEOMETRY/SILKSCREEN_BOTTOM\" _clp_sym))                                                     \n")

     j=j-200
     fprintf(rpt "(_clpInitTextOrientation _clp_text_orient \"LEFT\" nil (get _clp_cinfo 'f_rotation) + 0.000000 \"8\" )  \n")
     fprintf(rpt "(setq _clp_dbid (_clpDBCreateText \"%s.%s DRILL CHART\"                                        \n",boardname, vers)
     fprintf(rpt "(_clpAdjustPt 100:%d _clp_cinfo)  _clp_text_orient                                                 \n",j)
     fprintf(rpt "\"BOARD GEOMETRY/DIMENSION\" _clp_sym))                                                             \n")                                 
     
     i=0 
     foreach(everylayer _DSY_layername 
             i=i+1
             j=j-200
             fprintf(rpt "(_clpInitTextOrientation _clp_text_orient \"LEFT\" nil (get _clp_cinfo 'f_rotation) + 0.000000 \"8\" )  \n")
             when(car(parseString(everylayer ""))=="T"
                fprintf(rpt "(setq _clp_dbid (_clpDBCreateText \"%d--ARTWORK TOP\"                                                  \n",i)
                );end_when
             when(car(parseString(everylayer ""))=="A"
                  if(i<10
                     then 
                       sprintf(camlayer,"%s%d","LAYER0",i)  
                     else
                       sprintf(camlayer,"%s%d","LAYER",i)  
                    );end_if
                fprintf(rpt "(setq _clp_dbid (_clpDBCreateText \"%d--ARTWORK %s\"                                                  \n",i,camlayer)
                );end_when    
             when(car(parseString(everylayer ""))=="P"
                  if(i<10
                     then 
                       sprintf(camlayer,"%s%d","PLANE0",i)  
                     else
                       sprintf(camlayer,"%s%d","PLANE",i)  
                    );end_if
                   fprintf(rpt "(setq _clp_dbid (_clpDBCreateText \"%d--POWER %s\"                                                  \n",i,camlayer)
                );end_when
             when(car(parseString(everylayer ""))=="G"
                  if(i<10
                     then 
                       sprintf(camlayer,"%s%d","PLANE0",i)  
                     else
                       sprintf(camlayer,"%s%d","PLANE",i)  
                    );end_if
                   fprintf(rpt "(setq _clp_dbid (_clpDBCreateText \"%d--GROUND %s\"                                                  \n",i,camlayer)
                );end_when
             when(car(parseString(everylayer ""))=="B"
                fprintf(rpt "(setq _clp_dbid (_clpDBCreateText \"%d--ARTWORK BOTTOM\"                                                  \n",i)
                );end_when
             fprintf(rpt "(_clpAdjustPt 100:%d _clp_cinfo)  _clp_text_orient                                               \n",j)
             fprintf(rpt "\"BOARD GEOMETRY/DIMENSION\" _clp_sym))                                                               \n")
             );end_foreach        
   fprintf(rpt "(axlMsgPut (list \"Text pasted without CLIP_DRAWING property.\" _clpAxlMsg.classWarn))                \n")
   fprintf(rpt "(_clpDisplayMessage)                                                                                \n")
   fprintf(rpt "(axlFlushDisplay)                                                                                    \n")
   close(rpt)                                                                                            
));end_defun_DSY_CreatClp     
;====================================================================================
                      ;_DSY_Changname()
;====================================================================================
(defun _DSY_Changname ()                                                               
prog( ()                                                                               
   layerlist=axlGetParam("paramLayerGroup:etch")->groupMembers                         
   i=0                                                                                 
   dislayer_listtemp=nil                                                               
   dislayer_list=nil                                                                   
   foreach(dislayer layerlist                                                          
           i=i+1                                                               
           if(i<10                                                             
              then                                                             
                sprintf(dis_layer "0%d--%s",i,dislayer)                        
                dislayer_listtemp=cons(dis_layer dislayer_listtemp)            
              else                                                             
                sprintf(dis_layer "%d--%s",i,dislayer)                         
                dislayer_listtemp=cons(dis_layer dislayer_listtemp)            
             );end_if                                                          
           );end_foreach                                                               
   dislayer_list=reverse(dislayer_listtemp)                                    
));end_defun                                                                           

;====================================================================================
                      ;_DSY_SL_ADD()
;====================================================================================
(defun _DSY_SL_ADD (statepara)
prog( ()  
    alllayer = parseString(statepara "") 
    foreach(eachletter alllayer 
          if(eachletter!=" "&&eachletter!="p"&&eachletter!="s"&&eachletter!="g"
             then
                _DSY_SL_ERROR()
                return(1)
             );end_if    
          );end_foreach 
    if(nthelem(1 alllayer)!="s"
       then 
         _DSY_SL_ERROR()
         return(1)
       );end_if
    ERR_BOTTOM=reverse(alllayer)
    if(nthelem(1 ERR_BOTTOM)!="s"
       then 
         _DSY_SL_ERROR()
         return(1)
       );end_if
;-----------------end pd_inputerr-----------    
    layernum=0
    new_layer_list=nil
    foreach(layertemp alllayer
            when(layertemp=="s"
                 layernum++
                 if(layernum!=1&&layernum!=0
                    then
                      if(layernum<10
                         then
                           sprintf(new_Layer_name,"%s%d","art0",layernum)
                           new_layer_list=cons(new_Layer_name new_layer_list)
                         else
                           sprintf(new_Layer_name,"%s%d","art",layernum)
                           new_layer_list=cons(new_Layer_name new_layer_list) 
                         );end_if
                      );end_if   
                 );end_when      
            when(layertemp=="g"
                 layernum++
                 if(layernum<10
                    then
                      sprintf(new_Layer_name,"%s%d","gnd0",layernum)
                      new_layer_list=cons(new_Layer_name new_layer_list)
                    else
                      sprintf(new_Layer_name,"%s%d","gnd",layernum)
                      new_layer_list=cons(new_Layer_name new_layer_list) 
                    );end_if
                 );end_when      
            when(layertemp=="p"
                 layernum++
                 if(layernum<10
                    then
                      sprintf(new_Layer_name,"%s%d","power0",layernum)
                      new_layer_list=cons(new_Layer_name new_layer_list)
                    else
                      sprintf(new_Layer_name,"%s%d","power",layernum)
                      new_layer_list=cons(new_Layer_name new_layer_list) 
                    );end_if
                 );end_when
             );end_foreach    
         new_layer_list=cdr(new_layer_list)
         add_layer_list=reverse(new_layer_list)      
         _DSY_CreatNewlayer(add_layer_list)       
));end_defun _DSY_SL_ADD
;====================================================================================
                      ;_DSY_CreatNewlayer()
;====================================================================================
(defun _DSY_CreatNewlayer (listpara)
prog( ()  
    rpt = outfile("./creatlayer.scr")
    fprintf(rpt "version 14.1\n\nsetwindow pcb\n\ndefine xsection\n")
    fprintf(rpt "setwindow form.xsection \n")                        
    i=2
    foreach(need_layer_name listpara  
            j=i*2+1                                                    
            fprintf(rpt "FORM xsection bottom edit Insert \n")
            if(car(parseString(need_layer_name ""))=="a"
               then
                  fprintf(rpt "FORM xsection unnamed%d etch_material COPPER \n",j )
                  fprintf(rpt "FORM xsection unnamed%d layer_type Conductor\n",j )
                  fprintf(rpt "FORM xsection unnamed%d etch_subc_name %s \n",j,need_layer_name )
                  i++
               );end_if
            if(car(parseString(need_layer_name ""))=="p"||car(parseString(need_layer_name ""))=="g"
               then
                  fprintf(rpt "FORM xsection unnamed%d etch_material COPPER \n",j )
                  fprintf(rpt "FORM xsection unnamed%d layer_type Plane\n",j )
                  fprintf(rpt "FORM xsection unnamed%d etch_subc_name %s \n",j,need_layer_name )
                  fprintf(rpt "FORM xsection %s film_type Negative      \n",need_layer_name)
                  i++
               );end_if
            fprintf(rpt "FORM xsection bottom edit Insert \n")
             );end_foreach  
    fprintf(rpt "FORM xsection done \n")                                  
    close(rpt)                                                            
    axlShell("replay ./creatlayer.scr")                                
    shell("rm ./creatlayer.scr")                                       
));end_defun _DSY_CreatNewlayer                                        
;=================================================
;_DSY_del_rename()
;=================================================
(defun _DSY_del_rename ()
prog( ()
   layerlist=axlGetParam("paramLayerGroup:etch")->groupMembers
   i=1
   rpt=outfile("./rename.scr")
   fprintf(rpt "version 14.1\n\nsetwindow pcb\ntrapsize 35565\ndefine xsection\n")
   fprintf(rpt "setwindow form.xsection \n")                        
   foreach(re_each layerlist
           re_list = parseString(re_each "") 
           re_listtemp = reverse(re_list)
           re_listtemp=cdr(re_listtemp)
           re_listtemp=cdr(re_listtemp)
           re_name=buildString(reverse(re_listtemp) "")
           if(car(re_list)!="B"
              then
                if(car(re_list)!="T" 
                   then
                      i++
                      if(i<10
                         then
                            sprintf(tailnum "0%d",i)
                         else
                            sprintf(tailnum "%d",i)
                         );end_if
                      rename=strncat(re_name tailnum 2)
                      fprintf(rpt "FORM xsection %s etch_subc_name %s \n",re_each,rename)                        
                   );end_if
              );end_if
           );end_foreach
   fprintf(rpt "FORM xsection done \n") 
   close(rpt)                                                            
   axlShell("replay ./rename.scr")                                
   shell("rm ./creatlayer.scr")                                       
));end__DSY_del_rename
;=================================================
;                  _DSY_cancel_caminit()
;=================================================
(defun _DSY_cancel_caminit ()
prog( ()
let( (nParaStateTemp nParaStatet)
     nParaStateTemp=nil
     nParaStateTemp=axlGetParam("paramLayerGroup:etch")->groupMembers
     nParaState=reverse(nParaStateTemp)
     rpt=outfile("./cancelCaminit.scr")
     fprintf(rpt "version 14.1\n\nsetwindow pcb\ntrapsize 13240\n")  
     fprintf(rpt "film param                                   \n")  
     fprintf(rpt "setwindow form.film_control                  \n")  
     fprintf(rpt "FORM film_control filmtree  BOTTOM           \n")  
     foreach(eachStatePara  nParaState
             fprintf(rpt "FORM film_control filmtree popup Cut %s \n",eachStatePara)  
             );end_foreach   
     fprintf(rpt "FORM film_control filmtree popup Cut TOP \n")  
     fprintf(rpt "FORM film_control load                   \n")
     fprintf(rpt "fillin \"cam.txt\"                       \n")
     fprintf(rpt "FORM film_control filmtree  TOP          \n")
     fprintf(rpt "FORM film_control filmtree popup Cut TOP \n")
     fprintf(rpt "FORM film_control ok                     \n")
     close(rpt)
     axlShell("replay ./cancelCaminit.scr")                                           
     shell("rm ./cancelCaminit.scr")                                                  
);end_let
));end_defun  _DSY_cancel_caminit                                                                    
                                                                                                               
                                                                      
                                                                      
                                                                      
                                                                      
                                                                      
 
                         









                                                           
                                                           
                                                           
                                                           
                                                           
                                                           
                                                           
                                                           


































































































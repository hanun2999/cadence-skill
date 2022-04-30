;+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
;
;	Author: Sky Liu
;		AE for Graser (agent for Cadence)
;		mobile:13510590862
;             Email: sky048@126.com
;	File Name:  textexact.il
;	Revision 0: January 11,2005
;
;	
;	Purpose: 
;             To allow the User to export one design`s text on special layer ,then import it to another design
;		
;	Usage: 
;		1.add load("textoutin.il") line in the allegro.ilinit locate on pcbenv directiory.
;             2.enter "text_out_in" in the command line	
;		
;	Special notes:
;		1.when import filed be hit,a dialog will be display ,
;		2. you must export text one layer by layer
;		3. tow design must be of the same orign
;             
;


axlCmdRegister( "text_out_in" `Texthandle)

defun( Texthandle ()
       TexthandleMakeFormFile()
       form = axlFormCreate( (gensym) "textinorout.form" `(e outer) `TexthandleCallBk t)
       Skill_Programs_Form=form
       (axlFormSetField Skill_Programs_Form "Directory" "textfile.txt")
       (axlFormBuildPopup Skill_Programs_Form "layer" 
                                      `(
                                         ("PACKAGE GEOMETRY/SILKSCREEN_TOP" "PACKAGE GEOMETRY/SILKSCREEN_TOP") 
                                         ("PACKAGEGEOMETRY/SILKSCREEN_BOTTOM" "PACKAGEGEOMETRY/SILKSCREEN_BOTTOM") 
                                         ("REF DES/SILKSCREEN_TOP" "REF DES/SILKSCREEN_TOP") 
                                         ("REF DES/SILKSCREEN_BOTTOM" "REF DES/SILKSCREEN_BOTTOM")))
       (axlFormSetField Skill_Programs_Form "layer" "REF DES/SILKSCREEN_TOP")


  
       axlFormDisplay( form)
);enddefun

defun( TexthandleCallBk (form)
        case( get( Skill_Programs_Form `curField)

             ( "Import"

                  axlClearSelSet()
                  textlist=nil
                  b=outfile("error.txt")
                  textname=nil
                  textxy=nil
                  textrotation=nil
                  alldone=nil
                  dx=nil
                  dy=nil
                  
                  textnotfound="this name have found in the database:\n"
                  notfoundtext=outfile("Nfoundtext.txt")
                  fprintf(notfoundtext textnotfound)
                  
                  if( isFile("textfile.txt") then

                     ;Origndeff = axlUIPrompt("Enter tow orign distancex,y:" "")
                     
                           ;deff=parseString(Origndeff ",")
                           ;dx=car(deff)
                           ;dy=car(cdr(deff))
                    
                           
                     
                     textfilein=infile("./textfile.txt")                
                     textline=parseString(gets(S textfilein) "_")  ;R1 1,2 90
                     axlClearSelSet()
                     axlSetFindFilter( ?enabled (list "noall" "invisible" "text")
                                             ?onButtons (list "text")
                                           )
                     textlist = axlGetSelSet( axlAddSelectAll() )
                     
                     while( alldone==nil

                                textname=car(textline)
                                textnamelen=strlen(textname)   ;LENGTH   2
                                textname=substring(textname 1 textnamelen-1)
                                textxy=car(cdr(textline))  ; 1,2
                                textrotation=cdr(cdr(textline))
                                textrotation=car(textrotation)  ;90
                                
                                ;axlMsgPut("textline now is:%L %L %s" textline 
                                ;s=sprintf(s "textline now is:%L %L %s\n"  textline 
                                ;fprintf(b s)

                                found=nil
                                good=nil
                                ;axlMsgPut("%L " textline)
                                
                                foreach( onetext textlist
                                     if( onetext->objType == "text" && onetext->layer  == axlFormGetField( Skill_Programs_Form "layer") then 
                                       ; || onetext->layer  == "PACKAGE GEOMETRY/ASSEMBLY_BOTTOM" || 
                                        ; onetext->layer  == "REF DES/ASSEMBLY_TOP" || onetext->layer  == "REF DES/ASSEMBLY_BOTTOM" then
                                        if( onetext->text == textname then
                                            found=t
                                            good=t
                                            ;axlMsgPut("onetext->text is:%s" onetext->text)
                                            s=sprintf(s "tonetext->text is:%s\n"  onetext->text)
                                            fprintf(b s)
                                         );endifonetext
                                         
                                    
                                        if( good==t then
                                            good=nil
                                            xloc=nil 
                                            yloc=nil
                                            loc=list()
                                            locstr1=nil
                                            loc1=list()
                                            
                                            xy          = onetext->xy
                                            text        = onetext->text
                                            textBlock   = onetext->textBlock   
                                            rotation    = onetext->rotation
                                            parent_dbid = onetext->parent
                                            isMirrored  = onetext->isMirrored    ; t/nil 
                                            justify     = onetext->justify       ; "LEFT" "CENTER" "RIGHT"

                                            
                                            strlenth=strlen(textrotation)
                                            strrotation=substring(textrotation 1 strlenth-1)

                                            rotation=atof(strrotation)
                                            
                                            locstr1=car(parseString(textxy "()"))
                                            loc=parseString(locstr1 " ")
                                            xloc=atof(nthelem(1 loc));+atof(dx)
                                            yloc=atof(nthelem(2 loc));+atof(dy)
                                            loc1=list(xloc yloc)
                                            axlMsgPut("%L,%f,%f,%s" loc xloc yloc textxy)
                                            s=sprintf(s "%L,%f,%f,%s\n" loc xloc yloc textxy)
                                            
                                            fprintf(b s)
                                            
                                            orientation_text = make_axlTextOrientation(
                                                               ?textBlock textBlock,
                                                               ?rotation  rotation,
                                                               ?mirrored  isMirrored,
                                                               ?justify   justify 
                                                               )
                                            status= axlDBCreateText( 
                                                               text                    
                                                               loc1
                                                               orientation_text 
                                                               onetext->layer
                                                               parent_dbid
                                                               ) 
                                                               
                                            if( status != nil then
                                                axlDeleteObject( list( onetext )) 
                                            );endifstatus  
                                            
                                            
                                           
                                        );endifgood
                                     );endifonetext  
                                     
                                );endforeach
                                
                                if( found =nil then
                                        
                                            nfoundline=sprintf(nfoundline "%s: doesnot exit in the design\n" textname)
                                            fprintf(notfoundtext nfoundline)
                                            
                                            axlMsgPut("%s not found,Please check it" textname)
                                );endiffound

                                gets(S textfilein)
                                if( S!=nil then
                                     textline=parseString(S "_")
                                else
                                     alldone=t
                                );endifgets
                            axlMsgPut("textline now is:%L" textline)
                            s=sprintf(s "textline now is:%L\n"  textline)
                            fprintf(b s)
                    );endwhile 

                     
                  else
                     axlMsgPut("textfile not found,Please check it")
                  );endifisfile
                  
                   
                    close(b)
                    close(textfilein)
                    close(notfoundtext)
                    axlClearSelSet()
                    axlMsgPut("Import succesfully!please view the viewlog!")
     
                    
              );endimport
              
             ( "Export"
                  textlist=nil
                  textfile=outfile("textfile.txt")
                  axlClearSelSet()
                  axlSetFindFilter( ?enabled (list "noall" "invisible" "text")
                      ?onButtons (list "text")
                    )

                  textlist = axlGetSelSet( axlAddSelectAll() )
                  found=nil
                  
                  foreach( onetext textlist
                        ;axlMsgPut("current layer is : %s" axlFormGetField( Skill_Programs_Form "layer") )
                        
                        if( onetext->objType == "text" && onetext->layer  == axlFormGetField( Skill_Programs_Form "layer")  then
                             ;  || onetext->layer  == "PACKAGE GEOMETRY/ASSEMBLY_BOTTOM" || 
                             ;onetext->layer  == "REF DES/ASSEMBLY_TOP" || onetext->layer  == "REF DES/ASSEMBLY_BOTTOM" then
                             
                            text=sprintf(text " _%L_%f\n" onetext->xy onetext->rotation)
                            text=strcat(onetext->text text)
                            fprintf(textfile text)
                            found=t
                         );endif
                  );endforeach
                  if( found == t then
                  axlMsgPut("Export succesfully!")
                  else 
                  axlMsgPut("not found!Please reexprot!")

                  )
                  
                  close( textfile)
                  axlClearSelSet()
              );endexport
              
              ( "class" putprop( Skill_Programs_Form get(Skill_Programs_Form 'curValue) 'class))

              ( "adone"
                   axlFormClose(Skill_Programs_Form)
	            axlCancelEnterFun()
	            axlClearSelSet()
	            axlCloseFindFilter()
	       );enddone

         );endcase
);enddefun
                              

               
defun( TexthandleMakeFormFile ()
        frmfle = outfile("textinorout.form")
        fprintf( frmfle "FILE_TYPE=FORM_DEFN VERSION=2\nFORM\nFIXED\nPORT 40 10\nHEADER \"Text Handle Form\"\n")
        fprintf( frmfle "POPUP <CURSPOP>\"PACKAGE GEOMETRY/ASSEMBLY_TOP\"\"1\",\"PACKAGE GEOMETRY/ASSEMBLY_BOTTOM
                              \"\"2\",\"REF DES/ASSEMBLY_TOP\"\"3\",\"REF DES/ASSEMBLY_BOTTOM\"\"4\",\"PACKAGE GEOMETRY/SILKSCREEN_TOP\"\"5\",
                              \"PACKAGEGEOMETRY/SILKSCREEN_BOTTOM\"\"6\",\"REF DES/SILKSCREEN_TOP\"\"7\"
                              ,\"REF DES/SILKSCREEN_BOTTOM\"\"8\".\n")

        fprintf( frmfle "TILE\n")
        fprintf( frmfle "GROUP \"Import Text\"\nGLOC 3 1\nGSIZE 34 6\nENDGROUP\n")
        fprintf( frmfle "GROUP \"Export Text\"\nGLOC 3 7\nGSIZE 34 11\nENDGROUP\n") 
        fprintf( frmfle "TEXT \"Select a Layer to export:\"\n")
        fprintf( frmfle "TLOC 4 9\n")
        fprintf( frmfle "ENDTEXT\n")
        fprintf( frmfle "FIELD layer\nFLOC 5 12\nFGROUP \"Export\"\nENUMSET 28\nPOP \"CURSPOP\"\nENDFIELD\n\n")
        fprintf( frmfle "FIELD Import\nFLOC 12 4\nFGROUP \"Import\"\nMENUBUTTON \"Import Text\" 16 3\nENDFIELD\n")
        fprintf( frmfle "FIELD Export\nFLOC 12 15\nFGROUP \"Export\"\nMENUBUTTON \"Export Text\" 16 3\nENDFIELD\n")
        fprintf( frmfle "FIELD adone\nFLOC 16 19\nMENUBUTTON \"Done\" 8 3\nENDFIELD\n")
        fprintf( frmfle "ENDTILE\n")
        fprintf( frmfle "ENDFORM\n")
        close( frmfle)
);enddefun

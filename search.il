
;+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
;
;	Author: Sky Liu
;		AE for Graser (agent for Cadence)
;		mobile:13510590862
;             Email: sky048@126.com
;	File Name:  search.il
;	Revision 0: January 16,2005
;
;	
;	Purpose: 
;             To allow the User to serach a component or a net
;		
;	Usage:  
;              1.add load("search.il") line in the allegro.ilinit locate on pcbenv directiory.
;              2.enter "SearchStar" in the command line	
	


axlCmdRegister( "SearchStar" `_SearchStar)


(defun _SearchStar ()
     axlClearSelSet()
     _SearchMakeForm()
     symgrp=nil
     netgrp=nil
     alldone=nil
     
     form = axlFormCreate( (gensym) "search.form" `(e outer)
                         `_INEStartCallBk t)
     Skill_Programs_Form=form
     axlFormDisplay(form)
     (axlFormSetField form "searchobject" "")
     putprop( Skill_Programs_Form "" `searchobject)
     ;axlShell("alias Enter _Next()")

     (axlFormSetField form "components" t)
     putprop( Skill_Programs_Form t `components) 
     (axlFormSetField form "nets" nil)
     putprop( Skill_Programs_Form nil `nets)
     
    

 );enddefunmain

defun( _INEStartCallBk (Skill_Programs_Form)
       (case Skill_Programs_Form->curField
           ( "components" 
                
               (axlFormSetField form "components" t)
               putprop( Skill_Programs_Form t `components)
               (axlFormSetField form "nets" nil)
                putprop( Skill_Programs_Form nil `nets))
                                      
           ( "nets" 
                (axlFormSetField form "nets" t)
                putprop( Skill_Programs_Form t `nets)
                (axlFormSetField form "components" nil)
                putprop( Skill_Programs_Form nil `components))

           ( "done" _Next())
           ( "exit" _Done())
           
        );endcase
);enddefun

defun( _SelectComponent ()
(prog ()
       found=nil
       symgrp=nil
       axlClearSelSet()
       axlMsgPut("Enter component name.")
       axlSetFindFilter( ?enabled `( "noall" "symbols") ?onButtons `("symbols"))
       
       axlAddSelectAll()
       axlDehighlightObject( car(netgrp))
       symbollist = axlGetSelSet()
             foreach( onesym symbollist
                        
                        if(onesym->refdes == upperCase(axlFormGetField( Skill_Programs_Form "searchobject")) then
                              axlShell("shadow off")
                              found=t
                              symgrp=list(onesym)
                              axlZoomToDbid(onesym t)
                              
                         );endif
             );endfoeach
            if(found==nil then
                   axlMsgPut( "Symbol not found,Please reinput again.")
                   (axlFormSetField form "searchobject" "")
                   putprop( Skill_Programs_Form "" `searchobject)
             );endifsymgrp
       
       axlClearSelSet()
       axlHighlightObject( car(symgrp))
       axlCancelEnterFun()
       

);endporg
);enddefun     

defun( _SelectNet ()
(prog ()
       axlDehighlightObject( car(symgrp))
       netgrp=nil
       found=nil
       axlMsgPut("Enter net name.")
       axlClearSelSet()
       axlSetFindFilter( ?enabled `( "noall" "nets") ?onButtons `("nets"))
       axlAddSelectAll()
       netlist = axlGetSelSet()
       foreach( onenet netlist
                 if(onenet->name == upperCase(axlFormGetField( Skill_Programs_Form "searchobject")) then
                       found=t
                       netgrp=list(onenet)
                       axlShell("shadow on 50")
                       axlZoomToDbid(onenet t)
                 );endifonename
       );endforeachonenet
       
       
       if(found==nil then
           axlMsgPut( "Net not found,Please reinput again.")
           (axlFormSetField form "searchobject" "")
            putprop( Skill_Programs_Form "" `searchobject)
       );endifnetgrp

       axlClearSelSet()
       axlHighlightObject( car(netgrp))
       axlCancelEnterFun()
       
);endprog
);enddefun



defun( _Next ()
    
        axlCancelEnterFun()
        axlFormSetActiveField(Skill_Programs_Form "done" )
        if( axlFormGetField( Skill_Programs_Form "searchobject") != "" then
                if(Skill_Programs_Form->components == t then
                      axlClearSelSet()
                      _SelectComponent()
                );endif
                if(Skill_Programs_Form->nets == t then
                      axlClearSelSet()
                      _SelectNet()
                );endif
               
        else
              axlMsgPut( "Please input Object.")     
        );endif
        
        (axlFormSetField form "searchobject" "")
        putprop( Skill_Programs_Form "" `searchobject)
        axlFormSetActiveField(Skill_Programs_Form "searchobject" )
   
 );enddefun
 
defun( _Done ()
       setq(alldone t)
       axlFormClose(Skill_Programs_Form)
	axlCancelEnterFun()
       axlDehighlightObject( car(netgrp))
       axlDehighlightObject( car(symgrp))
       axlShell("shadow off")
	axlClearSelSet()
	axlCloseFindFilter()

);enddefun

defun( _SearchMakeForm ()

	frmfle = outfile("search.form")
	fprintf( frmfle "FILE_TYPE=FORM_DEFN VERSION=2\nFORM\nFIXED\n")
	fprintf( frmfle "PORT 30 5\nHEADER \"Searcher Form\"\n")
       fprintf( frmfle "TILE\n")
       fprintf( frmfle "TEXT \"Input the object will be selected:\"\n")
       fprintf( frmfle "TLOC 3 1\n")
       fprintf( frmfle "ENDTEXT\n")
       fprintf( frmfle "FIELD searchobject\nFLOC 4 3\nSTRFILLIN 20 32\nENDFIELD\n\n")
       fprintf( frmfle "FIELD components\nFLOC 4 5\nCHECKLIST\"Components\" \"alg\"\n ENDFIELD\n\n")
	fprintf( frmfle "FIELD nets\nFLOC 17 5\nCHECKLIST \"Nets\" \"alg\"\nENDFIELD\n\n")
	fprintf( frmfle "FIELD done\nFLOC 4 7\nMENUBUTTON \"Next\" 9 3\nENDFIELD\n\n")
	fprintf( frmfle "FIELD exit\nFLOC 17 7\nMENUBUTTON \"Exit\" 9 3\nENDFIELD\n\n")
       fprintf( frmfle "ENDTILE\n")
       fprintf( frmfle "ENDFORM\n")	
       close(frmfle)
);enddefun    
     

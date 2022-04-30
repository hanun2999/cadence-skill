;Written by USI

defun(text_r ()

axlVisibleDesign(nil)
axlVisibleLayer("Ref Des/Silkscreen_Top" t)
axlVisibleLayer("Ref Des/Silkscreen_Bottom" t)
axlVisibleLayer("Ref Des/Assembly_Top" t)
axlVisibleLayer("Ref Des/Assembly_Bottom" t)
    
axlSetFindFilter(?enabled list("noall" "text") 
       ?onButtons list("noall" "text"))

axlAddSelectAll()

text_db_list = axlGetSelSet()

foreach(text_db text_db_list
     
           xy=text_db->bBox 
              dx=caar(xy)
              dy=cadar(xy)                
              ux=caadr(xy)
              uy=cadadr(xy)

              loc_x=(ux+dx)/2
              loc_y=(uy+dy)/2
              loc=list(loc_x loc_y)


ang=0
ang = text_db->rotation


 if( (ang>90 && ang<=270) then                                  
                                    axlTransformObject(text_db, ?angle 180 ?origin loc)
    )           

axlVisibleDesign(nil)
axlVisibleLayer("Ref Des/Silkscreen_Top" t)
axlVisibleLayer("Ref Des/Silkscreen_Bottom" t)
axlVisibleLayer("Ref Des/Assembly_Top" t)
axlVisibleLayer("Ref Des/Assembly_Bottom" t)
))

axlCmdRegister( "text_rotate" `text_r)


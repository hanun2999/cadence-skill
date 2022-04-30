/* 
├─ 
│ ├─        程序名称： Quick_open
│ ├─        程序功能：快速打开默认文档
│ ├─        创建时间：2013年10月17日 
│ ├─        作    者：王凯
├─ 

*/ 
procedure( quick_open(t_open)
    

    if(!boundp('EVER_LAUNCHED) 
	then
	
     axlShell("quick_display")
	 
	 ; axlShell("quick_textset")
	 ;axlShell("grids") 
	 
	; axlSetVariable("psmpath" '("." "Z:/PCBLIB/"))
	; axlSetVariable("padpath" '("." "Z:/PCBLIB/"))
	; axlSetVariable("padpath" '("." "Z:/STEP MOUDLE/"))
	axlSetVariable("pcb_cursor" "infinite")
	
	; axlGetVariable("autosave_dbcheck")

      EVER_LAUNCHED = t
	  
    )
)
if(axlVersion('version)>16.3
then
     if(axlVersion('programName) == "allegro"
	    axlTriggerSet('open 'quick_open)
	   )
)

; load("Quick_open.il")

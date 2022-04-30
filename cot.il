; Program Name: cot.il
; Author:	Richard L.  a chinese guy in Montreal
;			    fpmontreal@gmail.com
;
; Tested on:	Allegro v15.5
; Purpose:	This routine is a very simple utility that will create oblong thermal shape
;          (thank Hunter516 to let me try)
; 
; update: support by more style (idea from markwang, .....www.pcbbbs.com)
; update: fit for FPM project
/*---------------------------------
CreateOblThForm()
---------------------------------*/
defun( CreateOblThForm ()
	MainFormFile=axlTempFile()
	p = outfile(MainFormFile "w")
	f_FormBegin(p 35,20,"Create Thermal - RichardL." "TOOLWINDOW")
	f_Bitmap(p "cot" "cot" 0 0 14 14)
	f_Text(p "Outer diameter(A):",15,0)  f_EditFloat(p "A",29,0,5,5,4)
	f_Text(p "Inner diameter(B):",15,3)  f_EditFloat(p "B",29,3,5,5,4)
	f_Text(p "Oblong length(D):", 15,6)  f_EditFloat(p "D",29,6,5,5,4)
	f_Text(p "Circle spoke(C):",  15,9)  f_EditFloat(p "C",29,9,5,5,4)
	f_Text(p "Oblong spoke(E):",  15,12) f_EditFloat(p "E",29,12,5,5,4)
	f_Group(p "Direction",2,14,32,4)
	f_CheckList(p "H", 4,16,"Horizontal","di")
	f_CheckList(p "V",18,16,"Vertical","di")
	f_Button(p "OK",2,19,10,3) 
	f_Button(p "Cancel",20,19,10,3)
	f_FormEnd(p)
	close(p)
	MainFormFile
);func

/*---------------------------------
CheckCOTValue()
---------------------------------*/
defun( CheckCOTValue ()
prog( ()
let( ()
	if((ot->a>0 && ot->b>0 && ot->c>0 && ot->d>0 && ot->e>0) then
   		if((ot->a>ot->b && ot->d>ot->e && ot->b>ot->c) return(t)
   		axlMsgPut("Invalid Value between A,B,C,D,E"))
	);if
	axlMsgPut("Invalid Value, check your value carefully.")
	return(nil)
]

;global
defstruct( struOblTh a b c d e dirH)
ot=nil

defun( CreateOblongThermal ()
	MainFormFile=CreateOblThForm()	
 fw = axlFormCreate((gensym) MainFormFile '("NE" "msglines" 0) 'OblThCallback t nil)
	ot=make_struOblTh(?a 100 ?b 50 ?c 20 ?d 100 ?e 30 ?dirH t)
	
 (axlFormSetField fw "A" ot->a)
 (axlFormSetField fw "B" ot->b)
 (axlFormSetField fw "C" ot->c)
 (axlFormSetField fw "D" ot->d)
 (axlFormSetField fw "E" ot->e)
 (axlFormSetField fw "A" ot->a)
 (axlFormSetField fw "H" ot->dirH)
 (axlFormSetField fw "bmp" "cot")

 axlFormDisplay(fw)
; return(fw)	; return form handle to caller
)

defun( OblThCallback (fw)
	case(fw->curField
		("H" ot->dirH=t)
		("V" ot->dirH=nil)
		("A" ot->a=fw->curValue)
		("B" ot->b=fw->curValue)
		("C" ot->c=fw->curValue)
		("D" ot->d=fw->curValue)
		("E" ot->e=fw->curValue)
 	)

	if(fw->doneState==2 || fw->doneState==3 ;cancle & close
		then axlFormClose(fw) axlTempFileRemove(MainFormFile))
	case(fw->doneState
	(1 ;here is the real main thing!

	if(CheckCOTValue() then
	axlShell("done")
 axlSetActiveLayer("etch/top")
	axlDBChangeDesignExtents( '((-1000 -1000) (1000 1000)))
	
	if(ot->dirH then
	path = axlPathStart( (list -ot->d/2:-ot->a/2))   	 
	axlPathLine(path,0,ot->d/2:-ot->a/2) axlPathArcAngle(path,0,ot->d/2:ot->a/2,  nil,180)   	 
	axlPathLine(path,0,-ot->d/2:ot->a/2) axlPathArcAngle(path,0,-ot->d/2:-ot->a/2,nil,180)   	 
	else
	path = axlPathStart( (list ot->a/2:-ot->d/2))   	 
	axlPathLine(path,0,ot->a/2:ot->d/2) axlPathArcAngle(path,0,-ot->a/2:ot->d/2,  nil,180)   	 
	axlPathLine(path,0,-ot->a/2:-ot->d/2) axlPathArcAngle(path,0,ot->a/2:-ot->d/2,nil,180)   	 
	)	
	shapeid=axlDBCreateShape(path t)
	o_poly = axlPolyFromDB(car(shapeid)) axlDeleteObject(car(shapeid))
	i_poly=axlPolyExpand(o_poly -(ot->a-ot->b)/2 'NONE)

	if(ot->dirH 
	shapeid=axlDBCreateRectangle(list(-ot->d/2-ot->a/2:-ot->c/2 ot->d/2+ot->a/2:ot->c/2) t)	
	shapeid=axlDBCreateRectangle(list(-ot->c/2:-ot->d/2-ot->a/2 ot->c/2:ot->d/2+ot->a/2) t)	
	)
	i_poly=append(i_poly axlPolyFromDB(car(shapeid))) axlDeleteObject(car(shapeid))
	
	if(ot->dirH 
	shapeid=axlDBCreateRectangle(list(-ot->e/2:-ot->a/2 ot->e/2:ot->a/2) t)	
	shapeid=axlDBCreateRectangle(list(-ot->a/2:-ot->e/2 ot->a/2:ot->e/2) t)	
	)
	i_poly = append(i_poly axlPolyFromDB(car(shapeid))) axlDeleteObject(car(shapeid))
	
	f_poly = axlPolyOperation(o_poly i_poly 'ANDNOT)

	foreach(onepoly f_poly axlDBCreateShape(onepoly t))
	axlWindowFit()
	)
	);CheckCOTValue
	);case
)

;CreateOblongThermal()
axlCmdRegister( "COT" `CreateOblongThermal)

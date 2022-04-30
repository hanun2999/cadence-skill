;DESCRIPTION:	   basic form operation with tmpfile support
;AUTHOR: Richard L.   fpmontreal@gmail.com
/*---------------------------------
f_FormBegin(p w h title form_opt)  TOOLWINDOW / AUTOGREYTEXT / FIXED_FONT / UNIXHGT
---------------------------------*/
defun( f_FormBegin (p w h @optional (form_title "by RichardL.") (form_opt "AUTOGREYTEXT"))
	sprintf(dest,"FILE_TYPE=FORM_DEFN VERSION=2\nFORM %s\nFIXED\nPORT %d %d\nHEADER \"%s\"\nTILE\n\n",form_opt,w,h,form_title)
	if(p fprintf(p,"%s",dest))
	dest
)

/*---------------------------------
f_FormEnd(p flexmode) StandButtons / EdgeGravity / EdgeGravityOne
---------------------------------*/
defun( f_FormEnd (p @optional flexmode)
	if(flexmode	sprintf(dest,"FLEXMODE %s\nENDTILE\nENDFORM\n",flexmode)
		sprintf(dest,"ENDTILE\nENDFORM\n")
	)
	if(p fprintf(p,"%s",dest))
	dest
)

/*---------------------------------
f_CheckList(field x y name group)
---------------------------------*/
defun( f_CheckList (p field x y name @optional (group nil))
	if(group==nil 
		sprintf(dest,"FIELD %s\nFLOC %d %d\nCHECKLIST \"%s\" \nENDFIELD\n\n",field,x,y,name)
		sprintf(dest,"FIELD %s\nFLOC %d %d\nCHECKLIST \"%s\" \"%s\"\nENDFIELD\n\n",field,x,y,name,group)
	)
	if(p fprintf(p,"%s",dest))
	dest
)

/*---------------------------------
f_Group(field x y w h)
---------------------------------*/
defun( f_Group (p field x y w h)
	sprintf(dest,"GROUP \"%s\"\nFLOC %d %d\nFSIZE %d %d\nENDGROUP\n\n",field,x,y,w,h) 
	if(p fprintf(p,"%s",dest))
	dest
)

/*---------------------------------
f_Text(field x y)
---------------------------------*/
defun( f_Text (p text x y)
	sprintf(dest,"TEXT \"%s\"\nFLOC %d %d\nENDTEXT\n\n",text,x,y) 
	if(p fprintf(p,"%s",dest))
	dest
)

/*---------------------------------
f_EditFloat(field x y iw dw dec)    (iw-input width) (dw-data width)
---------------------------------*/
defun( f_EditFloat (p field x y iw dw dec)
	sprintf(dest,"FIELD %s\nFLOC %d %d\nREALFILLIN %d %d\nDECIMAL %d\nENDFIELD\n\n",field,x,y,iw,dw,dec) 
	if(p fprintf(p,"%s",dest))
	dest
)

/*---------------------------------
f_Button(x y w h)
---------------------------------*/
defun( f_Button (p name x y w h)	;close done/ok cancel help print 
	sprintf(dest,"FIELD %s\nFLOC %d %d\nMENUBUTTON \"%s\" %d %d\nENDFIELD\n\n",name,x,y,name,w,h) 
	if(p fprintf(p,"%s",dest))
	dest
)

/*---------------------------------
f_Bitmap(name x y w h @optional opt)
---------------------------------*/
defun( f_Bitmap (p field name x y w h @optional (opt nil))		;[RIGHT | CENTER | BORDER | BOLD | UNDERLINE]
	if(opt==nil 
	sprintf(dest,"FIELD %s\nTHUMBNAIL %s\nFLOC %d %d\nFSIZE %d %d\nENDFIELD\n\n",field,name,x,y,w,h) 
	sprintf(dest,"FIELD %s\nTHUMBNAIL %s\nOPTIONS %s\nFLOC %d %d\nFSIZE %d %d\nENDFIELD\n\n",field,name,opt,x,y,w,h) 
	)
	if(p fprintf(p,"%s",dest))
	dest
)

/*---------------------------------
f_TreeView(field x y w h)
---------------------------------*/
defun( f_TreeView (p field x y w h)
	sprintf(dest,"FIELD %s\nFLOC %d %d\nTREEVIEW %d %d\nENDFIELD\n\n",field,x,y,w,h) 
	if(p fprintf(p,"%s",dest))
	dest
)


/*---------------------------------
example: CreateMainForm()
---------------------------------*/
/*
defun( CreateMainForm ()
	MainFormFile=axlTempFile()
	p = outfile(MainFormFile "w")
	f_FormBegin(p 80,20,"Batch Symbol Creater - Richard L.")
	f_Group(p "Select Level",2,2,20,8)
	f_CheckList(p "LevelMax",  4,4,"1 - Maximum","rg")
	f_CheckList(p "LevelMom",  4,6,"2 - Nominal","rg")
	f_CheckList(p "LevelLeast",4,8,"3 - Least",  "rg")
	f_Text(p "SolderMask Ext:",2,12) f_EditFloat(p "SolderMaskOffset",14,12,7,7,4)
	f_Text(p "Silk Gap:",      2,14) f_EditFloat(p "SilkGap",         14,14,7,7,4)
	f_Text(p "SilkWidth",      2,16) f_EditFloat(p "SilkWidth",       14,16,7,7,4)
	f_Text(p "Choice Symbol(s):",24,2)
	f_CheckList(p "AllSym",40,2,"Select All")
	f_TreeView(p "SymTree",24,4,56,12)
	f_Button(p "Run",2,20,10,3)
	f_FormEnd(p)
	close(p)
	MainFormFile
);func
*/
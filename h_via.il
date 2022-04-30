;**************************************************************************************
;1 高亮同类过孔、焊盘
;   快捷键：Ctrl+h
;2 fanout到焊盘中心
;   快捷键：Ctrl+a
;3 过孔DRC检查
;   1)过孔相碰（包括同网络过孔）
;   2)查通孔是否打在焊盘上
;   3)查通孔是否打在屏蔽架上[shape必须在BOARD GEOMETRY/SHIELD_TOP（BOTTOM）层]
;   4)查是否存在不是地网络的通孔
;   5)查孔是否只连一层地
;   快捷键：Ctrl+F1
;4 RF线次层挖空
;   快捷键：Ctrl+F2
;5 自动打地过孔
;   快捷键：Ctrl+v
;***************************************************************************************

;***************************************************************************
;高亮同类过孔、焊盘
axlCmdRegister("h_via_main" `h_via_main)
;axlSetAlias( "~H" "h_via_main")

defun( h_via_main ()
    via_form()
    axlSetFindFilter(?enabled `("NOALL" "PINS" "vias")	?onButtons `("PINS" "vias"))

    while( axlSingleSelectPoint()
    if( axlGetSelSet()!=nil then
	a=car(axlGetSelSet())
	s=a->name
	axlFormSetField(fs "padstack_name"	s)
	if( axlFormGetField( fs "window")=="1" then
	    axlAddSelectBox(axlWindowBoxGet())
	else
	    axlAddSelectAll()
	)
	foreach( a axlGetSelSet()
	    if( a->name!=s then axlSubSelectObject(a))
	)
    
    ))
    axlFinishEnterFun()
)

defun( via_form ()
    ;定义form文件名
    via_form_file="./via_form_file.form"
    ;创建form
    p=outfile(via_form_file "w")
    if(p != nil then
	fprintf(p "FILE_TYPE=FORM_DEFN VERSION=2\n")
	fprintf(p "FORM\n")
	fprintf(p "FIXED\n")
	fprintf(p "PORT 40 60\n")
	fprintf(p "HEADER \"Highlight via\"\n")
	fprintf(p "TILE\n")
	fprintf(p "\n")
	
    	fprintf(p "GROUP \"Range\"\n")
	fprintf(p "GLOC 1 0\n")
	fprintf(p "GSIZE 20 4\n")
	fprintf(p "ENDGROUP\n")
	fprintf(p "\n")
	fprintf(p "FIELD window\n")
	fprintf(p "FLOC 2 2\n")
	fprintf(p "CHECKLIST \"Window\" \"1\"\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")
	fprintf(p "FIELD design\n")
	fprintf(p "FLOC 12 2\n")
	fprintf(p "CHECKLIST \"design\" \"1\"\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")

	fprintf(p "TEXT \"Select highlight padstack\"\n")
	fprintf(p "TLOC 1 4\n")
	fprintf(p "ENDTEXT\n")
	fprintf(p "\n")
	fprintf(p "FIELD padstack_name\n")
	fprintf(p "FLOC 1 6\n")
	fprintf(p "REALFILLIN 19 30\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")
	fprintf(p "FIELD vias_list\n")
	fprintf(p "FLOC 1 8\n")
	fprintf(p "LIST \"\" 20 6\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")
	fprintf(p "ENDTILE\n")
	fprintf(p "ENDFORM\n")
    else
	printf("ERROR,can't create form file!")
    )
    close(p)
    ;打开form
    ;axlFormCreate('fs via_form_file '("msgLines" 0) 'hl_via nil nil )
    axlMiniStatusLoad( 'fs via_form_file  'hl_via t )
   
    ;过孔列表
    vd_list=axlDBGetDesign()->padstacks
    vn_list=nil
    foreach(a vd_list
    ;@@@@@@@@@@@@@@@@@@@@
	if( nindex(upperCase(a->name) "VIA")!=nil then
	    vn_list=append1(vn_list a->name)
	)
    ;@@@@@@@@@@@@@@@@@@@@
    )
    if( vn_list!=nil then
	ps=""
	vn_list=sort(vn_list nil)
	axlFormListDeleteAll(fs "vias_list")
	axlFormSetField(fs "vias_list" vn_list)
	axlFormSetField(fs "window" t)
	;显示form
	axlFormDisplay(fs)
    )
    ;删除form文件
    if(isFile(via_form_file) then
 	deleteFile(via_form_file)
    )
)

defun( hl_via (fs)
	axlFormSetFieldVisible(fs "vias_list" 1)
	if( fs->curField=="vias_list" then
	    s=fs->curValue
	    axlFormSetField(fs "padstack_name"	s)
	    ;axlSetFindFilter(?enabled list("vias") ?onButtons list("vias"))
	    axlClearSelSet()
	    if( axlFormGetField( fs "window")=="1" then
		axlAddSelectBox(axlWindowBoxGet())
	    else
		axlAddSelectAll()
	    )
	    foreach( a axlGetSelSet()
		if( a->name!=s then axlSubSelectObject(a))
	    )
	)

)

;**************************************************************************
;fanout到焊盘中心
axlCmdRegister("fanout_bbvia" `fanout_bbvia)
;axlSetAlias( "~F" "fanout_bbvia")

defun( fanout_bbvia ()
    fanout_bbvia_form()
    axlSetFindFilter(?enabled `("NOALL" "PINS" "COMPONENTS")	?onButtons `("PINS"))
    axlClearSelSet()

    mark=axlDBTransactionStart()
    pin_list=nil
    gelem=1
    while( gelem
	gelem=axlSelect()
	if( gelem!=nil then
	pin_list=nil
	foreach(a axlGetSelSet()
	    if( a->objType=="component" then
		foreach( b a->pins
		    if( b->net->name!="" && b->isThrough==nil then;带网络，非通孔
			pin_list=append1(pin_list b)
		    )
		)
	    else
		if( a->net->name!="" && a->isThrough==nil then;带网络，非通孔
		    pin_list=append1(pin_list a)
		)
	    )
	)
	else
	    axlDBTransactionCommit(mark)
	);end if
    );end while
    axlFinishEnterFun()
)

defun( fanout_bbvia_form ()
    ;定义form文件名
    fvia_form_file="./fvia_form_file.form"
    ;创建form
    p=outfile(fvia_form_file "w")
    if(p != nil then
	fprintf(p "FILE_TYPE=FORM_DEFN VERSION=2\n")
	fprintf(p "FORM\n")
	fprintf(p "FIXED\n")
	fprintf(p "PORT 40 60\n")
	fprintf(p "HEADER \"fanout BBvia\"\n")
	fprintf(p "TILE\n")
	fprintf(p "\n")
	
	fprintf(p "TEXT \"Select fanout BBvia\"\n")
	fprintf(p "TLOC 1 1\n")
	fprintf(p "ENDTEXT\n")
	fprintf(p "\n")

	fprintf(p "FIELD vias_name\n")
	fprintf(p "FLOC 1 3\n")
	fprintf(p "REALFILLIN 19 30\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")
	
	fprintf(p "FIELD vias_list\n")
	fprintf(p "FLOC 1 5\n")
	fprintf(p "LIST \"\" 20 12\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")
	
	fprintf(p "FIELD fanout\n")
	fprintf(p "FLOC 1 28\n")
	fprintf(p "MENUBUTTON \"Fanout\" 6 3\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")
	
	fprintf(p "FIELD oops\n")
	fprintf(p "FLOC 8 28\n")
	fprintf(p "MENUBUTTON \"Oops\" 6 3\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")
	
	fprintf(p "FIELD cancel\n")
	fprintf(p "FLOC 15 28\n")
	fprintf(p "MENUBUTTON \"Cancel\" 6 3\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")

	fprintf(p "ENDTILE\n")
	fprintf(p "ENDFORM\n")
    else
	printf("ERROR,can't create form file!")
    )
    close(p)
    ;打开form
    ;axlFormCreate('fs fvia_form_file '("msgLines" 0) 'do_fanout_bbvia nil nil )
    axlMiniStatusLoad( 'fs fvia_form_file  'do_fanout_bbvia t )
    
    ;过孔列表
    vd_list=axlDBGetDesign()->padstacks
    vn_list=nil
    foreach(a vd_list
	if( nindex(upperCase(a->name) "V")!=nil then
	;if( nindex(upperCase(a->name) "VIA")!=nil then
	    vn_list=append1(vn_list a->name)
	)
    )
    if( vn_list!=nil then
	vn_list=sort(vn_list nil)
	axlFormListDeleteAll(fs "vias_list")
	axlFormSetField(fs "vias_list" vn_list)
	if( boundp('fanout_vianame)==nil then
	    fanout_vianame=nthelem(1 vn_list)
	)
	axlFormListSelect(fs "vias_list" fanout_vianame)	
	axlFormSetField(fs "vias_name"	fanout_vianame)
	;显示form
	axlFormDisplay(fs)
    )
    ;删除form文件
    if(isFile(fvia_form_file) then
 	deleteFile(fvia_form_file)
    )

)

defun( do_fanout_bbvia (fs)
    case( fs->curField
	    ("vias_list"
		axlFormSetField(fs "vias_name"	fs->curValue)
		fanout_vianame=fs->curValue
	    )
	    ("fanout"
		axlDBTransactionMark(mark)
		if( pin_list!=nil then
		foreach(b pin_list
		    a=car(axlDBCreateVia( fanout_vianame, b->xy))
		    if( car(a->startEnd)!=car(b->startEnd) && cadr(a->startEnd)!=cadr(b->startEnd) then
			axlDeleteObject(a)
		    )
		)
		)
		axlClearSelSet()
	    )
	    ("oops"
		axlDBTransactionOops(mark)
	    )
	    ("cancel"
		axlDBTransactionRollback(mark)
		mark=axlDBTransactionStart()
	    )
	)
)


;***********************************************************
;同网络相碰过孔列表
;查通孔是否打在焊盘上
;查通孔是否打在屏蔽架上[shape必须在BOARD GEOMETRY/SHIELD_TOP（BOTTOM）层]
;查是否存在不是地网络的通孔
;查孔是否只连一层地
axlCmdRegister("viacheck" `viacheck)
;axlSetAlias( "CF1" "viacheck")

defun( viacheck ()
    class_sub = "manufacturing/viadrc_mark"
    axlLayerCreateNonConductor(class_sub)
    axlVisibleLayer(class_sub t)
    axlVisibleUpdate(t)
    ;计算过孔半径
    c=axlDBGetDesign()->padstacks
    rad=" "
    foreach(a c
	    ;计算半径
	    b=a->pads
	    i=1
	    s=car(a->startEnd)
	    while(nthelem(i b)->layer!=s 
		i=i+1
	    )
	    d=nthelem(i b)->bBox
	    c=caadr(d)
	    d=cadadr(d)
	    sprintf(s "%f-%f" c d)
	    rad=strcat(rad a->name " " s " ")
    )
    
    ;定义form文件名
    via_form_file="./viacheck.form"
    ;创建form
    p=outfile(via_form_file "w")
    if(p != nil then
	fprintf(p "FILE_TYPE=FORM_DEFN VERSION=2\n")
	fprintf(p "FORM\n")
	fprintf(p "FIXED\n")
	fprintf(p "PORT 25 60\n")
	fprintf(p "HEADER \"Via drc\"\n")
	fprintf(p "TILE\n")
	fprintf(p "\n")

	fprintf(p "FIELD c1\n")
	fprintf(p "FLOC 1 1\n")
	fprintf(p "CHECKLIST \"Via spacing drc\" \n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")

	fprintf(p "FIELD c2\n")
	fprintf(p "FLOC 1 3\n")
	fprintf(p "CHECKLIST \"Through via in pad\" \n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")

	fprintf(p "FIELD c3\n")
	fprintf(p "FLOC 1 5\n")
	fprintf(p "CHECKLIST \"Through via in shield\" \n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")

	fprintf(p "FIELD c4\n")
	fprintf(p "FLOC 1 7\n")
	fprintf(p "CHECKLIST \"Not GND through via\" \n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")

	fprintf(p "TEXT \"Name:\"\n")
	fprintf(p "TLOC 4 9\n")
	fprintf(p "ENDTEXT\n")
	fprintf(p "\n")
	fprintf(p "FIELD gndnet\n")
	fprintf(p "FLOC 9 9\n")
	fprintf(p "REALFILLIN 8 18\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")
	fprintf(p "FIELD nL\n")
	fprintf(p "FLOC 19 9\n")
	fprintf(p "MENUBUTTON \"...\" 4 3\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")

	fprintf(p "FIELD c5\n")
	fprintf(p "FLOC 1 11\n")
	fprintf(p "CHECKLIST \"Single layer via\" \n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")

	fprintf(p "FIELD check\n")
	fprintf(p "FLOC 1 14\n")
	fprintf(p "MENUBUTTON \"check\" 6 3\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")

	fprintf(p "FIELD cancel\n")
	fprintf(p "FLOC 10 14\n")
	fprintf(p "MENUBUTTON \"cancel\" 6 3\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")
	
	fprintf(p "FIELD clear\n")
	fprintf(p "FLOC 1 17\n")
	fprintf(p "MENUBUTTON \"Clear mark\" 16 3\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")

	fprintf(p "ENDTILE\n")
	fprintf(p "ENDFORM\n")
    else
	printf("ERROR,can't create form file!")
    )
    close(p)
    ;打开form
    fw=axlFormCreate((gensym) via_form_file '("msgLines" 0) 'check_i nil nil )
    if( boundp('gnds)==nil then
	gnds="GND"
    )
    axlFormSetField(fw "gndnet" gnds)
    
    ;显示form
    if( boundp('cc1)==nil then
	cc1=nil
	cc2=t
	cc3=t
	cc4=t
	cc5=nil
    )
    axlFormSetField(fw "c1" cc1)
    axlFormSetField(fw "c2" cc2)
    axlFormSetField(fw "c3" cc3)
    axlFormSetField(fw "c4" cc4)
    axlFormSetField(fw "c5" cc5)
    axlFormDisplay(fw)
    ;删除form文件
    if(isFile(via_form_file) then
 	deleteFile(via_form_file)
    )

)

defun( check_i (fw)
    if( boundp('fw1) then axlFormClose(fw1))
    case( fw->curField
    ("c1" cc1=fw->curValue)
    ("c2" cc2=fw->curValue)
    ("c3" cc3=fw->curValue)
    ("c4" cc4=fw->curValue)
    ("c5" cc5=fw->curValue)
    ("nL"
	gndname()
    )
    ("check"
	view=axlVisibleGet()

	axlClearSelSet()
	axlSetFindFilter(?enabled `("NOALL" "LINES")	?onButtons `("LINES"))
	axlVisibleDesign(nil)
	axlVisibleLayer("manufacturing/viadrc_mark" t)
	axlAddSelectAll()
	axlDeleteObject(axlGetSelSet())

	sn_viadrc()
	axlVisibleSet(view)
	axlVisibleLayer("via class" t)    
	axlVisibleUpdate(t)
    )
    ("cancel"
	axlFormClose(fw)
    )
    ("clear"
	view=axlVisibleGet()
	
	axlClearSelSet()
	axlSetFindFilter(?enabled `("NOALL" "LINES")	?onButtons `("LINES"))
	axlVisibleDesign(nil)
	axlVisibleLayer("manufacturing/viadrc_mark" t)
	axlAddSelectAll()
	axlDeleteObject(axlGetSelSet())
	
	axlVisibleSet(view)
	axlVisibleUpdate(t)
    )

    )
)

;选择地网络名
defun( gndname ()
    ;定义form文件名
    form_file="./form_file.form"
    ;创建form
    p=outfile(form_file "w")
    if(p != nil then
	fprintf(p "FILE_TYPE=FORM_DEFN VERSION=2\n")
	fprintf(p "FORM\n")
	fprintf(p "FIXED\n")
	fprintf(p "PORT 22 60\n")
	fprintf(p "HEADER \"Select GND Net\"\n")
	fprintf(p "TILE\n")
	fprintf(p "\n")
	
	fprintf(p "FIELD net_list\n")
	fprintf(p "FLOC 1 1\n")
	fprintf(p "LIST \"\" 20 10\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")
	
	fprintf(p "ENDTILE\n")
	fprintf(p "ENDFORM\n")
    else
	printf("ERROR,can't create form file!")
    )
    close(p)
    ;打开form
    fw1=axlFormCreate((gensym) form_file '("msgLines" 0) 'c_name t nil )
    ;网表list
    a=axlDBGetDesign()->nets
    netlist=nil
    foreach(b a
	netlist=append1(netlist b->name)
    )
    netlist=sort(netlist nil)
    ;显示form
    axlFormSetField(fw1 "net_list" netlist)
    axlFormDisplay(fw1)
    ;删除form文件
    if(isFile(form_file) then
 	deleteFile(form_file)
    )
    
)

defun( c_name (fw1)
    if( fw1->curValue!=nil then
	gnds=fw1->curValue
    )
    if( boundp('fs) then if( fs->doneState!=nil then  axlFormSetField(fs "gndnet" gnds)))
    if( boundp('fw) then if( fw->doneState!=3 then  axlFormSetField(fw "gndnet" gnds)))
)

;====
defun( sn_viadrc ()
if( car(axlDBGetDesignUnits())=="mils" then
    unit=20
else
    unit=0.5
)

p=outfile("./viadrc.log")


;选择所有过孔
axlClearSelSet()
axlSetFindFilter( ?enabled list( "noall" "vias" "pins" "shapes" "clines") ?onButtons list( "vias"))
axlVisibleDesign(nil)
;axlVisibleLayer("via class/top" t)
;axlVisibleLayer("via class/bottom" t)
axlVisibleLayer("via class" t)
axlAddSelectAll()
vialist=axlGetSelSet()
;取得通孔list
k=length(vialist)
if( k>0 then
    thlst=nil
    foreach(a vialist
	if( a->isThrough==t then thlst=append1(thlst a))
    )
)
;========过孔间距检查======================
if( cc1==t then
    axlClearSelSet()
    axlSetFindFilter( ?enabled list( "noall" "vias" "pins" "shapes" "clines") ?onButtons list( "noall" "vias"))
    
    fprintf(p "Via spacing drc(including same net via)\n")
    fprintf(p "================================================\n")
    j=0
    axlVisibleDesign(nil)
    
    axlVisibleLayer("via class" t);显示过孔
    k=axlGetParam("paramLayerGroup:etch")->nChildren-1
    layername=" ETCH/TOP"
    s="etch/top"
    a=axlLayerGet(s)
    for(i 1 k
	s=strcat("ETCH" "/" a->nextLayer)
	layername=strcat(layername " " s)
	a=axlLayerGet(s)
	if( a->isEtch==nil println(strcat(a->name " Layer Type is wrong.")))
    )
    
    foreach( a vialist
	;查找过孔半径
	s=strcat(" " a->name " ")
	s=index(rad s)
	c=parseString(nthelem(2 parseString(s " ")) "-")
	s=atof(cadr(c))
	c=atof(car(c))
	
	;选择
	axlAddSelectObject(a)
	b=a->xy
	if(a->rotation==90 || a->rotation==270 then
	    axlAddSelectBox(list(list(car(b)+s cadr(b)+c) list(car(b)-s cadr(b)-c)))
	else
	    axlAddSelectBox(list(list(car(b)+c cadr(b)+s) list(car(b)-c cadr(b)-s)))
	)
	;确定是否同层，计算中心距，确定是否过近
	nnl=length(axlGetSelSet())
	for(nn j+1 nnl
	b=car(last(axlGetSelSet()))
	;确定层
	k=nindex(layername strcat(" " car(a->startEnd)))
	s=nindex(layername strcat(" " car(b->startEnd)))
	if( k<=s && nindex(layername strcat(" " cadr(a->startEnd)))>=s || k>=s && k<=nindex(layername strcat(" " cadr(b->startEnd))) then
	;确定间距
	if(b!=a then
	    ;查找另一过孔半径
	    s=strcat(" " b->name " ")
	    s=index(rad s)
	    k=parseString(nthelem(2 parseString(s " ")) "-")
	    s=atof(cadr(k))
	    k=atof(car(k))
	    if( k==s && b->definition->drillDiameter>0 then
		if( k+c>sqrt((car(a->xy)-car(b->xy))**2+(cadr(a->xy)-cadr(b->xy))**2) then
		x=(car(a->xy)+car(b->xy))/2
		y=(cadr(a->xy)+cadr(b->xy))/2
		axlDBCreateLine(list(list(x-unit y-unit) list(x+unit y+unit) list(x+unit y-unit) list(x-unit y+unit) list(x-unit y-unit)) 0 class_sub)
		fprintf(p "%L %-8s %-8s\n" list(x y) a->name b->name)
		)
	    else
		x=(car(a->xy)+car(b->xy))/2
		y=(cadr(a->xy)+cadr(b->xy))/2
		axlDBCreateLine(list(list(x-unit y-unit) list(x+unit y+unit) list(x+unit y-unit) list(x-unit y+unit) list(x-unit y-unit)) 0 class_sub)
		fprintf(p "%L %-8s %-8s\n" list(x y) a->name b->name)
	    )
	axlSubSelectObject(b)
	);end if(b!=a)
	else
	    axlSubSelectObject(b)
	);end if有同层
	);end for
	j=j+1
    )
    axlClearSelSet()
)
;========过孔间距检查======================
;=====查孔是否只连一层地=================
if( cc5==t then
    axlClearSelSet()
    fprintf(p "\nSingle layer via\n")
    fprintf(p "================================================\n")
    axlSetFindFilter( ?enabled list( "noall" "vias" "pins" "shapes" "clines") ?onButtons list( "noall" "pins" "shapes" "clines"))
    foreach(a vialist
	i=0
	s=a->xy
	b=a->definition->drillDiameter/2
	x=list(list(car(s)-b cadr(s)-b) list(car(s)+b cadr(s)+b))
	
	b=a->startEnd
	s=axlLayerGet(car(b))
	
	axlVisibleDesign(nil)
	axlVisibleLayer(strcat("pin/" s->name) t)
	axlVisibleLayer(strcat("etch/" s->name) t)
	if( axlAddSelectBox(x) then
	    foreach(c axlGetSelSet()
	    if(c->net!=a->net then
		axlSubSelectObject(c)
	    )
	    )
	    if( length(axlGetSelSet())>0 then i=1)
	    axlSubSelectAll()
	)

	b=cadr(parseString(cadr(b) "/"))
	while(s->name!=b && i<2
	    s=s->nextLayer
	    axlVisibleDesign(nil)
	    axlVisibleLayer(strcat("pin/" s) t)
	    axlVisibleLayer(strcat("etch/" s) t)
	    if( axlAddSelectBox(x) then
		foreach(c axlGetSelSet()
		if(c->net!=a->net then
		    axlSubSelectObject(c)
		)
		)
		if( length(axlGetSelSet())>0 then i=i+1)
		axlSubSelectAll()
	    )
	    s=strcat("ETCH" "/" s)
	    s=axlLayerGet(s)
	)
	if( i<2 then
	    x=a->xy
	    fprintf(p "%L   %L\n" x a->startEnd)
	    y=cadr(x)
	    x=car(x)
	    axlDBCreateLine(list(list(x-unit y-unit) list(x+unit y+unit) list(x+unit y-unit) list(x-unit y+unit) list(x-unit y-unit)) 0 class_sub)
	)
	axlClearSelSet()
    );end foreach
)

;=====查孔是否只连一层地=================
if( length(thlst)>0 then;有通孔检查以下项
;=====查通孔是否打在焊盘、屏蔽架上=================
if( cc2==t || cc3==t then
    axlClearSelSet()
    axlVisibleDesign(nil)
    if( cc2==t && cc3==t then
	axlSetFindFilter( ?enabled list( "noall" "vias" "pins" "shapes" "clines") ?onButtons list( "noall" "pins" "shapes"))
	axlVisibleLayer("pin/Bottom" t)
	axlVisibleLayer("pin/Top" t)
	axlVisibleLayer("BOARD GEOMETRY/SHIELD_TOP" t)
	axlVisibleLayer("BOARD GEOMETRY/SHIELD_BOTTOM" t)
    else
	if( cc2==t then
	    axlSetFindFilter( ?enabled list( "noall" "vias" "pins" "shapes" "clines") ?onButtons list( "noall" "pins"))
	    axlVisibleLayer("pin/Bottom" t)
	    axlVisibleLayer("pin/Top" t)
	else
	    axlSetFindFilter( ?enabled list( "noall" "vias" "pins" "shapes" "clines") ?onButtons list( "noall" "shapes"))
	    axlVisibleLayer("BOARD GEOMETRY/SHIELD_TOP" t)
	    axlVisibleLayer("BOARD GEOMETRY/SHIELD_BOTTOM" t)
	)
    )
    fprintf(p "\nThrough via in pad or shield\n")
    fprintf(p "================================================\n")
    foreach(a thlst
	s=strcat(" " a->name " ")
	s=index(rad s)
	c=parseString(nthelem(2 parseString(s " ")) "-")
	c=atof(car(c))
	b=a->xy
	axlAddSelectBox(list(list(car(b)+c cadr(b)+c) list(car(b)-c cadr(b)-c)))
	i=length(axlGetSelSet())
	foreach( b axlGetSelSet()
	    if( b->objType=="pin" then
		fprintf(p "%-12s %L\n" car(b->startEnd) a->xy)
	    else
		fprintf(p "%-12s %L\n" b->layer a->xy)
	    )
	    x=car(a->xy)
	    y=cadr(a->xy)
	    axlDBCreateLine(list(list(x-unit y-unit) list(x+unit y+unit) list(x+unit y-unit) list(x-unit y+unit) list(x-unit y-unit)) 0 class_sub)
	    axlSubSelectObject(b)
	)
    )
    
    axlVisibleLayer("via class/top" t)
    axlVisibleLayer("via class/bottom" t)
)
;=====查通孔是否打在焊盘、屏蔽架上=================
;=====查是否存在不是地网络的通孔=================
if( cc4==t then
    fprintf(p "\nNot GND through via\n")
    fprintf(p "================================================\n")
    foreach(a thlst
	if(a->net->name!=gnds then
	    if(a->net->name==nil then
		fprintf(p "%L nil\n" a->xy)
	    else
		fprintf(p "%L %s\n" a->xy a->net->name)
	    )
	    x=car(a->xy)
	    y=cadr(a->xy)
	    axlDBCreateLine(list(list(x-unit y-unit) list(x+unit y+unit) list(x+unit y-unit) list(x-unit y+unit) list(x-unit y-unit)) 0 class_sub)
	)
    )
)
;=====查是否存在不是地网络的通孔=================
)
;*****其他检查*******
axlClearSelSet()
close(p)
;显示检查结果
if( fileLength("./viadrc.log")>0 then
    axlUIViewFileCreate("./viadrc.log" "via drc" nil '(45 15) '(s))
else
    deleteFile("./viadrc.log")
    print("There isn't DRC for via.")
)
)

;*************************************************************
;几个快捷键
defun( s_k ()
;取得正片层名
a=axlLayerGet("ETCH/TOP")
s=""
layername=nil
while( s!=nil
    s=a->name
    if( a->drcPhotoType=="positive" then
	layername=append1(layername s)
    )
    s=a->nextLayer
    if( s!=nil then
	nextlayer=strcat("ETCH" "/" s)
	a=axlLayerGet(nextlayer)
    )
)
lup=""
ldown=""
foreach(a layername
    lup=strcat(" \"" a "\"" lup)
    ldown=strcat(ldown " \"" a "\"")
)
;设置alt-layer正换层快捷键
s=strcat("funckey ] 'settoggle layer_mode " ldown "; options alt_subclass  $layer_mode'")
axlShell(s)
;设置alt-layer负换层快捷键
s=strcat("funckey [ 'settoggle layer_mode " lup "; options alt_subclass  $layer_mode'")
axlShell(s)
;设推挤模式快捷键
axlShell("funckey = 'settoggle shove_mode Off \"Hug preferred\" \"Shove preferred\"; options bubble_space $shove_mode'")

)

;******************************************************************************
;RF挖空
;挖空层，缺省2层
;间距，缺省辖2w
axlCmdRegister("clear_RF" `clear_RF)
;axlSetAlias( "~R" "clear_RF")

defun( clear_RF ()
    clear_RF_form()
    axlSetFindFilter(?enabled `("NOALL" "CLINES" "pins" "vias" )	?onButtons `("CLINES"))
    axlClearSelSet()
    
    cline_list=nil
    while( axlSelect()
	ls=axlGetSelSet()
	a=car(ls)
	if( a->objType=="path" then
	    a=nthelem(2 parseString(a->layer "/"))
	else
	    a=nthelem(2 parseString(car(a->startEnd) "/"))
	)
	if( a=="TOP" then
	    layer=nthelem(2 layer_list)
	    axlFormListSelect(fs "layer_name" layer)	
	else
	    if( a=="BOTTOM" then
		layer=nthelem(length(layer_list)-1 layer_list)
		axlFormListSelect(fs "layer_name" layer)	
	    )
	)
    )
    axlFinishEnterFun()
)

defun( clear_RF_form ()
    ;定义form文件名
    clear_RF_file="./clesr_RF_file.form"
    ;创建form
    p=outfile(clear_RF_file "w")
    if( car(axlDBGetDesignUnits())=="mils" then
	s="mil"
    else
	s="mm"
    )
    if(p != nil then
	fprintf(p "FILE_TYPE=FORM_DEFN VERSION=2\n")
	fprintf(p "FORM\n")
	fprintf(p "FIXED\n")
	fprintf(p "PORT 40 60\n")
	fprintf(p "HEADER \"fanout BBvia\"\n")
	fprintf(p "TILE\n")
	fprintf(p "\n")
	
	fprintf(p "TEXT \"clear layer\"\n")
	fprintf(p "TLOC 1 1\n")
	fprintf(p "ENDTEXT\n")
	fprintf(p "\n")

	fprintf(p "FIELD layer_name\n")
	fprintf(p "FLOC 9 1\n")
	fprintf(p "LIST \"\" 12 5\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")


    	fprintf(p "GROUP \"clear space\"\n")
	fprintf(p "GLOC 1 11\n")
	fprintf(p "GSIZE 20 7\n")
	fprintf(p "ENDGROUP\n")
	fprintf(p "\n")
	fprintf(p "FIELD xws\n")
	fprintf(p "FLOC 2 13\n")
	fprintf(p "CHECKLIST \" \" \"1\"\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")
	fprintf(p "FIELD width\n")
	fprintf(p "FLOC 2 15\n")
	fprintf(p "CHECKLIST \" \" \"1\"\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")
	
	fprintf(p "FIELD xw\n")
	fprintf(p "FLOC 5 13\n")
	fprintf(p "REALFILLIN 6 3\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")
	
	fprintf(p "FIELD um\n")
	fprintf(p "FLOC 5 15\n")
	fprintf(p "REALFILLIN 6 6\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")

	fprintf(p "TEXT \"W\"\n")
	fprintf(p "TLOC 13 13\n")
	fprintf(p "ENDTEXT\n")
	fprintf(p "\n")
	
	fprintf(p "TEXT \"%s\"\n" s)
	fprintf(p "TLOC 13 15\n")
	fprintf(p "ENDTEXT\n")
	fprintf(p "\n")

	fprintf(p "FIELD add_s\n")
	fprintf(p "FLOC 1 19\n")
	fprintf(p "MENUBUTTON \"add keepout\" 15 3\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")
	
	fprintf(p "FIELD add_L\n")
	fprintf(p "FLOC 1 22\n")
	fprintf(p "MENUBUTTON \"add line keepout\" 15 3\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")
	
	fprintf(p "ENDTILE\n")
	fprintf(p "ENDFORM\n")
    else
	printf("ERROR,can't create form file!")
)
    close(p)
    ;打开form
    ;axlFormCreate('fs clear_RF_file '("msgLines" 0) 'do_clear_RF nil nil )
    axlMiniStatusLoad( 'fs clear_RF_file  'do_clear_RF t )
    
    ;初始化form
    ;取得层名
    a=axlLayerGet("ETCH/TOP")
    s=""
    layer_list=nil
    while( s!=nil
	s=a->name
	layer_list=append1(layer_list s)
	s=a->nextLayer
	if( s!=nil then
	    nextlayer=strcat("ETCH" "/" s)
	   a=axlLayerGet(nextlayer)
	)
    )

    
    layer=nthelem(2 layer_list)
    axlFormListDeleteAll(fs "layer_name")
    axlFormSetField(fs "layer_name" layer_list)
    axlFormListSelect(fs "layer_name" layer)	
    axlFormSetField(fs "xws" t)
    if( boundp('xs)==nil then
	xs="2.0"
	xum="0.6"
    )
    axlFormSetField(fs "xw" xs)
    axlFormSetField(fs "um" xum)
    ;显示form
    axlFormDisplay(fs)
    ;删除form文件
    if(isFile( clear_RF_file) then
 	deleteFile(clear_RF_file)
    )
)
defun( do_clear_RF (fs)
    case( fs->curField
    ("layer_name"
	layer=fs->curValue
    )
    ("xw"
	xs=fs->curValue
    )
    ("um"
	xum=fs->curValue
    )
    ("add_s"
	if( ls!=nil then
	    foreach(a ls
		polydbid = axlPolyFromDB(a, ?layer car(a->startEnd) ?padType 'REGULAR)
		;计算间距
		if( axlFormGetField( fs "xws")=="1" then
		    ;查批ls中的cline
		    i=1
		    while( nthelem(i ls)->objType!="path" && i<length(ls)
			i=i+1
		    )
		    b=nthelem(i ls)
		    if( b->objType=="path" then;有cline,找最大线宽
			if( b->isSameWidth==t then
			    s=car(b->segments)->width*atof(xs)
			else
			    s=0
			    foreach(c b->segments
				if( c->width>s then s=c->width)
			    )
			    s=s*atof(xs)
			)
		    else;无cline,按已知线宽计算
			s=atof(xum)
			axlFormSetField(fs "width" t)
		    )
		    
		else
		    s=atof(xum)
		)
		exp_poly = (axlPolyExpand polydbid s 'ACU_ARC)
		axlDBCreateShape(car(exp_poly) t strcat("ROUTE KEEPOUT/" layer)) 
		sprintf(xum "%f" s)
		axlFormSetField(fs "um" xum)
	    )
	)
    )
    ("add_L"
	if( length(ls)==2 then
	    if( car(ls)->objType="pin" && cadr(ls)->objType=="pin" then
		s=atof(xum)
		polydbid = axlPolyFromDB(car(ls), ?layer car(car(ls)->startEnd) ?padType 'REGULAR)
		exp_poly = (axlPolyExpand polydbid s 'NONE)
		a=car(exp_poly)->bBox
		w1=abs(caar(a)-caadr(a))/2
		h1=abs(cadar(a)-cadadr(a))/2
		
		polydbid = axlPolyFromDB(cadr(ls), ?layer car(cadr(ls)->startEnd) ?padType 'REGULAR)
		exp_poly = (axlPolyExpand polydbid s 'NONE)
		a=car(exp_poly)->bBox
		w2=abs(caar(a)-caadr(a))/2
		h2=abs(cadar(a)-cadadr(a))/2

		s=atof(xum)
		a=car(ls)->xy
		b=cadr(ls)->xy
		if( abs(car(a)-car(b))>abs(cadr(a)-cadr(b)) then
		    path = axlPathStart( list(car(a):cadr(a)-h1 car(a):cadr(a)+h1 car(b):cadr(b)+h2 car(b):cadr(b)-h2 car(a):cadr(a)-h1 ))
		else
		    path = axlPathStart( list(car(a)-w1:cadr(a) car(a)+w1:cadr(a) car(b)+w2:cadr(b) car(b)-w2:cadr(b) car(a)-w1:cadr(a)))
		)
		axlDBCreateShape(path t strcat("ROUTE KEEPOUT/" layer)) 
	    else
		print("Select two pins.")
	    )
	else
	    print("Select two pins.")
	)
    )
    )
    
)

;******************************************************************************

;*********************自动打地过孔*********************************************
;axlSetAlias("~A" "auto_via")
axlCmdRegister("auto_via" `auto_via)

defun( auto_via ()
    class_sub = "manufacturing/autovia_mark"
    axlLayerCreateNonConductor(class_sub)
    axlVisibleLayer(class_sub t)
    axlVisibleUpdate(t)

    
    auto_via_form()
    xy=t
    mark=axlDBTransactionStart()
    if( car(axlDBGetDesignUnits())=="mils" then
	unit=1
    else
	unit=10.0
    )
    while( xy
    xy=axlEnterBox()
    if( xy!=nil then
	axlDBTransactionMark(mark)
	view=axlVisibleGet()
	axlVisibleDesign(nil)
	axlSetFindFilter( ?enabled list( "noall" "vias" "pins" "shapes" "clines") ?onButtons list( "noall" "pins" "vias" "shapes"))
	;显示相关层
	i=1
	while( auto_vianame != car(nthelem(i layername))
	    i=i+1
	)
	s=nthelem(i layername)
	rad=nthelem(4 s);过孔半径
	if( nthelem(3 s)==t then;通孔，显示shield
	    axlVisibleLayer("BOARD GEOMETRY/SHIELD_TOP" t)
	    axlVisibleLayer("BOARD GEOMETRY/SHIELD_BOTTOM" t)
	)
	s=nthelem(2 s)
	k=cadr(s)
	s=car(s)
	a=axlLayerGet(s)
	axlVisibleLayer(strcat("via class/" a->name) t);显示过孔
	axlVisibleLayer(strcat("pin/" a->name) t);显示pin
	while( s!=k;下一层
	    s=a->nextLayer
	    axlVisibleLayer(strcat("via class/" s) t);显示过孔
	    axlVisibleLayer(strcat("pin/" s) t);显示pin
	    s=strcat("ETCH" "/" s)
	    a=axlLayerGet(s)
	)
	
	minx=round(caar(xy)*unit)/unit
	miny=round(cadar(xy)*unit)/unit
	maxx=round(caadr(xy)*unit)/unit
	maxy=round(cadadr(xy)*unit)/unit
	if( minx>maxx then
	    i=minx
	    minx=maxx
	    maxx=i
	)
	if( miny>maxy then
	    i=miny
	    miny=maxy
	    maxy=i
	)

	i=0
	x=minx
	while(x<=maxx-atof(xxs) || i==0
	    x=minx+atof(xxs)*i
	    i=i+1
	    j=0
	    y=miny
	    while(y<=maxy-atof(yys) || j==0
		y=miny+atof(yys)*j
		j=j+1
		curvia = axlDBCreateVia( auto_vianame, list(x y), gnds)
		
		if(cadr(curvia) then
		    axlDBCreateCircle(list(list(x y) car(curvia)->definition->drillDiameter*2) 0 class_sub)
		    axlDeleteObject(car(curvia))
		else
		    axlClearSelSet()
		    axlAddSelectBox(list(list(x+rad y+rad) list(x-rad y-rad)))
		    if( length(axlGetSelSet())>1 then
			axlDBCreateCircle(list(list(x y) car(curvia)->definition->drillDiameter*2) 0 class_sub)
			axlDeleteObject(car(curvia))
		    )
		)
		if( cross_v=="1" then
		    curvia = axlDBCreateVia( auto_vianame, list(x+atof(xxs)/2 y+atof(yys)/2), gnds)
		    if(cadr(curvia) then
			axlDBCreateCircle(list(list(x+atof(xxs)/2 y+atof(yys)/2) car(curvia)->definition->drillDiameter*2) 0 class_sub)
			axlDeleteObject(car(curvia))
		    else
			axlClearSelSet()
			axlAddSelectBox(list(list(x+atof(xxs)/2+rad y+atof(yys)/2+rad) list(x+atof(xxs)/2-rad y+atof(yys)/2-rad)))
			if( length(axlGetSelSet())>1 then
			    axlDBCreateCircle(list(list(x+atof(xxs)/2 y+atof(yys)/2) car(curvia)->definition->drillDiameter*2) 0 class_sub)
			    axlDeleteObject(car(curvia))
			)
		    )
		)
	    );end while
	);end while
	axlClearSelSet()
	axlVisibleSet(view)
	axlVisibleLayer(class_sub t)
    else
	axlDBTransactionCommit(mark)
    );end if
    );end while
    axlFinishEnterFun()
)

defun( auto_via_form ()
    ;定义form文件名
    a_via_form="./auto_via_form.form"
    ;创建form
    p=outfile(a_via_form "w")
    if( car(axlDBGetDesignUnits())=="mils" then
	s="mil"
    else
	s="mm"
    )
    if(p != nil then
	fprintf(p "FILE_TYPE=FORM_DEFN VERSION=2\n")
	fprintf(p "FORM\n")
	fprintf(p "FIXED\n")
	fprintf(p "PORT 40 60\n")
	fprintf(p "HEADER \"Auto via BBvia\"\n")
	fprintf(p "TILE\n")
	fprintf(p "\n")
	
	fprintf(p "TEXT \"Select GND Net\"\n")
	fprintf(p "TLOC 1 1\n")
	fprintf(p "ENDTEXT\n")
	fprintf(p "\n")
	
	fprintf(p "TEXT \"Name:\"\n")
	fprintf(p "TLOC 4 3\n")
	fprintf(p "ENDTEXT\n")
	fprintf(p "\n")
	fprintf(p "FIELD gndnet\n")
	fprintf(p "FLOC 9 3\n")
	fprintf(p "REALFILLIN 8 18\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")
	fprintf(p "FIELD nL\n")
	fprintf(p "FLOC 19 3\n")
	fprintf(p "MENUBUTTON \"...\" 4 3\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")

	fprintf(p "TEXT \"Select Via\"\n")
	fprintf(p "TLOC 1 5\n")
	fprintf(p "ENDTEXT\n")
	fprintf(p "\n")

	fprintf(p "FIELD vias_list\n")
	fprintf(p "FLOC 1 7\n")
	fprintf(p "LIST \"\" 20 5\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")
	
    	fprintf(p "GROUP \"Spacing(%s)\"\n" s)
	fprintf(p "GLOC 1 16\n")
	fprintf(p "GSIZE 20 9\n")
	fprintf(p "ENDGROUP\n")
	fprintf(p "\n")
	
	fprintf(p "TEXT \"X\"\n")
	fprintf(p "TLOC 2 18\n")
	fprintf(p "ENDTEXT\n")
	fprintf(p "\n")
	fprintf(p "TEXT \"Y\"\n")
	fprintf(p "TLOC 2 20\n")
	fprintf(p "ENDTEXT\n")
	fprintf(p "\n")
	fprintf(p "FIELD cross\n")
	fprintf(p "FLOC 2 22\n")
	fprintf(p "CHECKLIST \"Position cross\" \n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")


	fprintf(p "FIELD xx\n")
	fprintf(p "FLOC 5 18\n")
	fprintf(p "REALFILLIN 4 4\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")
	fprintf(p "FIELD yy\n")
	fprintf(p "FLOC 5 20\n")
	fprintf(p "REALFILLIN 4 4\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")

	fprintf(p "FIELD oops\n")
	fprintf(p "FLOC 1 26\n")
	fprintf(p "MENUBUTTON \"Oops\" 6 3\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")
	
	fprintf(p "FIELD cancel\n")
	fprintf(p "FLOC 8 26\n")
	fprintf(p "MENUBUTTON \"Cancel\" 6 3\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")

	fprintf(p "FIELD clear\n")
	fprintf(p "FLOC 16 26\n")
	fprintf(p "MENUBUTTON \"Clear mark\" 9 3\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")

	fprintf(p "FIELD view_c\n")
	fprintf(p "FLOC 1 29\n")
	fprintf(p "MENUBUTTON \"View dynamic copper\" 25 3\n")
	fprintf(p "ENDFIELD\n")
	fprintf(p "\n")

	fprintf(p "ENDTILE\n")
	fprintf(p "ENDFORM\n")
    else
	printf("ERROR,can't create form file!")
    )
    close(p)
    ;打开form
    ;axlFormCreate('fs a_via_form '("msgLines" 0) 'do_fanout_bbvia nil nil )
    axlMiniStatusLoad( 'fs a_via_form  'add_vias t )
    
    ;设置GND网络名
    if( boundp('gnds)==nil then
	gnds="GND"
    )
    axlFormSetField(fs "gndnet" gnds)
    ;过孔列表
    vd_list=axlDBGetDesign()->padstacks
    vn_list=nil
    layername=nil
    foreach(a vd_list
	if( nindex(upperCase(a->name) "VIA")!=nil then
	    vn_list=append1(vn_list a->name)
	    ;计算半径
	    b=a->pads
	    i=1
	    s=car(a->startEnd)
	    while(nthelem(i b)->layer!=s 
		i=i+1
	    )
	    d=nthelem(i b)->bBox
	    c=caadr(d)
	     
	    layername=append1(layername list(a->name a->startEnd a->isThrough c)) 
	)
    )
    if( boundp('xxs)==nil then
	xxs="3.0"
	yys="3.0"
    )
    axlFormSetField(fs "xx" xxs)
    axlFormSetField(fs "yy" yys)
    if( boundp('cross_v)==nil then
	cross_v="0"
    )
    axlFormSetField(fs "cross" atoi(cross_v))

    if( vn_list!=nil then
	vn_list=sort(vn_list nil)
	axlFormListDeleteAll(fs "vias_list")
	axlFormSetField(fs "vias_list" vn_list)
	if( boundp('auto_vianame)==nil then
	    auto_vianame=nthelem(1 vn_list)
	)
	axlFormListSelect(fs "vias_list" auto_vianame)	
	;显示form
	axlFormDisplay(fs)
    )
    ;删除form文件
    if(isFile(a_via_form) then
 	deleteFile(a_via_form)
    )
)

defun( add_vias (fs)
     if( boundp('fw1) then axlFormClose(fw1))
     case( fs->curField
	("nL"
	    gndname()
	)
	("vias_list"
	    auto_vianame=fs->curValue
	)
	("xx"
	    xxs=fs->curValue
	)
	("yy"
	    yys=fs->curValue
	)
	("cross"
	    cross_v=fs->curValue
	)
	("oops"
	    axlDBTransactionOops(mark)
	)
	("cancel"
	    axlDBTransactionRollback(mark)
	    mark=axlDBTransactionStart()
	)
	("clear"
	    view=axlVisibleGet()
	    axlClearSelSet()
	    axlSetFindFilter(?enabled `("NOALL" "LINES")	?onButtons `("LINES"))
	    axlVisibleDesign(nil)
	    axlVisibleLayer("manufacturing/autovia_mark" t)
	    axlAddSelectAll()
	    axlDeleteObject(axlGetSelSet())
	    axlVisibleSet(view)
	    axlVisibleUpdate(t)
	)
	("view_c"
	    view=axlVisibleGet()
	    axlClearSelSet()
	    axlSetFindFilter(?enabled `("NOALL" "SHAPES")	?onButtons `("SHAPES"))
	    axlVisibleDesign(nil)
	    axlVisibleLayer("ETCH" t)
	    axlAddSelectAll()
	    foreach( b axlGetSelSet()
		if( b->net->name==gnds || b->shapeBoundary==nil then
		    axlSubSelectObject(b)
		)
	    )
	    axlVisibleSet(view)
	    axlVisibleUpdate(t)
	)
    )
)
;*********************自动打地过孔*********************************************

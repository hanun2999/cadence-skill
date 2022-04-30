axlSetAlias( "SF12" "gotoitem")
axlSetAlias( "SUp" "gotolast")
axlSetAlias( "SDown" "gotonext")


axlCmdRegister("gotonext" `gotonext)
defun(gotonext ()
    gotoerror(1)
)
axlCmdRegister("gotolast" `gotolast)
defun(gotolast ()
    gotoerror(-1)
)
axlCmdRegister("gotoitem" `gotoitem)
defun(gotoitem ()
    gotoerror(0)
)

defun(gotoerror (nextitem)
    if(nextitem == 0 then
	Valor_item=axlEnterString(?prompts "input the serial number")
	s=parseString(Valor_item ".")
	sub=length(s)
	cd1=atoi(nth(0 s))
	if(sub==2 then cd2=atoi(nth(1 s)) else cd2=1)
    )

    if(nextitem != 0 then
	if(boundp('cd1)==nil then
	    cd1=1
	    cd2=1
	    sub=1
	else
	    if(sub == 1 then
		sprintf(s "./detail_dis/%d.txt" cd1)
		if(isFileName(s) && nextitem ==1 then
		    ddd=axlUIYesNo("Do you want to check the same errors?")
		    if(ddd then
			sub=2
			cd2=2
		    else
			cd1=cd1 + 1
		    )
		else
		    cd1=cd1+nextitem
		    if(cd1==0 then cd1=1)
		)
	    else ;sub=2
		cd2=cd2+nextitem
		if(cd2==1 then sub=1)
	    );end判断是否进入详细内容
	);edn判断是否第一次看报告
    );end判断是否采用前进后退
		
    ;读入坐标

    if(sub==2 then
	;取层参数
	in_file="./detail_dis/pcb_display.txt"
	in=infile(in_file)
	fileLh=fileLength(in_file)
	i=0
	while(fileTell(in)<fileLh && i<cd1
	    gets(s in)
	    i=i+1
	);end while
	close(in)
	z=parseString(s "?")
	s=nth(1 z)
	i=strlen(s)-1
	layers=substring(s 1 i)
	
	s=parseString(nth(0 z) " ")
	ref=nth(3 s)
	k=length(s)

	sprintf(in_file "./detail_dis/%d.txt" cd1)
	in=infile(in_file)
	;取得文件的cd2行
	fileLh=fileLength(in_file)
	i=0
	while(fileTell(in)<fileLh && i<cd2
	    gets(s in)	
	    i=i+1
	    if(i==1 then
		z=parseString(s " ")
		firstlayer=nth(1 z)
		if(ref!="0" then
		    j=0
		    n=length(z)
		    while(ref!=nth(j z) && j<n
			j=j+1
		    )
		    if(j==n j=0)
		)
	    )
	);end while
	close(in)
	if(i==cd2 then;有此纪录,取参数
	    ;取坐标和位号
	    z=parseString(s " ")
	    if(ref!="0" then
		ref=nth(j z)
		if(k==5 ref=strcat(ref " " nth(j+1 z)))
	    )
	    k=length(z)
	    x=atof(nth(k-6 z))
	    y=atof(nth(k-5 z))
	    if( car(axlDBGetDesignUnits())=="mils" then
		range=80+atoi(nth(2 z))/2
		if(range>1000 range=120)
	    else
		range=3+atoi(nth(2 z))/2000
		if(range>25 range=3)
	    )	 
	    i=3
	    while(nth(i z)!="micron" && nth(i z)!="mil" && i<k
		i=i+1
	    )

	    thislayer=nth(1 z)
	    firstlayer=upperCase(firstlayer)
	    thislayer=upperCase(thislayer)
	    if(firstlayer!=thislayer then
		s=parseString(layers " ")
		layers=""
		if( thislayer=="SMT" || thislayer=="SMB"  || thislayer=="SST"  || thislayer=="SSB"  || thislayer=="SPT" || thislayer=="SPB" || thislayer=="COMP_+_TOP" || thislayer=="COMP_+_BOT" then
		    ;top bottom互换，包括_
		    foreach(a s 
			case(upperCase(a)
			("TOP" layers=strcat(layers " " "BOTTOM"))
			("BOTTOM" layers=strcat(layers " " "TOP"))
			(t 
			    i=nindex(a "_TOP")
			    j=nindex(a "_BOTTOM")
			    if(i!=nil layers=strcat(layers " " substring(a 1 i-1) "_BOTTOM"))
			    if(j!=nil layers=strcat(layers " " substring(a 1 j-1) "_TOP"))
			    if(i==nil && j==nil layers=strcat(layers " " a))
			)
			)
		    )
		else
		    if(substring(firstlayer 1 2)=="D_" || firstlayer=="DRILL" then
		    ;两个层换
			if(firstlayer=="DRILL" then
			    b=parseString(strcat("D_TOP_BOTTOM_" thislayer) "_")
			else
			    if(thislayer=="DRILL" then
				b=parseString(strcat(firstlayer "_D_TOP_BOTTOM") "_")
			    else
				b=parseString(strcat(firstlayer "_" thislayer) "_")
			    )
			)
			foreach(a s
			   a=upperCase(a)
			   if(a==nth(1 b) then
				layers=strcat(layers " " nth(4 b))
			   else
				if(a==nth(2 b) then
				    layers=strcat(layers " " nth(5 b))
				else
				    layers=strcat(layers " " a)
				)
			    )
			)
		    else
		    ;一个层换
			foreach(a s
			if(upperCase(a)==firstlayer then
			    layers=strcat(layers " " thislayer)
			else
			 
			    i=nindex(a "_TOP")
			    j=nindex(a "_BOTTOM")
			    if(i!=nil && thislayer=="BOTTOM" layers=strcat(layers " " substring(a 1 i-1) "_BOTTOM"))
			    if(j!=nil && thislayer=="TOP" layers=strcat(layers " " substring(a 1 j-1) "_TOP"))
			    if(i==nil && j==nil layers=strcat(layers " " a))
			)
			)
		    )
		)
	    )
	    
	    item(x y range ref layers)
	    
	else;无此纪录，详细内容超出,转向下一条
	    sub=1
	    cd1=cd1+1
	    cd2=1
	)
    )
    
    if(sub==1 then
	in_file="./detail_dis/pcb_display.txt"
	in=infile(in_file)
	fileLh=fileLength(in_file)
	i=0
	while(fileTell(in)<fileLh && i<cd1
	    gets(s in)
	    i=i+1
	);end while
	close(in)
	if(i==cd1 then;有此纪录,取参数
	    z=parseString(s "?")
	    s=nth(1 z)
	    j=strlen(s)-1
	    layers=substring(s 1 j)
	    s=parseString(nth(0 z) " ")
	    x=atof(nth(0 s))
	    y=atof(nth(1 s))
	    if( car(axlDBGetDesignUnits())=="mils" then
		range=80+atoi(nth(2 s))/2
		if(range>1000 range=120)
	    else
		range=3+atoi(nth(2 s))/2000
		if(range>25 range=3)
	    )	    
	    ref=nth(3 s)
	    if(length(s)==5 then ref=strcat(nth(3 s) " " nth(4 s)))
	    item(x y range ref layers)
	else;无此纪录，显示报告已完成
	    axlUIConfirm("This is over.")
	)
    )

)

defun( item (x y range ref layers)
    ;清空创建错误标记,显示层，移动坐标，部分高亮，窗口输出错误序号
    ;创建drc层
    class_sub = "manufacturing/viadrc_mark"
    axlLayerCreateNonConductor(class_sub)
    axlVisibleLayer(class_sub t)
    axlVisibleUpdate(t)

    ;删旧mark
    axlClearSelSet()	    
    axlSetFindFilter(?enabled `("NOALL" "LINES")	?onButtons `("LINES"))
    axlVisibleDesign(nil)
    axlVisibleLayer("manufacturing/viadrc_mark" t)
    axlAddSelectAll()
    axlDeleteObject(axlGetSelSet())

    ;显示层
    z=parseString(layers " ")
    k=length(z)
    i=0
    sprintf(s "k: %d" k)
    while(i<k
	s=parseString(nth(i z) "_")
	s=buildString(s " ")
	s=strcat(s "/" nth(i+1 z))
        ;由丝印层切换到assembly层
      
       if( strcmp(s "PACKAGE GEOMETRY/SILKSCREEN_TOP")==0  then s="PACKAGE GEOMETRY/ASSEMBLY_TOP" )
       if( strcmp(s "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM")==0  then s="PACKAGE GEOMETRY/ASSEMBLY_BOTTOM" )

  
	
        axlVisibleLayer(s t)

	i=i+2
    )
    
    ;高亮器件
    if(ref!="0" then
	axlSetFindFilter(?enabled (list "NOALL" "SYMBOLS") ?onButtons (list "SYMBOLS"))
	s=parseString(ref " ")
	axlSelectByName("REFDES" s)
    )
    ;创建新mark
    z=axlDBCreateLine(list(list(x-range y-range) list(x+range y+range) list(x+range y-range) list(x-range y+range) list(x-range y-range)) 0 class_sub)
    ;移动至mark区
    a=car(z)
    axlZoomToDbid(a t)

    ;窗口输出错误序号
    if(sub==1 then
	sprintf(s "item: %d" cd1)
    else
	sprintf(s "item: %d.%d" cd1 cd2)
    )
    println(s)
    axlVisibleUpdate(t)	     
)

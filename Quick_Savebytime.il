axlCmdRegister("wxsf" 'wxSaveFileBT)
;axlShell("alias sd wxsf date")
;axlShell("alias sf wxsf time")
/*
├─
│ ├─        程序名称：
│ ├─        程序功能：保存文件，并注上(覆盖)当前时间（日期）
│ ├─        创建时间：2012年08月22日
│ ├─        修改时间：
│ ├─        作    者：gpxknk
│ └─        备    注：
├─
2012年08月22日 统一格式，即XXX-1630.brd
2012年08月24日 添加日期，同时保持两种格式
命令行指令：
        sd : 保存为 XXX_MMdd_hhmm.brd
        sf : 保存为 XXX_hhmm.brd,也可能是 XXX_MMdd_hhmm.brd（只修改时间）
对于sD1 sD2 sT1 sT2:
        sD1;日期前缀 eg: _X0824_1200.brd
        sD2;日期后缀 eg: _0824X_1200.brd
        sT1;时间前缀 eg: _0824_X1200.brd
        sT2;时间后缀 eg: _0824_1200X.brd
        1.连接符还是统一用"_",而"-"说实在的不规范
        2.而日期（时间）中间不要插符号，如时间：_16.30.brd,"."用在基本文件名上说实在的也不规范
        3.不要出现'空格','.','\',':','?'等等等等字符
		
		

		
		8784.58 8758.00   上 26.58   3XLED
		
		
		8821.50    8782.00  上 39.5    2XLED
		
		
		rj45  17.3
*/
procedure( wxSaveFileBT(@optional (mode "date") )
prog( (tm sDate sTime sDName sDNameNew sPre sPost pt sD1 sD2 sT1 sT2)
        sD1= ""
        sD2= ""
        sT1= ""
        sT2= ""
        sDName= axlCurrentDesign()        ;axlGetDrawingName
        tm= timeToTm(stringToTime(getCurrentTime()))
        sTime= sprintf(nil,"_%s%2d%2d%s",sT1,tm->tm_hour,tm->tm_min,sT2)
        sDate= sprintf(nil,"_%s%2d%2d%s%s",sD1,tm->tm_mon + 1,tm->tm_mday,sD2,sTime)        ;;tm->tm_year
        rexCompile(" ")
        sTime= rexReplace(sTime,"0",0)
        sDate= rexReplace(sDate,"0",0)
        case(mode
                ("time" pt= strcat("^\\(.+\\)[-_]+",sT1,"[0-2][0-9]\\.*[0-5][0-9]",sT2,"$"),sPost=sTime)
                ("date" pt= strcat("^\\(.+\\)[-_]+",sD1,"[0-1][0-9][0-3][0-9]",sD2,"[-_]+",sT1,"[0-2][0-9]\\.*[0-5][0-9]",sT2,"$"),sPost=sDate)
                (t printf("ERROR:wxSaveFileBT: 'wxsf' argument error,\n"),return(nil))
        );case
        rexCompile(pt)
        if(rexExecute(sDName) then
                sPre= rexSubstitute( "\\1" )
                sDNameNew= strcat(sPre,sPost)
        else
                sDNameNew= strcat(sDName,sPost)
        );if
        axlSaveDesign(?design strcat(sDNameNew ".brd"))
		; axlSaveDesign(?design sDNameNew)
        printf("Save: [ %s ] --> [ %s ]\n",sDName,sDNameNew)
);prog
);procedure
;        printf("Save: [ ] --> [  ]\n")
; axlSaveDesign(?design "test.brd")


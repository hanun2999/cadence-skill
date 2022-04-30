/* 
├─ 
│ ├─        程序名称： Qview
│ ├─        程序功能：快速打开路径或者文件
│ ├─        创建时间：2013年10月17日 
│ ├─        作    者：王凯
│ ├─        Q      Q:263350809
├─
方法和注意：1，opendoc help-skill.pdf 命令即可打开对应文件
            2，仅用于本公司（Z盘），调用帮助文件。
*/

; load("Quick_docorpath.il")

axlCmdRegister("opendoc" 'Quick_docorpath)


defun( Quick_docorpath (@rest name)
      filename = car(name)
	  ; filename = "help-skill.pdf"
	  zis = or(isFile(filename "Z:/") isDir(filename "Z:/"))
      tis = or(isFile(filename "Z:/skill/") isDir(filename "Z:/skill/"))
	  bis = or(isFile(filename "Z:/skill/SKILL-learning") isDir(filename "Z:/skill/SKILL-learning"))
      cond(
	  (equal(zis t)
       axlHttp(strcat("Z:/" filename))
	   )
	  (equal(tis t)
       axlHttp(strcat("Z:/skill/" filename))
	   )	   
	  (equal(bis t)
       axlHttp(strcat("Z:/skill/SKILL-learning" filename))
	   )
	  (equal(or(zis tis bis) nil)
       axlUIConfirm("Please input the right DOC name or path")
	   )
	   
	  )
	  )
	  
	  
	  
	  
	  
	  
	  
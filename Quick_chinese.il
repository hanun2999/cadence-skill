;axlUIPrompt("Code:",sprintf(nil,"%L",axlUIPrompt("Please Input Chinese:")))

;load("Quick_chinese.il")

axlCmdRegister( "zwen" `ZhongWen_to_Skill_Form )

(defun ZhongWen_to_Skill_Form ()
			time = getCurrentTime()
			time = parseString(time)
			day = nth(1 time)
			month = car(time)
			month = upperCase(month)
			year = nth(3 time)
			date = strcat(" Date: " day " " month " " year)
			 Create_ZhongWen_to_Skill_Form()
			zhongwenform=axlFormCreate( (gensym) zhongwen_form_file nil 'ZhongWen_to_Skill_Form_Action t)
			axlFormDisplay(zhongwenform)
			axlUIWPrint(zhongwenform date)
			deleteFile(zhongwen_form_file)
		)


(defun Create_ZhongWen_to_Skill_Form ()
drain()
zhongwen_form_file = "zhongwen_form.form"
zhongwenform = outfile(zhongwen_form_file "w")
fprintf(zhongwenform "FILE_TYPE=FORM_DEFN VERSION=2\n")
fprintf(zhongwenform "FORM AUTOGREYTEXT\n")
fprintf(zhongwenform "FIXED\n")
fprintf(zhongwenform "PORT 91 25\n")
fprintf(zhongwenform "HEADER \"\326\320\316\304\311\372\263\311Skill\264\372\302\353\"\n\n")
fprintf(zhongwenform "POPUP <ENUM>\"ITEM1\"\"0\",\"ITEM2\"\"1\",\"ITEM3\"\"2\",\"LAST ONE\"\"3\".\n\n")
fprintf(zhongwenform "TILE\n\n")

fprintf(zhongwenform "TEXT \"\241\357 \307\353\312\344\310\353\326\320\316\304 \241\357\"\n")
fprintf(zhongwenform "FLOC 2 2\n")
fprintf(zhongwenform "ENDTEXT\n\n")

fprintf(zhongwenform "FIELD ZhongWen\n")
fprintf(zhongwenform "FLOC 2 5\n")
fprintf(zhongwenform "FSIZE 86 2\n")
fprintf(zhongwenform "STRFILLIN 86 1000\n")
fprintf(zhongwenform "ENDFIELD \n\n\n")

fprintf(zhongwenform "TEXT \"\241\356 \266\324\323\246Skill\264\372\302\353 \241\356\"\n")
fprintf(zhongwenform "FLOC 2 9\n")
fprintf(zhongwenform "ENDTEXT\n\n")

fprintf(zhongwenform "FIELD DaiMa\n")
fprintf(zhongwenform "FLOC 2 12\n")
fprintf(zhongwenform "FSIZE 86 2\n")
fprintf(zhongwenform "STRFILLIN 86 1000\n")
fprintf(zhongwenform "ENDFIELD \n\n\n")

fprintf(zhongwenform "FIELD CreateDaiMa\n")
fprintf(zhongwenform "FLOC 40 17\n")
fprintf(zhongwenform "MENUBUTTON \"\307\345\277\325\" 10 4\n")
fprintf(zhongwenform "ENDFIELD \n\n")

fprintf(zhongwenform "ENDTILE\n\n")
fprintf(zhongwenform "ENDFORM\n\n")

close(zhongwenform)
)


(defun ZhongWen_to_Skill_Form_Action (zhongwenform)

case(zhongwenform->curField
		("ZhongWen"
		values=axlFormGetField(zhongwenform "ZhongWen")
		axlFormSetField(zhongwenform "DaiMa" sprintf(nil "%L" values))		
		)
		("CreateDaiMa"
		axlFormSetField(zhongwenform "DaiMa" nil)
		axlFormSetField(zhongwenform "ZhongWen" nil)
		)
		("DaiMa")
	)
)

 ; axlUIConfirm("\316\322\265\304\271\244\327\367")
; axlFormSetField(zhongwenform "ZhongWen" 123)
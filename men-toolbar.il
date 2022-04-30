; load("men-toolbar.il")


defun(toolmenucreat (arg)
judge = axlGetVariable("autosave_dbcheck")
case(judge 
(nil

SKILLToolsMenu = '(
     (popup "\316\322\265\304\271\244\276\337")
/*	------------------------- 常用功能---------------------------	*/
     ("[\265\367\312\324\264\260\277\332]","set  telskill")
	 ("[\326\320\316\304\327\2528\275\370\326\306ASCII\302\353]"	 "zwen")
	 ("[\265\261\307\260\316\304\274\376\313\371\324\332\302\267\276\266]"	 "filemgr")
	 ("[\260\264\312\261\274\344\261\243\264\346]" "wxsf")
     ("\270\361\265\343\311\350\326\303"   "quick_grids")
	 ("\262\343\303\346\307\320\273\273"	 "quick_display")
	 ("\265\245\316\273\327\252\273\273"	 "conv")	 
	 ("\261\352\274\307STEP\304\243\320\315", "step pkg map")
	 (separator)
	 (popup "\317\356\304\277\306\300\311\363")
	 ("\306\364\266\257\306\300\311\363", "qidong")
	 ("\306\300\311\363\271\375\263\314", "pingshen")
	 ("\306\300\311\363\275\341\271\373", "huifu")
	 (end)
	 (separator)

	 
/*	------------------------ 丝印处理相关------------------------	*/
	 
	 (popup "\313\277\323\241\271\244\276\337")
	 ("\327\324\266\257\320\375\327\252\316\273\272\305","ro_text") 
	 ("\327\324\266\257\316\273\272\305\271\351\326\320","mc_ref")\
	 ("\316\273\272\305\265\274\310\353/\265\274\263\366","text_out_in")
	 ("\327\326\314\345\264\363\320\241\311\350\326\303","quick_textset")
	 ("\327\326\314\345\266\324\306\353","align_text")
	 (separator)	 
	 ("\274\354\262\351\313\277\323\241\270\311\311\346","ch_text_overlap")
	 ("\274\354\262\351\313\277\323\241\275\307\266\310","ch_refrota")
	 ("\274\354\262\351\313\277\323\241\310\261\312\247","ch_noref")
	 (end)	 
	 
/*	------------------------ Layout工具------------------------	*/
	 (popup "Layout\271\244\276\337")
	 ("\262\356\267\326\265\367\325\373"  "resize_respace_dp")
	 ("\260\345\262\343\311\350\326\303"	 "addlayer")
	 ("\322\376\262\330/\317\324\312\276\315\255\306\244"	 "opclspfill")	 
	 ("\321\330\260\345\277\362\264\264\275\250ANTIETCH" "anti_create")
	 ("\315\263\322\273\320\336\270\304\317\337\277\355"	 "cwidth")		 
	 ("\307\320\270\356\317\337/\315\255\306\244\271\244\276\337"	 "cut")
	 ("\314\355\274\323\265\271\324\262\275\307\276\330\320\316\315\255\306\244"	 "x_rs ")
	 ("\327\337\317\337\327\252\316\252\315\255\306\244"	 "c2s")
	 ("\270\337\301\301\316\264\311\310\263\366\275\305"	"hl_nf")	 
	 ("\314\355\274\323\306\275\272\342\315\255\277\351" "auto balance")
	 ("\320\336\270\304\315\370\302\347\312\364\320\324"	 "net_editor")
	 ("\320\336\270\304\271\375\277\327\313\371\312\364\315\370\302\347"	 "cvia")
	 (separator)	
	 ("\274\354\262\351\266\317\315\267\317\337/\271\375\277\327","quick_dangling")
  	 ("\274\354\262\351\261\355\314\371\324\255\274\376\265\275\262\345\274\376\275\305\276\340","quick_smd2thrp")
	 ("\274\354\262\351\317\337\277\355","checkwidth")	
	 ("\274\354\262\351\327\350\272\270\265\275\327\337\317\337\276\340\300\353" "solder2line check")
	 ("\274\354\262\351\316\336\315\370\302\347\315\255\306\244","uc shape")
	 ("\317\324\312\276\270\337\266\310\262\316\312\375","show_height")
	 ("\274\354\262\351\316\336\270\337\266\310\320\305\317\242\306\367\274\376","upd_fe_height")
	 (end)
	 
/*	------------------------ 辅助工具------------------------	*/	 
	 (popup "\270\250\326\372\271\244\276\337")	 
	 ("\321\325\311\253\327\324\266\257\311\350\326\303"	 "quick_colorset")
	 ("\262\343\317\324\312\276\277\330\326\306" "visibility")
	 ("\312\326\266\257\260\332\267\305\306\367\274\376" "place_symbols")	 
	 ("\306\367\274\376\266\324\306\353"	 "xasym")
	 ("\306\367\274\376\265\310\276\340"	 "esym")
	 ("\270\337\301\301\316\336\315\370\302\347\271\375\277\327"	 "hlvia")
	 ("\270\337\301\301\316\336\315\370\302\347\322\375\275\305"	 "hl_null_pin")	 
	 ("\262\343\317\324\312\276\277\330\326\3062"	 "etch visibility")
	 ("\270\361\265\343\271\244\276\337" "grid_system")
	 ("\306\367\274\376\266\324\306\353\265\275\270\361\265\343"   "comps grid")
	 (end)

	 
/*	------------------------ 后处理工具------------------------	*/	 
	 (popup "\271\342\273\346\271\244\276\337")
	 ("\267\305\326\303\262\343\265\376\320\305\317\242" "xs")	 
	 ("\327\324\266\257\311\350\326\303\271\342\273\346\262\343" "quickart")
	 ("\327\324\266\257\265\275\264\246\271\342\273\346\316\304\274\376" "UIchoose")
	 ("\261\355\314\371\322\375\275\305\261\250\270\346" "report SMD rate")
	 ("\311\276\263\375\271\342\273\346\316\304\274\376" "cam clear")	 
	 (end)

/*	------------------------ 绘图工具------------------------	*/	 
	 (popup "\306\344\313\373\271\244\276\337")
	 ("\264\264\275\250\315\326\324\262FLASH"	 "cot")	 
	 ("\327\324\266\257\264\264\275\250\272\270\305\314"	 "ct pad")	 
	 ("\271\375\277\327\266\324\306\353"	 "align_via")
	 ("\317\324\312\276\277\342\302\267\276\266","show library")
	 ("\317\324\312\276\270\326\315\370\262\343\320\305\317\242","paste")	 	 
	 (end)

/*	------------------------ 导出工具------------------------	*/	 
	 (popup "\265\274\263\366")
	 ("\322\375\275\305\315\370\302\347\271\330\317\265\261\355"	 "quick_p2net")
	 ("\265\274\263\366\277\342\316\304\274\376"	 "dumplib")
	 ("\265\274\263\366cad"	 "cds2f")
	 ("\265\274\263\366IPC"	 "listratt")
	 ("\265\274\263\366\262\356\267\326"	 "dp_rep")
	 (end)
	 ("\271\244\276\337\260\357\326\372","opendoc help-skill.pdf")
     ("\271\330\323\332","notice")
	 ))
	 
	 (t
	 
     SKILLToolsMenu = '(
     (popup "MY_tools")
/*	------------------------- 常用功能---------------------------	*/

     ("[Skill Window-for debug]","set  telskill")
	 ("[CN-CODE]"	 "zwen")
	 ("[Workdir]"	 "filemgr")
	 ("[Save by time]" "wxsf")
     ("Quick Grids"   "quick_grids")
	 ("Quick View"	 "quick_display")
	 ("Quick Conv unit"	 "conv")	 
	 ("STEP setup", "step pkg map")
	 (popup "Project Tools")
	 ("Quick begin", "qidong")
	 ("Quick reviews", "pingshen")
	 ("Quick callback", "huifu")
	 (end)
	 (separator)	 
/*	------------------------ 丝印处理相关------------------------	*/
	 
 
	 (popup "SilkScreen Tools")
	 ("Text Rotate","ro_text") 
	 ("Text Center","mc_ref")\
	 ("Text Out & in","text_out_in")
	 ("Text Set" "quick_textset")
	 ("Text Align","align_text")
	 (separator)	 
	 ("Ch_Text_overlap","ch_text_overlap")
	 ("Ch_Text_rotation","ch_refrota")
	 ("Ch_Noref","ch_noref")
	 (end)	 
/*	------------------------ Layout工具------------------------	*/

	 (popup "Layout Tools")
	 ("Quick DP_change" "resize_respace_dp")
	 ("Quick Layer"	 "addlayer")
	 ("Quick noshape"	 "opclspfill")	 
	 ("Quick AntiEtch" "anti_create")
	 ("Quick Change width"	 "cwidth")		 
	 ("Quick Cut"	 "cut")
	 ("Quick Shape"	 "x_rs ")
	 ("Quick Cline To Shape"	 "c2s")
	 ("Quick hlnp"	"hl_nf")	 
	 ("Quick balance" "auto balance")
	 ("Change net"	 "net_editor")
	 ("Change via net"	 "cvia")
	 (separator)	
	 ("Ch_dangling","quick_dangling")
  	 ("Ch_sdmsym2PTH","quick_smd2thrp")
	 ("Ch_width","checkwidth")	
	 ("Ch_solder-cline" "solder2line check")
	 ("Ch_nc shape","uc shape")
	 ("Ch_height","show_height")
	 ("Ch_noheight","upd_fe_height")
	 (end)	 
/*	------------------------ 辅助工具------------------------	*/	 

	 (popup "Aux Tools")	 
	 ("Quick Color set"	 "quick_colorset")
	 ("Quick view visibility" "visibility")
	 ("Quick place sym" "place_symbols")	 
	 ("Quick Alignsym"	 "xasym")
	 ("Quick Eqsym"	 "esym")
	 ("Quick HL nonet via"	 "hlvia")
	 ("Quick HL_dummy pin"	 "hl_null_pin")	 
	 ("Quick Etch visibility"	 "etch visibility")
	 ("Quick gridsys" "grid_system")
	 ("Quick comps grids"   "comps grid")
	 (end)
	 
/*	------------------------ 后处理工具------------------------	*/	 

	 (popup "Art Tools")
	 ("Quick Stack" "xs")	 
	 ("Quick Artwork" "quickart")
	 ("Quick ART out" "UIchoose")
	 ("Quick repSMDpin" "report SMD rate")
	 ("Quick del art" "cam clear")	 
	 (end)
/*	------------------------ 绘图工具------------------------	*/	 

	 (popup "Other Tools")
	 ("Creat Ot flash"	 "cot")	 
	 ("Create pad"	 "ct pad")	 
	 ("Align_via"	 "align_via")
	 ("Show lib path","show library")
	 ("Show paste","paste")	 	 
	 (end)
/*	------------------------ 导出工具------------------------	*/	 
	 (popup "EXPORT")
	 ("Export Pin2Net connection"	 "quick_p2net")
	 ("Export lib"	 "dumplib")
	 ("Export cad"	 "cds2f")
	 ("Export IPC"	 "listratt")
	 ("Export diff"	 "dp_rep")
	 (end)
	 ("Skill_Help","opendoc help-skill.pdf")	 
     ("About","notice")
	 )	 
	 )	 
	

	)
        let( (q)
        q = axlUIMenuFind(nil -1)
        res = axlUIMenuInsert(q SKILLToolsMenu)
        )
)
axlTriggerSet('menu  'toolmenucreat)	 


	  
axlCmdRegister("notice" 'notice)
	 
defun(notice ()
let( (judgen)
     judgen = axlGetVariable("autosave_dbcheck")
     if(
	 judgen == nil
	 then
      axlUIConfirm("\310\347\271\373\320\350\322\252\270\374\270\304\323\357\321\324,\307\353\324\332\323\303\273\247\311\350\326\303\326\320\271\264\321\241autosave_dbcheck\321\241\317\356!")
	  else
	  axlUIConfirm("If you want change the language,Please select the autosave_dbcheck option or not!")
	  ; 
	  
	  )
	  )
	  ) 


	 
	 
	 
	 
	 
	 
	 
	 
/*	------------------------ 待测工具------------------------	*/	 	 
	 ; (popup "Unuseful Tools")
	 ; ("Hilight via","h_via_main")
	 ; ("Fanout_bbvia","fanout_bbvia")
	 ; ("Viacheck","viacheck")
	 ; ("RF-keepout","clear_RF")
	 ; ("Auto Via","auto_via")
	 ; ("Diff report","diff_Check_Routine")
	 ; ("Ch_netname longer","ipc_356")
	 ; (end)	

	 
	 
	 
     ; ("Cut cline"	 "clinecut")	 
	 ; ("Cut shape"	 "cutshape")	 
	 ; ("Quick valor" "valor out")	
	 ; ("Add pin_number"	 "apn")	
	 ; ("Export pards" "brd_pads")	 
	 ; ("Export report"	 "dl")	 
	 ; ("Ch_stackvias","sv")	 
	 ; ("Ch_sym_lib","symbol check")		 
	 ; ("Component_changes"	 "component_changes")
	 ; ("Film_reorder"	 "film_reorder")
	 ; ("Pickdata"	 "pickdata")
	 ; ("Qfp_pitch_calculate"	 "qfp_pitch")	 	 
	 ; ("Splitring"	 "splitring")
	 ; ("Ch_Refdir","ch_dir")
	 ; ("Show place list" "place list")	
	 ; ("Ch_Cline90" "loop90 Check")
	 ; ("Ch_nc_via","ch_nc_via")	 
	 ; ("Ch_no_refdes","check_no_refdes")
	 ; ("Ch_Drc walk","drc walk")
	 ; ("Quick Search" "SearchStar")
	 ; ("Quick gridsave2env" "grid_setenv")
     ; ("Quick Add ICT" "add ict")
	 ; ("Hl_npe"	 "hl_npe")
	 ; ("Hl_ntp"	 "hl_ntp")

	 ;dsy_setlayout-------------
	 ;find_dang
	 ;find drc
	 ;ch_wave_sym restore_refdes
	 ;rmxdrc	 
	 ;ch_fanoutwidth
	 ;hl_nf hl_nf_botm hl_nf_top
	 ;super_net_finder
	 ;make device
	 ;rename ref des
	 ;replace_via update_via
     ;draw targets
     ;mkth
	 ;flareBoard unflareBoard flareLayer unflareLayer
	 ;editbrd	 
	 ;ch_ref ch_refskip
	 ;update_symbols
	 ;del_via
	 ;viewrep
	 ;ch_cross
	 ;lgs_tech_in
	 ;mirror_text	 
	 ;ruler
	 ;runalgrplt
	 ;push_shapes copy_shape
	 ;extracts valor extract info
	 ;valor film info
	 ;layer list	
	 ;height	 



	 

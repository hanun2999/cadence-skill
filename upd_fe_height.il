;;#####################################################################################################
;;
;;     _|  _|_|_|_|_\    _/    LTX Corporation
;;     _|      _|   _\  _/     145 University Ave
;;     _|      _|    _\_/      Westwood,MA 02090
;;     _|      _|     _/       WW-32
;;     _|      _|    _/_\
;;     _|      _|   _/  _\     T 781 467 5336
;;     _|_|_|_|_|  _/    _\    F 781 329 6880
;;                             andy_kulik@ltx.com
;;
;;
;;  Author     : Andreas Kulik
;;
;;  Created    : 10-09-2003
;;
;;#####################################################################################################
;; Use this code at your own risk. The Author is under no circumstances responsible for any damage and
;; resulting consequences this script may cause. The script is provided as is and may be modified if
;; this notice and the revision history is maintained.
;;#####################################################################################################
;;
;; File         : upd_fe_height.il (TESTED with 14.2 on Windows2000)
;;
;; Description  : "Update all PACKAGE_HEIGHT_MAX properties with the values of the HEIGHT property"
;;                This program replaces the value of PACKAGE_HEIGHT_MAX property of each component
;;                with the value of the Front-End HEIGHT property attached to the Component Definition
;;                The program seperates components into two categories:
;;                          1) components with only on PLACE_BOUND_TOP/BOTTOM
;;                          2) components with multiple place bounds
;;                Both categories are displayed in a FORM window.
;;                Components with one Place_Bound figure are shown in a tree widget of the following style
;;
;;                <Symbol-Name1>
;;                      <PART_NUMBER_A>
;;                           <REFDES_1>
;;                           <REFDES_2>
;;                <Symbol-Name2>
;;                      <PART_NUMBER_B>
;;                           <REFDES_3>
;;                           <REFDES_4>
;;                <Symbol-Name3>
;;                      <PART_NUMBER_C>
;;                           <REFDES_5>
;;
;;                Components with multiple place_bounds are displayed in a second TAB. The TAB is made of
;;                two list widgets. The top one displaying the component. Upon selection the bottom
;;                list widget will display the place_bounds. Selecting a place_bound will highlight it
;;                in Allegro and zoom to its location using its BoundaryBox.
;;
;;                All changes to height values on components with one place_bound are written
;;                to a log file including a time_stamp in the filename
;;
;; Note         : 1) The HEIGHT property is a valid ConceptHDL property defining the component height.
;;                   Allegro uses PACKAGE_HEIGHT_MAX/MIN to detect height violations. IF the user uses
;;                   the HEIGHT property to manage component heights the DRC functionality is lost.
;;                2) This program also detects components with no HEIGHT property and writes a log file
;;                3) Components with equal values of PACKAGE_HEIGHT_MAX and HEIGHT are ignored
;;                4) If a component has no PART_NUMBER property attached to the component definition
;;                   the program will use "NO_PARTNUMBER" as the PART_NUMBER value.
;;
;; Limitations  : 1) Changes to components with multiple place bounds are not written to a log file
;;                2) The assumptions is made that the HEIGHT property has the correct value of the
;;                   component HEIGHT and that there is a relationship between HEIGHT and PART_NUMBER
;;
;; Installation : 1) place this file into your pcbenv directory and add the following line to your
;;                   allegro.ilinit file
;;
;;                       (load "upd_fe_height.il")
;;
;;                2) Type the following in the console window to launch the program
;;
;;                       upd_fe_height
;;
;;                2) <Optional> Add the following to your menu file where <menuitem> is
;;                   the name of a pulldown menu in Allegro
;;
;;                   POPUP "<menuitem>"
;;                     BEGIN
;;                         MENUITEM "Update Height Values", "upd_fe_height"
;;	               END
;;
;;#####################################################################################################
;; Revision History:
;;
;; Version  Rev.    Date        Name          Changes
;;-----------------------------------------------------------------------------------------------------
;;    1.0    0    10-24-2003   A. Kulik       Original
;;    1.1    0    11-18/2003   A. Kulik       Added components located on the bottom layer
;;#####################################################################################################
(defun AK_upd_height ()

  symdef_list = axlDBGetDesign()->symdefs
  height_list_single = nil
  height_list_mult   = nil
  height_list_none   = nil
  (foreach symdef_dbid symdef_list
	   (if symdef_dbid->type == "PACKAGE" then
	       name     = symdef_dbid->name ; footprint name
	       (foreach instance symdef_dbid->instances
			refdes = instance->refdes
			(if instance->isMirrored then
			  layer = "BOTTOM"
			  isbottom = t
			  else
			  layer = "TOP"
			  isbottom = nil
			  );
			;; get the compdef properties
			comp_dbid  = instance->component
			height     = instance->component->compdef->prop->HEIGHT
			part_num   = instance->component->compdef->prop->PART_NUMBER
			add2to_noheightlist = nil
			(if height == nil then
			  add2to_noheightlist = t
			  else
			  (if atof(height) == nil then
			      height  = axlMKSStr2UU(height)
			      ;; height is not a number
			      add2to_noheightlist = t
			      else
			      height  = axlMKSStr2UU(height)
			      );end-if
			  );end-if
			(if part_num == nil then
			    part_num = "NO_PARTNUMBER"
			    );
			(if instance->component->symbol then
			  ;;symbol is placed
			  plcb_list = nil
			  plcb_cnt = 0
			  addtolist = nil
			  (foreach child_dbid instance->children
				   (if child_dbid->objType == "shape" then
				       (if isbottom == t then
					   (if child_dbid->layer == "PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM" then
					       plcb_cnt = plcb_cnt + 1
					       pkg_height_max = child_dbid->prop->PACKAGE_HEIGHT_MAX
					       plcb_data = list(child_dbid pkg_height_max)
					       plcb_list = cons(plcb_data plcb_list)
					       (if height != pkg_height_max then
						   addtolist = t
						   );if height
					       );if child_dbid

					   else

					   (if child_dbid->layer == "PACKAGE GEOMETRY/PLACE_BOUND_TOP" then
					       plcb_cnt = plcb_cnt + 1
					       pkg_height_max = child_dbid->prop->PACKAGE_HEIGHT_MAX
					       plcb_data = list(child_dbid pkg_height_max)
					       plcb_list = cons(plcb_data plcb_list)
					       (if height != pkg_height_max then
						   addtolist = t
						   );if height
					       );if child_dbid
					   );if is bottom
				       );if
				   );foreach
			  height_list_data = list(name part_num height refdes comp_dbid plcb_list layer)
			  (if add2to_noheightlist == t then
			      height_list_none = cons( height_list_data height_list_none)
			      else
			      (if addtolist == t then
				  (if plcb_cnt > 1 then
				      height_list_mult   = cons( height_list_data height_list_mult)
				      else
				      height_list_single = cons( height_list_data height_list_single)
				      );if
				  );if
			      );if
			  );if
			);end-foreach
	       );end-if
	   );foreach

  height_list_single = sortcar(height_list_single nil)
  height_list_mult   = sortcar(height_list_mult nil)
  height_list_none   = sortcar(height_list_none nil)
  ;;axlMeterDestroy()
  t
);
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun AK_CreateForm ()
  form_file = "upd_height.form"
  form = outfile(form_file "w")
  fprintf( form "FILE_TYPE=FORM_DEFN VERSION=2\n")
  fprintf( form "FORM\n")
  fprintf( form "FIXED\n")
  fprintf( form "PORT 50 21\n")
  fprintf( form "HEADER \"Update Front-End Height Property\"\n")
  fprintf( form "\n")
  fprintf( form "\n")
  fprintf( form "TILE\n")

  fprintf( form "TABSET \"1\"\n")
  fprintf( form "FLOC 1 1\n")
  fprintf( form "FSIZE 48 40\n")

  fprintf( form "TAB \"Single PlaceBounds\"\n")
  fprintf( form "FIELD Tree_Single\n")
  fprintf( form "FLOC 3 1\n")
  fprintf( form "TREEVIEW  40 15\n")
  fprintf( form "ENDFIELD\n")
  fprintf( form "FIELD Update_Height_Single\n")
  fprintf( form "FLOC 3 32\n")
  fprintf( form "MENUBUTTON \"Update Height\" 4 3\n")
  fprintf( form "ENDFIELD\n")
  fprintf( form "FIELD Select_All_Single\n")
  fprintf( form "FLOC 20 32\n")
  fprintf( form "MENUBUTTON \"Select All\" 4 3\n")
  fprintf( form "ENDFIELD\n")
  fprintf( form "FIELD DeSelect_All_Single\n")
  fprintf( form "FLOC 30 32\n")
  fprintf( form "MENUBUTTON \"Deselect All\" 4 3\n")
  fprintf( form "ENDFIELD\n")
  fprintf( form "\n")
  fprintf( form "ENDTAB\n")

  fprintf( form "TAB \"Multiple Place Bounds\"\n")
  fprintf( form "TEXT \"Components\"\n")
  fprintf( form "TLOC 3 1\n")
  fprintf( form "ENDTEXT\n")
  fprintf( form "FIELD Comp_List_Field\n")
  fprintf( form "FLOC 3 3\n")
  fprintf( form "LIST \"\" 35 7\n")
  fprintf( form "ENDFIELD\n")
  fprintf( form "\n")
  fprintf( form "TEXT \"Place_bounds\"\n")
  fprintf( form "TLOC 3 18\n")
  fprintf( form "ENDTEXT\n")
  fprintf( form "\n")
  fprintf( form "FIELD PLCB_List_Field\n")
  fprintf( form "FLOC 3 20\n")
  fprintf( form "LIST \"\" 35 4\n")
  fprintf( form "ENDFIELD\n")
  fprintf( form "TEXT \"Comp Height\"\n")
  fprintf( form "TLOC 3 28\n")
  fprintf( form "ENDTEXT\n")
  fprintf( form "\n")
  fprintf( form "TEXT\n")
  fprintf( form "TLOC 15 28\n")
  fprintf( form "INFO Comp_Height_Msg_Field 15\n")
  fprintf( form "ENDTEXT\n")
  fprintf( form "\n")
  fprintf( form "TEXT \"PlcBnd Height\"\n")
  fprintf( form "TLOC 3 30\n")
  fprintf( form "ENDTEXT\n")
  fprintf( form "\n")
  fprintf( form "TEXT\n")
  fprintf( form "TLOC 15 30\n")
  fprintf( form "INFO PLCB_Height_Msg_Field 15\n")
  fprintf( form "ENDTEXT\n")

  fprintf( form "FIELD Update_Height_Mult\n")
  fprintf( form "FLOC 3 34\n")
  fprintf( form "MENUBUTTON \"Update Height\" 4 3\n")
  fprintf( form "ENDFIELD\n")
  fprintf( form "\n")
  fprintf( form "ENDTAB\n")

  fprintf( form "ENDTABSET\n")
  fprintf( form "FIELD Reread_Db\n")
  fprintf( form "FLOC 6 42\n")
  fprintf( form "MENUBUTTON \"Reread DB\" 4 3\n")
  fprintf( form "ENDFIELD\n")
  fprintf( form "\n")
  fprintf( form "FIELD Exit_Field\n")
  fprintf( form "FLOC 33 42\n")
  fprintf( form "MENUBUTTON \" Exit \" 4 3\n")
  fprintf( form "ENDFIELD\n")
  fprintf( form "\n")
  fprintf( form "ENDTILE\n")
  fprintf( form "\n")
  fprintf(form "ENDFORM\n")
  close(form)
);
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun Height_Form_Routine ()

  axlFlushDisplay()

  ;; read in the form
  (if Height_Form == nil then
      Height_Form = axlFormCreate( (gensym) form_file '("W" "OUTER") 'Height_Form_Action nil)
      );
  sym_list = nil
  sym_tree_list = nil
  total_comps = 0
  (foreach item height_list_single
	   sym_name  = nth(0 item)
	   part_num  = nth(1 item)
	   refdes    = nth(3 item)

	   (if member(sym_name sym_list) == nil then
	       sym_list  = cons(sym_name sym_list)
	       st_item   = axlFormTreeViewAddItem(Height_Form "Tree_Single" sym_name nil nil t)
	       pn_tree_list  = nil
	       pn_list   = nil

	       else
	       (foreach sym sym_tree_list
			symbol       = nth(0 sym)
			(if symbol == sym_name then
			    st_item = nth(1 sym)
			    pn_tree_list = nth(2 sym)
			    pn_list      = nth(3 sym)
			    );
			);
	       );

	   (if member(part_num pn_list) == nil then
	       pn_list = cons(part_num pn_list)
	       stp_item = axlFormTreeViewAddItem(Height_Form "Tree_Single" part_num st_item nil t)
	       data = list(part_num stp_item)
	       pn_tree_list = cons(data pn_tree_list)
	       ref_item = axlFormTreeViewAddItem(Height_Form "Tree_Single" refdes stp_item nil nil)
	       else
	       (foreach pnitem pn_tree_list
			pn     = nth(0 pnitem)
			(if part_num == pn then
			    parent = nth(1 pnitem)
			    ref_item = axlFormTreeViewAddItem(Height_Form "Tree_Single" refdes parent nil nil)
			    );
			);
	       );
	   temp_list = nil
	   found_entry = nil
	   sym_data  = list(sym_name st_item pn_tree_list pn_list)
	   (if sym_tree_list == nil then
	       sym_tree_list = cons(sym_data sym_tree_list)
	       else
	       (foreach treeitem sym_tree_list
			name = nth(0 treeitem)
			(if name == sym_name then
				temp_list = cons(sym_data temp_list)
				found_entry = t
				else
				temp_list = cons(treeitem temp_list)
				);
			);
	       sym_tree_list = temp_list
	       (if found_entry == nil then
		   sym_tree_list = cons(sym_data sym_tree_list)
		   );
	       );
	   axlFormTreeViewSet(Height_Form "Tree_Single" 'TV_SORTCHILDREN stp_item)
	   axlFormTreeViewSet(Height_Form "Tree_Single" 'TV_SORTCHILDREN st_item)
	   );
  ;; Components with multiple placebounds
  axlFormListDeleteAll(Height_Form "Comp_List_Field")
  axlFormSetField(Height_Form "Comp_List_Field" nil)
  axlFormListDeleteAll(Height_Form "PLCB_List_Field")
  axlFormSetField(Height_Form "PLCB_List_Field" nil)
  axlFormSetFieldEditable( Height_Form "Update_Height_Mult" 0 )

  (foreach item height_list_mult
	   sym_name  = nth(0 item)
	   part_num  = nth(1 item)
	   refdes    = nth(3 item)
	   layer     = nth(6 item)
	   xy        = comp_dbid->symbol->xy
	   (if comp_dbid->symbol->isMirrored then
	     layer = "BOTTOM"
	     else
	     layer = "TOP"
	     );
	   sprintf( sel_field "%s %s %L" refdes, layer, xy)
	   axlFormSetField(Height_Form "Comp_List_Field" sel_field)
	   );end-foreach


  show_confirm = nil
  (if length(height_list_none) >= 1 then
      ;; generate report for components with no height property
      show_confirm = t
      time = getCurrentTime()
      rexCompile(" ")
      time = rexReplace(time "_" 0)
      rexCompile(":")
      time = rexReplace(time "_" 0)
      sprintf(filename "Components_No_Height_%s.dat" time)
      oport = outfile(filename "w")
      fprintf(oport "*****************************************************\n")
      fprintf(oport "*                 R E P O R T                       *\n")
      fprintf(oport "*      Components with missing HEIGHT property      *\n")
      fprintf(oport "*  (Please forward this file to the EDA Librarian)  *\n")
      fprintf(oport "*****************************************************\n\n")
      fprintf(oport "Filename: %s\n\n" filename);
      fprintf(oport "-----------------------------------------------------\n")
      (foreach item height_list_none
	       sym_name  = nth(0 item)
	       part_num  = nth(1 item)
	       refdes    = nth(3 item)
	       layer     = nth(6 item)
	       fprintf(oport "LTX Partnumber : %s\n" part_num)
	       fprintf(oport "Allegro Symbol : %s\n" sym_name)
	       fprintf(oport "Layer          : %s\n" layer)
	       fprintf(oport "Refdes         : %s\n" refdes)
	       fprintf(oport "-----------------------------------------------------\n")
	       );
      close(oport)
      );
  axlFormTreeViewSet(Height_Form "Tree_Single" 'TV_NOEDITLABEL nil)

  (if show_confirm == t then
      (if axlUIYesNo("Found Components with missing HEIGHT property\n\nDo you want to see the log file?") then
	  (if isFile(filename) then
	      (if neq(logWindow nil)
		logWindow = axlUIWClose(logWindow)
		); end if
	      logWindow = axlUIViewFileCreate(filename "Report - Comps No Height" nil)
	      );
	  );
      );
  axlFormDisplay(Height_Form) 		; display the form
  );
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun Height_Form_Action (height_form)
  case(Height_Form->curField                ; contains name of field that has been touched
       ("Comp_List_Field"
	sel    = (Height_Form->curValue) ; stores value user put in field to program variable
	selidx = (Height_Form->curValueInt); stores index of selection on list
	axlFormSetFieldEditable( Height_Form "Update_Height_Mult" 0 )
	;; dehiglight highlighted place bounds
	axlDehighlightObject(hilite_list nil)
	hilite_list = nil
	(if sel == nil then	; no more stubs in list, lock buttons

	    printf("%s\n" "nothing selected")
	    else
	    item = nth(selidx height_list_mult)
	    sym_name  = nth(0 item)
	    part_num  = nth(1 item)
	    height    = nth(2 item)
	    refdes    = nth(3 item)
	    comp_dbid = nth(4 item)
	    plcb_list = nth(5 item)
	    layer     = nth(6 item)
	    xy        = comp_dbid->symbol->xy
	    Bbox      = comp_dbid->symbol->bBox
	    cnt = 1
	    Zoom(Bbox)
	    axlFormListDeleteAll(Height_Form "PLCB_List_Field")
	    foreach(plcb plcb_list
			 plcb_bbox   = nth(0 plcb)->bBox
			 plcb_height = nth(1 plcb)
			 sprintf( sel_field "%d %L" cnt, plcb_bbox)
			 axlFormSetField(Height_Form "PLCB_List_Field" sel_field)
			 cnt = cnt + 1
			 );
	    axlFormSetField(Height_Form "PLCB_List_Field" nil)
	    axlFormSetInfo( Height_Form "Comp_Height_Msg_Field" height)
	    );
	);
       ("PLCB_List_Field"
	sel     = (Height_Form->curValue) ; stores value user put in field to program variable
	plcbidx = (Height_Form->curValueInt)
	axlFormSetFieldEditable( Height_Form "Update_Height_Mult" 1 )
	;; dehiglight highlighted place bounds
	axlDehighlightObject(hilite_list nil)
	hilite_list = nil

	(if sel == nil then	; no more stubs in list, lock buttons

	    printf("%s\n" "nothing selected")
	    else
	    item = nth(selidx height_list_mult)
	    plcb_list   = nth(5 item)
	    plcb        = nth(plcbidx plcb_list)
	    plcb_dbid   = nth(0 plcb)
	    plcb_bbox   = plcb_dbid->bBox
	    plcb_height = nth(1 plcb)
	    axlFormSetInfo( Height_Form "PLCB_Height_Msg_Field" plcb_height)
	    Zoom(plcb_bbox)
	    ;; highlite the place_bound
	    hilite_list = cons(plcb_dbid hilite_list)
	    axlHighlightObject(hilite_list nil)

	    );
	);
       ("Exit_Field"
	;; dehiglight highlighted place bounds
	axlDehighlightObject(hilite_list nil)
	hilite_list = nil
	axlFlushDisplay()		; forces screen refresh so dehighlight takes effect
	axlFinishEnterFun()
	axlFormClose(Height_Form)
	t
	);
       ("Update_Height_Single"

	AK_get_tree_items(); this function stores all selected items in single_data_list
	show_confirm = t
	time = getCurrentTime()
	rexCompile(" ")
	time = rexReplace(time "_" 0)
	rexCompile(":")
	time = rexReplace(time "_" 0)
	sprintf(filename "upd_fe_height_single_PLCB_%s.log" time)
	oport = outfile(filename "w")
	fprintf(oport "*****************************************************\n")
	fprintf(oport "*                                                   *\n")
	fprintf(oport "*            Update Front-End Height Log            *\n")
	fprintf(oport "*                                                   *\n")
	fprintf(oport "*****************************************************\n\n")
	(foreach item single_data_list
		 ftp_name = nth(0 item)
		 pn_num   = nth(1 item)
		 (foreach item height_list_single
			  sym_name  = nth(0 item)
			  (if ftp_name == sym_name then
			      part_num  = nth(1 item)
			      (if pn_num == part_num then
				  height    = nth(2 item)
				  refdes    = nth(3 item)
				  comp_id   = nth(4 item)
				  plcb_list = nth(5 item)
				  layer     = nth(6 item)
				  proppair = list("PACKAGE_HEIGHT_MAX" axlMKSConvert(height car(axlDBGetDesignUnits())))
				  plcb_dbid  = nth(0 car(plcb_list))
				  pkg_height = nth(1 car(plcb_list))
				  (if pkg_height == nil then
				      pkg_height = "NONE"
				      );
				  (if axlDBAddProp(plcb_dbid proppair) then
				      fprintf(oport "Component      : %s\n" refdes)
				      fprintf(oport "LTX Partnumber : %s\n" part_num)
				      fprintf(oport "Allegro Symbol : %s\n" sym_name)
				      fprintf(oport "Layer          : %s\n" layer)
				      fprintf(oport "Height changed from %s -> %s\n" pkg_height,height);
				      fprintf(oport "-----------------------------------------------------\n")
				      );
				  );
			      );
			  );
		 );
	close(oport)
	;; need to refresh ids in order for changes to take affect
	axlDBRefreshId(nil)
	(if isFile(filename) then
	    (if neq(logWindow nil)
	      logWindow = axlUIWClose(logWindow)
	      ); end if
	    logWindow = axlUIViewFileCreate(filename "Update Heigth Log" nil)
	    );
	);
       ("Update_Height_Mult"

	proppair = list("PACKAGE_HEIGHT_MAX" axlMKSConvert(height car(axlDBGetDesignUnits())))
	plcb_dbid  = nth(0 car(plcb_list))
	pkg_height = nth(1 car(plcb_list))
	(if pkg_height == nil then
	    pkg_height = "NONE"
	    );
	(if axlDBAddProp(plcb_dbid proppair) then
	    ;; remove comp from list
	    axlFormListDeleteItem(Height_Form "Comp_List_Field" selidx)
	    axlFormListDeleteAll(Height_Form "PLCB_List_Field")
	    axlFormSetField(Height_Form "PLCB_List_Field" nil)
	    else
	    axlUIConfirm("Failed to update HEIGHT value")
	    );

	;; need to refresh ids in order for changes to take affect
	axlDBRefreshId(nil)
	);
       ("Reread_Db"
	;; dehiglight highlighted place bounds
	axlDehighlightObject(hilite_list nil)
	hilite_list = nil
	axlFormTreeViewSet(Height_Form "Tree_Single" 'TV_REMOVEALL nil)
	AK_upd_height()
	Height_Form_Routine()
	axlWindowFit()

	);
       ("Select_All_Single"
	(foreach treeitem sym_tree_list
		 id      = nth(1 treeitem)
		 axlFormTreeViewSetSelectState(Height_Form "Tree_Single" id t)
		 pn_list = nth(2 treeitem)
		 (foreach item pn_list
			  id = nth(1 item)
			  axlFormTreeViewSetSelectState(Height_Form "Tree_Single" id t)
			  );foreach
		 );
	);
       ("DeSelect_All_Single"
	(foreach treeitem sym_tree_list
		 id      = nth(1 treeitem)
		 axlFormTreeViewSetSelectState(Height_Form "Tree_Single" id nil)
		 pn_list = nth(2 treeitem)
		 (foreach item pn_list
			  id = nth(1 item)
			  axlFormTreeViewSetSelectState(Height_Form "Tree_Single" id nil)
			  );foreach
		 );
	);
       (t
	case(Height_Form->treeViewSelState
	     (0
	      label = axlFormTreeViewGetLabel(Height_Form "Tree_Single" Height_Form->curValueInt)
	      (foreach treeitem sym_tree_list
		       sym_name = nth(0 treeitem)
		       pn_list = nth(2 treeitem)
		       (if sym_name == label then
			   (foreach item pn_list
				    id = nth(1 item)
				    axlFormTreeViewSetSelectState(Height_Form "Tree_Single" id nil)
				    );foreach
			   );if
		       (foreach item pn_list
				pn = nth(0 item)
				id = nth(1 item)
				(if pn == label then
				    parents = axlFormTreeViewGetParents(Height_Form "Tree_Single" id)
				    (foreach prt parents
					     AK_tree_all_children_off(prt)
					     );
				    );
				);
		       );foreach
	      );0
	     (1
	      label = axlFormTreeViewGetLabel(Height_Form "Tree_Single" Height_Form->curValueInt)
	      (foreach treeitem sym_tree_list
		       sym_name = nth(0 treeitem)
		       pn_list = nth(2 treeitem)
		       (if sym_name == label then
			   (foreach item pn_list
				    id = nth(1 item)
				    axlFormTreeViewSetSelectState(Height_Form "Tree_Single" id t)
				    );foreach
			   );if
		       (foreach item pn_list
				pn = nth(0 item)
				id = nth(1 item)
				(if pn == label then
				    parents = axlFormTreeViewGetParents(Height_Form "Tree_Single" id)
				    (foreach prt parents
					     axlFormTreeViewSetSelectState(Height_Form "Tree_Single" prt t)
					     );
				    );
				);
		       );foreach
	      );1
	     );case
	);t
       );case
  );
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun AK_tree_all_children_off (parent)

  pl = axlFormTreeViewGetLabel(Height_Form "Tree_Single" parent)
  alloff = t
  (foreach treeitem sym_tree_list
	   sym_name = nth(0 treeitem)
	   (if sym_name == pl then
	       pn_list = nth(2 treeitem)
	       (foreach item pn_list
			pn = nth(0 item)
			id = nth(1 item)
			state = axlFormTreeViewGetSelectState(Height_Form "Tree_Single" id)
			(if state == 1 then
			    alloff = nil
			    );
			);foreach
	       );
	   );foreach
  (if alloff == t then
      axlFormTreeViewSetSelectState(Height_Form "Tree_Single" parent nil)
      );
  );
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun AK_get_tree_items ()
  single_data_list = nil
  (foreach treeitem sym_tree_list
	   name = nth(0 treeitem)
	   id   = nth(1 treeitem)
	   pn_list = nth(2 treeitem)
	   (if axlFormTreeViewGetSelectState(Height_Form "Tree_Single" id) == 1 then
	       ;; root tis selected -> get selected children
	       (foreach item pn_list
			pn = nth(0 item)
			pid = nth(1 item)
			(if axlFormTreeViewGetSelectState(Height_Form "Tree_Single" pid) == 1 then
			    data_set  = list(name pn)
			    single_data_list = cons(data_set single_data_list)
			    );
			);foreach
	       );
	   );foreach
  );
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun Zoom (bbox)

  axlWindowBoxSet(bbox)
  );
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun AK_upd_height_main ()
  vis_list = axlVisibleGet()       ;saves color settings

  hilite_list = nil
  Height_Form = nil
  logWindow = nil
  ;;remove existing logfile
  axlTempFileRemove("./upd_fe_height.log")
  AK_CreateForm()
  AK_upd_height()
  Height_Form_Routine()

  axlDehighlightObject(hilite_list nil)
  axlVisibleSet(vis_list)         ;restores color settings
  deleteFile(form_file)		;deletes form file
  axlWindowFit()
  (if neq(logWindow nil)
    logWindow = axlUIWClose(logWindow)
    ); end if
  (if axlUIYesNo("Do you want to update DRC's ?") then
      axlShell("drc update")
      );
  );
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
axlCmdRegister( "upd_fe_height" `AK_upd_height_main)

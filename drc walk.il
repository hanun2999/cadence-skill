; drc_walk.il - Copyright 1994-96 Loral Federal Systems Owego
;
; drc walk - display DRCs in Allegro design
; layers   - show a group of class/subclass pairs for a given etch layer
;
;
; NO WARRANTY - This software is made available asis; and may not work
;  as advertised in all environment.
;
; This function works with Allegro 10+.
;
; This function will generate a list of DRCs in the current design, and
; allow the user to 'walk through' the list to inspect/verify/etc.
; User can filter the list of DRCs by layer and/or type. Select HELP
; from the drc walk menu for further details.
;
; This file also contains the layers function.
;
; Load the software (by including drc_walk.il in your allegro.ilinit file
;      or by explicity typing (load "drc_walk.il")  at your allegro command
;      line.
;
; This function builds its form & help screen in the /tmp directory
;
;  Created by:    Joe Morrison
;                 joe.morrison@lmco.com
;                 Loral Federal Systems-Owego
;
; This skill program demonstrates the following concepts:
;                 - File I/O
;                 - Asynchronous Forms & Callbacks
;                 - Manipulating design elements by database id
;                 - Create a sublist of items matching search criteria
;                 - viewfile creation
; Updated: April 2001
;          -change the location of the files from /tmp to the current directory ./

(defun _saveSelSet ()
    (list (axlGetSelSet) (axlGetFindFilter nil) (axlGetFindFilter t)))

(defun _restoreSelSet (oldSelSet "l")
    (axlSetFindFilter ?enabled (cons "noall" (nth 1 oldSelSet))
                      ?onButtons (cons "noall" (nth 2 oldSelSet)))
    (axlSingleSelectObject (car oldSelSet))
    t)

(defun _drcZap ()
    (let (lines2 lines newFilter selSet oldSetData)
        (setq oldSetData (_saveSelSet))
        (axlClearSelSet)
        (setq newFilter (list "LINES" "CLINES" ))
        (axlSetFindFilter ?enabled (append  newFilter (list "invisible")) ?onButtons newFilter)
        (axlAddSelectAll)
        (setq lines (axlGetSelSet))
        (setq lines2 (setof l lines
           (equal (lowerCase l->layer) (lowerCase lfsShowLayer))))
        (axlDeleteObject lines2)
        (_restoreSelSet oldSetData)
        _ratSchedID = (list )
        (axlFlushDisplay)
    ) ; let
) ; defun - clear all rats/drc markers

(defun _drcFormBuild ()
  (let (_drcPort)
    (setq _drcFormFile (strcat (makeTempFileName (strcat _drcDir "drcForm")) ".form"))
    (setq _drcPort (outfile _drcFormFile))
   (fprintf _drcPort "FILE_TYPE=FORM_DEFN VERSION=2\n")
   (fprintf _drcPort "FORM\n")
   (fprintf _drcPort "FIXED\n")
   (fprintf _drcPort "PORT 70 16\n")
   (fprintf _drcPort "HEADER \"Allegro DRC Walker\"\n\n")
   (fprintf _drcPort "POPUP <drc_select_layer_p>\"a\"\"a\".\n")
   (fprintf _drcPort "POPUP <drc_select_type_p>\"a\"\"a\".\n\n\n")
   (fprintf _drcPort "TILE\n")
   (fprintf _drcPort "TEXT \"Layer:\"\n")
   (fprintf _drcPort "TLOC 2 2\n")
   (fprintf _drcPort "ENDTEXT\n\n")
   (fprintf _drcPort "TEXT \"Allegro DRC Walker\"\n")
   (fprintf _drcPort "TLOC 23 0\n")
   (fprintf _drcPort "ENDTEXT\n\n")
   (fprintf _drcPort "TEXT \"Matching DRCs\"\n")
   (fprintf _drcPort "TLOC 23 7\n")
   (fprintf _drcPort "ENDTEXT\n\n")
   (fprintf _drcPort "TEXT \"DRC Type:\"\n")
   (fprintf _drcPort "TLOC 2 4\n")
   (fprintf _drcPort "ENDTEXT\n\n")
   (fprintf _drcPort "TEXT \"DRC:\"\n")
   (fprintf _drcPort "TLOC 1 21\n")
   (fprintf _drcPort "ENDTEXT\n\n")
   (fprintf _drcPort "FIELD drc_select_layer\n")
   (fprintf _drcPort "FLOC 13 2\n")
   (fprintf _drcPort "ENUMSET 35\n")
   (fprintf _drcPort "POP \"drc_select_layer_p\"\n")
   (fprintf _drcPort "ENDFIELD\n\n")
   (fprintf _drcPort "FIELD drc_select_type\n")
   (fprintf _drcPort "FLOC 13 4\n")
   (fprintf _drcPort "ENUMSET 35\n")
   (fprintf _drcPort "POP \"drc_select_type_p\"\n")
   (fprintf _drcPort "ENDFIELD\n\n")
   (fprintf _drcPort "FIELD drc_list\n")
   (fprintf _drcPort "FLOC 5 9\n")
   (fprintf _drcPort "LIST \"Matching DRCs\" 50 5\n")
   (fprintf _drcPort "ENDFIELD\n\n")
   (fprintf _drcPort "FIELD drc_this\n")
   (fprintf _drcPort "FLOC 6 21\n")
   (fprintf _drcPort "INFO_ONLY\n")
   (fprintf _drcPort "STRFILLIN 57 57\n")
   (fprintf _drcPort "ENDFIELD\n\n")
   (fprintf _drcPort "FIELD drc_roll\n")
   (fprintf _drcPort "FLOC 1 23\n")
   (fprintf _drcPort "CHECKLIST \"Rollover List\"\n")
   (fprintf _drcPort "ENDFIELD\n\n")
   (fprintf _drcPort "FIELD drc_showobj\n")
   (fprintf _drcPort "FLOC 20 23\n")
   (fprintf _drcPort "CHECKLIST \"DRC Show Element\"\n")
   (fprintf _drcPort "ENDFIELD\n\n")
   (fprintf _drcPort "FIELD drc_zoom\n")
   (fprintf _drcPort "FLOC 1 25\n")
   (fprintf _drcPort "CHECKLIST \"Zoom to DRC\"\n")
   (fprintf _drcPort "ENDFIELD\n\n")
   (fprintf _drcPort "FIELD drc_zoomsize\n")
   (fprintf _drcPort "FLOC 20 25\n")
   (fprintf _drcPort "INTSLIDEBAR 5 25\n")
   (fprintf _drcPort "MIN 50\n")
   (fprintf _drcPort "MAX 2000\n")
   (fprintf _drcPort "ENDFIELD\n\n")
   (fprintf _drcPort "FIELD drc_next\n")
   (fprintf _drcPort "FLOC 1 28\n")
   (fprintf _drcPort "MENUBUTTON \"Next\" 8 3\n")
   (fprintf _drcPort "ENDFIELD\n\n")
   (fprintf _drcPort "FIELD drc_prev\n")
   (fprintf _drcPort "FLOC 10 28\n")
   (fprintf _drcPort "MENUBUTTON \"Previous\" 12 3\n")
   (fprintf _drcPort "ENDFIELD\n\n")
   (fprintf _drcPort "FIELD drc_show\n")
   (fprintf _drcPort "FLOC 23 28\n")
   (fprintf _drcPort "MENUBUTTON \"Show\" 8 3\n")
   (fprintf _drcPort "ENDFIELD\n\n")
   (fprintf _drcPort "FIELD done\n")
   (fprintf _drcPort "FLOC 33 28\n")
   (fprintf _drcPort "MENUBUTTON \"Done\" 8 3\n")
   (fprintf _drcPort "ENDFIELD\n\n")
   (fprintf _drcPort "FIELD lhelp\n")
   (fprintf _drcPort "FLOC 45 28\n")
   (fprintf _drcPort "MENUBUTTON \"Help\" 8 3\n")
   (fprintf _drcPort "ENDFIELD\n\n")
   (fprintf _drcPort "ENDTILE\n\n")
   (fprintf _drcPort "ENDFORM\n")

     close(_drcPort)
     if(! isFile( _drcFormFile) then
        axlUIConfirm( (strcat "Unable to Open Form File, Check Permissions on " _drcDir))
        (_drcEnd)
     );if
  ) ; let
) ; defun - display form information

(defun _drcHelp ()
  (let (helpfile helpPort)
    (setq helpfile (strcat (makeTempFileName (strcat _drcDir "drcHelp")) ".txt"))
    (setq helpPort (outfile helpfile))
       (fprintf helpPort "     LAP Presents........\n\n")
       (fprintf helpPort "drc walk - A tool to inspect the Design Rule Check errors\n")
       (fprintf helpPort "in your Allegro design.\n\n")
       (fprintf helpPort "layers - A tool to turn on typical features for a given subclass of ETCH.\n")
       (fprintf helpPort "----------------------------------------------------------------------\n")
       (fprintf helpPort "The DRC Walker allows you to inspect DRC errors in your current\n")
       (fprintf helpPort "Allegro design, one at a time.  You can filter the DRC errors by\n")
       (fprintf helpPort "layer and/or DRC type.  The DRC to be inspected can either be\n")
       (fprintf helpPort "selected from the list by a mouse pick, or the user can 'walk'\n")
       (fprintf helpPort "through the list of errors using the 'next' and 'previous'\n")
       (fprintf helpPort "buttons.\n\n")
       (fprintf helpPort "Window title: the count of DRCs matching the currently selected\n")
       (fprintf helpPort "layer and type.\n\n")
       (fprintf helpPort "Layer: the list of all layers in the design containing DRC\n")
       (fprintf helpPort "errors.  You can select which layer to display using the middle\n")
       (fprintf helpPort "mouse button.\n\n")
       (fprintf helpPort "DRC Type: the list of all DRC errors currently flagged in this\n")
       (fprintf helpPort "design.  You can select which DRC to display by using the middle\n")
       (fprintf helpPort "mouse button.\n\n")
       (fprintf helpPort "Matching DRCs: the list of all DRCs that match the layer & type\n")
       (fprintf helpPort "selections.  Each line, which corresponds to one drc error, has a\n")
       (fprintf helpPort "sequence number, DRC error, the layer, and the x:y location.  You\n")
       (fprintf helpPort "can pick a particular DRC to examine with the left mouse button.\n")
       (fprintf helpPort "The currently displayed DRC is highlighted in the list.\n\n")
       (fprintf helpPort "DRC: an information only field that shows information about the\n")
       (fprintf helpPort "currently displayed DRC.\n\n")
       (fprintf helpPort "Rollover List: Normally, the 'next' button has no effect when you\n")
       (fprintf helpPort "select 'next' at the end of the list.  Similarly, 'previous' has\n")
       (fprintf helpPort "no effect when you select 'previous' at the top of the list.\n")
       (fprintf helpPort "Selecting the rollover checkbox causes 'next' at the last item to\n")
       (fprintf helpPort "show the first item in the list; and 'previous' at the first item\n")
       (fprintf helpPort "to show the last item.\n\n")
       (fprintf helpPort "DRC Show Element: If this box is selected, a 'show element'\n")
       (fprintf helpPort "window will appear to provide you with more information about the\n")
       (fprintf helpPort "current DRC.\n\n")
       (fprintf helpPort "Zoom to DRC: Normally, the full design is shown in the design\n")
       (fprintf helpPort "window. If 'Zoom to DRC' is selected, the design window will zoom\n")
       (fprintf helpPort "about the DRC. The size of the drc window is controlled by the\n")
       (fprintf helpPort "zoom factor field, which has a slider button to select the size.\n\n")
       (fprintf helpPort "Next: Pressing this button will cause the immediately following\n")
       (fprintf helpPort "DRC in the list to be displayed.\n\n")
       (fprintf helpPort "Previous: Pressing this button will cause the immediately prior\n")
       (fprintf helpPort "DRC in the list to be displayed.\n\n")
       (fprintf helpPort "Show: Redisplay the current DRC. This button is useful when you\n")
       (fprintf helpPort "change zooming or the show element controls.\n\n")
       (fprintf helpPort "Done: Exit from the DRC Walker\n\n")
       (fprintf helpPort "Help: Display this file.\n")
       (fprintf helpPort "---------------------------------------------------------------------\n\n")
       (fprintf helpPort "Layers:\n")
       (fprintf helpPort " invoke by typing:      layers [+,-] layername(s)\n")
       (fprintf helpPort " at the Allegro command line\n\n")
       (fprintf helpPort " Layername corresponds to one or more ETCH subclasses defined for\n")
       (fprintf helpPort "the current design.\n\n")
       (fprintf helpPort " A '+' causes the layer to be added to the current display\n")
       (fprintf helpPort "visibility, a '-' causes that layer to be removed. Normally, the\n")
       (fprintf helpPort "layers command causes all other currently displayed features to\n")
       (fprintf helpPort "be made invisible.\n\n")
       (fprintf helpPort " Classes involved:\n")
       (fprintf helpPort "        BOARD GEOMETRY/OUTLINE\n")
       (fprintf helpPort "        DRC ERROR CLASS/<layer>\n")
       (fprintf helpPort "        ETCH/<layer>\n")
       (fprintf helpPort "        PIN/<layer>\n")
       (fprintf helpPort "        VIA CLASS/<layer>\n")
       (fprintf helpPort "        VIA KEEPOUT/<layer>\n")
       (fprintf helpPort "        ROUTE KEEPOUT/<layer>\n")
       (fprintf helpPort "        PIN/FILMMASKTOP  - if <layer> = TOP\n")
       (fprintf helpPort "        PACKAGE GEOMETRY/ASSEMBLY_TOP  - if <layer> = TOP\n")
       (fprintf helpPort "        PIN/FILMMASKBOTTOM  - if <layer> = BOTTOM\n")
       (fprintf helpPort "        PACKAGE GEOMETRY/ASSEMBLY_BOTTOM  - if <layer> = BOTTOM\n\n")
       (fprintf helpPort "---------------------------------------------------------------------\n\n")
       (fprintf helpPort " Questions, Comments, Suggestions?\n\n")
       (fprintf helpPort " Contact\n Joe Morrison \t\t\tLoral Federal Systems-Owego\n")
       (fprintf helpPort " joe.morrison@lmco.com\t607+751-4938\n")

     close(helpPort)
     if(! isFile( helpfile) then
        axlUIConfirm( (strcat "Unable to Open Help File, Check Permissions on " _drcDir))
        (_drcEnd)
      else
        axlUIViewFileCreate( helpfile "LAP DRC Walker - Help" nil)
        (if (isFile helpfile) then (deleteFile helpfile))
     );if
  ) ; let
) ; defun - display help information

(procedure lfsSingleLayer( _layer @optional (vis t))
  (cond
    ((index (lowerCase _layer) "top")  (setq layer "TOP"))
    ((index (lowerCase _layer) "bot")  (setq layer "BOTTOM"))
    (t                                 (setq layer _layer))
  ) ; end conditional layer processing
  (foreach lyr (axlGetParam "paramLayerGroup:ETCH" )->groupMembers
      (if (eq (lowerCase lyr) (lowerCase layer)) ; found a legal layer
         then
            (axlVisibleLayer (strcat "BOARD GEOMETRY" "/" "OUTLINE") t)
            (axlVisibleLayer (strcat "DRC ERROR CLASS" "/" _layer) vis)
            (axlVisibleLayer (strcat "ETCH" "/" layer) vis)
            (axlVisibleLayer (strcat "PIN" "/" layer) vis)
            (axlVisibleLayer (strcat "VIA CLASS" "/" layer) vis)
            (axlVisibleLayer (strcat "VIA KEEPOUT" "/" layer) vis)
            (axlVisibleLayer (strcat "ROUTE KEEPOUT" "/" layer) vis)
            (if (index (lowerCase layer) "top")
              then
                (axlVisibleLayer (strcat "PIN" "/" "FILMMASKTOP") vis)
                (axlVisibleLayer (strcat "PACKAGE GEOMETRY" "/" "ASSEMBLY_TOP") vis)
            ) ; if a top layer
            (if (index (lowerCase layer) "bot")
              then
                (axlVisibleLayer (strcat "PIN" "/" "FILMMASKBOTTOM") vis)
                (axlVisibleLayer (strcat "PACKAGE GEOMETRY" "/" "ASSEMBLY_BOTTOM") vis)
            ) ; if a top layer
      ) ; if found a legal layer
  ) ; foreach layer in board
  t
) ; procedure - turn one layer on or off

(procedure lfsLayers( layer @rest args)
;   (println  layer )
;   (println args)
   (setq _deferRedraw nil)
   (if (or  (or (equal layer "+") (equal layer "-")) (equal layer "*"))
      then
        (if (equal layer "*")
          then
           (setq _deferRedraw t)
          else
           (setq _deferRedraw nil)
;        (println "is  + or -")
        ) ; is a splat
      else
;        (println "not + or -")
        (axlVisibleDesign nil)
        (lfsSingleLayer layer t)
   ) ; turn off what's currently displayed

   (if (eq layer "-")
     then (setq visibility nil)
     else (setq visibility t)
   ) ; set visibility

   (foreach lyr args
;      (println lyr)
     (case lyr
        ("+"   (setq visibility t))
        ("-"   (setq visibility nil))
        (t     (lfsSingleLayer lyr visibility))
     ) ; case for argument stream
   ) ; foreach argument passed
   (if !_deferRedraw
     then
         (axlShell "redraw")
   ) ; if redraw not deferred
t
) ; procedure - turn on/off a set of layers


 ;;
 ;; lfsWindowExpand
 ;;
 ;; factor the size of a window
 ;;
 ;; basic function for all points is (F + 1)/2 * (point) - (F-1)/2 *opposite point
 ;; where F is the integer scaling factor
 ;;
 (procedure lfsWindowExpand( _window @optional (F 3))
     (let ((x1 (caar _window)) ; first item in first list
           (y1 (cadar _window)); second item in first list
           (x2 (caadr _window)) ; first item in second list
           (y2 (cadadr _window)); second item in second list
           f1 f2 f3 f4)
         (setq f1 (quotient (difference (times (plus F 1) x1)
                                        (times (difference F 1) x2)) 2))
         (setq f2 (quotient (difference (times (plus F 1) y1)
                                        (times (difference F 1) y2)) 2))
         (setq f3 (quotient (difference (times (plus F 1) x2)
                                        (times (difference F 1) x1)) 2))
         (setq f4 (quotient (difference (times (plus F 1) y2)
                                        (times (difference F 1) y1)) 2))
         (setq _window (list (list f1 f2) (list f3 f4)))
         (axlWindowBoxSet _window)
     ) ; let
     t
 ) ; lfsWindowExpand

(procedure lfsDRCFilterList(lfsLayerFilt lfsDRCFilt)
; => lfsFilteredDRCs
(let (lyrPart typPart lfsLayerClause lfsDRCClause tmpStr ctr drc_entry)
   (if (equal lfsLayerFilt "ALL")
    then
      (setq lfsLayerClause t)
      (setq lyrPart "")
    else
      (setq lfsLayerClause '(equal (cadr (parseString d1->layer "/")) lfsLayerFilt))
      (setq lyrPart (strcat " on " lfsLayerFilt))
   ) ; end if

   (if (equal lfsDRCFilt "ALL")
    then
      (setq lfsDRCClause t)
      (setq typPart "")
    else
      (setq lfsDRCClause '(equal d1->name lfsDRCFilt))
      (setq typPart (strcat " " lfsDRCFilt))
   ) ; end if

   (setq lfsDRCWorkingList (setof d1 drcs (and (eval lfsDRCClause) (eval lfsLayerClause))))
   (setq lfsDisplayList (list))
   (setq ctr 1)
   (foreach drc lfsDRCWorkingList
     (sprintf tmpStr "%d %s on %s %g:%g" ctr drc->name
        (cadr (parseString drc->layer "/"))
        (car drc->xy) (cadr drc->xy))
     (setq lfsDisplayList (cons tmpStr lfsDisplayList))
     (setq ctr (add1 ctr))
   ) ; foreach - build display list
   (setq lfsDisplayList (reverse lfsDisplayList))
   (setq lfsNumberDRCs (length lfsDRCWorkingList))
   (sprintf lfsDRCTitle "%d%s DRCs%s" lfsNumberDRCs typPart lyrPart)
   (axlFormTitle _drcForm lfsDRCTitle)
   (axlFormListDeleteAll _drcForm "drc_list")
   (foreach drc_entry lfsDisplayList (axlFormSetField _drcForm "drc_list" drc_entry))
   (axlFormSetField _drcForm "drc_list" nil)
   (setq _drcCurrentDRC (car lfsDisplayList))
   (setq _drcCurrentNum 1)
   (axlFormSetField _drcForm "drc_this" _drcCurrentDRC)
) ; let
   t
) ; lfsDRCFilterList

(defun lfsDRCInitialize ()
  null
) ; end initialize

(defun lfsMarkPoint (loc)
; returns a list of dbids used to mark this location
; mark point using a diamond with extended points
  (let  ((x (car loc))
         (y (cadr loc))
         (n (axlMKSConvert 1 "MILS"))
         (c (axlMKSConvert 75 "MILS"))
         (f (axlMKSConvert 500 "MILS"))
         (wid (axlMKSConvert 5 "MILS"))
         (dbid_list (list))
         pts)
   (if (nequal loc nil)
     then
       (setq pts (list x+c:y+1 x+1:y+c x:y+f x-1:y+c x-c:y+1 x-f:y
                    x-c:y-1 x-1:y-c x:y-f x+1:y-c x+c:y-1 x+f:y x+c:y+1))
       (setq db1 (axlDBCreateLine pts wid lfsShowLayer))
       (setq dbid_list (list (caar db1)))
       dbid_list
     else
       nil
   ) ; if valid location
  ) ; end let for local variables
) ; defun mark a location for user attention


(defun _drcEnd ()
  (axlFormClose _drcForm)
  (axlDehighlightObject _drcHilites)
  (axlDeleteObject _drcMarker)
  (setq _drcHilites nil)
  (setq _drcMarker nil)
  (if (isFile _drcFormFile) then (deleteFile _drcFormFile))
) ; end drc display

(defun _drcShow (dbid)
  (if (neq dbid nil)
    then
     (setq _drcMarker (lfsMarkPoint dbid->xy))
     (if _drcZoom
         then (lfsWindowExpand dbid->bBox _drcZoomSize/100.0)
         else
           (if _drcZoomDo
             then
                (axlWindowFit)
                (setq _drcZoomDo nil)
           ) ; if window fit is forced
     ) ; if - handle window zoom/fit
     (if (nequal _drcLastLayer dbid->layer)
       then
         (lfsLayers  (cadr (parseString dbid->layer "/")))
         (axlVisibleLayer lfsShowLayer t)
         (axlShell "redraw")
     ) ; if - update colors when necessary
     (setq _drcLastLayer dbid->layer)
     (setq _drcHilites (list dbid))
     (foreach _viol dbid->violations
       (if (axlIsDBIDType _viol)
         then (setq _drcHilites (cons _viol _drcHilites))
       ) ; if _viol
     )
     (axlHighlightObject _drcHilites)
     (if _drcShowObj
        then (axlShowObject _drcHilites)
     ) ; if show object is selected
  ) ; valid dbid to work with
) ; defun - highlight this drc

(defun _drcUpdateDisp ()
  (let (_tmpDB)
    (foreach _tmpDB _drcHilites
      (if (nequal nil  _tmpDB->?)
         then  (axlDehighlightObject _tmpDB)
      ) ; if still valid
    ) ; foreach hilight
;    (axlDehighlightObject _drcHilites)
    (foreach _tmpDB _drcMarker
      (if (nequal nil  _tmpDB->?)
         then  (axlDeleteObject _tmpDB)
      ) ; if still valid
    ) ; foreach marker
;   (axlDeleteObject _drcMarker)
    (setq _drcHilites nil)
    (setq _drcMarker nil)
    (if (lfsNumberDRCs > 0)
      then
      (cond
        ((and ( _drcCurrentNum < 1) _drcRollList) (setq _drcCurrentNum lfsNumberDRCs))
        ((and ( _drcCurrentNum < 1) !_drcRollList) (setq _drcCurrentNum 1))
        ((and ( _drcCurrentNum > lfsNumberDRCs) !_drcRollList) (setq _drcCurrentNum lfsNumberDRCs))
        ((and ( _drcCurrentNum > lfsNumberDRCs) _drcRollList) (setq _drcCurrentNum 1))
      ) ; end conditional cases
       (setq _drcCurrentDRC (nthelem _drcCurrentNum lfsDisplayList))
       (axlFormSetField _drcForm "drc_this" _drcCurrentDRC)
      (axlFormListSelect _drcForm "drc_list" _drcCurrentDRC)
       (setq _drcDBID (nthelem _drcCurrentNum lfsDRCWorkingList))
       (if (nequal nil  _drcDBID->?)
         then (_drcShow _drcDBID)
         else
           drcs=(axlDBGetDesign)->drcs
          (lfsDRCFilterList _drcCurrentLayer _drcCurrentType)
          (setq _drcLastLayer nil)
       ) ; do show if valid drcdbid
    ) ; if there are DRCs in the list
  ) ; let
) ; end update display

(defun _drcUpdateAll ()
  ; Build the DRC List
  (lfsDRCFilterList _drcCurrentLayer _drcCurrentType)
  (setq _drcLastLayer nil)
  (_drcUpdateDisp)
) ; end update display list & current drc

 ;;
 ;; _drcCallBack
 ;;
 ;; callback for delete unconnected shapes confirmation form
 ;;
 (defun _drcCallBack (form)

     ; determine which button has been pushed and act accordingly
     (cond
         ((equal (get form 'curField) "drc_select_layer")
             (setq _drcCurrentLayer (get form 'curValue))
             (_drcUpdateAll)
         )
         ((equal (get form 'curField) "drc_select_type")
             (setq _drcCurrentType (get form 'curValue))
             (_drcUpdateAll)
         )
         ((equal (get form 'curField) "drc_list")
             (setq _drcCurrentNum (add1 (get form 'curValueInt)))
             (_drcUpdateDisp)
          )
         ((equal (get form 'curField) "drc_next")
             (setq _drcCurrentNum (add1 _drcCurrentNum))
             (_drcUpdateDisp)
          )
         ((equal (get form 'curField) "drc_prev")
             (setq _drcCurrentNum (sub1 _drcCurrentNum))
             (_drcUpdateDisp)
          )
         ((equal (get form 'curField) "drc_roll")
             (setq _drcRollList (get form 'curValue))
          )
         ((equal (get form 'curField) "drc_showobj")
             (setq _drcShowObj (get form 'curValue))
          )
         ((equal (get form 'curField) "drc_zoom")
             (setq _drcZoom (get form 'curValue))
             (setq _drcZoomDo t)
             (_drcUpdateDisp)
          )
         ((equal (get form 'curField) "drc_zoomsize")
             (setq _drcZoomSize (get form 'curValue))
             (if _drcZoom
               then (_drcUpdateDisp)
             ) ; if zooming enabled
          )
         ((equal (get form 'curField) "drc_show")
             (_drcUpdateDisp)
          )
         ((equal (get form 'curField) "done") (_drcEnd))
         ((equal (get form 'curField) "lhelp") (_drcHelp))
     ) ; cond

     ; now, refresh the display so all this stuff REALLY happens
     (axlFlushDisplay)

 ) ; _drcCallBack


(defun drc_main ()
  (setq lfsShowLayer "Board Geometry/lfs_utilities")
  (if (axlIsLayer lfsShowLayer) then (_drcZap) )
  (axlLayerCreateNonConductor lfsShowLayer)

  drcs=(axlDBGetDesign)->drcs
  (setq _drcRollList nil)

; open the form
  (setq _drcDir "./")
  (_drcFormBuild)
  (axlFormCreate '_drcForm _drcFormFile '("east" "outer") '_drcCallBack t)
  _lyrList=(cons "ALL" (axlGetParam "paramLayerGroup:ETCH")->groupMembers)
; build the available layers popup

  drcTypes=(list "ALL")
  (foreach tmpDRC drcs
    (if (!(member tmpDRC->name drcTypes))
       then drcTypes=(cons  tmpDRC->name drcTypes)
     ) ; if not on lost
     (setq _chkLayer (cadr (parseString tmpDRC->layer "/")))
    (if (!(member _chkLayer _lyrList))
      then
       (setq _lyrList (append1 _lyrList _chkLayer))
    ) ; if layer not found
  ) ; build list of drctypes & layers

  drcTypes=(reverse drcTypes)

  (axlFormBuildPopup _drcForm "drc_select_layer" _lyrList)
  (axlFormBuildPopup _drcForm "drc_select_type" drcTypes)

  ; set the default layer name into the form
  (setq _drcCurrentLayer "ALL")
  (setq _drcCurrentType  "ALL")
  (setq _drcRollList nil)
  (setq _drcZoom     nil)
  (setq _drcZoomDo   t)
  (setq _drcHilites nil)
  (setq _drcMarker nil)
  (setq _drcLastLayer nil)
  (setq _drcShowObj nil)
  (setq _drcZoomSize 300)

  (axlFormSetField _drcForm "drc_select_layer" _drcCurrentLayer)
  (axlFormSetField _drcForm "drc_select_type"  _drcCurrentType)
  (axlFormSetField _drcForm "drc_roll" _drcRollList)
  (axlFormSetField _drcForm "drc_zoom" _drcZoom)
  (axlFormSetField _drcForm "drc_showobj" _drcShowObj)
  (axlFormSetField _drcForm "drc_zoomsize" _drcZoomSize)

  ; Build the DRC List
  (lfsDRCFilterList _drcCurrentLayer _drcCurrentType)

  ; and display the form
  (axlFormDisplay _drcForm)
  (_drcUpdateDisp)

) ; end drc_main

(axlCmdRegister "drc walk" 'drc_main)
(axlCmdRegister "layers" 'lfsLayers)
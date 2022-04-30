/*
################################################################################
#                                                                              #
#                      Command: film_reorder                                   #
#                   Skill File: film_reorder.il                                #
#                  How To Load: Command> skill load("film_reorder.il")         #
#               How To Execute: Command> film_reorder                          #
#               Sourcelink Solution Reference : 11297786                       #
#                                                                              #
#                       Author: Jatin Sasan , Cadence Design Systems           #
#                        Email: jsasan@cadence.com                             #
#                Creation Date: 09/12/2006                                     #
#                                                                              #
################################################################################

################################################################################
#                                                                              #
#  DISCLAIMER:                                                                 #
# THIS CODE IS UNSUPPORTED AND HAS HAD MINIMAL TESTING.                        #
# The following code is provided for Cadence customers                         #
# to use at their own risk. The code may require modification to               #
# satisfy the requirements of any user. The code and any                       #
# modifications to the code may not be compatible with current or              #
# future versions of Cadence products.                                         #
# THE CODE IS PROVIDED "AS IS" AND WITH NO WARRANTIES, INCLUDING               #
# WITHOUT LIMITATION ANY EXPRESS WARRANTIES OR IMPLIED WARRANTIES              #
# OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.                          #
#                                                                              #
################################################################################

################################################################################
#                                                                              #
#  09/12/2006:  Pops a UI where you can load films and reorder them through    #
#               Up and Down buttons
#  Revision history:                                                           #
#	1.0 Original file		                           Sept 12,2006          #
#     1.1 Fixed Mirror and Shape fill bug. Options were
#         getting set incorrectly in reverse order       Dec 17, 2006          #
#                                                                              #
#  Advantages:                                                                 #
# a) Easy to Reorder films.
# b) Preserves the artwork film layer settings                                 #
#                                                                              #
#                                                                              #
#  Limitations:                                                                #
# a) Artwork film layer settings for undefined line width, Shape Bounding      #
#    box and XY offset are not preserved. They are reset to default on         #
#    reordering.                                                               #
################################################################################
*/

axlCmdRegister("film_reorder" 'film_reorder)

declare(film_array[50])
declare(film_order[50])
(setq brd_films nil)
unless(axlGetVariable("film_nosort")  ;Allegro by default sorts the film records in Artwork control form
  axlSetVariable("film_nosort" t)       ;Setting this env variable turns off the default sorting.
       ) ; end unless

procedure( film_reorder()
  _makeForm_artwork_reorder()
   axlFormDisplay(_Form_artwork)
); end procedure


;###########################################################
;#                                                         #
;#                FORM CREATION                            #
;#                                                         #
;###########################################################

(defun _makeForm_artwork_reorder ()
   _Form_artwork=outfile("./form_artwork.form" "w")
   fprintf(_Form_artwork "FILE_TYPE=FORM_DEFN VERSION=2\n")
   fprintf(_Form_artwork "FORM\n")
   fprintf(_Form_artwork "FIXED\n")
   fprintf(_Form_artwork "PORT 55 18\n")
   fprintf(_Form_artwork "HEADER \"Artwork Film Re-ordering\" \n")

   fprintf(_Form_artwork "TILE\n")

   fprintf(_Form_artwork "TEXT \"Existing Films in Brd:\"\n")
   fprintf(_Form_artwork "TLOC 4 2\n")
   fprintf(_Form_artwork "ENDTEXT\n")

   fprintf(_Form_artwork "FIELD FILMS_LIST\n")
   fprintf(_Form_artwork "FLOC  20 2\n")
   fprintf(_Form_artwork "LIST \"\" 20 7\n")
   fprintf(_Form_artwork "OPTIONS multiselect\n")
   fprintf(_Form_artwork "ENDFIELD\n")

   fprintf(_Form_artwork "FIELD LOAD\n")
   fprintf(_Form_artwork "FLOC 4 6\n")
   fprintf(_Form_artwork "MENUBUTTON \"Load Films\" 12 3\n")
   fprintf(_Form_artwork "ENDFIELD\n")

   fprintf(_Form_artwork "FIELD UP\n")
   fprintf(_Form_artwork "FLOC 45 2 \n")
   fprintf(_Form_artwork "MENUBUTTON \"Up\" 6 3\n")
   fprintf(_Form_artwork "ENDFIELD\n")

   fprintf(_Form_artwork "FIELD DOWN\n")
   fprintf(_Form_artwork "FLOC 45 6\n")
   fprintf(_Form_artwork "MENUBUTTON \"Down\" 6 3\n")
   fprintf(_Form_artwork "ENDFIELD\n")

   fprintf(_Form_artwork "FIELD DONE\n")
   fprintf(_Form_artwork "FLOC 10 16 \n")
   fprintf(_Form_artwork "MENUBUTTON \"Re-order\" 12 3\n")
   fprintf(_Form_artwork "ENDFIELD\n")

   fprintf(_Form_artwork "FIELD CANCEL\n")
   fprintf(_Form_artwork "FLOC 35 16\n")
   fprintf(_Form_artwork "MENUBUTTON \"Close\" 12 3\n")
   fprintf(_Form_artwork "ENDFIELD\n")

   fprintf(_Form_artwork "ENDTILE\n")
   fprintf(_Form_artwork "ENDFORM\n")
   close(_Form_artwork)
   _Form_artwork = axlFormCreate( (gensym) "form_artwork.form" '(e inner) 'artwork_callback t)

); end defun _makeForm_artwork_reorder


procedure(artwork_callback(myform)
    let( (prev_list final_list )
        case( myform->curField
                ("FILMS_LIST"
                   /* Nothing to do */
                 )
                ("LOAD"
                       axlFormListDeleteItem(myform, "FILMS_LIST" brd_films)
                       (setq brd_films nil)
                       film_count = get_film_list()
                       for(key 0 film_count-1
                           brd_films = append(brd_films list(film_array[key]->film_name))
                           )
                       axlFormListAddItem(myform, "FILMS_LIST" brd_films 0)
                       val = brd_films
                 )
                ("UP"
                         for(key 0 film_count-1
                            film_order[key] = nth(key val)
                            ); end for unless
                         (setq count -1) (setq j -1)
                         (prev_list = final_list = next_list = nil)
                         (setq sel_index 0 )
                         sel_items =  axlFormListGetSelItems(myform "FILMS_LIST")
                         unless(length(sel_items) != 1
                            foreach(items val
                                j++
                                unless(items != car(sel_items)
                                     sel_index = j
                                      ) ; end unless
                                   ) ; end foreach
                            (setq haha film_order[sel_index])
                            if(sel_index != 0 then
                               current_prev = film_order[sel_index-1]
                             else (setq current_prev nil) final_list = val); end if
                             unless(current_prev == nil
                                 for(key 0 sel_index-2
                                    prev_list = append(prev_list list(film_order[key]))
                                     ); end for
                                 for(key sel_index+1 length(brd_films)-1
                                    next_list = append(next_list list(film_order[key]))
                                    ) ; end for
                                    unless(sel_index-2 == -1
                                    final_list = append(prev_list final_list)
                                           ) ; end unless
                                    final_list = append(final_list list(haha))
                                    final_list = append(final_list list(current_prev))
                                    unless((sel_index+1 > length(brd_films)-1)
                                     final_list = append(final_list next_list)
                                           ) ; end unless
                                  ) ; end unless
                           ) ; end if
                       axlFormListDeleteItem(myform, "FILMS_LIST" val)
                       if(final_list == nil then (setq final_list val))
                       axlFormListAddItem(myform, "FILMS_LIST" final_list 0)
                       (setq val final_list)
                 )
                ("DOWN"
                         for(key 0 film_count-1
                            film_order[key] = nth(key val)
                            ); end for unless
                         (setq countd -1) (setq jd -1) (prev_listd = final_listd = next_listd = nil)
                         (setq sel_indexd 0)
                         sel_itemsd =  axlFormListGetSelItems(myform "FILMS_LIST")
                         unless(length(sel_itemsd) != 1
                            foreach(items val
                                jd++
                                unless(items != car(sel_itemsd)
                                     (setq sel_indexd jd)
                                      ) ; end unless
                                   ) ; end foreach
                             hahad   = film_order[sel_indexd]
                            if((sel_indexd != length(brd_films)-1) then
                               current_prevd = film_order[sel_indexd+1]
                             else (setq current_prevd nil) final_listd = val); end if
                             unless(current_prevd == nil
                                 for(key 0 sel_indexd-1
                                    prev_listd = append(prev_listd list(film_order[key]))
                                     ); end for
                                 for(key sel_indexd+2 length(brd_films)-1
                                    next_listd = append(next_listd list(film_order[key]))
                                    ) ; end for
                                    unless(sel_indexd == 0
                                    final_listd = append(prev_listd final_listd)
                                           ) ; end unless
                                    final_listd = append(final_listd list(current_prevd))
                                    final_listd = append(final_listd list(hahad))
                                    unless((sel_indexd+2 > length(brd_films)-1)
                                     final_listd = append(final_listd next_listd)
                                           ) ; end unless
                                  ) ; end unless
                           ) ; end if
                       axlFormListDeleteItem(myform, "FILMS_LIST" val)
                       if(final_listd == nil then final_listd = val)
                       axlFormListAddItem(myform, "FILMS_LIST" final_listd 0)
                       (setq val final_listd)
                 )
                ("DONE"
                       (setq count 0) (setq reverse_film nil)
                       design_value = cadr(axlDBGetDesignUnits())
                       case(design_value
                           (0 bBox = 254)(1 bBox = 254)(2 bBox = 254) (3 bBox = 2540)(4 bBox = 25400)
                           ) ; end case
                       dbid_film = axlGetParam("artwork")
                       foreach(filmgp dbid_film->groupMembers
                          test_film = strcat("artwork:" filmgp)
                          _film = axlGetParam(test_film)
                           unless(filmgp == nth(0 val)
                            axlDeleteObject(_film)
                                  ) ; end unless
                              ) ; end foreach
                         add_film = remove(nth(0 val) val)

                         foreach(films add_film
                            reverse_film = append(reverse_film list(films))
                                 ) ; end foreach
                         foreach(new_film reverse_film
                             for(jt 0 length(brd_films)-1
                               unless(new_film != film_array[jt]->film_name
                                    axlfcreate(new_film list(film_array[jt]->rotation
                                                             00 00 00 bBox
                                                             film_array[jt]->negative
                                                             film_array[jt]->mirror
                                                             film_array[jt]->fullcontact
                                                             film_array[jt]->unconnect_pads
                                                             film_array[jt]->pad_aperture
                                                             film_array[jt]->aperture_rotation
                                                             film_array[jt]->shapefill
                                                             film_array[jt]->vector) car(film_array[jt]->film_layers))
                                     ); end unless
                                 ) ; end for
                               ); end foreach
                    sprintf(msg_test,"Films reordered successfully. Open Artwork control form to verify the reordering\n")
                    axlUIConfirm(msg_test)
                 )
                 ("CANCEL"
                    axlFormClose(myform)
                    axlCancelEnterFun()
                    axlTempFileRemove("form_artwork.form")
                 )
             ) ; end case
     ); end let
); end procedure

;###########################################################
;#                                                         #
;#                Main Program get_film_list               #
;#                                                         #
;###########################################################


(defun get_film_list ()
       prog( (dbid_film test_film _film _active_films tfilm)
      defstruct(filmrecord film_name film_layers pad_aperture fullcontact mirror negative rotation
                           shapefill unconnect_pads aperture_rotation vector)
      (setq i 0)
      dbid_film = axlGetParam("artwork")
       foreach(filmgp dbid_film->groupMembers
               test_film = strcat("artwork:" filmgp)
               _film = axlGetParam(test_film)
              film_array[i] = make_filmrecord(
                                              ?film_name           _film->name
                                              ?film_layers         list(_film->groupMembers)
                                              ?pad_aperture        _film->drawMissingPadApertures
                                              ?fullcontact         _film->fullContact
                                              ?mirror              _film->mirrored
                                              ?negative            _film->negative
                                              ?rotation            _film->rotation
                                              ?shapefill           _film->suppressShapeFill
                                              ?unconnect_pads      _film->suppressUnconnectPads
                                              ?aperture_rotation   _film->useApertureRotation
                                              ?vector              _film->vectorBasedPad
                                             )
            ; Modify the structures to have 0 or 1 so as to pass argument during film creation.
            if(film_array[i]->pad_aperture == t then film_array[i]->pad_aperture=1 else film_array[i]->pad_aperture=0)
            if(film_array[i]->fullcontact == t then film_array[i]->fullcontact=1 else film_array[i]->fullcontact=0)
            if(film_array[i]->mirror == t then film_array[i]->mirror=1 else film_array[i]->mirror=0)
            if(film_array[i]->negative == t then film_array[i]->negative=0 else film_array[i]->negative=1)
            if(film_array[i]->shapefill == t then film_array[i]->shapefill=0 else film_array[i]->shapefill=1)
            if(film_array[i]->vector == t then film_array[i]->vector=1 else film_array[i]->vector=0)
            if(film_array[i]->unconnect_pads == t then film_array[i]->unconnect_pads=1
            else film_array[i]->unconnect_pads=0)
            if(film_array[i]->aperture_rotation == t then film_array[i]->aperture_rotation=1
            else film_array[i]->aperture_rotation=0)
            case(film_array[i]->rotation
                 (0   film_array[i]->rotation=0)
                 (90  film_array[i]->rotation=2)
                 (180 film_array[i]->rotation=4)
                 (270 film_array[i]->rotation=6)
                ) ; end case
                i++
                   ) ; end foreach
         return(i)
              ) ; end prog
   );end defun
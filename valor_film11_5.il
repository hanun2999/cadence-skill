/*************************************************************
*
*  File:  valor_film11_5.il	Copyright 1997 (c)
*
*  Date:  April 8, 1997		Property of Valor
*				developed by OHIO Design
*					     Automation, Inc.
*
*  IMPORTANT: FOR USE WITH RELEASE 11.5 and later
*
**************************************************************
*
*  Purpose:  To parse a Cadence Allegro design and produce
*	     a file called "films_<brd_name>.scr " that generates
*	     Allegro film mask information.
*
*/

axlCmdRegister("valor film info" 'valor_film_info)

defun( valor_film_info ( )
 let( ( fptr scr_ptr line words count
	view original_view brd_name )

  brd_name = axlCurrentDesign()
  sprintf(tot_name "films_%s.scr" brd_name)
  sprintf(msg "Valor: Writing %s" tot_name)
  axlMsgPut(msg)
  
  if( fptr = outfile("./valor_tmp.scr") then

    fprintf(fptr "version 11.0\n")
    fprintf(fptr "setwindow pcb\n")
    fprintf(fptr "scriptmode +invisible\n")
    fprintf(fptr "film param\n")
    fprintf(fptr "printform form.film_control script valor_fc.scr\n")
    fprintf(fptr "setwindow form.film_control\n")
    fprintf(fptr "FORM film_control done\n")
    close(fptr)

    axlShell("replay ./valor_tmp.scr")
    deleteFile("./valor_tmp.scr")
    original_view = axlVisibleGet()
    count = 1

    if( scr_ptr = infile("./valor_fc.scr") then
     if( tot_ptr = outfile(tot_name) then
      while( gets(line scr_ptr)
	words = parseString(line " ")
	if( nthelem(2 words) == "film_control" &&
	    nthelem(4 words) == "name" then

	  if( fptr = outfile("./valor_tmp.scr") then
	    fprintf(fptr "version 11.0\n")
	    fprintf(fptr "setwindow pcb\n")
	    fprintf(fptr "scriptmode +invisible\n")
	    fprintf(fptr "film param\n")
	    fprintf(fptr "setwindow form.film_control\n")
	    fprintf(fptr "FORM film_control %s edit Display\n"
			  nthelem(3 words))
	    fprintf(fptr "FORM film_control %s edit Edit\n"
			  nthelem(3 words))
	    fprintf(fptr "setwindow form.film_edit\n")
	    fprintf(fptr "printform form.film_edit script valor_film.scr\n")
	    fprintf(fptr "setwindow form.film_edit\n")
	    fprintf(fptr "FORM film_edit done\n")    
	    fprintf(fptr "setwindow form.film_control\n")
	    fprintf(fptr "FORM film_control done\n")    
	    close(fptr) 
 
	    axlShell("replay ./valor_tmp.scr")
	    deleteFile("./valor_tmp.scr")

	    view = axlVisibleGet()
	    if( count == 1 then
	      fprintf(tot_ptr "# Allegro script\n")
	    else
	      fprintf(tot_ptr "...\n")
	    )
	    tot_ptr = _valor_write_info( nthelem(3 words) view tot_ptr )
	    count = count + 1

	    deleteFile("./valor_film.scr")
	  )
	)
       )
      )
      close(tot_ptr)
      close(scr_ptr)
      deleteFile("./valor_fc.scr")
      axlVisibleSet(original_view)
      axlShell("redisplay")
    else
      error("Cannot access valor_fc.scr, check read permissions.")
    )
  else
    error("Cannot open file, check write permissions.")
  )
  axlMsgPut(" ----- Valor films completed successfully ----- \n")
 )
)


(defun _valor_write_info ( film_name view tot_ptr )
 (let ( fptr line words class_info class_name sclass_info )
 
  fprintf(tot_ptr "FORM film_control %s edit Edit\n" film_name)

  foreach( class_info view
    if( nthelem(5 class_info) != nil then
      class_name = nthelem(3 class_info)
      foreach( sclass_info nthelem(7 class_info)
	if( cadr(sclass_info) then
	  fprintf(tot_ptr "FORM film_edit list %20s %s\n"
		  class_name car(sclass_info))
	)
      )
    )
  )

  if( fptr = infile("./valor_film.scr") then
    while( gets(line fptr)
      words = parseString(line " ")
      if( car(words) == "FORM" then
	if( nthelem(3 words) == "positive" ||
	    nthelem(3 words) == "full_contact" ||
	    nthelem(3 words) == "suppress_unconnect" ||
	    nthelem(3 words) == "undefined_line_width" then
	  fprintf(tot_ptr "%s" line)
	)
      )
    )
    fprintf(tot_ptr "FORM film_edit done\n")
    close(fptr)
  )
  tot_ptr

 ) ;end-let
) ;end-defun


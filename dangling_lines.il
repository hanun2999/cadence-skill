/*************************************************************
*
*  File:  dangling_lines.il
*
*  Date: April 2001
*
*  Written by: Douglas G. Stanley
*  Broadcom Corp. - dstanley@broadcom.com
*                   dgstan@yahoo.com
*
*  May 20, 2004 -  Mike Wilson 
*	 Dell Inc. - mike_wilson@dell.com
*
*	 15.x dangling_lines.txt has parentheses around the x,y pairs.
*	 Removed them so that the string to number conversion will work.
*	 Still works in 14.2 also.
*
**************************************************************
*
*  Purpose: To check the status of the dangling line report
*  and allow the easy access to the coordinates
*           
*
* 
* This is what the report looks like in 14.x:
* Dangling cline on ETCH TOP from 2865.0 4215.0 to 2965.0 4315.0

* This is what the report looks like in 15.x:
* Dangling cline on ETCH TOP from (2865.0 4215.0) to (2965.0 4315.0)
*
* This is after I chop the first few fields and filter the parentheses:
* TOP from 2865.0 4215.0 to 2965.0 4315.0
*
*/

axlCmdRegister("dangle" 'dangling_lines ?cmdType "general")
axlCmdRegister("dl" 'dangling_lines ?cmdType "general")

defun( dangling_lines ( )

  brd_name = axlCurrentDesign( )
  dl_list = list()


  defun( dl_form_action ( dl_form )
    case( dl_form->curField

      ("done"
        axlFormClose( dl_form )
        axlCancelEnterFun( )
        shell( "rm dl_form" )
      ); end "done"


      ("dl_list"

        axlFormSetFieldVisible( dl_form "line_start" 1 )
        axlFormSetFieldVisible( dl_form "line_end" 1 )
        axlUIWPrint( dl_form "Select \"Line Start\" or \"Line End\" to view endpoints..." )

        inc = 100
        pickline = dl_form->curValue

				rexCompile( "[()]" ) 
				line = rexReplace( pickline "" 0 )

        line_num = dl_form->curValueInt + 1

        line_str = parseString( line )
        layer = nth( 0 line_str )

        x1 = atof( nth( 2 line_str ) ) 
        y1 = atof( nth( 3 line_str ) )
        x2 = atof( nth( 5 line_str ) )
        y2 = atof( nth( 6 line_str ) )
	
        if( x1 < x2 then
          x1 = x1 - inc
          x2 = x2 + inc
        else
          x1 = x1 + inc
          x2 = x2 - inc
        )

        if( y1 < y2 then
          y1 = y1 - inc
          y2 = y2 + inc
        else
          y1 = y1 + inc
          y2 = y2 - inc
        )

        axlVisibleDesign( nil )
        
        pin_layer = strcat( "PIN/" layer )
        via_layer = strcat( "VIA CLASS/" layer )
        etch_layer = strcat( "ETCH/" layer )
        axlVisibleLayer( pin_layer t )
        axlVisibleLayer( via_layer t )
        axlVisibleLayer( etch_layer t )
        axlUIWUpdate( nil )
        Command = sprintf( dummy "window points;x %f y %f;x %f y %f" x1 y1 x2 y2 )
				print( Command )
        axlShell( Command )

      ); end "dl_list"


      ("line_start"

        inc = 200

        line_str = parseString( line )
				
        x0 = atof( nth( 2 line_str ) )
        y0 = atof( nth( 3 line_str ) )
        x1 = x0 - inc
        y1 = y0 - inc
        x2 = x0 + inc
        y2 = y0 + inc

        Command = sprintf( dummy "window points;x %f y %f;x %f y %f; zoom center; pick grid %f %f" x1 y1 x2 y2 x0 y0 )
        axlShell( Command )
        axlUIWPrint( dl_form "Start point of entry #%d at X: %d Y: %d" line_num fix( x0 ) fix( y0 ) )

      ); end "line_start"


      ("line_end"

        inc = 200

        line_str = parseString( line )
				
        x0 = atof( nth( 5 line_str ) )
        y0 = atof( nth( 6 line_str ) )
        x1 = x0 - inc
        y1 = y0 - inc
        x2 = x0 + inc
        y2 = y0 + inc

        Command = sprintf( dummy "window points;x %f y %f;x %f y %f; zoom center; pick grid %f %f" x1 y1 x2 y2 x0 y0 )
        axlShell( Command )
        axlUIWPrint( dl_form "End point of entry #%d at X: %d Y: %d" line_num fix( x0 ) fix( y0 ) )

      ); end "line_end"

    ); end case
  ); end defun Find_Component_Form_Action_Routine


  ;sprintf( command  "if( -e dangling_lines.txt ) rm dangling_lines.txt" )
  ;stat = csh( command )

  sprintf( msg "Generating Dangling Line Report: dangling_lines.txt" )
  axlMsgPut( msg )


  axlShell( "reports" )
  sprintf( command "setwindow form.rpt; FORM rpt rpt Dangling Lines; FORM rpt filename dangling_lines.txt; FORM rpt execute; FORM rpt cancel" )
  axlShell( command )

  rpt = infile( "./dangling_lines.txt" )

  if( getc( rpt ) != 'nil then

    close( rpt )
    rpt = infile( "./dangling_lines.txt" )

    axlMsgPut( "----- Errors found in Dangling Line Report -----" )

    while( gets( dl_entry rpt ) != 'nil
      dl_list = cons( dl_entry dl_list )
    )

    dl_form = nil

    dl_form=outfile("dl_form.form" "w")
    fprintf(dl_form "FILE_TYPE=FORM_DEFN VERSION=2\n")
    fprintf(dl_form "FORM\n")
    fprintf(dl_form "FIXED\n")
    fprintf(dl_form "PORT 42 20\n")
    fprintf(dl_form "HEADER \"Find Dangling Line Form\"\n")
    fprintf(dl_form "TILE\n")
    fprintf(dl_form "TEXT \"Select Dangling Line from list to view:\"\n")
    fprintf(dl_form "TLOC 2 1\n")
    fprintf(dl_form "ENDTEXT\n")
    fprintf(dl_form "FIELD dl_list\n")
    fprintf(dl_form "FLOC 2 3\n")
    fprintf(dl_form "LIST \"\" 39 8\n")
    fprintf(dl_form "ENDFIELD\n")
    fprintf(dl_form "FIELD line_start\n")
    fprintf(dl_form "FLOC 2 18\n")
    fprintf(dl_form "MENUBUTTON \"Line Start\" 6 3\n")
    fprintf(dl_form "ENDFIELD\n")
    fprintf(dl_form "FIELD line_end\n")
    fprintf(dl_form "FLOC 16 18\n")
    fprintf(dl_form "MENUBUTTON \"Line End\" 6 3\n")
    fprintf(dl_form "ENDFIELD\n")
    fprintf(dl_form "FIELD done\n")
    fprintf(dl_form "FLOC 32 18\n")
    fprintf(dl_form "MENUBUTTON \"Close\" 6 3\n")
    fprintf(dl_form "ENDFIELD\n")

    fprintf(dl_form "ENDTILE\n")
    fprintf(dl_form "ENDFORM\n")

    close(dl_form)

    dl_form=axlFormCreate( (gensym) "dl_form.form" '(e outer) 'dl_form_action t)

    foreach( dl dl_list

      dl_str = parseString( dl )
      dl_str = nthcdr( 4 dl_str )

      dl_cat = buildString( dl_str ) 

      axlFormSetField( dl_form "dl_list" dl_cat )

    ); end foreach 

    axlFormDisplay( dl_form )
    axlUIWPrint( dl_form "Select Dangling Line..." )
    axlFormSetFieldVisible( dl_form "line_start" 0 )
    axlFormSetFieldVisible( dl_form "line_end" 0 )

  else
    axlMsgPut( "----- Dangling Line Report complete - No errors found ----- \n" )
    ;axlUIConfirm( "-----Dangling Line Report complete - No errors found -----" )
  )

  close( rpt )

) ; end-defun


; This is what the report looks like:
; Dangling cline on ETCH TOP from 2865.0 4215.0 to 2965.0 4315.0

; This is after I chop the first few fields:
; TOP from 2865.0 4215.0 to 2965.0 4315.0

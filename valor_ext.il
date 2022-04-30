/*
**************************************************************
*
*  File:  valor_ext.il
*  (c) Copyright 1999 Valor Computerized Systems Ltd.
*
*  Date: Jan 28, 1998
*
*  Last Modified: Feb 1999
*  - Added support for property extraction
*  - updated for: Cadence Allegro (version 12) for Windows NT
*  - write tempfiles outside cadence file tree
*  - add "crosshatch" to extraction (KIT 5730)
*
*  Last Modified: Jun 2000
*  - build comps property list from design
*  - output net property file
*  - output technology file
*  - consolidated UNIX and NT versions into 1 file
*
*  Last Modified: Jul 2000
*  - build extract view file dynamiclly
*
*  Last Modified: Aug 2000
*  - delete extractfile, no longer need post hook files
*  - Combine the film file valor_film13_5.il into extract (this).
*
*  Last Modified: 6 Sep 2000 - Moshe Levy
*  - Set final extract of nets & tech files

*  Last Modified: May 2001 - ZW, as suggested by David Hutchins (Intel)
*  - Read in also 'logical component properties'
*
**************************************************************
* This Allegro Skill program may be loaded automatically
* when Allegro is invoked by creating an allegro.ilinit
* file in the user's pcbenv directory (i.e., ~/pcbenv/allegro.ilinit).
*
* The allegro.ilinit file could look like the following:
*----------- Start of allegro.ilinit file -----------------------------
*setSkillPath(". ~/scm ~/skill /tools/cadence/PE13.6/tools.sun4v/pcb/etc")
*load("valor_ext.il")
*----------- End of allegro.ilinit file --------------------------------
*
* Where this file, valor_ext.il, is located in one of the directory paths
* as defined by the setSkillPath function.
*
**************************************************************
*
*  Purpose:  To run the built in extract command creating 
*            views ready for Valor Enterprise EDA Translation
*
**************************************************************
*/
axlCmdRegister("valor extract info" 'valor_extract_info)
axlCmdRegister("extracts" 'valor_extract_info)

defun( valor_extract_info ( )
 let( (brd_name viewfile compsout geomsout layersout
       padsout pinsout propsout netsout techout extractfile command stat
       component prop prop_cnt cmp_prop_list inport outport text)
  axlMsgPut("Valor: Extract out files")

  brd_name = axlCurrentDesign()

  sprintf(extractfile "valor_view.txt")
  sprintf(compsout "comps_%s.out" brd_name)
  sprintf(geomssout "geoms_%s.out" brd_name)
  sprintf(layersout "layers_%s.out" brd_name)
  sprintf(padsout "pads_%s.out" brd_name)
  sprintf(pinsout "pins_%s.out" brd_name)
  sprintf(propsout "props_%s.out" brd_name)
  sprintf(netsout "nets_%s.out" brd_name)
  sprintf(techout "tech_%s.out" brd_name)

  /* generate the techfile */
  axlMsgPut("extracting technology file")
  command=sprintf(nil "techfile -w %s %s" axlGetDrawingName() techout)
  stat = system(command)

  /* extract the list of component properties */
  axlMsgPut("extracting Component Properties")
  foreach( component axlDBGetDesign()->compdefs
    foreach( prop axlDBGetProperties(component)
        if( !(member car(prop) cmp_prop_list) then
          cmp_prop_list = cons( car(prop) cmp_prop_list)
        );if
    );foreach Prop
  );foreach component 
  foreach( component axlDBGetDesign()->components
    foreach( prop axlDBGetProperties(component)
        if( !(member car(prop) cmp_prop_list) then
          cmp_prop_list = cons( car(prop) cmp_prop_list)
        );if
    );foreach Prop
  );foreach component

  /* outport = outfile(extractfile) */
  outport = axlDMOpenFile( "ALLEGRO_OUT" extractfile "w" )

  ;; build the extract file
  fprintf( outport "GEOMETRY\n" )
  fprintf( outport "    CLASS = 'PACKAGE GEOMETRY'\n" )
  fprintf( outport "    SUBCLASS = PLACE_BOUND_TOP \n" )
  fprintf( outport "    OR \n" )
  fprintf( outport "    CLASS = 'PACKAGE GEOMETRY'\n" )
  fprintf( outport "    SUBCLASS = PLACE_BOUND_BOTTOM   \n" )
  fprintf( outport "    OR \n" )
  fprintf( outport "    CLASS = 'PACKAGE GEOMETRY'\n" )
  fprintf( outport "    SUBCLASS = ASSEMBLY_TOP  \n" )
  fprintf( outport "    OR \n" )
  fprintf( outport "    CLASS = 'PACKAGE GEOMETRY'\n" )
  fprintf( outport "    SUBCLASS = ASSEMBLY_BOTTOM   \n" )
  fprintf( outport "#\n" )
  fprintf( outport "   SUBCLASS\n" )
  fprintf( outport "   RECORD_TAG\n" )
  fprintf( outport "   REFDES\n" )
  fprintf( outport "   COMP_PACKAGE\n" )
  fprintf( outport "   COMP_PART_NUMBER\n" )
  fprintf( outport "   SYM_NAME\n" )
  fprintf( outport "   SYM_X\n" )
  fprintf( outport "   SYM_Y\n" )
  fprintf( outport "   SYM_ROTATE\n" )
  fprintf( outport "   SYM_MIRROR\n" )
  fprintf( outport "   GRAPHIC_DATA_NAME\n" )
  fprintf( outport "   GRAPHIC_DATA_1\n" )
  fprintf( outport "   GRAPHIC_DATA_2\n" )
  fprintf( outport "   GRAPHIC_DATA_3\n" )
  fprintf( outport "   GRAPHIC_DATA_4\n" )
  fprintf( outport "   GRAPHIC_DATA_5\n" )
  fprintf( outport "   GRAPHIC_DATA_6\n" )
  fprintf( outport "   GRAPHIC_DATA_7\n" )
  fprintf( outport "   GRAPHIC_DATA_8\n" )
  fprintf( outport "   GRAPHIC_DATA_9\n" )
  fprintf( outport "   GRAPHIC_DATA_10\n" )
  fprintf( outport "END\n" )
  fprintf( outport "#\n" )
  fprintf( outport "FULL_GEOMETRY\n" )
  fprintf( outport "   CLASS\n" )
  fprintf( outport "   SUBCLASS\n" )
  fprintf( outport "   RECORD_TAG\n" )
  fprintf( outport "   REFDES\n" )
  fprintf( outport "   PIN_NUMBER\n" )
  fprintf( outport "   PAD_STACK_NAME\n" )
  fprintf( outport "   NET_NAME\n" )
  fprintf( outport "   PIN_X\n" )
  fprintf( outport "   PIN_Y\n" )
  fprintf( outport "   VIA_X\n" )
  fprintf( outport "   VIA_Y\n" )
  fprintf( outport "   TEST_POINT    \n" )
  fprintf( outport "   GRAPHIC_DATA_NAME\n" )
  fprintf( outport "   GRAPHIC_DATA_1\n" )
  fprintf( outport "   GRAPHIC_DATA_2\n" )
  fprintf( outport "   GRAPHIC_DATA_3\n" )
  fprintf( outport "   GRAPHIC_DATA_4\n" )
  fprintf( outport "   GRAPHIC_DATA_5\n" )
  fprintf( outport "   GRAPHIC_DATA_6\n" )
  fprintf( outport "   GRAPHIC_DATA_7\n" )
  fprintf( outport "   GRAPHIC_DATA_8\n" )
  fprintf( outport "   GRAPHIC_DATA_9\n" )
  fprintf( outport "   GRAPHIC_DATA_10\n" )
  fprintf( outport "   NO_SHAPE_CONNECT\n" )
  fprintf( outport "   DRILL_FIGURE_CHAR\n" )
  fprintf( outport "END\n" )
  fprintf( outport "#\n" )
  fprintf( outport "LAYER\n" )
  fprintf( outport "   LAYER_SORT\n" )
  fprintf( outport "   LAYER_SUBCLASS\n" )
  fprintf( outport "   LAYER_ARTWORK\n" )
  fprintf( outport "   LAYER_USE\n" )
  fprintf( outport "   LAYER_CONDUCTOR\n" )
  fprintf( outport "   LAYER_DIELECTRIC_CONSTANT\n" )
  fprintf( outport "   LAYER_ELECTRICAL_CONDUCTIVITY\n" )
  fprintf( outport "   LAYER_MATERIAL\n" )
  fprintf( outport "   LAYER_SHIELD_LAYER\n" )
  fprintf( outport "   LAYER_THERMAL_CONDUCTIVITY\n" )
  fprintf( outport "   LAYER_THICKNESS\n" )
  fprintf( outport "END\n" )
  fprintf( outport "#\n" )
  fprintf( outport "PAD_DEF\n" )
  fprintf( outport "END\n" )
  fprintf( outport "#\n" )
  fprintf( outport "COMPOSITE_PAD\n" )
  fprintf( outport "   CLASS\n" )
  fprintf( outport "   REFDES\n" )
  fprintf( outport "   PIN_NUMBER\n" )
  fprintf( outport "   PAD_STACK_NAME\n" )
  fprintf( outport "   START_LAYER_NAME\n" )
  fprintf( outport "   END_LAYER_NAME\n" )
  fprintf( outport "   NET_NAME\n" )
  fprintf( outport "   PIN_X\n" )
  fprintf( outport "   PIN_Y\n" )
  fprintf( outport "   VIA_X\n" )
  fprintf( outport "   VIA_Y\n" )
  fprintf( outport "   DRILL_HOLE_X\n" )
  fprintf( outport "   DRILL_HOLE_Y\n" )
  fprintf( outport "   DRILL_HOLE_PLATING\n" )
  fprintf( outport "   DRILL_FIGURE_CHAR\n" )
  fprintf( outport "   DRILL_FIGURE_SHAPE\n" )
  fprintf( outport "   DRILL_FIGURE_WIDTH \n" )
  fprintf( outport "   DRILL_FIGURE_HEIGHT\n" )
  fprintf( outport "   DRILL_FIGURE_ROTATION\n" )
  fprintf( outport "   GRAPHIC_DATA_NAME\n" )
  fprintf( outport "   GRAPHIC_DATA_1\n" )
  fprintf( outport "   GRAPHIC_DATA_2\n" )
  fprintf( outport "   GRAPHIC_DATA_3\n" )
  fprintf( outport "   GRAPHIC_DATA_4\n" )
  fprintf( outport "END\n" )
  fprintf( outport "#\n" )
  fprintf( outport "COMPONENT\n" )
  fprintf( outport "   REFDES != ''\n" )
  fprintf( outport "   REFDES\n" )
  fprintf( outport "   PART_NUMBER\n" )
  /* add the component property entries */
  foreach( prop cmp_prop_list
    fprintf( outport "   %s\n" prop )
  );foreach prop
  fprintf( outport "END\n" )
  fprintf( outport "#\n" )
  fprintf( outport "NET\n" )
  fprintf( outport "   NET_NAME_SORT\n" )
  fprintf( outport "   NET_NAME\n" )
  fprintf( outport "   NET_PHYSICAL_TYPE\n" )
  fprintf( outport "   NET_SPACING_TYPE\n" )
  fprintf( outport "   NET_ELECTRICAL_CONSTRAINT_SET\n" )
  fprintf( outport "   NET_DIFFERENTIAL_PAIR\n" )
  fprintf( outport "   NET_STUB_LENGTH\n" )
  fprintf( outport "   NET_MAX_VIA_COUNT\n" )
  fprintf( outport "   NET_MIN_LINE_WIDTH\n" )
  fprintf( outport "   NET_MAX_PARALLEL\n" )
  fprintf( outport "   NET_IMPEDANCE_AVERAGE\n" )
  fprintf( outport "END\n" )
  fprintf( outport "#\n" )
  /* close( outport) */
  axlDMClose( outport )

  /* Perform the extraction */
  if( stat = axlExtractToFile(extractfile
         list(compsout geomssout layersout padsout pinsout propsout netsout)
                              "crosshatch")  then
     axlMsgPut(" ----- Valor extract completed successfully ----- \n")
  else
     error( "Valor Extract: failure running extraction" )
  )
  deleteFile(extractfile)
 )
)

/*
**************************************************************
*
*  File:  valor_film13_5.il
*  (c) Copyright 1999 Valor Computerized Systems Ltd.
*
*  Date: April 1999
*
*  Last Modified: April 1999
*  - "valor film info" registered as general
*    No longer writes script to temp file
*       Assistance provided by Cadence:
*       (ref: inmail/enterprise/cadence/frank.990413)
*
**************************************************************
*
*  Purpose: To extract from a Cadence Allegro design the
*           Artwork information and place it in
*	    a file called "films_<brd_name>.afa"
*
*             For use with:
*                Cadence Allegro Version  12 (or newer)
*                Valor Enterprise Version 4.3D3 (or newer)
*
**************************************************************
*/

axlCmdRegister("valor film info" 'valor_film_info ?cmdType "general")
axlCmdRegister("films" 'valor_film_info ?cmdType "general")

defun( valor_film_info ( )
 let( ( brd_name afa_name DesignDir DirSep inPort dataLine dataList Layer Layers LayCnt EtchCnt )

  brd_name = axlCurrentDesign()
  sprintf(afa_name "films_%s.afa" brd_name)
  sprintf(msg "Valor: Writing %s" afa_name)
  axlMsgPut(msg)

  axlShell("film area -n")
  sprintf(buf "setwindow text; save %s; close" afa_name)
  axlShell(buf)

  axlMsgPut(" ----- Checking films contents ----- \n")
  EtchCnt = 0
  ; Get a list of classes
  Layers=(axlGetParam("paramLayerGroup:ETCH")->groupMembers)
  foreach( Layer Layers
    LayCnt = 0
    inPort = infile(afa_name)
    when( inPort
      while( gets( dataLine inPort )
        dataList = parseString( dataLine )
        if( equal( nthelem( 1 dataList ) "ETCH" ) then
          EtchCnt = EtchCnt + 1
          if( equal( nthelem( 2 dataList ) Layer ) then
            LayCnt = LayCnt + 1
          )
        )
        if( equal( nthelem( 2 dataList ) "ETCH" ) then
          EtchCnt = EtchCnt + 1
          if( equal( nthelem( 3 dataList ) Layer ) then
            LayCnt = LayCnt + 1
          )
        )
      )
      close( inPort )
    )
    if( LayCnt > 1  then
      sprintf(msg "Warning: ETCH/%s referenced multiple times in Films" Layer)
      axlMsgPut(msg)
    )
  )
  if( EtchCnt == 0 then
    axlMsgPut("Error: no ETCH class layers referenced in Films\n")
  else
    axlMsgPut(" ----- Valor films completed successfully ----- \n")
  )
 ) ; end-let
) ; end-defun


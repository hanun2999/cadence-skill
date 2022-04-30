; Create_Thermal_Flash.il
; Revision 0: July 31,1995
; Written by:
;	Edward B. Acheson
;	Corportate Application Engineer
;	Cadence Design Systems
;	Chelmsford MA 01824
;
;	Install this file in you master skill directory  then add load( "Create_Thermal_Flash.il")
;	to the allegro.ilinit file in you pcbenv directory. To start the command read the
;       fprintf lines in the function listed below:
;

axlCmdRegister( "mkth" `_THRP_Start)
;Globals
temphelpfile=nil
	temphelpfile = makeTempFileName("/tmp/THRPhelp")
	temphelpfile = strcat(temphelpfile ".txt")
;+
;===============================================================================
; NAME:
;	_THRP_Help
;
; SYNOPSIS:
;	 _THRP_Help()
;
; DESCRIPTION:
;	This function create a temporary help file and then displayes the file to the
;	screen. The file is then deleted 
;
;	For more information see:
;	makeTempFileName, axlUIConfirm, axlUIViewFileCreate
;
;===============================================================================
;-
defun( _THRP_Help ()
let( (helpPort message)
	helpPort = outfile( temphelpfile )
  fprintf( helpPort "===============================================================================\n")
  fprintf( helpPort "\n               Create Thermal Flash                      \n\n")
  fprintf( helpPort "===============================================================================\n")
  fprintf( helpPort " This Command is used to make a board symbol representation of a thermal flash\n")
  fprintf( helpPort "apperture for artwork generation using the 274X format, or for reading the input\n")
  fprintf( helpPort "of Gerber format into Allegro to view the art work generated. This command will\n")
  fprintf( helpPort "work under Allegro release 8.1 and higher.\n\n")
  fprintf( helpPort " To execute this command, open an Allegro Mechanical Symbol drawing. Set the\n")
  fprintf( helpPort "extents of the drawing so they are large enough to fit the symbol. Next\n")
  fprintf( helpPort "set the origin of the drawing to the center. In The Allegro Symbol\n")
  fprintf( helpPort "Command window enter mkth <ret>. This will startup the command. If the drawing\n")
  fprintf( helpPort "open is not a MECHANICAL drawing, then a message will appear and the opertion\n")
  fprintf( helpPort "will end.\n\n")
  fprintf( helpPort "When the Thermal Pad Symbol Defaults form appears, enter the data into each\n")
  fprintf( helpPort "field as required. Enter the values in each field in the same units as the open\n")
  fprintf( helpPort "MECHANICAL Drawing. No conversion will take place in this form. Checks are made\n")
  fprintf( helpPort "in the diameter defintions for correct input, and appropriate messages will\n")
  fprintf( helpPort "display. After all data is input, press the OK button, and the thermal shapes\n")
  fprintf( helpPort "will be added to the MECHANICAL symbol drawing. Make any edits you may require\n")
  fprintf( helpPort "in the drawing , then create the symbol under the apporpriate name and save the\n")
  fprintf( helpPort "symbol drawing.\n\n")
  fprintf( helpPort "Definitions:\n  Inner Diameter: The diameter of the innermost ring for the\n")
  fprintf( helpPort "           Thermal Relief Pad.\n")
  fprintf( helpPort "  Outer Diameter: The diameter of the outermost ring for the\n") 
  fprintf( helpPort "           Thermal Relief Pad.\n")
  fprintf( helpPort "  Spoke Width:    The width or thickness of the contact points\n")
  fprintf( helpPort "           or spokes for the Thermal Relief Pad.\n") 
  fprintf( helpPort "  No. of Spokes:  The number of contact points or spokes in the\n")
  fprintf( helpPort "           Thermal Relief Pad. Legal values are 1,2,3, and 4.\n") 
  fprintf( helpPort "  Spoke Angle:    The start angle of the Spoke. O degrees is\n")
  fprintf( helpPort "           vertical, then rotating counter-clockwise. Legal values\n")
  fprintf( helpPort "           are 0, 30, 45, 60, and 90. A popup will allow selection\n")
  fprintf( helpPort "           of values.\n")
  fprintf( helpPort "  Add Center Dot: The center dot is circular shape added to the\n")
  fprintf( helpPort "           Thermal Relief Pad to visually display the pad center.\n")
  fprintf( helpPort "           To allow the addition of the Center Dot Toggle this\n")
  fprintf( helpPort "           button ON.\n")
  fprintf( helpPort "  Dot Diameter:   The diameter value of the center dot.\n")
  fprintf( helpPort "  OK:             This button executes the generation of the Thermal\n")
  fprintf( helpPort "            Relief Pad.\n")
  fprintf( helpPort "  Cancel:         This button closes the form and exits this Command\n")
  fprintf( helpPort "  Help:           This button displays the help message.\n")
  fprintf( helpPort "\n\n For more information on this command see the Application note entitled\n")
  fprintf( helpPort "\"Generating Flash Thermal Relief Symbols: SKILL Program Create_Thermal_Flash.il\"\n") 
  fprintf( helpPort "===============================================================================\n")
  fprintf( helpPort "                                                                      eba290895\n")
     close(helpPort) 
     if(! isFile( temphelpfile) then
      	axlUIConfirm("Unable to Open Help File, Check Permissions!")
     else
	axlUIViewFileCreate( temphelpfile "Create Themal Flash - Help" nil)
     );if
));defun

;+
;===============================================================================
; NAME:
;	_THRP_Start
;
; SYNOPSIS:
;	 _THRP_Start()
;
; DESCRIPTION:
;	This function is called upon the exection of this skill command. It will
;	check for the correct drawing type, then will create the form file and
;	call the functions to open the form. The Global Variable for the form
;	pointer (THRP_FormPtr) is also intialized.
;
;	For more information see:
;	axlDesignType, _THRP_MkForm, axlUIConfirm, _THRP_Quit, _THRP_FormDisplay.
;
;===============================================================================
;-
defun( _THRP_Start ()
let( (formname innerd outerd spoke)
    THRP_FormPtr = nil
    if( axlDesignType( t ) == "MECHANICAL" then
        formname = _THRP_MkForm()
        if(! isFile( formname) then
        	axlUIConfirm("Unable to Open Form File, Check Permissions!")
            _THRP_Quit()
        else
           _THRP_FormDisplay( formname )
        );if 
    else
      axlUIConfirm("Illegal Drawing Type. Must be a Mechanical Symbol Drawing!")
   )
));defun

;+
;===============================================================================
; NAME:
;	_THRP_RunCmd
;
; SYNOPSIS:
;	 _THRP_RunCmd()
;
; DESCRIPTION:
;	This function is called by the 'OK' button on the Thermal Pad Symbol
;	Defaults form. This function calls all the required functions to 
;	verify form data and construct the shapes for the definition of the
;	thermal relief pads.
;
;	For more information see:
;	_THRP_CheckValues, _THRP_GetCoord, _THRP_BuildMasterCoord, _THRP_BuildTHShape
;	_THRP_MkCenterDot, axlMsgPut, _THRP_Quit.
;
;===============================================================================
;-
defun( _THRP_RunCmd ()
    let( (primarypoints mastercoord values success)
        success = nil
	when( _THRP_CheckValues() == t
         	primarypoints = _THRP_GetCoord()
       		mastercoord = _THRP_BuildMasterCoord(primarypoints)
       		success = _THRP_BuildTHShape( mastercoord
				      nthelem( 4 primarypoints)
      				      nthelem( 5 primarypoints)
			       	      )
      		 when( success != nil && THRP_FormData->trgtdt == t
			success =  _THRP_MkCenterDot()
		        when(success == nil
		   	    axlMsgPut("Error - Center Dot Shape Not Added")
			);when
		 );when
         );if
	when(success == t _THRP_Quit())
));defun
       

;+
;===============================================================================
; NAME:
;	_THRP_Quit
;
; SYNOPSIS:
;	 _THRP_Quit()
;
; DESCRIPTION:
;	This function will close the form assigned to Global variable THRP_FormPtr.
;	This function is called by the success in the _THRP_RunCmd or the Cancel
;	button in the Thermal Pad Symbol Defaults form.
;
;	For more information see:
;	axlFormClose.
;
;===============================================================================
;-
defun( _THRP_Quit ()
      when( THRP_FormPtr  axlFormClose( THRP_FormPtr ))
      when( isFile( temphelpfile )
	 deleteFile( temphelpfile )
      )
);defun
 

;+
;===============================================================================
; NAME:
;	_THRP_MkCenterDot
;
; SYNOPSIS:
;	 _THRP_MkCenterDot()
;
; DESCRIPTION:
;	This function will create a shape circle at the 0X 0Y location at the
;	diameter specified in the Thermal Pad Symbol Defaults form. This data
;	is extracted from the Dot Diameter field. If the creation of the shape
;	is successful, this function returns 't', otherwise a 'nil' is returned.
;
; DEPENDENCIES:
;	The global variable THRP_FormData is required.
;
;	for more information see:
;	axlPathStartCircle, axlDBCreateOpenShape, axlDBCreateCloseShape.
;
;===============================================================================
;-
defun( _THRP_MkCenterDot ()
prog( ()
let( (path success)
	path = axlPathStartCircle( list(0.0:0.0 (THRP_FormData->trgtdia/2.0)) 0.0) 
	shapeid = axlDBCreateCloseShape(axlDBCreateOpenShape( path t  "etch/top" nil ))
	if( shapeid != nil then
	    return(t)
	else
	    return(nil)
        );
)));

;+
;===============================================================================
; NAME:
;	_THRP_CheckValues
;
; SYNOPSIS:
;	 _THRP_CheckValues()
;
; DESCRIPTION:
;	This function check for leagal values defined in the Thermal Pad Definition
;	Form. If All values entered are legal, this function will return 't'. If
;	any value is illegal, this function returns 'nil'. A message will display
;	which value is incorrect.
;
; DEPENDENCIES:
;	This function requires the global variable THRP_FormData for the form
;	pointer.
;
;	For more information see:
;	axlMsgPut
;
;===============================================================================
;-
defun( _THRP_CheckValues ()
prog( ()
let( ()
	if(THRP_FormData->indiam > 0 then
	   if(THRP_FormData->outdia  > 0 then
              if(THRP_FormData->outdia > THRP_FormData->indiam then
	         if(THRP_FormData->spkwdth > 0 then
                   if(THRP_FormData->trgtdt == nil then
			return(t)
		   else
		      if(THRP_FormData->trgtdia > 0 then
			 return(t)
		      else
			 axlMsgPut( "Invalid Value for Center Dot Size")	
		      );if
                    );if
                 else
                    axlMsgPut( "Invalid Value for Spoke Width")
		 );if
              else
                axlMsgPut( "Outer Diameter Must Be A Greater Value Than The Inner Diameter")
              );if
           else
              axlMsgPut( "Invalid Value for Outer Diameter")
           );if
        else
           axlMsgPut( "Invalid Value for Inner Diameter")
	);if
	return(nil)
)));defun

;+
;===============================================================================
; NAME:
;	_THRP_BuildTHShape
;
; SYNOPSIS:
;	 _THRP_BuildTHShape(
;			input_list
;		        start_angle
;			num_spokes
;			)
;
; DESCRIPTION:
;	This function will create the arc shapes for the thermal reliefs. This
;	function will retyrn a value of t if shape creation is successful, or a
;	nil value if all shapes cannot be created. If a shape cannot be created a
;	message will be displayed.
;
; DEPENDENCIES:
;	input_list - the list of coordinates for the shape corner points.
;	
;	start_angle - the angle in degrees from which the arc segment will be
;			constructed from.
;	num_spokes - the number of contact spokes. Limit to 1,2,3 or 4.		
;
;	For more information see:
;	_THRP_MkPath, axlDBCreateCloseShape, axlDBCreateOpenShape, axlMsgPut.
;
;===============================================================================
;-
defun( _THRP_BuildTHShape ( coord_list sangle num_spoke)
prog( ()
	let( (counter add_angle shapeid)
	counter = 0
	shapeid = nil
	add_angle = 360 / num_spoke
	while( (counter < num_spoke)
		path = _THRP_MkPath( coord_list sangle)
		shapeid = axlDBCreateCloseShape(axlDBCreateOpenShape( path t  "etch/top" nil ))
		when( shapeid == nil
                     axlMsgPut("ERROR - Could Not Generate Shape")
		     return( nil )
		)
		sangle = sangle + add_angle
		counter++
	);while
	return( t )
)));defun

;+
;===============================================================================
; NAME:
;	_THRP_BuildMasterCoord
;
; SYNOPSIS:
;	 _THRP_BuildMasterCoord( input_list )
;
; DESCRIPTION:
;	This function takes a list five floating integers and returns a list of
;	four lists of XY coordinates. The function identifes four corners from
;	the first, second third and fifth elements in the input list. This first
;	and second input coordinates are the minimum Y, maximum Y coordinates
;	respectively. The third element is the X coordinate, the fith coordinate is
;	the number of divisions which will be divided by 360 degrees.
;	 The return list is a series of XY list coordinates in a sequential order
;	for the adding of a polygonal outline for an arc type object.
;
; DEPENDENCIES:
;	input_list - This list is generated by _THRP_GetCoord()
;
;	For more information see:
;	_THRP_GetCoord()
;
;===============================================================================
;-
defun( _THRP_BuildMasterCoord (point_list)
prog( ()
let( ( arcswing corner1 corner2 corner3 corner4)
	arcswing = 360 / nthelem( 5 point_list) 
	if( nthelem( 5 point_list) > 2 then
		arcswing = ( nthelem( 5 point_list) - 1) * arcswing
	);if
	corner1 = list( nthelem( 3 point_list) nthelem( 1 point_list))
	corner2 = _clpRotatePt( list( (-1* nthelem(3 point_list)) nthelem(1 point_list)) '(0 0) arcswing)
	corner3 = _clpRotatePt( list( (-1* nthelem(3 point_list)) nthelem(2 point_list)) '(0 0) arcswing)
	corner4 = list( nthelem( 3 point_list) nthelem( 2 point_list))
	return( list( corner1 corner2 corner3 corner4))
)));

;+
;===============================================================================
; NAME:
;      _THRP_GetCoord
;
; SYNOPSIS:
;        _THRP_GetCoord()
;
; DESCRIPTION:
;        This function reads the data entered in the form passed by the global
;	variable THRP_FormData. This function uses the inner diameter, outer
;	diameter data, and spoke width to calculate a vertex point for an arc.
;	The values for number of spokes and angle are also converted from ASCII
;	to numeric. 
;	 This Function returns a list of coordinates from which to
;	calculate vertices. The return format in the list is inner y coordinate,
;	outer Y coordinate, X coordinate, rotation angle, number of spokes.
; 
; DEPENDENCIES:
;         This function requires the following input:
;	THRP_FormData->indiam,THRP_FormData->outdia,THRP_FormData->spkwdth,
;	THRP_FormData->spkangl,THRP_FormData->spknum
;
;        For more information see:
;            axlCreateForm()
;
;===============================================================================
;-
defun( _THRP_GetCoord ()
prog( ()
let( (innerR outerR spc counter set_angle)
	innerR= THRP_FormData->indiam / 2.0
        outerR = THRP_FormData->outdia / 2.0
	spc = THRP_FormData->spkwdth / 2.0

	coordin = sqrt( (innerR * innerR) - ( spc * spc) )
	coordout = sqrt( (outerR * outerR) - ( spc * spc) )

        set_angle = case( (THRP_FormData->spkangl)
              ("0"  0)
	      ("15" 15)
              ("30" 30)
              ("45" 45)
              ("60" 60)
	      ("75" 75)
              ("90" 90)
         );case
	num_spokes = THRP_FormData->spknum
	coord_data = list( coordin coordout spc set_angle num_spokes) 
	return(coord_data)
)));defun

;+
;===============================================================================
; NAME:
;      _THRP_MkPath
;
; SYNOPSIS:
;        _THRP_FormCallBack(
;		coord_list
;		angle
;		)
;
; DESCRIPTION:
;	This function returns a Path for the generation of a shape which represents
;	a section of a Thermal relief pad. This function will cause the shape path
;	to be rotated as required. 
;
; DEPENDENCIES:
;	coord_list - a list of four coordinate list pairs which represent the
;		     four corners of an arc type shape.
;	angle - The angle in degrees for the rotation of the shape from 0:0.
;
;	For more information see:
;		axlPathStart, axlPathArcCenter, axlPathLine, _THRP_RotatePt
;
;===============================================================================
;-
defun( _THRP_MkPath ( coord_list angle)
prog( ()
let( (path coord_pair coord_pairp first_pair next_pair)
	path = nil
	coord_pairp = _clpRotatePt( nthelem( 1 coord_list) '(0 0) angle)
	path = axlPathStart(  list( car(coord_pairp):cadr(coord_pairp)))
	coord_pair = _clpRotatePt( nthelem( 2 coord_list) '(0 0) angle)
        path = axlPathArcCenter( path,0.0, car(coord_pair):cadr(coord_pair), t, 0:0 )
	coord_pair = _clpRotatePt( nthelem( 3 coord_list) '(0 0) angle)
        path = axlPathLine( path,0.0, car(coord_pair):cadr(coord_pair))
	coord_pair = _clpRotatePt( nthelem( 4 coord_list) '(0 0) angle)
        path = axlPathArcCenter( path,0.0, car(coord_pair):cadr(coord_pair), nil, 0:0 )
        path = axlPathLine( path,0.0, car(coord_pairp):cadr(coord_pairp))
        return( path )

)));defun

;+
;===============================================================================
; NAME:
;      _THRP_FormCallBack
;
; SYNOPSIS:
;        _THRP_FormCallBack()
;
; DESCRIPTION:
;        This function is used in the axlCreateForm command. This Call is to
;	identify values and actions from the form currently displayed.
;     
;        For more information see:
;            axlCreateForm()
;
;===============================================================================
;-
defun(  _THRP_FormCallBack ( form )
    case( get( THRP_FormPtr 'curField)
	( "outdia" putprop( THRP_FormData get( THRP_FormPtr 'curValue) 'outdia))
	( "indiam" putprop( THRP_FormData get( THRP_FormPtr 'curValue) 'indiam))
	( "spkwdth" putprop( THRP_FormData get( THRP_FormPtr 'curValue) 'spkwdth))
	( "spkangl" putprop( THRP_FormData get( THRP_FormPtr 'curValue) 'spkangl))
	( "spknum" putprop( THRP_FormData get( THRP_FormPtr 'curValue) 'spknum))
	( "trgtdt" putprop( THRP_FormData get( THRP_FormPtr 'curValue) 'trgtdt))
	( "trgtdia" putprop( THRP_FormData get( THRP_FormPtr 'curValue) 'trgtdia))
        ( "okay" _THRP_RunCmd())
        ( "cancel" _THRP_Quit())
	( "vhelp" _THRP_Help())
    );case
);defun
  
;+
;===============================================================================
; NAME:
;      _THRP_FormDisplay
;
; SYNOPSIS:
;        _THRP_FormDisplay()
;
; DESCRIPTION:
;        This function is used in the axlCreateForm command. This Call is to
;	identify values and actions from the form currently displayed.
;     
;        For more information see:
;            axlCreateForm()
;
;===============================================================================
;-
defun(  _THRP_FormDisplay ( formname )
   prog( ()
   THRP_FormData = nil
   let( (form)
   form = axlFormCreate( (gensym) formname '(CENTER) '_THRP_FormCallBack t)
   setq(THRP_FormPtr  form)
   if( THRP_FormData == nil then
        setq( THRP_FormData t)
        axlFormSetField( THRP_FormPtr "trgtdia" 0.0)
        putprop( THRP_FormData 0.0 'trgtdia)
        axlFormSetField( THRP_FormPtr "trgtdt" nil)
        putprop( THRP_FormData nil 'trgtdt)
        axlFormSetField( THRP_FormPtr "spkangl" "45")
        putprop( THRP_FormData "45" 'spkangl)
        axlFormSetField( THRP_FormPtr "spknum" 4)
        putprop( THRP_FormData 4 'spknum)
        axlFormSetField( THRP_FormPtr "spkwdth" 20.0)
        putprop( THRP_FormData 20.0 'spkwdth)
        axlFormSetField( THRP_FormPtr "indiam" 90.0)
        putprop( THRP_FormData 90.0 'indiam)
        axlFormSetField( THRP_FormPtr "outdia" 110.0)
        putprop( THRP_FormData 110.0 'outdia)
        axlFormDisplay( form )
   );if
  when( isFile( formname )  deleteFile( formname ))
)));defun

   
;+
;===============================================================================
; NAME:
;      _THRP_MkForm
;
; SYNOPSIS:
;        file_name = _THRP_MkForm()
;
; DESCRIPTION:
;        This function creates a form file in the /tmp directory with a temporary
;        name. The temporary name is returned. This form file is used to collect
;        information 
;     
;        For more information see:
;            makeTempFileName(), outfile()
;
;===============================================================================
;-
defun( _THRP_MkForm ()
prog( ()
let( (tempformfile formPort)
	tempformfile = makeTempFileName("/tmp/Thermalform")
	tempformfile = strcat(tempformfile ".form")
	formPort = outfile( tempformfile )
    fprintf( formPort "FILE_TYPE = FORM_DEFN VERSION=2\n FORM\nFIXED\nPORT 64 12\n")
    fprintf( formPort "HEADER \"Thermal Pad Symbol Defaults\"\n\n")
    fprintf( formPort "POPUP <CURSANGLE>\"0\"\"0\",\"30\"\"30\",\"45\"\"45\",\"60\"\"60\",\"90\"\"90\".\n")
    fprintf( formPort "POPUP <CURSSPOKES>\"1\"\"1\",\"2\"\"2\",\"3\"\"3\",\"4\"\"4\".\n\n")
    fprintf( formPort "TILE\n\nGROUP \"Thermal Pad Definition\"\nGLOC 1 1\nGSIZE 30 10\nENDGROUP\n\n")
    fprintf( formPort "TEXT \"Inner Diameter:\"\n TLOC 2 4\n FGROUP \"Thermal Pad Definition\"\n ENDTEXT\n \n")
    fprintf( formPort "FIELD indiam\n FLOC 18 4\n REALFILLIN 9 9\n DECIMAL 4\n FGROUP \"Thermal Pad Definition\"\n ENDFIELD\n \n")
    fprintf( formPort "TEXT \"Outer Diameter:\"\n TLOC 2 6\n FGROUP \"Thermal Pad Definition\"\n ENDTEXT\n \n")
    fprintf( formPort "FIELD outdia\n FLOC 18 6\n REALFILLIN 9 9\n DECIMAL 4\n FGROUP \"Thermal Pad Definition\"\n ENDFIELD\n \n")
    fprintf( formPort "GROUP \"Spoke Definition\"\n GLOC 33 1\n GSIZE 30 10\n ENDGROUP\n \n")
    fprintf( formPort "TEXT \"Spoke Width:\"\n TLOC 34 4\n FGROUP \"Spoke Definition\"\n ENDTEXT\n \n")
    fprintf( formPort "FIELD spkwdth\n FLOC 50 4\n REALFILLIN 9 9\n DECIMAL 4\n FGROUP \"Spoke Definition\"\n ENDFIELD\n \n")
    fprintf( formPort "TEXT \"Num. of spokes\"\n TLOC 34 6\n FGROUP \"Spoke Definition\"\n ENDTEXT\n\n")
    fprintf( formPort "FIELD spknum\n FLOC 50 6\n INTSLIDEBAR 2 2\n MIN 1\n MAX 4\n FGROUP \"Spoke Definition\"\n ENDFIELD\n\n")
    fprintf( formPort "TEXT \"Spoke Angle:\"\n TLOC 34 8\n FGROUP \"Spoke Definition\"\n ENDTEXT\n\n")
    fprintf( formPort "FIELD spkangl\n FLOC 50 8\n ENUMSET 3\n POP \"CURSANGLE\"\n FGROUP \"Spoke Definition\"\n ENDFIELD\n\n")

    fprintf( formPort "GROUP \"Center Dot Option\"\n GLOC 1 12\n GSIZE 62 6\n ENDGROUP\n\n")
    fprintf( formPort "FIELD trgtdt\n FLOC 2 15\n CHECKLIST \"Add Center Dot\"\n FGROUP \"Center Dot Option\"\n ENDFIELD\n\n")
    fprintf( formPort "TEXT \"Dot Diameter\"\n TLOC 34 15\n FGROUP \"Center Dot Option\"\n ENDTEXT\n\n FIELD trgtdia\n FLOC 50 15\n")
    fprintf( formPort "REALFILLIN 9 9\n DECIMAL 4\n FGROUP \"Center Dot Option\"\n ENDFIELD\n\n")

    fprintf( formPort "FIELD okay\n FLOC 3 20\n MENUBUTTON \" OK \" 10 3\n ENDFIELD\n\n")
    fprintf( formPort "FIELD cancel\n FLOC 27 20\n MENUBUTTON \"Cancel\" 10 3\n ENDFIELD\n\n")
    fprintf( formPort "FIELD vhelp\n FLOC 49 20\n MENUBUTTON \" Help \" 10 3\n ENDFIELD\n\n")

    fprintf( formPort "ENDTILE\n ENDFORM\n")
	close( formPort )

	return( tempformfile )

))); defun


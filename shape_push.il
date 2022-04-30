;       This is a modified version of "mv_shape.il" which was
;       originally written by Linda Mezzatelli of Cadence Design
;       in the Columbia MD office.
;       Rewvision 0:
;               Linda Mazzitelli
;
;       Revision 1:                             February 16,1995
;               Ed Acheson
;
;       I reformated the program by breaking it down into specific functions
;       for readibility.
;       I enhanced this SKILL program so that shapes with arcs may be copied.
;       I also added the feature to create power planes from the route keep in
;       shape.
;       The form was reset to get actual ecth layers used in the drawing.
;
;
;       How to use:
;       place this file in your SKILL directory as shape_push.il and
;       modify the allegro.ilinit file. Open an Allegro drawing with
;       shapes. Enter the command push_shapes in the Allegro command
;       window. Pick the shape you wish to copy. A form will appear.
;       Enter the class and subclass to copy the shape to. If there
;       are more shapes to copy select execute, If no more shaps are
;       to be copied, select done.
;       If a net is attached to the shape, that net will be copied to
;       the new shape.
;       The Cancel button, or popup will stop the command without
;       any currently highlighted or selected shapes and exit.
;
;       Special Feature:
;       Once special feature about this command is, If a Route Keepin
;       Shape is selected, You enter the Etch Class/Subclass name, Select
;       Execute or Done in the form, you will then be prompted for a net
;       name. The shape will be copied to the Specified etch layer as a
;       SOLID PLANE.
;       This will expidite the genration of Power Planes.
;
;       Limitations:
;       At this time, voids are not copied. Any restrictions for shapes
;       on class/subclass layers apply.
;
axlCmdRegister( "push_shapes" `_CSS_RunInit)
axlCmdRegister( "copy_shape" `_CSS_RunInit)

;===================================================================
;+
;NAME:
;       _CSS_Popup_Form
;
;SYNOPSIS:
;       formptr = _CSS_Popup_Form()
;
;Description:
;       This function creates a popup to cancel from the command when
;       attempting to select a shape.
;       This function takes no parameters. This function returns the
;       form parameters to create the popup
;
;       This function is called by the popup skill command
;       For Further information see:
;       axlUIPopupSet, axlUIPopupDefine
;
;-
;===================================================================
defun( _CSS_Popup_Form ()
prog( ()
let( (popup_ptr)
        popup_ptr = axlUIPopupDefine( nil
                (list
                         (list "cancel" '_CSS_Cancel)
                        )
                )
        return( popup_ptr)
)));
 
 
;===================================================================
;+
;NAME:
;       _CSS_FormFile
;SYNOPSIS:
;       _CSS_FormFile()
;
;Description:
;       This function creates the form file required by the
;       _CSS_Form_Create function. This function extracts etch
;       subclass names and builds a popup list for etch subclasses.
;       This function requires no parameters.
;       This function returns no parameters
;       For More information see:
;       _CSS_Form_Create, axlExtractToFile
;-
;===================================================================
defun( _CSS_FormFile ()
let( (exfile form_file exdata not_eof line layer_name parsed_line)
        exfile = outfile("ex_tmp_file.txt")
        fprintf( exfile "LAYER\nLAYER_ARTWORK = NEGATIVE\n")
        fprintf( exfile "OR\nLAYER_ARTWORK = POSITIVE\n")
        fprintf( exfile "LAYER_SUBCLASS\n")
        close( exfile )
        axlExtractToFile( "ex_tmp_file.txt" "ex_layer_data_temp.txt" "quiet")
        form_file = outfile( "mv_shape.form")
        fprintf( form_file "FILE_TYPE = FORM_DEFN VERSION = 2\nFORM\nFIXED\n")
        fprintf( form_file "PORT 44 14\nHEADER \"Copy Shape To:\"\n")
        fprintf( form_file "POPUP <CLASSP>\"ETCH\" \"ETCH\",\"ROUTE KEEPOUT\" ")
        fprintf( form_file "\"ROUTE KEEPOUT\",\"PACKAGE KEEPOUT\" \"PACKAGE KEEPOUT\".\n")
        fprintf( form_file " POPUP <SUBP>")
        exdata = infile("ex_layer_data_temp.txt")
        not_eof = gets( line exdata)
        while( not_eof
                parsed_line = parseString( line "!")
                if( nthelem( 1 parsed_line) == "S" then
                        layer_name = nthelem( 2 parsed_line)
                        when( layer_name != nil
                        fprintf( form_file "\"%s\" \"%s\"" layer_name layer_name)
                        )
                )
                not_eof = gets( line exdata)
                if( nthelem( 1 parsed_line) == "S" && not_eof fprintf( form_file ","))
        );endwhile
        close( exdata )
        fprintf( form_file ". \n\n")
        fprintf( form_file "TILE\n\n")
        fprintf( form_file "TEXT \"Class:\"\nTLOC 3 5\nENDTEXT\n\n")
        fprintf( form_file "TEXT \"Subclass:\"\nTLOC 3 11\nENDTEXT\n\n")
        fprintf( form_file "FIELD class\nFLOC 15 5\nSTRFILLIN 20 20\nPOP \"CLASSP\"\n")        fprintf( form_file "ENDFIELD\n\n")
        fprintf( form_file "FIELD subclass\nFLOC 15 11\nSTRFILLIN 20 20\nPOP \"SUBP\"\n")
        fprintf( form_file "ENDFIELD\n\n")
        fprintf( form_file "FIELD execute\nFLOC 3 17\nMENUBUTTON \"Execute\" 10 2\n ENDFIELD\n\n")
        fprintf( form_file "FIELD done\nFLOC 17 17\nMENUBUTTON \"Done\" 10 2\n ENDFIELD\n\n")
        fprintf( form_file "FIELD cancel\nFLOC 31 17\nMENUBUTTON \"Cancel\" 10 2\n ENDFIELD\n\n")
        fprintf( form_file "ENDTILE\n\nENDFORM\n")
        close( form_file )
));endDefun _CSS_FormFile
        
 
;===================================================================
;+
;NAME:
;       _CSS_Form_Create
;
;SYNOPSIS:
;       formptr = _CSS_Form_Create()
;
;Description:
;       This function creates a form pointer id for input of
;       class/subclass data. This function takes no parameters. This
;       function returns the form pointer. This function requires a
;       form file named "mv_shape.form" located in the form search
;       directory.
;       The form callback function is named _CSS_Form_Action
;       For Further information see:
;       axlFormCreate, _CSS_Form_Action
;
;-
;===================================================================
defun( _CSS_Form_Create ()
prog( ()
let( (form_ptr)
        if( ! isFile("mv_shape.form") _CSS_FormFile())
        if( isFile("mv_shape.form") then
        form_ptr = axlFormCreate(
                        gensym()
                        "mv_shape.form"
                        '("E" "OUTER")
                        '_CSS_Form_Action t
                )
        return( form_ptr )
        else
                axlMsgPut(" ERROR - Unable To open Form File")
                return( nil )
        )
);end-let
);end-prog
);end-defun
 
 
;===================================================================
;+
;NAME:
;       _CSS_Form_Action
;
;SYNOPSIS:
;       _CSS_Form_Action
;
;Description:
;       This function is called by the _CSS_Form_Create function when
;       the form is created. This form requires the pointer assigned
;       for the form as it is generated.
;
;       For Further information see:
;       axlFormCreate, _CSS_Form_Create
;
;-
;===================================================================
defun( _CSS_Form_Action (_CSS_Form_Ptr)
        case(_CSS_Form_Ptr->curField
                ("class"
                        CSSclass=_CSS_Form_Ptr->curValue
                        CSSclass=upperCase(CSSclass)
                )
                ("subclass"
                        CSSsubclass=_CSS_Form_Ptr->curValue
                        CSSsubclass=upperCase(CSSsubclass)
                )
                ("execute"
                        axlDehighlightObject(_CSS_Shape_DBID)
                        axlCancelEnterFun()
                        axlUIPopupSet( nil )
                        axlFormClose(_CSS_Form_Ptr)
                        _CSS_CreatShape(_CSS_Shape_DBID CSSclass CSSsubclass)
                        _CSS_RunInit()
                )
                ("done"
                        axlClearSelSet()
                        axlDehighlightObject(_CSS_Shape_DBID)
                        axlFormClose(_CSS_Form_Ptr)
                        _CSS_CreatShape(_CSS_Shape_DBID CSSclass CSSsubclass)
                        axlCancelEnterFun()
                        _CSS_Cancel()
                )
                ("cancel"
                        axlDehighlightObject(_CSS_Shape_DBID)
                        axlClearSelSet( )
                        _CSS_Shape_DBID = nil
                        axlFormClose(_CSS_Form_Ptr)
                        axlCancelEnterFun()
                        _CSS_Cancel()
                )
        )
);
;===================================================================
;+
;NAME:
;       _CSS_CreatShape
;SYNOPSIS:
;       _CSS_CreatShape(shape_ptr class_data subclass_data)
;
;Description
;       This function call the required functions to construct a shape
;       from a selected shape. This function requires three parameters.
;       the first is the selected shape pointer, the second is parameter
;       is a test string for the class name. The third parameter is a
;       test string for the subclass name.
;
;       For further information see:
;       _CSS_BuildShapePath, _CSS_AddShape
;-
;=====================================================================
defun( _CSS_CreatShape (shape_ptr class_data subclass_data)
 let( (segment_list shape_path )
        segment_list =car( shape_ptr )->segments
        shape_path = _CSS_BuildShapePath( segment_list )
        _CSS_AddShape( shape_path shape_ptr class_data subclass_data)
        _CSS_Shape_DBID = nil
));
 
 
;===================================================================
;+
;NAME:
;       _CSS_SelectShape
;
;SYNOPSIS:
;       shape_dbid = _CSS_SelectShape()
;
;Description:
;       This function creates a form pointer id for input of
;       class/subclass data. This function takes no parameters. This
;       function returns the form pointer. This function requires a
;       form file named "mv_shape.form" located in the form search
;       directory.
;       For Further information see:
;       axlFormCreate
;
;-
;===================================================================
defun( _CSS_SelectShape ()
prog( ()
let( ( sel_shape_id )
        axlClearSelSet()
        axlSetFindFilter(
                ?enabled '("NOALL" "SHAPES")
                ?onButtons '("SHAPES")
        )
        axlMsgPut("Select Shape.")
        sel_shape_id = axlGetSelSet(axlSingleSelectPoint())
        when(sel_shape_id != nil axlHighlightObject( sel_shape_id ))
        return( sel_shape_id )
)));end - defun
 
 
;===================================================================
;+
;NAME:
;       _CSS_AddShape
;
;SYNOPSIS:
;        _CSS_AddShape( shape_path shape_id class_data subclass_data)
;
;Description:
;       This function creates a new shape from the segments of the
;       input shape_path. The selected shape dbid (shape_id ) is passed
;       to get net and fill data for the shape. The shape Class and Subclass names
;       are passed as string variables. This function reqiures that all
;       three parameters are entered. If all three parameters are nil
;       this function returns a nil. If this function is successful, it
;       will return a 't'.
;       For Further information see:
;       axlDBCreateShape
;
;-
;===================================================================
defun( _CSS_AddShape ( shape_path shape_dbid class_data subclass_data)
let( (fill_type net_name clss_sbclss)
        sprintf( clss_sbclss "%s/%s" class_data subclass_data)
        if( car(shape_dbid)->layer == "ROUTE KEEPIN/ALL" && class_data == "ETCH" then
                fill_type = t
                net_name = axlUIPrompt(" Enter New Net Name" "")
        else
                fill_type = car(shape_dbid)->fill
                net_name = car(shape_dbid)->net->name
        )
        axlDBCreateCloseShape(
                axlDBCreateOpenShape( shape_path
                        fill_type
                        clss_sbclss
                        net_name
                        nil
                )
        )
));end-defun
;===============================================================================
;+
; NAME:   _CSS_BuildShapePath
;
; SYNOPSIS: shape_path = _CSS_BuildShapePath( segment_list )
;
; Description:
;       This function creates a path list required for creating a Shape outline
;       for the SKILL axlDB-Shape commands. This function requires a list of
;       segments as the input parameter.
;       this function will return the path list.
;
;       For further information see:
;       axlPathStart, axlPathLine, axlPathArcCenter
;
;-
;===============================================================================
defun( _CSS_BuildShapePath ( segment_list)
prog( ()
let( ( return_path coord_number)
   coordinate_number = nil
   if(coordinate_number == nil then
       foreach(seg segment_list
          when(seg->objType == "line"
            if(coordinate_number == nil then
                coord = car(seg->startEnd)
                return_path = axlPathStart( list(coord)  seg->width)
                return_path = axlPathLine( return_path seg->width car( cdr(seg->startEnd)) )
                coordinate_number = t
            else
                return_path = axlPathLine(return_path seg->width car( cdr(seg->startEnd)) )
            );endif
          );endwhen
          when(seg->objType == "arc"
             if(coordinate_number == nil then
                 coord = car(seg->startEnd)
                 return_path = axlPathStart( list(coord)  seg->width)
                 return_path = axlPathArcCenter( return_path  seg->width car( cdr(seg->startEnd))
                                seg->isClockwise seg->xy)
                 coordinate_number = t
             else
                 return_path = axlPathArcCenter( return_path seg->width car( cdr(seg->startEnd))
                                                seg->isClockwise seg->xy )
             );endif
          );endwhen
       );endforeach
   )
   return( return_path )
)));end-defun _CSS_BuildShapePath
 
;===================================================================
;+
;NAME:
;       _CSS_RunInit
;
;SYNOPSIS:
;        _CSS_RunInit( )
;
;Description:
;       This function calls all function required to execute the copy
;       shape commands.
;       For Further information see:
;       axlDBCreateShape
;
;-
;===================================================================
defun( _CSS_RunInit ()
        Canceled = nil
        _CSS_Form_Ptr = nil
        _CSS_Shape_DBID = nil
        when( axlOKToProceed()
                axlMsgPut("Push Shape Command")
                axlUIPopupSet( nil )
                while( _CSS_Shape_DBID == nil && Canceled == nil
                        axlUIPopupSet( _CSS_Popup_Form())
                        _CSS_Shape_DBID = _CSS_SelectShape()
                        when( _CSS_Shape_DBID == nil && Canceled == nil
                                axlMsgPut(" No Shape Selected.")
                                axlMsgPut("Select again.")
                        );endwhen
                        axlUIPopupSet( nil )
                );endwhile
                when( Canceled == nil
                _CSS_Form_Ptr = _CSS_Form_Create()
                axlFormDisplay(_CSS_Form_Ptr)
                )
        )
);
 
;===================================================================
;+
;NAME:
;       _CSS_Cancel
;
;SYNOPSIS:
;        _CSS_Cancel( )
;
;Description:
;       This function deletes  all temporary disk files ,closes the
;       form if it is open, and exits the SKILL command.
;       For Further information see:
;       axlFormClose,axlCancelEnterFun,axlMsgPut
;
;-
;===================================================================
defun( _CSS_Cancel ()
        Canceled = t
        when( _CSS_Form_Ptr != nil axlFormClose( _CSS_Form_Ptr))
        when( isFile("ex_layer_data_temp.txt") deleteFile("ex_layer_data_temp.txt"))
        when( isFile("ex_tmp_file.txt") deleteFile("ex_tmp_file.txt"))
        when( isFile("mv_shape.form") deleteFile("mv_shape.form"))
        when( isFile("extract.log") deleteFile("extract.log"))
        axlCancelEnterFun()
        axlMsgPut("Done")
)



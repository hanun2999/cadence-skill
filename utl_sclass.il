;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Title:  utl_sclass.il
;;
;;  Purpose:  To generate a list (in order or in reverse order) of a
;;		design's subclasses on the ETCH class, or any other class.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




defun( utl_getEtchSubclasses ()

   prog( (layerdbid reverseList reverse returnList layers)

      layerdbid = axlGetParam( "paramLayerGroup:ETCH" )
      reverseList = list()
      foreach( reverse layerdbid->groupMembers
         reverseList = cons( reverse reverseList )
      )

      returnList = list()
      foreach( layers reverseList
         returnList = cons( layers returnList )
      )
      return(returnList)
   ) ; end prog
) ; End of defun


defun( utl_getReverseEtchSubclasses ()

   prog( (layerdbid reverseList reverse )

      layerdbid = axlGetParam( "paramLayerGroup:ETCH" )
      reverseList = list()
      foreach( reverse layerdbid->groupMembers
         reverseList = cons( reverse reverseList )
      )

      return(reverseList)
   ) ; end prog
) ; End of defun





defun( utl_getSubclasses (class)

   prog( (layerdbid reverseList reverse returnList info layers)

      sprintf( info "paramLayerGroup:%s" upperCase(class) )
      layerdbid = axlGetParam( info )
      reverseList = list()
      foreach( reverse layerdbid->groupMembers
         reverseList = cons( reverse reverseList )
      )

      returnList = list()
      foreach( layers reverseList
         returnList = cons( layers returnList )
      )
      return(returnList)
   ) ; end prog
) ; End of defun


defun( utl_getReverseSubclasses (class)

   prog( (layerdbid reverseList reverse info )

      sprintf( info "paramLayerGroup:%s" upperCase(class) )
      layerdbid = axlGetParam( info )
      reverseList = list()
      foreach( reverse layerdbid->groupMembers
         reverseList = cons( reverse reverseList )
      )

      return(reverseList)
   ) ; end prog
) ; End of defun


defun( utl_className ( layerName )

   prog( ( class_name letter letter_list build_class_name )

        class_name = ""
        build_class_name = t
        letter_list = parseString( layerName "" )

        foreach( letter letter_list

            if( letter == "/" then
                build_class_name = nil
            )

            if( build_class_name then
                class_name = strcat( class_name letter )
            )
        )

        return( class_name )

   ) ; end prog
) ; End of defun


defun( utl_subclassName ( layerName )

   prog( ( subclass_name letter letter_list build_subclass_name )

        subclass_name = ""
        build_subclass_name = nil
        letter_list = parseString( layerName "" )

        foreach( letter letter_list

            if( build_subclass_name then
                subclass_name = strcat( subclass_name letter )
            )

            if( letter == "/" then
                build_subclass_name = t
            )
        )

        return( subclass_name )

   ) ; end prog
) ; End of defun




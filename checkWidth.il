/*****************************************************************************
*                                                                            *
* Description:  This program will flag all connect lines in a user defined   *
*               area that do not match a user defined width.                 *
*                                                                            *
*               An External DRC marker will be added to the center of the    *
*               connect lines that do not match the user specified width.    *
*               To remove the DRCs you must fix the line width and re-run    *
*               the program, or re-run the program usign a line width that   *
*               matches the existing connect line.                           *
*                                                                            *
* Execution:    Locate this file (checkWidth.il) in the directory path where *
*               all other skill routines are located. In the apd.ilinit file *
*               include the line:                                            *
*                                                                            *
*                      load("checkWidth.il")                                 *
*                                                                            *
*               To execute the command in the Allegro command window enter   *
*                                                                            *
*                      checkwidth                                            *
*                                                                            *
*****************************************************************************/
axlCmdRegister( "checkwidth" 'checkWidth)

procedure( checkWidth()
  ;This procedure will check all the cline segs in a user specified window and
  ;put a DRC on the clines that do not match the user specified width
  prog((x y drcs errors box checkWidth)

    errors = 0

    ;Have the user input the width to be checked for. The value input
    ;will be a string datatype.
    checkWidth = axlEnterString(?prompts
                      list("what width should the lines in this area be ?"))

    ;If checkWidth is nil, then the user selected cancel and the
    ;function should be ended.
    when( checkWidth==nil
      return(0)
    )

    ;Keep looping and asking the user for new input while the value
    ;of checkWidth can not be converted to a floating point number
    while( type( atof(checkWidth) ) != 'flonum

      axlMsgPut( list( "Please enter a valid width." 0))

      checkWidth = axlEnterString(?prompts
                        list("Please enter a valid width "))

      ;If checkWidth is nil, then the user seleced cancel and the function
      ;should be ended.
      when( checkWidth==nil
        return(0)
      )
    )

      checkWidth = atof( checkWidth )

    box = axlEnterBox(?prompts list("Please select the area to be checked."))
  
    ;delete the previous DRCs
    axlSetFindFilter( ?enabled list("noall" "drcs")
                      ?onButtons list("noall" "drcs"))
    axlSingleSelectBox(box)
    drcs = axlGetSelSet()
    foreach(drc drcs
      when( drc->prop->EXTERNAL_VIOLATION_DESCRIPTION ==
                                           "User defined line width"
        axlDeleteObject(drc)
      )
    )
      

    axlSetFindFilter( ?enabled list("noall" "clinesegs")
                      ?onButtons list("noall" "clinesegs"))
    axlSingleSelectBox(box)
    clinesegs = axlGetSelSet()
    foreach( clineseg clinesegs
      if( clineseg->width != checkWidth
      then
        x = (nth(0 nth(0 clineseg->startEnd)) +
             nth(0 nth(1 clineseg->startEnd)))/2
        y = (nth(1 nth(0 clineseg->startEnd)) +
             nth(1 nth(1 clineseg->startEnd)))/2

        axlDBCreateExternalDRC( "User defined line width"
                                list(x y)
                                strcat( "DRC ERROR CLASS/"
                                      nth(1 parseString(clineseg->layer "/")))
                                list(clineseg)
                                nil
                                sprintf(nil "%f" clineseg->width ))
        ;turn on the drcs for the layer
        axlVisibleLayer( strcat("DRC ERROR CLASS/" 
                         nth(1 parseString(clineseg->layer "/"))) t)
        printf("Found error at %L.\n" list(x y))
        errors++
      );if
    );foreach
    if( errors==1
    then
      printf("Found %d cline seg that was not %f wide.\n" errors 
                                                         checkWidth*1.0)
    else
      printf("Found %d cline segs that were not %f wide.\n" errors 
                                                          checkWidth*1.0)
    )
  );let
);procedure
         

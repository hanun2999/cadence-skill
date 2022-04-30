axlCmdRegister("display" 'Display)

procedure(Display()
        let((Displayfile myform)
                Displayfile = axlTempFile()
                myform = outfile(Displayfile "w")
                fprintf(myform "#Created by xml2bnf  perl utility\n")
                fprintf(myform "#Coded by Venkata Ramanan/Santa Clara, CA\n\n")
                fprintf(myform "FILE_TYPE=FORM_DEFN VERSION=2\n")
                fprintf(myform "FORM AUTOGREYTEXT\n")
                fprintf(myform "FIXED\n")
                fprintf(myform "PORT 23 22\n")
                fprintf(myform "HEADER \"ZZ tools\"\n\n")
                fprintf(myform "POPUP <ENUM>\"ITEM1\"\"0\",\"ITEM2\"\"1\",\"ITEM3\"\"2\",\"LAST ONE\"\"3\".\n\n")
                fprintf(myform "TILE\n\n")
                fprintf(myform "## Text Field in Form## \n")
                fprintf(myform "TEXT \"SilkTop\"\n")
                fprintf(myform "FLOC 1 1\n")
                fprintf(myform "TGROUP \"PBTop\"\n")
                fprintf(myform "ENDTEXT\n\n")
                fprintf(myform "## Button Field in FORM ## \n")
                fprintf(myform "FIELD SilkTopOn\n")
                fprintf(myform "FLOC 8 1\n")
                fprintf(myform "MENUBUTTON \"On\" 5 3\n")
                fprintf(myform "FGROUP \"PBTop\"\n")
                fprintf(myform "ENDFIELD \n\n")
                fprintf(myform "## Button Field in FORM ## \n")
                fprintf(myform "FIELD SilkTopOff\n")
                fprintf(myform "FLOC 15 1\n")
                fprintf(myform "MENUBUTTON \"Off\" 5 3\n")
                fprintf(myform "FGROUP \"PBTop\"\n")
                fprintf(myform "ENDFIELD \n\n")
                fprintf(myform "## Text Field in Form## \n")
                fprintf(myform "TEXT \"SilkBot\"\n")
                fprintf(myform "FLOC 1 3\n")
                fprintf(myform "TGROUP \"PBTop\"\n")
                fprintf(myform "ENDTEXT\n\n")
                fprintf(myform "## Button Field in FORM ## \n")
                fprintf(myform "FIELD SilkBotOn\n")
                fprintf(myform "FLOC 8 3\n")
                fprintf(myform "MENUBUTTON \"On\" 5 3\n")
                fprintf(myform "FGROUP \"PBTop\"\n")
                fprintf(myform "ENDFIELD \n\n")
                fprintf(myform "## Button Field in FORM ## \n")
                fprintf(myform "FIELD SilkBotOff\n")
                fprintf(myform "FLOC 15 3\n")
                fprintf(myform "MENUBUTTON \"Off\" 5 3\n")
                fprintf(myform "FGROUP \"PBTop\"\n")
                fprintf(myform "ENDFIELD \n\n")
                fprintf(myform "## Text Field in Form## \n")
                fprintf(myform "TEXT \"SoldTop\"\n")
                fprintf(myform "FLOC 1 5\n")
                fprintf(myform "TGROUP \"PBTop\"\n")
                fprintf(myform "ENDTEXT\n\n")
                fprintf(myform "## Button Field in FORM ## \n")
                fprintf(myform "FIELD SoldTopOn\n")
                fprintf(myform "FLOC 8 5\n")
                fprintf(myform "MENUBUTTON \"On\" 5 3\n")
                fprintf(myform "FGROUP \"PBTop\"\n")
                fprintf(myform "ENDFIELD \n\n")
                fprintf(myform "## Button Field in FORM ## \n")
                fprintf(myform "FIELD SoldTopOff\n")
                fprintf(myform "FLOC 15 5\n")
                fprintf(myform "MENUBUTTON \"Off\" 5 3\n")
                fprintf(myform "FGROUP \"PBTop\"\n")
                fprintf(myform "ENDFIELD \n\n")
                fprintf(myform "## Text Field in Form## \n")
                fprintf(myform "TEXT \"SoldBot\"\n")
                fprintf(myform "FLOC 1 7\n")
                fprintf(myform "TGROUP \"PBTop\"\n")
                fprintf(myform "ENDTEXT\n\n")
                fprintf(myform "## Button Field in FORM ## \n")
                fprintf(myform "FIELD SoldBotOn\n")
                fprintf(myform "FLOC 8 7\n")
                fprintf(myform "MENUBUTTON \"On\" 5 3\n")
                fprintf(myform "FGROUP \"PBTop\"\n")
                fprintf(myform "ENDFIELD \n\n")
                fprintf(myform "## Button Field in FORM ## \n")
                fprintf(myform "FIELD SoldBotOff\n")
                fprintf(myform "FLOC 15 7\n")
                fprintf(myform "MENUBUTTON \"Off\" 5 3\n")
                fprintf(myform "FGROUP \"PBTop\"\n")
                fprintf(myform "ENDFIELD \n\n")
                fprintf(myform "## Text Field in Form## \n")
                fprintf(myform "TEXT \"PBTop\"\n")
                fprintf(myform "FLOC 1 9\n")
                fprintf(myform "TGROUP \"PBTop\"\n")
                fprintf(myform "ENDTEXT\n\n")
                fprintf(myform "## Button Field in FORM ## \n")
                fprintf(myform "FIELD PBTopOn\n")
                fprintf(myform "FLOC 8 9\n")
                fprintf(myform "MENUBUTTON \"On\" 5 3\n")
                fprintf(myform "FGROUP \"PBTop\"\n")
                fprintf(myform "ENDFIELD \n\n")
                fprintf(myform "## Button Field in FORM ## \n")
                fprintf(myform "FIELD PBTopOff\n")
                fprintf(myform "FLOC 15 9\n")
                fprintf(myform "MENUBUTTON \"Off\" 5 3\n")
                fprintf(myform "FGROUP \"PBTop\"\n")
                fprintf(myform "ENDFIELD \n\n")
                fprintf(myform "## Text Field in Form## \n")
                fprintf(myform "TEXT \"PBBot\"\n")
                fprintf(myform "FLOC 1 11\n")
                fprintf(myform "TGROUP \"PBTop\"\n")
                fprintf(myform "ENDTEXT\n\n")
                fprintf(myform "## Button Field in FORM ## \n")
                fprintf(myform "FIELD PBBotOn\n")
                fprintf(myform "FLOC 8 11\n")
                fprintf(myform "MENUBUTTON \"On\" 5 3\n")
                fprintf(myform "FGROUP \"PBTop\"\n")
                fprintf(myform "ENDFIELD \n\n")
                fprintf(myform "## Button Field in FORM ## \n")
                fprintf(myform "FIELD PBBotOff\n")
                fprintf(myform "FLOC 15 11\n")
                fprintf(myform "MENUBUTTON \"Off\" 5 3\n")
                fprintf(myform "FGROUP \"PBTop\"\n")
                fprintf(myform "ENDFIELD \n\n")
                fprintf(myform "## Text Field in Form## \n")
                fprintf(myform "TEXT \"Ref DES\"\n")
                fprintf(myform "FLOC 1 13\n")
                fprintf(myform "TGROUP \"PBTop\"\n")
                fprintf(myform "ENDTEXT\n\n")
                fprintf(myform "## Button Field in FORM ## \n")
                fprintf(myform "FIELD RTop\n")
                fprintf(myform "FLOC 8 13\n")
                fprintf(myform "MENUBUTTON \"RTop\" 5 3\n")
                fprintf(myform "FGROUP \"PBTop\"\n")
                fprintf(myform "ENDFIELD \n\n")
                fprintf(myform "## Button Field in FORM ## \n")
                fprintf(myform "FIELD RBot\n")
                fprintf(myform "FLOC 15 13\n")
                fprintf(myform "MENUBUTTON \"RBot\" 5 3\n")
                fprintf(myform "FGROUP \"PBTop\"\n")
                fprintf(myform "ENDFIELD \n\n")
                fprintf(myform "## Text Field in Form## \n")
                fprintf(myform "TEXT \"Other\"\n")
                fprintf(myform "FLOC 1 15\n")
                fprintf(myform "TGROUP \"PBTop\"\n")
                fprintf(myform "ENDTEXT\n\n")
                fprintf(myform "## Button Field in FORM ## \n")
                fprintf(myform "FIELD CGOn\n")
                fprintf(myform "FLOC 8 15\n")
                fprintf(myform "MENUBUTTON \"CGOn\" 5 3\n")
                fprintf(myform "FGROUP \"PBTop\"\n")
                fprintf(myform "ENDFIELD \n\n")
                fprintf(myform "## Button Field in FORM ## \n")
                fprintf(myform "FIELD CAll\n")
                fprintf(myform "FLOC 15 15\n")
                fprintf(myform "MENUBUTTON \"CAll\" 5 3\n")
                fprintf(myform "FGROUP \"PBTop\"\n")
                fprintf(myform "ENDFIELD \n\n")
                fprintf(myform "ENDTILE\n\n")
                fprintf(myform "ENDFORM\n\n")
                close(myform)
                
            myform = axlFormCreate(gensym() Displayfile '("NE" "msglines" 0) 'DisplayAction t nil)
            axlFormDisplay(myform)
            axlFormSetField(myform "sub_menuclass" 1)
                when(isFile(Displayfile)
                        deleteFile(Displayfile)
                )
        )
)


procedure(DisplayAction(myform)
let(n( )
        case(myform->curField
                ("SilkTopOn"
                            axlVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_TOP" t)
                            axlVisibleLayer("BOARD GEOMETRY/SILKSCREEN_TOP" t)
                                axlVisibleUpdate(t)
                ;Button Field 
                ;Enter Action Here
                
                )
                ("SilkTopOff"
                            axlVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_TOP" nil)
                            axlVisibleLayer("BOARD GEOMETRY/SILKSCREEN_TOP" nil)
                                axlVisibleUpdate(nil)
                ;Button Field 
                ;Enter Action Here
                
                )
                ("SilkBotOn"
                                axlVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" t)
                            axlVisibleLayer("BOARD GEOMETRY/SILKSCREEN_BOTTOM" t)
                                axlVisibleUpdate(t)
                ;Button Field 
                ;Enter Action Here
                
                )
                ("SilkBotOff"
                                axlVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" nil)
                            axlVisibleLayer("BOARD GEOMETRY/SILKSCREEN_BOTTOM" nil)
                                axlVisibleUpdate(nil)
                ;Button Field 
                ;Enter Action Here
                
                )
                ("SoldTopOn"
                                axlVisibleLayer("PACKAGE GEOMETRY/SOLDERMASK_TOP" t)
                            axlVisibleLayer("BOARD GEOMETRY/SOLDERMASK_TOP" t)
                                axlVisibleUpdate(t)
                ;Button Field 
                ;Enter Action Here
                
                )
                ("SoldTopOff"
                                axlVisibleLayer("PACKAGE GEOMETRY/SOLDERMASK_TOP" nil)
                            axlVisibleLayer("BOARD GEOMETRY/SOLDERMASK_TOP" nil)
                                axlVisibleUpdate(nil)
                ;Button Field 
                ;Enter Action Here
                
                )
                ("SoldBotOn"
                                axlVisibleLayer("PACKAGE GEOMETRY/SOLDERMASK_BOTTOM" t)
                            axlVisibleLayer("BOARD GEOMETRY/SOLDERMASK_BOTTOM" t)
                                axlVisibleUpdate(t)
                ;Button Field 
                ;Enter Action Here
                
                )
                ("SoldBotOff"
                                axlVisibleLayer("PACKAGE GEOMETRY/SOLDERMASK_BOTTOM" nil)
                            axlVisibleLayer("BOARD GEOMETRY/SOLDERMASK_BOTTOM" nil)
                                axlVisibleUpdate(nil)
                ;Button Field 
                ;Enter Action Here
                
                )
                ("PBTopOn"
                                axlVisibleLayer("PACKAGE GEOMETRY/PLACE_BOUND_TOP" t)
                            axlVisibleLayer("BOARD GEOMETRY/PLACE_BOUND_TOP" t)
                                axlVisibleUpdate(t)
                ;Button Field 
                ;Enter Action Here
                
                )
                ("PBTopOff"
                                axlVisibleLayer("PACKAGE GEOMETRY/PLACE_BOUND_TOP" nil)
                            axlVisibleLayer("BOARD GEOMETRY/PLACE_BOUND_TOP" nil)
                                axlVisibleUpdate(nil)
                ;Button Field 
                ;Enter Action Here
                
                )
                ("PBBotOn"
                                axlVisibleLayer("PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM" t)
                            axlVisibleLayer("BOARD GEOMETRY/PLACE_BOUND_BOTTOM" t)
                                axlVisibleUpdate(t)
                ;Button Field 
                ;Enter Action Here
                
                )
                ("PBBotOff"
                                axlVisibleLayer("PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM" nil)
                            axlVisibleLayer("BOARD GEOMETRY/PLACE_BOUND_BOTTOM" nil)
                                axlVisibleUpdate(nil)
                ;Button Field 
                ;Enter Action Here
                
                )
                ("RTop"
                            axlVisibleDesign(nil)
                            axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t)
                            axlVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_TOP" t)
                            axlVisibleLayer("BOARD GEOMETRY/SILKSCREEN_TOP" t)
                            axlVisibleLayer("REF DES/SILKSCREEN_TOP" t)
                            axlVisibleLayer("PIN/TOP" t)
                                axlVisibleUpdate(t)
                ;Button Field 
                ;Enter Action Here
                
                )
                ("RBot"
                            axlVisibleDesign(nil)
                            axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t)
                            axlVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" t)
                            axlVisibleLayer("BOARD GEOMETRY/SILKSCREEN_BOTTOM" t)
                            axlVisibleLayer("REF DES/SILKSCREEN_BOTTOM" t)
                            axlVisibleLayer("PIN/BOTTOM" t)
                                axlVisibleUpdate(t)
                ;Button Field 
                ;Enter Action Here
                
                )
                ("CGOn"
                                axlVisibleLayer("CONSTRAINT REGION/ALL" t)
                                axlVisibleUpdate(t)
                ;Button Field 
                ;Enter Action Here
                
                )
                ("CAll"
                            axlVisibleDesign(nil)        
                                axlVisibleUpdate(nil)
                ;Button Field 
                ;Enter Action Here
                
                )
        )
                )

;if((nequal myform->doneState 1)
;axlFormClose(myform)

        
)

; SKILL file rep_ucshape.il
;
;	This file will look at the current database to find any shapes
;	that unconnected and have no net name associated with them.
;

axlCmdRegister( "uc shape" 'uc_shape)
procedure( uc_shape()
	logfile="./uncon_shapes.log"
	axlClearSelSet()
	axlSetFindFilter(?enabled '(noall shapes) ?onButtons '(noall shapes))
	axlAddSelectAll()
	rep_file=outfile(logfile)
	fprintf(rep_file "\tUnconnected Shape Report\n\nLocation\t\t\tLayer\n\n")
	l_shapes=axlGetSelSet()
	axlClearSelSet()
	foreach( shape l_shapes
		i=0
		if( shape->net!=nil	;only get etch shapes
		  then
			if( shape->net->name==""	;get unconnected shapes
			  then
			  location=car(shape->bBox)
	      layer=shape->layer
	      fprintf(rep_file "%L\t\t%s\n" location,layer)
				if(layer="BOUNDARY/TOP"||"BOUNDARY/BOTTOM"
					 then
					 ++i
					 l_shapes=cons(shape l_shapes)
					 axlMsgPut("There are %d unfilled shapes ." i)
					
				  ); end if layer  
					 
			);endif
		);endif
	);endfor
	close(rep_file)
	axlUIViewFileCreate(logfile "Unconnected Shapes Log" nil)
);end defun
;write by deargds
axlShell("alias Up 'skill x_up'")
axlShell("alias Down 'skill x_down'")
axlShell("alias Left 'skill x_left'")
axlShell("alias Right 'skill x_right'")
axlShell("alias set move grid 'skill set_x_move_screen_step'")
x_move_screen_step = 1

defun( set_x_move_screen_step ()
prog(()
let(( gp gpv)
	gp = axlUIPrompt("Please input screen move grid:")
	when( gp == nil return(nil))
	gpv = atof(gp)
	if( gpv != nil then
		x_move_screen_step = gpv
	else
		x_move_screen_step = 1
	)
)))

defun( x_up ()
let((x y box)
x = 0
y = x_move_screen_step
box = axlWindowBoxGet()
axlWindowBoxSet(list(list(xCoord(lowerLeft(box)) + x yCoord(lowerLeft(box)) + y) list( xCoord(upperRight(box)) + x yCoord(upperRight(box)) + y)))
))

defun( x_down ()
let((x y box)
x = 0
y = minus(x_move_screen_step)
box = axlWindowBoxGet()
axlWindowBoxSet(list(list(xCoord(lowerLeft(box)) + x yCoord(lowerLeft(box)) + y) list( xCoord(upperRight(box)) + x yCoord(upperRight(box)) + y)))
))

defun( x_left ()
let((x y box)
x = minus(x_move_screen_step)
y = 0
box = axlWindowBoxGet()
axlWindowBoxSet(list(list(xCoord(lowerLeft(box)) + x yCoord(lowerLeft(box)) + y) list( xCoord(upperRight(box)) + x yCoord(upperRight(box)) + y)))
))

defun( x_right ()
let((x y box)
x = x_move_screen_step
y = 0
box = axlWindowBoxGet()
axlWindowBoxSet(list(list(xCoord(lowerLeft(box)) + x yCoord(lowerLeft(box)) + y) list( xCoord(upperRight(box)) + x yCoord(upperRight(box)) + y)))
))
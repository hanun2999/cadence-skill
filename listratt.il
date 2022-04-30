/* This is an example of how to lists all RatT locations. 

################################################################################
#                                                                              #
#                      Command: listratt                                       #
#                   Skill File: listratt.il                                    #
#                  How To Load: Command> (load("listratt.il"))                 #
#               How To Execute: Command> listratt                              #
#                                                                              #
#                                                                              #
#                       Author: Larry Bowman, Cadence Design Systems           #
#                        Email: bowman@cadence.com                             #
#                    Telephone: 512-349-1109                                   #
#                Creation Date: 2/19/2003                                      #
#                                                                              #
#                                                                              #
#      This program will generate a list of all Rat T names,                   #
#      Rat T X-Y locations and their associated net names.                     #
#                                                                              #
################################################################################



################################################################################
#  DISCLAIMER:                                                                 #
#       The user of this command assumes all responsibility and does not       #
#       hold Cadence Design Systems nor the author of this code for any        #
#       unwarranted results or problems due to the use of this code.           #
#                                                                              #
#       This is non-supported code and the user may modify it as needed.       #
#                                                                              #
################################################################################
*/


axlCmdRegister("listratt" 'LCB_list_ratt)

defun(LCB_list_ratt ()

root = axlDBGetDesign()
lnets = root->nets
ratt_nets = setof(net lnets net->ratT != nil)
if(ratt_nets then
  foreach(net ratt_nets
     netname = net->name
     foreach(netratt net->ratT
       axlUIWPrint(nil "Found RatT %s at location %L for net %s"  netratt->name netratt->xy netname)
     ); end foreach
  ); end foreach
else
 axlUIWPrint(nil "** No RatT's Found. **")
); endif

); end defun
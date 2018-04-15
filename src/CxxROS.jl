# $Id: CxxROS.jl,v 1.2 2018/04/15 01:14:26 manabu Exp manabu $

module CxxROS

export RosTime
export std_msgs, sensor_msgs, geometry_msgs, nav_msgs

using Cxx

const path_to_ros = "/opt/ros/lunar/"
addHeaderDir(path_to_ros * "include", kind=C_System)

cxx"""
#include <ros/ros.h>
"""

# importing objects...

Libdl.dlopen(path_to_ros * "lib/libroscpp.so", Libdl.RTLD_GLOBAL)
# BaseTime: Time, Duration, WallTime, WallTimeDuration,...
include("time.jl")

# importing datatypes...

include("msgs/std_msgs.jl")
include("msgs/geometry_msgs.jl")
include("msgs/sensor_msgs.jl")
include("msgs/nav_msgs.jl")

include("tf.jl")

end #module

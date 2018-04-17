module CxxROS

using Cxx
include("std.jl")

try
    global const path_to_ros = normpath(joinpath(ENV["ROS_ROOT"], "../.."))
    isdir(path_to_ros)
catch
    throw(ErrorException("please set environment variavle: ROS_ROOT"))
end

addHeaderDir(path_to_ros * "include", kind=C_System)

cxx"""
#include <ros/ros.h>
"""
include("boost.jl")

# importing objects...

Libdl.dlopen(path_to_ros * "lib/libroscpp.so", Libdl.RTLD_GLOBAL)

include("time.jl")

# importing datatypes...

include("msgs/std_msgs.jl")
include("msgs/geometry_msgs.jl")
include("msgs/sensor_msgs.jl")
include("msgs/nav_msgs.jl")

include("tf.jl")

end #module

# no show interface for elements of boost::array cause exception
function Base.show(io::IO, ptr::Cxx.CppRef{Cxx.CxxArrayType{T},Cxx.NullCVR}) where T
    println(io, "Array<", Base.typename(T), ",1>")
end

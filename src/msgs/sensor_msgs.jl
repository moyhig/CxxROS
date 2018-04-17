module sensor_msgs

using Cxx
using CxxStd: StdString, StdVector

cxx"""
    #include <sensor_msgs/Imu.h>
    #include <sensor_msgs/LaserScan.h>
    """

for dtype in [ :Imu, :LaserScan ]
    cppname = string("sensor_msgs::", dtype)
    cxxtval = Expr(:macrocall, Symbol("@cxxt_str"), cppname)
    symtval = Symbol(dtype, :Msg)

    @eval global const $(symtval) = $(cxxtval)

    cxxcstr = Expr(:macrocall, Symbol("@icxx_str"), string(cppname, "();"))
    @eval (::Type{$(symtval)})() = $(cxxcstr)
end

end #module

eval(sensor_msgs, :(Imu	      = ImuMsg))
eval(sensor_msgs, :(LaserScan = LaserScanMsg))

export sensor_msgs

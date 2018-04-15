# $Id: sensor_msgs.jl,v 1.2 2018/04/15 01:15:30 manabu Exp manabu $

module sensor_msgs

using Cxx
using CxxStd: StdString, StdVector

cxx"""
    #include <sensor_msgs/Imu.h>
    #include <sensor_msgs/LaserScan.h>
    """

for dtype in [ :Imu, :LaserScan ]
    cppname  = string("sensor_msgs::", dtype)
    cxxtdef  = Expr(:macrocall, Symbol("@cxxt_str"), cppname)
    symname  = Symbol(dtype, :Msg)
    @eval global const $(symname) = $(cxxtdef)
    body = Expr(:macrocall, Symbol("@icxx_str"), string(cppname, "();"))
    @eval (::Type{$(symname)})() = $(body)
end

# no show interface for elements of boost::array cause exception
function Base.show(io::IO, ptr::Cxx.CppRef{Cxx.CxxArrayType{T},Cxx.NullCVR}) where T
    println(io, "Array<", Base.typename(T), ",1>")
end

end #module

eval(sensor_msgs, :(Imu	      = ImuMsg))
eval(sensor_msgs, :(LaserScan = LaserScanMsg))

module geometry_msgs

using Cxx
using CxxStd: WrappedCppPrimArray

cxx"""
#include <geometry_msgs/Vector3.h>
#include <geometry_msgs/Point.h>
#include <geometry_msgs/Quaternion.h>
"""

TVals = Union{}
TRefs = Union{}
#TPtrs = Union{}

for dtype in [ :Vector3, :Point, :Quaternion ]
    cppname  = string("geometry_msgs::", dtype)
    cxxtval  = Expr(:macrocall, Symbol("@cxxt_str"), cppname)
    cxxtref  = Expr(:macrocall, Symbol("@cxxt_str"), string(cppname, "&"))
    #cxxtptr  = @eval cpptptr($(cxxtval))
    symtval  = Symbol(dtype, :Msg)
    symtref  = Symbol(dtype, :Msg, :R)
    symtall  = Symbol(dtype, :Msg, :U)

    @eval begin
        global const $(symtval) = $(cxxtval)
        global const $(symtref) = $(cxxtref)
        global const $(symtall) = Union{$(cxxtval), $(cxxtref)}
        #export $(symtval), $(symtref), $(symtall)
    end

    TVals = Union{TVals, @eval $(symtval)}
    TRefs = Union{TRefs, @eval $(symtref)}
    #TPtrs = Union{TPtrs, @eval $(symtptr)}

    body = Expr(:macrocall, Symbol("@icxx_str"), string(cppname, "();"))
    @eval (::Type{$(symtval)})() = $(body)

    #body = Expr(:macrocall, Symbol("@icxx_str"), string("(", cppname, "&) \$v;"))
    #@eval Base.convert(::Type{$(cxxtref)}, v::$(cxxtval)) = $(body)
end

function Base.convert(::Type{CT}, v::T) where {CT<:AbstractArray,T<:Union{TVals,TRefs}}
    convert(CT, unsafe_wrap(DenseArray, v))
end

function Base.unsafe_wrap(::Type{DenseArray}, v::T) where {T<:Union{TVals,TRefs}}
    if typeof(icxx"$v;") <: QuaternionMsgU
        WrappedCppPrimArray(icxx"&($v.x);",4)
    else
        WrappedCppPrimArray(icxx"&($v.x);",3)
    end
end

#function Base.unsafe_wrap(::Type{DenseArray}, v::T) where {T<:TPtrs}
#    if typeof(icxx"*$v;") <: QuaternionMsg
#        WrappedCppPrimArray(icxx"&($v->x);",4)
#    else
#        WrappedCppPrimArray(icxx"&($v->x);",3)
#    end
#end

end #module

eval(geometry_msgs, :(Vector3     = Vector3Msg))
eval(geometry_msgs, :(Vector3R    = Vector3MsgR))
eval(geometry_msgs, :(Vector3U    = Vector3MsgU))
eval(geometry_msgs, :(Quaternion  = QuaternionMsg))
eval(geometry_msgs, :(QuaternionR = QuaternionMsgR))
eval(geometry_msgs, :(QuaternionU = QuaternionMsgU))

export geometry_msgs

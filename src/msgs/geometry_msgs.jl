# $Id: geometry_msgs.jl,v 1.2 2018/04/15 01:14:48 manabu Exp manabu $

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
TPtrs = Union{}

for dtype in [ :Vector3, :Point, :Quaternion ]
    cppname  = string("geometry_msgs::", dtype)
    cxxtval  = Expr(:macrocall, Symbol("@cxxt_str"), cppname)
    cxxtref  = Expr(:macrocall, Symbol("@cxxt_str"), string(cppname, "&"))
    #cxxtptr  = @eval cpptptr($(cxxtval))
    symname  = Symbol(dtype, :Msg)
    #@eval global const $(symname) = $(cxxtval)
    @eval global const $(symname) = Union{$(cxxtval),$(cxxtref)}

    TVals = Union{TVals, @eval $(cxxtval)}
    TRefs = Union{TRefs, @eval $(cxxtref)}
    #TPtrs = Union{TPtrs, @eval $(cxxtptr)}

    body = Expr(:macrocall, Symbol("@icxx_str"), string(cppname, "();"))
    #@eval (::Type{T})() where {T<:$(symname)} = $(body)
    @eval (::Type{$(symname)})() = $(body)
end


function Base.unsafe_wrap(::Type{DenseArray}, v::T) where {T<:TRefs}
    if typeof(icxx"$v;") <: QuaternionMsg
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

function Base.convert(::Type{CT}, v::T) where {CT<:AbstractArray,T<:TRefs}
    convert(CT, unsafe_wrap(DenseArray, v))
end

end #module

eval(geometry_msgs, :(Vector3    = Vector3Msg))
eval(geometry_msgs, :(Quaternion = QuaternionMsg))

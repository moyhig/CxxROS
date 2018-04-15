# $Id: std_msgs.jl,v 1.2 2018/04/15 01:15:43 manabu Exp manabu $

module std_msgs

# importing RosTime
using ..CxxROS

using Cxx
using CxxStd: StdString

cxx"""
#include <std_msgs/String.h>
#include <std_msgs/Time.h>
"""

for dtype in [ :String, :Time ]
    cppname  = string("std_msgs::", dtype)
    cxxtdef  = Expr(:macrocall, Symbol("@cxxt_str"), cppname)
    symname  = Symbol(dtype, :Msg)
    @eval global const $(symname) = $(cxxtdef)
    body = Expr(:macrocall, Symbol("@icxx_str"), string(cppname, "();"))
    @eval (::Type{$(symname)})() = $(body)
end

const StdData = Union{String, StdString, RosTime}
const StdMsgs = Union{StringMsg, TimeMsg}

function Base.convert(::Type{S}, msg::T) where {S<:StdData,T<:StdMsgs}
    S(icxx"$msg.data;")
end

function Base.convert(::Type{T}, data::S) where {S<:StdData,T<:StdMsgs}
    msg = T()
    icxx"$msg.data = $data;"
    msg
end

end #module

eval(std_msgs, :(String = StringMsg))
eval(std_msgs, :(Time	= TimeMsg))

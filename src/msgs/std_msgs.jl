module std_msgs

# importing RosTime
using ..CxxROS

using Cxx
using CxxStd: StdString

cxx"""
#include <std_msgs/String.h>
#include <std_msgs/Time.h>
"""

TVals = Union{}

for dtype in [ :String, :Time ]
    cppname = string("std_msgs::", dtype)
    cxxtval = Expr(:macrocall, Symbol("@cxxt_str"), cppname)
    symtval = Symbol(dtype, :Msg)

    @eval global const $(symtval) = $(cxxtval)
    @eval TVals = Union{TVals, $(symtval)}

    cxxcstr = Expr(:macrocall, Symbol("@icxx_str"), string(cppname, "();"))
    @eval (::Type{$(symtval)})() = $(cxxcstr)
end

const StdData = Union{String, StdString, RosTime}
const StdMsgs = TVals
#const StdMsgs = Union{StringMsg, TimeMsg}

Base.convert(::Type{S}, msg::StdMsgs) where {S<:StdData} = S(icxx"$msg.data;")

function Base.convert(::Type{T}, data::StdData) where {T<:StdMsgs}
    msg = T()
    icxx"$msg.data = $data;"
    msg
end

end #module

eval(std_msgs, :(String = StringMsg))
eval(std_msgs, :(Time	= TimeMsg))
export std_msgs

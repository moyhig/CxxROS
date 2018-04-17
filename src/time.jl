using Cxx
using TimeZones

for dtype in [ :Time, :Duration, :Rate ]
    cppname = string("ros::", dtype)
    cxxtval = Expr(:macrocall, Symbol("@cxxt_str"), cppname)
    cxxtref = Expr(:macrocall, Symbol("@cxxt_str"), string(cppname, "&"))
    symtval = Symbol(string("Ros", dtype))
    symtref = Symbol(string("Ros", dtype, "R"))
    symtall = Symbol(string("Ros", dtype, "U"))

    @eval begin
        global const $(symtval) = $(cxxtval)
        global const $(symtref) = $(cxxtref)
        global const $(symtall) = Union{$(cxxtval), $(cxxtref)}
        export $(symtval), $(symtref) #, $(symtall)
    end

    cxxcstr = Expr(:macrocall, Symbol("@icxx_str"), string(cppname, "((double) \$t);"))
    @eval Base.convert(::Type{$(symtval)}, t::Float64) = $(cxxcstr)
end

function Base.convert(::Type{ZonedDateTime}, rt::RosTimeU)
    dt = Dates.unix2datetime(icxx"(long)($rt.toSec());")
    astimezone(ZonedDateTime(dt, tz"UTC"), localzone())
end

Base.get(rt::RosTimeU)::Float64              = icxx"$rt.toSec();"
     set(rt::RosTimeU, t::Float64)::RosTimeU = icxx"$rt.fromSec((double) $t);"

# wrapper for ros::spin, ros::spinOnce

mutable struct RosSpin
    should_continue::Bool
    task::Any
    rate::RosRate
    RosSpin()        = new(false, nothing, (@cxx ros::Rate(1)))
    RosSpin(r::Real) = new(false, nothing, (@cxx ros::Rate(r)))
end

function spin(s::RosSpin)
    while s.should_continue
        # println("RosSpin: ", s.should_continue)
        @cxx ros::spinOnce()
        try
            sleep(.001)
        catch ex
            if isa(ex, ErrorException)
                println("got exception: ", ex.msg)
                s.should_continue = false
                break
            end
        end
        @cxx s.rate->sleep()
    end
end

function Base.start(s::RosSpin)
    s.should_continue = true
    s.task = @async spin(s)
end

function stop(s::RosSpin)
    s.should_continue = false
    #println("RosSpin: ", s.should_continue)
end

export RosSpin, stop, set

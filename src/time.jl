# $Id: time.jl,v 1.2 2018/04/15 12:37:38 manabu Exp manabu $

using Cxx

# ros::Time

const RosTime = Union{cxxt"ros::Time",cxxt"ros::Time&"}

function Base.convert(::Type{RosTime}, ut::Float64)
    rt = icxx"$RosTime();"
    ut0, ut1 = Int32(trunc(ut)), Int32(trunc((ut - trunc(ut)) * 1000000000))
    icxx"$rt.sec = $ut0; $rt.nsec = $ut1;"
    rt
end

function Base.convert(::Type{Int64}, rt::RosTime)
    # (Dates.value(Dates.unix2datetime(0))
    #  - Dates.value(Dates.epochms2datetime(0)))
    # = 62167219200000
    icxx"(long)($rt.toSec()*1000.);" + 62167219200000
end

function Base.convert(::Type{RosTime}, t::DateTime)
    rt = icxx"$RosTime();"
    ut = Base.Dates.datetime2unix(t)
    ut0, ut1 = Int32(trunc(ut)), Int32(trunc((ut - trunc(ut)) * 1000000000))
    icxx"$rt.sec = $ut0; $rt.nsec = $ut1;"
    rt
end

# ros::Rate and ros::spin, ros::spinOnce
export RosRate, RosSpin, stop

const RosRate = Union{cxxt"ros::Rate", cxxt"ros::Rate&"}

mutable struct RosSpin
    should_continue::Bool
    task::Any
    rate::RosRate
    RosSpin()        = new(false, nothing, (@cxx ros::Rate(1)))
    RosSpin(r::Real) = new(false, nothing, (@cxx ros::Rate(r)))
end

function spin(s::RosSpin)
    while s.should_continue
        println("HELO: ", s.should_continue)
        @cxx ros::spinOnce()
        try
            sleep(.001)
        catch ex
            if isa(ex, ErrorException)
                println("exception: ", ex.msg)
                #s.should_continue = false
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
    #println("HELO: ", s.should_continue)
end

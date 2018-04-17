using Cxx
using CxxStd: WrappedCppPrimArray

cxx"""
#include <tf/transform_datatypes.h>
"""

const tfVector3    = Union{cxxt"tf::Vector3",    cxxt"tf::Vector3&"}
const tfQuaternion = Union{cxxt"tf::Quaternion", cxxt"tf::Quaternion&"}
const tfMatrix3x3  = Union{cxxt"tf::Matrix3x3",  cxxt"tf::Matrix3x3&"}

function Base.unsafe_wrap(::Type{DenseArray}, v::T) where {T<:tfVector3}
    WrappedCppPrimArray(icxx"&$v[0];",3)
end

function Base.unsafe_wrap(::Type{DenseArray}, q::T) where {T<:tfQuaternion}
    WrappedCppPrimArray(icxx"&$q[0];",4)
end

function Base.convert(::Type{CT}, v::T) where {CT<:AbstractArray,T<:Union{tfVector3, tfQuaternion}}
    convert(CT, unsafe_wrap(DenseArray, v))
end

function Base.convert(::Type{CT}, m::T) where {CT<:AbstractArray, T<:tfMatrix3x3}
    [DenseArray(icxx"$m[0];"), DenseArray(icxx"$m[1];"), DenseArray(icxx"$m[2];")]
end

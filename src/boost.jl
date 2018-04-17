using Cxx

const BoostSharedPtr{T}  = cxxt"boost::shared_ptr<$T>"
const BoostSharedPtrR{T} = cxxt"boost::shared_ptr<$T>&"

function (::Type{BoostSharedPtr{T}})() where T
    icxx"$(BoostSharedPtr{T})();"
end

function make_shared(ptr::BoostSharedPtr{T}) where T
    icxx"$ptr = boost::make_shared<$T>();"
    ptr
end

set(ptr0::BoostSharedPtr{T}, ptr1::BoostSharedPtr{T}) where T = icxx"$ptr0 = $ptr1;"
Base.get(ptr::BoostSharedPtr{T}) where T = icxx"$ptr.get();"

use_count(ptr::BoostSharedPtr) = icxx"$ptr.use_count();"
Base.reset(ptr) = icxx"$ptr.reset();"

export BoostSharedPtr, make_shared, set, use_count

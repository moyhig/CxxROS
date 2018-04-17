const StdVector{T}  = cxxt"std::vector<$T>"
const StdVectorR{T} = cxxt"std::vector<$T>&"

function Base.convert(::Type{cxxt"std::vector<$T>&"}, v::cxxt"std::vector<$T>") where T
    icxx"(std::vector<$T>&) $v;"
end

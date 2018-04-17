# replace CxxStd.StdVector{T} of union to separate contents

const StdVector{T}  = cxxt"std::vector<$T>"
const StdVectorR{T} = cxxt"std::vector<$T>&"

Base.convert(::Type{StdVectorR{T}}, v::StdVector{T}) where T = icxx"(std::vector<$T>&) $v;"
#Base.convert(::Type{StdVectorR{T}}, v::StdVector{T}) where T = icxx"($(StdVectorR{T})) $v;"

#function Base.convert(::Type{cxxt"std::vector<$T>&"}, v::cxxt"std::vector<$T>") where T
#    icxx"(std::vector<$T>&) $v;"
#end

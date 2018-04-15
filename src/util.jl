# $Id: util.jl,v 1.1 2018/04/15 00:59:35 manabu Exp manabu $

function dereference(t::Any)
    t <: Cxx.CppRef ? Cxx.CppValue{Cxx.CxxQualType{(t.parameters[1]),Cxx.NullCVR},N} where N : t
end

function reference(t::Any)
    if typeof(t) == UnionAll
        t0 = t.body
    else
        t0 = t
    end
    t0 <: Cxx.CppValue ? Cxx.CppRef{((t0.parameters[1]).parameters[1]), Cxx.NulCVR} : t
end

function pointer(t::Any)
    t <: Cxx.CppValue ? Cxx.CppPtr{t.body.parameters[1],Cxx.NullCVR} : t
end

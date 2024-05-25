## Description #############################################################################
#
# Deprecations.
#
############################################################################################

# == Auxiliary macros ======================================================================

# Macro to declare functions to remove keywords.
macro decl_rm_kw(kwarg)
    local fn_name = Symbol("_rm_" * string(kwarg))

    expr = quote
        $fn_name(; $kwarg, kwargs...) = kwargs
    end

    return esc(expr)
end

# -- Macros to Check Deprecated Keywords ---------------------------------------------------

# This macro mark `old` deprecated in favor of `new`. It also pushes `new` to `kwargs` using
# the conversion function `fn`.
macro deprecate_kw_and_push(old, new, fn = identity)
    local rm_kwarg = Symbol("_rm_" * string(old))
    local sym_old = Meta.quot(Symbol(old))
    local sym_new = Meta.quot(Symbol(new))

    expr = quote
        if haskey(kwargs, $sym_old)
            Base.depwarn(
                "The option `$($sym_old)` is deprecated. Use `$($sym_new)` instead.",
                $sym_old
            )

            kwargs = $rm_kwarg(; $new = $fn(kwargs[$sym_old]), kwargs...)
        end
    end

    return esc(expr)
end

# This macro mark `old` deprecated in favor of `new`. It also assigns `new` to `kwargs`
# using the conversion function `fn`.
macro deprecate_kw_and_return(old, new, fn = identity)
    local rm_kwarg = Symbol("_rm_" * string(old))
    local sym_old = Meta.quot(Symbol(old))
    local sym_new = Meta.quot(Symbol(new))

    expr = quote
        if haskey(kwargs, $sym_old)
            Base.depwarn(
                "The option `$($sym_old)` is deprecated. Use `$($sym_new)` instead.",
                $sym_old
            )

            $new   = $fn(kwargs[$sym_old])
            kwargs = $rm_kwarg(; kwargs...)
        end
    end

    return esc(expr)
end

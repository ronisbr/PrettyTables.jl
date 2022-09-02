# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Deprecations.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

#                               Auxiliary macros
# ==============================================================================

# Macro to help declare functions to remove keywords.
macro decl_rm_kwarg(kwarg)
    local fn_name = Symbol("_rm_" * string(kwarg))

    expr = quote
        $fn_name(; $kwarg, kwargs...) = kwargs
    end

    return esc(expr)
end

# Macro to help checking deprecated keywords.
macro deprecate_kwarg_and_push(old, new, fn = identity)
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

macro deprecate_kwarg_and_return(old, new, fn = identity)
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

#                       Deprecations introduced in v2.0
# ==============================================================================

@decl_rm_kwarg(rownum_header_crayon)
@decl_rm_kwarg(noheader)
@decl_rm_kwarg(nosubheader)

@deprecate HTMLDecoration(args...; kwargs...) HtmlDecoration(args...; kwargs...)
@deprecate HTMLTableFormat(args...; kwargs...) HtmlTableFormat(args...; kwargs...)
@deprecate HTMLHighlighter(args...; kwargs...) HtmlHighlighter(args...; kwargs...)
@deprecate URLTextCell(args...; kwargs...) UrlTextCell(args...; kwargs...)

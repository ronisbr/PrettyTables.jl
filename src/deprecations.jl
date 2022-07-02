# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Deprecations.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

#                       Deprecations introduced in v2.0
# ==============================================================================

function _rm_rownum_header_crayon(;
    rownum_header_crayon::Crayon,
    kwargs...
)
    return kwargs
end

function _rm_noheader(; noheader::Bool, kwargs...)
    return kwargs
end

function _rm_nosubheader(; nosubheader::Bool, kwargs...)
    return kwargs
end

@deprecate HTMLDecoration(args...; kwargs...) HtmlDecoration(args...; kwargs...)
@deprecate HTMLTableFormat(args...; kwargs...) HtmlTableFormat(args...; kwargs...)
@deprecate HTMLHighlighter(args...; kwargs...) HtmlHighlighter(args...; kwargs...)

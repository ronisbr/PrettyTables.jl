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

function _rm_filters_row(;
    filters_row::Union{Nothing, Tuple},
    kwargs...
)
    return kwargs
end

function _rm_filters_col(;
    filters_col::Union{Nothing, Tuple},
    kwargs...
)
    return kwargs
end

function _rm_rownum_header_crayon(;
    rownum_header_crayon::Crayon,
    kwargs...
)
    return kwargs
end

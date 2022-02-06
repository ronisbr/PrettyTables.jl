# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Miscellaneous functions related to the processed tables.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

function _is_alignment_valid(alignment::Symbol)
    return (alignment == :l) || (alignment == :c) || (alignment == :r) ||
           (alignment == :L) || (alignment == :C) || (alignment == :R)
end

_is_alignment_valid(alignment) = false

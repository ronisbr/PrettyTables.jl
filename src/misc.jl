# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Description
#
#   Miscellaneous functions used by all back-ends.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

"""
    function _str_escaped(str::AbstractString)

Return the escaped string representation of `str`.

"""
_str_escaped(str::AbstractString) =
    # NOTE: Here we cannot use `escape_string(str)` because it also adds the
    # character `"` to the list of characters to be escaped.
    sprint(escape_string, str, "", sizehint = lastindex(str))

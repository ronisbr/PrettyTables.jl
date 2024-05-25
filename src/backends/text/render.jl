## Description #############################################################################
#
# Functions related to text rendering.
#
############################################################################################

# Render the value `v` to strings using the rendered `T` to be displayed in the text
# back-end.
#
# The first argument can be:
#
# - `Val(:print)`: the function `print` will be used.
# - `Val(:show)`: the function `show` will be used.
#
# This function must return a vector of strings in which each element is a line inside the
# rendered cell.
#
# If `linebreaks` is `true`, the rendered should split the created string into multiple
# tokens.
#
# In case `show` is used, if `isstring` is `false`, it means that the original data is not a
# string even if `v` is a string. Hence, the surrounding quotes added by `show` will be
# removed. This is required to correctly handle formatters.
#
# If `limit_printing` is `true`, then `v` will be converted to string using the property
# `:limit => true`.
function _text_render_cell(
    ::Val{:print},
    @nospecialize(io::IOContext),
    v::Any;
    compact_printing::Bool = true,
    isstring::Bool = false,
    limit_printing::Bool = true,
    linebreaks::Bool = false
)
    # Create the context that will be used when rendering the cell. Notice that the
    # `IOBuffer` will be neglected.
    context = IOContext(
        io,
        :compact => compact_printing,
        :limit => limit_printing
    )

    str = sprint(print, v; context = context)

    return _text_render_cell(
        Val(:print),
        io,
        str;
        compact_printing = compact_printing,
        isstring = isstring,
        linebreaks = linebreaks
    )
end

function _text_render_cell(
    ::Val{:print},
    @nospecialize(io::IOContext),
    str::AbstractString;
    compact_printing::Bool = true,
    isstring::Bool = false,
    limit_printing::Bool = true,
    linebreaks::Bool = false
)
    vstr = linebreaks ? string.(split(str, '\n')) : [str]

    # NOTE: Here we cannot use `escape_string(str)` because it also adds the character `"`
    # to the list of characters to be escaped.
    output_str = Vector{String}(undef, length(vstr))

    @inbounds for i in 1:length(vstr)
        s = vstr[i]
        output_str[i] = sprint(escape_string, s, "", sizehint = lastindex(s))
    end

    return output_str
end

function _text_render_cell(
    ::Val{:show},
    @nospecialize(io::IOContext),
    v::Any;
    compact_printing::Bool = true,
    linebreaks::Bool = false,
    limit_printing::Bool = true,
    isstring::Bool = false
)
    # Create the context that will be used when rendering the cell.
    context = IOContext(
        io,
        :compact => compact_printing,
        :limit => limit_printing
    )

    str  = sprint(show, v; context = context)

    return _text_render_cell(
        Val(:show),
        io,
        str;
        compact_printing = compact_printing,
        linebreaks = linebreaks,
        limit_printing = limit_printing,
        isstring = isstring
    )
end

function _text_render_cell(
    ::Val{:show},
    @nospecialize(io::IOContext),
    v::AbstractString;
    compact_printing::Bool = true,
    linebreaks::Bool = false,
    limit_printing::Bool = true,
    isstring::Bool = false
)
    # Create the context that will be used when rendering the cell.
    context = IOContext(
        io,
        :compact => compact_printing,
        :limit => limit_printing
    )

    aux  = linebreaks ? string.(split(v, '\n')) : [v]
    vstr = sprint.(show, aux; context = context)

    if !isstring
        for i in 1:length(vstr)
            aux_i   = first(vstr[i], length(vstr[i]) - 1)
            vstr[i] = last(aux_i, length(aux_i) - 1)
        end
    end

    return vstr
end

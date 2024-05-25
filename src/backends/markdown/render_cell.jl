## Description #############################################################################
#
# Render cells in the markdown back end.
#
############################################################################################

function _markdown_render_cell(
    ::Val{:print},
    @nospecialize(io::IOContext),
    v::Any;
    compact_printing::Bool = true,
    isstring::Bool = false,
    limit_printing::Bool = true,
)
    isstring && return v

    # Create the context that will be used when rendering the cell. Notice that the
    # `IOBuffer` will be neglected.
    context = IOContext(
        io,
        :compact => compact_printing,
        :limit => limit_printing
    )

    return sprint(print, v; context = context)
end

function _markdown_render_cell(
    ::Val{:show},
    @nospecialize(io::IOContext),
    v::Any;
    compact_printing::Bool = true,
    limit_printing::Bool = true,
    isstring::Bool = false
)
    isstring && return v

    # Create the context that will be used when rendering the cell.
    context = IOContext(
        io,
        :compact => compact_printing,
        :limit => limit_printing
    )

    return sprint(show, v; context = context)
end

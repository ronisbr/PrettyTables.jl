## Description #############################################################################
#
# Functions to print to the IO that we have a circular reference.
#
############################################################################################

function _pt_html_circular_reference(@nospecialize(io::IOContext))
    print(io, "#= circular reference =#")
end

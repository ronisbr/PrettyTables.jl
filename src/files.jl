## Description #############################################################################
#
# Function to include a table in a file.
#
############################################################################################

export include_pt_in_file

"""
    include_pt_in_file(filename::AbstractString, mark::AbstractString, args...; kwargs...) -> Nothing

Include a table in the file `filename` using the `mark`.

This function will print a table using the arguments `args` and keywords `kwargs` in the
function `pretty_table` (**the IO must not be passed to `args` here**). Then, it will search
inside the file `filename` for the following section:

    <PrettyTables mark>
    ...
    </PrettyTables>

and will **replace everything between the marks** with the printed table. If the closing tag
is in a separate line, all characters before it will be kept. This is important to add
comment tags.

If the user wants to also remove the opening and ending tags, pass the keyword
`remove_tags = true`.

The keyword `tag_append` can be used to pass a string that can be used to add a text after
the opening tag. This is important for HTML where the comments have opening and closing
tags. Thus, if `tag_append = " -->"`, the following can be used to add a table into HTML
files:

    <!-- <PrettyTables mark> -->
    ...
    <!-- </PrettyTables> -->

By default, this function will copy the original file to `filename_backup`. If this is not
desired, pass the keyword `backup_file = false` to the function.
"""
function include_pt_in_file(
    filename::AbstractString,
    mark::AbstractString,
    args...;
    backup_file::Bool = true,
    remove_tags::Bool = false,
    tag_append::String = "",
    kwargs...
)
    orig = ""

    open(filename, "r") do f
        orig = read(f, String)
    end

    GC.gc()

    # First, print the table into a string.
    io = IOBuffer()
    pretty_table(io, args...; kwargs...)
    str = String(take!(io))

    # Write the output to a temporary file.
    path, io = mktemp()

    if !remove_tags
        r = Regex("(?<=<PrettyTables $mark>$tag_append)(?:.|\n)*?(?=.*</PrettyTables>)")
        write(io, replace(orig, r => "\n$str"))
    else
        r = Regex("<PrettyTables $mark>$tag_append(?:.|\n)*?</PrettyTables>")
        write(io, replace(orig, r => "$str"))
    end
    close(io)

    # Backup the original file if required.
    backup_file && mv(filename, filename * "_backup"; force = true)

    # Copy the temporary file to `filename`.
    #
    # If we user `mv`, then we get some problems related to `libuv` in Windows. This seems
    # related to this issue:
    #
    #   https://discourse.julialang.org/t/find-what-has-locked-held-a-file/23278
    cp(path, filename; force = true)

    return nothing
end

## Description #############################################################################
#
# Miscellaneous functions and macros.
#
############################################################################################

"""
    _sprint_with_context(f::Function, rc::RenderContext, args...) -> String

Call `f(io, args...)`, where `io` is the `IOContext` of the render context `rc`, and return
everything that was written as a `String`.

This function must be used instead of `sprint(f, args...; context)` in the cell rendering
code. `sprint` builds its temporary `IOContext` around the *caller's* IO, so the resulting
type changes with the object the user is printing to, making every new output IO type
trigger a fresh inference and code generation of the whole rendering call, which showed up
directly as time-to-first-print. The render context pins the type to `IOContext{IOBuffer}`
for every caller. Additionally, its buffer is reused across the entire table, meaning that
each rendered cell pays only for the final `String` allocation.
"""
function _sprint_with_context(f::F, rc::RenderContext, args...) where {F}
    buf = rc.buf
    truncate(buf, 0)
    seekstart(buf)
    f(rc.ctx, args...)
    n = buf.size
    return GC.@preserve buf unsafe_string(pointer(buf.data), n)
end

"""
    _cell_to_str(cell::Any, context::RenderContext, renderer::Union{Val{:print}, Val{:show}}, mime::Union{Nothing, MIME}) -> Tuple{String, Bool}

Convert `cell` to a `String` using the `renderer` and the render `context`. If the renderer
is `:show`, `mime` is not `nothing`, and `cell` can be shown in `mime`, the string is the
`mime` representation of the cell and the second returned value is `true`, meaning that the
string is already written in the back end format. Otherwise, the second returned value is
`false`.

Notice that the type of `mime` must be declared, even if it is not specialized. Otherwise,
`showable` and `show` would be inferred with the methods that receive the MIME type as a
string, which are invalidated when a package defines a new string type.
"""
function _cell_to_str(
    @nospecialize(cell::Any),
    context::RenderContext,
    ::Val{:print},
    @nospecialize(mime::Union{Nothing, MIME})
)
    return _sprint_with_context(print, context, cell), false
end

function _cell_to_str(
    cell::AbstractString,
    context::RenderContext,
    ::Val{:print},
    @nospecialize(mime::Union{Nothing, MIME})
)
    # Notice that we must not use `string` here because it is the identity for any
    # `AbstractString`, whereas the callers require a `String`.
    return (cell isa String ? cell : String(cell)), false
end

function _cell_to_str(
    @nospecialize(cell::Any),
    context::RenderContext,
    ::Val{:show},
    @nospecialize(mime::Union{Nothing, MIME})
)
    if !isnothing(mime) && showable(mime, cell)
        return _sprint_with_context(show, context, mime, cell), true
    end

    return _sprint_with_context(show, context, cell), false
end

function _cell_to_str(
    cell::AbstractString,
    context::RenderContext,
    ::Val{:show},
    @nospecialize(mime::Union{Nothing, MIME})
)
    if !isnothing(mime) && showable(mime, cell)
        return _sprint_with_context(show, context, mime, cell), true
    end

    return string(cell), false
end

function _cell_to_str(
    ::UndefinedCell,
    ::RenderContext,
    ::Val{:print},
    @nospecialize(mime::Union{Nothing, MIME})
)
    return "#undef", false
end

function _cell_to_str(
    ::UndefinedCell,
    ::RenderContext,
    ::Val{:show},
    @nospecialize(mime::Union{Nothing, MIME})
)
    return "#undef", false
end

"""
    _iocontext(rc::RenderContext) -> IOContext

Return the underlying `IOContext` of the render context `rc`. It is required by APIs that
must receive an `IOContext`, such as `CustomTextCell.init!`.
"""
_iocontext(rc::RenderContext) = rc.ctx

"""
    @_print(io, args...)

Print `args` to `io`. Each argument in `args` is printed sequentially using `print`.

This macro expands each argument into a separate `print` call, avoiding the overhead of
string interpolation or concatenation, which reduces allocations.
"""
macro _print(io, args...)
    return esc(quote
        $([:(print($io, $arg)) for arg in args]...)
    end)
end

"""
    @_println(io, args...)

Print `args` to `io` followed by a newline. Each argument in `args` is printed sequentially
using `print`, and a final `println` is issued to terminate the line.

This macro expands each argument into a separate `print` call, avoiding the overhead of
string interpolation or concatenation, which reduces allocations.
"""
macro _println(io, args...)
    return esc(quote
        $([:(print($io, $arg)) for arg in args]...)
        println($io)
    end)
end

"""
    _aprint(
        buf::IO,
        str::String,
        indentation_level::Int = 0,
        indentation_spaces::Int = 2;
        kwargs...
    ) -> Nothing

Print `str` in the buffer `buf` aligned to the `indentation_level`. Each indentation level
contains a number of spaces given by `indentation_spaces`.

# Keywords

- `minify::Bool`: If `true`, the output will be minified, meaning that it will be printed
    without indentation spaces or line breaks.
    (**Default**: `false`)
"""
function _aprint(
    buf::IO,
    str::String,
    indentation_level::Int = 0,
    indentation_spaces::Int = 2;
    minify::Bool = false,
)
    if minify
        for t in eachsplit(str, '\n')
            !isempty(t) && print(buf, strip(t))
        end

        return nothing
    end

    padding = " "^max(indentation_level * indentation_spaces, 0)
    first_token = true

    for t in eachsplit(str, '\n')
        # Print newline before each token except the first, preserving internal
        # line breaks (including empty lines).
        !first_token && println(buf)
        first_token = false

        # If the token is empty, we do nothing to avoid unnecessary white spaces.
        !isempty(t) && @_print(buf, padding, t)
    end

    return nothing
end

"""
    _aprintln(
        buf::IO,
        str::String,
        indentation_level::Int = 0,
        indentation_spaces::Int = 2;
        kwargs...
    ) -> Nothing

Print `str` in the buffer `buf` aligned to the `indentation_level` and adding a line break
at the end. Each indentation level contains a number of spaces given by
`indentation_spaces`.

# Keywords

- `minify::Bool`: If `true`, the output will be minified, meaning that it will be printed
    without indentation spaces or line breaks.
    (**Default**: `false`)
"""
function _aprintln(
    buf::IO,
    str::String,
    indentation_level::Int = 0,
    indentation_spaces::Int = 2;
    minify::Bool = false,
)
    _aprint(buf, str, indentation_level, indentation_spaces; minify)
    !minify && println(buf)
    return nothing
end

"""
    _aprint_section_annotation(
        buf::IO,
        str::String,
        indentation_level::Int = 0,
        indentation_spaces::Int = 2,
        column_width::Int = 92,
        fill_char::Char = '='
    ) -> Nothing

Print a section annotation line to `buf`. The annotation consists of `str` padded to
`indentation_level` and followed by `fill_char` characters up to `column_width`. If
`column_width` is negative, it defaults to 92. No newline is appended.
"""
function _aprint_section_annotation(
    buf::IO,
    str::String,
    indentation_level::Int = 0,
    indentation_spaces::Int = 2,
    column_width::Int = 92,
    fill_char::Char = '=',
)
    column_width < 0 && (column_width = 92)

    padding_length = max(indentation_level * indentation_spaces, 0)
    padding        = " "^padding_length
    line_width     = padding_length + textwidth(str) + 1
    fill_length    = max(column_width - line_width, 0)

    @_print(buf, padding, str, " ", fill_char^fill_length)

    return nothing
end

"""
    _aprintln_section_annotation(
        buf::IO,
        str::String,
        indentation_level::Int = 0,
        indentation_spaces::Int = 2,
        column_width::Int = 92,
        fill_char::Char = '='
    ) -> Nothing

Same as `_aprint_section_annotation`, but appends a newline after the annotation.
"""
function _aprintln_section_annotation(
    buf::IO,
    str::String,
    indentation_level::Int = 0,
    indentation_spaces::Int = 2,
    column_width::Int = 92,
    fill_char::Char = '=',
)
    _aprint_section_annotation(
        buf, str, indentation_level, indentation_spaces, column_width, fill_char
    )
    println(buf)

    return nothing
end

"""
    _align_column_with_regex!(
        column::AbstractVector{String},
        alignment_anchor_regex::Vector{Regex},
        alignment_anchor_fallback::Symbol
    ) -> Int

Align the lines in the `column` at the first match obtained by the regex vector
`alignment_anchor_regex`, falling back to `alignment_anchor_fallback` if a match is not
found for a specific line. Afterward, all the lines are padded to the width of the widest
one.

This function returns the largest line width.
"""
function _align_column_with_regex!(
    column::AbstractVector{String},
    alignment_anchor_regex::Vector{Regex},
    alignment_anchor_fallback::Symbol,
)
    # Compute the column of the anchor in each line, which is the one of the first regex
    # match or the one defined by the fallback alignment if there is no match.
    anchors = similar(column, Int)

    for (i, line) in pairs(column)
        m = nothing

        for r in alignment_anchor_regex
            m = findfirst(r, line)
            !isnothing(m) && break
        end

        anchors[i] = if !isnothing(m)
            textwidth(@views line[1:first(m)])
        elseif alignment_anchor_fallback == :c
            cld(textwidth(line), 2)
        elseif alignment_anchor_fallback == :r
            textwidth(line) + 1
        else
            0
        end
    end

    # Pad the lines on the left so that all the anchors are in the same column.
    alignment_column   = maximum(anchors; init = 0)
    largest_cell_width = 0

    for (i, line) in pairs(column)
        line      = " "^max(alignment_column - anchors[i], 0) * line
        column[i] = line

        largest_cell_width = max(largest_cell_width, textwidth(line))
    end

    # Pad the lines on the right so that all of them have the same width.
    for (i, line) in pairs(column)
        column[i] = line * " "^max(largest_cell_width - textwidth(line), 0)
    end

    return largest_cell_width
end

"""
    _align_multline_column_with_regex!(
        column::AbstractVector{String},
        alignment_anchor_regex::Vector{Regex},
        alignment_anchor_fallback::Symbol,
    ) -> Int

Similar to `_align_column_with_regex!`, but each row will be split into multiple lines at
`\n` before applying the alignment.
"""
function _align_multline_column_with_regex!(
    column::AbstractVector{String},
    alignment_anchor_regex::Vector{Regex},
    alignment_anchor_fallback::Symbol,
)
    # In this case, we align all the lines of all the rows together. Afterward, we join the
    # lines of each row again.
    rows  = split.(column, '\n')
    lines = String[line for row in rows for line in row]

    largest_cell_width = _align_column_with_regex!(
        lines, alignment_anchor_regex, alignment_anchor_fallback
    )

    k = 0

    for (i, row) in zip(eachindex(column), rows)
        n = length(row)
        column[i] = join(@view(lines[(k + 1):(k + n)]), '\n')
        k += n
    end

    return largest_cell_width
end

"""
    _auto_wrap(str::AbstractString, field_width::Int) -> String

Autowrap the string `str` given a `field_width`.
"""
function _auto_wrap(str::AbstractString, field_width::Int)
    # Check for errors.
    (field_width <= 0) && throw(ArgumentError("`field_width` must be greater than 0."))

    # Buffers.
    buf      = IOBuffer(; sizehint = length(str)) # ........ Buffer to store the entire text
    line_buf = IOBuffer(; sizehint = length(str)) # ....... Buffer to store the current line

    # Auxiliary variables.
    state          = :text # .................................................. String state
    c_id           = 0     # ................................... ID of the current character
    line_width     = 0     # .................................... Total line printable width
    last_space     = 0     # ................................ ID of the last space character
    lw_after_space = 0     # ..................... Line width after the last space character

    for c in str
        state = StringManipulation._next_string_state(c, state)
        ctw = textwidth(c)

        if state != :text
            write(line_buf, c)
            c_id += ncodeunits(c)
            continue
        end

        line_overflow = line_width + ctw > field_width

        @views if (c == '\n') || (line_overflow && ((last_space == 0) || (c == ' ')))
            # If the character is a line break, if we have a line overflow and we do not
            # have any space in this line, or if we have a line overflow and this character
            # is a space, we only flush the current line buffer to the output buffer.
            write(buf, take!(line_buf))
            write(buf, '\n')

            c_id       = 0
            line_width = 0
            last_space = 0

            (c ∈ (' ', '\n')) && continue

        elseif line_overflow
            line = take!(line_buf)

            # If we have a last space in this line, break the line at that position, and
            # move the rest to another line.
            l₀ = line[1:(last_space - 1)]
            l₁ = line[(last_space + 1):end]

            write(buf, l₀)
            write(buf, '\n')
            write(line_buf, l₁)

            c_id       = length(l₁)
            line_width = lw_after_space
            last_space = 0
        end

        write(line_buf, c)
        c_id += ncodeunits(c)

        line_width     += textwidth(c)
        lw_after_space += ctw

        if c == ' '
            last_space     = c_id
            lw_after_space = 0
        end
    end

    # Flush the rest of the line.
    write(buf, take!(line_buf))

    return String(take!(buf))
end

"""
    _compact_type_str(T) -> String

Return a string with a compact representation of type `T`.
"""
_compact_type_str(T) = string(T)

function _compact_type_str(T::Union)
    str = T >: Missing ? string(nonmissingtype(T)) * "?" : string(T)
    return replace(str, "Union" => "U")
end

"""
    _maximum_textwidth_per_line(str::AbstractString) -> Int

Compute the maximum textwidth per line of the string `str`.
"""
function _maximum_textwidth_per_line(str::AbstractString)
    return maximum(printable_textwidth_per_line(str))
end

"""
    _omitted_cell_summary(table_data::TableData, pspec::PrintingSpec) -> String

Return the omitted cell summary related to the `table_data` and printing specification
`pspec`.
"""
function _omitted_cell_summary(table_data::TableData, pspec::PrintingSpec)
    pspec.show_omitted_cell_summary || return ""

    num_rows    = table_data.num_rows
    num_columns = table_data.num_columns
    max_rows    = table_data.maximum_number_of_rows
    max_columns = table_data.maximum_number_of_columns

    # Compute the number of omitted rows and columns. Notice that a negative maximum means
    # no cropping.
    num_omitted_columns = (max_columns >= 0) ? num_columns - max_columns : 0
    num_omitted_rows    = (max_rows >= 0) ? num_rows - max_rows : 0

    return _omitted_cell_summary(num_omitted_rows, num_omitted_columns)
end

"""
    _omitted_cell_summary(num_omitted_rows::Int, num_omitted_columns::Int) -> String

Return the omitted cell summary string when there are `num_omitted_rows` omitted data rows
and `num_omitted_columns` omitted data columns.
"""
function _omitted_cell_summary(num_omitted_rows::Int, num_omitted_columns::Int)
    has_omitted_columns = num_omitted_columns > 0
    has_omitted_rows    = num_omitted_rows > 0

    (has_omitted_columns || has_omitted_rows) || return ""

    buf = IOBuffer()

    if has_omitted_columns
        print(buf, num_omitted_columns)
        print(buf, num_omitted_columns == 1 ? " column" : " columns")
    end

    (has_omitted_columns && has_omitted_rows) && print(buf, " and ")

    if has_omitted_rows
        print(buf, num_omitted_rows)
        print(buf, num_omitted_rows == 1 ? " row" : " rows")
    end

    print(buf, " omitted")

    return String(take!(buf))
end

"""
    _resolve_printing_backend(configurations; kwargs...) -> Symbol

Return the printing backend to be used based on the `configurations` provided, which is
selected by the native table format in the entry `table_format` or, if it does not select a
back end, by the native table style in the entry `style`. Notice that this function must
only be used when the user did not specify the backend directly using the `backend`
keyword.

# Keywords

- `default::Symbol`: Backend returned when the table format does not select a backend,
    which happens when it is absent or when it is the backend-agnostic
    [`TableFormat`](@ref).
    (**Default**: `:text`)
"""
function _resolve_printing_backend(@nospecialize(configurations); default::Symbol = :text)
    backend = _backend_of(get(configurations, :table_format, nothing))
    isnothing(backend) && (backend = _backend_of(get(configurations, :style, nothing)))
    return something(backend, default)
end

"""
    _backend_of(object::Any) -> Union{Nothing, Symbol}

Return the back end selected by the native table format or table style `object`, or
`nothing` if `object` does not select a back end. The methods for the native objects are
defined in the `table_format.jl` file of each back end.
"""
_backend_of(::Any) = nothing

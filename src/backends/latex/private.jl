## Description #############################################################################
#
# Private functions and macros.
#
############################################################################################

# Dictionary that translates table type to environment.
const _latex_table_env = Dict(
    :array     => "array",
    :longtable => "longtable",
    :tabular   => "tabular"
)

# Convert the alignment symbol into a LaTeX alignment string.
function _latex_alignment(s::Symbol)
    if (s == :l) || (s == :L)
        return "l"
    elseif (s == :c) || (s == :C)
        return "c"
    elseif (s == :r) || (s == :R)
        return "r"
    else
        error("Invalid LaTeX alignment symbol: $s.")
    end
end

# Apply an alignment to a LaTeX table cell.
function _latex_cell_alignment(
    ptable::ProcessedTable,
    str::String,
    alignment::Symbol,
    j::Int,
    vlines::Union{Nothing, Symbol, Vector{Int}},
    left_vline::String,
    mid_vline::String,
    right_vline::String
)
    a = _latex_alignment(alignment)

    # We only need to add left vertical line if it is the first column.
    lvline = ((j == 0) && (_check_vline(ptable, vlines, 0))) ?
        left_vline :
        ""

    # For the right vertical line, we must check if it is a mid line or right line.
    if _check_vline(ptable, vlines, j)
        num_printed_columns = _size(ptable)[2]
        rvline = (j == num_printed_columns) ? right_vline : mid_vline
    else
        rvline = ""
    end

    # Wrap the data into the multicolumn environment.
    return _latex_envs(str, "multicolumn{1}{$(lvline)$(a)$(rvline)}")
end

# Get the LaTeX table description (alignment and vertical columns).
function _latex_table_description(
    ptable::ProcessedTable,
    vlines::Union{Symbol, AbstractVector},
    left_vline::AbstractString,
    mid_vline::AbstractString,
    right_vline::AbstractString,
    hidden_columns_at_end::Bool
)
    str = "{"
    num_columns = _size(ptable)[2]

    if _check_vline(ptable, vlines, 0)
        str *= left_vline
    end

    for j in 1:num_columns
        alignment = _get_column_alignment(ptable, j) |> _latex_alignment
        str *= alignment

        if _check_vline(ptable, vlines, j)
            if j != num_columns
                str *= mid_vline
            else
                str *= right_vline
            end
        end
    end

    # If we have hidden columns at the end, we need an additional column to show the
    # continuation characters.
    if hidden_columns_at_end
        str *= "c"

        # Check if we need to draw a line at the end of the table.
        if _check_vline(ptable, vlines, num_columns)
            str *= right_vline
        end
    end

    str *= "}"

    return str
end

# Wrap the `text` into LaTeX environment(s).
function _latex_envs(text::AbstractString, envs::Vector{String})
    return _latex_envs(text, envs, length(envs))
end

function _latex_envs(text::AbstractString, env::String)
    if !isempty(text)
        return "\\" * string(env) * "{" * text * "}"
    else
        return ""
    end
end

function _latex_envs(text::AbstractString, envs::Vector{String}, i::Int)
    @inbounds if i > 0
        str = _latex_envs(text, envs[i])
        return _latex_envs(str, envs, i -= 1)
    end

    return text
end

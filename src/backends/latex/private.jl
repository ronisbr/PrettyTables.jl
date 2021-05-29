# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Private functions and macros.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Dictionary that translates table type to environment.
const _latex_table_env = Dict(
    :array     => "array",
    :longtable => "longtable",
    :tabular   => "tabular"
)

# Apply an alignment to a LaTeX table cell.
function _latex_apply_cell_alignment(
    str::String,
    alignment::Symbol,
    j::Int,
    num_printed_cols::Int,
    show_row_number::Bool,
    vlines::Vector{Int},
    left_vline::String,
    mid_vline::String,
    right_vline::String
)
    a = _latex_alignment(alignment)
    aux_j = show_row_number ? j + 1 : j

    # We only need to add left vertical line if it is the first
    # column.
    lvline = if (0 ∈ vlines) && (aux_j - 1 == 0)
        left_vline
    else
        ""
    end

    # For the right vertical line, we must check if it is a mid line
    # or right line.
    if aux_j ∈ vlines
        rvline = (j == num_printed_cols) ? right_vline : mid_vline
    else
        rvline = ""
    end

    # Wrap the data into the multicolumn environment.
    return _latex_envs(str, "multicolumn{1}{$(lvline)$(a)$(rvline)}")
end

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

# Get the LaTeX table description (alignment and vertical columns).
function _latex_table_desc(
    id_cols::AbstractVector,
    alignment::Vector{Symbol},
    show_row_name::Bool,
    row_name_alignment::Symbol,
    show_row_number::Bool,
    row_number_alignment::Symbol,
    vlines::AbstractVector,
    left_vline::AbstractString,
    mid_vline::AbstractString,
    right_vline::AbstractString
)
    Δc = show_row_number ? 1 : 0

    str = "{"

    0 ∈ vlines && (str *= left_vline)

    # Add the alignment information of the row number column if required.
    Δc = 0
    if show_row_number
        Δc += 1
        str *= _latex_alignment(row_number_alignment)
        Δc ∈ vlines && (str *= mid_vline)
    end

    if show_row_name
        Δc += 1
        str *= _latex_alignment(row_name_alignment)
        Δc ∈ vlines && (str *= mid_vline)
    end

    # Process the alignment of all the other columns.
    for i = 1:length(id_cols)
        str *= _latex_alignment(alignment[id_cols[i]])

        if i+Δc ∈ vlines
            if i != length(id_cols)
                str *= mid_vline
            else
                str *= right_vline
            end
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


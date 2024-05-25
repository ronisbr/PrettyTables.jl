## Description #############################################################################
#
# Pre-defined highlighters for the markdown back end.
#
############################################################################################

export hl_cell

"""
    hl_cell(i::Number, j::Number, decoration::MarkdownDecoration) -> MarkdownHighlighter

Highlight the cell `(i, j)` with the `decoration` (see [`MarkdownDecoration`](@ref)).

    hl_cell(cells::AbstractVector{NTuple(2,Int)}, decoration::MarkdownDecoration) -> MarkdownHighlighter

Highlights all the `cells` with the `decoration` (see [`MarkdownDecoration`](@ref)).

!!! info

    Those functions return a `MarkdownHighlighter` to be used with the HTML backend.
"""
hl_cell(i::Number, j::Number, decoration::MarkdownDecoration) = MarkdownHighlighter(
    f = (data, x, y)->begin
        return (x == i) && (y == j)
    end,
    decoration = decoration
)

function hl_cell(cells::AbstractVector{NTuple{2,Int}}, decoration::MarkdownDecoration)
    return MarkdownHighlighter(
        f = (data, x, y)->begin
            return (x, y) ∈ cells
        end,
        decoration = decoration
    )
end

"""
    hl_col(i::Number, decoration::MarkdownDecoration) -> MarkdownHighlighter

Highlight the entire column `i` with the `decoration`.

    hl_col(cols::AbstractVector{Int}, decoration::MarkdownDecoration) -> MarkdownHighlighter

Highlights all the columns in `cols` with the `decoration`.

!!! info

    Those functions return a `MarkdownHighlighter` to be used with the HTML backend.
"""
hl_col(j::Number, decoration::MarkdownDecoration) = MarkdownHighlighter(
    f = (data, x, y)->begin
        return y == j
    end,
    decoration = decoration
)

hl_col(cols::AbstractVector{Int}, decoration::MarkdownDecoration) = MarkdownHighlighter(
    f = (data, x, y)->begin
        return y ∈ cols
    end,
    decoration = decoration
)

"""
    hl_row(i::Number, decoration::MarkdownDecoration) -> MarkdownHighlighter

Highlight the entire row `i` with the `decoration`.

    hl_row(rows::AbstractVector{Int}, decoration::MarkdownDecoration) -> MarkdownHighlighter

Highlights all the rows in `rows` with the `decoration`.

!!! info

    Those functions return a `MarkdownHighlighter` to be used with the HTML backend.
"""
hl_row(i::Number, decoration::MarkdownDecoration) = MarkdownHighlighter(
    f = (data, x, y)->begin
        return x == i
    end,
    decoration = decoration
)

hl_row(rows::AbstractVector{Int}, decoration::MarkdownDecoration) = MarkdownHighlighter(
    f = (data, x, y)->begin
        return x ∈ rows
    end,
    decoration = decoration
)

"""
    hl_lt(n::Number, decoration::MarkdownDecoration) -> MarkdownHighlighter

Highlight all elements that are `< n` using the `decoration`.

!!! info

    This function returns a `MarkdownHighlighter` to be used with the text backend.
"""
hl_lt(n::Number, decoration::MarkdownDecoration) = MarkdownHighlighter(
    f = (data, i, j)->begin
        if applicable(<, data[i, j], n) && data[i, j] < n
            return true
        else
            return false
        end
    end,
    decoration = decoration
)

"""
    hl_leq(n::Number, decoration::MarkdownDecoration) -> MarkdownHighlighter

Highlight all elements that are `≤ n` using the `decoration`.

!!! info

    This function returns a `MarkdownHighlighter` to be used with the text backend.
"""
hl_leq(n::Number, decoration::MarkdownDecoration) = MarkdownHighlighter(
    f = (data,i,j)->begin
        if applicable(≤,data[i,j],n) && data[i,j] ≤ n
            return true
        else
            return false
        end
    end,
    decoration = decoration
)

"""
    hl_gt(n::Number, decoration::MarkdownDecoration) -> MarkdownHighlighter

Highlight all elements that are `> n` using the `decoration`.

!!! info

    This function returns a `MarkdownHighlighter` to be used with the text backend.
"""
hl_gt(n::Number, decoration::MarkdownDecoration) = MarkdownHighlighter(
    f = (data, i, j)->begin
        if applicable(>, data[i, j], n) && data[i, j] > n
            return true
        else
            return false
        end
    end,
    decoration = decoration
)

"""
    hl_geq(n::Number, decoration::MarkdownDecoration) -> MarkdownHighlighter

Highlight all elements that are `≥ n` using the `decoration`.

!!! info

    This function returns a `MarkdownHighlighter` to be used with the text backend.
"""
hl_geq(n::Number, decoration::MarkdownDecoration) = MarkdownHighlighter(
    f = (data, i, j)->begin
        if applicable(≥, data[i, j], n) && data[i, j] ≥ n
            return true
        else
            return false
        end
    end,
    decoration = decoration
)

"""
    hl_value(v::Any, decoration::MarkdownDecoration) -> MarkdownHighlighter

Highlight all the values that matches `data[i,j] == v` using the `decoration`.

!!! info

    This function returns a `MarkdownHighlighter` to be used with the text backend.
"""
hl_value(v, decoration::MarkdownDecoration) = MarkdownHighlighter(
    f = (data, i, j)->data[i, j] == v,
    decoration = decoration
)


## Description #############################################################################
#
# Pre-defined highlighters for the text back end.
#
############################################################################################

export hl_cell, hl_col, hl_row, hl_lt, hl_leq, hl_gt, hl_geq, hl_value

"""
    hl_cell(i::Number, j::Number, crayon::Crayon) -> Highlighter

Highlight the cell `(i,j)` with the `crayon`.

    hl_cell(cells::AbstractVector{NTuple(2,Int)}, crayon::Crayon) -> Highlighter

Highlights all the `cells` with the `crayon`.

!!! info

    Those functions return a `Highlighter` to be used with the text backend.
"""
hl_cell(i::Number, j::Number, crayon::Crayon) = Highlighter(
    f = (data, x, y)->begin
        return (x == i) && (y == j)
    end,
    crayon = crayon
)

hl_cell(cells::AbstractVector{NTuple{2,Int}}, crayon::Crayon) = Highlighter(
    f = (data, x, y)->begin
        return (x, y) ∈ cells
    end,
    crayon = crayon
)

"""
    hl_col(i::Number, crayon::Crayon) -> Highlighter

Highlight the entire column `i` with the `crayon`.

    hl_col(cols::AbstractVector{Int}, crayon::Crayon) -> Highlighter

Highlights all the columns in `cols` with the `crayon`.

!!! info

    Those functions return a `Highlighter` to be used with the text backend.
"""
hl_col(j::Number, crayon::Crayon) = Highlighter(
    f = (data, x, y)->begin
        return y == j
    end,
    crayon = crayon
)

hl_col(cols::AbstractVector{Int}, crayon::Crayon) = Highlighter(
    f = (data, x, y)->begin
        return y ∈ cols
    end,
    crayon = crayon
)

"""
    hl_row(i::Number, crayon::Crayon) -> Highlighter

Highlight the entire row `i` with the `crayon`.

    hl_row(rows::AbstractVector{Int}, crayon::Crayon) -> Highlighter

Highlights all the rows in `rows` with the `crayon`.

!!! info

    Those functions return a `Highlighter` to be used with the text backend.
"""
hl_row(i::Number, crayon::Crayon) = Highlighter(
    f = (data, x, y)->begin
        return x == i
    end,
    crayon = crayon
)

hl_row(rows::AbstractVector{Int}, crayon::Crayon) = Highlighter(
    f = (data, x, y)->begin
        return x ∈ rows
    end,
    crayon = crayon
)

"""
    hl_lt(n::Number) -> Highlighter

Highlight all elements that are `< n`.

!!! info

    This function return a `Highlighter` to be used with the text backend.
"""
hl_lt(n::Number) = Highlighter(
    f = (data, i, j)->begin
        if applicable(<, data[i, j], n) && data[i, j] < n
            return true
        else
            return false
        end
    end,
    crayon = Crayon(bold = true, foreground = :red)
)

"""
    hl_leq(n::Number) -> Highlighter

Highlight all elements that are `≤ n`.

!!! note

    This function return a `Highlighter` to be used with the text backend.
"""
hl_leq(n::Number) = Highlighter(
    f = (data, i, j)->begin
        if applicable(≤, data[i, j], n) && data[i, j] ≤ n
            return true
        else
            return false
        end
    end,
    crayon = Crayon(bold = true, foreground = :red)
)

"""
    hl_gt(n::Number) -> Highlighter

Highlight all elements that are `> n`.

!!! info

    Those functions return a `Highlighter` to be used with the text backend.
"""
hl_gt(n::Number) = Highlighter(
    f = (data, i, j)->begin
        if applicable(>, data[i, j], n) && data[i, j] > n
            return true
        else
            return false
        end
    end,
    crayon = Crayon(bold = true, foreground = :blue)
)

"""
    hl_geq(n::Number) -> Highlighter

Highlight all elements that `≥ n`.

!!! info

    Those functions return a `Highlighter` to be used with the text backend.
"""
hl_geq(n::Number) = Highlighter(
    f = (data, i, j)->begin
        if applicable(≥, data[i, j], n) && data[i, j] ≥ n
            return true
        else
            return false
        end
    end,
    crayon = Crayon(bold = true, foreground = :blue)
)

"""
    hl_value(v::Any) -> Highlighter

Highlight all the values that matches `data[i,j] == v`.

!!! info

    This function return a `Highlighter` to be used with the text backend.
"""
hl_value(v) = Highlighter(
    f = (data, i, j)->data[i, j] == v,
    crayon = Crayon(bold = true, foreground = :yellow)
)

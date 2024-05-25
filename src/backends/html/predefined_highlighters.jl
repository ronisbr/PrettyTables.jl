## Description #############################################################################
#
# Pre-defined highlighters for the HTML back end.
#
############################################################################################

export hl_cell

"""
    hl_cell(i::Number, j::Number, decoration::HtmlDecoration) -> HtmlHighlighter

Highlight the cell `(i, j)` with the `decoration` (see [`HtmlDecoration`](@ref)).

    hl_cell(cells::AbstractVector{NTuple(2,Int)}, decoration::HtmlDecoration) -> HtmlHighlighter

Highlights all the `cells` with the `decoration` (see [`HtmlDecoration`](@ref)).

!!! info

    Those functions return a `HtmlHighlighter` to be used with the HTML backend.
"""
hl_cell(i::Number, j::Number, decoration::HtmlDecoration) = HtmlHighlighter(
    f = (data, x, y)->begin
        return (x == i) && (y == j)
    end,
    decoration = decoration
)

function hl_cell(cells::AbstractVector{NTuple{2,Int}}, decoration::HtmlDecoration)
    return HtmlHighlighter(
        f = (data, x, y)->begin
            return (x, y) ∈ cells
        end,
        decoration = decoration
    )
end

"""
    hl_col(i::Number, decoration::HtmlDecoration) -> HtmlHighlighter

Highlight the entire column `i` with the `decoration`.

    hl_col(cols::AbstractVector{Int}, decoration::HtmlDecoration) -> HtmlHighlighter

Highlights all the columns in `cols` with the `decoration`.

!!! info

    Those functions return a `HtmlHighlighter` to be used with the HTML backend.
"""
hl_col(j::Number, decoration::HtmlDecoration) = HtmlHighlighter(
    f = (data, x, y)->begin
        return y == j
    end,
    decoration = decoration
)

hl_col(cols::AbstractVector{Int}, decoration::HtmlDecoration) = HtmlHighlighter(
    f = (data, x, y)->begin
        return y ∈ cols
    end,
    decoration = decoration
)

"""
    hl_row(i::Number, decoration::HtmlDecoration) -> HtmlHighlighter

Highlight the entire row `i` with the `decoration`.

    hl_row(rows::AbstractVector{Int}, decoration::HtmlDecoration) -> HtmlHighlighter

Highlights all the rows in `rows` with the `decoration`.

!!! info

    Those functions return a `HtmlHighlighter` to be used with the HTML backend.
"""
hl_row(i::Number, decoration::HtmlDecoration) = HtmlHighlighter(
    f = (data, x, y)->begin
        return x == i
    end,
    decoration = decoration
)

hl_row(rows::AbstractVector{Int}, decoration::HtmlDecoration) = HtmlHighlighter(
    f = (data, x, y)->begin
        return x ∈ rows
    end,
    decoration = decoration
)

"""
    hl_lt(n::Number, decoration::HtmlDecoration) -> HtmlHighlighter

Highlight all elements that are `< n` using the `decoration`.

!!! info

    This function returns a `HtmlHighlighter` to be used with the text backend.
"""
hl_lt(n::Number, decoration::HtmlDecoration) = HtmlHighlighter(
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
    hl_leq(n::Number, decoration::HtmlDecoration) -> HtmlHighlighter

Highlight all elements that are `≤ n` using the `decoration`.

!!! info

    This function returns a `HtmlHighlighter` to be used with the text backend.
"""
hl_leq(n::Number, decoration::HtmlDecoration) = HtmlHighlighter(
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
    hl_gt(n::Number, decoration::HtmlDecoration) -> HtmlHighlighter

Highlight all elements that are `> n` using the `decoration`.

!!! info

    This function returns a `HtmlHighlighter` to be used with the text backend.
"""
hl_gt(n::Number, decoration::HtmlDecoration) = HtmlHighlighter(
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
    hl_geq(n::Number, decoration::HtmlDecoration) -> HtmlHighlighter

Highlight all elements that are `≥ n` using the `decoration`.

!!! info

    This function returns a `HtmlHighlighter` to be used with the text backend.
"""
hl_geq(n::Number, decoration::HtmlDecoration) = HtmlHighlighter(
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
    hl_value(v::Any, decoration::HtmlDecoration) -> HtmlHighlighter

Highlight all the values that matches `data[i,j] == v` using the `decoration`.

!!! info

    This function returns a `HtmlHighlighter` to be used with the text backend.
"""
hl_value(v, decoration::HtmlDecoration) = HtmlHighlighter(
    f = (data, i, j)->data[i, j] == v,
    decoration = decoration
)

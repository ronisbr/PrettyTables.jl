# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Pre-defined highlighters for the text backend.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export hl_cell, hl_col, hl_row, hl_lt, hl_leq, hl_gt, hl_geq, hl_value

"""
    function hl_cell(i::Number, j::Number, crayon::Crayon)

Highlight the cell `(i,j)` with the crayon `crayon`.

    function hl_cell(cells::AbstractVector{NTuple(2,Int)}, crayon::Crayon)

Highlights all the cells in `cells` with the crayon `crayon`.

# Remarks

Those functions return a `TextHighlighter` to be used with the text backend.

"""
hl_cell(i::Number, j::Number, crayon::Crayon) = TextHighlighter(
    f = (data,x,y)->begin
        return (x == i) && (y == j)
    end,
    crayon = crayon
)

hl_cell(cells::AbstractVector{NTuple{2,Int}}, crayon::Crayon) = TextHighlighter(
    f = (data,x,y)->begin
        return (x,y) ∈ cells
    end,
    crayon = crayon
)

"""
    function hl_col(i::Number, crayon::Crayon)

Highlight the entire column `i` with the crayon `crayon`.

    function hl_col(cols::AbstractVector{Int}, crayon::Crayon)

Highlights all the columns in `cols` with the crayon `crayon`.

# Remarks

Those functions return a `TextHighlighter` to be used with the text backend.

"""
hl_col(j::Number, crayon::Crayon) = TextHighlighter(
    f = (data,x,y)->begin
        return y == j
    end,
    crayon = crayon
)

hl_col(cols::AbstractVector{Int}, crayon::Crayon) = TextHighlighter(
    f = (data,x,y)->begin
        return y ∈ cols
    end,
    crayon = crayon
)

"""
    function hl_row(i::Number, crayon::Crayon)

Highlight the entire row `i` with the crayon `crayon`.

    function hl_row(rows::AbstractVector{Int}, crayon::Crayon)

Highlights all the rows in `rows` with the crayon `crayon`.

# Remarks

Those functions return a `TextHighlighter` to be used with the text backend.

"""
hl_row(i::Number, crayon::Crayon) = TextHighlighter(
    f = (data,x,y)->begin
        return x == i
    end,
    crayon = crayon
)

hl_row(rows::AbstractVector{Int}, crayon::Crayon) = TextHighlighter(
    f = (data,x,y)->begin
        return x ∈ rows
    end,
    crayon = crayon
)

"""
    function hl_lt(n::Number)

Highlight all elements that < `n`.

# Remarks

Those functions return a `TextHighlighter` to be used with the text backend.

"""
hl_lt(n::Number) = TextHighlighter(
    f = (data,i,j)->begin
        if applicable(<,data[i,j],n) && data[i,j] < n
            return true
        else
            return false
        end
    end,
    crayon = Crayon(bold       = true,
                    foreground = :red)
)

"""
    function hl_leq(n::Number)

Highlight all elements that ≤ `n`.

# Remarks

Those functions return a `TextHighlighter` to be used with the text backend.

"""
hl_leq(n::Number) = TextHighlighter(
    f = (data,i,j)->begin
        if applicable(≤,data[i,j],n) && data[i,j] ≤ n
            return true
        else
            return false
        end
    end,
    crayon = Crayon(bold       = true,
                    foreground = :red)
)

"""
    function hl_gt(n::Number)

Highlight all elements that > `n`.

# Remarks

Those functions return a `TextHighlighter` to be used with the text backend.

"""
hl_gt(n::Number) = TextHighlighter(
    f = (data,i,j)->begin
        if applicable(>,data[i,j],n) && data[i,j] > n
            return true
        else
            return false
        end
    end,
    crayon = Crayon(bold       = true,
                    foreground = :blue)
)

"""
    function hl_geq(n::Number)

Highlight all elements that ≥ `n`.

# Remarks

Those functions return a `TextHighlighter` to be used with the text backend.

"""
hl_geq(n::Number) = TextHighlighter(
    f = (data,i,j)->begin
        if applicable(≥,data[i,j],n) && data[i,j] ≥ n
            return true
        else
            return false
        end
    end,
    crayon = Crayon(bold       = true,
                    foreground = :blue)
)

"""
    function hl_value(v::Any)

Highlight all the values that matches `data[i,j] == v`.

# Remarks

Those functions return a `TextHighlighter` to be used with the text backend.

"""
hl_value(v) = TextHighlighter(
    f = (data,i,j)->data[i,j] == v,
    crayon = Crayon(bold       = true,
                    foreground = :yellow)
)

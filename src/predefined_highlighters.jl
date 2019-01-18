#== # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Pre-defined highlighters.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # ==#

export hl_lt, hl_leq, hl_gt, hl_geq, hl_value

"""
    function hl_lt(n::Number)

Highlight all elements that < `n`.

"""
hl_lt(n::Number) = Highlighter(
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

"""
hl_leq(n::Number) = Highlighter(
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

"""
hl_gt(n::Number) = Highlighter(
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

"""
hl_geq(n::Number) = Highlighter(
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

"""
hl_value(v) = Highlighter(
    f = (data,i,j)->data[i,j] == v,
    crayon = Crayon(bold       = true,
                    foreground = :yellow)
)

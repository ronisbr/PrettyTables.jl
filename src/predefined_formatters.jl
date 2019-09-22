#== # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Description
#
#   Pre-defined formatters.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # ==#

export ft_printf, ft_round

"""
    function ft_printf(ftv_str, [columns])

Apply the formats `ftv_str` (see the function `sprintf1` of the package
**Formatting.jl**) to the elements in the columns `columns`.

If `ftv_str` is a `Vector`, then `columns` must be also be a `Vector` with the
same number of elements. If `ftv_str` is a `String`, and `columns` is not
specified (or is empty), then the format will be applied to the entire table.
Otherwise, if `ftv_str` is a `String` and `columns` is a `Vector`, then the
format will be applied only to the columns in `columns`.

# Remarks

This formatter will be applied only to the cells that are of type `Number`.

"""
ft_printf(ftv_str::String) = ft_printf([ftv_str])
ft_printf(ftv_str::String, column::Int) = ft_printf(ftv_str, [column])
ft_printf(ftv_str::String, columns::AbstractVector{Int}) =
    ft_printf([ftv_str for i = 1:length(columns)], columns)

function ft_printf(ftv_str::Vector{String}, columns::AbstractVector{Int} = Int[])
    lc = length(columns)

    lc == 0 && (length(ftv_str) != 1) &&
    error("If columns is empty, then ftv_str must have only one element.")

    lc > 0 && (length(ftv_str) != lc) &&
    error("The vector columns must have the same number of elements of the vector ftv_str.")

    # By using the function `sprintf1` from the package Formatting.jl, it was
    # possible to reduce the time to print a 100x5 table of `Float64`s from 25s
    # to 0.04s. Thanks to @RalphAS for the tip!

    if lc == 0
        return Dict{Int,Function}(0 => (v,i) -> begin
            return typeof(v) <: Number ? sprintf1(ftv_str[1], v) : v
        end)
    else
        ft = Dict{Int,Function}()

        for i = 1:length(columns)
            push!(ft, columns[i] => (v,j) -> begin
                return typeof(v) <: Number ? sprintf1(ftv_str[i], v) : v
            end)
        end

        return ft
    end
end

"""
    function ft_round(digits, [columns])

Round the elements in the columns `columns` to the number of digits in `digits`.

If `digits` is a `Vector`, then `columns` must be also be a `Vector` with the
same number of elements. If `digits` is a `Number`, and `columns` is not
specified (or is empty), then the rounding will be applied to the entire table.
Otherwise, if `digits` is a `Number` and `columns` is a `Vector`, then the
elements in the columns `columns` will be rounded to the number of digits
`digits`.

"""
ft_round(digits::Int) = ft_round([digits])
ft_round(digits::Int, columns::AbstractVector{Int}) =
    ft_round([digits for i = 1:length(columns)], columns)

function ft_round(digits::AbstractVector{Int}, columns::AbstractVector{Int} = Int[])
    lc = length(columns)

    lc == 0 && (length(digits) != 1) &&
    error("If columns is empty, then digits must have only one element.")

    lc > 0 && (length(digits) != lc) &&
    error("The vector columns must have the same number of elements of the vector digits.")

    if lc == 0
        return Dict{Int,Function}(0 => (v,i) -> begin
                                      if applicable(round,v)
                                          return round(v; digits = digits[1])
                                      else
                                          return v
                                      end
                                  end)
    else
        ft = Dict{Int,Function}()

        for i = 1:length(columns)
            push!(ft, columns[i] => (v,j) -> begin
                      if applicable(round,v)
                          return round(v; digits = digits[i])
                      else
                          return v
                      end
                  end)
        end

        return ft
    end
end

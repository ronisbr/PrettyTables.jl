#== # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Description
#
#   Pre-defined formatters.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # ==#

export ft_printf, ft_round

"""
    function ft_printf(ftv_str, [columns])

Apply the formats `ftv_str` (see `@sprintf`) to the elements in the columns
`columns`.

If `ftv_str` is a `Vector`, then `columns` must be also be a `Vector` with the
same number of elements. If `ftv_str` is a `String`, and `columns` is not
specified (or is empty), then the format will be applied to the entire table.
Otherwise, if `ftv_str` is a `String` and `columns` is a `Vector`, then the
format will be applied only to the columns in `columns`.

"""
ft_printf(ftv_str::String) = ft_printf([ftv_str])
ft_printf(ftv_str::String, columns::Vector{Int}) =
    ft_printf([ftv_str for i = 1:length(columns)], columns)

function ft_printf(ftv_str::Vector{String}, columns::Vector{Int} = Int[])
    lc = length(columns)

    lc == 0 && (length(ftv_str) != 1) &&
    error("If columns is empty, then ftv_str must have only one element.")

    lc > 0 && (length(ftv_str) != lc) &&
    error("The vector columns must have the same number of elements of the vector ftv_str.")

    if lc == 0
        return Dict{Int,Function}(0 => (v,i) -> @eval @sprintf($(ftv_str[1]), $v))
    else
        ft = Dict{Int,Function}()

        for i = 1:length(columns)
            push!(ft, columns[i] => (v,j) -> @eval @sprintf($(ftv_str[i]), $v))
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
ft_round(digits::Int, columns::Vector{Int}) =
    ft_round([digits for i = 1:length(columns)], columns)

function ft_round(digits::Vector{Int}, columns::Vector{Int} = Int[])
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

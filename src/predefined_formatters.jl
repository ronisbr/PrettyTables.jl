# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Pre-defined formatters.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export ft_printf, ft_round, ft_latex_sn, ft_nomissing, ft_nonothing

"""
    ft_printf(ftv_str, [columns])

Apply the formats `ftv_str` (see the function `sprintf1` of the package
**Formatting.jl**) to the elements in the columns `columns`.

If `ftv_str` is a `Vector`, then `columns` must be also be a `Vector` with the
same number of elements. If `ftv_str` is a `String`, and `columns` is not
specified (or is empty), then the format will be applied to the entire table.
Otherwise, if `ftv_str` is a `String` and `columns` is a `Vector`, then the
format will be applied only to the columns in `columns`.

!!! info
    This formatter will be applied only to the cells that are of type `Number`.
"""
ft_printf(ftv_str::String) = ft_printf([ftv_str])
ft_printf(ftv_str::String, column::Int) = ft_printf(ftv_str, [column])

function ft_printf(ftv_str::String, columns::AbstractVector{Int})
    return ft_printf([ftv_str for i = 1:length(columns)], columns)
end

function ft_printf(ftv_str::Vector{String}, columns::AbstractVector{Int} = Int[])
    lc = length(columns)

    if lc == 0 && (length(ftv_str) != 1)
        error("If columns is empty, then ftv_str must have only one element.")
    end

    if lc > 0 && (length(ftv_str) != lc)
        error("The vector columns must have the same number of elements of the vector ftv_str.")
    end

    # By using the function `sprintf1` from the package Formatting.jl, it was
    # possible to reduce the time to print a 100x5 table of `Float64`s from 25s
    # to 0.04s. Thanks to @RalphAS for the tip!

    if lc == 0
        return (v, i, j) -> begin
            return typeof(v) <: Number ? sprintf1(ftv_str[1], v) : v
        end
    else
        return (v, i, j) -> begin
            @inbounds for k = 1:length(columns)
                if j == columns[k]
                    return typeof(v) <: Number ? sprintf1(ftv_str[k], v) : v
                end
            end

            return v
        end
    end
end

"""
    ft_round(digits, [columns])

Round the elements in the `columns` to the number of `digits`.

If `digits` is a `Vector`, then `columns` must be also be a `Vector` with the
same number of elements. If `digits` is a `Number`, and `columns` is not
specified (or is empty), then the rounding will be applied to the entire table.
Otherwise, if `digits` is a `Number` and `columns` is a `Vector`, then the
elements in the columns `columns` will be rounded to the number of digits
`digits`.
"""
ft_round(digits::Int) = ft_round([digits])

function ft_round(digits::Int, columns::AbstractVector{Int})
    return ft_round([digits for i = 1:length(columns)], columns)
end

function ft_round(digits::AbstractVector{Int}, columns::AbstractVector{Int} = Int[])
    lc = length(columns)

    if lc == 0 && (length(digits) != 1)
        error("If columns is empty, then digits must have only one element.")
    end

    if lc > 0 && (length(digits) != lc)
        error("The vector columns must have the same number of elements of the vector digits.")
    end

    if lc == 0
        return (v, i, j) -> begin
            if applicable(round, v)
                return round(v, digits = digits[1])
            else
                return v
            end
        end
    else
        return (v, i, j) -> begin
            @inbounds for k = 1:length(columns)
                if j == columns[k]
                    if applicable(round, v)
                        return round(v, digits = digits[k])
                    else
                        return v
                    end
                end
            end

            return v
        end
    end
end

"""
    ft_latex_sn(m_digits, [columns])

Format the numbers of the elements in the `columns` to a scientific notation
using LaTeX. The number is first printed using `sprintf1` functions with the `g`
modifier and then converted to the LaTeX format. The number of digits in the
mantissa can be selected by the argument `m_digits`.

If `m_digits` is a `Vector`, then `columns` must be also be a `Vector` with the
same number of elements. If `m_digits` is a `Integer`, and `columns` is not
specified (or is empty), then the format will be applied to the entire table.
Otherwise, if `m_digits` is a `String` and `columns` is a `Vector`, then the
format will be applied only to the columns in `columns`.

!!! info
    This formatter will be applied only to the cells that are of type `Number`.
"""
ft_latex_sn(m_digits::Int) = ft_latex_sn([m_digits])

function ft_latex_sn(m_digits::Int, columns::AbstractVector{Int})
    return ft_latex_sn([m_digits for i = 1:length(columns)], columns)
end

function ft_latex_sn(
    m_digits::AbstractVector{Int},
    columns::AbstractVector{Int} = Int[]
)
    lc = length(columns)

    if lc == 0 && (length(m_digits) != 1)
        error("If columns is empty, then `m_digits` must have only one element.")
    end

    if lc > 0 && (length(m_digits) != lc)
        error("The vector columns must have the same number of elements of the vector `m_digits`.")
    end

    if lc == 0
        return (v, i, j) -> begin
            if typeof(v) <: Number
                str = sprintf1("%." * string(m_digits[1]) * "g", v)

                # Check if we have scientific notation.
                aux = match(r"e[+,-][0-9]+", str)
                if aux !== nothing
                    exp_str = " \\cdot 10^{" * string(parse(Int, aux.match[2:end])) * "}"
                    str = replace(str, r"e.*" => exp_str)
                    str = "\$" * str * "\$"
                end

                return str
            else
                return v
            end
        end
    else
        return (v, i, j) -> begin
            @inbounds for k = 1:length(columns)
                if j == columns[k]
                    if typeof(v) <: Number
                        str = sprintf1("%." * string(m_digits[k]) * "g", v)

                        # Check if we have scientific notation.
                        aux = match(r"e[+,-][0-9]+", str)
                        if aux !== nothing
                            exp_str =
                                " \\cdot 10^{" * string(parse(Int, aux.match[2:end])) * "}"
                            str = replace(str, r"e.*" => exp_str)
                            str = "\$" * str * "\$"
                        end

                        return str
                    else
                        return v
                    end
                end
            end

            return v
        end
    end
end

"""
    ft_nomissing(v, i::Int, j::Int)

Replace `missing` with an empty string. If `v` is not `Missing`, then `v` is
returned.
"""
ft_nomissing(v::Missing, i::Int, j::Int) = ""
ft_nomissing(v, i::Int, j::Int) = v

"""
    ft_nonothing(v, i::Int, j::Int)

Replace `nothing` with an empty string. If `v` is not `Nothing`, then `v` is
returned.
"""
ft_nonothing(v::Nothing, i::Int, j::Int) = ""
ft_nonothing(v, i::Int, j::Int) = v

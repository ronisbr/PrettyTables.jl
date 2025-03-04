## Description #############################################################################
#
# Pre-defined formatters.
#
############################################################################################

export fmt__printf, fmt__round, fmt__latex_sn

"""
    fmt__printf(fmt_str::String[, columns::AbstractVector{Int}]) -> Function

Apply the format `fmt_str` (see the `Printf` standard library) to the elements in the
columns specified in the vector `columns`. If `columns` is not specified, the format will be
applied to the entire table.

!!! info

    This formatter will be applied only to the cells that are of type `Number`.
"""
function fmt__printf(fmt_str::String)
    # For efficiency, compute the `Format` object outside.
    fmt = Printf.Format(fmt_str)

    return (v, _, _) -> begin
        !(v isa Number) && return v

        return Printf.format(fmt, v)
    end
end

function fmt__printf(fmt_str::String, columns::AbstractVector{Int})
    # For efficiency, compute the `Format` object outside.
    fmt = Printf.Format(fmt_str)

    return (v, _, j) -> begin
        !(v isa Number) && return v

        for c in columns
            j == c && return Printf.format(fmt, v)
        end

        return v
    end
end

"""
    fmt__round(digits::Int[, columns::AbstractVector{Int}]) -> Function

Round the elements in the columns specified in the vector `columns` to the number of
`digits`. If `columns` is not specified, the rounding will be applied to the entire table.
"""
function fmt__round(digits::Int)
    return (v, _, _) -> begin
        try
            return round(v; digits)
        catch
            return v
        end
    end
end

function fmt__round(digits::Int, columns::AbstractVector{Int})
    return (v, _, j) -> begin
        for c in columns
            if j == c
                try
                    return round(v; digits)
                catch
                    return v
                end
            end
        end

        return v
    end
end

"""
    fmt__latex_sn(m_digits::Int[, columns::AbstractVector{Int}]) -> Function

Format the numbers of the elements in the `columns` to a scientific notation using LaTeX.
If `columns` is not present, the formatting will be applied to the entire table.

The number is first printed using `Printf` functions with the `g` modifier and then
converted to the LaTeX format. The number of digits in the mantissa can be selected by the
argument `m_digits`.

!!! info

    This formatter will be applied only to the cells that are of type `Number`.
"""
function fmt__latex_sn(m_digits::Int)
    # Precompute Format objects.
    fmts = Printf.Format("%." * string(m_digits) * "g")

    return (v, _, _) -> begin
        !(v isa Number) && return v

        str = Printf.format(fmts, v)

        # Check if we have scientific notation.
        aux = match(r"e[+,-][0-9]+", str)

        if !isnothing(aux)
            exp_str = " \\cdot 10^{" * string(parse(Int, aux.match[2:end])) * "}"
            str = replace(str, r"e.*" => exp_str)
            str = "\$" * str * "\$"
        end

        return LatexCell(str)
    end
end

function fmt__latex_sn(m_digits::Int, columns::AbstractVector{Int})
    # Precompute Format objects.
    fmts = Printf.Format("%." * string(m_digits) * "g")

    return (v, _, j) -> begin
        !(v isa Number) && return v

        for c in columns
            j != c && continue

            str = Printf.format(fmts, v)

            # Check if we have scientific notation.
            aux = match(r"e[+,-][0-9]+", str)

            if !isnothing(aux)
                exp_str = " \\cdot 10^{" * string(parse(Int, aux.match[2:end])) * "}"
                str = replace(str, r"e.*" => exp_str)
                str = "\$" * str * "\$"
            end

            return LatexCell(str)
        end

        return v
    end
end

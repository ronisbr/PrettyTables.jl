## Description #############################################################################
#
# Pre-defined formatters.
#
############################################################################################

export fmt__printf, fmt__round, fmt__latex_sn, fmt__excel_stringify


"""
    fmt__printf(fmt_str::String[, columns::AbstractVector{Int}]) -> Function

Apply the format `fmt_str` (see the `Printf` standard library) to the elements in the
columns specified in the vector `columns`. If `columns` is not specified, the format will be
applied to the entire table.

!!! info

    This formatter will be applied only to the cells that are of type `Number`.

# Extended Help

## Examples

```julia-repl
julia> data = [f(a) for a = 0:30:90, f in (sind, cosd, tand)]
4×3 Matrix{Float64}:
 0.0       1.0        0.0
 0.5       0.866025   0.57735
 0.866025  0.5        1.73205
 1.0       0.0       Inf

julia> pretty_table(data; formatters = [fmt__printf("%5.3f")])
┌────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │
├────────┼────────┼────────┤
│  0.000 │  1.000 │  0.000 │
│  0.500 │  0.866 │  0.577 │
│  0.866 │  0.500 │  1.732 │
│  1.000 │  0.000 │    Inf │
└────────┴────────┴────────┘

julia> pretty_table(data; formatters = [fmt__printf("%5.3f", [1, 3])])
┌────────┬──────────┬────────┐
│ Col. 1 │   Col. 2 │ Col. 3 │
├────────┼──────────┼────────┤
│  0.000 │      1.0 │  0.000 │
│  0.500 │ 0.866025 │  0.577 │
│  0.866 │      0.5 │  1.732 │
│  1.000 │      0.0 │    Inf │
└────────┴──────────┴────────┘
```
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

# Extended Help

## Examples

```julia-repl
julia> data = [f(a) for a = 0:30:90, f in (sind, cosd, tand)]
4×3 Matrix{Float64}:
 0.0       1.0        0.0
 0.5       0.866025   0.57735
 0.866025  0.5        1.73205
 1.0       0.0       Inf

julia> pretty_table(data; formatters = [fmt__round(1)])
┌────────┬────────┬────────┐
│ Col. 1 │ Col. 2 │ Col. 3 │
├────────┼────────┼────────┤
│    0.0 │    1.0 │    0.0 │
│    0.5 │    0.9 │    0.6 │
│    0.9 │    0.5 │    1.7 │
│    1.0 │    0.0 │    Inf │
└────────┴────────┴────────┘

julia> pretty_table(data; formatters = [fmt__round(1, [1, 3])])
┌────────┬──────────┬────────┐
│ Col. 1 │   Col. 2 │ Col. 3 │
├────────┼──────────┼────────┤
│    0.0 │      1.0 │    0.0 │
│    0.5 │ 0.866025 │    0.6 │
│    0.9 │      0.5 │    1.7 │
│    1.0 │      0.0 │    Inf │
└────────┴──────────┴────────┘
```
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

The formatted number will be wrapped in the object `LatexCell`. Hence, this formatter only
makes sense if the selected backend is `:latex`.

!!! info

    This formatter will be applied only to the cells that are of type `Number`.

# Extended Help

## Examples

```julia-repl
julia> data = [10.0^(-i + j) for i in 1:6, j in 1:6]
6×6 Matrix{Float64}:
 1.0     10.0     100.0    1000.0   10000.0  100000.0
 0.1      1.0      10.0     100.0    1000.0   10000.0
 0.01     0.1       1.0      10.0     100.0    1000.0
 0.001    0.01      0.1       1.0      10.0     100.0
 0.0001   0.001     0.01      0.1       1.0      10.0
 1.0e-5   0.0001    0.001     0.01      0.1       1.0

julia> pretty_table(data; formatters = [fmt__latex_sn(1)], backend = :latex)
\\begin{tabular}{|r|r|r|r|r|r|}
  \\hline
  \\textbf{Col. 1} & \\textbf{Col. 2} & \\textbf{Col. 3} & \\textbf{Col. 4} & \\textbf{Col. 5} & \\textbf{Col. 6} \\\\
  \\hline
  1 & \$1 \\cdot 10^{1}\$ & \$1 \\cdot 10^{2}\$ & \$1 \\cdot 10^{3}\$ & \$1 \\cdot 10^{4}\$ & \$1 \\cdot 10^{5}\$ \\\\
  0.1 & 1 & \$1 \\cdot 10^{1}\$ & \$1 \\cdot 10^{2}\$ & \$1 \\cdot 10^{3}\$ & \$1 \\cdot 10^{4}\$ \\\\
  0.01 & 0.1 & 1 & \$1 \\cdot 10^{1}\$ & \$1 \\cdot 10^{2}\$ & \$1 \\cdot 10^{3}\$ \\\\
  0.001 & 0.01 & 0.1 & 1 & \$1 \\cdot 10^{1}\$ & \$1 \\cdot 10^{2}\$ \\\\
  0.0001 & 0.001 & 0.01 & 0.1 & 1 & \$1 \\cdot 10^{1}\$ \\\\
  \$1 \\cdot 10^{-5}\$ & 0.0001 & 0.001 & 0.01 & 0.1 & 1 \\\\
  \\hline
\\end{tabular}
```
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

"""
    fmt__excel_stringify(columns)

Create a formatter function that turns data types the Excel backend can't handle into their 
string representation.

The Excel backend can only handle the following data types natively:

    `String`,`Float64`, `Int`, `Bool`, `Dates.Date`, `Dates.Time`, `Dates.DateTime`, `Missing`, 

Passing any other datatypes will cause an error. However, converting these other data types to their 
string representation (using the `string()` function), allows them to pass without an issue.

For example, the following matrix of tuples cannot be handled natively by the Excel backend, 
but using the stringify formatter allows it to be handled successfully as a matrix of strings:

```
julia> matrix = [(i, j) for i in 1:4, j in 1:4]
4×4 Matrix{Tuple{Int64, Int64}}:
 (1, 1)  (1, 2)  (1, 3)  (1, 4)
 (2, 1)  (2, 2)  (2, 3)  (2, 4)
 (3, 1)  (3, 2)  (3, 3)  (3, 4)
 (4, 1)  (4, 2)  (4, 3)  (4, 4)

julia> pt = pretty_table(matrix; backend=:excel, formatters = [fmt__excel_stringify(1:4)])
XLSXFile("blank.xlsx") containing 1 Worksheet
            sheetname size          range
-------------------------------------------------
          prettytable 5x4           A1:D5

julia> pt[1][:]
5×4 Matrix{Any}:
 "Col. 1"  "Col. 2"  "Col. 3"  "Col. 4"
 "(1, 1)"  "(1, 2)"  "(1, 3)"  "(1, 4)"
 "(2, 1)"  "(2, 2)"  "(2, 3)"  "(2, 4)"
 "(3, 1)"  "(3, 2)"  "(3, 3)"  "(3, 4)"
 "(4, 1)"  "(4, 2)"  "(4, 3)"  "(4, 4)"
```
![image|320x500](../../docs/assets/Excel_tuples.png)

"""
function fmt__excel_stringify(args...; kwargs...)
    error("""
    Excel backend requires the XLSX.jl package.
    
    Please install and load it with:
        using Pkg
        Pkg.add("XLSX")
        using XLSX
    
    Then retry your pretty_table call with backend = :excel.
    """)
end

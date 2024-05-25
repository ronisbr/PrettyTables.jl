## Description #############################################################################
#
# Auxiliary functions to pretty print tables.
#
############################################################################################

export @ptconfclean, @ptconf, @pt

# Global configuration object.
const _pt_conf = PrettyTablesConf()

"""
    @ptconfclean()

Clean all global configurations to pretty print tables using the macro `@pt`.
"""
macro ptconfclean()
    ex = :(clear_pt_conf!(PrettyTables._pt_conf))
    return esc(ex)
end

"""
    @ptconf(expr...)

Add configurations in `expr` to be used with the macro `@pt`.

The expression format must be:

    keyword1 = value1 keyword2 = value2 ...

in which the keywords can be any other possible keyword that can be used in the function
`pretty_table`.

!!! warning

    If a keyword is not supported by the function `pretty_table`, then no error message is
    printed when calling `@ptconf`. However, an error will be thrown when `@pt` is called.
"""
macro ptconf(expr...)
    kws = Expr[]

    for ex in expr
        # If the head is :(=), then it must be a configuration. Notice that we
        # will ignore everything that is not an expression like `a = b`.
        if (ex isa Expr) && (ex.head == :(=))
            push!(kws, Expr(:kw, ex.args[1], ex.args[2]))
        end
    end

    ex = :(set_pt_conf!(PrettyTables._pt_conf, $(kws...)))

    return esc(ex)
end

"""
    @pt(expr...)

Pretty print tables in `expr` to `stdout` using the global configurations selected with the
macro `@ptconf`.

Multiple tables can be printed by passing multiple expressions like:

    @pt table1 table2 table3

The user can select the table header by passing the expression:

    :header = [<Vector with the header>]

Notice that the header is valid only for the next printed table. Hence:

    @pt :header = header1 table1 :header = header2 table2 table3

will print `table1` using `header1`, `table2` using `header2`, and `table3` using the
default header.

!!! info

    When more than one table is passed to this macro, then multiple calls to `pretty_table`
    will occur. Hence, the cropping algorithm will behave exactly the same as printing the
    tables separately.

# Examples

```julia
julia> @ptconf tf = tf_simple

julia> @pt :header = ["Time","Velocity"] [1:1:10 ones(10)] :header = ["Time","Position"] [1:1:10 1:1:10]
======= ===========
  Time   Velocity
======= ===========
   1.0        1.0
   2.0        1.0
   3.0        1.0
   4.0        1.0
   5.0        1.0
   6.0        1.0
   7.0        1.0
   8.0        1.0
   9.0        1.0
  10.0        1.0
======= ===========
======= ===========
  Time   Position
======= ===========
     1          1
     2          2
     3          3
     4          4
     5          5
     6          6
     7          7
     8          8
     9          9
    10         10
======= ===========

julia> @pt ones(3,3) + I + [1 2 3; 4 5 6; 7 8 9]
========= ======== =========
  Col. 1   Col. 2   Col. 3
========= ======== =========
     3.0      3.0      4.0
     5.0      7.0      7.0
     8.0      9.0     11.0
========= ======== =========
```
"""
macro pt(expr...)
    exprs  = Expr[]
    header = nothing

    for ex in expr
        # If the head is :(=) and the argument is `:header`, then we must set
        # the header.
        if (ex isa Expr) && (ex.head == :(=)) && (ex.args[1] == :(:header))
            header = esc(ex.args[2])
        # If it is not, then we assume that it is a table to be printed.
        else
            expr = :(pretty_table_with_conf(_pt_conf, $(esc(ex)), header = $header))
            push!(exprs, expr)
            header = nothing
        end
    end

    return Expr(:block, exprs...)
end

# Similar API to Formatting.jl, but using the Printf stdlib (requires Julia 1.6+).
function sprintf1(fmt::AbstractString, x)
    return sprintf1(Printf.Format(fmt), x)
end

function sprintf1(fmt::Printf.Format, x)
    Printf.format(fmt, x)
end

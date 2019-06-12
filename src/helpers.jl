#== # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Auxiliary functions to pretty print tables.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # ==#

export @pt

"""
    macro pt(expr...)

Pretty print tables to `stdout` using the configurations in `expr`.

The expression format must be:

    [<Set of configurations> table]*

in which the set of configurations are expressions like `key = value`. The keys
can be:

* `header`: Select a header for the table.
* `tf`: Select a table format.
* Any other possible keyword that can be used in the function `pretty_table`.

Notice that multiple tables can be printed. Furthermore, the configurations
persist for multiple printing **except for the header**. Hence, for example:

    @pt header = header1 highlighters = hl1 formatter = ft1 table1 highlighters = hl2 table2

will print `table1` using the header `header1` and the configuration
`highlighters = hl1 formatter = ft1` and will print `table2` without header and
using `highlighters = hl2 formatter = ft1`.

# Examples

```julia
julia> @pt tf = simple header = ["Time","Velocity"] [1:1:10 ones(10)] header = ["Time","Position"] [1:1:10 1:1:10]
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
```

# Remarks

When more than one table is passed to this macro, then multiple calls to
`pretty_table` will occur. Hence, the cropping algorithm will behave exactly the
same as printing the tables separately.

"""
macro pt(expr...)
    exprs  = Expr[]
    conf   = Expr[]
    header = nothing
    tf     = nothing

    for ex in expr
        # If the head is :(=), then it must be a configuration.
        if (ex isa Expr) && (ex.head == :(=))
            # Check if we are changing the header.
            if ex.args[1] == :header
                header = esc(ex.args[2])
            # Check if we are changing the table format.
            elseif ex.args[1] == :tf
                tf = esc(ex.args[2])
            else
                # If the configuration already exits, then drop it.
                ind = findall(x -> x.args[1] == ex.args[1], conf)
                deleteat!(conf,ind)
                push!(conf, ex)
            end
        # If it is not, then we assume that it is a table to be printed.
        else
            # Assemble the arguments.
            args = Expr[]
            header != nothing && push!(args, header)
            tf     != nothing && push!(args, tf)

            # Add the other configurations escaping them.
            econf = [esc(c) for c in conf]

            if isempty(args)
                expr = :(pretty_table($(esc(ex)); $(econf...)))
            else
                expr = :(pretty_table($(esc(ex)), $(args...); $(econf...)))
            end

            push!(exprs, expr)
            header = nothing
        end
    end

    return Expr(:block, exprs...)
end

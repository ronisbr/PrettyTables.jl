Alignment
=========

```@meta
CurrentModule = PrettyTables
DocTestSetup = quote
    using PrettyTables
end
```

The keyword `alignment` can be a `Symbol` or a vector of `Symbol`.

If it is a symbol, we have the following behavior:

* `:l` or `:L`: the text of all columns will be left-aligned;
* `:c` or `:C`: the text of all columns will be center-aligned;
* `:r` or `:R`: the text of all columns will be right-aligned;
* Otherwise it defaults to `:r`.

If it is a vector, then it must have the same number of symbols as the number of
columns in `data`. The *i*-th symbol in the vector specify the alignment of the
*i*-th column using the same symbols as described previously.

```jldoctest
julia> data = Any[ f(a) for a = 0:30:90, f in (sind, cosd, tand)];

julia> pretty_table(data; alignment=:l)
┌──────────┬──────────┬─────────┐
│ Col. 1   │ Col. 2   │ Col. 3  │
├──────────┼──────────┼─────────┤
│ 0.0      │ 1.0      │ 0.0     │
│ 0.5      │ 0.866025 │ 0.57735 │
│ 0.866025 │ 0.5      │ 1.73205 │
│ 1.0      │ 0.0      │ Inf     │
└──────────┴──────────┴─────────┘

julia> pretty_table(data; alignment=[:l, :c, :r])
┌──────────┬──────────┬─────────┐
│ Col. 1   │  Col. 2  │  Col. 3 │
├──────────┼──────────┼─────────┤
│ 0.0      │   1.0    │     0.0 │
│ 0.5      │ 0.866025 │ 0.57735 │
│ 0.866025 │   0.5    │ 1.73205 │
│ 1.0      │   0.0    │     Inf │
└──────────┴──────────┴─────────┘
```

!!! note
    The `alignment` keyword is supported in all back-ends.

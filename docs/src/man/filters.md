Filters
=======

```@meta
CurrentModule = PrettyTables
DocTestSetup = quote
    using PrettyTables
end
```

It is possible to specify filters to filter the data that will be printed. There
are two types of filters: the row filters, which are specified by the keyword
`filters_row`, and the column filters, which are specified by the keyword
`filters_col`.

The filters are a tuple of functions that must have the following signature:

```julia
f(data, i)::Bool
```

in which `data` is a pointer to the matrix that is being printed and `i` is the
i-th row in the case of the row filters or the i-th column in the case of column
filters. If this function returns `true` for `i`, then the i-th row (in case of
`filters_row`) or the i-th column (in case of `filters_col`) will be printed.
Otherwise, it will be omitted.

A set of filters can be passed inside of a tuple. Notice that, in this case,
**all filters** for a specific row or column must be return `true` so that it
can be printed, *i.e* the set of filters has an `AND` logic.

If the keyword is set to `nothing`, which is the default, then no filtering will
be applied to the row and/or column.

!!! note
    The filters do not change the row and column numbering for the others
    modifiers such as column width specification, formatters, and highlighters.
    Thus, for example, if only the 4-th row is printed, then it will also be
    referenced inside the formatters and highlighters as 4 instead of 1.

## Example

Given a matrix `data`, let's suppose that is desired to print:

* only the 5-th and 6-th column; and
* only the rows in which the 5-th and 6-th columns are positive.

Then we can use one of the following approaches:

```julia
f_c(data, i)  = i in (5, 6)
f_r1(data, i) = data[i, 5] >= 0
f_r2(data, i) = data[i, 6] >= 0
```

and set `filters_col = (f_c,)` and `filters_row = (f_r1, f_r2)`, or


```julia
f_c(data, i) = i in (5, 6)
f_r(data, i) = (data[i, 5] >= 0) && (data[i, 6] >= 0)
```

and set `filters_col = (f_c,)` and `filters_row = (f_r,)`.

!!! note
    The keywords related to the filters are supported in all back-ends.

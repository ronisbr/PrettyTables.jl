PrettyTables.jl Changelog
=========================

Version 0.8.1
-------------

- ![Feature][badge-feature] The back-end is now automatically inferred from the
  table type keyword (`tf`). Thanks @DhruvaSambrani. (PRs [#41][gh-pr-41] and
  [#42][gh-pr-42], Issue [#40][gh-issue-40])
- ![Bugfix][badge-bugfix] LaTeX back-end was failing when printing a table with
  an UTF-8 character on it. (Issue [#38][gh-issue-38])
- ![Enhancement][badge-enhancement]
  [Tables.jl](https://github.com/JuliaData/Tables.jl) API is now the priority
  when printing tables. This means that if an object complies with this API,
  then it will be used, even if the object is also derived from a supported type
  like `AbstractVecOrMat`. (Issue [#28][gh-issue-28])

Version 0.8.0
-------------

- ![Feature][badge-feature] The keyword `standalone = false` can be used with
  HTML back-end to print only the table.
- ![Feature][badge-feature] An experimental version of a LaTeX back-end is now
  available. Notice that it still lacks tests and many bugs are expected.
- ![Feature][badge-feature] A table can now be added to a text file using the
  function `include_pt_to_file`. You can define marks that will be used to place
  the table in the file. It works with all back-ends.
- ![Bugfix][badge-bugfix] The support for
  [Tables.jl](https://github.com/JuliaData/Tables.jl) API were fixed for cases
  in which `Tables.columns` did not return a matrix. Thanks @pdeffebach for the
  PR! (Issue [#24][gh-issue-24]) (PR [#25][gh-pr-25])
- ![Info][badge-info] End of support of Julia 1.2. The supported versions are
  1.0 and 1.3.

Version 0.7.0
-------------

- ![Feature][badge-feature] The keyword `columns_width` can be used to select
  the desired width for each column.
- ![Feature][badge-feature] Add the possibility to automatically wrap the table
  cells when using the text back-end and the column size is fixed. This can be
  triggered by the keyword `autowrap`. (Issue [#21][gh-issue-21])
- ![Feature][badge-feature] Initial version of HTML back-end. Notice that this
  is the first version with a minimal set of features. This implementation
  should be considered beta.
- ![Bugfix][badge-bugfix] The character `"` is not escaped anymore when printing
  cells of type `AbstractString`. (Issue [#22][gh-issue-22])
- ![Deprecation][badge-deprecation] When using the text back-end, passing the
  table format as an option to `pretty_table` function is now deprecated. The
  table format in all back-ends must be passed using the keyword `tf`. Thus, for
  example, `pretty_table(data, unicode_rounded)` must be converted to
  `pretty_table(data, tf = unicode_rounded)`.

Version 0.6.0
-------------

- ![Feature][badge-feature] The format of the horizontal line in the table,
  which are drawn using the option `hlines`, can now be selected using the
  keyword `hlines_format`.
- ![Feature][badge-feature] The alignment of a single cell can now be changed
  regardless of the column alignment. This can be achieve by the keyword
  `cell_alignment`.
- ![Feature][badge-feature] The line between the header and the data can now be
  hide using the variable `header_line` of the structure `PrettyTableFormat`.
  (Issue [#15][gh-issue-15])
- ![Feature][badge-feature] New predefined highlighters: `hl_cell`, `hl_col`,
  `hl_row`, which can be used to apply highlights to single cells or to entire
  columns or rows, respectively.
- ![Bugfix][badge-bugfix] The formatter `ft_printf` is now only applied to cells
  that are of type `Number`. (Issue [#19][gh-issue-19])
- ![Enhancement][badge-enhancement] The formatter `ft_printf` can now receive
  one integer if the user wants to format only a single column.
- ![Info][badge-info] End of support of Julia 1.1. The supported versions are
  1.0 and 1.2.

Version 0.5.1
-------------

- ![Bugfix][badge-bugfix] DataFrames with strings were being printed surrounded
  by quotes, which were leading to a wrong escaping. (Issue [#16][gh-issue-16])

Version 0.5.0
-------------

- ![Feature][badge-feature] The macro `@pt` can be used to print tables with
  global configurations. Those configurations can be set by the macro `@ptconf`.
- ![Feature][badge-feature] There is now the option `nosubheader` to suppress
  printing sub-headers. This can be useful when printing `DataFrame` or `Dict`
  and it is desired to hide the types of the columns. (Issue [#14][gh-issue-14])
- ![Enhancement][badge-enhancement] PrettyTables.jl is now compatible with
  Tables.jl 0.2. It means that if an elements that is passed to `pretty_table`
  is not one of those natively supported, then it will call `Tables.columns` to
  automatically convert it. If it fails, than Tables.jl will throw an error
  instead of PrettyTables.jl. (Issue [#13][gh-issue-13])
- ![Enhancement][badge-enhancement] If only one highlighter is wanted, then an
  instance of `Highlighter` can now be directly passed to the keyword
  `highlighters`, *i.e.* it does not must be a `Tuple` anymore.

Version 0.4.2
-------------

- Dummy release to add `Project.toml` and switch to
  [Registrator.jl](https://github.com/JuliaComputing/Registrator.jl).

Version 0.4.1
-------------

- ![Enhancement][badge-enhancement] If the user wants to crop the output, then
  the printing function does not need to process the entire matrix. Thus, now it
  will only process the columns and rows that will be actually printed, which
  yielded a huge performance gain when big matrices are printed with crop on.
- ![Bugfix][badge-bugfix] Matrices with `nothing` and `missing` are now
  correctly printed.

Version 0.4.0
-------------

- ![BREAKING][badge-breaking]![Feature][badge-feature] The text can now be
  horizontally and / or vertically cropped to fit the available screen size.
  Notice that, by default, the screen size is obtained and the text is cropped,
  which is a breaking change compared to the previous version. This behavior can
  be modified by the keywords `crop` and `screen_size`.
- ![Feature][badge-feature] `Vector` can now be printed natively.
- ![Feature][badge-feature] The user can now specify filters for the data using
  the keywords `filters_col` and `filters_row`, so that only a partial subset of
  the input is printed.
- ![Feature][badge-feature] `Dict` can now be printed natively. (Issue
  [#6][gh-issue-6])
- ![Bugfix][badge-bugfix] The formatting was wrong when printing a table with
  sub-headers and the row number column. (Issue [#9][gh-issue-9])
- ![Bugfix][badge-bugfix] The row number column size is now correctly computed
  when the header is omitted. (Issue [#10][gh-issue-10])

Version 0.3.1
-------------

- ![Enhancement][badge-enhancement] `Vector` was replaced by `AbstractVector` in
  predefined formatters. Hence, it is now possible to use range notation. Thus,
  for example `ft_printf("%4.2f", [2,3,4,5,6,7,8,9,10])` can now be rewritten as
  `ft_printf("%4.2f", 2:10)`. (PR [#8][gh-pr-8])

Version 0.3.0
-------------

- ![BREAKING][badge-breaking]![Feature][badge-feature] Every styling option is
  now handled by [Crayons.jl](https://github.com/KristofferC/Crayons.jl).
- ![Bugfix][badge-bugfix] Strings are escaped before printing the header. This
  avoids problems in formatting if escape sequences are present. (Issue
  [#4][gh-issue-4])
- ![Feature][badge-feature] The text inside the cells can have multiple lines.
- ![Feature][badge-feature] The header can be suppressed when printing the
  table. (Issue [#3][gh-issue-3])
- ![Enhancement][badge-enhancement] Many performance improvements.
- ![Enhancement][badge-enhancement] The `hlines` keywords can accept ranges.
  (PR [#5][gh-pr-5])
- ![Enhancement][badge-enhancement] The pre-defined formatter `ft_printf` uses
  the function `sprintf1` from the package
  [Formatting.jl](https://github.com/JuliaIO/Formatting.jl) instead of the macro
  `@sprintf`, leading to a huge performance gain. (Issue [#7][gh-issue-7])

Version 0.2.1
-------------

- ![Bugfix][badge-bugfix] The version of the package was not updated on
  `Project.toml` in the last release.

Version 0.2.0
-------------

- ![BREAKING][badge-breaking] The header is not assumed to be on the data
  anymore. It is now specified by a new parameter called `header`.
- ![Bugfix][badge-bugfix] Only `Matrix{Any}` was allowed to be printed.
- ![Feature][badge-feature] Support for highlighters.
- ![Feature][badge-feature] Some pre-defined highlighters were added.
- ![Feature][badge-feature] Some pre-defined formatters were added.
- ![Feature][badge-feature] Initial support for Tables.jl API.
- ![Feature][badge-feature] New package documentation using Documenter.jl.
- ![Feature][badge-feature] Support for sub-headers.
- ![Feature][badge-feature] There is now an option called `hlines` to draw
  horizontal lines between selected rows.
- ![Enhancement][badge-enhancement] New pre-defined formats: `unicode_rounded`
  and `borderless`.

Version 0.1.0
-------------

- Initial version.

[badge-breaking]: https://img.shields.io/badge/BREAKING-red.svg
[badge-deprecation]: https://img.shields.io/badge/Deprecation-orange.svg
[badge-feature]: https://img.shields.io/badge/Feature-green.svg
[badge-enhancement]: https://img.shields.io/badge/Enhancement-blue.svg
[badge-bugfix]: https://img.shields.io/badge/Bugfix-purple.svg
[badge-info]: https://img.shields.io/badge/Info-gray.svg

[gh-issue-3]: https://github.com/ronisbr/PrettyTables.jl/issues/3
[gh-issue-4]: https://github.com/ronisbr/PrettyTables.jl/issues/4
[gh-issue-6]: https://github.com/ronisbr/PrettyTables.jl/issues/6
[gh-issue-7]: https://github.com/ronisbr/PrettyTables.jl/issues/7
[gh-issue-9]: https://github.com/ronisbr/PrettyTables.jl/issues/9
[gh-issue-10]: https://github.com/ronisbr/PrettyTables.jl/issues/10
[gh-issue-13]: https://github.com/ronisbr/PrettyTables.jl/issues/13
[gh-issue-14]: https://github.com/ronisbr/PrettyTables.jl/issues/14
[gh-issue-15]: https://github.com/ronisbr/PrettyTables.jl/issues/15
[gh-issue-16]: https://github.com/ronisbr/PrettyTables.jl/issues/16
[gh-issue-19]: https://github.com/ronisbr/PrettyTables.jl/issues/19
[gh-issue-21]: https://github.com/ronisbr/PrettyTables.jl/issues/21
[gh-issue-22]: https://github.com/ronisbr/PrettyTables.jl/issues/22
[gh-issue-24]: https://github.com/ronisbr/PrettyTables.jl/issues/24
[gh-issue-28]: https://github.com/ronisbr/PrettyTables.jl/issues/28
[gh-issue-38]: https://github.com/ronisbr/PrettyTables.jl/issues/38
[gh-issue-42]: https://github.com/ronisbr/PrettyTables.jl/issues/42

[gh-pr-5]: https://github.com/ronisbr/PrettyTables.jl/pull/5
[gh-pr-8]: https://github.com/ronisbr/PrettyTables.jl/pull/8
[gh-pr-25]: https://github.com/ronisbr/PrettyTables.jl/pull/25
[gh-pr-41]: https://github.com/ronisbr/PrettyTables.jl/pull/41
[gh-pr-42]: https://github.com/ronisbr/PrettyTables.jl/pull/42

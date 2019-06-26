PrettyTables.jl Changelog
=========================

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

[gh-pr-5]: https://github.com/ronisbr/PrettyTables.jl/pull/5
[gh-pr-8]: https://github.com/ronisbr/PrettyTables.jl/pull/8

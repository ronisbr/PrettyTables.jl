PrettyTables.jl Changelog
=========================

Version 1.3.1
-------------

- ![Bugfix][badge-bugfix] The function `pretty_table` was returning an error
  when the alignment regex anchor contained a columns that does not exists.
  (Issue [#154][gh-issue-154])

Version 1.3.0
-------------

- ![Bugfix][badge-bugfix] The alignment anchor regex algorithm was not computing
  the alignment row correctly in lines with UTF-8 symbols. (Issue
  [#147][gh-issue-153])
- ![Feature][badge-feature] Two predefined formatters were added: `ft_nomissing`
  and `ft_nonothing`. They can be used to transform, respectively, `missing` and
  `nothing` into an empty string. (Issue [#150][gh-issue-150])

Version 1.2.3
-------------

- ![Bugfix][badge-bugfix] We were not considering the column width configuration
  (`maximum_columns_width`, `minimum_columns_width`, etc.) when computing the
  number of columns we can display in the available size. This behavior was
  leading to incorrect cropping in many situation. (Issue [#149][gh-issue-149])

Version 1.2.2
-------------

- ![Bugfix][badge-bugfix] Newlines must be kept in `AnsiTextCell`. Otherwise, it
  will be impossible to align text between those cells.

Version 1.2.1
-------------

- ![Deprecation][badge-deprecation] The deprecations removed in v1.2.0 were
  added again so that this new version is not breaking.
  (Issue [#146][gh-issue-146])

Version 1.2.0
-------------

- ![Deprecation][badge-deprecation] All deprecations introduced in v0.12 are now
  removed.
- ![Feature][badge-feature] The HTML decoration can now used any custom style.
  (PR [#135][gh-pr-135])
- ![Feature][badge-feature] The HTML backend now has an option to minify the
  output.
- ![Feature][badge-feature] The HTML backend now has the option
  `allow_html_in_cells` so that the user can use HTML code inside the table.
- ![Feature][badge-feature] The alignment option in HTML backend can now be set
  to `:n` so that no alignment annotation is added.
- ![Feature][badge-feature] The option `HTML` can be passed to `pretty_table` so
  that an HTML object is returned. (Issue [#130][gh-issue-130])
- ![Feature][badge-feature] The text backend has now a new custom cell called
  `AnsiTextCell`, which allows adding a cell with ANSI escape sequences inside
  the table. (Issue [#142][gh-issue-142]) (PR [#143][gh-pr-143])
- ![Feature][badge-feature] The keyword `color` can now be used when converting
  a table to string to render the ANSI escape sequences.
- ![Enhancement][badge-enhancement] The HTML rendering now uses the section
  `thead` and `tbody`.
- ![Enhancement][badge-enhancement] Some special characters in HTML are now
  escaped to ensure a correct rendering.
- ![Enhancement][badge-enhancement] The vectors related to filtering are now set
  to `UnitRange` if filtering is not present. Hence, the performance when
  printing huge tables cropped to the display size is highly improved by
  avoiding allocating big vectors. (Issue [#140][gh-issue-140]) (PR
  [#144][gh-issue-144])
- ![Bugfix][badge-bugfix] The horizontal line selection is now consistent if the
  vertical cropping is set to `:middle`. (Issue [#133][gh-issue-133])

Version 1.1.0
-------------

- ![Feature][badge-feature] The text backend now supports custom text cells that
  can have escape characters to apply, for example, decorations. The custom cell
  `URLTextCell` is bundled with PrettyTables.jl to add hyperlinks to text using
  the escape sequence `\e]8`. (Issue [#129][gh-issue-129])
- ![Bugfix][badge-bugfix] The character `%` is now escaped in LaTeX. (Issue
  [#125][gh-issue-125])

Version 1.0.1
-------------

- ![Bugfix][badge-bugfix] The alignment regex keys are now sorted before
  processing. This introduces a slight delay, but avoid a huge wait time for
  very large tables. (Ref:
  https://github.com/JuliaData/DataFrames.jl/issues/2739)

Version 1.0.0
-------------

In this version, the API of text backend is stabilized. It means that current
functionality will always work during the lifespan of v1. There can be new
features, but none will be breaking. The only exception is if Julia printing
system has a breaking change, which is allowed.

The HTML and LaTeX APIs **are not** stabilized. They **can** and will likely
change during the lifespan of v1. However, any breaking change will only occur
when the minor version is bumped. Those two backend must be considered **beta**.

- ![Enhancement][badge-enhancement] Any `AbstractDict` can now be printed.

Verison 0.12.1
--------------

- ![Bugfix][badge-bugfix] The minimum column width must be 1, otherwise
  `pretty_table` will crash when cropping an empty column in text backend.
  (Issue [#118][gh-issue-118])
- ![Enhancement][badge-enhancement] Some despecializations were performed and
  type instabilities were fixed, leading to a slightly performance increase.

Version 0.12.0
--------------

- ![Deprecation][badge-deprecation]![Enhancement][badge-enhancement] The backend
  selection is not handled by a `Symbol` anymore. It is now selected using a
  `Val`. Hence, `backend = :text` must be replaced by `backend = Val(:text)`.
  The old API still works but it is marked as deprecated and will be removed in
  the next version. This drastically reduced the time to print the first table
  in LaTeX and HTML backends.
- ![Deprecation][badge-deprecation]![Enhancement][badge-enhancement] The header
  is not selected by an argument anymore, but by a keyword called `header`. The
  format has also changed. It must be now a tuple of vectors instead of a
  matrix. The first vector is the header whereas the others are the subheaders.
  The old API still works but it is marked as deprecated and will be removed in
  the next version.
- ![Enhancement][badge-enhancement] Many internal code enhancements allowed to
  improve a lot the performance (despecializations, type instabilities fixes,
  code refactoring to avoid unnecessary allocations, tweaking `@inline`
  annotations, etc.). (Issue [#116][gh-issue-116])
- ![Enhancement][badge-enhancement] The package now has a precompilation script
  that reduced a lot the time to print the first table in all backends.
- ![Info][badge-info] End of support of Julia 1.5. The supported versions are
  1.0 and 1.6.

Version 0.11.1
--------------

- ![Bugfix][badge-bugfix] In specific situations, the algorithm that aligns
  columns based on regexes was trying to align columns that were not printed,
  leading to segmentation fault. (Issue [#112][gh-issue-112])

Version 0.11.0
--------------

- ![BREAKING][badge-breaking] By default, all the cells are now rendered using
  the option `:limit => true` of `IOContext`. To return to the old behavior, use
  `limit_printing = false`.
- ![Feature][badge-feature] HTML backend now supports row names.
- ![Feature][badge-feature] LaTeX backend now supports row names.
- ![Feature][badge-feature] A new LaTeX pre-defined format was added:
  `tf_latex_modern`.
- ![Feature][badge-feature] A new LaTeX pre-defined format was added:
  `tf_latex_booktabs`.
- ![Feature][badge-feature] The wrap table environment of LaTeX backend can now
  be changed using the keyword `wrap_table_environment`.
- ![Feature][badge-feature] A new table type of LaTeX backend was added:
  `:array`.
- ![Feature][badge-feature] In Text backend, it is now possible to align the
  column cells using regexes (see `alignment_regex_anchor`).
- ![Feature][badge-feature] It is now possible to select the table label in
  LaTeX backend. (Issue [#103][gh-issue-103])
- ![Enhancement][badge-enhancement] LaTeX tables can now control whether to use
  the `table` environment or not.
- ![Enhancement][badge-enhancement] HTML classes in CSS are now surrounded by
  quotes.
- ![Enhancement][badge-enhancement] An unnecessary space in HTML tags was
  removed.
- ![Enhancement][badge-enhancement] The color of omitted cell text in Text
  backend was changed from red to cyan. (Issue [#94])
- ![Enhancement][badge-enhancement] The compat bounds of Reexport.jl was
  updated. (Issue [#105][gh-issue-105])
- ![Bugfix][badge-bugfix] PrettyTables.jl now support Tables.jl that returns
  tuples as columns. (Issue [#90][gh-issue-90])
- ![Bugfix][badge-bugfix] The option `sortkeys` can now be used when printing
  dictionaries using HTML backend.
- ![Bugfix][badge-bugfix] The first header is now correctly set when using
  `longtable` in LaTeX backend, avoiding multiple entries in list of tables.
  (Issue [#95][gh-issue-95])
- ![Bugfix][badge-bugfix] The formatter `ft_latex_sn` now only modifies
  `Number`.
- ![Bugfix][badge-bugfix] The arguments of `@ptconf` was not being escaped.
  (Issue [#107][gh-issue-107])

Version 0.10.1
--------------

- ![Bugfix][badge-bugfix] The cell width computation when the column has a
  maximum allowed size was fixed. (Issue [#93][gh-issue-93])

Version 0.10.0
--------------

- ![BREAKING][badge-breaking] `same_column_size` was renamed to
  `equal_columns_width`.
- ![BREAKING][badge-breaking] Remove dependency Parameters.jl. This reduced the
  loading time in 30% but some features related to structure copying are now
  missing. (Issue [#79][gh-issue-79])
- ![BREAKING][badge-breaking] All table format variables now has the prefix
  `tf_`. This was required to avoid naming conflicts since some variables like
  `matrix` have common names.
- ![BREAKING][badge-breaking] `screen_size` was renamed to `display_size`.
- ![BREAKING][badge-breaking]![Feature][badge-feature] If a table is cropped in
  text back-end, then a summary indicating the number of omitted rows and
  columns is now printed. This can be disable by the option
  `show_omitted_cell_summary`.
- ![BREAKING][badge-breaking]![Enhancement][badge-enhancement] PrettyTables.jl
  now uses compact printing by default.
- ![BREAKING][badge-breaking]![Enhancement][badge-enhancement] LaTeX tables when
  using `tabular` is now wrapped inside a `table` environment.
- ![BREAKING][badge-breaking] PrettyTables.jl does not print trailing spaces
  anymore.
- ![Feature][badge-feature] Option `crop_subheader` in text back-end. If this
  option is `true`, PrettyTables.jl neglects the subheader length when computing
  the row size, cropping it if necessary.
- ![Feature][badge-feature] Option `minimum_columns_width` in text back-end.
  This option allows the user the specify the minimum allowed size of each
  column.
- ![Feature][badge-feature] Option `maximum_columns_width` in text back-end.
  This option allows the user the specify the maximum allowed size of each
  column.
- ![Feature][badge-feature] Option `title`. It is now possible to define the
  table title in all back-ends. (Issue [#32][gh-issue-32])
- ![Feature][badge-feature] Header cells can now be aligned independently from
  the column alignment. (Issue [#66][gh-issue-66])
- ![Feature][badge-feature] Option `hlines` in LaTeX back-end. The user can now
  define where they want horizontal lines in the LaTeX back-end. (Issue
  [#70][gh-issue-70])
- ![Feature][badge-feature] Option `cell_first_line_only`. If `true`, then only
  the first line of the cells are printed.
- ![Feature][badge-feature] Option `row_number_alignment` in text back-end. This
  option can be used to select the alignment of the row number column in text
  back-end.
- ![Feature][badge-feature] PrettyTables.jl can now render Markdown cells in all
  back-ends. (PR [#63][gh-pr-63] and other commits)
- ![Feature][badge-feature] Option `crop_num_lines_at_beginning` in text
  back-end. This option defines how many lines are skipped at the beginning when
  cropping the table.
- ![Feature][badge-feature] Option `newline_at_end` in text back-end. If
  `false`, then the table is printed without a newline character at end.
- ![Feature][badge-feature] Option `continuation_row_alignment` in text
  back-end. This option allows the user to select the alignment of the
  continuation row.
- ![Feature][badge-feature] Option `row_number_column_title`. This selects the
  title of the row number column.
- ![Feature][badge-feature] A new configuration system is added so that the user
  can create structures storing printing configurations to be reused.
- ![Feature][badge-feature] PrettyTables.jl can now use the function `print` or
  `show` to render the cells. This is selected by the keyword `renderer`.
- ![Feature][badge-feature] Option `ellipsis_line_skip` in text back-end. This
  option configures how many lines are skipped when showing ellipsis to indicate
  that the lines were cropped.
- ![Feature][badge-feature] Text back-end can now crop a table in the middle.
  The behavior can be selected by the keyword `vcrop_mode`.
- ![Enhancement][badge-enhancement] PrettyTables.jl can now handle UTF-8 strings
  with variable character size.
- ![Enhancement][badge-enhancement] PrettyTables.jl now supports `#undef` cells.
- ![Enhancement][badge-enhancement] A lot of optimizations were performed to
  decrease the time to print the first table, which is now almost 45% less.
- ![Enhancement][badge-enhancement] LaTeX output is now indented.
- ![Enhancement][badge-enhancement] HTML output is now indented.
- ![Enhancement][badge-enhancement] The types when printing Tables.jl now has a
  compact representation.
- ![Enhancement][badge-enhancement] `show_row_number` is now available in all
  back-ends.
- ![Enhancement][badge-enhancement] Revamp of internal mechanism of text
  back-end, leading to a much more organized code base.
- ![Bugfix][badge-bugfix] The original data is now passed to highlighters and
  filters when the table complies with Tables.jl API. (Issue [#65][gh-issue-65])
- ![Bugfix][badge-bugfix] LaTeX alignment was wrong in filtered columns.
- ![Bugfix][badge-bugfix] Fix row name crayons in text back-end. (Issue
  [#68][gh-issue-68])
- ![Bugfix][badge-bugfix] Do not throw an error is a table is empty.
- ![Info][badge-info] End of support of Julia 1.4. The supported versions are
  1.0 and 1.5.

Version 0.9.1
-------------

- ![Feature][badge-feature] The option `overwrite` was added to the text
  back-end. It deletes the same amount of lines that will be printed. This can
  be used to provide a way to display a table that updates with time. (PR
  [#56][gh-pr-56])
- ![Enhancement][badge-enhancement] The object that complies with Table.jl API
  can now return any `AbstractVector` as column or row names. (PR
  [#53][gh-pr-53] and [#54][gh-pr-54])

Version 0.9.0
-------------

- ![BREAKING][badge-breaking]![Feature][badge-feature] The table format of the
  text back-end now has the variable `vlines` which defines the vertical lines
  that should be drawn by default. In this case, the variables `left_border` and
  `right_border` were removed because they were not necessary anymore.
- ![BREAKING][badge-breaking]![Feature][badge-feature] The compatibility with
  [Tables.jl](https://github.com/JuliaData/Tables.jl) API was improved. Now,
  tables without a schema can be printed. Furthermore, if a table has a schema
  but the user pass a header, then the user's header will be used instead. Thus,
  this can be breaking. (Issue [#45][gh-issue-45])
- ![BREAKING][badge-breaking]![Enhancement][badge-enhancement] The behavior of
  the keyword `hlines` was modified in text back-end. Now, it can be used to
  draw **any** horizontal line, including the bottom, header, and top lines. A
  variable also named `hlines` was added to the structure `TextFormat` to
  defined which horizontal lines should be drawn by default. Thus, the variables
  `top_line`, `header_line`, and `bottom_line` of the same structure were
  removed since they were not necessary anymore. Furthermore, the old behavior
  of `hlines` and `hlines_format` can be replicated in this version using
  `body_hlines` and `body_hlines_format`, respectively.
- ![BREAKING][badge-breaking]![Enhancement][badge-enhancement] The vertical
  lines behavior in LaTeX back-end was modified to match the behavior selected
  for the text back-end. Thus, the keyword `row_number_vline` was removed, since
  it was not necessary anymore.
- ![Deprecation][badge-deprecation]![Enhancement][badge-enhancement] The API of
  formatters was drastically change to improve the consistency of the package.
  Now, as we have in `highlighters`, the formatters are composed of a function
  or a tuple of functions with the signature `f(value,i,j)`, where `value` is
  the cell value that must be formatted, `i` is the row number, and `j` is the
  column number. These function must return the formatted value for the cell
  `(i,j)`. Since it is now possible to define multiple formatters, the keyword
  name was changed from `formatter` to `formatters`. The old API still works,
  but it marked as deprecated.
- ![Feature][badge-feature] The vertical lines in text back-end can now be
  controlled by the keyword `vlines`. (Issue [#46][gh-issue-46])
- ![Feature][badge-feature] The option `row_names` can be used to append a
  column to the left of the table with the names of the columns.
- ![Enhancement][badge-enhancement] The `highlighters` format of text back-end
  was improved. The user can now create highlighters that will dynamically apply
  `crayons` depending on the data value and the cell coordinate, as it was
  possible with the LaTeX and HTML back-ends.
- ![Enhancement][badge-enhancement] The API of `cell_alignment` was changed to
  improve the consistency of the package. Now, as we have in `highlighters`, the
  `cell_alignment` must be a function or a tuple of functions with the signature
  `f(data,i,j)`, where `data` is the matrix that is being printed, `i` is the
  row number, and `j` is the column number. These function must return the
  alignment symbol for the cell `(i,j)`. For convenience, the old API using
  dictionaries is still available for the simple cases.
- ![Info][badge-info] End of support of Julia 1.3. The supported versions are
  1.0 and 1.4.

Version 0.8.4
-------------

- ![Enhancement][badge-enhancement] Improvements in the documentation of
  functions and macros.

Version 0.8.3
-------------

- ![Feature][badge-feature] The method `pretty_table(String, ...)` can be used
  to return the printed table as a string. Furthermore, all the tests were
  modified to use this function instead of `sprint`. (Issue [#29][gh-issue-29])

Version 0.8.2
-------------

- ![Feature][badge-feature] The table format `matrix` was added to the text and
  HTML back-ends. Thanks @DhruvaSambrani. (PR [#39][gh-pr-39], Issue
  [#33][gh-issue-33])

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
[gh-issue-29]: https://github.com/ronisbr/PrettyTables.jl/issues/29
[gh-issue-32]: https://github.com/ronisbr/PrettyTables.jl/issues/32
[gh-issue-33]: https://github.com/ronisbr/PrettyTables.jl/issues/33
[gh-issue-38]: https://github.com/ronisbr/PrettyTables.jl/issues/38
[gh-issue-40]: https://github.com/ronisbr/PrettyTables.jl/issues/40
[gh-issue-45]: https://github.com/ronisbr/PrettyTables.jl/issues/45
[gh-issue-46]: https://github.com/ronisbr/PrettyTables.jl/issues/46
[gh-issue-65]: https://github.com/ronisbr/PrettyTables.jl/issues/65
[gh-issue-66]: https://github.com/ronisbr/PrettyTables.jl/issues/66
[gh-issue-68]: https://github.com/ronisbr/PrettyTables.jl/issues/68
[gh-issue-70]: https://github.com/ronisbr/PrettyTables.jl/issues/70
[gh-issue-79]: https://github.com/ronisbr/PrettyTables.jl/issues/79
[gh-issue-90]: https://github.com/ronisbr/PrettyTables.jl/issues/90
[gh-issue-95]: https://github.com/ronisbr/PrettyTables.jl/issues/95
[gh-issue-103]: https://github.com/ronisbr/PrettyTables.jl/issues/103
[gh-issue-105]: https://github.com/ronisbr/PrettyTables.jl/issues/105
[gh-issue-107]: https://github.com/ronisbr/PrettyTables.jl/issues/107
[gh-issue-112]: https://github.com/ronisbr/PrettyTables.jl/issues/112
[gh-issue-116]: https://github.com/ronisbr/PrettyTables.jl/issues/116
[gh-issue-118]: https://github.com/ronisbr/PrettyTables.jl/issues/118
[gh-issue-125]: https://github.com/ronisbr/PrettyTables.jl/issues/125
[gh-issue-129]: https://github.com/ronisbr/PrettyTables.jl/issues/129
[gh-issue-130]: https://github.com/ronisbr/PrettyTables.jl/issues/130
[gh-issue-133]: https://github.com/ronisbr/PrettyTables.jl/issues/133
[gh-issue-140]: https://github.com/ronisbr/PrettyTables.jl/issues/140
[gh-issue-142]: https://github.com/ronisbr/PrettyTables.jl/issues/142
[gh-issue-146]: https://github.com/ronisbr/PrettyTables.jl/issues/146
[gh-issue-149]: https://github.com/ronisbr/PrettyTables.jl/issues/149
[gh-issue-150]: https://github.com/ronisbr/PrettyTables.jl/issues/150
[gh-issue-153]: https://github.com/ronisbr/PrettyTables.jl/issues/153
[gh-issue-154]: https://github.com/ronisbr/PrettyTables.jl/issues/154

[gh-pr-5]: https://github.com/ronisbr/PrettyTables.jl/pull/5
[gh-pr-8]: https://github.com/ronisbr/PrettyTables.jl/pull/8
[gh-pr-25]: https://github.com/ronisbr/PrettyTables.jl/pull/25
[gh-pr-39]: https://github.com/ronisbr/PrettyTables.jl/pull/39
[gh-pr-41]: https://github.com/ronisbr/PrettyTables.jl/pull/41
[gh-pr-42]: https://github.com/ronisbr/PrettyTables.jl/pull/42
[gh-pr-53]: https://github.com/ronisbr/PrettyTables.jl/pull/53
[gh-pr-54]: https://github.com/ronisbr/PrettyTables.jl/pull/54
[gh-pr-56]: https://github.com/ronisbr/PrettyTables.jl/pull/56
[gh-pr-63]: https://github.com/ronisbr/PrettyTables.jl/pull/63
[gh-pr-135]: https://github.com/ronisbr/PrettyTables.jl/pull/135
[gh-pr-140]: https://github.com/ronisbr/PrettyTables.jl/pull/140
[gh-pr-143]: https://github.com/ronisbr/PrettyTables.jl/pull/143

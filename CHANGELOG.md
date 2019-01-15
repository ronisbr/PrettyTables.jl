PrettyTables.jl Changelog
=========================

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

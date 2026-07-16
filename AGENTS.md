# Repository Instructions

## Package Structure

- Treat `src/PrettyTables.jl` as the module entrypoint. Preserve its include order: load core types and implementation first, keep each backend grouped, load printing-state files after the backends, and include `src/precompile.jl` last.
- Keep backend implementations under `src/backends/{text,html,latex,markdown,typst,excel}` and put focused backend regressions in the corresponding `test/backends/...` directory.
- Keep extension code under `ext/`. `PrettyTablesExcelExt` activates with XLSX and `PrettyTablesTypstryExt` activates with Typstry; both trigger packages belong to the root test target.
- Use the root `Project.toml` for package and test dependencies. Support Julia 1.10 or newer according to `[compat]`; tests use the root `[extras]` and `[targets]`, and there is no `test/Project.toml`.
- Build documentation from `docs/`, which has its own `Project.toml` and `make.jl`.

## Commands

- Allow generous timeouts for first runs because package precompilation can be substantial.
- Instantiate the root environment with `julia --project=. -e 'using Pkg; Pkg.instantiate()'`.
- Run the complete suite with `julia --project=. -e 'using Pkg; Pkg.test()'`. Use this by default because `test/runtests.jl` unconditionally loads shared test types and all internal, backend, extension, integration, general, and error test groups.
- Do not assume a test-name selector exists. For a focused file, install TestEnv in the default/shared tool environment first with `julia -e 'using Pkg; Pkg.add("TestEnv")'`, then activate the test environment and mirror the `runtests.jl` setup, for example: `julia --project=. -e 'using TestEnv; TestEnv.activate(); using Test, PrettyTables, Crayons, LaTeXStrings, Markdown, OffsetArrays, StyledStrings, Tables, XLSX, Dates; Crayons.force_color(true); include("test/types.jl"); include("test/backends/text/alignment.jl")'`. Prefer `Pkg.test()` when the selected file needs additional suite state.
- Bootstrap docs from the repository root with `julia --project=docs -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate()'`, then build locally with `julia --project=docs docs/make.jl local`.
- Format with `julia -e 'using JuliaFormatter; format(".")'`. Install JuliaFormatter in the active/default tool environment first; it is not a package dependency, so do not run this command with `--project=.`.
- Expect CI to run the build action before tests. The main workflow covers Julia 1.10 and latest stable on Ubuntu x64, macOS arm64, and Windows x64; the nightly workflow runs the same supported platform/architecture combinations on Julia nightly.

## Code Style

- Apply the BlueStyle configuration in `.JuliaFormatter.toml` and preserve its explicit alignment and rewrite settings.
- Write test groups as `@testset "..." verbose = true begin` when adding groups to `test/runtests.jl`; use focused nested testsets within backend files as appropriate.
- Preserve exact backend output, including whitespace, delimiters, escaping, and ANSI sequences. Keep `Crayons.force_color(true)` in test setup so ANSI expectations remain deterministic in CI and non-TTY sessions.
- Review `src/precompile.jl` when changing common public rendering paths. Keep its representative `pretty_table` workloads current and preserve its redirected-output handling and stdout restoration.
- Follow `COMMITS.md` when creating commits: keep commits incremental and functional, use an imperative summary under 50 characters without a trailing period, and separate any punctuated body with a blank line.

## Behavioral Constraints

- Accept only one- or two-dimensional data; reject data with more than two dimensions.
- Require an `alignment` vector to contain exactly one entry per data column.
- Require `summary_rows` and explicitly supplied `summary_row_labels` to have equal lengths.
- Render recursive table data as the exact sentinel `#= circular reference =#`; do not recurse indefinitely or change the sentinel casually.
- Add focused regression coverage in the matching backend test directory whenever output behavior changes, and compare exact rendered output where existing tests do so.

## Not Configured

- Do not invent a linter or formatting gate. The GitHub Actions workflows have no formatting job, even though JuliaFormatter settings are present locally.
- Do not expect pre-commit hooks; no pre-commit configuration is committed.
- Do not run `Pkg.build()` as a repository task; there is no `deps/build.jl`.

using LinearAlgebra
using Printf
using PrettyTables
using SHA
using Tables

const SOURCES = [
    ("matrix", "Matrix"),
    ("view", "SubArray/view"),
    ("transpose", "Transpose"),
    ("diagonal", "Diagonal"),
    ("columns", "Tables.jl columns"),
    ("rows", "Tables.jl rows"),
]

const BACKENDS = [:text, :html, :latex, :markdown, :typst]
const COLUMN_LABELS = ["Column 1", "Column 2", "Column 3", "Column 4"]
const RECORD_VERSION = "PTBENCH_V1"
const TARGET_TPFT_NS = 100_000_000.0
const TARGET_REPEATED_NS = 100_000.0

const DASHBOARD_TABLE_FORMAT = TextTableFormat(;
    borders = text_table_borders__unicode_rounded,
    horizontal_line_at_beginning = true,
    horizontal_line_after_column_labels = true,
    horizontal_line_after_data_rows = true,
    vertical_lines_at_data_columns = :all,
)

const DASHBOARD_TABLE_STYLE = TextTableStyle(;
    first_line_column_label = crayon"bold cyan",
    column_label = crayon"fg:cyan",
    row_label = crayon"bold",
    table_border = crayon"fg:dark_gray",
)

"""
    print_help() -> Nothing

Print the public command-line help and benchmark scope.
"""
function print_help()
    println(
        """
Usage: julia --project=. benchmark/user_observed_performance.jl [options]

Measure user-observed PrettyTables performance for 6 table sources and the 5 built-in
rendering backends: text, html, latex, markdown, and typst. Excel is explicitly
excluded.

Options:
  --trials N       Fresh Julia workers per scenario (default: 10).
  --repeats N      Warm renders in each worker (default: 50).
  --backends LIST  Comma-separated built-in backends (default: all five).
  --help           Show this help message.

Backend examples:
  --backends text,html
  --backends typst

Each source/backend/trial runs alone in a fresh process. Runs with 1-3 trials are useful
only for exploratory checks; use the default or more for credible comparisons.

Score v1 is higher-is-better and weights TPFT twice:
  100 * (((100 ms / TPFT)^2 * (100 μs / repeated))^(1/3))
"""
    )
    return nothing
end

"""
    parse_backends(value::String) -> Vector{Symbol}

Parse the comma-separated backend list `value`, normalize its names, and remove duplicates
while preserving their first-occurrence order.
"""
function parse_backends(value::String)
    isempty(strip(value)) && throw(ArgumentError("--backends requires a nonempty list"))
    selected = Symbol[]
    valid = join(String.(BACKENDS), ",")
    for entry in split(value, ',')
        name = lowercase(strip(entry))
        isempty(name) &&
            throw(ArgumentError("--backends contains an empty name; valid values: $valid"))
        backend = Symbol(name)
        backend in BACKENDS ||
            throw(ArgumentError("unknown backend '$name'; valid values: $valid"))
        backend in selected || push!(selected, backend)
    end
    return selected
end

"""
    parse_positive_integer(option::String, value::String) -> Int

Parse `value` as a positive integer for the named command-line `option`.
"""
function parse_positive_integer(option::String, value::String)
    number = tryparse(Int, value)
    if isnothing(number) || number <= 0
        throw(ArgumentError("$option requires a positive integer, got '$value'"))
    end
    return number
end

"""
    parse_parent_arguments(arguments::Vector{String}) -> NamedTuple

Parse and validate the public command-line `arguments`.

# Returns

- `NamedTuple`: Positive trial and repeat counts, ordered backend selection, and help state.
"""
function parse_parent_arguments(arguments::Vector{String})
    trials  = 10
    repeats = 50
    backends = copy(BACKENDS)
    index   = 1

    while index <= length(arguments)
        argument = arguments[index]
        if argument == "--help"
            return (; trials, repeats, backends, help = true)
        elseif argument == "--trials" || argument == "--repeats"
            index == length(arguments) && throw(ArgumentError("$argument requires a value"))
            value = parse_positive_integer(argument, arguments[index + 1])
            if argument == "--trials"
                trials = value
            else
                repeats = value
            end
            index += 2
        elseif argument == "--backends"
            if index == length(arguments) || startswith(arguments[index + 1], "--")
                throw(ArgumentError("--backends requires a comma-separated list"))
            end
            backends = parse_backends(arguments[index + 1])
            index += 2
        else
            throw(ArgumentError("unknown option '$argument'; use --help for usage"))
        end
    end

    return (; trials, repeats, backends, help = false)
end

"""
    make_source(source_name::String) -> Union{AbstractMatrix, NamedTuple, AbstractVector}

Construct an equivalent four-by-four source selected by the internal `source_name`.
"""
function make_source(source_name::String)
    matrix = [row == column ? row : 0 for row in 1:4, column in 1:4]
    names  = (:c1, :c2, :c3, :c4)

    if source_name == "matrix"
        return matrix
    elseif source_name == "view"
        return view(matrix, :, :)
    elseif source_name == "transpose"
        return transpose(matrix)
    elseif source_name == "diagonal"
        return Diagonal(1:4)
    elseif source_name == "columns"
        return NamedTuple{names}(Tuple(matrix[:, column] for column in axes(matrix, 2)))
    elseif source_name == "rows"
        return [NamedTuple{names}(Tuple(matrix[row, :])) for row in axes(matrix, 1)]
    end

    throw(ArgumentError("unknown worker source '$source_name'"))
end

"""
    new_sink() -> IOContext{IOBuffer}

Create a colorless in-memory sink with a deterministic large display size.
"""
function new_sink()
    return IOContext(IOBuffer(), :color => false, :displaysize => (10_000, 10_000))
end

"""
    median_value(values::AbstractVector{<:Real}) -> Float64

Compute the median of the nonempty real-valued collection `values`.
"""
function median_value(values::AbstractVector{<:Real})
    isempty(values) && throw(ArgumentError("cannot compute the median of no values"))
    ordered = sort!(Float64.(values))
    count   = length(ordered)
    middle  = (count + 1) ÷ 2
    return isodd(count) ? ordered[middle] : (ordered[middle] + ordered[middle + 1]) / 2
end

"""
    geometric_mean(values::AbstractVector{<:Real}) -> Float64

Compute the positive geometric mean of `values` in log space.
"""
function geometric_mean(values::AbstractVector{<:Real})
    isempty(values) && throw(ArgumentError("cannot compute a geometric mean of no values"))
    all(value -> value > 0, values) ||
        throw(ArgumentError("geometric mean values must be positive"))
    return exp(sum(log, values) / length(values))
end

"""
    compile_components(
        value::Union{Real, Tuple{Vararg{Real}}},
    ) -> Tuple{Float64, Float64}

Normalize the scalar or tuple cumulative compilation counter `value` into compile and
recompile times.
"""
function compile_components(value::Union{Real, Tuple})
    if value isa Tuple
        isempty(value) && return 0.0, -1.0
        compile_time   = Float64(value[1])
        recompile_time = length(value) >= 2 ? Float64(value[2]) : -1.0
        return compile_time, recompile_time
    end
    return Float64(value), -1.0
end

"""
    render_worker(source_name::String, backend_name::String, repeats::Int) -> Nothing

Measure the isolated `source_name` and `backend_name` scenario for `repeats` warm renders,
then emit one fixed-field worker record.
"""
function render_worker(source_name::String, backend_name::String, repeats::Int)
    source_name in first.(SOURCES) ||
        throw(ArgumentError("worker source '$source_name' is not allowed"))
    backend = Symbol(backend_name)
    backend in BACKENDS ||
        throw(ArgumentError("worker backend '$backend_name' is not allowed"))

    source = make_source(source_name)
    GC.gc()

    compile_available =
        isdefined(Base, :cumulative_compile_timing) &&
        isdefined(Base, :cumulative_compile_time_ns)
    compile_before = 0.0
    recompile_before = -1.0
    compile_after = 0.0
    recompile_after = -1.0
    first_sink = new_sink()
    first_elapsed_ns = 0

    if compile_available
        Base.cumulative_compile_timing(true)
        compile_before, recompile_before = compile_components(
            Base.cumulative_compile_time_ns()
        )
    end

    try
        start_ns = time_ns()
        pretty_table(
            first_sink,
            source;
            backend = backend,
            column_labels = COLUMN_LABELS,
            limit_printing = false,
        )
        first_elapsed_ns = time_ns() - start_ns
    finally
        if compile_available
            compile_after, recompile_after = compile_components(
                Base.cumulative_compile_time_ns()
            )
            Base.cumulative_compile_timing(false)
        end
    end

    first_output = take!(first_sink.io)
    isempty(first_output) && error("$source_name/$backend_name produced empty first output")
    first_digest = bytes2hex(SHA.sha256(first_output))
    output_bytes = length(first_output)

    repeated_ns = Vector{Float64}(undef, repeats)
    for repetition in 1:repeats
        sink = new_sink()
        GC.gc()
        start_ns = time_ns()
        pretty_table(
            sink,
            source;
            backend = backend,
            column_labels = COLUMN_LABELS,
            limit_printing = false,
        )
        repeated_ns[repetition] = time_ns() - start_ns

        output = take!(sink.io)
        isempty(output) &&
            error("$source_name/$backend_name produced empty repeated output")
        digest = bytes2hex(SHA.sha256(output))
        if length(output) != output_bytes ||
            digest != first_digest ||
            output != first_output
            error("$source_name/$backend_name produced unstable repeated output")
        end
    end

    compile_ns = compile_available ? max(compile_after - compile_before, 0.0) : -1.0
    recompile_ns = if compile_available && recompile_before >= 0 && recompile_after >= 0
        max(recompile_after - recompile_before, 0.0)
    else
        -1.0
    end
    repeated_median_ns = median_value(repeated_ns)

    println(
        RECORD_VERSION,
        '\t',
        source_name,
        '\t',
        backend_name,
        '\t',
        first_elapsed_ns,
        '\t',
        compile_ns,
        '\t',
        recompile_ns,
        '\t',
        repeated_median_ns,
        '\t',
        output_bytes,
        '\t',
        first_digest,
    )
    return nothing
end

"""
    run_trial(
        script::String,
        project::String,
        source::String,
        backend::Symbol,
        repeats::Int,
        trial::Int,
    ) -> NamedTuple

Run one scenario trial in a clean single-threaded Julia subprocess and parse its record.

# Arguments
- `script::String`: Path to the benchmark worker script.
- `project::String`: Path to the explicit Julia project used by the worker.
- `source::String`: Internal source name requested from the worker.
- `backend::Symbol`: Built-in rendering backend requested from the worker.
- `repeats::Int`: Number of warm renders performed by the worker.
- `trial::Int`: One-based trial number used in diagnostics.
"""
function run_trial(
    script::String,
    project::String,
    source::String,
    backend::Symbol,
    repeats::Int,
    trial::Int,
)
    output = IOBuffer()
    errors = IOBuffer()
    julia = Base.julia_cmd()
    backend_name = String(backend)
    command = `$julia --startup-file=no --history-file=no --threads=1 --project=$project`
    command = `$command $script --_worker $source $backend_name $repeats`
    process = run(pipeline(command; stdout = output, stderr = errors); wait = false)
    wait(process)

    standard_output = String(take!(output))
    standard_error  = String(take!(errors))
    if !success(process)
        message = isempty(strip(standard_error)) ? "no error output" : strip(standard_error)
        error(
            "worker failed for $source/$backend_name trial $trial with exit code " *
            "$(process.exitcode):\n$message",
        )
    end
    if !isempty(strip(standard_error))
        println(
            stderr,
            "Worker warning for $source/$backend_name trial $trial:\n",
            strip(standard_error),
        )
    end

    fields = split(chomp(standard_output), '\t')
    length(fields) == 9 || error(
        "worker returned $(length(fields)) fields instead of 9 for " *
        "$source/$backend_name: $(repr(standard_output))",
    )
    fields[1] == RECORD_VERSION ||
        error("worker returned unsupported record version '$(fields[1])'")
    fields[2] == source || error("worker source field did not match request")
    fields[3] == backend_name || error("worker backend field did not match request")
    fields[2] in first.(SOURCES) || error("worker returned a disallowed source")
    Symbol(fields[3]) in BACKENDS || error("worker returned a disallowed backend")
    occursin(r"^[0-9a-f]{64}$", fields[9]) || error("worker returned an invalid digest")

    try
        return (
            tpft_ns = parse(Float64, fields[4]),
            compile_ns = parse(Float64, fields[5]),
            recompile_ns = parse(Float64, fields[6]),
            repeated_ns = parse(Float64, fields[7]),
            output_bytes = parse(Int, fields[8]),
            digest = fields[9],
        )
    catch exception
        error(
            "worker returned invalid numeric fields for $source/$backend_name: " *
            sprint(showerror, exception),
        )
    end
end

"""
    git_profile(project::String) -> NamedTuple

Read the repository revision and worktree state for `project`, with a graceful non-git
fallback.
"""
function git_profile(project::String)
    try
        sha = readchomp(
            pipeline(`git -C $project rev-parse --short HEAD`; stderr = devnull)
        )
        status = readchomp(pipeline(`git -C $project status --porcelain`; stderr = devnull))
        return (; sha, state = isempty(status) ? "clean" : "dirty")
    catch
        return (; sha = "unavailable", state = "unavailable")
    end
end

"""
    cell_score(tpft_ns::Real, repeated_ns::Real) -> Float64

Compute Score v1 from the scenario's `tpft_ns` and `repeated_ns` measurements.
"""
function cell_score(tpft_ns::Real, repeated_ns::Real)
    return 100 * exp(
        (2 * log(TARGET_TPFT_NS / tpft_ns) + log(TARGET_REPEATED_NS / repeated_ns)) / 3
    )
end

"""
    optional_median(values::AbstractVector{<:Real}) -> Float64

Compute the median of `values` after discarding unavailable negative diagnostics.
"""
function optional_median(values::AbstractVector{<:Real})
    available = filter(value -> value >= 0, values)
    return isempty(available) ? -1.0 : median_value(available)
end

"""
    diagnostic_string(value::Real, scale::Real; kwargs...) -> String

Format `value` divided by `scale`, or return an availability marker for a negative value.

# Keywords
- `suffix::String`: Append this unit suffix to an available value.
    (**Default**: `""`)
"""
function diagnostic_string(value::Real, scale::Real; suffix::String = "")
    return value < 0 ? "n/a" : @sprintf("%.3f%s", value / scale, suffix)
end

"""
    output_supports_color(io::IO) -> Bool

Detect whether `io` is an interactive terminal with color support.
"""
function output_supports_color(io::IO)
    return io isa Base.TTY && Base.get_have_color()
end

"""
    dashboard_table_style(io::IO) -> TextTableStyle

Choose the dashboard table styling when `io` supports color, otherwise use plain styling.
"""
function dashboard_table_style(io::IO)
    return output_supports_color(io) ? DASHBOARD_TABLE_STYLE : TextTableStyle()
end

"""
    print_accent(io::IO, text::AbstractString, decoration::Crayon) -> Nothing

Print `text` with `decoration` when `io` supports color, otherwise print plain text.
"""
function print_accent(io::IO, text::AbstractString, decoration::Crayon)
    if output_supports_color(io)
        print(io, decoration, text, crayon"reset")
    else
        print(io, text)
    end
    return nothing
end

"""
    print_dashboard_header(io::IO) -> Nothing

Print the benchmark report masthead.
"""
function print_dashboard_header(io::IO)
    title    = "PRETTYTABLES  /  USER-OBSERVED PERFORMANCE"
    subtitle = "Fresh-process rendering benchmark  ·  Score v1"
    println(io, "╭", repeat("─", 78), "╮")
    print(io, "│ ")
    print_accent(io, title, crayon"bold cyan")
    println(io, repeat(" ", 76 - textwidth(title)), " │")
    println(io, "│ ", subtitle, repeat(" ", 76 - textwidth(subtitle)), " │")
    println(io, "╰", repeat("─", 78), "╯")
    return nothing
end

"""
    print_section(io::IO, title::String, detail::String = "") -> Nothing

Print a clearly separated report section heading with an optional concise `detail`.
"""
function print_section(io::IO, title::String, detail::String = "")
    println(io)
    print_accent(io, "━━ ", crayon"fg:cyan")
    print_accent(io, uppercase(title), crayon"bold cyan")
    isempty(detail) || print(io, "  ", detail)
    println(io)
    return nothing
end

"""
    print_progress(
        io::IO,
        first_worker::Int,
        last_worker::Int,
        total_workers::Int,
        backend::Symbol,
        source_label::String,
    ) -> Nothing

Print one stderr progress line for an isolated scenario batch.
"""
function print_progress(
    io::IO,
    first_worker::Int,
    last_worker::Int,
    total_workers::Int,
    backend::Symbol,
    source_label::String,
)
    range = @sprintf("%3d – %3d / %d", first_worker, last_worker, total_workers)
    print_accent(io, "• [$range] ", crayon"fg:cyan")
    print_accent(io, rpad(String(backend), 9), crayon"bold")
    println(io, " · ", source_label)
    return nothing
end

"""
    print_run_profile(
        git::NamedTuple,
        project::String,
        trials::Int,
        repeats::Int,
        backends::Vector{Symbol},
        scenario_count::Int,
        total_workers::Int,
    ) -> Nothing

Print the compact execution profile panel for the selected `backends`, `scenario_count`,
sampling parameters, worker count, repository `git` state, and `project`.
"""
function print_run_profile(
    git::NamedTuple,
    project::String,
    trials::Int,
    repeats::Int,
    backends::Vector{Symbol},
    scenario_count::Int,
    total_workers::Int,
)
    run_quality = if trials <= 3
        "exploratory; use at least 10 trials to compare"
    else
        "comparison-ready"
    end
    profile_rows = Any[
        "Julia" string(VERSION)
        "Revision" "$(git.sha) ($(git.state))"
        "Machine" Sys.CPU_NAME
        "Execution" "parent: $(Threads.nthreads()) threads · workers: 1 thread"
        "Sampling" "$trials fresh workers / scenario · $repeats warm renders / worker"
        "Scope" "$scenario_count scenarios · $total_workers workers · Excel excluded"
        "Backends" join(String.(backends), " · ")
        "Sink policy" "new IOBuffer/IOContext for every timed render"
        "Score target" "TPFT: 100 ms · repeated: 100 μs"
        "Run quality" run_quality
        "Project" project
    ]
    highlighters = TextHighlighter[TextHighlighter(
        (_, _, column) -> column == 1, crayon"bold"
    ),]
    pretty_table(
        IOContext(stdout, :color => output_supports_color(stdout)),
        profile_rows;
        column_labels = ["Run profile", "Value"],
        alignment = [:l, :l],
        column_label_alignment = :l,
        fit_table_in_display_horizontally = false,
        fit_table_in_display_vertically = false,
        highlighters = highlighters,
        limit_printing = false,
        style = dashboard_table_style(stdout),
        table_format = DASHBOARD_TABLE_FORMAT,
    )
    return nothing
end

"""
    print_result_table(title::String, rows::Matrix, labels::Vector{String}) -> Nothing

Print `rows` under `title` with the column `labels` and without display-width cropping.
"""
function print_result_table(title::String, rows::Matrix, labels::Vector{String})
    print_section(stdout, title)
    score_column = size(rows, 2)
    highlighters = TextHighlighter[
        TextHighlighter((_, _, column) -> column == score_column, crayon"bold yellow"),
        TextHighlighter(
            (data, row, column) ->
                data[row, column] == "n/a" || data[row, column] == "-",
            crayon"fg:dark_gray",
        ),
        TextHighlighter(
            (data, row, column) -> data[row, column] == "FAILED", crayon"bold red"
        ),
    ]
    alignment = vcat([:l, :l], fill(:r, length(labels) - 2))
    length(labels) == 6 && (alignment = vcat([:l], fill(:r, length(labels) - 1)))
    pretty_table(
        IOContext(stdout, :color => output_supports_color(stdout)),
        rows;
        column_labels = labels,
        alignment = alignment,
        column_label_alignment = :c,
        fit_table_in_display_horizontally = false,
        fit_table_in_display_vertically = false,
        highlighters = highlighters,
        limit_printing = false,
        style = dashboard_table_style(stdout),
        table_format = DASHBOARD_TABLE_FORMAT,
    )
    return nothing
end

"""
    aggregate_group(cells::Vector{<:NamedTuple}) -> NamedTuple

Aggregate the successful scenario `cells` using geometric means and median diagnostics.
"""
function aggregate_group(cells::Vector{<:NamedTuple})
    tpft_ns     = geometric_mean([cell.tpft_ns for cell in cells])
    repeated_ns = geometric_mean([cell.repeated_ns for cell in cells])
    compile_ns  = optional_median([cell.compile_ns for cell in cells])
    shares      = [cell.compile_share for cell in cells if cell.compile_share >= 0]
    share       = isempty(shares) ? -1.0 : median_value(shares)
    score       = geometric_mean([cell.score for cell in cells])
    return (; tpft_ns, repeated_ns, compile_ns, compile_share = share, score)
end

"""
    run_parent(
        trials::Int,
        repeats::Int,
        backends::Vector{Symbol},
    ) -> Nothing

Run the isolated scenarios for `backends` with `trials` workers and `repeats` warm renders,
aggregate their metrics, and print the functional report.
"""
function run_parent(trials::Int, repeats::Int, backends::Vector{Symbol})
    script = abspath(@__FILE__)
    project = dirname(dirname(script))
    git = git_profile(project)
    scenario_count = length(SOURCES) * length(backends)
    total_workers = scenario_count * trials
    backend_names = join(String.(backends), ", ")

    print_dashboard_header(stdout)
    print_section(stdout, "Run profile", "environment and sampling plan")
    print_run_profile(
        git, project, trials, repeats, backends, scenario_count, total_workers
    )
    print_section(
        stderr,
        "Benchmark progress",
        "one update per isolated scenario; worker output stays private",
    )

    cells = NamedTuple[]
    failures = String[]
    worker_index = 0
    for backend in backends
        for (source_name, source_label) in SOURCES
            tpft_values      = Float64[]
            compile_values   = Float64[]
            recompile_values = Float64[]
            repeated_values  = Float64[]
            byte_values      = Float64[]
            share_values     = Float64[]
            scenario_failed  = false

            print_progress(
                stderr,
                worker_index + 1,
                worker_index + trials,
                total_workers,
                backend,
                source_label,
            )
            for trial in 1:trials
                worker_index += 1
                try
                    record = run_trial(
                        script, project, source_name, backend, repeats, trial
                    )
                    push!(tpft_values, record.tpft_ns)
                    push!(compile_values, record.compile_ns)
                    push!(recompile_values, record.recompile_ns)
                    push!(repeated_values, record.repeated_ns)
                    push!(byte_values, record.output_bytes)
                    share =
                        record.compile_ns < 0 ? -1.0 :
                        100 * record.compile_ns / record.tpft_ns
                    push!(share_values, share)
                catch exception
                    scenario_failed = true
                    message =
                        "$backend/$source_label trial $trial: " *
                        sprint(showerror, exception)
                    push!(failures, message)
                    println(stderr, "FAILED: ", message)
                    worker_index += trials - trial
                    break
                end
            end

            scenario_failed && continue
            tpft_ns = median_value(tpft_values)
            compile_ns = optional_median(compile_values)
            recompile_ns = optional_median(recompile_values)
            repeated_ns = median_value(repeated_values)
            output_bytes = median_value(byte_values)
            available_shares = filter(value -> value >= 0, share_values)
            compile_share =
                isempty(available_shares) ? -1.0 : median_value(available_shares)
            score = cell_score(tpft_ns, repeated_ns)
            push!(
                cells,
                (;
                    backend,
                    source = source_label,
                    tpft_ns,
                    compile_ns,
                    recompile_ns,
                    repeated_ns,
                    output_bytes,
                    compile_share,
                    score,
                ),
            )
        end
    end

    scenario_rows = Matrix{Any}(undef, scenario_count, 10)
    scenario_index = 0
    for backend in backends
        for (_, source_label) in SOURCES
            scenario_index += 1
            matches = filter(
                cell -> cell.backend == backend && cell.source == source_label, cells
            )
            if isempty(matches)
                scenario_rows[scenario_index, :] = [
                    String(backend),
                    source_label,
                    "FAILED",
                    "-",
                    "-",
                    "-",
                    "-",
                    "-",
                    "-",
                    "-",
                ]
                continue
            end

            cell = only(matches)
            scenario_rows[scenario_index, :] = [
                String(cell.backend),
                cell.source,
                @sprintf("%.3f", cell.tpft_ns / 1e6),
                diagnostic_string(cell.compile_ns, 1e6),
                diagnostic_string(cell.recompile_ns, 1e6),
                diagnostic_string(cell.compile_share, 1; suffix = "%"),
                @sprintf("%.3f", cell.repeated_ns / 1e3),
                @sprintf("%.1f", cell.tpft_ns / cell.repeated_ns),
                round(Int, cell.output_bytes),
                @sprintf("%.2f", cell.score),
            ]
        end
    end
    print_result_table(
        "Scenario results & compilation",
        scenario_rows,
        [
            "Backend",
            "Source",
            "TPFT ms",
            "Compile ms",
            "Recompile ms",
            "Compile share",
            "Repeated μs",
            "Cold/warm",
            "Output bytes",
            "Score v1",
        ],
    )
    println(
        "  Medians across fresh workers. Compilation is diagnostic within first-print time."
    )

    backend_rows = Matrix{Any}(undef, length(backends), 6)
    for (index, backend) in enumerate(backends)
        group = filter(cell -> cell.backend == backend, cells)
        if length(group) == length(SOURCES)
            aggregate = aggregate_group(group)
            backend_rows[index, :] = [
                String(backend),
                @sprintf("%.3f", aggregate.tpft_ns / 1e6),
                @sprintf("%.3f", aggregate.repeated_ns / 1e3),
                diagnostic_string(aggregate.compile_ns, 1e6),
                diagnostic_string(aggregate.compile_share, 1; suffix = "%"),
                @sprintf("%.2f", aggregate.score),
            ]
        else
            backend_rows[index, :] = [String(backend), "FAILED", "-", "-", "-", "-"]
        end
    end
    print_result_table(
        "Backend summary",
        backend_rows,
        [
            "Backend",
            "TPFT gmean ms",
            "Repeated gmean μs",
            "Compile median ms",
            "Compile share median",
            "Score v1",
        ],
    )

    source_rows = Matrix{Any}(undef, length(SOURCES), 6)
    for (index, (_, source_label)) in enumerate(SOURCES)
        group = filter(cell -> cell.source == source_label, cells)
        if length(group) == length(backends)
            aggregate = aggregate_group(group)
            source_rows[index, :] = [
                source_label,
                @sprintf("%.3f", aggregate.tpft_ns / 1e6),
                @sprintf("%.3f", aggregate.repeated_ns / 1e3),
                diagnostic_string(aggregate.compile_ns, 1e6),
                diagnostic_string(aggregate.compile_share, 1; suffix = "%"),
                @sprintf("%.2f", aggregate.score),
            ]
        else
            source_rows[index, :] = [source_label, "FAILED", "-", "-", "-", "-"]
        end
    end
    print_result_table(
        "Source summary",
        source_rows,
        [
            "Source",
            "TPFT gmean ms",
            "Repeated gmean μs",
            "Compile median ms",
            "Compile share median",
            "Score v1",
        ],
    )

    if isempty(failures) && length(cells) == scenario_count
        global_score = geometric_mean([cell.score for cell in cells])
        print_section(
            stdout,
            "Global Score v1",
            "$scenario_count selected scenario scores · backends: $backend_names",
        )
        print_accent(stdout, "  ", crayon"bold")
        print_accent(stdout, @sprintf("%.2f", global_score), crayon"bold green")
        println("  higher is better")
    else
        print_section(
            stdout, "Global Score v1", "unavailable because one or more scenarios failed"
        )
        print_accent(stdout, "  UNAVAILABLE", crayon"bold red")
        println()
        println("  Failures:")
        foreach(message -> println("  - ", message), failures)
    end
    println(
        "  TPFT has 2:1 weight over repeated time; compilation is already included in TPFT."
    )
    println("  Score v1 is comparable only with the same selected backend set.")
    println(
        "  TPFT excludes Julia startup/package loading; every trial is a fresh process."
    )
    return nothing
end

"""
    main(arguments::Vector{String}) -> Nothing

Dispatch `arguments` to the internal worker or public benchmark mode.
"""
function main(arguments::Vector{String})
    if !isempty(arguments) && arguments[1] == "--_worker"
        length(arguments) == 4 || error("invalid internal worker field count")
        repeats = parse_positive_integer("internal repeats", arguments[4])
        return render_worker(arguments[2], arguments[3], repeats)
    end

    options = parse_parent_arguments(arguments)
    if options.help
        print_help()
    else
        run_parent(options.trials, options.repeats, options.backends)
    end
    return nothing
end

try
    main(ARGS)
catch exception
    println(stderr, "error: ", sprint(showerror, exception))
    exit(1)
end

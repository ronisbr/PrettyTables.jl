## Description #############################################################################
#
# Define the main function for printing tables.
#
############################################################################################

export pretty_table

function pretty_table(@nospecialize(data::Any); kwargs...)
    io = stdout isa Base.TTY ? IOContext(stdout, :limit => true) : stdout
    return pretty_table(io, data; kwargs...)
end

function pretty_table(::Type{String}, @nospecialize(data::Any); color::Bool = false, kwargs...)
    io = IOContext(IOBuffer(), :color => color)
    pretty_table(io, data; kwargs...)
    return String(take!(io.io))
end

function pretty_table(
    @nospecialize(io::IO),
    @nospecialize(data::Any);

    # == Arguments for the IOContext =======================================================

    compact_printing::Bool = true,
    limit_printing::Bool = true,

    # == Arguments for the Printing Specification ==========================================

    show_omitted_cell_summary::Bool = true,
    renderer::Symbol = :print,

    kwargs...
)
    # == Check Inputs ======================================================================

    if (renderer != :print) && (renderer != :show)
        error("The renderer must be `:print` or `:show`.")
    end

    # == Table Preprocessing ===============================================================

    # Check for circular dependency.
    ptd = get(io, :__PRETTY_TABLES__DATA__, nothing)

    if !isnothing(ptd)
        context = IOContext(
            io,
            :compact => compact_printing,
            :limit   => limit_printing
        )

        # In this case, `ptd` is a vector with the data printed by PrettyTables.jl. Hence,
        # we need to search if the current one is inside this vector. If true, we have a
        # circular dependency.
        for d in ptd
            if d === data
                return _html__circular_reference(context)
            end
        end

        # Otherwise, we must push the current data to the vector.
        push!(ptd, data)
    else
        context = IOContext(
            io,
            :__PRETTY_TABLES__DATA__ => Any[data],
            :compact                 => compact_printing,
            :limit                   => limit_printing
        )
    end

    pdata = _preprocess_data(data)

    # == Printing Specification ============================================================

    table_data = _table_data(Ref{Any}(pdata); kwargs...)

    pspec = PrintingSpec(
        context,
        table_data,
        renderer,
        show_omitted_cell_summary
    )

    # When wrapping `stdout` in `IOContext` in Jupyter, `io.io` is not equal to `stdout`
    # anymore. Hence, we need to check if `io` is `stdout` before calling the HTML back end.
    is_stdout = (io === stdout) || ((io isa IOContext) && (io.io === stdout))
    _html__print(pspec; is_stdout, kwargs...)

    return nothing
end

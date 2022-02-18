# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Private functions.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

################################################################################
#                                Preprocessing
################################################################################

# Those functions apply a preprocessing to the data that will be printed
# depending on its type.

function _preprocess_vec_or_mat(
    data::AbstractVecOrMat,
    header::Union{Nothing, AbstractVector, Tuple}
)
    if header === nothing
        pheader = (["Col. " * string(i) for i = 1:size(data,2)],)
    elseif header isa AbstractVector
        pheader = (header,)
    else
        pheader = header
    end

    return data, pheader
end

function _preprocess_dict(
    dict::AbstractDict{K, V};
    sortkeys::Bool = false
) where {K, V}
    pheader = (
        ["Keys", "Values"],
        [compact_type_str(K), compact_type_str(V)]
    )

    k = collect(keys(dict))
    v = collect(values(dict))

    if sortkeys
        ind = sortperm(collect(keys(dict)))
        vk  = k[ind]
        vv  = v[ind]
    else
        vk = k
        vv = v
    end

    pdata = hcat(vk, vv)

    return pdata, pheader
end

function _preprocess_Tables_column(
    data::Any,
    header::Union{Nothing, AbstractVector, Tuple}
)
    # Access the table using the columns.
    table = Tables.columns(data)

    # Get the column names.
    names = collect(Symbol, Tables.columnnames(table))

    # Compute the table size and get the column types.
    size_j::Int = length(names)
    size_i::Int = Tables.rowcount(table)

    pdata = ColumnTable(data, table, names, (size_i, size_j))

    # For the header, we have the following priority:
    #
    #     1. If the user passed a vector `header`, then use it.
    #     2. Otherwise, check if the table defines a schema to create the
    #        header.
    #     3. If the table does not have a schema, then build a default header
    #        based on the column name and type.
    if header === nothing
        sch = Tables.schema(data)

        if sch !== nothing
            types::Vector{String} = compact_type_str.([sch.types...])
            pheader = (names, types)
        else
            pheader = (pdata.column_names,)
        end
    elseif header isa AbstractVector
        pheader = (header,)
    else
        pheader = header
    end

    return pdata, pheader
end

function _preprocess_Tables_row(
    data::Any,
    header::Union{Nothing, AbstractVector, Tuple}
)
    # Access the table using the rows.
    table = Tables.rows(data)

    # We need to fetch the first row to get information about the columns.
    row₁, ~ = iterate(table, 1)

    # Get the column names.
    names = collect(Symbol, Tables.columnnames(row₁))

    # Compute the table size.
    size_i::Int = length(table)
    size_j::Int = length(names)

    pdata = RowTable(data, table, names, (size_i, size_j))

    # For the header, we have the following priority:
    #
    #     1. If the user passed a vector `header`, then use it.
    #     2. Otherwise, check if the table defines a schema to create the
    #        header.
    #     3. If the table does not have a schema, then build a default header
    #        based on the column name and type.
    if header === nothing
        sch = Tables.schema(data)

        if sch !== nothing
            types::Vector{String} = compact_type_str.([sch.types...])
            pheader = (names, types)
        else
            pheader = (pdata.column_names,)
        end
    elseif header isa AbstractVector
        pheader = (header,)
    else
        pheader = header
    end

    return pdata, pheader
end

################################################################################
#                              Print information
################################################################################

# This function creates the structure that holds the global print information.
function _print_info(
    data::Any;
    alignment::Union{Symbol, Vector{Symbol}} = :r,
    cell_alignment::Union{
        Nothing,
        Dict{Tuple{Int, Int}, Symbol},
        Function,
        Tuple
    } = nothing,
    cell_first_line_only::Bool = false,
    compact_printing::Bool = true,
    row_filters::Union{Nothing, Tuple} = nothing,
    column_filters::Union{Nothing, Tuple} = nothing,
    formatters::Union{Nothing, Function, Tuple} = nothing,
    header::Union{Nothing, AbstractVector, Tuple} = nothing,
    header_alignment::Union{Symbol, Vector{Symbol}} = :s,
    header_cell_alignment::Union{
        Nothing,
        Dict{Tuple{Int, Int}, Symbol},
        Function,
        Tuple
    } = nothing,
    limit_printing::Bool = true,
    noheader::Bool = false,
    nosubheader::Bool = false,
    renderer::Symbol = :print,
    row_names::Union{Nothing, AbstractVector} = nothing,
    row_name_alignment::Symbol = :r,
    row_name_column_title::AbstractString = "",
    row_number_alignment::Symbol = :r,
    row_number_column_title::AbstractString = "Row",
    show_row_number::Bool = false,
    title::AbstractString = "",
    title_alignment::Symbol = :l
)

    _header = header isa Tuple ? header : (header,)

    # Create the processed table, which holds information about the additonal
    # columns, filters, etc.
    ptable = ProcessedTable(
        data,
        _header;
        alignment             = alignment,
        cell_alignment        = cell_alignment,
        column_filters        = column_filters,
        header_alignment      = header_alignment,
        header_cell_alignment = header_cell_alignment,
        noheader              = noheader,
        nosubheader           = nosubheader,
        row_filters           = row_filters
    )

    # Add the additional columns if requested.
    if show_row_number
        _add_column!(
            ptable,
            1:size(data)[1],
            [row_number_column_title];
            alignment = row_number_alignment,
            id = :row_number
        )
    end

    if row_names !== nothing
        _add_column!(
            ptable,
            row_names,
            [row_name_column_title];
            alignment = row_name_alignment,
            id = :row_name
        )
    end

    # Make sure that `formatters` is a tuple.
    formatters === nothing  && (formatters = ())
    typeof(formatters) <: Function && (formatters = (formatters,))

    # Render.
    renderer_val = renderer == :show ? Val(:show) : Val(:print)

    # Create the structure that stores the print information.
    pinfo = PrintInfo(
        ptable,
        formatters,
        compact_printing,
        title,
        title_alignment,
        cell_first_line_only,
        renderer_val,
        limit_printing
    )

    return pinfo
end

################################################################################
#                                   Printing
################################################################################

# This is a middleware function to apply the preprocess step to the data that
# will be printed.
function _pretty_table(
    (@nospecialize io::IO),
    data::Any;
    header::Union{Nothing, AbstractVector, Tuple} = nothing,
    kwargs...
)

    if Tables.istable(data)
        if Tables.columnaccess(data)
            pdata, pheader = _preprocess_Tables_column(data, header)
        elseif Tables.rowaccess(data)
            pdata, pheader = _preprocess_Tables_row(data, header)
        else
            error("The object does not have a valid Tables.jl implementation.")
        end

    elseif typeof(data) <: AbstractVecOrMat
        pdata, pheader = _preprocess_vec_or_mat(data, header)
    elseif typeof(data) <: AbstractDict
        sortkeys = get(kwargs, :sortkeys, false)
        pdata, pheader = _preprocess_dict(data; sortkeys = sortkeys)
    else
        error("The type $(typeof(data)) is not supported.")
    end

    return _pt(io, pdata; header = pheader, kwargs...)
end

# This is the low level function that prints the table. In this case, `data`
# must be accessed by `[i,j]` and the size of the `header` must be equal to the
# number of columns in `data`.
function _pt(
    (@nospecialize io::IO),
    data::Any;
    alignment::Union{Symbol, Vector{Symbol}} = :r,
    backend::Union{Symbol, T_BACKENDS} = Val(:auto),
    cell_alignment::Union{
        Nothing,
        Dict{Tuple{Int, Int}, Symbol},
        Function,
        Tuple
    } = nothing,
    cell_first_line_only::Bool = false,
    compact_printing::Bool = true,
    row_filters::Union{Nothing, Tuple} = nothing,
    column_filters::Union{Nothing, Tuple} = nothing,
    formatters::Union{Nothing, Function, Tuple} = nothing,
    header::Union{Nothing, AbstractVector, Tuple} = nothing,
    header_alignment::Union{Symbol, Vector{Symbol}} = :s,
    header_cell_alignment::Union{
        Nothing,
        Dict{Tuple{Int, Int}, Symbol},
        Function,
        Tuple
    } = nothing,
    noheader::Bool = false,
    nosubheader::Bool = false,
    limit_printing::Bool = true,
    renderer::Symbol = :print,
    row_names::Union{Nothing, AbstractVector} = nothing,
    row_name_alignment::Symbol = :r,
    row_name_column_title::AbstractString = "",
    row_number_alignment::Symbol = :r,
    row_number_column_title::AbstractString = "Row",
    show_row_number::Bool = false,
    title::AbstractString = "",
    title_alignment::Symbol = :l,
    kwargs...
)
    # Check for deprecations.
    if haskey(kwargs, :filters_row)
        Base.depwarn(
            "The option `filters_row` is deprecated. Use `row_filters` instead.",
            :filters_row
        )

        row_filters = kwargs[:filters_row]
        kwargs = _rm_filters_row(;kwargs...)
    end

    if haskey(kwargs, :filters_col)
        Base.depwarn(
            "The option `filters_row` is deprecated. Use `row_filters` instead.",
            :filters_row
        )

        column_filters = kwargs[:filters_col]
        kwargs = _rm_filters_col(;kwargs...)
    end

    # NOTE: Inform that using `backend` as `Symbol` is deprecated. This will be
    # removed in the next PrettyTables.jl version.
    if backend isa Symbol
      _backend = Val(backend)
      Base.depwarn(
          "Using `backend` as a symbol is deprecated. Use `Val(:$backend)` instead.",
          nothing
      )
    else
      _backend = backend
    end

    if _backend === Val(:auto)
        # In this case, if we do not have the `tf` keyword, then we just
        # fallback to the text _backend. Otherwise, check if the type of `tf`.
        if haskey(kwargs, :tf)
            tf = kwargs[:tf]

            if tf isa TextFormat
                _backend = Val(:text)
            elseif tf isa HTMLTableFormat
                _backend = Val(:html)
            elseif tf isa LatexTableFormat
                _backend = Val(:latex)
            else
                throw(
                    TypeError(
                        :_pt,
                        Union{TextFormat, HTMLTableFormat, LatexTableFormat},
                        typeof(tf)
                    )
                )
            end
        else
            _backend = Val(:text)
        end
    end

    # Create the structure that stores the print information.
    pinfo = _print_info(
        data;
        alignment               = alignment,
        cell_alignment          = cell_alignment,
        cell_first_line_only    = cell_first_line_only,
        compact_printing        = compact_printing,
        column_filters          = column_filters,
        row_filters             = row_filters,
        formatters              = formatters,
        header                  = header,
        header_alignment        = header_alignment,
        header_cell_alignment   = header_cell_alignment,
        limit_printing          = limit_printing,
        noheader                = noheader,
        nosubheader             = nosubheader,
        renderer                = renderer,
        row_names               = row_names,
        row_name_alignment      = row_name_alignment,
        row_name_column_title   = row_name_column_title,
        row_number_alignment    = row_number_alignment,
        row_number_column_title = row_number_column_title,
        show_row_number         = show_row_number,
        title                   = title,
        title_alignment         = title_alignment
    )

    # Select the appropriate backend.
    if _backend === Val(:text)
        _pt_text(Ref{Any}(io), pinfo; kwargs...)
    elseif _backend === Val(:html)
        _pt_html(Ref{Any}(io), pinfo; kwargs...)
    elseif _backend === Val(:latex)
        _pt_latex(Ref{Any}(io), pinfo; kwargs...)
    end

    return nothing
end

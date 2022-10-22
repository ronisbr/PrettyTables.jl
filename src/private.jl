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
        pheader = (["Col. " * string(i) for i in axes(data, 2)],)
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

    # Compute the number of rows.
    size_i::Int = length(table)

    # If we have at least one row, we can obtain the number of columns by
    # fetching the row. Otherwise, we try to use the schema.
    if size_i > 0
        row₁ = first(table)

        # Get the column names.
        names = collect(Symbol, Tables.columnnames(row₁))
    else
        sch = Tables.schema(data)

        if sch === nothing
            # In this case, we do not have a row and we do not have a schema.
            # Thus, we can do nothing. Hence, we assume there is no row or
            # column.
            names = Symbol[]
        else
            names = [sch.names...]
        end
    end

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
    max_num_of_columns::Int = -1,
    max_num_of_rows::Int = -1,
    renderer::Symbol = :print,
    row_labels::Union{Nothing, AbstractVector} = nothing,
    row_label_alignment::Symbol = :r,
    row_label_column_title::AbstractString = "",
    row_number_alignment::Symbol = :r,
    row_number_column_title::AbstractString = "Row",
    show_header::Bool = true,
    show_row_number::Bool = false,
    show_subheader::Bool = true,
    title::AbstractString = "",
    title_alignment::Symbol = :l
)

    _header = header isa Tuple ? header : (header,)

    # Create the processed table, which holds information about the additonal
    # columns, etc.
    ptable = ProcessedTable(
        data,
        _header;
        alignment             = alignment,
        cell_alignment        = cell_alignment,
        header_alignment      = header_alignment,
        header_cell_alignment = header_cell_alignment,
        max_num_of_columns    = max_num_of_columns,
        max_num_of_rows       = max_num_of_rows,
        show_header           = show_header,
        show_subheader        = show_subheader,
    )

    # Add the additional columns if requested.
    if show_row_number
        _add_column!(
            ptable,
            axes(data)[1] |> collect,
            [row_number_column_title];
            alignment = row_number_alignment,
            id = :row_number
        )
    end

    if row_labels !== nothing
        _add_column!(
            ptable,
            row_labels,
            [row_label_column_title];
            alignment = row_label_alignment,
            id = :row_label
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
        limit_printing,
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
    backend::T_BACKENDS = Val(:auto),
    cell_alignment::Union{
        Nothing,
        Dict{Tuple{Int, Int}, Symbol},
        Function,
        Tuple
    } = nothing,
    cell_first_line_only::Bool = false,
    compact_printing::Bool = true,
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
    max_num_of_columns::Int = -1,
    max_num_of_rows::Int = -1,
    renderer::Symbol = :print,
    row_labels::Union{Nothing, AbstractVector} = nothing,
    row_label_alignment::Symbol = :r,
    row_label_column_title::AbstractString = "",
    row_number_alignment::Symbol = :r,
    row_number_column_title::AbstractString = "Row",
    show_header::Bool = true,
    show_row_number::Bool = false,
    show_subheader::Bool = true,
    title::AbstractString = "",
    title_alignment::Symbol = :l,
    kwargs...
)

    # Check for deprecations.
    @deprecate_kw_and_push(crop_num_lines_at_beginning, reserved_display_lines)
    @deprecate_kw_and_push(row_name_crayon, row_label_crayon)
    @deprecate_kw_and_push(row_name_decoration, row_label_decoration)
    @deprecate_kw_and_push(row_name_header_crayon, row_label_header_crayon)
    @deprecate_kw_and_push(rownum_header_crayon, row_number_header_crayon)
    @deprecate_kw_and_return(noheader, show_header, !)
    @deprecate_kw_and_return(nosubheader, show_subheader, !)
    @deprecate_kw_and_return(row_name_alignment, row_label_alignment)
    @deprecate_kw_and_return(row_name_column_title, row_label_column_title)
    @deprecate_kw_and_return(row_names, row_labels)

    if backend === Val(:auto)
        # In this case, if we do not have the `tf` keyword, then we just
        # fallback to the text backend. Otherwise, check if the type of `tf`.
        if haskey(kwargs, :tf)
            tf = kwargs[:tf]

            if tf isa TextFormat
                backend = Val(:text)
            elseif tf isa HtmlTableFormat
                backend = Val(:html)
            elseif tf isa LatexTableFormat
                backend = Val(:latex)
            else
                throw(
                    TypeError(
                        :_pt,
                        Union{TextFormat, HtmlTableFormat, LatexTableFormat},
                        typeof(tf)
                    )
                )
            end
        else
            backend = Val(:text)
        end
    end

    # Verify if we have a circular reference.
    ptd = get(io, :__PRETTY_TABLES_DATA__, nothing)

    if ptd !== nothing
        context = IOContext(io)

        # In this case, `ptd` is a vector with the data printed by
        # PrettyTables.jl. Hence, we need to search if the current one is inside
        # this vector. If true, we have a circular dependency.
        for d in ptd
            if d === _getdata(data)

                if backend === Val(:text)
                    _pt_text_circular_reference(context)
                elseif backend === Val(:html)
                    _pt_html_circular_reference(context)
                elseif backend === Val(:latex)
                    _pt_latex_circular_reference(context)
                end

                return nothing
            end
        end

        # Otherwise, we must push the current data to the vector.
        push!(ptd, _getdata(data))
    else
        context = IOContext(io, :__PRETTY_TABLES_DATA__ => Any[_getdata(data)])
    end

    # Create the structure that stores the print information.
    pinfo = _print_info(
        data;
        alignment               = alignment,
        cell_alignment          = cell_alignment,
        cell_first_line_only    = cell_first_line_only,
        compact_printing        = compact_printing,
        formatters              = formatters,
        header                  = header,
        header_alignment        = header_alignment,
        header_cell_alignment   = header_cell_alignment,
        max_num_of_columns      = max_num_of_columns,
        max_num_of_rows         = max_num_of_rows,
        limit_printing          = limit_printing,
        renderer                = renderer,
        row_labels              = row_labels,
        row_label_alignment     = row_label_alignment,
        row_label_column_title  = row_label_column_title,
        row_number_alignment    = row_number_alignment,
        row_number_column_title = row_number_column_title,
        show_header             = show_header,
        show_row_number         = show_row_number,
        show_subheader          = show_subheader,
        title                   = title,
        title_alignment         = title_alignment
    )

    # Select the appropriate backend.
    if backend === Val(:text)
        _pt_text(context, pinfo; kwargs...)
    elseif backend === Val(:html)
        _pt_html(context, pinfo; kwargs...)
    elseif backend === Val(:latex)
        _pt_latex(context, pinfo; kwargs...)
    end

    return nothing
end

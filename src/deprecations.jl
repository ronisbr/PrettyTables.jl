# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Deprecations.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

#                       Deprecations introduced in v0.12
# ==============================================================================

@deprecate(
    pretty_table(data::Any, header::AbstractVector; kwargs...),
    pretty_table(data; header = header, kwargs...)
)

@deprecate(
    pretty_table(io::IO, data::Any, header::AbstractVector; kwargs...),
    pretty_table(io, data; header = header, kwargs...)
)

@deprecate(
    pretty_table(::Type{String}, data::Any, header::AbstractVector; kwargs...),
    pretty_table(String, data; header = header, kwargs...)
)

@deprecate(
    pretty_table(::Type{HTML}, data::Any, header::AbstractVector; kwargs...),
    pretty_table(HTML, data; header = header, kwargs...)
)

@deprecate(
    pretty_table(data::Any, header::AbstractMatrix; kwargs...),
    pretty_table(
        data;
        header = tuple([header[i, :] for i = 1:size(header, 1)]...),
        kwargs...
    )
)

@deprecate(
    pretty_table(io::IO, data::Any, header::AbstractMatrix; kwargs...),
    pretty_table(
        io,
        data;
        header = tuple([header[i, :] for i = 1:size(header, 1)]...),
        kwargs...
    )
)

@deprecate(
    pretty_table(::Type{String}, data::Any, header::AbstractMatrix; kwargs...),
    pretty_table(
        String,
        data;
        header = tuple([header[i, :] for i = 1:size(header, 1)]...),
        kwargs...
    )
)

@deprecate(
    pretty_table(::Type{HTML}, data::Any, header::AbstractMatrix; kwargs...),
    pretty_table(
        HTML,
        data;
        header = tuple([header[i, :] for i = 1:size(header, 1)]...),
        kwargs...
    )
)

# Those definitions are necessary to avoid ambiguities. They **must** be removed
# together with the previous deprecations.
pretty_table(io::IO, data::AbstractVector; kwargs...) = _pretty_table(io, data; kwargs...)
pretty_table(io::IO, data::AbstractMatrix; kwargs...) = _pretty_table(io, data; kwargs...)

function pretty_table(
    ::Type{String},
    data::AbstractVector;
    color::Bool = false,
    kwargs...
)
    io = IOContext(IOBuffer(), :color => color)
    _pretty_table(io, data; kwargs...)
    return String(take!(io.io))
end

function pretty_table(
    ::Type{String},
    data::AbstractMatrix;
    color::Bool = false,
    kwargs...
)
    io = IOContext(IOBuffer(), :color => color)
    _pretty_table(io, data; kwargs...)
    return String(take!(io.io))
end

function pretty_table(::Type{HTML}, data::AbstractVector; kwargs...)
    if !haskey(kwargs, :backend) && !haskey(kwargs, :tf)
        str = pretty_table(String, data; backend = Val(:html), kwargs...)
    else
        str = pretty_table(String, data; kwargs...)
    end

    return HTML(str)
end

function pretty_table(::Type{HTML}, data::AbstractMatrix; kwargs...)
    if !haskey(kwargs, :backend) && !haskey(kwargs, :tf)
        str = pretty_table(String, data; backend = Val(:html), kwargs...)
    else
        str = pretty_table(String, data; kwargs...)
    end

    return HTML(str)
end

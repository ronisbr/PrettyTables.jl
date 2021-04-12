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

@deprecate(pretty_table(data::Any, header::AbstractVector; kwargs...),
           pretty_table(data; header = header, kwargs...))

@deprecate(pretty_table(io::IO, data::Any, header::AbstractVector; kwargs...),
           pretty_table(io, data; header = header, kwargs...))

@deprecate(pretty_table(::Type{String}, data::Any, header::AbstractVector; kwargs...),
           pretty_table(String, data; header = header, kwargs...))

@deprecate(pretty_table(data::Any, header::AbstractMatrix; kwargs...),
           pretty_table(data;
                        header = [header[i, :] for i = 1:size(header, 1)],
                        kwargs...))

@deprecate(pretty_table(io::IO, data::Any, header::AbstractMatrix; kwargs...),
           pretty_table(io, data;
                        header = [header[i, :] for i = 1:size(header, 1)],
                        kwargs...))

@deprecate(pretty_table(::Type{String}, data::Any, header::AbstractMatrix; kwargs...),
           pretty_table(String, data;
                        header = [header[i, :] for i = 1:size(header, 1)],
                        kwargs...))

pretty_table(io::IO, data::AbstractVector; kwargs...) =
    _pretty_table(io, data; kwargs...)

pretty_table(io::IO, data::AbstractMatrix; kwargs...) =
    _pretty_table(io, data; kwargs...)

function pretty_table(::Type{String}, data::AbstractVector; kwargs...)
    io = IOBuffer()
    _pretty_table(io, data; kwargs...)
    return String(take!(io))
end

function pretty_table(::Type{String}, data::AbstractMatrix; kwargs...)
    io = IOBuffer()
    _pretty_table(io, data; kwargs...)
    return String(take!(io))
end

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Deprecations.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

#                              Introduced in v0.7
# ==============================================================================

# We changed the name of the structre `PrettyTableFormat`. Thus, for now, let's
# create an alias.
export PrettyTableFormat
const PrettyTableFormat = TextFormat

function pretty_table(data::AbstractVecOrMat{T1}, header::AbstractVecOrMat{T2},
                      tf::TextFormat; kwargs...) where {T1,T2}

    @warn "pretty_table(data, header, tf; kwargs...) is deprecated. Please, use pretty_table(data, header; tf = tf, kwargs...)"

    return pretty_table(data, header; tf = tf, kwargs...)
end

function pretty_table(io::IO, data::AbstractVecOrMat{T1},
                       header::AbstractVecOrMat{T2}, tf::TextFormat; kwargs...) where
    {T1,T2}

    @warn "pretty_table(io, data, header, tf; kwargs...) is deprecated. Please, use pretty_table(io, data, header; tf = tf, kwargs...)"

    return pretty_table(io, data, header; tf = tf, kwargs...)
end

function pretty_table(data::AbstractVecOrMat{T}, tf::TextFormat; kwargs...) where T

    @warn "pretty_table(data, tf; kwargs...) is deprecated. Please, use pretty_table(data; tf = tf, kwargs...)"

    return pretty_table(data; tf = tf, kwargs...)
end


function pretty_table(io::IO, data::AbstractVecOrMat{T}, tf::TextFormat;
                      kwargs...) where T

    @warn "pretty_table(io, data, tf; kwargs...) is deprecated. Please, use pretty_table(io, data; tf = tf, kwargs...)"

    return pretty_table(io, data; tf = tf, kwargs...)
end

function pretty_table(dict::Dict{K,V}, tf::TextFormat; kwargs...) where {K,V}

    @warn "pretty_table(dict, tf; kwargs...) is deprecated. Please, use pretty_table(dict; tf = tf, kwargs...)"

    return pretty_table(dict; tf = tf, kwargs...)
end

function pretty_table(io::IO, dict::Dict{K,V}, tf::TextFormat; kwargs...) where {K,V}

    @warn "pretty_table(io, dict, tf; kwargs...) is deprecated. Please, use pretty_table(io, dict; tf = tf, kwargs...)"

    return pretty_table(io, dict; tf = tf, kwargs...)
end

function pretty_table(table, tf::TextFormat; kwargs...)

    @warn "pretty_table(table, tf; kwargs...) is deprecated. Please, use pretty_table(table; tf = tf, kwargs...)"

    return pretty_table(table; tf = tf, kwargs...)
end

function pretty_table(io::IO, table, tf::TextFormat; kwargs...)

    @warn "pretty_table(io, table, tf; kwargs...) is deprecated. Please, use pretty_table(io, table; tf = tf, kwargs...)"

    return pretty_table(io, table; tf = tf, kwargs...)
end

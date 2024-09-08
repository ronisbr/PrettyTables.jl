## Description #############################################################################
#
# Definition of types and structures for the tests.
#
############################################################################################

# == Circular Reference ====================================================================

struct CircularRef
    A1::Vector{Any}
    A2::Vector{Any}
    A3::Vector{Any}
    A4::Vector{Any}
end

Tables.istable(x::CircularRef) = true
Tables.columnaccess(::CircularRef) = true
Tables.columnnames(x::CircularRef) = [:A1, :A2, :A3, :A4]
Tables.columns(x::CircularRef) = x

function Base.show(io::IO, cf::CircularRef)
    context = IOContext(io, :color => false)
    pretty_table(context, cf; renderer = :show)
    return nothing
end

function Base.show(io::IO, ::MIME"text/plain", cf::CircularRef)
    context = IOContext(io, :color => false)
    pretty_table(
        context,
        cf;
        line_breaks = true,
        renderer = :show
    )
    return nothing
end

function Base.show(io::IO, ::MIME"text/html", cf::CircularRef)
    pretty_table(io, cf; backend = :html, renderer = :show)
    return nothing
end

function Base.show(io::IO, ::MIME"text/latex", cf::CircularRef)
    pretty_table(io, cf; backend = :latex, renderer = :show)
    return nothing
end

function Base.show(io::IO, ::MIME"text/markdown", cf::CircularRef)
    pretty_table(io, cf; backend = :markdown, renderer = :show)
    return nothing
end

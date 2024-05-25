## Description #############################################################################
#
# Private functions and macros.
#
############################################################################################

const _html_alignment = Dict(
    :l => "left",
    :L => "left",
    :c => "center",
    :C => "center",
    :r => "right",
    :R => "right"
)

function _add_text_alignment_to_style!(
    style::Dict{String, String},
    alignment::Symbol
)
    if (alignment == :n) || (alignment == :N)
        return nothing
    elseif haskey(_html_alignment, alignment)
        return style["text-align"] = _html_alignment[alignment]
    else
        return style["text-align"] = _html_alignment[:r]
    end

    return nothing
end

# Create the string to be used in the HTML `style` property given a set of `style`s passed
# in a dictionary.
function _create_html_style(style::Dict{String, String})
    # If there is no keys in the style dictionary, just return the tag.
    if isempty(style)
        return ""
    else
        # Create the style string.
        style_str = " style = \""

        # We must sort the keys so that we can provide stable outputs.
        v   = collect(values(style))
        k   = collect(keys(style))
        ind = sortperm(collect(keys(style)))
        vk  = @view k[ind]
        vv  = @view v[ind]

        num_styles = length(vk)

        @inbounds for i in 1:num_styles
            # If the value is empty, then just continue.
            value = vv[i]
            isempty(value) && continue

            style_str *= vk[i] * ": "
            style_str *= value * ";"

            i != num_styles && (style_str *= " ")
        end

        return style_str * "\""
    end
end

# Open an HTML `tag` with `properties` and `style`.
function _open_html_tag(
    tag::String;
    properties::Union{Nothing, Dict{String, String}} = nothing,
    style::Union{Nothing, Dict{String, String}} = nothing
)
    # Compile the text with the properties.
    properties_str = ""

    if !isnothing(properties)
        for (k, v) in properties
            if !isempty(v)
                properties_str *= " " * k * " = \"" * _escape_html_str(v) * "\""
            end
        end
    end

    # Compile the text with the style.
    style_str = ""

    if !isnothing(style)
        style_str = _create_html_style(style)
    end

    # Return the tag.
    return "<" * tag * properties_str * style_str * ">"
end

# Close an HTML `tag`.
function _close_html_tag(tag::String)
    return "</" * tag * ">"
end

# Create an HTML `tag` with a `content`, `properties`, and `style`.
function _create_html_tag(
    tag::String,
    content::String;
    properties::Union{Nothing, Dict{String, String}} = nothing,
    style::Union{Nothing, Dict{String, String}} = nothing
)
    return _open_html_tag(tag; properties, style) * content * _close_html_tag(tag)
end

# Print the HTML top bar.
function _print_top_bar(
    @nospecialize(buf::IO),
    top_left_str::String,
    top_left_str_decoration::HtmlDecoration,
    top_right_str::String,
    top_right_str_decoration::HtmlDecoration,
    il::Int,
    ns::Int,
    minify::Bool
)
    style = Dict{String, String}()

    # Check if there is information to be displayed in the top bar.
    if !isempty(top_left_str) || !isempty(top_right_str)
        _aprintln(
            buf,
            _open_html_tag("div"),
            il,
            ns,
            minify
        )
        il += 1

        # -- Top Left ----------------------------------------------------------------------

        if !isempty(top_left_str)
            empty!(style)
            style["float"] = "left"
            _aprintln(buf, _open_html_tag("div"; style), il, ns, minify)
            il += 1

            _aprintln(
                buf,
                _create_html_tag(
                    "span",
                    _escape_html_str(top_left_str);
                    style = Dict(top_left_str_decoration)
                ),
                il,
                ns,
                minify
            )

            il -= 1
            _aprintln(buf, _close_html_tag("div"), il, ns, minify)
        end

        # -- Top Right ---------------------------------------------------------------------

        if !isempty(top_right_str)
            empty!(style)
            style["float"] = "right"
            _aprintln(buf, _open_html_tag("div"; style), il, ns, minify)
            il += 1

            _aprintln(
                buf,
                _create_html_tag(
                    "span",
                    _escape_html_str(top_right_str);
                    style = Dict(top_right_str_decoration)
                ),
                il,
                ns,
                minify
            )

            il -= 1
            _aprintln(buf, _close_html_tag("div"), il, ns, minify)
        end

        # We need to clear the floats so that the table is rendered below the top bar.
        empty!(style)
        style["clear"] = "both"
        _aprintln(buf, _create_html_tag("div", ""; style), il, ns, minify)

        il -= 1
        _aprintln(buf, _close_html_tag("div"), il, ns, minify)
    end
end

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Private functions and macros.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

const _html_alignment = Dict(
    :l => "left",
    :L => "left",
    :c => "center",
    :C => "center",
    :r => "right",
    :R => "right"
)

function _html_text_alignment_dict(alignment::Symbol)
    if (alignment == :n) || (alignment == :N)
        return Dict{String, String}()
    elseif haskey(_html_alignment, alignment)
        return Dict{String, String}("text-align" => _html_alignment[alignment])
    else
        return Dict{String, String}("text-align" => _html_alignment[:r])
    end
end

function _styled_html(
    tag::String,
    text::String,
    style::Dict{String,String} = Dict{String,String}();
    class::String = ""
)
    str_class = isempty(class) ? "" : " class = \"" * class * "\""

    # If there is no keys in the style dictionary, just return the tag.
    if isempty(style)
        return "<" * tag * str_class * ">" * text * "</" * tag * ">"
    else
        # Create the style string.
        style_str = ""

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

        return "<" * tag * str_class * " style = \"" * style_str * "\">" * text * "</" * tag * ">"
    end
end

# Print the HTML top bar.
function _print_top_bar(
    buf::IO,
    top_left_str::String,
    top_left_str_decoration::HTMLDecoration,
    top_right_str::String,
    top_right_str_decoration::HTMLDecoration,
    il::Int,
    ns::Int,
    minify::Bool
)
    # Check if there is information to be displayed in the top bar.
    if !isempty(top_left_str) || !isempty(top_right_str)
        _aprintln(
            buf,
            "<div>",
            il,
            ns,
            minify
        )
        il += 1

        # Top left
        # ----------------------------------------------------------------------

        if !isempty(top_left_str)
            _aprintln(
                buf,
                "<div style=\"float: left\">",
                il,
                ns,
                minify
            )
            il += 1

            _aprintln(
                buf,
                _styled_html("span", top_left_str, Dict(top_left_str_decoration)),
                il,
                ns,
                minify
            )

            il -= 1
            _aprintln(buf, "</div>", il, ns, minify)
        end

        # Top right
        # ----------------------------------------------------------------------

        if !isempty(top_right_str)
            _aprintln(
                buf,
                "<div style=\"float: right\">",
                il,
                ns,
                minify
            )
            il += 1

            _aprintln(
                buf,
                _styled_html("span", top_right_str, Dict(top_right_str_decoration)),
                il,
                ns,
                minify
            )

            il -= 1
            _aprintln(buf, "</div>", il, ns, minify)
        end

        # We need to clear the floats so that the table is rendered below the
        # top bar.
        _aprintln(buf, "<div style=\"clear: both\"></div>", il, ns, minify)

        il -= 1
        _aprintln(buf, "</div>", il, ns, minify)
    end
end

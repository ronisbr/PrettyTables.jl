# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Private functions and macros.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

const _html_alignment = Dict(:l => "left",
                             :c => "center",
                             :r => "right")

function _styled_html(tag::String, text::String, style::Dict{String,String} = Dict{String,String}())
    # If there is no keys in the style dictionary, just return the tag.
    if isempty(style)
        return "<" * tag * ">" * text * "</" * tag * ">"
    else
        # Create the sytle string.
        style_str = ""

        for key in keys(style)
            # If the value is empty, then just continue.
            value = style[key]
            isempty(value) && continue

            style_str *= key * ": "
            style_str *= style[key] * "; "
        end

        return "<" * tag * " style = \"" * style_str * "\">" * text * "</" * tag * ">"
    end
end



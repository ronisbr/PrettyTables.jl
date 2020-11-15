# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Private functions and macros.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

const _html_alignment = Dict(:l => "left",
                             :L => "left",
                             :c => "center",
                             :C => "center",
                             :r => "right",
                             :R => "right")

function _styled_html(tag::String, text::String,
                      style::Dict{String,String} = Dict{String,String}();
                      class::String = "")

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

        @inbounds for i = 1:num_styles
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



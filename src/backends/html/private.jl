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

        # We must sort the keys so that we can provide stable outputs.
        v   = collect(values(style))
        k   = collect(keys(style))
        ind = sortperm(collect(keys(style)))
        vk  = @view k[ind]
        vv  = @view v[ind]

        for i = 1:length(vk)
            # If the value is empty, then just continue.
            value = vv[i]
            isempty(value) && continue

            style_str *= vk[i] * ": "
            style_str *= value * "; "
        end

        return "<" * tag * " style = \"" * style_str * "\">" * text * "</" * tag * ">"
    end
end



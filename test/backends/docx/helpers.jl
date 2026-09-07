## Description #############################################################################
#
# Word Back End: Helpers to inspect the rendered Word tables.
#
############################################################################################

docx_cells(table::W.Table, row::Int) = table.rows[row].cells

docx_cell(table::W.Table, row::Int, col::Int) = docx_cells(table, row)[col]

docx_paragraph(cell::W.TableCell) = only(cell.children)

docx_runs(cell::W.TableCell) = docx_paragraph(cell).children

function docx_text(cell::W.TableCell)
    buf = IOBuffer()

    for run in docx_runs(cell)
        for child in run.children
            (child isa W.Text) && print(buf, child.text)
            (child isa W.Break) && print(buf, '\n')
        end
    end

    return String(take!(buf))
end

docx_row_text(table::W.Table, row::Int) = map(docx_text, docx_cells(table, row))

docx_gridspans(table::W.Table, row::Int) =
    map(c -> something(c.properties.gridspan, 1), docx_cells(table, row))

function docx_border(cell::W.TableCell, side::Symbol)
    borders = cell.properties.borders
    isnothing(borders) && return nothing
    return getproperty(borders, side)
end

docx_border_size(cell::W.TableCell, side::Symbol) =
    convert(W.EighthPoint, docx_border(cell, side).size).value

docx_hex(color::W.AutomaticDefault{W.HexColor}) = color.value.hex

docx_shading(cell::W.TableCell) = cell.properties.shading

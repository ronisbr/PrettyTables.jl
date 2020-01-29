# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
#
#   Pre-defined formats for HTML tables.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export html_default, html_dark, html_minimalist, html_simple, html_matrix

const html_default = HTMLTableFormat()

const html_dark = HTMLTableFormat(
    css = """
    table, td, th {
        border-collapse: collapse;
        font-family: sans-serif;
    }

    td, th {
        border-bottom: 0;
        padding: 4px
    }

    tr:nth-child(even) {
        background: #242627 !important;
        color: white;
    }

    tr:nth-child(odd) {
        background: #363b3d !important;
        color: white;
    }

    tr.header {
        background: #000 !important;
        color: #5fa6c2 !important;
        font-weight: bold;
    }

    tr.subheader {
        background: #242627 !important;
        color: white;
    }

    tr.headerLastRow {
        border-bottom: 2px solid black;
    }

    th.rowNumber, td.rowNumber {
        text-align: right;
    }
    """
)

const html_minimalist = HTMLTableFormat(
    css = """
    table, td, th {
        border-collapse: collapse;
        font-family: sans-serif;
    }

    td, th {
        border-bottom: 0;
        background: #fff !important;
        padding: 4px
    }

    tr.header {
        background: #fff !important;
        font-weight: bold;
    }

    tr.subheader {
        background: #fff !important;
        color: dimgray;
    }

    tr.headerLastRow {
        border-bottom: 2px solid black;
    }

    th.rowNumber, td.rowNumber {
        text-align: right;
    }
    """
)

const html_simple = HTMLTableFormat(
    css = """
    table, td, th {
        border-collapse: collapse;
        font-family: sans-serif;
    }

    td, th {
        border-bottom: 0;
        padding: 4px
    }

    tr:nth-child(odd) {
        background: #eee;
    }

    tr:nth-child(even) {
        background: #fff;
    }

    tr.header {
        background: #fff !important;
        font-weight: bold;
    }

    tr.subheader {
        background: #fff !important;
        color: dimgray;
    }

    tr.headerLastRow {
        border-bottom: 2px solid black;
    }

    th.rowNumber, td.rowNumber {
        text-align: right;
    }
    """
)
const html_matrix = HTMLTableFormat(
    css = """
    table {
        position: relative;
    }

    table::before,
    table::after {
        content: "";
        position: absolute;
        top: 0;
        border: 1px solid #000;
        width: 6px;
        height: 100%;
    }

    table::before {
        left: -6px;
        border-right: 0px;
    }

    table::after {
        right: -6px;
        border-left: 0px;
    }

    td {
        padding: 5px;
        text-align: center;
    }
    """
)


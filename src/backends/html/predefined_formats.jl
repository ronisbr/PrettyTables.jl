## Description #############################################################################
#
# Pre-defined formats for HTML tables.
#
############################################################################################

export tf_html_default, tf_html_dark, tf_html_minimalist, tf_html_simple
export tf_html_matrix

const tf_html_default = HtmlTableFormat()

const tf_html_dark = HtmlTableFormat(
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

const tf_html_minimalist = HtmlTableFormat(
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

const tf_html_simple = HtmlTableFormat(
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

const tf_html_matrix = HtmlTableFormat(
    css = """
    table {
        position: relative;
    }

    table::before,
    table::after {
        border: 1px solid #000;
        content: "";
        height: 100%;
        position: absolute;
        top: 0;
        width: 6px;
    }

    table::before {
        border-right: 0px;
        left: -6px;
    }

    table::after {
        border-left: 0px;
        right: -6px;
    }

    td {
        padding: 5px;
        text-align: center;
    }
    """
)


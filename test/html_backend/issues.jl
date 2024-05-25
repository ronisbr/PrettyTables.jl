## Description #############################################################################
#
# Tests of reported issues.
#
############################################################################################

# == Issue #170 ============================================================================

@testset "Issue #170 - Pringint of UndefInitializer()" begin
    v = Vector{Any}(undef, 5)
    v[1] = undef
    v[2] = "String"
    v[5] = π

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: right;">Col. 1</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">UndefInitializer()</td>
    </tr>
    <tr>
      <td style = "text-align: right;">String</td>
    </tr>
    <tr>
      <td style = "text-align: right;">#undef</td>
    </tr>
    <tr>
      <td style = "text-align: right;">#undef</td>
    </tr>
    <tr>
      <td style = "text-align: right;">π</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        v;
        backend = Val(:html)
    )

    @test result == expected

    expected = """
<table>
  <thead>
    <tr class = "header headerLastRow">
      <th style = "text-align: right;">Col. 1</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">UndefInitializer()</td>
    </tr>
    <tr>
      <td style = "text-align: right;">String</td>
    </tr>
    <tr>
      <td style = "text-align: right;">#undef</td>
    </tr>
    <tr>
      <td style = "text-align: right;">#undef</td>
    </tr>
    <tr>
      <td style = "text-align: right;">π</td>
    </tr>
  </tbody>
</table>
"""

    result = pretty_table(
        String,
        v;
        backend = Val(:html),
        renderer = :show
    )

    @test result == expected
end

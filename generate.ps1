Clear-Host
Import-Module PowerYaml.psm1 # import the YAML parser if necessary (get it via PSGET)
set-psdebug -strict # catch a few extra bugs
 
$ServerName = 'nt7565' 
$Database = 'MARKITEDM_DEV_DX' 
$SQL =@"
SELECT 
  ROUTINE_SCHEMA AS [schema],
  ROUTINE_NAME AS [name],
  CREATED AS [created],
  LAST_ALTERED AS [modified],
  DATA_TYPE AS returnType,
  ROUTINE_DEFINITION AS definition
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_SCHEMA IN('ajr', 'dbo')
  AND ROUTINE_NAME LIKE 'fn%'
"@

# create the SqlClient connection
$conn = new-Object System.Data.SqlClient.SqlConnection("Server=$Servername;DataBase=$Database;Integrated Security=True")#
$conn.Open() | out-null #open the connection

# We add a handler for the warnings just in case we get one
$message = [string]'';
$handler = [System.Data.SqlClient.SqlInfoMessageEventHandler] { param ($sender,
              $event)    $global:message = "$($message)`n $($event.Message)" };
$conn.add_InfoMessage($handler);
$conn.FireInfoMessageEventOnUserErrors = $true

$cmd = new-Object System.Data.SqlClient.SqlCommand($SQL, $conn)
$rdr = $cmd.ExecuteReader()
$datatable = new-object System.Data.DataTable
$datatable.Load($rdr)
if ($message -ne '') { Write-Warning $message } # tell the user of any warnings or info messages

$functions = @() #initialise the array of hashtables
foreach ($row in $datatable.Rows) # we read the routines row by row
{
 
    if ("$($row['definition'])" -cmatch '(?ism)(?<=/\*\*).*?(?=\*\*/)')
    {
        $fn = @{}
        #parse the YAML into a hashtable
        try { 
            $fn = Get-Yaml $($matches[0])
        }
        catch {
            write-host `r`n
            write-warning "could not parse $($row['name']) `r`n$($matches[0])"
        }
        #add the rest of the objects
        $fn.name = $row.name
        $fn.schema = $row.schema
        $fn.created = $row.created
        $fn.modified = $row.modified
        $fn.returnType = $row.returnType

        $functions += $fn; #and add-in each routine to the array.
    }
}

$scriptPath = Split-Path -parent $PSCommandPath
$html = Get-Content $scriptPath\documentationTemplate.html


######## HTML generation
$html = $html.Replace("{{database}}", $ServerName + "\" + $Database)

$dateGenerated = Get-Date
$html = $html.Replace("{{dateGenerated}}", $dateGenerated)


$h = ""
foreach ($f in $functions) {
#$f.parameters
    # parameter list
    $pHtml = @"
        <table>
            <tr>
                <th>Name</th>
                <th>Type</th>
                <th>Description</th>
                <th>If NULL</th>
            </tr>

"@

    foreach ($p in $f.parameters) {
        $pHtml += @"
            <tr>
                <td>$($p.name)</td>
                <td>$($p.type)</td>
                <td>$($p.description)</td>
                <td>$($p.ifNull)</td>
            </tr>
"@
    }
    $pHtml += "</table>"

    # example list
    $eHtml = "<ol class=""examples"">"
    foreach ($e in $f.examples) {
        $eHtml += "<li>$($e)</li>"
    }
    $eHtml += "</ol>"

    $h += "<a name=""$($f.schema).$($f.name)""></a>"
    $h += "<h3>$($f.schema).$($f.name)</h3>"
    $h += "<p>Created by $($f.author) on $($f.created)</p>"
    $h += "<h4>Summary</h4>"
    $h += "<p>$($f.summary)</p>"
    $h += "<h4>Parameters</h4>"
    if (0 -lt $f.parameters.Length) { $h += $pHtml } else { $h += "none" }
    $h += "<h4>Returns $($f.returnType)</h4>"
    $h += "<p>$($f.returns)</p>"
    if (0 -lt $f.examples.Length) {
        $h += "<h4>Examples</h4>"
        $h += $eHtml
    }
    $h += "<hr />"

}

$html = $html.Replace("{{functions}}", $h)


# functions index/menu HTML block
$h = "<ul>"
foreach ($f in $functions) {
    $h += "<li><a href=""#$($f.schema).$($f.name)"">$($f.schema).$($f.name)</a></li>"
}
$h += "</ul>"

$html = $html.Replace("{{functionsIndex}}", $h)


$html > $scriptPath\documentation.html





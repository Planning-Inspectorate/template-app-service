# Read the Checkov output file
$output = Get-Content -Path "checkov_output.txt"

# Initialize an array to store the parsed results
$results = @()

# Initialize variables to store current check details
$currentCheck = @{ }
$lineNumber = 1

# Parse the output line by line
foreach ($line in $output) {
    if ($line -match 'Check: (CKV[^\s]+): "([^"]+)"') {
        # Save the previous check details if any
        if ($currentCheck.CheckID) {
            $results += [PSCustomObject]$currentCheck
        }
        # Start a new check
        $currentCheck = @{
            LineNumber = $lineNumber
            CheckID = $matches[1]
            Description = $matches[2]
            Status = ""
            Resource = ""
            File = ""
            Guide = ""
            SuppressComment = ""
            CodeLineNumber = ""
        }
    } elseif ($line -match 'FAILED for resource: (.+)') {
        $currentCheck.Status = "FAILED"
        $currentCheck.Resource = $matches[1]
        $currentCheck.CodeLineNumber = $lineNumber
    } elseif ($line -match 'SKIPPED for resource: (.+)') {
        $currentCheck.Status = "SKIPPED"
        $currentCheck.Resource = $matches[1]
        $currentCheck.CodeLineNumber = $lineNumber
    } elseif ($line -match 'File: (.+):(\d+)') {
        $currentCheck.File = $matches[1]
        $currentCheck.CodeLineNumber = $matches[2]
    } elseif ($line -match 'Guide: (.+)') {
        # Remove any extra formatting characters from the Guide link
        $currentCheck.Guide = $matches[1] -replace '\x1b\[1m', '' -replace '\x1b\[0m', ''
    } elseif ($line -match 'Suppress comment: (.+)') {
        $currentCheck.SuppressComment = $matches[1]
    }
    $lineNumber++
}

# Save the last check details
if ($currentCheck.CheckID) {
    $results += [PSCustomObject]$currentCheck
}

# Export the results to a CSV file with Line Number as the first column
$results | Select-Object LineNumber, Resource, File, CodeLineNumber, CheckID, Guide, SuppressComment, Status, Description | Export-Csv -Path "checkov_results.csv" -NoTypeInformation

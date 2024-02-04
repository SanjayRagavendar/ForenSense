$dateTime = Get-Date -Format "yyyy-MM-dd_HH-mm"
$endpointUrl = "https://127.0.0.1:5000/api/report"   

$evidenceDirectory = "C:\ForenSense"
New-Item -ItemType Directory -Path $evidenceDirectory -Force

$systemInfo = Get-WmiObject Win32_ComputerSystem
$osInfo = Get-WmiObject Win32_OperatingSystem
$diskInfo = Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3}


$reportFile = "$evidenceDirectory\forensic_report.html"

# Start building the HTML content for the report
$htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forensic Investigation Report</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            padding: 20px;
        }
        h1 {
            font-size: 24px;
        }
        h2 {
            font-size: 20px;
        }
        pre {
            background-color: #f4f4f4;
            padding: 10px;
            border-radius: 5px;
            overflow-x: auto;
        }
    </style>
</head>
<body>
    <h1>Forensic Investigation Report - Case $dateTime</h1>

    <h2>System Information:</h2>
    <pre>$($systemInfo | Out-String)</pre>

    <h2>Disk Information:</h2>
    <pre>$($diskInfo | Out-String)</pre>

</body>
</html>
"@

# Write the HTML content to the report file
$htmlContent | Out-File -Encoding UTF8 $reportFile

Write-Host "Forensic investigation completed. Report saved to: $reportFile"

# Invoke the REST API to send the report file
Invoke-RestMethod -Uri $endpointUrl -Method Post -Body "file=$reportFile"

# Disable network adapters
Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Disable-NetAdapter -Confirm:$false

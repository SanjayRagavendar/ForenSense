# PowerShell script to monitor system stats and send anomalies to Flask endpoint

# Function to send data to Flask endpoint
function Send-ToFlaskEndpoint($data) {
    $apiEndpoint = "http://127.0.0.1:5000/api/system-stats"
    Invoke-RestMethod -Uri $apiEndpoint -Method POST -Body $data -ContentType "application/json"
}

# Function to monitor system stats
function Monitor-SystemStats {
    $intervalInSeconds = 20

    while ($true) {
        # Get system stats
        $systemStats = @{
            "Timestamp"      = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            "RecentlyAccessedFiles" = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" | Select-Object -ExpandProperty "Count"
            "ModifiedFiles" = Get-Process | Where-Object { $_.StartTime -gt (Get-Date).AddMinutes(-5) } | Select-Object -Property Path -Unique
            "RamUsage"       = (Get-Counter -Counter "\Memory\Available MBytes").CounterSamples.CookedValue
            "CpuUsage"       = (Get-Counter -Counter "\Processor(_Total)\% Processor Time").CounterSamples.CookedValue
            "Load"           = (Get-WmiObject Win32_ComputerSystem).LoadPercentage
        }

        # Check for anomalies (customize as needed)
        $anomaliesDetected = $false

        # Example: Check if RamUsage exceeds a threshold
        if ($systemStats.RamUsage -gt 90) {
            $anomaliesDetected = $true
        }

        # Example: Check if CpuUsage exceeds a threshold
        if ($systemStats.CpuUsage -gt 90) {
            $anomaliesDetected = $true
        }

        # Example: Check if Load exceeds a threshold
        if ($systemStats.Load -gt 90) {
            $anomaliesDetected = $true
        }

        # If anomalies detected, send data to Flask endpoint
        if ($anomaliesDetected) {
            $systemStatsJson = $systemStats | ConvertTo-Json
            Send-ToFlaskEndpoint $systemStatsJson
        }

        # Wait for the specified interval before checking again
        Start-Sleep -Seconds $intervalInSeconds
    }
}

# Start monitoring system stats
Monitor-SystemStats

$importantFiles = @{
    "C:\Windows\System32\ntoskrnl.exe"   = "expected_checksum1";
    "C:\Windows\System32\kernel32.dll"   = "expected_checksum2";
    "C:\Windows\System32\ntdll.dll"      = "expected_checksum3";
    "C:\Windows\System32\services.exe"   = "expected_checksum4";
    "C:\Windows\System32\lsass.exe"      = "expected_checksum5";
    "C:\Windows\System32\svchost.exe"    = "expected_checksum6";
    "C:\Windows\System32\user32.dll"     = "expected_checksum7";
    "C:\Windows\System32\advapi32.dll"   = "expected_checksum8";
    "C:\Windows\System32\kernelbase.dll" = "expected_checksum9";
    "C:\Windows\System32\win32k.sys"     = "expected_checksum10";
}

# API Endpoint URL
$apiEndpoint = "http://127.0.0.1:5000/api/checksum-anomaly"

# Flag to check if anomalies are detected
$anomaliesDetected = $false

foreach ($file in $importantFiles.Keys) {
    if (Test-Path $file -PathType Leaf) {
        $checksum = Get-FileHash -Path $file -Algorithm MD5
        $expectedChecksum = $importantFiles[$file]

        # Compare the calculated checksum with the expected checksum
        if ($checksum.Hash -ne $expectedChecksum) {
            $anomaliesDetected = $true

            $anomalyData = @{
                "file"              = $file
                "expectedChecksum" = $expectedChecksum
                "actualChecksum"   = $checksum.Hash
                "timestamp"        = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            }

            # Post anomaly data to API endpoint
            Invoke-RestMethod -Uri $apiEndpoint -Method POST -Body ($anomalyData | ConvertTo-Json) -ContentType "application/json"
        }
    } else {
        Write-Host "File not found: $($file)"
    }
}

# Check if anomalies were detected and send a message to Flask API
if ($anomaliesDetected) {
    "Anomalies detected! Data sent to API." | Out-Host
} else {
    "No anomalies found." | Out-Host
}

$endpointUrl = "http://127.0.0.1:5000/api/reg"

$registryRootKeys = @(
    "HKLM:\Software",
    "HKLM:\SYSTEM\CurrentControlSet",
    "HKCU:\Software",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion"
)

$registryData = @{}

foreach ($rootKey in $registryRootKeys) {
    try {
        $subkeys = Get-ChildItem -Path $rootKey -Recurse -ErrorAction Stop
        foreach ($subkey in $subkeys) {
            $keyPath = $subkey.PSPath.Replace("Microsoft.PowerShell.Core\Registry::", "")
            try {
                $key = Get-Item -Path $keyPath -ErrorAction Stop
                $properties = $key | Get-ItemProperty
                $registryData += @{
                    "KeyPath" = $keyPath
                    "Properties" = $properties
                }
            } catch {
                Write-Host "Error accessing subkey: $keyPath"
            }
        }
    } catch {
        Write-Host "Error accessing root key: $rootKey"
    }
}

$jsonData = $registryData | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $endpointUrl -Method Post -Body $jsonData -ContentType "application/json"
    Write-Host "Data sent successfully. Response: $response"
} catch {
    Write-Host "Error sending data to the endpoint: $_"
}

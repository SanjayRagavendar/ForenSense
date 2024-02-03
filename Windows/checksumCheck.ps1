# Define the important files and their expected checksums
$importantFiles = @{
    "C:\Windows\System32\ntoskrnl.exe" = "expected_checksum1",
    "C:\Windows\System32\kernel32.dll" = "expected_checksum2",
    "C:\Windows\System32\ntoskrnl.exe"="",
    "C:\Windows\System32\kernel32.dll"="",
    "C:\Windows\System32\ntdll.dll"="",
    "C:\Windows\System32\services.exe"="",
    "C:\Windows\System32\lsass.exe"="",
    "C:\Windows\System32\svchost.exe"="",
    "C:\Windows\System32\user32.dll"="",
    "C:\Windows\System32\advapi32.dll"="",
    "C:\Windows\System32\kernelbase.dll"="",
    "C:\Windows\System32\win32k.sys"=""
}

foreach ($file in $importantFiles.Keys) {
    if (Test-Path $file -PathType Leaf) {
        $checksum = Get-FileHash -Path $file -Algorithm MD5
        $expectedChecksum = $importantFiles[$file]

        # Compare the calculated checksum with the expected checksum
        if ($checksum.Hash -ne $expectedChecksum) {
            Write-Host "Checksum mismatch for $($file). Expected: $expectedChecksum, Actual: $($checksum.Hash)"
            
            Invoke-WebRequest -Uri "https://172.168.0.1:5000/api/chksum" -Method POST -Body "Checksum mismatch for $file. Expected: $expectedChecksum, Actual: $($checksum.Hash)"
        }
    } else {
        Write-Host "File not found: $($file)"
    }
}

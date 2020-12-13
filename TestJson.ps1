[bool]$validJson = $false
[bool]$validPath = $false
[string]$jsonFile = $null

while (-not $validPath) {
    $fileName = Read-Host "Enter the path to the file (C:\***\***\FileName.json)"
    $validPath = Test-Path -Path $fileName
    if (-not ($validPath)) {
        Write-Host "Path is not valid"
    }
}


try {    
    $jsonFile = Get-Content $fileName | Out-String | ConvertFrom-Json     
    $validJson = $true
}
catch {
    $validJson = $false
}


if ($validJson) {
    Write-Host "Provided text has been correctly parsed to JSON";
} else {
    Write-Host "Provided text is not a valid JSON string";
}


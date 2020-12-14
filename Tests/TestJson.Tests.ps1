




BeforeAll {
    function CheckJson {

        param (
            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string]$fileName
        )

        [bool]$validJson = $true
        [bool]$validPath = $false
        [string]$jsonFile = $null
    
        $validPath = Test-Path -Path $fileName
        if (-not ($validPath)) {
            Write-Host "Path is not valid"
            $validJson = $false
        }
        
        if ($validJson) {
            try {    
                $jsonFile = Get-Content $fileName | Out-String | ConvertFrom-Json     
            }
            catch {
                Write-Host "Provided text is not a valid JSON string";
                $validJson = $false
            }
        }
        
        return $validJson;
    }
}

Describe "Test-JSON"{
    It "Valid Json" {
        CheckJson | Should -Be $true
    }  
}


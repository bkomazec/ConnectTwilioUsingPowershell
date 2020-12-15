using module .\CredentialProcessor.psm1
using module .\Credentials.psm1

class CredentialManager {

    hidden[CredentialProcessor]$credentialProcessor = $null
    [bool]$credentials_set = $false
    [Credentials]$credentials = $null

    CredentialManager(){}

    [void] InitFromFile(){
        $this.credentialProcessor = [CredentialProcessor]::new()      
        $fileName = Read-Host "Enter the path to the file (C:\***\***\FileName.json)"
        [TestJsonResponse]$response = $this.credentialProcessor.InitFromFile($fileName)

        switch ($response) {
            OK { $this.SetCredentials(); Write-Host "Credentials set successfully" -ForegroundColor Green }
            PathNotValid {$this.ClearCredentials(); Write-Host "Path is not valid" -ForegroundColor Red }
            Empty { $this.ClearCredentials(); Write-Host "File is empty" -ForegroundColor Red }
            WrongFormat { $this.ClearCredentials(); Write-Host "Provided text is not a valid JSON string" -ForegroundColor Red }
            WrongCredentials { $this.ClearCredentials(); Write-Host "Some credentials are empty or missing" -ForegroundColor Red }
        }
    }

    [void]InitFromUserInput(){
        $this.credentialProcessor = [CredentialProcessor]::new()
        if($null -eq $this.credentialProcessor.InitFromUserInput()){
            $this.ClearCredentials()
        }   
        else{
            $this.SetCredentials()
        }
    }

    hidden[void]ClearCredentials(){
        $this.credentials_set = $false
        $this.credentialProcessor = $null
        $this.credentials = $null
    }

    hidden[void]SetCredentials(){
        $this.credentials_set = $true
        $this.credentials = $this.credentialProcessor.credentials
    }
}


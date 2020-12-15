using module .\CredentialProcessor.psm1
using module .\Credentials.psm1

class CredentialManager {

    hidden[CredentialProcessor]$credentialProcessor = $null
    [bool]$credentials_set = $false
    [Credentials]$credentials = $null

    CredentialManager(){}

    [void] InitFromFile(){
        $this.credentialProcessor = [CredentialProcessor]::new()
        $fileName = ""
      
        $fileName = Read-Host "Enter the path to the file (C:\***\***\FileName.json)"

        if($null -eq $this.credentialProcessor.InitFromFile($fileName)){
            $this.credentials_set = $false
            $this.credentialProcessor = $null
            $this.credentials = $null
        }    
        else{
            $this.credentials_set = $true
            $this.credentials = $this.credentialProcessor.credentials
        }
    }

    [void]InitFromUserInput(){
        $this.credentialProcessor = [CredentialProcessor]::new()
        if($null -eq $this.credentialProcessor.InitFromUserInput()){
            $this.credentials_set = $false
            $this.credentialProcessor = $null
            $this.credentials = $null
        }   
        else{
            $this.credentials_set = $true
            $this.credentials = $this.credentialProcessor.credentials
        }
    }
}


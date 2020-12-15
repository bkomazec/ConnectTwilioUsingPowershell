using module .\CredentialManager.psm1
using module .\Credentials.psm1
using module .\SMSApi.psm1

class Twilio {

    [CredentialManager]$credentialManager = $null
    [SMSApi]$smsApi = $null
    
    Twilio(){
        $this.credentialManager = [CredentialManager]::new()        
    }

    [void]SetCredentialsFromFile(){
        $this.credentialManager.InitFromFile()
        $this.InitializeApi()        
    }

    [void]SetCredentialsFromUserInput(){
        $this.credentialManager.InitFromUserInput()
        $this.InitializeApi()
    }

    hidden[void]InitializeApi(){
        if($this.credentialManager.credentials_set){
            $this.smsApi = [SMSApi]::new($this.credentialManager.credentials)
            Write-Host "Api successfully set" -ForegroundColor Green
        }
        else{
            Write-Host "Error setting Api" -ForegroundColor Red
        }
    }

    [void]SendSMS(){
        if($this.credentialManager.credentials_set){
            $this.smsApi.SendMessage()
        }
        else{
            Write-Host "Credentials are not set"
        }
    }

    [void]GetAllMessages(){
        if($this.credentialManager.credentials_set){
            $this.smsApi.GetMessages()
        }
        else{
            Write-Host "Credentials are not set"
        }
    }

    [void]DeleteMessage(){
        if($this.credentialManager.credentials_set){
            $messageId = Read-Host "Enter the message Id"
            $this.smsApi.DeleteMessage($messageId)
        }
        else{
            Write-Host "Credentials are not set"
        }
    }
}















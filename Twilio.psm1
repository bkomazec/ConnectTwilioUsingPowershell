using module .\CredentialManager.psm1
using module .\Credentials.psm1
using module .\SMSApi.psm1


class Twilio {

    [CredentialManager]$credentialManager = $null
    [SMSApi]$smsApi = $null
    
    Twilio(){
        $this.credentialManager = [CredentialManager]::new()        
    }

    [void]InitializeApi(){
        if($this.credentialManager.credentials_set){
            $this.smsApi = [SMSApi]::new($this.credentialManager.credentials)
        }
        else{
            Write-Host "Error getting credentials"
        }
    }

    # [void] ChooseOption(){
    #     while (-not $this.credentialManager.credentials_set) {
    #         $this.credentialManager.CheckCredentials()
    #     }
    
    #     [int]$option = $this.credentialManager.GetOption("Choose option: 1. Send message, 2. Get all messages, 3. Delete message, 4. Set new credintials, 5. Exit",1,5) 
       
    #     if ($option -eq 1) {
    #         $sendingSuccessful = $false
    #         while (-not $sendingSuccessful) {
    #             try {

    #                 [string]$body = ""
    #                 [bool]$textIsValid = $false

    #                 while (-not $textIsValid) {
    #                     try {
    #                         $body = Read-Host "Enter the message text"
    #                         $textIsValid = $true
    #                     }
    #                     catch {
    #                         $textIsValid = $false
    #                     }
    #                 }

    #                 $this.credentialManager.SendMessage($body);
    #                 $sendingSuccessful = $true
    #                 Write-Host "Message successfully sent!" -ForegroundColor Green
    #             }
    #             catch {
    #                 Write-Host "Error sending sms. Please check you credentials." -ForegroundColor Red
    #                 $this.credentialManager.ClearCredentials()
    #                 $this.credentialManager.CheckCredentials()
    #             }
    #         }
    #     }
        
    #     elseif ($option -eq 2) {                
    #         $messages = $this.credentialManager.GetMessages() 
    #         if ($null -eq $messages) {
    #             Write-Host "Error getting messages"
    #         }
    #         else{
    #             Write-Host $messages 
    #         }
            
    #     }

    #     elseif ($option -eq 3){
    #         $messageId = Read-Host "Enter the message iD (SM**********************)"
    #         if ($this.credentialManager.DeleteMessage($messageId)) {
    #             Write-Host "Message successfully deleted!" -ForegroundColor Green
    #         }
    #         else{
    #             Write-Host "Error deleting message" -ForegroundColor Red
    #         }            
    #     }

    #     elseif ($option -eq 4){
    #         $this.credentialManager.ClearCredentials();
    #     }

    #     elseif ($option -eq 5){
    #         Clear-History
    #         Remove-Variable * -ErrorAction SilentlyContinue
    #         Exit
    #     }

    #     $this.ChooseOption()
    # }
}
















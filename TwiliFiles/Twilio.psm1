using module .\CredentialProcessor.psm1


class Twilio {

    hidden[CredentialProcessor]$credentialProcessor = $null
    
    Twilio(){
        $this.credentialProcessor = [CredentialProcessor]::new()
    }

    [void] ChooseOption(){
        while (-not $this.credentialProcessor.credentials_set) {
            $this.credentialProcessor.CheckCredentials()
        }
    
        [int]$option = $this.credentialProcessor.GetOption("Choose option: 1. Send message, 2. Get all messages, 3. Delete message, 4. Set new credintials, 5. Exit",1,5) 
       
        if ($option -eq 1) {
            $sendingSuccessful = $false
            while (-not $sendingSuccessful) {
                try {

                    [string]$body = ""
                    [bool]$textIsValid = $false

                    while (-not $textIsValid) {
                        try {
                            $body = Read-Host "Enter the message text"
                            $textIsValid = $true
                        }
                        catch {
                            $textIsValid = $false
                        }
                    }

                    $this.credentialProcessor.SendMessage($body);
                    $sendingSuccessful = $true
                    Write-Host "Message successfully sent!" -ForegroundColor Green
                }
                catch {
                    # if ($this.credentialProcessor.withdraw) {
                    #     $this.credentialProcessor.withdraw = $false
                    #     $this.ChooseOption()
                    # }

                    Write-Host "Error sending sms. Please check you credentials." -ForegroundColor Red
                    $this.credentialProcessor.ClearCredentials()
                    $this.credentialProcessor.CheckCredentials()
                }
            }
        }
        
        elseif ($option -eq 2) {                
            $messages = $this.credentialProcessor.GetMessages() 
            if ($null -eq $messages) {
                Write-Host "Error getting messages"
            }
            else{
                Write-Host $messages 
            }
            
        }

        elseif ($option -eq 3){
            $messageId = Read-Host "Enter the message iD (SM**********************)"
            if ($this.credentialProcessor.DeleteMessage($messageId)) {
                Write-Host "Message successfully deleted!" -ForegroundColor Green
            }
            else{
                Write-Host "Error deleting message" -ForegroundColor Red
            }            
        }

        elseif ($option -eq 4){
            $this.credentialProcessor.ClearCredentials();
        }

        elseif ($option -eq 5){
            Clear-History
            Remove-Variable * -ErrorAction SilentlyContinue
            Exit
        }

        $this.ChooseOption()
    }
}
















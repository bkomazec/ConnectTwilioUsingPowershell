using module .\CredentialManager.psm1


class Twilio {
    
    Twilio(){
        $global:credentialManager = [CredentialManager]::new()
    }

    [void] ChooseOption(){

        while (-not $global:credentialManager.credentials_set) {
            $global:credentialManager.CheckCredentials()
        }
    
        [int]$option = $global:credentialManager.GetOption("Choose option: 1. Send message, 2. Get all messages, 3. Delete message, 4. Set new credintials, 5. Exit",1,5) 
       
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

                    $global:credentialManager.SendMessage($body);
                    $sendingSuccessful = $true
                    Write-Host "Message successfully sent!" -ForegroundColor Green
                }
                catch {
                    if ($global:credentialManager.withdraw) {
                        $global:credentialManager.withdraw = $false
                        $this.ChooseOption()
                    }

                    Write-Host "Error sending sms. Please check you credentials." -ForegroundColor Red
                    $global:credentialManager.ClearCredentials()
                    $global:credentialManager.CheckCredentials
                }
            }
        }
        
        elseif ($option -eq 2) {                
            $messages = $global:credentialManager.GetMessages() 
            Write-Host $messages 
            # GetMessages
        }

        elseif ($option -eq 3){
            $messageId = Read-Host "Enter the message iD (SM**********************)"
            if ($global:credentialManager.DeleteMessage($messageId)) {
                Write-Host "Message successfully deleted!" -ForegroundColor Green
            }
            else{
                Write-Host "Error deleting message" -ForegroundColor Red
            }            
        }

        elseif ($option -eq 4){
            $global:credentialManager.ClearCredentials();
        }

        elseif ($option -eq 5){
            Clear-History
            Remove-Variable * -ErrorAction SilentlyContinue
            Exit
        }

        $this.ChooseOption()
    }
}
















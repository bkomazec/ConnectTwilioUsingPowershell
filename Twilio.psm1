using module .\CredentialManager.psm1


class Twilio {
    
    [CredentialManager]$credentialManager = $null
    [bool]$isAlive = $true;

    Twilio(){
        $global:credentialManager = [CredentialManager]::new()
    }

    [void] ChooseOption(){

        while (-not $global:credentialManager.credentials_set) {
            $global:credentialManager.CheckCredentials()
        }
    
        [int]$option = $global:credentialManager.GetOption("Choose option: 1. Send message, 2. Edit message, 3. Get all messages, 4. Delete message, 5. Exit",1,5) 
    
        if($global:credentialManager.CheckCredentials){
    
            if ($option -eq 1) {
                $sendingSuccessful = $false
                while (-not $sendingSuccessful) {
                    try {
                        $global:credentialManager.SendMessage();
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
                Write-Host "Edit message option is not yet implemented" -ForegroundColor Yellow
            }
    
            elseif ($option -eq 3) {                
                $messages = $global:credentialManager.GetMessages() 
                Write-Host $messages 
                # GetMessages
            }
    
            elseif ($option -eq 4){
                $messageId = Read-Host "Enter the message iD (SM**********************)"
                if ($global:credentialManager.DeleteMessage($messageId)) {
                    Write-Host "Message successfully deleted"
                }
                else{
                    Write-Host "Error deleting message"
                }            
            }
    
            elseif ($option -eq 5){
                Clear-History
                Remove-Variable * -ErrorAction SilentlyContinue
                Exit
            }
    
            $this.ChooseOption()
        }
    }

    
    

}
















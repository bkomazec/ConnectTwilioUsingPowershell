using module .\CredentialManager.psm1

class CredentialProcessor {

    hidden[CredentialManager]$credentialManager = $null
    [bool]$credentials_set = $false

    CredentialProcessor(){
        $this.credentialManager = [CredentialManager]::new()
    }

    [bool] CheckCredentials() {

        if(-not $this.credentials_set)
        {
    
            [int]$option = $this.GetOption("Credentials are needed. Choose option: 1. Import from json file, 2. Enter credentials, 3. Cancel [1/2/3] `n 
            If you choose to import from a json file, the file needs to be in the following format: `n
            'accountSID': 'ACxxxxxxxxxxxxxxxxxxxxxxxxxxx' `n
            'authToken': 'xxxxxxxxxxxxxxxxxxxxxxxxxxx' `n
            'twilioNumber': '+xxxxxxxxxxxx' `n
            'userNumber': '+xxxxxxxxxxxx' `n", 1, 3)
    
            if ($option -eq 1) {
                $fileName = ""
                $pathCorrect = $false
                while (-not $pathCorrect) {
                    $fileName = Read-Host "Enter the path to the file (C:\***\***\FileName.json)"
                    if (-not (Test-Path -Path $fileName)) {
                        Write-Host "Path is not correct" -ForegroundColor Red
                    }
                    else {
                        $pathCorrect = $true
                    }
                }

                if(-not $this.credentialManager.InputCredentials($fileName)){
                    $this.credentials_set = $false
                    return $false
                }          
            }
    
            elseif ($option -eq 2) {
                $this.credentialManager.ReadCredentials()             
            }  
    
            else {
                $this.credentials_set = $false
                return $false
            }    
        }    
    
        $this.credentials_set = $true
        return $true
    }

    [void] ClearCredentials()  {  
        $this.credentialManager.ClearCredentials()  
        $this.credentials_set = $false
    }

    [PSCustomObject] GetMessages() {

        $sid=$this.credentialManager.account_sid
        $url = "https://api.twilio.com/2010-04-01/Accounts/$sid/Messages.json"
    
        try{
            $p = $this.credentialManager.auth_token | ConvertTo-SecureString -asPlainText    -Force
            $credential = New-Object System.Management.Automation.PSCredential($this.credentialManager.account_sid, $p)
            return Invoke-WebRequest $url -Method Get -Credential $credential -UseBasicParsing |  ConvertFrom-Json
        }

        catch{
            return $null
        }
    }

    #Sending data to Twilio and sending SMS
    [void] SendMessage ( $body) {

        # Pull in Twilio account info, previously set as environment variables
        $sid = $this.credentialManager.account_sid
        $token = $this.credentialManager.auth_token

        # Twilio API endpoint and POST params
        $url = "https://api.twilio.com/2010-04-01/Accounts/$sid/Messages.json"

        $params = @{ To = $this.credentialManager.user_number; From = $this.credentialManager.twilio_number; Body = $body }

        # Create a credential object for HTTP basic auth
        $p = $token | ConvertTo-SecureString -asPlainText    -Force
        $credential = New-Object System.Management.Automation.PSCredential($sid, $p)

        # Make API request, selecting JSON properties from response

        Invoke-WebRequest $url -Method Post -Credential $credential -Body $params -UseBasicParsing |
        ConvertFrom-Json | Select sid, body                

    }

    [bool] DeleteMessage($messageId){
        try {
            $sid=$this.credentialManager.account_sid
            $token = $this.credentialManager.auth_token
            $url = "https://api.twilio.com/2010-04-01/Accounts/$sid/Messages/$messageId.json"

            $p = $token | ConvertTo-SecureString -asPlainText    -Force
            $credential = New-Object System.Management.Automation.PSCredential($sid, $p)
            try {
                Invoke-WebRequest $url -Method Delete -Credential $credential -UseBasicParsing
                return true
            }
            catch {
                return false
            }
        }
        catch {
            return $false
        }
        return $true
    }

    [int] GetOption ($text,$min,$max) {
        [int]$option = 0
    
        while ($option -eq 0) {
            [int]$inputNumber = 0;
            $inputValid = [int]::TryParse((Read-Host $text), [ref]$inputNumber)
            if (-not $inputValid) {
                Write-Host "Please enter a number" -ForegroundColor Red
            }
    
            elseif ($inputNumber -lt $min -or $inputNumber -gt $max ){
                Write-Host "The answer is not correct. Choose one of the offered answers." -ForegroundColor Red
            }
    
            else{
                $option = $inputNumber
            }
        }
    
        return $option
    }
}


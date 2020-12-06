
class CredentialManager {

    hidden[string]$account_sid = ""
    hidden[string]$auth_token = ""
    hidden[string]$twilio_number = ""
    hidden[string]$user_number = ""
    [bool]$withdraw = $true
    [bool]$credentials_set = $false

    CredentialManager(){}

    [CredentialManager] ReturnInstance(){
        return [CredentialManager]::new()
    }

    [void] ClearCredentials()  {    
        $this.account_sid = ""
        $this.auth_token = ""
        $this.twilio_number = ""
        $this.user_number = ""
    }

    [bool] CheckCredentials() {

        if([string]::IsNullOrEmpty($this.account_sid) -or [string]::IsNullOrEmpty($this.auth_token) -or [string]::IsNullOrEmpty($this.twilio_number) -or [string]::IsNullOrEmpty($this.user_number))
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
    
                try {
                    $jsonFile = Get-Content $fileName | Out-String | ConvertFrom-Json
                    $jsonFile
                    $this.account_sid = $jsonFile.accountSID
                    $this.auth_token = $jsonFile.authToken
                    $this.twilio_number = $jsonFile.twilioNumber
                    $this.user_number = $jsonFile.userNumber
                }
                catch {
                    Write-Host "Error loading file" -ForegroundColor Red
                    $this.credentials_set = $false
                    return $false
                }                
            }
    
            elseif ($option -eq 2) {
                $this.account_sid = Read-Host "What is your account sid (ACxxxxxxxxxxxxxxxxxxxxxxxxxxx)?" #AsSecureString;
                $this.auth_token = Read-Host "What is your authorization token?" #AsSecureString;
                $this.twilio_number = $this.CheckPhoneNumber("What is your twilio number? (+xxxxxxxxxxxx)")
                $this.user_number = $this.CheckPhoneNumber("To which number you send sms? (+xxxxxxxxxxxx)")              
            }  
    
            else {
                # $global:withdraw = $true
                $this.withdraw = $true
                $this.credentials_set = $false
                return $false
            }    
        }    
    
        $this.credentials_set = $true
        return $true
    }

    [PSCustomObject] GetMessages() {
        $sid=$this.account_sid
        $url = "https://api.twilio.com/2010-04-01/Accounts/$sid/Messages.json"
    
        $p = $this.auth_token | ConvertTo-SecureString -asPlainText    -Force
        $credential = New-Object System.Management.Automation.PSCredential($this.account_sid, $p)
        return Invoke-WebRequest $url -Method Get -Credential $credential -UseBasicParsing |  ConvertFrom-Json
    }

    #Sending data to Twilio and sending SMS
    [void] SendMessage () {

        # Pull in Twilio account info, previously set as environment variables
        $sid=$this.account_sid
        $token = $this.auth_token
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

        # Twilio API endpoint and POST params
        $url = "https://api.twilio.com/2010-04-01/Accounts/$sid/Messages.json"

        $params = @{ To = $this.user_number; From = $this.twilio_number; Body = $body }

        # Create a credential object for HTTP basic auth
        $p = $token | ConvertTo-SecureString -asPlainText    -Force
        $credential = New-Object System.Management.Automation.PSCredential($sid, $p)

        # Make API request, selecting JSON properties from response
        Invoke-WebRequest $url -Method Post -Credential $credential -Body $params -UseBasicParsing |
        ConvertFrom-Json | Select sid, body
    }

    [bool] DeleteMessage($messageId){
        try {
            $sid=$this.account_sid
            $token = $this.auth_token
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

    [string] CheckPhoneNumber([string]$question) {
        
        $phoneRegex = "^\+[0-9]"
        [bool]$NumberValid = $false
        [string]$number = ""

        while (-not $NumberValid) {
            # [ValidateLength(9,15)]
            $number = Read-Host $question

            if(-not ($number -match $phoneRegex)){
                Write-Host "Invalid number" -ForegroundColor Red
            }
            elseif ($number.Length -lt 9 -or $number.Length -gt 15 ) {
                Write-Host "Enter between 9 and 15 characters" -ForegroundColor Red
            }
            else{
                $NumberValid = $true
            }
        }

        return $number
    }
    
}


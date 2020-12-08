class CredentialManager {

    [string]$account_sid = ""
    [string]$auth_token = ""
    [string]$twilio_number = ""
    [string]$user_number = ""

    CredentialManager(){}

    [void] ClearCredentials()  {    
        $this.account_sid = ""
        $this.auth_token = ""
        $this.twilio_number = ""
        $this.user_number = ""
    }

    [bool] InputCredentials($fileName){
        

        try {
            $jsonFile = Get-Content $fileName | Out-String | ConvertFrom-Json
            $jsonFile
            $this.account_sid = $jsonFile.accountSID
            $this.auth_token = $jsonFile.authToken
            $this.twilio_number = $jsonFile.twilioNumber
            $this.user_number = $jsonFile.userNumber
            return $true
        }
        catch {
            Write-Host "Error loading file" -ForegroundColor Red
            return $false
        }     
    }

    [void] ReadCredentials(){
        $this.account_sid = Read-Host "What is your account sid (ACxxxxxxxxxxxxxxxxxxxxxxxxxxx)?" #AsSecureString;
        $this.auth_token = Read-Host "What is your authorization token?" #AsSecureString;
        $this.twilio_number = $this.CheckPhoneNumber("What is your twilio number? (+xxxxxxxxxxxx)")
        $this.user_number = $this.CheckPhoneNumber("To which number you send sms? (+xxxxxxxxxxxx)") 
    }

    hidden[string] CheckPhoneNumber([string]$question) {
        
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


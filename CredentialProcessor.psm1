using module .\Credentials.psm1

class CredentialProcessor {

    [Credentials]$credentials = $null

    CredentialProcessor(){
        $this.credentials = [Credentials]::new()
    }

    [void] ClearCredentials()  {    
        $this.credentials.account_sid = ""
        $this.credentials.auth_token = ""
        $this.credentials.twilio_number = ""
        $this.credentials.user_number = ""
    }

    [Credentials]InitFromFile($fileName){
        try {
            $jsonFile = Get-Content $fileName | Out-String | ConvertFrom-Json
            $jsonFile
            $this.credentials.account_sid = $jsonFile.accountSID
            $this.credentials.auth_token = $jsonFile.authToken
            $this.credentials.twilio_number = $jsonFile.twilioNumber
            $this.credentials.user_number = $jsonFile.userNumber
            return $this.credentials
        }
        catch {
            Write-Host "Error loading file" -ForegroundColor Red
            return $null
        }     
    }

    [Credentials]InitFromUserInput(){
        $this.credentials.account_sid = Read-Host "What is your account sid (ACxxxxxxxxxxxxxxxxxxxxxxxxxxx)?" #AsSecureString;
        $this.credentials.auth_token = Read-Host "What is your authorization token?" #AsSecureString;
        $this.credentials.twilio_number = $this.CheckPhoneNumber("What is your twilio number? (+xxxxxxxxxxxx)")
        $this.credentials.user_number = $this.CheckPhoneNumber("To which number you send sms? (+xxxxxxxxxxxx)")
        return $this.credentials
    }
    hidden[string] CheckPhoneNumber([string]$question) {
        
        $phoneRegex = "^\+[0-9]"
        [bool]$NumberValid = $false
        [string]$number = ""

        while (-not $NumberValid) {
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


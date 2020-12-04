class CredentialManager {

    hidden[string]$account_sid = ""
    hidden[string]$auth_token = ""
    hidden[string]$twilio_number = ""
    hidden[string]$user_number = ""
    [bool]$withdraw = $true

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
    
            [int]$option = GetOption "Credentials are needed. Choose option: 1. Import from json file, 2. Enter credentials, 3. Cancel [1/2/3] `n 
            If you choose to import from a json file, the file needs to be in the following format: `n
            'accountSID': 'ACxxxxxxxxxxxxxxxxxxxxxxxxxxx' `n
            'authToken': 'xxxxxxxxxxxxxxxxxxxxxxxxxxx' `n
            'twilioNumber': '+xxxxxxxxxxxx' `n
            'userNumber': '+xxxxxxxxxxxx' `n" 1 3
    
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
                    return $false
                }
                
            }
    
            elseif ($option -eq 2) {
                $this.account_sid = Read-Host "What is your account sid (ACxxxxxxxxxxxxxxxxxxxxxxxxxxx)?" #AsSecureString;
                $this.auth_token = Read-Host "What is your authorization token?" #AsSecureString;
                $this.twilio_number = CheckPhoneNumber "What is your twilio number? (+xxxxxxxxxxxx)"
                $this.user_number = CheckPhoneNumber "To which number you send sms? (+xxxxxxxxxxxx)"
            }  
    
            else {
                # $global:withdraw = $true
                $this.withdraw = $true
                return $false
            }
    
            # if (Test-Path 'env:TWILIO_ACCOUNT_SID') {
            #     $env:TWILIO_ACCOUNT_SID = $account_sid
            # }
            # else{
            #     Write-Progress -Activity "Saving parameters" -PercentComplete 0 -Status "Saving account sid"
            #     [Environment]::SetEnvironmentVariable("TWILIO_ACCOUNT_SID", $account_sid, "User")    
            # }
    
            # if (Test-Path 'env:TWILIO_AUTH_TOKEN') {
            #     $env:TWILIO_AUTH_TOKEN = $auth_token
            # }
            # else{
            #     Write-Progress -Activity "Saving parameters" -PercentComplete 25 -Status "Saving auth token"
            #     [Environment]::SetEnvironmentVariable("TWILIO_AUTH_TOKEN", $auth_token, "User")    
            # }
    
            # if (Test-Path 'env:TWILIO_NUMBER') {
            #     $env:TWILIO_NUMBER = $twilio_number
            # }
            # else{
            #     Write-Progress -Activity "Saving parameters" -PercentComplete 50 -Status "Saving Twilio number"
            #     [Environment]::SetEnvironmentVariable("TWILIO_NUMBER", $twilio_number, "User")    
            # }
    
            # if (Test-Path 'env:USER_NUMBER') {
            #     $env:USER_NUMBER = $user_number
            # }
            # else{
            #     Write-Progress -Activity "Saving parameters" -PercentComplete 75 "Saving Twilio number"
            #     [Environment]::SetEnvironmentVariable("USER_NUMBER", $user_number, "User")    
            # } 
             
            # Write-Progress -Activity "Saving parameters" -PercentComplete 100
        }    
    
        return $true
    }
    
}


# function DeleteCredentials() {
    
#     # if (Test-Path 'env:TWILIO_ACCOUNT_SID') {
#     #     [Environment]::SetEnvironmentVariable("TWILIO_ACCOUNT_SID", "", "User")
#     # }

#     # if (Test-Path 'env:TWILIO_AUTH_TOKEN') {
#     #     [Environment]::SetEnvironmentVariable("TWILIO_AUTH_TOKEN", "", "User")
#     # }

#     # if (Test-Path 'env:TWILIO_NUMBER') {
#     #     [Environment]::SetEnvironmentVariable("TWILIO_NUMBER", "", "User")
#     # }

#     # if (Test-Path 'env:USER_NUMBER') {
#     #     [Environment]::SetEnvironmentVariable("USER_NUMBER", "", "User")
#     # }

#     if (Test-Path 'env:TWILIO_ACCOUNT_SID') {
#         Remove-Item Env:\TWILIO_ACCOUNT_SID
#     }

#     if (Test-Path 'env:TWILIO_AUTH_TOKEN') {
#         Remove-Item Env:\TWILIO_AUTH_TOKEN
#     }

#     if (Test-Path 'env:TWILIO_NUMBER') {
#         Remove-Item Env:\TWILIO_NUMBER
#     }

#     if (Test-Path 'env:USER_NUMBER') {
#         Remove-Item Env:\USER_NUMBER
#     }
# }

# function CreateEnvironment() {

    #     if (-not ( Test-Path 'env:TWILIO_ACCOUNT_SID')) {
    #         [Environment]::SetEnvironmentVariable("TWILIO_ACCOUNT_SID", "", "User")
    #     }

    #     if (Test-Path 'env:TWILIO_AUTH_TOKEN') {
    #         [Environment]::SetEnvironmentVariable("TWILIO_AUTH_TOKEN", "", "User")
    #     }

    #     if (Test-Path 'env:TWILIO_NUMBER') {
    #         [Environment]::SetEnvironmentVariable("TWILIO_NUMBER", "", "User")
    #     }

    #     if (Test-Path 'env:USER_NUMBER') {
    #         [Environment]::SetEnvironmentVariable("USER_NUMBER", "", "User")
    #     }
    # }




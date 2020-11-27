





#region Public functions

#Choose one opti0n
function ChooseOption{

    [int]$option = GetOption "Choose option: 1. Send message, 2. Edit message, 3. Read messages [1/2/3]" 1 3

    if(CheckCredentials){
        if ($option -eq 1) {
            $sendingSuccessful = $false
            while (-not $sendingSuccessful) {            
                try {
                    SendMessage
                    $sendingSuccessful = $true
                }
                catch {
                    Write-Host "Error sending sms. Please check you credentials." -ForegroundColor Red
                    ClearCredentials
                    CheckCredentials
                }
            }       
        }
    
        elseif ($option -eq 2) {
            Write-Host "Edit message option is not yet implemented" -ForegroundColor Yellow
        }
    
        elseif ($option -eq 3) {
            ReadMessages
        }
    
        ChooseOption  
    }
}

#Sending data to Twilio and sending SMS
function SendMessage () {    

    # Pull in Twilio account info, previously set as environment variables
    $sid = $env:TWILIO_ACCOUNT_SID
    $token = $env:TWILIO_AUTH_TOKEN
    $twilioNumber = $env:TWILIO_NUMBER
    $userNumber = $env:USER_NUMBER
    [string]$body = ""
    $textIsValid = false

    while (-not $textIsValid) {
        try {
            [ValidateLength(1,10)][String]$text = Read-Host "Enter the message text"
            $textIsValid = $true
            $body = $text
        }
        catch {
            $textIsValid = $false
        }        
    }       

    # Twilio API endpoint and POST params
    $url = "https://api.twilio.com/2010-04-01/Accounts/$sid/Messages.json"
    
    # $params = @{ To = $userNumber; From = $twilioNumber; Body = "Hello from PowerShell" }
    $params = @{ To = $userNumber; From = $twilioNumber; Body = "Hello from PowerShell" }

    # Create a credential object for HTTP basic auth
    $p = $token | ConvertTo-SecureString -asPlainText    -Force

    $credential = New-Object System.Management.Automation.PSCredential($sid, $p)

    # Make API request, selecting JSON properties from response
    Invoke-WebRequest $url -Method Post -Credential $credential -Body $params -UseBasicParsing |
    ConvertFrom-Json | Select sid, body
}

function ReadMessages {
    $sid = $env:TWILIO_ACCOUNT_SID
    $token = $env:TWILIO_AUTH_TOKEN
    $url = "https://api.twilio.com/2010-04-01/Accounts/$sid/Messages.json"    
    
    $p = $token | ConvertTo-SecureString -asPlainText    -Force
    $credential = New-Object System.Management.Automation.PSCredential($sid, $p)
    $messages = Invoke-WebRequest $url -Method Get -Credential $credential -UseBasicParsing |  ConvertFrom-Json 
    $messages
}

#endregion Public functions

#region Private functions

function GetOption ($text,$min,$max) {
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

function CheckPhoneNumber {
    param(
        [Parameter(Mandatory=$true)]
        [String]$question
    )

    $phoneRegex = "^\+[0-9]"
    [bool]$NumberValid = $false

    while (-not $NumberValid) {
        # [ValidateLength(9,15)]
        [String]$number = Read-Host $question

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

function CheckCredentials {

    if(-not(Test-Path 'env:TWILIO_ACCOUNT_SID') -or ($env:TWILIO_ACCOUNT_SID -eq "") `
    -or -not(Test-Path 'env:TWILIO_AUTH_TOKEN') -or ($env:TWILIO_AUTH_TOKEN -eq "") `
    -or -not(Test-Path 'env:TWILIO_NUMBER') -or ($env:TWILIO_NUMBER -eq "") `
    -or -not(Test-Path 'env:USER_NUMBER') -or ($env:USER_NUMBER -eq ""))
    {

        [int]$option = GetOption "Credentials are needed. Choose option: 1. Import from json file, 2. Enter credentials, 3. Cancel [1/2/3] `n 
        If you choose to import from a json file, the file needs to be in the following format: `n
        'accountSID': 'ACxxxxxxxxxxxxxxxxxxxxxxxxxxx' `n
        'authToken': 'xxxxxxxxxxxxxxxxxxxxxxxxxxx' `n
        'twilioNumber': '+xxxxxxxxxxxx' `n
        'userNumber': '+xxxxxxxxxxxx'" 1 3

        [String]$account_sid = ""
        [String]$auth_token = ""
        [String]$twilio_number = ""
        [String]$user_number = ""

        if ($option -eq 1) {

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
                $account_sid = $jsonFile.accountSID
                $auth_token = $jsonFile.authToken
                $twilio_number = $jsonFile.twilioNumber
                $user_number = $jsonFile.userNumber
            }
            catch {
                Write-Host "Error loading file" -ForegroundColor Red
                return $false
            }
            
        }

        elseif ($option -eq 2) {
            $account_sid = Read-Host "What is your account sid (ACxxxxxxxxxxxxxxxxxxxxxxxxxxx)?" #AsSecureString;
            $auth_token = Read-Host "What is your authorization token?" #AsSecureString;
            $twilio_number = CheckPhoneNumber "What is your twilio number? (+xxxxxxxxxxxx)"
            $user_number = CheckPhoneNumber "To which number you send sms? (+xxxxxxxxxxxx)"
        }  

        else {
            return $false
        }

        if (Test-Path 'env:TWILIO_ACCOUNT_SID') {
            $env:TWILIO_ACCOUNT_SID = $account_sid
        }
        else{
            Write-Progress -Activity "Saving parameters" -PercentComplete 0 -Status "Saving account sid"
            [Environment]::SetEnvironmentVariable("TWILIO_ACCOUNT_SID", $account_sid, "User")    
        }

        if (Test-Path 'env:TWILIO_AUTH_TOKEN') {
            $env:TWILIO_AUTH_TOKEN = $auth_token
        }
        else{
            Write-Progress -Activity "Saving parameters" -PercentComplete 25 -Status "Saving auth token"
            [Environment]::SetEnvironmentVariable("TWILIO_AUTH_TOKEN", $auth_token, "User")    
        }

        if (Test-Path 'env:TWILIO_NUMBER') {
            $env:TWILIO_NUMBER = $twilio_number
        }
        else{
            Write-Progress -Activity "Saving parameters" -PercentComplete 50 -Status "Saving Twilio number"
            [Environment]::SetEnvironmentVariable("TWILIO_NUMBER", $twilio_number, "User")    
        }

        if (Test-Path 'env:USER_NUMBER') {
            $env:USER_NUMBER = $user_number
        }
        else{
            Write-Progress -Activity "Saving parameters" -PercentComplete 75 "Saving Twilio number"
            [Environment]::SetEnvironmentVariable("USER_NUMBER", $user_number, "User")    
        } 
         
        Write-Progress -Activity "Saving parameters" -PercentComplete 100
    }    

    return $true
}

function DeleteCredentials() {
    
    # if (Test-Path 'env:TWILIO_ACCOUNT_SID') {
    #     [Environment]::SetEnvironmentVariable("TWILIO_ACCOUNT_SID", "", "User")
    # }

    # if (Test-Path 'env:TWILIO_AUTH_TOKEN') {
    #     [Environment]::SetEnvironmentVariable("TWILIO_AUTH_TOKEN", "", "User")
    # }

    # if (Test-Path 'env:TWILIO_NUMBER') {
    #     [Environment]::SetEnvironmentVariable("TWILIO_NUMBER", "", "User")
    # }

    # if (Test-Path 'env:USER_NUMBER') {
    #     [Environment]::SetEnvironmentVariable("USER_NUMBER", "", "User")
    # }

    if (Test-Path 'env:TWILIO_ACCOUNT_SID') {
        Remove-Item Env:\TWILIO_ACCOUNT_SID
    }

    if (Test-Path 'env:TWILIO_AUTH_TOKEN') {
        Remove-Item Env:\TWILIO_AUTH_TOKEN
    }

    if (Test-Path 'env:TWILIO_NUMBER') {
        Remove-Item Env:\TWILIO_NUMBER
    }

    if (Test-Path 'env:USER_NUMBER') {
        Remove-Item Env:\USER_NUMBER
    }
}

function ClearCredentials  {    
    $env:TWILIO_ACCOUNT_SID = ""
    $env:TWILIO_AUTH_TOKEN = ""
    $env:TWILIO_NUMBER = ""
    $env:USER_NUMBER = ""
}

#endregion Private functions






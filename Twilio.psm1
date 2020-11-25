#Sending data to Twilio and sending SMS
function SendMessage () {    

    # Pull in Twilio account info, previously set as environment variables
    $sid = $env:TWILIO_ACCOUNT_SID
    $token = $env:TWILIO_AUTH_TOKEN
    $twilioNumber = $env:TWILIO_NUMBER
    $userNumber = $env:USER_NUMBER

    Write-Host "Test 1"

    # Twilio API endpoint and POST params
    $url = "https://api.twilio.com/2010-04-01/Accounts/$sid/Messages.json"
    # $params = @{ To = $userNumber; From = $twilioNumber; Body = "Hello from PowerShell" }
    $params = @{ To = $userNumber; From = $twilioNumber; Body = "Hello from PowerShell" }

    Write-Host "Test 2"

    # Create a credential object for HTTP basic auth
    $p = $token | ConvertTo-SecureString -asPlainText    -Force

    Write-Host "Test 3"
    $credential = New-Object System.Management.Automation.PSCredential($sid, $p)

    Write-Host "Test 4"

    # Make API request, selecting JSON properties from response
    Invoke-WebRequest $url -Method Post -Credential $credential -Body $params -UseBasicParsing |
    ConvertFrom-Json | Select sid, body

    Write-Host "Test 5"
}

#Choose one optin
function ChooseOption{

    ClearEnvironment

    [int]$option = 0

    while ($option -eq 0) {
        [int]$inputNumber = 0;
        $inputValid = [int]::TryParse((Read-Host "Choose option: 1. Send message, 2. Edit message [1/2]"), [ref]$inputNumber)
        if (-not $inputValid) {
            Write-Host "Please enter a number" -ForegroundColor Red
        }

        elseif ($inputNumber -lt 1 -or $inputNumber -gt 2 ){
            Write-Host "The answer is not correct. Choose one of the offered answers." -ForegroundColor Red
        }

        else{
            $option = $inputNumber
        }
    }

    if ($option -eq 1) {
        
        while (-not $sendingSuccessful) {

            GetParameters($option)
            $sendingSuccessful = $false

            try {
                SendMessage
                $sendingSuccessful = $true
            }
            catch {
                Write-Host "Error sending sms. Please check you credentials." -ForegroundColor Red
            }
        }       
    }

    elseif ($option -eq 2) {
        Write-Host "Edit message option is not yet implemented" -ForegroundColor Yellow
    }
        
}

#Get inputs from user
function GetParameters () {
    [String]$account_sid = Read-Host "What is your account sid (ACxxxxxxxxxxxxxxxxxxxxxxxxxxx)?" #AsSecureString;
    [String]$auth_token = Read-Host "What is your authorization token?" #AsSecureString;
    [String]$twilio_number = CheckPhoneNumber "What is your twilio number? (+xxxxxxxxxxxx)"
    [String]$user_number = CheckPhoneNumber "To which number you send sms? (+xxxxxxxxxxxx)"

    Write-Progress -Activity "Saving parameters" -PercentComplete 0 -Status "Saving account sid"
    [Environment]::SetEnvironmentVariable("TWILIO_ACCOUNT_SID", $account_sid, "User")
    Write-Progress -Activity "Saving parameters" -PercentComplete 25 -Status "Saving auth token"
    [Environment]::SetEnvironmentVariable("TWILIO_AUTH_TOKEN", $auth_token, "User")
    Write-Progress -Activity "Saving parameters" -PercentComplete 50 -Status "Saving Twilio number"
    [Environment]::SetEnvironmentVariable("TWILIO_NUMBER", $twilio_number, "User")
    Write-Progress -Activity "Saving parameters" -PercentComplete 75 "Saving Twilio number"
    [Environment]::SetEnvironmentVariable("USER_NUMBER", $user_number, "User")
    Write-Progress -Activity "Saving parameters" -PercentComplete 100 
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

function ClearEnvironment() {
    
    if (Test-Path 'env:TWILIO_ACCOUNT_SID') {
        [Environment]::SetEnvironmentVariable("TWILIO_ACCOUNT_SID", "", "User")
    }

    if (Test-Path 'env:TWILIO_AUTH_TOKEN') {
        [Environment]::SetEnvironmentVariable("TWILIO_AUTH_TOKEN", "", "User")
    }

    if (Test-Path 'env:TWILIO_NUMBER') {
        [Environment]::SetEnvironmentVariable("TWILIO_NUMBER", "", "User")
    }

    if (Test-Path 'env:USER_NUMBER') {
        [Environment]::SetEnvironmentVariable("USER_NUMBER", "", "User")
    }

    # if (Test-Path 'env:TWILIO_ACCOUNT_SID') {
    #     Remove-Item Env:\TWILIO_ACCOUNT_SID
    # }

    # if (Test-Path 'env:TWILIO_AUTH_TOKEN') {
    #     Remove-Item Env:\TWILIO_AUTH_TOKEN
    # }

    # if (Test-Path 'env:TWILIO_NUMBER') {
    #     Remove-Item Env:\TWILIO_NUMBER
    # }

    # if (Test-Path 'env:USER_NUMBER') {
    #     Remove-Item Env:\USER_NUMBER
    # }
}








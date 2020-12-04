

# function SetGlobalVariables {
#     $global:withdraw = $false

# }

# $global:withdraw = $false

#region Public functions

#Choose one opti0n

using module .\CredentialManager.psm1

$credentialManager = $null

function GetCredentialManager ([CredentialManager]$manager) {
    # $this.credentialManager = [CredentialManager]::new();
    $credentialManager = $manager;
}

function ChooseOption{

    if ($null -eq $credentialManager) {
        GetCredentialManager
    }

    [int]$option = GetOption "Choose option: 1. Send message, 2. Edit message, 3. Get all messages, 4. Delete message, 5. Exit" 1 5

    if($this.credentialManager.CheckCredentials){

        if ($option -eq 1) {
            $sendingSuccessful = $false
            while (-not $sendingSuccessful) {
                try {
                    SendMessage
                    $sendingSuccessful = $true
                }
                catch {
                    if ($withdraw) {
                        $withdraw = $false
                        ChooseOption
                    }

                    Write-Host "Error sending sms. Please check you credentials." -ForegroundColor Red
                    ClearCredentials
                    $this.credentialManager.CheckCredentials
                }
            }
        }

        elseif ($option -eq 2) {
            Write-Host "Edit message option is not yet implemented" -ForegroundColor Yellow
        }

        elseif ($option -eq 3) {
            GetMessages
        }

        elseif ($option -eq 4){
            $messageId = Read-Host "Enter the message iD (SM**********************)"

            DeleteMessage "https://api.twilio.com/2010-04-01/Accounts/$env:TWILIO_ACCOUNT_SID/Messages/$messageId.json"
        }

        elseif ($option -eq 5){
            Clear-History
            Remove-Variable * -ErrorAction SilentlyContinue
            Exit
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

function GetMessages {
    $sid = $env:TWILIO_ACCOUNT_SID
    $token = $env:TWILIO_AUTH_TOKEN
    $url = "https://api.twilio.com/2010-04-01/Accounts/$sid/Messages.json"

    $p = $token | ConvertTo-SecureString -asPlainText    -Force
    $credential = New-Object System.Management.Automation.PSCredential($sid, $p)
    $messages = Invoke-WebRequest $url -Method Get -Credential $credential -UseBasicParsing |  ConvertFrom-Json
    $messages
}

function DeleteMessage ($url) {
    $sid = $env:TWILIO_ACCOUNT_SID
    $token = $env:TWILIO_AUTH_TOKEN
    $p = $token | ConvertTo-SecureString -asPlainText    -Force
    $credential = New-Object System.Management.Automation.PSCredential($sid, $p)
    try {
        Invoke-WebRequest $url -Method Delete -Credential $credential -UseBasicParsing
        Write-Host "Message deleted successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "Error deleting message" -ForegroundColor Red
    }


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


#endregion Private functions






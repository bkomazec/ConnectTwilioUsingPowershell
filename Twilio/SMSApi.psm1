using module .\Credentials.psm1

class SMSApi {

    hidden[Credentials]$credentials = $null

    SMSApi([Credentials]$credentials){
        $this.credentials = $credentials
    }
   
    [void]SendMessage(){
        if ($null -eq $this.credentials) {
            Write-Host "Credentials needed!"
            return
        }
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

                $this.SendSMS($body);
                $sendingSuccessful = $true
                Write-Host "Message successfully sent!" -ForegroundColor Green
            }
            catch {
                Write-Host "Error sending sms. Please check you credentials." -ForegroundColor Red
            }
        }
        
    }

    #Sending data to Twilio and sending SMS
    hidden[void] SendSMS ([string] $body) {

        # Pull in Twilio account info, previously set as environment variables
        $sid = $this.credentials.account_sid
        $token = $this.credentials.auth_token

        # Twilio API endpoint and POST params
        $url = "https://api.twilio.com/2010-04-01/Accounts/$sid/Messages.json"

        $params = @{ To = $this.credentials.user_number; From = $this.credentials.twilio_number; Body = $body }

        # Create a credential object for HTTP basic auth
        $p = $token | ConvertTo-SecureString -asPlainText    -Force
        $credential = New-Object System.Management.Automation.PSCredential($sid, $p)

        # Make API request, selecting JSON properties from response

        $message = Invoke-WebRequest $url -Method Post -Credential $credential -Body $params -UseBasicParsing |
        ConvertFrom-Json | Select sid, body
        $message              
    }

    [void] GetMessages() {
        if ($null -eq $this.credentials) {
            Write-Host "Credentials needed!"
            return
        }

        $sid=$this.credentials.account_sid
        $url = "https://api.twilio.com/2010-04-01/Accounts/$sid/Messages.json"
    
        try{
            $p = $this.credentials.auth_token | ConvertTo-SecureString -asPlainText    -Force
            $credential = New-Object System.Management.Automation.PSCredential($this.credentials.account_sid, $p)
            $messages = Invoke-WebRequest $url -Method Get -Credential $credential -UseBasicParsing |  ConvertFrom-Json 
            Write-Host $messages
        }

        catch{
            Write-Host "Error getting messages"
        }
    }

    [void] DeleteMessage([string]$messageId){
        try {
            $sid=$this.credentials.account_sid
            $token = $this.credentials.auth_token
            $url = "https://api.twilio.com/2010-04-01/Accounts/$sid/Messages/$messageId.json"

            $p = $token | ConvertTo-SecureString -asPlainText    -Force
            $credential = New-Object System.Management.Automation.PSCredential($sid, $p)

            try {
                Invoke-WebRequest $url -Method Delete -Credential $credential -UseBasicParsing
                Write-Host "Message successfully deleted!" -ForegroundColor Green
            }
            catch {
                Write-Host "Error deleting message!" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "Error deleting message! Check your credentials" -ForegroundColor Red
        }
    }
}
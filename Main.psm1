using module .\Twilio.psm1

$global:twilioInstance = [Twilio]::new();

Write-Host $global:twilioInstance.isAlive;

$global:twilioInstance.ChooseOption()


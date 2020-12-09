using module .\Twilio.psm1

$twilioInstance = [Twilio]::new();

$twilioInstance.ChooseOption()


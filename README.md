# PowerShell Module - Send sms via Twilio using Powershell

## Introduction
This module should enable sending SMS messages via the Twilio service using Powershell

## Requirements
This module requires:
1. PowerShell last version
    * To install:
    ``` PowerShell
    iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"
    ```
2. The latest Pester module installed on PowerShell Core
    * To install:
    ``` PowerShell
    Install-module Pester -repository PSGallery -force
    ```

## How to use this module

**Steps:**
1. using module .\Twilio.psm1
2. $twilio = [Twilio]::new()
3. $twilio.SetCredentialsFromFile()

After initialisation, you can use next functions:

1. $twilio.SendSMS()
2. $twilio.GetAllMessages()
3. $twilio.DeleteMessage()
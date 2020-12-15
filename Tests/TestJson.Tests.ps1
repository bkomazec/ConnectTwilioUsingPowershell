using module .\CredentialProcessor.psm1
using module .\Credentials.psm1

BeforeAll {
    function CheckJson {

            param (
                [Parameter(Mandatory)]
                [ValidateNotNullOrEmpty()]
                [string]$fileName
            )

        [CredentialProcessor]$credentialProcessor = [CredentialProcessor]::new()
        $credentialProcessor.InitFromFile($fileName)
    }
}

Describe "Test-JSON"{
    It "Valid Json" {
        CheckJson .\Credentials.json | Should -Be OK
    }  
    It "Wrong path" {
        CheckJson "aaaaaa" | Should -Be PathNotValid
    }  
    It "File empty" {
        CheckJson .\CredentialsEmpty.json | Should -Be Empty
    }  
    It "Wrong JSON string format" {
        CheckJson .\CredentialsWrongFormat.json | Should -Be WrongFormat
    }  
    It "Some credentials missing" {
        CheckJson .\CredentialsMissingProperty.json | Should -Be WrongCredentials
    }  
}


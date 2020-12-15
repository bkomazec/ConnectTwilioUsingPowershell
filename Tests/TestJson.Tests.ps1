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
        CheckJson | Should -Be Credentials
    }  
}


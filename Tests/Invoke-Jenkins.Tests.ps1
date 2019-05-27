 Import-Module -Name $PSScriptRoot\..\ThreeShape.Jenkins.Beta.psm1
. $PSScriptRoot/../Private/Get-JenkinsRequestHeaders.ps1
. $PSScriptRoot/../Private/ConvertTo-BasicAuth.ps1
. $PSScriptRoot/../Private/Get-CrumbHeader.ps1
function Get-MockHttpResponseException {
    param(
    [string] $HttpStatusCode
    )

    $exceptionBlockSource = '
    class MockWebResponse : System.Net.WebResponse
    {
    [System.Net.HttpStatusCode] $StatusCode

         MockWebResponse() {
             $this.StatusCode = $HttpStatusCode
         }
    }

    class MockHttpResponseException : System.Net.Http.HttpRequestException
    {
        [MockWebResponse] $Response

        MockHttpResponseException() {
            $this.Response = [MockWebResponse]::new()
        }
    }

    throw [MockHttpResponseException]::new()
    '
    $parameterizedSource = $exceptionBlockSource.Replace('$HttpStatusCode',$HttpStatusCode)
    return [scriptblock]::Create($parameterizedSource)
}

#Unit tests
Describe "Initialize-Jenkins method" {

    BeforeAll {
        $script:moduleName = (Get-Item $PSScriptRoot\..\*.psd1)[0].BaseName
        $jenkinsUrl = "http://localhost"
        $apiUser = "Bobby Bobbelhead"
        $apiPassword = "Fallout4ever" | ConvertTo-SecureString -AsPlainText -Force

        Initialize-Jenkins  -JenkinsUrl $jenkinsUrl `
                            -ApiUsername $apiUser `
                            -ApiPassword $apiPassword

        Mock -ModuleName $script:moduleName -CommandName Get-CrumbHeader { return "this=crumb" }
        Mock -ModuleName $script:moduleName -CommandName Invoke-RestMethod { return "dfgdfg:sdfsdsf" }
    }

    Context 'When invalid MaximumAttempts args are passed to Invoke-Jenkins' {

        It 'Then it throws an exception' {
            $request = {
                Invoke-JenkinsRequest   -Resource "manage" `
                                        -MaximumAttempts -1
            }

            $request | Should -Throw -ExceptionType ([System.Management.Automation.ParameterBindingException]) -PassThru
        }
    }

    Context 'When a request to a jenkins backend is succesful' {

        It 'Then Invoke-WebRequest is called within the Invoke-Jenkins method once and only once' {
            Mock -ModuleName $script:moduleName Invoke-WebRequest { "return 200 OK"}

            $result = Invoke-JenkinsRequest -Resource "nowhere" `
                                            -Username "rasmus" `
                                            -Password $script:apiPassword

            $result | Should -Be "return 200 OK"

            Assert-MockCalled -ModuleName $script:moduleName -Scope "It" Invoke-WebRequest -Exactly -Times 1
        }
    }

    Context 'When a request to jenkins fails' {
        It 'then Invoke-WebRequest call is retried three times by default' {
            Mock -ModuleName $script:moduleName Invoke-WebRequest { throw [System.Net.Http.HttpRequestException]::new("Simulate an exception") }

            $result = Invoke-JenkinsRequest -Resource "nowhere" `
                                            -Username "rasmus" `
                                            -Password $script:apiPassword

            $result | Should -BeExactly $null

            Assert-MockCalled -ModuleName $script:moduleName -Scope "It" Invoke-WebRequest -Exactly -Times 3
        }


        It 'Then Invoke-WebRequest is retried up to the number of times specified' {
            Mock -ModuleName $script:moduleName Invoke-WebRequest { throw [System.Net.Http.HttpRequestException]::new("Simulate an exception") }

            $result = Invoke-JenkinsRequest -Resource "nowhere" `
                                            -Username "rasmus" `
                                            -Password $script:apiPassword `
                                            -MaximumAttempts 5

            $result | Should -BeExactly $null

            Assert-MockCalled -ModuleName $script:moduleName -Scope "It" Invoke-WebRequest -Exactly -Times 5
        }

        It 'Any failure causes an exception to be re-thrown' {
            $exceptionBlock = Get-MockHttpResponseException -HttpStatusCode "[System.Net.HttpStatusCode]::Forbidden"

            Mock -ModuleName $script:moduleName Invoke-WebRequest $exceptionBlock

            $request = {
                Invoke-JenkinsRequest   -Resource "nowhere" `
                                        -Username "rasmus" `
                                        -Password $script:apiPassword
            }

            $request | Should -Throw "MockHttpResponseException"
        }

        It 'Any unexpected exception is rethrown for the caller to handle' {
            Mock -ModuleName $script:moduleName Invoke-WebRequest { throw [System.AccessViolationException]::new() }

            $request = {
                Invoke-JenkinsRequest   -Resource "nowhere" `
                                        -Username "rasmus" `
                                        -Password $script:apiPassword
            }

            $request | Should -Throw -ExceptionType ([System.AccessViolationException]) -PassThru
        }
    }

    Context 'When a request returns a redirect' {
        It 'The redirect is not treated as an exception when TreatRedirectsAsSucces is true as is the case by default)' {
            $exceptionBlock = Get-MockHttpResponseException -HttpStatusCode "[System.Net.HttpStatusCode]::Redirect"
            Mock -ModuleName $script:moduleName Invoke-WebRequest $exceptionBlock

            $result = Invoke-JenkinsRequest -Resource "nowhere" `
                                            -Username "rasmus" `
                                            -Password $script:apiPassword

            Assert-MockCalled -ModuleName $script:moduleName -Scope "It" Invoke-WebRequest -Exactly -Times 1
            $result | Should -Not -BeNullOrEmpty
        }

        It 'The redirect causes an exception if the caller sets TreatRedirectsAsSucces = false' {
            $exceptionBlock = Get-MockHttpResponseException -HttpStatusCode "[System.Net.HttpStatusCode]::Redirect"
            Mock -ModuleName $script:moduleName Invoke-WebRequest $exceptionBlock

            $request = {
                Invoke-JenkinsRequest   -Resource "nowhere" `
                                        -Username "rasmus" `
                                        -Password $script:apiPassword `
                                        -MaximumAttempts 5 `
                                        -TreatRedirectAsSucces $false
            }
            $request | Should -Throw "MockHttpResponseException"
        }

    }

}






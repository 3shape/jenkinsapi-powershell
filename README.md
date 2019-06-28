
# Jenkins.Api PowerShell Module ![Build status on master branch](https://travis-ci.com/3shapeAS/jenkinsapi-powershell.svg?branch=master)

The Jenkins.Api PowerShell module automates several Jenkins administrative and authoring tasks in PowerShell.

This module can be found in PowerShell Gallery: https://www.powershellgallery.com/packages/Jenkins.Api

## Functions

This module offers the following functions, all from the [Public](/Public) folder:

* Get-JenkinsUserFullName
* Initialize-Jenkins
* Invoke-Jenkins
* Invoke-JenkinsForm
* Invoke-JenkinsRequest
* New-JenkinsJob
* Remove-JenkinsJob

## CI/CD

For CI, see https://travis-ci.com/3shapeAS/jenkinsapi-powershell

### Release Process

* Contribute a PR
* Pass all Pester tests!
* Get it approved and merged to master
* Push a tag
* Deploys to [PSGallery](https://www.powershellgallery.com/packages/Jenkins.Api) in 5 minutes

<#
Use Indented.StubCommand to generate the module stub

https://github.com/indented-automation/Indented.StubCommand

On a machine that has got the required PowerShell module installed:

Install-Module -Name Indented.StubCommand

$functionBody = {
    throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
}
New-StubModule -FromModule <ModuleName> -Path <OutputPath> -FunctionBody $functionBody
#>

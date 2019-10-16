<#PSScriptInfo
.VERSION 1.0.0
.GUID Get-A-New-GUID
.AUTHOR Microsoft Corporation
.COMPANYNAME Microsoft Corporation
.COPYRIGHT (c) Microsoft Corporation. All rights reserved.
.TAGS DSCConfiguration
.LICENSEURI https://github.com/X-Guardian/{Module}Dsc/blob/master/LICENSE
.PROJECTURI https://github.com/X-Guardian/{Module}Dsc
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES First version.
.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core
#>

#Requires -module '{Module}Dsc'

<#
    .DESCRIPTION
        This configuration will ...
#>

Configuration '{Module}{Resource}_Config'
{
    Import-DscResource -ModuleName '{Module}Dsc'

    Node localhost
    {
        {Module}{Resource} 'Name1'
        {
            KeyProperty      = 'Key Property Value'
            RequriedProperty = 'Required Property Value'
            WriteProperty    = 'Write Property Value'
        }
    }
}

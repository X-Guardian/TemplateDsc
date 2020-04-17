<#
    .SYNOPSIS
        DSC module for the {Resource} resource

    .DESCRIPTION
        The {Resource} DSC resource manages ...

    .PARAMETER KeyProperty
        Key - String
        Specifies the key property.

    .PARAMETER RequiredProperty
        Requried - String
        Specifies a required property.

    .PARAMETER WriteProperty
        Write - String
        Specifies a write property.
#>

Set-StrictMode -Version 2.0

$script:dscModuleName = '{DscModule}'
$script:psModuleName = '{PSModule}'

$script:dscResourceName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)

$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'

$script:localizationModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'AdfsDsc.Common'
Import-Module -Name (Join-Path -Path $script:localizationModulePath -ChildPath 'AdfsDsc.Common.psm1')

$script:localizedData = Get-LocalizedData -ResourceName $script:dscResourceName

function Get-TargetResource
{
    <#
    .SYNOPSIS
        Get-TargetResource

    .NOTES
        Used Cmdlets/Functions:

        Name           | Module
        ---------------|----------------
        Get-{Resource} | {PSModule}
        Assert-Module  | {DscModule}.Common
    #>

    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $KeyProperty,

        [Parameter(Mandatory = $true)]
        [System.String]
        $RequiredProperty
    )

    # Set Verbose and Debug parameters
    $commonParms = @{
        Verbose = $VerbosePreference
        Debug   = $DebugPreference
    }

    Write-Verbose ($script:localizedData.GettingResourceMessage -f $KeyProperty)

    # Check of the Resource PowerShell module is installed
    Assert-Module -ModuleName $script:psModuleName

    try
    {
        # $targetResource = Get-{Resource} -KeyProperty $KeyProperty
    }
    catch
    {
        $errorMessage = $script:localizedData.GettingResourceErrorMessage -f $FederationServiceName
        New-InvalidOperationException -Message $errorMessage -Error $_
    }

    $returnValue = @{
        KeyProperty      = $targetResource.KeyProperty
        RequiredProperty = $targetResource.RequiredProperty
        WriteProperty    = $targetResource.WriteProperty
        ReadProperty     = $targetResource.ReadProperty
    }

    $returnValue
}

function Set-TargetResource
{
    <#
    .SYNOPSIS
        Set-TargetResource

        Used Cmdlets/Functions:

        Name                          | Module
        ------------------------------|----------------
        Set-{Resource}                | {PSModule}
        Compare-ResourcePropertyState | {DscModule}.Common
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $KeyProperty,

        [Parameter(Mandatory = $true)]
        [System.String]
        $RequiredProperty,

        [Parameter()]
        [System.String]
        $WriteProperty
    )

    # Set Verbose and Debug parameters
    $commonParms = @{
        Verbose = $VerbosePreference
        Debug   = $DebugPreference
    }

    # Remove any parameters not used in Splats
    [HashTable]$parameters = $PSBoundParameters
    $parameters.Remove('Ensure')
    $parameters.Remove('Verbose')
    $parameters.Remove($KeyProperty)

    $getTargetResourceParms = @{
        KeyProperty      = $KeyProperty
        RequiredProperty = $RequiredProperty
    }
    $targetResource = Get-TargetResource @getTargetResourceParms

    $propertiesNotInDesiredState = (
        Compare-ResourcePropertyState -CurrentValues $targetResource -DesiredValues $parameters `
            @commonParms | Where-Object -Property InDesiredState -eq $false)

    $setParameters = @{ }
    foreach ($property in $propertiesNotInDesiredState)
    {
        Write-Verbose -Message ($script:localizedData.SettingResourcePropertyMessage -f
            $Name, $property.ParameterName, ($property.Expected -join ', '))

        $SetParameters.add($property.ParameterName, $property.Expected)
    }

    try
    {
        # Set-{Resource} -KeyProperty $KeyProperty @SetParameters
    }
    catch
    {
        $errorMessage = $script:localizedData.SettingResourceErrorMessage -f $KeyProperty
        New-InvalidOperationException -Message $errorMessage -Error $_
    }
}

function Test-TargetResource
{
    <#
    .SYNOPSIS
        Test-TargetResource

    .NOTES
        Used Cmdlets/Functions:

        Name                          | Module
        ------------------------------|------------------
        Compare-ResourcePropertyState | {DscModule}.Common
    #>

    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $KeyProperty,

        [Parameter(Mandatory = $true)]
        [System.String]
        $RequiredProperty,

        [Parameter()]
        [System.String]
        $WriteProperty
    )

    # Set Verbose and Debug parameters
    $commonParms = @{
        Verbose = $VerbosePreference
        Debug   = $DebugPreference
    }

    $getTargetResourceParms = @{
        KeyProperty      = $KeyProperty
        RequiredProperty = $RequiredProperty
    }
    $targetResource = Get-TargetResource @getTargetResourceParms

    $propertiesNotInDesiredState = (
        Compare-ResourcePropertyState -CurrentValues $targetResource -DesiredValues $PSBoundParameters `
            @commonParms | Where-Object -Property InDesiredState -eq $false)

    if ($propertiesNotInDesiredState)
    {
        # Resource is not in desired state
        Write-Verbose -Message ($script:localizedData.ResourceNotInDesiredStateMessage -f $KeyProperty)

        $inDesiredState = $false
    }
    else
    {
        # Resource is in desired state
        Write-Verbose -Message ($script:localizedData.ResourceInDesiredStateMessage -f $KeyProperty)

        $inDesiredState = $true
    }

    $inDesiredState
}

Export-ModuleMember -Function *-TargetResource

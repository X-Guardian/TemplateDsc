<#
    .SYNOPSIS
        DSC module for the {DscModule} {Resource} resource

    .DESCRIPTION
        The {DscModule}{Resource} DSC resource manages ...

    .PARAMETER KeyProperty
        Key - String
        Specifies the key property.

    .PARAMETER RequiredProperty
        Requried - String
        Specifies a required property.

    .PARAMETER WriteProperty
        Write - String
        Specifies a write property.

    .PARAMETER Ensure
        Write - String
        Allowed values: Present, Absent
        Specifies whether the resource should be present or absent. Default value is 'Present'.
#>

Set-StrictMode -Version 2.0

$script:dscModuleName = '{DscModule}'
$script:psModuleName = '{PSModule}'
$script:dscResourceName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)

$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'

$script:localizationModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath "$($script:DSCModuleName).Common"
Import-Module -Name (Join-Path -Path $script:localizationModulePath -ChildPath "$($script:dscModuleName).Common.psm1")

$script:localizedData = Get-LocalizedData -ResourceName $script:dscResourceName

function Get-TargetResource
{
    <#
    .SYNOPSIS
        Get-TargetResource

    .NOTES
        Used Cmdlets/Functions:

        Name                                     | Module
        -----------------------------------------|----------------
        Get-{Resource}                           | {PSModule}
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

    # Remove any parameters not used in Splats
    $parameters = $PSBoundParameters
    $parameters.Remove('Verbose')

    # Check of the Resource PowerShell module is installed
    Assert-Module -ModuleName $script:psModuleName

    Write-Verbose ($script:localizedData.GettingResourceMessage -f $KeyProperty)

    try
    {
        # $targetResource = Get-{Resource} -KeyProperty $KeyProperty
    }
    catch
    {
        $errorMessage = $script:localizedData.GettingResourceError -f $FederationServiceName
        New-InvalidOperationException -Message $errorMessage -Error $_
    }

    if ($targetResource)
    {
        # Resource is Present
        Write-Debug -Message ($script:localizedData.TargetResourcePresentDebugMessage -f $KeyProperty)

        $returnValue = @{
            KeyProperty      = $targetResource.KeyProperty
            RequiredProperty = $targetResource.RequiredProperty
            WriteProperty    = $targetResource.WriteProperty
            ReadProperty     = $targetResource.ReadProperty
            Ensure           = 'Present'
        }
    }
    else
    {
        # Resource is Absent
        Write-Debug -Message ($script:localizedData.TargetResourceAbsentDebugMessage -f $KeyProperty)

        $returnValue = @{
            KeyProperty      = $KeyProperty
            RequiredProperty = $RequiredProperty
            WriteProperty    = $null
            ReadProperty     = $null
            Ensure           = 'Absent'
        }
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
        New-{Resource}                | {PSModule}
        Set-{Resource}                | {PSModule}
        Remove-{Resource}             | {PSModule}
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
        $WriteProperty,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = 'Present'
    )

    # Set Verbose and Debug parameters
    $commonParms = @{
        Verbose = $VerbosePreference
        Debug   = $DebugPreference
    }

    # Remove any parameters not used in Splats
    $parameters = $PSBoundParameters
    $parameters.Remove('Ensure')
    $parameters.Remove('Verbose')
    $parameters.Remove($KeyProperty)

    Write-Verbose -Message ($script:localizedData.SettingResourceMessage -f $KeyProperty)

    $GetTargetResourceParms = @{
        KeyProperty      = $KeyProperty
        RequiredProperty = $RequiredProperty
    }
    $targetResource = Get-TargetResource @GetTargetResourceParms

    if ($TargetResource.Ensure -eq 'Present')
    {
        # Resource is Present
        Write-Debug -Message ($script:localizedData.TargetResourcePresentDebugMessage -f $KeyProperty)

        if ($Ensure -eq 'Present')
        {
            # Resource shouild be present
            Write-Debug -Message ($script:localizedData.TargetResourceShouldBePresentDebugMessage -f $KeyProperty)

            $propertiesNotInDesiredState = (
                Compare-ResourcePropertyState -CurrentValues $targetResource -DesiredValues $parameters `
                    @commonParms | Where-Object -Property InDesiredState -eq $false)

            $setParameters = @{ }
            foreach ($property in $propertiesNotInDesiredState)
            {
                Write-Verbose -Message ($script:localizedData.SettingResourcePropertyMessage -f
                    $KeyProperty, $property.ParameterName, ($property.Expected -join ', '))
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
        else
        {
            # Resource should be Absent
            Write-Debug -Message ($script:localizedData.TargetResourceShouldBeAbsentDebugMessage -f $KeyProperty)

            Write-Verbose -Message ($script:localizedData.RemovingResourceMessage -f $KeyProperty)

            try
            {
                # Remove-{Resource} -KeyProperty $KeyProperty
            }
            catch
            {
                $errorMessage = $script:localizedData.RemovingResourceErrorMessage -f $KeyProperty
                New-InvalidOperationException -Message $errorMessage -Error $_
            }
        }
    }
    else
    {
        # Resource is Absent
        Write-Debug -Message ($script:localizedData.TargetResourceAbsentDebugMessage -f $KeyProperty)

        if ($Ensure -eq 'Present')
        {
            # Resource should be Present
            Write-Debug -Message ($script:localizedData.TargetResourceShouldBePresentDebugMessage -f $KeyProperty)

            Write-Verbose -Message ($script:localizedData.AddingResourceMessage -f $KeyProperty)

            try
            {
                # New-{Resource} @parameters
            }
            catch
            {
                $errorMessage = $script:localizedData.AddingResourceErrorMessage -f $KeyProperty
                New-InvalidOperationException -Message $errorMessage -Error $_
            }

        }
        else
        {
            # Resource should be Absent
            Write-Debug -Message ($script:localizedData.TargetResourceShouldBeAbsentDebugMessage -f $KeyProperty)

            Write-Verbose -Message ($script:localizedData.ResourceInDesiredStateMessage -f $KeyProperty)
        }
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
        $WriteProperty,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = 'Present'
    )

    # Set Verbose and Debug parameters
    $commonParms = @{
        Verbose = $VerbosePreference
        Debug   = $DebugPreference
    }

    Write-Verbose -Message ($script:localizedData.TestingResourceMessage -f $KeyPropertyName)

    $getTargetResourceParms = @{
        KeyProperty      = $KeyProperty
        RequiredProperty = $RequiredProperty
    }
    $targetResource = Get-TargetResource @getTargetResourceParms

    if ($targetResource.Ensure -eq 'Present')
    {
        # Resource is Present
        Write-Debug -Message ($script:localizedData.TargetResourcePresentDebugMessage -f $KeyProperty)

        if ($Ensure -eq 'Present')
        {
            # Resource should be Present
            Write-Debug -Message ($script:localizedData.TargetResourceShouldBePresentDebugMessage -f $KeyProperty)

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
        }
        else
        {
            # Resource should be Absent
            Write-Debug -Message ($script:localizedData.TargetResourceShouldBeAbsentDebugMessage -f $KeyProperty)

            Write-Verbose -Message ($script:localizedData.ResourceIsPresentButShouldBeAbsentMessage -f $KeyProperty)
            $inDesiredState = $false
        }
    }
    else
    {
        # Resource is Absent
        Write-Debug -Message ($script:localizedData.TargetResourceAbsentDebugMessage -f $KeyProperty)

        if ($Ensure -eq 'Present')
        {
            # Resource should be Present
            Write-Debug -Message ($script:localizedData.TargetResourceShouldBePresentDebugMessage -f $KeyProperty)

            Write-Verbose -Message ($script:localizedData.ResourceIsAbsentButShouldBePresentMessage -f $KeyProperty)
            $inDesiredState = $false
        }
        else
        {
            # Resource should be Absent
            Write-Debug -Message ($script:localizedData.TargetResourceShouldBeAbsentDebugMessage -f $KeyProperty)

            Write-Verbose -Message ($script:localizedData.ResourceInDesiredStateMessage -f $KeyProperty)
            $inDesiredState = $true
        }
    }

    $inDesiredState
}

Export-ModuleMember -Function *-TargetResource

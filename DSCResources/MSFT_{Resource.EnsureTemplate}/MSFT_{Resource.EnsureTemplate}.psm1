<#
    .SYNOPSIS
        DSC module for the {Module} {Resource} resource

    .DESCRIPTION
        The {Module}{Resource} DSC resource manages ...

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

$script:dscModuleName = '{Module}'
$script:PSModuleName = '{PSModule}'
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
        Used Resource PowerShell Cmdlets:
        - Get-{Resource} - https://{GetResourceUrl}
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

    # Remove any parameters not used in Splats
    $parameters = $PSBoundParameters
    $parameters.Remove('Verbose')

    # Check of the Resource PowerShell module is installed
    Assert-Module -ModuleName $script:PSModuleName

    Write-Verbose ($script:localizedData.GettingResourceMessage -f $Name)

    # $targetResource = Get-{Resource} -KeyProperty $KeyProperty

    if ($targetResource)
    {
        # Resource exists
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
        # Resource does not exist
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

    .NOTES
        Used Resource PowerShell Cmdlets:
        - New-{Resource}    - https://{NewResourceUrl}
        - Set-{Resource}    - https://{SetResourceUrl}
        - Remove-{Resource} - https://{RemoveResourceUrl}
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

    # Remove any parameters not used in Splats
    $parameters = $PSBoundParameters
    $parameters.Remove('Ensure')
    $parameters.Remove('Verbose')
    $parameters.Remove($KeyProperty)

    $GetTargetResourceParms = @{
        KeyProperty      = $KeyProperty
        RequiredProperty = $RequiredProperty
    }
    $targetResource = Get-TargetResource @GetTargetResourceParms

    if ($Ensure -eq 'Present')
    {
        # Resource should exist
        if ($TargetResource.Ensure -eq 'Present')
        {
            # Resource exists
            $propertiesNotInDesiredState = (
                Compare-ResourcePropertyState -CurrentValues $targetResource -DesiredValues $parameters |
                    Where-Object -Property InDesiredState -eq $false)

            $SetParameters = New-Object -TypeName System.Collections.Hashtable
            foreach ($property in $propertiesNotInDesiredState)
            {
                Write-Verbose -Message ($script:localizedData.SettingResourceMessage -f
                    $Name, $property.ParameterName, ($property.Expected -join ', '))
                $SetParameters.add($property.ParameterName, $property.Expected)
            }

            # Set-{Resource} -KeyProperty $KeyProperty @SetParameters
        }
        else
        {
            # Resource does not exist
            Write-Verbose -Message ($script:localizedData.AddingResourceMessage -f $Name)
            # New-{Resource} @parameters
        }
    }
    else
    {
        # Resource should not exist
        if ($TargetResource.Ensure -eq 'Present')
        {
            # Resource exists
            Write-Verbose -Message ($script:localizedData.RemovingResourceMessage -f $Name)
            # Remove-{Resource} -KeyProperty $KeyProperty
        }
        else
        {
            # Resource does not exist
            Write-Verbose -Message ($script:localizedData.ResourceInDesiredStateMessage -f $Name)
        }
    }
}

function Test-TargetResource
{
    <#
    .SYNOPSIS
        Test-TargetResource
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

    $getTargetResourceParms = @{
        KeyProperty      = $KeyProperty
        RequiredProperty = $RequiredProperty
    }
    $targetResource = Get-TargetResource @getTargetResourceParms

    if ($targetResource.Ensure -eq 'Present')
    {
        # Resource exists
        if ($Ensure -eq 'Present')
        {
            # Resource should exist
            $propertiesNotInDesiredState = (
                Compare-ResourcePropertyState -CurrentValues $targetResource -DesiredValues $PSBoundParameters |
                    Where-Object -Property InDesiredState -eq $false)
            if ($propertiesNotInDesiredState)
            {
                # Resource is not in desired state
                foreach ($property in $propertiesNotInDesiredState)
                {
                    Write-Verbose -Message (
                        $script:localizedData.ResourcePropertyNotInDesiredStateMessage -f
                        $targetResource.Name, $property.ParameterName, `
                            $property.Expected, $property.Actual)
                }
                $inDesiredState = $false
            }
            else
            {
                # Resource is in desired state
                Write-Verbose -Message ($script:localizedData.ResourceInDesiredStateMessage -f
                    $targetResource.Name)
                $inDesiredState = $true
            }
        }
        else
        {
            # Resource should not exist
            Write-Verbose -Message ($script:localizedData.ResourceExistsButShouldNotMessage -f
                $targetResource.Name)
            $inDesiredState = $false
        }
    }
    else
    {
        # Resource does not exist
        if ($Ensure -eq 'Present')
        {
            # Resource should exist
            Write-Verbose -Message ($script:localizedData.ResourceDoesNotExistButShouldMessage -f
                $targetResource.Name)
            $inDesiredState = $false
        }
        else
        {
            # Resource should not exist
            Write-Verbose ($script:localizedData.ResourceDoesNotExistAndShouldNotMessage -f
                $targetResource.Name)
            $inDesiredState = $true
        }
    }

    $inDesiredState
}

Export-ModuleMember -Function *-TargetResource

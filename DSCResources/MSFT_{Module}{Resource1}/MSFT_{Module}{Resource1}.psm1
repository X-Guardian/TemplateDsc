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

$script:resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$script:modulesFolderPath = Join-Path -Path $script:resourceModulePath -ChildPath 'Modules'

$script:localizationModulePath = Join-Path -Path $script:modulesFolderPath -ChildPath 'AdfsDsc.Common'
Import-Module -Name (Join-Path -Path $script:localizationModulePath -ChildPath 'AdfsDsc.Common.psm1')

$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_AdfsApplicationPermission'

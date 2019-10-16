$Global:DSCModuleName = '{Module}Dsc'
$Global:PSModuleName = '{Module}'
$Global:DscResourceFriendlyName = '{Resource}'
$Global:DSCResourceName = "MSFT_$Global:DscResourceFriendlyName"

$moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git',
        (Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force

$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Unit

try
{
    InModuleScope $Global:DSCResourceName {
        # Import Stub Module
        Import-Module (Join-Path -Path $PSScriptRoot -ChildPath "Stubs\$($Global:PSModuleName)Stub.psm1") -Force

        # Define Resource Commands
        $ResourceCommand = @{
            Get     = 'Get-{Resource}'
            Install = 'Install-{Resource}'
        }

        $mockUserName = 'CONTOSO\SvcAccount'
        $mockPassword = 'DummyPassword'

        $mockCredential = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList @(
            $mockUserName,
            (ConvertTo-SecureString -String $mockPassword -AsPlainText -Force)
        )

        $mockMSFTCredential = New-CimCredentialInstance -UserName $mockUserName

        $mockResource = @{
            KeyProperty      = 'Key Property Value'
            RequiredProperty = 'Required Property Value'
            WriteProperty    = 'Write Property Value'
            ReadProperty     = 'Read Property Value'
            Ensure           = 'Present'
        }

        $mockAbsentResource = @{
            KeyProperty      = 'Key Property Value'
            RequiredProperty = 'Required Property Value'
            WriteProperty    = $null
            ReadProperty     = $null
            Ensure           = 'Absent'
        }

        $mockGetTargetResourceResult = @{
            KeyProperty      = $mockResource.KeyProperty
            RequiredProperty = $mockResource.RequiredProperty
            WriteProperty    = $mockResource.WriteProperty
            ReadProperty     = $mockResource.ReadProperty
            Ensure           = $mockResource.Ensure
        }

        $mockGetTargetResourcePresentResult = $mockGetTargetResourceResult.Clone()
        $mockGetTargetResourcePresentResult.Ensure = 'Present'

        $mockGetTargetResourceAbsentResult = $mockGetTargetResourceResult.Clone()
        $mockGetTargetResourceAbsentResult.Ensure = 'Absent'

        Describe "$Global:DSCResourceName\Get-TargetResource" -Tag 'Get' {
            BeforeAll {
                $getTargetResourceParameters = @{
                    KeyProperty      = $mockResource.KeyProperty
                    RequiredProperty = $mockResource.RequiredProperty
                }

                $mockGetResourceCommandResult = @{
                    KeyProperty      = $mockResource.KeyProperty
                    RequiredProperty = $mockResource.RequiredProperty
                    WriteProperty    = $mockResource.WriteProperty
                }

                Mock -CommandName Assert-Module
                Mock -CommandName $ResourceCommand.Get -MockWith { $mockGetResourceCommandResult }
            }

            Context "When the $($Global:DscResourceFriendlyName) Resource is configured" {
                BeforeAll {
                    Mock -CommandName $ResourceCommand.Get -MockWith { 'Configured' }

                    $result = Get-TargetResource @getTargetResourceParameters
                }

                foreach ($property in $mockResource.Keys)
                {
                    It "Should return the correct $property property" {
                        $result.$property | Should -Be $mockResource.$property
                    }
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Assert-Module `
                        -ParameterFilter { $ModuleName -eq $Global:PSModuleName } `
                        -Exactly -Times 1
                    Assert-MockCalled -CommandName $ResourceCommand.Get -Exactly -Times 1
                }
            }

            Context "When the $($Global:DscResourceFriendlyName) Resource is not configured" {
                BeforeAll {
                    Mock -CommandName $ResourceCommand.Get -MockWith { 'NotConfigured' }

                    $result = Get-TargetResource @getTargetResourceParameters
                }

                foreach ($property in $mockResource.Keys)
                {
                    It "Should return the correct $property property" {
                        $result.$property | Should -Be $mockAbsentResource.$property
                    }
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Assert-Module `
                        -ParameterFilter { $ModuleName -eq $Global:PSModuleName } `
                        -Exactly -Times 1
                    Assert-MockCalled -CommandName $ResourceCommand.Get -Exactly -Times 1
                }
            }
        }

        Describe "$Global:DSCResourceName\Set-TargetResource" -Tag 'Set' {
            BeforeAll {
                $getTargetResourceParameters = @{
                    KeyProperty      = $mockResource.KeyProperty
                    RequiredProperty = $mockResource.RequiredProperty
                }

                Mock -CommandName $ResourceCommand.Install
            }

            Context "When the $($Global:DscResourceFriendlyName) Resource is not installed" {
                BeforeAll {
                    $mockGetTargetResourceAbsentResult = @{
                        Ensure = 'Absent'
                    }

                    Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourceAbsentResult }
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should -Not -Throw
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName $ResourceCommand.Install `
                        -ParameterFilter { $KeyProperty -eq $setTargetResourceParameters.KeyProperty } `
                        -Exactly -Times 1
                }

                Context "When $($ResourceCommand.Install) throws an exception" {
                    BeforeAll {
                        Mock $ResourceCommand.Install -MockWith { throw 'Error' }
                    }

                    It 'Should throw the correct error' {
                        { Set-TargetResource @setTargetResourceParameters } | Should -Throw (
                            $script:localizedData.InstallationError -f $setTargetResourceParameters.KeyProperty)
                    }
                }
            }

            Context "When the $($Global:DscResourceFriendlyName) Resource is installed" {
                BeforeAll {
                    Mock -CommandName Get-TargetResource -MockWith { $mockGetTargetResourcePresentResult }
                }

                It 'Should not throw' {
                    { Set-TargetResource @setTargetResourceParameters } | Should -Not -Throw
                }
            }
        }

        Describe "$Global:DSCResourceName\Test-TargetResource" -Tag 'Test' {
            BeforeAll {
                $testTargetResourceParameters = @{
                    KeyProperty      = $mockResource.KeyProperty
                    RequiredProperty = $mockResource.RequiredProperty
                }
            }

            Context "When the $($Global:DscResourceFriendlyName) Resource is installed" {
                BeforeAll {
                    Mock Get-TargetResource -MockWith { $mockGetTargetResourcePresentResult }
                }

                It 'Should return $true' {
                    Test-TargetResource @testTargetResourceParameters | Should -BeTrue
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-TargetResource `
                        -ParameterFilter { `
                            $KeyProperty -eq $testTargetResourceParameters.KeyProperty } `
                        -Exactly -Times 1

                }
            }

            Context "When the $($Global:DscResourceFriendlyName) Resource is not installed" {
                BeforeAll {
                    Mock Get-TargetResource -MockWith { $mockGetTargetResourceAbsentResult }
                }

                It 'Should return $false' {
                    Test-TargetResource @testTargetResourceParameters | Should -BeFalse
                }

                It 'Should call the expected mocks' {
                    Assert-MockCalled -CommandName Get-TargetResource `
                        -ParameterFilter { `
                            $KeyProperty -eq $testTargetResourceParameters.KeyProperty } `
                        -Exactly -Times 1
                }
            }
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}

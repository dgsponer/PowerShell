<#
.SYNOPSIS
    Short description
    Compare the ESXi build version between two Hosts or multiple hosts objects 
.DESCRIPTION
    Long description
    File-Name:  Compare-EsxHostBuild.ps1
    Author:     Diego Holzer
    Version:    v0.0.1
    Changelog:
                v0.0.1, 2021-02-09, Diego Holzer: First implementation.
.NOTES
    Copyright (c) 2021 Diego Holzer,
    licensed under the MIT License (https://mit-license.org/)
.LINK
    https://github.com/dholzer/PowerShell/vSphere
.EXAMPLE
    Run a normal check, true mean: the build is euqal
    Compare-EsxHostBuild -PrimaryHost 'esxi01' -SecondaryHost 'esxi02'
.EXAMPLE
    Run a check from one host to a other host and get a detailed list with the result, true mean: the build is euqal
    Compare-EsxHostBuild -PrimaryHost 'esxi01' -SecondaryHost 'esxi02' -Details
.EXAMPLE
    Run a check from one host to all other hosts and get a detailed list with the result in json
    Compare-EsxHostBuild -PrimaryHost 'esxi01' -SecondaryHost (Get-VMHost) -Details -AsJson
#>

function Compare-EsxHostBuild {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
        $PrimaryHost,
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 1)]
        $SecondaryHost,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 2)]
        [switch]$Details = $false,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 3)]
        [switch]$AsJson = $false
    )

    begin {
        $returnValue = @()
    }

    process {
        if ($PrimaryHost.GetType().Name -ne 'VMHostImpl') {
            $PrimaryHost = Get-VMHost $PrimaryHost
        }
        
        if ($SecondaryHost.GetType().Name -ne 'VMHostImpl') {
            $SecondaryHost = Get-VMHost $SecondaryHost
        }

        foreach ($primaryHostElement in $PrimaryHost) {
            $primaryHostElementBuild = $primaryHostElement.Build
            foreach ($secondaryHostElement in $SecondaryHost) {
                $secondaryHostElementBuild = $secondaryHostElement.Build

                $equal =  ($primaryHostElementBuild -eq $secondaryHostElementBuild)

                $value = [PSCustomObject]@{
                    PrimaryVMHost = $primaryHostElement.Name
                    SecondaryVMHost = $secondaryHostElement.Name
                    PrimaryBuild = $primaryHostElementBuild
                    SecondaryBuild = $secondaryHostElementBuild 
                    Equal = $equal
                }
                $returnValue += $value
            }
        }
    }

    end {
        if ($Details) {
            if ($AsJson) {
                return ($returnValue | Sort-Object PrimaryVMHost | ConvertTo-Json -Depth 50)
            }
            else {
                return ($returnValue | Sort-Object PrimaryVMHost) 
            }
        }
        else {
            if ($false -in $returnValue.Equal) {
                return $false
            }
            else {
                return $true
            }
        }
    }
}

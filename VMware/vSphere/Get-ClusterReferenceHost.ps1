<#
.SYNOPSIS
    Short description
    Get a host from the same cluster, with the same model 
.DESCRIPTION
    Long description
    File-Name:  Get-ClusterReferenceHost.ps1
    Author:     Diego Gsponer
    Version:    v0.0.2
    Changelog:
                v0.0.1, 2021-02-09, Diego Gsponer: First implementation.
                v0.0.2, 2022-07-12, Diego Gsponer: Add examples.
.NOTES
    Copyright (c) 2021 Diego Gsponer,
    licensed under the MIT License (https://mit-license.org/)
.LINK
    https://github.com/dgsponer/PowerShell/vSphere
.EXAMPLE
    Get-ClusterReferenceHost -VMHost 'esxi01'
    Run a normal get, return value is a other host in the same cluster with the same model (last one)
.EXAMPLE
    Get-ClusterReferenceHost -VMHost 'esxi01' -First
    Run a normal get, return value is a other host in the same cluster with the same model (first one)
.EXAMPLE
    Get-ClusterReferenceHost -VMHost 'esxi01' -Details
    Run a normal get, return value is a other host in the same cluster with the same model, detailed list
.EXAMPLE
    Get-ClusterReferenceHost -VMHost 'esxi01' -Details -AsJson
    Run a normal get, return value is a other host in the same cluster with the same model, detailed list as json
#>

function Get-ClusterReferenceHost {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
        $PrimaryHost,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 1)]
        [ValidateSet('First','Last')]
        $Position = 'Last', 
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

        foreach ($primaryHostElement in $PrimaryHost) {
            $cluster = Get-Cluster -VMHost $primaryHostElement
            $primaryHostModel = (Get-VMHost $primaryHostElement).ExtensionData.Hardware.SystemInfo.Model
            $referenceHost = $Cluster | Get-VMHost | Where-Object {$_.ConnectionState -eq 'Connected' -AND $_ -ne $primaryHostElement -AND $_.ExtensionData.Hardware.SystemInfo.Model -eq $PrimaryHostModel} | Sort-Object Name

            if ($Position -eq 'First') {
                $referenceHost = $referenceHost | Select-Object -First 1
            }
            elseif ($Position -eq 'Last') {
                $referenceHost = $referenceHost | Select-Object -Last 1
            }

            $value = [PSCustomObject]@{
                PrimaryHost = $primaryHostElement.Name
                ReferenceHost = $referenceHost.Name
                Model = $primaryHostModel
                Cluster = $cluster.Name
            }

            $returnValue += $value
        }
    }

    end {
        if ($Details) {
            if ($AsJson) {
                return ($returnValue | ConvertTo-Json -Depth 50)
            }
            else {
                return $returnValue
            }
        }
        else {
            return $returnValue | Select-Object ReferenceHost
        }
    }
}

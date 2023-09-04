<#
.SYNOPSIS
    Short description
    Get the esxcli host nic statistics
.DESCRIPTION
    Long description
    File-Name:  Get-EsxHostNicStats.ps1
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
    Get-EsxHostNicStats -VMHost 'esxi01' -VmNic vmnic1
    Run a normal get, return value is a object with statistics from the vmnic
.EXAMPLE
    Get-EsxHostNicStats -VMHost 'esxi01' -VmNic vmnic1, vmnic2 -AsJson
    Run a normal get, return value is a object with statistics from multiple vmnics in json
#>

function Get-EsxHostNicStats {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
        $VMHost,
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 1)]
        $VmNic,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 2)]
        [switch]$AsJson
    )

    begin {
        $returnValue = @()
    }

    process {
        if ($VMHost.GetType().Name -ne 'VMHostImpl') {
            $VMHost = Get-VMHost $VMHost
        }

        foreach ($VMHostElement in $VMHost) {
            foreach ($vmNicElement in $VmNic) {
                $esxCli = Get-EsxCli -V2 -VMHost $VMHostElement
                $arguments = $esxCli.network.nic.stats.get.createArgs()
                $arguments.nicname = $vmNicElement

                $esxCliResult = $esxCli.network.nic.stats.get.Invoke($arguments)
                $esxCliResult | Add-Member -Name 'VMHost' -Value $VMHostElement.Name -MemberType NoteProperty
                $returnValue += $esxCliResult
            }
        }
    }

    end {
        $returnValue = $returnValue | Select-Object VMHost, * -ErrorAction Ignore
        if ($AsJson) {
            return ($returnValue | ConvertTo-Json -Depth 50)
        }
        else {
            return $returnValue
        }
    }
}

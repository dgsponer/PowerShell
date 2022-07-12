<#
.SYNOPSIS
    Short description
    Ping from a host to a target ip
.DESCRIPTION
    Long description
    File-Name:  Ping-EsxHost.ps1
    Author:     Diego Holzer
    Version:    v0.0.2
    Changelog:
                v0.0.1, 2021-02-09, Diego Holzer: First implementation.
                v0.0.2, 2022-07-12, Diego Holzer: Change comparing behavor, Add examples.
.NOTES
    Copyright (c) 2021 Diego Holzer,
    licensed under the MIT License (https://mit-license.org/)
.LINK
    https://github.com/dholzer/PowerShell/vSphere
.EXAMPLE
    Run a normal ping, return value is true for success
    Ping-EsxHost -VMHost 'esxi01' -DestinationAddress '172.16.0.1' -VmKernel 'vmk1'
.EXAMPLE
    Run a normal ping, return value is a detailed list with informations about the ping
    Ping-EsxHost -VMHost 'esxi01' -DestinationAddress '172.16.0.1' -VmKernel 'vmk1' -Details
.EXAMPLE
    Run a ping to multiple addresses, return value is a detailed list with informations about the ping
    Ping-EsxHost -VMHost 'esxi01' -DestinationAddress @('172.16.0.1','172.16.0.2','172.16.0.3') -VmKernel 'vmk0' -Details
.EXAMPLE
    Run a ping from multiple hosts to multiple addresses, return value is a detailed list with informations about the ping
    Ping-EsxHost -VMHost (Get-VMHost -State Connected) -DestinationAddress (Get-VMHost -State Connected | Get-VMHostNetworkAdapter -Name 'vmk0' -VMKernel).IP -VmKernel 'vmk0' -Details
#>

function Ping-EsxHost {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
        $VMHost,
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 1)]
        $DestinationAddress,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 2)]
        [string]$VmKernel,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 3)]
        [int]$PingCount = 3,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 4)]
        [switch]$Details = $false,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 5)]
        [switch]$AsJson = $false
    )

    begin {
        $returnValue = @()
    }

    process {
        if ($VMHost.GetType().Name -ne 'VMHostImpl') {
            $VMHost = Get-VMHost $VMHost
        }

        foreach ($VMHostElement in $VMHost) {
            foreach ($destinationAddressElement in $DestinationAddress) {
                $esxCli = Get-EsxCli -V2 -VMHost $VMHostElement
                $arguments = $esxCli.network.diag.ping.createArgs()
                $arguments.host = $destinationAddressElement
                $arguments.count = $PingCount
                if(($VMHostElement | Get-VMHostNetworkAdapter -Name $VmKernel -ErrorAction Ignore).PortGroupName -like 'vxw-vmknicPg-dvs*') {
                    $arguments.netstack = 'vxlan'
                } else {
                    $arguments.interface = $VmKernel
                }

                $esxCliResult = $esxCli.network.diag.ping.Invoke($arguments)

                if ($PingCount -eq $esxCliResult.Summary.Recieved) {
                    $success = $true
                }
                else {
                    $success = $false
                }
            
                $value = [PSCustomObject]@{
                    PrimaryVMHost = $VMHostElement.Name
                    DestinationAddress = $destinationAddressElement
                    Transmitted = $esxCliResult.Summary.Transmitted
                    Recieved = $esxCliResult.Summary.Recieved
                    Success = $success
                    Summary = $esxCliResult.Summary
                    Trace = $esxCliResult.Trace
                }
                $returnValue += $value
            }
        }
    }

    end {
        if ($Details) {
            $returnValue = $returnValue | Sort-Object PrimaryVMHost
            if ($AsJson) {
                return ($returnValue | ConvertTo-Json -Depth 50)
            }
            else {
                return $returnValue
            }    
        }
        else {
            if ($false -in $returnValue.Success) {
                return $false
            }
            else {
                return $true
            }
        }
    }
}

<#
.SYNOPSIS
    Short description
    Get the same data in powershell like the physical nic dialog in vventer
.DESCRIPTION
    Long description
    File-Name:  Get-EsxHostSwitchAndLinkInfo.ps1
    Author:     Diego Holzer
    Version:    v0.0.2
    Changelog:
                v0.0.1, 2021-02-09, Diego Holzer: First implementation.
                v0.0.2, 2022-07-12, Diego Holzer: Add examples.
.NOTES
    Copyright (c) 2021 Diego Holzer,
    licensed under the MIT License (https://mit-license.org/)
.LINK
    https://github.com/dholzer/PowerShell/vSphere
.EXAMPLE
    Run a normal get, return value is a object with the switches and link infos
    Get-EsxHostSwitchAndLinkInfo -VMHost 'esxi01'
.EXAMPLE
    Run a normal get, return value is a object from a sepcific switch and link infos
    Get-EsxHostSwitchAndLinkInfo -VMHost 'esxi01' -Switch 'vdSwitch'
.EXAMPLE
    Run a normal get, return value is a object with the switch and link infos from multiple hosts
    Get-EsxHostSwitchAndLinkInfo -VMHost (Get-VMHost)
#>

function Get-EsxHostSwitchAndLinkInfo {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
        $VMHost,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 1)]
        $Switch = ''
    )

    begin {
        $returnValue = @()
    }

    process {
        if ($VMHost.GetType().Name -ne 'VMHostImpl') {
            $VMHost = Get-VMHost $VMHost
        }
        foreach ($VMHostElement in $VMHost) {
            
            if ($Switch.Length -ne 0) {
                $switchObject = $VMHostElement | Get-VirtualSwitch -Name $Switch
            }
            else {
                $switchObject = $VMHostElement | Get-VirtualSwitch
            }
            
            foreach ($switchElement in $switchObject) {
                $switchElementNics = $VMHostElement | Get-VMHostNetworkAdapter -DistributedSwitch $switchElement -Physical | Sort-Object Name
                foreach ($switchElementNic in $switchElementNics) {
                    $maxSpeed = $switchElementNic.ExtensionData.ValidLinkSpecification.SpeedMb | Sort-Object -Descending | Select-Object -First 1
                    $currentSpeed = $switchElementNic.ExtensionData.LinkSpeed.SpeedMb
                    $currentDuplex = $switchElementNic.ExtensionData.LinkSpeed.Duplex
                    $duplexAvailable = ($true -in ($switchElementNic.ExtensionData.ValidLinkSpecification | Where-Object {$_.SpeedMb -eq $currentSpeed}).Duplex)            

                    $value = [PSCustomObject]@{
                        VMHost = $VMHostElement.Name
                        Switch = $SwitchElement.Name
                        Link = $SwitchElementNic
                        Mac = $SwitchElementNic.Mac
                        Speed = $currentSpeed
                        MaxSpeed = $maxSpeed
                        Duplex = $currentDuplex
                        DuplexAvailable = $duplexAvailable
                    }
                    $returnValue += $value
                }    
            }
        }
    }

    end {
        return ($returnValue | Sort-Object VMHost, Link)
    }
}

<#
.SYNOPSIS
    Short description
    Get the vmkernel, with ip and the assign switch and portgroup
.DESCRIPTION
    Long description
    File-Name:  Get-EsxHostvmKernelInfo.ps1
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
    Get-EsxHostvmKernelInfo -VMHost 'esxi01'
    Run a normal get, return value is a object with the switches and link infos
#>

function Get-EsxHostvmKernelInfo {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
        $VMHost
    )

    begin {
        $returnValue = @()
    }

    process {
        if ($VMHost.GetType().Name -ne 'VMHostImpl') {
            $VMHost = Get-VMHost $VMHost
        }

        foreach ($VMHostElement in $VMHost) {
            $VMHostElementVMKernels = $VMHostElement | Get-VMHostNetworkAdapter -VMKernel
            foreach ($vmKernel in $VMHostElementVMKernels) {
                $portGroupName = $vmKernel.PortGroupName
                # Skip if vmKernel has empty portgroupname (i.e. NSX-T)
                if ($portGroupName -eq $null){
                    continue
                }
                
                $portGroup = Get-VirtualPortGroup -Name $portGroupName -VMHost $VMHostElement
                $switch = $portGroup.VirtualSwitch

                $value = [PSCustomObject]@{
                    VMHost = $VMHostElement.Name
                    Switch = $switch.Name
                    VMKernel = $vmKernel.Name
                    IP = $vmKernel.IP
                    PortGroupName = $portGroupName
                }
                $returnValue += $value
            }
        }
    }

    end {
        return ($returnValue | Sort-Object VMHost, VMKernel)
    }
}

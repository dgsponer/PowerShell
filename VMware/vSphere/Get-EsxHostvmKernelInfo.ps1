function Get-EsxHostvmKernelInfo {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
        $PrimaryHost
    )

    begin {
        $returnValue = @()
    }

    process {
        if ($PrimaryHost.GetType().Name -ne 'VMHostImpl') {
            $PrimaryHost = Get-VMHost $PrimaryHost
        }

        foreach ($primaryHostElement in $PrimaryHost) {
            $primaryHostElementVMKernels = $primaryHostElement | Get-VMHostNetworkAdapter -VMKernel
            foreach ($vmKernel in $primaryHostElementVMKernels) {
                $portGroup = Get-VirtualPortGroup -Name $vmKernel.PortGroupName -VMHost $primaryHostElement
                $switch = $portGroup.VirtualSwitch

                $value = [PSCustomObject]@{
                    PrimaryHost = $primaryHostElement.Name
                    Switch = $switch.Name
                    VMKernel = $vmKernel.Name
                    IP = $vmKernel.IP
                    PortGroupName = $vmKernel.PortGroupName
                }
                $returnValue += $value
            }
        }
    }

    end {
        return ($returnValue | Sort-Object PrimaryHost, VMKernel)
    }
}

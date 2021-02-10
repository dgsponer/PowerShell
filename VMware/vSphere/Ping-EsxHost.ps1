function Ping-EsxHost {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
        $PrimaryHost,
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
        if ($PrimaryHost.GetType().Name -ne 'VMHostImpl') {
            $PrimaryHost = Get-VMHost $PrimaryHost
        }

        foreach ($primaryHostElement in $PrimaryHost) {
            foreach ($destinationAddressElement in $DestinationAddress) {
                $esxCli = Get-EsxCli -V2 -VMHost $primaryHostElement
                $arguments = $esxCli.network.diag.ping.createArgs()
                $arguments.host = $destinationAddressElement
                $arguments.count = $PingCount
                if(($primaryHostElement | Get-VMHostNetworkAdapter -Name $VmKernel -ErrorAction Ignore).PortGroupName -like 'vxw-vmknicPg-dvs*') {
                    $arguments.netstack = 'vxlan'
                } else {
                    $arguments.interface = $VmKernel
                }

                $esxCliResult = $esxCli.network.diag.ping.Invoke($arguments)

                if ($esxCliResult.Summary.Transmitted -eq $esxCliResult.Summary.Recieved) {
                    $success = $true
                }
                else {
                    $success = $false
                }
            
                $value = [PSCustomObject]@{
                    PrimaryVMHost = $primaryHostElement.Name
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

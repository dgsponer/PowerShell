function Get-EsxHostSwitchAndLinkInfo {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
        $PrimaryHost,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 1)]
        $Switch = ''
    )

    begin {
        $returnValue = @()
    }

    process {
        if ($PrimaryHost.GetType().Name -ne 'VMHostImpl') {
            $PrimaryHost = Get-VMHost $PrimaryHost
        }
        foreach ($primaryHostElement in $PrimaryHost) {
            
            if ($Switch.Length -ne 0) {
                $switchObject = $primaryHostElement | Get-VirtualSwitch -Name $Switch
            }
            else {
                $switchObject = $primaryHostElement | Get-VirtualSwitch
            }
            
            foreach ($switchElement in $switchObject) {
                $switchElementNics = $primaryHostElement | Get-VMHostNetworkAdapter -DistributedSwitch $switchElement -Physical | Sort-Object Name
                foreach ($switchElementNic in $switchElementNics) {
                    $maxSpeed = $switchElementNic.ExtensionData.ValidLinkSpecification.SpeedMb | Sort-Object -Descending | Select-Object -First 1
                    $currentSpeed = $switchElementNic.ExtensionData.LinkSpeed.SpeedMb
                    $currentDuplex = $switchElementNic.ExtensionData.LinkSpeed.Duplex
                    $duplexAvailable = ($true -in ($switchElementNic.ExtensionData.ValidLinkSpecification | Where-Object {$_.SpeedMb -eq $currentSpeed}).Duplex)            

                    $value = [PSCustomObject]@{
                        PrimaryHost = $primaryHostElement.Name
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
        return ($returnValue | Sort-Object PrimaryHost, Link)
    }
}

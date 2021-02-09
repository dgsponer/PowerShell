function Get-EsxNicInfo {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
        $PrimaryHost,
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 1)]
        $VmNic
    )

    begin {
        $returnValue = @()
    }

    process {
        if ($PrimaryHost.GetType().Name -ne 'VMHostImpl') {
            $PrimaryHost = Get-VMHost $PrimaryHost
        }

        foreach ($primaryHostElement in $PrimaryHost) {
            foreach ($vmNicElement in $VmNic) {
                $esxCli = Get-EsxCli -V2 -VMHost $primaryHostElement
                $arguments = $esxCli.network.nic.get.createArgs()
                $arguments.nicname = $vmNicElement

                $esxCliResult = $esxCli.network.nic.get.Invoke($arguments)
                $esxCliResult | Add-Member -Name 'VMHost' -Value $primaryHostElement.Name -MemberType NoteProperty
                $returnValue += $esxCliResult
            }
        }
    }

    end {
        return ($returnValue | Select-Object VMHost, * -ErrorAction Ignore)
    }
}

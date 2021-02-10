function Get-EsxHostNicInfo {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
        $PrimaryHost,
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 1)]
        $VmNic,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 2)]
        [switch]$AsJson
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
        $returnValue = $returnValue | Select-Object VMHost, * -ErrorAction Ignore
        if ($AsJson) {
            return ($returnValue | ConvertTo-Json -Depth 50)
        }
        else {
            return $returnValue
        }
    }
}

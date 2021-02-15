function Set-EsxHostNic {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
        $PrimaryHost,
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 1)]
        $VmNic,
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 2)]
        [ValidateSet('Up','Down')]
        $LinkState,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 3)]
        [int]$MaxTry = 3,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 4)]
        [switch]$Details = $false,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 5)]
        [switch]$AsJson = $false
    )

    begin {
        . .\Get-EsxHostNicInfo.ps1
        $returnValue = @()

        switch ($LinkState) {
            'Up' {
                $mode = 'up'
                $linkStatus = 'Up*'
            }
            'Down' {
                $mode = 'down'
                $linkStatus = 'Down*'    
            }
        }
    }

    process {
        if ($PrimaryHost.GetType().Name -ne 'VMHostImpl') {
            $PrimaryHost = Get-VMHost $PrimaryHost
        }

        foreach ($primaryHostElement in $PrimaryHost) {
            foreach ($vmNicElement in $VmNic) {
                $esxCli = Get-EsxCli -V2 -VMHost $primaryHostElement
                $arguments = $esxCli.network.nic.$mode.createArgs()
                $arguments.nicname = $vmNicElement
    
                $esxCliResult = $esxCli.network.nic.$mode.Invoke($arguments)
                Start-Sleep 10

                $value = [PSCustomObject]@{
                    VMHost = $primaryHostElement.Name
                    vmNic = $vmNicElement
                    LinkStatus = (Get-EsxHostNicInfo -PrimaryHost $primaryHostElement -VmNic $vmNicElement).LinkStatus
                    CliStatus = $esxCliResult
                }
                $returnValue += $value
            }
        }
    }

    end {
        if ($Details) {
            $returnValue = $returnValue | Sort-Object VMHost
            if ($AsJson) {
                return ($returnValue | ConvertTo-Json -Depth 50)
            }
            else {
                return $returnValue
            }
        }
        else {
            if ($false -in $returnValue.CliStatus) {
                return $false
            }
            else {
                return $true
            }
        }
    }
}

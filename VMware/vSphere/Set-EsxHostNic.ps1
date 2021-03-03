function Set-EsxHostNic {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
        $PrimaryHost,
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 1)]
        $VmNic,
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 2)]
        [ValidateSet('Up','Down')]
        $State,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 3)]
        [int]$WaitDelay = 15,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 4)]
        [switch]$Details = $false,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 5)]
        [switch]$AsJson = $false
    )

    begin {
        if (!(Get-Command Get-EsxHostNicInfo -ErrorAction Ignore)) {
            . .\Get-EsxHostNicInfo.ps1
        }

        $returnValue = @()

        switch ($State) {
            'Up' {
                $mode = 'up'
                $linkStatusMsg = 'Up*'
            }
            'Down' {
                $mode = 'down'
                $linkStatusMsg = 'Down*'
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
                Start-Sleep $WaitDelay

                $linkStatus = (Get-EsxHostNicInfo -PrimaryHost $primaryHostElement -VmNic $vmNicElement).LinkStatus

                $value = [PSCustomObject]@{
                    VMHost = $primaryHostElement.Name
                    vmNic = $vmNicElement
                    LinkStatus = $linkStatus
                    TaskStatus = ($linkStatus -like $linkStatusMsg)
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
            if ($false -in $returnValue.TaskStatus) {
                return $false
            }
            else {
                return $true
            }
        }
    }
}

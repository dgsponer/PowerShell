function Set-EsxHostNic {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
        $PrimaryHost,
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 1)]
        $VmNic,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 2)]
        [switch]$Enable,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 3)]
        [switch]$Disable,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 4)]
        [int]$MaxTry = 3,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 5)]
        [switch]$Details = $false,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 6)]
        [switch]$AsJson = $false
    )

    begin {
        . .\Get-EsxHostNicInfo.ps1
        $returnValue = @()

        if ($Enable) {
            $mode = 'up'
            $linkStatus = 'Up*'
        }

        if ($Disable) {
            $mode = 'down'
            $linkStatus = 'Down*'
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

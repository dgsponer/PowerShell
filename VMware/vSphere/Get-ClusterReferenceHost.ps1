function Get-ClusterReferenceHost {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
        $PrimaryHost,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 1)]
        [ValidateSet('First','Last')]
        $Position = 'Last', 
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 2)]
        [switch]$Details = $false,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 3)]
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
            $cluster = Get-Cluster -VMHost $primaryHostElement
            $primaryHostModel = (Get-VMHost $primaryHostElement).ExtensionData.Hardware.SystemInfo.Model
            $referenceHost = $Cluster | Get-VMHost | Where-Object {$_.ConnectionState -eq 'Connected' -AND $_ -ne $primaryHostElement -AND $_.ExtensionData.Hardware.SystemInfo.Model -eq $PrimaryHostModel} | Sort-Object Name

            if ($Position -eq 'First') {
                $referenceHost = $referenceHost | Select-Object -First 1
            }
            elseif ($Position -eq 'Last') {
                $referenceHost = $referenceHost | Select-Object -Last 1
            }

            $value = [PSCustomObject]@{
                PrimaryHost = $primaryHostElement.Name
                ReferenceHost = $referenceHost.Name
                Model = $primaryHostModel
                Cluster = $cluster.Name
            }

            $returnValue += $value
        }
    }

    end {
        if ($Details) {
            if ($AsJson) {
                return ($returnValue | ConvertTo-Json -Depth 50)
            }
            else {
                return $returnValue
            }
        }
        else {
            return $returnValue | Select-Object ReferenceHost
        }
    }
}

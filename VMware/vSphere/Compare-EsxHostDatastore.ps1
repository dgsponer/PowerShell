function Compare-EsxHostDatastore {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
        $PrimaryHost,
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 1)]
        $SecondaryHost,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 2)]
        [switch]$Details = $false
    )

    begin {
        $returnValue = @()
    }

    process {
        if ($PrimaryHost.GetType().Name -ne 'VMHostImpl') {
            $PrimaryHost = Get-VMHost $PrimaryHost
        }
        
        if ($SecondaryHost.GetType().Name -ne 'VMHostImpl') {
            $SecondaryHost = Get-VMHost $SecondaryHost
        }

        foreach ($primaryHostElement in $PrimaryHost) {
            $primaryHostElementDatastore = $primaryHostElement | Get-Datastore
            foreach ($secondaryHostElement in $SecondaryHost) {
                $secondaryHostElementDatastore = $secondaryHostElement | Get-Datastore

                $compareDatastore = Compare-Object -ReferenceObject $primaryHostElementDatastore -DifferenceObject $secondaryHostElementDatastore -IncludeEqual

                if ($compareDatastore) {
                    foreach ($compareDatastoreElement in ($compareDatastore | Sort-Object SideIndicator)) {
                        if ($compareDatastoreElement.SideIndicator -eq '==') {
                            $compareResult = 'Equal'
                        }
                        elseif ($compareDatastoreElement.SideIndicator -eq '=>') {
                            $compareResult = 'missing'
                        }
                        elseif ($compareDatastoreElement.SideIndicator -eq '<=') {
                            $compareResult = 'to much'
                        }
                        $value = [PSCustomObject]@{
                            PrimaryVMHost = $primaryHostElement.Name
                            SecondaryVMHost = $secondaryHostElement.Name
                            Datastore = $compareDatastoreElement.InputObject.Name
                            Status = $compareResult
                        }
                        $returnValue += $value        
                    }
                }
            }
        }
    }

    end {
        if ($Details) {
            if ($AsJson) {
                return ($returnValue | Sort-Object PrimaryVMHost, SecondaryVMHost | ConvertTo-Json -Depth 50)
            }
            else {
                return ($returnValue | Sort-Object PrimaryVMHost, SecondaryVMHost)
            }
        }
        
        if ('missing' -in $returnValue.Status -OR 'to much' -in $returnValue.Status) {
            return $false
        }
        else {
            return $true
        }
    }
}

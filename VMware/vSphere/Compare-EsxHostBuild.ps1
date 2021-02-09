function Compare-EsxHostBuild {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
        $PrimaryHost,
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 1)]
        $SecondaryHost,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 2)]
        [switch]$list = $false
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
            $primaryHostElementBuild = $primaryHostElement.Build
            foreach ($secondaryHostElement in $SecondaryHost) {
                $secondaryHostElementBuild = $secondaryHostElement.Build

                $equal =  ($primaryHostElementBuild -eq $secondaryHostElementBuild)

                $value = [PSCustomObject]@{
                    PrimaryVMHost = $primaryHostElement.Name
                    SecondaryVMHost = $secondaryHostElement.Name
                    PrimaryBuild = $primaryHostElementBuild
                    SecondaryBuild = $secondaryHostElementBuild 
                    Equal = $equal
                }
                $returnValue += $value
            }
        }
    }

    end {
        if ($list) {
            return ($returnValue | Sort-Object PrimaryVMHost)
        }
        
        if ($false -in $returnValue.Equal) {
            return $false
        }
        else {
            return $true
        }
    }
}

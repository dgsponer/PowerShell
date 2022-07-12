<#
.SYNOPSIS
    Short description
    Compare the mounted Datastores between two Hosts or multiple hosts objects 
.DESCRIPTION
    Long description
    File-Name:  Compare-EsxHostDatastores.ps1
    Author:     Diego Holzer
    Version:    v0.0.1
    Changelog:
                v0.0.1, 2021-02-09, Diego Holzer: First implementation.
                v0.0.2, 2022-07-12, Diego Holzer: Add examples.
.NOTES
    Copyright (c) 2021 Diego Holzer,
    licensed under the MIT License (https://mit-license.org/)
.LINK
    https://github.com/dholzer/PowerShell/vSphere
.EXAMPLE
    Compare-EsxHostDatastores -PrimaryHost 'esxi01' -SecondaryHost 'esxi02'
    Run a normal check, true mean: both host have mounted the same datastores
.EXAMPLE
    Compare-EsxHostDatastores -PrimaryHost 'esxi01' -SecondaryHost 'esxi02' -Details
    Run a check from one host to a other host and get a detailed list with the result, true mean: the same datastores are mounted
.EXAMPLE
    Compare-EsxHostDatastores -PrimaryHost 'esxi01' -SecondaryHost (Get-VMHost) -Details -AsJson
    Run a check from one host to all other hosts and get a detailed list with the result in json
#>

function Compare-EsxHostDatastore {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
        $PrimaryHost,
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 1)]
        $SecondaryHost,
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

<#
.SYNOPSIS
    Short description
    Enable the FollowHardwareMac for the next reboot.
.DESCRIPTION
    Long description
    File-Name:  Set-EsxHostFollowMac.ps1
    Author:     Diego Gsponer
    Version:    v0.0.1
    Changelog:
                v0.0.1, 2022-07-12, Diego Gsponer: First implementation.
.NOTES
    Copyright (c) 2021 Diego Holzer,
    licensed under the MIT License (https://mit-license.org/)
.LINK
    https://github.com/dgsponer/PowerShell/vSphere
.EXAMPLE
    Set-EsxHostFollowMac -VMHost 'esxi01'
    Enable take over the MacAddress from physical once the next reboot, returnvalue true or false
.EXAMPLE
    Set-EsxHostFollowMac -VMHost 'esxi01' -Details
    Enable take over the MacAddress from physical once the next reboot, returnvalue is a detailed list
.EXAMPLE
    Set-EsxHostFollowMac -VMHost 'esxi01' -Details -AsJson
    Enable take over the MacAddress from physical once the next reboot, returnvalue is a detailed list in json
#>

function Set-EsxHostFollowMac {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
        $VMHost,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 1)]
        [switch]$Details = $false,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 2)]
        [switch]$AsJson = $false
    )

    begin {
        $returnValue = @()
    }

    process {
        if ($VMHost.GetType().Name -ne 'VMHostImpl') {
            $VMHost = Get-VMHost $VMHost
        }
        foreach ($vmHostElement in $VMHost) {
            $value = $VMHost | Get-AdvancedSetting -Name 'Net.FollowHardwareMac' | Set-AdvancedSetting -Value 1 -Confirm:$false
            $returnValue += $value
        }
    }

    end {
        if ($Details) {
            $returnValue = $returnValue | Sort-Object Name
            if ($AsJson) {
                return ($returnValue | ConvertTo-Json -Depth 50)
            }
            else {
                return $returnValue
            }    
        }
        else {
            if (0 -in $returnValue.Value) {
                return $false
            }
            else {
                return $true
            }
        }
    }
}

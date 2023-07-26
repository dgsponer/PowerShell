<#
.SYNOPSIS
VMware Cloud Director VAMI API wrapper

.DESCRIPTION
Get-VcdVamiDefaultServer,
Set-VcdVamiDefaultServer,
Remove-VcdVamiDefaultServer,
Get-VcdVamiApiAuthentication,
Set-VcdVamiApiAuthentication,
Remove-VcdVamiApiAuthentication,
Get-VcdVamiApiHeader,
Get-VcdVamiApiCall,
Get-VcdVamiServices,
Get-VcdVamiBackups,
Get-VcdVamiFips,
Get-VcdVamiisPrimary,
Get-VcdVamiMount,
Get-VcdVamiNodes,
Get-VcdVamiStorage,
Get-VcdVamiTasks,
Get-VcdVamiVersion

.PARAMETER xxx
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>

# /services
function Get-VcdVamiServices {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 0)]
        $vcdVamiServer = $Global:VcdVamiDefaultServer    
    )
    
    begin {
        $endpoint = 'services'
    }

    process {
        try {
            $result = Get-VcdVamiApiCall $vcdVamiServer $endpoint
        }
        catch {
            Write-Host $_.Exception.Message
        }
    }

    end {
        return $result
    } 
}

# /backups
function Get-VcdVamiBackups {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 0)]
        $vcdVamiServer = $Global:VcdVamiDefaultServer    
    )
    
    begin {
        $endpoint = 'backups'
    }

    process {
        try {
            $result = Get-VcdVamiApiCall $vcdVamiServer $endpoint
        }
        catch {
            Write-Host $_.Exception.Message
        }
    }

    end {
        return $result
    } 
}

# /fips
function Get-VcdVamiFips {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 0)]
        $vcdVamiServer = $Global:VcdVamiDefaultServer    
    )
    
    begin {
        $endpoint = 'fips'
    }

    process {
        try {
            $result = Get-VcdVamiApiCall $vcdVamiServer $endpoint
        }
        catch {
            Write-Host $_.Exception.Message
        }
    }

    end {
        return $result
    } 
}

# /isPrimary
function Get-VcdVamiisPrimary {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 0)]
        $vcdVamiServer = $Global:VcdVamiDefaultServer    
    )
    
    begin {
        $endpoint = 'isPrimary'
    }

    process {
        try {
            $result = Get-VcdVamiApiCall $vcdVamiServer $endpoint
        }
        catch {
            Write-Host $_.Exception.Message
        }
    }

    end {
        return $result
    } 
}

# /mount
function Get-VcdVamiMount {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 0)]
        $vcdVamiServer = $Global:VcdVamiDefaultServer    
    )
    
    begin {
        $endpoint = 'mount'
    }

    process {
        try {
            $result = Get-VcdVamiApiCall $vcdVamiServer $endpoint
        }
        catch {
            Write-Host $_.Exception.Message
        }
    }

    end {
        return $result
    } 
}

# /nodes
function Get-VcdVamiNodes {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 0)]
        $vcdVamiServer = $Global:VcdVamiDefaultServer
    )
    
    begin {
        $endpoint = 'nodes'
    }

    process {
        try {
            $result = Get-VcdVamiApiCall $vcdVamiServer $endpoint
        }
        catch {
            Write-Host $_.Exception.Message
        }
    }

    end {
        return $result
    } 
}

# /storage
function Get-VcdVamiStorage {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 0)]
        $vcdVamiServer = $Global:VcdVamiDefaultServer    
    )
    
    begin {
        $endpoint = 'storage'
    }

    process {
        try {
            $result = Get-VcdVamiApiCall $vcdVamiServer $endpoint
        }
        catch {
            Write-Host $_.Exception.Message
        }
    }

    end {
        return $result
    } 
}

# /tasks
function Get-VcdVamiTasks {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 0)]
        $vcdVamiServer = $Global:VcdVamiDefaultServer    
    )
    
    begin {
        $endpoint = 'tasks'
    }

    process {
        try {
            $result = Get-VcdVamiApiCall $vcdVamiServer $endpoint
        }
        catch {
            Write-Host $_.Exception.Message
        }
    }

    end {
        return $result
    } 
}

# /version
function Get-VcdVamiVersion {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 0)]
        $vcdVamiServer = $Global:VcdVamiDefaultServer    
    )
    
    begin {
        $endpoint = 'version'
    }

    process {
        try {
            $result = Get-VcdApiCall $vcdVamiServer $endpoint
        }
        catch {
            Write-Host $_.Exception.Message
        }
    }

    end {
        return $result
    } 
}

function Get-VcdVamiApiAuthentication {
    [CmdletBinding()]
    param (
    )

    begin {
    }
    
    process {
        try {
            $Global:VcdVamiApiAuthentication
        }
        catch {
            Write-Host $_.Exception.Message
        }
    }

    end {
    }
}

function Get-VcdVamiDefaultServer {
    [CmdletBinding()]
    param (
    )

    begin {
    }
    
    process {
        $Global:VcdVamiDefaultServer
    }

    end {
    }
}

function Set-VcdVamiDefaultServer {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
        $vcdVamiDefaultServer
    )

    begin {
    }
    
    process {
    }

    end {
        $global:VcdVamiDefaultServer = $vcdVamiDefaultServer
    }
}

function Remove-VcdVamiDefaultServer {
    [CmdletBinding()]
    param (
    )

    begin {
    }
    
    process {
        Remove-Variable VcdVamiDefaultServer -Scope Global
    }

    end {
    }
}

function Set-VcdVamiApiAuthentication {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
        [PSCredential] $vcdVamiApiAuthentication
    )

    begin {
    }
    
    process {
    }

    end {
        $global:VcdVamiApiAuthentication = $vcdVamiApiAuthentication
    }
}

function Remove-VcdVamiApiAuthentication {
    [CmdletBinding()]
    param (
    )

    begin {
    }
    
    process {
        try {
            Remove-Variable VcdVamiApiAuthentication -Scope Global
        }
         catch {
             Write-Host $_.Exception.Message
         }
    }

    end {
    }
}

function Get-VcdVamiApiHeader {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 0)]
        [pscredential] $vcdVamiApiAuthentication = $Global:VcdVamiApiAuthentication
    )

    begin {
        if ($vcdVamiApiAuthentication -eq $emtpy) {
            $vcdVamiApiAuthentication = Get-Credential
        }

        $vcdVamiHeader = @{}
    }
    
    process {
        try {
            $vcdVamiApiAuthorization = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($vcdVamiApiAuthentication.UserName+":"+($vcdVamiApiAuthentication.GetNetworkCredential().Password)))

            $vcdVamiHeader = @{
                'Authorization' = 'Basic ' + $vcdVamiApiAuthorization
                'Accept' = 'application/json'
            }
        }
        catch {
            Write-Host $_.Exception.Message
        }
    }

    end {
        return $vcdVamiHeader
    }
}

function Get-VcdVamiApiCall {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
        $vcdVamiServer,
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 1)]
        $endpoint
    )

    begin {
    }
    
    process {
        try {
            $result = Invoke-WebRequest -SkipCertificateCheck -Headers (Get-VcdVamiApiHeader) -Method Get -Uri ('https://'+$vcdVamiServer+':5480/api/1.0.0/'+$endpoint) | ConvertFrom-Json
        }
        catch {
            Write-Host $_.Exception.Message
        }
    }

    end {
        return $result
    }
}

Export-ModuleMember -Function Get-VcdVamiDefaultServer, Set-VcdVamiDefaultServer, Remove-VcdVamiDefaultServer, Get-VcdVamiApiAuthentication, Set-VcdVamiApiAuthentication, Remove-VcdVamiApiAuthentication, Get-VcdVamiApiHeader, Get-VcdVamiApiCall, Get-VcdVamiServices, Get-VcdVamiBackups, Get-VcdVamiFips, Get-VcdVamiisPrimary, Get-VcdVamiMount, Get-VcdVamiNodes, Get-VcdVamiStorage, Get-VcdVamiTasks, Get-VcdVamiVersion

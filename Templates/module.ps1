function FUNCTIONNAME {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
        $PARAM,
    )

    begin {

    }

    process {
        do {
            try {
                # DO SOMETHING
                $i++
            }
            catch {
                Write-Host $_.Exception.Message
                $i++
            }
        } while (!$ANYTHING -AND $i -lt 3)
    }

    end {
    
    }
}

Export-ModuleMember -Function Function

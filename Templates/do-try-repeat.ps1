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

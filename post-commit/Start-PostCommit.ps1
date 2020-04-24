Function Get-Tracked
{
    $currentLocation = Get-Location
    Set-Location -Path $devPath
    $files = git ls-tree -r master --name-status
    Set-Location $currentLocation
    
    return $files
}

Function Update-Prod
{
    param(
        [Parameter()]
        [switch]$DoNotFlushPath
    )

    if (!(Test-Path -Path $prodPath))
    {
        try
        {
            # creating prodPath
            New-Item -Path $prodPath -ItemType Directory -Force -Confirm:$False -ErrorAction Stop | Out-Null

            # setting the flag DoNotFlushPath
            $DoNotFlushPath = $True
        }
        catch
        {
            Write-Host "Failed to create '$prodPath' : $_" -ForegroundColor Red
            exit 1
        }
    }

    if (!$DoNotFlushPath)
    {
        try
        {
            # flushing out everything from prodPath
            Get-ChildItem -Path $prodPath -Recurse | Remove-Item -Recurse -Force -Confirm:$False -ErrorAction Stop
            Start-Sleep -Seconds 1
        }
        catch
        {
            Write-Host "Failed to flush '$devPath' : $_" -ForegroundColor Red
            exit 1
        }
    }

    # copy tracked folders and files from devPath to prodPath
    $tracked | % {
        Write-Host "Copying '$_' : " -ForegroundColor Cyan -NoNewline
        try
        {
            $subDirs = [System.IO.Path]::GetDirectoryName($_)
            if (![string]::IsNullOrEmpty($subDirs))
            {
                New-Item -Path "$prodPath\$subDirs" -ItemType Directory -Force -Confirm:$False | Out-Null
            }
    
            if ($_.Contains("/")) { $destPath = "$prodPath\$($_.Replace("/", "\"))" }
            else { $destPath = $prodPath }
            Copy-Item -Path "$devPath\$($_.Replace("/", "\"))" -Destination $destPath -Force -Recurse -Confirm:$False -ErrorAction Stop
            Write-Host "OK" -ForegroundColor Green
        }
        catch
        {
            Write-Host "Failed: $_" -ForegroundColor Red
        }
    }
}

# paths used in repo
$devPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "\..\..\src"
$prodPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "\..\..\prod"

Write-Host "=== git post-commit hook ==="
$tracked = Get-Tracked
Update-Prod
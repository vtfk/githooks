$devPathName = "src"
$prodPathName = "prod"
$hookName = "post-commit"
$flushProdOnHookRun = $True
$defaultBranch = "main" # for new repositories, this is probably "main", for older repositories, this is probably "master". Find it by running "git branch"
$onlyFilesFromDefaultBranch = $True # if set to True, $prodPathName will always only have files/content from defaultBranch. If set to False, $prodPathName will always have files/content current to the last commit (from which ever branch the commit were performed!)

Function Get-Tracked
{
    $currentLocation = Get-Location
    Set-Location -Path $devPath
    $files = git ls-tree -r $defaultBranch --name-status
    Set-Location $currentLocation
    
    return $files
}

Function Update-Prod
{
    if (!(Test-Path -Path $prodPath))
    {
        try
        {
            # creating prodPath
            New-Item -Path $prodPath -ItemType Directory -Force -Confirm:$False -ErrorAction Stop | Out-Null

            # setting the flag DoNotFlushPath
            $flushProdOnHookRun = $False
        }
        catch
        {
            Write-Host "Failed to create '$prodPath' : $_" -ForegroundColor Red
            exit 1
        }
    }

    if ($flushProdOnHookRun)
    {
        try
        {
            # flushing out everything from prodPath
            Get-ChildItem -Path $prodPath -Recurse | Remove-Item -Recurse -Force -Confirm:$False -ErrorAction Stop
            Start-Sleep -Seconds 1
        }
        catch
        {
            Write-Host "Failed to flush '$prodPath' : $_" -ForegroundColor Red
            exit 1
        }
    }

    # copy tracked folders and files from devPath to prodPath
    $tracked | % {
        if (!$onlyFilesFromDefaultBranch) { Write-Host "Copying '$_' : " -ForegroundColor Cyan -NoNewline }
        else { Write-Host "Copying '$($defaultBranch):$($_)' : " -ForegroundColor Cyan -NoNewline }

        try
        {
            $subDirs = [System.IO.Path]::GetDirectoryName($_)
            $fileName = [System.IO.Path]::GetFileName($_)
            if (![string]::IsNullOrEmpty($subDirs))
            {
                New-Item -Path "$prodPath\$subDirs" -ItemType Directory -Force -Confirm:$False | Out-Null
            }
    
            if ($_.Contains("/")) { $destPath = "$prodPath\$($_.Replace("/", "\"))" }
            else { $destPath = $prodPath }

            if (!$onlyFilesFromDefaultBranch) { Copy-Item -Path "$devPath\$($_.Replace("/", "\"))" -Destination $destPath -Force -Recurse -Confirm:$False -ErrorAction Stop }
            else {
                if ($_.Contains("/")) { git show "$($defaultBranch):$devPathName/$_" > "$destPath" }
                else { git show "$($defaultBranch):$devPathName/$_" > "$destPath\$fileName" }
            }
            Write-Host "OK" -ForegroundColor Green
        }
        catch
        {
            #Write-Host "Failed: $_" -ForegroundColor Red
            Write-Error -Exception $_ -ErrorAction Continue
        }
    }
}

# paths used in repo
$devPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "\..\..\$devPathName"
$prodPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "\..\..\$prodPathName"

Write-Host "=== git $hookName hook ==="
$tracked = Get-Tracked
Update-Prod

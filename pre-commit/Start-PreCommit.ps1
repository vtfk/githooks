[CmdletBinding()]
param()

Function Invoke-PesterTest
{
    # check if testPath exists
    if (!(Test-Path -Path $testPath))
    {
        Write-Host "Path '$testPath' does not exist. commit allowed, though you should implement some tests ;)" -ForegroundColor Yellow
        exit 0
    }
    elseif ((Get-ChildItem -Path $testPath -Filter "*.Tests.ps1").Count -le 0)
    {
        # check if testPath contains any Pester test files
        Write-Host "Path '$testPath' does not contain any Pester test files. commit allowed, though you should implement some tests ;)" -ForegroundColor Yellow
        exit 0
    }

    # invoke all Pester test files
    Get-ChildItem -Path $testPath -Filter "*.Tests.ps1" | % {
        $result = Invoke-Pester -Script $_.FullName -PassThru
        if ($result.FailedCount -gt 0)
        {
            Write-Error "Pester test '$($_.Name)' failed. commit NOT allowed!"
            exit 1
        }
    }
}

# paths used in repo
$testPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "\..\..\Tests"

Write-Host "=== git pre-commit hook ==="
Invoke-PesterTest
# untrack-tfstate.ps1
# Usage: run this script from PowerShell in the repository root.
# It will try to remove tracked Terraform state files from Git and commit the change.

Set-StrictMode -Version Latest

try {
    $repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
    if (-not $repoRoot) { $repoRoot = Get-Location }
    Push-Location $repoRoot

    Write-Output "Checking for git..."
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Output "Git not found in PATH. Please install Git for Windows and re-run this script: https://git-scm.com/download/win"
        Pop-Location
        exit 1
    }

    Write-Output "Removing Terraform state files from Git index (if tracked)..."
    git rm --cached td5/scripts/tofu/live/ci-cd-permissions/terraform.tfstate 2>$null
    git rm --cached td5/scripts/tofu/live/ci-cd-permissions/terraform.tfstate.backup 2>$null
    git rm -r --cached td5/scripts/tofu/live/ci-cd-permissions/.terraform 2>$null

    git add .gitignore

    $commitMsg = "chore: ignore Terraform state files and remove them from repo"
    git commit -m $commitMsg 2>$null

    Write-Output "Done. Run 'git status' to review changes, then 'git push' to push the commit." 
}
catch {
    Write-Error "An error occurred: $_"
}
finally {
    Pop-Location
}

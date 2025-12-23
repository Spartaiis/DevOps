<#
run-infra-tests-locally.ps1

Script helper to run the OpenTofu tests locally.
Usage: run from repository root.
#>

param(
  [string]$WorkingDir = "td5/scripts/tofu/live/lambda-sample",
  [string]$TfVarNamePrefix = "lambda-sample-",
  [switch]$UseProfile
)

Set-StrictMode -Version Latest

Write-Output "This script will run: tofu init && tofu test in $WorkingDir"

# Check for tofu (OpenTofu) executable
if (-not (Get-Command tofu -ErrorAction SilentlyContinue)) {
  Write-Error "'tofu' (OpenTofu) not found in PATH. Install from https://opentofu.org/ or your package manager."
  exit 1
}

Push-Location $PSScriptRoot

if ($UseProfile) {
  Write-Output "Using AWS profile from env: AWS_PROFILE (if set). Ensure profile has necessary permissions."
} else {
  Write-Output "Make sure AWS credentials are available via env vars or default profile."
}

$uniqueName = "$TfVarNamePrefix$([guid]::NewGuid().ToString())"

Set-Location $WorkingDir

Write-Output "Running: tofu init -backend=false -input=false"
tofu init -backend=false -input=false

Write-Output "Running: tofu test -verbose with TF_VAR_name=$uniqueName"
$env:TF_VAR_name = $uniqueName

try {
  tofu test -verbose
  Write-Output "tofu test finished"
} catch {
  Write-Error "tofu test failed: $_"
}

Pop-Location

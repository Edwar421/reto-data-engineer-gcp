#Requires -Version 5.1
<#
.SYNOPSIS
  Bootstrap local: bucket de estado Terraform + primer apply (WIF, BQ, GCS).
.EXAMPLE
  .\scripts\bootstrap.ps1 -ProjectId "mi-proyecto-gcp"
#>
param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectId,

  [string]$Environment = "dev",
  [string]$Region = "us-central1",
  [string]$BqLocation = "US",
  [string]$DatasetId = "bdb_dwh",
  [string]$GithubRepository = ""
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $RepoRoot

function Assert-Command($Name) {
  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    throw "No se encontro '$Name' en PATH. Instala las herramientas listadas en el README."
  }
}

Assert-Command terraform
Assert-Command gcloud
Assert-Command git

if (-not $GithubRepository) {
  $remote = git remote get-url origin 2>$null
  if ($remote -match "github\.com[:/](.+?)(\.git)?$") {
    $GithubRepository = $Matches[1] -replace "\.git$", ""
  } else {
    $GithubRepository = "Edwar421/reto-data-engineer-gcp"
  }
}

Write-Host "Proyecto GCP : $ProjectId"
Write-Host "Ambiente     : $Environment"
Write-Host "Repo GitHub  : $GithubRepository"
Write-Host ""

gcloud config set project $ProjectId | Out-Null
$adc = gcloud auth application-default print-access-token 2>$null
if (-not $adc) {
  Write-Host "Iniciando Application Default Credentials..."
  gcloud auth application-default login
}

Write-Host "==> Bootstrap: bucket de estado Terraform"
terraform -chdir="terraform/bootstrap" init -input=false
terraform -chdir="terraform/bootstrap" apply -input=false -auto-approve `
  -var="project_id=$ProjectId" `
  -var="region=$Region"

$stateBucket = terraform -chdir="terraform/bootstrap" output -raw state_bucket
Write-Host "State bucket : $stateBucket"

$backendPath = Join-Path $RepoRoot "terraform\backend.hcl"
$tfvarsPath = Join-Path $RepoRoot "terraform\terraform.tfvars"

@"
bucket = "$stateBucket"
prefix = "dwh/$Environment"
"@ | Set-Content -Encoding ascii $backendPath

@"
project_id        = "$ProjectId"
region            = "$Region"
bq_location       = "$BqLocation"
dataset_id        = "$DatasetId"
environment       = "$Environment"
github_repository = "$GithubRepository"
github_branch     = "main"
"@ | Set-Content -Encoding ascii $tfvarsPath

Write-Host "==> Terraform principal (WIF, BigQuery, GCS, IAM)"
terraform -chdir="terraform" init -input=false -backend-config="backend.hcl" -reconfigure
terraform -chdir="terraform" apply -input=false -auto-approve

Write-Host ""
Write-Host "Listo. Configura estas variables en GitHub:"
Write-Host "  Settings > Secrets and variables > Actions > Variables"
Write-Host ""
terraform -chdir="terraform" output github_actions_vars
Write-Host ""
Write-Host "TF_STATE_BUCKET = $stateBucket"
Write-Host ""
Write-Host "Luego sube el CSV:"
$rawBucket = terraform -chdir="terraform" output -raw raw_bucket
Write-Host "  gcloud storage cp datos_transacciones.csv gs://$rawBucket/raw/datos_transacciones.csv"

# Builds the signed Google Play App Bundle and verifies which key signed it.
# Output is mirrored to app\diagnostics\play-bundle.log.
$ErrorActionPreference = 'Continue'
$app = Split-Path -Parent $PSScriptRoot
Set-Location $app
$log = Join-Path $app 'diagnostics\play-bundle.log'
New-Item -ItemType Directory -Force -Path (Split-Path $log) | Out-Null
Start-Transcript -Path $log -Force | Out-Null

if (-not (Test-Path (Join-Path $app 'android\key.properties'))) {
    Write-Host 'Missing android\key.properties - run 3_create_upload_key.cmd first.'
    Stop-Transcript | Out-Null; exit 1
}

Write-Host '===== flutter build appbundle --release ====='
flutter build appbundle --release 2>&1 | Out-Host
$buildCode = $LASTEXITCODE
Write-Host "===== RESULT: build -> exit $buildCode ====="

$aab = Join-Path $app 'build\app\outputs\bundle\release\app-release.aab'
if ($buildCode -eq 0 -and (Test-Path $aab)) {
    $size = [math]::Round((Get-Item $aab).Length / 1MB, 1)
    Write-Host "AAB: $aab ($size MB)"
    $keytool = (Get-Command keytool -ErrorAction SilentlyContinue).Source
    if (-not $keytool) { $keytool = 'C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe' }
    Write-Host '===== signer certificate ====='
    & $keytool -printcert -jarfile $aab 2>&1 | Out-Host
    $dest = Join-Path ([Environment]::GetFolderPath('Desktop')) 'BEZY-1.0.0.aab'
    Copy-Item $aab $dest -Force
    Write-Host "Copied to Desktop: $dest"
}
Stop-Transcript | Out-Null

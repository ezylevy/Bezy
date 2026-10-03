# Runs the BEZY pre-release checks and writes everything to
# app\diagnostics\release-checks.log so the results can be reviewed later.
$ErrorActionPreference = 'Continue'
$app = Split-Path -Parent $PSScriptRoot
Set-Location $app
$log = Join-Path $app 'diagnostics\release-checks.log'
New-Item -ItemType Directory -Force -Path (Split-Path $log) | Out-Null
Start-Transcript -Path $log -Force | Out-Null

function Step($name, [scriptblock]$cmd) {
    Write-Host "`n===== $name ====="
    & $cmd 2>&1 | Out-Host
    $code = $LASTEXITCODE
    Write-Host "===== RESULT: $name -> exit $code ====="
    return $code
}

$results = [ordered]@{}
$results['flutter --version'] = Step 'flutter --version' { flutter --version }
$results['pub get']           = Step 'pub get' { flutter pub get }
$results['analyze']           = Step 'analyze' { flutter analyze --no-pub }
$results['test']              = Step 'test' { flutter test --no-pub }
$results['route generator']   = Step 'route generator' { flutter test --no-pub tool/generate_campaign_routes_test.dart }
$results['build apk']         = Step 'build apk --release' { flutter build apk --release }

$apk = Join-Path $app 'build\app\outputs\flutter-apk\app-release.apk'
if (Test-Path $apk) {
    Write-Host "`n===== APK ====="
    $size = [math]::Round((Get-Item $apk).Length / 1MB, 1)
    Write-Host "app-release.apk size: $size MB"
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($apk)
    $zip.Entries | Where-Object { $_.FullName -like 'lib/*/libflutter.so' } |
        ForEach-Object { Write-Host "ABI: $($_.FullName)" }
    $zip.Dispose()
}

Write-Host "`n===== SUMMARY ====="
$results.GetEnumerator() | ForEach-Object { Write-Host ("{0,-20} exit {1}" -f $_.Key, $_.Value) }
Stop-Transcript | Out-Null
Write-Host "`nLog saved to $log"

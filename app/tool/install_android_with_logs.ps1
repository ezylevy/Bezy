param(
    [string]$Package = "com.ezylevy.bezy",
    [string]$LegacyPackage = "com.ezylevy.bezy.test",
    [string]$Apk = "dist/BEZY-Test.apk"
)

$ErrorActionPreference = "Stop"
$appRoot = Split-Path -Parent $PSScriptRoot
$apkPath = Join-Path $appRoot $Apk
$adb = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"
$diagnosticsDirectory = Join-Path $appRoot "diagnostics"
$logPath = Join-Path $diagnosticsDirectory "android-launch.log"

if (-not (Test-Path -LiteralPath $adb)) {
    throw "adb was not found at $adb"
}
if (-not (Test-Path -LiteralPath $apkPath)) {
    throw "APK was not found at $apkPath"
}

Write-Host "Waiting for one authorized Android device..."
Write-Host "Enable Developer options and USB debugging, connect USB, and approve the computer on the phone."
while ($true) {
    $deviceLines = @(& $adb devices | Select-String "\s(device|unauthorized)$")
    $authorized = @($deviceLines | Select-String "\sdevice$")
    $unauthorized = @($deviceLines | Select-String "\sunauthorized$")
    if ($authorized.Count -eq 1) { break }
    if ($unauthorized.Count -gt 0) {
        Write-Host "Phone detected. Approve the USB debugging prompt on the phone..."
    }
    elseif ($authorized.Count -gt 1) {
        throw "More than one Android device is connected. Leave only the target phone connected."
    }
    Start-Sleep -Seconds 2
}

Write-Host "Installing $apkPath while preserving app data..."
$installOutput = & $adb install -r $apkPath 2>&1
$installOutput | Write-Host
if ($LASTEXITCODE -ne 0) {
    $signatureMismatch = $installOutput -match "UPDATE_INCOMPATIBLE"
    if (-not $signatureMismatch) {
        throw "APK installation failed."
    }

    Write-Warning "The installed app has a different signature. Reinstalling requires deleting its local progress."
    $answer = Read-Host "Type DELETE to uninstall the existing BEZY and continue"
    if ($answer -cne "DELETE") {
        throw "Installation cancelled without deleting app data."
    }
    & $adb uninstall $Package | Write-Host
    & $adb uninstall $LegacyPackage | Write-Host
    & $adb install $apkPath | Write-Host
    if ($LASTEXITCODE -ne 0) { throw "Clean APK installation failed." }
}

New-Item -ItemType Directory -Path $diagnosticsDirectory -Force | Out-Null
& $adb logcat -c
& $adb shell am force-stop $Package
Write-Host "Launching BEZY and monitoring the first 15 seconds..."
& $adb shell am start -W -n "$Package/.MainActivity" | Write-Host
Start-Sleep -Seconds 15

& $adb logcat -d -v time | Out-File -LiteralPath $logPath -Encoding utf8
$pidValue = (& $adb shell pidof $Package).Trim()
if ($pidValue) {
    Write-Host "BEZY is still running (PID $pidValue). Full launch log: $logPath"
}
else {
    Write-Warning "BEZY stopped after launch. Relevant crash lines follow:"
    Get-Content -LiteralPath $logPath | Select-String -Pattern @(
        "FATAL EXCEPTION",
        "AndroidRuntime",
        "Process: $Package",
        "flutter",
        "MainActivity",
        "Unable to start activity"
    ) | Write-Host
    Write-Host "Full log: $logPath"
}

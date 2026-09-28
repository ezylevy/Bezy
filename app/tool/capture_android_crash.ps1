param(
    [string]$Package = "com.ezylevy.bezy"
)

$ErrorActionPreference = "Stop"
$adb = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"
if (-not (Test-Path -LiteralPath $adb)) {
    throw "adb was not found at $adb"
}

$devices = & $adb devices
$connected = @($devices | Select-String "\sdevice$")
if ($connected.Count -ne 1) {
    throw "Connect exactly one Android device with USB debugging enabled and accept its authorization prompt."
}

& $adb logcat -c
& $adb shell am force-stop $Package
& $adb shell monkey -p $Package -c android.intent.category.LAUNCHER 1 | Out-Null
Start-Sleep -Seconds 8

Write-Host "Relevant launch/crash log for $Package"
& $adb logcat -d -v time | Select-String -Pattern @(
    "FATAL EXCEPTION",
    "AndroidRuntime",
    "Process: $Package",
    "flutter",
    "MainActivity",
    "Unable to start activity"
)

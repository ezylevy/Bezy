param(
    [string]$Alias = "upload"
)

$ErrorActionPreference = "Stop"
$appRoot = Split-Path -Parent $PSScriptRoot
$androidRoot = Join-Path $appRoot "android"
$keystorePath = Join-Path $androidRoot "bezy-upload-keystore.jks"
$propertiesPath = Join-Path $androidRoot "key.properties"

if ((Test-Path -LiteralPath $keystorePath) -or (Test-Path -LiteralPath $propertiesPath)) {
    throw "Upload-key files already exist. Back them up and remove them explicitly before creating a replacement."
}

$keytool = Get-Command keytool -ErrorAction SilentlyContinue
if ($keytool) {
    $keytoolPath = $keytool.Source
}
else {
    $keytoolPath = "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
}
if (-not (Test-Path -LiteralPath $keytoolPath)) {
    throw "keytool was not found. Install Android Studio or a JDK first."
}

function ConvertTo-PlainText([Security.SecureString]$SecureValue) {
    $pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureValue)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($pointer)
    }
    finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($pointer)
    }
}

$first = Read-Host "Choose a strong upload-key password (store it in your password manager)" -AsSecureString
$second = Read-Host "Repeat the password" -AsSecureString
$password = ConvertTo-PlainText $first
$confirmation = ConvertTo-PlainText $second

try {
    if ($password.Length -lt 12) {
        throw "Use at least 12 characters. A password-manager generated password is recommended."
    }
    if ($password -cne $confirmation) {
        throw "The passwords do not match."
    }

    $env:BEZY_UPLOAD_STORE_PASSWORD = $password
    & $keytoolPath `
        -genkeypair `
        -v `
        -keystore $keystorePath `
        -storetype JKS `
        -storepass:env BEZY_UPLOAD_STORE_PASSWORD `
        -keypass:env BEZY_UPLOAD_STORE_PASSWORD `
        -alias $Alias `
        -keyalg RSA `
        -keysize 4096 `
        -validity 10000 `
        -dname "CN=BEZY Upload, O=BEZY, C=IL"
    if ($LASTEXITCODE -ne 0) {
        throw "keytool failed with exit code $LASTEXITCODE"
    }

    $gradleStorePath = $keystorePath.Replace("\", "/")
    [IO.File]::WriteAllLines($propertiesPath, @(
        "storePassword=$password"
        "keyPassword=$password"
        "keyAlias=$Alias"
        "storeFile=$gradleStorePath"
    ))

    Write-Host "Upload key created successfully."
    Write-Host "Keystore: $keystorePath"
    Write-Host "Gradle config: $propertiesPath"
    Write-Warning "Back up both files securely. Losing the upload key can block future updates until Google approves a key reset."
}
finally {
    Remove-Item Env:BEZY_UPLOAD_STORE_PASSWORD -ErrorAction SilentlyContinue
    $password = $null
    $confirmation = $null
}

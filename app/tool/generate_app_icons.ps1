param(
    [string]$Source = "assets/logos/app_icon_master.png"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$appRoot = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $appRoot $Source
if (-not (Test-Path -LiteralPath $sourcePath)) {
    throw "Icon source not found: $sourcePath"
}

function Write-Icon {
    param(
        [System.Drawing.Image]$Image,
        [int]$Size,
        [string]$RelativePath
    )

    $outputPath = Join-Path $appRoot $RelativePath
    $outputDirectory = Split-Path -Parent $outputPath
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null

    # 24-bit RGB deliberately removes alpha. App Store icons must be opaque.
    $bitmap = New-Object System.Drawing.Bitmap(
        $Size,
        $Size,
        [System.Drawing.Imaging.PixelFormat]::Format24bppRgb
    )
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $graphics.DrawImage($Image, 0, 0, $Size, $Size)
        $bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

$sourceImage = [System.Drawing.Image]::FromFile($sourcePath)
try {
    $icons = @{
        "android/app/src/main/res/mipmap-mdpi/ic_launcher.png" = 48
        "android/app/src/main/res/mipmap-hdpi/ic_launcher.png" = 72
        "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png" = 96
        "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png" = 144
        "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" = 192
        "assets/logos/play_store_icon.png" = 512
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png" = 20
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png" = 40
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png" = 60
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png" = 29
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png" = 58
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png" = 87
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png" = 40
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png" = 80
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png" = 120
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png" = 120
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png" = 180
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png" = 76
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png" = 152
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png" = 167
        "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png" = 1024
    }

    foreach ($entry in $icons.GetEnumerator()) {
        Write-Icon -Image $sourceImage -Size $entry.Value -RelativePath $entry.Key
    }
}
finally {
    $sourceImage.Dispose()
}

Write-Host "Generated Android, iOS, and Play Store icons from $Source"

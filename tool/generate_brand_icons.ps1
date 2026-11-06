# Derive platform bitmaps from the approved symbol without recoloring its pixels.
# Run from the repository root: powershell -File tool/generate_brand_icons.ps1
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$workspace = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$symbol = [System.Drawing.Image]::FromFile((Join-Path $workspace 'assets/brand/logo/steady-symbol-gradient.png'))
function Save-SteadyIcon([string]$relativePath, [int]$size, [double]$fraction = 0.65, [bool]$transparent = $false) {
    $target = [System.IO.Path]::GetFullPath((Join-Path $workspace $relativePath))
    if (-not $target.StartsWith($workspace + [System.IO.Path]::DirectorySeparatorChar)) { throw 'Icon target outside workspace' }
    [System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($target)) | Out-Null
    $bitmap = [System.Drawing.Bitmap]::new($size, $size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $background = if ($transparent) { [System.Drawing.Color]::Transparent } else { [System.Drawing.Color]::White }
        $graphics.Clear($background)
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $height = $size * $fraction
        $width = $height * $symbol.Width / $symbol.Height
        $rect = [System.Drawing.RectangleF]::new(($size - $width) / 2, ($size - $height) / 2, $width, $height)
        $graphics.DrawImage($symbol, $rect)
        $bitmap.Save($target, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally { $graphics.Dispose(); $bitmap.Dispose() }
}
try {
    $densities = @{'mdpi'=48; 'hdpi'=72; 'xhdpi'=96; 'xxhdpi'=144; 'xxxhdpi'=192}
    foreach ($density in $densities.Keys) {
        Save-SteadyIcon "android/app/src/main/res/mipmap-$density/ic_launcher.png" $densities[$density]
        # Adaptive foreground: the complete symbol stays inside Android's 66dp safe zone.
        Save-SteadyIcon "android/app/src/main/res/mipmap-$density/ic_launcher_foreground.png" ([int]($densities[$density] * 2.25)) 0.60 $true
    }
    $catalog = Get-Content -LiteralPath (Join-Path $workspace 'ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json') -Raw | ConvertFrom-Json
    foreach ($item in $catalog.images) {
        $size = [double]($item.size.Split('x')[0]) * [double]($item.scale.TrimEnd('x'))
        Save-SteadyIcon "ios/Runner/Assets.xcassets/AppIcon.appiconset/$($item.filename)" ([int]$size)
    }
    foreach ($size in @(192, 512)) {
        Save-SteadyIcon "web/icons/Icon-$size.png" $size
        Save-SteadyIcon "web/icons/Icon-maskable-$size.png" $size 0.60
    }
    Save-SteadyIcon 'web/favicon.png' 32
} finally { $symbol.Dispose() }

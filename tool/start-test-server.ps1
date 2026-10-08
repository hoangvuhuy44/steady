param(
    [ValidateRange(1024, 65535)][int]$Port = 3000,
    [ValidateSet('0.0.0.0', '127.0.0.1')][string]$BindAddress = '0.0.0.0',
    [switch]$SkipBuild
)
$ErrorActionPreference = 'Stop'
$steadyRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Push-Location $steadyRoot
try {
    if (-not $SkipBuild) {
        & flutter build web --release
        if ($LASTEXITCODE -ne 0) { throw 'Flutter web build failed.' }
    }
    $steadyWebRoot = Join-Path $steadyRoot 'build/web'
    if (-not (Test-Path -LiteralPath (Join-Path $steadyWebRoot 'index.html'))) {
        throw 'Missing web build. Run without -SkipBuild first.'
    }
    if (Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue) {
        throw "Port $Port is already in use. Stop its existing server or choose -Port 3001."
    }
    $steadyDart = (Get-Command dart -ErrorAction Stop).Source
    $steadyScript = Join-Path $PSScriptRoot 'serve_web.dart'
    $steadyCommand = '""{0}" run "{1}" --root="{2}" --host={3} --port={4}"' -f $steadyDart, $steadyScript, $steadyWebRoot, $BindAddress, $Port
    $steadyProcess = Start-Process -FilePath $env:ComSpec -ArgumentList @('/d', '/s', '/c', $steadyCommand) -WorkingDirectory $steadyRoot -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $steadyRoot 'build/test-server.stdout.log') -RedirectStandardError (Join-Path $steadyRoot 'build/test-server.stderr.log')
    $steadyReady = $false
    for ($steadyAttempt = 0; $steadyAttempt -lt 30; $steadyAttempt++) {
        if ($steadyProcess.HasExited) { throw 'Server exited. Check build/test-server.stderr.log.' }
        try {
            $steadyStatus = Invoke-WebRequest -Uri "http://127.0.0.1:$Port/" -UseBasicParsing -TimeoutSec 1
            if ($steadyStatus.StatusCode -eq 200) { $steadyReady = $true; break }
        } catch { Start-Sleep -Milliseconds 500 }
    }
    if (-not $steadyReady) { throw 'Server is not ready. Check build/test-server.stderr.log.' }
    Write-Output "Steady is ready: http://127.0.0.1:$Port/"
    if ($BindAddress -eq '0.0.0.0') {
        Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' } | ForEach-Object {
            Write-Output "LAN testers: http://$($_.IPAddress):$Port/ (same network; firewall must allow TCP $Port)"
        }
    }
    $steadyListenerId = (Get-NetTCPConnection -LocalPort $Port -State Listen | Select-Object -First 1).OwningProcess
    Write-Output "To stop this server: Stop-Process -Id $steadyListenerId"
} finally { Pop-Location }

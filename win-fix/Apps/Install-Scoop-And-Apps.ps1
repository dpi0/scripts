# Ensure TLS 1.2 (needed on some systems for HTTPS)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host "Checking for Scoop..."

# Install Scoop if it isn't already installed
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Scoop not found. Installing Scoop..."

    # Allow scripts for current user (required for Scoop)
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

    # Official Scoop install command
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

    Write-Host "Scoop installation complete."
} else {
    Write-Host "Scoop is already installed."
}

scoop install git

scoop install main/yt-dlp
scoop install main/ffmpeg
scoop install main/gpg

scoop bucket add extras
scoop install extras/mpv
scoop install extras/playnite
scoop install extras/autohotkey
scoop install extras/wezterm
scoop install extras/spotify
scoop install extras/localsend
scoop install extras/copyq
scoop install extras/nilesoft-she

scoop bucket add nirsoft
scoop install nirsoft/nircmd

scoop bucket add versions
scoop install versions/everything-alpha

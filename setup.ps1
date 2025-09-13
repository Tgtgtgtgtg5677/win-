# Must run elevated
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Run PowerShell as Administrator."
    exit 1
}

# Use TLS1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# (Optional) disable firewall (insecure) - keep if you really want it
try {
    Write-Host "Disabling firewall profiles..."
    Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled False -ErrorAction Stop
} catch {
    Write-Warning "Could not modify firewall: $($_.Exception.Message)"
}

# Install Chrome Remote Desktop host
try {
    $msiUrl = 'https://dl.google.com/edgedl/chrome-remote-desktop/chromeremotedesktophost.msi'
    $msiPath = Join-Path $env:TEMP 'chromeremotedesktophost.msi'
    Write-Host "Downloading CRD host..."
    Invoke-WebRequest -Uri $msiUrl -OutFile $msiPath -UseBasicParsing -ErrorAction Stop

    Write-Host "Installing CRD host silently..."
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", "`"$msiPath`"", "/qn", "/norestart" -Wait -NoNewWindow -ErrorAction Stop

    Remove-Item -Path $msiPath -Force -ErrorAction SilentlyContinue
    Write-Host "CRD host installed."
} catch {
    Write-Error "CRD install failed: $($_.Exception.Message)"
}

# Install Chrome (silent)
try {
    $chromeUrl = 'https://dl.google.com/chrome/install/latest/chrome_installer.exe'
    $chromePath = Join-Path $env:TEMP 'chrome_installer.exe'
    Write-Host "Downloading Chrome..."
    Invoke-WebRequest -Uri $chromeUrl -OutFile $chromePath -UseBasicParsing -ErrorAction Stop

    Write-Host "Installing Chrome silently..."
    Start-Process -FilePath $chromePath -ArgumentList "/silent","/install" -Wait -NoNewWindow -ErrorAction Stop

    Remove-Item -Path $chromePath -Force -ErrorAction SilentlyContinue
    Write-Host "Chrome installed."
} catch {
    Write-Error "Chrome install failed: $($_.Exception.Message)"
}

Write-Host "Finished. Note: You still need to complete Chrome Remote Desktop host pairing via https://remotedesktop.google.com/access"

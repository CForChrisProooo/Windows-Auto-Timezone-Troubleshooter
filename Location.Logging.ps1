Add-Type -AssemblyName System.Device

$watcher = New-Object System.Device.Location.GeoCoordinateWatcher
$watcher.Start()
Start-Sleep 2

# CSV log files
$logFile = "$env:USERPROFILE\location_log.csv"
$alertFile = "$env:USERPROFILE\location_alerts.csv"

# Create CSV headers if files don't exist
if (-not (Test-Path $logFile)) {
    "Timestamp,Latitude,Longitude,Accuracy,City,State,Country,Source,PublicIP,SSIDs,BSSIDs" | Out-File $logFile -Encoding UTF8
}
if (-not (Test-Path $alertFile)) {
    "Timestamp,Latitude,Longitude,Accuracy,City,State,Country,Source,PublicIP,SSIDs,BSSIDs" | Out-File $alertFile -Encoding UTF8
}

while ($true) {
    # Wait for a valid location fix
    $loc = $watcher.Position.Location
    if ($loc -eq $null -or ($loc.Latitude -eq 0 -and $loc.Longitude -eq 0)) {
        Write-Host "Waiting for location fix..."
        Start-Sleep 5
        continue
    }

    $accuracy = $loc.HorizontalAccuracy
    $lat = $loc.Latitude
    $lon = $loc.Longitude

    # Source Classification
    if ($accuracy -le 20) {
        $source = "GPS"
    }
    elseif ($accuracy -le 80) {
        $source = "Likely WiFi"
    }
    elseif ($accuracy -le 300) {
        $source = "WiFi"
    }
    elseif ($accuracy -le 600) {
        $source = "WiFi/Cell"
    }
    elseif ($accuracy -le 1200) {
        $source = "Likely Cell"
    }
    elseif ($accuracy -le 2500) {
        $source = "Cell/IP"
    }
    elseif ($accuracy -le 5000) {
        $source = "Likely IP"
    }
    else {
        $source = "Unknown/Hybrid"
    }

    # Public IP
    try { 
        $publicIP = (Invoke-RestMethod -Uri "https://api.ipify.org?format=json").ip 
    } catch { 
        $publicIP = "Unavailable" 
    }

    # Wi-Fi SSID + BSSID scan
    try {
        $wifiScan = netsh wlan show networks mode=bssid
        $ssidMatches = @()
        $bssidMatches = @()

        foreach ($line in $wifiScan) {
            if ($line -match '^\s*SSID\s+\d+\s+:\s+(.*)$') { 
                $ssidMatches += $Matches[1].Trim() 
            }
            elseif ($line -match '^\s*BSSID\s+\d+\s+:\s+([0-9a-fA-F:]+)') { 
                $bssidMatches += $Matches[1].Trim() 
            }
        }

        if (-not $ssidMatches) { $ssidMatches = @("None found") }
        if (-not $bssidMatches) { $bssidMatches = @("None found") }

        $ssidCSV = '"' + ($ssidMatches -join "; ") + '"'
        $bssidCSV = '"' + ($bssidMatches -join "; ") + '"'

    } catch { 
        $ssidCSV = "Unavailable"
        $bssidCSV = "Unavailable"
    }

    # Reverse geocoding
    try {
        $geo = Invoke-RestMethod -Uri "https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon"

        if ($geo.address.city) { $city = $geo.address.city }
        elseif ($geo.address.town) { $city = $geo.address.town }
        elseif ($geo.address.suburb) { $city = $geo.address.suburb }
        else { $city = "Unknown" }

        if ($geo.address.state) { $state = $geo.address.state } else { $state = "Unknown" }
        if ($geo.address.country) { $country = $geo.address.country } else { $country = "Unknown" }

        # Normalise specific cities
        if ($city -match 'Brisbane') { $city = "Brisbane" }

    } catch {
        $city = $state = $country = "Unknown"
    }

    # Construct CSV line
    $csvLine = "{0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10}" -f `
        (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $lat, $lon, $accuracy, $city, $state, $country, $source, $publicIP, $ssidCSV, $bssidCSV

    # Output to console
    Write-Host $csvLine

    # Append to CSV logs
    Add-Content -Path $logFile -Value $csvLine
    if ($city -ne "Brisbane") { Add-Content -Path $alertFile -Value $csvLine }

    Start-Sleep 15
}

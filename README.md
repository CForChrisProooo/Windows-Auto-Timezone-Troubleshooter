Windows Location & Network Diagnostic Logger

A PowerShell script that logs location sources, geographic coordinates, timezone, public IP, and nearby Wi-Fi network details (SSIDs and BSSIDs) to CSV files.
Designed to help troubleshoot incorrect geolocation, Wi-Fi positioning errors, or unexpected region mismatches on Windows systems.

Features

Logs latitude, longitude, accuracy, city, state, country

Detects whether location is derived from Wi-Fi or IP-based sources

Records your current public IP address

Scans and logs all nearby Wi-Fi SSIDs and BSSIDs

SSIDs and BSSIDs are strictly separated

Multiple networks recorded in a single row

Stores your current system timezone

Generates two CSV files:

location_log.csv – full continuous log

location_alerts.csv – entries where the detected city is not Brisbane

Useful for diagnosing:

Wrong-region search results

Incorrect website geolocation

Microsoft Location Services inconsistencies

Wi-Fi triangulation issues

VPN, ISP routing, or tower handover anomalies

Output Columns
Timestamp
Latitude
Longitude
Accuracy
City
State
Country
Source
PublicIP
SSIDs
BSSIDs


Each scan produces one row. SSIDs and BSSIDs are semicolon-separated lists.

How It Works

Uses Windows’ GeoCoordinateWatcher to acquire coordinates

Scans nearby Wi-Fi access points via netsh wlan show networks mode=bssid

Reverse-geocodes coordinates using OpenStreetMap (Nominatim)

Logs your system-reported timezone

Appends data to CSV files every 15 seconds

Use Cases

Troubleshooting incorrect GeoIP or Wi-Fi location on Windows

Investigating why Microsoft services think you're in the wrong city

Auditing network coverage, duplicate Wi-Fi networks, or rogue APs

Recording movement patterns for testing or analysis

Checking public IP changes over time (dynamic IP, VPN, carrier NAT)

Running the Script

Save the script as location_logger.ps1

Run PowerShell as Administrator

Execute:

Set-ExecutionPolicy Bypass -Scope Process -Force
.\location_logger.ps1


The script runs continuously until closed.

Notes

Uses the OpenStreetMap Nominatim API — please respect rate limits

Works on Windows 10 and Windows 11

Wi-Fi scanning requires wireless adapters enabled

BSSID and SSID parsing is strict to avoid mixed data

License

MIT License.

# Windows Location & Network Diagnostic Logger

A PowerShell script that logs **location sources**, **geographic coordinates**, **timezone**, **public IP**, and nearby **Wi-Fi network details** (SSIDs & BSSIDs) to CSV files.  
Designed to help diagnose incorrect geolocation, Wi-Fi positioning errors, and unexpected region mismatches on Windows systems.

---

## ⭐ Features

- Logs latitude, longitude, accuracy, city, state, country  
- Detects whether the location is derived from **Wi-Fi** or **IP-based** sources  
- Records your current **public IP address**  
- Scans and logs all nearby Wi-Fi SSIDs and BSSIDs  
  - SSIDs and BSSIDs are strictly separated  
  - Multiple networks stored in a single row  
- Logs your current **system timezone**  
- Generates two CSV files:  
  - `location_log.csv` – full continuous log  
  - `location_alerts.csv` – entries where the detected city is *not* Brisbane (customisable)

---

## 🛠 Useful For Diagnosing

- Wrong-region search results  
- Incorrect website geolocation  
- Microsoft Location Services inconsistencies  
- Wi-Fi triangulation issues  
- VPN / ISP routing / cell-tower handover anomalies  

---

## 📄 Output Columns

- Timestamp  
- Latitude  
- Longitude  
- Accuracy  
- City  
- State  
- Country  
- Source (WiFi or IP/Other)  
- PublicIP  
- SSIDs  
- BSSIDs  

Each scan produces one row.  
SSIDs and BSSIDs are **semicolon-separated lists**.

---

## ⚙️ How It Works

- Uses **GeoCoordinateWatcher** to acquire coordinates  
- Scans nearby access points via:

netsh wlan show networks mode=bssid


- Performs reverse geocoding using **OpenStreetMap (Nominatim)**  
- Reads your system-reported **timezone**  
- Appends data to CSV files every **15 seconds**

---

## 🧭 Use Cases

- Troubleshooting incorrect GeoIP or Wi-Fi location on Windows  
- Understanding why Microsoft services think you're in the wrong city  
- Auditing network coverage, duplicate SSIDs, or rogue APs  
- Recording movement patterns for testing or automation  
- Tracking public IP changes over time  

---

## ▶️ Running the Script

1. Save the script as `location_logger.ps1`  
2. Run PowerShell as Administrator  
3. Execute:

   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force
   .\location_logger.ps1

🏙 Changing the Expected City (Alert Trigger)

This script alerts when the detected city does not match your expected location.
By default, it is set to Brisbane.


To change it:

Open the script in a text editor

Find the line:

$ExpectedCity = "Brisbane"

Replace "Brisbane" with your preferred city, e.g.:

$ExpectedCity = "Sydney"


📌 Notes

Uses the OpenStreetMap Nominatim API — please respect rate limits

Works on Windows 10 and Windows 11

Wi-Fi scanning requires an enabled wireless adapter

SSID/BSSID parsing is strict to avoid mixed or malformed data


📜 License

MIT License.

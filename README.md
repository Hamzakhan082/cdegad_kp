# CDEGAD KP Forest Department

Flutter mobile client connected to the existing React dashboard and its shared
MariaDB database.

## Local client demo

The demo uses these sibling projects:

- Mobile app: `cdegad_kp/`
- Dashboard: `Forest_Project/forest_dashbord/`
- Shared API: `Forest_Project/forest_Dashbord_B/Server/index.js`
- Shared database: `forestdashbord`

The release APK is configured for `http://192.168.1.8:5000`. The laptop and
phone must be connected to the same router, and the laptop must actually own
the IPv4 address `192.168.1.8` before installing the APK.

Confirm the address in PowerShell:

```powershell
Get-NetIPAddress -AddressFamily IPv4 |
  Where-Object { $_.IPAddress -notlike '127.*' }
```

If the router gives the laptop another address, either reserve
`192.168.1.8` in the router or rebuild with the address that was assigned:

```powershell
flutter build apk --release `
  --dart-define=API_BASE_URL=http://YOUR_LAPTOP_IP:5000
```

Android Internet permission and cleartext HTTP support are enabled for this
local-network demo.

## Start the shared API

Start XAMPP/MariaDB first. Then:

```powershell
Set-Location "E:\Forest CDGATE\Forest_Project\forest_Dashbord_B"
npm install
node Server/index.js
```

Verify from the laptop (replace the IP when necessary):

```powershell
Invoke-RestMethod http://192.168.1.8:5000/API/VDC
```

The server listens on all network interfaces on port `5000`.

## Start the React dashboard

In a second terminal:

```powershell
Set-Location "E:\Forest CDGATE\Forest_Project\forest_dashbord"
npm install
npm start
```

Open `http://localhost:3000`. The dashboard keeps using
`http://localhost:5000`; only the physical mobile app uses the laptop's LAN
address.

## Install the demo APK

The built artifact is:

```text
build/app/outputs/flutter-apk/forest-cdgate-demo.apk
```

Copy it to the Android phone and install it, or use USB debugging:

```powershell
adb install -r build/app/outputs/flutter-apk/forest-cdgate-demo.apk
```

Keep MariaDB, the API terminal, and the dashboard terminal running throughout
the demo. A record submitted in any of the eight mobile modules is translated
to the existing dashboard table schema and appears after refreshing the
matching dashboard report.

## Development and verification

```powershell
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=API_BASE_URL=http://YOUR_LAPTOP_IP:5000
```

The source default is `http://192.168.1.8:5000`; `API_BASE_URL` remains
overrideable for another router, an emulator, or local testing.

The separate `backend/` directory is an alternate newer API and is not used by
the shared-dashboard demo.

# Universal Intel Chipset Updater
Automated tool to detect and install the latest Intel chipset INF drivers.  

> ⚡ **This tool supports older platforms dating back to 2nd-generation Intel CPUs (Sandy Bridge), for which Intel no longer includes drivers in the latest INF packages. While the installer can process these platforms thanks to backward compatibility, in practice no driver is installed or updated for them — the system simply ensures compatibility and maintains the proper INF references.**

📄 The full list of driver versions, and links for the installer .exe files can be found in `Intel_Chipset_Drivers_Download.txt`

Unlike official Intel releases, this tool can identify the highest available driver version for each platform and also install drivers for older platforms such as B85; X79/C600; Z87, H87, H81/C220; and X99/C610 — platforms whose drivers are not included in the latest Intel Chipset Driver Software.

## 🪪 Version
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/FirstEver-eu/Intel-Chipset-Driver-Updater?style=flat-square&label=Latest%20Version)](https://github.com/FirstEver-eu/Intel-Chipset-Driver-Updater/releases)

### 🚀 Key Features
- Automatic detection of Intel chipsets (Desktop, Mobile, Workstation, Server)  
- Version comparison against the latest INF releases  
- Direct installation of chipset INF via Windows Installer (`pnputil`)  
- Cleans temporary installation files automatically  
- Debug mode for detailed logging and troubleshooting  

### 📋 Supported Platforms

| 🖥️ Mainstream Desktop | ⚡ Workstation/Enthusiast | 🔋 Atom/Embedded & Low-Power |
| :--- | :--- | :--- |
| 15th Gen: Panther Lake<br>14th Gen: Arrow Lake, Raptor Lake Refresh<br>13th Gen: Raptor Lake<br>12th Gen: Alder Lake<br>11th Gen: Rocket Lake<br>10th Gen: Comet Lake, Cannon Lake<br>9th/8th Gen: Coffee Lake<br>7th Gen: Kaby Lake<br>6th Gen: Skylake<br>5th Gen: Broadwell<br>4th Gen: Haswell<br>3rd Gen: Ivy Bridge<br>2nd Gen: Sandy Bridge | Xeon W-2400/W-3400: Sapphire Rapids<br>Xeon W-3300: Ice Lake-X<br>X299: Cascade Lake-X, Skylake-X<br>X99: Broadwell-E, Haswell-E<br>X79: Ivy Bridge-E, Sandy Bridge-E | Core Ultra 200V: Lunar Lake<br>N-series: Alder Lake-N<br>Atom: Jasper Lake, Elkhart Lake, Gemini Lake, Apollo Lake<br>Atom Server: Denverton, Avoton<br>Legacy Atom: Bay Trail, Braswell, Valleyview |
| 💻 Mainstream Mobile | 🗄️ Server Platforms | 🕰️ Legacy Chipsets |
| Core Ultra 200V: Lunar Lake<br>14th Gen: Meteor Lake<br>11th Gen: Tiger Lake<br>10th Gen: Ice Lake, Comet Lake<br>8th/9th Gen: Coffee Lake<br>7th Gen: Kaby Lake<br>6th Gen: Skylake<br>5th Gen: Broadwell<br>4th Gen: Haswell, Crystal Well<br>3rd Gen: Ivy Bridge<br>2nd Gen: Sandy Bridge | 6th Gen Xeon: Granite Rapids, Clearwater Forest<br>5th Gen Xeon: Emerald Rapids<br>4th Gen Xeon: Sapphire Rapids<br>3rd Gen Xeon: Ice Lake-SP<br>2nd Gen Xeon: Cascade Lake<br>1st Gen Xeon: Skylake-SP<br>Older Xeon: Broadwell-EP, Haswell-EP, Ivy Town, Sandy Bridge-EP | 100 Series: Sunrise Point<br>9 Series: Wildcat Point<br>8 Series: Lynx Point<br>7 Series: Panther Point<br>6 Series: Cougar Point |

## 🛠️ Usage

### Option 1: Download Complete Package (Recommended)
1. Download the latest SFX archive `ChipsetUpdater-10.1.x-Driver64-Win10-Win11.exe` from [Releases](https://github.com/FirstEver-eu/Intel-Chipset-Driver-Updater/releases)
2. Run the executable as Administrator
3. Follow the on-screen prompts

### Option 2: Manual Scripts
1. Download both `Update-Intel-Chipset.bat` and `Update-Intel-Chipset.ps1`
2. Ensure both files are in the same directory
3. Run `Update-Intel-Chipset.bat` as Administrator
4. Follow the on-screen prompts

### 🔍 Troubleshooting
For detailed logging and troubleshooting, use:
1. Download both `Get-Intel-HWIDs.bat` and `Get-Intel-HWIDs.ps1`
2. Run `Get-Intel-HWIDs.bat` as Administrator
3. Provides extensive logging to C:\Intel_HWIDs_Report.txt for issue diagnosis.

## ⚠️ Important Notes

- **Administrator Rights Required**: Script must be run as Administrator
- **Restart Required**: Computer restart is needed after driver installation
- **Temporary Black Screen**: During PCIe bus driver updates, screen may temporarily go black
- **Device Reconnection**: Some devices may temporarily disconnect during installation

## 🔧 Manual Update

Driver information is maintained in:
- `Intel-Chipset-Driver-Updater.txt` - Contains download links and versions
- `Intel_Chipset_Drivers_Latest.md` - Platform compatibility matrix

If automatic detection fails, you can manually update these files with the latest driver information.

## 🤝 Contributing

Platform and driver information is maintained based on Intel official documentation and manufacturer updates. If you have access to newer platform information or driver links, please update the relevant files.

## 📝 License

This project is provided as-is for educational and convenience purposes.

## ⚠️ Disclaimer

This tool is not affiliated with Intel Corporation. Drivers are sourced from official Intel servers and manufacturer websites. Use at your own risk. Always backup your system before updating drivers.

## 📸 Screenshot

<img width="602" height="1056" alt="Intel Chipset Updater" src="https://github.com/user-attachments/assets/872520ad-706b-4f8c-ad23-a73300620614" />

---
**Maintainer**: Marcin Grygiel / www.firstever.tech  
**Source**: https://github.com/FirstEver-eu/Intel-Chipset-Updater  
**VirusTotal Scan**: [Result 0/98](https://www.virustotal.com/gui/url/73be62d14c2a11ebd6322142d44fbd32d843182f3e9f6d5a3a5b6841c552c077) (Clean)

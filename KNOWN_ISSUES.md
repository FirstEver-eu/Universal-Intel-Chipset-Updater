# 🐛 Known Issues & Solutions

This document contains all reported issues, bugs, and their corresponding solutions for the Universal Intel Chipset Drivers Updater. The list is maintained by the community and updated regularly.

## 📑 Quick Navigation

- [Issue #1: Touchpad Stops Working After Chipset Update](#issue-1-touchpad-stops-working-after-chipset-update)
- [Issue #2: PowerShell Execution Policy Restriction](#issue-2-powershell-execution-policy-restriction)

---

## Issue #1: Touchpad Stops Working After Chipset Update

**Affected Systems**: Lenovo ThinkPad T480 and T480s laptops

**Symptoms**:  
- Touchpad becomes completely unresponsive after chipset driver update  
- No cursor movement or touchpad clicks registered

**Cause**:  
Chipset driver update interferes with touchpad driver functionality.

**Solution**:
1. Download the appropriate touchpad driver for your model:
   - **ELAN UltraNav Driver** (for ThinkPad T480s):  
     `n22ga09w.exe` – https://download.lenovo.com/pccbbs/mobiles/n22ga09w.exe
   - **Synaptics UltraNav Driver** (for ThinkPad T480):  
     `n23gz21w.exe` – https://download.lenovo.com/pccbbs/mobiles/n23gz21w.exe
2. Run the downloaded installer as Administrator  
3. Restart your system

[↑ Back to top](#quick-navigation)

---

## Issue #2: PowerShell Execution Policy Restriction

**Affected Systems**: All Windows systems with default PowerShell settings

**Symptoms**:
- SFX EXE fails to run with PowerShell execution policy errors  
- Script terminates immediately without user interaction  
- Error message:  
  ```
  File ... cannot be loaded because running scripts is disabled on this system
  ```

**Cause**:  
Windows PowerShell blocks script execution by default for security reasons.

**Solution**:

### For SFX EXE Users

#### ✅ Permanent Fix (Recommended)
1. **Press Windows + X** and select **Windows PowerShell (Admin)**
2. Run the command:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. Type **Y** to confirm  
4. Run the ChipsetUpdater EXE normally

#### ⚠️ Temporary Fix (One-Time Bypass)
1. Open Command Prompt as Administrator  
2. Navigate to your EXE location  
3. Run:
   ```cmd
   PowerShell -ExecutionPolicy Bypass -Command "& {Start-Process -FilePath 'ChipsetUpdater-10.1-2025.11-Driver64-Win10-Win11.exe' -Verb RunAs}"
   ```

---

### For PS1 Users (Direct PowerShell Script)

#### Permanent Fix:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```
Type **Y** to confirm.  
Now you can run the PS1 script normally.

#### Temporary Fix:
```powershell
powershell -ExecutionPolicy Bypass -File "Universal-Intel-Chipset-Updater.ps1"
```

---

### Alternative: Use Batch Files Instead

If the SFX continues to fail:

1. Download both `.bat` and `.ps1` files  
2. Place them in the same folder  
3. Right-click the `.bat` file → **Run as administrator**

---

### Security Notes
- Permanent fix affects only the current user and is safe for trusted scripts  
- Temporary bypass is safest for one-time use  
- Revert execution policy anytime with:  
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy Restricted -Scope CurrentUser
  ```

[↑ Back to top](#quick-navigation)

---

## 🔍 Reporting New Issues

If you encounter a new issue not listed here, please:

- Check if the issue is already listed in this document  
- Open a new GitHub Issue with detailed description  
- Include your system specifications and exact error messages  
- Share any workarounds or solutions you've discovered  

---

Last Updated: ${current_date}

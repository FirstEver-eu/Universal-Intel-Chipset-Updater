# Intel Chipset Device Update Script
# Based on Intel Chipset Device Latest database
# Downloads latest INF files from GitHub and updates if newer versions available
# By Marcin Grygiel / www.firstever.tech

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires administrator privileges. Please run PowerShell as Administrator." -ForegroundColor Red
    exit
}

# =============================================
# CONFIGURATION - Set to 1 to enable debug mode
# =============================================
$DebugMode = 0  # 0 = Disabled, 1 = Enabled
# =============================================

# GitHub repository URLs
$githubBaseUrl = "https://raw.githubusercontent.com/FirstEverTech/Universal-Intel-Chipset-Updater/main/"
$chipsetINFsUrl = $githubBaseUrl + "INTEL_CHIPSET_INFS_LATEST.md"
$downloadListUrl = $githubBaseUrl + "INTEL_CHIPSET_INFS_DOWNLOAD.txt"

# Temporary directory for downloads
$tempDir = "C:\Windows\Temp\IntelChipset"

# =============================================
# ENHANCED ERROR HANDLING (BACKGROUND)
# =============================================

$global:InstallationErrors = @()
$global:ScriptStartTime = Get-Date
$logFile = "$tempDir\chipset_update.log"

function Write-Log {
    param([string]$Message, [string]$Type = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Type] $Message"
    try {
        Add-Content -Path $logFile -Value $logEntry -ErrorAction SilentlyContinue
    } catch {
        # Silent fallback
    }
    
    # Only show errors to user, everything else goes to log only
    if ($Type -eq "ERROR") {
        $global:InstallationErrors += $Message
        Write-Host "ERROR: $Message" -ForegroundColor Red
    }
}

function Write-DebugMessage {
    param([string]$Message, [string]$Color = "Gray")
    Write-Log -Message $Message -Type "DEBUG"
    if ($DebugMode -eq 1) {
        Write-Host "DEBUG: $Message" -ForegroundColor $Color
    }
}

function Show-FinalSummary {
    $duration = (Get-Date) - $global:ScriptStartTime
    if ($global:InstallationErrors.Count -gt 0) {
        Write-Host "`nCompleted with $($global:InstallationErrors.Count) error(s)." -ForegroundColor Red
        Write-Host "See $logFile for details." -ForegroundColor Red
    } else {
        Write-Host "`nOperation completed successfully." -ForegroundColor Green
    }
    Write-Log "Script execution completed in $([math]::Round($duration.TotalMinutes, 2)) minutes with $($global:InstallationErrors.Count) errors"
}

# =============================================
# FILE INTEGRITY VERIFICATION FUNCTIONS
# =============================================

function Get-FileHash256 {
    param([string]$FilePath)
    
    try {
        if (Test-Path $FilePath) {
            $hash = Get-FileHash -Path $FilePath -Algorithm SHA256
            Write-DebugMessage "Calculated SHA256 for $FilePath : $($hash.Hash)"
            return $hash.Hash
        } else {
            Write-Log "File not found for hash calculation: $FilePath" -Type "ERROR"
            return $null
        }
    } catch {
        Write-Log "Error calculating hash for $FilePath : $($_.Exception.Message)" -Type "ERROR"
        return $null
    }
}

function Verify-FileHash {
    param(
        [string]$FilePath, 
        [string]$ExpectedHash,
        [string]$HashType = "Primary",
        [string]$OriginalFileName = $null
    )

    if (-not $ExpectedHash) {
        Write-DebugMessage "No expected $HashType hash provided, skipping verification."
        return $true
    }

    $actualHash = Get-FileHash256 -FilePath $FilePath
    if (-not $actualHash) {
        Write-Log "Failed to calculate hash for $FilePath" -Type "ERROR"
        return $false
    }

    if ($actualHash -eq $ExpectedHash) {
        Write-DebugMessage "$HashType hash verification passed for $FilePath"
        Write-Host "PASS: $HashType hash verification passed." -ForegroundColor Green
        return $true
    } else {
        # Używamy oryginalnej nazwy pliku jeśli jest dostępna, w przeciwnym razie używamy nazwy tymczasowego pliku
        $displayName = if ($OriginalFileName) { $OriginalFileName } else { Split-Path $FilePath -Leaf }
        
        # Przygotuj komunikat o błędzie
        $errorMessage = "$HashType hash verification failed for $displayName. Source: $ExpectedHash, Actual: $actualHash"
        
        # Ręczne zapisanie do logu i dodanie do globalnej listy błędów (bez wyświetlania przez Write-Log)
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [ERROR] $errorMessage"
        try {
            Add-Content -Path $logFile -Value $logEntry -ErrorAction SilentlyContinue
        } catch {
            # Silent fallback
        }
        $global:InstallationErrors += $errorMessage

        # Wypisz sformatowany komunikat na konsoli (bez kropki na końcu nazwy pliku)
        Write-Host ""
        Write-Host "$HashType hash verification failed: $displayName" -ForegroundColor Red  # Usunięto kropkę
        Write-Host "Source: $ExpectedHash" -ForegroundColor Red
        Write-Host "Actual: $actualHash" -ForegroundColor Red
        Write-Host ""
        return $false
    }
}

# =============================================
# DIGITAL SIGNATURE VERIFICATION FUNCTIONS
# =============================================

function Verify-FileSignature {
    param([string]$FilePath)

    try {
        Write-DebugMessage "Verifying digital signature for: $FilePath"
        
        # Get file signature
        $signature = Get-AuthenticodeSignature -FilePath $FilePath
        Write-DebugMessage "Signature status: $($signature.Status)"
        Write-DebugMessage "Signer: $($signature.SignerCertificate.Subject)"
        Write-DebugMessage "Signature Algorithm: $($signature.SignerCertificate.SignatureAlgorithm.FriendlyName)"

        # Check if signature is valid
        if ($signature.Status -ne 'Valid') {
            Write-Log "Digital signature is not valid. Status: $($signature.Status)" -Type "ERROR"
            Write-Host "FAIL: Digital signature verification - Status: $($signature.Status)" -ForegroundColor Red
            return $false
        }

        # Check if signed by Intel Corporation
        if ($signature.SignerCertificate.Subject -notmatch 'CN=Intel Corporation') {
            Write-Log "File not signed by Intel Corporation. Signer: $($signature.SignerCertificate.Subject)" -Type "ERROR"
            Write-Host "FAIL: Digital signature verification - Not signed by Intel Corporation." -ForegroundColor Red
            return $false
        }

        # Check if using SHA256 algorithm
        if ($signature.SignerCertificate.SignatureAlgorithm.FriendlyName -notmatch 'sha256') {
            Write-Log "Signature not using SHA256 algorithm. Algorithm: $($signature.SignerCertificate.SignatureAlgorithm.FriendlyName)" -Type "ERROR"
            Write-Host "FAIL: Digital signature verification - Not using SHA256 algorithm" -ForegroundColor Red
            return $false
        }

        Write-Host "PASS: Digitally signed by Intel Corporation." -ForegroundColor Green
        Write-DebugMessage "Digital signature verification passed for $FilePath"
        return $true
    }
    catch {
        Write-Log "Error verifying digital signature: $($_.Exception.Message)" -Type "ERROR"
        Write-Host "FAIL: Digital signature verification - Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Verify-InstallerSignature {
    param([string]$INFPath, [string]$Prefix)

    try {
        # Determine the installer path
        if ($Prefix) {
            $setupPath = Join-Path $INFPath ($Prefix.TrimStart('\'))
        } else {
            $setupPath = Join-Path $INFPath "SetupChipset.exe"
        }

        Write-DebugMessage "Checking installer signature at: $setupPath"

        if (-not (Test-Path $setupPath)) {
            Write-Log "Installer not found for signature verification: $setupPath" -Type "ERROR"
            return $false
        }

        # Verify the digital signature
        return Verify-FileSignature -FilePath $setupPath
    }
    catch {
        Write-Log "Error in installer signature verification: $($_.Exception.Message)" -Type "ERROR"
        return $false
    }
}

# =============================================
# UPDATED PARSER FOR EXTENDED FORMAT
# =============================================

function Parse-DownloadList {
    param([string]$DownloadListContent)

    Write-DebugMessage "Starting download list parsing."
    $downloadData = @{}
    
    try {
        $blocks = $DownloadListContent -split "`n`n" | Where-Object { $_.Trim() }

        Write-DebugMessage "Found $($blocks.Count) blocks in download list."

        foreach ($block in $blocks) {
            $name = $null
            $infVer = $null
            $link = $null
            $prefix = $null
            $variant = "Consumer"
            $sha256 = $null
            $backup = $null
            $sha256_b = $null
            $prefix_b = $null

            $lines = $block -split "`n" | ForEach-Object { $_.Trim() }
            foreach ($line in $lines) {
                if ($line -match '^Name\s*=\s*(.+)') {
                    $name = $matches[1]
                } elseif ($line -match '^INFVer\s*=\s*[^,]+,([0-9.]+)') {
                    $infVer = $matches[1]
                } elseif ($line -match '^Link\s*=\s*(.+)') {
                    $link = $matches[1]
                } elseif ($line -match '^Prefix\s*=\s*(.+)') {
                    $prefix = $matches[1]
                } elseif ($line -match '^Variant\s*=\s*(.+)') {
                    $variant = $matches[1]
                } elseif ($line -match '^SHA256\s*=\s*([A-F0-9]+)') {
                    $sha256 = $matches[1]
                } elseif ($line -match '^Backup\s*=\s*(.+)') {
                    $backup = $matches[1]
                } elseif ($line -match '^SHA256_B\s*=\s*([A-F0-9]+)') {
                    $sha256_b = $matches[1]
                } elseif ($line -match '^Prefix_B\s*=\s*(.+)') {
                    $prefix_b = $matches[1]
                }
            }

            if ($infVer -and $link) {
                $key = "$infVer-$variant"
                $downloadData[$key] = @{
                    Name = $name
                    INFVer = $infVer
                    Link = $link
                    Prefix = $prefix
                    Variant = $variant
                    SHA256 = $sha256
                    Backup = $backup
                    SHA256_B = $sha256_b
                    Prefix_B = $prefix_b
                }
                Write-DebugMessage "Added download entry: $key -> $name"
            } else {
                Write-DebugMessage "Skipping incomplete block - missing INFVer or Link."
            }
        }

        Write-DebugMessage "Download list parsing completed. Found $($downloadData.Count) entries."
        return $downloadData
    }
    catch {
        Write-Log "Download list parsing failed: $($_.Exception.Message)" -Type "ERROR"
        return @{}
    }
}

# =============================================
# ENHANCED DOWNLOAD FUNCTION WITH PRECISE ERROR HANDLING
# =============================================

function Download-Extract-File {
    param(
        [string]$Url, 
        [string]$OutputPath, 
        [string]$Prefix, 
        [string]$ExpectedHash,
        [string]$SourceName = "Primary"
    )

    try {
        $tempFile = "$tempDir\temp_$(Get-Random).$([System.IO.Path]::GetExtension($Url).TrimStart('.'))"

        # Download file
        Write-DebugMessage "Downloading from $SourceName source: $Url to $tempFile"
        Write-Host "Downloading from $SourceName source..." -ForegroundColor Yellow
        
        # Try to download file
        $downloadSuccess = $true
        $downloadError = $null
        
        try {
            Invoke-WebRequest -Uri $Url -OutFile $tempFile -UseBasicParsing -ErrorAction Stop
        } catch {
            $downloadSuccess = $false
            $downloadError = $_.Exception.Message
        }

        if (-not $downloadSuccess) {
            Write-Log "Download failed for $SourceName source $Url : $downloadError" -Type "ERROR"
            return @{ Success = $false; ErrorType = "DownloadFailed"; Message = "Download failed: $downloadError" }
        }

        # Check if file was downloaded
        if (-not (Test-Path $tempFile)) {
            return @{ Success = $false; ErrorType = "DownloadFailed"; Message = "File not found after download" }
        }

        # Verify hash if provided
        if ($ExpectedHash) {
            Write-Host "Verifying $SourceName source file integrity..." -ForegroundColor Yellow
            $originalFileName = [System.IO.Path]::GetFileName($Url)
            if (-not (Verify-FileHash -FilePath $tempFile -ExpectedHash $ExpectedHash -HashType $SourceName -OriginalFileName $originalFileName)) {
                Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
                return @{ Success = $false; ErrorType = "HashMismatch"; Message = "Hash verification failed" }
            }
        }

        $fileExtension = [System.IO.Path]::GetExtension($Url).ToLower()
        
        if ($fileExtension -eq '.zip') {
            try {
                Add-Type -AssemblyName System.IO.Compression.FileSystem
                [System.IO.Compression.ZipFile]::ExtractToDirectory($tempFile, $OutputPath)
                Write-Host "ZIP file extracted successfully." -ForegroundColor Green
                Write-DebugMessage "ZIP extraction successful to: $OutputPath"
            } catch {
                try {
                    Write-Host "Using COM object for ZIP extraction..." -ForegroundColor Yellow
                    $shell = New-Object -ComObject Shell.Application
                    $zipFolder = $shell.NameSpace($tempFile)
                    $destFolder = $shell.NameSpace($OutputPath)
                    $destFolder.CopyHere($zipFolder.Items(), 0x14)
                    Write-Host "ZIP file extracted successfully using COM." -ForegroundColor Green
                } catch {
                    Write-Log "Error extracting ZIP file: $_" -Type "ERROR"
                    return @{ Success = $false; ErrorType = "ExtractionFailed"; Message = "ZIP extraction failed: $_" }
                }
            }
        } elseif ($fileExtension -eq '.exe') {
            New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null

            if ($Prefix -and $Prefix -ne '\SetupChipset.exe') {
                $subDir = Split-Path $Prefix.TrimStart('\') -Parent
                if ($subDir) {
                    $fullOutputPath = Join-Path $OutputPath $subDir
                    New-Item -ItemType Directory -Path $fullOutputPath -Force | Out-Null
                    Write-DebugMessage "Created subdirectory: $fullOutputPath"
                }

                $outputFile = Join-Path $OutputPath ($Prefix.TrimStart('\'))
                Copy-Item $tempFile $outputFile -Force
                Write-Host "EXE file copied to: $outputFile" -ForegroundColor Green
            } else {
                Copy-Item $tempFile "$OutputPath\SetupChipset.exe" -Force
                Write-Host "EXE file copied to: $OutputPath\SetupChipset.exe" -ForegroundColor Green
            }
        } else {
            Write-Log "Unknown file type: $fileExtension" -Type "ERROR"
            return @{ Success = $false; ErrorType = "UnknownFileType"; Message = "Unknown file type: $fileExtension" }
        }

        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
        Write-DebugMessage "Removed temporary file: $tempFile"
        return @{ Success = $true; ErrorType = "None"; Message = "Success" }
    }
    catch {
        Write-Log "Error in Download-Extract-File: $_" -Type "ERROR"
        return @{ Success = $false; ErrorType = "UnknownError"; Message = "Unexpected error: $_" }
    }
}

# =============================================
# ORIGINAL FUNCTIONS (UPDATED FOR NEW FORMAT)
# =============================================

function Get-IntelChipsetHWIDs {
    $intelChipsets = @()
    $chipsetCount = 0
    $nonChipsetCount = 0

    try {
        $pciDevices = Get-PnpDevice -Class 'System' -ErrorAction SilentlyContinue | 
                      Where-Object { $_.HardwareID -like '*PCI\VEN_8086*' -and $_.Status -eq 'OK' }

        foreach ($device in $pciDevices) {
            foreach ($hwid in $device.HardwareID) {
                if ($hwid -match 'PCI\\VEN_8086&DEV_([A-F0-9]{4})') {
                    $deviceId = $matches[1]
                    $description = $device.FriendlyName

                    if ($description -match 'Chipset|LPC|PCI Express Root Port|PCI-to-PCI bridge|Motherboard Resources') {
                        $intelChipsets += [PSCustomObject]@{
                            HWID = $deviceId
                            Description = $description
                            HardwareID = $hwid
                            InstanceId = $device.InstanceId
                            IsChipset = $true
                        }
                        $chipsetCount++
                    } else {
                        $nonChipsetCount++
                    }
                }
            }
        }

        if ($intelChipsets.Count -eq 0) {
            foreach ($device in $pciDevices) {
                foreach ($hwid in $device.HardwareID) {
                    if ($hwid -match 'PCI\\VEN_8086&DEV_([A-F0-9]{4})') {
                        $deviceId = $matches[1]
                        $description = $device.FriendlyName

                        $intelChipsets += [PSCustomObject]@{
                            HWID = $deviceId
                            Description = $description
                            HardwareID = $hwid
                            InstanceId = $device.InstanceId
                            IsChipset = $false
                        }
                        $chipsetCount++

                        if ($intelChipsets.Count -ge 5) { break }
                    }
                }
                if ($intelChipsets.Count -ge 5) { break }
            }
        }

        Write-DebugMessage "Scanning completed: found $chipsetCount potential chipset devices and $nonChipsetCount non-chipset devices"
        return $intelChipsets | Sort-Object HWID -Unique
    }
    catch {
        Write-Log "Hardware detection failed: $($_.Exception.Message)" -Type "ERROR"
        return @()
    }
}

function Get-CurrentINFVersion {
    param([string]$DeviceInstanceId)

    try {
        $device = Get-PnpDevice | Where-Object {$_.InstanceId -eq $DeviceInstanceId}
        if ($device) {
            $versionProperty = $device | Get-PnpDeviceProperty -KeyName "DEVPKEY_Device_DriverVersion" -ErrorAction SilentlyContinue
            if ($versionProperty -and $versionProperty.Data) {
                Write-DebugMessage "Got version from DEVPKEY_Device_DriverVersion: $($versionProperty.Data)"
                return $versionProperty.Data
            }
            
            $infVersionProperty = $device | Get-PnpDeviceProperty -KeyName "DEVPKEY_Device_INFVersion" -ErrorAction SilentlyContinue
            if ($infVersionProperty -and $infVersionProperty.Data) {
                Write-DebugMessage "Got version from DEVPKEY_Device_INFVersion: $($infVersionProperty.Data)"
                return $infVersionProperty.Data
            }
        }

        # Fallback to WMI
        $driverInfo = Get-CimInstance -ClassName Win32_PnPSignedDriver | Where-Object { 
            $_.DeviceID -eq $DeviceInstanceId -and $_.DriverVersion
        } | Select-Object -First 1

        if ($driverInfo) {
            Write-DebugMessage "Got version from WMI: $($driverInfo.DriverVersion)"
            return $driverInfo.DriverVersion
        }

        Write-DebugMessage "Could not determine version for device: $DeviceInstanceId"
        return $null
    }
    catch {
        Write-DebugMessage "Error getting INF version: $_"
        return $null
    }
}

function Clear-TempINFFolders {
    try {
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
            Write-DebugMessage "Cleaned up temporary directory: $tempDir"
        }
    }
    catch {
        Write-DebugMessage "Error during cleanup: $_"
    }
}

function Get-LatestINFInfo {
    param([string]$Url)

    try {
        # Simple cache-busting without external dependencies
        $cacheBuster = "t=" + (Get-Date -Format 'yyyyMMddHHmmss')
        if ($Url.Contains('?')) {
            $finalUrl = $Url + "&" + $cacheBuster
        } else {
            $finalUrl = $Url + "?" + $cacheBuster
        }
        
        Write-DebugMessage "Downloading from: $finalUrl (with cache-buster)"
        $content = Invoke-WebRequest -Uri $finalUrl -UseBasicParsing -ErrorAction Stop
        Write-DebugMessage "Successfully downloaded content from $finalUrl"
        return $content.Content
    }
    catch {
        Write-Log "Error downloading from GitHub: $($_.Exception.Message)" -Type "ERROR"
        return $null
    }
}

function Parse-ChipsetINFsFromMarkdown {
    param([string]$MarkdownContent)

    Write-DebugMessage "Starting Markdown parsing."
    $chipsetData = @{}
    
    try {
        $lines = $MarkdownContent -split "`n"
        $currentPlatform = $null
        $currentGeneration = $null
        $inMainstreamSection = $false
        $inWorkstationSection = $false
        $inXeonSection = $false
        $inAtomSection = $false

        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i].Trim()

            # Detect section headers
            if ($line -match '^### Mainstream Desktop/Mobile') {
                $inMainstreamSection = $true
                $inWorkstationSection = $false
                $inXeonSection = $false
                $inAtomSection = $false
                Write-DebugMessage "Entered Mainstream Desktop/Mobile section."
                continue
            }
            elseif ($line -match '^### Workstation/Enthusiast') {
                $inMainstreamSection = $false
                $inWorkstationSection = $true
                $inXeonSection = $false
                $inAtomSection = $false
                Write-DebugMessage "Entered Workstation/Enthusiast section."
                continue
            }
            elseif ($line -match '^### Xeon/Server Platforms') {
                $inMainstreamSection = $false
                $inWorkstationSection = $false
                $inXeonSection = $true
                $inAtomSection = $false
                Write-DebugMessage "Entered Xeon/Server Platforms section."
                continue
            }
            elseif ($line -match '^### Atom/Low-Power Platforms') {
                $inMainstreamSection = $false
                $inWorkstationSection = $false
                $inXeonSection = $false
                $inAtomSection = $true
                Write-DebugMessage "Entered Atom/Low-Power Platforms section."
                continue
            }

            # Detect platform headers
            if ($line -match '^####\s+(.+)') {
                $currentPlatform = $matches[1]
                
                if ($inMainstreamSection) {
                    $sectionName = "Mainstream Desktop/Mobile"
                } elseif ($inWorkstationSection) {
                    $sectionName = "Workstation/Enthusiast"
                } elseif ($inXeonSection) {
                    $sectionName = "Xeon/Server Platforms"
                } elseif ($inAtomSection) {
                    $sectionName = "Atom/Low-Power Platforms"
                } else {
                    $sectionName = "Unknown"
                }
                
                Write-DebugMessage "Processing platform: $currentPlatform ($sectionName)"
                continue
            }

            # Detect generation headers
            if ($line -match '\*\*Generation:\*\*\s*(.+)') {
                $currentGeneration = $matches[1]
                Write-DebugMessage "Generation: $currentGeneration"
                continue
            }

            # Detect table headers and data rows
            if ($line -match '^\|.*INF.*\|.*Package.*\|.*Version.*\|.*Date.*\|.*HWIDs.*\|$' -and $currentPlatform) {
                Write-DebugMessage "Found table for platform: $currentPlatform"
                # Skip separator line
                $i++

                # Process data rows until we hit a non-table line
                while ($i -lt $lines.Count -and $lines[$i].Trim() -match '^\|.*\|.*\|.*\|.*\|.*\|$') {
                    $dataLine = $lines[$i].Trim()
                    $i++

                    # Skip separator lines
                    if ($dataLine -match '^\|\s*:---') { continue }

                    # Parse table row
                    $columns = $dataLine.Split('|', [System.StringSplitOptions]::RemoveEmptyEntries) | ForEach-Object { $_.Trim() }
                    if ($columns.Count -ge 5) {
                        $inf = $columns[0]
                        $package = $columns[1]
                        $version = $columns[2]
                        $date = $columns[3] -replace '\\', ''  # Remove backslash if present
                        $hwIds = $columns[4] -split ',' | ForEach-Object { $_.Trim() }

                        Write-DebugMessage "Parsed row: INF=$inf, Package=$package, Version=$version, HWIDs=$($hwIds -join ',')"

                        foreach ($hwId in $hwIds) {
                            if ($hwId -match '^[A-F0-9]{4}$') {
                                $chipsetData[$hwId] = @{
                                    Platform = $currentPlatform
                                    Section = $sectionName
                                    Generation = $currentGeneration
                                    INF = $inf
                                    Package = $package
                                    Version = $version
                                    Date = $date
                                    HasAsterisk = $date -match '\*$'
                                }
                                Write-DebugMessage "Added HWID: $hwId for platform $currentPlatform"
                            } else {
                                Write-DebugMessage "Skipping invalid HWID: $hwId"
                            }
                        }
                    }
                }
            }
        }

        Write-DebugMessage "Markdown parsing completed. Found $($chipsetData.Count) HWID entries."
        return $chipsetData
    }
    catch {
        Write-Log "Markdown parsing failed: $($_.Exception.Message)" -Type "ERROR"
        return @{}
    }
}

function Install-ChipsetINF {
    param([string]$INFPath, [string]$Prefix)

    try {
        if ($Prefix) {
            $setupPath = Join-Path $INFPath ($Prefix.TrimStart('\'))
        } else {
            $setupPath = Join-Path $INFPath "SetupChipset.exe"
        }

        Write-DebugMessage "Installing from path: $setupPath"

        if (Test-Path $setupPath) {
            # =============================================
            # DIGITAL SIGNATURE VERIFICATION - ADDED
            # =============================================
            Write-Host "Verifying installer digital signature..." -ForegroundColor Yellow
            if (-not (Verify-FileSignature -FilePath $setupPath)) {
                Write-Log "Installer digital signature verification failed. Aborting installation." -Type "ERROR"
                Write-Host "ERROR: Installer digital signature verification failed. Installation aborted." -ForegroundColor Red
                return $false
            }

            Write-Host ""
            Write-Host "IMPORTANT NOTICE:" -ForegroundColor Yellow
            Write-Host "The INF files updater is now running." -ForegroundColor Yellow
            Write-Host "Please DO NOT close this window or interrupt the process." -ForegroundColor Yellow
            Write-Host "The system may appear unresponsive during installation - this is normal." -ForegroundColor Yellow
            Write-Host ""

            Write-Host "Running installer: SetupChipset.exe" -ForegroundColor Cyan
            Write-DebugMessage "Starting installer with arguments: -S -OVERALL -downgrade -norestart"

            $process = Start-Process -FilePath $setupPath -ArgumentList "-S -OVERALL -downgrade -norestart" -Wait -PassThru

            if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
                Write-Host "INF files installed successfully." -ForegroundColor Green
                Write-DebugMessage "Installer completed successfully with exit code: $($process.ExitCode)"
                return $true
            } else {
                Write-Log "Installer failed with exit code: $($process.ExitCode)" -Type "ERROR"
                return $false
            }
        } else {
            Write-Log "Installer not found at: $setupPath" -Type "ERROR"
            $exeFiles = Get-ChildItem -Path $INFPath -Filter "*.exe" -Recurse | Where-Object {
                $_.Name -like "*Setup*" -or $_.Name -like "*Install*"
            }
            if ($exeFiles) {
                Write-Host "Found alternative installer: $($exeFiles[0].FullName)" -ForegroundColor Yellow
                # Verify signature for alternative installer too
                Write-Host "Verifying alternative installer digital signature..." -ForegroundColor Yellow
                if (-not (Verify-FileSignature -FilePath $exeFiles[0].FullName)) {
                    Write-Log "Alternative installer digital signature verification failed." -Type "ERROR"
                    return $false
                }
                return Install-ChipsetINF -INFPath $INFPath -Prefix "\$($exeFiles[0].Name)"
            }
            return $false
        }
    }
    catch {
        Write-Log "Error running installer: $_" -Type "ERROR"
        return $false
    }
}

# Main script execution
try {
    Write-Host "=== Intel Chipset Device Software Update ===" -ForegroundColor Cyan
    Write-Host "Scanning for Intel Chipset..." -ForegroundColor Green

    # Create temporary directory
    Clear-TempINFFolders
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    Write-DebugMessage "Created temporary directory: $tempDir"

    # Detect Intel Chipset HWIDs
    $detectedIntelChipsets = Get-IntelChipsetHWIDs

    if ($detectedIntelChipsets.Count -eq 0) {
        Write-Host "No Intel chipset devices found." -ForegroundColor Yellow
        Write-Host "If you have an Intel platform, make sure you have at least SandyBridge or newer platform." -ForegroundColor Yellow
        Clear-TempINFFolders
        exit
    }

    Write-Host "Found $($detectedIntelChipsets.Count) Intel chipset device(s)" -ForegroundColor Green

    # Debug information
    if ($DebugMode -eq 1) {
        Write-Host "`n=== DEBUG INFORMATION ===" -ForegroundColor Cyan
        Write-Host "Checking versions for detected devices:" -ForegroundColor Gray
        foreach ($device in $detectedIntelChipsets) {
            $currentVersion = Get-CurrentINFVersion -DeviceInstanceId $device.InstanceId
            Write-Host "Device: $($device.Description)" -ForegroundColor Gray
            Write-Host "  HWID: $($device.HWID) | Version: $currentVersion" -ForegroundColor Gray
        }
        Write-Host "=== END DEBUG ===`n" -ForegroundColor Cyan
    }

    # Download latest INF information
    Write-Host "Downloading latest INF information..." -ForegroundColor Green
    $chipsetInfo = Get-LatestINFInfo -Url $chipsetINFsUrl
    $downloadListInfo = Get-LatestINFInfo -Url $downloadListUrl

    if (-not $chipsetInfo -or -not $downloadListInfo) {
        Write-Host "Failed to download INF information. Exiting." -ForegroundColor Red
        Clear-TempINFFolders
        exit
    }

    # Parse INF information
    Write-Host "Parsing INF information..." -ForegroundColor Green
    $chipsetData = Parse-ChipsetINFsFromMarkdown -MarkdownContent $chipsetInfo
    $downloadData = Parse-DownloadList -DownloadListContent $downloadListInfo

    if ($chipsetData.Count -eq 0 -or $downloadData.Count -eq 0) {
        Write-Host "Error: Could not parse INF information." -ForegroundColor Red
        Write-Host "Please check the format of markdown and download list files." -ForegroundColor Yellow
        Clear-TempINFFolders
        exit
    }

    # Find matching chipset platforms
    $matchingChipsets = @()
    $chipsetUpdateAvailable = $false

    foreach ($device in $detectedIntelChipsets) {
        $hwId = $device.HWID
        if ($chipsetData.ContainsKey($hwId)) {
            $chipsetInfo = $chipsetData[$hwId]
            $currentVersion = Get-CurrentINFVersion -DeviceInstanceId $device.InstanceId

            $matchingChipsets += @{
                Device = $device
                ChipsetInfo = $chipsetInfo
                CurrentVersion = $currentVersion
                HardwareID = $device.HardwareID
                InstanceId = $device.InstanceId
            }

            Write-Host "Found compatible platform: $($chipsetInfo.Platform) (HWID: $hwId)" -ForegroundColor Green
            Write-DebugMessage "Platform match: $($chipsetInfo.Platform) - Current: $currentVersion, Latest: $($chipsetInfo.Version)"
        }
    }

    if ($matchingChipsets.Count -eq 0) {
        Write-Host "No compatible Intel chipset platforms found." -ForegroundColor Yellow
        Write-Host "If you have an Intel platform, make sure you have at least SandyBridge or newer platform." -ForegroundColor Yellow
        Clear-TempINFFolders
        exit
    }

    # Group by platform
    $uniquePlatforms = @{}
    foreach ($match in $matchingChipsets) {
        $platform = $match.ChipsetInfo.Platform
        $package = $match.ChipsetInfo.Package

        if (-not $uniquePlatforms.ContainsKey($platform)) {
            $uniquePlatforms[$platform] = @{
                ChipsetInfo = $match.ChipsetInfo
                Devices = @($match.Device)
                CurrentVersions = @()
            }
        }

        if ($match.CurrentVersion) {
            $uniquePlatforms[$platform].CurrentVersions += $match.CurrentVersion
        }
    }

    # Display platform information
    Write-Host "`n=== Platform Information ===" -ForegroundColor Cyan

    $hasAnyAsterisk = $false

    foreach ($platformName in $uniquePlatforms.Keys) {
        $platformData = $uniquePlatforms[$platformName]
        $chipsetInfo = $platformData.ChipsetInfo
        $devices = $platformData.Devices
        $currentVersions = $platformData.CurrentVersions | Sort-Object -Unique

        Write-Host "Platform: $platformName" -ForegroundColor White
        if ($chipsetInfo.Generation) {
            Write-Host "Generation: $($chipsetInfo.Generation)" -ForegroundColor Gray
        }

        if ($currentVersions.Count -gt 0) {
            Write-Host "Current Version: $(($currentVersions -join ', '))" -ForegroundColor Gray
        } else {
            Write-Host "Current Version: Unable to determine" -ForegroundColor Gray
        }

        Write-Host "Latest Version: $($chipsetInfo.Version)" -ForegroundColor Gray

        $installerVersionDisplay = "$($chipsetInfo.Package) ($($chipsetInfo.Date))"
        Write-Host "Installer Version: $installerVersionDisplay" -ForegroundColor Yellow

        $needsUpdate = $false
        if ($currentVersions.Count -gt 0) {
            foreach ($currentVersion in $currentVersions) {
                if ($currentVersion -ne $chipsetInfo.Version) {
                    $needsUpdate = $true
                    break
                }
            }

            if (-not $needsUpdate) {
                Write-Host "Status: Already on latest version." -ForegroundColor Green
            } else {
                $currentVersionsText = $currentVersions -join ', '
                Write-Host "Status: Update available - current: $currentVersionsText, latest: $($chipsetInfo.Version)" -ForegroundColor Yellow
                $chipsetUpdateAvailable = $true
            }
        } else {
            Write-Host "Status: INF files will be installed" -ForegroundColor Yellow
            $chipsetUpdateAvailable = $true
        }

        if ($chipsetInfo.HasAsterisk) {
            $hasAnyAsterisk = $true
        }

        Write-Host ""
    }

    if ($hasAnyAsterisk) {
        Write-Host "Note: INF files marked with (*) do not have embedded dates" -ForegroundColor Yellow
        Write-Host "      and will show as 07/18/1968 in system. The actual" -ForegroundColor Yellow
        Write-Host "      INF files release corresponds to the installer date." -ForegroundColor Yellow
        Write-Host ""
    }

    if ((-not $chipsetUpdateAvailable) -and ($uniquePlatforms.Count -gt 0)) {
        Write-Host "All platforms are up to date." -ForegroundColor Green
        $response = Read-Host "Do you want to force reinstall this INF files anyway? (Y/N)"
        if ($response -eq "Y" -or $response -eq "y") {
            $chipsetUpdateAvailable = $true
        } else {
            Write-Host "Installation cancelled." -ForegroundColor Yellow
            Clear-TempINFFolders
            exit
        }
    }

    if ($chipsetUpdateAvailable) {
        Write-Host ""
        Write-Host "IMPORTANT NOTICE:" -ForegroundColor Yellow
        Write-Host "The INF files update process may take several minutes to complete." -ForegroundColor Yellow
        Write-Host "During installation, the screen may temporarily go black and some" -ForegroundColor Yellow
        Write-Host "devices may temporarily disconnect as PCIe bus INF files are being" -ForegroundColor Yellow
        Write-Host "updated. This is normal behavior and the system will return to" -ForegroundColor Yellow
        Write-Host "normal operation once the installation is complete." -ForegroundColor Yellow
        Write-Host ""
        $response = Read-Host "Do you want to proceed with INF files update? (Y/N)"
    } else {
        $response = "N"
    }

    if ($response -eq "Y" -or $response -eq "y") {
        Write-Host "`nStarting INF files update process..." -ForegroundColor Green

        # CREATE SYSTEM RESTORE POINT
        Write-Host "Creating system restore point..." -ForegroundColor Yellow
        try {
            $restorePointDescription = "Before Intel Chipset INF Update - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
            
            # Enable system restore on C: drive if not already enabled
            try {
                $null = Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
            } catch {
                Write-DebugMessage "System restore might already be enabled or not available: $($_.Exception.Message)"
            }
            
            # Create restore point
            Checkpoint-Computer -Description $restorePointDescription -RestorePointType "MODIFY_SETTINGS"
            Write-Host "System restore point created successfully: '$restorePointDescription'" -ForegroundColor Green
            Write-DebugMessage "System restore point created: $restorePointDescription"
        }
        catch {
            Write-Log "Failed to create system restore point: $($_.Exception.Message)" -Type "ERROR"
            Write-Host "WARNING: Could not create system restore point. Continuing anyway..." -ForegroundColor Yellow
            Write-Host "If the update causes issues, you may not be able to easily revert the changes." -ForegroundColor Yellow
        }

        $packageGroups = @{}
        foreach ($platformName in $uniquePlatforms.Keys) {
            $platformData = $uniquePlatforms[$platformName]
            $packageVersion = $platformData.ChipsetInfo.Package
            
            if (-not $packageGroups.ContainsKey($packageVersion)) {
                $packageGroups[$packageVersion] = @()
            }
            $packageGroups[$packageVersion] += $platformName
        }

        $sortedPackages = $packageGroups.Keys | Sort-Object { [version]($_ -replace '\s*\(S\)\s*', '') } -Descending
        Write-DebugMessage "Package groups: $($packageGroups.Count) unique packages"

        $successCount = 0
        $processedPackages = @{}

        foreach ($packageVersion in $sortedPackages) {
            $platforms = $packageGroups[$packageVersion]
            
            Write-Host "`nPackage $packageVersion for platforms: $($platforms -join ', ')" -ForegroundColor Cyan
            Write-DebugMessage "Processing package: $packageVersion for platforms: $($platforms -join ', ')"

            $variant = "Consumer"
            if ($packageVersion -match '\(S\)$') {
                $variant = "Server"
            }
            Write-DebugMessage "Determined variant: $variant"

            $cleanPackageVersion = $packageVersion -replace '\s*\(S\)\s*', ''
            $downloadKey = "$cleanPackageVersion-$variant"
            Write-DebugMessage "Looking for download key: $downloadKey"

            if ($downloadData.ContainsKey($downloadKey)) {
                $downloadInfo = $downloadData[$downloadKey]
                $driverPath = "$tempDir\$cleanPackageVersion-$variant"

                # ENHANCED DOWNLOAD LOGIC WITH PRECISE ERROR HANDLING
                $downloadSuccess = $false
                $usedBackup = $false
                $errorPhase = $null

                # Attempt 1: Primary Source
                Write-Host "`nAttempting download from primary source..." -ForegroundColor Yellow
                $primaryResult = Download-Extract-File -Url $downloadInfo.Link -OutputPath $driverPath -Prefix $downloadInfo.Prefix -ExpectedHash $downloadInfo.SHA256 -SourceName "Primary"

                if ($primaryResult.Success) {
                    $downloadSuccess = $true
                    Write-Host "SUCCESS: Primary source - download and hash verification successful." -ForegroundColor Green
                } else {
                    # Analyze primary source error
                    if ($primaryResult.ErrorType -eq "DownloadFailed") {
                        Write-Host "FAILED: Primary source - download failed" -ForegroundColor Red
                        $errorPhase = "1a"
                    } elseif ($primaryResult.ErrorType -eq "HashMismatch") {
                        $errorPhase = "1b"
                    } else {
                        Write-Host "FAILED: Primary source - unexpected error" -ForegroundColor Red
                        $errorPhase = "1x"
                    }

                    # Attempt 2: Backup Source (if available)
                    if ($downloadInfo.Backup) {
                        Write-Host "Attempting download from backup source..." -ForegroundColor Yellow
                        $backupPrefix = if ($downloadInfo.Prefix_B) { $downloadInfo.Prefix_B } else { $downloadInfo.Prefix }
                        
                        $backupResult = Download-Extract-File -Url $downloadInfo.Backup -OutputPath $driverPath -Prefix $backupPrefix -ExpectedHash $downloadInfo.SHA256_B -SourceName "Backup"
                        
                        if ($backupResult.Success) {
                            $downloadSuccess = $true
                            $usedBackup = $true
                            Write-Host "SUCCESS: Backup source - download and hash verification successful." -ForegroundColor Green
                        } else {
                            # Analyze backup source error
                            if ($backupResult.ErrorType -eq "DownloadFailed") {
                                Write-Host "FAILED: Backup source - download failed." -ForegroundColor Red
                                $errorPhase = "2a"
                            } elseif ($backupResult.ErrorType -eq "HashMismatch") {
                                $errorPhase = "2b"
                            } else {
                                Write-Host "FAILED: Backup source - unexpected error." -ForegroundColor Red
                                $errorPhase = "2x"
                            }
                        }
                    } else {
                        Write-Host "No backup source available" -ForegroundColor Red
                    }
                }

                # Final decision based on download success
                if (-not $downloadSuccess) {
                    switch ($errorPhase) {
                        "1a" { 
                            Write-Host "`nERROR: Primary source download failed and no backup available" -ForegroundColor Red
                            Write-Host "Check your internet connection or the primary URL." -ForegroundColor Yellow
                        }
                        "1b" { 
                            Write-Host "`nERROR: Primary source file corrupted (hash mismatch) and no backup available" -ForegroundColor Red
                            Write-Host "The downloaded file may be tampered or incomplete." -ForegroundColor Yellow
                        }
                        "2a" { 
                            Write-Host "`nERROR: Both primary and backup sources download failed" -ForegroundColor Red
                            Write-Host "Check your internet connection and URL availability." -ForegroundColor Yellow
                        }
                        "2b" { 
                            Write-Host "`nERROR: Both primary and backup sources have hash mismatches" -ForegroundColor Red
                            Write-Host "Files may be corrupted on both servers." -ForegroundColor Yellow
                        }
                        default {
                            Write-Host "`nERROR: Unknown download error" -ForegroundColor Red
                        }
                    }
                    continue
                }

                # Proceed with installation if download was successful
                if (Install-ChipsetINF -INFPath $driverPath -Prefix $(if ($usedBackup -and $downloadInfo.Prefix_B) { $downloadInfo.Prefix_B } else { $downloadInfo.Prefix })) {
                    $successCount++
                    $processedPackages[$cleanPackageVersion] = $true
                    Write-Host "Successfully installed package $cleanPackageVersion for $($platforms.Count) platform(s)." -ForegroundColor Green
                    Write-DebugMessage "Installation successful for package: $cleanPackageVersion"
                } else {
                    Write-Host "Failed to install INF files." -ForegroundColor Red
                    Write-DebugMessage "Installation failed for package: $cleanPackageVersion"
                }
            } else {
                Write-Host "Error: Download information not found for package version $cleanPackageVersion (variant: $variant)" -ForegroundColor Red
                Write-Host "Please check Intel_Chipset_INFs_Download.txt for missing entries." -ForegroundColor Yellow
                Write-DebugMessage "Download key not found: $downloadKey"
            }
        }

        if ($successCount -gt 0) {
            Write-Host "`nIMPORTANT NOTICE:" -ForegroundColor Yellow
            Write-Host "Computer restart is required to complete INF installation!" -ForegroundColor Yellow
            
            Write-Host "`nSummary: Installed $successCount unique package(s) for all detected platforms." -ForegroundColor Green
            Write-DebugMessage "Installation summary: $successCount successful packages."
        } else {
            Write-Host "`nNo INF files were successfully installed." -ForegroundColor Red
            Write-DebugMessage "No packages were successfully installed."
        }
    } else {
        Write-Host "Update cancelled." -ForegroundColor Yellow
        Write-DebugMessage "User cancelled the update."
    }

    # Clean up
    Write-Host "`nCleaning up temporary files..." -ForegroundColor Gray
    Clear-TempINFFolders

    # Show final summary
    Show-FinalSummary

    Write-Host "`nINF files update process completed." -ForegroundColor Cyan
    Write-Host "If you have any issues with this tool, please report them at:"
    Write-Host "https://github.com/FirstEverTech/Universal-Intel-Chipset-Updater" -ForegroundColor Cyan

    if ($DebugMode -eq 1) {
        Write-Host "`n[DEBUG MODE ENABLED - All debug messages were shown]" -ForegroundColor Magenta
    }
}
catch {
    Write-Log "Unhandled error in main execution: $($_.Exception.Message)" -Type "ERROR"
    Write-Host "An unexpected error occurred. Please check the log file at $logFile for details." -ForegroundColor Red
    Clear-TempINFFolders
    exit 1
}

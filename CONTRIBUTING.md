# Contributing to Universal Intel Chipset Updater

First off, thank you for considering contributing to Universal Intel Chipset Updater! It's people like you that make this tool better for everyone.

Following these guidelines helps to communicate that you respect the time of the developers managing and developing this open source project. In return, they should reciprocate that respect in addressing your issue, assessing changes, and helping you finalize your pull requests.

---

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [What We're Looking For](#what-were-looking-for)
3. [How to Contribute](#how-to-contribute)
4. [Reporting Bugs](#reporting-bugs)
5. [Suggesting Enhancements](#suggesting-enhancements)
6. [Your First Code Contribution](#your-first-code-contribution)
7. [Pull Request Process](#pull-request-process)
8. [Style Guidelines](#style-guidelines)
9. [Community](#community)

---

## Code of Conduct

This project and everyone participating in it is expected to follow basic principles of respect and constructive collaboration:

- **Be respectful**: Treat all contributors with respect and dignity
- **Be constructive**: Provide helpful feedback and suggestions
- **Be patient**: Remember that contributors may be working on this in their free time
- **Be inclusive**: Welcome contributors of all skill levels and backgrounds

---

## What We're Looking For

We love contributions from the community! Here are some ways you can help:

### High Priority Areas
- 🐛 **Bug reports and fixes** - Help us identify and resolve issues
- 🔒 **Security improvements** - Enhanced verification or safety features
- 📚 **Documentation** - Improvements to README, guides, or code comments
- 🌍 **Translations** - Additional language support beyond English and Polish
- 🧪 **Testing** - Testing on various Windows versions and Intel chipset generations

### Medium Priority Areas
- ✨ **Feature enhancements** - Improvements to existing functionality
- 🔧 **Code optimization** - Performance improvements and refactoring
- 📊 **Hardware support** - Testing and validation on new Intel platforms
- 🎨 **User experience** - Interface improvements and user feedback

### Ideas We're Open To
- Alternative download sources for improved reliability
- Enhanced logging and diagnostic capabilities
- Integration with system management tools
- Automated testing frameworks
- Cross-platform compatibility exploration (if feasible)

---

## How to Contribute

### Quick Start

1. **Fork** the repository
2. **Clone** your fork: `git clone https://github.com/YOUR-USERNAME/Universal-Intel-Chipset-Updater.git`
3. **Create** a branch: `git checkout -b feature/your-feature-name`
4. **Make** your changes
5. **Test** thoroughly
6. **Commit** with clear messages: `git commit -m "Add feature: description"`
7. **Push** to your fork: `git push origin feature/your-feature-name`
8. **Open** a Pull Request

---

## Reporting Bugs

### Before Submitting a Bug Report

1. **Check the [Known Issues](https://github.com/FirstEverTech/Universal-Intel-Chipset-Updater/blob/main/KNOWN_ISSUES.md)** - Your issue might already be documented
2. **Search existing issues** - Someone may have already reported it
3. **Update to the latest version** - The bug might already be fixed
4. **Enable debug mode** - Set `$DebugMode = 1` in the PowerShell script for detailed logs

### How to Submit a Good Bug Report

Use the **Bug Report** issue template and include:

**Required Information:**
- **System Information**:
  - Windows version (e.g., Windows 11 23H2)
  - PowerShell version: Run `$PSVersionTable.PSVersion`
  - Intel chipset/platform (if known)
- **Script Version**: Which release you're using (e.g., v10.1-2025.11.5)
- **Expected Behavior**: What you expected to happen
- **Actual Behavior**: What actually happened
- **Steps to Reproduce**: Detailed steps to recreate the issue
- **Log Files**: Attach or paste relevant sections from `C:\Windows\Temp\IntelChipset\chipset_update.log`
- **Screenshots**: If applicable, especially for UI issues

**Example Bug Report:**
```markdown
**System**: Windows 11 23H2, PowerShell 5.1, Intel Z690 chipset
**Version**: v10.1-2025.11.5
**Issue**: Hash verification fails with "Source/Actual mismatch"

**Steps to Reproduce**:
1. Run script as administrator
2. Select option to download and install
3. Download completes but hash verification fails

**Log Output**:
[paste relevant log section here]

**Expected**: Hash should match and installation should proceed
**Actual**: Error message displayed and installation aborted
```

---

## Suggesting Enhancements

### Before Submitting an Enhancement

1. **Check if it's already implemented** in the latest version
2. **Search existing feature requests** in issues
3. **Consider the scope** - Does it align with the project's goals?

### How to Submit a Good Enhancement Request

Use the **Feature Request** issue template and include:

- **Clear Title**: Concise description of the enhancement
- **Problem Statement**: What problem does this solve?
- **Proposed Solution**: How would you implement it?
- **Alternatives Considered**: Other approaches you've thought about
- **Use Cases**: Real-world scenarios where this would be useful
- **Impact**: Who would benefit from this?

**Example Feature Request:**
```markdown
**Title**: Add support for exporting hardware scan results to CSV

**Problem**: Users cannot easily share or analyze their chipset configuration

**Proposed Solution**: 
Add a `-ExportCSV` parameter that saves detected HWIDs and driver versions to a CSV file

**Use Cases**:
- IT administrators managing multiple systems
- Users comparing configurations across devices
- Troubleshooting hardware detection issues

**Benefits**: Improved diagnostics and system documentation
```

---

## Your First Code Contribution

Unsure where to begin? Look for issues labeled:

- `good first issue` - Simple issues perfect for newcomers
- `help wanted` - Issues where we'd especially appreciate help
- `documentation` - Great for non-coding contributions

### Setting Up Your Development Environment

1. **Install Prerequisites**:
   - Windows 10/11 with PowerShell 5.0+
   - Git for version control
   - A code editor (VS Code recommended with PowerShell extension)

2. **Fork and Clone**:
   ```bash
   git clone https://github.com/YOUR-USERNAME/Universal-Intel-Chipset-Updater.git
   cd Universal-Intel-Chipset-Updater
   ```

3. **Create a Test Branch**:
   ```bash
   git checkout -b test/your-test-name
   ```

4. **Test Your Changes**:
   - Run the script with `$DebugMode = 1` enabled
   - Test on your own system first
   - Check for any error messages or warnings

---

## Pull Request Process

### Before Submitting

- ✅ **Test thoroughly** on your system
- ✅ **Follow style guidelines** (see below)
- ✅ **Update documentation** if adding/changing features
- ✅ **Add comments** for complex logic
- ✅ **Check for typos** and formatting consistency

### Pull Request Checklist

1. **Clear Title**: Descriptive PR title (e.g., "Fix: Resolve hash verification cache issue")
2. **Description**: Explain what changes you made and why
3. **Link Issues**: Reference related issues (e.g., "Fixes #123")
4. **Test Results**: Describe how you tested your changes
5. **Screenshots**: Include if relevant (especially for UI changes)

### PR Template Example

```markdown
## Description
Brief description of what this PR does

## Related Issues
Fixes #123, Relates to #456

## Changes Made
- Added feature X
- Fixed bug Y
- Updated documentation Z

## Testing Performed
- Tested on Windows 11 23H2
- Verified with Intel Z690 chipset
- Confirmed hash verification works correctly

## Screenshots (if applicable)
[Paste screenshots here]

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] Tested on my system
- [ ] No new warnings or errors
```

### Review Process

1. **Automated Checks**: (When CI/CD is implemented) Your PR must pass all checks
2. **Code Review**: Maintainers will review your code
3. **Feedback**: Address any requested changes
4. **Approval**: Once approved, your PR will be merged
5. **Credit**: You'll be credited in the release notes!

---

## Style Guidelines

### PowerShell Code Style

#### General Principles
- **Clarity over cleverness**: Readable code is maintainable code
- **Consistent formatting**: Follow existing code patterns
- **Meaningful names**: Use descriptive variable and function names
- **Error handling**: Always include proper error checking

#### Naming Conventions
```powershell
# Variables: PascalCase
$DownloadUrl = "https://example.com"
$HashValue = "abc123..."

# Functions: Verb-Noun format, PascalCase
function Get-IntelHardwareId { }
function Test-FileSignature { }

# Constants: ALL_CAPS with underscores
$TEMP_DIR = "C:\Windows\Temp\IntelChipset"
$VENDOR_ID = "8086"
```

#### Code Formatting
```powershell
# Use 4-space indentation (no tabs)
if ($condition) {
    Write-Host "Message"
    # Nested code
    foreach ($item in $collection) {
        Process-Item $item
    }
}

# Line length: Keep under 120 characters when possible
# Break long lines logically
$result = Invoke-WebRequest `
    -Uri $url `
    -Method Get `
    -Headers $headers

# Space around operators
$sum = $a + $b
$isValid = ($value -eq $expected)
```

#### Comments
```powershell
# Single-line comments for brief explanations
$retryCount = 3  # Maximum retry attempts

# Multi-line comments for complex logic
<#
    This function verifies the digital signature of downloaded files
    by checking against Intel Corporation certificates in the system store.
    Returns $true if signature is valid, $false otherwise.
#>
function Test-IntelSignature {
    # Implementation
}

# TODO comments for future improvements
# TODO: Add support for custom download directories
```

#### Error Handling
```powershell
# Always use try-catch for operations that can fail
try {
    $result = Invoke-WebRequest -Uri $url
    # Process result
}
catch {
    Write-Host "Error: Failed to download file - $_" -ForegroundColor Red
    # Fallback logic or cleanup
}

# Validate inputs
if (-not $filePath) {
    Write-Error "File path is required"
    return
}
```

### Documentation Style

#### README and Markdown Files
- Use clear, concise language
- Break up text with headers and lists
- Include examples for complex concepts
- Keep line length reasonable (80-100 characters in paragraphs)
- Use proper Markdown formatting

#### Code Comments
- Explain **why**, not **what** (code shows what)
- Update comments when code changes
- Use clear, professional language
- Avoid redundant comments

**Good:**
```powershell
# Retry with backup URL if primary source is unavailable
$downloadUrl = $backupUrl
```

**Bad:**
```powershell
# Set download URL to backup URL
$downloadUrl = $backupUrl
```

---

## Community

### Getting Help

- 💬 **GitHub Issues**: Best place for bugs and feature requests
- 📖 **Documentation**: Check README and KNOWN_ISSUES first
- 🔍 **Search**: Look for existing discussions before posting

### Project Resources

- [Project Website](https://www.firstever.tech)
- [GitHub Repository](https://github.com/FirstEverTech/Universal-Intel-Chipset-Updater)
- [Security Policy](https://github.com/FirstEverTech/Universal-Intel-Chipset-Updater/blob/main/SECURITY.md)
- [Latest Release](https://github.com/FirstEverTech/Universal-Intel-Chipset-Updater/releases/latest)

### Recognition

Contributors will be:
- Listed in release notes
- Credited in the project README (for significant contributions)
- Appreciated by the entire community! 🎉

---

## Questions?

Don't hesitate to ask questions! You can:
1. Open an issue with the `question` label
2. Check if your question is already answered in existing issues
3. Reach out via the contact information in the README

---

## License

By contributing to Universal Intel Chipset Updater, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing! Your efforts make this project better for everyone.** 🚀

---

*This contributing guide is inspired by open source best practices and adapted for this project's specific needs.*
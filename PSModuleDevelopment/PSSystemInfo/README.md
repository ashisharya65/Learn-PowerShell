# PSSystemInfo

> ⚠️ **Disclaimer: This is a test module created purely for learning and demonstration purposes. It is not published to the PowerShell Gallery.**

`PSSystemInfo` is a lightweight, cross-platform PowerShell module designed to retrieve essential system information quickly. It is built to work seamlessly across Windows, Linux, and macOS using PowerShell Core (v7+).

## Features

- **Cross-Platform Compatibility:** Works on any OS running PowerShell 7 or later.
- **System Information:** Easily retrieve the computer name, operating system details, and system uptime.
- **Clean Output:** Returns data as a standardized `PSCustomObject` for easy filtering and pipeline integration.

## Installation (Local)

Since this module is for testing purposes and not available on the PowerShell Gallery, you can use it locally by following these steps:

1. Clone or download this repository to your local machine.
2. Open PowerShell 7+.
3. Navigate to the directory containing the module.
4. Import the module using its manifest file:

```powershell
Import-Module ./PSSystemInfo.psd1
```

## Usage

Once imported, you can use its commands. 

```powershell
# Get basic system information
Get-SystemInfo
```

**Example Output:**

```text
ComputerName OS                                Uptime
------------ --                                ------
TEST-PC      Linux 5.15.0-generic              2 Days, 4 Hours, 15 Minutes
```

## Exported Functions

### `Get-SystemInfo`
Retrieves the basic details of the system it runs on.

**Properties Returned:**
- `ComputerName`: The hostname of the machine.
- `OS`: The specific operating system version (retrieved via `$PSVersionTable.OS`).
- `Uptime`: A human-readable string representing how long the system has been running. (e.g., "1 Days, 4 Hours, 30 Minutes").

## Requirements
- **PowerShell 7.0+ (Core)** for cross-platform support on Linux, macOS, and Windows.
- **Windows PowerShell 5.1** is also fully supported for backwards compatibility on older Windows machines.

## License
This project is licensed under the MIT License.

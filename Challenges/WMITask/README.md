# Problem Statement

## Objective

Develop a PowerShell script that retrieves comprehensive system information using Windows Management Instrumentation (WMI) and stores it in a custom PowerShell object. This information should include the computer name, operating system, CPU, architecture, logical disks with more than 80% free space, installed applications within a specified date range, the IP address of a specified network adapter, and the count of hotfixes installed within a specified date range.

## Requirements

1. **Parameters**:

   - **NetworkAdapter**: The name of the network adapter to retrieve the IP address from.
   - **StartDate**: The start date for filtering installed applications and patches.
   - **EndDate**: The end date for filtering installed applications and patches.

2. **Output**:
   A custom PowerShell object containing the following fields:
   - **Computername**: The name of the computer.
   - **OS**: The name of the operating system.
   - **CPU**: The name of the processor.
   - **Arch**: The architecture of the operating system (32-bit or 64-bit).
   - **Memory**: The number of logical disks with more than 80% free space.
   - **InstalledApps**: The number of applications installed within the specified date range.
   - **IPAddress**: The IP address of the specified network adapter.
   - **Patches**: The number of hotfixes installed within the specified date range.

## Constraints

- Ensure that all date parsing is handled correctly, and any errors in date parsing should be managed gracefully.
- The script should be robust and handle cases where certain WMI classes or properties might not be available.
- The script should provide verbose logging in case of any issues or failures during the execution.

## Example Usage

```powershell
.\Solution.ps1 -NetworkAdapter "MediaTek Wi-Fi 6 MT7921 Wireless LAN Card" -StartDate "2024/05/01" -EndDate "2024/07/01"
```

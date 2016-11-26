<#
Disclaimer

This code is provided without copyright and “AS IS”.  It is free for you to use and modify under the MIT license.
Note: All scripts require WMF 5 or above, and to run from PowerShell using "Run as Administrator"

#>
#Requires -version 5.0
#Requires -runasadministrator
Clear-Host
Write-Host -ForegroundColor Green -Object @"

    This is the Setup-Host script. This script will perform the following:
    * Set the host 'TrustedHosts' value to * for PowerShell Remoting
    * Install the Lability module from PSGallery
    * Install Hyper-V if not installed
    * Create the C:\Lability folder
    * Copy configurations and resources to C:\Lability
    * Reboot the host


"@

Pause


# For remoting commands to VM's - have the host set trustedhosts
Enable-PSremoting -force

Write-Host -ForegroundColor Cyan -Object "Setting TrustedHosts so that remoting commands to VMs work properly"
$trust = Get-Item -Path WSMan:\localhost\Client\TrustedHosts
if ($Trust.Value -eq "*") {
    Write-Host -ForegroundColor Green -Object "TrustHosts is already set to *. No changes needed"
}
else {
    $add = '*'
    Write-Host -ForegroundColor Cyan -Object "Adding $add to TrustedHosts"
    Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value $add -Concatenate -force
}

# Lability install
Write-Host -ForegroundColor Cyan "Installing Lability for the lab build"
Get-PackageSource -Name PSGallery | Set-PackageSource -Trusted -Force -ForceBootstrap
Install-Module -Name Lability -RequiredVersion 0.10.0 -Force -SkipPublisherCheck

# Installing modules needed to run configs - this will be replaced
Install-Module -Name xActiveDirectory -RequiredVersion 2.13.0.0
Install-Module -Name xComputerManagement -RequiredVersion 1.8.0.0
Install-Module -Name xNetworking -RequiredVersion 2.12.0.0
Install-Module -Name xDhcpServer -RequiredVersion 1.5.0.0
Install-Module -Name xADCSDeployment -RequiredVersion 1.0.0.0
Install-Module -Name xDnsServer -RequiredVersion 1.7.0.0

# Setup host Env.
$HostStatus=Test-LabHostConfiguration
If ($HostStatus -eq $False) {
    Write-Host -ForegroundColor Cyan "Starting to Initialize host and install Hyper-V" 
    Start-LabHostConfiguration -ErrorAction SilentlyContinue -Verbose
}

###### COPY Configs to host machine
Write-Host -ForegroundColor Cyan -Object "Copying configs to c:\Lability\Configurations" 
Copy-item -Path C:\PS-AutoLab-Env\Configurations\* -recurse -Destination C:\Lability\Configurations -force

#### Temp fix until Lability updates version with new media File
#### Copying new media file manually
Copy-item -Path C:\PS-AutoLab-Env\media.json -Destination 'C:\Program Files\WindowsPowershell\Modules\Lability\0.10.0\config'

$HostStatus=Test-LabHostConfiguration
If ($HostStatus -eq $False) {
    Write-Host -ForegroundColor Yellow -Object "The machine is about to reboot."
    Pause
    Restart-Computer
} else {
Write-Host -ForegroundColor Yellow -Object "All done!"
}

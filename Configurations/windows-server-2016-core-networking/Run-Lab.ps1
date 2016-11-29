<#
Disclaimer

This code is provided without copyright and “AS IS”.  It is free for you to use and modify under the MIT license.
Note: All scripts require WMF 5 or above, and to run from PowerShell using "Run as Administrator"

#>
#Requires -version 5.0
#Requires -runasadministrator

Clear-Host
Write-Host -ForegroundColor Green -Object @"

    This is the Run-Lab script. This script will perform the following:
    
    * Start the Lab environment
    
    Note! If this is the first time you have run this, it will take about 30 minutes for the DSC configs to apply. 
   
    To stop the lab VM's:
    .\Shutdown-lab.ps1

"@

Pause

Write-Host -ForegroundColor Cyan -Object 'Starting the lab environment'
# Creates the lab environment without making a Hyper-V Snapshot
Start-Lab -ConfigurationData .\*.psd1 

Write-Host -ForegroundColor Green -Object @"

    Next Steps:

    To stop the lab VM's:
    .\Shutdown-lab.ps1

"@


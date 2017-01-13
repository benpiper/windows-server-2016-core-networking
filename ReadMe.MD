
# Pluralsight PowerShell Automated Lab Environment
This is an automated lab environment build tool to support learners in designing and building a virtual lab environment for the course *[Implementing and Securing Windows Server 2016 Core Networking](https://www.pluralsight.com/courses/windows-server-2016-core-networking)*.

The configurations for the VM are written in Microsoft PowerShell DSC and deployed using [VirtualEngine Lability](https://github.com/VirtualEngine/Lability). This tool will completely build a lab environment from scratch.

# Requirements
The host computer must have the following:
* WMF 5 (Windows Management Framework 5)
* An internet connection

## This Lab tool currently supports running on a host:
* Windows Server 2016
* Windows 10 client with SLAT

# Instructions 
Refer to the course for the proper usage of this tool.

_Note - If you do not provide the [Windows Server 2016 Evaluation ISO](http://bit.ly/win2016iso), then the first time you run Setup-Lab.ps1, it will download all required files including ISOs and DSCResources.
This initial ISO download may require several hours depending on your Internet connection but it only happens the first time.
You will be able to build and wipe the Lab quickly in future._

## Other scripts you will need:
You will receive reminders and instructions when to run these when you start the .\Setup-Lab script.

* .\Run-Lab.ps1 _(Starts the Lab environment)_
* .\Shutdown-Lab.ps1 _(Stops the lab VM's)_
* .\Wipe-Lab.ps1 _(Wipe the lab and VM's from your system)_

_NOTE - Configuration convergence takes about 30 minutes and several reboots - do not turn off machines until they finish.

# Current and Future Developmentfs
_Please make recommendations or fork this repo and share your own!!!_

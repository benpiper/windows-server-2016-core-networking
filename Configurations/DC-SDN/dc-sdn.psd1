<# Notes:

Goal - Create a Domain Controller, Populute with OU's Groups and Users.
       

Disclaimer

This example code is provided without copyright and AS IS.  It is free for you to use and modify.
Note: These demos should not be run as a script. These are the commands that I use in the 
demonstrations and would need to be modified for your environment.

#> 

@{
    AllNodes = @(
        @{
            NodeName = '*'
            
            # Common networking
            InterfaceAlias = 'Ethernet'
            DefaultGateway = '192.168.80.1'
            SubnetMask = 24
            AddressFamily = 'IPv4'
            DnsServerAddress = '192.168.80.10'           
                       
            # Domain and Domain Controller information
            DomainName = "Company.Pri"
            DomainDN = "DC=Company,DC=Pri"
            DCDatabasePath = "C:\NTDS"
            DCLogPath = "C:\NTDS"
            SysvolPath = "C:\Sysvol"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true 
                        
            # Lability default node settings
            Lability_SwitchName = 'Management'
            Lability_ProcessorCount = 2
            Lability_StartupMemory = 2GB
            Lability_MaximumMemory = 2GB
            Lability_MinimumMemory = 2GB
            SecureBoot = $false
            Lability_Media = '2016_x64_Datacenter_Core_EN_Eval' # Can be Core,Win10,2012R2,nano
                                                       # 2016_x64_Standard_EN_Eval
                                                       # 2016_x64_Standard_Core_EN_Eval
                                                       # 2016_x64_Datacenter_EN_Eval
                                                       # 2016_x64_Datacenter_Core_EN_Eval
                                                       # 2016_x64_Standard_Nano_EN_Eval
                                                       # 2016_x64_Datacenter_Nano_EN_Eval
                                                       # 2012R2_x64_Standard_EN_Eval
                                                       # 2012R2_x64_Standard_EN_V5_Eval
                                                       # 2012R2_x64_Standard_Core_EN_Eval
                                                       # 2012R2_x64_Standard_Core_EN_V5_Eval
                                                       # 2012R2_x64_Datacenter_EN_V5_Eval
                                                       # WIN10_x64_Enterprise_EN_Eval
        }
        @{
            NodeName = 'DC-SDN'
            IPAddress = '192.168.80.10'
            MacAddress = '001DC8B70110'           
            Role = 'DC'
            Lability_BootOrder = 10
            Lability_BootDelay = 5 # Number of seconds to delay before others
            Lability_timeZone = 'US Eastern Standard Time' #[System.TimeZoneInfo]::GetSystemTimeZones()
        }      

        
    );
    NonNodeData = @{
        Lability = @{
            # EnvironmentPrefix = 'PS-GUI-' # this will prefix the VM names                                    
            Media = @(); # Custom media additions that are different than the supplied defaults (media.json)
            Network = @( # Virtual switch in Hyper-V
                @{ Name = 'Management'; Type = 'External'; NetAdapterName = 'Management'; AllowManagementOS = $true;}
            );
            DSCResource = @(
                ## Download published version from the PowerShell Gallery or Github
                @{ Name = 'xActiveDirectory'; RequiredVersion="2.13.0.0"; Provider = 'PSGallery'; },
                @{ Name = 'xComputerManagement'; RequiredVersion = '1.8.0.0'; Provider = 'PSGallery'; }
                @{ Name = 'xNetworking'; RequiredVersion = '2.12.0.0'; Provider = 'PSGallery'; }
                @{ Name = 'xDnsServer'; RequiredVersion = '1.7.0.0'; Provider = 'PSGallery'; }

            );
        };
    };
};

<# Notes:


#> 

@{
    AllNodes = @(
        @{
            NodeName = '*'
            
            # Common networking
            InterfaceAlias = 'Ethernet'                 
                       
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
            NodeName = 'DC'
            IPAddress = '192.168.3.10'
            DefaultGateway = '192.168.3.1'
            SubnetMask = 24
            AddressFamily = 'IPv4'
            DnsServerAddress = '192.168.3.10'      
            DnsForwarder = @('192.168.3.1')
            Role = 'DC'
            Lability_BootOrder = 10
            Lability_BootDelay = 5 # Number of seconds to delay before others
            Lability_timeZone = 'US Eastern Standard Time' #[System.TimeZoneInfo]::GetSystemTimeZones()
        },
        @{
            NodeName = 'FILE1'
            Role = 'FileServer'
            Lability_BootOrder = 20
            Lability_BootDelay = 30 # Number of seconds to delay before others
            Lability_timeZone = 'US Eastern Standard Time' #[System.TimeZoneInfo]::GetSystemTimeZones()
        },
        @{
            NodeName = 'FILE2'
            Role = 'FileServer'
            Lability_BootOrder = 30
            Lability_BootDelay = 60 # Number of seconds to delay before others
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

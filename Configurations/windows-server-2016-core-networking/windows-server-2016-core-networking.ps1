<# Notes:

Disclaimer

This example code is provided without copyright and AS IS.  It is free for you to use and modify.
Note: These demos should not be run as a script. These are the commands that I use in the 
demonstrations and would need to be modified for your environment.

#> 

Configuration AutoLab {

    param (
        [Parameter()] 
        [ValidateNotNull()] 
        [PSCredential] $Credential = (Get-Credential -Credential Administrator)
    )

#region DSC Resources
    Import-DSCresource -ModuleName PSDesiredStateConfiguration,
        @{ModuleName="xActiveDirectory";ModuleVersion="2.13.0.0"},
        @{ModuleName="xComputerManagement";ModuleVersion="1.8.0.0"},
        @{ModuleName="xNetworking";ModuleVersion="2.12.0.0"},
        @{ModuleName="xDnsServer";ModuleVersion="1.7.0.0"}

#endregion

    node $AllNodes.Where({$true}).NodeName {
#region LCM configuration
       
        LocalConfigurationManager {
            RebootNodeIfNeeded   = $true
            AllowModuleOverwrite = $true
            ConfigurationMode = 'ApplyOnly'
        }

#endregion
  
#region IPaddress settings 

 
    If (-not [System.String]::IsNullOrEmpty($node.IPAddress)) {
        xIPAddress 'PrimaryIPAddress' {
            IPAddress      = $node.IPAddress
            InterfaceAlias = $node.InterfaceAlias
            SubnetMask     = $node.SubnetMask
            AddressFamily  = $node.AddressFamily
        }

        If (-not [System.String]::IsNullOrEmpty($node.DefaultGateway)) {     
            xDefaultGatewayAddress 'PrimaryDefaultGateway' {
                InterfaceAlias = $node.InterfaceAlias
                Address = $node.DefaultGateway
                AddressFamily = $node.AddressFamily
            }
        }

        If (-not [System.String]::IsNullOrEmpty($node.DnsServerAddress)) {                    
            xDnsServerAddress 'PrimaryDNSClient' {
                Address        = $node.DnsServerAddress
                InterfaceAlias = $node.InterfaceAlias
                AddressFamily  = $node.AddressFamily
            }
        }

        If (-not [System.String]::IsNullOrEmpty($node.DnsConnectionSuffix)) {
            xDnsConnectionSuffix 'PrimaryConnectionSuffix' {
                InterfaceAlias = $node.InterfaceAlias
                ConnectionSpecificSuffix = $node.DnsConnectionSuffix
            }
        }
    } #End IF
            
#endregion

#region Firewall Rules
<#
        xFirewall Firewall {
            Name = 'AllowMgmtNetwork'
            DisplayName = 'Allow management network'
            Ensure = 'Present'
            Enabled = 'True'
            Profile = 'Any'
            Direction = 'Inbound'
            Protocol = 'TCP'
            RemoteAddress = '192.168.88.1-192.168.88.254'
        }           #>      
                
        xFirewall 'FPS-ICMP4-ERQ-In' {
            Name = 'FPS-ICMP4-ERQ-In'
            DisplayName = 'File and Printer Sharing (Echo Request - ICMPv4-In)'
            Description = 'Echo request messages are sent as ping requests to other nodes.'
            Direction = 'Inbound'
            Action = 'Allow'
            Enabled = 'True'
            Profile = 'Any'
        }

        xFirewall 'FPS-ICMP6-ERQ-In' {
            Name = 'FPS-ICMP6-ERQ-In';
            DisplayName = 'File and Printer Sharing (Echo Request - ICMPv6-In)'
            Description = 'Echo request messages are sent as ping requests to other nodes.'
            Direction = 'Inbound'
            Action = 'Allow'
            Enabled = 'True'
            Profile = 'Any'
        }

        xFirewall 'FPS-SMB-In-TCP' {
            Name = 'FPS-SMB-In-TCP'
            DisplayName = 'File and Printer Sharing (SMB-In)'
            Description = 'Inbound rule for File and Printer Sharing to allow Server Message Block transmission and reception via Named Pipes. [TCP 445]'
            Direction = 'Inbound'
            Action = 'Allow'
            Enabled = 'True'
            Profile = 'Any'
        }
#endregion

    } #end nodes ALL

#region Domain Controller config

    node $AllNodes.Where({$_.Role -eq 'DC'}).NodeName {

        $DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("$($node.DomainName)\$($Credential.UserName)", $Credential.Password)
      
        xComputer ComputerName { 
            Name = $Node.NodeName 
        }            

        ## Hack to fix DependsOn with hypens "bug" :(
        foreach ($feature in @(
                'DNS',
                'RSAT-DNS-Server'                           
                'AD-Domain-Services'
                'GPMC',
                'RSAT-AD-Tools' 
                'RSAT-AD-PowerShell'
                'RSAT-AD-AdminCenter'
                'RSAT-ADDS-Tools'

            )) {
            WindowsFeature $feature.Replace('-','') {
                Ensure = 'Present';
                Name = $feature;
                IncludeAllSubFeature = $False;
            }
        } #End foreach

            xADDomain FirstDC {
                DomainName = $Node.DomainName
                DomainAdministratorCredential = $Credential
                SafemodeAdministratorPassword = $Credential
                DatabasePath = $Node.DCDatabasePath
                LogPath = $Node.DCLogPath
                SysvolPath = $Node.SysvolPath 
                DependsOn = '[WindowsFeature]ADDomainServices'
            }  
        
        #Add OU, Groups, and Users


            xADOrganizationalUnit IT {
                Name = 'IT'
                Ensure = 'Present'
                Path = $Node.DomainDN
                ProtectedFromAccidentalDeletion = $False
                DependsOn = '[xADDomain]FirstDC'
            }
           

            # Users
            xADUser IT1 {
                DomainName = $node.DomainName
                Path = "OU=IT,$($node.DomainDN)"
                UserName = 'PSIT'
                GivenName = 'Pluralsight'
                Surname = 'IT'
                DisplayName = 'Pluralsight IT'
                Description = 'Pluralsight IT'
                Department = 'IT'
                Enabled = $true
                Password = $DomainCredential
                DomainAdministratorCredential = $DomainCredential
                PasswordNeverExpires = $true
                DependsOn = '[xADDomain]FirstDC'
            }

            xADUser IT2 {
                DomainName = $node.DomainName
                Path = "OU=IT,$($node.DomainDN)"
                UserName = 'bpiper'
                GivenName = 'Ben'
                Surname = 'Piper'
                DisplayName = 'Ben Piper'
                Description = 'Your 1337 teacher'
                Department = 'IT'
                Enabled = $true
                Password = $DomainCredential
                DomainAdministratorCredential = $DomainCredential
                PasswordNeverExpires = $true
                DependsOn = '[xADDomain]FirstDC'
            }

          
            #Groups
            xADGroup ITG1 {
                GroupName = 'IT'
                Path = "OU=IT,$($node.DomainDN)"
                Category = 'Security'
                GroupScope = 'Universal'
                Members = 'PSIT', 'bpiper'
                DependsOn = '[xADDomain]FirstDC'
            }

            xADGroup NCManagementAdmins {
                GroupName = 'NCManagementAdmins'
                Category = 'Security'
                GroupScope = 'DomainLocal'
                Members = 'Administrator', 'bpiper', 'PSIT'
                DependsOn = '[xADDomain]FirstDC'
            }                 

            xADGroup NCRestClients {
                GroupName = 'NCRestClients'
                Category = 'Security'
                GroupScope = 'DomainLocal'
                Members = 'Administrator', 'bpiper', 'PSIT'
                DependsOn = '[xADDomain]FirstDC'
            }

            xADGroup DNSAdmins {
                GroupName = 'DNSAdmins'
                Category = 'Security'
                GroupScope = 'DomainLocal'
                Members = 'Administrator'
                DependsOn = '[xADDomain]FirstDC'
            }

            xDnsServerForwarder SetForwarder {
                IPAddresses = $Node.DnsForwarder
                IsSingleInstance = 'Yes'
                DependsOn = '[xADDomain]FirstDC'
            }
            

           
       
    } #end nodes DC

#endregion 


#region File server config
   node $AllNodes.Where({$_.Role -eq 'FileServer'}).NodeName {
        
        foreach ($feature in @(
                'FS-FileServer'
                'FS-DFS-Namespace'
                'FS-DFS-Replication'

            )) {
            WindowsFeature $feature.Replace('-','') {
                Ensure = 'Present'
                Name = $feature
                IncludeAllSubFeature = $False
            }
        }
        
    }#end File server Config


#region DomainJoin config
   node $AllNodes.Where({$_.Role -eq 'DomainJoin'}).NodeName {

    $DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("$($node.DomainName)\$($Credential.UserName)", $Credential.Password)
 
        xWaitForADDomain DscForestWait {
            DomainName = $Node.DomainName
            DomainUserCredential = $DomainCredential
            RetryCount = '20'
            RetryIntervalSec = '60'
        }

         xComputer JoinDC {
            Name = $Node.NodeName
            DomainName = $Node.DomainName
            Credential = $DomainCredential
            DependsOn = '[xWaitForADDomain]DSCForestWait'
        }
    }#end DomianJoin Config
#endregion
#>
} # End AllNodes
#endregion

AutoLab -OutputPath .\ -ConfigurationData .\windows-server-2016-core-networking.psd1


<#
	===========================================================================
	 Created with: 	PowerShell ISE (Win11 22621)
	 Revision:      v2
	 Last Modified:	02 Oct 2025
	 Created by:   	Jay Harper (github.com/thecatdidit/powershellusefulscripts)
	 Organizaiton: 	Happy Days Are Here Again
	 Filename:     	Create-CMDetailedDeviceReport.ps1
	===========================================================================
	.CHANGELOG
	 v2 [02 Oct 2025
	 Updated comments to correct spelling and grammar issues
	 v1 [14 Dec 2018]
	 Script initial creation
	 
	.SYNOPSIS
        Script to query Device-Based Collection(s) and return detailed data
        for each machine. This can be run against Windows workstations and
        servers.

	.DESCRIPTION   
        Queries members of a Device-Based Collection and returns detailed data
        for each machine.

        The information is then exported to a CSV file for import into Excel
        or other application.

        Entries are added to a single variable which can be passed through to
        other scripts, queried for specific values and exported to other
        data sources. 

        Information returned includes:

        * Computer Name
        * Collection ID
        * Hardware Model
        * Processor/Architecture Type
        * User Full Name (AD cross-reference of the logged in username)
        * User Email Address (AD cross-reference)
        * Manager Name (AD cross-reference)
        * Manager Email Address (AD cross-reference)
        * OS Name
        * OS Build (Good for tracking WaaS builds)
        * Product Name (When querying for a specific application)
        * Product Version
        * ISActive (Has the machine reported to SCCM within your active device timeframe?)
        * Last Policy Request (The last time ConfigMgr client has requested policy from MP)
        * IP Address (Returns the first metric NIC's network info. Adjust as needed)
        
        Comment out any values that are not required. The fewer values, the faster
        the report will process.

        The information is designed to be useful for technicians, decision makers
        or as part of project status reports. 

	.USAGE
        PS C:\Create-DetailedDeviceReport.ps1

	.INPUTS
        None at this timeframe

	.OUTPUTS
        CSV file with each row containing queried device details.
        The file is saved under 'C:\Temp' by default. To change
        location, update the $ExportFileName variable. The directory
        will be added as a parameter in a future revision.

        The default config settings configured in this script would
        return entries such as the following:

        Computer          : WS-ABC123ZZ
        CollectionID      : COL8675309
        Model             : Dell Latitude 7390
        ProcessorType     : x64-based PC
        FullName          : Dilbert Johnson
        EmailAddress      : dilbert.johnson@cubicle.org
        ManagerName       : Dogbert Ramirez
        ManagerEmail      : dogbert.ramirez@cublcle.org
        OS                : Windows 10 Enterprise
        Build             : 10.0.15063.1446
        ProductName       : Symantec Endpoint Protection
        ProductVersion    : 14.2.1031.0100
        IsActive          : 1
        LastPolicyRequest : 12/14/2018 10:54:04 AM
        IPAddresses       : 172.16.100.98

	.NOTES
        I will work to create some script parameters for a future
        revision to make it easier to run for different scenarios.
#>

$computers = @()

##
# Add the requested values:
# SCCMName:    Management Point server name (FQDN)
# NameSpace:   Site Code
# Collections: Can be one or more collections (e.g. "COL001","COL002"
##
$SCCMName = '<MANAGEMENTPOINT>'
$Namespace = 'root\sms\site_<SITECODE>'
$Collections = "<COLLECTIONID>"

##
# Load Configuration Manager PowerShell Module
# Connect to SCCM PSProvider
##
$ModulePath = (Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\ConfigMgr10\Setup -Name "UI Installation Directory").'UI Installation Directory'
$SiteServerName = (Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\ConfigMgr10\AdminUI\Connection -Name Server).Server
$ProviderLocation = gcim -ComputerName $SiteServerName -Namespace root\sms SMS_ProviderLocation -filter "ProviderForLocalSite='True'"
$ProviderMachine = $ProviderLocation.Machine
$SiteCode = $ProviderLocation.SiteCode
Import-Module $ModulePath\bin\ConfigurationManager.psd1
Set-Location $SiteCode":\"

foreach ($locale in $Collections)

{

$LocationName = Get-CMCollection -Id $locale | Select-Object -ExpandProperty Name
$PCList = Get-CMCollectionMember -CollectionId $locale | Select-Object Name, UserName, LastPolicyRequest, DeviceOS, ClientActiveStatus, ResourceID, DeviceOSBuild

ForEach ($i in $PCList)
{
    
    $Fullstat = New-Object System.Object
    $CollectionID = $locale
    $PCADInfo = Get-ADComputer $i.Name -Properties OperatingSystem
    $OSInfo = $PCADInfo | Select-Object -ExpandProperty OperatingSystem
    $Build = $i.DeviceOSBuild
    $IPAddress = (Get-CMResource -Fast -ResourceId $i.ResourceID | Select-Object -ExpandProperty IPAddresses)[0]
    $ModelInfo = Get-WmiObject -ComputerName "$($SCCMName)" -Namespace "$($Namespace)" `
                -query ("select SMS_G_System_COMPUTER_SYSTEM.Model
    			from
		        	SMS_G_System_COMPUTER_SYSTEM
	        	where
		       		SMS_G_System_COMPUTER_SYSTEM.Name=  ""$($i.Name)"" ")
    $Model = $ModelInfo.Model
    $ProcessorClass = Get-WmiObject -ComputerName "$($SCCMName)" -Namespace "$($Namespace)" `
		-Query ("select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client,SMS_G_System_COMPUTER_SYSTEM.SystemType
			from 
				SMS_R_System 
			inner join 
				SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = 
				SMS_R_System.ResourceId 
			inner join 
				SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceID = 
				SMS_R_System.ResourceId
			where
				SMS_R_SYSTEM.Name= ""$($i.Name)"" ")
    $ProcessorType = $ProcessorClass.SMS_G_System_COMPUTER_SYSTEM.SystemType
    
    ##
    # For the $Software variable, replace '<APPLICATION>'
    # with your wildcard search.
    # (e.g. *Adobe Flash Player*, *Symantec Endpoint Protection*)
    # In the event that no information can be obtained.
    ##
    
    $Software = Get-WmiObject -ComputerName "$($SCCMName)" -Namespace "$($Namespace)" `
				  -Query ("select InstalledLocation,ProductVersion,ProductName
            from 
                SMS_R_System
            join 
                SMS_G_SYSTEM_Installed_Software on SMS_R_System.ResourceID = 
                SMS_G_SYSTEM_Installed_Software.ResourceID
            where
                SMS_R_SYSTEM.Name= ""$($i.Name)"" ") |
	
	        Select-Object -Property ProductName, ProductVersion, InstalledLocation |
	        Where-Object ProductName -like "*<APPLICATION>*"

    
    ##
    # Perform a query of user's AD information.
	# If the user's manager is linked in AD, this info will be returned, as well.
    # In the event that no information can be obtained, User fields will be populated with "<NA>"
    ##
	
    if ($i.UserName -gt '')
    
    {
    
        $Username = $i.UserName
        $NameStats = Get-ADUser $Username
        $userManager = (Get-ADUser (Get-ADUser $username -properties manager).manager)
        $userManagerName = $userManager.Name
        $userManagerEmail = $userManager.UserPrincipalName
        $FullName = $NameStats.Name
        $EmailAddress = $NameStats.UserPrincipalName

    }

    else

    {
        $Username = "<NA>"
        $NameStats = "<NA>"
        $FullName = "<NA>" 
        $EmailAddress = "<NA>"
        $userManagerName = "<NA>"
        $userManagerEmail = "<NA>"
    }
        
    $Fullstat | Add-Member -Type NoteProperty -Name Computer -Value $i.Name
    $Fullstat | Add-Member -Type NoteProperty -Name CollectionID -Value $CollectionID
    $Fullstat | Add-Member -Type NoteProperty -Name Model -Value $Model
    $Fullstat | Add-Member -Type NoteProperty -Name ProcessorType -Value $ProcessorType
    $Fullstat | Add-Member -Type NoteProperty -Name FullName $FullName
    $Fullstat | Add-Member -Type NoteProperty -Name EmailAddress $EmailAddress
    $Fullstat | Add-Member -Type NoteProperty -Name ManagerName $userManagerName
    $Fullstat | Add-Member -Type NoteProperty -Name ManagerEmail $userManagerEmail
    $Fullstat | Add-Member -Type NoteProperty -Name OS -Value $OSInfo
    $Fullstat | Add-Member -Type NoteProperty -Name Build -Value $Build
    $Fullstat | Add-Member -Type NoteProperty -Name ProductName -Value ($software | Select-Object -ExpandProperty ProductName -First 1)
    $Fullstat | Add-Member -Type NoteProperty -Name ProductVersion -Value ($software | Select-Object -ExpandProperty ProductVersion -First 1)
    $Fullstat | Add-Member -Type NoteProperty -Name IsActive -Value $i.ClientActiveStatus
    $Fullstat | Add-Member -Type NoteProperty -NAme LastPolicyRequest -Value $i.LastPolicyRequest
    $Fullstat | Add-Member -type NoteProperty -Name IPAddresses -Value $IPAddress
    $Computers += $Fullstat
    $Fullstat
}
    $TimeStamp = Get-Date -UFormat "%m%d%Y_%H%M"
    $ExportFileName = "C:\Temp\collection_details_query_$TimeStamp.csv"
    $computers | Export-Csv -Path $ExportFileName -NoTypeInformation
}

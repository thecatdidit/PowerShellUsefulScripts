* Information compiled overviewing my lab

Automatic Deployment Rule Set Examples and Best Practices
Scenario Example 1(Submitted by /r/thecatdidit - Modeled primarily off of a guide from DamGoodAdmin CM Version: 1802
Client Count: ~2100
OS Breakdown: Win10:99.8%|Win7:0.2% (all x64)
ADR Rulesets
	• MS Office (LAST YEAR)
	• MS Office (CURRENT CYCLE - LAST 28 DAYS)
	• Windows OS (LAST SIX MONTHS)
•	Cumulative Updates and SSUs older than six months are not needed
	• Windows OS (CURRENT CYCLE - LAST 28 DAYS)
• ADR-specific settings
* 		
* Severity: ALL values (Critical, Important, Low, Moderate, None - Microsoft has been problematic with 
how they classify update severity)
		○ Filters (using Title criteria in ADR settings - for Windows OS ADRs)
•	§ -ARM64
•	§ -x86-based
•	§ -Windows Malicious Software Removal Tool
•	○ MS Office Products
•	§ Office 2013/2016/2019
•	○ Windows OS Products
•	§ Windows 10 (1607,1703,1709,1803)
•	§ 1803 and Later Servicing/Drivers (we are planning a Win10 build unification 5using 1803)
•	§ Visual Studio 2015 (some devs needs this re: report rendering)

 
Deployment Targets 
	• Testing Group
		○ Maintaining a group of at least 30 workstations. 
		○ Mix of power users, VMs, test workstations
	• All Workstations
Deployment Procedure
	• Two primary patch cycles
		○ Office Patch Tuesday (1st Tuesday of the month)
		○ “BIG” Patch Tuesday (2nd Tuesday of the month)
	• Strategy
		○ Office PT: OfficeCurrentCycle ADR deployed to Testing Group
			§ Run ADR again after a 7-day soak period, deploy to all others
		○ “BIG” PT: WinCurrentCycle ADR deployed to Testing Group
			§ Run ADR again after a 14-day soak period, deploy to all others
		○ Weekly ADR of CurrentCycle rulesets to keep them current, pick up revised KBs, etc.
		○ End of month run of Last Year/6 Months ADR rulesets to ensure a full body of patches for new and existing, errant workstations
	• QC/Monitoring
		○ Run daily reports specific to each monthly OS update KB (e.g. KB4471324 against query-based collection of Win10 1803 clients
		○ Run daily report of patch deployment errors
		○ Weekly random pick of 10 clients that are manually evaluated (to confirm accuracy of report data, etc.)
		○ Our Infosec team utilizes Nexpose to scan everything on our network. We review the scores with them each week, pinpoint any urgent needs and deal with false positives for users who have certain software exceptions.
		○ SUG cleanup 24-48 hours after an ADR has been run to ensure quality data
3rd Party Update Catalogues                                                                                                           
	• Adobe Acrobat and Reader DC
	• Adobe Flash Player (XML Master Version file)
		○ Download URLs for installers can be extrapolated using the version. 
		○ URL formats
			§ https://fpdownload.macromedia.com/pub/flashplayer/pdc/<FLASHMAJORVERSION>/install_flash_player/<FLASHFULLVERSION>_ppapi.msi
		○ Example: 32.0.0.101 (Major Version: 32 | Full Version: 32.0.0.101
			§ PPAPI: https://fpdownload.macromedia.com/pub/flashplayer/pdc/32.0.0.101/install_flash_player_32_ppapi.msi
			§ NPAPI/Plugin: https://fpdownload.macromedia.com/pub/flashplayer/pdc/32.0.0.101/install_flash_player_32_plugin.msi
			§ PowerShell: Get-OnlineVerFlashPlayer.ps1 (gets the latest version and generates download URLs). Source: thecatdidit/PowerShellUsefulScripts
	• Chrome
		○ Download URL for current version offline MSI: https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi
	• Ivanti (commercial)
	• Mozilla Firefox
		○ URL formats (Example: 64.0)
			§ x64: https://download-origin.cdn.mozilla.net/pub/firefox/releases/64.0/win64/en-US/Firefox%20Setup%2064.0.exe
			§ x86: https://download-origin.cdn.mozilla.net/pub/firefox/releases/64.0/win32/en-US/Firefox%20Setup%2064.0.exe
			§ PowerShell: Get-OnlineVerFirefox.ps1 (gets the latest versionand generates download URLs. Source: thecatdidit/PowerShellUsefulScripts
	• Notepad++
		○ URL formats (Example: 7.6.1 | Major Version: 7 | Full Version 7.6.1)
			§ x64: https://notepad-plus-plus.org/repository/7.x/7.6.1/npp.7.6.1.Installer.x64.exe
			§ x86: https://notepad-plus-plus.org/repository/7.x/7.6.1/npp.7.6.1.Installer.x86.exe
			§ PowerShell: Get-OnlineVerNotepadPlusPlus.ps1 (gets the latest versionand generates download URLs. Source: thecatdidit/PowerShellUsefulScripts
	• PatchMyPC (commercial)
Windows 10/Server 2016/Server 2019 Update History
(via Microsoft Support)
	• Anniversary Edition/Server 2016 (1607/14393.x)
	• Creators Update (1703/15063.x)
	• Fall Creators Update (1709/16299.x)
	• April Update (1803/17134.x)
	• October Update/Server 2019 (1809/17763.x)
WSUS
	• Maintaining the WSUS Catalog by Declining Updates for Better Update Scanning 
	• Fully Automate Software Update Maiwntenance in Configuration Manager
	• The complete guide to Microsoft WSUS and Configuration Manager SUP maintenance
Configuration Baselines (Compliance Settings)
Security Baselines
	• Disable SMBv1
	• Enable BitLocker Protection
	• Credential Guard Status
	• Check for the Spectre/Meltdown vulnerabilities
	• Machines have the LAPS client installed
	• Speculative Execution Side-Channel Vulnerabilities
Operating System Deployment
PXE
	• You want to PXE boot? Don’t use DHCP options.
	• Co-existing DHCP and WDS on same server
	• Tweaking PXE boot times in Configuration Manager 1606 …
	• Re-install PXE point
OS Image Management
	• https://www.msigeek.com/2635/unmount-and-clean-up-a-wim-image-using-deployment-image-servicing-and-management-dism
	• If Offline Update Integration from the SCCM Console doesn’t work: https://futureimpossible.com/add-windows-cumulative-to-your-windows-image-with-powershell/ 
	• Creating Customized Windows 10 Reference Image and Media (ISO, WIM, capture with Task Sequence Media, etc.) (ISO, WIM, capture with Task Sequence Media, etc.)
Application Management
Use the PowerShell Application Deployment Toolkit (PSADT): it’s a useful PowerShell wrapper script to help you install applications with great flexibility: check running processes, prompt user to close apps if running, reboot/process kill countdown timers, pop-ups and more. Link in Scripts/Tools section.
Backup
	• Microsoft SCCM Backup and Recovery Guide
SQL
Move database
	• How to move the ConfigMgr 2012 site database to a new SQL server
	• Moving the ConfigMgr Current Branch database to another server (as in back to the primary site server)
A tip in case you hit the problem of “Failed to create/backup SQL SSB certificate” in ConfigMgrSetup.log:
	• SCCM database move: Failed to create/backup SQL SSB certificate
Troubleshooting Guides
	• Application Installation Workflow
	• Troubleshooting SCCM Task Sequence Failures
	• OSD Troubleshooting: smsts.log Locations
	• Configuration Manager Client Action Cycles (and What They Do)
References/Resources
Microsoft References
	• System Center Configuration Manager Documentation 
	• System Center Configuration Manager Tech Community
	• SQL Views for ConfigMgr Current Branch
	• Log Files Overview
	• Configuration Manager Perf and Scale Guidance Whitepaper (Preview)
	• Uservoice Config Mgr (For Feature Request, Improvements, etc.) 

Twitter Accounts
	• David James (ConfigMgr Product Team Lead)
	• Roger Zander (MVP)
	• Mirko Colemberg (MVP / Windows Insider MVP)
	• Johan Arwidmark (MVP)
	• Mykael Nystrom (MVP)
	• Kent Agerlund (MS RD / MVP)
	• Jason Sandys (MVP)
	• Garth Jones (MVP)
	• Bryan Dam 
	• Justin Chalfant
	• Anders Rødland
	• David Segura
Community Resources
	• WinAdmins Slack Group
	• /r/SCCM/
	• /r/SysAdmin/ 
	• ChangeWindows (Tracking of Microsoft’s WaaS OS builds - great for Windows 10)
Blogs/Guides
	• https://prajwaldesai.com/
	• http://eskonr.com/
	• https://www.anoopcnair.com/ 
	• https://www.systemcenterdudes.com/
	• https://ccmexec.com/ 
	• http://www.scconfigmgr.com/ 
	• http://rzander.azurewebsites.net/
	• https://deploymentresearch.com
	• https://deploymentbunny.com/ 
	• http://blog.colemberg.ch/
	• https://home.configmgrftw.com/blog/
	• https://damgoodadmin.com/ 
	• https://www.andersrodland.com/ 
	• https://www.osdeploy.com/
	• https://www.enhansoft.com/blog/author/garth
	• https://configgirl.com/
	• https://setupconfigmgr.com
	• https://www.cvedetails.com/ (Intuitive site to review details related to CVE advisories referenced in Microsoft Updates)
	• https://ruckzuck.tools/
	• http://www.mssccm.com/ 
	• https://www.ghacks.net/category/windows/
	• https://www.neowin.net/news/tags/microsoft
	• https://www.catalog.update.microsoft.com/Home.asp 
	• https://www.zerodayinitiative.com/blog (review of monthly patches Adobe/MS/etc.)


Scripts/Tools
	• lazywinadmin/PowerShell
	• winadminsdotorg/SystemCenterConfigMgr 
	• Client Center for Configuration Manager
	• Client Health Script
	• SCCM docs script
	• asjimene/SCCM-Application-Packager
	• PowerShell App Deploy Toolkit 
	• thecatdidit/PowerShellUsefulScripts
	• Make CMTrace the Default Log File Viewer with PowerShell



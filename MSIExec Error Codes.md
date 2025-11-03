MsiExec.exe and InstMsi.exe Error Messages
	Error Value	Error code	Description
	0	ERROR_SUCCESS	The action completed successfully.
	13	ERROR_INVALID_DATA	The data is invalid.
	87	ERROR_INVALID_PARAMETER	One of the parameters was invalid.
	120	ERROR_CALL_NOT_IMPLEMENTED	This value is returned when a custom action attempts to call a function that cannot be called from custom actions. The function returns the value ERROR_CALL_NOT_IMPLEMENTED. Available beginning with Windows Installer version 3.0.
	1259	ERROR_APPHELP_BLOCK	If Windows Installer determines a product may be incompatible with the current operating system, it displays a dialog box informing the user and asking whether to try to install anyway. This error code is returned if the user chooses not to try the installation.
	1601	ERROR_INSTALL_SERVICE_FAILURE	The Windows Installer service could not be accessed. Contact your support personnel to verify that the Windows Installer service is properly registered.
	1602	ERROR_INSTALL_USEREXIT	The user cancels installation.
	1603	ERROR_INSTALL_FAILURE	A fatal error occurred during installation.
	1604	ERROR_INSTALL_SUSPEND	Installation suspended, incomplete.
	1605	ERROR_UNKNOWN_PRODUCT	This action is only valid for products that are currently installed.
	1606	ERROR_UNKNOWN_FEATURE	The feature identifier is not registered.
	1607	ERROR_UNKNOWN_COMPONENT	The component identifier is not registered.
	1608	ERROR_UNKNOWN_PROPERTY	This is an unknown property.
	1609	ERROR_INVALID_HANDLE_STATE	The handle is in an invalid state.
	1610	ERROR_BAD_CONFIGURATION	The configuration data for this product is corrupt. Contact your support personnel.
	1611	ERROR_INDEX_ABSENT	The component qualifier not present.
	1612	ERROR_INSTALL_SOURCE_ABSENT	The installation source for this product is not available. Verify that the source exists and that you can access it.
	1613	ERROR_INSTALL_PACKAGE_VERSION	This installation package cannot be installed by the Windows Installer service. You must install a Windows service pack that contains a newer version of the Windows Installer service.
	1614	ERROR_PRODUCT_UNINSTALLED	The product is uninstalled.
	1615	ERROR_BAD_QUERY_SYNTAX	The SQL query syntax is invalid or unsupported.
	1616	ERROR_INVALID_FIELD	The record field does not exist.
	1618	ERROR_INSTALL_ALREADY_RUNNING	Another installation is already in progress. Complete that installation before proceeding with this install.
			
			For information about the mutex, see _MSIExecute Mutex.

	1619	ERROR_INSTALL_PACKAGE_OPEN_FAILED	This installation package could not be opened. Verify that the package exists and is accessible, or contact the application vendor to verify that this is a valid Windows Installer package.
	1620	ERROR_INSTALL_PACKAGE_INVALID	This installation package could not be opened. Contact the application vendor to verify that this is a valid Windows Installer package.
	1621	ERROR_INSTALL_UI_FAILURE	There was an error starting the Windows Installer service user interface. Contact your support personnel.
	1622	ERROR_INSTALL_LOG_FAILURE	There was an error opening installation log file. Verify that the specified log file location exists and is writable.
	1623	ERROR_INSTALL_LANGUAGE_UNSUPPORTED	This language of this installation package is not supported by your system.
	1624	ERROR_INSTALL_TRANSFORM_FAILURE	There was an error applying transforms. Verify that the specified transform paths are valid.
	1625	ERROR_INSTALL_PACKAGE_REJECTED	This installation is forbidden by system policy. Contact your system administrator.
	1626	ERROR_FUNCTION_NOT_CALLED	The function could not be executed.
	1627	ERROR_FUNCTION_FAILED	The function failed during execution.
	1628	ERROR_INVALID_TABLE	An invalid or unknown table was specified.
	1629	ERROR_DATATYPE_MISMATCH	The data supplied is the wrong type.
	1630	ERROR_UNSUPPORTED_TYPE	Data of this type is not supported.
	1631	ERROR_CREATE_FAILED	The Windows Installer service failed to start. Contact your support personnel.
	1632	ERROR_INSTALL_TEMP_UNWRITABLE	The Temp folder is either full or inaccessible. Verify that the Temp folder exists and that you can write to it.
	1633	ERROR_INSTALL_PLATFORM_UNSUPPORTED	This installation package is not supported on this platform. Contact your application vendor.
	1634	ERROR_INSTALL_NOTUSED	Component is not used on this machine.
	1635	ERROR_PATCH_PACKAGE_OPEN_FAILED	This patch package could not be opened. Verify that the patch package exists and is accessible, or contact the application vendor to verify that this is a valid Windows Installer patch package.
	1636	ERROR_PATCH_PACKAGE_INVALID	This patch package could not be opened. Contact the application vendor to verify that this is a valid Windows Installer patch package.
	1637	ERROR_PATCH_PACKAGE_UNSUPPORTED	This patch package cannot be processed by the Windows Installer service. You must install a Windows service pack that contains a newer version of the Windows Installer service.
	1638	ERROR_PRODUCT_VERSION	Another version of this product is already installed. Installation of this version cannot continue. To configure or remove the existing version of this product, use Add/Remove Programs in Control Panel.
	1639	ERROR_INVALID_COMMAND_LINE	Invalid command line argument. Consult the Windows Installer SDK for detailed command-line help.
	1640	ERROR_INSTALL_REMOTE_DISALLOWED	The current user is not permitted to perform installations from a client session of a server running the Terminal Server role service.
	1641	ERROR_SUCCESS_REBOOT_INITIATED	The installer has initiated a restart. This message is indicative of a success.
	1642	ERROR_PATCH_TARGET_NOT_FOUND	The installer cannot install the upgrade patch because the program being upgraded may be missing or the upgrade patch updates a different version of the program. Verify that the program to be upgraded exists on your computer and that you have the correct upgrade patch.
	1643	ERROR_PATCH_PACKAGE_REJECTED	The patch package is not permitted by system policy.
	1644	ERROR_INSTALL_TRANSFORM_REJECTED	One or more customizations are not permitted by system policy.
	1645	ERROR_INSTALL_REMOTE_PROHIBITED	Windows Installer does not permit installation from a Remote Desktop Connection.
	1646	ERROR_PATCH_REMOVAL_UNSUPPORTED	The patch package is not a removable patch package. Available beginning with Windows Installer version 3.0.
	1647	ERROR_UNKNOWN_PATCH	The patch is not applied to this product. Available beginning with Windows Installer version 3.0.
	1648	ERROR_PATCH_NO_SEQUENCE	No valid sequence could be found for the set of patches. Available beginning with Windows Installer version 3.0.
	1649	ERROR_PATCH_REMOVAL_DISALLOWED	Patch removal was disallowed by policy. Available beginning with Windows Installer version 3.0.
	1650	ERROR_INVALID_PATCH_XML	The XML patch data is invalid. Available beginning with Windows Installer version 3.0.
	1651	ERROR_PATCH_MANAGED_ADVERTISED_PRODUCT	Administrative user failed to apply patch for a per-user managed or a per-machine application that is in advertise state. Available beginning with Windows Installer version 3.0.
	1652	ERROR_INSTALL_SERVICE_SAFEBOOT	Windows Installer is not accessible when the computer is in Safe Mode. Exit Safe Mode and try again or try using System Restore to return your computer to a previous state. Available beginning with Windows Installer version 4.0.

	1653	ERROR_ROLLBACK_DISABLED	Could not perform a multiple-package transaction because rollback has been disabled. Multiple-Package Installations cannot run if rollback is disabled. Available beginning with Windows Installer version 4.5.

	1654	ERROR_INSTALL_REJECTED	The app that you are trying to run is not supported on this version of Windows. A Windows Installer package, patch, or transform that has not been signed by Microsoft cannot be installed on an ARM computer.
	3010	ERROR_SUCCESS_REBOOT_REQUIRED	A restart is required to complete the install. This message is indicative of a success. This does not include installs where the ForceReboot action is run.


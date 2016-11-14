#
# Module manifest for module 'biz.dfch.PS.Appclusive.Client'
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'biz.dfch.PS.Appclusive.Client.psm1'

# Version number of this module.
ModuleVersion = '4.11.2.20161111'

# ID used to uniquely identify this module
GUID = '110e9ca0-df4a-404b-9a47-aa616cf7ee63'

# Author of this module
Author = 'Ronald Rink'

# Company or vendor of this module
CompanyName = 'd-fens GmbH'

# Copyright statement for this module
Copyright = '(c) 2014-2016 d-fens GmbH. Distributed under Apache 2.0 license.'

# Description of the functionality provided by this module
Description = 'PowerShell module for the Appclusive Framework and Middleware'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of the .NET Framework required by this module
DotNetFrameworkVersion = '4.6'

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @(
	'biz.dfch.PS.System.Logging'
	,
	'biz.dfch.PS.System.Utilities'
)

# Assemblies that must be loaded prior to importing this module
RequiredAssemblies = @(
	'biz.dfch.CS.Appclusive.Api.dll'
	,
	'System.Net'
	,
	'System.Web'
	,
	'System.Web.Extensions'
	,
	'biz.dfch.CS.Appclusive.Public.dll'
	,
	'Newtonsoft.Json.dll'
)

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
ScriptsToProcess = @(
	'Import-Module.ps1'
)

# ModuleToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @(
	'Enter-Server.ps1'
	,
	'New-KeyNameValue.ps1'
	,
	'Get-KeyNameValue.ps1'
	,
	'Set-KeyNameValue.ps1'
	,
	'Remove-KeyNameValue.ps1'
	,
	'New-ManagementCredential.ps1'
	,
	'Get-ManagementCredential.ps1'
	,
	'Set-ManagementCredential.ps1'
	,
	'Remove-ManagementCredential.ps1'
	,
	'Remove-Entity.ps1'
	,
	'Get-ModuleVariable.ps1'
	,
	'Get-Time.ps1'
	,
	'Test-Status.ps1'
	,
	'Get-Job.ps1'
	,
	'Pop-ChangeTracker.ps1'
	,
	'Push-ChangeTracker.ps1'
	,
	'New-User.ps1'
	,
	'Get-User.ps1'
	,
	'Set-User.ps1'
	,
	'Get-ManagementUri.ps1'
	,
	'Get-EntityKind.ps1'
	,
	'Format-ResultAs.ps1'
	,
	'Get-Node.ps1'
	,
	'New-Node.ps1'
	,
	'Set-Node.ps1'
	,
	'Invoke-NodeAction.ps1'
	,
	'Remove-Node.ps1'
	,
	'Invoke-EntityAction.ps1'
	,
	'Set-Job.ps1'
	,
	'Get-ExternalNode.ps1'
	,
	'New-ExternalNode.ps1'
	,
	'Set-ExternalNode.ps1'
	,
	'Get-CimiTarget.ps1'
	,
	'Get-Product.ps1'
	,
	'Get-CatalogueItem.ps1'
	,
	'Get-Tenant.ps1'
	,
	'Set-SessionTenant.ps1'
	,
	'Get-SessionTenant.ps1'
	,
	'Get-Version.ps1'
	,
	'Format-Exception.ps1'
	,
	'New-Connector.ps1'
	,
	'Set-Connector.ps1'
	,
	'Get-Connector.ps1'
	,
	'Remove-Connector.ps1'
	,
	'New-Interface.ps1'
	,
	'Set-Interface.ps1'
	,
	'Get-Interface.ps1'
	,
	'Remove-Interface.ps1'
	,
	'Test-Connect.ps1'
	,
	'Set-ManagementUri.ps1'
	,
	'New-ManagementUri.ps1'
	,
	'Set-EntityBag.ps1'
	,
	'Import-DataType.ps1'
	,
	'New-EntityBag.ps1'
	,
	'Get-EntityBag.ps1'
	,
	'Set-Folder.ps1'
	,
	'New-Folder.ps1'
	,
	'Get-Folder.ps1'
	,
	'Import-Product.ps1'
	,
	'Import-DataType.ps1'
	,
	'Get-Role.ps1'
	,
	'Set-Role.ps1'
	,
	'New-Role.ps1'
)

# Functions to export from this module
FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module.
# ModuleList = @()

# List of all files packaged with this module
FileList = @(
	'LICENSE'
	,
	'NOTICE'
	,
	'README.md'
	,
	'biz.dfch.PS.Appclusive.Client.xml'
	,
	'Microsoft.Data.Edm.dll'
	,
	'Microsoft.Data.OData.dll'
	,
	'Microsoft.Data.Services.Client.dll'
	,
	'System.Spatial.dll'
	,
	'Import-Module.ps1'
	,
    'biz.dfch.CS.Appclusive.Api.dll'
	,
	'biz.dfch.CS.Appclusive.Public.dll'
	,
    'Newtonsoft.Json.dll'
	,
    'System.Net.Http.Formatting.dll'
)

# Private data to pass to the module specified in RootModule/ModuleToProcess
PrivateData = @{

	PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'dfch', 'PowerShell', 'Appclusive', 'Automation', 'OData'
		
        # A URL to the license for this module.
        LicenseUri = 'https://github.com/dfensgmbh/biz.dfch.PS.Appclusive.Client/blob/master/LICENSE'
		
        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/dfensgmbh/biz.dfch.PS.Appclusive.Client'
		
        # A URL to an icon representing this module.
        IconUri = 'https://raw.githubusercontent.com/dfensgmbh/biz.dfch.PS.Appclusive.Client/master/logo-32x32.png'
		
        # ReleaseNotes of this module
        ReleaseNotes = '20161111
# BUGFIXES

Set-Role Cmdlet
* Avoid console output of HTTP response when adding/removing permission'
    } 
	
	"MODULEVAR" = "biz_dfch_PS_Appclusive_Client"
}

# HelpInfo URI of this module
HelpInfoURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/'

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
DefaultCommandPrefix = 'Apc'

}

# 
# Copyright 2015-2016 d-fens GmbH
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 

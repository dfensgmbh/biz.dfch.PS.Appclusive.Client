function Set-Role {
<#
.SYNOPSIS
Sets or creates a Role entry in Appclusive.


.DESCRIPTION
Sets or creates a Role entry in Appclusive.

By updating an Role entry you can specify, if you want to update the 
Description, MailAddress, Name, RoleType or any combination thereof. 
For updating Name or RoleType you need to use the Argument '-NewName'/'-NewRoleType'


.OUTPUTS
default


.EXAMPLE
Set-Role -Name "ArbitraryRole" -RoleType External -svc $svc -CreateIfNotExist;

RoleType     : 4
MailAddress  :
Id           : 42
Tid          : 11111111-1111-1111-1111-111111111111
Name         : ArbitraryRole
Description  :
CreatedById  : 1
ModifiedById : 1
Created      : 23.08.2016 11:08:14 +02:00
Modified     : 23.08.2016 11:08:14 +02:00
RowVersion   :
Permissions  : {}
Users        : {}
Tenant       :
CreatedBy    :
ModifiedBy   :

Create a new Role entry if it does not exist.


.EXAMPLE
Set-Role -Name "ArbitraryName" -Description "UpdatedDescription" -NewName "UpdatedName"

RoleType     : 2
MailAddress  :
Id           : 42
Tid          : 11111111-1111-1111-1111-111111111111
Name         : UpdatedName
Description  : UpdatedDescription
CreatedById  : 1
ModifiedById : 1
Created      : 23.08.2016 11:08:14 +02:00
Modified     : 23.08.2016 11:08:14 +02:00
RowVersion   :
Permissions  : {}
Users        : {}
Tenant       :
CreatedBy    :
ModifiedBy   :

Update an existing Role with new Name and new Description.


.EXAMPLE
Set-Role -Id 42 -RoleType Distribution -MailAddress "arbitrary@example.com" -NewName "UpdatedName"

RoleType     : 2
MailAddress  : arbitrary@example.com
Id           : 42
Tid          : 11111111-1111-1111-1111-111111111111
Name         : UpdatedName
Description  : 
CreatedById  : 1
ModifiedById : 1
Created      : 23.08.2016 11:08:14 +02:00
Modified     : 23.08.2016 11:08:14 +02:00
RowVersion   :
Permissions  : {}
Users        : {}
Tenant       :
CreatedBy    :
ModifiedBy   :

Update an existing Role with new Name and MailAddress and RoleType.


.EXAMPLE
Set-Role -Id 42 -Permissions @("Apc:NodesCanRead","Apc:NodesCanCreate") -CreateIfNotExist

RoleType     : 2
MailAddress  : 
Id           : 42
Tid          : 11111111-1111-1111-1111-111111111111
Name         : ArbitraryName
Description  : 
CreatedById  : 1
ModifiedById : 1
Created      : 23.08.2016 11:08:14 +02:00
Modified     : 23.08.2016 11:08:14 +02:00
RowVersion   :
Permissions  : {}
Users        : {}
Tenant       :
CreatedBy    :
ModifiedBy   :

Create/Update Role by adding specified permissions


.EXAMPLE
Set-Role -Id 42 -Permissions @("Apc:NodesCanRead","Apc:NodesCanCreate") -RemovePermissions

RoleType     : 2
MailAddress  : 
Id           : 42
Tid          : 11111111-1111-1111-1111-111111111111
Name         : ArbitraryName
Description  : 
CreatedById  : 1
ModifiedById : 1
Created      : 23.08.2016 11:08:14 +02:00
Modified     : 23.08.2016 11:08:14 +02:00
RowVersion   :
Permissions  : {}
Users        : {}
Tenant       :
CreatedBy    :
ModifiedBy   :

Update an existing Role by removing the specified permissions


.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Set-Role/
Set-Role: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Set-Role/


.NOTES
See module manifest for dependencies and further requirements.


#>
[CmdletBinding(
    SupportsShouldProcess = $false
	,
    ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/Set-Role/'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
Param
(
	[Parameter(Mandatory = $true, ParameterSetName = 'id', Position = 0)]
	[ValidateRange(1, [long]::MaxValue)]
	[long] $Id
	,
	[Parameter(Mandatory = $true, ParameterSetName = 'create', Position = 0)]
	[Parameter(Mandatory = $true, ParameterSetName = 'name', Position = 0)]
	[ValidateNotNullOrEmpty()]
	[Alias('n')]
	[string] $Name
	,
	[Parameter(Mandatory = $true, ParameterSetName = 'create', Position = 1)]
	[Parameter(Mandatory = $false, ParameterSetName = 'name', Position = 1)]
	[Parameter(Mandatory = $false, ParameterSetName = 'id', Position = 1)]
	[ValidateSet('Default', 'Security', 'Distribution', 'BuiltIn', 'External')]
	[string] $RoleType
	,
	[Parameter(Mandatory = $false)]
	[ValidateNotNullOrEmpty()]
	[string] $MailAddress
	,
	[Parameter(Mandatory = $false)]
	[ValidateNotNullOrEmpty()]
	[string] $Description
	,
	# Specifies the permissions which should be added/removed
	[Parameter(Mandatory = $false)]
	[string[]] $Permissions = @()
	,
	[Parameter(Mandatory = $false, ParameterSetName = 'id')]
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[ValidateNotNullOrEmpty()]
	[string] $NewName
	,
	# Specifies to remove the specified permissions
	[Parameter(Mandatory = $false, ParameterSetName = 'id')]
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[switch] $RemovePermissions = $false
	,
	# Specifies to create a entity if it does not exist
	[Parameter(Mandatory = $true, ParameterSetName = 'create')]
	[Alias("c")]
	[switch] $CreateIfNotExist = $false
	,
	# Service reference to Appclusive
	[Parameter(Mandatory = $false)]
	[Alias('Services')]
	[hashtable] $svc = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Services
	,
	# Specifies the return format of the Cmdlet
	[ValidateSet('default', 'json', 'json-pretty', 'xml', 'xml-pretty')]
	[Parameter(Mandatory = $false)]
	[alias('ReturnFormat')]
	[string] $As = 'default'
)

Begin 
{
	trap { Log-Exception $_; break; }

	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug -fn $fn -msg ("CALL. svc '{0}'. Name '{1}'." -f ($svc -is [Object]), $Name) -fac 1;

	# Parameter validation
	Contract-Requires ($svc.Core -is [biz.dfch.CS.Appclusive.Api.Core.Core]) "Connect to the server before using the Cmdlet";
}

Process 
{
	trap { Log-Exception $_; break; }
	
	# Default test variable for checking function response codes.
	[Boolean] $fReturn = $false;
	# Return values are always and only returned via OutputParameter.
	$OutputParameter = $null;
	$AddedEntity = $null;

	if($PSCmdlet.ParameterSetName -eq 'id') 
	{
		$FilterExpression = "Id eq {0}L" -f $Id;
		$entity = $svc.Core.Roles.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$top',1) | Select;
		
		Contract-Assert ($entity) "Entity does not exist";
	}
	else 
	{
		$currentTenant = Get-Tenant -svc $svc -Current;
		$FilterExpression = "(tolower(Name) eq '{0}' and Tid eq guid'{1}')" -f $Name.ToLower(), $currentTenant.Id;
		$entity = $svc.Core.Roles.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$top',1) | Select;
		
		Contract-Assert ($CreateIfNotExist -or $entity) "Entity does not exist. Use '-CreateIfNotExist' to create the resource";
	}
	
	if($PSCmdlet.ParameterSetName -eq 'create') 
	{
		$entity = New-Object biz.dfch.CS.Appclusive.Api.Core.Role;
		$svc.Core.AddToRoles($entity);
		$AddedEntity = $entity;
		$entity.Name = $Name;
		$entity.RoleType = $RoleType
		$entity.Created = [System.DateTimeOffset]::Now;
		$entity.Modified = $entity.Created;
		$entity.CreatedById = 0;
		$entity.ModifiedById = 0;
	}
	else
	{
		if($PSBoundParameters.ContainsKey('NewName'))
		{
			$entity.Name = $NewName;
		}
		if($PSBoundParameters.ContainsKey('RoleType'))
		{
			$entity.RoleType = $RoleType;
		}
	}
	
	if($PSBoundParameters.ContainsKey('Description'))
	{
		$entity.Description = $Description;
	}
	if($PSBoundParameters.ContainsKey('MailAddress'))
	{
		$entity.MailAddress = $MailAddress;
	}
	
	$svc.Core.UpdateObject($entity);
	$null = $svc.Core.SaveChanges();


	if($PSBoundParameters.ContainsKey('Permissions'))
	{
		# assert, that specified permissions do not contain duplicates
		Contract-Assert($Permissions.Count -eq ($Permissions | Select -Unique).Count) "Duplicates found in specified Permissions";

		$originalPermissions = Get-Role -Id $entity.Id -svc $svc -ExpandPermissions;
		$permissionEntities = New-Object System.Collections.ArrayList;
		$permissionsCanBeAdded = $true;
		$permissionsCanBeRemoved = $true;
		
		foreach($permissionName in $Permissions)
		{
			$query = "Name eq '{0}'" -f $permissionName;
			$apcPermission = $svc.Core.Permissions.AddQueryOption('$filter', $query).AddQueryOption('$top', 1) | Select;
			Contract-Assert($apcPermission) ("Permissions with Name '{0}' not found." -f $permissionName);
			
			# assert, that every specified permission can be added/removed
			if (!$originalPermissions)
			{
				$permissionsCanBeRemoved = $false;
			}
			elseif ($originalPermissions.Name.Contains($permissionName))
			{
				$permissionsCanBeAdded = $false;
			}
			else 
			{
				$permissionsCanBeRemoved = $false;
			}
			
			$null = $permissionEntities.Add($apcPermission);
		}
		
		foreach($apcPermission in $permissionEntities)
		{
			if($PSBoundParameters.ContainsKey("RemovePermissions"))
			{
				Contract-Assert($permissionsCanBeRemoved) "One or more of the specified permissions cannot be removed as they are not mapped to the corresponding role";
				$svc.Core.DeleteLink($entity, 'Permissions', $apcPermission);
				$svc.Core.SaveChanges();
			}
			else
			{
				Contract-Assert($permissionsCanBeAdded) "One or more of the specified permissions cannot be added as they are already mapped to the corresponding role.";
				$svc.Core.AddLink($entity, 'Permissions', $apcPermission);
				$svc.Core.SaveChanges();
			}
		}
	}

	$r = $entity;
	$OutputParameter = Format-ResultAs $r $As;
	$fReturn = $true;
}

End 
{
	$datEnd = [datetime]::Now;
	Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;

	# Return values are always and only returned via OutputParameter.
	return $OutputParameter;
}

} # function

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Set-Role; } 

# 
# Copyright 2016 d-fens GmbH
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

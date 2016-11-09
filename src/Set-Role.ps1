function Set-Role {
<#
.SYNOPSIS
Sets or creates a Role entry in Appclusive.


.DESCRIPTION
Sets or creates a Role entry in Appclusive.

By updating an Role entry you can specify, if you want to update the 
Description, MailAddress, Name, RoleType or any combination thereof. 
For updating the name you need to use the Argument '-NewName'


.OUTPUTS
default


.EXAMPLE
Set-Role -Name "ArbitraryRole" -RoleType 3 -svc $svc -CreateIfNotExist;

RoleType     : 3
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
Set-Role -Name "ArbitraryName" -Description "updatedDescription" -NewName "UpdatedName"

RoleType     : 3
MailAddress  :
Id           : 42
Tid          : 11111111-1111-1111-1111-111111111111
Name         : UpdatedName
Description  : updatedDescription
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

Update an existing Role with new Name and Description.


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
	# Specifies the name to modify
	[Parameter(Mandatory = $true, ParameterSetName = 'create', Position = 0)]
	[Parameter(Mandatory = $true, ParameterSetName = 'name', Position = 0)]
	[ValidateNotNullOrEmpty()]
	[Alias('n')]
	[string] $Name
	,
	# Specifies the name to modify
	[Parameter(Mandatory = $true, ParameterSetName = 'create', Position = 1)]
	[long] $RoleType
	,
	# Specifies the name to modify
	[Parameter(Mandatory = $false)]
	[ValidateNotNullOrEmpty()]
	[string] $MailAddress
	,
	# Specifies the description
	[Parameter(Mandatory = $false)]
	[ValidateNotNullOrEmpty()]
	[string] $Description
	,
	# Specifies the permissions which should be added
	[Parameter(Mandatory = $false)]
	[string[]] $Permissions = @()
	,
	# Specifies the new name
	[Parameter(Mandatory = $false, ParameterSetName = 'name', Position = 2)]
	[ValidateNotNullOrEmpty()]
	[string] $NewName
	,
	# Specifies if the permissions should be removed instead
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

# Begin
Begin 
{
	trap { Log-Exception $_; break; }

	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug -fn $fn -msg ("CALL. svc '{0}'. Name '{1}'." -f ($svc -is [Object]), $Name) -fac 1;

	# Parameter validation
	Contract-Requires ($svc.Core -is [biz.dfch.CS.Appclusive.Api.Core.Core]) "Connect to the server before using the Cmdlet";
	
	# RoleType param validation
	$minRoleTypeValue = [biz.dfch.CS.Appclusive.Public.Security.RoleTypeEnum]::Default.value__;
	$maxRoleTypeValue = [biz.dfch.CS.Appclusive.Public.Security.RoleTypeEnum]::External.value__;
	if ($RoleType) 
	{
		Contract-Requires($minProtectionLevelValue -le $RoleType);
		Contract-Requires($maxProtectionLevelValue -ge $RoleType);
	}
    
    if($PSBoundParameters.ContainsKey('MailAddress'))
    {
        $isValidMail = [System.Net.Mail.MailAddress]::new($MailAddress);
        Contract-Requires(!!$MailAddress);
    }
}

Process 
{

# Default test variable for checking function response codes.
[Boolean] $fReturn = $false;
# Return values are always and only returned via OutputParameter.
$OutputParameter = $null;
$AddedEntity = $null;

try 
{
	$FilterExpression = "(tolower(Name) eq '{0}')" -f $Name.ToLower();
	$entity = $svc.Core.Roles.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$top',1) | Select;

	if(!$CreateIfNotExist -And !$entity) 
	{
		$msg = "Name: Parameter validation FAILED. Entity does not exist. Use '-CreateIfNotExist' to create resource: '{0}'" -f $Name;
		$gotoError = New-CustomErrorRecord -m $msg -cat ObjectNotFound -o $Name;
		throw($gotoError);
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
	elseif($PSCmdlet.ParameterSetName -eq 'name')
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

	foreach($permission in ($Permissions | Select -Unique))
	{
		$query = "Name eq '{0}'" -f $permission;
		$permission = $svc.Core.Permissions.AddQueryOption('$filter', $query).AddQueryOption('$top', 1) | Select;
		
		if($null -eq $permission) 
		{
			Log-Error $fn "Permission not found";
			continue;
		}
		$oldPermissions = Get-Role -Id $entity.Id -svc $svc -ExpandPermissions;
		foreach($oldPermission in $oldPermissions)
		{
			$hasPermissionMessage = "The role already has permission {0}" -f $permission;
			$isEqual = $oldPermission.Name -eq $permission;
			
			if($PSBoundParameters.ContainsKey("RemovePermissions") -and $isEqual)
			{
				$svc.Core.RemoveLink($entity, 'Permissions', $permission);
				continue;
			}
			elseif($PSBoundParameters.ContainsKey("RemovePermissions") -and !$isEqual)
			{
				$hasPermissionMessage = "The role doesn't have permission {0}" -f $permission;
				Contract-Assert(!$isEqual) $hasPermissionMessage;
			}
			Contract-Assert(!$isEqual) $hasPermissionMessage;
		}
		
		$svc.Core.AddLink($entity, 'Permissions', $permission);
		$null = $svc.Core.SaveChanges();
	}

	$r = $entity;
	$OutputParameter = Format-ResultAs $r $As;
	$fReturn = $true;
}
catch 
{
	if($gotoSuccess -eq $_.Exception.Message) 
	{
		$fReturn = $true;
	} 
	else 
	{
		[string] $ErrorText = "catch [$($_.FullyQualifiedErrorId)]";
		$ErrorText += (($_ | fl * -Force) | Out-String);
		$ErrorText += (($_.Exception | fl * -Force) | Out-String);
		$ErrorText += (Get-PSCallStack | Out-String);
		
		if($_.Exception -is [System.Net.WebException]) 
		{
			Log-Critical $fn ("[WebException] Request FAILED with Status '{0}'. [{1}]." -f $_.Exception.Status, $_);
			Log-Debug $fn $ErrorText -fac 3;
		}
		else 
		{
			Log-Error $fn $ErrorText -fac 3;
			
			if($gotoError.Exception.Message -eq $_.Exception.Message) 
			{
				Log-Error $fn $e.Exception.Message;
				$PSCmdlet.ThrowTerminatingError($e);
			} 
			elseif($gotoFailure -ne $_.Exception.Message) 
			{ 
				Write-Verbose ("$fn`n$ErrorText"); 
			} 
			else 
			{
				# N/A
			}
		}
		$fReturn = $false;
		$OutputParameter = $null;
		
		if($AddedEntity) 
		{ 
			$svc.Core.DeleteObject($AddedEntity); 
		}
	}
}
finally 
{
	# Clean up
	# N/A
}

}
# Process

End 
{
	$datEnd = [datetime]::Now;
	Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;

	# Return values are always and only returned via OutputParameter.
	return $OutputParameter;
}
# End

}
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

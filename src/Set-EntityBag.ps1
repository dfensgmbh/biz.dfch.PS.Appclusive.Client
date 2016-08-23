function Set-EntityBag {
<#
.SYNOPSIS
Sets or creates a EntityBag entry in Appclusive.


.DESCRIPTION
Sets or creates a EntityBag entry in Appclusive.

By updating an EntityBag entry you can specify if you want to update the description, protectionLevel or value or any combination thereof. For updating the value you need to use the Argument '-NewValue'


.OUTPUTS
default


.EXAMPLE
Set-EntityBag -Name "ArbitraryName" -Value "ArbitraryValue" -EntityId 2 -EntityKindId 1 -svc $svc -CreateIfNotExist;

Name            : ArbitraryName
Value           : ArbitraryValue
EntityId        : 2
EntityKindId    : 1
ProtectionLevel : 0
Id              : 159
Tid             : 11111111-1111-1111-1111-111111111111
Description     :
CreatedById     : 1
ModifiedById    : 1
Created         : 23.08.2016 11:08:14 +02:00
Modified        : 23.08.2016 11:08:14 +02:00
RowVersion      : {0, 0, 0, 0...}
Tenant          :
CreatedBy       :
ModifiedBy      :

Create a new EntityBag entry if it does not exists.


.EXAMPLE
Set-EntityBag -Name "ArbitraryName" -Value "ArbitraryValue" -EntityId 2 -EntityKindId 1 -Description "updatedDescription" -NewValue "Arbitrary updated value" -svc $svc;

Name            : ArbitraryName
Value           : Arbitrary updated value
EntityId        : 2
EntityKindId    : 1
ProtectionLevel : 0
Id              : 159
Tid             : 11111111-1111-1111-1111-111111111111
Description     : updatedDescription
CreatedById     : 1
ModifiedById    : 1
Created         : 23.08.2016 11:08:14 +02:00
Modified        : 23.08.2016 11:08:14 +02:00
RowVersion      : {0, 0, 0, 0...}
Tenant          :
CreatedBy       :
ModifiedBy      :

Update an existing EntityBag with new value and description.


.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Set-EntityBag/
Set-EntityBag: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Set-EntityBag/


.NOTES
See module manifest for dependencies and further requirements.


#>
[CmdletBinding(
    SupportsShouldProcess = $false
	,
    ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/Set-EntityBag/'
)]
Param 
(
	# Specifies the name to modify
	[Parameter(Mandatory = $true, Position = 0)]
	[ValidateNotNullOrEmpty()]
	[Alias('n')]
	[string] $Name
	,
	# Specifies the value to modify
	[Parameter(Mandatory = $true, Position = 1)]
	[string] $Value
	,
	# Specifies the EntityId
	[Parameter(Mandatory = $true, Position = 2)]
	[long] $EntityId
	,
	# Specifies the EntityKindId
	[Parameter(Mandatory = $true, Position = 3)]
	[long] $EntityKindId
	,
	# Specifies the new value
	[Parameter(Mandatory = $false)]
	[string] $NewValue
	,
	[Parameter(Mandatory = $false)]
	[string] $Description
	,
	# Specifies the ProtectionLevel
	[Parameter(Mandatory = $false)]
	[long] $ProtectionLevel
	,
	# Specifies to create a entity if it does not exist
	[Parameter(Mandatory = $false)]
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
	Contract-Requires ($svc.Core -is [biz.dfch.CS.Appclusive.Api.Core.Core]) "Connect to the server before using the Cmdlet"
}
# Begin

Process 
{

# Default test variable for checking function response codes.
[Boolean] $fReturn = $false;
# Return values are always and only returned via OutputParameter.
$OutputParameter = $null;
$AddedEntity = $null;

try 
{
	$exp = @();
	
	$exp += ("(tolower(Name) eq '{0}')" -f $Name.ToLower());
	$exp += ("(EntityId eq {0})" -f $EntityId);
	$exp += ("(EntityKindId eq {0})" -f $EntityKindId);

	$FilterExpression = [String]::Join(' and ', $exp);

	$entity = $svc.Core.EntityBags.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$top',1) | Select;

	if(!$CreateIfNotExist -And !$entity) 
	{
		$msg = "Name: Parameter validation FAILED. Entity does not exist. Use '-CreateIfNotExist' to create resource: '{0}'" -f $Name;
		$e = New-CustomErrorRecord -m $msg -cat ObjectNotFound -o $Name;
		throw($gotoError);
	}
	if(!$entity) 
	{
		$entity = New-Object biz.dfch.CS.Appclusive.Api.Core.EntityBag;
		$svc.Core.AddToEntityBags($entity);
		$AddedEntity = $entity;
		$entity.Name = $Name;
		$entity.Value = $Value;
		$entity.EntityId = $EntityId;
		$entity.EntityKindId = $EntityKindId;
		$entity.Created = [System.DateTimeOffset]::Now;
		$entity.Modified = $entity.Created;
		$entity.CreatedById = 0;
		$entity.ModifiedById = 0;
		$entity.Tid = [guid]::Empty.ToString();
	}
	if($PSBoundParameters.ContainsKey('Description'))
	{
		$entity.Description = $Description;
	}
	if($PSBoundParameters.ContainsKey('ProtectionLevel'))
	{
		$entity.ProtectionLevel = $ProtectionLevel;
	}
	if($PSBoundParameters.ContainsKey('NewValue'))
	{
		$entity.Value = $NewValue;
	}

	$svc.Core.UpdateObject($entity);
	$r = $svc.Core.SaveChanges();

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
			if($gotoError -eq $_.Exception.Message) 
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
if($MyInvocation.ScriptName) { Export-ModuleMember -Function Set-EntityBag; } 

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

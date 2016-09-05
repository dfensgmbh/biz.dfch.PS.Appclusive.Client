function New-EntityBag {
<#
.SYNOPSIS
Creates an EntityBag entry in Appclusive.


.DESCRIPTION
Creates an EntityBag entry in Appclusive.

You must specify the parameters 'Name', 'Value', 'EntityId' and 'EntityKindId'. If the entry already exists no update of the existing entry is performed.


.OUTPUTS
default | json | json-pretty | xml | xml-pretty

.EXAMPLE
New-EntityBag -Name "ArbitraryName" -Value "ArbitraryValue" -EntityId 2 -EntityKindId 1 -svc $svc

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

Create a new EntityBag entry, if it does not yet exist.


.EXAMPLE
New-EntityBag -Name "ArbitraryName" -Value "ArbitraryValue" -EntityId 2 -EntityKindId 1 -svc $svc -Description "ArbitraryDescription" -ProtectionLevel [biz.dfch.CS.Appclusive.Public.OdataServices.Core.EntityBagProtectionLevelEnum]::Default.value__

Name            : ArbitraryName
Value           : ArbitraryValue
EntityId        : 2
EntityKindId    : 1
ProtectionLevel : 1
Id              : 159
Tid             : 11111111-1111-1111-1111-111111111111
Description     : ArbitraryDescription
CreatedById     : 1
ModifiedById    : 1
Created         : 23.08.2016 11:08:14 +02:00
Modified        : 23.08.2016 11:08:14 +02:00
RowVersion      : {0, 0, 0, 0...}
Tenant          :
CreatedBy       :
ModifiedBy      :

Create a new EntityBag entry, if it does not yet exist, with description and protectionLevel...


.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/New-EntityBag/
Set-EntityBag: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Set-EntityBag/


.NOTES
See module manifest for dependencies and further requirements.


#>
[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = 'Low'
	,
	HelpURI='http://dfch.biz/biz/dfch/PS/Appclusive/Client/New-EntityBag/'
)]
Param 
(
	# Specifies the Name to modify
	[Parameter(Mandatory = $true, Position = 0)]
	[ValidateNotNullOrEmpty()]
	[string] $Name
	,
	# Specifies the Value to modify
	[Parameter(Mandatory = $true, Position = 1)]
	[string] $Value
	,
	# Specifies the EntityKindId to modify
	[Parameter(Mandatory = $true, Position = 2)]
	[ValidateRange(1,[long]::MaxValue)]
	[long] $EntityKindId
	,
	# Specifies the EntityId to modify
	[Parameter(Mandatory = $true, Position = 3)]
	[ValidateRange(1,[long]::MaxValue)]
	[long] $EntityId
	,
	# Specifies the ProtectionLevel to modify
	[Parameter(Mandatory = $false)]
	[long] $ProtectionLevel
	,	
	# Specifies the Description to modify
	[Parameter(Mandatory = $false)]
	[string] $Description
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
	
	# ProtectionLevel param validation
	$minProtectionLevelValue = [biz.dfch.CS.Appclusive.Public.OdataServices.Core.EntityBagProtectionLevelEnum]::MinValue.value__;
	$maxProtectionLevelValue = [biz.dfch.CS.Appclusive.Public.OdataServices.Core.EntityBagProtectionLevelEnum]::MaxValue.value__;
	
	Contract-Assert($minProtectionLevelValue -le $ProtectionLevel);
	Contract-Assert($maxProtectionLevelValue -ge $ProtectionLevel);
}
# Begin

Process
{
	# Default test variable for checking function response codes.
	[Boolean] $fReturn = $false;
	# Return values are always and only returned via OutputParameter.
	$OutputParameter = $null;

	$exp = @();
	$entityBagContents = @();
	
	$exp += ("(tolower(Name) eq '{0}')" -f $Name.ToLower());
	$exp += ("(EntityId eq {0})" -f $EntityId);
	$exp += ("(EntityKindId eq {0})" -f $EntityKindId);
	$FilterExpression = [String]::Join(' and ', $exp);
	
	$entityBagContents += $Name;
	$entityBagContents += $Value;
	$entityBagContents += $EntityId;
	$entityBagContents += $EntityKindId;

	$entityBag = $svc.Core.EntityBags.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$top', 1) | Select;
	Contract-Assert (!$entityBag) 'EntityBag does already exist';
	
	if($PSCmdlet.ShouldProcess($entityBagContents))
	{
		if($PSBoundParameters.ContainsKey('Description') -And $PSBoundParameters.ContainsKey('ProtectionLevel'))
		{
			$r = Set-EntityBag -Name $Name -Value $Value -EntityId $EntityId -EntityKindId $EntityKindId -ProtectionLevel $ProtectionLevel -Description $Description -CreateIfNotExist -svc $svc;
		}
		elseif($PSBoundParameters.ContainsKey('Description'))
		{
			$r = Set-EntityBag -Name $Name -Value $Value -EntityId $EntityId -EntityKindId $EntityKindId -Description $Description -CreateIfNotExist -svc $svc;
		}
		elseif($PSBoundParameters.ContainsKey('ProtectionLevel'))
		{
			$r = Set-EntityBag -Name $Name -Value $Value -EntityId $EntityId -EntityKindId $EntityKindId -ProtectionLevel $ProtectionLevel -CreateIfNotExist -svc $svc;
		}
		else
		{
			$r = Set-EntityBag -Name $Name -Value $Value -EntityId $EntityId -EntityKindId $EntityKindId -CreateIfNotExist -svc $svc;
		}
		$OutputParameter = $r;
	}

	$fReturn = $true;
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
if($MyInvocation.ScriptName) 
{
	Export-ModuleMember -Function New-EntityBag; 
} 

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

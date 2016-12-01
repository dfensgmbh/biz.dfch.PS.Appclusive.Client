function Set-Customer {
<#
.SYNOPSIS
Sets or creates a Customer entry in Appclusive.


.DESCRIPTION
Sets or creates a Customer entry in Appclusive.

By updating a Customer entry you can specify if you want to update the name, description or any combination thereof.


.OUTPUTS
default


.EXAMPLE
Set-Customer -Name "ArbitraryName" -Description "ArbitraryDescription" -ContractMappingExternalId "ArbitraryContract" -svc $svc -CreateIfNotExist;

Id               : 42
Tid              : deaddead-dead-dead-dead-deaddeaddead
Name             : ArbitraryName
Description      : ArbitraryDescription
CreatedById      : 1
ModifiedById     : 1
Created          : 30.11.2016 12:00:00 +02:00
Modified         : 30.11.2016 12:00:00 +02:00
RowVersion       :
ContractMappings : {}
Tenants          : {}
Tenant           :
CreatedBy        :
ModifiedBy       :

Create a new Customer with an associated ContractMapping entry if it does not exists.


.EXAMPLE
Set-Customer -Id 42 -Name "AnotherName" -Description "AnotherDescription" -svc $svc;

Id               : 42
Tid              : deaddead-dead-dead-dead-deaddeaddead
Name             : AnotherName
Description      : AnotherDescription
CreatedById      : 1
ModifiedById     : 1
Created          : 30.11.2016 12:00:00 +02:00
Modified         : 30.11.2016 12:01:00 +02:00
RowVersion       :
ContractMappings : {}
Tenants          : {}
Tenant           :
CreatedBy        :
ModifiedBy       :

Update an existing Customer with new Name and Description.


.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Set-Customer/
Set-Customer: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Set-Customer/


.NOTES
See module manifest for dependencies and further requirements.


#>
[CmdletBinding(
    SupportsShouldProcess = $false
	,
    ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/Set-Customer/'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
Param 
(
	# Specifies the Id of the entry to modify
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'id')]
	[ValidateRange(1, [long]::MaxValue)]
	[long] $Id
	,
	# Specifies the Id of the entry to modify
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'create')]
	[Parameter(Mandatory = $false, Position = 1, ParameterSetName = 'id')]
	[ValidateNotNullOrEmpty()]
	[Alias('n')]
	[string] $Name
	,
	# Specifies the ExternalId of the ContractMapping to create for the Customer
	[Parameter(Mandatory = $false, Position = 1, ParameterSetName = 'create')]
	[ValidateNotNullOrEmpty()]
	[Alias('contractId')]
	[string] $ContractMappingExternalId
	,
	# Specifies the ExternalType of the ContractMapping to create for the Customer
	[Parameter(Mandatory = $false, ParameterSetName = 'create')]
	[ValidateNotNullOrEmpty()]
	[Alias('contractType')]
	[string] $ContractMappingExternalType = "SAM"
	,
	# Specifies the Name of the ContractMapping to create for the Customer
	[Parameter(Mandatory = $false, ParameterSetName = 'create')]
	[ValidateNotNullOrEmpty()]
	[Alias('contractName')]
	[string] $ContractMappingName = "Default"
	,
	[Parameter(Mandatory = $false)]
	[ValidateNotNullOrEmpty()]
	[string] $Description
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
	Contract-Requires ($svc.Core -is [biz.dfch.CS.Appclusive.Api.Core.Core]) "Connect to the server before using the Cmdlet"
}

Process 
{
	trap { Log-Exception $_; break; }

	# Default test variable for checking function response codes.
	[Boolean] $fReturn = $false;
	# Return values are always and only returned via OutputParameter.
	$OutputParameter = $null;

	if($PSCmdlet.ParameterSetName -eq 'id')
	{
		$filterExpression = "Id eq {0}L" -f $Id;
		$entity = $svc.Core.Customers.AddQueryOption('$filter', $filterExpression).AddQueryOption('$top', 1) | Select;
		
		Contract-Assert ($entity) "Entity does not exist";
	}
	else 
	{
		$currentTenant = Get-Tenant -svc $svc -Current;
		$filterExpression = "(tolower(Name) eq '{0}' and Tid eq guid'{1}')" -f $Name.ToLower(), $currentTenant.Id;
		$entity = $svc.Core.Customers.AddQueryOption('$filter', $filterExpression).AddQueryOption('$top', 1) | Select;
		
		Contract-Assert ($CreateIfNotExist -or $entity) "Entity does not exist. Use '-CreateIfNotExist' to create the resource";
	}
	
	if($CreateIfNotExist -and !$entity) 
	{
		$entity = New-Object biz.dfch.CS.Appclusive.Api.Core.Customer;
		$svc.Core.AddToCustomers($entity);
	}
	if($PSBoundParameters.ContainsKey('Description'))
	{
		$entity.Description = $Description;
	}
	if($PSBoundParameters.ContainsKey('Name'))
	{
		$entity.Name = $Name;
	}
	
	$svc.Core.UpdateObject($entity);
	$null = $svc.Core.SaveChanges();
	
	# Create default contract
	if($PSBoundParameters.ContainsKey('ContractMappingExternalId'))
	{
		$defaultContractMapping = New-Object biz.dfch.CS.Appclusive.Api.Core.ContractMapping;
		$svc.Core.AddToContractMappings($defaultContractMapping);
		
		$defaultContractMapping.Name = $ContractMappingName;
		$defaultContractMapping.ExternalType = $ContractMappingExternalType;
		$defaultContractMapping.ExternalId = $ContractMappingExternalId;
		$defaultContractMapping.IsPrimary = $true;
		$defaultContractMapping.ValidFrom = [System.DateTimeOffset]::MinValue;
		$defaultContractMapping.ValidUntil = [System.DateTimeOffset]::MaxValue;
		$defaultContractMapping.CustomerId = $entity.Id;
		
		$svc.Core.UpdateObject($defaultContractMapping);
		$null = $svc.Core.SaveChanges();
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

}
if($MyInvocation.ScriptName) { Export-ModuleMember -Function Set-Customer; } 

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

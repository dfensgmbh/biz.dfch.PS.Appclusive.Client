function Set-Tenant {
<#
.SYNOPSIS
Connects a Tenant entry with a Customer entry in Appclusive.


.DESCRIPTION
Connects a Tenant entry with a Customer entry in Appclusive.

By connecting a Tenant entry with a Customer you can specify the Customer 
by Name, Id or by the ContractMapping ExternalId.


.OUTPUTS
default


.EXAMPLE
Set-Tenant -Id 'deaddead-dead-dead-dead-deaddeaddead' -CustomerId 42 -svc $svc;

Id           : deaddead-dead-dead-dead-deaddeaddead
Name         : Arbitrary Tenant
Description  : Arbitrary Tenant
ExternalId   : deaddead-dead-dead-dead-deaddeaddead
ExternalType : External
CreatedById  : 1
ModifiedById : 1
Created      : 01.12.2016 09:00:00 +00:00
Modified     : 01.12.2016 13:57:53 +00:00
RowVersion   : {0, 0, 0, 0...}
ParentId     : 11111111-1111-1111-1111-111111111111
CustomerId   : 42
Parent       :
Customer     :
Children     : {}

Connect a Tenant entry with the specified Customer.


.EXAMPLE
Set-Tenant -Id 'deaddead-dead-dead-dead-deaddeaddead' -CustomerName 'Arbitrary Customer' -svc $svc;

Id           : deaddead-dead-dead-dead-deaddeaddead
Name         : Arbitrary Tenant
Description  : Arbitrary Tenant
ExternalId   : deaddead-dead-dead-dead-deaddeaddead
ExternalType : External
CreatedById  : 1
ModifiedById : 1
Created      : 01.12.2016 09:00:00 +00:00
Modified     : 01.12.2016 13:57:53 +00:00
RowVersion   : {0, 0, 0, 0...}
ParentId     : 11111111-1111-1111-1111-111111111111
CustomerId   : 42
Parent       :
Customer     :
Children     : {}

Connect a Tenant entry with the specified Customer.


.EXAMPLE
Set-Tenant -Id 'deaddead-dead-dead-dead-deaddeaddead' -ContractMappingExternalId 'Arbitrary Contract' -svc $svc;

Id           : deaddead-dead-dead-dead-deaddeaddead
Name         : Arbitrary Tenant
Description  : Arbitrary Tenant
ExternalId   : deaddead-dead-dead-dead-deaddeaddead
ExternalType : External
CreatedById  : 1
ModifiedById : 1
Created      : 01.12.2016 09:00:00 +00:00
Modified     : 01.12.2016 13:57:53 +00:00
RowVersion   : {0, 0, 0, 0...}
ParentId     : 11111111-1111-1111-1111-111111111111
CustomerId   : 42
Parent       :
Customer     :
Children     : {}

Connect a Tenant entry with the Customer of the specified ContractMapping.


.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Set-Tenant/
Set-Tenant: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Set-Tenant/


.NOTES
See module manifest for dependencies and further requirements.


#>
[CmdletBinding(
	SupportsShouldProcess = $false
	,
	ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/Set-Tenant/'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
Param
(
	[Parameter(Mandatory = $true, Position = 0)]
	[Guid] $Id
	,
	[Parameter(Mandatory = $true, ParameterSetName = 'customerId', Position = 1)]
	[ValidateRange(1,[long]::MaxValue)]
	[long] $CustomerId
	,
	[Parameter(Mandatory = $true, ParameterSetName = 'customerName', Position = 1)]
	[ValidateNotNullOrEmpty()]
	[string] $CustomerName
	,
	[Parameter(Mandatory = $true, ParameterSetName = 'contractMappingId', Position = 1)]
	[ValidateNotNullOrEmpty()]
	[Alias('contractId')]
	[string] $ContractMappingExternalId
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
	
	# Get Tenant
	$filterExpression = "Id eq guid'{0}'" -f $Id;
	$entity = $svc.Core.Tenants.AddQueryOption('$filter', $filterExpression).AddQueryOption('$top', 1) | Select;
		
	Contract-Assert ($entity) "Entity does not exist";
	
	if($PSCmdlet.ParameterSetName -eq 'contractMappingId') 
	{
		$filterExpression = "ExternalId eq '{0}'" -f $ContractMappingExternalId;
		$contractMapping = $svc.Core.ContractMappings.AddQueryOption('$filter', $filterExpression) | Select;

		Contract-Assert($contractMapping);
		Contract-Assert(1 -eq $contractMapping.Count) "More than one ContractMapping with specified ExternalId found";
		
		$filterExpression = "Id eq {0}" -f $contractMapping.CustomerId;
		$customer = $svc.Core.Customers.AddQueryOption('$filter', $filterExpression) | Select;
		Contract-Assert($customer);
		
		$svc.Core.AddLink($customer, 'Tenants', $entity);
	}
	elseif($PSCmdlet.ParameterSetName -eq 'customerId')
	{
		$filterExpression = "Id eq {0}" -f $CustomerId;
		$customer = $svc.Core.Customers.AddQueryOption('$filter', $filterExpression) | Select;
		Contract-Assert($customer);
		
		$svc.Core.AddLink($customer, 'Tenants', $entity);
	}
	elseif($PSCmdlet.ParameterSetName -eq 'customerName')
	{
		$filterExpression = "Name eq '{0}'" -f $CustomerName;
		$customer = $svc.Core.Customers.AddQueryOption('$filter', $filterExpression) | Select;

		Contract-Assert($customer);
		Contract-Assert(1 -eq $customer.Count) "More than one Customer with specified Name found";
		
		$svc.Core.AddLink($customer, 'Tenants', $entity);
	}
	
	$null = $svc.Core.SaveChanges();

	# WORKAROUND - detach entity to force reload with CustomerId
	$svc.core.Detach($entity);
	$entity = $svc.Core.Tenants.AddQueryOption('$filter', $filterExpression).AddQueryOption('$top', 1) | Select;
	
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

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Set-Tenant; } 

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

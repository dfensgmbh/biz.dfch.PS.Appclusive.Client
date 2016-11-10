function New-Role {
<#
.SYNOPSIS
Creates a Role entry in Appclusive.


.DESCRIPTION
Creates a Role entry in Appclusive.

You must specify the parameters 'Name' and 'RoleType'. If the entry already exists no update of the existing entry is performed.


.OUTPUTS
default | json | json-pretty | xml | xml-pretty

.EXAMPLE
New-Role -Name ArbitraryRole -RoleType External

RoleType     : External
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

Create a new Role entry if it not already exists.


.EXAMPLE
New-Role -Name ArbitraryRole -RoleType External -Description ArbitraryDescription -MailAddress arbitrary@example.com

RoleType     : External
MailAddress  : arbitrary@example.com
Id           : 42
Tid          : 11111111-1111-1111-1111-111111111111
Name         : ArbitraryRole
Description  : ArbitraryDescription
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

Create a new Role entry if it not already exists, with Description and MailAddress.


.EXAMPLE
New-Role -Name ArbitraryRole -RoleType External -Permissions @("Apc:NodesCanRead","Apc:NodesCanCreate")

RoleType     : External
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

Create a new Role entry if it not already exists, with specified Permissions


.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/New-Role/
Set-Role: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Set-Role/


.NOTES
See module manifest for dependencies and further requirements.


#>
[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = 'Low'
	,
	HelpURI='http://dfch.biz/biz/dfch/PS/Appclusive/Client/Role/'
)]
Param 
(
	[Parameter(Mandatory = $true, Position = 0)]
	[ValidateNotNullOrEmpty()]
	[Alias('n')]
	[string] $Name
	,
	[Parameter(Mandatory = $true, Position = 1)]
	[ValidateSet('Default', 'Security', 'Distribution', 'BuiltIn', 'External')]
	[string] $RoleType
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
	# Specifies the permissions to be linked
	[Parameter(Mandatory = $false)]
	[string[]] $Permissions = @()
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

	$Exp = @();
	$RoleContents = @();
	
	$Exp += ("(tolower(Name) eq '{0}')" -f $Name.ToLower());
	$FilterExpression = [String]::Join(' and ', $Exp);
	
	$RoleContents += $Name;

	$role = $svc.Core.Roles.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$top',1) | Select;
	Contract-Assert (!$role) 'Entity does already exist';
	
	if($PSCmdlet.ShouldProcess($RoleContents))
	{
		$r = Set-Role -Name $Name -RoleType $RoleType -svc $svc -CreateIfNotExist;
		
		if($PSBoundParameters.ContainsKey("Description"))
		{
			$r = Set-Role -Name $Name -Description $Description -svc $svc;
		}
		if($PSBoundParameters.ContainsKey("MailAddress"))
		{
			$r = Set-Role -Name $Name -MailAddress $MailAddress -svc $svc;
		}
		if($PSBoundParameters.ContainsKey("Permissions"))
		{
			$r = Set-Role -Name $Name -Permissions $Permissions -svc $svc;
		}
		
		$OutputParameter = $r;
	}

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
if($MyInvocation.ScriptName) { Export-ModuleMember -Function New-Role; } 

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

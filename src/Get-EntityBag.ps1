function Get-EntityBag {
<#
.SYNOPSIS
Retrieves one or more entities from the EntityBag entity set.


.DESCRIPTION
Retrieves one or more entities from the EntityBag entity set.

You can retrieve one ore more entities from the entity set by specifying 
Id, Name or other properties.


.INPUTS
The Cmdlet can either return all available entities or filter entities on 
specified conditions.
See PARAMETERS section on possible inputs.


.OUTPUTS
default | json | json-pretty | xml | xml-pretty

In addition output can be filtered on specified properties.


.EXAMPLE
Get-EntityBag -ListAvailable -Select Name

Name
----
myvCenter
ActivitiClientUri
ServiceBusClientUri
WindowsAdminUri

Retrieves the name of all EntityBags.


.EXAMPLE
Get-EntityBag -id 159

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

Retrieves the EntityBag object with Id 159 and returns all properties of it.



.EXAMPLE
Get-EntityBag -ListAvailable -Select Name, Id -First 3

Name                    Id
----                    --
myvCenter               4
ActivitiClientUri       5
ServiceBusClientUri     8

Retrieves the name and id of the first 3 EntityBags.



.EXAMPLE
Get-EntityBag HttpProxy -Select Value -ValueOnly -DefaultValue 'http://proxy:8080'

http://proxy:8080

Retrieves the 'Value' property of a EntityBag with Name 'HttpProxy' 
and http://proxy:8080 if the entity is not found.


.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Get-EntityBag/


.NOTES
See module manifest for required software versions and dependencies.


#>
[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/Get-EntityBag/'
	,
	DefaultParameterSetName = 'list'
)]
PARAM 
(
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'id')]
	[ValidateRange(1,[long]::MaxValue)]
	[long] $Id
	,
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'name')]
	[Parameter(Mandatory = $false, ParameterSetName = 'entityReference')]
	[Alias('n')]
	[string] $Name
	,
	[Parameter(Mandatory = $true, ParameterSetName = 'entityReference')]
	[long] $EntityKindId
	,
	[Parameter(Mandatory = $true, ParameterSetName = 'entityReference')]
	[long] $EntityId
	,
	# [Parameter(Mandatory = $true, ParameterSetName = 'entity')]
	# [biz.dfch.CS.Appclusive.Core.OdataServices.Core.BaseEntity] $entity
	# ,
	# Specify the attributes of the entity to return
	[Parameter(Mandatory = $false)]
	[string[]] $Select = @()
	,
	# Specifies to return only values without header information. 
	# This parameter takes precendes over the 'Select' parameter.
	[ValidateScript( { if(1 -ge $Select.Count -And $_) { $true; } else { throw("You must specify exactly one 'Select' property when using 'ValueOnly'."); } } )]
	[Parameter(Mandatory = $false)]
	[Alias('HideTableHeaders')]
	[switch] $ValueOnly
	,
	# This value is only returned if the regular search would have returned no results
	[Parameter(Mandatory = $false)]
	[Alias('default')]
	$DefaultValue
	,
	# Specifies to deserialize JSON payloads
	[ValidateScript( { if($ValueOnly -And $_) { $true; } else { throw("You must set the 'ValueOnly' switch when using 'ConvertFromJson'."); } } )]
	[Parameter(Mandatory = $false)]
	[Alias('Convert')]
	[switch] $ConvertFromJson
	,
	# Limits the output to the specified number of entries
	[Parameter(Mandatory = $false)]
	[Alias('top')]
	[long] $First
	,
	# Service reference to Appclusive
	[Parameter(Mandatory = $false)]
	[Alias('Services')]
	[hashtable] $svc = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Services
	,
	# Indicates to return all file information
	[Parameter(Mandatory = $false, ParameterSetName = 'list')]
	[switch] $ListAvailable = $false
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
	
	$EntitySetName = 'EntityBags';
	
	# Parameter validation
	Contract-Requires ($svc.Core -is [biz.dfch.CS.Appclusive.Api.Core.Core]) "Connect to the server before using the Cmdlet"
	
	if($Select) 
	{
		$Select = $Select | Select -Unique;
	}
	elseif ($ValueOnly)
	{
		$Select = 'Value';
	}
}
# Begin

Process 
{
	trap { Log-Exception $_; break; }

	# Default test variable for checking function response codes.
	[Boolean] $fReturn = $false;
	# Return values are always and only returned via OutputParameter.
	$OutputParameter = $null;

	Contract-Assert ($PSCmdlet.ShouldProcess(($PSBoundParameters | Out-String)));
	
	$response = @();
	$exp = @();

	if($PSCmdlet.ParameterSetName -eq 'list') 
	{
		if($Select) 
		{
			if($PSBoundParameters.ContainsKey('First'))
			{
				$response = $svc.Core.$EntitySetName.AddQueryOption('$orderby', 'Name').AddQueryOption('$top', $First) | Select -Property $Select;
			}
			else
			{
				$response = $svc.Core.$EntitySetName.AddQueryOption('$orderby', 'Name') | Select -Property $Select;
			}
		}
		else 
		{
			if($PSBoundParameters.ContainsKey('First'))
			{
				$response = $svc.Core.$EntitySetName.AddQueryOption('$orderby', 'Name').AddQueryOption('$top', $First) | Select;
			}
			else
			{
				$response = $svc.Core.$EntitySetName.AddQueryOption('$orderby', 'Name') | Select;
			}
		}
	}
	else 
	{
		if ($PSCmdlet.ParameterSetName -eq 'name')
		{
			$exp += ("(tolower(Name) eq '{0}')" -f $name.ToLower());
		}
		elseif ($PSCmdlet.ParameterSetName -eq 'id')
		{
			$exp += ("Id eq {0}" -f $Id);
		}
		elseif ($PSCmdlet.ParameterSetName -eq 'entityReference')
		{
			$exp += ("EntityKindId eq {0}" -f $EntityKindId);
			$exp += ("EntityId eq {0}" -f $EntityId);
			if($Name)
			{
				$exp += ("(tolower(Name) eq '{0}')" -f $name.ToLower());
			}
		}
		# elseif ($PSCmdlet.ParameterSetName -eq 'entity')
		# {
	
		# }
	
		$filterExpression = [String]::Join(' and ', $exp);
		if($Select -And 'object' -ne $As) 
		{
			if($PSBoundParameters.ContainsKey('First'))
			{
				$response = $svc.Core.$EntitySetName.AddQueryOption('$top', $First).AddQueryOption('$filter', $filterExpression) | Select -Property $Select;
			}
			else
			{
				$response = $svc.Core.$EntitySetName.AddQueryOption('$filter', $filterExpression) | Select -Property $Select;
			}
		}
		else
		{
			if($PSBoundParameters.ContainsKey('First'))
			{
				$response = $svc.Core.$EntitySetName.AddQueryOption('$top', $First).AddQueryOption('$filter', $filterExpression) | Select;
			}
			else
			{
				$response = $svc.Core.$EntitySetName.AddQueryOption('$filter', $filterExpression) | Select;
			}
		}
	}

	if(1 -eq $Select.Count -And $ValueOnly)
	{
		$response = $response.$Select;
	}
	if($PSBoundParameters.ContainsKey('DefaultValue') -And !$response)
	{
		$response = $DefaultValue;
	}
	if($ValueOnly -And $ConvertFromJson)
	{
		$responseTemp = New-Object System.Collections.ArrayList;
		foreach($item in $response)
		{
			try
			{
				$null = $responseTemp.Add((ConvertFrom-Json -InputObject $item));
			}
			catch
			{
				$null = $responseTemp.Add($item);
			}
		}
		$response = $responseTemp.ToArray();
	}
	$OutputParameter = Format-ResultAs $response $As
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

} # function

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Get-EntityBag; } 

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

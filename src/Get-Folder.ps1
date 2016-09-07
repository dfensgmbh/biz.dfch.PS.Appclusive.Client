function Get-Folder {
<#
.SYNOPSIS
Retrieves one or more entities from the Folder entity set.


.DESCRIPTION
Retrieves one or more entities from the Folder entity set.

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
Get-Node -ListAvailable -Select Id, Name

  Id Name
  -- ----
   8  SomeArbitraryNode
  15  SomeOtherNode
  42  TheAnswerToEverythingNode
 667  NeighbourNode

Retrieves the id and name of all Nodes.


.EXAMPLE
Get-Node 218

Parameters     : {"Hostname":"Server01"}
EntityKindId   : 27
ParentId       : 1
Id             : 218
Tid            : 22222222-2222-2222-2222-222222222222
Name           : abhenry
Description    : abhenry is a whiles for timeous purposes
CreatedById    : 1
ModifiedById   : 1
Created        : 15.12.2015 12:06:49 +01:00
Modified       : 15.12.2015 12:06:49 +01:00
RowVersion     : {0, 0, 0, 0...}
Parent         :
EntityKind     :
Children       : {}
IncomingAssocs : {}
OutgoingAssocs : {}
Tenant         :
CreatedBy      :
ModifiedBy     :

Retrieves the Node object with Id 218 and returns all properties of it.


.EXAMPLE
Get-Node 218 -Select Parameters -ValueOnly -ConvertFromJson

Hostname
---
Server01

Similar to the previous example, but only returns the 'Parameters' property 
of it. In addition the contents of the property will be converted from JSON.


.EXAMPLE
Get-Node -ListAvailable -Select Id -First 3

Id
--
218
271
358

Retrieves the id of the first 3 Nodes.


.EXAMPLE
Get-Node 218 -Select Name -ValueOnly

abhenry

Retrieves the name of the Node with Id 218.


.EXAMPLE
Get-Node -ModifiedBy SYSTEM -Select Id, Name

Id Name
-- ----
 1 Root Node
 2 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
 3 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
 4 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
 5 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
 6 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
 7 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
 8 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
 9 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
10 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
11 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
12 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
13 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
14 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
15 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
16 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
17 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
18 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
19 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
20 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node

Retrieves id and name of all Nodes that have been modified by user 
with name 'SYSTEM' (case insensitive substring match).


.EXAMPLE
Get-Node AppclusiveScheduler -Select Name -ValueOnly -DefaultValue 'AppclusiveSchedulerNotAvailable'

AppclusiveSchedulerNotAvailable

Retrieves the 'Name' property of a Node with Name 'AppclusiveScheduler' 
and AppclusiveSchedulerNotAvailable if the entity is not found.


.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Get-Node/


.NOTES
See module manifest for required software versions and dependencies.


#>
[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/Get-Folder/'
	,
	DefaultParameterSetName = 'list'
)]
PARAM 
(
	# Specifies the id of the entity
	[Parameter(Mandatory = $false, ParameterSetName = 'id')]
	[long] $Id
	,
	# Specifies the name of the entity
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[Alias('n')]
	[string] $Name
	,
	# Filter by creator
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[string] $CreatedBy
	,
	# Filter by modifier
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[string] $ModifiedBy
	,
	# Specifies the Parent id for this entity
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[long] $ParentId
	,
	# Specify the attributes of the entity to return
	[Parameter(Mandatory = $false)]
	[string[]] $Select = @()
	,
	# Specifies to return only values without header information. 
	# This parameter takes precendes over the 'Select' parameter.
	[ValidateScript( { if(1 -eq $Select.Count -And $_) { $true; } else { throw("You must specify exactly one 'Select' property when using 'ValueOnly'."); } } )]
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[Parameter(Mandatory = $false, ParameterSetName = 'id')]
	[Alias('HideTableHeaders')]
	[switch] $ValueOnly
	,
	# Limits the output to the specified number of entries
	[Parameter(Mandatory = $false)]
	[Alias('top')]
	[int] $First
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
	# Indicates to return job information
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[Parameter(Mandatory = $false, ParameterSetName = 'id')]
	[Alias('ExpandStatus')]
	[switch] $ExpandJob = $false
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
	
	$EntitySetName = 'Folders';
	
	# Parameter validation
	Contract-Requires ($svc.Core -is [biz.dfch.CS.Appclusive.Api.Core.Core]) "Connect to the server before using the Cmdlet";	
	Contract-Requires (1 -ge ($PSBoundParameters.GetEnumerator() | Where { $_.Key -match 'Expand' -and $_.Value -eq $true}).Count) "You can specify only one 'Expand...' param.";
	
	if($Select) 
	{
		$Select = $Select | Select -Unique;
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

	Contract-Assert ($PSCmdlet.ShouldProcess(($PSBoundParameters | Out-String)))

	if($PSCmdlet.ParameterSetName -eq 'list') 
	{
		if($PSBoundParameters.ContainsKey('First'))
		{
			$Response = $svc.Core.$EntitySetName.AddQueryOption('$top', $First) | Select;
		}
		else
		{
			$Response = $svc.Core.$EntitySetName | Select;
		}
		
		if($Select) 
		{
			$Response = $Response | Select -Property $Select;
		}
	}
	else 
	{
		$Exp = @();
		if($PSCmdlet.ParameterSetName -eq 'id')
		{
			$Exp += ("Id eq {0}" -f $Id);
		}
		if($Name) 
		{ 
			$Exp += ("tolower(Name) eq '{0}'" -f $Name.ToLower());
		}
		if($ParentId)
		{
			$Exp += ("ParentId eq {0}" -f $ParentId);
		}
		if($CreatedBy) 
		{ 
			$CreatedById = Get-User -svc $svc $CreatedBy -Select Id -ValueOnly;
			Contract-Assert ( !!$CreatedById ) 'User not found';
			$Exp += ("CreatedById eq {0}" -f $CreatedById);
		}
		if($ModifiedBy)
		{ 
			$ModifiedById = Get-User -svc $svc $ModifiedBy -Select Id -ValueOnly;
			Contract-Assert ( !!$ModifiedById ) 'User not found';
			$Exp += ("(ModifiedById eq {0})" -f $ModifiedById);
		}
		
		$FilterExpression = [String]::Join(' and ', $Exp);
		$Response = $svc.Core.$EntitySetName.AddQueryOption('$filter', $FilterExpression) | Select;
		
		if($Select) 
		{
			$Response = $Response | Select -Property $Select;
		}
		if(1 -eq $Select.Count -And $ValueOnly)
		{
			$Response = $Response.$Select;
		}
		
		<#
		
		
		
		if($EntityKindId)
		{
			$Exp += ("(EntityKindId eq {0})" -f $EntityKindId);
		}
		$FilterExpression = [String]::Join(' and ', $Exp);
	
		if($PSBoundParameters.ContainsKey('First'))
		{
			$Response = $svc.Core.$EntitySetName.AddQueryOption('$filter', $FilterExpression) | Select;
		}
	
		
		else 
		{
			if ( $ExpandJob )
			{
				$ResponseTemp = New-Object System.Collections.ArrayList;
				foreach ($item in $Response)
				{
					if ( $item )
					{
						$Response_ = $svc.Core.InvokeEntityActionWithSingleResult($item, 'Status', [System.Object], $null);
						$null = $ResponseTemp.Add($Response_);
					}
				}
				$Response = $ResponseTemp.ToArray();
			}
		}


#>
	}

	$OutputParameter = Format-ResultAs $Response $As;
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

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Get-Folder; } 

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

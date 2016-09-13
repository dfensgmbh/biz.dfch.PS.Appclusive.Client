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
Get-Folder -ListAvailable -Select Id, Name

   Id Name
   -- ----
   42 arbitrary folder
  100 another folder
  101 folder 2
  666 folder 3

Retrieves the id and name of all Folders.


.EXAMPLE
Get-Folder -Id 34253 -svc $svc

EntityId       :
Parameters     : {}
EntityKindId   : 28
ParentId       : 1680
Id             : 34253
Tid            : abcd1234-abcd-1234-abcd-12345abcdefg
Name           : Arbitrary Folder
Description    :
CreatedById    : 653
ModifiedById   : 653
Created        : 09.06.2016 14:28:56 +02:00
Modified       : 09.06.2016 14:28:56 +02:00
RowVersion     : {0, 0, 0, 0...}
EntityKind     :
Parent         :
Children       : {}
IncomingAssocs : {}
OutgoingAssocs : {}
Tenant         :
CreatedBy      :
ModifiedBy     :

Retrieves the Folder object with Id 34253 and returns all properties of it.


.EXAMPLE
Get-Folder -ParentId 42 -Select Name -ValueOnly -svc $svc

arbitrary folder
another folder
some folder

Returns the names (just the value) of the folders that have parentId with id 42.


.EXAMPLE
Get-Folder -ListAvailable -Select Id -First 3 -svc $svc

   Id
   --
   42
  100
  101

Retrieves the id of the first 3 Folders.


.EXAMPLE
Get-Folder -ModifiedBy TestUser -Select Id, Name -svc $svc

   Id Name
   -- ----
   42 arbitrary folder
  100 another folder
  101 folder 2
  666 folder 3

Retrieves id and name of all Folders that have been modified by user
with name 'TestUser' (case insensitive substring match).


.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Get-Folder/


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
	[Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'id')]
	[ValidateRange(1,[long]::MaxValue)]
	[long] $Id
	,
	# Specifies the name of the entity
	[Parameter(Mandatory = $true, ParameterSetName = 'name')]
	[ValidateNotNullOrEmpty()]
	[Alias('n')]
	[string] $Name
	,
	# Filter by creator
	[Parameter(Mandatory = $false, ParameterSetName = 'createdBy')]
	[string] $CreatedBy
	,
	# Filter by modifier
	[Parameter(Mandatory = $false, ParameterSetName = 'modifiedBy')]
	[string] $ModifiedBy
	,
	# Specifies the Parent id for this entity
	[Parameter(Mandatory = $false, ParameterSetName = 'parentId')]
	[ValidateRange(1,[long]::MaxValue)]
	[long] $ParentId
	,
	# Specify the attributes of the entity to return
	[Parameter(Mandatory = $false)]
	[string[]] $Select = @()
	,
	# Specifies to return only values without header information. 
	# This parameter takes precendes over the 'Select' parameter.
	[ValidateScript( { if(1 -eq $Select.Count -And $_) { $true; } else { throw("You must specify exactly one 'Select' property when using 'ValueOnly'."); } } )]
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
		elseif($PSCmdlet.ParameterSetName -eq 'name') 
		{
			$Exp += ("tolower(Name) eq '{0}'" -f $Name.ToLower());
		}
		elseif($PSCmdlet.ParameterSetName -eq 'parentId')
		{
			$Exp += ("ParentId eq {0}" -f $ParentId);
			if($createdby)
			{
				$createdById = Get-User -svc $svc $createdBy -Select Id -ValueOnly;
				Contract-Assert ( !!$createdById ) 'User not found';
				$Exp += ("CreatedById eq {0}" -f $createdById)
			}
			if($modifiedby)
			{
				$modifiedById = Get-User -svc $svc $modifiedBy -Select Id -ValueOnly;
				Contract-Assert ( !!$modifiedById ) 'User not found';
				$Exp += ("(ModifiedById eq {0})" -f $modifiedById);
			}
		}
		elseif($PSCmdlet.ParameterSetName -eq 'createdby')
		{
			$CreatedById = Get-User -svc $svc $CreatedBy -Select Id -ValueOnly;
			Contract-Assert ( !!$CreatedById ) 'User not found';
			$Exp += ("CreatedById eq {0}" -f $CreatedById);
		}
		elseif($PSCmdlet.ParameterSetName -eq 'modifiedby')
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
		if($First)
		{
			$Response = $Response | Select -First 1;
		}
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

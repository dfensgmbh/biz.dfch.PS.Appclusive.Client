function New-Folder {
<#
.SYNOPSIS
Creates a folder entry in Appclusive.


.DESCRIPTION
Creates a folder entry in Appclusive.

You must specify all four parameters 'Name', 'NodeId', 'ExternalId' and 'ExternalType'. If the entry already exists no update of the existing entry is performed.


.OUTPUTS
[biz.dfch.CS.Appclusive.Api.Core.ExternalNode]


.EXAMPLE
New-ApcExternalNode -Name "Arbitrary Name" -NodeId 42 -ExternalType ArbitraryType -ExternalId "http://example.com/api/items/1"

NodeId       : 42
ExternalType : ArbitraryType
ExternalId   : http://example.com/api/items/1
Id           : 61059
Tid          : 11111111-1111-1111-1111-111111111111
Name         : Arbitrary Name
Description  :
CreatedById  : 1
ModifiedById : 1
Created      : 22.08.2016 09:27:39 +02:00
Modified     : 22.08.2016 09:27:39 +02:00
RowVersion   : {0, 0, 0, 0...}
Node         :
Properties   : {}
Tenant       :
CreatedBy    :
ModifiedBy   :

Create a new ExternalNode entry if it not already exists.


.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/New-ExternalNode/
Set-ExternalNode: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Set-ExternalNode/


.NOTES
See module manifest for dependencies and further requirements.


#>
[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/New-ExternalNode/'
)]
Param 
(
	# Specifies the name for this entity
	[Parameter(Mandatory = $true, Position = 0)]
	[ValidateNotNullOrEmpty()]
	[string] $Name
	,
	# Specifies the description for this entity
	[Parameter(Mandatory = $false)]
	[string] $Description
	,
	# Specifies the parent Id for this entity
	[Parameter(Mandatory = $false)]
	[Alias("pid")]
	[hashtable] $ParentId = (Get-ApcTenant -Current -svc $svc).NodeId
	,
	# Specifies the parameters for this entity
	[Parameter(Mandatory = $false)]
	[Alias("p")]
	[hashtable] $Parameters = @{}
	,
	# Service reference to Appclusive
	[Parameter(Mandatory = $false)]
	[Alias('Services')]
	[hashtable] $svc = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Services
)

Begin 
{
	trap { Log-Exception $_; break; }

	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug -fn $fn -msg ("CALL. svc '{0}'. Name '{1}'. ParentId '{2}'." -f ($svc -is [Object]), $Name, $ParentId) -fac 1;

	# Parameter validation
	Contract-Requires ($svc.Core -is [biz.dfch.CS.Appclusive.Api.Core.Core]) "Connect to the server before using the Cmdlet"
	
	$EntitySetName = 'Folders';
}
# Begin

Process
{
	trap { Log-Exception $_; break; }

	# Default test variable for checking function response codes.
	[Boolean] $fReturn = $false;
	# Return values are always and only returned via OutputParameter.
	$OutputParameter = $null;

	$FolderContents = @($Name);
	$Exp = @();
	$Exp += "(tolower(Name) eq '{0}')" -f $Name.toLower();
	$Exp += "(tolower(Description) eq '{0}')" -f $Description.toLower();
	$Exp += "(ParentId eq {0})" -f $ParentId;
	$FilterExpression = [String]::Join(' and ', $Exp);
	$entity = $svc.Core.$EntitySetName.AddQueryOption('$filter', $FilterExpression) | Select;
	
	Contract-Assert (!$entity) 'Entity does already exist';

	if($PSCmdlet.ShouldProcess($FolderContents))
	{
		$r = Set-Folder @PSBoundParameters -CreateIfNotExist:$true;
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
if($MyInvocation.ScriptName) { Export-ModuleMember -Function New-ExternalNode; } 

# 
# Copyright 2014-2015 d-fens GmbH
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

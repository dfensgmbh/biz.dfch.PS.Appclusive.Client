function New-Folder {
<#
.SYNOPSIS
Creates a folder entry in Appclusive.


.DESCRIPTION
Creates a folder entry in Appclusive.

You must specify parameter 'Name'. If the entry already exists no update of the existing entry is performed.


.OUTPUTS
[biz.dfch.CS.Appclusive.Api.Core.Folder]


.EXAMPLE
New-Folder -svc $svc -Name "Arbitrary Name"

EntityId       :
Parameters     : {}
EntityKindId   : 28
ParentId       : 1
Id             : 79780
Tid            : 11111111-1111-1111-1111-111111111111
Name           : Arbitrary Name
Description    :
CreatedById    : 1
ModifiedById   : 1
Created        : 09.09.2016 13:31:36 +02:00
Modified       : 09.09.2016 13:31:36 +02:00
RowVersion     : {0, 0, 0, 0...}
EntityKind     :
Parent         :
Children       : {}
IncomingAssocs : {}
OutgoingAssocs : {}
Tenant         :
CreatedBy      :
ModifiedBy     :

Create a new Folder entry if it not already exists.


.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/New-Folder/


.NOTES
See module manifest for dependencies and further requirements.


#>
[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/New-Folder/'
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
	# Specifies the parent Id for this entity, default is the root folder
	[Parameter(Mandatory = $false)]
	[ValidateRange(1,[long]::MaxValue)]
	[Alias("pid")]
	[long] $ParentId = (Get-ApcTenant -Current -svc $svc).NodeId
	,
	# Specifies the parameters for this entity
	[Parameter(Mandatory = $false)]
	[Alias("p")]
	[string] $Parameters = '{}'
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
	
	if($PSCmdlet.ShouldProcess($FolderContents))
	{
		$r = Set-Folder @PSBoundParameters;
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
if($MyInvocation.ScriptName) { Export-ModuleMember -Function New-Folder; } 

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

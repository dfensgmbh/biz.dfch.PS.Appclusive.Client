function Test-Connect {
<#
.SYNOPSIS
Test connections (Interfaces/Connectors) created in Appclusive.

.DESCRIPTION
Test connections (Interfaces/Connectors) created in Appclusive.

Check if an EntityKind can connect to a different EntityKind or Node.
Check if a Connector can be removed.

Returns Flag.
.INPUTS
See PARAMETERS section on possible inputs.

.OUTPUTS
default | json | json-pretty | xml | xml-pretty

.EXAMPLE

.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Test-Connect/

.NOTES
See module manifest for required software versions and dependencies.
#>
[CmdletBinding(
    SupportsShouldProcess = $false
	,
    ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/Test-Connect/'
	,
	DefaultParameterSetName = 'Node'
)]
PARAM 
(
	# EntityKindId of the Entity to check
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'EntityKind')]
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Node')]
    [Alias("EkId")]
	[string] $EntityKindId
	,
	# Parent EntityKindId to check against
	[Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'EntityKind')]
    [Alias("PEkId")]
	[string] $ParentEntityKindId
	,
	# Parent NodeNodeId to check against
	[Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Node')]
    [Alias("Node")]
    [Alias("NId")]
	[string] $ParentNodeId
	,
	# Service Reference to Appclusive
	[Parameter(Mandatory = $false)]
	[Alias('Services')]
	[hashtable] $svc = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Services
)

Begin 
{
	trap { Log-Exception $_; break; }

	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug -fn $fn -msg ("CALL. svc '{0}'. InputObject '{1}'." -f ($svc -is [Object]), $InputObject) -fac 1;
		
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

    $entitySetName = "Nodes";
    $entityId = $ParentNodeId;
	if ($PSCmdlet.ParameterSetName -eq 'EntityKind')
	{
        $entitySetName = "EntityKinds";
        $entityId = $ParentEntityKindId;
	}

    $response = $svc.Core.InvokeEntityActionWithSingleResult($entitySetName, $entityId, "CanConnect", [bool], @{"EntityKindId"=$EntityKindId});

	$OutputParameter = $response;
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

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Test-Connect; } 

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

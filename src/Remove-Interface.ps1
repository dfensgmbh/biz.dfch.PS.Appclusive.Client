function Remove-Interface {
<#
.SYNOPSIS
Removes a Interface.

.DESCRIPTION
Removes a Interface.

The Cmdlet lets you remove an existing entry from the Interface.

.EXAMPLE
Remove-Interface -Id interfaceId -Confirm

Removes the Interface with explicit confirmation.
#>
[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = 'High'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/Remove-Interface/'
)]
Param 
(
	# The key name portion of the KNV to remove
	[Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'Id')]
	[string] $Id
	,
	# The name name portion of the KNV to remove
	[Parameter(Mandatory = $false, Position = 1, ParameterSetName = 'Name')]
	[string] $Name
	,
	# Service reference to Appclusive
	[Parameter(Mandatory = $false)]
	[Alias('Services')]
	[hashtable] $svc = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Services
	,
	# Specifies the return format of the Cnmdlet
	[ValidateSet('default', 'json', 'json-pretty', 'xml', 'xml-pretty')]
	[Parameter(Mandatory = $false)]
	[alias('ReturnFormat')]
	[string] $As = 'default'
)

Begin 
{
	trap { Log-Exception $_; break; }

    $entitySetName = "Interfaces";
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug -fn $fn -msg ("CALL. svc '{0}'. Name '{1}'." -f ($svc -is [Object]), $Name) -fac 1;

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

	$Exp = @();
	if($Id) 
	{ 
		$Exp += ("(Id eq {0})" -f $Id);
	}
	if($Name) 
	{ 
		$Exp += ("(tolower(Name) eq '{0}')" -f $Name.ToLower());
	}

	$FilterExpression = [String]::Join(' and ', $Exp);

	$interface = $svc.Core.$entitySetName.AddQueryOption('$filter',$FilterExpression).AddQueryOption('$top', 1);
    Remove-Entity -svc $svc -Id $interface.Id -EntitySetName $entitySetName -Confirm:$false;

	$OutputParameter = Format-ResultAs $r $As
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
if($MyInvocation.ScriptName) { Export-ModuleMember -Function Remove-Interface; } 
 
#
# Copyright 2015-2016 d-fens GmbH
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
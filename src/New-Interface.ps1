function New-Interface {
<#
.SYNOPSIS
Creates an Interface entry in Appclusive.
.DESCRIPTION
Creates an Interface entry in Appclusive.
You must specify a Name and a ParentId (default is 1, which is the root Node).
.OUTPUTS
default | json | json-pretty | xml | xml-pretty
.EXAMPLE
.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/New-Interface/
Set-KeyNameValue: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Set-Interface/
.NOTES
See module manifest for dependencies and further requirements.
#>
[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = 'Low'
	,
	HelpURI='http://dfch.biz/biz/dfch/PS/Appclusive/Client/New-Interface/'
)]
Param 
(
	# Specifies the name to modify
	[Parameter(Mandatory = $true, Position = 0)]
	[ValidateNotNullOrEmpty()]
	[string] $Name
	,
	# Specifies the value to modify
	[Parameter(Mandatory = $false, Position = 1)]
	[long] $ParentId = 1
	,
	# Specifies the value to modify
	[Parameter(Mandatory = $false)]
	[string] $Description
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
	Contract-Requires ($svc.Core -is [biz.dfch.CS.Appclusive.Api.Core.Core]) "Connect to the server before using the Cmdlet"
}
# Begin

Process
{
	# Default test variable for checking function response codes.
	[Boolean] $fReturn = $false;
	# Return values are always and only returned via OutputParameter.
	$OutputParameter = $null;

	$Exp = @();
	if($Name) 
	{ 
		$Exp += ("(Name eq '{0}')" -f $Name);
	}

	$FilterExpression = [String]::Join(' and ', $Exp);
	$interface = $svc.Core.Interfaces.AddQueryOption('$filter',$FilterExpression).AddQueryOption('$top', 1);

	if ($interface)
	{
		$msg = "Parameter validation FAILED. Interface with Name '{0}' already exists." -f $Name;
		Log-Error $fn $msg;
		$e = New-CustomErrorRecord -m $msg -cat ResourceExists -o $Name;
		throw($gotoError);
	}
	
	if($PSCmdlet.ShouldProcess($KeyNameValueContents))
	{
		if($PSBoundParameters.ContainsKey('Description'))
		{
			$r = Set-Interface -Name $Name -Value $Value -Description $Description -CreateIfNotExist -svc $svc -As $As;
		}
		else
		{
			$r = Set-Interface -Name $Name -Value $Value -CreateIfNotExist -svc $svc -As $As;
		}
		
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

if($MyInvocation.ScriptName) { Export-ModuleMember -Function New-Interface; } 
 
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
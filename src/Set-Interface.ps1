function Set-Interface {
<#
.SYNOPSIS
Sets or creates an Interface entry in Appclusive.
.DESCRIPTION
Sets or creates an Interface entry in Appclusive.
Can create or update an Interface, needs Name and ParentId.
.OUTPUTS
default | json | json-pretty | xml | xml-pretty | PSCredential | Clear
.EXAMPLE
.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Set-Interface/
.NOTES
See module manifest for dependencies and further requirements.
#>
[CmdletBinding(
    SupportsShouldProcess = $false
	,
    ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/Set-Interface/'
)]
Param 
(
	# Specifies the name to modify
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName="Id")]
	[long] $Id
	,
	# Specifies the name to modify
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName="Name")]
	[Alias('n')]
	[string] $Name
	,
	# Specifies the new name name
	[Parameter(Mandatory = $false)]
	[string] $NewName
    ,
	# Specifies the description
	[Parameter(Mandatory = $false)]
	[long] $ParentId = 1
	,
	# Specifies the description
	[Parameter(Mandatory = $false)]
	[string] $Description
	,
	# Specifies to create a KNV if it does not exist
	[Parameter(Mandatory = $false)]
	[Alias("c")]
	[switch] $CreateIfNotExist = $false
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
    $AddedEntity = $null;

	$filter = ("Name eq '{0}'" -f $Name);
	$interface = $svc.Core.Interfaces.AddQueryOption('$filter', $filter).AddQueryOption('$top',1) | Select;
	
	$Exp = @();
	if($Id) 
	{ 
		$Exp += ("(Id eq {0})" -f $Id);
	}
	if($Name) 
	{ 
		$Exp += ("(Name eq '{0}')" -f $Name);
	}

	$FilterExpression = [String]::Join(' and ', $Exp);

	$interface = $svc.Core.Interfaces.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$top', 1) | Select;
	$r = @();

	if(!$CreateIfNotExist -And !$interface) 
	{
		$msg = "Interface: Parameter validation FAILED. Entity does not exist. Use '-CreateIfNotExist' to create resource.";
		$e = New-CustomErrorRecord -m $msg -cat ObjectNotFound -o $Name;
		throw($gotoError);
	}

	if(!$interface) 
	{
		$interface = New-Object biz.dfch.CS.Appclusive.Api.Core.Interface;
		$interface.Name = $Name;
		$interface.ParentId = $ParentId;

		$svc.Core.AddToInterfaces($interface);

		$AddedEntity = $interface;
		$interface.Created = [System.DateTimeOffset]::Now;
		$interface.Modified = [System.DateTimeOffset]::Now;
		$interface.CreatedById = 0;
		$interface.ModifiedById = 0;
		$interface.Tid = [guid]::Empty.ToString();
	}

	if($NewName) { $interface.Name = $NewName; }
    
	if($PSBoundParameters.ContainsKey('Description'))
	{
		$interface.Description = $Description;
	}

	$svc.Core.UpdateObject($interface);
	$r = $svc.Core.SaveChanges();
	
	$r = $interface | Select @{ Name="JobUri"; Expression={$_.Name.Replace('http://','https://').Replace('JobResponses','Jobs')} }, @{ Name="JobId"; Expression={$_.Id} };

	if ( !$Async )
	{
		$r = Get-Job -Id $r.JobId -svc $svc -ExpandInterface;
		# DFTODO retry handling
	}
	
	$OutputParameter = Format-ResultAs $r $As;
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

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Set-Interface; } 
 
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

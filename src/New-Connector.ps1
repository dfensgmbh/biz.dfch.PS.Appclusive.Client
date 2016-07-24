function New-Connector {
<#
.SYNOPSIS
Creates an Connector entry in Appclusive.
.DESCRIPTION
Creates an Connector entry in Appclusive.
You must specify a Name, InterfaceId and EntityKindId.
.OUTPUTS
default | json | json-pretty | xml | xml-pretty
.EXAMPLE
.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/New-Connector/
Set-Connector: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Set-Connector/
.NOTES
See module manifest for dependencies and further requirements.
#>
[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = 'Low'
	,
	HelpURI='http://dfch.biz/biz/dfch/PS/Appclusive/Client/New-Connector/'
)]
Param 
(
	# Specifies the new name name
	[Parameter(Mandatory = $true)]
	[string] $Name
    ,
	# Specifies the description
	[Parameter(Mandatory = $true)]
	[long] $InterfaceId = 1
	,
	# Specifies the description
	[Parameter(Mandatory = $true)]
	[long] $EntityKindId = 1
	,
	# Specifies the description
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

    $entitySetName = "Connectors";

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
	$entity = $svc.Core.$entitySetName.AddQueryOption('$filter',$FilterExpression).AddQueryOption('$top', 1);

	if ($entity)
	{
		$msg = "{0}: Parameter validation FAILED. Entity with Name '{1}' already exists." -f $entitySetName,$Name;
		Log-Error $fn $msg;
		$e = New-CustomErrorRecord -m $msg -cat ResourceExists -o $Name;
		throw($gotoError);
	}
	
	if($PSCmdlet.ShouldProcess($Name))
	{
		if($PSBoundParameters.ContainsKey('Description'))
		{
			$r = Set-Connector -Name $Name -InterfaceId $InterfaceId -EntityKindId $EntityKindId -Description $Description -CreateIfNotExist -svc $svc -As $As;
		}
		else
		{
			$r = Set-Connector -Name $Name -InterfaceId $InterfaceId -EntityKindId $EntityKindId -CreateIfNotExist -svc $svc -As $As;
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

if($MyInvocation.ScriptName) { Export-ModuleMember -Function New-Connector; } 

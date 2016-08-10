function Remove-Connector {
<#
.SYNOPSIS
Removes a Connector.

.DESCRIPTION
Removes a Connector.

The Cmdlet lets you remove an existing entry from the Connector.

.EXAMPLE
Remove-Connector -Id connectorId -Confirm

Removes the Connector with explicit confirmation.
#>
[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = 'High'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/Remove-Connector/'
)]
Param 
(
	# The key name portion of the KNV to remove
	[Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'Id')]
	[string] $Id
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

    $entitySetName = "Connectors";
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
if($MyInvocation.ScriptName) { Export-ModuleMember -Function Remove-Connector; } 
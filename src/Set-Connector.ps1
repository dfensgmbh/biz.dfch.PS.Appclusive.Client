function Set-Connector {
<#
.SYNOPSIS
Sets or creates an Connector entry in Appclusive.
.DESCRIPTION
Sets or creates an Connector entry in Appclusive.
Can create or update an Connector, needs Name, InterfaceId and EntityKindId.
.OUTPUTS
default | json | json-pretty | xml | xml-pretty | PSCredential | Clear
.EXAMPLE
.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Set-Connector/
.NOTES
See module manifest for dependencies and further requirements.
#>
[CmdletBinding(
    SupportsShouldProcess = $false
	,
    ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/Set-Connector/'
)]
Param 
(
	# Specifies the name to modify
	[Parameter(Mandatory = $false)]
	[long] $Id
	,
	# Specifies the new name name
	[Parameter(Mandatory = $false)]
	[string] $Name
    ,
	# Specifies the description
	[Parameter(Mandatory = $false)]
	[long] $InterfaceId = 1
	,
	# Specifies the description
	[Parameter(Mandatory = $false)]
	[long] $EntityKindId = 1
	,
	# Specifies the description
	[Parameter(Mandatory = $true, Position=5, ParameterSetName="Provide")]
	[switch] $Provide
	,
	# Specifies the description
	[Parameter(Mandatory = $true, Position=5, ParameterSetName="Require")]
	[switch] $Require
	,
	# Specifies the description
	[Parameter(Mandatory = $false)]
	[long] $Multiplicity = 1
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
    # Default test variable for checking function response codes.
    [Boolean] $fReturn = $false;
    # Return values are always and only returned via OutputParameter.
    $OutputParameter = $null;
    $AddedEntity = $null;

	$Exp = @();
	if($Id) 
	{ 
		$Exp += ("(Id eq {0})" -f $Id);
	    $entity = $svc.Core.$entitySetName.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$top', 1) | Select;
	}

	$r = @();

	if(!$CreateIfNotExist -And !$entity) 
	{
		$msg = "{0}: Parameter validation FAILED. Entity does not exist. Use '-CreateIfNotExist' to create resource." -f $entitySetName;
		$e = New-CustomErrorRecord -m $msg -cat ObjectNotFound -o $Name;
		throw($gotoError);
	}

	if(!$entity) 
	{
		$entity = New-Object biz.dfch.CS.Appclusive.Api.Core.Connector;
		$entity.Name = $Name;
		$entity.InterfaceId = $InterfaceId;
		$entity.EntityKindId = $EntityKindId;
        $entity.Multiplicity = $Multiplicity;
        
        if (!!$Provide) { $entity.ConnectionType = 1; }
        if (!!$Require) { $entity.ConnectionType = 2; }

		$svc.Core.AddToConnectors($entity);

		$AddedEntity = $entity;
		$entity.Created = [System.DateTimeOffset]::Now;
		$entity.Modified = [System.DateTimeOffset]::Now;
		$entity.CreatedById = 0;
		$entity.ModifiedById = 0;
		$entity.Tid = [guid]::Empty.ToString();
	}

	if($Name) { $entity.Name = $Name; }
	if($InterfaceId) { $entity.InterfaceId = $InterfaceId; }
	if($EntityKindId) { $entity.EntityKindId = $EntityKindId; }
	if($Description) { $entity.Description = $Description; }
	if($Multiplicity) { $entity.Multiplicity = $Multiplicity; }
        
    if (!!$Provide) { $entity.ConnectionType = 1; }
    if (!!$Require) { $entity.ConnectionType = 2; }
    
	$svc.Core.UpdateObject($entity);
	$r = $svc.Core.SaveChanges();

	$r = $entity;
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

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Set-Connector; } 

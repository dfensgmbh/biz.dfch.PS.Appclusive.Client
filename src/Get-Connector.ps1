function Get-Connector {
<#

.SYNOPSIS

Retrieves Connectors from the Appclusive server.


.DESCRIPTION

Retrieves Connectors from the Appclusive server.

Interfaces are used to define Connectors between EntityKinds. Besides specifying a selection you can furthermore define the order, the selected columns and the return format.
If you specify 'object' as output type then all filter options such as 'Select' are ignored.


.OUTPUTS

default | json | json-pretty | xml | xml-pretty


.INPUTS

You basically specify key, name and value to be retrieved. If one or more of these parameters are omitted all entities are returned that match these criteria.
If you specify 'object' as output type then all filter options such as 'Select' are ignored.

.NOTES
See module manifest for dependencies and further requirements.

#>
[CmdletBinding(
    SupportsShouldProcess = $false
	,
    ConfirmImpact = 'Low'
	,
	DefaultParameterSetName = 'list'
)]
PARAM 
(
	# Specifies the Key property of the entity.
	[Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'Id')]
	[string] $Id
	,
	# Specifies the order of the returned entites. You can specify more than one property (e.g. Key and Name).
	[ValidateSet('Id', 'Name')]
	[Parameter(Mandatory = $false, Position = 1)]
	[string[]] $OrderBy = @('Id','Name')
	,
	# Specifies to return only values without header information. 
	# This parameter takes precendes over the 'Select' parameter.
	[Alias('HideTableHeaders')]
	[switch] $ValueOnly
	,
	# Specifies to deserialize JSON payloads
	[ValidateSet('json')]
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[Alias('Convert')]
	[string] $ConvertFrom
	,
	# Limits the output to the specified number of entries
	[Parameter(Mandatory = $false)]
	[Alias('top')]
	[int] $First
	,
	# This value is only returned if the regular search would have returned no results
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[Alias('default')]
	$DefaultValue
	,
	# Specifies a references to the Appclusive endpoints
	[Parameter(Mandatory = $false)]
	[Alias('Services')]
	[hashtable] $svc = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Services
	,
	# Specifies to return all existing entities
	[Parameter(Mandatory = $false, ParameterSetName = 'list')]
	[switch] $ListAvailable = $false
    ,
	# Specifies the return format of the search
	[ValidateSet('default', 'json', 'json-pretty', 'xml', 'xml-pretty', 'object')]
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

	$EntitySetName = 'Connectors';
	
	# Parameter validation
	Contract-Requires ($svc.Core -is [biz.dfch.CS.Appclusive.Api.Core.Core]) "Connect to the server before using the Cmdlet"

	$OrderBy = $OrderBy | Select -Unique;
	$OrderByString = [string]::Join(',', $OrderBy);
	$Select = $Select | Select -Unique;

	if($ValueOnly)
	{
		if('object' -eq $As)
		{
			throw ("'ReturnFormat':'object' and 'ValueOnly' must not be specified at the same time." );
			$e = New-CustomErrorRecord -m $msg -cat InvalidArgument -o $PSCmdlet;
			$PSCmdlet.ThrowTerminatingError($e);
		}
		$Select = 'Value';
	}
	if($PSBoundParameters.ContainsKey('Select') -And 'object' -eq $As)
	{
		$msg = ("'ReturnFormat':'object' and 'Select' must not be specified at the same time." );
		$e = New-CustomErrorRecord -m $msg -cat InvalidArgument -o $PSCmdlet;
		$PSCmdlet.ThrowTerminatingError($e);
	}
}
# Begin

Process 
{

    # Default test variable for checking function response codes.
    [Boolean] $fReturn = $false;
    # Return values are always and only returned via OutputParameter.
    $OutputParameter = $null;
	
    try 
    {
	    # Parameter validation
	    # N/A
	
	    if($PSCmdlet.ParameterSetName -eq 'list') 
	    {
		    if($Select -And 'object' -ne $As) 
		    {
			    if($PSBoundParameters.ContainsKey('First'))
			    {
				    $Response = $svc.Core.$EntitySetName.AddQueryOption('$orderby','Name').AddQueryOption('$top', $First) | Select -Property $Select;
			    }
			    else
			    {
				    $Response = $svc.Core.$EntitySetName.AddQueryOption('$orderby','Name') | Select -Property $Select;
			    }
		    }
		    else 
		    {
			    if($PSBoundParameters.ContainsKey('First'))
			    {
				    $Response = $svc.Core.$EntitySetName.AddQueryOption('$orderby','Name').AddQueryOption('$top', $First) | Select;
			    }
			    else
			    {
				    $Response = $svc.Core.$EntitySetName.AddQueryOption('$orderby','Name') | Select;
			    }
		    }
	    } 
	    else 
	    {
		    $Exp = @();
		    if($Id) 
		    { 
			    $Exp += ("(Id eq {0})" -f $Id);
		    }

		    $FilterExpression = [String]::Join(' and ', $Exp);

		    if($Select -And 'object' -ne $As) 
		    {
			    if($PSBoundParameters.ContainsKey('First'))
			    {
				    $Response = $svc.Core.$EntitySetName.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$orderby', $OrderByString).AddQueryOption('$top', $First) | Select -Property $Select;
			    }
			    else
			    {
				    $Response = $svc.Core.$EntitySetName.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$orderby', $OrderByString) | Select -Property $Select;
			    }
		    }
		    else 
		    {
			    if($PSBoundParameters.ContainsKey('First'))
			    {
				    $Response = $svc.Core.$EntitySetName.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$orderby', $OrderByString).AddQueryOption('$top', $First) | Select;
			    }
			    else
			    {
				    $Response = $svc.Core.$EntitySetName.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$orderby', $OrderByString) | Select;
			    }
		    }
            
            if (!$Response)
            {
		        if($PSBoundParameters.ContainsKey('DefaultValue'))
		        {
			        $Response = $DefaultValue;
		        }
            }

		    if('Value' -eq $Select -And $ValueOnly)
		    {
			    $Response = ($Response).Value;
		    }

		    if('Value' -eq $Select -And $ConvertFrom)
		    {
			    $ResponseTemp = New-Object System.Collections.ArrayList;
			    foreach($item in $Response)
			    {
				    try
				    {
					    $null = $ResponseTemp.Add((ConvertFrom-Json -InputObject $item));
				    }
				    catch
				    {
					    $null = $ResponseTemp.Add($item);
				    }
			    }
			    $Response = $ResponseTemp.ToArray();
			    Remove-Variable ResponseTemp -Confirm:$false;
		    }
	    }
	
	    $OutputParameter = Format-ResultAs $Response $As
	    $fReturn = $true;
    }
    catch 
    {
	    if($gotoSuccess -eq $_.Exception.Message) 
	    {
		    $fReturn = $true;
	    } 
	    else 
	    {
		    [string] $ErrorText = "catch [$($_.FullyQualifiedErrorId)]";
		    $ErrorText += (($_ | fl * -Force) | Out-String);
		    $ErrorText += (($_.Exception | fl * -Force) | Out-String);
		    $ErrorText += (Get-PSCallStack | Out-String);
		
		    if($_.Exception -is [System.Net.WebException]) 
		    {
			    Log-Critical $fn ("[WebException] Request FAILED with Status '{0}'. [{1}]." -f $_.Exception.Status, $_);
			    Log-Debug $fn $ErrorText -fac 3;
		    } 
		    else 
		    {
			    Log-Error $fn $ErrorText -fac 3;
			    if($gotoError -eq $_.Exception.Message) 
			    {
				    Log-Error $fn $e.Exception.Message;
				    $PSCmdlet.ThrowTerminatingError($e);
			    } 
			    elseif($gotoFailure -ne $_.Exception.Message) 
			    { 
				    Write-Verbose ("$fn`n$ErrorText"); 
			    } 
			    else 
			    {
				    # N/A
			    }
		    } 
		    $fReturn = $false;
		    $OutputParameter = $null;
	    } 
    } 
    finally 
    {
	    # Clean up
	    # N/A
    }

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
if($MyInvocation.ScriptName) { Export-ModuleMember -Function Get-Connector; } 
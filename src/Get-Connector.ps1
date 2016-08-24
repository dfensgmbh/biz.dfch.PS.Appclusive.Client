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
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Id')]
	[long] $Id
	,
	# Specifies to return all existing entities
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'EntityKindId')]
	[long] $EntityKindId
	,
	# Specifies to return all existing entities
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'InterfaceId')]
	[long] $InterfaceId
	,
	# Specifies the order of the returned entites. You can specify more than one property (e.g. Key and Name).
	[ValidateSet('Id', 'Name', 'EntityKindId', 'InterfaceId')]
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
	# Specifies to return all existing entities
	[Parameter(Mandatory = $false)]
	[switch] $Require = $false
	,
	# Specifies to return all existing entities
	[Parameter(Mandatory = $false)]
	[switch] $Provide = $false
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
		    if($PSBoundParameters.ContainsKey('Id')) 
		    { 
			    $Exp += ("(Id eq {0})" -f $Id);
		    }
		    if($PSBoundParameters.ContainsKey('EntityKindId')) 
		    { 
			    $Exp += ("(EntityKindId eq {0})" -f $EntityKindId);
		    }
		    if($PSBoundParameters.ContainsKey('InterfaceId')) 
		    { 
			    $Exp += ("(InterfaceId eq {0})" -f $InterfaceId);
		    }
		    if($PSBoundParameters.ContainsKey('Require')) 
		    { 
			    $Exp += ("(ConnectionType eq {0})" -f [biz.dfch.CS.Appclusive.Public.OdataServices.Core.ConnectorType]::Require.value__);
		    }
		    if($PSBoundParameters.ContainsKey('Provide')) 
		    { 
			    $Exp += ("(ConnectionType eq {0})" -f [biz.dfch.CS.Appclusive.Public.OdataServices.Core.ConnectorType]::Provide.value__);
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

# SIG # Begin signature block
# MIIXDwYJKoZIhvcNAQcCoIIXADCCFvwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUPUEPHM4IvG4kGpdEKxzszLz+
# s/6gghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
# VzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNV
# BAsTB1Jvb3QgQ0ExGzAZBgNVBAMTEkdsb2JhbFNpZ24gUm9vdCBDQTAeFw0xMTA0
# MTMxMDAwMDBaFw0yODAxMjgxMjAwMDBaMFIxCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMSgwJgYDVQQDEx9HbG9iYWxTaWduIFRpbWVzdGFt
# cGluZyBDQSAtIEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlO9l
# +LVXn6BTDTQG6wkft0cYasvwW+T/J6U00feJGr+esc0SQW5m1IGghYtkWkYvmaCN
# d7HivFzdItdqZ9C76Mp03otPDbBS5ZBb60cO8eefnAuQZT4XljBFcm05oRc2yrmg
# jBtPCBn2gTGtYRakYua0QJ7D/PuV9vu1LpWBmODvxevYAll4d/eq41JrUJEpxfz3
# zZNl0mBhIvIG+zLdFlH6Dv2KMPAXCae78wSuq5DnbN96qfTvxGInX2+ZbTh0qhGL
# 2t/HFEzphbLswn1KJo/nVrqm4M+SU4B09APsaLJgvIQgAIMboe60dAXBKY5i0Eex
# +vBTzBj5Ljv5cH60JQIDAQABo4HlMIHiMA4GA1UdDwEB/wQEAwIBBjASBgNVHRMB
# Af8ECDAGAQH/AgEAMB0GA1UdDgQWBBRG2D7/3OO+/4Pm9IWbsN1q1hSpwTBHBgNV
# HSAEQDA+MDwGBFUdIAAwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFs
# c2lnbi5jb20vcmVwb3NpdG9yeS8wMwYDVR0fBCwwKjAooCagJIYiaHR0cDovL2Ny
# bC5nbG9iYWxzaWduLm5ldC9yb290LmNybDAfBgNVHSMEGDAWgBRge2YaRQ2XyolQ
# L30EzTSo//z9SzANBgkqhkiG9w0BAQUFAAOCAQEATl5WkB5GtNlJMfO7FzkoG8IW
# 3f1B3AkFBJtvsqKa1pkuQJkAVbXqP6UgdtOGNNQXzFU6x4Lu76i6vNgGnxVQ380W
# e1I6AtcZGv2v8Hhc4EvFGN86JB7arLipWAQCBzDbsBJe/jG+8ARI9PBw+DpeVoPP
# PfsNvPTF7ZedudTbpSeE4zibi6c1hkQgpDttpGoLoYP9KOva7yj2zIhd+wo7AKvg
# IeviLzVsD440RZfroveZMzV+y5qKu0VN5z+fwtmK+mWybsd+Zf/okuEsMaL3sCc2
# SI8mbzvuTXYfecPlf5Y1vC0OzAGwjn//UYCAp5LUs0RGZIyHTxZjBzFLY7Df8zCC
# BCkwggMRoAMCAQICCwQAAAAAATGJxjfoMA0GCSqGSIb3DQEBCwUAMEwxIDAeBgNV
# BAsTF0dsb2JhbFNpZ24gUm9vdCBDQSAtIFIzMRMwEQYDVQQKEwpHbG9iYWxTaWdu
# MRMwEQYDVQQDEwpHbG9iYWxTaWduMB4XDTExMDgwMjEwMDAwMFoXDTE5MDgwMjEw
# MDAwMFowWjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# MDAuBgNVBAMTJ0dsb2JhbFNpZ24gQ29kZVNpZ25pbmcgQ0EgLSBTSEEyNTYgLSBH
# MjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKPv0Z8p6djTgnY8YqDS
# SdYWHvHP8NC6SEMDLacd8gE0SaQQ6WIT9BP0FoO11VdCSIYrlViH6igEdMtyEQ9h
# JuH6HGEVxyibTQuCDyYrkDqW7aTQaymc9WGI5qRXb+70cNCNF97mZnZfdB5eDFM4
# XZD03zAtGxPReZhUGks4BPQHxCMD05LL94BdqpxWBkQtQUxItC3sNZKaxpXX9c6Q
# MeJ2s2G48XVXQqw7zivIkEnotybPuwyJy9DDo2qhydXjnFMrVyb+Vpp2/WFGomDs
# KUZH8s3ggmLGBFrn7U5AXEgGfZ1f53TJnoRlDVve3NMkHLQUEeurv8QfpLqZ0BdY
# Nc0CAwEAAaOB/TCB+jAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIB
# ADAdBgNVHQ4EFgQUGUq4WuRNMaUU5V7sL6Mc+oCMMmswRwYDVR0gBEAwPjA8BgRV
# HSAAMDQwMgYIKwYBBQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3Jl
# cG9zaXRvcnkvMDYGA1UdHwQvMC0wK6ApoCeGJWh0dHA6Ly9jcmwuZ2xvYmFsc2ln
# bi5uZXQvcm9vdC1yMy5jcmwwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHwYDVR0jBBgw
# FoAUj/BLf6guRSSuTVD6Y5qL3uLdG7wwDQYJKoZIhvcNAQELBQADggEBAHmwaTTi
# BYf2/tRgLC+GeTQD4LEHkwyEXPnk3GzPbrXsCly6C9BoMS4/ZL0Pgmtmd4F/ximl
# F9jwiU2DJBH2bv6d4UgKKKDieySApOzCmgDXsG1szYjVFXjPE/mIpXNNwTYr3MvO
# 23580ovvL72zT006rbtibiiTxAzL2ebK4BEClAOwvT+UKFaQHlPCJ9XJPM0aYx6C
# WRW2QMqngarDVa8z0bV16AnqRwhIIvtdG/Mseml+xddaXlYzPK1X6JMlQsPSXnE7
# ShxU7alVrCgFx8RsXdw8k/ZpPIJRzhoVPV4Bc/9Aouq0rtOO+u5dbEfHQfXUVlfy
# GDcy1tTMS/Zx4HYwggSfMIIDh6ADAgECAhIRIdaZp2SXPvH4Qn7pGcxTQRQwDQYJ
# KoZIhvcNAQEFBQAwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24g
# bnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzIw
# HhcNMTYwNTI0MDAwMDAwWhcNMjcwNjI0MDAwMDAwWjBgMQswCQYDVQQGEwJTRzEf
# MB0GA1UEChMWR01PIEdsb2JhbFNpZ24gUHRlIEx0ZDEwMC4GA1UEAxMnR2xvYmFs
# U2lnbiBUU0EgZm9yIE1TIEF1dGhlbnRpY29kZSAtIEcyMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAsBeuotO2BDBWHlgPse1VpNZUy9j2czrsXV6rJf02
# pfqEw2FAxUa1WVI7QqIuXxNiEKlb5nPWkiWxfSPjBrOHOg5D8NcAiVOiETFSKG5d
# QHI88gl3p0mSl9RskKB2p/243LOd8gdgLE9YmABr0xVU4Prd/4AsXximmP/Uq+yh
# RVmyLm9iXeDZGayLV5yoJivZF6UQ0kcIGnAsM4t/aIAqtaFda92NAgIpA6p8N7u7
# KU49U5OzpvqP0liTFUy5LauAo6Ml+6/3CGSwekQPXBDXX2E3qk5r09JTJZ2Cc/os
# +XKwqRk5KlD6qdA8OsroW+/1X1H0+QrZlzXeaoXmIwRCrwIDAQABo4IBXzCCAVsw
# DgYDVR0PAQH/BAQDAgeAMEwGA1UdIARFMEMwQQYJKwYBBAGgMgEeMDQwMgYIKwYB
# BQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3JlcG9zaXRvcnkvMAkG
# A1UdEwQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwQgYDVR0fBDswOTA3oDWg
# M4YxaHR0cDovL2NybC5nbG9iYWxzaWduLmNvbS9ncy9nc3RpbWVzdGFtcGluZ2cy
# LmNybDBUBggrBgEFBQcBAQRIMEYwRAYIKwYBBQUHMAKGOGh0dHA6Ly9zZWN1cmUu
# Z2xvYmFsc2lnbi5jb20vY2FjZXJ0L2dzdGltZXN0YW1waW5nZzIuY3J0MB0GA1Ud
# DgQWBBTUooRKOFoYf7pPMFC9ndV6h9YJ9zAfBgNVHSMEGDAWgBRG2D7/3OO+/4Pm
# 9IWbsN1q1hSpwTANBgkqhkiG9w0BAQUFAAOCAQEAj6kakW0EpjcgDoOW3iPTa24f
# bt1kPWghIrX4RzZpjuGlRcckoiK3KQnMVFquxrzNY46zPVBI5bTMrs2SjZ4oixNK
# Eaq9o+/Tsjb8tKFyv22XY3mMRLxwL37zvN2CU6sa9uv6HJe8tjecpBwwvKu8LUc2
# 35IgA+hxxlj2dQWaNPALWVqCRDSqgOQvhPZHXZbJtsrKnbemuuRQ09Q3uLogDtDT
# kipbxFm7oW3bPM5EncE4Kq3jjb3NCXcaEL5nCgI2ZIi5sxsm7ueeYMRGqLxhM2zP
# TrmcuWrwnzf+tT1PmtNN/94gjk6Xpv2fCbxNyhh2ybBNhVDygNIdBvVYBAexGDCC
# BNYwggO+oAMCAQICEhEhDRayW4wRltP+V8mGEea62TANBgkqhkiG9w0BAQsFADBa
# MQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTEwMC4GA1UE
# AxMnR2xvYmFsU2lnbiBDb2RlU2lnbmluZyBDQSAtIFNIQTI1NiAtIEcyMB4XDTE1
# MDUwNDE2NDMyMVoXDTE4MDUwNDE2NDMyMVowVTELMAkGA1UEBhMCQ0gxDDAKBgNV
# BAgTA1p1ZzEMMAoGA1UEBxMDWnVnMRQwEgYDVQQKEwtkLWZlbnMgR21iSDEUMBIG
# A1UEAxMLZC1mZW5zIEdtYkgwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDNPSzSNPylU9jFM78Q/GjzB7N+VNqikf/use7p8mpnBZ4cf5b4qV3rqQd62rJH
# RlAsxgouCSNQrl8xxfg6/t/I02kPvrzsR4xnDgMiVCqVRAeQsWebafWdTvWmONBS
# lxJejPP8TSgXMKFaDa+2HleTycTBYSoErAZSWpQ0NqF9zBadjsJRVatQuPkTDrwL
# eWibiyOipK9fcNoQpl5ll5H9EG668YJR3fqX9o0TQTkOmxXIL3IJ0UxdpyDpLEkt
# tBG6Y5wAdpF2dQX2phrfFNVY54JOGtuBkNGMSiLFzTkBA1fOlA6ICMYjB8xIFxVv
# rN1tYojCrqYkKMOjwWQz5X8zAgMBAAGjggGZMIIBlTAOBgNVHQ8BAf8EBAMCB4Aw
# TAYDVR0gBEUwQzBBBgkrBgEEAaAyATIwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93
# d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wCQYDVR0TBAIwADATBgNVHSUE
# DDAKBggrBgEFBQcDAzBCBgNVHR8EOzA5MDegNaAzhjFodHRwOi8vY3JsLmdsb2Jh
# bHNpZ24uY29tL2dzL2dzY29kZXNpZ25zaGEyZzIuY3JsMIGQBggrBgEFBQcBAQSB
# gzCBgDBEBggrBgEFBQcwAoY4aHR0cDovL3NlY3VyZS5nbG9iYWxzaWduLmNvbS9j
# YWNlcnQvZ3Njb2Rlc2lnbnNoYTJnMi5jcnQwOAYIKwYBBQUHMAGGLGh0dHA6Ly9v
# Y3NwMi5nbG9iYWxzaWduLmNvbS9nc2NvZGVzaWduc2hhMmcyMB0GA1UdDgQWBBTN
# GDddiIYZy9p3Z84iSIMd27rtUDAfBgNVHSMEGDAWgBQZSrha5E0xpRTlXuwvoxz6
# gIwyazANBgkqhkiG9w0BAQsFAAOCAQEAAApsOzSX1alF00fTeijB/aIthO3UB0ks
# 1Gg3xoKQC1iEQmFG/qlFLiufs52kRPN7L0a7ClNH3iQpaH5IEaUENT9cNEXdKTBG
# 8OrJS8lrDJXImgNEgtSwz0B40h7bM2Z+0DvXDvpmfyM2NwHF/nNVj7NzmczrLRqN
# 9de3tV0pgRqnIYordVcmb24CZl3bzpwzbQQy14Iz+P5Z2cnw+QaYzAuweTZxEUcJ
# bFwpM49c1LMPFJTuOKkUgY90JJ3gVTpyQxfkc7DNBnx74PlRzjFmeGC/hxQt0hvo
# eaAiBdjo/1uuCTToigVnyRH+c0T2AezTeoFb7ne3I538hWeTdU5q9jGCBLcwggSz
# AgEBMHAwWjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# MDAuBgNVBAMTJ0dsb2JhbFNpZ24gQ29kZVNpZ25pbmcgQ0EgLSBTSEEyNTYgLSBH
# MgISESENFrJbjBGW0/5XyYYR5rrZMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEM
# MQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQB
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRYoMw4WJox2ynE
# 5i4KQ/50WLTeTzANBgkqhkiG9w0BAQEFAASCAQAnmLv72buPWs9UPW4jZZBtso1U
# IcluvARGLbOUfnmdlo+EL7isBHtIR8B1td9sIu3LNPaS1+W+E6+HgM+Gp1CVZEyD
# Ek6D2G2Y0/N8di2/GJuKV7aHPW0aJb3qBI5OFZvfvgX9qtBM0go5XuWXnHzESgbl
# jjPIHTYAqLRmxGFdj1Lqg8xqn6jAKnOpnJzkeKDgXE8LTuf7pMB3Qu5CiYrdeBOp
# 7Ap3leR5g5mbMeWOUThMx1xh3NHgzj5Hee/jvMH56Rf7HDddbPO9vW896jXDyBnt
# D+mBJAgm+umQ81X/7F5VURKCcsOrh+ZAEzmJ7BVgzlv5v04AnDB4qdkrQ6UeoYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEh1pmnZJc+8fhCfukZzFNBFDAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE2
# MDgyNDE1NTQwNlowIwYJKoZIhvcNAQkEMRYEFFIn8cwk2/Y2PVz+kf54xLmElfyA
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUY7gvq2H1g5CWlQULACScUCkz
# 7HkwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# 1pmnZJc+8fhCfukZzFNBFDANBgkqhkiG9w0BAQEFAASCAQAAKKMMXvIRbCUty/cn
# CvO6FgpCyEYqWsqAvaIPY2QrVgurvZwLj6i0hb8xwM9H0Vkxsu1xkadXcE3f0SlR
# MQRGEh1upK4V0XvRGNuGXlH8KDU/nt9Pt63Ju1/BgnbQ0Yq/Dx03ElsAvvrqxjMC
# I/8zxZFNxkx+PRTG0Da8l1TcHFpRWGoozgbQSzNDOo9fwS78xUJ2L1p9SiJr+APG
# uZRm7qacZ31QneA/rH/WDon1hLh5jBPLOTlhv+AIjoprzqU+U8bOnOkrrsRtKg5y
# 917q6cT6VU2xhzhN7Eus4HG0b/YlRNsedhzApNbkprp3L0DIvxNje7+jAvMF0So8
# dHr3
# SIG # End signature block

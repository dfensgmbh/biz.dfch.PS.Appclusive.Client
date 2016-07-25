function Format-Exception {
<#
.SYNOPSIS
Displays details of an exception.

.DESCRIPTION
Displays details of an exception.

For a given exception that occurred during execution of an Appclusive API call 
this Cmdlet will show you the details of.

.INPUTS
The Cmdlet can either return all available versions or version per single 
item.
See PARAMETERS section on possible inputs.

.OUTPUTS
default | json | json-pretty | xml | xml-pretty

.EXAMPLE
# Extracts the innermost exception from a failed SaveChanges operation.
PS > $node = New-Object biz.dfch.CS.Appclusive.Api.Core.Node;
PS > $svc.Core.AddToNodes($node);
PS > $svc.Core.SaveChanges();
PS > Format-Exception
System.Data.Services.Client.DataServiceClientException: HTTP 400.
entity : A null value was found for the property named 'Name', which has the expected type 'Edm.String[Nullable=False]'. The expected type 'Edm.String[Nullable=False]' does not allow null values.

.EXAMPLE
# Extracts the HTTP StatusCode from the innermost exception if there is a StatusCode.
PS > $node = New-Object biz.dfch.CS.Appclusive.Api.Core.Node;
PS > $svc.Core.AddToNodes($node);
PS > $svc.Core.SaveChanges();
PS > Format-Exception -StatusCode
400

.EXAMPLE
# Extracts all exceptions from a failed SaveChanges operation.
PS > $node = New-Object biz.dfch.CS.Appclusive.Api.Core.Node;
PS > $svc.Core.AddToNodes($node);
PS > $svc.Core.SaveChanges();
PS > Format-Exception -ListAvailable
System.Management.Automation.MethodInvocationException
System.Data.Services.Client.DataServiceRequestException
System.Data.Services.Client.DataServiceClientException

.EXAMPLE
# Extracts all exceptions details from a failed SaveChanges operation.
PS > $node = New-Object biz.dfch.CS.Appclusive.Api.Core.Node;
PS > $svc.Core.AddToNodes($node);
PS > $svc.Core.SaveChanges();
PS > Format-Exception -All
Exception calling "SaveChanges" with "0" argument(s): "An error occurred while processing this request."


Response       : {System.Data.Services.Client.ChangeOperationResponse}
Message        : An error occurred while processing this request.
Data           : {}
InnerException : System.Data.Services.Client.DataServiceClientException: {
                   "odata.error":{
                     "code":"","message":{
                       "lang":"en-US","value":"The request is invalid."
                     },"innererror":{
                       "message":"entity : A null value was found for the property named 'Name', which has the expected type 'Edm.String[Nullable=False]'. The expected type
                 'Edm.String[Nullable=False]' does not allow null values.\r\n","type":"","stacktrace":""
                     }
                   }
                 }
TargetSite     : System.Data.Services.Client.DataServiceResponse HandleResponse()
StackTrace     :    at System.Data.Services.Client.SaveResult.HandleResponse()
                    at System.Data.Services.Client.BaseSaveResult.EndRequest()
                    at System.Data.Services.Client.DataServiceContext.SaveChanges(SaveChangesOptions options)
                    at CallSite.Target(Closure , CallSite , Object )
HelpLink       :
Source         : Microsoft.Data.Services.Client
HResult        : -2146233079

StatusCode     : 400
Message        : {
                   "odata.error":{
                     "code":"","message":{
                       "lang":"en-US","value":"The request is invalid."
                     },"innererror":{
                       "message":"entity : A null value was found for the property named 'Name', which has the expected type 'Edm.String[Nullable=False]'. The expected type
                 'Edm.String[Nullable=False]' does not allow null values.\r\n","type":"","stacktrace":""
                     }
                   }
                 }
Data           : {}
InnerException :
TargetSite     :
StackTrace     :
HelpLink       :
Source         :
HResult        : -2146233079

.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Format-Exception/

.NOTES
See module manifest for required software versions and dependencies.
#>
[CmdletBinding(
    SupportsShouldProcess = $false
	,
    ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/Format-Exception/'
	,
	DefaultParameterSetName = 'single'
)]
PARAM 
(
	# Specifies the ErrorRecord to analyse
	[Parameter(Mandatory = $false, Position = 0)]
	[ValidateNotNullOrEmpty()]
	[Alias('er')]
	[System.Management.Automation.ErrorRecord] $ErrorRecord = $Global:Error[0]
	,
	# Specifies the (partial) exception type to analyse
	[Parameter(Mandatory = $false, ParameterSetName = 'single')]
	[string] $Name
	,
	# Extracts the HTTP StatusCode from the exception chain if available
	[Parameter(Mandatory = $false, ParameterSetName = 'single')]
	[Switch] $StatusCode = $false
	,
	# Displays all exceptions within ErrorRecord
	[Parameter(Mandatory = $false, ParameterSetName = 'all')]
	[Switch] $All = $true
	,
	# Lists the names of all exceptions within the ErrorRecord
	[Parameter(Mandatory = $false, ParameterSetName = 'list')]
	[Alias('list')]
	[Switch] $ListAvailable = $true
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
	
}
# Begin

Process 
{
	trap { Log-Exception $_; break; }
	# Default test variable for checking function response codes.
	[Boolean] $fReturn = $false;
	
	switch($PSCmdlet.ParameterSetName)
	{
		'list'
		{
			$Response = @();
			$ex = $ErrorRecord.Exception;
			while($ex)
			{
				$Response += $ex.GetType().FullName;
				
				$ex = $ex.InnerException;
			}
		}
		'all'
		{
			$Response = @();
			$ex = $ErrorRecord.Exception;
			while($ex)
			{
				$Response += $ex;
				
				$ex = $ex.InnerException.PSBase;
			}
		}
		'single'
		{
			$ex = $ErrorRecord.Exception;
			$result = Find-Exception $ex $Name;
			if(!$result)
			{
				$Response = $null;
			}
			elseif($result -is [System.Data.Services.Client.DataServiceClientException])
			{
				if($StatusCode)
				{
					$Response = $ex.StatusCode;
				}
				else
				{
					$Response = Format-DataServiceClientException $result;
				}
			}
			else
			{
				$Response = ("{0}: {1}" -f $result.GetType().FullName, ($result.PSBase | Out-String));
			}
		}
		default
		{
			$er = New-CustomErrorRecord -cat InvalidArgument -o $PSCmdlet.ParameterSetName ("Invalid ParameterSetName '{0}'" -f $PSCmdlet.ParameterSetName);
			$PSCmdlet.ThrowTerminatingError($er);
		}
	}
	
	$OutputParameter = Format-ResultAs $Response $As
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

function Find-Exception($ex, $name)
{
	Contract-Requires (!!$ex);
	Contract-Requires ($ex -is [Exception]);
	
	$parentEx = $ex;
	$isExceptionFound = $false;
	while($ex)
	{
		if($name -and ($ex.GetType().FullName -match $name))
		{
			$isExceptionFound = $true;
			break;
		}
		$parentEx = $ex;
		$ex = $ex.InnerException;
	}
	
	if(!$isExceptionFound)
	{
		if($name)
		{
			$ex = $null;
		}
		else
		{
			$ex = $parentEx;
		}
	}
	return $ex;
}

function Format-DataServiceClientException($ex)
{
	Contract-Requires ($ex -is [System.Data.Services.Client.DataServiceClientException])

	try
	{
		[xml] $xml = $ex.Message;
		$message = $xml.head.title;
	}
	catch
	{
		try
		{
			$dic = New-Object biz.dfch.CS.Appclusive.Public.DictionaryParameters($er.Exception.InnerException.InnerException.Message);
			if(0 -ge $dic.Keys.Count)
			{
				$message = $ex.Message;
			}
			else
			{
				$message = $dic.GetOrSelf('odata.error').GetOrSelf('message').GetOrSelf('value');
				if($message -eq $dic)
				{
					$message = $dic.ToString();
				}
			}
		}
		catch
		{
			$message = $ex.Message
		}
	}

	$result = "{0}: HTTP {1}.`r`n{2}`r`n{3}" -f $ex.GetType().FullName, $ex.StatusCode, $message, $ex.StackTrace;
	return $result;
}

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Format-Exception; } 

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

# SIG # Begin signature block
# MIIXDwYJKoZIhvcNAQcCoIIXADCCFvwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU9S13Mf2i+V8n7dM0RUy1VGKk
# caCgghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQNS0thUx0HG5pT
# T8q9reOHnzHOxDANBgkqhkiG9w0BAQEFAASCAQBaVkK0iEjXkHwzl8jro9OfxXrU
# wRj2n2i2bfSiZNQ864TcQaK0F3IMrhHtKOudfmXa4/9Kb/Hu4FyZ1KIrfr87E94h
# BlnY0sKfLe2PlOm1p6ICJPDJE9mJLqp67HoOX21fK9h/QSlvaP0TCP87EJwKHLVn
# 5iUQ1Y6nD+mfHsuc+Mj8aJdLX0rdKKhUM263xiPnysnPvY+Iv2CaYn2565cGBPG+
# yYGwj76E16rQS/A5FDjPdluxOJwulcaX3VZzMPIGvX6aNkfjSwkuSKwxfxab/bpS
# 2x6bOv11irB5os8EDnfNDJKZgiCCJ2CVWHikNcPhs6wYooV5vxfhzDw9bNnqoYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEh1pmnZJc+8fhCfukZzFNBFDAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE2
# MDcyNDIyMzYxNFowIwYJKoZIhvcNAQkEMRYEFGTiT8ApwRMFPduo7TU3FuERA+ZU
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUY7gvq2H1g5CWlQULACScUCkz
# 7HkwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# 1pmnZJc+8fhCfukZzFNBFDANBgkqhkiG9w0BAQEFAASCAQBd7XTH7FrpLZ6jQw5D
# 45DYNPBeYCCJW+4710W/7T25o89A9taFZvPspg5wuo3YLXqqOuXhEZ18XbwRGiVL
# REH+geoJFIdf8nOfT2PolLzkXTvazKPfXcZ0f8E53lhDez/BVRWHMw4vsNnfuwzG
# q9sPFYSAyX3OZO1EDj6y7GC7ESQOEnGCNxY2SfBr3qtASpV6b/DWN3W8nsbKCCSk
# GzubSOVoTkL/uSAoi9PhIlyWPbUMwlpMuHBXLPJmenEHkvCacBhyCfc0j2ViApJl
# WkE7ePCBR+CJ2vgzOQ0liY2sa2qeOdaSxaGjQymmI4yZj9aygeluL4efT5vZyGbQ
# 0K2U
# SIG # End signature block

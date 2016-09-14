function Get-Tenant {
<#
.SYNOPSIS
Get tenant from the systems.

.DESCRIPTION
Get tenant from the systems.

You can search for tenants in the appclusive orch. There fore you can enter a name, guid or list all available tenants.

.INPUTS
The Cmdlet can either return all available tenants or filter entities on 
specified conditions.
See PARAMETERS section on possible inputs.

.OUTPUTS
default | json | json-pretty | xml | xml-pretty

.EXAMPLE
Get-Tenant

Id           : 33333333-3333-3333-3333-333333333333
Name         : GROUP_TENANT
Description  : GROUP_TENANT
ExternalId   : 33333333-3333-3333-3333-333333333333
ExternalType : Internal
CreatedById  : 1
ModifiedById : 1
Created      : 14.12.2015 16:12:47 +00:00
Modified     : 14.12.2015 16:12:47 +00:00
RowVersion   : {0, 0, 0, 0...}
ParentId     : 33333333-3333-3333-3333-333333333333
CustomerId   :
Parent       :
Customer     :
Children     : {}

Id           : 22222222-2222-2222-2222-222222222222
Name         : HOME_TENANT
Description  : HOME_TENANT
ExternalId   : 22222222-2222-2222-2222-222222222222
ExternalType : Internal
CreatedById  : 1
ModifiedById : 1
Created      : 14.12.2015 16:12:47 +00:00
Modified     : 14.12.2015 16:12:47 +00:00
RowVersion   : {0, 0, 0, 0...}
ParentId     : 22222222-2222-2222-2222-222222222222
CustomerId   :
Parent       :
Customer     :
Children     : {}

Return all available tenants. This is the same as Get-ApcTenant -ListAvailable.

.EXAMPLE
Get-ApcTenant -Id 'bb7580a0-5d34-40b2-9851-86c66443f304'

Id           : bb7580a0-5d34-40b2-9851-86c66443f304
Name         : Managed Service Tenant
Description  : Manage Service Tenant
               (previously 2e2435b9-5a68-4d15-acc2-ca42aaa000fe)
ExternalId   : d3a08f77-f848-4757-b7f2-1600ad851a0a
ExternalType : External
CreatedById  : 1
ModifiedById : 1014
Created      : 07.03.2016 00:00:00 +01:00
Modified     : 15.03.2016 10:54:04 +01:00
RowVersion   : {0, 0, 0, 0...}
ParentId     : 11111111-1111-1111-1111-111111111111
CustomerId   :
Parent       :
Customer     :
Children     : {}

Return the tenant with the id "bb7580a0-5d34-40b2-9851-86c66443f304".

.EXAMPLE
Get-ApcTenant -Name "Te" -TenantTyp Internal

Id           : 11111111-1111-1111-1111-111111111111
Name         : SYSTEM_TENANT
Description  : SYSTEM_TENANT
ExternalId   : 11111111-1111-1111-1111-111111111111
ExternalType : Internal
CreatedById  : 1
ModifiedById : 1
Created      : 14.12.2015 16:12:47 +00:00
Modified     : 06.01.2016 18:13:00 +01:00
RowVersion   : {0, 0, 0, 0...}
ParentId     : 11111111-1111-1111-1111-111111111111
CustomerId   : 2
Parent       :
Customer     :
Children     : {}

Id           : 22222222-2222-2222-2222-222222222222
Name         : HOME_TENANT
Description  : HOME_TENANT
ExternalId   : 22222222-2222-2222-2222-222222222222
ExternalType : Internal
CreatedById  : 1
ModifiedById : 1
Created      : 14.12.2015 16:12:47 +00:00
Modified     : 14.12.2015 16:12:47 +00:00
RowVersion   : {0, 0, 0, 0...}
ParentId     : 22222222-2222-2222-2222-222222222222
CustomerId   :
Parent       :
Customer     :
Children     : {}

Id           : 33333333-3333-3333-3333-333333333333
Name         : GROUP_TENANT
...

This call return all tenants where the name "te" include and the ExternalType "Internal" is.

.EXAMPLE
# Gets information about the tenant of the currently logged in user
PS > $tenantInformation = Get-Tenant -Current;
PS > $tenantInformation
Id              : e3c70408-9da0-45f2-ab7b-29d1081e948a
ParentId        : d9c2feda-f3da-488a-8dd3-3747e40b6c6a
NodeId          : 42
JobId           : 123
CustomerId      : 5
ConfigurationId : 43
BuiltInRoles    : biz.dfch.CS.Appclusive.Core.Managers.BuiltInRoles
PS > $tenantInformation.BuiltInRoles
CloudAdmin         : 14
CloudUser          : 15
CloudGuest         : 16
CreatorOwner       : 12
Everyone           : 13
AppclusiveEveryone : 5

.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Get-Tenant/

.NOTES
See module manifest for required software versions and dependencies.
#>
[CmdletBinding(
    ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/Get-Tenant/'
	,
	DefaultParameterSetName = 'list'
)]
PARAM 
(
	# Lists all tenants
	[Parameter(Mandatory = $false, ParameterSetName = 'list')]
	[switch] $ListAvailable = $false
	,
	# Tenant id to search for
	[Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'Id')]
	[Guid] $Id
	,
	# Specifies to return all child with this tenant id
	[Parameter(Mandatory = $false, ParameterSetName = 'Parent')]
	[Guid] $ParentId
	,
	# External Tenant id
	[Parameter(Mandatory = $false, ParameterSetName = 'ExternalId')]
	[string] $ExternalId
	,
	# Tenant name or a part of it to search for
	[Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'Name')]
	[ValidateNotNullOrEmpty()]
	[string] $Name
	,
	# Specifies the type of tenant to search for
	[ValidateSet('External', 'Internal')]
	[Parameter(Mandatory = $false)]
	[string] $ExternalType
	,
	# Service reference to Appclusive
	[Parameter(Mandatory = $false)]
	[Alias('Services')]
	[hashtable] $svc = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Services
	,
	# Specifies the return format of the Cmdlet
	[ValidateSet('default', 'json', 'json-pretty', 'xml', 'xml-pretty')]
	[Parameter(Mandatory = $false)]
	[Alias('ReturnFormat')]
	[string] $As = 'default'
	,
	# Specifies to retrieve tenant information about the currently logged in user
	[Parameter(Mandatory = $false, ParameterSetName = 'current')]
	[alias('WhoAmI')]
	[switch] $Current = $false
)

Begin 
{
	trap { Log-Exception $_; break; }

	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug -fn $fn -msg ("CALL. svc '{0}'. Name '{1}'." -f ($svc -is [Object]), $Name) -fac 1;
	
	Contract-Requires ($svc.Core -is [biz.dfch.CS.Appclusive.Api.Core.Core]) "Connect to the server before using the Cmdlet"
	
	$EntitySetName = 'Tenants';
}
# Begin

Process 
{
	trap { Log-Exception $_; break; }
	# Default test variable for checking function response codes.
	[Boolean] $fReturn = $false;
	
	if($PSCmdlet.ParameterSetName -eq 'list') 
	{
		$Response = $svc.Core.$EntitySetName.AddQueryOption('$orderby','Name') | Select;
	}
	elseif($PSCmdlet.ParameterSetName -eq 'current')
	{
		$Response = $svc.Core.InvokeEntitySetActionWithSingleResult("Tenants", 'Current', [biz.dfch.CS.Appclusive.Core.Managers.TenantManagerInformation], $null);
	}
	else
	{
		$Exp = @();
		if ($PSCmdlet.ParameterSetName -eq 'Id') 
		{
			$Exp += ("Id eq guid'{0}'" -f $Id.Guid);
		}
		elseif ($PSCmdlet.ParameterSetName -eq 'Parent') 
		{
			$Exp += ("ParentId eq guid'{0}'" -f $ParentId.Guid);
		}
		elseif ($PSCmdlet.ParameterSetName -eq 'ExternalId') 
		{
			$Exp += ("ExternalId eq '{0}'" -f $ExternalId);
		}
		elseif ($PSCmdlet.ParameterSetName -eq 'Name') 
		{
			$Exp += ("substringof('{0}', tolower(Name))" -f $Name.ToLower());
		}
		
		if($ExternalType)
		{
			$Exp += ("ExternalType eq '{0}'" -f $ExternalType);
		}
		
		$FilterExpression = [string]::Join(' and ', $Exp);
		$Response = $svc.Core.$EntitySetName.AddQueryOption('$filter', $FilterExpression) | Select;
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

} # function

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Get-Tenant; } 

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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUpt8ojnFGt2OoAaZw6QjPQwYY
# nUagghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTH8t05SclE1BOw
# IRh4vOtZBE/UHTANBgkqhkiG9w0BAQEFAASCAQChoZsUnbT/ToA3qWz2vljpohmF
# tg4rgjeuJfMrg/zEiQ4gRhogCmAi3czaE9mDfjsc5J9k2WtLMePbjP/Zj3pmFt1k
# WHRxq6IES1o/ivgeMQR+a+SgiIe0UR4g0DZeyxEyotcwEEtkjAb8FtUvypQSK0Hy
# kqAWVGgH2B5rIiJ6qJNVuiFWn8FPiwVMY/HQyJblYq7yndiRBlWpTevB1cyOKXmH
# MitdWEXn0wBtglIgSfNQe4tej8g7WQpsnsDwmkeABTeQRrAH00Vh10Tw9GKe6xAS
# XcexCJcX0fOmPjtFcuBTfksSlNd5vNk0Cecfo/cq3As7R58P6G+Xz9gHeT9yoYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEh1pmnZJc+8fhCfukZzFNBFDAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE2
# MDgzMTE5MTY0N1owIwYJKoZIhvcNAQkEMRYEFDjMpMoTd79gIGuw6dtx8hUAhN6c
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUY7gvq2H1g5CWlQULACScUCkz
# 7HkwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# 1pmnZJc+8fhCfukZzFNBFDANBgkqhkiG9w0BAQEFAASCAQCXkett0Lt8ACevQCWq
# RGmU0U4eseyfqfzSVHpTfPPwBj6QKMSrAjdQKYRBZZTYkPYfpU4SYF1AM29eDJ6W
# MGQFrpbaciEzD9mZlUiznFslW5f3wRt/sQW57BC7Qci+VNnrAIb4NzYlELnBGgT7
# vw95E8hb9v69DyroJkfNHkg4dhP9DqoaFzNrtsOekTi+OGzX9y7dx296J3lB2MMs
# ZDCQ7HVZTrVJFaAzRY0vK1d0xArO7wvpVbmG6wHExFCOAg2/voX6YhuThh2NbA6v
# hdQhgOaDyThx7AJNxUggMjXUrRAbQDakw1XqUe8uyqHCy6VRp5ic5CKdzvHaxz18
# s74H
# SIG # End signature block

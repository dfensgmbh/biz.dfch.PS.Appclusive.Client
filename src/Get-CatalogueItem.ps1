function Get-CatalogueItem {
<#
.SYNOPSIS
Retrieves one or more entities from the catalogueItem entity set.

.DESCRIPTION
Retrieves one or more entities from the catalogueItem  entity set.

You can retrieve one ore more entities from the entity set by specifying 
Id, Name or other properties.

.INPUTS
The Cmdlet can either return all available entities or filter entities on 
specified conditions.
See PARAMETERS section on possible inputs.

.OUTPUTS
default | json | json-pretty | xml | xml-pretty

.EXAMPLE
Get-CatalogueItem

CatalogueId  : 15
ProductId    : 14
ValidFrom    : 01.01.0001 00:00:00 +00:00
ValidUntil   : 01.01.2025 00:00:00 +01:00
EndOfLife    : 01.01.2025 00:00:00 +01:00
Parameters   :
Id           : 36
Tid          : 9e210b40-3b9c-466a-bc4d-9f9243933350
Name         : VDI Personal
Description  :
CreatedById  : 1014
ModifiedById : 1014
Created      : 14.02.2016 15:34:39 +01:00
Modified     : 14.02.2016 15:34:39 +01:00
RowVersion   : {0, 0, 0, 0...}
Catalogue    :
Product      :
Tenant       :
CreatedBy    :
ModifiedBy   :

CatalogueId  : 15
ProductId    : 14
ValidFrom    : 01.01.0001 00:00:00 +00:00
ValidUntil   : 01.01.2025 00:00:00 +01:00
EndOfLife    : 01.01.2025 00:00:00 +01:00
Parameters   :
Id           : 37
Tid          : 9e210b40-3b9c-466a-bc4d-9f9243933350
Name         : VDI Technical
Description  :
CreatedById  : 1014
ModifiedById : 1014
Created      : 14.02.2016 15:35:19 +01:00
Modified     : 14.02.2016 15:35:19 +01:00
RowVersion   : {0, 0, 0, 0...}
Catalogue    :
Product      :
Tenant       :
CreatedBy    :
ModifiedBy   :

List all available catalogue items

.EXAMPLE
Get-CatalogueItem -Id 37

CatalogueId  : 15
ProductId    : 14
ValidFrom    : 01.01.0001 00:00:00 +00:00
ValidUntil   : 01.01.2025 00:00:00 +01:00
EndOfLife    : 01.01.2025 00:00:00 +01:00
Parameters   :
Id           : 37
Tid          : 9e210b40-3b9c-466a-bc4d-9f9243933350
Name         : VDI Technical
Description  :
CreatedById  : 1014
ModifiedById : 1014
Created      : 14.02.2016 15:35:19 +01:00
Modified     : 14.02.2016 15:35:19 +01:00
RowVersion   : {0, 0, 0, 0...}
Catalogue    :
Product      :
Tenant       :
CreatedBy    :
ModifiedBy   :

Retrieves the catalogue item with id 37

.EXAMPLE
Get-ApcProduct -SearchByName "vdi"

CatalogueId  : 15
ProductId    : 14
ValidFrom    : 01.01.0001 00:00:00 +00:00
ValidUntil   : 01.01.2025 00:00:00 +01:00
EndOfLife    : 01.01.2025 00:00:00 +01:00
Parameters   :
Id           : 36
Tid          : 9e210b40-3b9c-466a-bc4d-9f9243933350
Name         : VDI Personal
Description  :
CreatedById  : 1014
ModifiedById : 1014
Created      : 14.02.2016 15:34:39 +01:00
Modified     : 14.02.2016 15:34:39 +01:00
RowVersion   : {0, 0, 0, 0...}
Catalogue    :
Product      :
Tenant       :
CreatedBy    :
ModifiedBy   :

CatalogueId  : 15
ProductId    : 14
ValidFrom    : 01.01.0001 00:00:00 +00:00
ValidUntil   : 01.01.2025 00:00:00 +01:00
EndOfLife    : 01.01.2025 00:00:00 +01:00
Parameters   :
Id           : 37
Tid          : 9e210b40-3b9c-466a-bc4d-9f9243933350
Name         : VDI Technical
Description  :
CreatedById  : 1014
ModifiedById : 1014
Created      : 14.02.2016 15:35:19 +01:00
Modified     : 14.02.2016 15:35:19 +01:00
RowVersion   : {0, 0, 0, 0...}
Catalogue    :
Product      :
Tenant       :
CreatedBy    :
ModifiedBy   :

Retrieves the catalogue items which contains "vdi"

.EXAMPLE
Get-ApcProduct -CatalogueId 4

CatalogueId  : 4
ProductId    : 50
ValidFrom    : 01.01.0001 00:00:00 +00:00
ValidUntil   : 02.01.9999 00:00:00 +01:00
EndOfLife    : 02.01.9999 00:00:00 +01:00
Parameters   :
Id           : 35
Tid          : 9e210b40-3b9c-466a-bc4d-9f9243933350
Name         : Managed Red Hat Enterprise Linux 6
Description  : Managed Red Hat Enterprise Linux 6
CreatedById  : 1014
ModifiedById : 1014
Created      : 14.02.2016 11:51:25 +01:00
Modified     : 14.02.2016 11:53:08 +01:00
RowVersion   : {0, 0, 0, 0...}
Catalogue    :
Product      :
Tenant       :
CreatedBy    :
ModifiedBy   :

CatalogueId  : 4
ProductId    : 53
ValidFrom    : 01.01.0001 00:00:00 +00:00
ValidUntil   : 31.12.9999 23:59:59 +00:00
EndOfLife    : 31.12.9999 23:59:59 +00:00
Parameters   :
Id           : 40
Tid          : 9e210b40-3b9c-466a-bc4d-9f9243933350
Name         : Managed Windows Server 2008 R2
Description  : Managed Windows Server 2008 R2
CreatedById  : 2
ModifiedById : 2
Created      : 15.02.2016 19:12:47 +01:00
Modified     : 15.02.2016 19:12:47 +01:00
RowVersion   : {0, 0, 0, 0...}
Catalogue    :
Product      :
Tenant       :
CreatedBy    :
ModifiedBy   :

Retrieves all products which are in the catalogue with id 4

.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Get-CatalogueItem/

.NOTES
See module manifest for required software versions and dependencies.
#>
# Requires biz.dfch.PS.Appclusive.Client
[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/Get-CatalogueItem/'
	,
	DefaultParameterSetName = 'list'
)]
PARAM 
(
	# Id of the catalogue item
	[Parameter(Mandatory = $false, ParameterSetName = 'Id')]
	[ValidateNotNullOrEmpty()]
	[Int] $Id = $null
	,
	# Full name or part of it, for the item you want to search - this is not case sensitive
	[Parameter(Mandatory = $false, ParameterSetName = 'SearchByName')]
	[ValidateNotNullOrEmpty()]
	[String] $Name = $null
	,
	# Id of the product
	[Parameter(Mandatory = $false, ParameterSetName = 'ProductId')]
	[ValidateNotNullOrEmpty()]
	[String] $ProductId = $null
	,
	# Id of the catalogue
	[Parameter(Mandatory = $false, ParameterSetName = 'CatalogueId')]
	[ValidateNotNullOrEmpty()]
	[String] $CatalogueId = $null
	,
	# Lists all available products
	[Parameter(Mandatory = $false, ParameterSetName = 'list')]
	[Switch] $ListAvailable = $true
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
	
	Contract-Requires ($svc.Core -is [biz.dfch.CS.Appclusive.Api.Core.Core]) "Connect to the server before using the Cmdlet"
	
	$EntitySetName = 'CatalogueItems';
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
	else
	{
		$Exp = @();
		If ($PSCmdlet.ParameterSetName -eq 'Id') 
		{
			$Exp += ("Id eq {0}" -f $Id);
		}
		
		If ($PSCmdlet.ParameterSetName -eq 'SearchByName') 
		{
			$Exp += ("substringof('{0}', tolower(Name))" -f $Name.ToLower());
		}
		
		If ($PSCmdlet.ParameterSetName -eq 'ProductId') 
		{
			$Exp += ("ProductId eq {0}" -f $ProductId);
		}
		
		If ($PSCmdlet.ParameterSetName -eq 'CatalogueId') 
		{
			$Exp += ("CatalogueId eq {0}" -f $CatalogueId);
		}
		
		$FilterExpression = [String]::Join(' and ', $Exp);
		$Response = $svc.Core.$EntitySetName.AddQueryOption('$filter', $FilterExpression) | Select;
	}
	
	# $OutputParameter = $result
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

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Get-CatalogueItem; } 
# SIG # Begin signature block
# MIIXDwYJKoZIhvcNAQcCoIIXADCCFvwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUIeSu8iSNwPQDqOiO+dL9QmOl
# D8OgghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRhLFncWJUuT9EP
# lhpkEneubtljaDANBgkqhkiG9w0BAQEFAASCAQBGYvpjQV8UQUiEY9juNxHDNZPP
# 5zrguDvsCOt+sFHaq3AhALAGJL/w3Fg55N2idg6fzcAlsMOqm1SUe4oSA3NylxQe
# L5sd1O7hEmF/7E0BW3XsuFofUn4vqEwLE9SLKj//sPKe1Xqo3YtTFlDMFBRkwmS8
# c+kQuffuGntb9KEBm239H8ZSDyLkD5okm8PzR7gM4A/gLjQ4S3v1RCMMRPwoSnD5
# 4ntP2JJwzkNSSbkacQK7OnMkQfqPkBZdz9MH3yOxcib25Ufmj6n07cxxmHQC+IIk
# 1YyzrUx9Bd0KtxymTCVJcJZZXIJE25gBuWh5Vt+hOg2/B2GoZoqfAn1KYnkqoYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEh1pmnZJc+8fhCfukZzFNBFDAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE2
# MDcyNDIyMzYxNVowIwYJKoZIhvcNAQkEMRYEFOskQfyp7MEJWg7/2uH/eecQtwjt
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUY7gvq2H1g5CWlQULACScUCkz
# 7HkwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# 1pmnZJc+8fhCfukZzFNBFDANBgkqhkiG9w0BAQEFAASCAQBOhBtqZ8DExHWwcH6o
# 2ziMlikg1C58K+d67Y/pcQPkrMd2kmpLYvEChS0VDIaLf0m7yMoN7PDssdSLkY04
# EtsenH2cNLuxVQDnRE+c/wRWHb4LAOw5tAv1cZXCwgLe9gUVNKLuG91xuambAD6g
# gBxmM2DOQ8NVykimcvBOPXT/5XVqFCamJ1StVhL2ITEu+QVlgtDpK7X13G9NPVfI
# I/fZj8UTEXRDc5xSlu7N+Yz1dQZmrI3YscObGkcAgJ8VeG0GV6VXnL0yJg0T/G00
# FRiHrADb2sB2KCppJj+qSjXnix9DhmrJR8IxbFLCcMwoEecHP0pkKSgaxl91nUS6
# sbQM
# SIG # End signature block

# Catalogue
$svc = Enter-AppclusiveServer;

$catName = 'Default DaaS'
$cat = $svc.Core.Catalogues |? Name -eq $catName;
$cat;
$svc.Core.DeleteObject($cat);
$svc.Core.SaveChanges();

$cat = New-Object biz.dfch.CS.Appclusive.Api.Core.Catalogue;
$svc.Core.AddToCatalogues($cat);
$cat.Status = "Published";
$cat.Version = 1;
$cat.Name = "Default DaaS";
$cat.Description = "Default catalogue for DaaS VDI";
$cat.Created = [System.DateTimeOffset]::Now;
$cat.Modified = $cat.Created;
$cat.CreatedBy = "SYSTEM";
$cat.ModifiedBy = $cat.CreatedBy;
$cat.Tid = "1";
$cat.Id = 0;
$svc.Core.UpdateObject($cat);
$svc.Core.SaveChanges();

# CatalogueItems
$svc = Enter-AppclusiveServer;

$cat = $svc.Core.Catalogues |? Name -eq $catName;
$cat

$catItem = New-Object biz.dfch.CS.Appclusive.Api.Core.CatalogueItem;
$svc.Core.AddToCatalogueItems($catItem);
$svc.Core.SetLink($catItem, "Catalogue", $cat);
$catItem.CatalogueId = $cat.Id;
$catItem.Type = 'VDI';
$catItem.Version = 1;
$catItem.Name = 'VDI Personal';
$catItem.Description = 'VDI (Virtual Desktop Infrastructure) for personal use';
$catItem.Created = [System.DateTimeOffset]::Now;
$catItem.Modified = $catItem.Created;
$catItem.ValidFrom = [System.DateTimeOffset]::MinValue;
$catItem.ValidUntil = [System.DateTimeOffset]::MaxValue;
$catItem.EndOfSale = [System.DateTimeOffset]::MaxValue;
$catItem.EndOfLife = [System.DateTimeOffset]::MaxValue;
$catItem.CreatedBy = "SYSTEM";
$catItem.ModifiedBy = $catItem.CreatedBy;
$catItem.Tid = "1";
$catItem.Id = 0;
$svc.Core.UpdateObject($catItem);
$svc.Core.SaveChanges();


# KeyNameValue
$svc = Enter-AppclusiveServer;

$knvs = Get-KeyNameValue -svc $svc -ListAvailable;
foreach($knv in $knvs) { Remove-KeyNameValue -svc $svc -Confirm:$false -Key $knv.Key -Name $knv.Name -Value $knv.Value; }

New-KeyNameValue -svc $svc -Key 'biz.dfch.CS.Appclusive.Core.Managers.UpdateNotificationSubscriptions' -Name 'biz.dfch.CS.Appclusive.Core.Managers.OrderEntityManager' -Value 'biz.dfch.CS.Appclusive.Core.OdataServices.Core.Job';
New-KeyNameValue -svc $svc -Key 'biz.dfch.CS.DaaS.Backends.Sccm.CatalogueItems' -Name 'Blacklist' -Value 'Pilot$';
New-KeyNameValue -svc $svc -Key 'biz.dfch.CS.DaaS.Backends.Sccm.CatalogueItems' -Name 'Blacklist' -Value 'Test$';
New-KeyNameValue -svc $svc -Key 'biz.dfch.CS.DaaS.Backends.Sccm.CatalogueItems' -Name 'Whitelist' -Value 'DSWR.+Production$';
New-KeyNameValue -svc $svc -Key 'biz.dfch.CS.DaaS.Backends.Sccm.CatalogueItems' -Name 'Whitelist' -Value 'DSWR.+\d$';
New-KeyNameValue -svc $svc -Key 'biz.dfch.CS.Appclusive.Core.OdataServices.Core.ActiveDirectoryUsersController' -Name 'Properties' -Value '{}';
Get-KeyNameValue -svc $svc -ListAvailable;

# ManagementCredential
$mc = New-Object biz.dfch.CS.Appclusive.Api.Core.ManagementCredential;
$mc
$svc.Core.AddToManagementCredentials($mc);
$mc.Name = 'biz.dfch.CS.Appclusive.Core.OdataServices.Core.ActiveDirectoryUsersController';
$mc.Description = 'ManagementCredential for Active Directory acsess';
$mc.Username = 'SWI\sDaaSPa';
$mc.Password = "tralala";
$mc.EncryptedPassword = $mc.Password;
$mc.Created = [System.DateTimeOffset]::Now;
$mc.Modified = $mc.Created;
$mc.CreatedBy = "SYSTEM";
$mc.ModifiedBy = $mc.CreatedBy;
$mc.Tid = "1";
$mc.Id = 0;
$svc.Core.UpdateObject($mc);
$svc.Core.SaveChanges();

$mc = New-Object biz.dfch.CS.Appclusive.Api.Core.ManagementCredential;
$mc
$svc.Core.AddToManagementCredentials($mc);
$mc.Name = 'biz.dfch.CS.Appclusive.Core.OdataServices.Core.ActiveDirectoryUsersController';
$mc.Description = 'ManagementCredential for Active Directory acsess';
$mc.Username = 'SWI\sDaaSPa';
$mc.Password = "tralala";
$mc.EncryptedPassword = $mc.Password;
$mc.Created = [System.DateTimeOffset]::Now;
$mc.Modified = $mc.Created;
$mc.CreatedBy = "SYSTEM";
$mc.ModifiedBy = $mc.CreatedBy;
$mc.Tid = "1";
$mc.Id = 0;
$svc.Core.UpdateObject($mc);
$svc.Core.SaveChanges();

# Node
$svc = Enter-AppclusiveServer;

$node = New-Object biz.dfch.CS.Appclusive.Api.Core.Node
$node
$svc.Core.AddToNodes($node);
$node.Name = 'myNode';
$node.Description = 'This is a node';
$node.Parameters = '{}';
$node.Type = $node.GetType().FullName;
$node.Created = [System.DateTimeOffset]::Now;
$node.Modified = $node.Created;
$node.CreatedBy = "SYSTEM";
$node.ModifiedBy = $node.CreatedBy;
$node.Tid = "1";
$node.Id = 0;
$svc.Core.UpdateObject($node);
$svc.Core.SaveChanges();

$nodeParent = $node;

$node = New-Object biz.dfch.CS.Appclusive.Api.Core.Node
$node
$svc.Core.AddToNodes($node);
$svc.Core.SetLink($node, 'Parent', $nodeParent);
$node.ParentId = $nodeParent.Id;
$node.Name = 'ChildNode2';
$node.Description = 'This is a child node2';
$node.Parameters = '{}';
$node.Type = $node.GetType().FullName;
$node.Created = [System.DateTimeOffset]::Now;
$node.Modified = $node.Created;
$node.CreatedBy = "SYSTEM";
$node.ModifiedBy = $node.CreatedBy;
$node.Tid = "1";
$node.Id = 0;
$svc.Core.UpdateObject($node);
$svc.Core.SaveChanges();

# SCCM
# http://thedesktopteam.com/blog/heinrich/sccm-2012-r2-powershell-basics-part-1/
CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
# Import-Module .\ConfigurationManager.psd1 -verbose;
Import-Module .\ConfigurationManager.psd1;
CD P02:

# EntityTypes
$svc = Enter-AppclusiveServer;

$et = New-Object biz.dfch.CS.Appclusive.Api.Core.EntityType
$et;
$svc.Core.AddToEntityTypes($et);
$et.Name = 'biz.dfch.CS.Appclusive.Core.OdataServices.Core.Order';
$et.Description = 'Order entity definition';
$et.Parameters = '{"Executing-Continue":"Completed","Executing-Cancel":"Failed"}';
$et.Created = [System.DateTimeOffset]::Now;
$et.Modified = $et.Created;
$et.CreatedBy = "SYSTEM";
$et.ModifiedBy = $et.CreatedBy;
$et.Tid = "1";
$et.Id = 0;
$svc.Core.UpdateObject($et);
$svc.Core.SaveChanges();

$et = New-Object biz.dfch.CS.Appclusive.Api.Core.EntityType
$et;
$svc.Core.AddToEntityTypes($et);
$et.Name = 'biz.dfch.CS.Appclusive.Core.OdataServices.Core.Approval';
$et.Description = 'Approval entity definition';
$et.Parameters = '{"Created-Continue":"Approval","Created-Cancel":"Failed","Approval-Continue":"WaitingToRun","Approval-Cancel":"Declined","WaitingToRun-Continue":"Completed","WaitingToRun-Cancel":"Failed"}';
$et.Created = [System.DateTimeOffset]::Now;
$et.Modified = $et.Created;
$et.CreatedBy = "SYSTEM";
$et.ModifiedBy = $et.CreatedBy;
$et.Tid = "1";
$et.Id = 0;
$svc.Core.UpdateObject($et);
$svc.Core.SaveChanges();

$et = New-Object biz.dfch.CS.Appclusive.Api.Core.EntityType
$et;
$svc.Core.AddToEntityTypes($et);
$et.Name = 'biz.dfch.CS.Appclusive.Core.OdataServices.Core.Default';
$et.Description = 'This is the definition for the default entity type';
$et.Parameters = '{"Created-Continue":"Running","Created-Cancel":"InternalErrorState","Running-Continue":"Completed"}';
$et.Created = [System.DateTimeOffset]::Now;
$et.Modified = $et.Created;
$et.CreatedBy = "SYSTEM";
$et.ModifiedBy = $et.CreatedBy;
$et.Tid = "1";
$et.Id = 0;
$svc.Core.UpdateObject($et);
$svc.Core.SaveChanges();


# load software packages from Sccm
$svc = Enter-AppclusiveServer;

$fn = "SccmImport";

CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
$null = Import-Module .\ConfigurationManager.psd1;
CD P02:

$al = New-Object System.Collections.ArrayList;
$packages = (Get-CMCollection).Name;
Log-Debug $fn ("SCCM: Processing '{0}' packages ..." -f $packages.Count)

$whiteListValues = Get-KeyNameValue -svc $svc -Key biz.dfch.CS.DaaS.Backends.Sccm.CatalogueItems -Name Whitelist -Select Value;
$whiteLists = $whiteListValues.Value;
$blackListValues = Get-KeyNameValue -svc $svc -Key biz.dfch.CS.DaaS.Backends.Sccm.CatalogueItems -Name Blacklist -Select Value;
$blackLists = $blackListValues.Value;

foreach($package in $packages)
{
	foreach($whiteList in $whiteLists)
	{
		if($package -imatch $whiteList)
		{
			Log-Debug $fn ("{0}: whiteList matched package '{1}'" -f $whiteList, $package);
			$null = $al.Add($package);
			break;
		}
	}
	foreach($blackList in $blackLists)
	{
		if($package -imatch $blackList)
		{
			Log-Debug $fn ("{0}: blackList matched package '{1}'" -f $blackList, $package);
			if($al.Contains($package))
			{
				$null = $al.Remove($package);
			}
			break;
		}
	}
}
Log-Debug $fn ("Found '{0}' matching packages ...'" -f $al.Count);

$catItems = $svc.Core.CatalogueItems.AddQueryOption('$filter', "Type eq 'SCCM'") | Select;
foreach($catItem in $catItems)
{
	try
	{
		$svc.Core.DeleteObject($catItem);
		$svc.Core.SaveChanges();
	}
	catch
	{
		Write-Host ("removing catItem '{0}' FAILED." -f $catItem.Name);
	}
}

if($null -eq $catItem)
{
	$catItem = New-Object biz.dfch.CS.Appclusive.Api.Core.CatalogueItem;
	$svc.Core.AddToCatalogueItems($catItem);
	$svc.Core.SetLink($catItem, "Catalogue", $cat);
}

Log-Debug $fn ("Processing '{0}' matching packages ...'" -f $al.Count);
foreach($catItemName in $al)
{
	$catItem = New-Object biz.dfch.CS.Appclusive.Api.Core.CatalogueItem;
	$svc.Core.AddToCatalogueItems($catItem);
	$svc.Core.SetLink($catItem, "Catalogue", $cat);
	$catItem.CatalogueId = $cat.Id;
	$catItem.Type = 'SCCM';
	$catItem.Version = 1;
	$catItem.Name = $catItemName;
	$catItem.Description = $catItemName;
	$catItem.Created = [System.DateTimeOffset]::Now;
	$catItem.Modified = $catItem.Created;
	$catItem.ValidFrom = [System.DateTimeOffset]::MinValue;
	$catItem.ValidUntil = [System.DateTimeOffset]::MaxValue;
	$catItem.EndOfSale = [System.DateTimeOffset]::MaxValue;
	$catItem.EndOfLife = [System.DateTimeOffset]::MaxValue;
	$catItem.CreatedBy = "SYSTEM";
	$catItem.ModifiedBy = $catItem.CreatedBy;
	$catItem.Tid = "1";
	$catItem.Id = 0;
	$svc.Core.UpdateObject($catItem);
	$svc.Core.SaveChanges();
}


# SIG # Begin signature block
# MIIXDwYJKoZIhvcNAQcCoIIXADCCFvwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUOvAaxC/Im2QMbChuhh43BhEP
# NbGgghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# GDcy1tTMS/Zx4HYwggSfMIIDh6ADAgECAhIRIQaggdM/2HrlgkzBa1IJTgMwDQYJ
# KoZIhvcNAQEFBQAwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24g
# bnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzIw
# HhcNMTUwMjAzMDAwMDAwWhcNMjYwMzAzMDAwMDAwWjBgMQswCQYDVQQGEwJTRzEf
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
# 9IWbsN1q1hSpwTANBgkqhkiG9w0BAQUFAAOCAQEAgDLcB40coJydPCroPSGLWaFN
# fsxEzgO+fqq8xOZ7c7tL8YjakE51Nyg4Y7nXKw9UqVbOdzmXMHPNm9nZBUUcjaS4
# A11P2RwumODpiObs1wV+Vip79xZbo62PlyUShBuyXGNKCtLvEFRHgoQ1aSicDOQf
# FBYk+nXcdHJuTsrjakOvz302SNG96QaRLC+myHH9z73YnSGY/K/b3iKMr6fzd++d
# 3KNwS0Qa8HiFHvKljDm13IgcN+2tFPUHCya9vm0CXrG4sFhshToN9v9aJwzF3lPn
# VDxWTMlOTDD28lz7GozCgr6tWZH2G01Ve89bAdz9etNvI1wyR5sB88FRFEaKmzCC
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
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBS+2frbQ+a/eMFZ
# Uuw7A0HL7O1XjDANBgkqhkiG9w0BAQEFAASCAQAHVRwbr5ApThGOFLk65YLwRBaJ
# isxlz2a/o2PvWHQjCEIfvt0j4JKbtqwJeXyWj1N9f9/s1R7N/nkBjuxzAU0yDp4G
# FuH3j0ZP3rRdDZbMHvNCv/Aec6oKbrLErlDqdM1cvcv9hbTe+C4u6nJWycTacNjN
# mhh4TGmXLI3sniAPkm3qg46AlRZV0t3s0cgGJaRhpfTxNHoMA60Vb3SXYPDU4N27
# HzRWpgp298bF8dBhKSaA8eX/bDlalfH+aV3xGLZsdtA9/IYgWU6CZO7AkoSS+spW
# RHEfAwtreD1CKpZeJOe/RIldvW1C5Tf6SHwyKyHJz6arm/I5qiZHgmtVDaDgoYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEhBqCB0z/YeuWCTMFrUglOAzAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE1
# MTAxNjA5MzI0MFowIwYJKoZIhvcNAQkEMRYEFGpwSHGYjf/4cHX5proCF3j/ZIDD
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUs2MItNTN7U/PvWa5Vfrjv7Es
# KeYwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# BqCB0z/YeuWCTMFrUglOAzANBgkqhkiG9w0BAQEFAASCAQCQ3eShLb6RovMoofHI
# RPy5zH5uR2nBIxp0yqDxmFmgw7wtfcaRY2S/N3t69nBdhgc50AVbTYV498dv4Tho
# a92xnziz6CNO+FN0Sbly5iXuWN0Lik5Biz3yf4VJ5M9K9y+gm0HFieHMvsWjjZey
# Zie1PdW0104HRV9Q4LcvBR2uYYLH9S8SFs58VzYVBG9+9h0BAWTsN254ngpcun1P
# 4kqahuVaNriyu4p8c95poGdfyJkbN/Z6aQxLW6IGfzsDrlzJVLFJ5eqcqUxG9geV
# 0s+RTcUZAr1dopFH0G5htztIJcfiQfNsIhBptOjAmfVFIOyZBdYnWqmsA1Sw88Ce
# 18IF
# SIG # End signature block
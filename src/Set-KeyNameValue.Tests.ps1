
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Set-KeyNameValue" -Tags "Set-KeyNameValue" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\New-KeyNameValue.ps1"
	. "$here\Remove-KeyNameValue.ps1"
	. "$here\Format-ResultAs.ps1"
	
    BeforeEach {
        $moduleName = 'biz.dfch.PS.Appclusive.Client';
        Remove-Module $moduleName -ErrorAction:SilentlyContinue;
        Import-Module $moduleName;

        $svc = Enter-ApcServer;
		
		$Key = "Key-{0}" -f [guid]::NewGuid().ToString();
		$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
		$Value = "Value-{0}" -f [guid]::NewGuid().ToString();
    }

	Context "Set-KeyNameValue" {
	
		# Context wide constants
		# N/A

		It "Set-KeyNameValueWithCreateIfNotExist-ShouldReturnNewEntity" -Test {
			# Arrange
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			$result = Set-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value -Description $Description -CreateIfNotExist;

			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Key | Should Be $Key;
			$result.Name | Should Be $Name;
			$result.Value | Should Be $Value;
			$result.Description | Should Be $Description;
			
			Remove-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value -Confirm:$false;
		}

		It "Set-KeyNameValueWithoutCreateIfNotExist-ShouldReturnNull" -Test {
			# Arrange
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			$result = Set-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value -CreateIfNotExist:$false;

			# Assert
			$result | Should Be $null;
		}

		It "Set-KeyNameValueWithNewValue-ShouldReturnUpdatedEntity" -Test {
			# Arrange
			$NewKey = "NewKey-{0}" -f [guid]::NewGuid().ToString();
			$NewName = "NewName-{0}" -f [guid]::NewGuid().ToString();
			$NewValue = "NewValue-{0}" -f [guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
			
			$resultCreated = New-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value -Description $Description;
			$resultCreated | Should Not Be $null;
			
			# Act
			$result = Set-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value -NewValue $NewValue -CreateIfNotExist:$false;

			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Key | Should Be $Key;
			$result.Name | Should Be $Name;
			$result.Value | Should Be $NewValue;
			$result.Description | Should Be $Description;

			Remove-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $NewValue -Confirm:$false;
		}
		
		It "Set-KeyNameValueWithNewName-ShouldReturnUpdatedEntity" -Test {
			# Arrange
			$NewKey = "NewKey-{0}" -f [guid]::NewGuid().ToString();
			$NewName = "NewName-{0}" -f [guid]::NewGuid().ToString();
			$NewValue = "NewValue-{0}" -f [guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
			
			$resultCreated = New-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value -Description $Description;
			$resultCreated | Should Not Be $null;
			
			# Act
			$result = Set-KeyNameValue -svc $svc -Key $Key -Name $Name -NewName $NewName -Value $Value -CreateIfNotExist:$false;

			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Key | Should Be $Key;
			$result.Name | Should Be $NewName;
			$result.Value | Should Be $Value;
			$result.Description | Should Be $Description;

			Remove-KeyNameValue -svc $svc -Key $Key -Name $NewName -Value $Value -Confirm:$false;
		}

		It "Set-KeyNameValueWithNewKey-ShouldReturnUpdatedEntity" -Test {
			# Arrange
			$NewKey = "NewKey-{0}" -f [guid]::NewGuid().ToString();
			$NewName = "NewName-{0}" -f [guid]::NewGuid().ToString();
			$NewValue = "NewValue-{0}" -f [guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
			
			$resultCreated = New-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value -Description $Description;
			$resultCreated | Should Not Be $null;
			
			# Act
			$result = Set-KeyNameValue -svc $svc -Key $Key -NewKey $NewKey -Name $Name -Value $Value -CreateIfNotExist:$false;

			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Key | Should Be $NewKey;
			$result.Name | Should Be $Name;
			$result.Value | Should Be $Value;
			$result.Description | Should Be $Description;

			Remove-KeyNameValue -svc $svc -Key $NewKey -Name $Name -Value $Value -Confirm:$false;
		}

		It "Set-KeyNameValueWithNewKeyNameValue-ShouldReturnUpdatedEntity" -Test {
			# Arrange
			$NewKey = "NewKey-{0}" -f [guid]::NewGuid().ToString();
			$NewName = "NewName-{0}" -f [guid]::NewGuid().ToString();
			$NewValue = "NewValue-{0}" -f [guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
			
			$resultCreated = New-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value -Description $Description;
			$resultCreated | Should Not Be $null;
			
			# Act
			$result = Set-KeyNameValue -svc $svc -Key $Key -NewKey $NewKey -Name $Name -NewName $NewName -Value $Value -NewValue $NewValue -CreateIfNotExist:$false;

			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Key | Should Be $NewKey;
			$result.Name | Should Be $NewName;
			$result.Value | Should Be $NewValue;
			$result.Description | Should Be $Description;
			
			Remove-KeyNameValue -svc $svc -Key $NewKey -Name $NewName -Value $NewValue -Confirm:$false;
		}

		It "Set-KeyNameValueWithNewKeyNameValueDescription-ShouldReturnUpdatedEntity" -Test {
			# Arrange
			$NewKey = "NewKey-{0}" -f [guid]::NewGuid().ToString();
			$NewName = "NewName-{0}" -f [guid]::NewGuid().ToString();
			$NewValue = "NewValue-{0}" -f [guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
			$NewDescription = "NewDescription-{0}" -f [guid]::NewGuid().ToString();
			
			$resultCreated = New-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value -Description $Description;
			$resultCreated | Should Not Be $null;
			
			# Act
			$result = Set-KeyNameValue -svc $svc -Key $Key -NewKey $NewKey -Name $Name -NewName $NewName -Value $Value -NewValue $NewValue -CreateIfNotExist:$false -Description $NewDescription;

			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Key | Should Be $NewKey;
			$result.Name | Should Be $NewName;
			$result.Value | Should Be $NewValue;
			$result.Description | Should Be $NewDescription;

			Remove-KeyNameValue -svc $svc -Key $NewKey -Name $NewName -Value $NewValue -Confirm:$false;
			}

		It "Set-KeyNameValueWithDuplicate-ShouldReturnUpdatedEntity" -Test {
			# Arrange
			$NewValue = "NewValue-{0}" -f [guid]::NewGuid().ToString();
			
			$null = New-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value;
			$null = New-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $NewValue;
			
			# Act
			$result = Set-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $NewValue -NewValue $Value;

			# Assert
			$result.Value | Should Be $Value;
			
			Remove-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value -Confirm:$false;
		}
		
		It "Set-KeyNameValueWithKeyAndNameAndValueLengthGreaterThan500" -Test {
			# Arrange
			# 510 Characters
			$Key = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. S";
			
			$Name = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. S";
			
			$Value = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. S";
			
			# Act
			$result = Set-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value -CreateIfNotExist;

			# Assert
			$result.Key | Should Be $Key;
			$result.Name | Should Be $Name;
			$result.Value | Should Be $Value;
			
			Remove-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value -Confirm:$false;
		}
	}
}

#
# Copyright 2015 d-fens GmbH
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUfOIgF7MN/cmR3Yvq9cPXlzdx
# w+mgghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRcdEwrttx68J0Y
# FIBUZNsMHhgTNzANBgkqhkiG9w0BAQEFAASCAQCKfJJOGjbszHWL+8Os5u1aid5F
# /L2lmZQr/EXf6xedrfuYKIHlbtxKL7b82/x9YNBC2FoFhKz6LlVTCs4M/HZWtuYX
# P5Cj6nrO/5Y6bjamJvmcYaF1enFx+9PhbfIsP4zMywgwCRl1R1lEhWfk1pMTsTaN
# aSPBP/xnXoglCxhERZKSCGR9wAROrXau7pyHbHKLsuPc/bE12Lj0aeLPyr+mduKd
# t99iNWnBUkmliYnju1wlb0xORA1YUiP0EFslQAoXmnNlaEE3KR1bRKewTayZFlP6
# j6TbDTwMCqkB9Oh04PJTsKntF8IyBDBkLZO8ApC8UkHn3a0C3+ogQTq6ioxzoYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEh1pmnZJc+8fhCfukZzFNBFDAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE2
# MDgzMTE5MTcwNVowIwYJKoZIhvcNAQkEMRYEFCjE4Ls6TTlU6tTlSEcOl1+b04sl
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUY7gvq2H1g5CWlQULACScUCkz
# 7HkwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# 1pmnZJc+8fhCfukZzFNBFDANBgkqhkiG9w0BAQEFAASCAQBftIYv3QKlBXpEPYEe
# wtu5hPwO1Kpu/PGXWO08BVXznoWDB7bUL1Bzp8aDzib0oPBh7+JJ3vgYgo6DzPqs
# 0tTQzAx4JEWQE4bnPVmjNV1IUhGO8eqly+Qnkov9eIRnkOiTWAYaZ2COid92idAj
# 8cC+eS4qvq5VnuxXg2ICFAodu4bLuy4ImvaGRszB3DiP9wcGPZLLvpORX0c0Ne+x
# wVFnDxvljauthqlnxazACZ9OV5GcPnw0QhSC6qTyWKADJdjtP0muLFDq9lKOMBIu
# Z1Kf5MyeUbkCydfKwIdtLkT0JKZW0caL7lH7kaUj0cYIsQhnlo67XJTKIEoeHnbX
# XXzM
# SIG # End signature block

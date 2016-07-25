#Requires -Modules @{ ModuleName = 'biz.dfch.PS.Pester.Assertions'; RequiredVersion = '1.1.1.20160710' }
#Requires -Modules @{ ModuleName = 'biz.dfch.PS.Appclusive.Client'; RequiredVersion = '3.0.0.20160715' }

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "Fatal. Cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}


Describe -Tags "Format-Exception" "Format-Exception" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Format-ResultAs.ps1"
	
	Context "Format-Exception-General" {
	
		# Context wide constants
		# N/A
		
		It "Warmup" -Test {
			$true | Should Be $true;
		}

		It 'CmdletExists' -Test {
		
			$result = Get-Command Format-Exception;
			$result -is [System.Management.Automation.FunctionInfo];
		
		}

		It "GettingHelp-ShouldSucceed" -Test {

			Get-Help Format-Exception | Should Not Be $Null;
		
		}
	}
	
	Context "Find-Exception" {

		It "Find-ExceptionWithNestedMatchingExceptionName-Succeeds" -Test {
			
			# Arrange
			$exceptionTypeName = 'System.Data.Services.Client.DataServiceClientException';

			$expectedMessage = 'arbitrary-DataServiceClientException-message';
			$exDataServiceClientException = New-Object System.Data.Services.Client.DataServiceClientException($expectedMessage, 500);
			$exDataServiceQueryException = New-Object System.Data.Services.Client.DataServiceQueryException("arbitrary-DataServiceQueryException-message", $exDataServiceClientException);
			$exExtendedTypeSystemException = New-Object System.Management.Automation.ExtendedTypeSystemException("arbitrary-ExtendedTypeSystemException-message", $exDataServiceQueryException);
			
			# Act
			$result = Find-Exception $exExtendedTypeSystemException $exceptionTypeName;

			# Assert
			$result | Should Not Be $null;
			$result | Should BeOfType [System.Data.Services.Client.DataServiceClientException];
		}

		It "Find-ExceptionWithNestedMatchingPartialExceptionName-Succeeds" -Test {
			
			# Arrange
			$exceptionTypeName = 'DataServiceClientException';

			$expectedMessage = 'arbitrary-DataServiceClientException-message';
			$exDataServiceClientException = New-Object System.Data.Services.Client.DataServiceClientException($expectedMessage, 500);
			$exDataServiceQueryException = New-Object System.Data.Services.Client.DataServiceQueryException("arbitrary-DataServiceQueryException-message", $exDataServiceClientException);
			$exExtendedTypeSystemException = New-Object System.Management.Automation.ExtendedTypeSystemException("arbitrary-ExtendedTypeSystemException-message", $exDataServiceQueryException);
			
			# Act
			$result = Find-Exception $exExtendedTypeSystemException $exceptionTypeName;

			# Assert
			$result | Should Not Be $null;
			$result | Should BeOfType [System.Data.Services.Client.DataServiceClientException];
		}

		It "Find-ExceptionWithNestedMatchingPartialExceptionName-ReturnsFirstMatchingExceptionAndSucceeds" -Test {
			
			# Arrange
			$exceptionTypeName = 'DataService';

			$expectedMessage = 'arbitrary-DataServiceClientException-message';
			$exDataServiceClientException = New-Object System.Data.Services.Client.DataServiceClientException($expectedMessage, 500);
			$exDataServiceQueryException = New-Object System.Data.Services.Client.DataServiceQueryException("arbitrary-DataServiceQueryException-message", $exDataServiceClientException);
			$exExtendedTypeSystemException = New-Object System.Management.Automation.ExtendedTypeSystemException("arbitrary-ExtendedTypeSystemException-message", $exDataServiceQueryException);
			
			# Act
			$result = Find-Exception $exExtendedTypeSystemException $exceptionTypeName;

			# Assert
			$result | Should Not Be $null;
			$result | Should BeOfType [System.Data.Services.Client.DataServiceQueryException];
		}

		It "Find-ExceptionWithNotMatchingExceptionName-ReturnsNull" -Test {
			
			# Arrange
			$exceptionTypeName = 'System.Data.Services.Client.DataServiceClientExceptionWithInvalidName';

			$expectedMessage = 'arbitrary-DataServiceClientException-message';
			$exDataServiceClientException = New-Object System.Data.Services.Client.DataServiceClientException($expectedMessage, 500);
			$exDataServiceQueryException = New-Object System.Data.Services.Client.DataServiceQueryException("arbitrary-DataServiceQueryException-message", $exDataServiceClientException);
			$exExtendedTypeSystemException = New-Object System.Management.Automation.ExtendedTypeSystemException("arbitrary-ExtendedTypeSystemException-message", $exDataServiceQueryException);
			
			# Act
			$result = Find-Exception $exExtendedTypeSystemException $exceptionTypeName;

			# Assert
			$result | Should Be $null;
		}

		It "Find-ExceptionWithExceptionName-Succeeds" -Test {
			
			# Arrange
			$exceptionTypeName = 'System.Data.Services.Client.DataServiceClientException';

			$expectedMessage = 'arbitrary-DataServiceClientException-message';
			$exDataServiceClientException = New-Object System.Data.Services.Client.DataServiceClientException($expectedMessage, 500);
			
			# Act
			$result = Find-Exception $exDataServiceClientException $exceptionTypeName;

			# Assert
			$result | Should Not Be $null;
			$result | Should BeOfType [System.Data.Services.Client.DataServiceClientException];
		}

		It "Find-ExceptionWithNullException-ThrowsContractException" -Test {
			
			# Arrange
			$exDataServiceClientException = $null;
			
			# Act
			{ Find-Exception $exDataServiceClientException $exceptionTypeName; } | Should ThrowErrorId "Contract";

			# Assert
			# N/A
		}

		It "Find-ExceptionWithEmptyExceptionTypeName-ReturnsInnermostExceptionAndSucceeds" -Test {
			
			# Arrange
			$exceptionTypeName = '';

			$expectedMessage = 'arbitrary-DataServiceClientException-message';
			$exDataServiceClientException = New-Object System.Data.Services.Client.DataServiceClientException($expectedMessage, 500);
			
			# Act
			$result = Find-Exception $exDataServiceClientException $exceptionTypeName;

			# Assert
			$result | Should Not Be $null;
		}

	}
	
	Context "Format-DataServiceClientException" {
	
		It "Find-ExceptionWithInvalidException-ThrowsContractException" -Test {
			
			# Arrange
			$exceptionTypeName = 'System.Data.Services.Client.DataServiceClientException';

			$expectedMessage = 'arbitrary-DataServiceClientException-message';
			$exDataServiceClientException = New-Object System.ArgumentException($expectedMessage);
			
			# Act
			{ Format-DataServiceClientException $exDataServiceClientException; } | Should ThrowErrorId "Contract";

			# Assert
			# N/A
		}
	
		It "Find-ExceptionWithDataServiceClientException-Succeeds" -Test {
			
			# Arrange
			$exceptionTypeName = 'System.Data.Services.Client.DataServiceClientException';

			$expectedMessage = 'arbitrary-DataServiceClientException-message';
			$exDataServiceClientException = New-Object System.Data.Services.Client.DataServiceClientException($expectedMessage, 500);
			
			# Act
			$result = Format-DataServiceClientException $exDataServiceClientException;

			# Assert
			$result | Should Not Be $null;
			$result | Should BeOfType [string];
			$result | Should Match "HTTP.*500";
			$result.Contains($expectedMessage) | Should Be $true;
		}
	}
	
	Context "Format-Exception-InputValidation" {
	
		It "Format-ExceptionWithExplicitNullErrorRecord-ThrowContractException" -Test {
			
			{ Format-Exception -ErrorRecord $null; } | Should ThrowException ValidationMetadataException;
		}

		It "Format-ExceptionWithImplicitNullErrorRecord" -Test {

			# Arrange
			$Error.Clear();
			
			# Act
			{ Format-Exception; } | Should ThrowException ValidationMetadataException;
		}
	}
	
	Context "Format-Exception-ListAvailable" {

		BeforeEach {

			$expectedMessage = 'arbitrary-DataServiceClientException-message';
			$exDataServiceClientException = New-Object System.Data.Services.Client.DataServiceClientException($expectedMessage, 500);
			$exDataServiceQueryException = New-Object System.Data.Services.Client.DataServiceQueryException("arbitrary-DataServiceQueryException-message", $exDataServiceClientException);
			$exExtendedTypeSystemException = New-Object System.Management.Automation.ExtendedTypeSystemException("arbitrary-ExtendedTypeSystemException-message", $exDataServiceQueryException);

			$Error.Clear();
			try
			{
				throw $exExtendedTypeSystemException;
			}
			catch
			{
				$null = $Error.Add($_);
			}

		}
		
		It "Format-ExceptionListAvailable-Succeeds" -Test {
			
			# Arrange

			# Act
			$result = Format-Exception -ListAvailable
			
			# Assert
			$result | Should Not Be $null;
			$result.Count | Should Be 3;
			$result[0] | Should Be 'System.Management.Automation.ExtendedTypeSystemException';
			$result[1] | Should Be 'System.Data.Services.Client.DataServiceQueryException';
			$result[2] | Should Be 'System.Data.Services.Client.DataServiceClientException';
		}
	}
	
	Context "Format-Exception-All" {

		BeforeEach {

			$expectedMessage = 'arbitrary-DataServiceClientException-message';
			$exDataServiceClientException = New-Object System.Data.Services.Client.DataServiceClientException($expectedMessage, 500);
			$exDataServiceQueryException = New-Object System.Data.Services.Client.DataServiceQueryException("arbitrary-DataServiceQueryException-message", $exDataServiceClientException);
			$exExtendedTypeSystemException = New-Object System.Management.Automation.ExtendedTypeSystemException("arbitrary-ExtendedTypeSystemException-message", $exDataServiceQueryException);

			$Error.Clear();
			try
			{
				throw $exExtendedTypeSystemException;
			}
			catch
			{
				$null = $Error.Add($_);
			}

		}

		It "Format-ExceptionAll-Succeeds" -Test {
			
			# Arrange

			# Act
			$result = Format-Exception -All
			
			# Assert
			$result | Should Not Be $null;
			$result.Count | Should Be 3;
			$result[0] | Should BeOfType [System.Management.Automation.ExtendedTypeSystemException];
			$result[1].GetType().FullName | Should Be "System.Data.Services.Client.DataServiceQueryException";
			$result[2].GetType().FullName | Should Be "System.Data.Services.Client.DataServiceClientException";
			Write-Host ($result | Out-String);
		}
	}

	Context "Format-Exception-Single" {
	
		It "Format-ExceptionWithImplicitErrorRecordAndNestedException-ReturnsFormattedDataServiceClientExceptionAndSucceeds" -Test {
			
			# Arrange
			$expectedMessage = 'arbitrary-DataServiceClientException-message';
			$exDataServiceClientException = New-Object System.Data.Services.Client.DataServiceClientException($expectedMessage, 500);
			$exDataServiceQueryException = New-Object System.Data.Services.Client.DataServiceQueryException("arbitrary-DataServiceQueryException-message", $exDataServiceClientException);
			$exExtendedTypeSystemException = New-Object System.Management.Automation.ExtendedTypeSystemException("arbitrary-ExtendedTypeSystemException-message", $exDataServiceQueryException);

			$Error.Clear();
			try
			{
				throw $exExtendedTypeSystemException;
			}
			catch
			{
				$null = $Error.Add($_);
			}

			# Act
			$result = Format-Exception;

			# Assert
			$result | Should Not Be $null;
			$result | Should BeOfType [string];
			$result | Should Match "HTTP.*500";
		}

		It "Format-ExceptionWithImplicitErrorRecord-Succeeds" -Test {
			
			# Arrange
			$Error.Clear();
			try
			{
				1 / 0;
			}
			catch
			{
				$null = $Error.Add($_);
			}

			# Act
			$result = Format-Exception;

			# Assert
			$result | Should Not Be $null;
			$result | Should Match 'System.DivideByZeroException';
		}

		It "Format-ExceptionWithExplicitErrorRecord-Succeeds" -Test {
			
			# Arrange
			$Error.Clear();
			try
			{
				1 / 0;
			}
			catch
			{
				$null = $Error.Add($_);
			}

			# Act
			$result = Format-Exception -Error $Error[0];

			# Assert
			$result | Should Not Be $null;
			$result | Should Match 'System.DivideByZeroException';
		}

		It "Format-ExceptionWithNotMatchingTypeName-ReturnsEmptyResult" -Test {
			
			# Arrange
			$Error.Clear();
			try
			{
				1 / 0;
			}
			catch
			{
				$null = $Error.Add($_);
			}

			# Act
			$result = Format-Exception -Name "arbitrary-not-matching-type-name";

			# Assert
			$result | Should Be $null;
		}
	}
}

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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUQIGxYd9Cb5qMUALXIDsqOSA6
# qrugghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBS8kA10PZEuCTpX
# bsX3LqeBHutzcTANBgkqhkiG9w0BAQEFAASCAQBPfD4+kAj1mdlMe15ar5Ro1gLY
# 6ken+Cx7gI3qxQwaBHYv8n2RYsUOR+uQsEqg5P+4hBFpIl2PNnGUj6tmWkWt3yF/
# 3TPBvkH3MhNnB1gHy27Y9WHE4fmqUGiAldX5LTAELmG2ivigtPX5LelNqL9LoqCW
# J9LxJFC1J6v3j7Tcx6r/CxLrBnw0fEx+Tk660O2phrgJ4pIsFyxYQY97To+/eIyj
# YtlpZM+5NPR5CZ2pejGU58rDmDcKYj8pt4Xt/b4ZEwTNdMKmHXlTCbeFa908h9M9
# XOEkUfIeZMvxQmbZeECCxAxk4Pv7IN1CqD5i0ZCmhswMIXh1En2vb7VOo2U3oYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEh1pmnZJc+8fhCfukZzFNBFDAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE2
# MDcyNDIyMzYxNVowIwYJKoZIhvcNAQkEMRYEFM3EbvQsAtmFaSrfXwrhZPMwPhlv
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUY7gvq2H1g5CWlQULACScUCkz
# 7HkwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# 1pmnZJc+8fhCfukZzFNBFDANBgkqhkiG9w0BAQEFAASCAQBoZZL9AFC68PXJUw2G
# pVlRA310eIuVMKnkRv1h75vB+HkGADh6DP6S7mMHK0wHe1Kn83DiglRapumOiPdB
# dnLM0i7ubCtEjM7qp8VfcfJxOrgZM1Kg2bZZSiyCAYWgujf32utSlpBoQ75p1A7N
# cEuqcU9I8DcDHAufpZBzQRKATkpaouImpQB6BVAN3KDv6zdlBqZPmon34oABaoZt
# REoGGnqGHHWWt6mIuQfJHkajqzv2vD1owFVQx2+k7woWunRkDPAStQE1u5wOhuOv
# 4Q5JhytxFmfBfsbT/7Xw8zqWwv4dxbdXMu7fd+8ZwluoQCbkFGzxkDJ2X6HVr1VT
# 5Dko
# SIG # End signature block

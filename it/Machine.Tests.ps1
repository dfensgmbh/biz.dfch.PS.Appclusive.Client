$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester()
{
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
	PARAM
	(
		$message = "EMERGENCY: Script cannot continue."
	)
	
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe "Machine.Tests" -Tags "Machine.Tests" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut";
	
	Context "#CLOUDTCL-1882-MachineTests" {
		
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;
			$svc = Enter-ApcServer;
		}
		
		It "MachineTemplate-ReturnsExpectedTemplate" -Test {
			
			# Act
			$machineTemplate = $svc.Infrastructure.InvokeEntitySetActionWithSingleResult("Machines", "Template", [biz.dfch.CS.Appclusive.Api.Infrastructure.Machine], $null);
			
			# Assert	
			$machineTemplate | Should Not Be $null;
			$machineTemplate.Tid | Should Be '22222222-2222-2222-2222-222222222222';
		}
		
		It "GettingMachines-ReturnsListOfMachines" -Test {
			
			# Arrange
						
			# Act
			$machines = $svc.Infrastructure.Machines | Select;
			
			# Assert
			$machines.Count -gt 0 | Should Be $true;
		}
		
		It "RestartMachine-Succeeds" -Test {
			
			# Arrange
			$query = $svc.Infrastructure.Machines;
			$machines = $query.Execute();

			:outer while($true)
			{
				foreach($machine in $machines)
				{
					$machineJob = $svc.Core.Jobs.AddQueryOption('$filter', ("RefId eq '{0}' and EntityKindId eq 1" -f $machine.Id)) | Select;
					
					if ($machineJob.Status -eq 'Running')
					{
						break outer;
					}
				}
				
				$continuation = $machines.GetContinuation();
				if ($continuation -eq $null)
				{
					{ throw "No machine in status 'Running' found" } | Should Not Throw;
				}
				
				$machines = $svc.core.Execute($continuation);
			}
			
			# Act
			$result = $svc.Infrastructure.InvokeEntityActionWithSingleResult($machine, "Restart", [biz.dfch.CS.Appclusive.Core.OdataServices.Core.JobResponse], $null);
			
			$svc = Enter-Apc;
			$query = "Id eq {0}" -f $result.Id;
			$job = $svc.Core.Jobs.AddQueryOption('$filter', $query) | Select;
			
			while(($job.Condition -eq 'Restart') -and ($job.Error -eq ''))
			{
				Start-Sleep 30;
				$svc = Enter-Apc;
				$job = $svc.Core.Jobs.AddQueryOption('$filter', $query) | Select;
			}
			
			# Assert
			$job.Error | Should Be "";
			$job.Status | Should Be "Running";
			$job.Condition | Should Be "";
			$job.ConditionParameters | Should Be "";
		}
		
		It "StartMachine-Succeeds" -Test {
			
			# Arrange
			$query = $svc.Infrastructure.Machines;
			$machines = $query.Execute();

			:outer while($true)
			{
				foreach($machine in $machines)
				{
					$machineJob = $svc.Core.Jobs.AddQueryOption('$filter', ("RefId eq '{0}' and EntityKindId eq 1" -f $machine.Id)) | Select;
					
					if ($machineJob.Status -eq 'Stopped')
					{
						break outer;
					}
				}
				
				$continuation = $machines.GetContinuation();
				if ($continuation -eq $null)
				{
					{ throw "No machine in status 'Stopped' found" } | Should Not Throw;
				}
				
				$machines = $svc.core.Execute($continuation);
			}
			
			# Act
			$result = $svc.Infrastructure.InvokeEntityActionWithSingleResult($machine, "Start", [biz.dfch.CS.Appclusive.Core.OdataServices.Core.JobResponse], $null);
			
			$svc = Enter-Apc;
			$query = "Id eq {0}" -f $result.Id;
			$job = $svc.Core.Jobs.AddQueryOption('$filter', $query) | Select;
			
			while(($job.Condition -eq 'Start') -and ($job.Error -eq ''))
			{
				Start-Sleep 30;
				$svc = Enter-Apc;
				$job = $svc.Core.Jobs.AddQueryOption('$filter', $query) | Select;
			}
			
			# Assert
			$job.Error | Should Be "";
			$job.Status | Should Be "Running";
			$job.Condition | Should Be "";
			$job.ConditionParameters | Should Be "";
		}
		
		It "StopMachine-Succeeds" -Test {
			
			# Arrange
			$query = $svc.Infrastructure.Machines;
			$machines = $query.Execute();

			:outer while($true)
			{
				foreach($machine in $machines)
				{
					$machineJob = $svc.Core.Jobs.AddQueryOption('$filter', ("RefId eq '{0}' and EntityKindId eq 1" -f $machine.Id)) | Select;
					
					if ($machineJob.Status -eq 'Running')
					{
						break outer;
					}
				}
				
				$continuation = $machines.GetContinuation();
				if ($continuation -eq $null)
				{
					{ throw "No machine in status 'Running' found" } | Should Not Throw;
				}
				
				$machines = $svc.core.Execute($continuation);
			}
			
			# Act
			$result = $svc.Infrastructure.InvokeEntityActionWithSingleResult($machine, "Stop", [biz.dfch.CS.Appclusive.Core.OdataServices.Core.JobResponse], @{Force = $True});
			
			$svc = Enter-Apc;
			$query = "Id eq {0}" -f $result.Id;
			$job = $svc.Core.Jobs.AddQueryOption('$filter', $query) | Select;
			
			while(($job.Condition -eq 'Stop') -and ($job.Error -eq ''))
			{
				Start-Sleep 30;
				$svc = Enter-Apc;
				$job = $svc.Core.Jobs.AddQueryOption('$filter', $query) | Select;
			}
			
			# Assert
			$job.Error | Should Be "";
			$job.Status | Should Be "Stopped";
			$job.Condition | Should Be "";
			$job.ConditionParameters | Should Be "";
		}
		
		It "QuickCreateMachine-Succeeds" -Test {

			# Arrange
			$quickCreateParameters = @{
				"Infrastructure_Machine_Name" = "SampleMachine";
				"Infrastructure_Compute_Cpu_Count" = 2;
				"Infrastructure_Compute_Memory_SizeGB" = 16;
				"Infrastructure_Storage_Disk00_SizeGB" = 80;
				"Infrastructure_Storage_Disk01_SizeGB" = 20;
				"Infrastructure_Storage_Disk02_SizeGB" = 20;
				"Infrastructure_Storage_Disk03_SizeGB" = 20;
				"Infrastructure_Network_Network00_Id" = 0;
			};
			
			# Act
			$result = $svc.Infrastructure.InvokeEntitySetActionWithSingleResult("Machines", "QuickCreate", [biz.dfch.CS.Appclusive.Core.OdataServices.Core.JobResponse], $quickCreateParameters);
			
			$query = "Id eq {0}" -f $result.Id;
			$job = $svc.Core.Jobs.AddQueryOption('$filter', $query) | Select;
			
			while(($job.Condition -eq 'Initialise') -and ($job.Error -eq ''))
			{
				Start-Sleep 30;
				$svc = Enter-Apc;
				$job = $svc.Core.Jobs.AddQueryOption('$filter', $query) | Select;
			}
			
			# Assert
			$job.Error | Should Be "";
			$job.Status | Should Be "Running";
			$job.Condition | Should Be "";
			$job.ConditionParameters | Should Be "";
		}
	}
}

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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUue8r2drNGPp88mThoxg1VoZ2
# lpGgghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRmMn5ZNBIUDEtP
# IqXJD/DcxOmvozANBgkqhkiG9w0BAQEFAASCAQDMO/rHG6lvGELGiTbdHcDN/UzE
# k4E451ojqdRfD85iwmj7FY1NB5q8Zs6obMOcc/qBXamAfqpwigOTHWwYrzu6VBnY
# Ay0PxaPVbGYlM/YamlTmIf1qG04aVzakOQ24+X1pnsmTXlngTKIb8qNfHSHg9pX4
# CPY02mInNgLyPhvkeKAV7LXqy1rEAtRCpkucFYD91aeRRTsWhjeZVwcbLr84AX0g
# T0Qr+SrcoTorGvFw+Ma7bvlmp+HYj6Pa8SLpeRoT6hZRMuEytBtQfXKQyzsMeYP4
# OgzW8Z+XOa0QHGeDOoWaY0d6pf2arTxx/TRkGLvz8R6VwEiKRA9qWZKtvu2qoYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEhBqCB0z/YeuWCTMFrUglOAzAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE2
# MDcwNDExMjIxOVowIwYJKoZIhvcNAQkEMRYEFLrgiLQnpxfB/T3GC/Rj/8xD9b2J
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUs2MItNTN7U/PvWa5Vfrjv7Es
# KeYwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# BqCB0z/YeuWCTMFrUglOAzANBgkqhkiG9w0BAQEFAASCAQAtsp0YhA5Mt2Ng7jxu
# WkzTvW+5r/eaZDJC8yOhOQuS+3AFANHJ1WWAQwKFA5EpaGi94Ba4pa20h2vdaq0R
# FUdU/wgmCimwbUQkZZAshN96vb6hkL0kuhXc80gk2jLY+DgpSdr+5F5OSpplBheF
# 1Zf5m3+knSiY3o56jMw5fkVM5L4IKW/a62+bcvoOQyQjF0zIBEFaHU65SpVo7433
# WHKC90QkGqq8s36XBN3NxCAsn3POHbQbMfXiCOI39MycFsetnzVBDkZ9xjfD9BCK
# z8sGstCpKM0VsEq+u8KyOmSUYbcjOHJtVql3ISe30rprcttakY0dJo47HH4GqaZm
# wRZP
# SIG # End signature block

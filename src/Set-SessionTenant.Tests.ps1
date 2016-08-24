
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Set-SessionTenant.Tests" -Tags "Set-SessionTenant.Tests" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Get-ModuleVariable.ps1"
	. "$here\Format-ResultAs.ps1"
	. "$here\Get-SessionTenant.ps1"
	. "$here\Get-Tenant.ps1"
	
    BeforeEach {
        $moduleName = 'biz.dfch.PS.Appclusive.Client';
        Remove-Module $moduleName -ErrorAction:SilentlyContinue;
        Import-Module $moduleName;

        $svc = Enter-ApcServer;
    }

	Context "Set-SessionTenant.Tests" {
	
		# Context wide constants
		# N/A
		
		BeforeEach {
			$error.Clear();
		}
		
		AfterEach {
			if(0 -ne $error.Count)
			{
				Write-Warning ($error | Out-String);
			}
		}
		
		It "Warmup" -Test {
			$true | Should Be $true;
		}
		
		It "SetSessionTenantWithInvalidId-ThrowsContractException" -Test {
		
			# Arrange
			$tenantId = [Guid]::NewGuid()
			
			# Act
			{ $result = Set-SessionTenant $tenantId -svc $svc; } | Should ThrowErrorId Contract;
			
			# Assert
			# N/A
		}
		
		It "SetSessionTenantWithValidId-Throws" -Test {
		
			# Arrange
			$tenantId = [biz.dfch.CS.Appclusive.Public.Constants]::TENANT_GUID_SYSTEM.ToString();
			
			# Act
			$result = Set-SessionTenant $tenantId -svc $svc;
			
			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Be $tenantId;
		}
		
		It "SetSessionTenantClear-Succeeds" -Test {
		
			# Arrange
			#
			
			# Act
			$result = Set-SessionTenant -Clear -svc $svc;
			
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
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Set-Tenant.Tests" -Tags "Set-Tenant.Tests" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Get-ModuleVariable.ps1"
	. "$here\Format-ResultAs.ps1"
	. "$here\Get-Tenant.ps1"
	. "$here\Set-Tenant.ps1"
	
	$entityPrefix = "Set-Tenant";
	$usedEntitySets = @("ContractMappings", "Customers");
	
	AfterAll {
		# Cleanup
		$svc = Enter-ApcServer;
		$entityFilter = "startswith(Name, '{0}')" -f $entityPrefix;

		foreach ($entitySet in $usedEntitySets)
		{
			$entities = $svc.Core.$entitySet.AddQueryOption('$filter', $entityFilter) | Select;
	 
			foreach ($entity in $entities)
			{
				Remove-ApcEntity -svc $svc -Id $entity.Id -EntitySetName $entitySet -Confirm:$false;
			}
		}
	}

	Context "Set-Tenant.Tests" {
	
		# Context wide constants
		# N/A
		
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;

			$svc = Enter-ApcServer;
			
			$systemTenantId = [biz.dfch.CS.Appclusive.Public.Constants]::TENANT_GUID_SYSTEM;
			
			$contractMappingName = "{0}-ContractMapping-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			$contractMappingExternalType = "ExternalType";
			$contractMappingExternalId = [guid]::NewGuid().ToString();
			$validFrom = [System.DateTimeOffset]::MinValue;
			$validUntil = [System.DateTimeOffset]::MaxValue;
			
			# Create Customer
			$testCustomer = New-Object biz.dfch.CS.Appclusive.Api.Core.Customer;
			$testCustomer.Name = $contractMappingName;
			$svc.Core.AddToCustomers($testCustomer);
			$null = $svc.Core.SaveChanges();
			
			# Create ContractMapping
			$contractMapping = New-Object biz.dfch.CS.Appclusive.Api.Core.ContractMapping;
			$contractMapping.Name = $contractMappingName;
			$contractMapping.ExternalType = $contractMappingExternalType;
			$contractMapping.ExternalId = $contractMappingExternalId;
			$contractMapping.IsPrimary = $true;
			$contractMapping.ValidFrom = $validFrom;
			$contractMapping.ValidUntil = $validUntil;
			$contractMapping.CustomerId = $testCustomer.Id;
			$svc.Core.AddToContractMappings($contractMapping);
			$null = $svc.Core.SaveChanges();
		}
		
		AfterEach {
			# Revert connection between testCustomer and SYSTEM tenant
			$systemTenant = Get-Tenant -Id $systemTenantId -svc $svc;
			$systemTenant.CustomerId = $null;
			$svc.Core.UpdateObject($systemTenant);
			$null = $svc.Core.SaveChanges();
		}
		
		It "Warmup" -Test {
			$true | Should Be $true;
		}
		
		It "Set-TenantWithInvalidCustomerId-ShouldThrowArgumentException" -Test {
			# Arrange
			# N/A
				
			# Act
			{ Set-Tenant -CustomerId 0 -svc $svc } | Should Throw 'argument';

			# Assert
			# N/A
		}
		
		It "Set-TenantWithEmptyCustomerName-ShouldThrowArgumentException" -Test {
			# Arrange
			# N/A
				
			# Act
			{ Set-Tenant -CustomerName "" -svc $svc } | Should Throw 'argument';

			# Assert
			# N/A
		}
		
		It "Set-TenantWithEmptyContractMappingExternalId-ShouldThrowArgumentException" -Test {
			# Arrange
			# N/A
				
			# Act
			{ Set-Tenant -ContractMappingExternalId "" -svc $svc } | Should Throw 'argument';

			# Assert
			# N/A
		}
		
		It "Set-TenantWithIdOfNonExistingTenant-ShouldThrowContractException" -Test {
			# Arrange
			$nonExistingTenantId = [guid]::NewGuid();
			
			# Act
			{ Set-Tenant -Id $nonExistingTenantId -CustomerId $testCustomer.Id -svc $svc } | Should ThrowErrorId 'Contract';
			
			# Assert
			# N/A
		}
		
		It "SetTenant-UpdateWithContractMappingExternalIdSucceeds" -Test {
			# Arrange

			# Act
			$result = Set-Tenant -Id $systemTenantId -ContractMappingExternalId $contractMapping.ExternalId -svc $svc;
			
			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Be $systemTenantId;
			$result.CustomerId | Should Be $testCustomer.Id;
		}
		
		It "SetTenant-UpdateWithCustomerIdSucceeds" -Test {
			# Arrange
			
			# Act
			$result = Set-Tenant -Id $systemTenantId -CustomerId $testCustomer.Id -svc $svc;
			
			# Assert
			$result | Should Not Be $null;
			$result.CustomerId | Should Be $testCustomer.Id;
		}
		
		It "SetTenant-UpdateWithCustomerNameSucceeds" -Test {
			# Arrange
			
			# Act
			$result = Set-Tenant -Id $systemTenantId -CustomerName $testCustomer.Name -svc $svc;
			
			# Assert
			$result | Should Not Be $null;
			$result.CustomerId | Should Be $testCustomer.Id;
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

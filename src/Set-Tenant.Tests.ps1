
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Set-Tenant.Tests" -Tags "Set-Tenant.Tests" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Get-ModuleVariable.ps1"
	. "$here\Format-ResultAs.ps1"
	. "$here\Get-Tenant.ps1"
	. "$here\Set-Tenant.ps1"
	
	
	BeforeAll {
		$svc = Enter-ApcServer;
		$entityPrefix = "ContractMappingTest";
	
		$contractMappingName = "{0}-ContractMappingTest" -f $entityPrefix;
		$externalType = "ExternalType";
		$externalId = "ExternalId";
		$validFrom = Get-Date;
		$validUntil = Get-Date;
		$validUntil = $validUntil.AddDays(90);
		$Tid = [biz.dfch.CS.Appclusive.Public.Constants]::TENANT_GUID_SYSTEM;
		
		# Create new ContractMapping
		$entity = New-Object biz.dfch.CS.Appclusive.Api.Core.ContractMapping;
		$entity.Name = $contractMappingName;
		$entity.ExternalType = $externalType;
		$entity.ExternalId = $externalId;
		$entity.IsPrimary = $true;
		$entity.ValidFrom = $validFrom;
		$entity.ValidUntil = $validUntil;
		$entity.CustomerId = 1
		$svc.Core.AddToContractMappings($entity);
		$svc.Core.SaveChanges();
	}
	
    BeforeEach {
        $moduleName = 'biz.dfch.PS.Appclusive.Client';
        Remove-Module $moduleName -ErrorAction:SilentlyContinue;
        Import-Module $moduleName;

        $svc = Enter-ApcServer;
    }
	
	AfterAll {
		$svc = Enter-ApcServer;
		$entityFilter = "startswith(Name, '{0}')" -f $entityPrefix;
		
		$entities = $svc.Core.ContractMappings.AddQueryOption('$filter', $entityFilter) | Select;
 
		foreach ($entity in $entities)
		{
			Remove-ApcEntity -svc $svc -Id $entity.Id -EntitySetName ContractMappings -Confirm:$false;
		}
	}

	Context "Set-Tenant.Tests" {
	
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
		
		It "SetTenant-UpdateWithContractIdSucceeds" -Test {
			# Arrange
			$contractFilter = "Name eq '{0}'" -f $contractMappingName;
			$contractMapping = $svc.Core.ContractMappings.AddQueryOption('$filter', $contractFilter) | Select;

			$customerId = 1;
			$customerFilter = "Id eq {0}" -f $customerId;
			$customer = $svc.Core.Customers.AddQueryOption('$filter', $customerFilter) | Select;
			
			# Act
			$result = Set-Tenant -Id $Tid -ContractMappingExternalId $contractMapping[0].ExternalId -svc $svc;
			
			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Be $Tid;
			$result.CustomerId | Should Be $customer.Id;
		}
		
		It "SetTenant-UpdateWithCustomerIdSucceeds" -Test {
			# Arrange
			$customerId = 1;
			$customerFilter = "Id eq {0}" -f $customerId;
			$customer = $svc.Core.Customers.AddQueryOption('$filter', $customerFilter) | Select;
			
			# Act
			$result = Set-Tenant -Id $Tid -CustomerId $customer.Id -svc $svc;
			
			# Assert
			$result | Should Not Be $null;
			$result.CustomerId | Should Be $customer.Id;
		}
		
		It "SetTenant-UpdateWithCustomerIdSucceeds" -Test {
			# Arrange
			$customerId = 1;
			$customerFilter = "Id eq {0}" -f $customerId;
			$customer = $svc.Core.Customers.AddQueryOption('$filter', $customerFilter);
			
			# Act
			$result = Set-Tenant -Id $Tid -CustomerName $customer.Name -svc $svc;
			
			# Assert
			$result | Should Not Be $null;
			$result.CustomerId | Should Be $customer.Id;
		}
#>		
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

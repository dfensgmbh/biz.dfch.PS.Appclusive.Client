#Requires -Modules @{ ModuleName = 'biz.dfch.PS.Pester.Assertions'; ModuleVersion = '1.1.1.20160710' }

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Set-Customer" -Tags "Set-Customer" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Get-Tenant"
	. "$here\Format-ResultAs.ps1"

	$entityPrefix = "Set-Customer";
	$usedEntitySets = @("ContractMappings", "Customers");
	
	Context "Set-Customer" {
	
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;

			$svc = Enter-ApcServer;

			$name = "{0}-Name-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			$contractMappingName = "{0}-Contract-Mapping-Name-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
		}
		
		AfterAll {
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
		
		# Context wide constants
		# N/A
		It "Warmup" -Test {
			$true | Should Be $true;
		}

		It "Set-CustomerWithCreateIfNotExist-ShouldCreateAndReturnNewEntity" -Test {
			# Arrange
			# N/A (Declared in BeforeEach)
			
			# Act
			$result = Set-Customer -Name $name -svc $svc -CreateIfNotExist;
			
			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be $name;
		}
		
		It "Set-CustomerWithCreateIfNotExistAndDescription-ShouldCreateAndReturnNewEntityWithSpecifiedDescription" -Test {
			# Arrange
			$description = "Description-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			$result = Set-Customer -Name $name -Description $description -svc $svc -CreateIfNotExist;
			
			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be $name;
			$result.Description | Should Be $description;
		}
		
		It "Set-CustomerWithCreateIfNotExistAndContractMappingConfiguration-ShouldCreateCustomerAndSpecifiedContract" -Test {
			# Arrange
			$contractMappingExternalId = "ContractMapping ExternalId";
			$contractMappingExternalType = "ContractMapping ExternalType";
			$description = "Description-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			$result = Set-Customer -Name $name -Description $description -ContractMappingExternalId $contractMappingExternalId -ContractMappingExternalType $contractMappingExternalType -ContractMappingName $contractMappingName -svc $svc -CreateIfNotExist;
			
			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be $name;
			$result.Description | Should Be $description;
			
			$filterExpression = "Name eq '{0}'" -f $contractMappingName;
			$contractMapping = $svc.Core.ContractMappings.AddQueryOption('$filter', $filterExpression) | Select;
			
			$contractMapping | Should Not Be $null;
			$contractMapping.Name | Should Be $contractMappingName;
			$contractMapping.ExternalId | Should Be $contractMappingExternalId;
			$contractMapping.ExternalType | Should Be $contractMappingExternalType;
			$contractMapping.CustomerId | Should Be $result.Id;
			$contractMapping.IsPrimary | Should Be $true;
		}
	
		It "Set-CustomerWithNewDescription-ShouldReturnUpdatedEntity" -Test {
			# Arrange
			$description = "Description-{0}" -f [guid]::NewGuid().ToString();
			
			$newDescription = "NewDescription-{0}" -f [guid]::NewGuid().ToString();
			
			$result1 = Set-Customer -Name $name -Description $description -svc $svc -CreateIfNotExist;
			$result1 | Should Not Be $null;
			$result1.Name | Should Be $name;
			$result1.Description | Should Be $description;
			
			# Act
			$result = Set-Customer -Id $result1.Id -Description $newDescription -svc $svc;

			# Assert
			$result | Should Not Be $null;
			$result1.Name | Should Be $name;
			$result.Description | Should Be $newDescription;
			$result.Id | Should Be $result1.Id;
		}
		
		It "Set-CustomerWithNewName-ShouldReturnUpdatedEntity" -Test {
			# Arrange
			$newName = "{0}-Name-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			
			$result1 = Set-Customer -Name $name -svc $svc -CreateIfNotExist;
			$result1 | Should Not Be $null;
			$result1.Name | Should Be $name;
			
			# Act
			$result = Set-Customer -Id $result1.Id -Name $newName -svc $svc;

			# Assert
			$result | Should Not Be $null;
			$result1.Name | Should Be $newName;
			$result.Id | Should Be $result1.Id;
		}

		It "Set-CustomerWithInvalidId-ShouldThrowArgumentException" -Test {
			# Arrange
			# N/A
				
			# Act
			{ Set-Customer -Id 0 -svc $svc } | Should Throw 'argument';

			# Assert
			# N/A
		}
		
		It "Set-CustomerWithEmptyName-ShouldThrowArgumentException" -Test {
			# Arrange
			# N/A
				
			# Act
			{ Set-Customer -Name "" -svc $svc } | Should Throw 'argument';

			# Assert
			# N/A
		}
		
		It "Set-CustomerWithIdOfNonExistingCustomer-ShouldThrowContractException" -Test {
			# Arrange
			$nonExistingCustomerId = [long]::MaxValue;
			
			# Act
			{ Set-Customer -Id $nonExistingCustomerId -svc $svc } | Should ThrowErrorId 'Contract';
			
			# Assert
			# N/A
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

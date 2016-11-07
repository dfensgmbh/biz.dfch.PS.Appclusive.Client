#Requires -Modules @{ ModuleName = 'biz.dfch.PS.Pester.Assertions'; ModuleVersion = '1.1.1.20160710' }

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Set-Role" -Tags "Set-Role" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Format-ResultAs.ps1"

	$entityPrefix = "Set-Role";
	$usedEntitySets = @("Roles");
	

	Context "Set-Role" {
	
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;

			$svc = Enter-ApcServer;

			$name = "{0}-Name-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			$value = "value-{0}" -f [guid]::NewGuid().ToString();
			$entityKindId = [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::Node.value__;

			$currentTenant = Get-Tenant -Current -svc $svc;
			$testNode = New-Node -Name $name -ParentId $currentTenant.NodeId -EntityKindId $entityKindId -svc $svc;
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

		It "Set-Role-ShouldReturnNewEntity" -Test {
			# Arrange
			# N/A (Declared in BeforeEach)
			
			# Act
			$result = Set-Role -Name $name -Value $value -EntityId $testNode.Id -EntityKindId $entityKindId -svc $svc -CreateIfNotExist;
			
			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be $name;
			$result.Value | Should Be $value;
			$result.EntityId | Should Be $testNode.Id;
			$result.EntityKindId| Should Be $entityKindId;
		}
	
		It "Set-Role-ShouldReturnNewEntityWithDescriptionAndProtectionLevel" -Test {
			# Arrange
			$description = "Description-{0}" -f [guid]::NewGuid().ToString();
			$protectionLevel = [biz.dfch.CS.Appclusive.Public.OdataServices.Core.RoleProtectionLevelEnum]::MinValue.value__;	
				
			# Act
			$result = Set-Role -Name $name -Value $value -EntityId $testNode.Id -EntityKindId $entityKindId -Description $description -ProtectionLevel $protectionLevel -svc $svc -CreateIfNotExist;
			
			# Assert
			$result | Should Not Be $null;
			$result.Description | Should Be $description;
			$result.ProtectionLevel | Should Be $protectionLevel;
		}

		It "Set-Role-WithNewDescriptionAndProtectionLevel-ShouldReturnUpdatedEntity" -Test {
			# Arrange
			$description = "Description-{0}" -f [guid]::NewGuid().ToString();
			$protectionLevel = [biz.dfch.CS.Appclusive.Public.OdataServices.Core.RoleProtectionLevelEnum]::MinValue.value__;
			
			$newDescription = "NewDescription-{0}" -f [guid]::NewGuid().ToString();
			$newProtectionLevel = [biz.dfch.CS.Appclusive.Public.OdataServices.Core.RoleProtectionLevelEnum]::MaxValue.value__;
			
			$result1 = Set-Role -Name $name -Value $value -EntityId $testNode.Id -EntityKindId $entityKindId -Description $description -ProtectionLevel $protectionLevel -svc $svc -CreateIfNotExist;
			$result1 | Should Not Be $null;
			$result1.Description | Should Be $description;
			$result1.ProtectionLevel | Should Be $protectionLevel;
			
			# Act
			$result = Set-Role -Name $name -Value $value -EntityId $testNode.Id -EntityKindId $entityKindId -Description $newDescription -ProtectionLevel $newProtectionLevel -svc $svc;

			# Assert
			$result | Should Not Be $null;
			$result.Description | Should Be $newDescription;
			$result.ProtectionLevel | Should Be $newProtectionLevel;
			$result.Id | Should Be $result1.Id;
		}
		
		It "Set-Role-ShouldReturnUpdatedValue" -Test {
			# Arrange
			$newValue = "NewValue-{0}" -f [guid]::NewGuid().ToString();

			$result1 = Set-Role -Name $name -Value $value -EntityId $testNode.Id -EntityKindId $entityKindId -svc $svc -CreateIfNotExist;
			$result1 | Should Not Be $null;
			
			# Act
			$result = Set-Role -Name $name -Value $value -EntityId $testNode.Id -EntityKindId $entityKindId -svc $svc -NewValue $newValue;
			
			# Assert
			$result | Should Not Be $null;
			$result.Value | Should Be $newValue;
			$result.EntityId | Should Be $testNode.Id;
			$result.EntityKindId| Should Be $entityKindId;
		}

		It "Set-Role-WithInvalidEntityKindIdShouldThrowArgumentException" -Test {
			# Arrange
			# N/A	
				
			# Act
			{ Set-Role -Name $name -Value $value -EntityId $testNode.Id -EntityKindId 0 -svc $svc -CreateIfNotExist } | Should Throw 'argument';

			# Assert
			# N/A
		}
		
		It "Set-Role-WithInvalidEntityIdShouldThrowArgumentException" -Test {
			# Arrange
			# N/A	
				
			# Act
			{ Set-Role -Name $name -Value $value -EntityId 0 -EntityKindId $testNode.EntityKindId -svc $svc -CreateIfNotExist } | Should Throw 'argument';

			# Assert
			# N/A
		}
		
		It "Set-Role-WithInvalidProtectionLevelShouldThrowContractException" -Test {
			# Arrange
			$invalidProtectionLevel = [biz.dfch.CS.Appclusive.Public.OdataServices.Core.RoleProtectionLevelEnum]::MaxValue.value__ + 1;
			
			# Act
			{ Set-Role -Name $name -Value $value -EntityId $testNode.Id -EntityKindId $entityKindId -svc $svc -ProtectionLevel $invalidProtectionLevel -CreateIfNotExist } | Should ThrowErrorId 'Contract';
			
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

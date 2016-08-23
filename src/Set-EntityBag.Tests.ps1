
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Set-EntityBag" -Tags "Set-EntityBag" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Format-ResultAs.ps1"

	$entityPrefix = "Set-EntityBag";
	$usedEntitySets = @("EntityBags");
	

	Context "Set-EntityBag" {
	
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;

			$svc = Enter-ApcServer;
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

		It "Set-EntityBag-ShouldReturnNewEntity" -Test {
			# Arrange
			$name = "{0}-Name-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			$value = "value-{0}" -f [guid]::NewGuid().ToString();
			$entityId = 2; #Replace with dynamically long
			$entityKindId = [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::Node.value__;
			
			# Act
			$result = Set-EntityBag -Name $name -Value $value -EntityId $entityId -EntityKindId $entityKindId -svc $svc -CreateIfNotExist;
			
			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be $name;
			$result.Value | Should Be $value;
			$result.EntityId | Should Be $entityId;
			$result.EntityKindId| Should Be $entityKindId;
		}
	
		It "Set-EntityBag-ShouldReturnNewEntityWithDescriptionAndProtectionLevel" -Test {
			# Arrange
			$name = "{0}-Name-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			$value = "Value-{0}" -f [guid]::NewGuid().ToString();
			$entityId = 2; #Replace with dynamically long
			$entityKindId = [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::Node.value__;
			$description = "Description-{0}" -f [guid]::NewGuid().ToString();
			$protectionLevel = [biz.dfch.CS.Appclusive.Public.OdataServices.Core.EntityBagProtectionLevelEnum]::MinValue.value__;	
				
			# Act
			$result = Set-EntityBag -Name $name -Value $value -EntityId $entityId -EntityKindId $entityKindId -Description $description -ProtectionLevel $protectionLevel -svc $svc -CreateIfNotExist;
			
			# Assert
			$result | Should Not Be $null;
			$result.Description | Should Be $description;
			$result.ProtectionLevel | Should Be $protectionLevel;
		}

		It "Set-EntityBag-WithNewDescriptionAndProtectionLevel-ShouldReturnUpdatedEntity" -Test {
			# Arrange
			$name = "{0}-Name-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			$value = "Value-{0}" -f [guid]::NewGuid().ToString();
			#Replace with dynamically long (create node)
			$entityId = 2;
			$entityKindId = [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::Node.value__;
			$description = "Description-{0}" -f [guid]::NewGuid().ToString();
			$protectionLevel = [biz.dfch.CS.Appclusive.Public.OdataServices.Core.EntityBagProtectionLevelEnum]::MinValue.value__;
			
			$newDescription = "NewDescription-{0}" -f [guid]::NewGuid().ToString();
			$newValue = "NewValue-{0}" -f [guid]::NewGuid().ToString();
			$newProtectionLevel = [biz.dfch.CS.Appclusive.Public.OdataServices.Core.EntityBagProtectionLevelEnum]::MaxValue.value__;
			
			$result1 = Set-EntityBag -Name $name -Value $value -EntityId $entityId -EntityKindId $entityKindId -Description $description -ProtectionLevel $protectionLevel -svc $svc -CreateIfNotExist;
			$result1 | Should Not Be $null;
			$result1.Description | Should Be $description;
			$result1.ProtectionLevel | Should Be $protectionLevel;
			
			# Act
			$result = Set-EntityBag -Name $name -Value $value -EntityId $entityId -EntityKindId $entityKindId -Description $newDescription -ProtectionLevel $newProtectionLevel -svc $svc;

			# Assert
			$result | Should Not Be $null;
			$result.Description | Should Be $newDescription;
			$result.ProtectionLevel | Should Be $newProtectionLevel;
			$result.Id | Should Be $result1.Id;
		}
		
		It "Set-EntityBag-ShouldReturnUpdatedValue" -Test {
			# Arrange
			$name = "{0}-Name-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			$value = "value-{0}" -f [guid]::NewGuid().ToString();
			$entityId = 2; #Replace with dynamically long
			$entityKindId = [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::Node.value__;

			$newValue = "Newvalue-{0}" -f [guid]::NewGuid().ToString();

			$result1 = Set-EntityBag -Name $name -Value $value -EntityId $entityId -EntityKindId $entityKindId -svc $svc -CreateIfNotExist;
			$result1 | Should Not Be $null;
			
			# Act
			$result = Set-EntityBag -Name $name -Value $value -EntityId $entityId -EntityKindId $entityKindId -svc $svc -NewValue $newValue;
			
			# Assert
			$result | Should Not Be $null;
			$result.Value | Should Be $newValue;
			$result.EntityId | Should Be $entityId;
			$result.EntityKindId| Should Be $entityKindId;
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
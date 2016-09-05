#Requires -Modules @{ ModuleName = 'biz.dfch.PS.Pester.Assertions'; ModuleVersion = '1.1.1.20160710' }

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "New-EntityBag" -Tags "New-EntityBag" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Format-ResultAs.ps1"
	. "$here\Set-EntityBag.ps1"
	. "$here\Set-Node.ps1"
	. "$here\Get-Job.ps1"
	. "$here\Get-EntityKind.ps1"
	. "$here\Get-Tenant.ps1"
	. "$here\Get-Node.ps1"
	. "$here\New-Node.ps1"
	
	$entityPrefix = "New-EntityBag";
	$usedEntitySets = @("EntityBags" , "Nodes");
	

	Context "New-EntityBag" {
	
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
		
		It "New-EntityBagWithMandatoryParameters-ShouldReturnNewEntity" -Test {
			# Arrange
			$protectionLevel = [biz.dfch.CS.Appclusive.Public.OdataServices.Core.EntityBagProtectionLevelEnum]::Default.value__;
			
			# Act
			$result = New-EntityBag -svc $svc -Name $name -Value $value -EntityKindId $entityKindId -EntityId $testNode.Id;
			
			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be $name;
			$result.Value | Should Be $value;
			$result.EntityKindId | Should Be $entityKindId;
			$result.EntityId | Should Be $testNode.Id;
			$result.ProtectionLevel | Should Be $protectionLevel;
		}

		It "New-EntityBag-ShouldReturnNewEntityWithDescriptionAndProtectionLevel" -Test {
			# Arrange
			$description = "Description-{0}" -f [guid]::NewGuid().ToString();
			$protectionLevel = [biz.dfch.CS.Appclusive.Public.OdataServices.Core.EntityBagProtectionLevelEnum]::MinValue.value__;
			
			# Act
			$result = New-EntityBag -svc $svc -Name $name -Value $value -EntityKindId $entityKindId -EntityId $testNode.Id -Description $description -ProtectionLevel $protectionLevel;

			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Value | Should Be $value;
			$result.Name | Should Be $Name;
			$result.Description | Should Be $description;
			$result.ProtectionLevel | Should Be $protectionLevel;
			$result.EntityId | Should Be $testNode.Id;
			$result.EntityKindId | Should Be $entityKindId;
		}

		It "New-EntityBag-CreateTwiceTheSameEntityBagShouldThrowContractException" -Test {
			# Arrange
			# N/A
			
			# Act / Assert
			$result = New-EntityBag -svc $svc -Name $name -Value $value -EntityKindId $entityKindId -EntityId $testNode.Id;
			{ New-EntityBag -svc $svc -Name $name -Value $value -EntityKindId $entityKindId -EntityId $testNode.Id } | Should ThrowErrorId 'Contract';
		}	
		
		It "New-EntityBag-WithInvalidEntityIdShouldThrowArgumentException" -Test {
			# Arrange
			$invalidEntityId = 0;
			
			# Act
			{ New-EntityBag -svc $svc -Name $name -Value $value -EntityKindId $entityKindId -Entityid $invalidEntityId } | Should Throw 'argument';
			
			# Assert
		}
		
		It "New-EntityBag-WithInvalidProtectionLevelShouldThrowContractException" -Test {
			# Arrange
			$invalidProtectionLevel = [biz.dfch.CS.Appclusive.Public.OdataServices.Core.EntityBagProtectionLevelEnum]::MaxValue.value__ + 1;
			
			# Act
			{ New-EntityBag -svc $svc -Name $name -Value $value -EntityKindId $entityKindId -Entityid $testNode.Id -ProtectionLevel $invalidProtectionLevel } | Should ThrowErrorId 'Contract';
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

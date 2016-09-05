$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Get-EntityBag" -Tags "Get-EntityBag" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Format-ResultAs.ps1"
	. "$here\Get-Job.ps1"
	. "$here\Get-EntityKind.ps1"
	. "$here\Get-Tenant.ps1"
	. "$here\Get-Node.ps1"
	. "$here\Get-User.ps1"
	. "$here\Set-Node.ps1"
	. "$here\Set-EntityBag.ps1"
	. "$here\New-Node.ps1"
	
	$entityPrefix = "Get-EntityBag";
	$usedEntitySets = @("EntityBags", "Nodes");
	
	Context "Get-EntityBag" {
		
		BeforeAll {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;
		
			$svc = Enter-ApcServer;
		
			# Create Test Data
			for ($i = 0; $i -le 5; $i++)
			{
				$name = "{0}-Name-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
				$value = "value-{0}" -f [guid]::NewGuid().ToString();
				$entityKindId = [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::Node.value__;

				$currentTenant = Get-Tenant -Current -svc $svc;
				$testNode = New-Node -Name $name -ParentId $currentTenant.NodeId -EntityKindId $entityKindId -svc $svc;
				
				Set-EntityBag -Name $name -Value $value -EntityId $testNode.Id -EntityKindId $entityKindId -svc $svc -CreateIfNotExist;
			}
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

			# Delete Test Data
			foreach ($entitySet in $usedEntitySets)
			{
				$entities = $svc.Core.$entitySet.AddQueryOption('$filter', $entityFilter) | Select;
		 
				foreach ($entity in $entities)
				{
					Remove-ApcEntity -svc $svc -Id $entity.Id -EntitySetName $entitySet -Confirm:$false;
				}
			}
		}
	
		It "Warmup" -Test {
			$true | Should Be $true;
		}

		It "Get-EntityBag-ShouldReturnList" -Test {
			# Arrange
			# N/A
			
			# Act
			$result = Get-EntityBag -svc $svc -ListAvailable;
			
			# Assert
			$result | Should Not Be $null;
			$result -is [Array] | Should Be $true;
			0 -lt $result.Count | Should Be $true;
		}

		It "Get-EntityBagListAvailableSelectName-ShouldReturnListWithNamesOnly" -Test {
			# Arrange
			# N/A
			
			# Act
			$result = Get-EntityBag -svc $svc -ListAvailable -Select Name;

			# Assert
			$result | Should Not Be $null;
			$result -is [Array] | Should Be $true;
			0 -lt $result.Count | Should Be $true;
			$result[0].Name | Should Not Be $null;
			$result[0].Id | Should Be $null;
		}

		It "Get-EntityBagFirst-ShouldReturnFirstEntity" -Test {
			# Arrange
			$showFirst = 1;
			
			# Act
			$result = Get-EntityBag -svc $svc -First $showFirst;

			# Assert
			$result | Should Not Be $null;
			$result -is [biz.dfch.CS.Appclusive.Api.Core.EntityBag] | Should Be $true;
		}
		
		It "Get-EntityBag-ShouldReturnEntityById" -Test {
			# Arrange
			$showFirst = 1;
			
			# Act
			$resultFirst = Get-EntityBag -svc $svc -First $showFirst;
			$Id = $resultFirst.Id;
			$result = Get-EntityBag -Id $Id -svc $svc;

			# Assert
			$result | Should Not Be $null;
			$result | Should Be $resultFirst;
			$result -is [biz.dfch.CS.Appclusive.Api.Core.EntityBag] | Should Be $true;
		}
		
		It "Get-EntityBag-ShouldReturnFiveEntities" -Test {
			# Arrange
			$showFirst = 5;
			
			# Act
			$result = Get-EntityBag -svc $svc -First $showFirst;

			# Assert
			$result | Should Not Be $null;
			$showFirst -eq $result.Count | Should Be $true;
			$result[0] -is [biz.dfch.CS.Appclusive.Api.Core.EntityBag] | Should Be $true;
		}

		It "Get-EntityBagThatDoesNotExist-ShouldReturnNull" -Test {
			# Arrange
			$entityBagName = 'EntityBag-that-does-not-exist';
			
			# Act
			$result = Get-EntityBag -svc $svc -Name $entityBagName;

			# Assert
			$result | Should Be $null;
		}
		
		It "Get-EntityBagThatDoesNotExist-ShouldReturnDefaultValue" -Test {
			# Arrange
			$entityBagName = 'EntityBag-that-does-not-exist';
			$defaultValue = 'MyDefaultValue';
			
			# Act
			$result = Get-EntityBag -svc $svc -Name $entityBagName -DefaultValue $defaultValue;

			# Assert
			$result | Should Be $defaultValue;
		}
		
		It "Get-EntityBagAsXml-ShouldReturnXML" -Test {
			# Arrange
			$showFirst = 1;
			
			# Act
			$result = Get-EntityBag -svc $svc -First $showFirst -As xml;

			# Assert
			$result | Should Not Be $null;
			$result.Substring(0,5) | Should Be '<?xml';
		}
		
		It "Get-EntityBag-ShouldReturnJSON" -Test {
			# Arrange
			$showFirst = 1;
			
			# Act
			$result = Get-EntityBag -svc $svc -First $showFirst -As json;

			# Assert
			$result | Should Not Be $null;
			$result.Substring(0, 1) | Should Be '{';
			$result.Substring($result.Length -1, 1) | Should Be '}';
		}
		
		It "Get-EntityBag-WithInvalidId-ShouldThrowException" -Test {
			# Act
			try 
			{
				$result = Get-EntityBag -Id 'myEntityBag';
				'throw exception' | Should Be $true;
			} 
			catch
			{
				# Assert
			   	$result | Should Be $null;
			}
		}

		It "Get-EntityBag-ByEntityKindIdandEntityId" -Test {
			# Arrange
			$showFirst = 1;
			
			$resultFirst = Get-EntityBag -svc $svc -First $showFirst;
			$entityKindId = $resultFirst.EntityKindId;
			$entityId = $resultFirst.EntityId;
		
			# Act
			$result = Get-EntityBag -svc $svc -EntityKindId $entityKindId -EntityId $entityId;
			
			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Be $resultFirst.Id;
			$result.EntityKindId | Should Be $entityKindId;
			$result.EntityId | Should Be $entityId;
		}
		
		It "Get-EntityBag-ByNameEntityKindIdAndEntityId" -Test {
			# Arrange
			$showFirst = 1;
			
			$resultFirst = Get-EntityBag -svc $svc -First $showFirst;
			$entityKindId = $resultFirst.EntityKindId;
			$entityId = $resultFirst.EntityId;
			$name = $resultFirst.Name;
			
			$resultFirst | Should Not Be $null;
		
			# Act
			$result = Get-EntityBag -svc $svc -Name $name -EntityKindId $entityKindId -EntityId $entityId;
			
			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Be $resultFirst.Id;
			$result.EntityKindId | Should Be $entityKindId;
			$result.EntityId | Should Be $entityId;
			$result.Name | Should Be $name;
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

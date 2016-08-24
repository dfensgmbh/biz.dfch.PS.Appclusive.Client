
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Set-ManagementUri" -Tags "Set-ManagementUri" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Format-ResultAs.ps1"

	$entityPrefix = "Set-ManagementUri";
	$usedEntitySets = @("ManagementUris");
	

	Context "Set-ManagementUri" {
	
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

		It "Set-ManagementUri-ShouldReturnNewEntity" -Test {
			# Arrange
			$name = "{0}-Name-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			$type = "type-{0}" -f [guid]::NewGuid().ToString();
			$value = "value-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			$result = Set-ManagementUri -svc $svc -Name $name -Type $type -Value $value -CreateIfNotExist;
			
			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be $name;
			$result.Type | Should Be $type;
			$result.Value | Should Be $value;
		}
		
		It "Set-ManagementUri-ShouldReturnNewEntityWithDescription" -Test {
			# Arrange
			$name = "{0}-Name-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			$type = "Type-{0}" -f [guid]::NewGuid().ToString();
			$value = "Value-{0}" -f [guid]::NewGuid().ToString();
			$description = "Description-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			$result = Set-ManagementUri -svc $svc -Name $name -Type $type -Value $value -Description $description -CreateIfNotExist;
			
			# Assert
			$result | Should Not Be $null;
			$result.Description | Should Be $description;
		}

		It "Set-ManagementUriWithNewValueAndDescription-ShouldReturnUpdatedEntity" -Test {
			# Arrange
			$name = "{0}-Name-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			$type = "Type-{0}" -f [guid]::NewGuid().ToString();
			
			$description = "Description-{0}" -f [guid]::NewGuid().ToString();
			$newDescription = "NewDescription-{0}" -f [guid]::NewGuid().ToString();
			
			$value = "Value-{0}" -f [guid]::NewGuid().ToString();
			$newValue = "NewValue-{0}" -f [guid]::NewGuid().ToString();
			
			$result1 = Set-ManagementUri -svc $svc -Name $name -Description $description -Value $value -Type $type -CreateIfNotExist;
			$result1 | Should Not Be $null;
			
			# Act
			$result = Set-ManagementUri -svc $svc -Name $name -Description $newDescription -Type $type -Value $newValue;

			# Assert
			$result | Should Not Be $null;
			$result.Description | Should Be $newDescription;
			$result.Value | Should Be $newValue;
		}
		
		It "Set-ManagementUriWithNewNameAndType-ShouldReturnUpdatedEntity" -Test {
			# Arrange
			$name = "{0}-Name-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			$type = "Type-{0}" -f [guid]::NewGuid().ToString();
			
			$newName = "{0}-NewName-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			$newType = "NewType-{0}" -f [guid]::NewGuid().ToString();
			
			Set-ManagementUri -Name $name -Type $type -svc $svc -CreateIfNotExist;
			
			# Act
			$result = Set-ManagementUri -Name $name -Type $type -NewName $newName -newType $newType -svc $svc;
			
			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be $newName;
			$result.Type | Should Be $newType;
		}
	}
}

#
# Copyright 2015 d-fens GmbH
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
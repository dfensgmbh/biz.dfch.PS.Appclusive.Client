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
			
			$name = "{0}-{1}" -f $entityPrefix, [guid]::NewGuid().toString();
			$Tid = "{0}" -f [guid]::NewGuid().toString();
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
			$result = Set-Role -Name $name -Tid $Tid -svc $svc -CreateIfNotExist;
			
			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be $name;
			$result.Tid | Should Be $Tid;
		}
	
		It "Set-Role-ShouldReturnNewEntityWithDescription" -Test {
			# Arrange
			$description = "Description-{0}" -f [guid]::NewGuid().ToString();
				
			# Act
			$result = Set-Role -Name $name -Tid $Tid -Description $description -svc $svc -CreateIfNotExist;
			
			# Assert
			$result | Should Not Be $null;
			$result.Description | Should Be $description;
		}

		It "Set-Role-WithNewDescription-ShouldReturnUpdatedEntity" -Test {
			# Arrange
			$description = "Description-{0}" -f [guid]::NewGuid().ToString();
			$newDescription = "NewDescription-{0}" -f [guid]::NewGuid().ToString();
			
			$result1 = Set-Role -Name $name -Tid $Tid -Description $description -svc $svc -CreateIfNotExist;
			$result1 | Should Not Be $null;
			$result1.Description | Should Be $description;
			
			# Act
			$result = Set-Role -Name $name -Tid $Tid -Description $newDescription -svc $svc;

			# Assert
			$result | Should Not Be $null;
			$result.Description | Should Be $newDescription;
			$result.Id | Should Be $result1.Id;
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

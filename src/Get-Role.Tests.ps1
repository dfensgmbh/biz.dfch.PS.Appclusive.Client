$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Get-Role" -Tags "Get-Role" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Format-ResultAs.ps1"
	. "$here\Get-Tenant.ps1"
	
	$entityPrefix = "Get-Role";
	$usedEntitySets = @("Roles");
	
	Context "Get-Role" {
		
		
		BeforeEach {
			
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;
		
			$svc = Enter-ApcServer;
	
			$name = "{0}-Name-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			$value = "value-{0}" -f [guid]::NewGuid().ToString();
			$entityKindId = [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::Node.value__;
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

		It "Get-Role-ShouldReturnList" -Test {
			# Arrange
			# N/A
			
			# Act
			$result = Get-Role -svc $svc -ListAvailable;
			
			# Assert
			$result | Should Not Be $null;
			$result -is [Array] | Should Be $true;
			0 -lt $result.Count | Should Be $true;
		}

		It "Get-RoleListAvailableSelectName-ShouldReturnListWithNamesOnly" -Test {
			# Arrange
			# N/A
			
			# Act
			$result = Get-Role -svc $svc -ListAvailable -Select Name;

			# Assert
			$result | Should Not Be $null;
			$result -is [Array] | Should Be $true;
			0 -lt $result.Count | Should Be $true;
			$result[0].Name | Should Not Be $null;
			$result[0].Id | Should Be $null;
		}

		It "Get-RoleFirst-ShouldReturnFirstEntity" -Test {
			# Arrange
			$showFirst = 1;
			
			# Act
			$result = Get-Role -svc $svc -First $showFirst;

			# Assert
			$result | Should Not Be $null;
			$result -is [biz.dfch.CS.Appclusive.Api.Core.Role] | Should Be $true;
		}
		
		It "Get-Role-ShouldReturnEntityById" -Test {
			# Arrange
			$showFirst = 1;
			
			# Act
			$resultFirst = Get-Role -svc $svc -First $showFirst;
			$id = $resultFirst.Id;
			$result = Get-Role -Id $id -svc $svc;

			# Assert
			$result | Should Not Be $null;
			$result | Should Be $resultFirst;
			$result -is [biz.dfch.CS.Appclusive.Api.Core.Role] | Should Be $true;
			$result.id | Should Be $id;
		}
		
		It "Get-Role-ShouldReturnFiveEntities" -Test {
			# Arrange
			$showFirst = 5;
			
			# Act
			$result = Get-Role -svc $svc -First $showFirst;

			# Assert
			$result | Should Not Be $null;
			$showFirst -eq $result.Count | Should Be $true;
			$result[0] -is [biz.dfch.CS.Appclusive.Api.Core.Role] | Should Be $true;
		}

		It "Get-RoleThatDoesNotExist-ShouldReturnNull" -Test {
			# Arrange
			$roleName = 'Role-that-does-not-exist';
			
			# Act
			$result = Get-Role -svc $svc -Name $roleName;

			# Assert
			$result | Should Be $null;
		}
		
		It "Get-RoleThatDoesNotExist-ShouldReturnDefaultValue" -Test {
			# Arrange
			$roleName = 'Role-that-does-not-exist';
			$defaultValue = 'MyDefaultValue';
			
			# Act
			$result = Get-Role -svc $svc -Name $roleName -DefaultValue $defaultValue;

			# Assert
			$result | Should Be $defaultValue;
		}
		
		It "Get-RoleAsXml-ShouldReturnXML" -Test {
			# Arrange
			$showFirst = 1;
			
			# Act
			$result = Get-Role -svc $svc -First $showFirst -As xml;

			# Assert
			$result | Should Not Be $null;
			$result.Substring(0,5) | Should Be '<?xml';
		}
		
		It "Get-Role-ShouldReturnJSON" -Test {
			# Arrange
			$showFirst = 1;
			
			# Act
			$result = Get-Role -svc $svc -First $showFirst -As json;

			# Assert
			$result | Should Not Be $null;
			$result.Substring(0, 1) | Should Be '{';
			$result.Substring($result.Length -1, 1) | Should Be '}';
		}
		
		It "Get-Role-WithInvalidId-ShouldThrowException" -Test {
			# Act
			try 
			{
				$result = Get-Role -Id 'myRole';
				'throw exception' | Should Be $true;
			} 
			catch
			{
				# Assert
			   	$result | Should Be $null;
			}
		}

		It "Get-Role-ByNameReturnsRole" -Test {
			# Arrange
			$showFirst = 1;
			
			$resultFirst = Get-Role -svc $svc -First $showFirst;
			$name = $resultFirst.Name;
		
			# Act
			$result = Get-Role -svc $svc -Name $name;
			
			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Be $resultFirst.Id;
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

#Requires -Modules @{ ModuleName = 'biz.dfch.PS.Pester.Assertions'; ModuleVersion = '1.1.1.20160710' }

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Set-Role" -Tags "Set-Role" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Format-ResultAs.ps1"
	. "$here\Get-Tenant.ps1"
	. "$here\Get-Role.ps1"

	$entityPrefix = "Set-Role";
	$usedEntitySets = @("Roles");
	

	Context "Set-Role" {
	
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;

			$svc = Enter-ApcServer;
			
			$name = "{0}-{1}" -f $entityPrefix, [guid]::NewGuid().toString();
			$roleType = [biz.dfch.CS.Appclusive.Public.Security.RoleTypeEnum]::Default.value__;
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
			$result = Set-Role -Name $name -RoleType $roleType -svc $svc -CreateIfNotExist;
			
			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be $name;
		}
	
		It "Set-RoleWithDescription-ShouldReturnNewEntityWithDescription" -Test {
			# Arrange
			$description = "Description-{0}" -f [guid]::NewGuid().ToString();
				
			# Act
			$result = Set-Role -Name $name -RoleType $roleType -Description $description -svc $svc -CreateIfNotExist;
			
			# Assert
			$result | Should Not Be $null;
			$result.Description | Should Be $description;
		}

		It "Set-Role-WithNewDescription-ShouldReturnUpdatedEntity" -Test {
			# Arrange
			$description = "Description-{0}" -f [guid]::NewGuid().ToString();
			$newDescription = "NewDescription-{0}" -f [guid]::NewGuid().ToString();
			
			$result1 = Set-Role -Name $name -RoleType $roleType -Description $description -svc $svc -CreateIfNotExist;
			$result1 | Should Not Be $null;
			$result1.Description | Should Be $description;
			
			# Act
			$result = Set-Role -Name $result1.Name -Description $newDescription -svc $svc;

			# Assert
			$result | Should Not Be $null;
			$result.Description | Should Be $newDescription;
			$result.Id | Should Be $result1.Id;
		}
		
		It "Set-RoleWithNewName-ShouldReturnUpdatedEntity" -Test {
			# Arrange
			$newName = "{0}-NewName-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			
			$result1 = Set-Role -Name $name -RoleType $roleType -svc $svc -CreateIfNotExist;
			$result1 | Should Not Be $null;
			$result1.Name | Should Be $name;
			
			# Act
			$result = Set-Role -Name $result1.Name -NewName $newName -svc $svc;

			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be $newName;
			$result.Id | Should Be $result1.Id;
		}
		
		It "Set-Role-WithNewMailAddress-ShouldReturnUpdatedEntity" -Test {
			# Arrange
			$mailaddress = "arbitrary@example.com";
			$newMailaddress = "new@example.com" -f [guid]::NewGuid().ToString();
			
			$result1 = Set-Role -Name $name -RoleType $roleType -Mailaddress $mailaddress -svc $svc -CreateIfNotExist;
			$result1 | Should Not Be $null;
			$result1.Mailaddress | Should Be $mailaddress;
			
			# Act
			$result = Set-Role -Name $result1.Name -Mailaddress $newMailaddress -svc $svc;

			# Assert
			$result | Should Not Be $null;
			$result.Mailaddress | Should Be $newMailaddress;
			$result.Id | Should Be $result1.Id;
		}
		
		It "Set-RoleDoesNotExist-ShouldThrowException" -Test {
			# Arrange
			$nameNotExisting = "not-existing-role-{0}" -f [guid]::NewGuid();
			# N/A (Declared in BeforeEach)
			
			# Act
			{ Set-Role -Name $nameNotExisting -RoleType $roleType -svc $svc } | Should Throw;
			
			# Assert
		}
		
		It "Set-RoleWithPermissions-ShouldCreateEntityWithSpecifiedPermissions" -Test {
			# Arrange
			$permissions = @("Apc:AcesCanRead", "Apc:AcesCanCreate");
			
			# Act
			$result = Set-Role -Name $name -RoleType $roleType -Permissions $permissions -svc $svc -CreateIfNotExist;
			$result | Should Not Be $null;
			$result.Id -gt 0 | Should Be $true
			
			$svc = Enter-ApcServer;
			$resultPermissions = Get-Role -Id $result.Id -ExpandPermissions -svc $svc;
			
			# Assert
			$resultPermissions | Should Not be $null;
			$resultPermissions.Count -gt 0 | Should Be $true;
		}
		
		It "Set-RoleWithPermissions-ShouldAddSpecifiedPermissions" -Test {
			# Arrange
			$permissions = @("Apc:AcesCanRead","Apc:AcesCanCreate");
			
			# Act
			$result = Set-Role -Name $name -RoleType $roleType -svc $svc -CreateIfNotExist;
			$result | Should Not Be $null;
			
			$svc = Enter-ApcServer;
			$result = Set-Role -Id $result.Id -Permissions $permissions -svc $svc;
			
			$svc = Enter-ApcServer;
			$resultPermissions = Get-Role -Id $result.Id -ExpandPermissions -svc $svc;
			
			# Assert
			$resultPermissions | Should Not be $null;
			$resultPermissions.Count -gt 0 | Should Be $true;
		}
		
		It "Set-RoleWithDuplicatePermissions-ShouldThrowContractException" -Test {
			# Arrange
			$permissions = @("Apc:AcesCanRead","Apc:AcesCanCreate");
			
			# Act
			$result = Set-Role -Name $name -RoleType $roleType -Permissions $permissions -svc $svc -CreateIfNotExist;
			$result | Should Not Be $null;
			
			$svc = Enter-ApcServer;
			{ Set-Role -Id $result.Id -Permissions $permissions -svc $svc } | Should ThrowErrorId "Contract";
			
			# Assert
			$resultPermissions | Should Not be $null;
			$resultPermissions.Count -gt 0 | Should Be $true;
		}
		
		It "Set-RoleWithPermissionsToRemove-ShouldReturnRemoveSpecifiedPermissions" -Test {
			# Arrange
			$permissions = @("Apc:AcesCanRead", "Apc:AcesCanCreate", "Apc:AcesCanUpdate");
			$permissionsRemove = @("Apc:AcesCanCreate");
			# Act
			$result = Set-Role -Name $name -RoleType $roleType -Permissions $permissions -svc $svc -CreateIfNotExist;
			$result | Should Not Be $null;
			
			$svc = Enter-ApcServer;
			$result = Set-Role -Name $name -RoleType $roleType -Permissions $permissionsRemove -svc $svc -CreateIfNotExist -RemovePermissions;

			$svc = Enter-ApcServer;
			$resultPermissions = Get-Role -Id $result.Id -ExpandPermissions -svc $svc;
			
			# Assert
			$resultPermissions | Should Not be $null;
			$resultPermissions.Count -gt 0 | Should Be $true;
			$resultPermissions.Count -eq 2 | Should Be $true;
		}
		
		It "Set-RoleWithPermissionsToRemoveWhichAreNotPresent-ShouldThrowContractException" -Test {
			# Arrange
			$permissions = @("Apc:AcesCanRead","Apc:AcesCanCreate");
			$notExistingPermissions = @("Apc:AcesCanUpdate");
			
			# Act
			$result = Set-Role -Name $name -RoleType $roleType -Permissions $permissions -svc $svc -CreateIfNotExist;
			$result | Should Not Be $null;
			
			{ Set-Role -Id $result.Id -Permissions $notExistingPermissions -svc $svc -RemovePermissions; } | Should ThrowErrorId "Contract";
			
			
			$svc = Enter-ApcServer;
			$resultingPermissions = Get-Role -Id $result.Id -svc $svc -ExpandPermissions;
			
			# Assert
			$resultingPermissions | Should Not Be $null;
			$resultingPermissions.Count -gt 0 | Should Be $true;
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

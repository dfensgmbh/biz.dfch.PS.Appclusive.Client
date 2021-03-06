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
	$mailaddress = "arbitrary@example.com";
	$newMailaddress = "new@example.com";
	$usedEntitySets = @("Roles");
	

	Context "Set-Role" {
	
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;

			$svc = Enter-ApcServer;
			
			$name = "{0}-{1}" -f $entityPrefix, [guid]::NewGuid().toString();
			$roleType = [biz.dfch.CS.Appclusive.Public.Security.RoleTypeEnum]::Default.ToString();
			$newRoleType = [biz.dfch.CS.Appclusive.Public.Security.RoleTypeEnum]::Distribution.ToString();
		}
		
		AfterAll {
			$svc = Enter-ApcServer;
			$entityFilter = "startswith(Name, '{0}')" -f $entityPrefix;

			foreach ($entitySet in $usedEntitySets)
			{
				$entities = $svc.Core.$entitySet.AddQueryOption('$filter', $entityFilter) | Select;
		 
				foreach ($entity in $entities)
				{
					$permissions = Get-Role -Id $entity.Id -svc $svc -ExpandPermissions;
				
					if ($permissions)
					{
						Set-Role -Id $entity.Id -svc $svc -PermissionsToRemove $permissions.Name;
					}
				
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
		
		It "Set-RoleByIdWithNewValues-ShouldReturnUpdatedEntity" -Test {
			# Arrange
			$newName = "{0}-NewName-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			
			$result1 = Set-Role -Name $name -RoleType $roleType -svc $svc -CreateIfNotExist;
			$result1 | Should Not Be $null;
			$result1.Name | Should Be $name;
			
			# Act
			$result = Set-Role -Id $result1.Id -RoleType $newRoleType -MailAddress $newMailaddress -NewName $newName -svc $svc;

			# Assert
			$result | Should Not Be $null;
			$result.MailAddress | Should Be $newMailaddress;
			$result.Name | Should Be $newName;
			$result.RoleType | Should Be $newRoleType;
			$result.Id | Should Be $result1.Id;
		}
		
		It "Set-RoleWithInvalidNewRoleType-ShouldThrowException" -Test {
			# Arrange
			$newName = "{0}-NewName-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			$invalidRoleType = 42;
			
			$result1 = Set-Role -Name $name -RoleType $roleType -svc $svc -CreateIfNotExist;
			$result1 | Should Not Be $null;
			$result1.Name | Should Be $name;
			
			# Act

			# Assert
			{ Set-Role -Id $result1.Id -RoleType invalidRoleType -svc $svc } | Should Throw;
		}
		
		It "Set-RoleWithNewDescription-ShouldReturnUpdatedEntity" -Test {
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
		
		It "Set-RoleWithNewRoleType-ShouldReturnUpdatedEntity" -Test {
			# Arrange
			$newName = "{0}-NewName-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			
			$result1 = Set-Role -Name $name -RoleType $roleType -svc $svc -CreateIfNotExist;
			$result1 | Should Not Be $null;
			$result1.Name | Should Be $name;
			
			# Act
			$result = Set-Role -Name $result1.Name -RoleType $newRoleType -svc $svc;

			# Assert
			$result | Should Not Be $null;
			$result.RoleType | Should Be $newRoleType;
			$result.Id | Should Be $result1.Id;
		}
		
		It "Set-Role-WithNewMailAddress-ShouldReturnUpdatedEntity" -Test {
			# Arrange
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
		
		It "Set-RoleWhichDoesNotExist-ShouldThrowContractException" -Test {
			# Arrange
			$nonExistingRoleName = "not-existing-role-{0}" -f [guid]::NewGuid();
			
			# Act
			{ Set-Role -Name $nonExistingRoleName -RoleType $roleType -svc $svc } | Should ThrowErrorId "Contract";
			
			# Assert
		}
		
		It "Set-RoleByIdWhichDoesNotExist-ShouldThrowContractException" -Test {
			# Arrange
			$nonExistingRoleId = [long]::MaxValue;
			# N/A (Declared in BeforeEach)
			
			# Act
			{ Set-Role -Id $nonExistingRoleId -NewName "Arbitrary" -svc $svc } | Should ThrowErrorId "Contract"
			
			# Assert
		}
		
		It "Set-RoleWithPermissionsToAddAndCreateIfNotExist-ShouldCreateEntityWithSpecifiedPermissions" -Test {
			# Arrange
			$permissions = @("Apc:AcesCanRead", "Apc:AcesCanCreate");
			
			# Act
			$result = Set-Role -Name $name -RoleType $roleType -PermissionsToAdd $permissions -svc $svc -CreateIfNotExist;
			$result | Should Not Be $null;
			$result.Name | Should Be $name;
			$result.RoleType | Should Be $roleType;
			$result.Id -gt 0 | Should Be $true
			
			$svc = Enter-Apc;
			$resultingPermissions = Get-Role -Id $result.Id -ExpandPermissions -svc $svc;
			
			# Assert
			$resultingPermissions | Should Not be $null;
			$resultingPermissions.Count -eq $permissions.Count | Should Be $true;
		}
		
		It "Set-RoleWithPermissionsToAdd-ShouldAddSpecifiedPermissions" -Test {
			# Arrange
			$permissions = @("Apc:AcesCanRead","Apc:AcesCanCreate");
			
			# Act
			$result = Set-Role -Name $name -RoleType $roleType -svc $svc -CreateIfNotExist;
			$result | Should Not Be $null;
			$result.Name | Should Be $name;
			$result.RoleType | Should Be $roleType;
			
			$svc = Enter-Apc;
			$result = Set-Role -Id $result.Id -PermissionsToAdd $permissions -svc $svc;
			
			$svc = Enter-Apc;
			$resultingPermissions = Get-Role -Id $result.Id -ExpandPermissions -svc $svc;
			
			# Assert
			$resultingPermissions | Should Not be $null;
			$resultingPermissions.Count -eq $permissions.Count | Should Be $true;
		}
		
		It "Set-RoleWithDuplicatesInPermissionsToAdd-ShouldThrowContractException" -Test {
			# Arrange
			$permissions = @("Apc:AcesCanRead","Apc:AcesCanCreate","Apc:AcesCanRead");
			
			# Act
			
			# Assert
			{ Set-Role -Name $name -RoleType $roleType -PermissionsToAdd $permissions -svc $svc -CreateIfNotExist } | Should ThrowErrorId "Contract";
		}
		
		It "Set-RoleWithDuplicatesInPermissionsToRemove-ShouldThrowContractException" -Test {
			# Arrange
			$permissions = @("Apc:AcesCanRead","Apc:AcesCanCreate","Apc:AcesCanRead");
			
			# Act
			
			# Assert
			{ Set-Role -Name $name -RoleType $roleType -PermissionsToRemove $permissions -svc $svc } | Should ThrowErrorId "Contract";
		}
		
		It "Set-RoleByAddingAlreadyLinkedPermissions-ShouldAddNonLinkedPermissions" -Test {
			# Arrange
			$originalPermissions = @("Apc:AcesCanRead","Apc:AcesCanCreate");
			$newPermissions = @("Apc:AcesCanCreate", "Apc:AcesCanUpdate");
			
			# Act
			$result = Set-Role -Name $name -RoleType $roleType -PermissionsToAdd $originalPermissions -svc $svc -CreateIfNotExist;
			$result | Should Not Be $null;
			$result.Name | Should Be $name;
			$result.RoleType | Should Be $roleType;
			
			$svc = Enter-Apc;
			$result = Set-Role -Id $result.Id -PermissionsToAdd $newPermissions -svc $svc;
			
			# Assert
			$svc = Enter-Apc;
			$resultingPermissions = Get-Role -Id $result.Id -ExpandPermissions -svc $svc;
			
			$resultingPermissions | Should Not be $null;
			$resultingPermissions.Count -eq 3 | Should Be $true;
			$resultingPermissions.Name.Contains($originalPermissions[0]) | Should Be $true;
			$resultingPermissions.Name.Contains($originalPermissions[1]) | Should Be $true;
			$resultingPermissions.Name.Contains($newPermissions[1]) | Should Be $true;
		}
		
		It "Set-RoleWithPermissionsToRemove-ShouldRemoveSpecifiedPermissions" -Test {
			# Arrange
			$permissionsToAdd = @("Apc:AcesCanRead", "Apc:AcesCanCreate", "Apc:AcesCanUpdate");
			$permissionsToRemove = @("Apc:AcesCanCreate");
			
			# Act
			$result = Set-Role -Name $name -RoleType $roleType -PermissionsToAdd $permissionsToAdd -svc $svc -CreateIfNotExist;
			$result | Should Not Be $null;
			$result.Name | Should Be $name;
			$result.RoleType | Should Be $roleType;
			
			$svc = Enter-Apc;
			$result = Set-Role -Name $name -PermissionsToRemove $permissionsToRemove -svc $svc;
			
			# Assert
			$svc = Enter-Apc;
			$resultingPermissions = Get-Role -Id $result.Id -ExpandPermissions -svc $svc;
			
			$resultingPermissions | Should Not be $null;
			$resultingPermissions.Count -eq 2 | Should Be $true;
		}
		
		It "Set-RoleWithNonLinkedPermissionsToRemove-ShouldThrowContractException" -Test {
			# Arrange
			$permissionsToAdd = @("Apc:AcesCanRead","Apc:AcesCanCreate");
			$nonLinkedPermissions = @("Apc:AcesCanRead", "Apc:AcesCanUpdate");
			
			# Act
			$result = Set-Role -Name $name -RoleType $roleType -PermissionsToAdd $permissionsToAdd -svc $svc -CreateIfNotExist;
			$result | Should Not Be $null;
			$result.Name | Should Be $name;
			$result.RoleType | Should Be $roleType;
			
			# Assert
			{ Set-Role -Id $result.Id -PermissionsToRemove $nonLinkedPermissions -svc $svc; } | Should ThrowErrorId "Contract";
		}
		
		It "Set-RoleWithSamePermissionInPermissionsToAddAndPermissionsToRemove-ShouldThrowContractException" -Test {
			# Arrange
			$permissionsToAdd = @("Apc:AcesCanRead","Apc:AcesCanCreate");
			$permissionsToRemove = @("Apc:AcesCanRead", "Apc:AcesCanUpdate");
			
			# Act
			$result = Set-Role -Name $name -RoleType $roleType -svc $svc -CreateIfNotExist;
			$result | Should Not Be $null;
			$result.Name | Should Be $name;
			$result.RoleType | Should Be $roleType;
			
			# Assert
			{ Set-Role -Id $result.Id -PermissionsToAdd $permissionsToAdd -PermissionsToRemove $nonLinkedPermissions -svc $svc; } | Should ThrowErrorId "Contract";
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

#Requires -Modules @{ ModuleName = 'biz.dfch.PS.Pester.Assertions'; ModuleVersion = '1.1.1.20160710' }

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Set-Role" -Tags "Set-Role" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Format-ResultAs.ps1"
	. "$here\Get-Tenant.ps1"
	. "$here\Get-Role.ps1"
	. "$here\Get-ModuleVariable.ps1"
	. "$here\Push-ChangeTracker.ps1"
	. "$here\Pop-ChangeTracker.ps1"

	$entityPrefix = "Set-Role";
	$mailaddress = "arbitrary@example.com";
	$newMailaddress = "new@example.com";
	$roleType = [biz.dfch.CS.Appclusive.Public.Security.RoleTypeEnum]::Default.ToString();
	$newRoleType = [biz.dfch.CS.Appclusive.Public.Security.RoleTypeEnum]::Distribution.ToString();
	$usedEntitySets = @("Roles");
	

	Context "Set-Role" {
	
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;

			$svc = Enter-ApcServer;
			
			$name = "{0}-{1}" -f $entityPrefix, [guid]::NewGuid().toString();
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
		
		It "Set-RoleWithPermissions-ShouldCreateEntityWithSpecifiedPermissions" -Test {
			# Arrange
			$permissions = @("Apc:AcesCanRead", "Apc:AcesCanCreate");
			
			# Act
			$result = Set-Role -Name $name -RoleType $roleType -Permissions $permissions -svc $svc -CreateIfNotExist;
			$result | Should Not Be $null;
			$result.Id -gt 0 | Should Be $true
			
			Push-ChangeTracker -Svc $svc;
			$resultPermissions = Get-Role -Id $result.Id -ExpandPermissions -svc $svc;
			Pop-ChangeTracker -Svc $svc;
			
			# Assert
			$resultPermissions | Should Not be $null;
			$resultPermissions.Count -eq $permissions.Count | Should Be $true;
		}
		
		It "Set-RoleWithPermissions-ShouldAddSpecifiedPermissions" -Test {
			# Arrange
			$permissions = @("Apc:AcesCanRead","Apc:AcesCanCreate");
			
			# Act
			$result = Set-Role -Name $name -RoleType $roleType -svc $svc -CreateIfNotExist;
			$result | Should Not Be $null;

			Push-ChangeTracker -Svc $svc;			
			$result = Set-Role -Id $result.Id -Permissions $permissions -svc $svc;
			Pop-ChangeTracker -Svc $svc;
			
			Push-ChangeTracker -Svc $svc;
			$resultPermissions = Get-Role -Id $result.Id -ExpandPermissions -svc $svc;
			Pop-ChangeTracker -Svc $svc;
			
			# Assert
			$resultPermissions | Should Not be $null;
			$resultPermissions.Count -eq $permissions.Count | Should Be $true;
		}
		
		It "Set-RoleWithDuplicatesInPermissions-ShouldThrowContractException" -Test {
			# Arrange
			$permissions = @("Apc:AcesCanRead","Apc:AcesCanCreate");
			
			# Act
			$result = Set-Role -Name $name -RoleType $roleType -Permissions $permissions -svc $svc -CreateIfNotExist;
			$result | Should Not Be $null;
			
			# Assert
			Push-ChangeTracker -Svc $svc;
			{ Set-Role -Id $result.Id -Permissions $permissions -svc $svc } | Should ThrowErrorId "Contract";
			Pop-ChangeTracker -Svc $svc;
		}
		
		It "Set-RoleWithAlreadyMappedPermissions-ShouldThrowContractException" -Test {
			# Arrange
			$originalPermissions = @("Apc:AcesCanRead","Apc:AcesCanCreate");
			$permissionsToBeAdded = @("Apc:AcesCanCreate");
			
			# Act
			$result = Set-Role -Name $name -RoleType $roleType -Permissions $originalPermissions -svc $svc -CreateIfNotExist;
			$result | Should Not Be $null;
			
			# Assert
			Push-ChangeTracker -Svc $svc;
			{ Set-Role -Id $result.Id -Permissions $permissionsToBeAdded -svc $svc } | Should ThrowErrorId "Contract";
			Pop-ChangeTracker -Svc $svc;
		}
		
		It "Set-RoleWithPermissionsToRemove-ShouldRemoveSpecifiedPermissions" -Test {
			# Arrange
			$permissions = @("Apc:AcesCanRead", "Apc:AcesCanCreate", "Apc:AcesCanUpdate");
			$permissionsToRemove = @("Apc:AcesCanCreate");
			
			# Act
			$result = Set-Role -Name $name -RoleType $roleType -Permissions $permissions -svc $svc -CreateIfNotExist;
			$result | Should Not Be $null;
			
			Push-ChangeTracker -Svc $svc;
			$result = Set-Role -Name $name -Permissions $permissionsToRemove -svc $svc -RemovePermissions;
			Pop-ChangeTracker -Svc $svc;
			
			Push-ChangeTracker -Svc $svc;
			$resultPermissions = Get-Role -Id $result.Id -ExpandPermissions -svc $svc;
			Pop-ChangeTracker -Svc $svc;
			
			# Assert
			$resultPermissions | Should Not be $null;
			$resultPermissions.Count -eq 2 | Should Be $true;
		}
		
		It "Set-RoleWithPermissionsToRemoveWhichAreNotPresent-ShouldThrowContractException" -Test {
			# Arrange
			$permissions = @("Apc:AcesCanRead","Apc:AcesCanCreate");
			$notExistingPermissions = @("Apc:AcesCanRead", "Apc:AcesCanUpdate");
			
			# Act
			$result = Set-Role -Name $name -RoleType $roleType -Permissions $permissions -svc $svc -CreateIfNotExist;
			$result | Should Not Be $null;
			
			# Assert
			{ Set-Role -Id $result.Id -Permissions $notExistingPermissions -svc $svc -RemovePermissions; } | Should ThrowErrorId "Contract";
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

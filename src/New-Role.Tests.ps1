#Requires -Modules @{ ModuleName = 'biz.dfch.PS.Pester.Assertions'; ModuleVersion = '1.1.1.20160710' }

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "New-Role" -Tags "New-Role" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Format-ResultAs.ps1"
	. "$here\Get-Role.ps1"
	. "$here\Set-Role.ps1"
	. "$here\Get-Tenant.ps1"

	$entityPrefix = "New-Role";
	$usedEntitySets = @("Roles");
	

	Context "New-Role" {
	
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;

			$svc = Enter-ApcServer;
			
			$name = "{0}-{1}" -f $entityPrefix, [guid]::NewGuid().toString();
			$roleType = [biz.dfch.CS.Appclusive.Public.Security.RoleTypeEnum]::Default.ToString();
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
						Set-Role -Id $entity.Id -svc $svc -Permissions $permissions.Name -RemovePermissions;
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

		It "New-Role-ShouldReturnNewEntity" -Test {
			# Arrange
			# N/A (Declared in BeforeEach)
			
			# Act
			$result = New-Role -Name $name -RoleType $roleType -svc $svc;
			
			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be $name;
			$result.RoleType | Should Be $roleType;
		}
	
		It "New-Role-ShouldReturnNewEntityWithDescription" -Test {
			# Arrange
			$description = "Description-{0}" -f [guid]::NewGuid().ToString();
				
			# Act
			$result = New-Role -Name $name -RoleType $roleType -Description $description -svc $svc;
			
			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be $name;
			$result.RoleType | Should Be $roleType;
			$result.Description | Should Be $description;
		}

		It "New-Role-WithPermissionsShouldReturnNewEntity" -Test {
			# Arrange
			$permissions = @("Apc:AcesCanRead","Apc:AcesCanCreate");
			
			# Act
			$result = New-Role -Name $name -RoleType $roleType -Permissions $permissions -svc $svc;
			$result | Should Not Be $null;
			$result.Name | Should Be $name;
			$result.RoleType | Should Be $roleType;
			
			$svc = Enter-Apc;
			$resultPermissions = Get-Role -Id $result.Id -ExpandPermissions -svc $svc;
			
			# Assert
			$resultPermissions | Should Not be $null;
			$resultPermissions.Count -eq 2 | Should Be $true;
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

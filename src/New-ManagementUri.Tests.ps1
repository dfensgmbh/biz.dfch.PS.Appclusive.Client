#Requires -Modules @{ ModuleName = 'biz.dfch.PS.Pester.Assertions'; ModuleVersion = '1.1.1.20160710' }

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "New-ManagementUri" -Tags "New-ManagementUri" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Set-ManagementUri.ps1"
	. "$here\Set-ManagementCredential.ps1"
	. "$here\Format-ResultAs.ps1"
	
	$entityPrefix = "New-ManagementUri";
	$usedEntitySets = @("ManagementUris", "ManagementCredentials");

	Context "New-ManagementUri" {
	
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

		It "New-ManagementUri-ShouldReturnNewEntityWithProvidedValue" -Test {
			# Arrange
			$name = "{0}-Name-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			$type = "Type-{0}" -f [guid]::NewGuid().ToString();
			$value = "Value-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			$result = New-ManagementUri -svc $svc -Type $type -Name $name -Value $value;

			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Type | Should Be $type;
			$result.Value | Should Be $value;
			$result.Name | Should Be $name;
		}

		It "New-ManagementUriWithDescription-ShouldReturnNewEntity" -Test {
			# Arrange
			$name = "{0}-Name-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			$type = "Type-{0}" -f [guid]::NewGuid().ToString();
			$value = "Value-{0}" -f [guid]::NewGuid().ToString();
			$description = "Description-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			$result = New-ManagementUri -svc $svc -type $type -Name $name -Value $value -Description $description;

			# Assert
			$result | Should Not Be $null;
			$result.Tid | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Name | Should Be $name;
			$result.Value | Should Be $value;
			$result.Description | Should Be $description;
		}

		It "New-ManagementUriWithManagementCredential-ShouldReturnNewEntityReferencingProvidedManagementCredential" -Test {
			# Arrange
			$name = "{0}-Name-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			$type = "Type-{0}" -f [guid]::NewGuid().ToString();
			$value = "Value-{0}" -f [guid]::NewGuid().ToString();
			
			$username = "Username-{0}" -f [guid]::NewGuid().ToString();
			$password = "Password-{0}" -f [guid]::NewGuid().ToString();

			$managementCredential = Set-ManagementCredential -svc $svc -Name $name -Username $username -Password $password -CreateIfNotExist;
			
			# Act
			$result = New-ManagementUri -svc $svc -Name $name -type $type -value $value -ManagementCredential $managementCredential.id
			
			# Assert
			$result | Should Not Be $null;
			$result.Tid | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Name | Should Be $name;
			$result.Value | Should Be $value;
			$result.ManagementCredentialId | Should Be $managementCredential.id
		}
		
		It "New-ManagementUriWithDescripionAndWithManagementCredentialId-ShouldReturnNewEntity" -Test {
			# Arrange
			$name = "{0}-Name-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			$type = "Type-{0}" -f [guid]::NewGuid().ToString();
			$value = "Value-{0}" -f [guid]::NewGuid().ToString();
			$description = "Description-{0}" -f [guid]::NewGuid().ToString();
			
			$username = "Username-{0}" -f [guid]::NewGuid().ToString();
			$password = "Password-{0}" -f [guid]::NewGuid().ToString();

			$managementCredential = Set-ManagementCredential -svc $svc -Name $name -Username $username -Password $password -CreateIfNotExist;

			# Act
			$result = New-ManagementUri -svc $svc -Name $name -type $type -value $value -Description $description -ManagementCredentialId $managementCredential.Id;
			
			# Assert
			$result | Should Not Be $null;
			$result.Tid | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Name | Should Be $name;
			$result.Value | Should Be $value;
			$result.Description | Should Be $description;
			$result.ManagementCredentialId | Should Be $managementCredential.id;
		}
		
		It "New-ManagementUri-ShouldThrowContractException" -Test {
			# Arrange
			$name = "{0}-Name-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			$type = "Type-{0}" -f [guid]::NewGuid().ToString();
			$value = "Value-{0}" -f [guid]::NewGuid().ToString();
			
			# Act/Assert
			$result = New-ManagementUri -svc $svc -Type $type -Name $name -Value $value;
			{ New-ManagementUri -svc $svc -Type $type -Name $name -Value $value } | Should ThrowErrorId 'Contract'; 
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

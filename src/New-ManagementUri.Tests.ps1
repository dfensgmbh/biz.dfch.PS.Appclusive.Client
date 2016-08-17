
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

		It "New-ManagementUri-ShouldReturnNewEntity" -Test {
			# Arrange
			$Name = "{0}-Name-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			$type = "Type-{0}" -f [guid]::NewGuid().ToString();
			$Value = "Value-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			$result = New-ManagementUri -svc $svc -Key $type -Name $Name -Value $Value;

			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.type | Should Be $type;
			$result.Value | Should Be $Value;
			$result.Name | Should Be $Name;
		}

		It "New-ManagementUriWithDescription-ShouldReturnNewEntity" -Test {
			# Arrange
			$Name = "{0}-Name-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			$type = "Type-{0}" -f [guid]::NewGuid().ToString();
			$Value = "Value-{0}" -f [guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			$result = New-ManagementUri -svc $svc -type $type -Name $Name -Value $Value -Description $Description;

			# Assert
			$result | Should Not Be $null;
			$result.Tid | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Name | Should Be $Name;
			$result.Value | Should Be $Value;
			$result.Description | Should Be $Description;
		}

		It "New-ManagementUriWithoutDescripionAndWithManagementCredential-ShouldReturnNewEntity" -Test {
			# Arrange
			$Name = "{0}-Name-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			$type = "Type-{0}" -f [guid]::NewGuid().ToString();
			$Value = "Value-{0}" -f [guid]::NewGuid().ToString();
			$ManagementCredential = Set-ManagementCredential -Name $Name -CreateIfNotExist;
			
			# Act
			$result = New-ManagementUri -svc $svc -Name $Name -type $type -value $value -ManagementCredential $ManagementCredential
			
			# Assert
			$result | Should Not Be $null;
			$result.Tid | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Name | Should Be $Name;
			$result.Value | Should Be $Value;
			$result.ManagementCredentialId | Should Be $ManagementCredential.id
		}
		
		It "New-ManagementUriWithDescripionAndWithManagementCredentialId-ShouldReturnNewEntity" -Test {
			# Arrange
			$Name = "{0}-Name-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			$type = "Type-{0}" -f [guid]::NewGuid().ToString();
			$Value = "Value-{0}" -f [guid]::NewGuid().ToString();
			$ManagementCredential = Set-ManagementCredential -Name $Name -CreateIfNotExist;
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			$result = New-ManagementUri -svc $svc -Name $Name -type $type -value $value -ManagementCredentialId $ManagementCredential.Id;
			
			# Assert
			$result | Should Not Be $null;
			$result.Tid | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Name | Should Be $Name;
			$result.Value | Should Be $Value;
			$result.Description | Should Be $Description;
			$result.ManagementCredentialId | Should Be $ManagementCredential.id;
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

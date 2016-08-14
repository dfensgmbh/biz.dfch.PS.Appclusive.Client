
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Set-ManagementCredential" -Tags "Set-ManagementCredential" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Format-ResultAs.ps1"
	
    BeforeEach {
        $moduleName = 'biz.dfch.PS.Appclusive.Client';
        Remove-Module $moduleName -ErrorAction:SilentlyContinue;
        Import-Module $moduleName;

        $svc = Enter-ApcServer;
    }

	Context "Set-ManagementCredential" {
	
		# Context wide constants
		# N/A

		It "Set-ManagementCredential-ShouldReturnNewEntity" -Test {
			# Arrange
			$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
			$Username = "Username-{0}" -f [guid]::NewGuid().ToString();
			$Password = "Password-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			$result = Set-ManagementCredential -svc $svc -Name $Name -Username $Username -Password $Password -CreateIfNotExist;

			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be $Name;
			$result.Username | Should Be $Username;
			$result.Password | Should Not Be $Password;
			$result.Password -eq $result.EncryptedPassword | Should Be $true;
		}

		It "Set-ManagementCredentialWithNewUsernameAndDescription-ShouldReturnUpdatedEntity" -Test {
			# Arrange
			$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
			$NewDescription = "NewDescription-{0}" -f [guid]::NewGuid().ToString();
			$Username = "Username-{0}" -f [guid]::NewGuid().ToString();
			$NewUsername = "NewUsername-{0}" -f [guid]::NewGuid().ToString();
			$Password = "Password-{0}" -f [guid]::NewGuid().ToString();
			$result1 = Set-ManagementCredential -svc $svc -Name $Name -Description $Description -Username $Username -Password $Password -CreateIfNotExist;
			$result1 | Should Not Be $null;
			
			# Act
			$result = Set-ManagementCredential -svc $svc -Name $Name -Description $NewDescription -Username $NewUsername;

			# Assert
			$result | Should Not Be $null;
			$result.Description | Should Be $NewDescription;
			$result.Username | Should Be $NewUsername;
			$result.Password -eq $result.EncryptedPassword | Should Be $true;
			$result.Password | Should Be $result1.Password;
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
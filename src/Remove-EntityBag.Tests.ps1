
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Remove-ManagementCredential" -Tags "Remove-ManagementCredential" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\New-ManagementCredential.ps1"
	. "$here\Set-ManagementCredential.ps1"
	. "$here\Format-ResultAs.ps1"
	
    BeforeEach {
        $moduleName = 'biz.dfch.PS.Appclusive.Client';
        Remove-Module $moduleName -ErrorAction:SilentlyContinue;
        Import-Module $moduleName;

        $svc = Enter-ApcServer;
    }
 
	Context "Remove-ManagementCredential" {
	
		# Context wide constants
		# N/A

		It "Remove-ManagementCredential-ShouldReturnDeletedEntity" -Test {
			# Arrange
			$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
			$Username = "Username-{0}" -f [guid]::NewGuid().ToString();
			$Password = "Password-{0}" -f [guid]::NewGuid().ToString();
			$result1 = New-ManagementCredential -svc $svc -Name $Name -Username $Username -Password $Password;
			$result1 | Should Not Be $null;
			
			# Act
			$result = Remove-ManagementCredential -svc $svc -Confirm:$false -Name $Name;

			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be $Name;
			$result.Username | Should Be $Username;
		}

		It "Remove-ManagementCredentialThatDoesNotExist-ShouldReturnNull" -Test {
			# Arrange
			$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			{ $result = Remove-ManagementCredential -svc $svc -Name $Name; } | Should Throw 'Assertion failed: ($objectFoundToBeRemoved)';

			# Assert
			$result | Should Be $null;
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

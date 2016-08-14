
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Get-ManagementCredential" -Tags "Get-ManagementCredential" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Get-User.ps1"
	. "$here\Format-ResultAs.ps1"
	
	Context "Get-ManagementCredential" {
        BeforeEach {
            $moduleName = 'biz.dfch.PS.Appclusive.Client';
            Remove-Module $moduleName -ErrorAction:SilentlyContinue;
            Import-Module $moduleName;

            $svc = Enter-ApcServer;
        }

		It "Warmup" -Test {
			$true | Should Be $true;
		}

		It "Get-ManagementCredentialListAvailable-ShouldReturnList" -Test {
			# Arrange
			# N/A
			
			# Act
			$result = Get-ManagementCredential -svc $svc -ListAvailable;

			# Assert
			$result | Should Not Be $null;
			$result -is [Array] | Should Be $true;
			0 -lt $result.Count | Should Be $true;
		}

		It "Get-ManagementCredentialListAvailableSelectName-ShouldReturnListWithNamesOnly" -Test {
			# Arrange
			# N/A
			
			# Act
			$result = Get-ManagementCredential -svc $svc -ListAvailable -Select Name;

			# Assert
			$result | Should Not Be $null;
			$result -is [Array] | Should Be $true;
			0 -lt $result.Count | Should Be $true;
			$result[0].Name | Should Not Be $null;
			$result[0].Id | Should Be $null;
		}

		It "Get-ManagementCredentialAsPSCredential-ShouldReturnPSCredential" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$result = Get-ManagementCredential -svc $svc -First $ShowFirst -As PSCredential;

			# Assert
			$result | Should Not Be $null;
			$result -is [PSCredential] | Should Be $true;
		}

		It "Get-ManagementCredential-ShouldReturnFirstEntity" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$result = Get-ManagementCredential -svc $svc -First $ShowFirst;

			# Assert
			$result | Should Not Be $null;
			$result -is [biz.dfch.CS.Appclusive.Api.Core.ManagementCredential] | Should Be $true;
		}
		
		It "Get-ManagementCredential-ShouldReturnFirstEntityById" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$resultFirst = Get-ManagementCredential -svc $svc -First $ShowFirst;
			$Id = $resultFirst.Id;
			$result = Get-ManagementCredential -Id $Id -svc $svc;

			# Assert
			$result | Should Not Be $null;
			$result | Should Be $resultFirst;
			$result -is [biz.dfch.CS.Appclusive.Api.Core.ManagementCredential] | Should Be $true;
		}
		
		It "Get-ManagementCredential-ShouldReturnFiveEntities" -Test {
			# Arrange
			$ShowFirst = 5;
			
			# Act
			$result = Get-ManagementCredential -svc $svc -First $ShowFirst;

			# Assert
			$result | Should Not Be $null;
			$ShowFirst -eq $result.Count | Should Be $true;
			$result[0] -is [biz.dfch.CS.Appclusive.Api.Core.ManagementCredential] | Should Be $true;
		}

		It "Get-ManagementCredentialThatDoesNotExist-ShouldReturnNull" -Test {
			# Arrange
			$ManagementCredentialName = 'ManagementCredential-that-does-not-exist';
			
			# Act
			$result = Get-ManagementCredential -svc $svc -Name $ManagementCredentialName;

			# Assert
			$result | Should Be $null;
		}
		
		It "Get-ManagementCredentialThatDoesNotExist-ShouldReturnDefaultValue" -Test {
			# Arrange
			$ManagementCredentialName = 'ManagementCredential-that-does-not-exist';
			$DefaultValue = 'MyDefaultValue';
			
			# Act
			$result = Get-ManagementCredential -svc $svc -Name $ManagementCredentialName -DefaultValue $DefaultValue;

			# Assert
			$result | Should Be $DefaultValue;
		}
		
		It "Get-ManagementCredential-ShouldReturnXML" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$result = Get-ManagementCredential -svc $svc -First $ShowFirst -As xml;

			# Assert
			$result | Should Not Be $null;
			$result.Substring(0,5) | Should Be '<?xml';
		}
		
		It "Get-ManagementCredential-ShouldReturnJSON" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$result = Get-ManagementCredential -svc $svc -First $ShowFirst -As json;

			# Assert
			$result | Should Not Be $null;
			$result.Substring(0, 1) | Should Be '{';
			$result.Substring($result.Length -1, 1) | Should Be '}';
		}
		
		It "Get-ManagementCredential-WithInvalidId-ShouldReturnException" -Test {
			# Act
			try 
			{
				$result = Get-ManagementCredential -svc $svc -Id 'myManagementCredential';
				'throw exception' | Should Be $true;
			} 
			catch
			{
				# Assert
			   	$result | Should Be $null;
			}
		}
		
		It "Get-ManagementCredentialByCreatedByThatDoesNotExist-ShouldReturnNull" -Test {
			# Arrange
			$User = 'User-that-does-not-exist';
			
			# Act
			$result = Get-ManagementCredential -svc $svc -CreatedBy $User;

			# Assert
		   	$result | Should Be $null;
		}
		
		It "Get-ManagementCredentialByCreatedBy-ShouldReturnListWithEntities" -Test {
			# Arrange
			$User = 'SYSTEM';
			
			# Act
			$result = Get-ManagementCredential -svc $svc -CreatedBy $User;

			# Assert
		   	$result | Should Not Be $null;
			$result -is [Array] | Should Be $true;
			0 -lt $result.Count | Should Be $true;
		}
		
		It "Get-ManagementCredentialByModifiedBy-ShouldReturnListWithEntities" -Test {
			# Arrange
			$User = 'SYSTEM';
			
			# Act
			$result = Get-ManagementCredential -svc $svc -ModifiedBy $User;

			# Assert
		   	$result | Should Not Be $null;
			$result -is [Array] | Should Be $true;
			0 -lt $result.Count | Should Be $true;
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

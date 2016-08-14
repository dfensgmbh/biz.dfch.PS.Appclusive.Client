$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Get-ManagementUri" -Tags "Get-ManagementUri" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Get-User.ps1"
	. "$here\Format-ResultAs.ps1"
	
	BeforeEach {
		$moduleName = 'biz.dfch.PS.Appclusive.Client';
		Remove-Module $moduleName -ErrorAction:SilentlyContinue;
		Import-Module $moduleName;
	
		$svc = Enter-ApcServer;
	}
	
	Context "Get-ManagementUri" {
	
		# Context wide constants
		# N/A
		
		It "Warmup" -Test {
			$true | Should Be $true;
		}

		It "Get-ManagementUriListAvailable-ShouldReturnList" -Test {
			# Arrange
			# N/A
			
			# Act
			$result = Get-ManagementUri -svc $svc -ListAvailable;

			# Assert
			$result | Should Not Be $null;
			$result -is [Array] | Should Be $true;
			0 -lt $result.Count | Should Be $true;
		}

		It "Get-ManagementUriListAvailableSelectName-ShouldReturnListWithNamesOnly" -Test {
			# Arrange
			# N/A
			
			# Act
			$result = Get-ManagementUri -svc $svc -ListAvailable -Select Name;

			# Assert
			$result | Should Not Be $null;
			$result -is [Array] | Should Be $true;
			0 -lt $result.Count | Should Be $true;
			$result[0].Name | Should Not Be $null;
			$result[0].Id | Should Be $null;
		}

		It "Get-ManagementUri-ShouldReturnFirstEntity" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$result = Get-ManagementUri -svc $svc -First $ShowFirst;

			# Assert
			$result | Should Not Be $null;
			$result -is [biz.dfch.CS.Appclusive.Api.Core.ManagementUri] | Should Be $true;
		}
		
		It "Get-ManagementUri-ShouldReturnFirstEntityById" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$resultFirst = Get-ManagementUri -svc $svc -First $ShowFirst;
			$Id = $resultFirst.Id;
			$result = Get-ManagementUri -Id $Id -svc $svc;

			# Assert
			$result | Should Not Be $null;
			$result | Should Be $resultFirst;
			$result -is [biz.dfch.CS.Appclusive.Api.Core.ManagementUri] | Should Be $true;
		}
		
		It "Get-ManagementUri-ShouldReturnFiveEntities" -Test {
			# Arrange
			$ShowFirst = 5;
			
			# Act
			$result = Get-ManagementUri -svc $svc -First $ShowFirst;

			# Assert
			$result | Should Not Be $null;
			$ShowFirst -eq $result.Count | Should Be $true;
			$result[0] -is [biz.dfch.CS.Appclusive.Api.Core.ManagementUri] | Should Be $true;
		}

		It "Get-ManagementUriThatDoesNotExist-ShouldReturnNull" -Test {
			# Arrange
			$ManagementUriName = 'ManagementUri-that-does-not-exist';
			
			# Act
			$result = Get-ManagementUri -svc $svc -Name $ManagementUriName;

			# Assert
			$result | Should Be $null;
		}
		
		It "Get-ManagementUriThatDoesNotExist-ShouldReturnDefaultValue" -Test {
			# Arrange
			$ManagementUriName = 'ManagementUri-that-does-not-exist';
			$DefaultValue = 'MyDefaultValue';
			
			# Act
			$result = Get-ManagementUri -svc $svc -Name $ManagementUriName -DefaultValue $DefaultValue;

			# Assert
			$result | Should Be $DefaultValue;
		}
		
		It "Get-ManagementUri-ShouldReturnXML" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$result = Get-ManagementUri -svc $svc -First $ShowFirst -As xml;

			# Assert
			$result | Should Not Be $null;
			$result.Substring(0,5) | Should Be '<?xml';
		}
		
		It "Get-ManagementUri-ShouldReturnJSON" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$result = Get-ManagementUri -svc $svc -First $ShowFirst -As json;

			# Assert
			$result | Should Not Be $null;
			$result.Substring(0, 1) | Should Be '{';
			$result.Substring($result.Length -1, 1) | Should Be '}';
		}
		
		It "Get-ManagementUri-WithInvalidId-ShouldReturnException" -Test {
			# Act
			try 
			{
				$result = Get-ManagementUri -Id 'myManagementUri';
				'throw exception' | Should Be $true;
			} 
			catch
			{
				# Assert
			   	$result | Should Be $null;
			}
		}
		
		It "Get-ManagementUriByCreatedByThatDoesNotExist-ShouldReturnNull" -Test {
			# Arrange
			$User = 'User-that-does-not-exist';
			
			# Act
			$result = Get-ManagementUri -svc $svc -CreatedBy $User;

			# Assert
		   	$result | Should Be $null;
		}
		
		It "Get-ManagementUriByCreatedBy-ShouldReturnListWithEntities" -Test {
			# Arrange
			$User = 'SYSTEM';
			
			# Act
			$result = Get-ManagementUri -svc $svc -CreatedBy $User;

			# Assert
		   	$result | Should Not Be $null;
			$result -is [Array] | Should Be $true;
			0 -lt $result.Count | Should Be $true;
		}
		
		It "Get-ManagementUriByModifiedBy-ShouldReturnListWithEntities" -Test {
			# Arrange
			$User = 'SYSTEM';
			
			# Act
			$result = Get-ManagementUri -svc $svc -ModifiedBy $User;

			# Assert
		   	$result | Should Not Be $null;
			$result -is [Array] | Should Be $true;
			0 -lt $result.Count | Should Be $true;
		} 
		
		It "Get-ManagementUriExpandManagementCredential-ShouldReturnManagementCredential" -Test {
			# Arrange
			. "$here\Get-ManagementCredential.ps1"
			Mock Get-ManagementCredential { return New-Object biz.dfch.CS.Appclusive.Api.Core.ManagementCredential };
			$showFirst = 1;
			
			# Act
			$resultFirst = Get-ManagementUri -svc $svc -First $showFirst;
			$result = Get-ManagementUri -svc $svc -Id $resultFirst.Id -ExpandManagementCredential;

			# Assert
		   	Assert-MockCalled Get-ManagementCredential -Exactly 1;
		   	$result | Should Not Be $null;
		   	$result.GetType().Name | Should Be 'ManagementCredential';
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

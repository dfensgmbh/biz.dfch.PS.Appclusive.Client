
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Get-KeyNameValue" -Tags "Get-KeyNameValue" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Format-ResultAs.ps1"

	Context "Get-KeyNameValue" {
        BeforeEach {
            $moduleName = 'biz.dfch.PS.Appclusive.Client';
            Remove-Module $moduleName -ErrorAction:SilentlyContinue;
            Import-Module $moduleName;

            $svc = Enter-ApcServer;
        }
	
		# Context wide constants
		# N/A
		
		It "Warmup" -Test {
			$true | Should Be $true;
		}

		It "Get-KeyNameValueListAvailable-ShouldReturnList" -Test {
			# Arrange
			# N/A
			
			# Act
			$result = Get-KeyNameValue -svc $svc -ListAvailable;

			# Assert
			$result | Should Not Be $null;
			$result -is [Array] | Should Be $true;
			0 -lt $result.Count | Should Be $true;
		}

		It "Get-KeyNameValueListAvailableSelectName-ShouldReturnListWithNamesOnly" -Test {
			# Arrange
			# N/A
			
			# Act
			$result = Get-KeyNameValue -svc $svc -ListAvailable -Select Name;

			# Assert
			$result | Should Not Be $null;
			$result -is [Array] | Should Be $true;
			0 -lt $result.Count | Should Be $true;
			$result[0].Name | Should Not Be $null;
			$result[0].Id | Should Be $null;
		}

		It "Get-KeyNameValue-ShouldReturnFirstEntity" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$result = Get-KeyNameValue -svc $svc -First $ShowFirst;

			# Assert
			$result | Should Not Be $null;
			$result -is [PSCustomObject] | Should Be $true;
		}
		
		It "Get-KeyNameValue-ShouldReturnFirstEntityByKeyNamePair" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$resultFirst = Get-KeyNameValue -svc $svc -First $ShowFirst;
			$result = Get-KeyNameValue -Key $resultFirst.Key -Name $resultFirst.Name -First $ShowFirst -svc $svc;
			
			# Assert
			$result | Should Not Be $null;
			$result.Key | Should Be $resultFirst.Key;
			$result.Name | Should Be $resultFirst.Name;
			$result -is [PSCustomObject] | Should Be $true;
		}
		
		It "Get-KeyNameValue-ShouldReturnFiveEntities" -Test {
			# Arrange
			$ShowFirst = 5;
			
			# Act
			$result = Get-KeyNameValue -svc $svc -First $ShowFirst;

			# Assert
			$result | Should Not Be $null;
			$ShowFirst -eq $result.Count | Should Be $true;
			$result[0] -is [PSCustomObject] | Should Be $true;
		}

		It "Get-KeyNameValueThatDoesNotExist-ShouldReturnNull" -Test {
			# Arrange
			$KeyNameValueName = 'KeyNameValue-that-does-not-exist';
			
			# Act
			$result = Get-KeyNameValue -svc $svc -Name $KeyNameValueName;

			# Assert
			$result | Should Be $null;
		}
		
		It "Get-KeyNameValueThatDoesNotExist-ShouldReturnDefaultValue" -Test {
			# Arrange
			$KeyNameValueName = 'KeyNameValue-that-does-not-exist';
			$DefaultValue = 'MyDefaultValue';
			
			# Act
			$result = Get-KeyNameValue -svc $svc -Name $KeyNameValueName -DefaultValue $DefaultValue;

			# Assert
			$result | Should Be $DefaultValue;
		}
		
		It "Get-KeyNameValue-ShouldReturnXML" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$result = Get-KeyNameValue -svc $svc -First $ShowFirst -As xml;

			# Assert
			$result | Should Not Be $null;
			$result.Substring(0,5) | Should Be '<?xml';
		}
		
		It "Get-KeyNameValue-ShouldReturnJSON" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$result = Get-KeyNameValue -svc $svc -First $ShowFirst -As json;

			# Assert
			$result | Should Not Be $null;
			$result.Substring(0, 1) | Should Be '{';
			$result.Substring($result.Length -1, 1) | Should Be '}';
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

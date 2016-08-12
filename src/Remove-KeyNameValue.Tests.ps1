
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Remove-KeyNameValue" -Tags "Remove-KeyNameValue" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\New-KeyNameValue.ps1"
	. "$here\Set-KeyNameValue.ps1"
	. "$here\Format-ResultAs.ps1"
	
    BeforeEach {
        $moduleName = 'biz.dfch.PS.Appclusive.Client';
        Remove-Module $moduleName -ErrorAction:SilentlyContinue;
        Import-Module $moduleName;

        $svc = Enter-ApcServer;
    }
 
	Context "Remove-KeyNameValue" {
	
		# Context wide constants
		# N/A

		It "Remove-KeyNameValueSingleEntity-ShouldReturnRemovedEntity" -Test {
			# Arrange
			$Key = "Key-{0}" -f [guid]::NewGuid().ToString();
			$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
			$Value = "Value-{0}" -f [guid]::NewGuid().ToString();
			$resultCreate = New-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value;
			$resultCreate | Should Not Be $null;
			$resultCreate.Id | Should Not Be 0;
			$resultCreate.Key | Should Be $Key;
			$resultCreate.Name | Should Be $Name;
			$resultCreate.Value | Should Be $Value;
			
			# Act
			$result = Remove-KeyNameValue -svc $svc -Confirm:$false -Key $Key -Name $Name -Value $Value;

			# Assert
			$result | Should Not Be $null;
			$result.Key | Should Be $Key;
			$result.Name | Should Be $Name;
			$result.Value | Should Be $Value;
		}

		It "Remove-KeyNameValueMultipleEntities-ShouldReturnRemovedEntity" -Test {
			# Arrange
			$Key = "Key-{0}" -f [guid]::NewGuid().ToString();
			$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
			$Value1 = "Value-{0}" -f [guid]::NewGuid().ToString();
			$resultCreate1 = New-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value1;
			$resultCreate1 | Should Not Be $null;
			$Value2 = "Value-{0}" -f [guid]::NewGuid().ToString();
			$resultCreate2 = New-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value2;
			$resultCreate2 | Should Not Be $null;
			
			# Act
			$result = Remove-KeyNameValue -svc $svc -Confirm:$false -Key $Key -Name $Name;

			# Assert
			$result | Should Not Be $null;
			$result.Count | Should Be 2;
			$result[0].Key | Should Be $Key;
			$result[0].Name | Should Be $Name;
			$result[0].Value | Should Be $Value1;
			$result[1].Key | Should Be $Key;
			$result[1].Name | Should Be $Name;
			$result[1].Value | Should Be $Value2;
		}

		It "Remove-KeyNameValueThatDoesNotExist-ShouldReturnNewEntity" -Test {
			# Arrange
			$Key = "Key-ThatDoesNotExist-{0}" -f [guid]::NewGuid().ToString();
			$Name = "Name-ThatDoesNotExist-{0}" -f [guid]::NewGuid().ToString();
			$Value = "Value-ThatDoesNotExist-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			{ $result = Remove-KeyNameValue -svc $svc -Confirm:$false -Key $Key -Name $Name -Value $Value; } | Should Throw 'Assertion failed: ($keyNameValueExists)';

			# Assert
			$result | Should Be $null;
		}

		# what is the purpose of this test?
		It "Remove-KeyNameValueWithDuplicate-ShouldReturnNull" -Test {
			# Arrange
			$Key = "Key-{0}" -f [guid]::NewGuid().ToString();
			$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
			$Value = "Value-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			{ $result1 = Remove-KeyNameValue -svc $svc -Confirm:$false -Key $Key -Name $Name -Value $Value; } | Should Throw 'Assertion failed: ($keyNameValueExists)';
			{ $result = Remove-KeyNameValue -svc $svc -Confirm:$false -Key $Key -Name $Name -Value $Value; } | Should Throw 'Assertion failed: ($keyNameValueExists)';

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
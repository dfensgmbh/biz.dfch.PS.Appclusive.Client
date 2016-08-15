
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "New-KeyNameValue" -Tags "New-KeyNameValue" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Set-KeyNameValue.ps1"
	. "$here\Remove-KeyNameValue.ps1"
	. "$here\Format-ResultAs.ps1"
	
    BeforeEach {
        $moduleName = 'biz.dfch.PS.Appclusive.Client';
        Remove-Module $moduleName -ErrorAction:SilentlyContinue;
        Import-Module $moduleName;

        $svc = Enter-ApcServer;
    }

	Context "New-KeyNameValue" {
	
		# Context wide constants
		# N/A

		It "New-KeyNameValue-ShouldReturnNewEntity" -Test {
			# Arrange
			$Key = "Key-{0}" -f [guid]::NewGuid().ToString();
			$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
			$Value = "Value-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			$result = New-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value;

			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Key | Should Be $Key;
			$result.Name | Should Be $Name;
			$result.Value | Should Be $Value;
			
			Remove-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value -Confirm:$false;
		}

		It "New-KeyNameValueWithDescription-ShouldReturnNewEntity" -Test {
			# Arrange
			$Key = "Key-{0}" -f [guid]::NewGuid().ToString();
			$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
			$Value = "Value-{0}" -f [guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			$result = New-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value -Description $Description;

			# Assert
			$result | Should Not Be $null;
			$result.Tid | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Key | Should Be $Key;
			$result.Name | Should Be $Name;
			$result.Value | Should Be $Value;
			$result.Description | Should Be $Description;
			
			Remove-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value -Confirm:$false;
		}

		It "New-KeyNameValueWithDuplicate-ShouldReturnNull" -Test {
			# Arrange
			$Key = "Key-{0}" -f [guid]::NewGuid().ToString();
			$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
			$Value = "Value-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			$result1 = New-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value;
			$result = New-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value;

			# Assert
			$result | Should Be $null;
			
			Remove-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value -Confirm:$false;
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

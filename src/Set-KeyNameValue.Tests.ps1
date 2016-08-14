
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Set-KeyNameValue" -Tags "Set-KeyNameValue" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\New-KeyNameValue.ps1"
	. "$here\Remove-KeyNameValue.ps1"
	. "$here\Format-ResultAs.ps1"
	
    BeforeEach {
        $moduleName = 'biz.dfch.PS.Appclusive.Client';
        Remove-Module $moduleName -ErrorAction:SilentlyContinue;
        Import-Module $moduleName;

        $svc = Enter-ApcServer;
    }

	Context "Set-KeyNameValue" {
	
		# Context wide constants
		# N/A

		It "Set-KeyNameValueWithCreateIfNotExist-ShouldReturnNewEntity" -Test {
			# Arrange
			$Key = "Key-{0}" -f [guid]::NewGuid().ToString();
			$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
			$Value = "Value-{0}" -f [guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			$result = Set-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value -Description $Description -CreateIfNotExist;

			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Key | Should Be $Key;
			$result.Name | Should Be $Name;
			$result.Value | Should Be $Value;
			$result.Description | Should Be $Description;
			
			Remove-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value -Confirm:$false;
		}

		It "Set-KeyNameValueWithoutCreateIfNotExist-ShouldReturnNull" -Test {
			# Arrange
			$Key = "Key-{0}" -f [guid]::NewGuid().ToString();
			$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
			$Value = "Value-{0}" -f [guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			$result = Set-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value -CreateIfNotExist:$false;

			# Assert
			$result | Should Be $null;
		}

		It "Set-KeyNameValueWithNewValue-ShouldReturnUpdatedEntity" -Test {
			# Arrange
			$Key = "Key-{0}" -f [guid]::NewGuid().ToString();
			$NewKey = "NewKey-{0}" -f [guid]::NewGuid().ToString();
			$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
			$NewName = "NewName-{0}" -f [guid]::NewGuid().ToString();
			$Value = "Value-{0}" -f [guid]::NewGuid().ToString();
			$NewValue = "NewValue-{0}" -f [guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
			
			$resultCreated = New-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value -Description $Description;
			$resultCreated | Should Not Be $null;
			
			# Act
			$result = Set-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value -NewValue $NewValue -CreateIfNotExist:$false;

			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Key | Should Be $Key;
			$result.Name | Should Be $Name;
			$result.Value | Should Be $NewValue;
			$result.Description | Should Be $Description;

			Remove-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $NewValue -Confirm:$false;
		}

		It "Set-KeyNameValueWithNewName-ShouldReturnUpdatedEntity" -Test {
			# Arrange
			$Key = "Key-{0}" -f [guid]::NewGuid().ToString();
			$NewKey = "NewKey-{0}" -f [guid]::NewGuid().ToString();
			$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
			$NewName = "NewName-{0}" -f [guid]::NewGuid().ToString();
			$Value = "Value-{0}" -f [guid]::NewGuid().ToString();
			$NewValue = "NewValue-{0}" -f [guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
			
			$resultCreated = New-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value -Description $Description;
			$resultCreated | Should Not Be $null;
			
			# Act
			$result = Set-KeyNameValue -svc $svc -Key $Key -Name $Name -NewName $NewName -Value $Value -CreateIfNotExist:$false;

			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Key | Should Be $Key;
			$result.Name | Should Be $NewName;
			$result.Value | Should Be $Value;
			$result.Description | Should Be $Description;

			Remove-KeyNameValue -svc $svc -Key $Key -Name $NewName -Value $Value -Confirm:$false;
		}

		It "Set-KeyNameValueWithNewKey-ShouldReturnUpdatedEntity" -Test {
			# Arrange
			$Key = "Key-{0}" -f [guid]::NewGuid().ToString();
			$NewKey = "NewKey-{0}" -f [guid]::NewGuid().ToString();
			$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
			$NewName = "NewName-{0}" -f [guid]::NewGuid().ToString();
			$Value = "Value-{0}" -f [guid]::NewGuid().ToString();
			$NewValue = "NewValue-{0}" -f [guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
			
			$resultCreated = New-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value -Description $Description;
			$resultCreated | Should Not Be $null;
			
			# Act
			$result = Set-KeyNameValue -svc $svc -Key $Key -NewKey $NewKey -Name $Name -Value $Value -CreateIfNotExist:$false;

			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Key | Should Be $NewKey;
			$result.Name | Should Be $Name;
			$result.Value | Should Be $Value;
			$result.Description | Should Be $Description;

			Remove-KeyNameValue -svc $svc -Key $NewKey -Name $Name -Value $Value -Confirm:$false;
		}

		It "Set-KeyNameValueWithNewKeyNameValue-ShouldReturnUpdatedEntity" -Test {
			# Arrange
			$Key = "Key-{0}" -f [guid]::NewGuid().ToString();
			$NewKey = "NewKey-{0}" -f [guid]::NewGuid().ToString();
			$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
			$NewName = "NewName-{0}" -f [guid]::NewGuid().ToString();
			$Value = "Value-{0}" -f [guid]::NewGuid().ToString();
			$NewValue = "NewValue-{0}" -f [guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
			
			$resultCreated = New-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value -Description $Description;
			$resultCreated | Should Not Be $null;
			
			# Act
			$result = Set-KeyNameValue -svc $svc -Key $Key -NewKey $NewKey -Name $Name -NewName $NewName -Value $Value -NewValue $NewValue -CreateIfNotExist:$false;

			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Key | Should Be $NewKey;
			$result.Name | Should Be $NewName;
			$result.Value | Should Be $NewValue;
			$result.Description | Should Be $Description;
			
			Remove-KeyNameValue -svc $svc -Key $NewKey -Name $NewName -Value $NewValue -Confirm:$false;
		}

		It "Set-KeyNameValueWithNewKeyNameValueDescription-ShouldReturnUpdatedEntity" -Test {
			# Arrange
			$Key = "Key-{0}" -f [guid]::NewGuid().ToString();
			$NewKey = "NewKey-{0}" -f [guid]::NewGuid().ToString();
			$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
			$NewName = "NewName-{0}" -f [guid]::NewGuid().ToString();
			$Value = "Value-{0}" -f [guid]::NewGuid().ToString();
			$NewValue = "NewValue-{0}" -f [guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
			$NewDescription = "NewDescription-{0}" -f [guid]::NewGuid().ToString();
			
			$resultCreated = New-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value -Description $Description;
			$resultCreated | Should Not Be $null;
			
			# Act
			$result = Set-KeyNameValue -svc $svc -Key $Key -NewKey $NewKey -Name $Name -NewName $NewName -Value $Value -NewValue $NewValue -CreateIfNotExist:$false -Description $NewDescription;

			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Key | Should Be $NewKey;
			$result.Name | Should Be $NewName;
			$result.Value | Should Be $NewValue;
			$result.Description | Should Be $NewDescription;

			Remove-KeyNameValue -svc $svc -Key $NewKey -Name $NewName -Value $NewValue -Confirm:$false;
			}

		It "Set-KeyNameValueWithDuplicate-ShouldReturnUpdatedEntity" -Test {
			# Arrange
			$Key = "Key-{0}" -f [guid]::NewGuid().ToString();
			$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
			$Value = "Value-{0}" -f [guid]::NewGuid().ToString();
			$NewValue = "NewValue-{0}" -f [guid]::NewGuid().ToString();
			
			$resultCreated1 = New-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value;
			$resultCreated2 = New-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $NewValue;
			
			# Act
			$result = Set-KeyNameValue -svc $svc -Key $Key -Name $Name -Value $NewValue -NewValue $Value;

			# Assert
			$result.Value | Should Be $Value;
			
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

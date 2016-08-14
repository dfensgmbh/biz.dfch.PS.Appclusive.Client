
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "New-User" -Tags "New-User" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Set-User.ps1"
	. "$here\Get-Tenant.ps1"
	. "$here\Format-ResultAs.ps1"
	
    BeforeEach {
        $moduleName = 'biz.dfch.PS.Appclusive.Client';
        Remove-Module $moduleName -ErrorAction:SilentlyContinue;
        Import-Module $moduleName;

        $svc = Enter-ApcServer;
    }

	Context "New-User" {
	
		# Context wide constants
		# N/A

		It "New-UserDuplicate-ShouldReturnNull" -Test {
			# Arrange
			$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
			$Mail = "Mail-{0}@appclusive.net" -f [guid]::NewGuid().ToString();
			$ExternalId = "{0}" -f [guid]::NewGuid();
			$result1 = New-User -svc $svc -Name $Name -Mail $Mail -ExternalId $ExternalId -ExternalType Internal;
			$result1 | Should Not Be $null;
			
			# Act
			{ $result = New-User -svc $svc -Name $Name -Mail $Mail -ExternalId $ExternalId; } | Should Throw 'Precondition failed'
			{ $result = New-User -svc $svc -Name $Name -Mail $Mail -ExternalId $ExternalId; } | Should Throw 'Entity does already exist'

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

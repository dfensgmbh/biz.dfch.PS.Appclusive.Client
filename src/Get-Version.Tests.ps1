
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "Fatal. Cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe "Get-Version" -Tags "Get-Version" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Format-ResultAs.ps1"
	
    BeforeEach {
        $moduleName = 'biz.dfch.PS.Appclusive.Client';
        Remove-Module $moduleName -ErrorAction:SilentlyContinue;
        Import-Module $moduleName;

        $svc = Enter-ApcServer;
    }

	Context "Get-Version" {
	
		# Context wide constants
		# N/A
		
		It "Warmup" -Test {
			$true | Should Be $true;
		}

		It "Get-VersionAll-ShouldSucceed" -Test {
			# Arrange
			# N/A
			
			# Act
			$result = Get-Version -svc $svc -All;

			# Assert
			$result | Should Not Be $null;
			$result | Should BeOfType [hashtable];
			4 -le $result.Count | Should Be $true;
		}

		It "Get-VersionModule-ShouldSucceed" -Test {
			# Arrange
			# N/A
			
			# Act
			$result = Get-Version -svc $svc -Module;

			# Assert
			$result | Should Not Be $null;
			$result | Should BeOfType [Version]
		}

		It "Get-VersionPublic-ShouldSucceed" -Test {
			# Arrange
			# N/A
			
			# Act
			$result = Get-Version -svc $svc -Public;

			# Assert
			$result | Should Not Be $null;
			$result | Should BeOfType [Version]
		}

		It "Get-VersionApi-ShouldSucceed" -Test {
			# Arrange
			# N/A
			
			# Act
			$result = Get-Version -svc $svc -Api;

			# Assert
			$result | Should Not Be $null;
			$result | Should BeOfType [Version]
		}

		It "Get-VersionServer-ShouldSucceed" -Test {
			# Arrange
			# N/A
			
			# Act
			$result = Get-Version -svc $svc -Server;

			# Assert
			$result | Should Not Be $null;
			$result | Should BeOfType [Hashtable]
		}
	}
}

#
# Copyright 2015-2016 d-fens GmbH
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


$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Test-Status" -Tags "Test-Status" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Get-ModuleVariable.ps1"
	. "$here\Format-ResultAs.ps1"
	
	Context "Test-Status" {
	
		# Context wide constants
		$biz_dfch_PS_Appclusive_Client = @{ };
		Mock Get-ModuleVariable { return $biz_dfch_PS_Appclusive_Client; }
		
		
		BeforeEach {
			$error.Clear();
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;
			
			$biz_dfch_PS_Appclusive_Client.DataContext = New-Object System.Collections.Stack;
		}
		
		AfterEach {
			if(0 -ne $error.Count)
			{
				Write-Warning ($error | Out-String);
			}
		}
		
		It "Warmup" -Test {
			$true | Should Be $true;
		}
		
		It "Test-StatusAnonymousSucceeds" -Test {
			# Arrange
			$svc = Enter-ApcServer;

			# Act
			$result = Test-Status -svc $svc;
			
			# Assert
			$result | Should Be $true;
		}
		
		It "Test-StatusAuthenticatedSucceeds" -Test {
			# Arrange
			$svc = Enter-ApcServer;

			# Act
			$result = Test-Status -Authenticate -svc $svc;
			
			# Assert
			$result | Should Be $true;
		}

		It "Test-StatusEchoSucceeds" -Test {
			# Arrange
			$svc = Enter-ApcServer;
			$InputObject = 'tralala';

			# Act
			$result = Test-Status $InputObject -svc $svc;
			
			# Assert
			$result | Should Not Be $null;
			$result | Should Be $InputObject
		}

		It "Test-StatusEchoWithEmptyInputFails" -Test {
			# Arrange
			$svc = Enter-ApcServer;
			$InputObject = '';

			# Act, Assert
			{ Test-Status $InputObject -svc $svc; } | Should ThrowException ParameterBindingValidationException;
		}

		It "Test-StatusEchoWithTooLongInputFails" -Test {
			# Arrange
			$svc = Enter-ApcServer;
			$InputObject = '1234567890123456789012345678901234567890';

			# Act, Assert
			{ Test-Status $InputObject -svc $svc; } | Should ThrowException ParameterBindingValidationException;
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

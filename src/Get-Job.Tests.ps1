#Requires -Modules @{ ModuleName = 'biz.dfch.PS.Pester.Assertions'; ModuleVersion = '1.1.1.20160710' }

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "Unrepresentative, because no entities existing.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe "Get-Job"  -Tags "Get-Job" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Get-User.ps1"
	. "$here\Format-ResultAs.ps1"
	
	Context "Get-Job" {
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

		It "Get-JobListAvailable-ShouldReturnList" -Test {
			# Arrange
			# N/A
			
			# Act
			$result = Get-Job -svc $svc -ListAvailable;
			if ( $result.Count -eq 0 )
			{
				Stop-Pester
			}

			# Assert
			$result | Should Not Be $null;
			$result -is [Array] | Should Be $true;
			0 -lt $result.Count | Should Be $true;
		}

		It "Get-JobListAvailableSelectName-ShouldReturnListWithNamesOnly" -Test {
			# Arrange
			# N/A
			
			# Act
			$result = Get-Job -svc $svc -ListAvailable -Select Name;

			# Assert
			$result | Should Not Be $null;
			$result -is [Array] | Should Be $true;
			0 -lt $result.Count | Should Be $true;
			$result[0].Name | Should Not Be $null;
			$result[0].Id | Should Be $null;
		}

		It "Get-Job-ShouldReturnFirstEntity" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$result = Get-Job -svc $svc -First $ShowFirst;

			# Assert
			$result | Should Not Be $null;
			$result -is [biz.dfch.CS.Appclusive.Api.Core.Job] | Should Be $true;
		}
		
		It "Get-Job-ShouldReturnFirstEntityById" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$resultFirst = Get-Job -svc $svc -First $ShowFirst;
			$Id = $resultFirst.Id;
			$result = Get-Job -Id $Id -svc $svc;

			# Assert
			$result | Should Not Be $null;
			$result | Should Be $resultFirst;
			$result -is [biz.dfch.CS.Appclusive.Api.Core.Job] | Should Be $true;
		}
		
		It "Get-Job-ShouldReturnFiveEntities" -Test {
			# Arrange
			$ShowFirst = 5;
			
			# Act
			$result = Get-Job -svc $svc -First $ShowFirst;

			# Assert
			$result | Should Not Be $null;
			$ShowFirst -eq $result.Count | Should Be $true;
			$result[0] -is [biz.dfch.CS.Appclusive.Api.Core.Job] | Should Be $true;
		}

		It "Get-JobThatDoesNotExist-ShouldReturnNull" -Test {
			# Arrange
			$JobName = 'Job-that-does-not-exist';
			
			# Act
			$result = Get-Job -svc $svc -Name $JobName;

			# Assert
			$result | Should Be $null;
		}
		
		It "Get-JobThatDoesNotExist-ShouldReturnDefaultValue" -Test {
			# Arrange
			$JobName = 'Job-that-does-not-exist';
			$DefaultValue = 'MyDefaultValue';
			
			# Act
			$result = Get-Job -svc $svc -Name $JobName -DefaultValue $DefaultValue;

			# Assert
			$result | Should Be $DefaultValue;
		}
		
		It "Get-Job-ShouldReturnXML" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$result = Get-Job -svc $svc -First $ShowFirst -As xml;

			# Assert
			$result | Should Not Be $null;
			$result.Substring(0,5) | Should Be '<?xml';
		}
		
		It "Get-Job-ShouldReturnJSON" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$result = Get-Job -svc $svc -First $ShowFirst -As json;

			# Assert
			$result | Should Not Be $null;
			$result.Substring(0, 1) | Should Be '{';
			$result.Substring($result.Length -1, 1) | Should Be '}';
		}
		
		It "Get-Job-WithInvalidId-ShouldReturnException" -Test {
			# Act
			try 
			{
				$result = Get-Job -Id 'myJob';
				'throw exception' | Should Be $true;
			} 
			catch
			{
				# Assert
			   	$result | Should Be $null;
			}
		}
		
		It "Get-JobByCreatedByThatDoesNotExist-ShouldThrowContractException" -Test {
			# Arrange
			$User = 'User-that-does-not-exist';
			
			# Act
			{ Get-Job -svc $svc -CreatedBy $User; } | Should ThrowErrorId "Contract";

			# Assert
		   	# N/A
		}
		
		It "Get-JobByCreatedBy-ShouldReturnListWithEntities" -Test {
			# Arrange
			$User = 'SYSTEM';
			
			# Act
			$result = Get-Job -svc $svc -CreatedBy $User;

			# Assert
		   	$result | Should Not Be $null;
			0 -lt $result.Count | Should Be $true;
		}
		
		It "Get-JobByModifiedBy-ShouldReturnListWithEntities" -Test {
			# Arrange
			$User = 'SYSTEM';
			
			# Act
			$result = Get-Job -svc $svc -ModifiedBy $User;

			# Assert
		   	$result | Should Not Be $null;
			0 -lt $result.Count | Should Be $true;
		}
		
		It "Get-JobExpandNode-ShouldReturnNode" -Test {
			# Arrange
			. "$here\Get-Node.ps1"
			Mock Get-Node { return New-Object biz.dfch.CS.Appclusive.Api.Core.Node };
			$ShowFirst = 1;
			
			# Act
			$resultFirst = Get-Job -svc $svc -First $ShowFirst;
			$result = Get-Job -svc $svc -Id $resultFirst.Id -ExpandNode;

			# Assert
		   	Assert-MockCalled Get-Node -Exactly 1;
		   	$result | Should Not Be $null;
		   	$result.GetType().Name | Should Be 'Node';
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


$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "Unrepresentative, because no entities exists.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe "Invoke-EntityAction" -Tags "Invoke-EntityAction" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Get-Node.ps1"
	. "$here\Format-ResultAs.ps1"
	
    BeforeEach {
        $moduleName = 'biz.dfch.PS.Appclusive.Client';
        Remove-Module $moduleName -ErrorAction:SilentlyContinue;
        Import-Module $moduleName;

        $svc = Enter-ApcServer;
	
		# DFTODO - Create node before every test and remove it after test
		$NodeEntity = Get-Node -First 1 -svc $svc;
		$EntityId = $NodeEntity.Id;
	
	    if ( !$EntityId ) { Stop-Pester; }
    }

	Context "Invoke-EntityAction" {
	
		# Context wide constants
		# N/A

		It "Invoke-EntityActionStatus-ShouldReturnSingle" -Test {
			# Arrange
			$EntitySetName = 'Nodes';
			$EntityActionName = 'Status';
			$ExpectedResult = 'single';
			
			# Act
			$result = Invoke-EntityAction -EntityId $EntityId -EntitySetName $EntitySetName -EntityActionName $EntityActionName -ExpectedResult $ExpectedResult -svc $svc;

			# Assert
			$result | Should Not Be $null;
		}
		
		It "Invoke-EntityActionAvailableActions-ShouldReturnList" -Test {
			# Arrange
			$EntitySetName = 'Nodes';
			$EntityActionName = 'AvailableActions';
			$ExpectedResult = 'list';
			
			# Act			
			$result = Invoke-EntityAction -EntityId $EntityId -EntitySetName $EntitySetName -EntityActionName $EntityActionName -ExpectedResult $ExpectedResult -svc $svc;

			# Assert
			$result | Should Not Be $null;
		}

		It "Invoke-UnknowEntityAction-ShouldThrow" -Test {
			# Arrange
			$EntitySetName = 'Nodes';
			$EntityActionName = 'NotExistingAction';
			$ExpectedResult = 'single';
			
			# Act / Assert
			{ Invoke-EntityAction -EntityId $EntityId -EntitySetName $EntitySetName -EntityActionName $EntityActionName -ExpectedResult $ExpectedResult -svc $svc} | Should Throw

			# Assert
			#N/A
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

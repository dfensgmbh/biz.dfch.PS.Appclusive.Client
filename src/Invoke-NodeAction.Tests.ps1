
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "Unrepresentative, because no entities exists.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe "Invoke-NodeAction" -Tags "Invoke-NodeAction" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Format-ResultAs.ps1"
	. "$here\Set-Node.ps1"
	. "$here\Get-Node.ps1"
	. "$here\Remove-Node.ps1"
	. "$here\Get-EntityKind.ps1"
	. "$here\Get-Job.ps1"
	
    BeforeEach {
        $moduleName = 'biz.dfch.PS.Appclusive.Client';
        Remove-Module $moduleName -ErrorAction:SilentlyContinue;
        Import-Module $moduleName;
        
	    $svc = Enter-ApcServer;
	
		# Create new node for tests
	    $NodeName = "Name-{0}" -f [guid]::NewGuid().ToString();
        $ekId = [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::Node.value__
        $NodeEntity = Set-Node -Name $NodeName -EntityKindId $ekId -CreateIfNotExist -svc $svc;
		
		# Finish initial state transition of newly created node
		$query = "RefId eq '{0}' and EntityKindId eq {1}" -f $node.Id, $ekId;
		$nodeJob = $svc.Core.Jobs.AddQueryOption('$filter', $query) | Select;
		$jobResult = @{Version = "1"; Message = "Arbitrary message"; Succeeded = $true};
		$null = Invoke-ApcEntityAction -InputObject $nodeJob -EntityActionName "JobResult" -InputParameters $jobResult;
		
	    $EntityId = $NodeEntity.Id;
	
	    if ( !$EntityId ) { Stop-Pester; }
    }
	
	AfterEach {
		$svc = Enter-ApcServer;
		
		$r = Remove-Node -Id $EntityId -Confirm:$false -svc $svc;
	}

	Context "Invoke-NodeAction" {
	
		# Context wide constants
		# N/A

		It "Invoke-NodeAction-ShouldReturnStatus" -Test {
			# Arrange
			$InputName = (Get-Node -Id $EntityId -ExpandAvailableActions -svc $svc)[0];
			
			# Act
			Invoke-NodeAction -EntityId $EntityId -InputName $InputName -svc $svc;
			$result = Get-Node -Id $EntityId -svc $svc -ExpandStatus;

			# Assert
			$result.Status | Should Be $InputName;
		}

		It "Invoke-UnkownNodeAction-ShouldThrow" -Test {
			# Arrange
			$InputName = "NotExistingAction";
			
			# Act			
			Invoke-NodeAction -EntityId $EntityId -InputName $InputName -svc $svc;
			$result = Get-Node -Id $EntityId -svc $svc -ExpandStatus;

			# Assert
			$result.Status | Should Not Be $InputName;
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

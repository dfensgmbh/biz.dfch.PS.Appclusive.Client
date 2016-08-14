
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "New-Node" -Tags "New-Node" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Get-Job.ps1"
	. "$here\Get-Node.ps1"
	. "$here\Set-Node.ps1"
	. "$here\Get-EntityKind.ps1"
	. "$here\Format-ResultAs.ps1"
	
    BeforeEach {
        $moduleName = 'biz.dfch.PS.Appclusive.Client';
        Remove-Module $moduleName -ErrorAction:SilentlyContinue;
        Import-Module $moduleName;

        $svc = Enter-ApcServer;
    }

	Context "New-Node" {
	
		# Context wide constants
		# N/A

		It "New-Node-ShouldCreateAndReturnNewEntity" -Test {
			# Arrange
			$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			$result = New-Node -svc $svc -Name $Name -ParentId 1 -EntityKindId 1;

			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be $Name;
			
			# Cleanup
			Remove-ApcEntity -svc $svc -Id $result.Id -EntitySetName 'Nodes' -Force -Confirm:$false;
			
			$query = "RefId eq '{0}' and EntityKindId eq 1" -f $result.Id;
			$nodeJob = $svc.Core.Jobs.AddQueryOption('$filter', $query) | Select;
			Remove-ApcEntity -svc $svc -Id $nodeJob.Id -EntitySetName 'Jobs' -Force -Confirm:$false;
		}

		It "New-NodeDuplicate-ShouldThrow" -Test {
			# Arrange
			$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
			$node = New-Node -svc $svc -Name $Name -ParentId 1 -EntityKindId 1;
			$node | Should Not Be $null;
			
			# Act
			{ $result = New-Node -svc $svc -Name $Name -ParentId 1 -EntityKindId 1; } | Should Throw 'Entity does already exist';

			# Assert
			$result | Should Be $null;
			
			# Cleanup
			Remove-ApcEntity -svc $svc -Id $node.Id -EntitySetName 'Nodes' -Force -Confirm:$false;
			
			$query = "RefId eq '{0}' and EntityKindId eq 1" -f $node.Id;
			$nodeJob = $svc.Core.Jobs.AddQueryOption('$filter', $query) | Select;
			Remove-ApcEntity -svc $svc -Id $nodeJob.Id -EntitySetName 'Jobs' -Force -Confirm:$false;
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

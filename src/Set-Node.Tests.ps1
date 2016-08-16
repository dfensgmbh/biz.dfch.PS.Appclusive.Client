
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Set-Node" -Tags "Set-Node" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Get-Job.ps1"
	. "$here\Get-Node.ps1"
	. "$here\Get-EntityKind.ps1"
	. "$here\Remove-Entity.ps1"
	. "$here\Format-ResultAs.ps1"
	
    BeforeEach {
        $moduleName = 'biz.dfch.PS.Appclusive.Client';
        Remove-Module $moduleName -ErrorAction:SilentlyContinue;
        Import-Module $moduleName;

        $svc = Enter-ApcServer;
    }

	Context "Set-Node" {
	
		# Context wide constants
		# N/A

		It "Set-Node-ShouldReturnNewEntity" -Test {
			# Arrange
			$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			$result = Set-Node -svc $svc -Name $Name -EntityKindId 1 -CreateIfNotExist;
			
			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be $Name;
			
			# Cleanup
			$query = "RefId eq '{0}' and EntityKindId eq {1}" -f $result.Id, [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::Node.value__;
			$nodeJob = $svc.Core.Jobs.AddQueryOption('$filter', $query) | Select;
			Remove-ApcEntity -svc $svc -Id $nodeJob.Id -EntitySetName 'Jobs' -Force -Confirm:$false;
			Remove-ApcEntity -svc $svc -Id $result.Id -EntitySetName 'Nodes' -Force -Confirm:$false;
		}

		It "Set-NodeWithNewDescription-ShouldReturnUpdatedEntity" -Test {
			
			# Arrange
			$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
			$NewDescription = "NewDescription-{0}" -f [guid]::NewGuid().ToString();
			$node = Set-Node -svc $svc -Name $Name -Description $Description -EntityKindId 1 -CreateIfNotExist;
			$node | Should Not Be $null;
			
			$svc = Enter-Apc;
			
			# Act
			$result = Set-Node -svc $svc -Name $Name -Description $NewDescription -EntityKindId 1;

			# Assert
			$result | Should Not Be $null;
			$result.Description | Should Be $NewDescription;
			
			# Cleanup
			$query = "RefId eq '{0}' and EntityKindId eq 1" -f $result.Id;
			$nodeJob = $svc.Core.Jobs.AddQueryOption('$filter', $query) | Select;
			Remove-ApcEntity -svc $svc -Id $nodeJob.Id -EntitySetName 'Jobs' -Force -Confirm:$false;
			Remove-ApcEntity -svc $svc -Id $result.Id -EntitySetName 'Nodes' -Force -Confirm:$false;
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
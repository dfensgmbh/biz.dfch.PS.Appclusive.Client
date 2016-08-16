
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Remove-Node" -Tags "Remove-Node" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Get-Job.ps1"
	. "$here\Get-Node.ps1"
	. "$here\New-Node.ps1"
	. "$here\Set-Node.ps1"
	. "$here\Get-EntityKind.ps1"
	. "$here\Format-ResultAs.ps1"
	
    BeforeEach {
        $moduleName = 'biz.dfch.PS.Appclusive.Client';
        Remove-Module $moduleName -ErrorAction:SilentlyContinue;
        Import-Module $moduleName;

        $svc = Enter-ApcServer;
    }
 
	Context "Remove-Node" {
	
		# Context wide constants
		# N/A

		It "Remove-Node-ShouldReturnDeletedEntity" -Test {
			# Arrange
			$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
			$creationResult = New-Node -svc $svc -Name $Name -ParentId 1 -EntityKindId 1;

			$creationResult | Should Not Be $null;
			$creationResult.Name | Should Be $Name;
						
			# Get and Delete Job
			$query = "RefId eq '{0}' and EntityKindId eq {1}" -f $creationResult.Id, [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::Node.value__;
			$nodeJob = $svc.Core.Jobs.AddQueryOption('$filter', $query) | Select;
			Remove-ApcEntity -svc $svc -Id $nodeJob.Id -EntitySetName 'Jobs' -Force -Confirm:$false;
			
			# Act
			$deletionResult = Remove-ApcEntity -svc $svc -Id $creationResult.Id -EntitySetName 'Nodes' -Force -Confirm:$false;
			
			# Assert
			$deletionResult | Should Not Be $null;
			$deletionResult.StatusCode | Should Be 204;
			
			# Cleanup
			
		}

		It "Remove-NodeThatDoesNotExist-ShouldReturnNull" -Test {
			# Arrange
			$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			{ $result = Remove-Node -svc $svc -Name $Name; } | Should Throw 'Assertion failed: ($objectFoundToBeRemoved)';

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

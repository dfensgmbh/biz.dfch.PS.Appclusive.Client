
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Remove-Interface" -Tags "Remove-Interface" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Set-Interface.ps1"
	. "$here\Invoke-EntityAction.ps1"
	. "$here\Get-Job.ps1"
	. "$here\Get-Interface.ps1"
	. "$here\Remove-Interface.ps1"
	. "$here\Remove-Entity.ps1"
	. "$here\Format-ResultAs.ps1"
	
    BeforeEach {
        $moduleName = 'biz.dfch.PS.Appclusive.Client';
        Remove-Module $moduleName -ErrorAction:SilentlyContinue;
        Import-Module $moduleName;

        $svc = Enter-ApcServer;
    }

	Context "Remove-Interface" {
	
        $interfacePrefix = "RemoveInterface";
	
        AfterAll {
            $moduleName = 'biz.dfch.PS.Appclusive.Client';
            Remove-Module $moduleName -ErrorAction:SilentlyContinue;
            Import-Module $moduleName;

            $svc = Enter-ApcServer;

            $interfaces = $svc.Core.Interfaces.AddQueryOption('$filter', "startswith(Name, 'RemoveInterface')") | Select;
         
            foreach ($interface in $interfaces)
            {
                Remove-Entity -svc $svc -Id $interface.Id -EntitySetName "Interfaces" -Confirm:$false;
            }
        }

		It "Remove-InterfaceByName-ShouldReturnRemovedEntity" -Test {
			# Arrange
			$Name = "{0}-Name-{1}" -f $interfacePrefix,[guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();

            $entityKindId = [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::Interface.value__

			$result = Set-Interface -svc $svc -Name $Name -Description $Description -CreateIfNotExist;

			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Name | Should Be $Name;
			$result.Description | Should Be $Description;

            $filter = "RefId eq '{0}' and EntityKindId eq {1}" -f $result.Id, $entityKindId;
            $job = $svc.Core.Jobs.AddQueryOption('$filter', $filter) | Select;
            
            $jobResult = @{Version = "1"; Message = "PESTER-TEST"; Succeeded = $true};
            $null = Invoke-EntityAction -svc $svc -InputObject $job -EntityActionName "JobResult" -InputParameters $jobResult;
            
            $entity = Get-Interface -svc $svc -Id $result.Id;

            $entity | Should Not Be $null;
            $entity.Id | Should Be $result.Id;
            $entity.Name | Should Be $result.Name;
            $entity.Description | Should be $entity.Description;

            # Act
            Remove-Interface -svc $svc -Name $result.Name;

            # Assert
            $entity = Get-Interface -svc $svc -Id $result.Id;
                      
            $entity | Should Not Be $null;

            # force update
            $moduleName = 'biz.dfch.PS.Appclusive.Client';
            Remove-Module $moduleName -ErrorAction:SilentlyContinue;
            Import-Module $moduleName;

            $svc = Enter-ApcServer;
            $jobAfterDelete = Get-Job -svc $svc -Id $job.Id;
            
            $jobAfterDelete | Should Not Be $null;
            $jobAfterDelete.Condition | Should Be "Delete";
		}

		It "Remove-InterfaceById-ShouldReturnRemovedEntity" -Test {
			# Arrange
			$Name = "{0}-Name-{1}" -f $interfacePrefix,[guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
            $entityKindId = [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::Interface.value__

			$result = Set-Interface -svc $svc -Name $Name -Description $Description -CreateIfNotExist;

			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Name | Should Be $Name;
			$result.Description | Should Be $Description;

            $filter = "RefId eq '{0}' and EntityKindId eq {1}" -f $result.Id, $entityKindId;
            $job = $svc.Core.Jobs.AddQueryOption('$filter', $filter) | Select;
            
            $jobResult = @{Version = "1"; Message = "PESTER-TEST"; Succeeded = $true};
            $null = Invoke-EntityAction -svc $svc -InputObject $job -EntityActionName "JobResult" -InputParameters $jobResult;
            
            $entity = Get-Interface -svc $svc -Id $result.Id;

            $entity | Should Not Be $null;
            $entity.Id | Should Be $result.Id;
            $entity.Name | Should Be $result.Name;
            $entity.Description | Should be $entity.Description;

            # Act
            Remove-Interface -svc $svc -Id $result.Id;

            # Assert
            $entity = Get-Interface -svc $svc -Id $result.Id;
            
            $entity | Should Not Be $null;

            # force update
            $moduleName = 'biz.dfch.PS.Appclusive.Client';
            Remove-Module $moduleName -ErrorAction:SilentlyContinue;
            Import-Module $moduleName;

            $svc = Enter-ApcServer;
            $jobAfterDelete = Get-Job -svc $svc -Id $job.Id;
            
            $jobAfterDelete | Should Not Be $null;
            $jobAfterDelete.Condition | Should Be "Delete";
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
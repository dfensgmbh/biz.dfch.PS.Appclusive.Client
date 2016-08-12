
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Remove-Connector" -Tags "Remove-Connector" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Set-Interface.ps1"
	. "$here\Invoke-EntityAction.ps1"
	. "$here\Get-Job.ps1"
	. "$here\Set-Connector.ps1"
	. "$here\Get-Connector.ps1"
	. "$here\Remove-Connector.ps1"
	. "$here\Remove-Entity.ps1"
	. "$here\Format-ResultAs.ps1"
	
	Context "Remove-Connector" {

        $entityPrefix = "RemoveConnector";
	
        AfterAll {
            $moduleName = 'biz.dfch.PS.Appclusive.Client';
            Remove-Module $moduleName -ErrorAction:SilentlyContinue;
            Import-Module $moduleName;

            $svc = Enter-ApcServer;
            $entities = $svc.Core.Connectors.AddQueryOption('$filter', "startswith(Name, 'RemoveConnector')") | Select;
         
            foreach ($entity in $entities)
            {
                Remove-Entity -svc $svc -Id $entity.Id -EntitySetName "Connectors" -Confirm:$false;
            }
            
            $svc = Enter-ApcServer;
            $interfaces = $svc.Core.Interfaces.AddQueryOption('$filter', "startswith(Name, 'RemoveConnector')") | Select;
         
            foreach ($interface in $interfaces)
            {
                Remove-Entity -svc $svc -Id $interface.Id -EntitySetName "Interfaces" -Confirm:$false;
            }
            
            $svc = Enter-ApcServer;
            $entityKinds = $svc.Core.EntityKinds.AddQueryOption('$filter', "startswith(Name, 'RemoveConnector')") | Select;
         
            foreach ($entityKind in $entityKinds)
            {
                Remove-Entity -svc $svc -Id $entityKind.Id -EntitySetName "EntityKinds" -Confirm:$false;
            }
        }

        BeforeEach {
            $moduleName = 'biz.dfch.PS.Appclusive.Client';
            Remove-Module $moduleName -ErrorAction:SilentlyContinue;
            Import-Module $moduleName;

            $svc = Enter-ApcServer;
        }

        function CreateInterface()
        {
            $Name = "{0}-Name-{1}" -f $entityPrefix,[guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();

			# Act
			$interface__ = Set-Interface -svc $svc -Name $Name -Description $Description -CreateIfNotExist;

            $entityKindId = [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::Interface.value__

            $filter = "RefId eq '{0}' and EntityKindId eq {1}" -f $interface__.Id, $entityKindId;
            $job = $svc.Core.Jobs.AddQueryOption('$filter', $filter) | Select;
            
            $jobResult = @{Version = "1"; Message = "PESTER-TEST"; Succeeded = $true};
            $null = Invoke-EntityAction -svc $svc -InputObject $job -EntityActionName "JobResult" -InputParameters $jobResult;

            return $interface__;
        }

        function CreateEntityKind() 
        {
            $entityKind = New-Object biz.dfch.CS.Appclusive.Api.Core.EntityKind;
            $entityKind.Name = "{0}-Name-{1}" -f $entityPrefix,[guid]::NewGuid().ToString();
            $entityKind.Version = "{0}-Version-{1}" -f $entityPrefix,[guid]::NewGuid().ToString();
            
            $svc.Core.AddToEntityKinds($entityKind);
            $svc.Core.SaveChanges();

            return $entityKind;
        }
        
		# Context wide constants
		# N/A
	    It "Remove-ConnectorWithId-ShouldReturnDeletedEntity" -Test {

			# Arrange
            $interface = CreateInterface | Select;
            $entityKind = CreateEntityKind | Select;

			$Name = "{0}-Name-{1}" -f $entityPrefix,[guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
            $InterfaceId = $interface.Id;
            $entityKindId = $entityKind.Id;
            $Multiplicity = 15;
            			            
			$connector = Set-Connector -svc $svc `                            -Name $Name `                            -InterfaceId $InterfaceId `
                            -EntityKindId $entityKindId `
                            -Description $Description `
                            -Multiplicity $Multiplicity `
                            -Provide `
                            -CreateIfNotExist;
			
            $connectorEntityKindId = [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::Connector.value__

            $filter = "RefId eq '{0}' and EntityKindId eq {1}" -f $connector.Id, $connectorEntityKindId;
            $job = $svc.Core.Jobs.AddQueryOption('$filter', $filter) | Select;
            
            $jobResult = @{Version = "1"; Message = "PESTER-TEST"; Succeeded = $true};
            $null = Invoke-EntityAction -svc $svc -InputObject $job -EntityActionName "JobResult" -InputParameters $jobResult;

            # Act
            $entity = Get-Connector -svc $svc -Id $connector.Id;

            $deletedEntity = Remove-Connector -svc $svc -Id $entity.Id;
            
            # Assert
            
            $entity = Get-Connector -svc $svc -Id $entity.Id;            
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
# includes tests for CLOUDTCL-1881

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester()
{
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
	PARAM
	(
		$message = "EMERGENCY: Script cannot continue."
	)
	
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe "Assoc.Tests" -Tags "Assoc.Tests" {

	Mock Export-ModuleMember { return $null; }
	. "$here\$sut"
	
	$entityPrefix = "TestItem-";
	$usedEntitySets = @("Assocs","Nodes");
	$nodeEntityKindId = [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::Node.value__;
	
	Context "#CLOUDTCL-1881-AssocTests" {
		
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;
			$svc = Enter-Appclusive;
			
			$currentTenant = Get-ApcTenant -Current -Svc $Svc;
			$nodeParentId = $currentTenant.NodeId;
		}
		
		AfterEach {
            $svc = Enter-ApcServer;
            $entityFilter = "startswith(Name, '{0}')" -f $entityPrefix;

            foreach ($entitySet in $usedEntitySets)
            {
                $entities = $svc.Core.$entitySet.AddQueryOption('$filter', $entityFilter) | Select;
         
                foreach ($entity in $entities)
                {
                    Remove-ApcEntity -svc $svc -Id $entity.Id -EntitySetName $entitySet -Confirm:$false;
                }
            }
        }
		
		It "Assoc-CreateAndDelete" -Test {
			#ARRANGE
			$nodeName1 = $entityPrefix + "node1";
			$nodeName2 = $entityPrefix + "node2";
			$assocName = $entityPrefix + "assoc";
			$order = 1;
			
			#ACT create node
			$node1 = New-ApcNode -Name $nodeName1 -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			$node2 = New-ApcNode -Name $nodeName2 -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			
			#get Id of the nodes
			$node1Id = $node1.Id;
			$node2Id = $node2.Id;
			
			#create Assoc that has node as destination
			$assoc = Create-Assoc -svc $svc -Name $assocName -SourceId $node1Id -DestinationId $node2Id -Order $order;
			
			#get the id of the assoc
			$assocId = $assoc.Id;
			
			#ASSERT assoc creation
			$assoc | Should Not Be $null;
			$assoc.Id | Should Not Be 0;
			$assoc.Name | Should Be $assocName;
			$assoc.SourceId | Should Be $node1Id;
			$assoc.DestinationId | Should Be $node2Id;
			$assoc.Order | Should Be $order;
			
			#ACT delete assoc
			Remove-ApcEntity -svc $svc -Id $assocId -EntitySetName "Assocs" -Confirm:$false;
			
			#get the deleted assoc
			$query = "Id eq {0}" -f $assocId;
			$deletedAssoc = $svc.Core.Assocs.AddQueryOption('$filter', $query) | select;
	
			#ASSERT that assoc is deleted
			$deletedAssoc | Should Be $null;
		}
		
		It "Assoc-UpdateNameAndDescription" -Test {
			#ARRANGE
			$nodeName1 = $entityPrefix + "node1";
			$nodeName2 = $entityPrefix + "node2";
			$assocName = $entityPrefix + "assoc";
			$order = 1;
			
			#ACT create nodes
			$node1 = New-ApcNode -Name $nodeName1 -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			$node2 = New-ApcNode -Name $nodeName2 -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			
			#get Id of the nodes
			$node1Id = $node1.Id;
			$node2Id = $node2.Id;
			
			#ACT create Assoc that has first two nodes as source and destination
			$assoc = Create-Assoc -svc $svc -Name $assocName -SourceId $node1Id -DestinationId $node2Id -Order $order;
			
			#get the id of the assoc
			$assocId = $assoc.Id;
			
			#ARRANGE update
			$newName = $assocName + " Updated";
			$newDescription = "Updated";
			
			#ACT Update assoc
			$updatedAssoc = Update-Assoc -Svc $svc -Id $assocId -Name $newName -Description $newDescription;
			
			#ASSERT - update
			$updatedAssoc.Id | Should Be $assocId;
			$updatedAssoc.Name | Should Be $newName;
			$updatedAssoc.Description | Should Be $newDescription;
	
			#CLEANUP delete assoc
			Remove-ApcEntity -svc $svc -Id $assocId -EntitySetName "Assocs" -Confirm:$false;
		}
		
		It "Assoc-UpdateSourceAndDestination-ShouldFail" -Test {
			#ARRANGE
			$nodeName1 = $entityPrefix + "node1";
			$nodeName2 = $entityPrefix + "node2";
			$nodeName3 = $entityPrefix + "node3";
			$nodeName4 = $entityPrefix + "node4";
			$assocName = $entityPrefix + "assoc";
			$order = 1;
			
			#ACT create nodes
			$node1 = New-ApcNode -Name $nodeName1 -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			$node2 = New-ApcNode -Name $nodeName2 -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			$node3 = New-ApcNode -Name $nodeName3 -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			$node4 = New-ApcNode -Name $nodeName4 -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			
			#get Id of the nodes
			$node1Id = $node1.Id;
			$node2Id = $node2.Id;
			$node3Id = $node3.Id;
			$node4Id = $node4.Id;
			
			#ACT create Assoc that has first two nodes as source and destination
			$assoc = Create-Assoc -svc $svc -Name $assocName -SourceId $node1Id -DestinationId $node2Id -Order $order;
			
			#get the id of the assoc
			$assocId = $assoc.Id;
			
			#ARRANGE update
			$assoc.SourceId = $node3Id;
			$assoc.DestinationId = $node4Id;
			
			#ACT Update assoc using node3 & node4 as source & destination
			$svc.Core.UpdateObject($assoc);
			{ $null = $svc.Core.SaveChanges(); } | Should ThrowDataServiceClientException @{StatusCode = 500};
			
			#CLEANUP delete assoc
			$svc = Enter-Appclusive;
			Remove-ApcEntity -svc $svc -Id $assocId -EntitySetName "Assocs" -Confirm:$false;
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

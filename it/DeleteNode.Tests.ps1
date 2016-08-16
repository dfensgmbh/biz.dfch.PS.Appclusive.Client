#includes tests for test cases CLOUDTCL-2190

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe -Tags "DeleteNode.Tests" "DeleteNode.Tests" {

	Mock Export-ModuleMember { return $null; }
	. "$here\Acl_Ace.ps1"

    $entityPrefix = "TestItem-";
	$usedEntitySets = @("Assocs","Nodes", "ExternalNodes", "Acls", "Aces", "EntityBags");
	$nodeEntityKindId = [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::Node.value__;
	$nodeParentId = (Get-ApcTenant -Current).NodeId;

	Context "#CLOUDTCL-2190-DeleteNode" {
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;
			$svc = Enter-Appclusive;
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
		
		It "DeleteNodeWithChildNode-ThrowsError" -Test {
			#ARRANGE
			$nodeName = $entityPrefix + "node";
			$childName = $entityPrefix + "childnode";
			
			#ACT create node
			$newNode = New-ApcNode -Name $nodeName -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			
			#get Id of the node
			$nodeId = $newNode.Id;
			
			#ACT create child Node
			$newChildNode = New-ApcNode -Name $childName -ParentId $nodeId -EntityKindId $nodeEntityKindId -svc $svc;
			
			#get Id of the child Node
			$childNodeId = $newChildNode.Id;
			
			#get parent & child Node
			$parentNode = Get-ApcNode -Id $nodeId -svc $svc;
			$childNode = Get-ApcNode -Id $childNodeId -svc $svc;
			
			#ASSERT parent & child Node creation
			$parentNode | Should Not Be $null;
			$parentNode.Id | Should Not Be $null;
			$childNode | Should Not Be $null;
			$childNode.Id | Should Not Be $null;
			$childNode.ParentId | Should Be $nodeId;
			
			try
			{
				#get the parent node
				$parentNode = Get-ApcNode -Id $nodeId -svc $svc;
				$svc.Core.DeleteObject($parentNode);
				#remove Node, but it's supposed to fail as we have Children
				$svc.Core.SaveChanges(); # } | Should ThrowDataServiceClientException @{StatusCode = 400};
			}
			catch
			{
				$(Format-ApcException) | Should Not Be $null;
				$_.Exception.Message | Should Not Be $null;
				$_.FullyQualifiedErrorId | Should Not Be $null;
			}
			finally 
			{
				$svc = Enter-Appclusive;
				
				#get the child node
				$childNode = Get-ApcNode -Id $childNodeId -svc $svc;
	
				#delete the child node first
				$svc.Core.DeleteObject($childNode);
				$result = $svc.Core.SaveChanges();
				
				#get the parent node
				$parentNode = Get-ApcNode -Id $nodeId -svc $svc;
	
				#delete the parent node
				$svc.Core.DeleteObject($parentNode);
				$result = $svc.Core.SaveChanges();
			}
		}
		
		It "DeleteNodeCheckAttatchedEntitiesDeletion" -Test {
			#ARRANGE
			$nodeName = $entityPrefix + "node";
			$extName = $entityPrefix + "externalnode";
			$aclName = $entityPrefix + "Acl";
			$aceName = $entityPrefix + "Ace";
			$entityBagName = $entityPrefix + "entityBag";
			
			#ACT create node
			$newNode = New-ApcNode -Name $nodeName -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			
			#get Id and entityKindId of the node
			$nodeId = $newNode.Id;
			$nodeEntityKindId = $newNode.EntityKindId;
			
			#get the job of the node
			$job = Get-ApcNode -Id $nodeId -ExpandJob;
			$jobId = [long] $job.Id;
			
			#create external node
			$extNode = New-ApcExternalNode -name $extName -NodeId $nodeId -ExternalId $nodeId -ExternalType "ArbitraryType" -svc $svc | select;
			#Write-Host ($extNode | out-string);
			
			#ASSERT external Node
			$extNode | Should Not Be $null;
			#get id of external node
			$extNodeId = $extNode.Id;
			
			#ACT create acl
			$acl = Create-Acl -svc $svc -aclName $aclName -entityId $nodeId -entityKindId $nodeEntityKindId;
			
			#get Id of the acl
			$aclId = $acl.Id;
			
			#ACT Create Ace
			$ace = Create-Ace -svc $svc -aceName $aceName -aclId $aclId;
			
			#get the Id of the ace
			$aceId = $ace.Id;
			
			#create EntityBag
			$entityBag = New-Object biz.dfch.CS.Appclusive.Api.Core.EntityBag;
			$entityBag.Name = $entityBagName;
			$entityBag.EntityId = $nodeId;
			$entityBag.EntityKindId = $nodeEntityKindId;
			$entityBag.Value = [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::EntityBag.value__;
			$svc.Core.AddToEntityBags($entityBag);
			$result = $svc.Core.SaveChanges();
			
			#get EntityBag
			$query = "Name eq '{0}' and EntityId eq {1}" -f $entityBagName, $nodeId;
			$entityBag = $svc.Core.EntityBags.AddQueryOption('$filter', $query) | select;
			$entityBag | Should Not Be $null;
			$entityBagId = $entityBag.Id;
			
			#ACT delete Node
			$node = Get-ApcNode -Id $nodeId -svc $svc;
			$svc.Core.DeleteObject($node);
			$result = $svc.Core.SaveChanges();
			
			#ASSERT
			#check that node is deleted
			$node = Get-ApcNode -Id $nodeId -svc $svc;
			$node | Should Be $null;
			
			#check that Job is deleted
			$query = "Id eq {0}" -f $jobId;
			$job = $svc.Core.Jobs.AddQueryOption('$filter', $query) | select;
			$job | Should Be $null;
			
			#check that the external Node is Deleted
			$query = "Id eq {0}" -f $extNodeId;
			$extNode = $svc.Core.ExternalNodes.AddQueryOption('$filter', $query) | select;
			$extNode | Should Be $null;
			
			#check that the acl is Deleted
			$query = "Id eq {0}" -f $aclId;
			$acl = $svc.Core.Acls.AddQueryOption('$filter', $query) | select;
			$acl | Should Be $null;
			
			#check that the ace is deleted
			$query = "Id eq {0}" -f $aceId;
			$ace = $svc.Core.Aces.AddQueryOption('$filter', $query) | select;
			$ace | Should Be $null;
			
			#check that the entityBag is deleted
			$query = "Id eq {0}" -f $entityBagId;
			$entityBag = $svc.Core.EntityBags.AddQueryOption('$filter', $query) | select;
			$entityBag | Should Be $null;
		}
		
		It "DeleteNodeWithChildNode-ThrowsError" -Test {
			#ARRANGE
			$nodeName = $entityPrefix + "node";
			$nodeChildren = 4;
			
			#ACT create node
			$newNode = New-ApcNode -Name $nodeName -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			
			#get Id of the node
			$nodeId = $newNode.Id;
			
			$ids = @();
			#ACT create chilren nodes
			for ($i =1; $i -le $nodeChildren; $i++)
			{
				$newChildNode = New-ApcNode -Name ("{0}-{1}" -f $nodeName,$i) -ParentId $nodeId -EntityKindId $nodeEntityKindId -svc $svc;
				$ids += $newChildNode.Id;
			}
			
			#CLEANUP delete chilren nodes
			foreach ($id in $ids)
			{
				Remove-ApcNode -Id $id -Confirm:$false -svc $svc;
			}
		}
		
		It "DeleteNodeWithAssoc" -Test {
			#ARRANGE
			$nodeName1 = $entityPrefix + "node1";
			$nodeName2 = $entityPrefix + "node2";
			$assocName = $entityPrefix + "assoc";
			
			#ACT create node
			$node1 = New-ApcNode -Name $nodeName1 -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			$node2 = New-ApcNode -Name $nodeName2 -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			
			#get Id of the nodes
			$node1Id = $node1.Id;
			$node2Id = $node2.Id;
			
			#create Assoc that has node as destination
			$newassoc = New-Object biz.dfch.CS.Appclusive.Api.Core.Assoc;
            $newassoc.SourceId = $node2Id;
			$newassoc.DestinationId = $node1Id;
            $newassoc.Order = $node2Id + $node1Id;
            $newassoc.Name = $assocName;
			$svc.Core.AddToAssocs($newassoc);
			$svc.Core.SaveChanges();
			
			#get the assoc
			$query = "Name eq '{0}'" -f $assocName;
			$assoc = $svc.core.Assocs.AddQueryOption('$filter', $query) | Select;
			
			#get the id of the assoc
			$assocId = $assoc.Id;
			
			#ASSERT that assoc has been created
			$assoc.Id | Should Not Be $null;
			$assoc.Name | Should Be $assocName;
			
			try
			{
				#get the  node1 and try to delete it
				$node1 = Get-ApcNode -Id $node1Id -svc $svc;
				$svc.Core.DeleteObject($node1);
				#it is supposed to fail because the node1 is the Destination of the Assoc
				$svc.Core.SaveChanges();
			}
			catch
			{
				$(Format-ApcException) | Should Not Be $null;
				$_.Exception.Message | Should Not Be $null;
				$_.FullyQualifiedErrorId | Should Not Be $null;
			}
			finally
			{
				#when we delete the node2, the assoc should be deleted because node2 is its source
				$svc = Enter-Appclusive;
				Remove-ApcNode -Id $node2Id -Confirm:$false -svc $svc;
				
				#ASSERT get the assoc and check that it does not exist anymore
				$query = "Id eq {0}" -f $assocId;
				$assoc = $svc.core.Assocs.AddQueryOption('$filter', $query) | Select;
				$assoc | Should be $null;
			}
		}
	}
}

#
# Copyright 2016 d-fens GmbH
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

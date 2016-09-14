#includes tests for CLOUDTCL-2199

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe -Tags "ExternalNode.Tests" "ExternalNode.Tests" {
	. "$here\$sut"
	
	$entityPrefix = "TestItem-";
	$usedEntitySets = @("Nodes", "ExternalNodes", "ExternalNodeBags");
	$nodeEntityKindId = [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::Node.value__;
	
	Context "#CLOUDTCL-2199-ExternalNodeTests" {
		
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;
			
			$svc = Enter-Appclusive;
			
			$currentTenant = Get-ApcTenant -Current -Svc $Svc;
			$nodeParentId = $currentTenant.NodeId;
		}
		
		AfterEach {
            $svc = Enter-Appclusive;
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
		
        It "Create-Get-Delete-ExternalNode" -Test {
			#ARRANGE
            $nodeName = $entityPrefix + "node";
			$extName = $entityPrefix + "externalnode";
			$extType = "ArbitraryType";
			
			#ACT create node
			$newNode = New-ApcNode -Name $nodeName -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			
			#get Id of the node
			$nodeId = $newNode.Id;
			
			#create external node
			$extNode = New-ApcExternalNode -name $extName -NodeId $nodeId -ExternalId $nodeId -ExternalType $extType -svc $svc | select;
			
			#get id of external node
			$extNodeId = $extNode.Id;
			
			#ASSERT external Node
			$extNode | Should Not Be $null;
            $extNode | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.ExternalNode];
            $extNode.NodeId | Should Be $nodeId;
            $extNode.ExternalId | Should Be $nodeId;
            $extNode.ExternalType | Should Be $extType;
            $extNode.Name | Should Be $extName;
			
			#ACT Get the external-node using Get-ApcExternalNode
			$loadedextNode = Get-ApcExternalNode -Id $extNodeId -svc $svc;
			
			#ASSERT the node we get is the same
			$loadedextNode | Should Not Be $null;
            $loadedextNode | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.ExternalNode];
            $loadedextNode.NodeId | Should Be $nodeId;
            $loadedextNode.ExternalId | Should Be $nodeId;
            $loadedextNode.ExternalType | Should Be $extType;
            $loadedextNode.Name | Should Be $extName;
			
			#ACT delete external node
			$svc.Core.DeleteObject($loadedextNode);
			$result = $svc.Core.SaveChanges();
			
			#ASSERT external node is deleted
			$result.StatusCode | Should Be 204;
			$query = "Id eq {0}" -f $extNodeId;
			$deletedExtNode = $svc.Core.ExternalNodes.AddQueryOption('$filter', $query) | select;
			$deletedExtNode | Should Be $null;
			
			#CLEANUP delete node
			Remove-ApcNode -svc $svc -Id $nodeId -Confirm:$false;
        }
		
        It "Create-Get-ExternalNodeBags" -Test {
			#ARRANGE
            $nodeName = $entityPrefix + "node";
			$extName = $entityPrefix + "externalnode";
			$extType = "ArbitraryType";
			
			#ACT create node
			$newNode = New-ApcNode -Name $nodeName -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			
			#get Id of the node
			$nodeId = $newNode.Id;
			$nodeEntityKindId = $newNode.EntityKindId;
			
			#create external node
			$extNode = New-ApcExternalNode -name $extName -NodeId $nodeId -ExternalId $nodeId -ExternalType $extType -svc $svc | select;
			
			#get id of external node
			$extNodeId = $extNode.Id;
			
			#ASSERT external Node
			$extNode | Should Not Be $null;
            $extNode | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.ExternalNode];
            $extNode.NodeId | Should Be $nodeId;
            $extNode.ExternalId | Should Be $nodeId;
            $extNode.ExternalType | Should Be $extType;
            $extNode.Name | Should Be $extName;

            $countOfBags = 10;
			
            for($i = 1; $i -le $countOfBags; $i++)
            {
                $nodeBagName = ("{0}-Name-{1}" -f $nodeName,$i);
                $nodeBagValue = ("{0}-Value-{1}" -f $nodeName,$i);

                $null = Create-ExternalNodeBag -Name $nodeBagName -ExternalNodeId $extNodeId -Value $nodeBagValue -Svc $svc;
            }
			
			#get the external node bags with specific id
            $nodeBagsFilter = "ExternaldNodeId eq {0}" -f $extNodeId;
            $createdNodeBags = $svc.Core.ExternalNodeBags.AddQueryOption('$filter', $nodeBagsFilter) | Select;
			
			#ASSERT  count of external node bags
            $createdNodeBags.Count | Should Be $countOfBags;  
        }
        
        It "Update-ExternalNode" -Test {
			#ARRANGE
            $nodeName = $entityPrefix + "node";
			$extName = $entityPrefix + "externalnode";
			$extType = "ArbitraryType";
			
			#ACT create node
			$newNode = New-ApcNode -Name $nodeName -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			
			#get Id of the node
			$nodeId = $newNode.Id;
			
			#create external node
			$extNode = New-ApcExternalNode -name $extName -NodeId $nodeId -ExternalId $nodeId -ExternalType $extType -svc $svc | select;
			
			#get id of external node
			$extNodeId = $extNode.Id;
			
			#ASSERT external Node
			$extNode | Should Not Be $null;
            $extNode | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.ExternalNode];
            $extNode.NodeId | Should Be $nodeId;
            $extNode.ExternalId | Should Be $nodeId;
            $extNode.ExternalType | Should Be $extType;
            $extNode.Name | Should Be $extName;
            
			#ACT Update external Node
			$newExtName = $extName + " Updated";
			$newExtDescription = "Description Updated";
			$newExtType = "Arbitrary-Type-Updated";
			$newExtId = ("Arbitrary-Id-{0}-Updated" -f $nodeId);
			
			$updatedExternalNode = Update-ExternalNode -Svc $svc -externalNodeId $extNodeId -UpdatedName $newExtName -UpdatedDescription $newExtDescription -UpdatedExternalType $newExtType -UpdatedExternalId $newExtId;
			
			#CLEANUP delete Node - external node is deleted automatically
			Remove-ApcNode -svc $svc -Id $nodeId -Confirm:$false;
        }
		
        It "Update-ExternalNodeBag" -Test {
			#ARRANGE
            $nodeName = $entityPrefix + "node";
			$extName = $entityPrefix + "externalnode";
			$extType = "ArbitraryType";
			$extBagName = $entityPrefix + "ExternalNodeBag";
            $extBagValue = ("{0}-Value" -f $nodeName);
			
			#ACT create node
			$newNode = New-ApcNode -Name $nodeName -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			
			#get Id of the node
			$nodeId = $newNode.Id;
			$nodeEntityKindId = $newNode.EntityKindId;
			
			#create external node
			$extNode = New-ApcExternalNode -name $extName -NodeId $nodeId -ExternalId $nodeId -ExternalType $extType -svc $svc | select;
			
			#get id of external node
			$extNodeId = $extNode.Id;
			
			#ASSERT external Node
			$extNode | Should Not Be $null;
            $extNode | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.ExternalNode];
            $extNode.NodeId | Should Be $nodeId;
            $extNode.ExternalId | Should Be $nodeId;
            $extNode.ExternalType | Should Be $extType;
            $extNode.Name | Should Be $extName;
			
			#ACT create external node bag
            $extNodeBag = Create-ExternalNodeBag -Name $extBagName -ExternalNodeId $extNodeId -Value $extBagValue -Svc $svc;
			
			#get id of external node bag
			$extNodeBagId = $extNodeBag.Id;
			
			#ACT Update external Node
			$newName = $extBagName + " Updated";
			$newDescription = "Description Updated";
			$newValue = $extBagValue + " Updated";
			
			$updatedExternalNode = Update-ExternalNodeBag -Svc $svc -ExternalNodeBagId $extNodeBagId -UpdatedName $newName -UpdatedDescription $newDescription -UpdatedValue $newValue;
			
			#CLEANUP delete Node - external node and external node bags are deleted automatically
			Remove-ApcNode -svc $svc -Id $nodeId -Confirm:$false;
        }
        
        It "Delete-ExternalNode-Deletes-ExtNodeBag" -Test {
			#ARRANGE
            $nodeName = $entityPrefix + "node";
			$extName = $entityPrefix + "externalnode";
			$extType = "ArbitraryType";
			$extBagName = $entityPrefix + "ExternalNodeBag";
            $extBagValue = ("{0}-Value" -f $nodeName);
			
			#ACT create node
			$newNode = New-ApcNode -Name $nodeName -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			
			#get Id of the node
			$nodeId = $newNode.Id;
			$nodeEntityKindId = $newNode.EntityKindId;
			
			#create external node
			$extNode = New-ApcExternalNode -name $extName -NodeId $nodeId -ExternalId $nodeId -ExternalType $extType -svc $svc | select;
			
			#get id of external node
			$extNodeId = $extNode.Id;
			
			#ASSERT external Node
			$extNode | Should Not Be $null;
            $extNode | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.ExternalNode];
            $extNode.NodeId | Should Be $nodeId;
            $extNode.ExternalId | Should Be $nodeId;
            $extNode.ExternalType | Should Be $extType;
            $extNode.Name | Should Be $extName;
			
			#ACT create external node bag
            $extNodeBag = Create-ExternalNodeBag -Name $extBagName -ExternalNodeId $extNodeId -Value $extBagValue -Svc $svc;
			
			#get id of external node bag
			$extNodeBagId = $extNodeBag.Id;
			
			#ACT delete external node
			$svc.Core.DeleteObject($extNode);
			$result = $svc.Core.SaveChanges();
			
			#ASSERT that external node bag is deleted too
			$query = "Id eq {0}" -f $extNodeBagId;
			$loadedExtNodeBag = $svc.Core.ExternalNodeBags.AddQueryOption('$filter', $query) | select;
			$loadedExtNodeBag | Should Be $null;
			$loadedExtNodeBag.Id | Should Be $null;
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

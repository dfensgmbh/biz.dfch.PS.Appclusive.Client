$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}


Describe -Tags "Appclusive.ExternalNode" "Appclusive.ExternalNode" {
	. "$here\$sut"

	Context "ExternalNode_PinDown" {
	
		BeforeAll {
            Import-Module biz.dfch.PS.Appclusive.Client
			$svc = Enter-ApcServer;
		}
		
        function CreateExternalNode([long]$nodeId, [string]$name)
        {
            $externalNode = New-Object biz.dfch.CS.Appclusive.Api.Core.ExternalNode;
            $externalNode.NodeId = $nodeId;
            $externalNode.ExternalId = ("Arbitrary-Id-{0}" -f $nodeId);
            $externalNode.ExternalType = "Arbitrary-Type";
            $externalNode.Name = $name;

            return $externalNode;        
        }  

        function CreateExternalNodeBag([long]$externalNodeId, [string]$key, [string]$value)
        {
            $externalNodeBag = New-Object biz.dfch.CS.Appclusive.Api.Core.ExternalNodeBag;
            $externalNodeBag.ExternaldNodeId = $externalNodeId;
            $externalNodeBag.Name = $key;
            $externalNodeBag.Value = $value;

            return $externalNodeBag;
        }

		AfterAll {
            Write-Host "    [_] " -ForegroundColor Green -NoNewline;

            Write-Host "Deleting created External Nodes" -NoNewLine;
            $nodeNames = @("Create-Read-ExternalNode", "Create-Read-ExternalNodeBags",
                            "Update-ExternalNode", "Update-ExternalNode-Updated", "Update-ExternalNodeBags",
                            "Delete-ExternalNode", "Delete-ExternalNode-Also-Deletes-NodeBags",
                            "Properties-Returns-ExternalNodeBags");

            foreach ($nodeName in $nodeNames)
            {
                $nodeFilter = ("Name eq '{0}'" -f $nodeName);
                $createdNodes = $svc.Core.ExternalNodes.AddQueryOption('$filter', $nodeFilter) | Select;

                foreach ($node in $createdNodes)
                {
                    $svc.Core.DeleteObject($node);
                }
            }

            $svc.Core.SaveChanges();
            
            Write-Host " Done" -ForegroundColor Green;
		}
		
		It "Warmup" -Test {
			1 | Should Be 1;
		}
		
        It "Create-Read-ExternalNode" -Test {            
            $nodeName = "Create-ExternalNode";
            $nodeId = 1;
            $node = CreateExternalNode $nodeId $nodeName;

            $svc.Core.AddToExternalNodes($node);
            $svc.Core.SaveChanges();

            $nodeFilter = ("Name eq '{0}'" -f $nodeName);
            $createdNode = $svc.Core.ExternalNodes.AddQueryOption('$filter', $nodeFilter).AddQueryOption('$top', 1) | Select;

            $createdNode | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.ExternalNode];
            $createdNode.NodeId | Should Be 1;
            $createdNode.ExternalId | Should Be ("Arbitrary-Id-{0}" -f $nodeId);
            $createdNode.ExternalType | Should Be "Arbitrary-Type";
            $createdNode.Name | Should Be $nodeName;
        }

        It "Create-Read-ExternalNodeBags" -Test {
            $nodeName = "Create-Read-ExternalNodeBags";
            $nodeId = 1;
            $node = CreateExternalNode $nodeId $nodeName;

            $countOfBags = 20;

            $svc.Core.AddToExternalNodes($node);
            $svc.Core.SaveChanges();

            $nodeFilter = ("Name eq '{0}'" -f $nodeName);
            $createdNode = $svc.Core.ExternalNodes.AddQueryOption('$filter', $nodeFilter).AddQueryOption('$top', 1) | Select;

            for($i = 1; $i -le $countOfBags; $i++)
            {
                $nodeBagName = ("{0}-Name-{1}" -f $nodeName,$i);
                $nodeBagValue = ("{0}-Value-{1}" -f $nodeName,$i);

                $nodebag = CreateExternalNodeBag $createdNode.Id $nodeBagName $nodeBagValue;
                
                $svc.Core.AddToExternalNodeBags($nodebag);
                $svc.Core.SaveChanges();
            }

            $nodeBagsFilter = "ExternaldNodeId eq {0}" -f $createdNode.Id;
            $createdNodeBags = $svc.Core.ExternalNodeBags.AddQueryOption('$filter', $nodeBagsFilter) | Select;

            $createdNodeBags.Count | Should Be $countOfBags;
            for($i = 1; $i -le $countOfBags; $i++)
            {
                $nodeBagName = ("{0}-Name-{1}" -f $nodeName,$i);
                $nodeBagValue = ("{0}-Value-{1}" -f $nodeName,$i);
                
                $nodeBagsFilter = "Name eq '{0}'" -f $nodeBagName;
                $createdNodeBag = $svc.Core.ExternalNodeBags.AddQueryOption('$filter', $nodeBagsFilter) | Select;

                $createdNodeBag | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.ExternalNodeBag];
                $createdNodeBag.Name | Should Be $nodeBagName;
                $createdNodeBag.Value | Should Be $nodeBagValue;
                $createdNodeBag.ExternaldNodeId | Should Be $createdNode.Id;
            }
        }
                
        It "Update-ExternalNode" -Test {                    
            $nodeName = "Update-ExternalNode";
            $nodeId = 1;
            $node = CreateExternalNode $nodeId $nodeName;

            $svc.Core.AddToExternalNodes($node);
            $svc.Core.SaveChanges();

            $nodeFilter = ("Name eq '{0}'" -f $nodeName);
            $createdNode = $svc.Core.ExternalNodes.AddQueryOption('$filter', $nodeFilter).AddQueryOption('$top', 1) | Select;

            $createdNode | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.ExternalNode];
            $createdNode.NodeId | Should Be 1;
            $createdNode.ExternalId | Should Be ("Arbitrary-Id-{0}" -f $nodeId);
            $createdNode.ExternalType | Should Be "Arbitrary-Type";
            $createdNode.Name | Should Be $nodeName;
            
            $createdNode.ExternalId = ("Arbitrary-Id-{0}-Updated" -f $nodeId);
            $createdNode.ExternalType = "Arbitrary-Type-Updated";
            $createdNode.Name = ("{0}-Updated" -f $nodeName);

            $svc.Core.UpdateObject($createdNode);
            $svc.Core.SaveChanges();
            
            $nodeFilter = ("Name eq '{0}-Updated'" -f $nodeName);
            $updatedNode = $svc.Core.ExternalNodes.AddQueryOption('$filter', $nodeFilter).AddQueryOption('$top', 1) | Select;
            
            $updatedNode | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.ExternalNode];
            $updatedNode.NodeId | Should Be 1;
            $updatedNode.ExternalId | Should Be ("Arbitrary-Id-{0}-Updated" -f $nodeId);
            $updatedNode.ExternalType | Should Be "Arbitrary-Type-Updated";
            $updatedNode.Name | Should Be ("{0}-Updated" -f $nodeName);
        }

        It "Update-ExternalNodeBags" -Test {
            $nodeName = "Update-ExternalNodeBags";
            $nodeId = 1;
            $node = CreateExternalNode $nodeId $nodeName;

            $countOfBags = 20;

            $svc.Core.AddToExternalNodes($node);
            $svc.Core.SaveChanges();

            $nodeFilter = ("Name eq '{0}'" -f $nodeName);
            $createdNode = $svc.Core.ExternalNodes.AddQueryOption('$filter', $nodeFilter).AddQueryOption('$top', 1) | Select;

            for($i = 1; $i -le $countOfBags; $i++)
            {
                $nodeBagName = ("{0}-Name-{1}" -f $nodeName,$i);
                $nodeBagValue = ("{0}-Value-{1}" -f $nodeName,$i);

                $nodebag = CreateExternalNodeBag $createdNode.Id $nodeBagName $nodeBagValue;
                
                $svc.Core.AddToExternalNodeBags($nodebag);
                $svc.Core.SaveChanges();
            }

            $nodeBagsFilter = "ExternaldNodeId eq {0}" -f $createdNode.Id;
            $createdNodeBags = $svc.Core.ExternalNodeBags.AddQueryOption('$filter', $nodeBagsFilter) | Select;

            $createdNodeBags.Count | Should Be $countOfBags;
            for($i = 1; $i -le $countOfBags; $i++)
            {
                $nodeBagName = ("{0}-Name-{1}" -f $nodeName,$i);
                $nodeBagValue = ("{0}-Value-{1}" -f $nodeName,$i);
                
                $nodeBagsFilter = "Name eq '{0}'" -f $nodeBagName;
                $createdNodeBag = $svc.Core.ExternalNodeBags.AddQueryOption('$filter', $nodeBagsFilter) | Select;

                $createdNodeBag | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.ExternalNodeBag];
                $createdNodeBag.Name | Should Be $nodeBagName;
                $createdNodeBag.Value | Should Be $nodeBagValue;
                $createdNodeBag.ExternaldNodeId | Should Be $createdNode.Id;

                $createdNodeBag.Name = ("{0}-Updated" -f $nodeBagName);
                $createdNodeBag.Value = ("{0}-Updated" -f $nodeBagValue);
                $svc.Core.UpdateObject($createdNodeBag);
            }

            $svc.Core.SaveChanges();
            for($i = 1; $i -le $countOfBags; $i++)
            {
                $nodeBagName = ("{0}-Name-{1}-Updated" -f $nodeName,$i);
                $nodeBagValue = ("{0}-Value-{1}-Updated" -f $nodeName,$i);
                
                $nodeBagsFilter = "Name eq '{0}'" -f $nodeBagName;
                $createdNodeBag = $svc.Core.ExternalNodeBags.AddQueryOption('$filter', $nodeBagsFilter) | Select;

                $createdNodeBag | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.ExternalNodeBag];
                $createdNodeBag.Name | Should Be $nodeBagName;
                $createdNodeBag.Value | Should Be $nodeBagValue;
                $createdNodeBag.ExternaldNodeId | Should Be $createdNode.Id;
            }
        }
        
        It "Delete-ExternalNode" -Test {
                    
            $nodeName = "Delete-ExternalNode";
            $nodeId = 1;
            $node = CreateExternalNode $nodeId $nodeName;

            $svc.Core.AddToExternalNodes($node);
            $svc.Core.SaveChanges();

            $nodeFilter = ("Name eq '{0}'" -f $nodeName);
            $createdNode = $svc.Core.ExternalNodes.AddQueryOption('$filter', $nodeFilter).AddQueryOption('$top', 1) | Select;

            $createdNode | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.ExternalNode];
            $createdNode.NodeId | Should Be 1;
            $createdNode.ExternalId | Should Be ("Arbitrary-Id-{0}" -f $nodeId);
            $createdNode.ExternalType | Should Be "Arbitrary-Type";
            $createdNode.Name | Should Be $nodeName;

            $svc.Core.DeleteObject($createdNode);
            $svc.Core.SaveChanges();

            $nodeFilter = ("Name eq '{0}'" -f $nodeName);
            $deletedNode = $svc.Core.ExternalNodes.AddQueryOption('$filter', $nodeFilter).AddQueryOption('$top', 1) | Select;

            $deletedNode | Should Be $null;
        }
	
        It "Delete-ExternalNode-Also-Deletes-NodeBags" -Test {
            $nodeName = "Delete-ExternalNode-Also-Deletes-NodeBags";
            $nodeId = 1;
            $node = CreateExternalNode $nodeId $nodeName;

            $countOfBags = 20;

            $svc.Core.AddToExternalNodes($node);
            $svc.Core.SaveChanges();

            $nodeFilter = ("Name eq '{0}'" -f $nodeName);
            $createdNode = $svc.Core.ExternalNodes.AddQueryOption('$filter', $nodeFilter).AddQueryOption('$top', 1) | Select;

            for($i = 1; $i -le $countOfBags; $i++)
            {
                $nodeBagName = ("{0}-Name-{1}" -f $nodeName,$i);
                $nodeBagValue = ("{0}-Value-{1}" -f $nodeName,$i);

                $nodebag = CreateExternalNodeBag $createdNode.Id $nodeBagName $nodeBagValue;
                
                $svc.Core.AddToExternalNodeBags($nodebag);
                $svc.Core.SaveChanges();
            }

            $svc.Core.DeleteObject($createdNode);
            $svc.Core.SaveChanges();
            
            $nodeBagsFilter = "ExternaldNodeId eq {0}" -f $createdNode.Id;
            $createdNodeBags = $svc.Core.ExternalNodeBags.AddQueryOption('$filter', $nodeBagsFilter) | Select;

            $createdNodeBags.Count | Should Be 0;
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

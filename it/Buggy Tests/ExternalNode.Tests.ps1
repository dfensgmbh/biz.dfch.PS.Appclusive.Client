#includes tests for CLOUDTCL-

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

	Context "#CLOUDTCL--ExternalNodesTests" {
	
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;
			$svc = Enter-Appclusive;
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
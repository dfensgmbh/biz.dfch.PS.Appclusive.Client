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
	$usedEntitySets = @("Nodes", "ExternalNodes", "Acls", "Aces", "EntityBags");

	Context "#CLOUDTCL-2190-DeleteNodeWithChildNode" {
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
		
		It "DeleteNodeWithChildNode" -Test {
			#ARRANGE
			$nodeName = $entityPrefix + "node";
			$childName = $entityPrefix + "childnode";
			
			#ACT create node
			$newNode = New-ApcNode -Name $nodeName -ParentId 1 -EntityKindId 1 -svc $svc | select;
			
			#get Id of the node
			$nodeId = $newNode.Id;
			
			#ACT create child Node
			$newChildNode = New-ApcNode -Name $childName -ParentId $nodeId -EntityKindId 1 -svc $svc | select;
			
			#get Id of the child Node
			$childNodeId = $newChildNode.Id;
			
			#get parent & child Node
			$parentNode = Get-ApcNode -Id $nodeId -svc $svc | select;
			$childNode = Get-ApcNode -Id $childNodeId -svc $svc | select;
			
			#ASSERT parent & child Node creation
			$parentNode | Should Not Be $null;
			$parentNode.Id | Should Not Be $null;
			$childNode | Should Not Be $null;
			$childNode.Id | Should Not Be $null;
			$childNode.ParentId | Should Be $nodeId;
			
			try
			{
				#get the parent node
				$parentNode = Get-ApcNode -Id $nodeId -svc $svc | select;
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
				$childNode = Get-ApcNode -Id $childNodeId -svc $svc | select;
	
				#delete the child node first
				$svc.Core.DeleteObject($childNode);
				$result = $svc.Core.SaveChanges();
				
				#get the parent node
				$parentNode = Get-ApcNode -Id $nodeId -svc $svc | select;
	
				#delete the parent node
				$svc.Core.DeleteObject($parentNode);
				$result = $svc.Core.SaveChanges();
			}
			
		}
		
		It "DeleteNodeCheckAttatchedEntitiesDeletion" -Test {
			#ARRANGE
			$nodeName = $entityPrefix + "newtestnode";
			$extName = $entityPrefix + "external-test-node";
			
			#ACT create node
			$newNode = New-ApcNode -Name $nodeName -ParentId 1 -EntityKindId 1 | select;
			
			#get Id of the node
			$nodeId = $newNode.Id;
			
			#get the job of the node
			$job = Get-ApcNode -Id $nodeId -ExpandJob | select;
			$jobId = [int] $job.Id;
			
			#create external node
			$extNode = New-ApcExternalNode -Name $extName -NodeId $nodeId ;
			
			
			
			<#
			
			$extNode = New-Object biz.dfch.CS.Appclusive.Api.Core.ExternalNode;
			$extNode.Name = $extName;
			$extNode.ExternalId = "509f27d7-4380-42fa-ac6d-0731c8f2111c";
			$extNode.ExternalType = "Cimi";
			$extNode.NodeId = $nodeId;
			$svc.Core.AddToExternalNodes($extNode);
			$result = $svc.Core.SaveChanges();
			<#
			$result.StatusCode | Should Be 201;
			#get the externa Node
			$query = "Name eq '{0}' and NodeId eq {1}" -f $extName, $nodeId;
			$extNode = $svc.Core.ExternalNodes.AddQueryOption('$filter', $query) | select;
			$extNode | Should Not Be $null;
			$extNodeId = $extNode.Id;
			
			#create ACL
			$aclName = $entityPrefix + "newTestAcl";
			$aclDescr = "Test Acl";
			$acl = New-Object biz.dfch.CS.Appclusive.Api.Core.Acl;
			$acl.Name = $aclName;
			$acl.Description = $aclDescr;
			$acl.EntityId = $nodeId;
			$acl.EntityKindId = 1;
			$acl.Tid = "11111111-1111-1111-1111-111111111111";
			$svc.Core.AddToAcls($acl);
			$result = $svc.Core.SaveChanges();
			
			#get ACL
			$query = "Name eq '{0}' and EntityId eq {1}" -f $aclName, $nodeId;
			$acl = $svc.Core.Acls.AddQueryOption('$filter', $query) | select;
			$acl | Should Not Be $null;
			$aclId = $acl.Id;
			
			#create ACE
			$aceName = $entityPrefix + "newTestAce";
			$aceDescr = "Test Ace";
			$ace = New-Object biz.dfch.CS.Appclusive.Api.Core.Ace;
			$ace.Name = $aceName;
			$ace.Description = $aceDescr;
			$ace.AclId = $aclId;
			$ace.Tid = "11111111-1111-1111-1111-111111111111";
			$username = $ENV:USERNAME;
			$query = "Name eq '{0}'" -f $username;
			$user = $svc.Core.Users.AddQueryOption('$filter', $query) | select;
			$userId = $user.Id;
			$ace.TrusteeId = $userId;
			$ace.TrusteeType = 1; #1 for users
			$ace.Type = 2;
			$ace.PermissionId = 2;
			$svc.Core.AddToAces($ace);
			$result = $svc.Core.SaveChanges();
			
			#get ACE
			$query = "Name eq '{0}' and AclId eq {1}" -f $aceName, $aclId;
			$ace = $svc.Core.Aces.AddQueryOption('$filter', $query) | select;
			$ace | Should Not Be $null;
			$aceId = $ace.Id;
						
			#create EntityBag
			$entityBagName = $entityPrefix + "newTestEntityBag";
			$entityBag = New-Object biz.dfch.CS.Appclusive.Api.Core.EntityBag;
			$entityBag.Name = $entityBagName;
			$entityBag.EntityId = $nodeId;
			$entityBag.EntityKindId = 1;
			$entityBag.Tid = "11111111-1111-1111-1111-111111111111";
			$entityBag.Value = 20;
			$svc.Core.AddToEntityBags($entityBag);
			$result = $svc.Core.SaveChanges();
			
			#get EntityBag
			$query = "Name eq '{0}' and EntityId eq {1}" -f $entityBagName, $nodeId;
			$entityBag = $svc.Core.EntityBags.AddQueryOption('$filter', $query) | select;
			$entityBag | Should Not Be $null;
			$entityBagId = $entityBag.Id;
			
			#ACT delete Node
			$query = "Id eq {0}" -f $nodeId;
			$node = $svc.Core.Nodes.AddQueryOption('$filter', $query) | select;
			$svc.Core.DeleteObject($node);
			$result = $svc.Core.SaveChanges();
			
			#ASSERT
			#check that node is deleted
			$query = "Id eq {0}" -f $nodeId;
			$node = $svc.Core.Nodes.AddQueryOption('$filter', $query) | select;
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
			#>
			
		}
		

		
		
	}
}
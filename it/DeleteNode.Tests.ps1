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
			$nodeName = $entityPrefix + "node";
			$extName = $entityPrefix + "externalnode";
			$aclName = $entityPrefix + "Acl";
			$aceName = $entityPrefix + "Ace";
			$entityBagName = $entityPrefix + "entityBag";
			
			#ACT create node
			$newNode = New-ApcNode -Name $nodeName -ParentId 1 -EntityKindId 1 -svc $svc| select;
			
			#get Id and entityKindId of the node
			$nodeId = $newNode.Id;
			$nodeEntityKindId = $newNode.EntityKindId;
			
			#get the job of the node
			$job = Get-ApcNode -Id $nodeId -ExpandJob | select;
			$jobId = [int] $job.Id;
			
			#create external node
			$extNode = New-ApcExternalNode -name $extName -NodeId $nodeId -ExternalId $nodeId -ExternalType "ArbitraryType" -svc $svc | select;
			#Write-Host ($extNode2 | out-string);
			
			#ASSERT external Node
			$extNode | Should Not Be $null;
			#get id of external node
			$extNodeId = $extNode.Id;
			
			#ACT create acl
			$acl = Create-Acl -svc $svc -aclName $aclName -entityId $nodeId -entityKindId $nodeEntityKindId | select;
			
			#get Id of the acl
			$aclId = $acl.Id;
			
			#ACT Create Ace
			$ace = Create-Ace -svc $svc -aceName $aceName -aclId $aclId | select;
			
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
			$node = Get-ApcNode -Id $nodeId -svc $svc | select;
			$svc.Core.DeleteObject($node);
			$result = $svc.Core.SaveChanges();
			
			#ASSERT
			#check that node is deleted
			$node = Get-ApcNode -Id $nodeId -svc $svc | select;
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
		

		
		
	}
}
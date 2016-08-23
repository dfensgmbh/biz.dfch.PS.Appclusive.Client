#Includes tests for test case CLOUDTCL-1873

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe -Tags "Node.Tests" "Node.Tests" {

	Mock Export-ModuleMember { return $null; }
	
	$entityPrefix = "TestItem-";
	$usedEntitySets = @("Nodes");
	$nodeEntityKindId = [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::Node.value__;

	Context "#CLOUDTCL-1873-NodeTests" {
		
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;
			$svc = Enter-Appclusive;
			$nodeParentId = (Get-ApcTenant -Current -svc $svc).NodeId;
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
		
		It "CreateNode" -Test {
			#ARRANGE
			$nodeName = $entityPrefix + "node";
			$nodeDescription = "node description";
			
			#ACT create node
			$node = New-ApcNode -Name $nodeName -Description $nodeDescription -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			
			#ASSERT Node creation
			$node | Should Not Be $null;
			$node.Id | Should Not Be $null;
			$node.Name | Should Be $nodeName;
			$node.Description | Should Be $nodeDescription;
		}
		
		It "CreateParentAndChildNode" -Test {
			#ARRANGE
			$nodeName = $entityPrefix + "node";
			$childName = $entityPrefix + "childnode";
			
			#ACT create node
			$parentNode = New-ApcNode -Name $nodeName -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			
			#get Id of the node
			$nodeId = $parentNode.Id;
			
			#ACT create child Node
			$childNode = New-ApcNode -Name $childName -ParentId $nodeId -EntityKindId $nodeEntityKindId -svc $svc;
			
			#ASSERT parent & child Node creation
			$parentNode | Should Not Be $null;
			$parentNode.Id | Should Not Be $null;
			$parentNode.Name | Should Be $nodeName;
			$childNode | Should Not Be $null;
			$childNode.Id | Should Not Be $null;
			$childNode.ParentId | Should Be $nodeId;
			$childNode.Name | Should Be $childName;
			
			#CLEANUP - Remove child node (The AfterEach block will handle parent node)
			Remove-ApcNode -id $childNode.Id -Confirm:$false -svc $svc;
		}
		
		It "LoadChildNodes" -Test {
			#ARRANGE
			$nodeName = $entityPrefix + "node";
			$childName1 = $entityPrefix + "childnode1";
			$childName2 = $entityPrefix + "childnode2";
			
			#ACT create node
			$parentNode = New-ApcNode -Name $nodeName -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			
			#get Id of the node
			$nodeId = $parentNode.Id;
			
			#ACT create child Node
			$childNode1 = New-ApcNode -Name $childName1 -ParentId $nodeId -EntityKindId $nodeEntityKindId -svc $svc;
			$childNode2 = New-ApcNode -Name $childName2 -ParentId $nodeId -EntityKindId $nodeEntityKindId -svc $svc;
			
			#ASSERT parent & child Node creation
			$parentNode | Should Not Be $null;
			$parentNode.Id | Should Not Be $null;
			$parentNode.Name | Should Be $nodeName;
			$childNode1 | Should Not Be $null;
			$childNode1.Id | Should Not Be $null;
			$childNode1.ParentId | Should Be $nodeId;
			$childNode1.Name | Should Be $childName1;
			$childNode2 | Should Not Be $null;
			$childNode2.Id | Should Not Be $null;
			$childNode2.ParentId | Should Be $nodeId;
			$childNode2.Name | Should Be $childName2;
			
			#ACT
			$childNodes = $svc.Core.LoadProperty($parentNode, 'Children') | Select;
			
			#ASSERT
			$childNodes | Should Not Be $null;
			$childNodes.Id -contains $childNode1.Id | Should be $true;
			$childNodes.Id -contains $childNode2.Id | Should be $true;
			
			#CLEANUP - Remove child nodes (The AfterEach block will handle parent node)
			Remove-ApcNode -id $childNode1.Id -Confirm:$false -svc $svc;
			Remove-ApcNode -id $childNode2.Id -Confirm:$false -svc $svc;
		}
		
		It "LoadParentNode" -Test {
			#ARRANGE
			$nodeName = $entityPrefix + "node";
			$childName = $entityPrefix + "childnode";
			
			#ACT create node
			$parentNode = New-ApcNode -Name $nodeName -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			
			#get Id of the node
			$nodeId = $parentNode.Id;
			
			#ACT create child Node
			$childNode = New-ApcNode -Name $childName -ParentId $nodeId -EntityKindId $nodeEntityKindId -svc $svc;
			
			#ACT
			$loadedParentNode = $svc.Core.LoadProperty($childNode, 'Parent') | Select;
				
			#ASSERT
			$loadedParentNode | Should Not Be $null;
			$loadedParentNode.Id | Should be $nodeId;
			
			#CLEANUP - Remove child node (The AfterEach block will handle parent node)
			Remove-ApcNode -id $childNode.Id -Confirm:$false -svc $svc;	
		}
		
		It "SetNodeAsChildToAnotherNode" -Test {
			#ARRANGE
			$nodeName1 = $entityPrefix + "node1";
			$nodeName2 = $entityPrefix + "node2";
			
			#ACT create nodes
			$node1 = New-ApcNode -Name $nodeName1 -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			$node2 = New-ApcNode -Name $nodeName2 -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			
			#get ids of nodes
			$node1Id = $node1.Id;
			$node2Id = $node2.Id;
			
			#ASSERT Nodes creation
			$node1 | Should Not Be $null;
			$node1.Id | Should Not Be $null;
			$node1.Name | Should Be $nodeName1;
			$node2 | Should Not Be $null;
			$node2.Id | Should Not Be $null;
			$node2.Name | Should Be $nodeName2;
			$childrenOfNode1 = $svc.Core.LoadProperty($node1, 'Children') | Select;
			$childrenOfNode1 | Should be $null;
			$childrenOfNode2 = $svc.Core.LoadProperty($node2, 'Children') | Select;
			$childrenOfNode2 | Should be $null;
			
			#ACT set node1 as parent of node2
			$svc.Core.SetLink($node2, "Parent", $node1);
			$updateResult = $svc.Core.SaveChanges();
			
			#Assert
			$parentNodeReload = $svc.Core.LoadProperty($node2, 'Parent') | Select;
			$childNodeReload = $svc.Core.LoadProperty($node1, 'Children') | Select;
			
			#ASSERT
			$updateResult.StatusCode | Should Be 204;
			$parentNodeReload.Id | Should Be $node1.Id;
			$childNodeReload.Id | Should Be $node2.Id;
			
			#Reload the service connection and the node2 so we assert the parentId change
			$svc = Enter-Appclusive;
			$node2Reload = Get-ApcNode -id $node2Id;
			$node2Reload.ParentId | Should Be $node1Id;
			
			#CLEANUP - Remove child node (The AfterEach block will handle parent node)
			Remove-ApcNode -id $node2Id -Confirm:$false -svc $svc;
		}
		
		<# it fails now, will be deployed on next release
		It "SetNodeAsItsOwnParent-ThrowsError" -Test {
			#ARRANGE
			$nodeName = $entityPrefix + "node";
			
			#ACT create node
			$node = New-ApcNode -Name $nodeName -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -svc $svc;
			
			#get id of node
			$nodeId = $node.Id;
			
			#ASSERT Node creation
			$node | Should Not Be $null;
			$node.Id | Should Not Be $null;
			$node.Name | Should Be $nodeName;
			$node.Description | Should Be $nodeDescription;
			
			#ACT set node as its own parent
			$svc.Core.SetLink($node, "Parent", $node);
				
			try
			{
				$updateResult = $Svc.Core.SaveChanges();
			}
			
			catch
			{
				$exception = ConvertFrom-Json $error[0].Exception.InnerException.InnerException.Message;
				$exception.'odata.error'.message.value | Should Be "An error has occurred.";
				$_.Exception.Message | Should Not Be $null;
				$_.FullyQualifiedErrorId | Should Not Be $null;
				Write-Host ($_.Exception.Message | Out-String);
				Write-Host ($_.FullyQualifiedErrorId | Out-String);
			}
			finally
			{
				#CLEANUP
				$svc = Enter-Appclusive;
				Remove-ApcNode -id $nodeId -Confirm:$false -svc $svc;
			}
		}#>
		
		It "CreateWithJobConditionParametersSucceeds" -Test {
			# Arrange
			$parentId = 1L;
			$entityKindId = 1L;
			$parameters = '{}';
			$jsonObject = '{
				"red":"#f00",
				"green":"#0f0",
				"blue":"#00f",
				"cyan":"#0ff",
				"magenta":"#f0f",
				"yellow":"#ff0",
				"black":"#000"
			}'
			
			$jobConditionParameters = $jsonObject | ConvertTo-Json -Compress;
			$nodeCreationParameters = @{
				Name = "Arbitrary name";
				Description = "Arbitrary description";
				EntityKindId = $entityKindId;
				ParentId = $parentId;
				Parameters = $parameters;
				JobConditionParameters = $jobConditionParameters.ToString();
			}
			
			# Act
			$nodeCreateResult = $svc.Core.InvokeEntitySetActionWithSingleResult("Nodes", "CreateWithJobConditionParameters", [biz.dfch.CS.Appclusive.Api.Core.JobResponse], $nodeCreationParameters);
			Contract-Assert (!!$nodeCreateResult);
			
			$job = Get-ApcJob -Id $nodeCreateResult.Id
			$node = Get-ApcNode -Id $job.RefId;
			
			try 
			{
				#Assert	
				$node | Should Not Be $null;
				$node.Id | Should Not Be 0;
				$node.Name | Should Be "Arbitrary name";
				$node.Description | Should Be "Arbitrary description";
				$node.ParentId | Should Be $parentId;
				$node.EntityKindId | Should Be $entityKindId;
				$node.Parameters | Should Be $parameters;
				
				$job | Should Not Be $null;
				$job.Id | Should Not Be 0;
				$job.RefId | Should Be $node.Id;
				$job.Status | Should Be "InitialState";
				$job.Condition | Should Be "Initialise";
				$job.ConditionParameters | Should Be $jobConditionParameters.ToString();
			} 
			finally 
			{
				#Cleanup
				$null = Remove-ApcEntity -Id $job.Id -EntitySetName "Jobs" -Confirm:$false;
				$null = Remove-ApcEntity -Id $node.Id -EntitySetName "Nodes" -Confirm:$false;
			}
		}
		
		It "DoStateChangeOnNodeSetsConditionAndConditionParametersOnJob" -Test {
			# Arrange
			$nodeName = $entityPrefix + "node";
			$condition = 'Continue';
			$conditionParams = @{Msg = "tralala"};
			
			$node = New-ApcNode -Name $nodeName -ParentId $nodeParentId -EntityKindId $nodeEntityKindId -Parameters @{} -svc $svc;
			
			$query = "RefId eq '{0}'" -f $node.Id;
			$job = $svc.Core.Jobs.AddQueryOption('$filter', $query) | Select;
			
			$jobResult = @{Version = "1"; Message = "Msg"; Succeeded = $true};
			Invoke-ApcEntityAction -InputObject $job -EntityActionName "JobResult" -InputParameters $jobResult;
			
			# Act
			$result = Invoke-ApcEntityAction -InputObject $node -EntityActionName "InvokeAction" -InputName $condition -InputParameters $conditionParams;
			
			try 
			{
				# Assert
				$svc = Enter-ApcServer;
				$result | Should Not Be $null;
				$resultingJob = Get-ApcJob -Id $job.Id -svc $svc;
				$resultingJob.Condition | Should Be $condition;
				$resultingJob.ConditionParameters | Should Be ($conditionParams | ConvertTo-Json -Compress);
			}
			finally 
			{
				# Cleanup
				$null = Remove-ApcEntity -Id $job.Id -EntitySetName "Jobs" -Confirm:$false;
				$null = Remove-ApcEntity -Id $node.Id -EntitySetName "Nodes" -Confirm:$false;
			}
		}
		
		
		
		It "GetAssignablePermissionsForConfigurationNode-ReturnsIntrinsicEntityKindNonNodePermissions" -Test {
			# Arrange
			$configurationRootNodeId = 2; #System tenant configuration node
			#$approvalEntityKindId = 5;
			$query = "Id gt {0}" -f [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::ReservationEnd.value__;
			$approvalEntityKindId = ($svc.Core.EntityKinds.AddQueryOption('$filter', $query) | Select -First 1).id;
			$nodeName = $entityPrefix + "node";
			
			$configurationNode = New-Object biz.dfch.CS.Appclusive.Api.Core.Node;
			$configurationNode.Parameters = "{}";
			$configurationNode.EntityKindId = $approvalEntityKindId;
			$configurationNode.EntityId = 42;
			$configurationNode.ParentId = $configurationRootNodeId;
			$configurationNode.Name = $nodeName;
			
			$svc.Core.AddToNodes($configurationNode);
			$null = $svc.Core.SaveChanges();
			#Write-Host ($configurationNode | Out-String);
			
			$configurationNode = Get-ApcNode -Name $nodeName -ParentId $configurationRootNodeId;
			$configurationNodeJob = Get-ApcNode -Id $configurationNode.Id -ExpandJob;
			
			try 
			{
				# Act
				$assignablePermissions = $svc.Core.InvokeEntityActionWithListResult($configurationNode, "GetAssignablePermissions", [biz.dfch.CS.Appclusive.Api.Core.Permission], $null);
				
				# Assert
				$assignablePermissions | Should Not Be $null;
				# All permissions for EntityKinds except CRUD permissions for
				# Nodes and its subtypes like Folders, ScheduledJobs, ScheduledJobInstances, Machines and Networks
				# And except CRUD for ActiveDirectoryUsers, Persons, CimiTargets, Endpoints and permissions for SpecialOperations as there are no EntityKinds defined for
				$assignablePermissions.Name -contains "Apc:TenantsCanRead" | Should Be $true;
				$assignablePermissions.Name -contains "Apc:UsersCanDelete" | Should Be $true;
				$assignablePermissions.Name -contains "Apc:NetworksCanRead" | Should Not Be $true;
				$assignablePermissions.Name -contains "Apc:FoldersCanDelete" | Should Not Be $true;
			}
			finally
			{
				# Cleanup
				$null = Remove-ApcEntity -Id $configurationNodeJob.Id -EntitySetName "Jobs" -Confirm:$false;
				$null = Remove-ApcEntity -Id $configurationNode.Id -EntitySetName "Nodes" -Confirm:$false;
			}
		}
		
		It "GetAssignablePermissionsForRootNode-ReturnsPermissionsExceptIntrinsicEntityKindNonNodePermissions" -Test {
			# Arrange
			$rootNodeId = 1L; #system tenant root node
			$rootNode = Get-ApcNode -Id $rootNodeId;
			
			$allPermissions = New-Object System.Collections.Generic.List``1[biz.dfch.CS.Appclusive.Api.Core.Permission];
			
			$query = $svc.Core.Permissions;
			$permissions = $query.Execute();
	
			while($true) 
			{
				foreach($permission in $permissions)
				{
					$allPermissions.Add($permission);
				}
			
				$continuation = $permissions.GetContinuation();
				if ($continuation -eq $null)
				{
					break;
				}
				
				$permissions = $Svc.core.Execute($continuation);
			}
			
			# Act
			$assignablePermissions = $svc.Core.InvokeEntityActionWithListResult($rootNode, "GetAssignablePermissions", [biz.dfch.CS.Appclusive.Api.Core.Permission], $null);
			
			# Assert
			$assignablePermissions | Should Not Be $null;
			# All product related permissions + permissions for
			# Nodes and its subtypes like Folders, ScheduledJobs, ScheduledJobInstances, Machines and Networks
			$assignablePermissions.Name -contains "Apc:NetworksCanRead" | Should Be $true;
			$assignablePermissions.Name -contains "Apc:FoldersCanDelete" | Should Be $true;
			$assignablePermissions.Name -contains "Apc:TenantsCanRead" | Should Not Be $true;
			$assignablePermissions.Name -contains "Apc:UsersCanDelete" | Should Not Be $true;
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

# SIG # Begin signature block
# MIIXDwYJKoZIhvcNAQcCoIIXADCCFvwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU+Zy6OevvPdXED1Q8MxTl7YK2
# ksSgghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
# VzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNV
# BAsTB1Jvb3QgQ0ExGzAZBgNVBAMTEkdsb2JhbFNpZ24gUm9vdCBDQTAeFw0xMTA0
# MTMxMDAwMDBaFw0yODAxMjgxMjAwMDBaMFIxCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMSgwJgYDVQQDEx9HbG9iYWxTaWduIFRpbWVzdGFt
# cGluZyBDQSAtIEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlO9l
# +LVXn6BTDTQG6wkft0cYasvwW+T/J6U00feJGr+esc0SQW5m1IGghYtkWkYvmaCN
# d7HivFzdItdqZ9C76Mp03otPDbBS5ZBb60cO8eefnAuQZT4XljBFcm05oRc2yrmg
# jBtPCBn2gTGtYRakYua0QJ7D/PuV9vu1LpWBmODvxevYAll4d/eq41JrUJEpxfz3
# zZNl0mBhIvIG+zLdFlH6Dv2KMPAXCae78wSuq5DnbN96qfTvxGInX2+ZbTh0qhGL
# 2t/HFEzphbLswn1KJo/nVrqm4M+SU4B09APsaLJgvIQgAIMboe60dAXBKY5i0Eex
# +vBTzBj5Ljv5cH60JQIDAQABo4HlMIHiMA4GA1UdDwEB/wQEAwIBBjASBgNVHRMB
# Af8ECDAGAQH/AgEAMB0GA1UdDgQWBBRG2D7/3OO+/4Pm9IWbsN1q1hSpwTBHBgNV
# HSAEQDA+MDwGBFUdIAAwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFs
# c2lnbi5jb20vcmVwb3NpdG9yeS8wMwYDVR0fBCwwKjAooCagJIYiaHR0cDovL2Ny
# bC5nbG9iYWxzaWduLm5ldC9yb290LmNybDAfBgNVHSMEGDAWgBRge2YaRQ2XyolQ
# L30EzTSo//z9SzANBgkqhkiG9w0BAQUFAAOCAQEATl5WkB5GtNlJMfO7FzkoG8IW
# 3f1B3AkFBJtvsqKa1pkuQJkAVbXqP6UgdtOGNNQXzFU6x4Lu76i6vNgGnxVQ380W
# e1I6AtcZGv2v8Hhc4EvFGN86JB7arLipWAQCBzDbsBJe/jG+8ARI9PBw+DpeVoPP
# PfsNvPTF7ZedudTbpSeE4zibi6c1hkQgpDttpGoLoYP9KOva7yj2zIhd+wo7AKvg
# IeviLzVsD440RZfroveZMzV+y5qKu0VN5z+fwtmK+mWybsd+Zf/okuEsMaL3sCc2
# SI8mbzvuTXYfecPlf5Y1vC0OzAGwjn//UYCAp5LUs0RGZIyHTxZjBzFLY7Df8zCC
# BCkwggMRoAMCAQICCwQAAAAAATGJxjfoMA0GCSqGSIb3DQEBCwUAMEwxIDAeBgNV
# BAsTF0dsb2JhbFNpZ24gUm9vdCBDQSAtIFIzMRMwEQYDVQQKEwpHbG9iYWxTaWdu
# MRMwEQYDVQQDEwpHbG9iYWxTaWduMB4XDTExMDgwMjEwMDAwMFoXDTE5MDgwMjEw
# MDAwMFowWjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# MDAuBgNVBAMTJ0dsb2JhbFNpZ24gQ29kZVNpZ25pbmcgQ0EgLSBTSEEyNTYgLSBH
# MjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKPv0Z8p6djTgnY8YqDS
# SdYWHvHP8NC6SEMDLacd8gE0SaQQ6WIT9BP0FoO11VdCSIYrlViH6igEdMtyEQ9h
# JuH6HGEVxyibTQuCDyYrkDqW7aTQaymc9WGI5qRXb+70cNCNF97mZnZfdB5eDFM4
# XZD03zAtGxPReZhUGks4BPQHxCMD05LL94BdqpxWBkQtQUxItC3sNZKaxpXX9c6Q
# MeJ2s2G48XVXQqw7zivIkEnotybPuwyJy9DDo2qhydXjnFMrVyb+Vpp2/WFGomDs
# KUZH8s3ggmLGBFrn7U5AXEgGfZ1f53TJnoRlDVve3NMkHLQUEeurv8QfpLqZ0BdY
# Nc0CAwEAAaOB/TCB+jAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIB
# ADAdBgNVHQ4EFgQUGUq4WuRNMaUU5V7sL6Mc+oCMMmswRwYDVR0gBEAwPjA8BgRV
# HSAAMDQwMgYIKwYBBQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3Jl
# cG9zaXRvcnkvMDYGA1UdHwQvMC0wK6ApoCeGJWh0dHA6Ly9jcmwuZ2xvYmFsc2ln
# bi5uZXQvcm9vdC1yMy5jcmwwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHwYDVR0jBBgw
# FoAUj/BLf6guRSSuTVD6Y5qL3uLdG7wwDQYJKoZIhvcNAQELBQADggEBAHmwaTTi
# BYf2/tRgLC+GeTQD4LEHkwyEXPnk3GzPbrXsCly6C9BoMS4/ZL0Pgmtmd4F/ximl
# F9jwiU2DJBH2bv6d4UgKKKDieySApOzCmgDXsG1szYjVFXjPE/mIpXNNwTYr3MvO
# 23580ovvL72zT006rbtibiiTxAzL2ebK4BEClAOwvT+UKFaQHlPCJ9XJPM0aYx6C
# WRW2QMqngarDVa8z0bV16AnqRwhIIvtdG/Mseml+xddaXlYzPK1X6JMlQsPSXnE7
# ShxU7alVrCgFx8RsXdw8k/ZpPIJRzhoVPV4Bc/9Aouq0rtOO+u5dbEfHQfXUVlfy
# GDcy1tTMS/Zx4HYwggSfMIIDh6ADAgECAhIRIQaggdM/2HrlgkzBa1IJTgMwDQYJ
# KoZIhvcNAQEFBQAwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24g
# bnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzIw
# HhcNMTUwMjAzMDAwMDAwWhcNMjYwMzAzMDAwMDAwWjBgMQswCQYDVQQGEwJTRzEf
# MB0GA1UEChMWR01PIEdsb2JhbFNpZ24gUHRlIEx0ZDEwMC4GA1UEAxMnR2xvYmFs
# U2lnbiBUU0EgZm9yIE1TIEF1dGhlbnRpY29kZSAtIEcyMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAsBeuotO2BDBWHlgPse1VpNZUy9j2czrsXV6rJf02
# pfqEw2FAxUa1WVI7QqIuXxNiEKlb5nPWkiWxfSPjBrOHOg5D8NcAiVOiETFSKG5d
# QHI88gl3p0mSl9RskKB2p/243LOd8gdgLE9YmABr0xVU4Prd/4AsXximmP/Uq+yh
# RVmyLm9iXeDZGayLV5yoJivZF6UQ0kcIGnAsM4t/aIAqtaFda92NAgIpA6p8N7u7
# KU49U5OzpvqP0liTFUy5LauAo6Ml+6/3CGSwekQPXBDXX2E3qk5r09JTJZ2Cc/os
# +XKwqRk5KlD6qdA8OsroW+/1X1H0+QrZlzXeaoXmIwRCrwIDAQABo4IBXzCCAVsw
# DgYDVR0PAQH/BAQDAgeAMEwGA1UdIARFMEMwQQYJKwYBBAGgMgEeMDQwMgYIKwYB
# BQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3JlcG9zaXRvcnkvMAkG
# A1UdEwQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwQgYDVR0fBDswOTA3oDWg
# M4YxaHR0cDovL2NybC5nbG9iYWxzaWduLmNvbS9ncy9nc3RpbWVzdGFtcGluZ2cy
# LmNybDBUBggrBgEFBQcBAQRIMEYwRAYIKwYBBQUHMAKGOGh0dHA6Ly9zZWN1cmUu
# Z2xvYmFsc2lnbi5jb20vY2FjZXJ0L2dzdGltZXN0YW1waW5nZzIuY3J0MB0GA1Ud
# DgQWBBTUooRKOFoYf7pPMFC9ndV6h9YJ9zAfBgNVHSMEGDAWgBRG2D7/3OO+/4Pm
# 9IWbsN1q1hSpwTANBgkqhkiG9w0BAQUFAAOCAQEAgDLcB40coJydPCroPSGLWaFN
# fsxEzgO+fqq8xOZ7c7tL8YjakE51Nyg4Y7nXKw9UqVbOdzmXMHPNm9nZBUUcjaS4
# A11P2RwumODpiObs1wV+Vip79xZbo62PlyUShBuyXGNKCtLvEFRHgoQ1aSicDOQf
# FBYk+nXcdHJuTsrjakOvz302SNG96QaRLC+myHH9z73YnSGY/K/b3iKMr6fzd++d
# 3KNwS0Qa8HiFHvKljDm13IgcN+2tFPUHCya9vm0CXrG4sFhshToN9v9aJwzF3lPn
# VDxWTMlOTDD28lz7GozCgr6tWZH2G01Ve89bAdz9etNvI1wyR5sB88FRFEaKmzCC
# BNYwggO+oAMCAQICEhEhDRayW4wRltP+V8mGEea62TANBgkqhkiG9w0BAQsFADBa
# MQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTEwMC4GA1UE
# AxMnR2xvYmFsU2lnbiBDb2RlU2lnbmluZyBDQSAtIFNIQTI1NiAtIEcyMB4XDTE1
# MDUwNDE2NDMyMVoXDTE4MDUwNDE2NDMyMVowVTELMAkGA1UEBhMCQ0gxDDAKBgNV
# BAgTA1p1ZzEMMAoGA1UEBxMDWnVnMRQwEgYDVQQKEwtkLWZlbnMgR21iSDEUMBIG
# A1UEAxMLZC1mZW5zIEdtYkgwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDNPSzSNPylU9jFM78Q/GjzB7N+VNqikf/use7p8mpnBZ4cf5b4qV3rqQd62rJH
# RlAsxgouCSNQrl8xxfg6/t/I02kPvrzsR4xnDgMiVCqVRAeQsWebafWdTvWmONBS
# lxJejPP8TSgXMKFaDa+2HleTycTBYSoErAZSWpQ0NqF9zBadjsJRVatQuPkTDrwL
# eWibiyOipK9fcNoQpl5ll5H9EG668YJR3fqX9o0TQTkOmxXIL3IJ0UxdpyDpLEkt
# tBG6Y5wAdpF2dQX2phrfFNVY54JOGtuBkNGMSiLFzTkBA1fOlA6ICMYjB8xIFxVv
# rN1tYojCrqYkKMOjwWQz5X8zAgMBAAGjggGZMIIBlTAOBgNVHQ8BAf8EBAMCB4Aw
# TAYDVR0gBEUwQzBBBgkrBgEEAaAyATIwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93
# d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wCQYDVR0TBAIwADATBgNVHSUE
# DDAKBggrBgEFBQcDAzBCBgNVHR8EOzA5MDegNaAzhjFodHRwOi8vY3JsLmdsb2Jh
# bHNpZ24uY29tL2dzL2dzY29kZXNpZ25zaGEyZzIuY3JsMIGQBggrBgEFBQcBAQSB
# gzCBgDBEBggrBgEFBQcwAoY4aHR0cDovL3NlY3VyZS5nbG9iYWxzaWduLmNvbS9j
# YWNlcnQvZ3Njb2Rlc2lnbnNoYTJnMi5jcnQwOAYIKwYBBQUHMAGGLGh0dHA6Ly9v
# Y3NwMi5nbG9iYWxzaWduLmNvbS9nc2NvZGVzaWduc2hhMmcyMB0GA1UdDgQWBBTN
# GDddiIYZy9p3Z84iSIMd27rtUDAfBgNVHSMEGDAWgBQZSrha5E0xpRTlXuwvoxz6
# gIwyazANBgkqhkiG9w0BAQsFAAOCAQEAAApsOzSX1alF00fTeijB/aIthO3UB0ks
# 1Gg3xoKQC1iEQmFG/qlFLiufs52kRPN7L0a7ClNH3iQpaH5IEaUENT9cNEXdKTBG
# 8OrJS8lrDJXImgNEgtSwz0B40h7bM2Z+0DvXDvpmfyM2NwHF/nNVj7NzmczrLRqN
# 9de3tV0pgRqnIYordVcmb24CZl3bzpwzbQQy14Iz+P5Z2cnw+QaYzAuweTZxEUcJ
# bFwpM49c1LMPFJTuOKkUgY90JJ3gVTpyQxfkc7DNBnx74PlRzjFmeGC/hxQt0hvo
# eaAiBdjo/1uuCTToigVnyRH+c0T2AezTeoFb7ne3I538hWeTdU5q9jGCBLcwggSz
# AgEBMHAwWjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# MDAuBgNVBAMTJ0dsb2JhbFNpZ24gQ29kZVNpZ25pbmcgQ0EgLSBTSEEyNTYgLSBH
# MgISESENFrJbjBGW0/5XyYYR5rrZMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEM
# MQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQB
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRsqN/DbelCrOEE
# N5ol9fL4whWxhjANBgkqhkiG9w0BAQEFAASCAQBxxL5wvCnoY/o2VBRhLicorlQY
# hMLdtgjOVlEIPZvPohqWOxZJLysMmB5Y2K30/8GG4hRnNoetw30obY9SwQs0U08W
# 5jW8jY20xNgyaVAI9sfF6LEeu853Jn68nk2WP/tfVGNMzOom9cKwdJd2huQJE3TZ
# sXbT5S6yduxmIXQvUrlDdtTZXn13HY9YC7o+H7jYIxbIMK1XHzqiJBR27etEeaMn
# Av5daAVMWUgEJU9Xbd6PeLO977NKq2rcM2T8FyYoffmV1dVgjjB+TLFpokpsQkPO
# 3soEezyUqr3HIMM9VvH1ytJthqe2bRZIDf5Y6gWi5snHZPUSIFOWB7eYlqQLoYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEhBqCB0z/YeuWCTMFrUglOAzAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE2
# MDcwNDExMjIyNFowIwYJKoZIhvcNAQkEMRYEFKkgisdtXAD6cF3D2jMgoTpJ3JVA
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUs2MItNTN7U/PvWa5Vfrjv7Es
# KeYwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# BqCB0z/YeuWCTMFrUglOAzANBgkqhkiG9w0BAQEFAASCAQCtrpgHNwa6W/vqMLtW
# 8QwoeN9A7V1M9bhNi0ttRWhogQ3+6aDP66ll5NBgKIc7LHE6WcopqOPbfZLLqY09
# vGRGL6LLtZzQ5cjtrP1/VX95A3hZcUYDLxFYAmMHhFEM8sGjmJf4uB3eENmNjSAZ
# olQkYe+NInEIy7UUtDP2cL4esZ6W+n/kfP8JJK9Cqnjj3JOZykACudVRObGPhnOn
# Wz2t8KVZW+OSeFUZE3LHFSYjHcAKKe53QRILrLfXPF2L1oM71GsUBTxr1iqwuPWS
# CWLbfbI673OiNcGyLsyYHXGcAPDdkOA1k5nO/9VfWlOngqIGxLTwC/vtkWUbnvl6
# 845e
# SIG # End signature block

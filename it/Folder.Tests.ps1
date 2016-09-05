# includes tests for CLOUDTCL-1882

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe -Tags "Folder.Tests" "Folder.Tests" {

	Mock Export-ModuleMember { return $null; }
	. "$here\$sut"
	$entityPrefix = "TestItem-";
	$usedEntitySets = @("Folders");
	
	Context "#CLOUDTCL-1882-FolderTests" {
		
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
		
		It "Folder-CreateAndDeleteShouldSucceed" -Test {
			#ARRANGE
			$name = $entityPrefix + "Folder";
			$description = "folder description";
			
			#ACT create folder
			$folder = Create-Folder -Svc $svc -Name $name -Description $description;
			
			#ASSERT
			$folder | Should Not Be $null;
			$folder.Id | Should Not Be 0;
			$folder.Name | Should Be $name;
			$folder.Description | Should Be $description;
	
			#get folder id
			$folderId = $folder.Id;
			
			#ACT delete folder
			Remove-ApcEntity -svc $svc -Id $folderId -EntitySetName "Folders" -Confirm:$false;
			
			#get the deleted folder
			$query = "Id eq {0}" -f $folderId;
			$deletedFolder = $svc.Core.Folders.AddQueryOption('$filter', $query) | Select;
			
			#ASSERT folder is deleted
			$deletedFolder | Should Be $null;
		}
		
		It "Folder-UpdateShouldSucceed" -Test {
			#ARRANGE
			$folderName = $entityPrefix + "Folder";
			$newName = $folderName + " Updated";
			$newDescription = "Description Updated";
			
			#ACT create folder
			$folder = Create-Folder -Svc $svc -Name $folderName;
			
			#get folder id
			$folderId = $folder.Id;
			
			#ACT update folder
			$updatedFolder = Update-Folder -Svc $svc -Id $folderId -Name $newName -Description $newDescription;
			
			#ASSERT - update
			$updatedFolder.Id | Should Be $folderId;
			$updatedFolder.Name | Should Be $newName;
			$updatedFolder.Description | Should Be $newDescription;	
		}
		
		It "Folder-UpdateParentIdShouldFail" -Test {
			#ARRANGE
			$folderName = $entityPrefix + "Folder";
			$newParentId = ($svc.Core.Folders | Select -First 1).ParentId;
			
			#ACT create folder
			$folder = Create-Folder -Svc $svc -Name $folderName;
			
			#get folder id
			$folderId = $folder.Id;
			
			#ACT update parent Id of folder
			$folder.ParentId = $newParentId;
			$svc.Core.UpdateObject($folder);
			{ $result = $svc.Core.SaveChanges(); } | Should ThrowDataServiceClientException @{StatusCode = 400};
			
			#get the folder
			$svc = Enter-Appclusive;
			$query = "Id eq {0}" -f $folderId;
			$loadedFolder = $svc.Core.Folders.AddQueryOption('$filter', $query) | Select;
			
			#ASSERT
			$loadedFolder.ParentId | Should Not Be $newparentId;
		}
		
		It "CreateFolderInsideFolder" -Test {
			#ARRANGE
			$folderName1 = $entityPrefix + "Folder1";
			$folderName2 = $entityPrefix + "Folder2";
			
			#ACT create folder
			$folder1 = Create-Folder -Svc $svc -Name $folderName1;
			
			#get folder id
			$folder1Id = $folder1.Id;
			
			#ACT create folder2 inside folder1
			$folder2 = Create-Folder -Svc $svc -Name $folderName2 -ParentId $folder1Id;
			
			#ASSERT
			$folder2 | Should Not Be $null;
			$folder2.Id | Should Not Be 0;
			$folder2.Name | Should Be $folderName2;
			$folder2.ParentId | Should Be $folder1Id;
			
			#get folder 2 id
			$folder2Id = $folder2.Id;

			#CLEANUP delete folders
			Remove-ApcEntity -svc $svc -Id $folder2Id -EntitySetName "Folders" -Confirm:$false;
			Remove-ApcEntity -svc $svc -Id $folder1Id -EntitySetName "Folders" -Confirm:$false;
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


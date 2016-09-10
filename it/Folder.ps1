function Create-Folder {
	Param
	(
		$Svc
		,
		$Name
		,
		$Description = "Default Description"
		,
		$EntityKindId = [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::Folder.value__
		,
		$ParentId = (Get-ApcTenant -Current -svc $Svc).NodeId
		,
		$Tid = (Get-ApcTenant -Current -svc $Svc).Id
		,
		$Parameters = '{}'
	)

	$newFolder = New-Object biz.dfch.CS.Appclusive.Api.Core.Folder;
	$newFolder.Name = $Name;
	$newFolder.Description = $Description;
	$newFolder.EntityKindId = $EntityKindId;
	$newFolder.ParentId = $ParentId;
	$newFolder.Tid = $Tid;
	$newFolder.Parameters = $Parameters;
	
	#add to folders
	$svc.Core.AddToFolders($newFolder);
	$result = $svc.Core.SaveChanges();
	
	#get folder
	$query = "Name eq '{0}' and Description eq '{1}'" -f $Name, $Description;
	$folder = $svc.Core.Folders.AddQueryOption('$filter', $query) | Select;
	
	return $folder;
}

function Update-Folder{
	Param
	(
		$Svc
		,
		$Id
		,
		$Name
		,
		$Description
	)
	
	$null = Push-ApcChangeTracker -Svc $Svc;
	
	#get the folder
	$query = "Id eq {0}" -f $Id;
	$folder = $svc.Core.Folders.AddQueryOption('$filter', $query) | Select;
	
	#update the folder
	if ($Name) 
	{
		$folder.Name = $Name;
	}
	if ($Description) 
	{
		$folder.Description = $Description;
	}
	
	$svc.Core.UpdateObject($folder);
	$result = $svc.Core.SaveChanges();
	
	#get the updated product
	$query = "Id eq {0}" -f $Id;
	$updatedFolder = $svc.Core.Folders.AddQueryOption('$filter', $query) | Select;
	
	$null = Pop-ApcChangeTracker -Svc $Svc;
	
	return $updatedFolder;
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

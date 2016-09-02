function Create-Assoc{
Param
	(
		$Svc
		,
		$Name
		,
		$Description = "Arbitrary Assoc"
		,
		$SourceId
		,
		$DestinationId
		,
		$Order = 0
		,
		$Parameters
	)

	$null = Push-ApcChangeTracker -Svc $Svc;
	
	$newAssoc = New-Object biz.dfch.CS.Appclusive.Api.Core.Assoc;
	$newAssoc.Name = $Name;
	$newAssoc.Description = $Description;
	$newassoc.SourceId = $SourceId;
	$newAssoc.DestinationId = $DestinationId;
	$newAssoc.Order = $Order;
	if ($Parameters)
	{
		$newAssoc.Parameters = $Parameters;
	}
	
	$svc.Core.AddToAssocs($newassoc);
	$result = $svc.Core.SaveChanges();
	
	#ASSERT result
	$null = $result.StatusCode | Should be 201;
	
	#get the assoc
	$query = "Name eq '{0}'" -f $assocName;
	$assoc = $svc.core.Assocs.AddQueryOption('$filter', $query) | Select;
	
	$null = Pop-ApcChangeTracker -Svc $Svc;
	
	#attaches a detached entity to the ChangeTracker if not already attached
	$null = $svc.Core.AttachIfNeeded($assoc);
	
	return $assoc;
}

function Update-Assoc{
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
	
	#get the assoc
	$query = "Id eq {0}" -f $Id;
	$assoc = $svc.Core.Assocs.AddQueryOption('$filter', $query) | select;
	
	#update the assoc
	if ($Name)
	{
		$assoc.Name = $Name;
	}
	if ($Description)
	{
		$assoc.Description = $Description;
	}
	
	$svc.Core.UpdateObject($assoc);
	$result = $svc.Core.SaveChanges();
	
	#get the updated assoc
	$query = "Id eq {0}" -f $Id;
	$updatedAssoc = $svc.Core.Assocs.AddQueryOption('$filter', $query) | select;
	
	return $updatedAssoc;
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

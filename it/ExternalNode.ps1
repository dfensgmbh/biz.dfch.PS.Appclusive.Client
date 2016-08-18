function Create-ExternalNodeBag {
	Param
	(
		$Svc
		,
		$Name
		,
		$Description = "Test External Node Bag"
		,
		$Value = [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::EntityBag.value__
		,
		[Parameter(Mandatory=$true)] $ExternalNodeId
		,
		$Tid = (Get-ApcTenant -Current).Id
	)
	
	#add parameters
	$newExternalNodeBag = New-Object biz.dfch.CS.Appclusive.Api.Core.ExternalNodeBag;
	$newExternalNodeBag.Name = $name;
	$newExternalNodeBag.Description = $description;
	$newExternalNodeBag.Value = $value;
	$newExternalNodeBag.ExternaldNodeId = $externalNodeId;
	$newExternalNodeBag.Tid = $tid;
	
	#ACT create external node bag
	$svc.Core.AddToExternalNodeBags($newExternalNodeBag);
	$result = $svc.Core.SaveChanges();
	
	#get external node bag
	$query = "Id eq {0}" -f $newExternalNodeBag.Id;
	$externalNodeBag = $svc.Core.ExternalNodeBags.AddQueryOption('$filter', $query) | select;
	
	#ASSERT external node bag
	$bin = $result.StatusCode | Should Be 201;
	$bin = $externalNodeBag | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.ExternalNodeBag];
	$bin = $externalNodeBag | Should Not Be $null;
	$bin = $externalNodeBag.Name = $name;
	$bin = $externalNodeBag.Description = $description;
	$bin = $externalNodeBag.Value = $value;
	$bin = $externalNodeBag.ExternaldNodeid = $externalNodeId;
	$bin = $externalNodeBag.Tid = $tid;

	return $externalNodeBag;
	
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





function Create-Catalogue {
	Param
	(
		$Svc
		,
		$Name
		,
		$Description = "Description"
		,
		$Status = "Published"
		,
		$Version = 1
		,
		$TenantId = (Get-ApcTenant -Current -svc $Svc).Id
	)
	
	#create catalog object
	$newCatalogue = New-Object biz.dfch.CS.Appclusive.Api.Core.Catalogue;
	
	#add mandatory parameters
	$newCatalogue.Name = $Name;
	$newCatalogue.Description = $Description;
	$newCatalogue.Status = $Status;
	$newCatalogue.Version = $Version;
	$newCatalogue.Tid = $TenantId;
	
	#ACT - create new catalogue
	$svc.Core.AddToCatalogues($newCatalogue);
	$result = $svc.Core.SaveChanges();
	
	#get the catalogue
	$query = "Id eq {0}" -f $newCatalogue.Id;
	$catalogue = $svc.Core.Catalogues.AddQueryOption('$filter', $query) | select;
	
	#ASSERT catalogue creation
	$bin = $result.StatusCode | Should Be 201;
	$bin = $catalogue | Should Not Be $null;
	$bin = $catalogue.Name | Should Be $name;
	$bin = $catalogue.Description | Should Be $description;
	$bin = $catalogue.Id | Should Not Be $null;
	$bin = $catalogue.Status |Should Be $status;
	$bin = $catalogue.Version |Should Be $version;
	$bin = $catalogue.Tid |Should Be $TenantId;
	
	return $catalogue;
}

function Delete-Catalogue{
	Param
	(
		$Svc
		,
		$CatalogueId
	)
	
	#get the catalogue
	$query = "Id eq {0}" -f $catalogueId;
	$catalogue = $svc.Core.Catalogues.AddQueryOption('$filter', $query) | select;
	
	#delete catalogue
	$svc.Core.DeleteObject($catalogue);
	$result = $svc.Core.SaveChanges();
	
	#get the catalogue
	$query = "Id eq {0}" -f $catalogueId;
	$deletedCatalogue = $svc.Core.Catalogues.AddQueryOption('$filter', $query) | select;
	
	#ASSERT that catalogue is deleted
	$deletedCatalogue | Should Be $null;
	
	return $result;
}

function Create-CatalogueItem {
	Param
	(
		$Svc
		,
		$Name
		,
		$Description = "Test Catalogue Item"
		,
		$CatalogueId
		,
		$ProductId
		,
		$Parameters
		,
		$ValidFrom = [DateTimeOffset]::Now
		,
		$ValidUntil = [DateTimeOffset]::Now.AddDays(365)
		,
		$EndOfLife = [DateTimeOffset]::Now.AddDays(365)
	)
	
	#add parameters
	$newCatalogueItem = New-Object biz.dfch.CS.Appclusive.Api.Core.CatalogueItem;
	$newCatalogueItem.Name = $name;
	$newCatalogueItem.Description = $description;
	$newCatalogueItem.CatalogueId = $catalogueId;
	$newCatalogueItem.ProductId = $productId;
	if($Parameters){
		$newCatalogueItem.Parameters = $parameters;
	}
	$newCatalogueItem.ValidFrom = $validFrom;
	$newCatalogueItem.ValidUntil = $validUntil;
	$newCatalogueItem.EndOfLife = $endOfLife;
	
	#create catalogueItem
	$svc.Core.AddToCatalogueItems($newCatalogueItem);
	$result = $svc.Core.SaveChanges();
	
	#get catalogueItem
	$query = "Id eq {0}" -f $newCatalogueItem.Id;
	$catalogueItem = $svc.Core.CatalogueItems.AddQueryOption('$filter', $query) | select;
	
	#ASSERT catalogue Item
	$bin = $result.StatusCode | Should Be 201;
	$bin = $catalogueItem | Should Not Be $null;
	$bin = $catalogueItem.Id | Should Not Be $null;
	$bin = $catalogueItem.Name | Should Be $name;
	$bin = $catalogueItem.Description | Should Be $description;
	$bin = $catalogueItem.CatalogueId | Should Be $catalogueId;
	$bin = $catalogueItem.ProductId | Should Be $productId;
	if($Parameters){
		$bin = $catalogueItem.Parameters | Should Be $parameters;
	}
	$bin = $catalogueItem.ValidFrom | Should Be $validFrom;
	$bin = $catalogueItem.ValidUntil | Should Be $validUntil;
	$bin = $catalogueItem.EndOfLife | Should Be $endOfLife;
	
	return $catalogueItem;

}

function Delete-CatalogueItem {
	Param
	(
		$Svc
		,
		$CatalogueItemId
	)
	
	#get the Catalogue Item
	$query = "Id eq {0}" -f $catalogueItemId;
	$catalogueItem = $svc.Core.CatalogueItems.AddQueryOption('$filter', $query) | select;
	
	#delete the Catalogue Item
	$svc.Core.DeleteObject($catalogueItem);
	$result = $svc.Core.SaveChanges();
	
	#get the deleted Catalogue Item
	$query = "Id eq {0}" -f $catalogueItemId;
	$deletedCatalogueItem = $svc.Core.CatalogueItems.AddQueryOption('$filter', $query) | select;
	
	#ASSERT that Catalogue Item is deleted
	$deletedCatalogueItem | Should Be $null;
	
	return $result;
}

function Update-Catalogue {
	Param
	(
		$Svc
		,
		$CatalogueId
		,
		$NewCatalogueDescription
	)
	
	#get the Catalogue 
	$query = "Id eq {0}" -f $catalogueId;
	$catalogue = $svc.Core.Catalogues.AddQueryOption('$filter', $query) | select;
	$catalogueDescription = $catalogue.Description; #get old desription
	
	#update the Catalogue
	$catalogue.Description = $newCatalogueDescription;
	$svc.Core.UpdateObject($catalogue);
	$result = $svc.Core.SaveChanges();
	
	#get the updated Catalogue 
	$query = "Id eq {0}" -f $catalogueId;
	$updatedCatalogue = $svc.Core.Catalogues.AddQueryOption('$filter', $query) | select;
	
	#ASSERT - update
	$updatedCatalogue.Description | Should Be $newCatalogueDescription;
	$updatedCatalogue.Description | Should Not Be $catalogueDescription;
	$updatedCatalogue.Id | Should Be $catalogueId;
	
	return $updatedCatalogue;
}

function Update-CatalogueItem{
	Param
	(
		$Svc
		,
		$CatalogueItemId
		,
		$NewCatalogueItemDescription
	)
	
	#get the Catalogue Item
	$query = "Id eq {0}" -f $catalogueItemId;
	$catalogueItem = $svc.Core.CatalogueItems.AddQueryOption('$filter', $query) | select;
	$catalogueItemDescription = $catalogueItem.Description; #get old description
	
	#update the Catalogue Item
	$catalogueItem.Description = $newCatalogueItemDescription;
	$svc.Core.UpdateObject($catalogueItem);
	$result = $svc.Core.SaveChanges();
	
	#get the updated Catalogue Item
	$query = "Id eq {0}" -f $catalogueItemId;
	$updatedCatalogueItem = $svc.Core.CatalogueItems.AddQueryOption('$filter', $query) | select;
	
	#ASSERT - update
	$updatedCatalogueItem.Description | Should Be $newCatalogueItemDescription;
	$updatedCatalogueItem.Description | Should Not Be $catalogueItemDescription;
	$updatedCatalogueItem.Id | Should Be $catalogueItemId;
	
	return $updatedCatalogueItem;
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

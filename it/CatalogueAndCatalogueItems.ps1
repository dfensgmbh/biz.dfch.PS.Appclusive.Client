function Create-Catalogue {
	Param
	(
		$svc
		,
		$name
		,
		$description = "Description"
		,
		$status = "Published"
		,
		$version = 1
		,
		$tenantId = (Get-ApcTenant -Current).Id
	)
	
	#create catalog object
	$newCatalogue = New-Object biz.dfch.CS.Appclusive.Api.Core.Catalogue;
	
	#add mandatory parameters
	$newCatalogue.Name = $Name;
	$newCatalogue.Description = $Description;
	$newCatalogue.Status = $Status;
	$newCatalogue.Version = $Version;
	$newCatalogue.Tid = $tenantId;
	
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
	$bin = $catalogue.Tid |Should Be $tenantId;
	
	return $catalogue;
}

function Delete-Catalogue{
	Param
	(
		$svc
		,
		$catalogueId
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

function Create-Product {
	Param
	(
		$svc
		,
		$name
		,
		$description = "Arbitrary Product"
		,
		$type = "Test Product"
		,
		$entityKindId = [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::Product.value__
		,
		$tenantId = (Get-ApcTenant -Current).Id
	)
	
	#add parameters
	$newProduct = New-Object biz.dfch.CS.Appclusive.Api.Core.Product;
	$newProduct.Name = $name;
	$newProduct.Description = $description;
	$newProduct.Type = $type;
	$newProduct.EntityKindId = $entityKindId;
	$newProduct.Tid = $tenantId;
	
	#ACT create product
	$svc.Core.AddToProducts($newProduct);
	$result = $svc.Core.SaveChanges();
	
	#get product
	$query = "Id eq {0}" -f $newProduct.Id;
	$product = $svc.Core.Products.AddQueryOption('$filter', $query) | select;
	
	#ASSERT product
	$bin = $result.StatusCode | Should Be 201;
	$bin = $product | Should Not Be $null;
	$bin = $product.Name | Should Be $name;
	$bin = $product.Description | Should Be $description;
	$bin = $product.Id | Should Not Be $null;
	$bin = $product.Type |Should Be $type;
	$bin = $product.EntityKindId |Should Be $entityKindId;
	$bin = $product.Tid |Should Be $tenantId;

	return $product;
}

function Delete-Product {
	Param 
	(
		$svc
		,
		$productId
	)
	
	#get the product
	$query = "Id eq {0}" -f $productId;
	$product = $svc.Core.Products.AddQueryOption('$filter', $query) | select;
	
	#delete product
	$svc.Core.DeleteObject($product);
	$result = $svc.Core.SaveChanges();
	
	#get the deleted product
	$query = "Id eq {0}" -f $productId;
	$deletedProduct = $svc.Core.Products.AddQueryOption('$filter', $query) | select;
	
	#ASSERT that product is deleted
	$deletedProduct | Should Be $null;
	
	return $result;
}

function Create-CatalogueItem {
	Param
	(
		$svc
		,
		$catalogueItemName
		,
		$productId
		,
		$catalogueId
	)
	
	#get Catalogue Item template
	$template = $svc.Core.InvokeEntitySetActionWithSingleResult('CatalogueItems', 'Template', [biz.dfch.CS.Appclusive.Api.Core.CatalogueItem], $null);
	#add parameters
	$newCatalogueItem = New-Object biz.dfch.CS.Appclusive.Api.Core.CatalogueItem;
	$newCatalogueItem.ValidFrom = $template.ValidFrom
	$newCatalogueItem.ValidUntil = $template.ValidUntil
	$newCatalogueItem.EndOfLife = $template.EndOfLife
	$newCatalogueItem.Name = $catalogueItemName;
	$newCatalogueItem.Parameters = '{}';
	$newCatalogueItem.Description = 'Test Catalogue Item';
	$newCatalogueItem.ProductId = $productId;
	$newCatalogueItem.CatalogueId = $catalogueId;
	
	#create catalogueItem
	$svc.Core.AddToCatalogueItems($newCatalogueItem);
	$result = $svc.Core.SaveChanges();
	
	#get catalogueItem
	$query = "Id eq {0}" -f $newCatalogueItem.Id;
	$newCatalogueItem = $svc.Core.CatalogueItems.AddQueryOption('$filter', $query) | select;
	
	#ASSERT catalogue Item
	$newCatalogueItem | Should Not Be $null;
	$newCatalogueItem.Id | Should Not Be $null;
	$result.StatusCode | Should Be 201;
	
	return $newCatalogueItem;

}

function Delete-CatalogueItem {
	Param
	(
		$svc
		,
		$catalogueItemId
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
		$svc
		,
		$catalogueId
		,
		$newCatalogueDescription
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
		$svc
		,
		$catalogueItemId
		,
		$newCatalogueItemDescription
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
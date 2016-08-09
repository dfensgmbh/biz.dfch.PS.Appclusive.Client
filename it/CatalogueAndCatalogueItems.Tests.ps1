$svc = Enter-Appclusive LAB3;

$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".");

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe -Tags "CatalogueandCatalogueItems.Tests" "CatalogueandCatalogueItems.Tests" {

	Mock Export-ModuleMember { return $null; }
	. "$here\$sut"

    $entityPrefix = "TestItem-";
	$usedEntitySets = @("Catalogues", "CatalogueItems", "Products");

    Context "#CLOUDTCL-2191-Catalogue" {	
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;
			$svc = Enter-Appclusive LAB3;
		}
		
		AfterAll {
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

		
		It "CreateAndDeleteCatalogue" -Test {
			#ARRANGE
			$catalogueName = $entityPrefix + "newTestCatalogue";
			
			#ACT
			$newCatalogue = Create-Catalogue -svc $svc -Name $catalogueName;
			$catalogueId = $newCatalogue.Id;
			
			#ACT - DeleteCatalogue
			Delete-Catalogue -svc $svc -catalogueId $catalogueId;	
		}
		
		It "CreateAndDeleteCatalogueItemInCatalogue" -Test {
			#ARRANGE
			$catalogueName = $entityPrefix + "newTestCatalogue";
			$productName = $entityPrefix + "newTestProduct";
			$catalogueItemName = $entityPrefix + "newTestCatalogueItem";
			
			#create catalogue
			$newCatalogue = Create-Catalogue -svc $svc -Name $catalogueName;
			$catalogueId = $newCatalogue.Id;
			
			#create product
			$newProduct = Create-Product -svc $svc -productName $productName;
			$productId = $newProduct.Id;
			
			#create catalogue item
			$newCatalogueItem = Create-CatalogueItem -svc $svc -catalogueItemName $catalogueItemName -productId $productId -catalogueId $catalogueId;
			$catalogueItemId = $newCatalogueItem.Id;
			
			#delete catalogue item
			Delete-CatalogueItem -svc $svc -catalogueItemId $catalogueItemId;
			
			#delete product
			Delete-Product -svc $svc -productId $productId;
			
			#delete catalogue
			Delete-Catalogue -svc $svc -catalogueId $catalogueId;
		}
		
		It "UpdateEmptyCatalogue" -Test {
			#ARRANGE
			$catalogueName = $entityPrefix + "newTestCatalogue";
			$newCatalogueDescription = "Updated Description";
			
			#ACT - create empty catalogue
			$newCatalogue = Create-Catalogue -svc $svc -Name $catalogueName;
			$catalogueId = $newCatalogue.Id;
			
			#ACT - update description of empty catalogue
			$updatedCatalogue = Update-Catalogue -svc $svc -catalogueId $catalogueId -newCatalogueDescription $newCatalogueDescription;
			
			#ACT - delete catalogue
			Delete-Catalogue -svc $svc -catalogueId $catalogueId;
		}
		
		
		It "UpdateCatalogueWithCatalogueItem" -Test {	
			#ARRANGE
			$catalogueName = $entityPrefix + "newTestCatalogue";
			$productName = $entityPrefix + "newTestProduct";
			$catalogueItemName = $entityPrefix + "newTestCatalogueItem";
			$newCatalogueDescription = "Updated Description";
			
			#create catalogue
			$newCatalogue = Create-Catalogue -svc $svc -Name $catalogueName;
			$catalogueId = $newCatalogue.Id;
			
			#create product
			$newProduct = Create-Product -svc $svc -productName $productName;
			$productId = $newProduct.Id;
			
			#create catalogue item
			$newCatalogueItem = Create-CatalogueItem -svc $svc -catalogueItemName $catalogueItemName -productId $productId -catalogueId $catalogueId;
			$catalogueItemId = $newCatalogueItem.Id;
			
			#ACT - update description of catalogue
			$updatedCatalogue = Update-Catalogue -svc $svc -catalogueId $catalogueId -newCatalogueDescription $newCatalogueDescription;
			
			#delete catalogue item
			Delete-CatalogueItem -svc $svc -catalogueItemId $catalogueItemId;
			
			#delete product
			Delete-Product -svc $svc -productId $productId;
			
			#delete catalogue
			Delete-Catalogue -svc $svc -catalogueId $catalogueId;
		}
		
		It "UpdateCatalogueItem" -Test {
			#ARRANGE
			$catalogueName = $entityPrefix + "newTestCatalogue";
			$productName = $entityPrefix + "newTestProduct";
			$catalogueItemName = $entityPrefix + "newTestCatalogueItem";
			$newCatalogueItemDescription = "Updated Description for Catalogue Item";
			
			#create catalogue
			$newCatalogue = Create-Catalogue -svc $svc -Name $catalogueName;
			$catalogueId = $newCatalogue.Id;
			
			#create product
			$newProduct = Create-Product -svc $svc -productName $productName;
			$productId = $newProduct.Id;
						
			#create catalogue item
			$newCatalogueItem = Create-CatalogueItem -svc $svc -catalogueItemName $catalogueItemName -productId $productId -catalogueId $catalogueId;
			$catalogueItemId = $newCatalogueItem.Id;
			
			#ACT - update description of catalogue Item
			$updatedCatalogueItem = Update-CatalogueItem -svc $svc -catalogueItemId $catalogueItemId -newCatalogueItemDescription $newCatalogueItemDescription;
			
			#delete catalogue item
			Delete-CatalogueItem -svc $svc -catalogueItemId $catalogueItemId;
			
			#delete product
			Delete-Product -svc $svc -productId $productId;
			
			#delete catalogue
			Delete-Catalogue -svc $svc -catalogueId $catalogueId;
		}
	}
}
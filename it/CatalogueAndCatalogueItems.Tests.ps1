# includes tests for test case CLOUDTCL-2191

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
	. "$here\Product.ps1"
	
    $entityPrefix = "TestItem-";
	$usedEntitySets = @("Catalogues", "CatalogueItems", "Products");

    Context "#CLOUDTCL-2191-CatalogueAndcatalogueItems" {	
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
		
		It "Catalogue-CreateAndDelete" -Test {
			#ARRANGE
			$catalogueName = $entityPrefix + "Catalogue";
			
			#ACT create catalogue & get catalogue Id
			$newCatalogue = Create-Catalogue -svc $svc -name $catalogueName;
			$catalogueId = $newCatalogue.Id;
			
			#CLEANUP delete catalogue
			Delete-Catalogue -svc $svc -catalogueId $catalogueId;	
		}
		
		It "CreateAndDeleteCatalogueItemInCatalogue" -Test {
			#ARRANGE
			$catalogueName = $entityPrefix + "Catalogue";
			$productName = $entityPrefix + "Product";
			$catalogueItemName = $entityPrefix + "CatalogueItem";
			
			#ACT create catalogue
			$newCatalogue = Create-Catalogue -svc $svc -name $catalogueName;
			$catalogueId = $newCatalogue.Id;
			
			#ACT create product
			$newProduct = Create-Product -svc $svc -name $productName;
			$productId = $newProduct.Id;
			
			#ACT create catalogue item
			$newCatalogueItem = Create-CatalogueItem -svc $svc -name $catalogueItemName -catalogueId $catalogueId -productId $productId;
			$catalogueItemId = $newCatalogueItem.Id;
			
			#CLEANUP delete catalogue item
			Delete-CatalogueItem -svc $svc -catalogueItemId $catalogueItemId;
			
			#CLEANUP delete product
			Delete-Product -svc $svc -productId $productId; 
			
			#CLEANUP delete catalogue
			Delete-Catalogue -svc $svc -catalogueId $catalogueId;
		}
		
		It "GetCatalogueItem" -Test {
			#ARRANGE
			$catalogueName = $entityPrefix + "Catalogue";
			$productName = $entityPrefix + "Product";
			$catalogueItemName = $entityPrefix + "CatalogueItem";
			
			#ACT create catalogue
			$newCatalogue = Create-Catalogue -svc $svc -name $catalogueName;
			$catalogueId = $newCatalogue.Id;
			
			#ACT create product
			$newProduct = Create-Product -svc $svc -name $productName;
			$productId = $newProduct.Id;
			
			#ACT create catalogue item
			$newCatalogueItem = Create-CatalogueItem -svc $svc -name $catalogueItemName -catalogueId $catalogueId -productId $productId;
			$catalogueItemId = $newCatalogueItem.Id;
			
			#ACT get catalogue Item using Get-ApccatalogueItem
			$loadedCatalogueItem = Get-ApcCatalogueItem -Id $catalogueItemId;
			
			#ASSERT that the catalogue is the coorect one
			$loadedCatalogueItem | Should Not Be $null;
			$loadedCatalogueItem | Should Be $newCatalogueItem;
		}
		
		It "LoadCatalogueOfCatalogueItem" -Test {
			#ARRANGE
			$catalogueName = $entityPrefix + "Catalogue";
			$productName = $entityPrefix + "Product";
			$catalogueItemName = $entityPrefix + "CatalogueItem";
			
			#ACT create catalogue
			$newCatalogue = Create-Catalogue -svc $svc -name $catalogueName;
			$catalogueId = $newCatalogue.Id;
			
			#ACT create product
			$newProduct = Create-Product -svc $svc -name $productName;
			$productId = $newProduct.Id;
			
			#ACT create catalogue item
			$newCatalogueItem = Create-CatalogueItem -svc $svc -name $catalogueItemName -catalogueId $catalogueId -productId $productId;
			$catalogueItemId = $newCatalogueItem.Id;
			
			#ACT load catalogue from the catalogue item
			$loadedCatalogue = $svc.Core.LoadProperty($newCatalogueItem, 'Catalogue') | Select;
			
			#ASSERT thet loaded catalogue is the correct one
			$loadedCatalogue | Should Not Be $null;
			$loadedCatalogue.Id | Should Be $catalogueId;
			$loadedCatalogue | Should Be  $newCatalogue;

			#CLEANUP delete catalogue item
			Delete-CatalogueItem -svc $svc -catalogueItemId $catalogueItemId;
			
			#CLEANUP delete product
			Delete-Product -svc $svc -productId $productId; 
			
			#CLEANUP delete catalogue
			Delete-Catalogue -svc $svc -catalogueId $catalogueId;
		}
		
		It "LoadCatalogueItemsOfCatalogue" -Test {
			#ARRANGE
			$catalogueName = $entityPrefix + "Catalogue";
			$productName = $entityPrefix + "Product";
			$catalogueItemName1 = $entityPrefix + "CatalogueItem1";
			$catalogueItemName2 = $entityPrefix + "CatalogueItem2";
			
			#ACT create catalogue
			$newCatalogue = Create-Catalogue -svc $svc -name $catalogueName;
			$catalogueId = $newCatalogue.Id;
			
			#ACT create product
			$newProduct = Create-Product -svc $svc -name $productName;
			$productId = $newProduct.Id;
			
			#ACT create catalogue items
			$newCatalogueItem1 = Create-CatalogueItem -svc $svc -name $catalogueItemName1 -catalogueId $catalogueId -productId $productId;
			$catalogueItem1Id = $newCatalogueItem1.Id;
			$newCatalogueItem2 = Create-CatalogueItem -svc $svc -name $catalogueItemName2 -catalogueId $catalogueId -productId $productId;
			$catalogueItem2Id = $newCatalogueItem2.Id;
			
			#ACT load catalogue from the catalogue item
			$loadedCatalogueItems = $svc.Core.LoadProperty($newCatalogue, 'CatalogueItems') | Select;
			
			#ASSERT thet loaded catalogue is the correct one
			$loadedCatalogueItems | Should Not Be $null;
			$loadedCatalogueItems.Id -contains $catalogueItem1Id | Should be $true;
			$loadedCatalogueItems.Id -contains $catalogueItem2Id | Should be $true;

			#CLEANUP delete catalogue items
			Delete-CatalogueItem -svc $svc -catalogueItemId $catalogueItem1Id;
			Delete-CatalogueItem -svc $svc -catalogueItemId $catalogueItem2Id;
			
			#CLEANUP delete product
			Delete-Product -svc $svc -productId $productId; 
			
			#CLEANUP delete catalogue
			Delete-Catalogue -svc $svc -catalogueId $catalogueId;
		}
		
		It "UpdateEmptyCatalogue" -Test {
			#ARRANGE
			$catalogueName = $entityPrefix + "newTestCatalogue";
			$newCatalogueDescription = "Updated Description";
			
			#ACT - create empty catalogue
			$newCatalogue = Create-Catalogue -svc $svc -name $catalogueName;
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
			$newCatalogue = Create-Catalogue -svc $svc -name $catalogueName;
			$catalogueId = $newCatalogue.Id;
			
			#create product
			$newProduct = Create-Product -svc $svc -name $productName;
			$productId = $newProduct.Id;
			
			#create catalogue item
			$newCatalogueItem = Create-CatalogueItem -svc $svc -name $catalogueItemName -productId $productId -catalogueId $catalogueId;
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
			$newCatalogue = Create-Catalogue -svc $svc -name $catalogueName;
			$catalogueId = $newCatalogue.Id;
			
			#create product
			$newProduct = Create-Product -svc $svc -name $productName;
			$productId = $newProduct.Id;
						
			#create catalogue item
			$newCatalogueItem = Create-CatalogueItem -svc $svc -name $catalogueItemName -productId $productId -catalogueId $catalogueId;
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

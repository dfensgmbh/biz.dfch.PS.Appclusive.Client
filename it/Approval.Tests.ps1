# includes tests for CLOUDTCL-1887

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe "Approval.Tests" -Tags "Approval.Tests" {

	Mock Export-ModuleMember { return $null; }
	. "$here\$sut"
	. "$here\CatalogueAndCatalogueItems.ps1"
	. "$here\Cart.ps1"
	. "$here\Product.ps1"
	
	$entityPrefix = "TestItem-";
	$usedEntitySets = @("Orders", "CartItems", "CatalogueItems", "Products", "Catalogues", "Carts");
	
	
	Context "#CLOUDTCL-1887-ApprovalTests" {
		
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
		
		It "Approval-ApproveChangesOrderStatusToWaitingToRun" -Test {
			#ARRANGE
			$catalogueName = $entityPrefix + "Catalogue";
			$productName = $entityPrefix + "Product";
			$catalogueItemName = $entityPrefix + "CatalogueItem";
			$cartItemName = $entityPrefix + "CartItem";
			$orderName = $entityPrefix + "Order";
			$orderEntityKindId = [biz.dfch.cs.appclusive.public.constants+EntityKindId]::Order.value__;
			$approvalEntityKindId = [biz.dfch.cs.appclusive.public.constants+EntityKindId]::Approval.value__;
			
			#ACT create catalogue
			$newCatalogue = Create-Catalogue -svc $svc -name $catalogueName;
			$catalogueId = $newCatalogue.Id;
			
			#ACT create product
			$newProduct = Create-Product -svc $svc -name $productName;
			$productId = $newProduct.Id;
			
			#ACT create catalogue item
			$newCatalogueItem = Create-CatalogueItem -svc $svc -name $catalogueItemName -catalogueId $catalogueId -productId $productId;
			$catalogueItemId = $newCatalogueItem.Id;
			
			#ACT create new cart item
			$cartItem = Create-CartItem -svc $svc -Name $cartItemName -CatalogueItemId $catalogueItemId;
			$cartItemId = $cartItem.Id;
			$cartId = $cartItem.CartId;
			
			#get cart
			$query = "Id eq {0}" -f $cartId;
			$cart = $svc.Core.Carts.AddQueryOption('$filter', $query) | Select;
			
			#ASSERT cart
			$cartItems = $svc.Core.LoadProperty($cart, 'CartItems') | Select;
			$cartItems.Count | Should Be 1;
			$cartItems[0].Id | Should Be $cartItemId;
			
			#ACT create order
			$orderParameters = @{
				Name = $orderName;
				Description = "Arbitrary Description";
				Requester = (Get-ApcUser -svc $svc -Current).Id;
				Parameters = '{}';
			}
			
			$createOrder = $svc.Core.InvokeEntitySetActionWithSingleResult("Orders", "Create",  [biz.dfch.CS.Appclusive.Api.Core.Order], $orderParameters );
			
			#get order
			$query = "Name eq '{0}'" -f $orderName;
			$order = $svc.Core.Orders.AddQueryOption('$filter', $query) | Select;
			
			#get job of the order
			$query = "EntityKindId eq {0} and RefId eq '{1}'" -f $orderEntityKindId, $order.Id;
			$orderJob = $svc.Core.Jobs.AddQueryOption('$filter', $query) | Select;
			$orderJob.Status | Should Be 'Approval';
			
			#get the job of the approval, its parentId should be the id of the job of the order
			$query = "EntityKindId eq {0} and ParentId eq {1}" -f $approvalEntityKindId, $orderJob.Id;
			$approvalJob = $svc.Core.Jobs.AddQueryOption('$filter', $query) | Select;
			$approvalJob.Status | Should Be 'Created';
			
			#get the approval
			$query = "Id eq {0}" -f $approvalJob.RefId;
			$approval = $svc.Core.Approvals.AddQueryOption('$filter', $query) | Select;
			
			$condition = 'Continue';
			
			#approve the approval (set it to status "Approved" & order to status "Waiting to Run")
			$null = $svc.Core.InvokeEntityActionWithVoidResult($approval, "InvokeAction", @{Name=$condition; Parameters="Arbitrary"});
			
			$svc = Enter-Appclusive;
			#get the approval job
			$approvalJobRefreshed = Get-ApcJob -svc $svc -id $approvalJob.Id;
			$approvalJobRefreshed.Status | Should Be "Approved";
			
			#get the order Job
			$query = "EntityKindId eq {0} and RefId eq '{1}'" -f $orderEntityKindId, $order.Id;
			$orderJob = $svc.Core.Jobs.AddQueryOption('$filter', $query) | Select;
			$orderJob.Status | Should Be "WaitingToRun";
		}
		
		It "Approval-DeclineChangesOrderStatusToCancelled" -Test {
			#ARRANGE
			$catalogueName = $entityPrefix + "Catalogue";
			$productName = $entityPrefix + "Product";
			$catalogueItemName = $entityPrefix + "CatalogueItem";
			$cartItemName = $entityPrefix + "CartItem";
			$orderName = $entityPrefix + "Order";
			$orderEntityKindId = [biz.dfch.cs.appclusive.public.constants+EntityKindId]::Order.value__;
			$approvalEntityKindId = [biz.dfch.cs.appclusive.public.constants+EntityKindId]::Approval.value__;
			
			#ACT create catalogue
			$newCatalogue = Create-Catalogue -svc $svc -name $catalogueName;
			$catalogueId = $newCatalogue.Id;
			
			#ACT create product
			$newProduct = Create-Product -svc $svc -name $productName;
			$productId = $newProduct.Id;
			
			#ACT create catalogue item
			$newCatalogueItem = Create-CatalogueItem -svc $svc -name $catalogueItemName -catalogueId $catalogueId -productId $productId;
			$catalogueItemId = $newCatalogueItem.Id;
			
			#ACT create new cart item
			$cartItem = Create-CartItem -svc $svc -Name $cartItemName -CatalogueItemId $catalogueItemId;
			$cartItemId = $cartItem.Id;
			$cartId = $cartItem.CartId;
			
			#get cart
			$query = "Id eq {0}" -f $cartId;
			$cart = $svc.Core.Carts.AddQueryOption('$filter', $query) | Select;
			
			#ASSERT cart
			$cartItems = $svc.Core.LoadProperty($cart, 'CartItems') | Select;
			$cartItems.Count | Should Be 1;
			$cartItems[0].Id | Should Be $cartItemId;
			
			#ACT create order
			$orderParameters = @{
				Name = $orderName;
				Description = "Arbitrary Description";
				Requester = (Get-ApcUser -svc $svc -Current).Id;
				Parameters = '{}';
			}
			
			$createOrder = $svc.Core.InvokeEntitySetActionWithSingleResult("Orders", "Create",  [biz.dfch.CS.Appclusive.Api.Core.Order], $orderParameters );
			
			#get order
			$query = "Name eq '{0}'" -f $orderName;
			$order = $svc.Core.Orders.AddQueryOption('$filter', $query) | Select;
			
			#get job of the order
			$query = "EntityKindId eq {0} and RefId eq '{1}'" -f $orderEntityKindId, $order.Id;
			$orderJob = $svc.Core.Jobs.AddQueryOption('$filter', $query) | Select;
			$orderJob.Status | Should Be 'Approval';
			
			#get the job of the approval, its parentId should be the id of the job of the order
			$query = "EntityKindId eq {0} and ParentId eq {1}" -f $approvalEntityKindId, $orderJob.Id;
			$approvalJob = $svc.Core.Jobs.AddQueryOption('$filter', $query) | Select;
			$approvalJob.Status | Should Be 'Created';
			
			#get the approval
			$query = "Id eq {0}" -f $approvalJob.RefId;
			$approval = $svc.Core.Approvals.AddQueryOption('$filter', $query) | Select;
			
			$condition = 'Cancel';
			
			#approve the approval (set it to status "Approved" & order to status "Waiting to Run")
			$null = $svc.Core.InvokeEntityActionWithVoidResult($approval, "InvokeAction", @{Name=$condition; Parameters="Arbitrary"});
			
			$svc = Enter-Appclusive;
			#get the approval job
			$approvalJobRefreshed = Get-ApcJob -svc $svc -id $approvalJob.Id
			$approvalJobRefreshed.Status | Should Be "Declined";
			
			#get the order Job
			$query = "EntityKindId eq {0} and RefId eq '{1}'" -f $orderEntityKindId, $order.Id;
			$orderJob = $svc.Core.Jobs.AddQueryOption('$filter', $query) | Select;
			$orderJob.Status | Should Be "Cancelled";
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


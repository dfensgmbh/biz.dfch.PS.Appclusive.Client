#includes tests for 

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester()
{
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
	PARAM
	(
		$message = "EMERGENCY: Script cannot continue."
	)
	
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe "VM.Tests" -Tags "VM.Tests" {

	Mock Export-ModuleMember { return $null; }
	. "$here\$sut"
	. "$here\CatalogueAndCatalogueItems.ps1"
	. "$here\Product.ps1"
	. "$here\Cart.ps1"
	. "$here\Order.ps1"
	
	$entityPrefix = "TestItem";
	$usedEntitySets = @("CartItems", "CatalogueItems", "Products", "Catalogues", "Carts" );
	#gets the id of tenant Managed Customer Tenant
	$tenant = Get-ApcTenant -Name "Managed Customer Tenant" -svc $svc;
	$tenantId = $tenant.Id.toString();
	
	$vmName = $entityPrefix + "VM";
	$OS = @("SPMI-2015.6","SPMI-2015.3","SPMI-2015.4","SPMI-2015.5"); #2012R2, 2008R2, Rhel6.8, Rhel7.2
	$templateId = @("SPMT-2015.1", "SPMT-2015.3"); #with customization, noOS
	$memory = @("512", "393216"); #lowest, highest available memory size
	$folderId = "4927";

	Context "#CLOUDTCL--VMTests" {
	
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;
			$svc = Enter-Appclusive;
			Set-ApcSessionTenant -Id $tenantId -svc $svc;
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
		
		It "CreateVM-differentOSs" -Test {
			#ARRANGE
			$orderName = $entityPrefix + "Order-{0}" -f [guid]::NewGuid().ToString();
			$cartItemName = $entityPrefix + "cartItem-{0}" -f [guid]::NewGuid().ToString();
			$catalogueItemId = (Get-ApcCatalogueItem -Name "Virtualmachine").Id | Select -First 1;
			
			for ($i = 0; $i -lt $OS.Length; $i++){
				$parameters = Get-Parameters -Name ($vmName + $i) -OpSystem $OS[$i];
				
				#ACT create new cart item
				$cartItem = Create-CartItem -svc $svc -Name $cartItemName -CatalogueItemId $catalogueItemId -Parameters $parameters;
				$cartItemId = $cartItem.Id;
				$cartId = $cartItem.CartId;
				
				#ASSERT check that the cart Id of the cart Item belongs to a created Cart
				$carts = $svc.Core.Carts | Select;
				$carts.Id -Contains $cartId | Should Be $true;
				
				#ACT create order
				$orderParameters = @{
					Name = $orderName;
					Description = "Arbitrary Description";
					Requester = (Get-ApcUser -Current).Id;
					Parameters = '{"biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node.Id":"' + $folderId +'"}';
				}
				
				$createOrder = $svc.Core.InvokeEntitySetActionWithSingleResult("Orders", "Create",  [biz.dfch.CS.Appclusive.Api.Core.Order], $orderParameters ); 
				
				Start-Sleep -s 20
			}
			
			#ASSERT
			
		}
		
		It "CreateVM-withoutOS" -Test {
			#ARRANGE
			$orderName = $entityPrefix + "Order-{0}" -f [guid]::NewGuid().ToString();
			$cartItemName = $entityPrefix + "cartItem-{0}" -f [guid]::NewGuid().ToString();
			$catalogueItemId = (Get-ApcCatalogueItem -Name "Virtualmachine").Id | Select -First 1;
			
			#ACT create new cart item
			$parameters = Get-Parameters -Name ($vmName + "noOS") -OpSystem "" -TemplateId $templateId[1];
			$cartItem = Create-CartItem -svc $svc -Name $cartItemName -CatalogueItemId $catalogueItemId -Parameters $parameters;
			$cartItemId = $cartItem.Id;
			$cartId = $cartItem.CartId;
			
			#ASSERT check that the cart Id of the cart Item belongs to a created Cart
			$carts = $svc.Core.Carts | Select;
			$carts.Id -Contains $cartId | Should Be $true;
			
			#ACT create order
			$orderParameters = @{
				Name = $orderName;
				Description = "Arbitrary Description";
				Requester = (Get-ApcUser -Current).Id;
				Parameters = '{"biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node.Id":"' + $folderId +'"}';
			}
			
			$createOrder = $svc.Core.InvokeEntitySetActionWithSingleResult("Orders", "Create",  [biz.dfch.CS.Appclusive.Api.Core.Order], $orderParameters );
		}
		
		It "CreateVM-minMemorySizes" -Test {
			#ARRANGE
			$orderName = $entityPrefix + "Order-{0}" -f [guid]::NewGuid().ToString();
			$cartItemName = $entityPrefix + "cartItem-{0}" -f [guid]::NewGuid().ToString();
			$catalogueItemId = (Get-ApcCatalogueItem -Name "Virtualmachine").Id | Select -First 1;
			$testName = "minMem";
			
			$parameters = Get-Parameters -Name ($vmName + $testName) -OpSystem $OS[0] -MemorySize $memory[0];
			
			#ACT create new cart item
			$cartItem = Create-CartItem -svc $svc -Name $cartItemName -CatalogueItemId $catalogueItemId -Parameters $parameters;
			$cartItemId = $cartItem.Id;
			$cartId = $cartItem.CartId;
			
			#ASSERT check that the cart Id of the cart Item belongs to a created Cart
			$carts = $svc.Core.Carts | Select;
			$carts.Id -Contains $cartId | Should Be $true;
			
			#ACT create order
			$orderParameters = @{
				Name = $orderName;
				Description = "Arbitrary Description";
				Requester = (Get-ApcUser -Current).Id;
				Parameters = '{"biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node.Id":"' + $folderId +'"}';
			}
			
			$createOrder = $svc.Core.InvokeEntitySetActionWithSingleResult("Orders", "Create",  [biz.dfch.CS.Appclusive.Api.Core.Order], $orderParameters ); 

		}
	}
}
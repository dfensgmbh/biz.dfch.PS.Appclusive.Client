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
	
	$entityPrefix = "TestItem-";
	$usedEntitySets = @("CartItems", "CatalogueItems", "Products", "Catalogues", "Carts");

	Context "#CLOUDTCL--VMTests" {
	
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
		
		It "CreateVM" -Test {
			#ARRANGE
			$orderName = $entityPrefix + "Order";
			$catalogueItemId = (Get-ApcCatalogueItem -Name Virtualmachine).Id
			$parameters = {
				\"biz\":{
					\"dfch\":{
						\"Appclusive\":{
							\"Products\":{
								\"Infrastructure\":{
									\"VirtualMachine\":{
										\"Name\":\"vm1\",
										\"Description\":\"\",
										\"OperatingSystem\":\"SPMI-2015.6\",
										\"Hostname\":\"vm1\",
										\"BackupProfile\":{\"Name\":\"no_backup\"},
										\"StorageProfile\":{\"Name\":\"economy_singlesided\"},
										\"Storage\":{\"DiskCollection\":{\"Disk00\":{\"Name\":\"System\",\"Description\":\"Boot Disk\",\"SizeGB\":60,
										\"StorageProfile\":\"economy_singlesided\"}}},
										\"Network\":{
											\"NicCollection\":{
												\"Nic00\":{
													\"NetworkId\":\"https://cloud-api.media.int/v1/cimi/2/networks/5b98b6df-8a8e-48b4-a33a-b09d4a0c0475\",\"Address\":\"0.0.0.0\"
												}
											}
										},
										\"Cpu\":{\"Count\":4,
										\"Speed\":1.6,
										\"Reservation\":0},
										\"Memory\":{
											\"Size\":4096,
											\"Reservation\":0
										}
									},
									\"VirtualMachineExtensions\":{
										\"Cimi\":{
											\"TemplateId\":\"SPMT-2015.1\",
											\"OperatingSystemPassword\":\"password\",
											\"Availability\":\"high\",
											\"HostGroup\":\"none\",
											\"HostingCell\":\"cell_a\"
										}
									}
								}
							}
						}
					}
				}
			}
			
			
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
				Parameters = '{}';
			}
			
			$createOrder = $svc.Core.InvokeEntitySetActionWithSingleResult("Orders", "Create",  [biz.dfch.CS.Appclusive.Api.Core.Order], $orderParameters );
		}
	}
}
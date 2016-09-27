# includes tests for CLOUDTCL-1886

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

Describe "Order.Tests" -Tags "Order.Tests" {

	Mock Export-ModuleMember { return $null; }
	. "$here\$sut"
	. "$here\CatalogueAndCatalogueItems.ps1"
	. "$here\Cart.ps1"
	. "$here\Product.ps1"
	
	$entityPrefix = "TestItem-";
	$usedEntitySets = @("Orders", "CartItems", "CatalogueItems", "Products", "Catalogues", "Carts");
	
	Context "#CLOUDTCL-1886-OrderTests" {
		
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
		
		It "PlaceOrderWithoutCart-ShouldFail" -Test {
			#ARRANGE
			$orderName = $entityPrefix + "Order";
			
			#delete cart if there is one
			$cart = $svc.Core.Carts | Select -First 1;
			if ($cart)
			{
				Remove-ApcEntity -svc $svc -Id $cart.Id -EntitySetName "Carts" -Confirm:$false;
			}
			
			#ACT
			$order = New-Object biz.dfch.CS.Appclusive.Api.Core.Order;
			$order.Name = $OrderName;
			$order.Parameters = '{}';
			$svc.Core.AddToOrders($order);
			
			try
			{
				{ $null = $svc.Core.SaveChanges(); } | Should ThrowDataServiceClientException @{StatusCode = 400};
			}
			catch
			{
				$exception = ConvertFrom-Json $error[0].Exception.InnerException.InnerException.Message;
				$exception.'odata.error'.message.value | Should Be 'No cart found.';
			}
		}
		
		It "PlaceOrder-ShouldCreateOrderItemsFromCartItems" -Test {
			#ARRANGE
			$catalogueName = $entityPrefix + "Catalogue";
			$productName = $entityPrefix + "Product";
			$catalogueItemName1 = $entityPrefix + "CatalogueItem1";
			$catalogueItemName2 = $entityPrefix + "CatalogueItem2";
			$cartItemName1 = $entityPrefix + "CartItem1";
			$cartItemName2 = $entityPrefix + "CartItem2";
			$orderName = $entityPrefix + "Order";
			
			#ACT create catalogue
			$newCatalogue = Create-Catalogue -svc $svc -name $catalogueName;
			$catalogueId = $newCatalogue.Id;
			
			#ACT create product
			$newProduct = Create-Product -svc $svc -name $productName;
			$productId = $newProduct.Id;
			
			#ACT create catalogue item
			$newCatalogueItem1 = Create-CatalogueItem -svc $svc -name $catalogueItemName1 -catalogueId $catalogueId -productId $productId;
			$catalogueItem1Id = $newCatalogueItem1.Id;
			$newCatalogueItem2 = Create-CatalogueItem -svc $svc -name $catalogueItemName2 -catalogueId $catalogueId -productId $productId;
			$catalogueItem2Id = $newCatalogueItem2.Id;
			
			#ACT create new cart items
			$cartItem1 = Create-CartItem -svc $svc -Name $cartItemName1 -CatalogueItemId $catalogueItem1Id;
			$cartItem1Id = $cartItem1.Id;
			$cartId = $cartItem1.CartId;
			
			$cartItem2 = Create-CartItem -svc $svc -Name $cartItemName2 -CatalogueItemId $catalogueItem2Id;
			$cartItem2Id = $cartItem2.Id;
			
			#ASSERT 2 cart items are in the same cart
			$cartItem2.CartId | Should Be $cartId;
			
			#get cart
			$query = "Id eq {0}" -f $cartId;
			$cart = $svc.Core.Carts.AddQueryOption('$filter', $query) | Select;
			
			#ASSERT cartitems in cart
			$cartItems = $svc.Core.LoadProperty($cart, 'CartItems') | Select;
			$cartItems.Count | Should Be 2;
			$cartItems.Id -contains $cartItem1Id | Should Be $true;
			$cartItems.Id -contains $cartItem2Id | Should Be $true;
			
			#ACT create order
			$orderParameters = @{
				Name = $orderName;
				Description = "Arbitrary Description";
				Requester = (Get-ApcUser -Current).Id;
				Parameters = '{}';
			}
			
			$createOrder = $svc.Core.InvokeEntitySetActionWithSingleResult("Orders", "Create",  [biz.dfch.CS.Appclusive.Api.Core.Order], $orderParameters );
			
			#get order
			$query = "Name eq '{0}'" -f $orderName;
			$order = $svc.Core.Orders.AddQueryOption('$filter', $query) | Select;
			
			#get order Items
			$query = "OrderId eq {0}" -f $order.Id;
			$orderItems = $svc.Core.OrderItems.AddQueryOption('$filter', $query) | Select;
			
			#ASSERT order Items - they should be as many as the Cart Items in the Cart
			$orderItems.Count | Should Be $cartItems.Count;
			$orderItems.Name -contains $catalogueItemName1;
			$orderItems.Name -contains $catalogueItemName2;
		}
		
		It "PlaceOrder-ShouldDeleteCart" -Test {
			#ARRANGE
			$catalogueName = $entityPrefix + "Catalogue";
			$productName = $entityPrefix + "Product";
			$catalogueItemName = $entityPrefix + "CatalogueItem";
			$cartItemName = $entityPrefix + "CartItem";
			$orderName = $entityPrefix + "Order";
			
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
				Requester = (Get-ApcUser -Current).Id;
				Parameters = '{}';
			}
			
			$createOrder = $svc.Core.InvokeEntitySetActionWithSingleResult("Orders", "Create",  [biz.dfch.CS.Appclusive.Api.Core.Order], $orderParameters );
			
			Start-Sleep -s 5;
			
			#ASSERT get the cart and check that it is deleted
			$query = "Id eq {0}" -f $cartId;
			$cart = $svc.Core.Carts.AddQueryOption('$filter', $query) | Select;
			$cart | Should Be $null;
		}
		
		It "CancelOrder-ShouldSucceed" -Test {
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
				Requester = (Get-ApcUser -Current).Id;
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
			#Write-Host ($orderJob | out-String);
			
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
			$approvalJobRefreshed = Get-ApcJob -id $approvalJob.Id
			$approvalJobRefreshed.Status | Should Be "Approved";
			
			#get the order Job
			$query = "EntityKindId eq {0} and RefId eq '{1}'" -f $orderEntityKindId, $order.Id;
			$orderJob = $svc.Core.Jobs.AddQueryOption('$filter', $query) | Select;
			$orderJob.Status | Should Be "WaitingToRun";
			
			#set order to status "Cancelled"
			$condition = 'Cancel';
			$null = $svc.Core.InvokeEntityActionWithVoidResult($order, "InvokeAction", @{Name=$condition; Parameters="Arbitrary"});
			
			Start-Sleep -s 20;
			
			#ASSERT that order job has status "Cancelled"
			$svc = Enter-Appclusive;
			$orderJobRefreshed = Get-ApcJob -id $orderJob.Id
			$orderJobRefreshed.Status | Should Be "Cancelled";
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

# SIG # Begin signature block
# MIIXDwYJKoZIhvcNAQcCoIIXADCCFvwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUBx+7JHoF02go056RWV7AN2u9
# uxmgghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
# VzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNV
# BAsTB1Jvb3QgQ0ExGzAZBgNVBAMTEkdsb2JhbFNpZ24gUm9vdCBDQTAeFw0xMTA0
# MTMxMDAwMDBaFw0yODAxMjgxMjAwMDBaMFIxCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMSgwJgYDVQQDEx9HbG9iYWxTaWduIFRpbWVzdGFt
# cGluZyBDQSAtIEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlO9l
# +LVXn6BTDTQG6wkft0cYasvwW+T/J6U00feJGr+esc0SQW5m1IGghYtkWkYvmaCN
# d7HivFzdItdqZ9C76Mp03otPDbBS5ZBb60cO8eefnAuQZT4XljBFcm05oRc2yrmg
# jBtPCBn2gTGtYRakYua0QJ7D/PuV9vu1LpWBmODvxevYAll4d/eq41JrUJEpxfz3
# zZNl0mBhIvIG+zLdFlH6Dv2KMPAXCae78wSuq5DnbN96qfTvxGInX2+ZbTh0qhGL
# 2t/HFEzphbLswn1KJo/nVrqm4M+SU4B09APsaLJgvIQgAIMboe60dAXBKY5i0Eex
# +vBTzBj5Ljv5cH60JQIDAQABo4HlMIHiMA4GA1UdDwEB/wQEAwIBBjASBgNVHRMB
# Af8ECDAGAQH/AgEAMB0GA1UdDgQWBBRG2D7/3OO+/4Pm9IWbsN1q1hSpwTBHBgNV
# HSAEQDA+MDwGBFUdIAAwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFs
# c2lnbi5jb20vcmVwb3NpdG9yeS8wMwYDVR0fBCwwKjAooCagJIYiaHR0cDovL2Ny
# bC5nbG9iYWxzaWduLm5ldC9yb290LmNybDAfBgNVHSMEGDAWgBRge2YaRQ2XyolQ
# L30EzTSo//z9SzANBgkqhkiG9w0BAQUFAAOCAQEATl5WkB5GtNlJMfO7FzkoG8IW
# 3f1B3AkFBJtvsqKa1pkuQJkAVbXqP6UgdtOGNNQXzFU6x4Lu76i6vNgGnxVQ380W
# e1I6AtcZGv2v8Hhc4EvFGN86JB7arLipWAQCBzDbsBJe/jG+8ARI9PBw+DpeVoPP
# PfsNvPTF7ZedudTbpSeE4zibi6c1hkQgpDttpGoLoYP9KOva7yj2zIhd+wo7AKvg
# IeviLzVsD440RZfroveZMzV+y5qKu0VN5z+fwtmK+mWybsd+Zf/okuEsMaL3sCc2
# SI8mbzvuTXYfecPlf5Y1vC0OzAGwjn//UYCAp5LUs0RGZIyHTxZjBzFLY7Df8zCC
# BCkwggMRoAMCAQICCwQAAAAAATGJxjfoMA0GCSqGSIb3DQEBCwUAMEwxIDAeBgNV
# BAsTF0dsb2JhbFNpZ24gUm9vdCBDQSAtIFIzMRMwEQYDVQQKEwpHbG9iYWxTaWdu
# MRMwEQYDVQQDEwpHbG9iYWxTaWduMB4XDTExMDgwMjEwMDAwMFoXDTE5MDgwMjEw
# MDAwMFowWjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# MDAuBgNVBAMTJ0dsb2JhbFNpZ24gQ29kZVNpZ25pbmcgQ0EgLSBTSEEyNTYgLSBH
# MjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKPv0Z8p6djTgnY8YqDS
# SdYWHvHP8NC6SEMDLacd8gE0SaQQ6WIT9BP0FoO11VdCSIYrlViH6igEdMtyEQ9h
# JuH6HGEVxyibTQuCDyYrkDqW7aTQaymc9WGI5qRXb+70cNCNF97mZnZfdB5eDFM4
# XZD03zAtGxPReZhUGks4BPQHxCMD05LL94BdqpxWBkQtQUxItC3sNZKaxpXX9c6Q
# MeJ2s2G48XVXQqw7zivIkEnotybPuwyJy9DDo2qhydXjnFMrVyb+Vpp2/WFGomDs
# KUZH8s3ggmLGBFrn7U5AXEgGfZ1f53TJnoRlDVve3NMkHLQUEeurv8QfpLqZ0BdY
# Nc0CAwEAAaOB/TCB+jAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIB
# ADAdBgNVHQ4EFgQUGUq4WuRNMaUU5V7sL6Mc+oCMMmswRwYDVR0gBEAwPjA8BgRV
# HSAAMDQwMgYIKwYBBQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3Jl
# cG9zaXRvcnkvMDYGA1UdHwQvMC0wK6ApoCeGJWh0dHA6Ly9jcmwuZ2xvYmFsc2ln
# bi5uZXQvcm9vdC1yMy5jcmwwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHwYDVR0jBBgw
# FoAUj/BLf6guRSSuTVD6Y5qL3uLdG7wwDQYJKoZIhvcNAQELBQADggEBAHmwaTTi
# BYf2/tRgLC+GeTQD4LEHkwyEXPnk3GzPbrXsCly6C9BoMS4/ZL0Pgmtmd4F/ximl
# F9jwiU2DJBH2bv6d4UgKKKDieySApOzCmgDXsG1szYjVFXjPE/mIpXNNwTYr3MvO
# 23580ovvL72zT006rbtibiiTxAzL2ebK4BEClAOwvT+UKFaQHlPCJ9XJPM0aYx6C
# WRW2QMqngarDVa8z0bV16AnqRwhIIvtdG/Mseml+xddaXlYzPK1X6JMlQsPSXnE7
# ShxU7alVrCgFx8RsXdw8k/ZpPIJRzhoVPV4Bc/9Aouq0rtOO+u5dbEfHQfXUVlfy
# GDcy1tTMS/Zx4HYwggSfMIIDh6ADAgECAhIRIQaggdM/2HrlgkzBa1IJTgMwDQYJ
# KoZIhvcNAQEFBQAwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24g
# bnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzIw
# HhcNMTUwMjAzMDAwMDAwWhcNMjYwMzAzMDAwMDAwWjBgMQswCQYDVQQGEwJTRzEf
# MB0GA1UEChMWR01PIEdsb2JhbFNpZ24gUHRlIEx0ZDEwMC4GA1UEAxMnR2xvYmFs
# U2lnbiBUU0EgZm9yIE1TIEF1dGhlbnRpY29kZSAtIEcyMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAsBeuotO2BDBWHlgPse1VpNZUy9j2czrsXV6rJf02
# pfqEw2FAxUa1WVI7QqIuXxNiEKlb5nPWkiWxfSPjBrOHOg5D8NcAiVOiETFSKG5d
# QHI88gl3p0mSl9RskKB2p/243LOd8gdgLE9YmABr0xVU4Prd/4AsXximmP/Uq+yh
# RVmyLm9iXeDZGayLV5yoJivZF6UQ0kcIGnAsM4t/aIAqtaFda92NAgIpA6p8N7u7
# KU49U5OzpvqP0liTFUy5LauAo6Ml+6/3CGSwekQPXBDXX2E3qk5r09JTJZ2Cc/os
# +XKwqRk5KlD6qdA8OsroW+/1X1H0+QrZlzXeaoXmIwRCrwIDAQABo4IBXzCCAVsw
# DgYDVR0PAQH/BAQDAgeAMEwGA1UdIARFMEMwQQYJKwYBBAGgMgEeMDQwMgYIKwYB
# BQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3JlcG9zaXRvcnkvMAkG
# A1UdEwQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwQgYDVR0fBDswOTA3oDWg
# M4YxaHR0cDovL2NybC5nbG9iYWxzaWduLmNvbS9ncy9nc3RpbWVzdGFtcGluZ2cy
# LmNybDBUBggrBgEFBQcBAQRIMEYwRAYIKwYBBQUHMAKGOGh0dHA6Ly9zZWN1cmUu
# Z2xvYmFsc2lnbi5jb20vY2FjZXJ0L2dzdGltZXN0YW1waW5nZzIuY3J0MB0GA1Ud
# DgQWBBTUooRKOFoYf7pPMFC9ndV6h9YJ9zAfBgNVHSMEGDAWgBRG2D7/3OO+/4Pm
# 9IWbsN1q1hSpwTANBgkqhkiG9w0BAQUFAAOCAQEAgDLcB40coJydPCroPSGLWaFN
# fsxEzgO+fqq8xOZ7c7tL8YjakE51Nyg4Y7nXKw9UqVbOdzmXMHPNm9nZBUUcjaS4
# A11P2RwumODpiObs1wV+Vip79xZbo62PlyUShBuyXGNKCtLvEFRHgoQ1aSicDOQf
# FBYk+nXcdHJuTsrjakOvz302SNG96QaRLC+myHH9z73YnSGY/K/b3iKMr6fzd++d
# 3KNwS0Qa8HiFHvKljDm13IgcN+2tFPUHCya9vm0CXrG4sFhshToN9v9aJwzF3lPn
# VDxWTMlOTDD28lz7GozCgr6tWZH2G01Ve89bAdz9etNvI1wyR5sB88FRFEaKmzCC
# BNYwggO+oAMCAQICEhEhDRayW4wRltP+V8mGEea62TANBgkqhkiG9w0BAQsFADBa
# MQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTEwMC4GA1UE
# AxMnR2xvYmFsU2lnbiBDb2RlU2lnbmluZyBDQSAtIFNIQTI1NiAtIEcyMB4XDTE1
# MDUwNDE2NDMyMVoXDTE4MDUwNDE2NDMyMVowVTELMAkGA1UEBhMCQ0gxDDAKBgNV
# BAgTA1p1ZzEMMAoGA1UEBxMDWnVnMRQwEgYDVQQKEwtkLWZlbnMgR21iSDEUMBIG
# A1UEAxMLZC1mZW5zIEdtYkgwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDNPSzSNPylU9jFM78Q/GjzB7N+VNqikf/use7p8mpnBZ4cf5b4qV3rqQd62rJH
# RlAsxgouCSNQrl8xxfg6/t/I02kPvrzsR4xnDgMiVCqVRAeQsWebafWdTvWmONBS
# lxJejPP8TSgXMKFaDa+2HleTycTBYSoErAZSWpQ0NqF9zBadjsJRVatQuPkTDrwL
# eWibiyOipK9fcNoQpl5ll5H9EG668YJR3fqX9o0TQTkOmxXIL3IJ0UxdpyDpLEkt
# tBG6Y5wAdpF2dQX2phrfFNVY54JOGtuBkNGMSiLFzTkBA1fOlA6ICMYjB8xIFxVv
# rN1tYojCrqYkKMOjwWQz5X8zAgMBAAGjggGZMIIBlTAOBgNVHQ8BAf8EBAMCB4Aw
# TAYDVR0gBEUwQzBBBgkrBgEEAaAyATIwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93
# d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wCQYDVR0TBAIwADATBgNVHSUE
# DDAKBggrBgEFBQcDAzBCBgNVHR8EOzA5MDegNaAzhjFodHRwOi8vY3JsLmdsb2Jh
# bHNpZ24uY29tL2dzL2dzY29kZXNpZ25zaGEyZzIuY3JsMIGQBggrBgEFBQcBAQSB
# gzCBgDBEBggrBgEFBQcwAoY4aHR0cDovL3NlY3VyZS5nbG9iYWxzaWduLmNvbS9j
# YWNlcnQvZ3Njb2Rlc2lnbnNoYTJnMi5jcnQwOAYIKwYBBQUHMAGGLGh0dHA6Ly9v
# Y3NwMi5nbG9iYWxzaWduLmNvbS9nc2NvZGVzaWduc2hhMmcyMB0GA1UdDgQWBBTN
# GDddiIYZy9p3Z84iSIMd27rtUDAfBgNVHSMEGDAWgBQZSrha5E0xpRTlXuwvoxz6
# gIwyazANBgkqhkiG9w0BAQsFAAOCAQEAAApsOzSX1alF00fTeijB/aIthO3UB0ks
# 1Gg3xoKQC1iEQmFG/qlFLiufs52kRPN7L0a7ClNH3iQpaH5IEaUENT9cNEXdKTBG
# 8OrJS8lrDJXImgNEgtSwz0B40h7bM2Z+0DvXDvpmfyM2NwHF/nNVj7NzmczrLRqN
# 9de3tV0pgRqnIYordVcmb24CZl3bzpwzbQQy14Iz+P5Z2cnw+QaYzAuweTZxEUcJ
# bFwpM49c1LMPFJTuOKkUgY90JJ3gVTpyQxfkc7DNBnx74PlRzjFmeGC/hxQt0hvo
# eaAiBdjo/1uuCTToigVnyRH+c0T2AezTeoFb7ne3I538hWeTdU5q9jGCBLcwggSz
# AgEBMHAwWjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# MDAuBgNVBAMTJ0dsb2JhbFNpZ24gQ29kZVNpZ25pbmcgQ0EgLSBTSEEyNTYgLSBH
# MgISESENFrJbjBGW0/5XyYYR5rrZMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEM
# MQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQB
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTlu8xqcg0nz2wy
# GBUzS2301B4gRTANBgkqhkiG9w0BAQEFAASCAQBbcDnUkBa3CB7XPQw9amNVzQLe
# qRwxIOm2otONCKk556vkY1FM6agf0JTcgzA7CpqpYche+YoTJL56Tz/6R8ay8O/G
# wTju7O9Wxu/iYh6yWL9o+mPHHPevW1kb7xvYNEAewyAVmnwhZ1pfx8a0SU17DDc8
# ogXrfU2MoFXxCVXsM3MwTgxdZp1gRyl0x23Pt83BVwgEs/Sr+HE2b7IHk+bqaMg3
# cTK7HjOg7RRapVYuj96ev9uh7VhgQtzE+K+2yj9qcpaf831bCuYBf7plVktQYUvz
# rNqSZ6e5XtBi6wxVn4/sylF+hUlLB/yxkGYG4fDYFb2iCaIEZnesqsbkpnwooYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEhBqCB0z/YeuWCTMFrUglOAzAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE2
# MDcwNDExMjIyNFowIwYJKoZIhvcNAQkEMRYEFHFGJhsZMh1uLZKLIDuWX0TohxAe
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUs2MItNTN7U/PvWa5Vfrjv7Es
# KeYwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# BqCB0z/YeuWCTMFrUglOAzANBgkqhkiG9w0BAQEFAASCAQAJcU+QdRtN8EUneUSf
# c6GMPcP+K5WXkFWUDAdmnHeKMQcfh/MoSLI1t0I5Gdv43oU6s2gecLlJmiffehEi
# KqjQ6STtLBJ/ZTnjDKXsr6NjZ/Xgj22y/ybfARzi6t2B3DwXAEB735fA68uw89n6
# NHOSqfVPZ6E5La2nccamnPgEQSbgGXc72RYP970ptWLjdfXOznf5Xbn0E8LXRg0X
# L3prqssOkLQ2+oR8tgH6FNCT9xOFqawJ/Pm94cChLQQ7S1ZKsD+fSpr+oZ7T9+Uq
# +5tIaDD4G+PNlbbFv+XiUg/VY4hNbfUQ+IyBX7V+sisWxvKtV4YzR4VoCXEvVW3v
# hOJB
# SIG # End signature block

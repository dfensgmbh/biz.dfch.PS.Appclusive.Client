#includes tests for CLOUDTCL-1875 and CLOUDTCL-1876

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe "Cart.Tests" -Tags "Cart.Tests" {

	Mock Export-ModuleMember { return $null; }
	. "$here\$sut"
	. "$here\CatalogueAndCatalogueItems.ps1"
	. "$here\Product.ps1"
	
	$entityPrefix = "TestItem-";
	$usedEntitySets = @("CartItems", "CatalogueItems", "Products", "Catalogues", "Carts");

	Context "#CLOUDTCL-1875-CartTests" {
	
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
	
		It "Cart-AddingCartItem-CreatesCart" -Test {
			#ARRANGE
			$catalogueName = $entityPrefix + "Catalogue";
			$productName = $entityPrefix + "Product";
			$catalogueItemName = $entityPrefix + "CatalogueItem";
			$cartItemName = $entityPrefix + "CartItem";
			
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
			
			#ASSERT check that the cart Id of the cart Item belongs to a created Cart
			$carts = $svc.Core.Carts | Select;
			$carts.Id -Contains $cartId | Should Be $true;
			
			#CLEANUP remove cart
			Remove-ApcEntity -svc $svc -Id $cartId -EntitySetName "Carts" -Confirm:$false;
		}
		
		It "DeleteCartDeletesReferredCartItem" -Test {
			#ARRANGE
			$catalogueName = $entityPrefix + "Catalogue";
			$productName = $entityPrefix + "Product";
			$catalogueItemName = $entityPrefix + "CatalogueItem";
			$cartItemName = $entityPrefix + "CartItem";
			
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
			$filter = "Id eq {0}" -f $cartId;
			$cart = $svc.Core.Carts.AddQueryOption('$filter', $filter) | Select;
			
			#ASSERT cart has cart item
			$loadedCartItems = $svc.Core.LoadProperty($cart, 'CartItems') | Select;
			$loadedCartItems.Count | Should Be 1;
			$loadedCartItems.Id -Contains $catalogueItemId;
			
			#ACT delete cart
			$svc.Core.DeleteObject($cart);
			$result = $svc.Core.SaveChanges();
			
			#ASSERT that cart is deleted
			$result.StatusCode | Should Be 204;
			$filter = "Id eq {0}" -f $cartId;
			$deletedCart = $svc.Core.Carts.AddQueryOption('$filter', $filter) | Select;
			$deletedCart | Should Be $null;
			
			#ASSERT that cart item is deleted
			$filter = "Id eq {0}" -f $cartItemId;
			$null = $svc.Core.Carts.AddQueryOption('$filter', $filter) | Select;
		}
	}
	
	Context "#CLOUDTCL-1876-CartItemTests" {	
		
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
		
		It "CartItem-CreateAndDelete" -Test {
			#ARRANGE
			$catalogueName = $entityPrefix + "Catalogue";
			$productName = $entityPrefix + "Product";
			$catalogueItemName = $entityPrefix + "CatalogueItem";
			$cartItemName = $entityPrefix + "CartItem";
			
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
			
			#ACT Remove CartItem
			Delete-CartItem -svc $svc -cartItemId $cartItemId;
		}
		
		It "CartItem-Update" -Test {
			#ARRANGE
			$catalogueName = $entityPrefix + "Catalogue";
			$productName = $entityPrefix + "Product";
			$catalogueItemName = $entityPrefix + "CatalogueItem";
			$cartItemName = $entityPrefix + "CartItem";
			$newDescription = "Description Updated";
			
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
			
			#ACT update cart item
			$null = Update-CartItem -svc $svc -Id $cartItemId -Description $newDescription;
		}
		
		It "AddMoreThanOneCartItemsInCart" -Test {
			#ARRANGE
			$catalogueName = $entityPrefix + "Catalogue";
			$productName = $entityPrefix + "Product";
			$catalogueItemName1 = $entityPrefix + "CatalogueItem1";
			$catalogueItemName2 = $entityPrefix + "CatalogueItem2";
			$cartItemName1 = $entityPrefix + "CartItem1";
			$cartItemName2 = $entityPrefix + "CartItem2";
			
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
			
			#ACT create new cart item
			$cartItem1 = Create-CartItem -svc $svc -Name $cartItemName1 -CatalogueItemId $catalogueItem1Id;
			$cartItem2 = Create-CartItem -svc $svc -Name $cartItemName2 -CatalogueItemId $catalogueItem2Id;
			
			#ASSERT cart from the items, should be the same
			$cartItem1.CartId | Should Be $cartItem2.CartId;
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU0Oom00kFfWvICCbZeerey+SP
# oGSgghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRn7O+W+TDYCYQy
# f4HJtVSt40JEmTANBgkqhkiG9w0BAQEFAASCAQBIbvFu/qJyVcifC2EWU+T+MHn/
# RMc13o6EX0hy/pqqRVtLQzV++W9fkj6NSxUX/QQeWxBPxZS5d52Nwu3wktVMkcT/
# 4Vtye/6Icd4D6hoLFP+4/0ciolrrdR9ybq7/qJ3XdHNx3JAg8JFrktP71eNNnxGA
# AZrCCo6/882VLguF74kiq+mU74oP2L+5oIq7Kjb1wWt4uIC6q3GSthyWQ+wX8cA0
# xF6bCieZaaqe+dmSfokZQczaJ5NuwFTI0iGeutOaqg5NQHyjErbTgYVUvKKEUqMT
# jeuvn0PbYg5DdMAoeivsQJ2ttrM7Q9TNbiEKb1IK2tDdo9NfKsNvq0V0YSheoYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEhBqCB0z/YeuWCTMFrUglOAzAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE2
# MDcwNDExMjIwOVowIwYJKoZIhvcNAQkEMRYEFI40XIdVzCiw/ron+SBynXPVu73K
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUs2MItNTN7U/PvWa5Vfrjv7Es
# KeYwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# BqCB0z/YeuWCTMFrUglOAzANBgkqhkiG9w0BAQEFAASCAQCFV26CMB13R+2uudEe
# 5V7APkkFIFACIgm2oZWeFHnayRGGW1NsAPSwB+mw/Y90XkwLXGq6zsYSZ3lKyJXB
# AkhfaXVNPf7AuLmWuLYj5y7Jz0xhJFpANEcIym6X3/2xyNYk5rZ/2laIEMuCS6HS
# m92ei1F6jBpCkL08BTCFChaK3NU9B9+7q1kOvHcFwpkS3+3Oa+aebzWaFxdbZxHo
# t0VubwWcMyxnNZJWXIFXSyMPLxcwH/cy7NXY/m7qcDRubMytGyebBfepRsoJti0j
# +fxF/LtwW3WSqV7ujRU77jDLOmhUP4BgWnLdSTOM+I7kYzEXbI3jw39sOIG8fiTZ
# r/I+
# SIG # End signature block

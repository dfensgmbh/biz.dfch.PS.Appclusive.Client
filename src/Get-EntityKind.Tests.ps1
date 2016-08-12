
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Get-EntityKind" -Tags "Get-EntityKind" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Get-User.ps1"
	. "$here\Get-Job.ps1"
	. "$here\Set-Connector.ps1"
	. "$here\Get-Connector.ps1"
	. "$here\Set-Interface.ps1"
	. "$here\Get-Interface.ps1"
	. "$here\Remove-Entity.ps1"
	. "$here\Format-ResultAs.ps1"
	
	Context "Get-EntityKind" {	
        BeforeEach {
            $moduleName = 'biz.dfch.PS.Appclusive.Client';
            Remove-Module $moduleName -ErrorAction:SilentlyContinue;
            Import-Module $moduleName;

            $svc = Enter-ApcServer;
        }

		# Context wide constants
		# N/A
		
		It "Warmup" -Test {
			$true | Should Be $true;
		}

		It "Get-EntityKindListAvailable-ShouldReturnList" -Test {
			# Arrange
			# N/A
			
			# Act
			$result = Get-EntityKind -svc $svc -ListAvailable;

			# Assert
			$result | Should Not Be $null;
			$result -is [Array] | Should Be $true;
			0 -lt $result.Count | Should Be $true;
		}

		It "Get-EntityKindListAvailableSelectName-ShouldReturnListWithNamesOnly" -Test {
			# Arrange
			# N/A
			
			# Act
			$result = Get-EntityKind -svc $svc -ListAvailable -Select Name;

			# Assert
			$result | Should Not Be $null;
			$result -is [Array] | Should Be $true;
			0 -lt $result.Count | Should Be $true;
			$result[0].Name | Should Not Be $null;
			$result[0].Id | Should Be $null;
		}

		It "Get-EntityKind-ShouldReturnFirstEntity" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$result = Get-EntityKind -svc $svc -First $ShowFirst;

			# Assert
			$result | Should Not Be $null;
			$result -is [biz.dfch.CS.Appclusive.Api.Core.EntityKind] | Should Be $true;
		}
		
		It "Get-EntityKind-ShouldReturnFirstEntityById" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$resultFirst = Get-EntityKind -svc $svc -First $ShowFirst;
			$Id = $resultFirst.Id;
			$result = Get-EntityKind -svc $svc -Id $Id;

			# Assert
			$result | Should Not Be $null;
			$result | Should Be $resultFirst;
			$result -is [biz.dfch.CS.Appclusive.Api.Core.EntityKind] | Should Be $true;
		}
		
		It "Get-EntityKind-ShouldReturnFiveEntities" -Test {
			# Arrange
			$ShowFirst = 5;
			
			# Act
			$result = Get-EntityKind -svc $svc -First $ShowFirst;

			# Assert
			$result | Should Not Be $null;
			$ShowFirst -eq $result.Count | Should Be $true;
			$result[0] -is [biz.dfch.CS.Appclusive.Api.Core.EntityKind] | Should Be $true;
		}

		It "Get-EntityKindThatDoesNotExist-ShouldReturnNull" -Test {
			# Arrange
			$EntityKindName = 'EntityKind-that-does-not-exist';
			
			# Act
			$result = Get-EntityKind -svc $svc -Name $EntityKindName;

			# Assert
			$result | Should Be $null;
		}
		
		It "Get-EntityKindThatDoesNotExist-ShouldReturnDefaultValue" -Test {
			# Arrange
			$EntityKindName = 'EntityKind-that-does-not-exist';
			$DefaultValue = 'MyDefaultValue';
			
			# Act
			$result = Get-EntityKind -svc $svc -Name $EntityKindName -DefaultValue $DefaultValue;

			# Assert
			$result | Should Be $DefaultValue;
		}
		
		It "Get-EntityKind-ShouldReturnXML" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$result = Get-EntityKind -svc $svc -First $ShowFirst -As xml;

			# Assert
			$result | Should Not Be $null;
			$result.Substring(0,5) | Should Be '<?xml';
		}
		
		It "Get-EntityKind-ShouldReturnJSON" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$result = Get-EntityKind -svc $svc -First $ShowFirst -As json;

			# Assert
			$result | Should Not Be $null;
			$result.Substring(0, 1) | Should Be '{';
			$result.Substring($result.Length -1, 1) | Should Be '}';
		}
		
		It "Get-EntityKind-WithInvalidId-ShouldReturnException" -Test {
			# Act
			try 
			{
				$result = Get-EntityKind -svc $svc -Id 'myEntityKind';
				'throw exception' | Should Be $true;
			} 
			catch
			{
				# Assert
			   	$result | Should Be $null;
			}
		}
		
		It "Get-EntityKindByCreatedByThatDoesNotExist-ShouldReturnNull" -Test {
			# Arrange
			$User = 'User-that-does-not-exist';
			
			# Act
			$result = Get-EntityKind -CreatedBy $User -svc $svc;

			# Assert
		   	$result | Should Be $null;
		}
		
		It "Get-EntityKindByCreatedBy-ShouldReturnListWithEntities" -Test {
			# Arrange
			$User = 'SYSTEM';
			
			# Act
			$result = Get-EntityKind -svc $svc -CreatedBy $User;

			# Assert
		   	$result | Should Not Be $null;
			$result -is [Array] | Should Be $true;
			0 -lt $result.Count | Should Be $true;
		}
		
		It "Get-EntityKindByModifiedBy-ShouldReturnListWithEntities" -Test {
			# Arrange
			$User = 'SYSTEM';
			
			# Act
			$result = Get-EntityKind -svc $svc -ModifiedBy $User;

			# Assert
		   	$result | Should Not Be $null;
			$result -is [Array] | Should Be $true;
			0 -lt $result.Count | Should Be $true;
		}
	}
	
	Context "EntityKindName-Resolver" {
        BeforeEach {
            $moduleName = 'biz.dfch.PS.Appclusive.Client';
            Remove-Module $moduleName -ErrorAction:SilentlyContinue;
            Import-Module $moduleName;

            $svc = Enter-ApcServer;
        }

		It "ResolveByEntityKindName-Succeeds" -Test {
			
			# Arrange
			$name = "^Node$"
			$id = [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::Node.value__;
			
			# Act
			$result = Get-EntityKind -svc $svc -ResolveByName $name
			
			# Assert
			$result | Should Not Be $null;
			$result | Should Be $id;
		}

		It "ResolveByEntityKindNameWithMultipleMatches-ReturnsList" -Test {
			
			# Arrange
			$name = "Bag"
			
			# Act
			$result = Get-EntityKind -svc $svc -ResolveByName $name
			
			# Assert
			$result | Should Not Be $null;
			$result.Count -gt 1 | Should Be $true;
			$result -contains [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::ExternalNodeBag.value__ | Should Be $true;
			$result -contains [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::EntityBag.value__ | Should Be $true;
		}

		It "ResolveByInexistentEntityKindName-ReturnsNull" -Test {
			
			# Arrange
			$name = "inexistent-EntityKindName"
			
			# Act
			$result = Get-EntityKind -svc $svc -ResolveByName $name;
			
			# Assert
			$result | Should Be $null;
		}
	}
	
	Context "EntityKindID-Resolver" {
        BeforeEach {
            $moduleName = 'biz.dfch.PS.Appclusive.Client';
            Remove-Module $moduleName -ErrorAction:SilentlyContinue;
            Import-Module $moduleName;

            $svc = Enter-ApcServer;
        }
	
		It "ResolveByEntityKindID-Succeeds" -Test {
			
			# Arrange
			$name = "Node"
			$id = [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::Node.value__;
			
			# Act
			$result = Get-EntityKind -svc $svc -ResolveById $id
			
			# Assert
			$result | Should Not Be $null;
			$result | Should Be $name;
		}

		It "ResolveByInexistentEntityKindId-ReturnsNull" -Test {
			
			# Arrange
			$id = [long]::MaxValue;
			
			# Act
			$result = Get-EntityKind -svc $svc -ResolveById $id;
			
			# Assert
			$result | Should Be $null;
		}
	}

    Context "Get-EntityKind-Connector" {
        BeforeEach {
            $moduleName = 'biz.dfch.PS.Appclusive.Client';
            Remove-Module $moduleName -ErrorAction:SilentlyContinue;
            Import-Module $moduleName;

            $svc = Enter-ApcServer;
        }
    
        $entityPrefix = "GetEntityKindConnector";
        $entitySetName = "EntityKinds";
	
        $REQUIRE = 2L;
        $PROVIDE = 1L;

        AfterAll {
            $svc = Enter-ApcServer;
            $entities = $svc.Core.Connectors.AddQueryOption('$filter', "startswith(Name, 'GetEntityKindConnector')") | Select;
         
            foreach ($entity in $entities)
            {
                Remove-Entity -svc $svc -Id $entity.Id -EntitySetName "Connectors" -Confirm:$false;
            }
            
            $svc = Enter-ApcServer;
            $interfaces = $svc.Core.Interfaces.AddQueryOption('$filter', "startswith(Name, 'GetEntityKindConnector')") | Select;
         
            foreach ($interface in $interfaces)
            {
                Remove-Entity -svc $svc -Id $interface.Id -EntitySetName "Interfaces" -Confirm:$false;
            }
            
            $svc = Enter-ApcServer;
            $entityKinds = $svc.Core.EntityKinds.AddQueryOption('$filter', "startswith(Name, 'GetEntityKindConnector')") | Select;
         
            foreach ($entityKind in $entityKinds)
            {
                Remove-Entity -svc $svc -Id $entityKind.Id -EntitySetName "EntityKinds" -Confirm:$false;
            }
        }
        
        function CreateInterface()
        {
            $Name = "{0}-Name-{1}" -f $entityPrefix,[guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();

			# Act
			return Set-Interface -svc $svc -Name $Name -Description $Description -CreateIfNotExist;
        }

        function CreateEntityKind() 
        {
            $entityKind = New-Object biz.dfch.CS.Appclusive.Api.Core.EntityKind;
            $entityKind.Name = "{0}-Name-{1}" -f $entityPrefix,[guid]::NewGuid().ToString();
            $entityKind.Version = "{0}-Version-{1}" -f $entityPrefix,[guid]::NewGuid().ToString();
            
            $svc.Core.AddToEntityKinds($entityKind);
            $svc.Core.SaveChanges();

            return $entityKind;
        }

        function CreateConnector([long]$interfaceId, [long]$entityKindId, [long]$connectionType) 
        {
			$Name = "{0}-Name-{1}" -f $entityPrefix,[guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
            $Multiplicity = 42;
            			
            if ($connectionType -eq $REQUIRE)
            {
                return Set-Connector -svc $svc `
                                -Name $Name `
                                -InterfaceId $interfaceId `
                                -EntityKindId $entityKindId `
                                -Description $Description `
                                -Multiplicity $Multiplicity `
                                -Require `
                                -CreateIfNotExist;
            }
            else
            {
                return Set-Connector -svc $svc `
                                -Name $Name `
                                -InterfaceId $interfaceId `
                                -EntityKindId $entityKindId `
                                -Description $Description `
                                -Multiplicity $Multiplicity `
                                -Provide `
                                -CreateIfNotExist;
            }
        }
        
        It "Get-EntityKindWithConsumers-ShouldReturnListOfConnectors" -Test {
            # Arrange
            $interface = CreateInterface | Select;
            $entityKind = CreateEntityKind | Select;
            $interfaceB = CreateInterface | Select;
                        			
            CreateConnector $interface.Id $entityKind.Id $PROVIDE;
            CreateConnector $interface.Id $entityKind.Id $REQUIRE;		
            CreateConnector $interfaceB.Id $entityKind.Id $REQUIRE;

			# Act
            $list = Get-EntityKind -svc $svc -Id $entityKind.Id -Consumers;

			# Assert
            $list | Should Not Be $null;
            $list.Count | Should Be 2;
            
            $list[0] | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.Connector]
        }

        It "Get-EntityKindWithProviders-ShouldReturnListOfConnectors" -Test {
            # Arrange
            $interface = CreateInterface | Select;
            $entityKind = CreateEntityKind | Select;
            $interfaceB = CreateInterface | Select;
                        			
            CreateConnector $interface.Id $entityKind.Id $PROVIDE;
            CreateConnector $interface.Id $entityKind.Id $REQUIRE;		
            CreateConnector $interfaceB.Id $entityKind.Id $REQUIRE;

			# Act
            $list = Get-EntityKind -svc $svc -Id $entityKind.Id -Providers;

			# Assert
            $list | Should Not Be $null;
            $list.Count | Should Be 1;

            $list[0] | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.Connector] 
        }

        It "Get-EntityKindByProvideInterfaceId-ShouldReturnList" -Test {        
            # Arrange
            $interface = CreateInterface | Select;
            $interfaceB = CreateInterface | Select;
            $entityKind = CreateEntityKind | Select;
            $entityKindB = CreateEntityKind | Select;

            CreateConnector $interface.Id $entityKind.Id $PROVIDE;
            CreateConnector $interface.Id $entityKind.Id $REQUIRE;		
            CreateConnector $interfaceB.Id $entityKind.Id $REQUIRE;		
            CreateConnector $interface.Id $entityKindB.Id $PROVIDE;

			# Act
            $list = Get-EntityKind -svc $svc -ProvideInterface $interface.Id;

			# Assert
            $list | Should Not Be $null;
            $list.Count | Should Be 2;
            
            $list[0] | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.EntityKind]
        }

        It "Get-EntityKindByRequireInterfaceId-ShouldReturnList" -test {
        # Arrange
            $interface = CreateInterface | Select;
            $interfaceB = CreateInterface | Select;
            $entityKind = CreateEntityKind | Select;
            $entityKindB = CreateEntityKind | Select;

            CreateConnector $interface.Id $entityKind.Id $PROVIDE;
            CreateConnector $interface.Id $entityKind.Id $REQUIRE;		
            CreateConnector $interfaceB.Id $entityKind.Id $REQUIRE;		
            CreateConnector $interface.Id $entityKindB.Id $PROVIDE;

			# Act
            $list = Get-EntityKind -svc $svc -RequireInterface $interface.Id;

			# Assert
            $list | Should Not Be $null;
            $list.Count | Should Be 1;
            
            $list[0] | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.EntityKind];

            $list[0].Id | Should Be $entityKind.Id;
        }
    }
}

#
# Copyright 2015-2016 d-fens GmbH
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
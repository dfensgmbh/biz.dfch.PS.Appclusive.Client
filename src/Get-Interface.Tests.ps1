
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Get-Interface" -Tags "Get-Interface" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Get-Job.ps1"
	. "$here\Set-Connector.ps1"
	. "$here\Get-Connector.ps1"
	. "$here\Set-Interface.ps1"
	. "$here\Get-Interface.ps1"
	. "$here\Remove-Entity.ps1"
	. "$here\Format-ResultAs.ps1"
	
	Context "Get-Interface" {
        BeforeEach {
            $moduleName = 'biz.dfch.PS.Appclusive.Client';
            Remove-Module $moduleName -ErrorAction:SilentlyContinue;
            Import-Module $moduleName;

            $svc = Enter-ApcServer;
        }

        $entityPrefix = "GetInterface";
	
        AfterAll {
            $moduleName = 'biz.dfch.PS.Appclusive.Client';
            Remove-Module $moduleName -ErrorAction:SilentlyContinue;
            Import-Module $moduleName;

            $svc = Enter-ApcServer;
            $entities = $svc.Core.Connectors.AddQueryOption('$filter', "startswith(Name, 'GetInterface')") | Select;
         
            foreach ($entity in $entities)
            {
                Remove-Entity -svc $svc -Id $entity.Id -EntitySetName "Connectors" -Confirm:$false;
            }
            
            $svc = Enter-ApcServer;
            $interfaces = $svc.Core.Interfaces.AddQueryOption('$filter', "startswith(Name, 'GetInterface')") | Select;
         
            foreach ($interface in $interfaces)
            {
                Remove-Entity -svc $svc -Id $interface.Id -EntitySetName "Interfaces" -Confirm:$false;
            }
            
            $svc = Enter-ApcServer;
            $entityKinds = $svc.Core.EntityKinds.AddQueryOption('$filter', "startswith(Name, 'GetInterface')") | Select;
         
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

	    It "Get-InterfaceWithoutId-ShouldReturnList" -Test {

			# Arrange
			$Name = "{0}-Name-{1}" -f $entityPrefix,[guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();

			$result = Set-Interface -svc $svc -Name $Name -Description $Description -CreateIfNotExist;

			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Name | Should Be $Name;
			$result.Description | Should Be $Description;

			# Act
            $list = Get-Interface -svc $svc;

			# Assert
            $list | Should Not Be $null;
            $list.Count | Should BeGreaterThan 1;
		}

	    It "Get-InterfaceWithId-ShouldReturnEntity" -Test {
			# Arrange
			$Name = "{0}-Name-{1}" -f $entityPrefix,[guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();

			$result = Set-Interface -svc $svc -Name $Name -Description $Description -CreateIfNotExist;

			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Name | Should Be $Name;
			$result.Description | Should Be $Description;

            # Act
            $entity = Get-Interface -svc $svc -Id $result.Id;

            # Assert
            $entity | Should Not Be $null;
            $entity.Id | Should Be $result.Id;
            $entity.Name | Should Be $result.Name;
            $entity.Description | Should be $entity.Description;
		}

	    It "Get-InterfaceWithName-ShouldReturnEntity" -Test {
			# Arrange
			$Name = "{0}-Name-{1}" -f $entityPrefix,[guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();

			$result = Set-Interface -svc $svc -Name $Name -Description $Description -CreateIfNotExist;

			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Name | Should Be $Name;
			$result.Description | Should Be $Description;

            # Act
            $entity = Get-Interface -svc $svc -Name $result.Name;

            # Assert
            $entity | Should Not Be $null;
            $entity.Id | Should Be $result.Id;
            $entity.Name | Should Be $result.Name;
            $entity.Description | Should be $entity.Description;
		}

        It "Get-InterfaceWithRequires-ShouldReturnList" -Test {
            # Arrange
            $interface = CreateInterface | Select;
            $entityKind = CreateEntityKind | Select;
            $entityKindB = CreateEntityKind | Select;

			$Name = "{0}-Name-{1}" -f $entityPrefix,[guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
            $InterfaceId = $interface.Id;
            $EntityKindId = $entityKind.Id;
            $Multiplicity = 15;
            			
            Set-Connector -svc $svc `
                            -Name $Name `
                            -InterfaceId $InterfaceId `
                            -EntityKindId $EntityKindId `
                            -Description $Description `
                            -Multiplicity $Multiplicity `
                            -Require `
                            -CreateIfNotExist;
            
			Set-Connector -svc $svc `
                            -Name $Name `
                            -InterfaceId $InterfaceId `
                            -EntityKindId $entityKindB.Id `
                            -Description $Description `
                            -Multiplicity $Multiplicity `
                            -Provide `
                            -CreateIfNotExist;
                            
            Set-Connector -svc $svc `
                            -Name $Name `
                            -InterfaceId $InterfaceId `
                            -EntityKindId $EntityKindId `
                            -Description $Description `
                            -Multiplicity $Multiplicity `
                            -Require `
                            -CreateIfNotExist;
			# Act
            $list = Get-Interface -svc $svc -Id $InterfaceId -Consumers;

			# Assert
            $list | Should Not Be $null;
            $list.Count | Should Be 2;
        }

        It "Get-InterfaceWithProvides-ShouldReturnList" -Test {
            # Arrange
            $interface = CreateInterface | Select;
            $entityKind = CreateEntityKind | Select;
            $entityKindB = CreateEntityKind | Select;

			$Name = "{0}-Name-{1}" -f $entityPrefix,[guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
            $InterfaceId = $interface.Id;
            $entityKindId = $entityKind.Id;
            $Multiplicity = 15;
            			
            Set-Connector -svc $svc `
                            -Name $Name `
                            -InterfaceId $InterfaceId `
                            -EntityKindId $entityKindId `
                            -Description $Description `
                            -Multiplicity $Multiplicity `
                            -Require `
                            -CreateIfNotExist;
            
			Set-Connector -svc $svc `
                            -Name $Name `
                            -InterfaceId $InterfaceId `
                            -EntityKindId $entityKindB.Id `
                            -Description $Description `
                            -Multiplicity $Multiplicity `
                            -Provide `
                            -CreateIfNotExist;
                            
            Set-Connector -svc $svc `
                            -Name $Name `
                            -InterfaceId $InterfaceId `
                            -EntityKindId $entityKindId `
                            -Description $Description `
                            -Multiplicity $Multiplicity `
                            -Require `
                            -CreateIfNotExist;
			# Act
            $list = Get-Interface -svc $svc -Id $InterfaceId -Providers;

			# Assert
            $list | Should Not Be $null;
            $list.Count | Should Be 1;
        }
    }
}
 
#
# Copyright 2016 d-fens GmbH
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

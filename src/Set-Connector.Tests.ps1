
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe -Tags "Set-Interface" "Set-Interface" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Set-Connector.ps1"
	. "$here\Set-Interface.ps1"
	. "$here\Remove-Entity.ps1"
	. "$here\Format-ResultAs.ps1"
	
	$svc = Enter-ApcServer;

	Context "Set-Connector" {

        $entityPrefix = "SetConnector";
	
        AfterAll {
            $svc = Enter-ApcServer;
            $entities = $svc.Core.Connectors.AddQueryOption('$filter', "startswith(Name, 'SetConnector')") | Select;
         
            foreach ($entity in $entities)
            {
                Remove-Entity -svc $svc -Id $entity.Id -EntitySetName "Connectors" -Confirm:$false;
            }
            
            $svc = Enter-ApcServer;
            $interfaces = $svc.Core.Interfaces.AddQueryOption('$filter', "startswith(Name, 'SetConnector')") | Select;
         
            foreach ($interface in $interfaces)
            {
                Remove-Entity -svc $svc -Id $interface.Id -EntitySetName "Interfaces" -Confirm:$false;
            }
            
            $svc = Enter-ApcServer;
            $entityKinds = $svc.Core.EntityKinds.AddQueryOption('$filter', "startswith(Name, 'SetConnector')") | Select;
         
            foreach ($entityKind in $entityKinds)
            {
                Remove-Entity -svc $svc -Id $entityKind.Id -EntitySetName "EntityKinds" -Confirm:$false;
            }
        }

        function createInterface()
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

		# Context wide constants
		# N/A
	    It "Set-ConnectorWithCreateIfNotExistRequire-ShouldReturnNewEntity" -Test {
			# Arrange
            $interface = CreateInterface | Select;
            $entityKind = CreateEntityKind | Select;

			$Name = "{0}-Name-{1}" -f $entityPrefix,[guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
            $InterfaceId = $interface.Id;
            $entityKindId = $entityKind.Id;
            $Multiplicity = 15;

			# Act
			$result = Set-Connector -svc $svc `
                                    -Name $Name `
                                    -InterfaceId $InterfaceId `
                                    -EntityKindId $entityKindId `
                                    -Description $Description `
                                    -Multiplicity $Multiplicity `
                                    -Require `
                                    -CreateIfNotExist;

			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Name | Should Be $Name;
			$result.InterfaceId | Should Be $InterfaceId;
			$result.EntityKindId | Should Be $EntityKindId;
			$result.Description | Should Be $Description;
			$result.Multiplicity | Should Be $Multiplicity;
			$result.ConnectionType | Should Be 2;
		}

		# Context wide constants
		# N/A
	    It "Set-ConnectorWithCreateIfNotExistProvide-ShouldReturnNewEntity" -Test {
			# Arrange
            $interface = CreateInterface | Select;
            $entityKind = CreateEntityKind | Select;

			$Name = "{0}-Name-{1}" -f $entityPrefix,[guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
            $InterfaceId = $interface.Id;
            $entityKindId = $entityKind.Id;
            $Multiplicity = 10;

			# Act
			$result = Set-Connector -svc $svc `
                                    -Name $Name `
                                    -InterfaceId $InterfaceId `
                                    -EntityKindId $entityKindId `
                                    -Description $Description `
                                    -Multiplicity $Multiplicity `
                                    -Provide `
                                    -CreateIfNotExist;

			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Name | Should Be $Name;
			$result.InterfaceId | Should Be $InterfaceId;
			$result.EntityKindId | Should Be $EntityKindId;
			$result.Description | Should Be $Description;
			$result.Multiplicity | Should Be $Multiplicity;
			$result.ConnectionType | Should Be 1;
		}
	}
}
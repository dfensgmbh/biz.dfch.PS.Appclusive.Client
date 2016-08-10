
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe -Tags "Remove-Connector" "Remove-Connector" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Set-Interface.ps1"
	. "$here\Set-Connector.ps1"
	. "$here\Get-Connector.ps1"
	. "$here\Remove-Connector.ps1"
	. "$here\Remove-Entity.ps1"
	. "$here\Format-ResultAs.ps1"
	
	$svc = Enter-ApcServer;

	Context "Remove-Connector" {

        $entityPrefix = "RemoveConnector";
	
        AfterAll {
            $svc = Enter-ApcServer;
            $entities = $svc.Core.Connectors.AddQueryOption('$filter', "startswith(Name, 'RemoveConnector')") | Select;
         
            foreach ($entity in $entities)
            {
                Remove-Entity -svc $svc -Id $entity.Id -EntitySetName "Connectors" -Confirm:$false;
            }
            
            $svc = Enter-ApcServer;
            $interfaces = $svc.Core.Interfaces.AddQueryOption('$filter', "startswith(Name, 'RemoveConnector')") | Select;
         
            foreach ($interface in $interfaces)
            {
                Remove-Entity -svc $svc -Id $interface.Id -EntitySetName "Interfaces" -Confirm:$false;
            }
            
            $svc = Enter-ApcServer;
            $entityKinds = $svc.Core.EntityKinds.AddQueryOption('$filter', "startswith(Name, 'RemoveConnector')") | Select;
         
            foreach ($entityKind in $entityKinds)
            {
                Remove-Entity -svc $svc -Id $entityKind.Id -EntitySetName "EntityKinds" -Confirm:$false;
            }
        }

        BeforeEach {
            $svc = Enter-ApcServer;
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
        
		# Context wide constants
		# N/A
	    It "Remove-ConnectorWithId-ShouldReturnDeletedEntity" -Test {

			# Arrange
            $interface = CreateInterface | Select;
            $entityKind = CreateEntityKind | Select;

			$Name = "{0}-Name-{1}" -f $entityPrefix,[guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
            $InterfaceId = $interface.Id;
            $entityKindId = $entityKind.Id;
            $Multiplicity = 15;
            			            
			$connector = Set-Connector -svc $svc `                            -Name $Name `                            -InterfaceId $InterfaceId `
                            -EntityKindId $entityKindId `
                            -Description $Description `
                            -Multiplicity $Multiplicity `
                            -Provide `
                            -CreateIfNotExist;
			
            # Act
            $entity = Get-Connector -svc $svc -Id $connector.Id;

            $deletedEntity = Remove-Connector -svc $svc -Id $entity.Id;
            
            # Assert
            
            $entity = Get-Connector -svc $svc -Id $entity.Id;            
            $entity | Should Be $null;
		}
	}
}
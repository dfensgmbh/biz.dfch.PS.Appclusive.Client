
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe -Tags "Remove-Interface" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Set-Interface.ps1"
	. "$here\Get-Interface.ps1"
	. "$here\Remove-Interface.ps1"
	. "$here\Remove-Entity.ps1"
	. "$here\Format-ResultAs.ps1"
	
	$svc = Enter-ApcServer;

	Context "Remove-Interface" {
	
        $interfacePrefix = "RemoveInterface";
	
        AfterAll {
            $interfaces = $svc.Core.Interfaces.AddQueryOption('$filter', "startswith(Name, 'RemoveInterface')") | Select;
         
            foreach ($interface in $interfaces)
            {
                Remove-Entity -svc $svc -Id $interface.Id -EntitySetName "Interfaces" -Confirm:$false;
            }
        }

		It "Remove-InterfaceByName-ShouldReturnRemovedEntity" -Test {
			# Arrange
			$Name = "{0}-Name-{1}" -f $interfacePrefix,[guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();

			$result = Set-Interface -svc $svc -Name $Name -Description $Description -CreateIfNotExist;

			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Name | Should Be $Name;
			$result.Description | Should Be $Description;

            $entity = Get-Interface -svc $svc -Id $result.Id;

            $entity | Should Not Be $null;
            $entity.Id | Should Be $result.Id;
            $entity.Name | Should Be $result.Name;
            $entity.Description | Should be $entity.Description;

            # Act
            Remove-Interface -svc $svc -Name $result.Name;

            # Assert
            $entity = Get-Interface -svc $svc -Id $result.Id;
            
            $entity | Should Be $null;
		}

		It "Remove-InterfaceById-ShouldReturnRemovedEntity" -Test {
			# Arrange
			$Name = "{0}-Name-{1}" -f $interfacePrefix,[guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();

			$result = Set-Interface -svc $svc -Name $Name -Description $Description -CreateIfNotExist;

			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Name | Should Be $Name;
			$result.Description | Should Be $Description;

            $entity = Get-Interface -svc $svc -Id $result.Id;

            $entity | Should Not Be $null;
            $entity.Id | Should Be $result.Id;
            $entity.Name | Should Be $result.Name;
            $entity.Description | Should be $entity.Description;

            # Act
            Remove-Interface -svc $svc -Id $result.Id;

            # Assert
            $entity = Get-Interface -svc $svc -Id $result.Id;
            
            $entity | Should Be $null;
		}
	}
}

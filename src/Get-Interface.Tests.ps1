
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Get-Interface" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Set-Interface.ps1"
	. "$here\Get-Interface.ps1"
	. "$here\Remove-Entity.ps1"
	. "$here\Format-ResultAs.ps1"
	
	$svc = Enter-ApcServer;

	Context "Get-Interface" {

        $interfacePrefix = "GetInterface";
	
        AfterAll {
            $interfaces = $svc.Core.Interfaces.AddQueryOption('$filter', "startswith(Name, 'GetInterface')") | Select;
         
            foreach ($interface in $interfaces)
            {
                Remove-Entity -svc $svc -Id $interface.Id -EntitySetName "Interfaces" -Confirm:$false;
            }
        }

		# Context wide constants
		# N/A
	    It "Get-InterfaceWithoutId-ShouldReturnList" -Test {

			# Arrange
			$Name = "{0}-Name-{1}" -f $interfacePrefix,[guid]::NewGuid().ToString();
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

		# Context wide constants
		# N/A
	    It "Get-InterfaceWithId-ShouldReturnEntity" -Test {
			# Arrange
			$Name = "{0}-Name-{1}" -f $interfacePrefix,[guid]::NewGuid().ToString();
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

		# Context wide constants
		# N/A
	    It "Get-InterfaceWithName-ShouldReturnEntity" -Test {
			# Arrange
			$Name = "{0}-Name-{1}" -f $interfacePrefix,[guid]::NewGuid().ToString();
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

		# Context wide constants
		# N/A
	    It "Get-InterfaceWithIdGetProviders-ShouldReturnProviders" -Test {
			# Arrange
			$Name = "{0}-Name-{1}" -f $interfacePrefix,[guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();

			$result = Set-Interface -svc $svc -Name $Name -Description $Description -CreateIfNotExist;

			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Name | Should Be $Name;
			$result.Description | Should Be $Description;

            # Act
            $entity = Get-Interface -svc $svc -Id $result.Id -Providers;

            # Assert
            $true | Should Be $false;
		}

		# Context wide constants
		# N/A
	    It "Get-InterfaceWithIdGetConsumers-ShouldReturnConsumers" -Test {
			# Arrange
			$Name = "{0}-Name-{1}" -f $interfacePrefix,[guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();

			$result = Set-Interface -svc $svc -Name $Name -Description $Description -CreateIfNotExist;

			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Name | Should Be $Name;
			$result.Description | Should Be $Description;

            # Act
            $entity = Get-Interface -svc $svc -Id $result.Id -Consumers;

            # Assert
            $true | Should Be $false;
		}
	}
}
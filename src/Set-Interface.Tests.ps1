
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe -Tags "Set-Interface" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Set-Interface.ps1"
	. "$here\Remove-Entity.ps1"
	. "$here\Format-ResultAs.ps1"
	
	$svc = Enter-ApcServer;

	Context "Set-Interface" {

        $interfacePrefix = "SetInterface";
	
        AfterAll {
            $interfaces = $svc.Core.Interfaces.AddQueryOption('$filter', "startswith(Name, 'SetInterface')") | Select;
         
            foreach ($interface in $interfaces)
            {
                Remove-Entity -svc $svc -Id $interface.Id -EntitySetName "Interfaces" -Confirm:$false;
            }
        }

		# Context wide constants
		# N/A
	    It "Set-InterfaceWithCreateIfNotExist-ShouldReturnNewEntity" -Test {
			# Arrange
			$Name = "{0}-Name-{1}" -f $interfacePrefix,[guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();

			# Act
			$result = Set-Interface -svc $svc -Name $Name -Description $Description -CreateIfNotExist;

			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.Name | Should Be $Name;
			$result.Description | Should Be $Description;
		}
	}
}
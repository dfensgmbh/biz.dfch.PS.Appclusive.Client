#Requires -Modules @{ ModuleName = 'biz.dfch.PS.Pester.Assertions'; ModuleVersion = '1.1.1.20160710' }

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "Unrepresentative, because no entities existing.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe "Get-Node" -Tags "Get-Node" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Get-User.ps1"
	. "$here\Set-Node.ps1"
	. "$here\Get-Job.ps1"
	. "$here\Get-EntityKind.ps1"
	. "$here\Set-Connector.ps1"
	. "$here\Get-Connector.ps1"
	. "$here\Set-Interface.ps1"
	. "$here\Get-Interface.ps1"
	. "$here\Remove-Entity.ps1"
	. "$here\Format-ResultAs.ps1"
	
	Context "Get-Node" {
        BeforeEach {
            $moduleName = 'biz.dfch.PS.Appclusive.Client';
            Remove-Module $moduleName -ErrorAction:SilentlyContinue;
            Import-Module $moduleName;

            $svc = Enter-ApcServer;
        }

		It "Warmup" -Test {
			$true | Should Be $true;
		}

		It "Get-NodeListAvailable-ShouldReturnList" -Test {
			# Arrange
			# N/A
			
			# Act
			$result = Get-Node -svc $svc -ListAvailable;
			if ( $result.Count -eq 0 )
			{
				Stop-Pester
			}

			# Assert
			$result | Should Not Be $null;
			$result -is [Array] | Should Be $true;
			0 -lt $result.Count | Should Be $true;
		}

		It "Get-NodeListAvailableSelectName-ShouldReturnListWithNamesOnly" -Test {
			# Arrange
			# N/A
			
			# Act
			$result = Get-Node -svc $svc -ListAvailable -Select Name;

			# Assert
			$result | Should Not Be $null;
			$result -is [Array] | Should Be $true;
			0 -lt $result.Count | Should Be $true;
			$result[0].Name | Should Not Be $null;
			$result[0].Id | Should Be $null;
		}

		It "Get-Node-ShouldReturnFirstEntity" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$result = Get-Node -svc $svc -First $ShowFirst;

			# Assert
			$result | Should Not Be $null;
			$result -is [biz.dfch.CS.Appclusive.Api.Core.Node] | Should Be $true;
		}
		
		It "Get-Node-ShouldReturnFirstEntityById" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$resultFirst = Get-Node -svc $svc -First $ShowFirst;
			$Id = $resultFirst.Id;
			$result = Get-Node -Id $Id -svc $svc;

			# Assert
			$result | Should Not Be $null;
			$result | Should Be $resultFirst;
			$result -is [biz.dfch.CS.Appclusive.Api.Core.Node] | Should Be $true;
		}
		
		It "Get-Node-ShouldReturnThreeEntities" -Test {
			# Arrange
			$ShowFirst = 3;
			
			# Act
			$result = Get-Node -svc $svc -First $ShowFirst;

			# Assert
			$result | Should Not Be $null;
			$ShowFirst -eq $result.Count | Should Be $true;
			$result[0] -is [biz.dfch.CS.Appclusive.Api.Core.Node] | Should Be $true;
		}

		It "Get-NodeThatDoesNotExist-ShouldReturnNull" -Test {
			# Arrange
			$NodeName = 'Node-that-does-not-exist';
			
			# Act
			$result = Get-Node -svc $svc -Name $NodeName;

			# Assert
			$result | Should Be $null;
		}
		
		It "Get-NodeThatDoesNotExist-ShouldReturnDefaultValue" -Test {
			# Arrange
			$NodeName = 'Node-that-does-not-exist';
			$DefaultValue = 'MyDefaultValue';
			
			# Act
			$result = Get-Node -svc $svc -Name $NodeName -DefaultValue $DefaultValue;

			# Assert
			$result | Should Be $DefaultValue;
		}
		
		It "Get-Node-ShouldReturnXML" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$result = Get-Node -svc $svc -First $ShowFirst -As xml;

			# Assert
			$result | Should Not Be $null;
			$result.Substring(0,5) | Should Be '<?xml';
		}
		
		It "Get-Node-ShouldReturnJSON" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$result = Get-Node -svc $svc -First $ShowFirst -As json;

			# Assert
			$result | Should Not Be $null;
			$result.Substring(0, 1) | Should Be '{';
			$result.Substring($result.Length -1, 1) | Should Be '}';
		}
		
		It "Get-Node-WithInvalidId-ShouldReturnException" -Test {
			# Act
			try 
			{
				$result = Get-Node -Id 'myNode';
				'throw exception' | Should Be $true;
			} 
			catch
			{
				# Assert
			   	$result | Should Be $null;
			}
		}
		
		It "Get-NodeByCreatedByThatDoesNotExist-ShouldThrowContractException" -Test {
			# Arrange
			$User = 'User-that-does-not-exist';
			
			# Act / Assert
			{ $result = Get-Node -svc $svc -CreatedBy $User; } | Should ThrowErrorId "Contract";

			# Assert
			# N/A
		}
		
		It "Get-NodeByCreatedBy-ShouldReturnListWithEntities" -Test {
			# Arrange
			$User = 'SYSTEM';
			
			# Act
			$result = Get-Node -svc $svc -CreatedBy $User;

			# Assert
		   	$result | Should Not Be $null;
			0 -lt $result.Count | Should Be $true;
		}
		
		It "Get-NodeByModifiedBy-ShouldReturnListWithEntities" -Test {
			# Arrange
			$User = 'SYSTEM';
			
			# Act
			$result = Get-Node -svc $svc -ModifiedBy $User;

			# Assert
		   	$result | Should Not Be $null;
			0 -lt $result.Count | Should Be $true;
		}
		
		
		It "Get-NodeExpandJob-ShouldReturnJob" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$resultFirst = Get-Node -svc $svc -First $ShowFirst;
			$result = Get-Node -svc $svc -Id $resultFirst.Id -ExpandJob;

			# Assert
		   	$result | Should Not Be $null;
		   	$result.GetType().Name | Should Be 'Job';
		}
	}

    $entityPrefix = "GetNodeConnector";
    $entitySetName = "Nodes";
    $usedEntitySets = @("Connectors", "Interfaces", "Nodes", "EntityKinds");
    $REQUIRE = 2L;
    $PROVIDE = 1L;
	
    Context "Get-Node-Connector" {
	
        BeforeEach {
            $moduleName = 'biz.dfch.PS.Appclusive.Client';
            Remove-Module $moduleName -ErrorAction:SilentlyContinue;
            Import-Module $moduleName;

            $svc = Enter-ApcServer;
        }

        AfterEach {
            $moduleName = 'biz.dfch.PS.Appclusive.Client';
            Remove-Module $moduleName -ErrorAction:SilentlyContinue;
            Import-Module $moduleName;

            $svc = Enter-ApcServer;
            $entityFilter = "startswith(Name, '{0}')" -f $entityPrefix;

            foreach ($entitySet in $usedEntitySets)
            {
                $entities = $svc.Core.$entitySet.AddQueryOption('$filter', $entityFilter) | Select;
         
                foreach ($entity in $entities)
                {
                    Remove-Entity -svc $svc -Id $entity.Id -EntitySetName $entitySet -Confirm:$false;
                }
            }
        }
        
        function CreateInterface()
        {
            $Name = "{0}-Name-{1}" -f $entityPrefix,[guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();

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
        
        function CreateNode([long]$entityKindId)
        {
            $Name = "{0}-Name-{1}" -f $entityPrefix,[guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
            
            $node = Set-Node -Name $Name `
                                -Description $Description `
                                -EntityKindId $entityKindId `
                                -CreateIfNotExist `
                                -svc $svc;
            
            return $node;
        }

        It "Get-NodeProvideInterfaceId-ShouldReturnList" -Test {        
            # Arrange
            $interface = CreateInterface | Select;
            $interfaceB = CreateInterface | Select;
            $entityKind = CreateEntityKind | Select;
            $entityKindB = CreateEntityKind | Select;

            CreateConnector $interface.Id $entityKind.Id $PROVIDE;
            CreateConnector $interface.Id $entityKindB.Id $PROVIDE;

            CreateNode $entityKind.Id;
            CreateNode $entityKind.Id;
            CreateNode $entityKindB.Id;

			# Act
            $list = Get-Node -svc $svc -ProvideInterface $interface.Id;

			# Assert
            $list | Should Not Be $null;
            $list.Count | Should Be 3;
            
            $list[0] | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.Node]
        }

        It "Get-NodeRequireInterfaceId-ShouldReturnList" -test {
            # Arrange
            $interface = CreateInterface | Select;
            $interfaceB = CreateInterface | Select;
            $entityKind = CreateEntityKind | Select;
            $entityKindB = CreateEntityKind | Select;

			CreateConnector $interface.Id 29 $PROVIDE;
			CreateConnector $interfaceB.Id 29 $PROVIDE;
			
            CreateConnector $interface.Id $entityKind.Id $PROVIDE;
            CreateConnector $interface.Id $entityKind.Id $REQUIRE;		
            CreateConnector $interfaceB.Id $entityKind.Id $REQUIRE;		
            CreateConnector $interface.Id $entityKindB.Id $PROVIDE;
            
            CreateNode $entityKind.Id;
            CreateNode $entityKind.Id;
            CreateNode $entityKindB.Id;

			# Act
            $list = Get-Node -svc $svc -RequireInterface $interfaceB.Id;

			# Assert
            $list | Should Not Be $null;
            $list.Count | Should Be 2;
            
            $list[0] | Should BeOfType [biz.dfch.CS.Appclusive.Api.Core.Node];
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

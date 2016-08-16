
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "Unrepresentative, because no entities existing.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe "Test-Connect" -Tags "Test-Connect" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Get-User.ps1"
	. "$here\Set-Node.ps1"
	. "$here\Get-Node.ps1"
	. "$here\Get-Job.ps1"
	. "$here\Get-EntityKind.ps1"
	. "$here\Set-Connector.ps1"
	. "$here\Get-Connector.ps1"
	. "$here\Set-Interface.ps1"
	. "$here\Get-Interface.ps1"
	. "$here\Test-Connect.ps1"
	. "$here\Remove-Entity.ps1"
	. "$here\Format-ResultAs.ps1"
	
    $entityPrefix = "TestConnect";
    $entitySetName = "Nodes";
    $usedEntitySets = @("Connectors", "Interfaces", "Nodes", "EntityKinds");
    $REQUIRE = [biz.dfch.CS.Appclusive.Public.OdataServices.Core.ConnectorType]::Require.value__;
    $PROVIDE = [biz.dfch.CS.Appclusive.Public.OdataServices.Core.ConnectorType]::Provide.value__;
    
	Context "Test-Connect" {
    	
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

        BeforeEach {
            $moduleName = 'biz.dfch.PS.Appclusive.Client';
            Remove-Module $moduleName -ErrorAction:SilentlyContinue;
            Import-Module $moduleName;

            $svc = Enter-ApcServer;
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

        It "Test-Connect-ReturnsTrueForConnectableEntityKind" -Test {        
            # Arrange
            $entityKind = CreateEntityKind | Select;
            $entityKindB = CreateEntityKind | Select;

            $interface = CreateInterface | Select;
            $interfaceB = CreateInterface | Select;

            CreateConnector $interface.Id $entityKind.Id $PROVIDE;
            CreateConnector $interface.Id $entityKindB.Id $REQUIRE;
            			
            CreateConnector $interfaceB.Id $entityKind.Id $PROVIDE;
            CreateConnector $interfaceB.Id $entityKindB.Id $REQUIRE;	
            
			# Act
            $canConnect = Test-Connect -svc $svc -EntityKindId $entityKindB.Id -ParentEntityKindId $entityKind.Id;

			# Assert
            $canConnect | Should Be $true;
        }
        
        It "Test-Connect-ReturnsFalseForNotConnectableEntityKind" -Test {        
            # Arrange
            $entityKind = CreateEntityKind | Select;
            $entityKindB = CreateEntityKind | Select;

            $interface = CreateInterface | Select;
            $interfaceB = CreateInterface | Select;

            CreateConnector $interface.Id $entityKind.Id $PROVIDE;
            CreateConnector $interface.Id $entityKindB.Id $REQUIRE;
            			
            CreateConnector $interfaceB.Id $entityKindB.Id $REQUIRE;	
            
			# Act
            $canConnect = Test-Connect -svc $svc -EntityKindId $entityKindB.Id -ParentEntityKindId $entityKind.Id;

			# Assert
            $canConnect | Should Be $false;
        }
        
        It "Test-Connect-ReturnsTrueForConnectableNode" -Test {        
            # Arrange
            $entityKind = CreateEntityKind | Select;
            $entityKindB = CreateEntityKind | Select;

            $interface = CreateInterface | Select;
            $interfaceB = CreateInterface | Select;

            CreateConnector $interface.Id $entityKind.Id $PROVIDE;
            CreateConnector $interface.Id $entityKindB.Id $REQUIRE;
            			
            CreateConnector $interfaceB.Id $entityKind.Id $PROVIDE;
            CreateConnector $interfaceB.Id $entityKindB.Id $REQUIRE;	
            
            $node = CreateNode $entityKind.Id | Select;

			# Act
            $canConnect = Test-Connect -svc $svc -EntityKindId $entityKindB.Id -ParentNodeId $node.Id;

			# Assert
            $canConnect | Should Be $true;
        }
        
        It "Test-Connect-ReturnsFalseForNotConnectableNode" -Test {        
            # Arrange
            $entityKind = CreateEntityKind | Select;
            $entityKindB = CreateEntityKind | Select;

            $interface = CreateInterface | Select;
            $interfaceB = CreateInterface | Select;

            CreateConnector $interface.Id $entityKind.Id $PROVIDE;
            CreateConnector $interface.Id $entityKindB.Id $REQUIRE;
            			
            CreateConnector $interfaceB.Id $entityKindB.Id $REQUIRE;	
            
            $node = CreateNode $entityKind.Id;

			# Act
            $canConnect = Test-Connect -svc $svc -EntityKindId $entityKindB.Id -ParentNodeId $node.Id;

			# Assert
            $canConnect | Should Be $false;
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

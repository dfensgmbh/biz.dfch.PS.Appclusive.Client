$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe "Set-Folder" -Tags "Set-Folder" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Format-ResultAs.ps1"
	. "$here\Get-User.ps1"
	. "$here\Get-Folder.ps1"
	
	$entityPrefix = "TestItem-";
	$usedEntitySets = @("Folders");
	
		Context "Set-Folder" {
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
	
		# Context wide constants
		# N/A
		
		It "Warmup" -Test {
			$true | Should Be $true;
		}
		
		It "Set-Folder-ShouldReturnNewEntity" -Test {
			# Arrange
			$name = $entityPrefix + "Name-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			$result = Set-Folder -svc $svc -Name $name;
			
			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be $name;
			$result.Id | Should Not Be 0;
		}
		
		It "Set-Folder-CreateWithNullName-ShouldFail" -Test {
			# Arrange
			
			# Act
			{ $result = Set-Folder -svc $svc -Name $name; } | Should ThrowException ParameterBindingValidationException;
			
			# Assert
			$result | Should Be $null;
		}
		
		It "Set-Folder-CreateWithId-ShouldFail" -Test {
			# Arrange
			$id = 100000000;
			
			# Act
			$result = Set-Folder -svc $svc -Id $id;
			
			$query = "Id eq {0}" -f $id;
			$folder = $svc.Core.Folders.AddQueryOption('$filter', $query) | Select;
			
			# Assert
			$result | Should Be $null;
			$folder | Should Be $null;
		}
		
		It "Set-Folder-ShouldReturnXML" -Test {
			# Arrange
			$name = $entityPrefix + "Name-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			$result = Set-Folder -svc $svc -Name $name -As xml;
			
			# Assert
			$result | Should Not Be $null;
			$result.Substring(0,5) | Should Be '<?xml';
		}
		
		It "Set-Folder-UsingIdShouldUpdateFolder" -Test {
			# Arrange
			$name = $entityPrefix + "Name-{0}" -f [guid]::NewGuid().ToString();
			$description = "Description";
			$newName = $entityPrefix + "NameUpdate-{0}" -f [guid]::NewGuid().ToString();
			$newDescription = "Description Updated";
			
			# Act - create a folder
			Push-ApcChangeTracker -svc $svc;
			$result1 = Set-Folder -svc $svc -Name $name -Description $description;
			Pop-ApcChangeTracker -svc $svc;
			
			#get the id of the folder
			$folderId = $result1.Id;
			
			#Act - update the folder
			Push-ApcChangeTracker -svc $svc;
			$result2 = Set-Folder -svc $svc -Id $folderId -NewName $newName -NewDescription $newDescription;
			Pop-ApcChangeTracker -svc $svc;
			
			# Assert
			$result1 | Should Not Be $null;
			$result1.Name | Should Be $name;
			$result1.Description | Should Be $description;
			$result1.Id | Should Not Be 0;
			$result2 | Should Not Be $null;
			$result2.Name | Should Be $newName;
			$result2.Description | Should Be $newDescription;
			$result2.Id | Should Be $result1.Id;
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


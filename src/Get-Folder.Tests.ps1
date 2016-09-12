$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "Unrepresentative, because no entities existing.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe "Get-Folder" -Tags "Get-Folder" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Format-ResultAs.ps1"
	. "$here\Get-User.ps1"
	. "$here\New-Folder.ps1"
	. "$here\Set-Folder.ps1"
	
	$entityPrefix = "TestItem-";
	$usedEntitySets = @("Folders");
	
	Context "Get-Folder" {
        BeforeEach {
            $moduleName = 'biz.dfch.PS.Appclusive.Client';
            Remove-Module $moduleName -ErrorAction:SilentlyContinue;
            Import-Module $moduleName;
            $svc = Enter-Appclusive;
        }
		AfterAll {
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
		#create three folders so there is at least three in the list
		$name1 = $entityPrefix + "Name1-{0}" -f [guid]::NewGuid().ToString();
		$name2 = $entityPrefix + "Name2-{0}" -f [guid]::NewGuid().ToString();
		$name3 = $entityPrefix + "Name3-{0}" -f [guid]::NewGuid().ToString();
		$folder1 = New-Folder -svc $svc -Name $name1;
		$folder2 = New-Folder -svc $svc -Name $name2;
		$folder3 = New-Folder -svc $svc -Name $name3;
		
		It "Warmup" -Test {
			$true | Should Be $true;
		}
		
		It "Get-FolderListAvailable-ShouldReturnList" -Test {
			# Arrange
			# N/A
			
			# Act
			$result = Get-Folder -svc $svc -ListAvailable;
			
			# Assert
			$result | Should Not Be $null;
			$result -is [Array] | Should Be $true;
			0 -lt $result.Count | Should Be $true;
		}
		
		It "Get-FolderListAvailableSelectName-ShouldReturnListWithNamesOnly" -Test {
			# Arrange
			# N/A
			
			# Act
			$result = Get-Folder -svc $svc -ListAvailable -Select Name;
			
			# Assert
			$result | Should Not Be $null;
			$result -is [Array] | Should Be $true;
			0 -lt $result.Count | Should Be $true;
			$result[0].Name | Should Not Be $null;
			$result[0].Id | Should Be $null;
		}
		
		It "Get-Folder-ShouldReturnFirstEntity" -Test {
			# Arrange
			$showFirst = 1;
			
			# Act
			$result = Get-Folder -svc $svc -First $showFirst;
			
			# Assert
			$result | Should Not Be $null;
			$result -is [biz.dfch.CS.Appclusive.Api.Core.Folder] | Should Be $true;
		}
		
		It "Get-Folder-ShouldReturnById" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$resultFirst = Get-Folder -svc $svc -First $ShowFirst;
			
			$id = $resultFirst.Id;
			$result = Get-Folder -Id $id -svc $svc;
			
			# Assert
			$result | Should Not Be $null;
			$result | Should Be $resultFirst;
			$result.Id | Should Be $resultFirst.Id;
			$result -is [biz.dfch.CS.Appclusive.Api.Core.Folder] | Should Be $true;
		}
		
		It "Get-Folder-ShouldReturnByName" -Test {
			# Arrange
			$showFirst = 1;
			
			# Act
			$resultFirst = Get-Folder -svc $svc -First $showFirst;
			
			$name = $resultFirst.Name;
			$result = Get-Folder -svc $svc -Name $Name -First $ShowFirst ;
			
			# Assert
			$result | Should Not Be $null;
			$result | Should Be $resultFirst;
			$result.Name | Should Be $resultFirst.Name;
			$result -is [biz.dfch.CS.Appclusive.Api.Core.Folder] | Should Be $true;
		}
		
		It "Get-Folder-ShouldReturnByParentId" -Test {
			# Arrange
			$showFirst = 1;
			
			# Act
			$resultFirst = Get-Folder -svc $svc -First $showFirst;
			
			$parentId = $resultFirst.parentId;
			$result = Get-Folder -svc $svc -ParentId $parentId -First $ShowFirst;
			
			# Assert
			$result | Should Not Be $null;
			$result | Should Be $resultFirst;
			$result.parentId | Should Be $resultFirst.parentId;
			$result -is [biz.dfch.CS.Appclusive.Api.Core.Folder] | Should Be $true;
		}
		
		It "Get-Folder-ReturnByParentId-GetFirst" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$resultFirst = Get-Folder -svc $svc -First $ShowFirst;
			
			$parentId = $resultFirst.parentId;
			$result = Get-Folder -ParentId $parentId -svc $svc;
			
			$result1 = Get-Folder -svc $svc -ParentId $parentId -First $ShowFirst;
			
			# Assert
			$result | Should Not Be $null;
			$result.Count -gt 1 | Should  Be $true;
			$result1.Count -eq 1 | Should Be $true;
		}
		
		It "Get-Folder-SelectTwoPropertiesAndValueOnly-ShouldThrow" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$resultFirst = Get-Folder -svc $svc -First $ShowFirst;
			
			$parentId = $resultFirst.parentId;
			{ $result = Get-Folder -ParentId $parentId -svc $svc -Select Name, Id -ValueOnly;} | Should Throw;
			
			# Assert
			$result | Should Be $null;
			$error[0].Exception.ToString().contains("You must specify exactly one 'Select' property when using 'ValueOnly'.") | Should Be $true;
		}
		
		It "Get-Folder-ShouldReturnThreeEntities" -Test {
			# Arrange
			$showFirst = 3;
			
			# Act
			$result = Get-Folder -svc $svc -First $showFirst;
			
			# Assert
			$result | Should Not Be $null;
			$ShowFirst -eq $result.Count | Should Be $true;
			$result[0] -is [biz.dfch.CS.Appclusive.Api.Core.Folder] | Should Be $true;
		}
		
		It "Get-FolderThatDoesNotExist-ShouldReturnNull" -Test {
			# Arrange
			$name = 'Folder-that-does-not-exist';
			
			# Act
			$result = Get-Folder -svc $svc -Name $name;
			
			# Assert
			$result | Should Be $null;
		}
		
		It "Get-Folder-ShouldReturnXML" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$result = Get-Folder -svc $svc -First $ShowFirst -As xml;
			
			# Assert
			$result | Should Not Be $null;
			$result.Substring(0,5) | Should Be '<?xml';
		}
		
		It "Get-Folder-ShouldReturnJSON" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$result = Get-Folder -svc $svc -First $ShowFirst -As json;
			
			# Assert
			$result | Should Not Be $null;
			$result.Substring(0, 1) | Should Be '{';
			$result.Substring($result.Length -1, 1) | Should Be '}';
		}
		
		It "Get-Folder-WithInvalidId-ShouldReturnException" -Test {
			# Act
			try 
			{
				$result = Get-Folder -Id 'myFolder';
				'throw exception' | Should Be $true;
			} 
			catch
			{
				# Assert
			   	$result | Should Be $null;
			}
		}
		
		It "Get-FolderByCreatedByThatDoesNotExist-ShouldThrowContractException" -Test {
			# Arrange
			$User = 'User-that-does-not-exist';
			
			# Act
			{ Get-Folder -svc $svc -CreatedBy $User; } | Should ThrowErrorId "Contract";

			# Assert
		   	# N/A
		}
		
		It "Get-FolderByCreatedBy-ShouldReturnListWithEntities" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$result = Get-Folder -svc $svc -First $ShowFirst;
			
			$UserId = $result.CreatedById;
			$User = Get-User -svc $svc -Id $UserId -Select Name -ValueOnly;
			
			# Act
			$result1 = Get-Folder -svc $svc -CreatedBy $User;
			
			# Assert
		   	$result1 | Should Not Be $null;
			0 -lt $result1.Count | Should Be $true;
		}
		
		It "Get-FolderByModifiedBy-ShouldReturnListWithEntities" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$result = Get-Folder -svc $svc -First $ShowFirst;
			
			$UserId = $result.ModifiedById;
			$User = Get-User -svc $svc -Id $UserId -Select Name -ValueOnly;
			
			# Act
			$result1 = Get-Folder -svc $svc -ModifiedBy $User;
			
			# Assert
		   	$result1 | Should Not Be $null;
			0 -lt $result1.Count | Should Be $true;
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


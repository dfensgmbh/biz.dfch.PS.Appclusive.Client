$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester()
{
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
	PARAM
	(
		$message = "EMERGENCY: Script cannot continue."
	)
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe "New-Folder" -Tags "New-Folder" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Format-ResultAs.ps1"
	. "$here\Get-User.ps1"
	. "$here\Set-Folder.ps1"
	. "$here\Get-Folder.ps1"
	
	$entityPrefix = "TestItem-";
	$usedEntitySets = @("Folders");
	
		Context "New-Folder" {
        BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;
			$svc = Enter-ApcServer;
        }
		
		AfterEach {
            $svc = Enter-ApcServer;
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
		
		It "Warmup" -Test {
			$true | Should Be $true;
		}
		
		It "New-Folder-ShouldReturnNewEntity" -Test {
			# Arrange
			$name = $entityPrefix + "Name-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			$result = New-Folder -svc $svc -Name $name;
			
			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be $name;
			$result.Id | Should Not Be 0;
		}
		
		It "New-Folder-CreateInSelectedFolder" -Test {
			# Arrange
			$name1 = $entityPrefix + "Name1-{0}" -f [guid]::NewGuid().ToString();
			$name2 = $entityPrefix + "Name2-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			$folder1 = New-Folder -svc $svc -Name $name1;
			$folder2 = New-Folder -svc $svc -Name $name2 -ParentId $folder1.Id;

			# Assert
			$folder1 | Should Not Be $null;
			$folder1.Name | Should Be $name1;
			$folder1.Id | Should Not Be 0;
			$folder2 | Should Not Be $null;
			$folder2.Name | Should Be $name2;
			$folder2.Id | Should Not Be 0;
			$folder2.ParentId | Should Be $folder1.Id;
			
			#remove child folder otherwise cleanup won't work
			Remove-ApcEntity -svc $svc -Id $folder2.Id -EntitySetName "folders" -Confirm:$false;
		}
		
		It "New-Folder-CreateWithNonexistingParentId-ShouldNotCreateAndReturnNull" -Test {
			# Arrange
			$name = $entityPrefix + "Name-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			$result = New-Folder -svc $svc -Name $name -ParentId 9999999;
			
			# Assert
			$result | Should  Be $null;
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


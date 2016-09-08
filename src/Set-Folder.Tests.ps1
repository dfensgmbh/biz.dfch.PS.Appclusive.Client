$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "Unrepresentative, because no entities existing.")
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
			$Name = $entityPrefix + "Name-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			$result = Set-Folder -svc $svc -Name $Name -CreateIfNotExist;
			Write-Host ($result | out-string);
			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be $Name;
			$result.Id | Should Not Be 0;
		}
		
		It "Set-Folder-ShouldReturnNewEntity" -Test {
			# Arrange
			$Name = $entityPrefix + "Name-{0}" -f [guid]::NewGuid().ToString();
			
			# Act
			$result = Set-Folder -svc $svc -Name $Name -CreateIfNotExist;
			Write-Host ($result | out-string);
			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be $Name;
			$result.Id | Should Not Be 0;
		}
		
		
		It "Set-NodeWithNewDescription-ShouldReturnUpdatedEntity" -Test {
			
			# Arrange
			$Name = "Name-{0}" -f [guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
			$NewDescription = "NewDescription-{0}" -f [guid]::NewGuid().ToString();
			$node = Set-Node -svc $svc -Name $Name -Description $Description -EntityKindId 1 -CreateIfNotExist;
			$node | Should Not Be $null;
			
			$svc = Enter-Apc;
			
			# Act
			$result = Set-Node -svc $svc -Name $Name -Description $NewDescription -EntityKindId 1;

			# Assert
			$result | Should Not Be $null;
			$result.Description | Should Be $NewDescription;
			
			# Cleanup
			$query = "RefId eq '{0}' and EntityKindId eq 1" -f $result.Id;
			$nodeJob = $svc.Core.Jobs.AddQueryOption('$filter', $query) | Select;
			Remove-ApcEntity -svc $svc -Id $nodeJob.Id -EntitySetName 'Jobs' -Force -Confirm:$false;
			Remove-ApcEntity -svc $svc -Id $result.Id -EntitySetName 'Nodes' -Force -Confirm:$false;
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


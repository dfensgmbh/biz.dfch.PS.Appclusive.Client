
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Set-User" -Tags "Set-User" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Format-ResultAs.ps1"
	
	$entityPrefix = "Set-User-";
	$usedEntitySets = @("Users");
	
    BeforeEach {
        $moduleName = 'biz.dfch.PS.Appclusive.Client';
        Remove-Module $moduleName -ErrorAction:SilentlyContinue;
        Import-Module $moduleName;

        $svc = Enter-ApcServer;
    }
	
	AfterAll {
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

	Context "Set-User" {
	
		# Context wide constants
		# N/A

		It "Set-User-ShouldReturnNewEntity" -Test {
			# Arrange
			$Name = "{0}Name-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			$Mail = "Mail-{0}@appclusive.net" -f [guid]::NewGuid().ToString();
			$ExternalId = "{0}" -f [guid]::NewGuid();
			
			# Act
			$result = Set-User -svc $svc -Name $Name -Mail $Mail -ExternalId $ExternalId -CreateIfNotExist;

			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Not Be 0;
			$result.CreatedById | Should Not Be 0;
			$result.ModifiedById | Should Not Be 0;
			$result.Name | Should Be $Name;
			$result.Mail | Should Be $Mail;
			$result.ExternalId | Should Be $ExternalId;
		}

		It "Set-UserWithNewMailAndDescription-ShouldReturnUpdatedEntity" -Test {
			# Arrange
			$Name = "{0}Name-{1}" -f $entityPrefix, [guid]::NewGuid().ToString();
			$Description = "Description-{0}" -f [guid]::NewGuid().ToString();
			$NewDescription = "NewDescription-{0}" -f [guid]::NewGuid().ToString();
			$Mail = "Mail-{0}@appclusive.net" -f [guid]::NewGuid().ToString();
			$NewMail = "NewMail-{0}@appclusive.net" -f [guid]::NewGuid().ToString();
			$ExternalId = "{0}" -f [guid]::NewGuid();
			$result1 = Set-User -svc $svc -Name $Name -Description $Description -Mail $Mail -ExternalId $ExternalId -CreateIfNotExist;
			$result1 | Should Not Be $null;
			
			# Act
			$result = Set-User -svc $svc -Name $Name -Description $NewDescription -Mail $NewMail;

			# Assert
			$result | Should Not Be $null;
			$result.Description | Should Be $NewDescription;
			$result.Mail | Should Be $NewMail;
			$result.ExternalId | Should Be $result1.ExternalId;
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

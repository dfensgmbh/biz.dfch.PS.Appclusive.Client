
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "New-User" -Tags "New-User" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Set-User.ps1"
	. "$here\Get-Tenant.ps1"
	. "$here\Format-ResultAs.ps1"
	
	$entityNamePrefix = "New-User-";
	$usedEntitySets = @("Users");

	BeforeEach {
        $moduleName = 'biz.dfch.PS.Appclusive.Client';
        Remove-Module $moduleName -ErrorAction:SilentlyContinue;
        Import-Module $moduleName;

        $svc = Enter-ApcServer;
    }
	
	Context "New-User" {
	
		AfterAll {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;
			
			$svc = Enter-ApcServer;
			$entityFilter = "startswith(Name, '{0}')" -f $entityNamePrefix;

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

		It "New-UserDuplicate-ShouldReturnNull" -Test {
			# Arrange
			$name = "{0}Name-{1}" -f $entityNamePrefix, [guid]::NewGuid().ToString();
			$mail = "Mail-{0}@appclsusive.net" -f [guid]::NewGuid().ToString();
			$externalId = "{0}" -f [guid]::NewGuid();
			$result1 = New-User -svc $svc -Name $name -Mail $mail -ExternalId $externalId -ExternalType Internal;
			$result1 | Should Not Be $null;
			
			# Act
			{ $result = New-User -svc $svc -Name $name -Mail $mail -ExternalId $externalId; } | Should Throw 'Precondition failed'
			{ $result = New-User -svc $svc -Name $name -Mail $mail -ExternalId $externalId; } | Should Throw 'Entity does already exist'

			# Assert
			$result | Should Be $null;
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


function CreateEntityKind([string] $name, [string] $version) 
{
    $ek = $svc.Core.EntityKinds.AddQueryOption('$filter', ("Version eq '{0}'" -f $version)).AddQueryOption('$top', 1) | Select;

    if ($ek)
    {
        return $ek;
    }
    
    $entityKind = New-Object biz.dfch.CS.Appclusive.Api.Core.EntityKind;
    $entityKind.Name = $name;
    $entityKind.Version = $version;
            
    $svc.Core.AddToEntityKinds($entityKind);
    $svc.Core.SaveChanges();

    return $entityKind;
}

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Import-Product" -Tags "Import-Product" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Remove-Entity.ps1"
	. "$here\Set-KeyNameValue.ps1"
	. "$here\Get-EntityKind.ps1"
	. "$here\Import-DataType.ps1"
	. "$here\Format-ResultAs.ps1"

    BeforeAll
    {
        $moduleName = 'biz.dfch.PS.Appclusive.Client';
        Remove-Module $moduleName -ErrorAction:SilentlyContinue;
        Import-Module $moduleName;
        
        $svc = Enter-ApcServer;
        Add-Type -Path C:\GitRepos\biz.dfch.CS.Appclusive\src\biz.dfch.Appclusive.Products\bin\Debug\biz.dfch.Appclusive.Products.dll
    }

    BeforeEach {
        $moduleName = 'biz.dfch.PS.Appclusive.Client';
        Remove-Module $moduleName -ErrorAction:SilentlyContinue;
        Import-Module $moduleName;

        $svc = Enter-ApcServer;
    }
    
    $entityPrefix = "biz.dfch.Appclusive.Products.Infrastructure";
    $entitySetName = "DataTypes";
    $usedEntitySets = @("EntityKinds"); 
	Context "Import-Products" {

        AfterAll {
            $moduleName = 'biz.dfch.PS.Appclusive.Client';
            Remove-Module $moduleName -ErrorAction:SilentlyContinue;
            Import-Module $moduleName;

            $svc = Enter-ApcServer;
            $entityFilter = "startswith(Name, '{0}')" -f $entityPrefix;

            <#
            $entities = $svc.Core.EntityKinds.AddQueryOption('$filter', $entityFilter) | Select;
         
            foreach ($entity in $entities)
            {
                Remove-Entity -svc $svc -Id $entity.Id -EntitySetName "EntityKinds" -Confirm:$false;
            }

            $entities = $svc.Diagnostics.DataTypes.AddQueryOption('$filter', $entityFilter) | Select;
         
            foreach ($entity in $entities)
            {
                $svc.Diagnostics.DeleteObject($entity);
                $svc.Diagnostics.SaveChanges();
            }
            #>
        }
        
		It "Warmup" -Test {
			$true | Should Be $true;
		}

	    It "ImportDataTypes-ShouldImportSimpleProductOne" -Test {
            Add-Type -Path C:\GitRepos\biz.dfch.CS.Appclusive\src\biz.dfch.Appclusive.Products\bin\Debug\biz.dfch.Appclusive.Products.dll

            $t = Import-Product -FQCN "biz.dfch.Appclusive.Products.Infrastructure.V001.VirtualMachine" -svc $svc -force;

            write-Host ($t | out-string);
		}
	}
}
 
#
# Copyright 2015-2016 d-fens GmbH
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

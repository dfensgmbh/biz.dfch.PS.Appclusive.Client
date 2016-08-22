
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

Describe "Import-DataType" -Tags "Import-DataType" {

	Mock Export-ModuleMember { return $null; }
	
    Add-Type -Path "C:\GitRepos\biz.dfch.CS.Appclusive\src\biz.dfch.CS.Appclusive.Public\bin\Debug\biz.dfch.CS.Appclusive.Public.dll";
    Add-Type -Path "C:\GitRepos\biz.dfch.CS.Appclusive.Api\src\biz.dfch.CS.Appclusive.Api\bin\Debug\biz.dfch.CS.Appclusive.Api.dll";

	. "$here\$sut"
	. "$here\Remove-Entity.ps1"
	. "$here\Format-ResultAs.ps1"

    
    BeforeAll {
        $moduleName = 'biz.dfch.PS.Appclusive.Client';
        Remove-Module $moduleName -ErrorAction:SilentlyContinue;
        Import-Module $moduleName;
        
        $svc = Enter-ApcServer;

        $ek = CreateEntityKind "biz.dfch.Appclusive.Products.Tests.Mock.SimpleProductOne" "biz.dfch.Appclusive.Products.Tests.Mock.SimpleProductOne";

        $source = Get-Content -Raw C:\GitRepos\biz.dfch.PS.Appclusive.Client\src\lib\biz.dfch.Appclusive.Products.Tests.Mock.SimpleProductOne.cs -Encoding Default

        Add-Type -AssemblyName ('System.ComponentModel.DataAnnotations, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35');
        $assemblies = New-Object System.Collections.ArrayList
        $assemblies.Add([System.ComponentModel.DataAnnotations.RequiredAttribute].Assembly.Location)
        $assemblies.Add([biz.dfch.CS.Appclusive.Public.Converters.EntityBagAttribute].Assembly.Location)

        Add-Type -TypeDefinition $source -ReferencedAssemblies $assemblies
    }

    BeforeEach {
        $moduleName = 'biz.dfch.PS.Appclusive.Client';
        Remove-Module $moduleName -ErrorAction:SilentlyContinue;
        Import-Module $moduleName;

        $svc = Enter-ApcServer;
    }
    
    $entityPrefix = "biz.dfch.Appclusive.Products.Tests.Mock";
    $entitySetName = "DataTypes";
    $usedEntitySets = @("EntityKinds"); 
	Context "Import-DataType" {

        AfterAll {
            $moduleName = 'biz.dfch.PS.Appclusive.Client';
            Remove-Module $moduleName -ErrorAction:SilentlyContinue;
            Import-Module $moduleName;

            $svc = Enter-ApcServer;
            $entityFilter = "startswith(Name, '{0}')" -f $entityPrefix;

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
        }
        
	    It "ImportDataTypes-ShouldImportSimpleProductOne" -Test {
            Import-DataType -FQCN "biz.dfch.Appclusive.Products.Tests.Mock.SimpleProductOne" -svc $svc -RecreateIfExist;
            
            $dataTypes = $svc.Diagnostics.DataTypes.AddQueryOption('$filter', "startswith(Name, 'biz.dfch.Appclusive.Products.Tests.Mock.SimpleProductOne')") | Select;

            $dataTypes.Count | Should Be 3;

            $nameValidation = $dataTypes | where { $_.Name -eq "biz.dfch.Appclusive.Products.Tests.Mock.SimpleProductOne.Name" };
            $nameValidation | Should Not Be $null;
            $nameValidation.Default | Should Be "SimpleProductOne";
            $nameValidation.IsRequired | Should Be $true;
            $nameValidation.Minimum | Should Be $null;
            $nameValidation.Maximum | Should Be $null;
            $nameValidation.ValidatePattern | Should Be $null;

            $cpuSpeedValidation = $dataTypes | where { $_.Name -eq "biz.dfch.Appclusive.Products.Tests.Mock.SimpleProductOne.CpuSpeed" };
            $cpuSpeedValidation | Should Not Be $null;
            $cpuSpeedValidation.Default | Should Be "0.5";
            $cpuSpeedValidation.IsRequired | Should Be $true;
            $cpuSpeedValidation.Minimum | Should Be 0.25;
            $cpuSpeedValidation.Maximum | Should Be 2.50;
            $cpuSpeedValidation.ValidatePattern | Should Be $null;
            $cpuSpeedValidation.Unit | Should Be "GHz";

            $memoryReservationPercentValidation = $dataTypes | where { $_.Name -eq "biz.dfch.Appclusive.Products.Tests.Mock.SimpleProductOne.MemoryReserverationPercent" };
            $memoryReservationPercentValidation | Should Not Be $null;
            $memoryReservationPercentValidation.Default | Should Be "1";
            $memoryReservationPercentValidation.IsRequired | Should Be $true;
            $memoryReservationPercentValidation.Minimum | Should Be 0.0;
            $memoryReservationPercentValidation.Maximum | Should Be 1;
            $memoryReservationPercentValidation.Increment | Should Be 0.01;
            $memoryReservationPercentValidation.ValidatePattern | Should Be $null;
            $memoryReservationPercentValidation.Unit | Should Be "%";
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

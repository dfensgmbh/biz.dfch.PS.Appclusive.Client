function Import-Product {
    <#
    .SYNOPSIS
    Creates or Updates a Product (based on .NET Class)

    .DESCRIPTION
    Creates or Updates a Product (based on .NET Class)

    Inspects the .NET Class, based on it's attributes it will import the Class. Creating EntityKinds, Connectors, Interfaces, DataTypes and will even expand it to more Classes in the same Assembly which Require an Interface provided by the imported class.

    .OUTPUTS
    default | json | json-pretty | xml | xml-pretty

    .EXAMPLE

    # output suppressed

    .LINK
    Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Import-Product/

    .NOTES
    See module manifest for dependencies and further requirements.
    #>
    [CmdletBinding(
        SupportsShouldProcess = $true
	    ,
        ConfirmImpact = 'Medium'
	    ,
	    HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/Import-Product/'
    )]
    Param 
    (
	    # Specifies the Name of the Class to be imported
	    [Parameter(Mandatory = $true, Position = 0)]
        [Alias("FQCN")]
	    [string] $Class
	    ,
	    # Specifies to not also import dependent classes (connected children).
	    [Parameter(Mandatory = $false, Position = 1)]
	    [switch] $ExcludeDependent = $false
	    ,
	    # Specifies to update existing data
	    [Parameter(Mandatory = $false, Position = 2)]
	    [switch] $Force = $false
	    ,
	    # Service reference to Appclusive
	    [Parameter(Mandatory = $false, Position = 3)]
	    [Alias('Services')]
	    [hashtable] $svc = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Services
	    ,
	    # Specifies the return format of the Cmdlet
	    [ValidateSet('default', 'json', 'json-pretty', 'xml', 'xml-pretty')]
	    [Parameter(Mandatory = $false)]
	    [Alias('ReturnFormat')]
	    [string] $As = 'default'
    )

    Begin 
    {
	    trap { Log-Exception $_; break; }

        $entitySetName = "DataTypes";

	    $datBegin = [datetime]::Now;
	    [string] $fn = $MyInvocation.MyCommand.Name;
	    Log-Debug -fn $fn -msg ("CALL. svc '{0}'. EntityKindVersion '{1}'." -f ($svc -is [Object]), $EntityKindVersion) -fac 1;

	    # Parameter validation
	    Contract-Requires ($svc.Core -is [biz.dfch.CS.Appclusive.Api.Core.Core]) "Connect to the server before using the Cmdlet"
    }
    # Begin

    Process 
    {
        # Default test variable for checking function response codes.
        [Boolean] $fReturn = $false;
        # Return values are always and only returned via OutputParameter.
        $OutputParameter = $null;

        try
        {
            $ImportProduct_r = @();

	        $instance = New-Object $Class;
	        Contract-Assert (!!$instance)
        
            $entityType = $instance.GetType();
            $entityKind = Get-ApcEntityKind -Version $Class;
        
            if ($entityKind -and -not $Force)
            {
                Write-Host "Stopping. EntityKind already exists, use Force to update. This is not recommended";
                return;
            }
        
            $null = RecursivelyImportProducts $entityType;

	        $OutputParameter = Format-ResultAs $ImportProduct_r $As;
            $fReturn = $true;
        }
        catch
        {
            Write-Host ($error[0] | out-string);

        }
    }
    # Process

    End 
    {
        $datEnd = [datetime]::Now;
        Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;

        # Return values are always and only returned via OutputParameter.
        return $OutputParameter;
    }
    # End
}

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Import-Product; } 

function RecursivelyImportProducts([Type] $entityKindType, [System.Collections.ArrayList] $importedEntityKinds)
{
    if (-not $importedEntityKinds)
    {
        $importedEntityKinds = New-Object System.Collections.ArrayList($null);
    }
    
    Log-Info ("Importing Ek: '{0}'" -f ($entityKindType.FullName));
    # import EntityKind (incl. all stuff)
    $null = Import-EntityKind $entityKindType;
    
    # remember we imported it.
    $importedEntityKinds.Add($entityKindType);

    # find attached EntityKinds
    $provides = $entityKindType.GetCustomAttributes([biz.dfch.CS.Appclusive.Public.Configuration.ProvideInterfaceAttribute], $true);
    $possibleImports = GetPossibleImports $entityKindType;
    
    foreach ($provide in $provides)
    {
        $children = RequiresInterface $possibleImports $provide.Name $importedEntityKinds;
        Log-Info ("Checking Interface: '{0}'" -f $provide);

        foreach ($child in $children)
        {
            Log-Info ("Importing Ek: '{0}'" -f $child);
            $null = RecursivelyImportProducts $child $importedEntityKinds;
        }
    }
}

function Import-EntityKind([Type] $entityType)
{
    Log-Info ("Importing {0}" -f $entityType.FullName);

    $instance = New-Object $entityType;
    Contract-Assert (!!$instance)

    $entityKind = CreateOrGetEntityKind $entityType.FullName;
    
    $entityKind.Parameters = $instance.GetStateMachine().ToString();
    $null = $svc.Core.UpdateObject($entityKind);
    $null = $svc.Core.SaveChanges();

    Log-Info ".. Importing DataTypes";
    $null = Import-DataType -FQCN $entityType.FullName -svc $svc -RecreateIfExist -Confirm:$false;
           
    $null = $Svc.Core.SaveChanges();
    
    Log-Info ".. Importing Connectors";
    $nul = CreateOrUpdateConnectors $entityKind $entityType;
    $null = $Svc.Core.SaveChanges();
    
    Log-Info ".. Importing ProductAttribute";
    $null = HandleAppclusiveProductAttribute $entityKind $entityType;
    $null = $Svc.Core.SaveChanges();
    
    Log-Info ".. Importing Icon";
    $null = HandleIconAttribute $entityKind $entityType;
    $null = $Svc.Core.SaveChanges();
    
    Log-Info ".. Importing Permissions";
    $null = CreatePermissionsForEntityKindStateTransisitons $instance $entityKind;
    $null = $Svc.Core.SaveChanges();

}

function CreateOrUpdateConnectors([biz.dfch.CS.Appclusive.Api.Core.EntityKind] $entityKind, [Type] $entityKindType)
{
    $existingConnectors = $svc.Core.Connectors.AddQueryOption('$filter', ("EntityKindId eq {0}" -f $entityKind.Id)) | Select;
    $shouldConnectors = $entityKindType.GetCustomAttributes([biz.dfch.CS.Appclusive.Public.Configuration.InterfaceBaseAttribute], $true);
    
    $finalConnectors = New-Object System.Collections.ArrayList($null);
    
    Log-Info "... Adding Connectors";
    foreach ($shouldConnector in $shouldConnectors)
    {
        $interface = GetInterfaceIdByName $shouldConnector.Name;
        $existingConnector = $existingConnectors | where { $_.InterfaceId -eq $interface.Id -and $_.ConnectionType -eq $shouldConnector.ConnectorType };

        if (-not $existingConnector)
        {
            $existingConnector = New-Object biz.dfch.CS.Appclusive.Api.Core.Connector;
            $null = $svc.Core.AddToConnectors($existingConnector);

            $existingConnector.Name = "{0}_{1}::{2}" -f $entityKind.Id, $interface.Id, $shouldConnector.ConnectorType;
            $existingConnector.InterfaceId = $interface.Id;
            $existingConnector.EntityKindId = $entityKind.Id;
            $existingConnector.ConnectionType = $shouldConnector.ConnectorType;
        }

        $existingConnector.Multiplicity = $shouldConnector.Multiplicity;
        $null = $svc.Core.UpdateObject($existingConnector);
        $null = $finalConnectors.Add($existingConnector);
    }

    
    Log-Info "... Removing Connectors";
    foreach ($existingConnector in $existingConnectors)
    {
        $match = $finalConnectors | where { $_.InterfaceId -eq $existingConnector.InterfaceId -and $_.ConnectionType -eq $existingConnector.ConnectionType };

        if (-not $match)
        {
            # Write-Host ($existingConnector | out-string);
            # TODO FIX:
            #
            #      "lang":"en-US","value":"[ActivityID: 00000000-0000-0000-0000-000000000000] Assertion failed: EntityKindManager.GetEntityKindId<TEntity>()"
            #
            # $null = $svc.Core.DeleteObject($existingConnector);
        }
    }
    
    $null = $svc.Core.SaveChanges();

    return $finalConnectors;
}

function CreatePermission([string] $PermissionName, $Svc)
{
    $permission = $Svc.Core.Permissions.AddQueryOption('$filter', ("Name eq '{0}'" -f $PermissionName)) | Select -First 1;

    if (-not $permission)
    {
        Log-Info $PermissionName;

        $permission = New-Object biz.dfch.CS.Appclusive.Api.Core.Permission;
		$null = $Svc.Core.AddToPermissions($permission);
        
		$permission.Name = $PermissionName;
		$permission.Description = $PermissionName;

		$Svc.Core.UpdateObject($permission);        
        $null = $Svc.Core.SaveChanges();

        Log-Info " Created";
    }
    else
    {
        Log-Info ("{0} already exists" -f $PermissionName);
    }
}

function CreatePermissionsForEntityKindStateTransisitons([biz.dfch.CS.Appclusive.Public.Configuration.IEntityKindBaseDto] $instance, [biz.dfch.CS.Appclusive.Api.Core.EntityKind] $entityKind)
{
    $null = CreatePermission -PermissionName ("{0}:*" -f $entityKind.Name) -Svc $svc;

    foreach ($transition in $instance.GetStateMachine())
    {
        $null = CreatePermission -PermissionName ("{0}:{1}" -f $entityKind.Name, $transition.Transition) -Svc $svc;
    }
}

function CreateOrGetEntityKind([Type] $entityType)
{
    $entityKind = $svc.Core.EntityKinds.AddQueryOption('$filter', "Version eq '{0}'" -f $entityType.FullName) | Select -First 1;

    if (-not $entityKind)
    {
        $entityKind = New-Object biz.dfch.CS.Appclusive.Api.Core.EntityKind;
		$null = $svc.Core.AddToEntityKinds($entityKind);

        $entityKind.Name = ("{0}.{1}" -f $entityType.Namespace.Substring(0, $entityType.Namespace.LastIndexOf(".")), $entityType.Name);
        $entityKind.Version = $entityType.FullName;   
         
        $svc.Core.UpdateObject($entityKind);    
        $null = $Svc.Core.SaveChanges();
    }

    return $entityKind;
}

function GetInterfaceIdByName([string] $name)
{
    $interface = $svc.Core.Interfaces.AddQueryOption('$filter', ("Name eq '{0}'" -f $name)).AddQueryOption('$top', 1L) | SELECT;

    if (-not $interface)
    {
        $interface = Set-ApcInterface -Name $name -svc $svc -CreateIfNotExist;
    }

    return $interface;
}

function HandleAppclusiveProductAttribute([biz.dfch.CS.Appclusive.Api.Core.EntityKind] $entityKind, [Type] $entityKindType)
{
    $appclusiveProduct = $entityKindType.GetCustomAttributes([biz.dfch.CS.Appclusive.Public.Configuration.AppclusiveProductAttribute], $true);
        
    if ($appclusiveProduct)
    {
        $name = $appclusiveProduct.DisplayName;
        $product = $svc.Core.Products.AddQueryOption('$filter', ("EntityKindId eq {0} and Name eq '{1}'" -f $entityKind.Id,$name)).AddQueryOption('$top', 1) | SELECT;

        if (-not $product)
        {
            $product = New-Object biz.dfch.CS.Appclusive.Api.Core.Product;

            $product.Name = $name;
            $product.EntityKindId = $entityKind.Id;
            $product.ValidFrom = [System.DateTimeOffset]::MinValue;
            $product.ValidUntil = [System.DateTimeOffset]::MaxValue;
            $product.EndOfLife = [System.DateTimeOffset]::MaxValue;

            # DFTODO : Get Type from Product
            $product.Type = "Product";
        }
    }
}

function HandleIconAttribute([biz.dfch.CS.Appclusive.Api.Core.EntityKind] $entityKind, [Type] $entityKindType)
{
    $IconAttribute = $entityKindType.GetCustomAttributes([biz.dfch.CS.Appclusive.Public.Configuration.IconAttribute], $true);

    if ($IconAttribute)
    {
        $key = $entityKind.Version;
        $name = ("Icon-{0}" -f $IconAttribute.Type);
        $value = ("picto-{0}" -f $IconAttribute.Name);

        # $null = Set-ApcKeyNameValue -Key $key -Name $name -Value $value -svc $svc -CreateIfNotExist;
    }
}

function GetPossibleImports([Type] $entityKindType)
{
    $list = New-Object System.Collections.ArrayList($null); 
    $types = $entityKindType.Assembly.GetTypes();   
    $baseEntityKindInterface = [biz.dfch.CS.Appclusive.Public.Configuration.IEntityKindBaseDto];

    foreach ($type in $types)
    {
        $isOfEntityKindBaseDtoType = $baseEntityKindInterface.IsAssignableFrom($type);
        if ($isOfEntityKindBaseDtoType -and -not $type.IsAbstract)
        {
            $null = $list.Add($type);
        }
    }

    return $list;
}

function RequiresInterface([System.Collections.ArrayList] $types, [string] $interfaceName, [System.Collections.ArrayList] $except)
{
    $list = New-Object System.Collections.ArrayList($null);

    foreach ($type in $types)
    {
        $isExcepted = $except.Contains($type);

        if ($isExcepted)
        {
            continue;
        }

        $attributes = $type.GetCustomAttributes([biz.dfch.CS.Appclusive.Public.Configuration.RequireInterfaceAttribute], $true);
        $requires = $false;

        foreach ($attribute in $attributes)
        {
            if ($attribute.Name -eq $interfaceName)
            {
                $requires = $true;
            }
        }

        if ($requires)
        {
            $null = $list.Add($type);
        }        
    }

    return $list;
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

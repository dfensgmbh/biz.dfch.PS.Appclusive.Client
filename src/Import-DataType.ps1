function Import-DataType {
<#
.SYNOPSIS
Creates or Recreates DataTypes for an EntityKind (based on .NET Class)
.DESCRIPTION
Creates or Recreates DataTypes for an EntityKind (based on .NET Class)

Inspects the .NET Class for all it's properties and will create for every Property with an EntityBag Mapping a DataType. All supported Validation Attributes will be parsed into the DataTypes.
.OUTPUTS
default | json | json-pretty | xml | xml-pretty | PSCredential | Clear
.EXAMPLE
Import-DataType -EntityKindVersion biz.dfch.Appclusive.Products.Infrastructure.VirtualMachine.Network.NicCollection.Nic -RecreateIfExist

EntityKindId      : 15194
ValidateSet       :
ValidatePattern   :
ValidateScript    :
Type              : System.String
Default           :
Minimum           :
Maximum           :
Increment         :
IncrementFunction :
IsRequired        : True
Unit              :
Id                : 204
Tid               : 11111111-1111-1111-1111-111111111111
Name              : biz.dfch.Appclusive.Products.Infrastructure.VirtualMachine.Network.NicCollection.Nic.Name
Description       : This string property specifies the name of the virtual Network Interface Card
CreatedById       : 1
ModifiedById      : 1
Created           : 22.08.2016 11:45:01 +02:00
Modified          : 22.08.2016 11:45:01 +02:00
RowVersion        : {0, 0, 0, 0...}
EntityKind        :
Tenant            :
CreatedBy         :
ModifiedBy        :
.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Import-DataType/
.NOTES
See module manifest for dependencies and further requirements.
#>
[CmdletBinding(
    SupportsShouldProcess = $false
	,
    ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/Import-DataType/'
)]
Param 
(
	# Specifies the name of the entity to be parsed
	[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
    [Alias("FQCN")]
	[string] $EntityKindVersion
	,
	# Specifies to delete and create the datatypes if they already exist
	[Parameter(Mandatory = $false, Position = 1)]
	[Alias("f")]
	[Alias("force")]
	[switch] $RecreateIfExist = $false
	,
	# Service reference to Appclusive
	[Parameter(Mandatory = $false, Position = 2)]
	[Alias('Services')]
	[hashtable] $svc = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Services
	,
	# Specifies the return format of the Cmdlet
	[ValidateSet('default', 'json', 'json-pretty', 'xml', 'xml-pretty')]
	[Parameter(Mandatory = $false, Position = 3)]
	[Alias('ReturnFormat')]
	[string] $As = 'default'
)

Begin 
{
	trap { Log-Exception $_; break; }

    $entitySetName = "DataTypes";

	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug -fn $fn -msg ("CALL. svc '{0}'. Name '{1}'." -f ($svc -is [Object]), $EntityKindVersion) -fac 1;

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
        $entityKind = Get-ApcEntityKind -Version $EntityKindVersion -svc $svc;
        Contract-Assert !!$entityKind ("EntityKindVersion '{0}' must exist" -f $EntityKindVersion);
        Log-Debug $fn ("Loaded EntityKind with Version:{0} and Id:{1}" -f $entityKind.Version, $entityKind.Id);

        $EntityType = LoadTypeFromLocalAssemblybyFullQualifiedClassName $entityKind.Version;
        $ClassProperties = $EntityType.GetProperties();
        
        $r = @();
        
        $dataTypes = $svc.Diagnostics.DataTypes.AddQueryOption('$filter', ("EntityKindId eq {0}" -f $entityKind.Id));
        if ($PSBoundParameters.ContainsKey('RecreateIfExist'))
        {
            ForEach ($dataType in $dataTypes)
            {
                Remove-ApcEntity -svc $svc -InputObject $dataType -Confirm:$false;
            }

            $dataTypes = @();
        }

        ForEach ($classProperty in $ClassProperties)
        {
            $hasEntityBagAttribute = HasEntityBagAttribute $classProperty;
            if (!$hasEntityBagAttribute)
            {
                continue;
            }

            $dataType = $dataTypes | where { $_.Name -eq $classProperty.Name };
            if (!!$dataType)
            {
                # Do not change an existing dataType
                Log-Debug $fn ("[{0}]::{1} has not been updated." -f $entityKind.Version,$classProperty.Name);
                continue;
            }

            $dataType = New-Object biz.dfch.CS.Appclusive.Core.OdataServices.Diagnostics.DataType;
            $svc.Diagnostics.AddToDataTypes($dataType);

            $dataType.EntityKindId = $entityKind.Id;
            $dataType.Type = $classProperty.PropertyType.FullName;
            
            ApplyEntityBagAttribute $dataType $classProperty;
            ApplyPropertyDescriptionAttribute $dataType $classProperty;
            ApplyDefaultValue $dataType $classProperty;
            ApplyRequired $dataType $classProperty;
            ApplyRange $dataType $classProperty;
            ApplyIncrement $dataType $classProperty;
            ApplyUnit $dataType $classProperty;
            ApplyValidatePattern $dataType $classProperty;
            ApplyValidateScript $dataType $classProperty;
            ApplyValidateSet $dataType $classProperty;
            
	        $svc.Diagnostics.UpdateObject($dataType);
            $null = $svc.Diagnostics.SaveChanges();

            $r += $dataType;
        }

	    $OutputParameter = Format-ResultAs $r $As;
	    $fReturn = $true;
    }
    catch
    {
        Write-Error ($error[0]);
        $OutputParameter = $null;
	    $fReturn = $false;
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

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Import-DataType; } 


function LoadTypeFromLocalAssemblybyFullQualifiedClassName([string]$FQCN)
{
    $assemblies = [System.AppDomain]::CurrentDomain.GetAssemblies();
    $foundClasses = @();

	foreach($assembly in $assemblies)
	{		
		foreach($definedType in $assembly.DefinedTypes)
		{
			# only filter public and nested classes, skip interfaces
			if(!(($definedType.IsPublic -eq $true -Or $definedType.IsNestedPublic -eq $true) -And $definedType.IsInterface -ne $true))
			{
				continue;
			}
			
			$definedTypeFullName = $definedType.FullName;
			# swap base type into type name to enable search
			if($BaseType)
			{
				$definedTypeFullName = $definedType.BaseType.FullName;
			}

			if($definedTypeFullName -cne $FQCN)
			{
				continue;
			}
			
			# swap original type name back (because of BaseType switch)
			$definedTypeFullName = $definedType.FullName;

            $foundClasses += $definedType;
		}
	}

    if ($foundClasses.Count -eq 1)
    {
        return $foundClasses[0];
    }
    elseif ($foundClasses.Count -eq 0)
    {
        throw ("'{0}' is not in a loaded assembly" -f $FQCN);
    }
    else 
    {
        throw ("'{0}' is not Unique" -f $FQCN);
    }
}

function HasEntityBagAttribute($property)
{
    $attr = $classProperty.GetCustomAttributes([biz.dfch.CS.Appclusive.Public.Converters.EntityBagAttribute], $true);
    
    return ($attr.Count -eq 1);
}

function ApplyEntityBagAttribute([biz.dfch.CS.Appclusive.Core.OdataServices.Diagnostics.DataType]$dataType, $property)
{
    $attr = $classProperty.GetCustomAttributes([biz.dfch.CS.Appclusive.Public.Converters.EntityBagAttribute], $true);
    
    $dataType.Name = $attr.Name;
}

function ApplyPropertyDescriptionAttribute([biz.dfch.CS.Appclusive.Core.OdataServices.Diagnostics.DataType]$dataType, $property)
{
    $attr = $classProperty.GetCustomAttributes([biz.dfch.CS.Appclusive.Public.Configuration.EntityBagDescriptionAttribute], $true);
    if ($attr)
    {
        $dataType.Description = $attr.Name;
    }
}

function ApplyDefaultValue([biz.dfch.CS.Appclusive.Core.OdataServices.Diagnostics.DataType]$dataType, $property)
{
    $attr = $classProperty.GetCustomAttributes([System.ComponentModel.DefaultValueAttribute], $true);
    if ($attr)
    {
        $dataType.Default = $attr.Value;
    }
}

function ApplyRequired([biz.dfch.CS.Appclusive.Core.OdataServices.Diagnostics.DataType]$dataType, $property)
{
    $attr = $classProperty.GetCustomAttributes([System.ComponentModel.DataAnnotations.RequiredAttribute], $true);

    if ($attr)
    {
        $dataType.IsRequired = $true;
    }
    else
    {
        $dataType.IsRequired = $false;
    }
}

function ApplyRange([biz.dfch.CS.Appclusive.Core.OdataServices.Diagnostics.DataType]$dataType, $property)
{
    $attr = $classProperty.GetCustomAttributes([System.ComponentModel.DataAnnotations.RangeAttribute], $true);

    if ($attr)
    {
        $dataType.Minimum = $attr.Minimum;
        $dataType.Maximum = $attr.Maximum;
    }
}

function ApplyIncrement([biz.dfch.CS.Appclusive.Core.OdataServices.Diagnostics.DataType]$dataType, $property)
{
    $attr = $classProperty.GetCustomAttributes([biz.dfch.CS.Appclusive.Public.Configuration.IncrementAttribute], $true);

    if ($attr)
    {
        $dataType.Increment = $attr.Increment;
        $dataType.IncrementFunction = $attr.IncrementFunction;
    }
}

function ApplyUnit([biz.dfch.CS.Appclusive.Core.OdataServices.Diagnostics.DataType]$dataType, $property)
{
    $attr = $classProperty.GetCustomAttributes([biz.dfch.CS.Appclusive.Public.Configuration.UnitAttribute], $true);

    if ($attr)
    {
        $dataType.Unit = $attr.Name;
    }
}

function ApplyValidateSet([biz.dfch.CS.Appclusive.Core.OdataServices.Diagnostics.DataType]$dataType, $property)
{
    $attr = $classProperty.GetCustomAttributes([biz.dfch.CS.Appclusive.Public.Configuration.ValidateSetIfRequiredAttribute], $true);

    if ($attr)
    {
        $dataType.ValidateSet = $attr.Set;
    }
}

function ApplyValidateScript([biz.dfch.CS.Appclusive.Core.OdataServices.Diagnostics.DataType]$dataType, $property)
{
    $attr = $classProperty.GetCustomAttributes([biz.dfch.CS.Appclusive.Public.Configuration.ValidateScriptIfRequiredAttribute], $true);

    if ($attr)
    {
        $dataType.ValidateScript = $attr.Script;
    }
}

function ApplyValidatePattern([biz.dfch.CS.Appclusive.Core.OdataServices.Diagnostics.DataType]$dataType, $property)
{
    $attr = $classProperty.GetCustomAttributes([biz.dfch.CS.Appclusive.Public.Configuration.ValidatePatternIfRequiredAttribute], $true);

    if ($attr)
    {
        $dataType.ValidatePattern = $attr.Pattern;
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

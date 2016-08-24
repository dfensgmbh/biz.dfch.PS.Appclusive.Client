function Import-DataType {
<#
.SYNOPSIS
Creates or Recreates DataTypes for an EntityKind (based on .NET Class)

.DESCRIPTION
Creates or Recreates DataTypes for an EntityKind (based on .NET Class)

Inspects the .NET Class for all its properties and will create for every Property with an EntityBag Mapping a DataType. All supported Validation Attributes will be parsed into the DataTypes.

.OUTPUTS
default | json | json-pretty | xml | xml-pretty

.EXAMPLE
# Imports all properties of the product 'biz.dfch.Appclusive.Products.Infrastructure.V001.VirtualMachine'. Existing properties will be deleted if they already exist.
Import-DataType -EntityKindVersion biz.dfch.Appclusive.Products.Infrastructure.V001.VirtualMachine -RecreateIfExist

EntityKindId       : 4099
ValidateSet        :
ValidatePattern    :
ValidateScript     :
Type               : System.Double
KeyNameValueFilter :
Default            : 4
Minimum            : 0.5
Maximum            : 384
Increment          : 0.1
IncrementFunction  :
IsRequired         : True
Unit               : GB
Id                 : 88
Tid                : 11111111-1111-1111-1111-111111111111
Name               : biz.dfch.Appclusive.Products.Infrastructure.VirtualMachine.Memory.Size
Description        : This property specifies the memory in MB of the virtual machine.
CreatedById        : 3
ModifiedById       : 3
Created            : 8/24/2016 8:31:04 PM +02:00
Modified           : 8/24/2016 8:31:04 PM +02:00
RowVersion         : {0, 0, 0, 0...}
EntityKind         :
Tenant             :
CreatedBy          :
ModifiedBy         :

# output suppressed

.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Import-DataType/

.NOTES
See module manifest for dependencies and further requirements.
#>
[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = 'Medium'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/Import-DataType/'
)]
Param 
(
	# Specifies the Version of the EntityKind to be imported
	[Parameter(Mandatory = $true, Position = 0)]
    [Alias("FQCN")]
	[string] $EntityKindVersion
	,
	# Specifies to delete already existing entities during import
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

	$entityKind = biz.dfch.PS.Appclusive.Client\Get-ApcEntityKind -Version $EntityKindVersion -svc $svc;
	Contract-Assert (!!$entityKind) "EntityKindVersion does not exist";
	Log-Debug $fn ("Found EntityKind.Version:{0} [{1}]" -f $entityKind.Version, $entityKind.Id);

	$entityFqcn = biz.dfch.PS.System.Utilities\Get-DataType $entityKind.Version;
	Contract-Assert (1 -eq $entityFqcn.Count)
	$instance = New-Object $entityFqcn;
	Contract-Assert (!!$instance)
	$properties = $instance.GetType().GetProperties([System.Reflection.BindingFlags]::Public -bor [System.Reflection.BindingFlags]::FlattenHierarchy -bor [System.Reflection.BindingFlags]::Instance);
	Contract-Assert (!!$properties);
	Contract-Assert ($properties -is [Array])
	
	$r = @();
	
	$q = "EntityKindId eq {0}" -f $entityKind.Id;
	$dataTypes = $svc.Diagnostics.DataTypes.AddQueryOption('$filter', $q) | Select;
	if ($PSBoundParameters.ContainsKey('RecreateIfExist'))
	{
		foreach ($dataType in $dataTypes)
		{
			biz.dfch.PS.Appclusive.Client\Remove-Entity -svc $svc -InputObject $dataType -Confirm:$false;
		}

		$dataTypes = @();
	}

	foreach ($classProperty in $properties)
	{
		$hasEntityBagAttribute = HasEntityBagAttribute $classProperty;
		if (!$hasEntityBagAttribute)
		{
			continue;
		}

		$dataType = $dataTypes |? Name -eq $classProperty.Name;
		if (!!$dataType)
		{
			# Do not change an existing dataType
			Log-Warning $fn ("{0}.{1} has not been updated." -f $entityKind.Version, $classProperty.Name);
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
		ApplyKeyNameValueFilter $dataType $classProperty;
		ApplyStringLength $dataType $classProperty;
		
		$svc.Diagnostics.UpdateObject($dataType);
		if($PSCmdlet.ShouldProcess(($dataType | Out-String)))
		{
			$null = $svc.Diagnostics.SaveChanges();
			$r += $dataType;
		}

	}

	# $OutputParameter = biz.dfch.PS.Appclusive.Client\Format-ResultAs $r $As;
	$OutputParameter = $r;
	$fReturn = $true;

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

function HasEntityBagAttribute($property)
{
    $attr = $property.GetCustomAttributes([biz.dfch.CS.Appclusive.Public.Converters.EntityBagAttribute], $true);
    
    return ($attr.Count -eq 1);
}

function ApplyEntityBagAttribute([biz.dfch.CS.Appclusive.Core.OdataServices.Diagnostics.DataType] $dataType, $property)
{
    $attr = $property.GetCustomAttributes([biz.dfch.CS.Appclusive.Public.Converters.EntityBagAttribute], $true);
    Contract-Assert (!!$attr) "EntityBagAttribute does not exist $($dataType.Type)"
	
    $dataType.Name = $attr.Name;
}

function ApplyPropertyDescriptionAttribute([biz.dfch.CS.Appclusive.Core.OdataServices.Diagnostics.DataType] $dataType, $property)
{
    $attr = $property.GetCustomAttributes([biz.dfch.CS.Appclusive.Public.Configuration.EntityBagDescriptionAttribute], $true);

    if (!$attr)
    {
		return;
    }

	$dataType.Description = $attr.Name;
}

function ApplyDefaultValue([biz.dfch.CS.Appclusive.Core.OdataServices.Diagnostics.DataType] $dataType, $property)
{
    $attr = $property.GetCustomAttributes([System.ComponentModel.DefaultValueAttribute], $true);

    if (!$attr)
    {
		return;
    }

	$dataType.Default = $attr.Value;
}

function ApplyRequired([biz.dfch.CS.Appclusive.Core.OdataServices.Diagnostics.DataType] $dataType, $property)
{
    $attr = $property.GetCustomAttributes([System.ComponentModel.DataAnnotations.RequiredAttribute], $true);

	$dataType.IsRequired = $false;
    
	if (!$attr)
    {
		return;
    }
	
	$dataType.IsRequired = $true;
}

function ApplyRange([biz.dfch.CS.Appclusive.Core.OdataServices.Diagnostics.DataType] $dataType, $property)
{
    $attr = $property.GetCustomAttributes([System.ComponentModel.DataAnnotations.RangeAttribute], $true);

    if (!$attr)
    {
		return;
    }

	$dataType.Minimum = $attr.Minimum;
	$dataType.Maximum = $attr.Maximum;
}

function ApplyIncrement([biz.dfch.CS.Appclusive.Core.OdataServices.Diagnostics.DataType] $dataType, $property)
{
    $attr = $property.GetCustomAttributes([biz.dfch.CS.Appclusive.Public.Configuration.IncrementAttribute], $true);

    if (!$attr)
    {
		return;
    }

	$dataType.Increment = $attr.Increment;
	$dataType.IncrementFunction = $attr.IncrementFunction;
}

function ApplyUnit([biz.dfch.CS.Appclusive.Core.OdataServices.Diagnostics.DataType] $dataType, $property)
{
    $attr = $property.GetCustomAttributes([biz.dfch.CS.Appclusive.Public.Configuration.UnitAttribute], $true);

    if (!$attr)
    {
		return;
    }
	
	$dataType.Unit = $attr.Unit;
}

function ApplyValidateSet([biz.dfch.CS.Appclusive.Core.OdataServices.Diagnostics.DataType] $dataType, $property)
{
    $attr = $property.GetCustomAttributes([biz.dfch.CS.Appclusive.Public.Configuration.ValidateSetIfNotDefaultAttribute], $true);

    if (!$attr)
    {
		return;
    }

	$dataType.ValidateSet = $attr.Set;
}

function ApplyValidateScript([biz.dfch.CS.Appclusive.Core.OdataServices.Diagnostics.DataType] $dataType, $property)
{
    $attr = $property.GetCustomAttributes([biz.dfch.CS.Appclusive.Public.Configuration.ValidateScriptIfNotDefaultAttribute], $true);

    if (!$attr)
    {
		return;
    }
	
	$dataType.ValidateScript = $attr.Script;
}

function ApplyValidatePattern([biz.dfch.CS.Appclusive.Core.OdataServices.Diagnostics.DataType] $dataType, $property)
{
    $attr = $property.GetCustomAttributes([biz.dfch.CS.Appclusive.Public.Configuration.ValidatePatternIfNotDefaultAttribute], $true);

    if (!$attr)
    {
		return;
    }
	
	$dataType.ValidatePattern = $attr.Pattern;
}

function ApplyKeyNameValueFilter([biz.dfch.CS.Appclusive.Core.OdataServices.Diagnostics.DataType] $dataType, $property)
{
    $attr = $property.GetCustomAttributes([biz.dfch.CS.Appclusive.Public.Configuration.KeyNameValueFilterAttribute], $true);

    if (!$attr)
    {
		return;
    }
	
	$dataType.KeyNameValueFilter = $attr.Pattern;
}

function ApplyStringLength([biz.dfch.CS.Appclusive.Core.OdataServices.Diagnostics.DataType] $dataType, $property)
{
    $attr = $property.GetCustomAttributes([System.ComponentModel.DataAnnotations.StringLengthAttribute], $true);

    if (!$attr)
    {
		return;
    }

	$dataType.Maximum = $attr.MaximumLength;
	$dataType.Minimum = $attr.MinimumLength;
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

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
	# Specifies to delete already existing entities during import
	[Parameter(Mandatory = $false, Position = 3)]
	[switch] $ExcludeDependent = $false
	,
	# Service reference to Appclusive
	[Parameter(Mandatory = $false, Position = 5)]
	[Alias('Services')]
	[hashtable] $svc = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Services
	,
	# Specifies the return format of the Cmdlet
	[ValidateSet('default', 'json', 'json-pretty', 'xml', 'xml-pretty')]
	[Parameter(Mandatory = $false, Position = 6)]
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
        Write-Host $Class;
        $entityFqcn = biz.dfch.PS.System.Utilities\Get-DataType $Class;
        Write-Host ($entityFqcn | out-string);
	    Contract-Assert (1 -eq $entityFqcn.Count)

	    $instance = New-Object $entityFqcn;
	    Contract-Assert (!!$instance)
        
        $entityType = $instance.GetType();

        $entityKind = biz.dfch.PS.Appclusive.Client\Get-EntityKind -Version $entityFqcn;

        if ($entityKind)
        {
            return;
        }
    
        $entityKind = New-Object biz.dfch.CS.Appclusive.Api.Core.EntityKind;
		$svc.Core.AddToEntityKinds($dataType);

        $entityKind.Name = ("{0}.{1}" -f $entityType.Namespace.Substring(0, $t.Namespace.LastIndexOf(".")), $entityType.Name);
        $entityKind.Version = $entityFqcn;

        $entityKind.Parameters = $instance.GetStateMachine().ToString();
        $svc.Core.SaveChanges();
        
	    # $OutputParameter = biz.dfch.PS.Appclusive.Client\Format-ResultAs $r $As;
	    $OutputParameter = $r;
	    $fReturn = $true;
    }
    catch
    {

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

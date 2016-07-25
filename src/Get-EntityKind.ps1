function Get-EntityKind {
<#
.SYNOPSIS
Retrieves one or more entities from the EntityKind entity set.


.DESCRIPTION
Retrieves one or more entities from the EntityKind entity set.

You can retrieve one ore more entities from the entity set by specifying 
Id, Name or other properties.


.INPUTS
The Cmdlet can either return all available entities or filter entities on 
specified conditions.
See PARAMETERS section on possible inputs.


.OUTPUTS
default | json | json-pretty | xml | xml-pretty

In addition output can be filtered on specified properties.


.EXAMPLE
Get-EntityKind -ListAvailable -Select Name

Name
----
biz.dfch.CS.Appclusive.Core.com.swisscom.cms.Mos
biz.dfch.CS.Appclusive.Core.OdataServices.Core.Ace
biz.dfch.CS.Appclusive.Core.OdataServices.Core.Acl
biz.dfch.CS.Appclusive.Core.OdataServices.Core.Approval
biz.dfch.CS.Appclusive.Core.OdataServices.Core.Assoc
biz.dfch.CS.Appclusive.Core.OdataServices.Core.AuditTrail
biz.dfch.CS.Appclusive.Core.OdataServices.Core.Cart
biz.dfch.CS.Appclusive.Core.OdataServices.Core.CartItem
biz.dfch.CS.Appclusive.Core.OdataServices.Core.Catalogue
biz.dfch.CS.Appclusive.Core.OdataServices.Core.CatalogueItem
biz.dfch.CS.Appclusive.Core.OdataServices.Core.ContractMapping
biz.dfch.CS.Appclusive.Core.OdataServices.Core.CostCentre
biz.dfch.CS.Appclusive.Core.OdataServices.Core.Customer
biz.dfch.CS.Appclusive.Core.OdataServices.Core.EntityKind
biz.dfch.CS.Appclusive.Core.OdataServices.Core.Gate
biz.dfch.CS.Appclusive.Core.OdataServices.Core.Job
biz.dfch.CS.Appclusive.Core.OdataServices.Core.KeyNameValue
biz.dfch.CS.Appclusive.Core.OdataServices.Core.ManagementCredential
biz.dfch.CS.Appclusive.Core.OdataServices.Core.ManagementUri
biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
biz.dfch.CS.Appclusive.Core.OdataServices.Core.Order
biz.dfch.CS.Appclusive.Core.OdataServices.Core.OrderItem
biz.dfch.CS.Appclusive.Core.OdataServices.Core.Permission
biz.dfch.CS.Appclusive.Core.OdataServices.Core.Product
biz.dfch.CS.Appclusive.Core.OdataServices.Core.Role
biz.dfch.CS.Appclusive.Core.OdataServices.Core.Tenant
biz.dfch.CS.Appclusive.Core.OdataServices.Core.User

Retrieves the name of all EntityKinds.


.EXAMPLE
Get-EntityKind 27

Version      : biz.dfch.CS.Appclusive.Core.com.swisscom.cms.Mos
Parameters   : {"InitialState-Create":"Created","Created-Run":"Running","Created-Delete":"Deleted","Running-Stop":"Stop
               ped","Stopped-Decommission":"Decomissioned"}
Id           : 27
Tid          : 11111111-1111-1111-1111-111111111111
Name         : biz.dfch.CS.Appclusive.Core.com.swisscom.cms.Mos
Description  : biz.dfch.CS.Appclusive.Core.com.swisscom.cms.Mos
CreatedById  : 1
ModifiedById : 1
Created      : 14.12.2015 00:00:00 +00:00
Modified     : 14.12.2015 00:00:00 +00:00
RowVersion   : {0, 0, 0, 0...}
Tenant       :
CreatedBy    : SYSTEM
ModifiedBy   : SYSTEM

Retrieves the EntityKind object with Id 27 and returns all properties of it.


.EXAMPLE
Get-EntityKind biz.dfch.CS.Appclusive.Core.com.swisscom.cms.Mos -Select Parameters -ValueOnly -ConvertFromJson

InitialState-Create  : Created
Created-Run          : Running
Created-Delete       : Deleted
Running-Stop         : Stopped
Stopped-Decommission : Decomissioned

Retrieves the EntityKind 'ActivitiClientUri' and only returns the 'Description' property 
of it. In addition the contents of the property will be converted from JSON.


.EXAMPLE
Get-EntityKind -ListAvailable -Select Name, Id -First 3

Name                                               Id
----                                               --
biz.dfch.CS.Appclusive.Core.com.swisscom.cms.Mos   27
biz.dfch.CS.Appclusive.Core.OdataServices.Core.Ace  3
biz.dfch.CS.Appclusive.Core.OdataServices.Core.Acl  4

Retrieves the name and id of the first 3 EntityKinds.


.EXAMPLE
Get-EntityKind 27 -Select Name -ValueOnly

biz.dfch.CS.Appclusive.Core.com.swisscom.cms.Mos

Retrieves the name of the EntityKind with Id 27.


.EXAMPLE
Get-EntityKind -ModifiedBy SYSTEM -Select Id, Name

Id Name
-- ----
 1 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
 2 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Job
 4 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Acl
 5 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Approval

Retrieves id and name of all Users that have been modified by user 
with name 'SYSTEM' (case insensitive substring match).


.EXAMPLE
Get-EntityKind -Version biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node -Select Id, Name

Id Name
-- ----
 1 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node

Retrieves id and name of EntityKind with version 'biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node' (case insensitive substring match).


.EXAMPLE
Get-EntityKind biz.dfch.CS.Appclusive.Core.com.swisscom.cms.Msql -Select Parameters -ValueOnly -DefaultValue @{"InitialState-Create"="Created";"Created-Decommission"="Decomissioned"}

Name                           Value
----                           -----
InitialState-Create            Created
Created-Decommission           Decomissioned

Retrieves the 'Parameters' property of a EntityKind with Name 'biz.dfch.CS.Appclusive.Core.com.swisscom.cms.Msql' 
and @{"InitialState-Create"="Created";"Created-Decommission"="Decomissioned"} if the entity is not found.


.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Get-EntityKind/


.NOTES
See module manifest for required software versions and dependencies.


#>
[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/Get-EntityKind/'
	,
	DefaultParameterSetName = 'list'
)]
PARAM 
(
	# Specifies the id of the entity
	[Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'id')]
	[int] $Id
	,
	# Specifies the name of the entity
	[Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'name')]
	[Alias('n')]
	[string] $Name
	,
	# Filter by version
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[string] $Version
	,
	# Filter by creator
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[string] $CreatedBy
	,
	# Filter by modifier
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[string] $ModifiedBy
	,
	# Specify the attributes of the entity to return
	[Parameter(Mandatory = $false)]
	[string[]] $Select = @()
	,
	# Specifies to return only values without header information. 
	# This parameter takes precendes over the 'Select' parameter.
	[ValidateScript( { if(1 -ge $Select.Count -And $_) { $true; } else { throw("You must specify exactly one 'Select' property when using 'ValueOnly'."); } } )]
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[Parameter(Mandatory = $false, ParameterSetName = 'id')]
	[Alias('HideTableHeaders')]
	[switch] $ValueOnly
	,
	# This value is only returned if the regular search would have returned no results
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[Parameter(Mandatory = $false, ParameterSetName = 'id')]
	[Alias('default')]
	$DefaultValue
	,
	# Specifies to deserialize JSON payloads
	[ValidateScript( { if($ValueOnly -And $_) { $true; } else { throw("You must set the 'ValueOnly' switch when using 'ConvertFromJson'."); } } )]
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[Parameter(Mandatory = $false, ParameterSetName = 'id')]
	[Alias('Convert')]
	[switch] $ConvertFromJson
	,
	# Limits the output to the specified number of entries
	[Parameter(Mandatory = $false)]
	[Alias('top')]
	[int] $First
	,
	# Retrieves the EntityKindId for the specified EntityKindName
	[Parameter(Mandatory = $false, ParameterSetName = 'resolveByName')]
	[string] $ResolveByName
	,
	# Retrieves the EntityKindId for the specified EntityKindName
	[Parameter(Mandatory = $false, ParameterSetName = 'resolveById')]
	[long] $ResolveById
	,
	# Service reference to Appclusive
	[Parameter(Mandatory = $false)]
	[Alias('Services')]
	[hashtable] $svc = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Services
	,
	# Indicates to return all file information
	[Parameter(Mandatory = $false, ParameterSetName = 'list')]
	[switch] $ListAvailable = $false
	,
    # Returns all Connectors which provide this Interface
    [Parameter(Mandatory = $false)]
    [Alias('Providers')]
    [switch] $ListProviders = $false
    ,
    # Returns all Connectors which require this Interface
	[Parameter(Mandatory = $false)]
    [Alias('Consumers')]
    [switch] $ListConsumers = $false
    ,
	# Specifies the return format of the Cmdlet
	[ValidateSet('default', 'json', 'json-pretty', 'xml', 'xml-pretty')]
	[Parameter(Mandatory = $false)]
	[alias('ReturnFormat')]
	[string] $As = 'default'
)

Begin 
{
	trap { Log-Exception $_; break; }

	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug -fn $fn -msg ("CALL. svc '{0}'. Name '{1}'." -f ($svc -is [Object]), $Name) -fac 1;
	
	$EntitySetName = 'EntityKinds';
	
	# Parameter validation
	Contract-Requires ($svc.Core -is [biz.dfch.CS.Appclusive.Api.Core.Core]) "Connect to the server before using the Cmdlet"
	
	if($Select) 
	{
		$Select = $Select | Select -Unique;
	}
	elseif ($ValueOnly)
	{
		$Select = 'Parameters';
	}
}
# Begin

Process 
{
	trap { Log-Exception $_; break; }

	# Default test variable for checking function response codes.
	[Boolean] $fReturn = $false;
	# Return values are always and only returned via OutputParameter.
	$OutputParameter = $null;

	Contract-Assert ($PSCmdlet.ShouldProcess(($PSBoundParameters | Out-String)))

	if($PSCmdlet.ParameterSetName -eq 'list') 
	{
		if($Select) 
		{
			if($PSBoundParameters.ContainsKey('First'))
			{
				$Response = $svc.Core.$EntitySetName.AddQueryOption('$orderby','Name').AddQueryOption('$top', $First) | Select -Property $Select;
			}
			else
			{
				$Response = $svc.Core.$EntitySetName.AddQueryOption('$orderby','Name') | Select -Property $Select;
			}
		}
		else 
		{
			if($PSBoundParameters.ContainsKey('First'))
			{
				$Response = $svc.Core.$EntitySetName.AddQueryOption('$orderby','Name').AddQueryOption('$top', $First) | Select;
			}
			else
			{
				$Response = $svc.Core.$EntitySetName.AddQueryOption('$orderby','Name') | Select;
			}
		}
	} 
	elseif($PSCmdlet.ParameterSetName -eq 'resolveByName') 
	{
		$Response = @();
		$names = [Enum]::GetNames([biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]);
		foreach($name in ($names -match $ResolveByName)) 
		{ 
			$Response += [Enum]::Parse([biz.dfch.CS.Appclusive.Public.Constants+EntityKindId], $name).value__;
		}
	}
	elseif($PSCmdlet.ParameterSetName -eq 'resolveById') 
	{
		$Response = @();
		$values = [Enum]::GetValues([biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]);
		foreach($value in $values) 
		{
			if($ResolveById -eq ($value -as [long]))
			{
				$Response = $value.ToString();
				break;
			}
		}
	}
	else 
	{
		$Exp = @();
		if($PSCmdlet.ParameterSetName -eq 'id')
		{
			$Exp += ("Id eq {0}" -f $Id);
		}
		if($Name) 
		{ 
			$Exp += ("tolower(Name) eq '{0}'" -f $Name.ToLower());
		}
		if($Version) 
		{ 
			$Exp += ("tolower(Version) eq '{0}'" -f $Version.ToLower());
		}
		if($CreatedBy) 
		{ 
			$CreatedById = Get-User -svc $svc -Name $CreatedBy -Select Id -ValueOnly;
			if ( !$CreatedById )
			{
				# User not found
				return;
			}
			$Exp += ("(CreatedById eq {0})" -f $CreatedById);
		}
		if($ModifiedBy)
		{ 
			$ModifiedById = Get-User -svc $svc -Name $ModifiedBy -Select Id -ValueOnly;
			if ( !$ModifiedById )
			{
				# User not found
				return;
			}			
			$Exp += ("(ModifiedById eq {0})" -f $ModifiedById);
		}
		$FilterExpression = [String]::Join(' and ', $Exp);
	
		if($Select) 
		{
			if($PSBoundParameters.ContainsKey('First'))
			{
				$Response = $svc.Core.$EntitySetName.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$top', $First) | Select -Property $Select;
			}
			else
			{
				$Response = $svc.Core.$EntitySetName.AddQueryOption('$filter', $FilterExpression) | Select -Property $Select;
			}
		}
		else 
		{
			if($PSBoundParameters.ContainsKey('First'))
			{
				$Response = $svc.Core.$EntitySetName.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$top', $First) | Select;
			}
			else
			{
				$Response = $svc.Core.$EntitySetName.AddQueryOption('$filter', $FilterExpression) | Select;
			}
		}
		if(1 -eq $Select.Count -And $ValueOnly)
		{
			$Response = $Response.$Select;
		}

        if (!$Response)
        {
		    if($PSBoundParameters.ContainsKey('DefaultValue'))
		    {
			    $Response = $DefaultValue;
		    }
        }
        else
        {
            if ($PSBoundParameters.ContainsKey('ListProviders'))
            {
                $Response = Get-Connector -svc $svc -EntityKindId $Response.Id -Provide;
            }
            elseif ($PSBoundParameters.ContainsKey('ListConsumers'))
            {
                $Response = Get-Connector -svc $svc -EntityKindId $Response.Id -Require;
            }
        }

		if($ValueOnly -And $ConvertFromJson)
		{
			$ResponseTemp = New-Object System.Collections.ArrayList;
			foreach($item in $Response)
			{
				try
				{
					$null = $ResponseTemp.Add((ConvertFrom-Json -InputObject $item));
				}
				catch
				{
					$null = $ResponseTemp.Add($item);
				}
			}
			$Response = $ResponseTemp.ToArray();
		}
	}

	$OutputParameter = Format-ResultAs $Response $As
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

} # function

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Get-EntityKind; } 

# 
# Copyright 2014-2015 d-fens GmbH
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

# SIG # Begin signature block
# MIIXDwYJKoZIhvcNAQcCoIIXADCCFvwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUwnLRzb3YdDjTksTKK5Kc7wR0
# LZ2gghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
# VzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNV
# BAsTB1Jvb3QgQ0ExGzAZBgNVBAMTEkdsb2JhbFNpZ24gUm9vdCBDQTAeFw0xMTA0
# MTMxMDAwMDBaFw0yODAxMjgxMjAwMDBaMFIxCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMSgwJgYDVQQDEx9HbG9iYWxTaWduIFRpbWVzdGFt
# cGluZyBDQSAtIEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlO9l
# +LVXn6BTDTQG6wkft0cYasvwW+T/J6U00feJGr+esc0SQW5m1IGghYtkWkYvmaCN
# d7HivFzdItdqZ9C76Mp03otPDbBS5ZBb60cO8eefnAuQZT4XljBFcm05oRc2yrmg
# jBtPCBn2gTGtYRakYua0QJ7D/PuV9vu1LpWBmODvxevYAll4d/eq41JrUJEpxfz3
# zZNl0mBhIvIG+zLdFlH6Dv2KMPAXCae78wSuq5DnbN96qfTvxGInX2+ZbTh0qhGL
# 2t/HFEzphbLswn1KJo/nVrqm4M+SU4B09APsaLJgvIQgAIMboe60dAXBKY5i0Eex
# +vBTzBj5Ljv5cH60JQIDAQABo4HlMIHiMA4GA1UdDwEB/wQEAwIBBjASBgNVHRMB
# Af8ECDAGAQH/AgEAMB0GA1UdDgQWBBRG2D7/3OO+/4Pm9IWbsN1q1hSpwTBHBgNV
# HSAEQDA+MDwGBFUdIAAwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFs
# c2lnbi5jb20vcmVwb3NpdG9yeS8wMwYDVR0fBCwwKjAooCagJIYiaHR0cDovL2Ny
# bC5nbG9iYWxzaWduLm5ldC9yb290LmNybDAfBgNVHSMEGDAWgBRge2YaRQ2XyolQ
# L30EzTSo//z9SzANBgkqhkiG9w0BAQUFAAOCAQEATl5WkB5GtNlJMfO7FzkoG8IW
# 3f1B3AkFBJtvsqKa1pkuQJkAVbXqP6UgdtOGNNQXzFU6x4Lu76i6vNgGnxVQ380W
# e1I6AtcZGv2v8Hhc4EvFGN86JB7arLipWAQCBzDbsBJe/jG+8ARI9PBw+DpeVoPP
# PfsNvPTF7ZedudTbpSeE4zibi6c1hkQgpDttpGoLoYP9KOva7yj2zIhd+wo7AKvg
# IeviLzVsD440RZfroveZMzV+y5qKu0VN5z+fwtmK+mWybsd+Zf/okuEsMaL3sCc2
# SI8mbzvuTXYfecPlf5Y1vC0OzAGwjn//UYCAp5LUs0RGZIyHTxZjBzFLY7Df8zCC
# BCkwggMRoAMCAQICCwQAAAAAATGJxjfoMA0GCSqGSIb3DQEBCwUAMEwxIDAeBgNV
# BAsTF0dsb2JhbFNpZ24gUm9vdCBDQSAtIFIzMRMwEQYDVQQKEwpHbG9iYWxTaWdu
# MRMwEQYDVQQDEwpHbG9iYWxTaWduMB4XDTExMDgwMjEwMDAwMFoXDTE5MDgwMjEw
# MDAwMFowWjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# MDAuBgNVBAMTJ0dsb2JhbFNpZ24gQ29kZVNpZ25pbmcgQ0EgLSBTSEEyNTYgLSBH
# MjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKPv0Z8p6djTgnY8YqDS
# SdYWHvHP8NC6SEMDLacd8gE0SaQQ6WIT9BP0FoO11VdCSIYrlViH6igEdMtyEQ9h
# JuH6HGEVxyibTQuCDyYrkDqW7aTQaymc9WGI5qRXb+70cNCNF97mZnZfdB5eDFM4
# XZD03zAtGxPReZhUGks4BPQHxCMD05LL94BdqpxWBkQtQUxItC3sNZKaxpXX9c6Q
# MeJ2s2G48XVXQqw7zivIkEnotybPuwyJy9DDo2qhydXjnFMrVyb+Vpp2/WFGomDs
# KUZH8s3ggmLGBFrn7U5AXEgGfZ1f53TJnoRlDVve3NMkHLQUEeurv8QfpLqZ0BdY
# Nc0CAwEAAaOB/TCB+jAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIB
# ADAdBgNVHQ4EFgQUGUq4WuRNMaUU5V7sL6Mc+oCMMmswRwYDVR0gBEAwPjA8BgRV
# HSAAMDQwMgYIKwYBBQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3Jl
# cG9zaXRvcnkvMDYGA1UdHwQvMC0wK6ApoCeGJWh0dHA6Ly9jcmwuZ2xvYmFsc2ln
# bi5uZXQvcm9vdC1yMy5jcmwwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHwYDVR0jBBgw
# FoAUj/BLf6guRSSuTVD6Y5qL3uLdG7wwDQYJKoZIhvcNAQELBQADggEBAHmwaTTi
# BYf2/tRgLC+GeTQD4LEHkwyEXPnk3GzPbrXsCly6C9BoMS4/ZL0Pgmtmd4F/ximl
# F9jwiU2DJBH2bv6d4UgKKKDieySApOzCmgDXsG1szYjVFXjPE/mIpXNNwTYr3MvO
# 23580ovvL72zT006rbtibiiTxAzL2ebK4BEClAOwvT+UKFaQHlPCJ9XJPM0aYx6C
# WRW2QMqngarDVa8z0bV16AnqRwhIIvtdG/Mseml+xddaXlYzPK1X6JMlQsPSXnE7
# ShxU7alVrCgFx8RsXdw8k/ZpPIJRzhoVPV4Bc/9Aouq0rtOO+u5dbEfHQfXUVlfy
# GDcy1tTMS/Zx4HYwggSfMIIDh6ADAgECAhIRIdaZp2SXPvH4Qn7pGcxTQRQwDQYJ
# KoZIhvcNAQEFBQAwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24g
# bnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzIw
# HhcNMTYwNTI0MDAwMDAwWhcNMjcwNjI0MDAwMDAwWjBgMQswCQYDVQQGEwJTRzEf
# MB0GA1UEChMWR01PIEdsb2JhbFNpZ24gUHRlIEx0ZDEwMC4GA1UEAxMnR2xvYmFs
# U2lnbiBUU0EgZm9yIE1TIEF1dGhlbnRpY29kZSAtIEcyMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAsBeuotO2BDBWHlgPse1VpNZUy9j2czrsXV6rJf02
# pfqEw2FAxUa1WVI7QqIuXxNiEKlb5nPWkiWxfSPjBrOHOg5D8NcAiVOiETFSKG5d
# QHI88gl3p0mSl9RskKB2p/243LOd8gdgLE9YmABr0xVU4Prd/4AsXximmP/Uq+yh
# RVmyLm9iXeDZGayLV5yoJivZF6UQ0kcIGnAsM4t/aIAqtaFda92NAgIpA6p8N7u7
# KU49U5OzpvqP0liTFUy5LauAo6Ml+6/3CGSwekQPXBDXX2E3qk5r09JTJZ2Cc/os
# +XKwqRk5KlD6qdA8OsroW+/1X1H0+QrZlzXeaoXmIwRCrwIDAQABo4IBXzCCAVsw
# DgYDVR0PAQH/BAQDAgeAMEwGA1UdIARFMEMwQQYJKwYBBAGgMgEeMDQwMgYIKwYB
# BQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3JlcG9zaXRvcnkvMAkG
# A1UdEwQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwQgYDVR0fBDswOTA3oDWg
# M4YxaHR0cDovL2NybC5nbG9iYWxzaWduLmNvbS9ncy9nc3RpbWVzdGFtcGluZ2cy
# LmNybDBUBggrBgEFBQcBAQRIMEYwRAYIKwYBBQUHMAKGOGh0dHA6Ly9zZWN1cmUu
# Z2xvYmFsc2lnbi5jb20vY2FjZXJ0L2dzdGltZXN0YW1waW5nZzIuY3J0MB0GA1Ud
# DgQWBBTUooRKOFoYf7pPMFC9ndV6h9YJ9zAfBgNVHSMEGDAWgBRG2D7/3OO+/4Pm
# 9IWbsN1q1hSpwTANBgkqhkiG9w0BAQUFAAOCAQEAj6kakW0EpjcgDoOW3iPTa24f
# bt1kPWghIrX4RzZpjuGlRcckoiK3KQnMVFquxrzNY46zPVBI5bTMrs2SjZ4oixNK
# Eaq9o+/Tsjb8tKFyv22XY3mMRLxwL37zvN2CU6sa9uv6HJe8tjecpBwwvKu8LUc2
# 35IgA+hxxlj2dQWaNPALWVqCRDSqgOQvhPZHXZbJtsrKnbemuuRQ09Q3uLogDtDT
# kipbxFm7oW3bPM5EncE4Kq3jjb3NCXcaEL5nCgI2ZIi5sxsm7ueeYMRGqLxhM2zP
# TrmcuWrwnzf+tT1PmtNN/94gjk6Xpv2fCbxNyhh2ybBNhVDygNIdBvVYBAexGDCC
# BNYwggO+oAMCAQICEhEhDRayW4wRltP+V8mGEea62TANBgkqhkiG9w0BAQsFADBa
# MQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTEwMC4GA1UE
# AxMnR2xvYmFsU2lnbiBDb2RlU2lnbmluZyBDQSAtIFNIQTI1NiAtIEcyMB4XDTE1
# MDUwNDE2NDMyMVoXDTE4MDUwNDE2NDMyMVowVTELMAkGA1UEBhMCQ0gxDDAKBgNV
# BAgTA1p1ZzEMMAoGA1UEBxMDWnVnMRQwEgYDVQQKEwtkLWZlbnMgR21iSDEUMBIG
# A1UEAxMLZC1mZW5zIEdtYkgwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDNPSzSNPylU9jFM78Q/GjzB7N+VNqikf/use7p8mpnBZ4cf5b4qV3rqQd62rJH
# RlAsxgouCSNQrl8xxfg6/t/I02kPvrzsR4xnDgMiVCqVRAeQsWebafWdTvWmONBS
# lxJejPP8TSgXMKFaDa+2HleTycTBYSoErAZSWpQ0NqF9zBadjsJRVatQuPkTDrwL
# eWibiyOipK9fcNoQpl5ll5H9EG668YJR3fqX9o0TQTkOmxXIL3IJ0UxdpyDpLEkt
# tBG6Y5wAdpF2dQX2phrfFNVY54JOGtuBkNGMSiLFzTkBA1fOlA6ICMYjB8xIFxVv
# rN1tYojCrqYkKMOjwWQz5X8zAgMBAAGjggGZMIIBlTAOBgNVHQ8BAf8EBAMCB4Aw
# TAYDVR0gBEUwQzBBBgkrBgEEAaAyATIwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93
# d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wCQYDVR0TBAIwADATBgNVHSUE
# DDAKBggrBgEFBQcDAzBCBgNVHR8EOzA5MDegNaAzhjFodHRwOi8vY3JsLmdsb2Jh
# bHNpZ24uY29tL2dzL2dzY29kZXNpZ25zaGEyZzIuY3JsMIGQBggrBgEFBQcBAQSB
# gzCBgDBEBggrBgEFBQcwAoY4aHR0cDovL3NlY3VyZS5nbG9iYWxzaWduLmNvbS9j
# YWNlcnQvZ3Njb2Rlc2lnbnNoYTJnMi5jcnQwOAYIKwYBBQUHMAGGLGh0dHA6Ly9v
# Y3NwMi5nbG9iYWxzaWduLmNvbS9nc2NvZGVzaWduc2hhMmcyMB0GA1UdDgQWBBTN
# GDddiIYZy9p3Z84iSIMd27rtUDAfBgNVHSMEGDAWgBQZSrha5E0xpRTlXuwvoxz6
# gIwyazANBgkqhkiG9w0BAQsFAAOCAQEAAApsOzSX1alF00fTeijB/aIthO3UB0ks
# 1Gg3xoKQC1iEQmFG/qlFLiufs52kRPN7L0a7ClNH3iQpaH5IEaUENT9cNEXdKTBG
# 8OrJS8lrDJXImgNEgtSwz0B40h7bM2Z+0DvXDvpmfyM2NwHF/nNVj7NzmczrLRqN
# 9de3tV0pgRqnIYordVcmb24CZl3bzpwzbQQy14Iz+P5Z2cnw+QaYzAuweTZxEUcJ
# bFwpM49c1LMPFJTuOKkUgY90JJ3gVTpyQxfkc7DNBnx74PlRzjFmeGC/hxQt0hvo
# eaAiBdjo/1uuCTToigVnyRH+c0T2AezTeoFb7ne3I538hWeTdU5q9jGCBLcwggSz
# AgEBMHAwWjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# MDAuBgNVBAMTJ0dsb2JhbFNpZ24gQ29kZVNpZ25pbmcgQ0EgLSBTSEEyNTYgLSBH
# MgISESENFrJbjBGW0/5XyYYR5rrZMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEM
# MQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQB
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRqCcC8rwOBHZlH
# IssLjzXryYaedTANBgkqhkiG9w0BAQEFAASCAQCNP0UbkS9/o6mW7sChGhXQ5voO
# IkNk1BLCvbYp8g1sdv3gbrD4hV4sFL5Y3kYiFgDZlYwsj9+xbht1mtau5L5/6C+Y
# OlQFDd2j1PZg7vHuEO7BC928X7ZY/BIzcOix/nLGr1JA5rhN8zSpvi6nkz1OIXGK
# IN73kbuTQ8EmhbUKs0zA1OyzcDEe6pWzsH/BZ9+odOxGgkRrkZWzOIA/Gu926bMu
# KgLlGq0ecsuGiO/Z/QOvwdr09jSgoiwKEOfNxu3hy9cHizVhwMrYw99ULXQnoCiz
# vhdQ0qA9xTlkJ1UNj3R9Cv7jw494kzH0yuWos2TTFCwgWIbGT16E4a4Bm87WoYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEh1pmnZJc+8fhCfukZzFNBFDAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE2
# MDcyNDIyMzYxNlowIwYJKoZIhvcNAQkEMRYEFDAhncmotE60unrC3eEp66z0/nAI
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUY7gvq2H1g5CWlQULACScUCkz
# 7HkwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# 1pmnZJc+8fhCfukZzFNBFDANBgkqhkiG9w0BAQEFAASCAQAoG3C6fk8Z6PUYV4GZ
# ozVmKu7/vTCL8wBap5eH3KeIDKYGfbHM8MYEvJg/5dQea1V6nQBMffWqqw0v5nL7
# /aLvvtfFhC5LFyArQxHXtS5L/1UTkGbUynoMn0ywAKnkSyIqf1uHfz8FVbvFqwAI
# mGF7M3IhGMUyPpAvUsf7FjDP1UcAB45tEnEZShIWsVGvXfZfMsMoappJU4Nys5pc
# SbXEUOo3MRcwyUkcTvukT8fq7bv+qZJ0yB1/izJNSGCQlp9wrjEpkboW8vh5aCQY
# 8Dj/VlN7/X2Qabv/QjzTniiGhb7Vbw2HmgId5AamzyiffHee1tmTxd8tt3FiFXPO
# Tkru
# SIG # End signature block

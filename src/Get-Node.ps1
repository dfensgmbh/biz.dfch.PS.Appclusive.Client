function Get-Node {
<#
.SYNOPSIS
Retrieves one or more entities from the Node entity set.


.DESCRIPTION
Retrieves one or more entities from the Node entity set.

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
Get-Node -ListAvailable -Select Id, Name

  Id Name
  -- ----
   8  SomeArbitraryNode
  15  SomeOtherNode
  42  TheAnswerToEverythingNode
 667  NeighbourNode

Retrieves the id and name of all Nodes.


.EXAMPLE
Get-Node 218

Parameters     : {"Hostname":"Server01"}
EntityKindId   : 27
ParentId       : 1
Id             : 218
Tid            : 22222222-2222-2222-2222-222222222222
Name           : abhenry
Description    : abhenry is a whiles for timeous purposes
CreatedById    : 1
ModifiedById   : 1
Created        : 15.12.2015 12:06:49 +01:00
Modified       : 15.12.2015 12:06:49 +01:00
RowVersion     : {0, 0, 0, 0...}
Parent         :
EntityKind     :
Children       : {}
IncomingAssocs : {}
OutgoingAssocs : {}
Tenant         :
CreatedBy      :
ModifiedBy     :

Retrieves the Node object with Id 218 and returns all properties of it.


.EXAMPLE
Get-Node 218 -Select Parameters -ValueOnly -ConvertFromJson

Hostname
---
Server01

Similar to the previous example, but only returns the 'Parameters' property 
of it. In addition the contents of the property will be converted from JSON.


.EXAMPLE
Get-Node -ListAvailable -Select Id -First 3

Id
--
218
271
358

Retrieves the id of the first 3 Nodes.


.EXAMPLE
Get-Node 218 -Select Name -ValueOnly

abhenry

Retrieves the name of the Node with Id 218.


.EXAMPLE
Get-Node -ModifiedBy SYSTEM -Select Id, Name

Id Name
-- ----
 1 Root Node
 2 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
 3 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
 4 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
 5 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
 6 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
 7 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
 8 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
 9 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
10 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
11 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
12 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
13 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
14 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
15 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
16 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
17 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
18 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
19 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node
20 biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node

Retrieves id and name of all Nodes that have been modified by user 
with name 'SYSTEM' (case insensitive substring match).


.EXAMPLE
Get-Node AppclusiveScheduler -Select Name -ValueOnly -DefaultValue 'AppclusiveSchedulerNotAvailable'

AppclusiveSchedulerNotAvailable

Retrieves the 'Name' property of a Node with Name 'AppclusiveScheduler' 
and AppclusiveSchedulerNotAvailable if the entity is not found.


.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Get-Node/


.NOTES
See module manifest for required software versions and dependencies.


#>
[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/Get-Node/'
	,
	DefaultParameterSetName = 'list'
)]
PARAM 
(
	# Specifies the id of the entity
	[Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'id')]
	[long] $Id
	,
	# Specifies the name of the entity
	[Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'name')]
	[Alias('n')]
	[string] $Name
	,
	# Filter by creator
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[string] $CreatedBy
	,
	# Filter by modifier
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[string] $ModifiedBy
	,
	# Specifies the Parent id for this entity
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[long] $ParentId
	,
	# Specifies the EntityKind id for this entity
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[long] $EntityKindId
	,
	# Specifies the EntityKind name for this entity
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[string] $EntityKindName
	,
	# Specify the attributes of the entity to return
	[Parameter(Mandatory = $false)]
	[string[]] $Select = @()
	,
	# Specifies to return only values without header information. 
	# This parameter takes precendes over the 'Select' parameter.
	[ValidateScript( { if(1 -eq $Select.Count -And $_) { $true; } else { throw("You must specify exactly one 'Select' property when using 'ValueOnly'."); } } )]
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[Parameter(Mandatory = $false, ParameterSetName = 'id')]
	[Alias('HideTableHeaders')]
	[switch] $ValueOnly
	,
	# This value is only returned if the regular search would have returned no results
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
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
	# Service reference to Appclusive
	[Parameter(Mandatory = $false)]
	[Alias('Services')]
	[hashtable] $svc = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Services
	,
	# Indicates to return all file information
	[Parameter(Mandatory = $false, ParameterSetName = 'list')]
	[switch] $ListAvailable = $false
	,
	# Indicates to return child information
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[Parameter(Mandatory = $false, ParameterSetName = 'id')]
	[Alias('ExpandChildNodes')]
	[switch] $ExpandChildren = $false
	,
	# Indicates to return job information
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[Parameter(Mandatory = $false, ParameterSetName = 'id')]
	[Alias('ExpandStatus')]
	[switch] $ExpandJob = $false
	,
	# Indicates to return available actions information
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[Parameter(Mandatory = $false, ParameterSetName = 'id')]
	[switch] $ExpandAvailableActions = $false
	,
	# Indicates to return externalnodes
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[Parameter(Mandatory = $false, ParameterSetName = 'id')]
	[switch] $ExpandExternalNodes = $false
	,
    # Returns all Connectors which provide this Interface
    [Parameter(Mandatory = $true, ParameterSetName = 'ProvideInterface')]
    [Alias('Provide')]
    [long] $ProvideInterface
    ,
    # Returns all Connectors which require this Interface
	[Parameter(Mandatory = $true, ParameterSetName = 'RequireInterface')]
    [Alias('Require')]
    [long] $RequireInterface
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
	
	$EntitySetName = 'Nodes';
	
	# Parameter validation
	Contract-Requires ($svc.Core -is [biz.dfch.CS.Appclusive.Api.Core.Core]) "Connect to the server before using the Cmdlet";	
	Contract-Requires (1 -ge ($PSBoundParameters.GetEnumerator() | Where { $_.Key -match 'Expand' -and $_.Value -eq $true}).Count) "You can specify only one 'Expand...' param.";
	
	if($Select) 
	{
		$Select = $Select | Select -Unique;
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
		if($PSBoundParameters.ContainsKey('First'))
		{
			$Response = $svc.Core.$EntitySetName.AddQueryOption('$orderby', 'Name').AddQueryOption('$top', $First) | Select;
		}
		else
		{
			$Response = $svc.Core.$EntitySetName.AddQueryOption('$orderby', 'Name') | Select;
		}
		
		if($Select) 
		{
			$Response = $Response | Select -Property $Select;
		}
	}
    elseif($PSCmdlet.ParameterSetName -eq 'RequireInterface') 
	{
        $Response = $svc.Core.InvokeEntitySetActionWithListResult("Nodes", "RequireInterface", [biz.dfch.CS.Appclusive.Api.Core.Node], @{"InterfaceId"=$RequireInterface});

		if($Select) 
		{
			$Response = $Response | Select -Property $Select;
		}
	}
    elseif($PSCmdlet.ParameterSetName -eq 'ProvideInterface') 
	{
        $Response = $svc.Core.InvokeEntitySetActionWithListResult("Nodes", "ProvideInterface", [biz.dfch.CS.Appclusive.Api.Core.Node], @{"InterfaceId"=$ProvideInterface});
        
		if($Select) 
		{
			$Response = $Response | Select -Property $Select;
		}
	} 
	else 
	{
		$Exp = @();
		if($PSCmdlet.ParameterSetName -eq 'id')
		{
			$Exp += ("Id eq {0}L" -f $Id);
		}
		if($Name) 
		{ 
			$Exp += ("tolower(Name) eq '{0}'" -f $Name.ToLower());
		}
		if($ParentId)
		{
			$Exp += ("ParentId eq {0}L" -f $ParentId);
		}
		if($CreatedBy) 
		{ 
			$CreatedById = Get-User -svc $svc $CreatedBy -Select Id -ValueOnly;
			Contract-Assert ( !!$CreatedById ) 'User not found';
			$Exp += ("(CreatedById eq {0}L)" -f $CreatedById);
		}
		if($ModifiedBy)
		{ 
			$ModifiedById = Get-User -svc $svc $ModifiedBy -Select Id -ValueOnly;
			Contract-Assert ( !!$ModifiedById ) 'User not found';
			$Exp += ("(ModifiedById eq {0}L)" -f $ModifiedById);
		}
		if($CreatedBy)
		{ 
			$CreatedById = Get-User -svc $svc $CreatedBy -Select Id -ValueOnly;
			Contract-Assert ( !!$CreatedById ) 'User not found';
			$Exp += ("(CreatedById eq {0})" -f $CreatedById);
		}
		if($EntityKindName)
		{
			$EntityKindId = Get-EntityKind -Name $EntityKindName -svc $svc -Select Id -ValueOnly;
			Contract-Assert ( !!$EntityKindId ) 'EntityKind not found';
		}
		if($EntityKindId)
		{
			$Exp += ("(EntityKindId eq {0}L)" -f $EntityKindId);
		}
		$FilterExpression = [String]::Join(' and ', $Exp);
	
		if($PSBoundParameters.ContainsKey('First'))
		{
			if(!$ExpandChildren)
			{
				$Response = $svc.Core.$EntitySetName.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$top', $First) | Select;
			}
			else
			{
				$Response = $svc.Core.$EntitySetName.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$expand', 'Children').AddQueryOption('$top', $First) | Select;
			}
		}
		else
		{
			if(!$ExpandChildren)
			{
				$Response = $svc.Core.$EntitySetName.AddQueryOption('$filter', $FilterExpression) | Select;
			}
			else
			{
				$Response = $svc.Core.$EntitySetName.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$expand', 'Children') | Select;
			}
		}
	
		if($Select) 
		{
			$Response = $Response | Select -Property $Select;
		}
		else 
		{
			if ( $ExpandJob )
			{
				$ResponseTemp = New-Object System.Collections.ArrayList;
				foreach ($item in $Response)
				{
					if ( $item )
					{
						$Response_ = $svc.Core.InvokeEntityActionWithSingleResult($item, 'Status', [System.Object], $null);
						$null = $ResponseTemp.Add($Response_);
					}
				}
				$Response = $ResponseTemp.ToArray();
			}
			
			if ( $ExpandAvailableActions )
			{
				$ResponseTemp = New-Object System.Collections.ArrayList;
				foreach ($item in $Response)
				{
					if ( $item )
					{
						$Response_ = $svc.Core.InvokeEntityActionWithListResult($item, 'AvailableActions', [string], $null);
						$null = $ResponseTemp.Add($Response_);
					}
				}
				$Response = $ResponseTemp.ToArray();
			}
			
			if ( $ExpandExternalNodes )
			{
				$ResponseTemp = New-Object System.Collections.ArrayList;
				foreach ($item in $Response)
				{
					if ( $item )
					{
						$Response_ = $svc.Core.ExternalNodes.AddQueryOption('$filter', 'NodeId eq {0}' -f $item.Id);
						$null = $ResponseTemp.Add($Response_);
					}
				}
				$Response = $ResponseTemp.ToArray();
			}
		}
		if(1 -eq $Select.Count -And $ValueOnly)
		{
			$Response = $Response.$Select;
		}
		if($PSBoundParameters.ContainsKey('DefaultValue') -And !$Response)
		{
			$Response = $DefaultValue;
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

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Get-Node; } 

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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUCUSmVW62YxBWMP9bVlob5RY/
# cnmgghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQsFaP2JQ8d0jwn
# 96g7q1OQJ5tDHzANBgkqhkiG9w0BAQEFAASCAQCFE2tcV6lvcL+NnQmov+Mf7nIb
# IXCWG+GXLI220rurdfgmhPwKnZZfCXrwNqAyNUqQ3WZFNaSp05wwC6aXouKH8p2j
# 6Z8+nv5Ki+aPkft2pFRsk/eZ8g3LuUbidiyNOFwrNbClSgbndYvVI554txlWwqZT
# v7WxjVjXIJqYS0dISwk5/qo+zaFCu+JeJAcvoQLJbTrVwTzYvoDA9VmUetc7u18U
# /c64EHIf2zU+5HtHp6Yb1XV5Vk7hre7qME5dFYOrBIXGPssiit9HI+fvkFwXBPsr
# xe6gwmB/7OLUxhi1gjfvvP2TYfoKU8jfM795gOzrwU4ljzfdy4gppWnpZZtaoYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEh1pmnZJc+8fhCfukZzFNBFDAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE2
# MDgzMTE5MTY0NVowIwYJKoZIhvcNAQkEMRYEFEhKt8XshwyXAuzEe4bUwcNAffa5
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUY7gvq2H1g5CWlQULACScUCkz
# 7HkwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# 1pmnZJc+8fhCfukZzFNBFDANBgkqhkiG9w0BAQEFAASCAQAyioTNEKyObYoAP3jH
# D8fV/bkkzOstuWMwJGQVNb99pDfV3FyxVGweVYGwbYKUBXPBelS3s60Uxilg10TV
# yeBofgYxwgUEJw89W30IuImDcDo+/IllRu9gyI8MdLMDBT5tAHazyTZl/45NeNbw
# l5mnNgmRq3E/Muught/IZ49Q39nn0X0WSBB9eDAIN18ITiLosydYio1yvmTodSe6
# OCKvC2kW2yP/g0MMbLU3zlasHtNTSsyMYPZRtlm6mX9/qnC4tryeljDL3SPRLqg+
# nGVC7kp3EAtlnZCwNOAAaquYO2CeysEdG+Hsai4ADb96QxxkxwsqTEUoWGI5nyRs
# NXBe
# SIG # End signature block

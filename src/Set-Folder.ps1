function Set-Folder {
<#
.SYNOPSIS

Sets or creates a Folder entry in Appclusive.



.DESCRIPTION

Sets or creates a Folder entry in Appclusive.

By updating a Folder entry you can specify if you want to update the Name, Description or any combination thereof.



.OUTPUTS

default | json | json-pretty | xml | xml-pretty | PSCredential | Clear

.EXAMPLE
Set-Folder -Name TestItem -CreateIfNotExist -svc $svc

EntityId       :
Parameters     : {}
EntityKindId   : 28
ParentId       : 1
Id             : 79560
Tid            : 11111111-1111-1111-1111-111111111111
Name           : TestItem
Description    :
CreatedById    : 1
ModifiedById   : 1
Created        : 08.09.2016 11:33:32 +02:00
Modified       : 08.09.2016 11:33:32 +02:00
RowVersion     : {0, 0, 0, 0...}
EntityKind     :
Parent         :
Children       : {}
IncomingAssocs : {}
OutgoingAssocs : {}
Tenant         :
CreatedBy      :
ModifiedBy     :

Create a new Folder entry if it does not exist.


.EXAMPLE
Set-Folder -Name TestItem -NewName TestItemUpdated -NewDescription DescriptionUpdated -svc $svc 

EntityId       :
Parameters     : {}
EntityKindId   : 28
ParentId       : 1
Id             : 79560
Tid            : 11111111-1111-1111-1111-111111111111
Name           : TestItemUpdated
Description    : DescriptionUpdated
CreatedById    : 1
ModifiedById   : 1
Created        : 08.09.2016 11:33:32 +02:00
Modified       : 08.09.2016 11:33:32 +02:00
RowVersion     : {0, 0, 0, 0...}
EntityKind     :
Parent         :
Children       : {}
IncomingAssocs : {}
OutgoingAssocs : {}
Tenant         :
CreatedBy      :
ModifiedBy     :

Update an existing Folder with new Name and new Description.


.EXAMPLE
Set-Folder -Name $Name -NewName $newName -NewDescription $newDescription -svc $svc 
{
  "Id":  3131,
  "Key":  "myNewKey2",
  "Name":  "myName",
  "Value":  "myNewValue2",
  "CreatedBy":  "SERVER1\\Administrator",
  "Created":  "\/Date(1415920126010)\/",
  "ModifiedBy":  "SERVER1\\Administrator",
  "Modified":  "\/Date(1415920126010)\/",
  "RowVersion":  [
	0,
	0,
	0,
	0,
	0,
	2,
	152,
	17
    ]
}

Update an existing K/N/V with new Name and new Description. Return format is json with pretty-print.

.LINK

Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Set-Folder/


.NOTES

See module manifest for dependencies and further requirements.

#>
[CmdletBinding(
    SupportsShouldProcess = $false
	,
    ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/Set-KeyNameValue/'
)]
Param 
(
	# Specifies the name to modify
	[Parameter(Mandatory = $true, Position = 1)]
	[Alias("n")]
	[string] $Name
	,
	# Specifies the new name
	[Parameter(Mandatory = $false)]
	[string] $NewName
	,
	# Specifies the description to modify
	[Parameter(Mandatory = $false, Position = 2)]
	[Alias('d')]
	[string] $Description
	,
	# Specifies the new description
	[Parameter(Mandatory = $false)]
	[string] $NewDescription
	,
	# Specifies the parent Id for this entity
	[Parameter(Mandatory = $false)]
	[Alias("pid")]
	$ParentId = (Get-ApcTenant -Current -svc $svc).NodeId
	,
	# Specifies the tenant Id for this entity
	[Parameter(Mandatory = $false)]
	[Alias("t")]
	$Tid = (Get-ApcTenant -Current -svc $svc).Id
	,
	# Specifies the parameters for this entity
	[Parameter(Mandatory = $false)]
	[Alias("p")]
	$Parameters = '{}'
	,
	# Specifies to create a folder if it does not exist
	[Parameter(Mandatory = $false)]
	[Alias("c")]
	[switch] $CreateIfNotExist = $false
	,
	# Service reference to Appclusive
	[Parameter(Mandatory = $false)]
	[Alias('Services')]
	[hashtable] $svc = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Services
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
$AddedEntity = $null;

try 
{
	$Exp = @();
	$FolderContents = @();
	if($Name) 
	{ 
		$Exp += ("(tolower(Name) eq '{0}')" -f $Name.ToLower());
		$FolderContents += $Name;
	}
	if($Description) 
	{ 
		$Exp += ("(tolower(Description) eq '{0}')" -f $Description.ToLower());
		$FolderContents += $Description;
	}
	$FilterExpression = [String]::Join(' and ', $Exp);
	$FolderContentsString = [String]::Join(',', $FolderContents);
	
	try
	{
		$folder = $svc.Core.Folders.AddQueryOption('$filter', $FilterExpression).AddQueryOption('$top',1) | Select;
	}
	catch
	{
		$exceptionMsg = $error[0].Exception.InnerException.InnerException.ToString();
		if (!!$exceptionMsg -and $exceptionMsg -match "Http Error 404\.15 - Not Found")
		{
			$queryStringLength = $FilterExpression.Length + '$filter='.Length;
			$msg = "Key/Name/Value: Filter expression to query for existing entity exceeds maxQueryString (Length: '{0}'). To avoid this exception increase the maximum URL length on the IIS server." -f $queryStringLength;
			$e = New-CustomErrorRecord -m $msg -cat LimitsExceeded -o "maxQueryString";
			throw($gotoError);
		}
		
		throw;
	}
	if(!$CreateIfNotExist -And !$folder) #executed if folder doesn't exist > can't be updated
	{
		$msg = "Folder: Parameter validation FAILED. Entity does not exist. Use '-CreateIfNotExist' to create resource: '{0}'" -f $FolderContentsString;
		$e = New-CustomErrorRecord -m $msg -cat ObjectNotFound -o $Name;
		throw($gotoError);
	}
	if(!$folder) #executed when user executes command with -CreateIfNotExist
	{
		$folder = New-Object biz.dfch.CS.Appclusive.Api.Core.Folder;
		$svc.Core.AddToFolders($folder);
		$AddedEntity = $folder;
		$folder.Name = $Name;
		$folder.Description = $Description;
		$folder.EntityKindId = [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::Folder.value__;
		$folder.ParentId = $ParentId;
		$folder.Tid = $Tid;
		$folder.Parameters = $Parameters;
		$folder.Created = [System.DateTimeOffset]::Now;
		$folder.Modified = $folder.Created;
	}
	if($NewName) { $folder.Name = $NewName; }
	if($NewDescription) { $folder.Description = $NewDescription; }
	
	
	$Name = $folder.Name;
	
	$svc.Core.UpdateObject($folder);
	$r = $svc.Core.SaveChanges();
	
	#get folder
	$query = "Name eq '{0}'" -f $Name;
	$folder = $svc.Core.Folders.AddQueryOption('$filter', $query) | Select;
	
	$r = $folder;
	$OutputParameter = Format-ResultAs $r $As;
	$fReturn = $true;

}
catch 
{
	if($gotoSuccess -eq $_.Exception.Message) 
	{
		$fReturn = $true;
	} 
	else 
	{
		[string] $ErrorText = "catch [$($_.FullyQualifiedErrorId)]";
		$ErrorText += (($_ | fl * -Force) | Out-String);
		$ErrorText += (($_.Exception | fl * -Force) | Out-String);
		$ErrorText += (Get-PSCallStack | Out-String);
		
		if($_.Exception -is [System.Net.WebException]) 
		{
			Log-Critical $fn ("[WebException] Request FAILED with Status '{0}'. [{1}]." -f $_.Exception.Status, $_);
			Log-Debug $fn $ErrorText -fac 3;
		}
		else 
		{
			Log-Error $fn $ErrorText -fac 3;
			if($gotoError -eq $_.Exception.Message) 
			{
				Log-Error $fn $e.Exception.Message;
				$PSCmdlet.ThrowTerminatingError($e);
			} 
			elseif($gotoFailure -ne $_.Exception.Message) 
			{ 
				Write-Verbose ("$fn`n$ErrorText"); 
			} 
			else 
			{
				# N/A
			}
		}
		$fReturn = $false;
		$OutputParameter = $null;
		
		if($AddedEntity) 
		{ 
			$svc.Core.DeleteObject($AddedEntity);
			$svc.Core.SaveChanges();
		}
	}
}
finally 
{
	# Clean up
	# N/A
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
if($MyInvocation.ScriptName) { Export-ModuleMember -Function Set-KeyNameValue; } 

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

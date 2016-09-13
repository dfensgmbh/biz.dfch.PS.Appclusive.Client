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
Set-Folder -Name ArbitraryName -CreateIfNotExist -svc $svc

EntityId       :
Parameters     : {}
EntityKindId   : 28
ParentId       : 1
Id             : 79560
Tid            : 11111111-1111-1111-1111-111111111111
Name           : ArbitraryName
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
Set-Folder -Name ArbitraryName -NewName ArbitraryUpdatedName -NewDescription DescriptionUpdated -svc $svc 

EntityId       :
Parameters     : {}
EntityKindId   : 28
ParentId       : 1
Id             : 79560
Tid            : 11111111-1111-1111-1111-111111111111
Name           : ArbitraryUpdatedName
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
Set-Folder -id 79650 -NewName ArbitraryUpdatedName -NewDescription DescriptionUpdated -svc $svc 

EntityId       :
Parameters     : {}
EntityKindId   : 28
ParentId       : 1
Id             : 79560
Tid            : 11111111-1111-1111-1111-111111111111
Name           : ArbitraryUpdatedName
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

Update an existing folder with a new name and description using its Id

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
	# Specifies the id of the entity
	[Parameter(Mandatory = $true, ParameterSetName = 'id')]
	[ValidateRange(1,[long]::MaxValue)]
	[long] $Id = $null
	,
	# Specifies the name to modify
	[Parameter(Mandatory = $true, ParameterSetName = 'name')]
	[ValidateNotNullOrEmpty()]
	[Alias("n")]
	[string] $Name
	,
	# Specifies the new name
	[Parameter(Mandatory = $false, ParameterSetName = 'id')]
	[ValidateNotNullOrEmpty()]
	[string] $NewName
	,
	# Specifies the description to modify
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[Alias('d')]
	[string] $Description
	,
	# Specifies the new description
	[Parameter(Mandatory = $false, ParameterSetName = 'id')]
	[string] $NewDescription
	,
	# Specifies the parent Id for this entity
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[ValidateRange(1,[long]::MaxValue)]
	[Alias("pid")]
	[long] $ParentId = (Get-ApcTenant -Current -svc $svc).NodeId
	,
	# Specifies the parameters for this entity
	[Parameter(Mandatory = $false, ParameterSetName = 'name')]
	[Alias("p")]
	[string] $Parameters = '{}'
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
	#handles creation of folder
	if($PSCmdlet.ParameterSetName -eq 'name')
	{
		$folder = New-Object biz.dfch.CS.Appclusive.Api.Core.Folder;
		$svc.Core.AddToFolders($folder);
		$AddedEntity = $folder;
		if($Name)
		{
			$folder.Name = $Name;
		}
		if ($Description)
		{
			$folder.Description = $Description;
		}
		$folder.EntityKindId = [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::Folder.value__;
		$folder.ParentId = $ParentId;
		if ($Parameters)
		{
			$folder.Parameters = $Parameters;
		}
	}
	#handles update of folder
	elseif($PSCmdlet.ParameterSetName -eq 'id')
	{
		$folder = Get-Folder -svc $svc -id $Id;
		
		Contract-Assert (!!$folder) 'Entity does not exist';
		
		# new values when the folder is to be updated: 
		if($NewName)
		{
			$folder.Name = $NewName;
		}
		if($NewDescription)
		{
			$folder.Description = $NewDescription;
		}
		if($Parameters)
		{
			$folder.Parameters = $Parameters;
		}
	}
	
	$name = $folder.Name;
	
	$svc.Core.UpdateObject($folder);
	$r = $svc.Core.SaveChanges();
	
	#get folder
	$folder = Get-Folder -svc $svc -Name $name;
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
if($MyInvocation.ScriptName) { Export-ModuleMember -Function Set-Folder; } 

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

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "Unrepresentative, because no entities existing.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe "Get-Folder"  -Tags "Get-Folder" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Format-ResultAs.ps1"
	
		Context "Get-Folder" {
        BeforeEach {
            $moduleName = 'biz.dfch.PS.Appclusive.Client';
            Remove-Module $moduleName -ErrorAction:SilentlyContinue;
            Import-Module $moduleName;
            $svc = Enter-Appclusive;
        }
	
		# Context wide constants
		# N/A
		
		It "Warmup" -Test {
			$true | Should Be $true;
		}

		It "Get-FolderListAvailable-ShouldReturnList" -Test {
			# Arrange
			# N/A
			
			# Act
			$result = Get-Folder -svc $svc -ListAvailable;
			if ( $result.Count -eq 0 )
			{
				Stop-Pester
			}
			
			# Assert
			$result | Should Not Be $null;
			$result -is [Array] | Should Be $true;
			0 -lt $result.Count | Should Be $true;
		}
		
		It "Get-FolderListAvailableSelectName-ShouldReturnListWithNamesOnly" -Test {
			# Arrange
			# N/A
			
			# Act
			$result = Get-Folder -svc $svc -ListAvailable -Select Name;
			
			# Assert
			$result | Should Not Be $null;
			$result -is [Array] | Should Be $true;
			0 -lt $result.Count | Should Be $true;
			$result[0].Name | Should Not Be $null;
			$result[0].Id | Should Be $null;
		}
		
		It "Get-Folder-ShouldReturnFirstEntity" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$result = Get-Folder -svc $svc -First $ShowFirst;
			
			# Assert
			$result | Should Not Be $null;
			$result -is [biz.dfch.CS.Appclusive.Api.Core.Folder] | Should Be $true;
		}
		
		It "Get-Folder-ShouldReturnById" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$resultFirst = Get-Folder -svc $svc -First $ShowFirst;
			
			$Id = $resultFirst.Id;
			$result = Get-Folder -Id $Id -svc $svc;
			
			# Assert
			$result | Should Not Be $null;
			$result | Should Be $resultFirst;
			$result.Id | Should Be $resultFirst.Id;
			$result -is [biz.dfch.CS.Appclusive.Api.Core.Folder] | Should Be $true;
		}
		
		It "Get-Folder-ShouldReturnByName" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$resultFirst = Get-Folder -svc $svc -First $ShowFirst;
			
			$Name = $resultFirst.Name;
			$result = Get-Folder -Name $Name -svc $svc | Select -First $ShowFirst;
			
			# Assert
			$result | Should Not Be $null;
			$result | Should Be $resultFirst;
			$result.Name | Should Be $resultFirst.Name;
			$result -is [biz.dfch.CS.Appclusive.Api.Core.Folder] | Should Be $true;
		}
		
		It "Get-Folder-ShouldReturnThreeEntities" -Test {
			# Arrange
			$ShowFirst = 3;
			
			# Act
			$result = Get-Folder -svc $svc -First $ShowFirst;
			
			# Assert
			$result | Should Not Be $null;
			$ShowFirst -eq $result.Count | Should Be $true;
			$result[0] -is [biz.dfch.CS.Appclusive.Api.Core.Folder] | Should Be $true;
		}
		
		It "Get-FolderThatDoesNotExist-ShouldReturnNull" -Test {
			# Arrange
			$JobName = 'Folder-that-does-not-exist';
			
			# Act
			$result = Get-Folder -svc $svc -Name $JobName;
			
			# Assert
			$result | Should Be $null;
		}
		
		
		It "Get-Folder-ShouldReturnXML" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$result = Get-Folder -svc $svc -First $ShowFirst -As xml;
			
			# Assert
			$result | Should Not Be $null;
			$result.Substring(0,5) | Should Be '<?xml';
		}
		
		It "Get-Folder-ShouldReturnJSON" -Test {
			# Arrange
			$ShowFirst = 1;
			
			# Act
			$result = Get-Folder -svc $svc -First $ShowFirst -As json;
			Write-Host ($result | out-string);
			# Assert
			$result | Should Not Be $null;
			$result.Substring(0, 1) | Should Be '{';
			$result.Substring($result.Length -1, 1) | Should Be '}';
		}
		<#
		It "Get-Job-WithInvalidId-ShouldReturnException" -Test {
			# Act
			try 
			{
				$result = Get-Job -Id 'myJob';
				'throw exception' | Should Be $true;
			} 
			catch
			{
				# Assert
			   	$result | Should Be $null;
			}
		}
		
		It "Get-JobByCreatedByThatDoesNotExist-ShouldThrowContractException" -Test {
			# Arrange
			$User = 'User-that-does-not-exist';
			
			# Act
			{ Get-Job -svc $svc -CreatedBy $User; } | Should ThrowErrorId "Contract";

			# Assert
		   	# N/A
		}
		
		It "Get-JobByCreatedBy-ShouldReturnListWithEntities" -Test {
			# Arrange
			$User = 'SYSTEM';
			
			# Act
			$result = Get-Job -svc $svc -CreatedBy $User;

			# Assert
		   	$result | Should Not Be $null;
			0 -lt $result.Count | Should Be $true;
		}
		
		It "Get-JobByModifiedBy-ShouldReturnListWithEntities" -Test {
			# Arrange
			$User = 'SYSTEM';
			
			# Act
			$result = Get-Job -svc $svc -ModifiedBy $User;

			# Assert
		   	$result | Should Not Be $null;
			0 -lt $result.Count | Should Be $true;
		}
		
		It "Get-JobExpandNode-ShouldReturnNode" -Test {
			# Arrange
			. "$here\Get-Node.ps1"
			Mock Get-Node { return New-Object biz.dfch.CS.Appclusive.Api.Core.Node };
			$ShowFirst = 1;
			
			# Act
			$resultFirst = Get-Job -svc $svc -First $ShowFirst;
			$result = Get-Job -svc $svc -Id $resultFirst.Id -ExpandNode;

			# Assert
		   	Assert-MockCalled Get-Node -Exactly 1;
		   	$result | Should Not Be $null;
		   	$result.GetType().Name | Should Be 'Node';
		}#>
	}
}
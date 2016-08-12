
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe "Pop-ChangeTracker" -Tags "Pop-ChangeTracker" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	. "$here\Get-ModuleVariable.ps1"
	. "$here\Push-ChangeTracker.ps1"
	. "$here\Format-ResultAs.ps1"
	
	Context "Pop-ChangeTracker" {
	
		# Context wide constants
		$biz_dfch_PS_Appclusive_Client = @{ };
		Mock Get-ModuleVariable { return $biz_dfch_PS_Appclusive_Client; }
		
		BeforeEach {
			$error.Clear();
			Remove-Module biz.dfch.PS.Appclusive.Client -ErrorAction:SilentlyContinue;
			Import-Module biz.dfch.PS.Appclusive.Client -ErrorAction:SilentlyContinue;
			
			$biz_dfch_PS_Appclusive_Client.DataContext = New-Object System.Collections.Stack;
		}
		
		AfterEach {
			if(0 -ne $error.Count)
			{
				Write-Warning ($error | Out-String);
			}
		}
		
		It "Warmup" -Test {
			$true | Should Be $true;
		}
		
		It "Pop-ChangeTrackerWithNullStack-ThrowsException" -Test {
			# Arrange
			$svc = Enter-ApcServer;

			try
			{
				# Act
				$result = Pop-ChangeTracker -DataContext $null -svc $svc;
				'Statement returned without exception' | Should Be 'An exception should have been thrown';
			}
			catch
			{
				# Assert
				$error[0].Exception.Message -match "Cannot validate argument on parameter 'DataContext'." | Should Be $true;
				$error.Clear();
			}
		}

		It "Pop-ChangeTrackerWithEmptyStack-ThrowsException" -Test {
			# Arrange
			$svc = Enter-ApcServer;
			$stack = @{};

			try
			{
				# Act
				$result = Pop-ChangeTracker -DataContext $stack -svc $svc;
				'Statement returned without exception' | Should Be 'An exception should have been thrown';
			}
			catch
			{
				# Assert
				$error[0].Exception.Message -match "Cannot validate argument on parameter 'DataContext'." | Should Be $true;
				$error.Clear();
			}
		}

		It "Pop-ChangeTrackerWithEmptyHashtable-ClearsChangeTracker" -Test {
			# Arrange
			$svc = Enter-ApcServer;
			$stack = @{};
			$stack.Entities = New-Object System.Collections.ArrayList;
			$stack.Links = New-Object System.Collections.ArrayList;

			# Act
			$result = Pop-ChangeTracker -DataContext $stack -svc $svc;

			# Assert
			Assert-MockCalled Get-ModuleVariable;
			$result | Should Be $true;
			$biz_dfch_PS_Appclusive_Client.ContainsKey('DataContext') | Should Be $true;
			$biz_dfch_PS_Appclusive_Client.DataContext.Count | Should Be 0;
		}

		It "Pop-ChangeTrackerReinitialised-HasNoDataContext" -Test {
			# Arrange
			$svc = Enter-ApcServer;

			# Act and Assert
			Assert-MockCalled Get-ModuleVariable;
			$biz_dfch_PS_Appclusive_Client.ContainsKey('DataContext') | Should Be $true;
			$biz_dfch_PS_Appclusive_Client.DataContext.Count | Should Be 0;
		}
		
		It "Pop-ChangeTrackerReinitialised-PushAndPopHasNoDataContext" -Test {
			# Arrange
			$svc = Enter-ApcServer;
			$count = 2;
			$endpoints = $svc.Diagnostics.Endpoints | Select -First $count;

			# Act
			$result = Push-ChangeTracker -svc $svc;
			$DataContext = $biz_dfch_PS_Appclusive_Client.DataContext.Pop();
			$result = Pop-ChangeTracker -DataContext $DataContext -svc $svc;

			# Assert
			Assert-MockCalled Get-ModuleVariable;
			$biz_dfch_PS_Appclusive_Client.ContainsKey('DataContext') | Should Be $true;
			$biz_dfch_PS_Appclusive_Client.DataContext.Count | Should Be 0;
			
			$svc.Diagnostics.Entities.Count | Should Be $count;
		}

		It "Pop-ChangeTrackerClear-Succeeds" -Test {
			# Arrange
			$svc = Enter-ApcServer;
			$count = 2;
			$endpoints = $svc.Diagnostics.Endpoints | Select -First $count;

			foreach($e in $svc.Diagnostics.Entities)
			{
				$e.State | Should Be 'Unchanged';
			}
			
			foreach($endpoint in $endpoints)
			{
				$endpoint.Description = 'arbitrary-contents';
			}

			# Act
			$result = Push-ChangeTracker -svc $svc;
			$DataContext = $biz_dfch_PS_Appclusive_Client.DataContext.Pop();
			$result = Pop-ChangeTracker -DataContext $DataContext -svc $svc -Clear;

			# Assert
			Assert-MockCalled Get-ModuleVariable;
			$biz_dfch_PS_Appclusive_Client.ContainsKey('DataContext') | Should Be $true;
			$biz_dfch_PS_Appclusive_Client.DataContext.Count | Should Be 0;
			
			$svc.Diagnostics.Entities.Count | Should Be $count;
			foreach($e in $svc.Diagnostics.Entities)
			{
				$e.State | Should Be 'Unchanged';
				try
				{
					$svc.Diagnostics.UpdateObject($e);
					'Statement returned without exception' | Should Be 'An exception should have been thrown';
				}
				catch
				{
					# Assert
					$error[0].Exception.Message -match "The context is not currently tracking the entity." | Should Be $true;
				}
			}
			$error.Clear();
		}
	}
}

#
# Copyright 2015 d-fens GmbH
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
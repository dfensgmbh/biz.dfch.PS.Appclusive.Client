
function Get-Parameters{
	Param
	(
		$Name = $entityPrefix + "VM"
		,
		$OpSystem = "SPMI-2015.6"
		,
		$Hostname = $Name
		,
		$MemorySize = "4096"
		,
		$TemplateId = "SPMT-2015.1"
	)
	
	$parameters = '{
		"biz":{
			"dfch":{
				"Appclusive":{
					"Products":{
						"Infrastructure":{
							"VirtualMachine":{
								"Name":"' + $Name + '",
								"Description":"",
								"OperatingSystem":"' + $OpSystem + '",
								"Hostname":"' + $Hostname + '",
								"BackupProfile":{"Name":"no_backup"},
								"StorageProfile":{"Name":"economy_singlesided"},
								"Storage":{"DiskCollection":{"Disk00":{"Name":"System","Description":"Boot Disk","SizeGB":60,
								"StorageProfile":"economy_singlesided"}}},
								"Network":{
									"NicCollection":{
										"Nic00":{
											"NetworkId":"https://cloud-api.media.int/v1/cimi/2/networks/5b98b6df-8a8e-48b4-a33a-b09d4a0c0475","Address":"0.0.0.0"
										}
									}
								},
								"Cpu":{"Count":4,
								"Speed":1.6,
								"Reservation":0},
								"Memory":{
									"Size":' + $MemorySize + ',
									"Reservation":0
								}
							},
							"VirtualMachineExtensions":{
								"Cimi":{
									"TemplateId":"' + $TemplateId + '",
									"OperatingSystemPassword":"Test1234",
									"Availability":"high",
									"HostGroup":"none",
									"HostingCell":"cell_a"
								}
							}
						}
					}
				}
			}
		}
	}';
	
	return $parameters
}
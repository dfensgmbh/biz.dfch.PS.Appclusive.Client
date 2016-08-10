function Create-Node {
	Param
	(
		$svc
		,
		$Name
	)
	
	$nodeDescr = "this is a test node";
	$nodeParentId = 1680;
	
	#ACT create Node
	$node = New-Object biz.dfch.CS.Appclusive.Api.Core.Node;
	
	#add parameters
	$node.Name = $Name;
	$node.Description = $nodeDescr;
	$node.ParentId = $nodeParentId;
	$node.EntityKindId = 1;
	$node.Parameters = '{}';
	$node.Tid = "11111111-1111-1111-1111-111111111111";
	$svc.Core.AddToNodes($node);
	$result = $svc.Core.SaveChanges();
	
	#get the node
	$query = "Name eq '{0}' and ParentId eq {1}" -f $Name, $nodeParentId;
	$newNode = $svc.Core.Nodes.AddQueryOption('$filter', $query) | select;
	
	#ASSERT node
	$bin = $newNode | Should Not Be $null;
	$bin = $newNode.Id | Should Not Be $null;
	
	return $newNode;
}

function Delete-Node {
	Param
	(
		$svc
		,
		$nodeId
	)
	
	#get the node
	$query = "Id eq {0}" -f $nodeId;
	$node = $svc.Core.Nodes.AddQueryOption('$filter', $query) | select;
	
	#delete the node
	$svc.Core.DeleteObject($node);
	$result = $svc.Core.SaveChanges();
	
	#get the node
	$query = "Id eq {0}" -f $nodeId;
	$deletedNode = $svc.Core.Nodes.AddQueryOption('$filter', $query) | select;
	
	#ASSERT that catalogue is deleted
	$bin = $deletedNode | Should Be $null;
}
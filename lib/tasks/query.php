<?php
	require $argv[1] . "GameQ.php";

	$gq = new GameQ();
	$gq->addServer(array(
	    'id' => 'my_server',
	    'type' => $argv[2], // Counter-Strike: Source
	    'host' => $argv[3],
	));

	$results = $gq->requestData(); // Returns an array of results
	$my_server = $results['my_server'];

	print_r($my_server);
?>
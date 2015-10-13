<?php
// Include the main class file
	require $argv[1] . "GameQ.php";

	$host = $argv[2];
	$name = $argv[3];
	$user = $argv[4];
	$pass = $argv[5];

	$dbconn = pg_connect("host=$host dbname=$name user=$user password=$pass") or die('Could not connect: ' . pg_last_error());
	pg_set_client_encoding($dbconn, "UNICODE");

	$query = 'SELECT protocol FROM protocols';
	$result = pg_query($query) or die('Query failed: ' . pg_last_error());

	$current = array(); 

	while ($line = pg_fetch_row($result)) {
		if ($line[0] != null) {
			array_push($current, $line[0]);
    	}
	}

	// Free resultset
	pg_free_result($result);


	// Define the protocols path
	$protocols_path = $argv[1] . "gameq/protocols/";

	// Grab the dir with all the classes available
	$dir = dir($protocols_path);

	$protocols = array();

	// Now lets loop the directories
	while (false !== ($entry = $dir->read()))
	{
		if(!is_file($protocols_path.$entry))
		{
			continue;
		}

		// Figure out the class name
		$class_name = 'GameQ_Protocols_'.ucfirst(pathinfo($entry, PATHINFO_FILENAME));

		// Lets get some info on the class
		$reflection = new ReflectionClass($class_name);

		// Check to make sure we can actually load the class
		if(!$reflection->IsInstantiable())
		{
			continue;
		}

		// Load up the class so we can get info
		$class = new $class_name;

		// Add it to the list
		$protocols[$class->name()] = array(
			'name' => $class->name_long(),
			'port' => $class->port(),
			'state' => $class->state(),
		);

		// Unset the class
		unset($class);
	}

	// Close the directory
	unset($dir);

	ksort($protocols);

	$i = 0;
	foreach ($protocols AS $gameq => $info)
	{
		if (in_array($gameq, $current)) {
			
		}
			else {
			echo "adding " . $gameq . ".\n";

			$result = pg_query_params($dbconn, "INSERT INTO protocols (protocol, name, created_at, updated_at) VALUES ($1,$2,NOW(),NOW())", array($gameq, $info['name']));
			pg_free_result($result);
			$i++;
		}
	}

	// Closing connection
	pg_close($dbconn);
	echo "Added " . $i . " protocols.\n";
?>
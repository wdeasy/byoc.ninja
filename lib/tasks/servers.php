<?php
	require $argv[1] . "GameQ.php";

	$host = $argv[2];
	$name = $argv[3];
	$user = $argv[4];
	$pass = $argv[5];

	$dbconn = pg_connect("host=$host dbname=$name user=$user password=$pass") or die('Could not connect: ' . pg_last_error());
	pg_set_client_encoding($dbconn, "UNICODE");

	$query = "SELECT g.protocol, s.gameserverip, s.ip, s.query_port, s.auto_update, s.name, s.current, s.max, s.map, s.password, s.last_successful_query, p.host, p.map, p.num, p.max, p.pass FROM servers s JOIN games g on g.gameid = s.gameid JOIN protocols p on p.protocol = g.protocol WHERE s.updated IS TRUE AND s.banned IS FALSE AND s.query_port IS NOT NULL AND s.network <> 'byoc'";
	$result = pg_query($query) or die('Query failed: ' . pg_last_error());

	while ($line = pg_fetch_row($result)) {
		if ($line[0] != null) {
			queryServer($line[0],$line[1],$line[2],$line[3],$line[4],$line[5],$line[6],$line[7],$line[8],$line[9],$line[10],$line[11],$line[12],$line[13],$line[14],$line[15],$dbconn);		
    }
	}

	// Free resultset
	pg_free_result($result);

	// Closing connection
	pg_close($dbconn);

	function queryServer($game,$gameserverip,$ip,$port,$auto,$name,$current,$max,$map,$pass,$last,$h,$m,$n,$x,$p,$dbconn) {
		$gq = new GameQ();
		$gq->addServer(array(
    		'id' => 'my_server',
    		'type' => $game,
    		'host' => $ip . ":" . $port
		));

		$results = $gq->requestData();
		$my_server = $results['my_server'];	

		$respond		= $my_server['gq_online'] == 1 ? 1 : 0;


		if ($my_server['gq_online'] == 1) {
			$last = date('Y-m-d H:i:s', strtotime("now"));
		}

		$hostname 		= isset($my_server[$h]) ? trim(trim($my_server[$h], chr(0xC2).chr(0xA0))) : $name;
		$mapname		  = isset($my_server[$m]) ? $my_server[$m] : $map;
		$num_players	= isset($my_server[$n]) ? $my_server[$n] : $current;
		$max_players	= isset($my_server[$x]) ? $my_server[$x] : $max;
		$password		  = isset($my_server[$p]) ? $my_server[$p] : $pass;

		if ($last < date('Y-m-d H:i:s', strtotime("-1 hour"))) {
			$hostname 		= null;
			$mapname		  = null;
			$num_players	= null;
			$max_players	= null;
			$password		  = null;			
		}

		if ($auto == 't') {
			$result = pg_query_params($dbconn, 'UPDATE servers SET name = $1, map = $2, current = $3, max = $4, password = $5, respond = $6, last_successful_query = $7 WHERE gameserverip = $8', array($hostname,$mapname,$num_players,$max_players,$password,$respond,$last,$gameserverip));				
		} else {
			$result = pg_query_params($dbconn, 'UPDATE servers SET current = $1, max = $2, password = $3, respond = $4, last_successful_query = $5 WHERE gameserverip = $6', array($num_players,$max_players,$password,$respond,$last,$gameserverip));					
		}
		pg_free_result($result);
	}
?>
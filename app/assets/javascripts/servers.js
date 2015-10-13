function executeQuery() {
  $('#servers').load('/servers/servers #servers', function() {
  	$('.dropdown-toggle').dropdown();
  });
  setTimeout(executeQuery, 60000);
}
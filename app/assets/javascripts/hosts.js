function executeQuery() {
  $('#hosts').load('/hosts #hosts', function() {
  	$('.dropdown-toggle').dropdown();
  });
  setTimeout(executeQuery, 60000);
}
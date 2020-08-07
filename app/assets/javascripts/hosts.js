function executeQuery() {
  $('#hosts').load('/hosts #hosts', function() {
  	$('.dropdown-toggle').dropdown();
    console.log("Refreshing Server List");
  });
  setTimeout(executeQuery, 60000);
}

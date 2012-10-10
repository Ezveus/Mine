$(function() {
    $('#send').click(function() {
	var name = $('#name').val();
	$('#name').val('');
	var pass = $('#pass').val();
	$('#pass').val('');
	alert(name + ' : ' + pass + ' were sent');
    });
    $(document).keydown(function(e) {
	$('#char').text(e.which);
	if (e.which == 191 || e.which == 190) {
	    e.preventDefault();
	}
    });
});

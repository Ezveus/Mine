$(function() {
    $('#send').click(function() {
	var name = $('#name').val();
	$('#name').val('');
	var pass = $('#pass').val();
	$('#pass').val('');
	alert(name + ' : ' + pass + ' were sent');
    })
});

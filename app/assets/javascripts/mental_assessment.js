(function($) {
	$(document).ready(function(){
		$('#tab_cp_mental_wellbeing_assessment_scale select').each(function(){
    var elem = $(this).closest('.row').next();
    var elemText = $(elem).find('label:first-child').text();
    if(elemText == "Severity"){
        $(elem).hide();
			}
    });
    $('#tab_cp_mental_wellbeing_assessment_scale').delegate("select","change", function(e) {
     var elemId = e.target.id;
     var selectText = $('#' + elemId).find(":selected").text();
     var severElem = $(this).closest('.row').next();
      
    if(selectText == 'Severity 1-5'){
        severElem.show();
			}else{
        severElem.hide();
			}
		});
	});
})(jQuery);


$(document).ready(function(){
	$("#cell_activity_child_location").closest('.row').nextAll().hide() ;
	
	$('#cell_activity_child_location').change(function () {
		displayDefault();
	});

	function displayDefault(){
	var location = 0;
	setTimeout(function () {
		var locationVal = $('#cell_activity_child_location').find(":selected").text().toLowerCase();
		var mainElem = $('#cell_activity_child_location').closest('fieldset');
		location = $('#cell_activity_child_location').find(":selected").index();
	
		if (location > 0) {
	    		$("#cell_activity_child_district_chosen").closest('.row').show();
	    		$("#cell_activity_child_collateral_visits_chosen").closest('.row').show();
	    		$("#cell_activity_child_programme_participationorganisationfacilitation_chosen").closest('.row').show();
		} else {
			$("#cell_activity_child_district_chosen").closest('.row').hide();
			$("#cell_activity_child_collateral_visits_chosen").closest('.row').hide();
			$("#cell_activity_child_programme_participationorganisationfacilitation_chosen").closest('.row').hide();
		}
	}, 500);
	return location;	
}

    
});


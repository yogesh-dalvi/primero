
$(document).ready(function(){
	$("#cell_activity_child_location").closest('.row').nextAll().hide() ;
	displayDefault();

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
	    		$("#cell_activity_child_district").closest('.row').show();
	    		$("#cell_activity_child_collateral_visits").closest('.row').show();
				$("#cell_activity_child_programme_participationorganisationfacilitation").closest('.row').show();
				$('#' + mainElem.attr('id') + ' select').each(function(){
					if($(this).attr('id').indexOf("ongoing_client_child_") == -1){
						displayHideDropDownFields($(this), mainElem);
					}
				});
		} else {
			$("#cell_activity_child_district").closest('.row').hide();
			$("#cell_activity_child_collateral_visits").closest('.row').hide();
			$("#cell_activity_child_programme_participationorganisationfacilitation").closest('.row').hide();
		}
	}, 500);
	return location;	
}
});

$(document).ready(function(){
	$("#cell_activity__child_location").closest('.row').nextAll().hide() ;
	displayDefault();

	$('#cell_activity__child_location').change(function () {
		displayDefault();
	});


	function displayDefault(){
	var location = 0;
	setTimeout(function () {
		var locationVal = $('#cell_activity__child_location').find(":selected").text().toLowerCase();
		var mainElem = $('#cell_activity__child_location').closest('fieldset');
		location = $('#cell_activity__child_location').find(":selected").index();
		
		if (location > 0) {
	    		$("#cell_activity__child_district").closest('.row').show();
	    		$("#cell_activity__child_collateral_visits").closest('.row').show();
				$("#cell_activity__child_programme_participationorganisationfacilitation").closest('.row').show();
				$('#' + mainElem.attr('id') + ' select').each(function(){
					if($(this).attr('id').indexOf("ongoing_client_child_") == -1){
						displayHideDropDownFields($(this), mainElem);
					}
				});
		} else {
			$("#cell_activity__child_district").closest('.row').hide();
			$("#cell_activity__child_collateral_visits").closest('.row').hide();
			$("#cell_activity__child_programme_participationorganisationfacilitation").closest('.row').hide();
		}
	}, 500);
	return location;	
}
});


$(document).ready(function(){
	$("#record_case_data_child_location_chosen").closest('.row').nextAll().hide() ;
	var defaultIndex = displayDefault();
	if(defaultIndex > 0){
		$('#tab_cp_case_intake_form select').each(function(){
			displayHideDropDownFields($(this));
		});
	}
	
	$('#record_case_data_child_location').change(function () {
		displayDefault();
	});
	
	$('body').delegate("select", "change", function (e) {		
		displayHideDropDownFields($(this));
	});
    
});

function displayDefault(){
	var location = 0;
	
	setTimeout(function () {
		location = $('#record_case_data_child_location').find(":selected").index();		
		if (location > 0) {
			$("#record_case_data_child_district_chosen").closest('.row').show();
			$("#record_case_data_child_register_client_chosen").closest('.row').show();
			$("#record_case_data_child_clients_referred_by_chosen").closest('.row').show();
			$("#record_case_data_child_sex_chosen").closest('.row').show();
			$("#record_case_data_child_age").closest('.row').show();
			$("#record_case_data_child_education_of_the_client_chosen").closest('.row').show();
			$("#record_case_data_child_reasons_for_registering_at_special_cell__chosen").closest('.row').show();
			$("#record_case_data_child_previous_intervention_before_coming_to_the_cell__chosen").closest('.row').show();
			$("#record_case_data_child_nature_of_interaction").closest('.row').show();
			$("#record_case_data_child_intervention_by_special_cell__chosen").closest('.row').show();
			$("#record_case_data_child_referrals_new_clients_ongoing_clients__chosen").closest('.row').show();
			$('#record_case_data_child_other_interventions_taking_place_outside_the_cell_chosen').closest('.row').show();
			$("#record_case_data_child_outcomes_new_clients_ongoing_clients_chosen").closest('.row').show();
			$("#record_case_data_child_programme_participationorganisationfacilitation").closest('.row').show();
		} else {
			$("#record_case_data_child_district_chosen").closest('.row').hide();
			$("#record_case_data_child_register_client_chosen").closest('.row').hide();
			$("#record_case_data_child_clients_referred_by_chosen").closest('.row').hide();
			$("#record_case_data_child_sex_chosen").closest('.row').hide();
			$("#record_case_data_child_age").closest('.row').hide();
			$("#record_case_data_child_education_of_the_client_chosen").closest('.row').hide();
			$("#record_case_data_child_reasons_for_registering_at_special_cell__chosen").closest('.row').hide();
			$("#record_case_data_child_previous_intervention_before_coming_to_the_cell__chosen").closest('.row').hide();
			$("#record_case_data_child_nature_of_interaction").closest('.row').hide();
			$("#record_case_data_child_intervention_by_special_cell__chosen").closest('.row').hide();
			$("#record_case_data_child_referrals_new_clients_ongoing_clients__chosen").closest('.row').hide();
			$('#record_case_data_child_other_interventions_taking_place_outside_the_cell_chosen').closest('.row').hide();
			$("#record_case_data_child_outcomes_new_clients_ongoing_clients_chosen").closest('.row').hide();
			$("#record_case_data_child_programme_participationorganisationfacilitation").closest('.row').hide();
		}
	}, 500);
	return location;	
}

function displayHideDropDownFields(element){	
	
	var elemId = $(element).attr('id');
	var selectText = $('#' + elemId).find(":selected").text();
	var otherSpecifyElem = $(element).closest('.row').next();
	

	var urarr = [];
	
	$("#" +elemId+">option:gt(0)").each(function () {
		urarr.push($(this).text())
	});
	
	

	if (!$(element).prop('multiple')) {		
		if (selectText == 'Others specify') {			
			$(otherSpecifyElem).show();
			
			$("label").each(function () {
				var labelText = $(this).text();
				var otherElemLabelText = $(this).closest('.row').next().find('label').text();
				if (jQuery.inArray(labelText, urarr) != -1) {
					if (otherElemLabelText == 'If Other, Specify') {
						$(this).closest('.row').next().hide();
					}
					$(this).closest('.row').hide();
				}
			});
		} else {			
			var elemLabelText = $(otherSpecifyElem).find('label').text();
			if (elemLabelText == 'If Other, Specify') {
				if ($(otherSpecifyElem).css('display') == 'flex') {
					$(otherSpecifyElem).hide();
				}
			}

			$("label").each(function () {
				var labelText = $(this).text();
				var otherElemLabelText = $(this).closest('.row').next().find('label').text();
				if (selectText == labelText) {
					$(this).closest('.row').show();
				} else if (selectText != labelText && jQuery.inArray(labelText, urarr) != -1) {
					
					if (otherElemLabelText == 'If Other, Specify') {
						$(this).closest('.row').next().hide();
					}
					$(this).closest('.row').hide();
				}

			});
		}
	} else {
		var chosenElemId = '#' + elemId + '_chosen';
		var chosenElem = $(chosenElemId).find('.search-choice span').map(function () {
			return $(this).text();
		}).get();

		setTimeout(function () {
			var chosenElems = $(chosenElemId).find('.search-choice span').map(function () {
				return $(this).text();
			}).get();

			if (chosenElems == '') {
				$("label").each(function () {
					var labelText = $(this).text();
					if (jQuery.inArray(labelText, urarr) != -1 || jQuery.inArray(labelText, chosenElem) != -1) {
						$(this).closest('.row').hide();
					} else if (labelText == 'If Other, Specify') {
						$(otherSpecifyElem).hide();
					}
				});

			} else {
				$(chosenElem).each(function (i, val) {					
					if (val == 'Others specify') {
						if (jQuery.inArray(val, chosenElems) != -1) {
							$(otherSpecifyElem).show();
						} else {
							$(otherSpecifyElem).hide();
						}
					} else {
						$("label").each(function () {
							var labelText = $(this).text();
							if (val == labelText) {
								if (jQuery.inArray(labelText, chosenElems) != -1) {
									$(this).closest('.row').show();
								} else {
									$(this).closest('.row').hide();
								}
							}
						});
					}

				});

			};
		}, 500);

	}
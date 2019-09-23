$(document).ready(function(){
	$("#record_case_data_child_location").closest('.row').nextAll().hide() ;
	displayDefault(false);
		
	$('#record_case_data_child_location').change(function () {
		displayDefault(true);
	});
	
	$('body').delegate("select", "change", function (e) {
		var mainElem = $(this).closest('fieldset');
		displayHideDropDownFields($(this), mainElem);
	});
	
	$('#record_case_data_child_ongoing_clients').change(function(){
		var mainElem = $(this).closest('fieldset');
		var locationVal = $('#record_case_data_child_location').find(":selected").text().toLowerCase();	
		if($("#record_case_data_child_ongoing_clients").is(':checked')){
			$("#record_case_data_child_location").closest('.row').hide().nextAll().hide() ;
			$("#record_case_data_child_ongoing_clients").closest('.row').show();
			$('#cp_case_intake_'+ locationVal +'_subform_ongoing_client').closest('.row').show();
		}else{
			defaultElements();
			$('#' + mainElem.attr('id') + ' select').each(function(){
				displayHideDropDownFields($(this), mainElem);
			});
			$('#cp_case_intake_'+ locationVal +'_subform_ongoing_client').closest('.row').hide();
		}
	});
	
	$('body').delegate(".collapse_expand_subform","click", function(e) {
		var subformElem = $(this).closest('.subform_container');
		var subform = $(this).closest('.subform_container').attr('id');
		var expanded = $(this).hasClass('expanded');	
		if(expanded){
			$('#' + subform + ' div.row').each(function(){
				if(!$(this).hasClass('collapse_expand_subform_header')){
					$(this).hide();
				}
			})
			$("#ongoing_client_child_" + subform.substring(18, subform.length) + "_ongoing_followup").closest('.row').show();
			$("#ongoing_client_child_" + subform.substring(18, subform.length) + "_nature_of_interaction").closest('.row').show();
			$("#ongoing_client_child_" + subform.substring(18, subform.length) + "_intervention_by_special_cell_").closest('.row').show();
			$("#ongoing_client_child_" + subform.substring(18, subform.length) + "_referrals_new_clients_ongoing_clients_").closest('.row').show();
			$("#ongoing_client_child_" + subform.substring(18, subform.length) + "_other_interventions_taking_place_outside_the_cell").closest('.row').show();
			$("#ongoing_client_child_" + subform.substring(18, subform.length) + "_outcomes_new_clients_ongoing_clients").closest('.row').show();
			
			$('#' + subform + ' select').each(function(){
				displayHideDropDownFields($(this), subformElem);
			});
		}else{
			$('#' + subform + ' div.row').each(function(){
				if(!$(this).hasClass('collapse_expand_subform_header')){
					$(this).hide();
				}
			})
		}
	});
	
	$('body').delegate("a:contains('Add')","click", function(e) {
		var subform = $(this).closest('.row').find('div:first').attr('id');
		setTimeout(function(){		
			var elemId = $('#' + subform).children().last().attr('id');			
			$("#" + elemId + " fieldset label").each(function(){
				if($(this).text() == "Ongoing Followup"){
					$(this).closest('.row').nextAll().hide();			
					return false;
				}
			});		
			
			$("#ongoing_client_child_" + elemId.substring(18, elemId.length) + "_nature_of_interaction").closest('.row').show();
			$("#ongoing_client_child_" + elemId.substring(18, elemId.length) + "_intervention_by_special_cell_").closest('.row').show();
			$("#ongoing_client_child_" + elemId.substring(18, elemId.length) + "_referrals_new_clients_ongoing_clients_").closest('.row').show();
			$("#ongoing_client_child_" + elemId.substring(18, elemId.length) + "_other_interventions_taking_place_outside_the_cell").closest('.row').show();
			$("#ongoing_client_child_" + elemId.substring(18, elemId.length) + "_outcomes_new_clients_ongoing_clients").closest('.row').show();
		}, 100);
		
	});
    
});

function displayDefault(fromChangeEvent){
	var location = 0;
	var client = 0;
	setTimeout(function () {
		var locationVal = $('#record_case_data_child_location').find(":selected").text().toLowerCase();	
		var mainElem = $('#record_case_data_child_location').closest('fieldset');
		location = $('#record_case_data_child_location').find(":selected").index();
		client = $('#record_case_data_child_register_client').find(":selected").index();
		
		if (location > 0) {
			if(client > 0 && !fromChangeEvent){
				$("#record_case_data_child_ongoing_clients").closest('.row').show();	
				if($("#record_case_data_child_ongoing_clients").is(':checked')){
					$("#record_case_data_child_location").closest('.row').hide().nextAll().hide() ;
					$("#record_case_data_child_ongoing_clients").closest('.row').show();
					$('#cp_case_intake_'+ locationVal +'_subform_ongoing_client').closest('.row').show();
				}else{
					defaultElements();
					$('#' + mainElem.attr('id') + ' select').each(function(){
						displayHideDropDownFields($(this), '#' + mainElem);
					});
					$('#cp_case_intake_'+ locationVal +'_subform_ongoing_client').closest('.row').hide();
				}
			}else{
				
				defaultElements();
				$("#record_case_data_child_ongoing_clients").closest('.row').hide();		
			}		
			
		} else {
			$("#record_case_data_child_district").closest('.row').hide();
			$("#record_case_data_child_register_client").closest('.row').hide();
			$("#record_case_data_child_clients_referred_by").closest('.row').hide();
			$("#record_case_data_child_sex").closest('.row').hide();
			$("#record_case_data_child_age").closest('.row').hide();
			
			$("#record_case_data_child_education_of_the_client").closest('.row').hide();
			$("#record_case_data_child_reasons_for_registering_at_special_cell_").closest('.row').hide();
			$("#record_case_data_child_previous_intervention_before_coming_to_the_cell_").closest('.row').hide();
			$("#record_case_data_child_nature_of_interaction").closest('.row').hide();
			$("#record_case_data_child_intervention_by_special_cell_").closest('.row').hide();
			$("#record_case_data_child_referrals_new_clients_ongoing_clients_").closest('.row').hide();
			$('#record_case_data_child_other_interventions_taking_place_outside_the_cell').closest('.row').hide();
			$("#record_case_data_child_outcomes_new_clients_ongoing_clients").closest('.row').hide();
			$("#record_case_data_child_programme_participationorganisationfacilitation").closest('.row').hide();
		}
	}, 500);
	return location;	
}
function defaultElements(){
	$("#record_case_data_child_location").closest('.row').show()
	$("#record_case_data_child_district").closest('.row').show();
	$("#record_case_data_child_register_client").closest('.row').show();
	$("#record_case_data_child_clients_referred_by").closest('.row').show();
	$("#record_case_data_child_sex").closest('.row').show();
	$("#record_case_data_child_age").closest('.row').show();
	$("#record_case_data_child_education_of_the_client").closest('.row').show();
	$("#record_case_data_child_reasons_for_registering_at_special_cell_").closest('.row').show();
	$("#record_case_data_child_previous_intervention_before_coming_to_the_cell_").closest('.row').show();
	$("#record_case_data_child_nature_of_interaction").closest('.row').show();
	$("#record_case_data_child_intervention_by_special_cell_").closest('.row').show();
	$("#record_case_data_child_referrals_new_clients_ongoing_clients_").closest('.row').show();
	$('#record_case_data_child_other_interventions_taking_place_outside_the_cell').closest('.row').show();
	$("#record_case_data_child_outcomes_new_clients_ongoing_clients").closest('.row').show();
	$("#record_case_data_child_programme_participationorganisationfacilitation").closest('.row').show();
}

function displayHideDropDownFields(element,mainElement){	
	
	var divRowArr = [];
	if(mainElement.attr('id').includes('subform')){
		divRowArr = $('#' + mainElement.attr('id') + ' div.row');
	}else{
		divRowArr = $('#' + mainElement.attr('id') + ' > div.row:not(:has("fieldset"))');
	}
	
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
			
			$(divRowArr).find('label').each(function () {
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

			$(divRowArr).find('label').each(function () {
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
		var chosenElemId = '#' + elemId;
		var siblingSize = $(chosenElemId).siblings().size();
		var chosenElem = []
		if(siblingSize > 0 ) {
			chosenElem = $(chosenElemId).next().find('.search-choice span').map(function () {
				return $(this).text();
			}).get();
		}else{
			var latest_value = $("option:selected:last",chosenElemId).last().val();
			console.log(latest_value);
			chosenElem = $(chosenElemId + " :selected:last").map(function(i, el) {
				return $(el).text();
			}).get();
		}
		console.log("chosenElem :" + chosenElem);
		setTimeout(function () {
			var siblingsSize = $(chosenElemId).siblings().size();
			var chosenElems = []
			if(siblingsSize > 0 ) {
				chosenElems = $(chosenElemId).next().find('.search-choice span').map(function () {
					return $(this).text();
				}).get();
			}else{
				chosenElems = $(chosenElemId + " :selected").map(function(i, el) {
					return $(el).text();
				}).get();
			}
			console.log("chosenElems :" + chosenElems);
			if (chosenElems == '') {
				$(divRowArr).find('label').each(function () {
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
						$(divRowArr).find('label').each(function () {
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
}

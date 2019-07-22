$(document).ready(function(){
    
    var o = $("#record_case_data_child_register_client_chosen").closest('.row').nextAll("*:lt(1)").hide() ;
    var w = $("#record_case_data_child_clients_referred_by_chosen").closest('.row').nextAll("*:lt(4)").hide() ;
    var e = $("#record_case_data_child_reasons_for_registering_at_special_cell__chosen").closest('.row').nextAll("*:lt(2)").hide() ;
    var b = $("#record_case_data_child_intervention_by_special_cell__chosen").closest('.row').nextAll("*:lt(2)").hide() ;
    var a = $("#record_case_data_child_referrals_new_clients_ongoing_clients_chosen").closest('.row').nextAll("*:lt(3)").hide() ;
    var c = $("#record_case_data_child_outcomes_new_clients_ongoing_clients_chosen").closest('.row').nextAll("*:lt(3)").hide() ;
    var s = $('#record_case_data_child_other_interventions_taking_place_outside_the_cell_chosen').closest('.row').nextAll("*:lt(1)").hide() ;

    $('body').delegate("select","change", function(e) {
        var elemId = e.target.id;
        var selectText = $('#' + elemId).find(":selected").text();
        
       $("label").each(function() {
           var labelText = $(this).text();
           if(selectText == labelText){
               $(this).closest('.row').show();
           }
        
       });
    });
});



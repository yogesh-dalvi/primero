$(document).ready(function(){    
    $('#record_case_data_child_location option:eq(1)').prop('selected', true);      
    var selectText = $('#record_case_data_child_location').find(":selected").text();     
    $('#record_case_data_child_location_chosen a span').text(selectText);     
    $('#record_case_data_child_location_chosen a').removeClass('chosen-default');
});
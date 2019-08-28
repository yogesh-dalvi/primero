$(document).ready(function(){
    $('#case_narrative__child_source_of_referral_chosen').closest('.row').nextAll(':lt(4)').hide();
    $('#case_narrative__child_source_of_referral').change(function(){
        var elem = $(this);
        $(this).closest('.row').nextAll(':lt(4)').each(function(){
            var selectedText = $(elem).find(":selected").text();
            var labelText = $(this).find('label').text();
            if(labelText.includes(selectedText)){
                $(this).show();
            }else{
                $(this).hide();
            }
        })
    })
});

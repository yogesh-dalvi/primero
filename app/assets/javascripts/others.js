$(document).ready(function(){
    $('#case_narrative__child_age_month').parent().prev('div').find('label').css('visibility','hidden');
    $('#case_narrative__child_institutional_care').closest('.row').hide().nextAll(':lt(4)').hide();
    $("label").each(function () {
        var elem = $(this);
        var labelText = $(elem).text();
        if (labelText == 'Any Other, Specify') {
            $(elem).closest('.row').hide();
        }
    });

    $('body').delegate("select", "change", function (e) {
        displayHideDropDownFields($(this));
    });

    $('#case_narrative__child_child_currently_living_with').change(function(){
        var selectText = $(this).find(":selected").text();
        if (selectText == 'Institutional Care') {
            $('#case_narrative__child_institutional_care').closest('.row').show().nextAll(':lt(4)').show();
        } else {
            $('#case_narrative__child_institutional_care').closest('.row').hide().nextAll(':lt(4)').hide();
        }

    })
});    
function displayHideDropDownFields(element){
    var elemId = $(element).attr('id');
    var selectText = $('#' + elemId).find(":selected").text();
    var otherSpecifyElem = $(element).closest('.row').next();

    if (!$(element).prop('multiple')) {
        if (selectText == 'Any Other (Specify)') {			
            $(otherSpecifyElem).show();
        }else{			
			var otherElemLabelText = $(element).closest('.row').next().find('label').text();
			if (otherElemLabelText == 'Any Other, Specify') {
				$(element).closest('.row').next().hide();
			}
		}
    }else{
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
                if (labelText == 'Any Other (Specify)') {
                    $(otherSpecifyElem).hide();
                }
            });

        } else {
            $(chosenElem).each(function (i, val) {                    
                if (val == 'Any Other (Specify)') {
                    if (jQuery.inArray(val, chosenElems) != -1) {
                        $(otherSpecifyElem).show();
                    } else {
                        $(otherSpecifyElem).hide();
                    }
                } 

            });

        };
    }, 500);
}
}
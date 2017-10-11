$(document).ready(function(){
	var CURRENT_ROW_EDIT_ID = 0;	// ID of row being edited
	var NUM_COLUMNS = 0;			// Number of columns in table (not including delete/edit)
	var NUM_CONDITIONS = 1;			// Number of condition rows in the technician input
	var CONDITION_INPUT_HTML = "";

	/* I18n Support */
	var update_texts = function() {
		$('[data-i18n]').i18n();
		setFuelConsumptionPlaceholder();
		if($.i18n().locale === 'de') {
			$('.descriptionDE').show();
			$('.descriptionEN').hide();
		}
		else {
			$('.descriptionDE').hide();
			$('.descriptionEN').show();
		}
	};

	$('.lang-switch').click(function(e) {
		e.preventDefault();
		$.i18n().locale = $(this).data('locale');
		Cookies.set('lang', $(this).data('locale'), { expires: 20 })
		update_texts();
	});

	var lang;
	if(typeof(Cookies.get('lang')) != 'undefined') {
		lang = Cookies.get('lang');
	}
	else if(typeof($('html').attr('lang')) != 'undefined') {
		lang = $('html').attr('lang');
	}
	else {
		lang = 'de';
	}
	$.i18n({locale: lang}).load({
		'de': '/js/i18n/de.json',
		'en': '/js/i18n/en.json',
		'fr': '/js/i18n/fr.json'
	}).done(function() {
		update_texts();
	});
	
	update_texts();
	/* End I18n Code */

	setup();

	function setup(){
		setFuelConsumptionPlaceholder();

		if(typeof COLUMN_NAMES !== 'undefined') NUM_COLUMNS = COLUMN_NAMES.length;	// Get number of columns in table from EJS

		// Set hidden form inputs
		$("#heatpumpTypeSelect").val($("#heatpumpTypeSelect option:first").val());
		var selectedVal = $("#heatpumpTypeSelect").find(":selected").val(); 
		$("#heatpumpType").val(selectedVal);
		$("#heatpumpType2").val(selectedVal);

		// Get rid of comparison rows that have nothing in them
		pruneEmptyCompareRow("#scopCompareRow");
		pruneEmptyCompareRow("#notesCompareRow");
		pruneEmptyCompareRow("#outdoorSoundCompareRow");
		pruneEmptyCompareRow("#outdoorSoundConditionCompareRow");
		pruneEmptyCompareRow("#indoorSoundCompareRow");
		pruneEmptyCompareRow("#indoorSoundConditionCompareRow");
		pruneEmptyCompareRow("#refrigerantType2CompareRow");
		pruneEmptyCompareRow("#refrigerantType2AmountCompareRow");
		pruneEmptyCompareRow("#refrigerantType1CompareRow");
		pruneEmptyCompareRow("#refrigerantType1AmountCompareRow");

		// Save HTML of the technician test condition input
		var row = $("#dataPointContainer").children().eq(0);
		CONDITION_INPUT_HTML = "<div class='row mb-3'>" + row.html() + "</div>";		
	}

	/* Technician input - insert another row for test conditions */
	$("#insertTestCondition").on('click', function(e){
		$("#dataPointContainer").append(CONDITION_INPUT_HTML);
		NUM_CONDITIONS++;
	});

	/* Technician input - delete test condition row */
	$("#dataPointContainer").on('click', '.deleteBedingungRow',function(e){
		e.preventDefault();
		if(NUM_CONDITIONS <= 1) return;
		
		$(this).parent().parent().remove();
		NUM_CONDITIONS--;
	});

	/* Technician input (submit) */
	$("#uploadTestResultButton").on('click', function(){
		$(".error").removeClass("error");
		$(".inputError").removeClass("inputError");
    	$("#testInputSuccessAlert").hide();
    	$("#testInputErrorAlert").hide();
    	var errorFlag = 0;

		// Create 2d array of bedingung inputs
		var values = [];
		for(var i = 0; i < NUM_CONDITIONS; i++){
			var currentChildRow = $("#dataPointContainer").children().eq(i);	// Get nth child

			values.push(currentChildRow.find("#testConditionSelect").find(":selected").val());
			values.push(currentChildRow.find("#heatCapacity").val());
			values.push(currentChildRow.find("#inputPower").val());
			values.push(currentChildRow.find("#cop").val());
			values.push(currentChildRow.find("#humidity").val());
		}

		/* Validate all test condition inputs */
		$("#dataPointContainer").children().each(function(){
			if($(this).find("#heatCapacity").val() == "") 	$(this).find("#heatCapacity").addClass("inputError"); errorFlag = 1;
			if($(this).find("#inputPower").val() == "") 	$(this).find("#inputPower").addClass("inputError"); errorFlag = 1;
			if($(this).find("#cop").val() == "") 			$(this).find("#cop").addClass("inputError"); errorFlag = 1;
		});

		var data = {};
		var k = 0;
		for(var i = 0; i < values.length; i+=5){
			item = {};
			item['conditionID'] = values[i];
			item['heatCapacity'] = values[i+1];
			item['inputPower'] = values[i+2];
			item['cop'] = values[i+3];
			item['humidity'] = values[i+4];
			data[k] = item;
			k++;
		}

		// Create array of selected Norm IDs
	    var normIDs = $("#normCheckboxWrapper input:checkbox:checked").map(function(){
	      	return $(this).val();
	    }).get();

		var visible = $('input[name=visible]:checked').val();
		var heatpumpTypeSelect = $('select[name=heatpumpTypeSelect]').find(":selected").val();
		var heatingTypeSelect = $('select[name=heatingTypeSelect]').find(":selected").val();
		var customerSelect = $('select[name=customerSelect]').find(":selected").val();
		var heatpumpModel = $('input[name=heatpumpModel]').val();
		var heatpumpModelPart2 = $('input[name=heatpumpModelPart2]').val();
		var testNumber = $('input[name=testNumber]').val();
		var bauartSelect = $('select[name=bauartSelect]').find(":selected").val();
		var productTypeSelect = $('select[name=productTypeSelect]').find(":selected").val();
		var refrigerantType1 = $('input[name=refrigerantType1]').val();
		var refrigerantType1Amount = $('input[name=refrigerantType1Amount]').val();
		var refrigerantType2 = $('input[name=refrigerantType2]').val();
		var refrigerantType2Amount = $('input[name=refrigerantType2Amount]').val();
		var outdoorSoundLevel = $('input[name=outdoorSoundLevel]').val();
		var outdoorSoundType = $('input[name=outdoorSoundLevelType]').val();
		var indoorSoundLevel = $('input[name=indoorSoundLevel]').val();
		var indoorSoundType = $('input[name=indoorSoundLevelType]').val();
		var scop = $('input[name=scop]').val();
		var bivalence = $('input[name=bivalence]').val();
		var volumeFlowNorm = $('input[name=volumeFlowNorm]').val();
		var volumeFlow35 = $('input[name=volumeFlow35]').val();
		var volumeFlow45 = $('input[name=volumeFlow45]').val();
		var volumeFlow55 = $('input[name=volumeFlow55]').val();
		var notes = $('input[name=notes]').val();

		errorFlag = 0;
		if(normIDs.length <= 0){ 			$("#normCheckboxWrapper").addClass("error"); errorFlag = 1;}
		if(heatpumpModel === ''){ 			$('input[name=heatpumpModel]').parent().addClass("error"); errorFlag = 1;}
		if(refrigerantType1 === ''){ 		$('input[name=refrigerantType1]').parent().addClass("error"); errorFlag = 1;}
		if(refrigerantType1Amount === ''){ 	$('input[name=refrigerantType1Amount]').parent().addClass("error"); errorFlag = 1;}
		var regexTestNumber = /^\d\d\d-\d\d-\d\d$/;
		var test = regexTestNumber.test($('input[name=testNumber]').val());
		if(testNumber === '' || test === false){ $('input[name=testNumber]').parent().addClass("error"); errorFlag = 1};
		if(errorFlag){ $("#testInputErrorAlert").fadeIn(250); return;}

		$.ajax({
	        type: "POST",
	        data: {data, normIDs, visible, heatpumpTypeSelect, heatingTypeSelect, customerSelect, heatpumpModel, heatpumpModelPart2, testNumber, bauartSelect,
	        	   productTypeSelect, refrigerantType1, refrigerantType1Amount, refrigerantType2, refrigerantType2Amount,
	        	   outdoorSoundLevel, outdoorSoundType, indoorSoundLevel, indoorSoundType, scop, bivalence,
	        	   volumeFlowNorm, volumeFlow35, volumeFlow45, volumeFlow55, notes},
	        url: "/pruefresultate/eingabe/senden",
	        dataType: "json",
	        success: function(resData, textStatus, jqXHR){
	        	console.log("ajax sucess");
	        	switch(resData.status){ // Server response (show success/error message)
	        		case 'success':
	        			$("#testInputSuccessAlert").fadeIn(250);
	        			break;
	        		case 'error':
	        			$("#testInputErrorAlert").fadeIn(250);
	        			break;
	        	}
	        }
	    });
	});

	/* Removes tr from the comparison table if all <td> children are empty */
	function pruneEmptyCompareRow(rowid){
		var countFilled = 0;

		$(rowid).children("td").each(function(){
			if($(this).text().length > 0) countFilled++;
		});

		if(countFilled == 0) $(rowid).remove();		
	}

	/* Heatpumptype submit button Sets hidden inputs and shows accordion */
	$("#heatpumpTypeSelect").on('change', function(){
		$("#accordion").fadeIn(500);
		var selectedVal = $(this).find(":selected").val(); 

		$("#heatpumpType").val(selectedVal);
		$("#heatpumpType2").val(selectedVal);
	});

	/* Modifys power consumption label units */
	$("#fuelTypeSelect").on('change', function(){
		setFuelConsumptionPlaceholder();
	});

	/* Modifys power consumption label units */
	function setFuelConsumptionPlaceholder(){
		var type = $("#fuelTypeSelect").find(":selected").val();

		if(type === "gasoline"){
			$("input[name=fuelConsumption]").attr('placeholder', $.i18n('Consumption-Search-Gas-Placeholder'));
		}
		else{
			if(type === "oil"){
				$("input[name=fuelConsumption]").attr('placeholder', $.i18n('Consumption-Search-Oil-Placeholder'));
			}
			else{
				if(type === "electricity"){
					$("input[name=fuelConsumption]").attr('placeholder', $.i18n('Consumption-Search-Electricity-Placeholder'));
				}				
			}
		}

		return type;
	}

	/* Limits the fuel consumption input to a max value */
	$("input[name=fuelConsumption").on('input', function(){
		var type = $("#fuelTypeSelect").find(":selected").val();

		if(type === "gasoline" || type === "oil"){
			if($("input[name=fuelConsumption]").val() >= 10000){
				$("input[name=fuelConsumption]").val(10000);
			}
		}
		else{
			if(type === "electricity"){
				if($("input[name=fuelConsumption]").val() >= 100000){
					$("input[name=fuelConsumption]").val(100000);
				}
			}
		}		
	});

	/* ON MODAL OPEN */
	$('#modal').on('show.bs.modal', function (event) {
		$("#errors").empty();
		var modal = $(this);
		var button = $(event.relatedTarget); 	// Button that triggered modal
		var recipient = button.data('operation');

		modal.find('.modal-title').text(recipient);
		modal.find('#formButtonContainer button').attr('id', button.data('event'));	// Modify form button id to trigger proper submit event (ADD/EDIT)
	});

	/* EDIT (LOAD INPUTS) */
	$(".editTable").on("click", function(e){
		CURRENT_ROW_EDIT_ID = $(this).data('id');
		var url = $(this).data("action") + CURRENT_ROW_EDIT_ID;
		$("#errors").empty();

		$.ajax({	// Fetch available row data and put into inputs on modal
	        type: "POST",
	        data: CURRENT_ROW_EDIT_ID,
	        datatype: "json",
	        url: url,
	        success: function(resData, textStatus, jqXHR){
	        	responseData = JSON.parse(resData);
				$("#formInputContainer").empty();

				for(var k = 1; k < NUM_COLUMNS; k++){					// Add inputs with key names
					var input = "<input placeholder='" + COLUMN_NAMES[k] + "' name='" + COLUMN_NAMES[k] + "' type='text' class='form-control mb-3'>";
					$("#formInputContainer").append(input);
				}

	        	var values = [];
				for(var i = 0; i < responseData.results.length; i++) {	// Get all values from results
					var results = responseData.results[i];
					for(var prop in results) {
						values.push(results[prop]);
					}
				}
				
				var i = 1;	// Skip ID column
				$('#modal').find('.modal-body input[type=text]').each(function(){	// Put results values into inputs
					$(this).val(values[i]);
					i++;
				});
	        }
	    });
	});

   	/* EDIT (SUBMIT) */
	$('#formButtonContainer').on("click", '#formEdit', function(e){
		e.preventDefault();

		send_AJAX(inputs_to_JSON(), "/table/edit/update", "POST", "#errors");
	});

	/* ADD (LOAD INPUTS) */
	$("#addToTable").on("click", function(){
		$("#formInputContainer").empty();
		$("#errors").empty();

		for(var i = 1; i < NUM_COLUMNS; i++){
			var input = "<input name='" + COLUMN_NAMES[i] + "' placeholder='" + COLUMN_NAMES[i] + "' type='text' class='form-control mb-3'>";
			$("#formInputContainer").append(input);
		}
	});

	/* ADD (SUBMIT) */
	$('#formButtonContainer').on("click", '#formAdd', function(e){
		e.preventDefault();
		send_AJAX(inputs_to_JSON(), "/table/add", "POST", "#errors");		
	});

	/*
	 * Retrieves all modal inputs and creates a JSON object with each input's name and value 
	 * @return JSON object with format [{name: "value"},...]
	 */
	function inputs_to_JSON(){
		var numColumns = $('#tableDataContainer th').length - 2;	// Columns in table (no delete, edit columns)

		values = [];
		$("#formInputContainer :input").each(function(){			// Get all values from form
			values.push($(this).val());
		});

		var data = {};
		for(var i = 0; i < values.length; i++){						// Generate JSON to send to server
			data[COLUMN_NAMES[i+1]] = values[i];
		}
		data['id'] = CURRENT_ROW_EDIT_ID;

		return data;		
	}

	/*
	 * Creates AJAX request for sending modal form data to server. Expects JSON response {errors, status} 
	 * ERROR: Display errors in modal and die
	 * SUCCESS: Reload page
	 * @param data data to send
	 * @param url destination to send data to
	 * @param type GET/POST
	 */
	function send_AJAX(data, url, type, errorContainerID){
		$.ajax({
	        type: type,
	        data: data,
	        url: url,
	        datatype: "json",
	        success: function(resData, textStatus, jqXHR){
	        	responseData = JSON.parse(resData);

				$(errorContainerID).empty();

				switch(responseData.status){
					case "queryError":
						$(errorContainerID).append("<div class='alert alert-danger'>SERVER ERROR: " + responseData.errors.errno + "</div>");
						break;
					case "error":
						for(var i = 0; i < responseData.errors.length; i++){
							$(errorContainerID).append("<div class='alert alert-danger'>" + responseData.errors[i].msg + "</div>");
						}
						break;
					default:
						location.reload();
				}
	        }
	    });
	}

	/*
	 * Handles the "Add to Compare" checkboxes
	 */
	$(".addToCompare").on("click", function(){
		id = $(this).data("id");
		bedingungID = $(this).data("bedingungid");
		checkbox = $(this);

		$.ajax({
	        type: "POST",
	        data: {id, bedingungID},
	        url: "/vergleichen/einfuegen",
	        success: function(resData, textStatus, jqXHR){
	        	responseData = JSON.parse(resData);

	        	if(responseData.status === 'error'){
	        		checkbox.prop('checked', false);
		        	alert(responseData.errors[0].msg);
	        	}
	        }
	    });		
	});
});		
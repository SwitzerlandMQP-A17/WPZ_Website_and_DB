/* Module setup */
const express = require('express');
var session = require('express-session');
const bodyParser = require('body-parser');
const path = require('path');
const mysql = require('mysql');
const ejs = require('ejs');
const server = express();
const expressValidator = require('express-validator');
const { check, validationResult } = require('express-validator/check');
const winston = require('winston');
const pythonShell = require('python-shell');

/* Module middleware */
server.use(bodyParser.json());
server.use(bodyParser.urlencoded({extended: true}));
server.use(express.static(path.join(__dirname, 'public')));
server.set('views', path.join(__dirname, 'views'));
server.set('view engine', 'ejs');
server.use('/js', express.static(__dirname + '/node_modules/validator'));

/* Session setup */
server.use(session({
	secret: "worcesterpolytechnicinstitute",
	resave: true,
    saveUninitialized: true
}));

/* Local variables */
server.use(function(req, res, next) {
    res.locals.LOGGED_IN = req.session.USERNAME; // Used by EJS to determine login state
    next();
});

/* Set winston transport methods */
var logger = new (winston.Logger)({
	transports: [
		new (winston.transports.File)({
			name: 'info-file',
			filename: 'serverlog-info.log',
			level: 'info'
		}),
		new (winston.transports.File)({
			name: 'error-file',
			filename: 'serverlog-error.log',
			handleExceptions: true,
			level: 'error'
		})
	]
});

/* Connect to MySQL database with pool */
var pool = mysql.createPool({
	connectionLimit : 30,
	host            : 'localhost',
	user            : 'root',
	password        : 'admin',
	database        : 'wpz_database_prototype',
	multipleStatements: true
});

/* Route / */
server.get('/', function(req, res){
	res.render('pages/index', {
		title: "NTB Buchs | Wärmepumpen-Testzentrum Vergleichstool",
		accordionState: "hide",
		accordionInstallerState: "collapse",
		accordionFuelState: "collapse"
	});
});

/* Route testNumber/:id/:infoid */
server.get('/pruefresultate/:id/:infoid', function(req, res){
	var testNumber = req.params.id;
	var infoid = parseInt(req.params.infoid);

	pool.getConnection(function(err, client){
		if (err){ logger.log('error', 'TEST RESULT pool: %s', err.stack); }

		sql = 'CALL GetAdvancedInfo(?, ?)';
		final_sql = mysql.format(sql, [testNumber, infoid]);

		var query = client.query(final_sql, function (error, results, fields){
			res.render('pages/fullTestResults', {
				title: "NTB Buchs | Wärmepumpen-Testzentrum Vergleichstool Prüfresultate",
				queryResults: results[0],
				queryResultsConditions: results[1]
			});
			client.release();
		});

		query.on('error', (err) => { if (err){ logger.log('error', 'TEST RESULT query: %s', err.stack); } });
	});
});

/* Route /login */
server.get('/anmelden', function(req, res){
	res.render('pages/login', {
		title: "NTB Buchs | Wärmepumpen-Testzentrum Vergleichstool Anmeldung"
	});
});

/* Route /logout */
server.get('/abmelden', function(req, res){
	logger.log('info', 'LOGGING OUT USER %s', req.session.username);

	delete req.session.USERNAME;
	res.locals.LOGGED_IN = false;
	res.redirect('/');
});

/* Route /login/auth (Authenticate) */
server.post('/anmelden/auth', function(req,res){
	var username = req.body.username;
	var password = req.body.password;

	var post = req.body;
	if (username === 'test_user' && password === 'test_password') { //real username and password hidden for security purposes
		req.session.USERNAME = username;		// Set session variable
		res.locals.LOGGED_IN = true;			// Set local variable
		logger.log('info', 'LOGGING IN USER %s | SESSION ID = %s', req.session.USERNAME, req.sessionID);
		res.render('pages/maintenance', {
			title: "NTB Buchs | Wärmepumpen-Testzentrum Vergleichstool Instandhaltung"
		});
	} else {
		res.render('pages/login', {
			title: "NTB Buchs | Wärmepumpen-Testzentrum Vergleichstool Anmeldung",
			error: "Falscher Name oder Passwort"
		});
	}
});

/* Route /testInput */
server.get('/pruefresultate', function(req, res){
	var query = pool.query("CALL LoadInfoForInsert()", function (error, results, fields){	// Get data to fill inputs/selects on render
		res.render('pages/testInput', {
			title: "NTB Buchs | Wärmepumpen-Testzentrum Vergleichstool Techniker Prüfresultate Eingabe",
			queryResults: results
		});
	});

	query.on('error', (err) => { logger.log('error', 'LoadInfoForInsert(): %s', err.stack); });
});

/* Route /test/input/submit (Submit technician input) */
server.post('/pruefresultate/eingabe/senden', function(req, res){
	var sql_parent = "";	// Master sql string

	// First test condition
	var bedingungID = parseInt(req.body.data[0].conditionID);
	var heizleistung = parseFloat(req.body.data[0].heatCapacity);
	var leistungsaufnahme = parseFloat(req.body.data[0].inputPower);
	var cop = parseFloat(req.body.data[0].cop);
	var lufteuchtigkeit = parseFloat(req.body.data[0].humidity);

	if(isNaN(lufteuchtigkeit)) lufteuchtigkeit = null;	

	inserts = [bedingungID, heizleistung, leistungsaufnahme, cop, lufteuchtigkeit];
	sql = "CALL AddResultatLookup(NULL, ?, ?, ?, ?, ?, @ResultatID);";
	final_sql = mysql.format(sql, inserts);

	sql_parent += final_sql;

	// 2 to * test conditions
	for(var i = 1; i < req.body.data.length; i++){
		bedingungID = parseInt(req.body.data[i].conditionID);
		heizleistung = parseFloat(req.body.data[i].heatCapacity);
		leistungsaufnahme = parseFloat(req.body.data[i].inputPower);
		cop = parseFloat(req.body.data[i].cop);
		lufteuchtigkeit = parseFloat(req.body.data[i].humidity);

		if(isNaN(lufteuchtigkeit)) lufteuchtigkeit = null;

		inserts = [bedingungID, heizleistung, leistungsaufnahme, cop, lufteuchtigkeit];
		sql = " CALL AddResultatLookup(@ResultatID, ?, ?, ?, ?, ?, @ResultatID);";
		final_sql = mysql.format(sql, inserts);

		sql_parent += final_sql;
	}

   	var auftraggeberID = parseInt(req.body.customerSelect);
   	var geraetPart1 = req.body.heatpumpModel;
   	var geraetPart2 = req.body.heatpumpModelPart2;
   	var prufNummer = req.body.testNumber;
   	var kategorieID = parseInt(req.body.heatpumpTypeSelect);
   	var heizungstypID = parseInt(req.body.heatingTypeSelect);
   	var bauart = parseInt(req.body.bauartSelect);
	var produktart = req.body.productTypeSelect;	
	var refrigerantType1 = req.body.refrigerantType1;
	var refrigerantCapacity1 = parseFloat(req.body.refrigerantType1Amount);
	var refrigerantType2 = req.body.refrigerantType2;
	var refrigerantCapacity2 = parseFloat(req.body.refrigerantType2Amount);
	var volumeNorm = parseFloat(req.body.volumeFlowNorm);
	var volume35 = parseFloat(req.body.volumeFlow35);
	var volume45 = parseFloat(req.body.volumeFlow45);
	var volume55 = parseFloat(req.body.volumeFlow55);
	var scop = parseFloat(req.body.scop);
	var bivalence = req.body.bivalence;
	var bivalenceVal1 = null;
	var bivalenceVal2 = null;
	var shallAussen = parseFloat(req.body.outdoorSoundLevel);
	var shallAussenCondition = req.body.outdoorSoundType;
	var shallInnen = parseFloat(req.body.indoorSoundLevel);
	var shallInnenCondition = req.body.indoorSoundType;
	var notes = req.body.notes;
	var visibility = parseInt(req.body.visible);

	if(bivalence != ''){
		bivalenceVal1 = parseInt(bivalence.slice(0, bivalence.indexOf("/")).replace(/[^0-9\.\-]/g, ''));
		bivalenceVal2 = parseInt(bivalence.slice(bivalence.indexOf("/")).replace(/[^0-9\.\-]/g, ''));		
	}

	if(isNaN(req.body.volumeNorm)) volumeNorm = null;
	if(isNaN(req.body.volume35)) volume35 = null;
	if(isNaN(req.body.volume45)) volume45 = null;
	if(isNaN(req.body.volume55)) volume55 = null;
	if(req.body.productTypeSelect == '') produktart = null;
	if(req.body.outdoorSoundType == '') shallAussenCondition = null;
	if(req.body.indoorSoundType == '') shallInnenCondition = null;
	if(req.body.notes == '') notes = null;		
	if(req.body.heatpumpModelPart2 == '') geraetPart2 = null;
	if(req.body.refrigerantType2 == '') refrigerantType2 = null;
	if(req.body.bivalence == '') bivalence = null;
	if(isNaN(refrigerantCapacity2)) refrigerantCapacity2 = null;
	if(isNaN(scop)) scop = null;
	if(isNaN(shallAussen)) shallAussen = null;
	if(isNaN(shallInnen)) shallInnen = null;

	sql = " CALL InsertTestResult(?, ?, ?, ?, ?, ?, @ResultatID, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, @InfoID);";
	inserts = [auftraggeberID, geraetPart1, geraetPart2, prufNummer, kategorieID, heizungstypID, bauart, produktart, refrigerantType1, refrigerantCapacity1, refrigerantType2, refrigerantCapacity2, volumeNorm, volume35, volume45, volume55, scop, bivalence, bivalenceVal1, bivalenceVal2, shallAussen, shallAussenCondition, shallInnen, shallInnenCondition, notes, visibility];
	final_sql = mysql.format(sql, inserts);

	sql_parent += final_sql;

	for(var i = 0; i < req.body.normIDs.length; i++){
		sql_parent += " CALL AddNormInfoLookup(" + req.body.normIDs[i] + ", @InfoID);";
	}

	pool.getConnection(function(err, client){
		if (err){ logger.log('error', 'TECHNICIAN pool: %s', err.stack); }

		var query = client.query(sql_parent, function (error, results, fields){
			if(error){
				res.send(JSON.stringify({status: "error"}));
			}
			else{
				res.send(JSON.stringify({status: "success"}));
				exportExcel();
			}	
			client.release();
		});

		query.on('error', (err) => { if (err){ logger.log('error', 'TECHNICIAN query: %s', err.stack); } });
	});	
});

/* Route /compare */
server.get('/vergleichen', function(req, res){
	if(typeof req.session.COMPARE_LIST == 'undefined' || req.session.COMPARE_LIST.length <= 0){
		res.render('pages/compare', {
			title: "NTB Buchs | Wärmepumpen-Testzentrum Vergleichstool"
		});
	}
	else{
		pool.getConnection(function(err, client){
			if (err){ logger.log('error', 'COMPARE pool: %s', err.stack); }

			sql = 'CALL GetComparisonInfo(?, ?, ?, ?, ?, ?)';
			inserts = [req.session.COMPARE_LIST[0], req.session.COMPARE_LIST[1], req.session.COMPARE_LIST[2], req.session.COMPARE_LIST[3], req.session.COMPARE_LIST[4], req.session.BEDINGUNG_ID];
			final_sql = mysql.format(sql, inserts);

			var query = client.query(final_sql, function (error, results, fields){
				res.render('pages/compare', {
					title: "NTB Buchs | Wärmepumpen-Testzentrum Vergleichstool",
					queryResults: results
				});				
				client.release();
			});

			query.on('error', (err) => { logger.log('error', 'COMPARE query: %s', err.stack); });
		});		
	}
});

/* Route /searchResults */
server.get('/suchergebnisse', function(req, res){
	res.render('pages/searchResults', {
		title: "NTB Buchs | Wärmepumpen-Testzentrum Vergleichstool Suchergebnisse",
		searchTitle: req.session.HEATPUMPTYPE_STR,
		compareList: req.session.COMPARE_LIST
	});
});

/* Route /maintenance */
server.get('/instandhaltung', checkAuth, function(req, res){
	res.render('pages/maintenance', {
		title: "NTB Buchs | Wärmepumpen-Testzentrum Instandhaltungstool"
	});
});

/* Route /haftung */
server.get('/haftung', function(req, res){
	res.render('pages/haftung', {
		title: "NTB Buchs | Wärmepumpen-Testzentrum Vergleichstool Haftung"
	});
});

/* Route /auftraggeber */
server.get('/auftraggeber', checkAuth, function(req, res){
	render_table_view(req, res, "Auftraggeber", "AuftraggeberID");
});

/* Route /bauart */
server.get('/bauart', checkAuth, function(req, res){
	render_table_view(req, res, "Bauart", "BauartID");
});

/* Route /normen */
server.get('/norm', checkAuth, function(req, res){
	render_table_view(req, res, "Norm", "NormID");
});

/* Route /customers page */
server.get('/info', checkAuth, function(req, res){
	render_table_view(req, res, "Info", "InfoID");
});

/* Route /heizungstyp */
server.get('/heizungstyp', checkAuth, function(req, res){
	render_table_view(req, res, "Heizungstyp", "HeizungstypID");
});

/* Route /bedingung */
server.get('/bedingung', checkAuth, function(req, res){
	render_table_view(req, res, "Bedingung", "BedingungID");
});

/* Route /kategorie */
server.get('/kategorie', function(req, res){
	render_table_view(req, res, "Kategorie", "KategorieID");
});

/* Route /bauartinfo */
server.get('/bauartinfo', checkAuth, function(req, res){
	render_table_view(req, res, "BauartInfo", "IndexID");
});

/* Route /bedingungenrelativ */
server.get('/bedingungenrelativ', checkAuth, function(req, res){
	render_table_view(req, res, "BedingungenRelativ", "IndexID");
});

/* Route /resultat */
server.get('/resultat', checkAuth, function(req, res){
	render_table_view(req, res, "Resultat", "IndexID");
});

/* Route /verbindung */
server.get('/verbindung', checkAuth, function(req, res){
	render_table_view(req, res, "Verbindung", "VerbindungID");
});

/* Route /search/installer */
server.post('/such/installateur', [
	check('heatpumpType').not().isEmpty().withMessage('Wärmepumpenart ist erforderlich'),
	check('powerConsumption').not().isEmpty().withMessage('Heizleistung im Auslegepunkt ist erforderlich'),
	check('outsideTemp').not().isEmpty().withMessage('Außentemperatur im Auslegepunkt ist erforderlich'),
	check('heatingType').not().isEmpty().withMessage('Heizungstyp ist erforderlich')], function(req, res){

	errors = validationResult(req);

	if(!errors.isEmpty()){
		res.render('pages/index', {
			title: "NTB Buchs | Wärmepumpen-Testzentrum Vergleichstool Instandhaltung",
			installerErrors: errors.array(),
			accordionState: "show",
			accordionInstallerState: "show",
			accordionFuelState: "collapse"
		});
	}
	else{
		var heatpumpCategory1 = 1;
		var heatpumpCategory2 = 0;
		var watersupplyTemp = 35;
		var heatpumpType = req.body.heatpumpType;
		var powerConsumption = req.body.powerConsumption;
		var outsideTemp = req.body.outsideTemp;
		var heatingType = req.body.heatingType;

		switch(heatpumpType){
			case '1':
				req.session.HEATPUMPTYPE_STR = "Luft-Wasser";			
				break;
			case '2':
				req.session.HEATPUMPTYPE_STR = "Sole-Wasser";
				heatpumpCategory1 = 2;
				heatpumpCategory2 = 4;				
				break;
			case '3':
				req.session.HEATPUMPTYPE_STR = "Wasser-Wasser";
				heatpumpCategory1 = 3;
				heatpumpCategory2 = 4;	
				break;
		}

		req.session.COMPARE_LIST = [];
		req.session.BEDINGUNG_ID = null;
		req.session.save();

		switch(heatingType){
			case '3':
				watersupplyTemp = 55;
				break;
		}

		pool.getConnection(function(err, client){
			if (err){ logger.log('error', 'SEARCH installer pool: %s', err.stack); }

			sql = 'CALL SearchForPumps(?, ?, ?, ?, ?, ?, 0)';
			inserts = [heatpumpCategory1, heatpumpCategory2, parseInt(heatingType), parseInt(powerConsumption), parseInt(outsideTemp), watersupplyTemp];
			final_sql = mysql.format(sql, inserts);

			var query = client.query(final_sql, function (error, results, fields){
				res.render('pages/searchResults', {
					title: "NTB Buchs | Wärmepumpen-Testzentrum Vergleichstool Suchergebnisse",
					queryResults: results[0],
					searchTitle: req.session.HEATPUMPTYPE_STR,
					compareList: req.session.COMPARE_LIST,
					isFuelSearch: 0
				});
				client.release();
			});

			query.on('error', (err) => { logger.log('error', 'SEARCH installer query: %s', err.stack); });
		});
	}
});

/* Route /search/fuel */
server.post('/such/verbrauchsdaten', [
	check('heatpumpType').not().isEmpty().withMessage('Wärmepumpenart ist erforderlich'),
	check('heatingTypeFuel').not().isEmpty().withMessage('Heizungstyp ist erforderlich'),
	check('fuelConsumption').not().isEmpty().withMessage('Treibstoffaufnahme ist erforderlich')], function(req, res){

	errors = validationResult(req);

	if(!errors.isEmpty()){
		res.render('pages/index', {
			title: "NTB Buchs | Wärmepumpen-Testzentrum Vergleichstool Instandhaltung",
			fuelErrors: errors.array(),
			accordionState: "show",
			accordionInstallerState: "collapse",
			accordionFuelState: "show"
		});
	}
	else{
		var heatpumpCategory1 = 1;
		var heatpumpCategory2 = 0;
		var heatpumpType = req.body.heatpumpType;
		var fuelType = req.body.fuelType;
		var fuelConsumption = req.body.fuelConsumption;
		var heatingType = req.body.heatingTypeFuel;
		var previouslyHotWater = req.body.hotWater;

		switch(heatpumpType){
			case '1':
				req.session.HEATPUMPTYPE_STR = "Luft-Wasser";			
				break;
			case '2':
				req.session.HEATPUMPTYPE_STR = "Sole-Wasser";
				heatpumpCategory1 = 2;
				heatpumpCategory2 = 4;				
				break;
			case '3':
				req.session.HEATPUMPTYPE_STR = "Wasser-Wasser";
				heatpumpCategory1 = 3;
				heatpumpCategory2 = 4;	
				break;
		}
		
		req.session.COMPARE_LIST = [];
		req.session.BEDINGUNG_ID = null;
		req.session.save();

		var sql = "";
		switch(fuelType){
			case 'gasoline':
				sql = 'CALL SearchForPumpsByGas(?, ?, ?, ?, ?)';
				break;
			case 'oil':
				sql = 'CALL SearchForPumpsByOil(?, ?, ?, ?, ?)';
				break;
			case 'electricity':
				sql = 'CALL SearchForPumpsByElectricity(?, ?, ?, ?, ?)';
				break;
		}

		pool.getConnection(function(err, client){
			if (err){ logger.log('error', 'SEARCH fuel pool: %s', err.stack); }

			var inserts = [heatpumpCategory1, heatpumpCategory2, parseInt(heatingType), parseInt(fuelConsumption), parseInt(previouslyHotWater)];
			final_sql = mysql.format(sql, inserts);

			var query = client.query(final_sql, function (error, results, fields){
				res.render('pages/searchResults', {
					title: "NTB Buchs | Wärmepumpen-Testzentrum Vergleichstool Suchergebnisse",
					queryResults: results[0],
					searchTitle: req.session.HEATPUMPTYPE_STR,
					compareList: req.session.COMPARE_LIST,
					isFuelSearch: 1
				});
				client.release();
			});

			query.on('error', (err) => { logger.log('error', 'SEARCH fuel query: %s', err.stack); });
		});
	}
});

/*
 * Route /compare/add
 * Handles "Add to Compare" checkboxes. 
 * Stores InfoID of heatpump in an array which is then put into a session variable. Sends response based on success/error
 */
server.post('/vergleichen/einfuegen', function(req, res){
	var list = req.session.COMPARE_LIST || [];
	var id = req.body.id;
	var bedingungID = req.body.bedingungID;

	req.session.BEDINGUNG_ID = bedingungID;
	req.session.save();

	index = list.indexOf(id.toString());
	if(index > -1){						// Exists in array, remove
		list.splice(index, 1);
		req.session.COMPARE_LIST = list;
		req.session.save();
		res.send(JSON.stringify({status: "success"}));
	}
	else{
		if(list.length >= 5){			// Attempting to exceed limit
			var errorJSON = [];
			item = {};
			item ["msg"] = "Sie können nur bis fünf Wärmepumpen vergleichen.";
			errorJSON.push(item);
			res.send(JSON.stringify({errors: errorJSON, status: "error"}));
		}
		else{
			list.push(id);				// New value, add
			req.session.COMPARE_LIST = list;
			req.session.save();
			res.send(JSON.stringify({status: "success"}));
		}
	}
});

/* Route /table/delete/:id */
server.get('/table/delete/:id', checkAuth, function(req, res, next){
	var id = req.params.id;
	var redirect = '/' + req.session.CURRENT_TABLE;
	var sql = 'DELETE FROM ' + req.session.CURRENT_TABLE + ' WHERE ' + req.session.FIRST_COLUMN + " = ?";
	execute_query(req, res, sql, id, redirect);
});

/* Route /table/add (SUBMIT) */
server.post('/table/add', checkAuth, function(req, res, next){
	var keys = Object.keys(req.body);	// Array of keys
	var reqBodyLength = keys.length;	// Number of parameters in req.body
	values = [];						// Array of values

	for(var key in req.body) {			// Get values
		if(req.body[key] === '' || req.body[key] === null){	// Replace empty input with nullS
			values.push(null);
		}
		else{
			values.push(req.body[key]);
		}
	}

	pool.query("SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT, COLUMN_COMMENT FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = '" + req.session.CURRENT_TABLE + "' AND table_schema = 'WPZ_Database_Prototype'", function (error, results, fields){
		var errors = validate_IS_NULLABLE(values, keys, results);
		
		if(errors.length > 0){
			res.send(JSON.stringify({errors: errors, status: "error"}));
		}
		else{
			var sql = 'INSERT INTO ' + req.session.CURRENT_TABLE + ' ( ';

			for(var i = 0; i < (reqBodyLength - 2); i++){
				sql += keys[i] + ', ';
			}
			sql += keys[reqBodyLength - 2] + ' ) VALUES ( ';

			for(var k = 0; k < (reqBodyLength - 2); k++){
				sql += '?, ';
			}
			sql += '? )';

			execute_query(req, res, sql, values);
		}
	});
});

/* Route /table/edit/details/:id (EDIT LOAD) */
server.post('/table/edit/details/:id', checkAuth, function(req, res, next){
	var id = req.params.id;
	var sql = 'SELECT * FROM ' + req.session.CURRENT_TABLE + " WHERE " + req.session.FIRST_COLUMN + " = ?";
	execute_query(req, res, sql, id);
});

/* Route /table/edit/update (EDIT SUBMIT) */
server.post('/table/edit/update', checkAuth, function(req, res, next){
	var keys = Object.keys(req.body);	// Array of keys
	var reqBodyLength = keys.length;	// Number of parameters in req.body
	var values = [];					// Array of values

	for(var key in req.body) {			// Get values
		if(req.body[key] === '' || req.body[key] === null){	// Replace empty input with nullS
			values.push(null);
		}
		else{
			values.push(req.body[key]);
		}
	}

	pool.query("SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT, COLUMN_COMMENT FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = '" + req.session.CURRENT_TABLE + "' AND table_schema = 'WPZ_Database_Prototype'", function (error, results, fields){
		var errors = validate_IS_NULLABLE(values, keys, results);
		
		if(errors.length > 0){
			res.send(JSON.stringify({errors: errors, status: "error"}));
		}
		else{
			var sql = 'UPDATE ' + req.session.CURRENT_TABLE + ' SET ';

			for(var i = 0; i < (reqBodyLength - 2); i++){	// Account for ID at end of values
				sql += keys[i] + ' = ?, ';
			}
			sql += keys[reqBodyLength - 2] + ' = ? WHERE ' + req.session.FIRST_COLUMN + " = ?";

			execute_query(req, res, sql, values);			
		}
	});
});

/*
 * Renders the table view with the appropriate parameters
 * @param req Initial request
 * @param res Response
 * @tableName Name of the table to be rendered
 * @idCol Name of the primary key (ID) column in the table
 */
function render_table_view(req, res, tableName, idCol){
    pool.getConnection(function(err, client){
		if (err){ logger.log('error', 'DMB TABLE pool: %s', err.stack); }

		// Get first column of table to ORDER BY
		var query = client.query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = '" + tableName + "' AND table_schema = 'WPZ_Database_Prototype' LIMIT 1", function (error, results, fields){
			req.session.FIRST_COLUMN = results[0].COLUMN_NAME;
			req.session.save();
		});

		// Fetch all of table
		query = client.query('SELECT * FROM ' + tableName + " ORDER BY '" + req.session.FIRST_COLUMN + "' ASC", function (error, results, fields){
			req.session.CURRENT_TABLE = tableName;
			req.session.save();
			res.render('pages/tableDataView', {
				title: "NTB Buchs | Wärmepumpen-Testzentrum Vergleichstool Instandhaltung - Institut IES",
				queryResults: results,
				idColumn: idCol
			});
			client.release();
		});

		query.on('error', (err) => { logger.log('error', 'DMB TABLE query: %s', err.stack); });
	});
}

/*
 * Validates if user input is allowed to be null or not and compiles a list of corresponding errors
 * @param values User input values
 * @param keys Keys that match column names
 * @param results Results from validation query
 * @return JSON list of errors
 */
function validate_IS_NULLABLE(values, keys, results){
	var errorJSON = [];

	for(var i = 1; i < results.length; i++){
		if(values[i-1] === null && results[i].IS_NULLABLE === 'NO'){
			item = {};
			item ["msg"] = keys[i-1] + ' ist erforderlich';
			errorJSON.push(item);
		}
	}

	return errorJSON;
}

/*
 * Executes sql query and sends response to current page or redirects to given url. Does not render pages.
 * @param res Response variable from handler
 * @param sql SQL string to execute
 * @param inserts data to be inserted into sql
 * @param redirect where to direct response to (OPTIONAL, DEFAULTS TO NORMAL RESPONSE)
 */
function execute_query(req, res, sql, inserts, redirect = false){
	pool.getConnection(function(err, client){
		if (err){ logger.log('error', 'execute_query() pool: %s', err.stack); }

		final_sql = mysql.format(sql, inserts);

		var query = client.query(final_sql, function (error, results, fields){
			if(error){			// Error
				res.send(JSON.stringify({results: results, errors: error, status: "queryError"}));
			}
			else{
				//Execute Python Script IF sql contains SELECT
				if(sql.toLowerCase().search('select') != 0)
				{
					exportExcel();
				}
				if(redirect){	// Success, redirect if given (Force url back to origin)
					res.redirect(redirect);
				}
				else{			// Success, stay on and page and send data
					res.send(JSON.stringify({results: results, errors: error, status: "success"}));
				}
			}
			client.release();
			logger.log('info', '## execute_query() ## [SESSIONID: %s] [USERNAME : %s] [QUERY : %s]', req.sessionID, req.session.USERNAME, final_sql);
		});

		query.on('error', (err) => { logger.log('error', 'execute_query() query: %s', err.stack); });
	});	
}

/*
 * Checks if user has been authenticated
 */
function checkAuth(req, res, next) {
	if (!req.session.USERNAME) {
		res.render('pages/login', {
			title: "NTB Buchs | Wärmepumpen-Testzentrum Vergleichstool Anmeldung"
		});
	} else {
		res.header('Cache-Control', 'no-cache, private, no-store, must-revalidate, max-stale=0, post-check=0, pre-check=0');
		next();
	}
}

/*
 * Creates or updates Microsoft Excel spreadsheets of heat pump test result data
 */
function exportExcel() {
    var exportFolder = 'export\\'; // location of logos and export script
    var downloadFolder = 'public\\downloads\\'; // folder to write Excel files to
    var authString = 'mysql+pymysql://root:admin@localhost:3306/wpz_database_prototype'; 
    
    var options = {args: [authString, exportFolder, downloadFolder]};
    pythonShell.run(exportFolder+'export.py', options, function (err, results) {
        if (err) logger.log('error', 'exportExcel(): %s', err.stack);
    });           
}

/* Starts the server */
server.listen(3000, function(){
	logger.log('info', '%s', 'Server Started | localhost:3000');
	console.log("### Server Started | localhost:3000");
});

/* 404 Handler. Sends a 404 response if no response has been sent by this point */
server.use(function(req, res, next){
  	res.status(404);
	res.render('pages/404', {
		title: "NTB Buchs | 404"
	});
});

/* Shuts the server down gracefully by catching the CTRL+C event */
process.on('SIGINT', function() {
	console.log( "### Intercepted SIGINT" );
	logger.log('info', '%s', '### Intercepted SIGINT');	
	pool.end(function (err) {	// End all pool client connections, permanently closes DB connection
		if(err) throw err;
	});
	process.exit();
});

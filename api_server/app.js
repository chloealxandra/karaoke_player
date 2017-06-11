var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var request = require('request');

// configure app to use bodyParser()
// this will let us get the data from a POST
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

var port = process.env.PORT || 8080;        // set our port

var room_ips = ["http://192.168.1.18/", "ip1", "ip2", "ip3", "ip4"] //array of private ips for kjams machines


// ROUTES FOR OUR API
// =============================================================================
var router = express.Router();              // get an instance of the express Router

// middleware to use for all requests
router.use(function(req, res, next) {
    // do logging
    console.log('Responding to an API request');
    next(); // make sure we go to the next routes and don't stop here
});

// test route to make sure everything is working (accessed at GET http://localhost:8080/api)
router.get('/', function(req, res) {
    res.json({ message: 'api for the lighthouse' });   
});

router.get('/', function(req, res) {
    res.json({ message: 'api for the lighthouse' });   
});


// more routes for our API will happen here
router.route('/new_session')

  // create a new singer/session
  .post(function(req, res) {
      
    var room = req.body.room;  // room comes from the request
    var session = req.body.sessionId; //generated sessionId token gets passed as singer

    // send the request
    request.post(room_ips[room]+'newsinger', {form: {singername: session, password: session, confirm: session, submit: 'Jam Out!'}}, function (error, response, body) {
      console.log ('sending session '+session+' to url: '+room_ips[room]+'/newsinger');
      if(error) {
        res.json(error);
      }else{
        res.json(response);
      }
    })
      
  });

// REGISTER OUR ROUTES -------------------------------
// all of our routes will be prefixed with /api
app.use('/api', router);

// START THE SERVER
// =============================================================================
app.listen(port);
console.log('Serving kjams api on port: ' + port);


// API NOTES
// all requests need to be x-www-form-urlencoded


// NEW SINGER:
// /newsinger

// singername=webtest&password=webtest&confirm=webtest&submit=Jam+Out%21


// LOGGING IN:

// /singers returns list of singers

// singer id is keyed as siID


// singer=[siID]&password=[password]&submit=Login

// http://192.168.0.26/main?singer=181832&password=poly800&submit=Login


// singer=181832&password=poly800&submit=Login

// LOGGING OUT:

// /logout

// SEARCHING:
// http://192.168.0.26/search?search=s

// ADDING TO TONIGHT QUEUE:
// after searching - need the soID key (int) ex 10463

// http://192.168.0.26/drop?playlist=[siID]&song=[soID]

// repitching a song that's in a playlist:

// http://192.168.0.26/pitch?song[soID]&pitch[signed int]
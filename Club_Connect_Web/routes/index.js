var express = require('express');
var router = express.Router();
var Kinvey = require('kinvey-node-sdk');

Kinvey.init({
  appKey: 'kid_HkRu7Qkkl',
  appSecret: 'fa298122b975486c8ba15d9d8b4c52f5'
});

var kinveyInit = function(){
	var promise = new Promise(function(resolve) {
  	resolve(Kinvey.User.getActiveUser());
	});

	promise = promise.then(function onSuccess(user) {
	  if (user) {
	    return user.me();
	  }
	  return user;
	}).then(function onSuccess(user) {
			console.log(user)
			kinveyInitHelper(user);
		}).catch(function onError(error) {
			console.log(error)
		});
}
kinveyInit();

var kinveyInitHelper = function(user){
	if (user == null) {
		var user = new Kinvey.User();
		var promise = user.signup({
		  username: 'username',
		  password: 'password'
		}).then(function onSuccess(user) {
			console.log("logged in")
		}).catch(function onError(error) {
			handleKinveySignUpError();
		});
	}
	else{
	}
}

var getKinveyEventData = function(id){
	var dataStore = Kinvey.DataStore.collection('Event');
	var query = new Kinvey.Query();
	query.equalTo('event_fb_id', id);
	var stream = dataStore.find(query);
	stream.subscribe(function onNext(entities) {
		  console.log(entities);

		  if(entities && entities.length){
		  	kinveyData.data = entities;
		  	kinveyData.status = 0;
		  }
		  else{
		  	kinveyData.data = [];
		  	kinveyData.status = -2;
		  }
		}, function onError(error) {
		  console.log(error)
		}, function onComplete() {
		  console.log("complete")
	});
}

var handleKinveySignUpError = function(error){
		var promise = Kinvey.User.login('username', 'password').then(function onSuccess(user) {
    console.log("logged in");
		}).catch(function onError(error) {
  		console.log(error);
	});
}

var kinveyData = {
	status: -1,	//0 for success, -1 for waiting, -2 for empty
	data: []
};

var options = {
    timeout:  3000
  , pool:     { maxSockets:  Infinity }
  , headers:  { connection:  "keep-alive" }
};

var userEvents = []

module.exports = function (passport, graph) {
	router.get('/auth/facebook', passport.authenticate('facebook'));

	router.get('/auth/facebook/callback', passport.authenticate('facebook'), function (req, res) {
		passport.session.user = req.user;
		res.redirect('/success');
	});

	router.get('/success', function(req, res, next) {
		graph.setOptions(options).get("/" + passport.session.user.id + "/events", function(err, events) {
			if (err) {
				res.end(err);
			}
			else {
				userEvents.push.apply(userEvents, events.data);
			    res.render('dashboard.ejs', {
				  	events: events.data,
				});
			}
		});
	});

	router.get('/error', function(req, res, next) {
	  res.send("Error logging in.");
	});

	router.get('/events/:id', function (req, res) {
		var id = req.url.split('/')[2];
		// pass that as array to event.ejs
		// event.ejs uses jquery and d3.js to chart
		getKinveyEventData(id)

		graph.setOptions(options).get("/" + id + "?fields=attending_count,declined_count,interested_count,noreply_count", function(err, data) {
			if (err) {
				res.end(err);
			}
			else {
				for (var i = 0; i < userEvents.length; i++) {
					if (id == userEvents[i].id) {
						for (var key in userEvents[i]) {
							data[key] = userEvents[i][key];
						}
						/*
						data is JSON object with following properties:
							attending_count
							declined_count
							noreply_count
							id
							description
							end_time
							name
							place (json object)
							start_time
							rsvp_status
						*/
						res.render('event.ejs', {
							event: data,
						});
					}
				}
				res.end("Invalid event");
			}
		});
	});

	router.get('/', function(req, res, next) {
		res.render('home');
	});

	router.post('/events/get_kinvey_data/', function(req,res){
		console.log(kinveyData);
		res.send(kinveyData);
	});

	return router;
}

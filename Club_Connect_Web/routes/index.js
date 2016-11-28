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
	  	console.log("active user exists")
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
		var promise = Kinvey.User.login('username', 'password').then(function onSuccess(user) {
    console.log("logged in");
    kinveySaveData();
		}).catch(function onError(error) {
  		console.log(error);
  		handleKinveySignInError();
	});
	}
	else{
	}
}

//used to save data, edit as needed
var kinveySaveData = function(){
	var dataStore = Kinvey.DataStore.collection('Event');
		var promise = dataStore.save({
			//add data to save here
		}).then(function onSuccess(entity) {
		  // ...
		  console.log(entity)
		}).catch(function onError(error) {
		  // ...
		  console.log(error)
		});
}


var getKinveyEventData = function(id){
	var dataStore = Kinvey.DataStore.collection('Event');

	var query = new Kinvey.Query();
	query.equalTo('event_fb_id', id);
	var stream = dataStore.find(query);
	stream.subscribe(function onNext(entities) {

		  if(entities && entities.length){
		  	var attendee_ids = entities.map(function(a){
		  		return a.attendee_id;
		  	});

				var dataStore2 = Kinvey.DataStore.collection('secondary');
				var query2 = new Kinvey.Query();
				query2.contains("UID", attendee_ids);
				var stream2 = dataStore2.find(query2);
				stream2.subscribe(function onNext(entities) {

				var majors = entities.map(function(a){
		  		return a.major;
		  	});

		  	var ages = entities.map(function(a){
		  		return a.age;
		  	});

					kinveyData.data = {
						"majors": majors,
						"ages": ages
					};
		  		kinveyData.status = 0;
				}, function onError(error) {
				  console.log(error)
				}, function onComplete() {
				  console.log("Complete Secondary Query")
				});
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

var handleKinveySignInError = function(){
	var user = new Kinvey.User();
	var promise = user.signup({
  'username': 'username',
  'password': 'password'
	}).then(function onSuccess(user) {
		console.log("sign up default user")
	}).catch(function onError(error) {
		console.log(error)
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
		getKinveyEventData(id);
		var query = new Kinvey.Query();
		query.equalTo('last_name', 'query');
		// var promise = Kinvey.User.find(query, {
		// 	discover: true,
		// });

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

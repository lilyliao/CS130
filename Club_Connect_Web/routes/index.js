var express = require('express');
var router = express.Router();
var Kinvey = require('kinvey-node-sdk');

Kinvey.init({
  appKey: 'kid_HkRu7Qkkl',
  appSecret: 'fa298122b975486c8ba15d9d8b4c52f5'
});

var promise = Kinvey.ping().then(function(response) {
  console.log('Kinvey Ping Success. Kinvey Service is alive, version: ' + response.version + ', response: ' + response.kinvey);
}).catch(function(error) {
  console.log('Kinvey Ping Failed. Response: ' + error.description);
});

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
		for (var i = 0; i < userEvents.length; i++) {
			if (id == userEvents[i].id) {
				res.render('event.ejs', {
					event: userEvents[i],
				});
			}
		}
		res.end("Invalid event id");
	});

	router.get('/', function(req, res, next) {
		res.redirect('/auth/facebook');
	});

	return router;
}

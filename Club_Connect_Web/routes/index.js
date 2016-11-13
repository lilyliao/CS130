var express = require('express');
var router = express.Router();

module.exports = function (passport) {
	router.get('/auth/facebook', passport.authenticate('facebook'));

	router.get('/auth/facebook/callback', passport.authenticate('facebook'), function (req, res) {
		passport.session.user = req.user;
		res.redirect('/success');
	});

	router.get('/success', function(req, res, next) {
		console.log(passport.session.user);
	  res.render('dashboard.ejs', {
	  	user: passport.session.user
	  });
	});

	router.get('/error', function(req, res, next) {
	  res.send("Error logging in.");
	});

	router.get('/', function(req, res, next) {
	  res.render('index.ejs');
	});

	return router;
}

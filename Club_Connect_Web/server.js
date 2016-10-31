var express = require('express');
var app = express();

app.use(express.static('public'));

app.get('/', function(req, res) {
    res.sendFile('index.html', { root: __dirname } );
});

app.listen(3000, function() {
    console.log('Our app is running on http://localhost:' + 3000);
});
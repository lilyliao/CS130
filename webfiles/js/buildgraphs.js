var margin = {top: 20, right: 20, bottom: 30, left: 40},
	width = 960 - margin.left - margin.right,
	height = 500 - margin.top - margin.bottom;

var formatPercent = d3.format(".0%");

var xValue = function(d) { return d.name; }, // data -> value
	xScale = d3.scale.ordinal().rangeRoundBands([0, width], .1), // value -> display
	xMap = function(d) { return xScale(xValue(d)); }, // data -> display
	xAxis = d3.svg.axis().scale(xScale).orient("bottom");

var yValue = function(d) { return d.frequency; }, // data -> value
	yScale = d3.scale.linear().range([height, 0]), // value -> display
	yMap = function(d) { return yScale(yValue(d)); }, // data -> display
	yAxis = d3.svg.axis().scale(yScale).orient("left").tickFormat(formatPercent);

var svg = d3.select(".graph").append("svg")
		.attr("width", width + margin.left + margin.right)
		.attr("height", height + margin.top + margin.bottom)
	.append("g")
		.attr("transform", "translate(" + margin.left + "," + margin.top + ")");


// var alpha = "abcdefghijklmnopqrstuvwxyz".toUpperCase().split("");
// var freq = [.08167,.01492,.02780,.04253,.12702,.02288,.02022,.06094,.06973,
// 			.00153,.00747,.04025,.02517,.06749,.07507,.01929,.00098,.05987,
// 			.06333,.09056,.02758,.01037,.02465,.00150,.01971,.00074];


// arrays holding individual data points from tsv file
var users = [];
var UserID = [];
var Email = [];
var Year = [];
var Major = [];

// load in data from a tsv file
d3.tsv("users.tsv", type, function(error, info) {
	for (var i = info.length - 1; i >= 0; i--) {
		UserID[i] = info[i].UserID;
		Year[i] = info[i].Year;
		Major[i] = info[i].Major;
		Email[i] = info[i].Email;
	}

	users = info;
});

var events = [];
var EventID = [];
var StartTime = [];
var EndTime = [];
var DayOfWeek = [];
var RSVP = [];
var Attended = [];
var Location = [];
var Food = [];

// load in data from a tsv file
d3.tsv("events.tsv", typeEvent, function(error, info) {
	
	for (var i = info.length - 1; i >= 0; i--) {
		EventID[i] = info[i].EventID;
		StartTime[i] = info[i].StartTime;
		EndTime[i] = info[i].EndTime;
		DayOfWeek[i] = info[i].DayOfWeek;
		RSVP[i] = info[i].RSVP;
		Attended[i] = info[i].Attended;
		Location[i] = info[i].Location;
		Food[i] = info[i].Food;
	}

	events = info;
});

// change the type of certain parameters to numeric
function type(d) {
	d.UserID = +d.UserID;
	d.Year = +d.Year;
	return d;
}

// change the type of certain parameters to numeric
function typeEvent(d) {
	d.RSVP = +d.RSVP;
	d.Attended = +d.Attended;
	d.EventID = +d.EventID;
	d.StartTime = +d.StartTime;
	d.EndTime = +d.EndTime;

	return d;
}

// create a mapping between the frequency of each item, and the name of the item
// input: array of data from tsv file
// output: object array with parameter and its frequency
function distribute(arr) {
	var a = [], b = [], prev;

	arr.sort();

	for ( var i = 0; i < arr.length; i++ ) {
		if ( arr[i] !== prev ) {
			a.push(arr[i]);
			b.push(1);
		} else {
			b[b.length-1]++;
		}
		prev = arr[i];
	}
	for (var i = 0; i < b.length; i++) {
		b[i] = b[i] / arr.length;
	}

	var foo = [];
	for (var i = 0; i < a.length; i++) {
		foo.push({
			frequency: b[i],
			name: a[i]
		});
	}

	return foo;
}

function sum(arr) {
	var total = 0;
	for ( var i = 0; i < arr.length; i++ ) {
		total += arr[i];
	}
	return total;
}

function sumVSum(a1, a2, name1, name2) {
	var x = sum(a1);
	var y = sum(a2);
	var map = [];
	map.push({
		frequency: x,
		name: name1
	});
	map.push({
		frequency: y,
		name: name2
	});
	return map;
}

function getUniqueElem(arr) {
	var a = [], prev;

	arr.sort();
	for ( var i = 0; i < arr.length; i++ ) {
		if ( arr[i] !== prev ) {
			a.push(arr[i]);
		}
		prev = arr[i];
	}

	return a;
}

function foo(arr) {
    var a = [], b = [], prev;

    arr.sort();
    for ( var i = 0; i < arr.length; i++ ) {
        if ( arr[i] !== prev ) {
            a.push(arr[i]);
            b.push(1); 
        } else {
            b[b.length-1] += Attended[i];
        }
        prev = arr[i];
    }

    return [a, b];
}

var data = distribute(Major); // Year, Major




/*

	Checkboxes on main page in order to decide which graph to display
	if marked, sets variable to true, and calls update() on graph
	switch statement to choose variables for graph based on checked
	pick two variables from a file to build graph

*/


$(".choose").change(function() {
	$(".choose").not(this).prop("checked", false);
	if(this.checked) {
		// console.log($(".choose:checked").val());

		if ($(".choose:checked").val() == 1) {
			// console.log("swtich to year");
			data = distribute(Year);
		} else if ($(".choose:checked").val() == 2) {
			// console.log("swtich to major");
			data = distribute(Major);
		} else if ($(".choose:checked").val() == 3) {
			yAxis = d3.svg.axis().scale(yScale).orient("left");
			data = sumVSum(RSVP, Attended, "RSVP", "Attended");
		} else if ($(".choose:checked").val() == 4) {
			yAxis = d3.svg.axis().scale(yScale).orient("left");
			var count = [0, 0, 0, 0, 0, 0, 0];
			var day = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
			for (var i = 0; i < DayOfWeek.length; i++) {
				switch (DayOfWeek[i]) {
					case "Sunday":
						count[0] += Attended[i];
						break;
					case "Monday":
						count[1] += Attended[i];
						break;
					case "Tuesday":
						count[2] += Attended[i];
						break;
					case "Wednesday":
						count[3] += Attended[i];
						break;
					case "Thursday":
						count[4] += Attended[i];
						break;
					case "Friday":
						count[5] += Attended[i];
						break;
					case "Saturday":
						count[6] += Attended[i];
						break;
				}
			}
			var map = [];
			for (var i = 0; i < 7; i++) {
				map.push({
					frequency: count[i],
					name: day[i]
				});
			}
			data = map;
		} else if ($(".choose:checked").val() == 5) {
			yAxis = d3.svg.axis().scale(yScale).orient("left");
			var a = getUniqueElem(Food);
			var b = new Array(a.length).fill(0);
			for (var i = 0; i < Food.length ; i++) {
				b[a.indexOf(Food[i])] += Attended[i];
			}
			
			var map = [];
			for (var i = 0; i < a.length; i++) {
				map.push({
					frequency: b[i],
					name: a[i]
				})
			}
			data = map;
		}

		var rects = svg.selectAll("rect").data(data, function(d) { return d; });
		var axes  = svg.selectAll("text").data(data, function(d) { return d; });

		svg.selectAll("rect").remove();
		svg.selectAll("g").remove();

		xScale.domain(data.map(xValue));
		yScale.domain([0, d3.max(data, yValue)]);

		svg.append("g")
			.attr("class", "x axis")
			.attr("transform", "translate(0," + height + ")")
			.call(xAxis);

		svg.append("g")
				.attr("class", "y axis")
				.call(yAxis)
			.append("text")
				.attr("transform", "rotate(-90)")
				.attr("y", 6)
				.attr("dy", ".71em")
				.style("text-anchor", "end")
				.text("Frequency");


		svg.selectAll(".bar")
				.data(data)
			.enter().append("rect")
				.attr("class", "enter")
				.attr("class", "bar")
				.attr("x", xMap)
				.attr("width", xScale.rangeBand)
				.attr("y", yMap)
				.style("fill-opacity", 1e-6)
			.transition()
				.duration(250)
				.attr("height", function(d) { return height - yMap(d); })
				.style("fill-opacity", 1);


		svg.selectAll(".bar")
				.data(data)
			.exit()
					.attr("class", "exit")
				.transition()
					.duration(250)
					.attr("height", 0)
					.style("fill-opacity", 1e-6)
					.remove();

	}
});




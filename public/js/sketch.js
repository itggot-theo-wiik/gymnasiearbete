function setup() {
	// Dates
	x = ["datum 1", "datum 2", "datum 3", "datum 4", "datum 5", "datum 6", "datum 7"];

	// Weights
	y = [-10, 45, 46.83, 45, 110.8, 120, 140];
	sorted_y = [-10, 45, 45, 46.83, 110.8, 120, 140];

	// Height and width of box/canvas
	width = 640;
	height = 360;

	circle_diameter = 13;

	// Frame
	height_percentage = 0.7;
	width_percentage = 0.9;

	// Create the canvas
	// createCanvas(width, height);

	
	// START OF DANGER
	var cnv = createCanvas(width, height);
	cnv.parent("sketchHolder");

	// var cnv2 = createCanvas(width, height);
	// cnv2.parent("sketchHolder2");
	// END OF DANGER


	// Calculate the step length in pixels in x-axis
	// step = (width / (x.length - 1)) - 16;
	step = step_calc()
};

function draw() {
	// Background and axis lines (and the text)
	background(12, 247, 161);
	background(0, 202, 81);
	// line(0, (height * 0.1), 0, (height * 0.9));
	// text(sorted_y[y.length - 1].toString(), 0, height * 0.1 - 5);
	// text(sorted_y[0].toString(), 0, height * 0.9 - 5);

	// Top
	// line(0, 36, 25, 36);
	// Bottom
	// line(0, 324, 25, 324);

	// First line
	current_x = 0.5 * (width - (width * width_percentage));
	current_y = y_pos(0);

	// Lines
	i = 0;
	while (i < x.length) {
		i++;
		// The line
		line(current_x, current_y, (current_x + step), y_pos(i));
		strokeWeight(3);

		textSize(16);

		// The texts
		// KG
		text(y[i - 1] + " KG", current_x - 15, current_y - 15);
		fill(255, 255, 255);
		// DATE
		text(x[i - 1], current_x - 15, height - 15);

		// New positions
		current_x = (current_x + step);
		current_y = y_pos(i);
	};

	current_x = 0.5 * (width - (width * width_percentage));
	current_y = y_pos(0);

	// Dots
	i = 0;
	while (i < x.length) {
		i++;
		ellipse(current_x, current_y, circle_diameter, circle_diameter);

		// New positions
		current_x = (current_x + step);
		current_y = y_pos(i)
	};
};

function y_pos(i) {
	return ((height) - ((height * height_percentage) * ((y[i] - sorted_y[0]) / (sorted_y[sorted_y.length - 1] - sorted_y[0]))) - (height * (0.5 * (1 - height_percentage))));
};

function step_calc() {
	return ((width * width_percentage) / x.length);
};
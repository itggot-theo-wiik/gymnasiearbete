function setup() {
	// Dates
	x = ["datum 1", "datum 2", "datum 3"];

	// Weights
	y = [35, 52, 18];
	sorted_y = [18, 35, 52];

	// Height and width of box/canvas
	width = 640;
	height = 360;

	// Calculate the ratio
	y_ratio = pixel_per_kg_ratio(height, y);
	print("Ratio:");
	print(y_ratio);

	console.log("Ratio:");
	console.log(y_ratio);

	// Create the canvas
	createCanvas(width, height);

	// Calculate the step length in pixels in x-axis
	step = (width / (x.length - 1));

	// Debugg
	// print(step);
};

function draw() {
	// Background and axis lines (and the text)
	background(12, 247, 161);
	line(0, (height * 0.1), 0, (height * 0.9));
	text(sorted_y[y.length - 1].toString(), 0, height * 0.1);
	text(sorted_y[0].toString(), 0, height * 0.9);

	// Top
	line(0, 36, 50, 36);
	// Bottom
	line(0, 324, 50, 324);

	// First line
	current_x = 0;
	current_y = ((height * 0.9) - (y[0] * y_ratio));
	// 

	print(current_y);

	i = 0;
	while (i <= x.length) {
		i++;
		// The line
		line(current_x, current_y, (current_x + step), ((height * 0.9) - (y[i] * y_ratio)));

		// The texts
		// KG
		text(y[i - 1] + " KG", current_x, current_y - 15);
		// DATE
		text(x[i - 1], current_x, height - 15);

		// New positions
		current_x = (current_x + step);
		current_y = ((height * 0.9) - (y[i] * y_ratio));
	};
};

function pixel_per_kg_ratio(height, y) {
	var availible = (height * 0.8);
	pixel_per_kg_ratio = (availible / (sorted_y[sorted_y.length - 1] - sorted_y[0]));
	return pixel_per_kg_ratio;
};





















function sorter(arr) {
	sorted = false;

	while (sorted != true) {
		swap = false;
		var times = (arr.length - 1);
		for (var i = 0; i < times; i++) {
			if (arr[i] > arr[i + 1]) {
				var temp = arr[i];
				arr.splice(i, 1, arr[i + 1]);
				arr.splice(i + 1, 1, temp);
				swap = true;
			};
		};

		// If no swap, it is sorted!
		if (swap != true) {
			sorted = true;
		};
	};

	return arr;
};
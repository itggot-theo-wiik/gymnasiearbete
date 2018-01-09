function setup() {
	x = ["datum 1", "datum 2", "datum 3"];
	y = [76, 1, 50];
	width = 640;
	height = 360;
	pixel_per_kg_ratio(height, y);
	createCanvas(width, height);
	step = (width / (x.length - 1));
	print(step);
};

function draw() {
	background(255, 122, 33);
	line(0, (height * 0.1), 0, (height * 0.9));

	print(y);

	var sorted_y = y.sort();

	print(y);
	text(sorted_y[y.length - 1].toString(), 0, height * 0.1);
	text(sorted_y[0].toString(), 0, height * 0.9);

	// First line
	current_x = 0;
	current_y = (((height - y[0]) - (height * 0.1)));

	i = 0;
	while (i <= x.length) {
		i++;
		line(current_x, current_y, (current_x + step), ((height - y[i]) - (height * 0.1)));
		current_x = (current_x + step);
		current_y = ((height - y[i]) - (height * 0.1));
	};
};

function pixel_per_kg_ratio(height, y) {
	y = y.sort;
	availible = (height * 0.8);
	pixel_per_kg_ratio = (availible / (y[0] - y[y.length - 1]));
	return pixel_per_kg_ratio;
};
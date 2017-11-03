x = [];
y = [];

var times = rand();
for(var i=0; i < times; i++){
    x.push(i);
    y.push(50 + rand());
};

if (rand() > 10) {
    var color = ["#64ffda", "#9effff"];
} else {
    var color = ["#40ff80", "#83ffb1"];
};

drawGraph(x, y, color)

function rand() {
    return Math.floor((Math.random() * 20) + 1)
};

function drawGraph(x, y) {
    const CHART = document.getElementById('lineChart');
    let lineChart = new Chart(CHART, {
        type: 'line',
        data: {
            labels: x,
            datasets: [
                {
                    label: "Kilogram",
                    borderColor: color[0],
                    backgroundColor: color[1],
                    data: y,
                }
            ],
        }
    });
}
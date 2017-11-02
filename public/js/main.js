const CHART = document.getElementById('lineChart');
console.log(CHART);
let lineChart = new Chart(CHART, {
    type: 'line',
    data: {
        labels: ["First one", "Second one", "Third one", "Fourth one"],
        datasets: [
            {
                label: "Kilogram",
                borderColor: "#40ff80",
                backgroundColor: "#83ffb1",
                data: [36,79,64,50],
            }
        ],
    }
});
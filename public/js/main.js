function dontRun() {
    x = [];
    y = [];

    var times = Math.floor(rand());
    for (var i = 0; i < times; i++) {
        x.push(i);
        y.push(50 + rand());
    };

    if (rand() > 10) {
        var color = ["#64ffda", "#9effff"];
    } else {
        var color = ["#40ff80", "#83ffb1"];
    };

    drawGraph(x, y, color)
}

function rand() {
    return Math.floor((Math.random() * 20) + 1)
};

// Show the graph
function drawGraph(x, y, color) {
    const CHART = document.getElementById('lineChart');
    let lineChart = new Chart(CHART, {
        type: 'line',
        data: {
            labels: x,
            datasets: [{
                label: "Kilogram",
                borderColor: color[0],
                backgroundColor: color[1],
                data: y,
            }],
        }
    });
};

// Parallax
$(document).ready(function () {
    $('.parallax').parallax();
});

// function doughnutChart() {
//     data = {
//         datasets: [{
//             data: [3, 21]
//         }],

//         labels: [
//             'KG kvar',
//             'KG förlorat'
//         ]
//     };

//     const PIE = document.getElementById('pieChart');
//     var myDoughnutChart = new Chart(PIE, {
//         type: 'doughnut',
//         data: data,
//         datasets: [{
//             backgroundColor: [
//                 '#ff6384',
//                 '#ff6384',
//             ]
//         }],
//         // options: options
//     });
// };

// Toggla skuggan
function toggle_shadow() {
    element = document.querySelector(".nav_main");
    element.classList.toggle("nav_shadow_is_visible");
};

// Toggla osynliga leave
function toggle_leave() {
    element = document.querySelector(".nav_leave");
    element.classList.toggle("nav_is_visible");
};

// Animera Hamburgar menyn
$(document).ready(function () {
    $("#burger").click(function () {
        $("nav").animate({
            left: '0px'
        });
    });
});

$(document).ready(function () {
    $(".nav_leave").click(function () {
        $("nav").animate({
            left: '-304px'
        });
    });
});

function show(id) {
    element = document.getElementById(id);
    element.classList.toggle("display_confirmation");
};

function session_show(id) {
    element = document.getElementById(id);
    element.classList.toggle("show");
};

function hide(id) {
    element = document.getElementById(id);
    element.remove();
};

// Run test

var x = document.getElementById("demo");

function getLocation() {
    if (navigator.geolocation) {
        navigator.geolocation.watchPosition(showPosition);
    } else {
        x.innerHTML = "Geolocation is not supported by this browser.";
    }
}

function showPosition(position) {
    x.innerHTML = "Latitude: " + position.coords.latitude +
        "<br>Longitude: " + position.coords.longitude;
}

function isNumberKey(evt) {
    var charCode = (evt.which) ? evt.which : event.keyCode
    if (charCode > 31 && (charCode != 46 && (charCode < 48 || charCode > 57)))
        return false;
    return true;
}

function extremeFunction() {
    console.log("hekk");
}

extremeFunction()
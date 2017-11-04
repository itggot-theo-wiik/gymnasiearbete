function dontRun() {

    console.log("i am alvie")

    x = [];
    y = [];
    
    var times = Math.floor((Math.random() * 20) + 1);
    for(var i=0; i < times; i++){
        x.push(i);
        y.push(50 + rand());
    };
    
    if (Math.floor((Math.random() * 20) + 1) > 10) {
        var color = ["#64ffda", "#9effff"];
    } else {
        var color = ["#40ff80", "#83ffb1"];
    };
    
    drawGraph(x, y, color)

}

function rand() {
    return Math.floor((Math.random() * 20) + 1)
};

function drawGraph(x, y, color) {
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
};

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
$(document).ready(function() {
    $("#burger").click(function() {
        $("nav").animate({
            left: '0px'
        });
    });
});

$(document).ready(function() {
    $(".nav_leave").click(function() {
        $("nav").animate({
            left: '-304px'
        });
    });
});
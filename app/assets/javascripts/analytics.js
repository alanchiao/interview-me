/**
* Display graphs on user profile page
*/
$(document).ready(function(){
  if($('#profile').length > 0){
    var userid = $('#profile').attr('data-userid');
    var colorSet = ['#542437', '#952832','#F1EFA5','#4db585','#D3CE3D', '#F77825', '#554236'];
    var colorSet2 = ['#4db585','#952832'];
    CanvasJS.addColorSet("custom", colorSet);
    CanvasJS.addColorSet("custom2", colorSet2);
    // add doughnut chart of breakdown of type of problem a user has done
    // format json chart data
    var chartData = new Object();
    chartData.colorSet = "custom";
    chartData.data = new Array();
    var data_obj = new Object();
    data_obj.indexLabelFontSize = 14;
    data_obj.indexLabelPlacement = "outside";
    data_obj.type = "doughnut";
    data_obj.dataPoints = new Array();
    // get json data from user analytics model method
    var completedNoProblems = true;
    $.getJSON("/analytics/"+userid, function(data){
        $.each(data, function(key, value){
            data_obj.dataPoints.push({y: value[0], indexLabel: key});
            if(value[0]!=0){
                completedNoProblems = false;
            }
        });
        chartData.data.push(data_obj);
        if(!completedNoProblems){
            var chart = new CanvasJS.Chart("chartContainer",chartData);
            chart.render();
        }
        else{
            $("#chartContainer").html("<p style='font-size: 14px; padding:30px; position:relative; top:50%; margin-top:-50px; height: 100px;'>You have not completed any problems yet! No data to display.</p>");
        }
        
    });

    // add stacked bar chart
    // format chart data into json
    var chartData2 = new Object();
    chartData2.data = new Array();
    chartData2.colorSet = "custom2";
    var completed = new Object();
    completed.type = "stackedBar100";
    completed.name = "Completed";
    completed.showInLegend = true;
    completed.dataPoints = new Array();
    var noncompleted = new Object();
    noncompleted.type = "stackedBar100";
    noncompleted.name = "Incomplete";
    noncompleted.showInLegend = true;
    noncompleted.dataPoints = new Array();
    chartData2.axisX = new Object();
    chartData2.axisX.tickLength = 0;
    chartData2.axisX.gridThickness = 0;
    chartData2.axisX.labelFontSize = 14;
    chartData2.axisY = new Object();
    chartData2.axisY.tickLength = 0;
    chartData2.axisY.gridThickness = 0;
    chartData2.axisY.labelFontSize = 14;
    // get json data from user analytics model method
    $.getJSON("/analytics/"+userid, function(data){
        $.each(data, function(key, value){
            completed.dataPoints.push({y: value[0], label: key});
            noncompleted.dataPoints.push({y: value[1] - value[0], label: key});
        });
        chartData2.data.push(completed);
        chartData2.data.push(noncompleted);
        var chart = new CanvasJS.Chart("chartContainer2",chartData2);
        chart.render();
    });
  }
});
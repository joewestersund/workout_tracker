/*export default function selectWorkoutType(){
    alert('got here');
    var id = $("#SelectWorkoutType option:selected").val();
    alert("Hello. " + id);
} */


function ready()
{
    $('#select-workout-type').change(function(event){
        //var target = $('#select-workout-type-target').text();
        var id = $("#select-workout-type option:selected").val();
        window.location.href = "/workout_types/" + id + "/data_types"
    });
}

$(document).on('turbolinks:load', ready)

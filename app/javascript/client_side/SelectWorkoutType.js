export default function selectWorkoutType(){
    alert('got here');
    var id = $("#SelectWorkoutType option:selected").val();
    alert("Hello. " + id);
}

//'var id = $("#SelectWorkoutType option:selected").val(); window.location.href = id + "/routes" '

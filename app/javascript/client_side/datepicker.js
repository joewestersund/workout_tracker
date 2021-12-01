function ready() {
  init_datepicker = function(){
      $('.datepicker').datepicker({format: 'yyyy-mm-dd', todayBtn: "linked", autoclose: true});
  }
}

$(document).on('turbolinks:load', ready)
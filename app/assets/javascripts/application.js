// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui/widgets/sortable
//= require rails_sortable
//= require select2
//= require lodash
//= require toastr.min
//= require bootstrap-sprockets
// require ckeditor/init
//= require ckeditor/plugins/templates/plugin
//= require ckeditor/plugins/justify/plugin
//= require ckeditor/plugins/placeholder/plugin
//= require ckeditor/plugins/confighelper/plugin
//= require ckeditor/plugins/font/plugin
//= require ckeditor/plugins/panelbutton/plugin
//= require ckeditor/plugins/colorbutton/plugin
//= require ckeditor/plugins/ckeditor-bootstrap-collapsibleItem/plugin
//= require ckeditor/config
//= require_tree .
//= require jquery.remotipart 
//= require cocoon
//= require cookies_eu

function scrollToBottom(){
  if($('#messages').length > 0) {
    $('#messages').scrollTop($('#messages')[0].scrollHeight);
  }
}

function submitMessage(event){
   event.preventDefault();
   $('#new_message').submit();
}

function matchStart(params, data) {
  params.term = params.term || '';
  if (data.text.toUpperCase().indexOf(params.term.toUpperCase()) == 0) {
      return data;
  }
  return false;
}

$(document).on('keypress', '[data-behavior~=room_speaker]', function(event) {
   if (event.keyCode == 13) {
     submitMessage(event);
   }
});

$(document).on('click', '[data-send~=message]', function(event) {
   submitMessage(event);
});

$(document).on('load', function() {
  $("#new_message").on("ajax:complete", function(e, data, status) {
    $('#message_content').val('');
  })
  scrollToBottom();
});


$(function() {
  // Handler for .ready() called.
  $('a.toggle-password').on('click', function(e) {
    e.preventDefault()
    $(this).find('i').toggleClass("fa-eye fa-eye-slash")
    var input = $(this).parents('.show-password').find('input')
    if (input.attr("type") == "password") {
      input.attr("type", "text");
    } else {
      input.attr("type", "password");
    }
  })

  $('.u-content a').attr({"target" : "_blank"})

  $('#app_user_country').select2({
    theme: "bootstrap",
    matcher: function(params, data) {
      return matchStart(params, data);
    },
  });

  // CKEDITOR.plugins.addExternal( 'abbr', '/assets/placeholder', 'plugin.js' );
});

$(function() {
  $('.style-sortable, .ingredient-sortable, .allergen-sortable').railsSortable();
});

$(document).ready(function(){
  $( ".collapsible-item-title-link" ).each(function() {
    var icon = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-caret-down-fill" viewBox="0 0 16 16"> <path d="M7.247 11.14 2.451 5.658C1.885 5.013 2.345 4 3.204 4h9.592a1 1 0 0 1 .753 1.659l-4.796 5.48a1 1 0 0 1-1.506 0z"/> </svg>'
    if ($(this).find('span')[0] == undefined) {
      var color = '#007bff';
    } else {
      var eleColor = $(this).find('span')[0].style.color;
      if (eleColor == '') {
        var color = '#007bff';
      } else {
        var color = eleColor;
      }
    }
    $(this).attr('style', 'color:'+ color + '!important');
    $( this ).append(icon);
  });
});

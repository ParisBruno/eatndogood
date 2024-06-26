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
//= require ckeditor/plugins/colordialog/plugin
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
  $('.style-sortable, .ingredient-sortable, .allergen-sortable, .service-sortable').railsSortable();
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

var timer = setInterval(function () {
  var editor = $('.cke').length
  if (editor != 0) {
    var templateIcon = '<svg id="editorTemplateIcon" xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-file-earmark" viewBox="0 0 16 16"><path d="M14 4.5V14a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V2a2 2 0 0 1 2-2h5.5L14 4.5zm-3 0A1.5 1.5 0 0 1 9.5 3V1H4a1 1 0 0 0-1 1v12a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1V4.5h-2z"/></svg>'
    var leftIcon = '<svg id="editorLeftIcon" class="ck ck-icon ck-button__icon" viewBox="0 0 20 20"><path d="M2 3.75c0 .414.336.75.75.75h14.5a.75.75 0 1 0 0-1.5H2.75a.75.75 0 0 0-.75.75zm0 8c0 .414.336.75.75.75h14.5a.75.75 0 1 0 0-1.5H2.75a.75.75 0 0 0-.75.75zm0 4c0 .414.336.75.75.75h9.929a.75.75 0 1 0 0-1.5H2.75a.75.75 0 0 0-.75.75zm0-8c0 .414.336.75.75.75h9.929a.75.75 0 1 0 0-1.5H2.75a.75.75 0 0 0-.75.75z"></path></svg>'
    var centerIcon = '<svg id="editorCenterIcon" class="ck ck-icon ck-button__icon" viewBox="0 0 20 20"><path d="M2 3.75c0 .414.336.75.75.75h14.5a.75.75 0 1 0 0-1.5H2.75a.75.75 0 0 0-.75.75zm0 8c0 .414.336.75.75.75h14.5a.75.75 0 1 0 0-1.5H2.75a.75.75 0 0 0-.75.75zm2.286 4c0 .414.336.75.75.75h9.928a.75.75 0 1 0 0-1.5H5.036a.75.75 0 0 0-.75.75zm0-8c0 .414.336.75.75.75h9.928a.75.75 0 1 0 0-1.5H5.036a.75.75 0 0 0-.75.75z"></path></svg>'
    var rightIcon = "<svg id='editorRightIcon' class='ck ck-icon ck-button__icon' viewBox='0 0 20 20'><path d='M2 3.75c0 .414.336.75.75.75h14.5a.75.75 0 1 0 0-1.5H2.75a.75.75 0 0 0-.75.75zm0 8c0 .414.336.75.75.75h14.5a.75.75 0 1 0 0-1.5H2.75a.75.75 0 0 0-.75.75zm0 4c0 .414.336.75.75.75h9.929a.75.75 0 1 0 0-1.5H2.75a.75.75 0 0 0-.75.75zm0-8c0 .414.336.75.75.75h9.929a.75.75 0 1 0 0-1.5H2.75a.75.75 0 0 0-.75.75z'></path></svg>"
    var blockIcon = '<svg id="editorBlockIcon" class="ck ck-icon ck-button__icon" viewBox="0 0 20 20"><path d="M2 3.75c0 .414.336.75.75.75h14.5a.75.75 0 1 0 0-1.5H2.75a.75.75 0 0 0-.75.75zm0 8c0 .414.336.75.75.75h14.5a.75.75 0 1 0 0-1.5H2.75a.75.75 0 0 0-.75.75zm0 4c0 .414.336.75.75.75h9.929a.75.75 0 1 0 0-1.5H2.75a.75.75 0 0 0-.75.75zm0-8c0 .414.336.75.75.75h14.5a.75.75 0 1 0 0-1.5H2.75a.75.75 0 0 0-.75.75z"></path></svg>'
    var collapseIcon = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-arrows-expand" viewBox="0 0 16 16"><path fill-rule="evenodd" d="M1 8a.5.5 0 0 1 .5-.5h13a.5.5 0 0 1 0 1h-13A.5.5 0 0 1 1 8zM7.646.146a.5.5 0 0 1 .708 0l2 2a.5.5 0 0 1-.708.708L8.5 1.707V5.5a.5.5 0 0 1-1 0V1.707L6.354 2.854a.5.5 0 1 1-.708-.708l2-2zM8 10a.5.5 0 0 1 .5.5v3.793l1.146-1.147a.5.5 0 0 1 .708.708l-2 2a.5.5 0 0 1-.708 0l-2-2a.5.5 0 0 1 .708-.708L7.5 14.293V10.5A.5.5 0 0 1 8 10z"/></svg>'
    var colorIcon = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-palette" viewBox="0 0 16 16"> <path d="M8 5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3zm4 3a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3zM5.5 7a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0zm.5 6a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3z"/> <path d="M16 8c0 3.15-1.866 2.585-3.567 2.07C11.42 9.763 10.465 9.473 10 10c-.603.683-.475 1.819-.351 2.92C9.826 14.495 9.996 16 8 16a8 8 0 1 1 8-8zm-8 7c.611 0 .654-.171.655-.176.078-.146.124-.464.07-1.119-.014-.168-.037-.37-.061-.591-.052-.464-.112-1.005-.118-1.462-.01-.707.083-1.61.704-2.314.369-.417.845-.578 1.272-.618.404-.038.812.026 1.16.104.343.077.702.186 1.025.284l.028.008c.346.105.658.199.953.266.653.148.904.083.991.024C14.717 9.38 15 9.161 15 8a7 7 0 1 0-7 7z"/> </svg>'
    var bgColorIcon = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-palette-fill" viewBox="0 0 16 16"> <path d="M12.433 10.07C14.133 10.585 16 11.15 16 8a8 8 0 1 0-8 8c1.996 0 1.826-1.504 1.649-3.08-.124-1.101-.252-2.237.351-2.92.465-.527 1.42-.237 2.433.07zM8 5a1.5 1.5 0 1 1 0-3 1.5 1.5 0 0 1 0 3zm4.5 3a1.5 1.5 0 1 1 0-3 1.5 1.5 0 0 1 0 3zM5 6.5a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0zm.5 6.5a1.5 1.5 0 1 1 0-3 1.5 1.5 0 0 1 0 3z"/> </svg>'
    $('.cke_button__templates_icon').each(function() {
      $( this ).prepend(templateIcon);
    });
    $('.cke_button__justifyleft').each(function() {
      $( this ).prepend(leftIcon);
    });
    $('.cke_button__justifycenter').each(function() {
      $( this ).prepend(centerIcon);
    });
    $('.cke_button__justifyright').each(function() {
      $( this ).prepend(rightIcon);
    });
    $('.cke_button__justifyblock').each(function() {
      $( this ).prepend(blockIcon);
    });
    $('.cke_button__collapsibleitem').each(function() {
      $( this ).prepend(collapseIcon);
    });
    $('.cke_button__textcolor_icon').each(function() {
      $( this ).prepend(colorIcon);
    });
    $('.cke_button__bgcolor_icon').each(function() {
      $( this ).prepend(bgColorIcon);
    });
    clearInterval(timer);
  }
}, 500);

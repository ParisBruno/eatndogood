CKEDITOR.editorConfig = function (config) {

  // Define changes to default configuration here. For example:
  // config.language = 'fr';
  // config.uiColor = '#AADC6E';

  /* Filebrowser routes */
  // The location of an external file browser, that should be launched when "Browse Server" button is pressed.
  config.filebrowserBrowseUrl = "/ckeditor/attachment_files";

  // The location of an external file browser, that should be launched when "Browse Server" button is pressed in the Flash dialog.
  config.filebrowserFlashBrowseUrl = "/ckeditor/attachment_files";

  // The location of a script that handles file uploads in the Flash dialog.
  config.filebrowserFlashUploadUrl = "/ckeditor/attachment_files";

  // The location of an external file browser, that should be launched when "Browse Server" button is pressed in the Link tab of Image dialog.
  config.filebrowserImageBrowseLinkUrl = "/ckeditor/pictures";

  // The location of an external file browser, that should be launched when "Browse Server" button is pressed in the Image dialog.
  config.filebrowserImageBrowseUrl = "/ckeditor/pictures";

  // The location of a script that handles file uploads in the Image dialog.
  config.filebrowserImageUploadUrl = "/ckeditor/pictures?";

  // The location of a script that handles file uploads.
  config.filebrowserUploadUrl = "/ckeditor/attachment_files";

  config.allowedContent = true;
  config.filebrowserUploadMethod = 'form';
  config.enterMode = CKEDITOR.ENTER_BR; // <p></p> to <br />
  config.entities = false;
  config.basicEntities = false;

  config.font_names =  'Merriweather Sans; Sacramento; Montserrat;'+config.font_names;

    config.toolbar = 'Easy';

    config.toolbar_Easy =
    [
        ['Undo','Redo','-','RemoveFormat'],
        ['Styles','Format','Font','FontSize'],
        ['TextColor','BGColor'],
        ['Bold','Italic','Underline'], 
        ['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
        ['Link','Unlink'],
        [ 'Image' ],
        ['NumberedList', 'BulletedList'],
        ['Templates', 'CollapsibleItem']
    ];
    config.extraPlugins = 'panelbutton,colorbutton,confighelper,font,placeholder,justify,templates,collapsibleItem,colordialog';
};


CKEDITOR.on("instanceReady", function(event) {
  event.editor.on("beforeCommandExec", function(event) {
    // Show the paste dialog for the paste buttons and right-click paste
    if (event.data.name == "paste") {
      event.editor._.forcePasteDialog = true;
    }
    // Don't show the paste dialog for Ctrl+Shift+V
    if (event.data.name == "pastetext" && event.data.commandData.from == "keystrokeHandler") {
        event.cancel();
    }
  })
});



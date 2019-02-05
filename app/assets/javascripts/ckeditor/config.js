CKEDITOR.editorConfig = function (config) {

    config.toolbar = 'Easy';

    config.toolbar_Easy =
    [
        ['Source','-','Preview'],
        ['Cut','Copy','Paste','PasteText','PasteFromWord',],
        ['Undo','Redo','-','SelectAll','RemoveFormat'],
        ['Styles','Format'],['Maximize','-','About'],
        ['Subscript', 'Superscript', 'TextColor'],
        ['Bold','Italic','Underline','Strike'], ['NumberedList','BulletedList','-','Outdent','Indent','Blockquote'],
        ['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
        ['Link','Unlink','Anchor'],
      /*   ['Image', 'Attachment', 'Flash', 'Embed'], */
        ['Table','HorizontalRule','Smiley','SpecialChar','PageBreak']
    ];

}


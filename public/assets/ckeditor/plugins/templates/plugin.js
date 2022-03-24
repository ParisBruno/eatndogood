/**
 * @license Copyright (c) 2003-2022, CKSource Holding sp. z o.o. All rights reserved.
 * For licensing, see LICENSE.md or https://ckeditor.com/legal/ckeditor-oss-license
 */


( function() {
	CKEDITOR.plugins.add( 'templates', {
		// requires: 'dialog,ajax',
		// jscs:disable maximumLineLength
		lang: 'af,ar,az,bg,bn,bs,ca,cs,cy,da,de,de-ch,el,en,en-au,en-ca,en-gb,eo,es,es-mx,et,eu,fa,fi,fo,fr,fr-ca,gl,gu,he,hi,hr,hu,id,is,it,ja,ka,km,ko,ku,lt,lv,mk,mn,ms,nb,nl,no,oc,pl,pt,pt-br,ro,ru,si,sk,sl,sq,sr,sr-latn,sv,th,tr,tt,ug,uk,vi,zh,zh-cn', // %REMOVE_LINE_CORE%
		// jscs:enable maximumLineLength
		// icons: 'templates,templates-rtl', // %REMOVE_LINE_CORE%
		hidpi: true, // %REMOVE_LINE_CORE%
		init: function( editor ) {
			CKEDITOR.dialog.add( 'templates', CKEDITOR.getUrl( this.path + 'dialogs/templates.js' ) );

			editor.addCommand( 'templates', new CKEDITOR.dialogCommand( 'templates' ) );
      
      var templateIcon = '<svg id="editorTemplateIcon" xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-file-earmark" viewBox="0 0 16 16"><path d="M14 4.5V14a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V2a2 2 0 0 1 2-2h5.5L14 4.5zm-3 0A1.5 1.5 0 0 1 9.5 3V1H4a1 1 0 0 0-1 1v12a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1V4.5h-2z"/></svg>'
      if ($('#cke_recipe_description_en #editorTemplateIcon').length == 0) {
        $('#cke_recipe_description_en .cke_button__templates_icon').prepend(templateIcon);
      }
      if ($('#cke_recipe_summary_en #editorTemplateIcon').length == 0) {
        $('#cke_recipe_summary_en .cke_button__templates_icon').prepend(templateIcon);
      }
			editor.ui.addButton && editor.ui.addButton( 'Templates', {
				label: editor.lang.templates.button,
				command: 'templates',
				toolbar: 'doctools,10'
			} );
		}
	} );

	var templates = {},
		loadedTemplatesFiles = {};

	/**
	 * Adds templates' collection to the list of all available templates.
	 *
	 * @member CKEDITOR
	 * @param {String} name Name of the templates' collection.
	 * @param {CKEDITOR.plugins.templates.collectionDefinition} definition Definition of templates' collection.
	 */
	CKEDITOR.addTemplates = function( name, definition ) {
		templates[ name ] = definition;
	};

	/**
	 * Gets templates' collection by its name.
	 *
	 * @member CKEDITOR
	 * @param {String} name Name of the templates' collection.
	 * @returns {CKEDITOR.plugins.templates.collectionDefinition}
	 */
	CKEDITOR.getTemplates = function( name ) {
		return templates[ name ];
	};

	/**
	 * Loads files that contains templates' collection definition.
	 *
	 * @member CKEDITOR
	 * @param {String[]} templateFiles Array of files' paths.
	 * @param {Function} callback Function to be run after loading all files.
	 */
	CKEDITOR.loadTemplates = function( templateFiles, callback ) {
		// Holds the templates files to be loaded.
		var toLoad = [];

		// Look for pending template files to get loaded.
		for ( var i = 0, count = templateFiles.length; i < count; i++ ) {
			if ( !loadedTemplatesFiles[ templateFiles[ i ] ] ) {
				toLoad.push( templateFiles[ i ] );
				loadedTemplatesFiles[ templateFiles[ i ] ] = 1;
			}
		}

		if ( toLoad.length )
			CKEDITOR.scriptLoader.load( toLoad, callback );
		else
			setTimeout( callback, 0 );
	};
} )();

/**
 * The templates definition set to use. It accepts a list of names separated by
 * comma. It must match definitions loaded with the {@link #templates_files} setting.
 *
 *		config.templates = 'my_templates';
 *
 * @cfg {String} [templates='default']
 * @member CKEDITOR.config
 */

/**
 * The list of templates definition files to load.
 *
 *		config.templates_files = [
 *			'/editor_templates/site_default.js',
 *			'http://www.example.com/user_templates.js'
 *		];
 *
 * For a sample template file
 * [see `templates/default.js`](https://github.com/ckeditor/ckeditor4/blob/master/plugins/templates/templates/default.js).
 * For more information on template definiton see {@link CKEDITOR.plugins.templates.collectionDefinition}.
 *
 * @cfg {String[]}
 * @member CKEDITOR.config
 */
CKEDITOR.config.templates_files = [
	CKEDITOR.getUrl( 'plugins/templates/templates/default.js' )
];

/**
 * Whether the "Replace actual contents" checkbox is checked by default in the
 * Templates dialog.
 *
 *		config.templates_replaceContent = false;
 *
 * @cfg {Boolean}
 * @member CKEDITOR.config
 */
CKEDITOR.config.templates_replaceContent = true;

/**
 * @license Copyright (c) 2003-2019, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.md or https://ckeditor.com/legal/ckeditor-oss-license
 */
"use strict";CKEDITOR.dialog.add("placeholder",function(e){var t=e.lang.placeholder,a=e.lang.common.generalTab,i=/^[^\[\]<>]+$/;return{title:t.title,minWidth:300,minHeight:80,contents:[{id:"info",label:a,title:a,elements:[{id:"name",type:"text",style:"width: 100%;",label:t.name,"default":"",required:!0,validate:CKEDITOR.dialog.validate.regex(i,t.invalidName),setup:function(e){this.setValue(e.data.name)},commit:function(e){e.setData("name",this.getValue())}}]}]}});
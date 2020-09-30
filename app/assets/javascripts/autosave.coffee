# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

serialize_and_post = ($form) ->
  current_app = gon.current_app
  form =  $form.attr('action')
  _.forEach CKEDITOR.instances, (instance) ->
    instance.updateElement()
  form_data = $form.serializeArray()
  console.log(form_data)
  # Get the radio buttons and checkboxes.
  checkboxes = $form.find(':input').filter(':checkbox').serializeArray()
  radios = $form.find(':input').filter(':radio').serializeArray()
  form_data = $.merge(form_data, checkboxes)
  form_data = $.merge(form_data, radios)
  data = {payload: form_data, form: form}
  $.post("/#{current_app}/autosaves", data, (_data) ->
    toastr.info('Draft Saved')
  )

auto_save = ($form, old_data) ->
  _.forEach CKEDITOR.instances, (instance) ->
    instance.on 'blur', () ->
      console.log("Blurred")
      serialize_and_post($form)

  $form.find(':input').on 'blur', (e) ->
    console.log("Blurred")
    serialize_and_post($form, old_data)

restore_save = ($form) ->
  current_app = gon.current_app
  form =  $form.attr('action')
  $.get "/#{current_app}/autosaves?form=#{form}", (data) ->
    form_data = data
    #Have to loop the data twice to add dynamic rows then fill them in.
    # if !_.isEmpty(form_data)
      # $('.is-draft').show()
    # _.forEach form_data, (obj) ->
    #   if obj.name.slice(-4) == '_rc]'
    #     # Find the add row button.
    #     obj_name = obj.name.split('[')[obj.name.split('[').length - 1]
    #     add_button_id = obj_name.substring(0, obj_name.length - 4) + "-add"
    #     $add_button = $('#' + add_button_id)

        # Click it the appropriate number of times.
        # for i in [0...parseInt(obj.value)] by 1
        #   $add_button.trigger('click')
    
    # Fill in the fields.
    _.forEach form_data, (obj) ->
      $input = $("[name='#{obj.name}']")
      # console.log($input.val())
      # Check for radio and checkboxes.
      if $input.is(':radio') and $input.val() == obj.value
        console.log($input, obj.value)
        $input.attr('checked', true)
      else if $input.is(':checkbox')
        _.forEach $input, (i) ->
          klass = $(i).attr('id')
          if klass
            id = klass.split('_')[3]
            if id == obj.value
              $(i).attr('checked', true)
      else
        $input.val(obj.value)
    _.forEach CKEDITOR.instances, (instance) ->
      instance.updateElement()
    auto_save($form)
    
jQuery ->
  if $('.autosave').length > 0
    restore_save($('.autosave'))
    # # auto_save($('.autosave'))
    # # autosave every 2 mn
    setInterval(() ->
      $form = $('.autosave')
      serialize_and_post($form)
    , 20000);
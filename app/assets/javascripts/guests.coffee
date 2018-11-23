$ ->
  @email_textarea = $("textarea[data-role='guest_email_text']")
  @guest_email = $("input[data-role='guest_email']")
  @send_to_one = $("button[data-role='send_email_to_one']")
  @send_to_all = $("button[data-role='send_email_to_all']")
  @send_to_selected = $("button[data-role='send_email_to_selected']")
  @url = '/guests'

  @send_to_all.on('click', (e) =>
    e.preventDefault()
    text = @email_textarea.val()

    if (text.length > 0)
      $.ajax({
        method: "POST",
        url: @url,
        data: {
          _method: 'POST',
          text: text
        },
        dataType: 'JSON',
        success: ->
      , error: (data) -> console.log(data, form)
      })
  )

  @send_to_one.on('click', (e) =>
    e.preventDefault()
    text = @email_textarea.val()
    email = @guest_email.val()

    if (text.length > 0 && email.length > 0)
      $.ajax({
        method: "POST",
        url: @url,
        data: {
          _method: 'POST',
          text: text,
          emails: [email]
        },
        dataType: 'JSON',
        success: -> alert('Email was send.')
      , error: (data) -> console.log(data.error)
      })
  )

  @send_to_selected.on('click', (e) =>
    e.preventDefault()
    text = @email_textarea.val()
    emails = $.map($(".form-check-input:checked"), (guest) => $(guest).data('email'))

    if (text.length > 0 && emails.length > 0)
      $.ajax({
        method: "POST",
        url: @url,
        data: {
          _method: 'POST',
          text: text,
          emails: emails
        },
        dataType: 'JSON',
        success: -> alert('Email was send.')
      , error: (data) -> console.log(data.error)
      })
  )
$ ->
  $('.js-language-dropdown').on 'click', (event) ->
    event.preventDefault()
    $.cookie("locale", $(this).data('language'), { path: '/' })
    document.getElementById($(this).data('target')).innerHTML = $(this).text()

#= require jquery
#= require jquery-ujs
#= require bootstrap-sass-official

$ ->
  $('[data-toggle="tooltip"]').tooltip()

  $('.main-filter .tld-item input:checked').each ->
    $(@).next().addClass('active')
  $(document).on 'click', '.main-filter .tld-item label', ->
    $(@).toggleClass('active')

  $(document).on 'click', '.main-filter.panel .panel-heading', ->
    $(@).find('.title').toggleClass('hidden')
    $('.main-filter .panel-body').toggleClass('hidden')

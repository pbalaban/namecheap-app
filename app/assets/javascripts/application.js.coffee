#= require jquery
#= require jquery-ujs
#= require bootstrap-sass-official

$ ->
  $('[data-toggle="tooltip"]').tooltip()

  $(document).on 'click', '.main-filter.panel .panel-heading', ->
    $(@).find('.title').toggleClass('hidden')
    $('.main-filter .panel-body').toggleClass('hidden')

#= require jquery
#= require jquery-ujs
#= require bootstrap-sass-official
#= require seiyria-bootstrap-slider

$ ->
  $('[data-toggle="tooltip"]').tooltip()
  $("#domain_search_price").slider()

  $(document).on 'click', '.main-filter.panel .panel-heading', ->
    $(@).find('.title').toggleClass('hidden')
    $('.main-filter .panel-body').toggleClass('hidden')

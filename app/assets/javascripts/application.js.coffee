#= require jquery
#= require jquery-ujs
#= require bootstrap
#= require seiyria-bootstrap-slider
#= require handlebars
#= require ember
#= require ember-data
#= require_self
#= require app

window.App = Ember.Application.create()

$ ->
  $('[data-toggle="tooltip"]').tooltip()
  $("#domain_search_price").slider()

  $(document).on 'click', '.main-filter.panel .panel-heading', ->
    $(@).find('.title').toggleClass('hidden')
    $('.main-filter .panel-body').toggleClass('hidden')

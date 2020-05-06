# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@onModalHideCleanSignup = (hide_event) ->
  console.log("session event:", hide_event)
  $.getScript('/users/new')

$(document).on "turbolinks:load", ->
  $('#login-modal').on('hide.bs.modal', onModalHideCleanSignup)

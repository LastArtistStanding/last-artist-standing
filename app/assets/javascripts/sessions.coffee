# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@onModalHideCleanLogin = (hide_event) ->
  console.log("login event:", hide_event)
  $.getScript('/login')

$(document).on "turbolinks:load", ->
  $('#login-modal').on('hide.bs.modal', onModalHideCleanLogin)

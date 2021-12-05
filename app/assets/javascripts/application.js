//= require jquery
//= require bootstrap
//= require popper
//= require bootstrap-sprockets
//= require jquery_ujs
//= require_tree
//= link comments/writing_utils.js
//= link submissions/keyboard_navigation.js
//= link submissions/view_size_change.js
//= link application.css

$(function () {
  $('[data-toggle="popover"]').popover()
  $('[data-toggle="tooltip"]').tooltip()
})

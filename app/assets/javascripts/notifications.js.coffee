class Notifications
  constructor: ->
    @notifications = $("[data-behavior='notifications']")
    @setup() if @notifications.length > 0

  setup: ->
    $.ajax(
      url: "/notifications.json"
      dataType: "JSON"
      method: "GET"
      success: @handleSuccess
    )

  handleClick: (e) =>
    $.ajax(
      url: "/notifications/mark_as_read"
      dataType: "JSON"
      method: "POST"
      success: ->
        $("[data-behavior='unread-count']").text(0)
        $("[data-behavior='unread-count']").css('display', 'none')
        $("[data-behavior='notifications-link']").off "click"
    )

  handleSuccess: (data) =>
    console.log(data)
    items = $.map data, (notification) ->
      $(document.createElement("a"))
        .attr("href", notification.url)
        .text(notification.body)

    items.push "<a href='/notifications'>View All Notifications</a>"

    if items.length > 1
      $("[data-behavior='unread-count']").text(items.length - 1)
      $("[data-behavior='notification-items']").html(items)
      $("[data-behavior='notifications-link']").on "click", @handleClick

jQuery ->
  $(window).load ->
    new Notifications

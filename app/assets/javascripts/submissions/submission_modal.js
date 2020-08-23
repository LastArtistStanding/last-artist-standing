window.onload = () => {
  $(".submission").click((e) => {
    $('#submission-modal').modal('show')
    $('#submission-modal #title').html(e.target.alt)  
    $('#submission-modal #avatar').attr("src", e.target.attributes.avatar_link.nodeValue)  
    $('#submission-modal #drawing').attr("src", e.target.src)
    $('#submission-modal #detail-button').attr("href", e.target.attributes.detail_link.nodeValue)
    $('#submission-modal #full-size-button').attr("href", e.target.attributes.full_size_link.nodeValue)
  })
};
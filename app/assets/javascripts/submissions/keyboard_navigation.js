window.onkeyup = function(e) {
  if (window.location.toString().match(/submissions\/\d+$/) === null) {
    return
  }

  if (document.getElementById("comment-box") !== document.activeElement) {
    if (ppath && e.keyCode == 37) {
      window.open(ppath,"_self");
    }
    if (appath && e.keyCode == 219) {
      window.open(appath,"_self");
    }
    if (anpath && e.keyCode == 221) {
      window.open(anpath,"_self");
    }
    if (npath && e.keyCode == 39) {
      window.open(npath,"_self");
    }
  }
}

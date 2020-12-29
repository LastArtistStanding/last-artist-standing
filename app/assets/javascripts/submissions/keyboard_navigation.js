window.onkeyup = function(e) {
  if (window.location.toString().match(/submissions\/\d+(\#.*)?$/) === null) {
    return;
  }

  if (document.getElementById("comment-box") !== document.activeElement) {
    if (ppath && e.code === 'ArrowLeft') {
      window.open(ppath, "_self");
    }
    if (appath && e.code === 'BracketLeft') {
      window.open(appath, "_self");
    }
    if (anpath && e.code === 'BracketRight') {
      window.open(anpath, "_self");
    }
    if (npath && e.code === 'ArrowRight') {
      window.open(npath, "_self");
    }
  }
};

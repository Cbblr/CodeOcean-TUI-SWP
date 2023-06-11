$(document).on('turbolinks:load', function(event) {

  //Merge all editor components.
  $.extend(
      CodeOceanEditor,
      CodeOceanEditorAJAX,
      CodeOceanEditorEvaluation,
      CodeOceanEditorFlowr,
      CodeOceanEditorSubmissions,
      CodeOceanEditorTurtle,
      CodeOceanEditorWebsocket,
      CodeOceanEditorPrompt,
      CodeOceanEditorCodePilot,
      CodeOceanEditorRequestForComments
  );

  if ($('#editor').isPresent() && CodeOceanEditor && event.originalEvent.data.url.includes("/implement")) {
    // This call will (amon other things) initializeEditors and load the content except for the last line
    // It must not be called during page navigation. Otherwise, content will be duplicated!
    // Search for insertLines and Turbolinks reload / cache control
    CodeOceanEditor.initializeEverything();
  };

  let isMouseDownHorizontal = 0
  $('#resizerHorizontal').on('mousedown', mouseDownHorizontal)

  function mouseDownHorizontal(event) {
    isMouseDownHorizontal = 1
    document.body.addEventListener('mousemove', mouseMoveHorizontal)
    document.body.addEventListener('mouseup', mouseUpHorizontal)
  }

  function mouseMoveHorizontal(event) {
    if (isMouseDownHorizontal === 1) {
      $('#panel-left').css('width', event.clientX + "px")
    } else {
      mouseUpHorizontal()
    }
  }
  function mouseUpHorizontal(event) {
    isMouseDownHorizontal = 0
    document.body.removeEventListener('mouseup', mouseUpHorizontal)
    resizerHorizontal.removeEventListener('mousemove', mouseMoveHorizontal)
  }

  let isMouseDownVertical = 0
  $('#resizerVertical').on('mousedown', mouseDownVertical)

  function mouseDownVertical(event) {
    isMouseDownVertical = 1
    document.body.addEventListener('mousemove', mouseMoveVertical)
    document.body.addEventListener('mouseup', mouseUpVertical)
  }

  function mouseMoveVertical(event) {
    if (isMouseDownVertical === 1) {
      $('.panel-top').css('height', event.clientY + "px")
      $('.panel-bottom').css('height', ($('#editor-column').height() - $('.panel-top').height()) + "px");
    } else {
      mouseUpVertical()
    }
  }
  function mouseUpVertical(event) {
    isMouseDownVertical = 0
    document.body.removeEventListener('mouseup', mouseUpVertical)
    resizerVertical.removeEventListener('mousemove', mouseMoveVertical)
  }
});

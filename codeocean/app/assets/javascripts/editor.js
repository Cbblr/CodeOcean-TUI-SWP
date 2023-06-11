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

  let isMouseDown = 0
  $('#resizerHorizontal').on('mousedown', mouseDown)

  function mouseDown(event) {
    isMouseDown = 1
    document.body.addEventListener('mousemove', mouseMove)
    document.body.addEventListener('mouseup', mouseUp)
  }

  function mouseMove(event) {
    if (isMouseDown === 1) {
      $('#panel-left').css('flex-basis', event.clientX + "px")
    } else {
      mouseUp()
    }
  }
  function mouseUp(event) {
    isMouseDown = 0
    document.body.removeEventListener('mouseup', mouseUp)
    resizerHorizontal.removeEventListener('mousemove', mouseMove)
  }
});

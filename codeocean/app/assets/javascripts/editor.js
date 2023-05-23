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

  let ismdwn = 0
  rpanrResize.addEventListener('mousedown', mD)

  function mD(event) {
    ismdwn = 1
    document.body.addEventListener('mousemove', mV)
    document.body.addEventListener('mouseup', end)
  }

  function mV(event) {
    if (ismdwn === 1) {
      pan1.style.flexBasis = event.clientX + "px"
    } else {
      end()
    }
  }
  const end = (e) => {
    ismdwn = 0
    document.body.removeEventListener('mouseup', end)
    rpanrResize.removeEventListener('mousemove', mV)
  }
});

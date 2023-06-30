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
    if (isMouseDownHorizontal === 1 && event.clientX <= 0.7 * window.innerWidth && event.clientX >= 0.2 * window.innerWidth) {
      $('#panel-left').css('width', (event.clientX - $('#panel-left').offset().left) + "px")
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
      $('.panel-top').css('height', (event.clientY - $('.panel-top').offset().top - $('#statusbar').height()) + "px")
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
  
  $(document).ready(function() {
    // Retrieve the theme state from localStorage
    var savedTheme = localStorage.getItem('theme');
    const editors = CodeOceanEditor.editors;
  
    // Set the initial theme based on the stored state
    if (savedTheme === 'dark') {
      $('body').attr('data-bs-theme', 'dark');
      editors.forEach(editor => {
        editor.setTheme('ace/theme/tomorrow_night_eighties');
      });
      $('#theme-toggle i').removeClass('fa-moon').addClass('fa-sun');
    } else {
      $('body').attr('data-bs-theme', 'light');
      $('#theme-toggle i').removeClass('fa-sun').addClass('fa-moon');
    }
  });

  $('#theme-toggle').on('click', function() {
    var body = $('body');
    var icon = $(this).find('i');
    const editors = CodeOceanEditor.editors;
    
    if (body.attr('data-bs-theme') === 'dark') {
      body.attr('data-bs-theme', 'light');
      icon.removeClass('fa-sun').addClass('fa-moon');
      editors.forEach(editor => {
        editor.setTheme('ace/theme/textmate');
      });
      localStorage.setItem('theme', 'light'); // Store the theme state in localStorage
    } else {
      body.attr('data-bs-theme', 'dark');
      editors.forEach(editor => {
        editor.setTheme('ace/theme/tomorrow_night_eighties');
      });
      icon.removeClass('fa-moon').addClass('fa-sun');
      localStorage.setItem('theme', 'dark'); // Store the theme state in localStorage
    }
    return false; // Prevent default link behavior
  });
});

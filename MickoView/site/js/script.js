'use strict';


$(document).ready(function() {
  var inputFile = $('div#input > input#input');
  var inputButton = $('div#input > button#compile');
  var minicArea = $('div#frames > div#minic > iframe#minic');
  var assemblyArea = $('div#frames > div#assembly > iframe#assembly');
  var rulesArea = $('div#frames > div#rules > iframe#rules');

  if (!window.File || !window.FileReader || !window.FileList || !window.Blob) {
    alert('Vaš pretraživač ne podržava File API!');
    return;
  }

  inputButton.click(function(event) {
    if (!inputFile[0].files[0]) {
      alert('Morate prvo izabrati fajl!');
      return;
    }

    var reader = new FileReader();
    reader.readAsText(inputFile[0].files[0], 'UTF-8');
    reader.onload = function(e) {
      $.ajax({
        type: 'POST',
        url: '/',
        dataType: 'json',
        contentType: 'application/json; charset=UTF-8',
        data: JSON.stringify({
          code: reader.result
        })
      }).done(function(msg) {
        if (msg.error === true) {
          minicArea.attr('srcdoc', msg.errormsg);
          assemblyArea.attr('srcdoc', '');
          rulesArea.attr('srcdoc', '');
        } else {
          minicArea.attr('srcdoc', msg.minic);
          assemblyArea.attr('srcdoc', msg.assembly);
          rulesArea.attr('srcdoc', msg.rules);
        }
      }).fail(function(req, status, error) {
        var text = 'Submission failed!\n\n'
          + 'Req: ' + JSON.stringify(req)
          + ',\nStatus: ' + status
          + ',\nError: ' + error;

        minicArea.attr('srcdoc', text);
      });
    };
  });
});

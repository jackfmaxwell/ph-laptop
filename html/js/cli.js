
let cli = document.querySelector("#cli-app");


$(document).ready(function () {
  cliheader = cli.querySelector("header");
  cliheader.addEventListener("mousedown", () => {
    cliheader.classList.add("active");
    cliheader.addEventListener("mousemove", onDrag);
  });
  document.addEventListener("mouseup", (e) => {
    cliheader.classList.remove("active");
    cliheader.removeEventListener("mousemove", onDrag);
  });

  loadcliApp();
                                                                                       
});
window.addEventListener("message", function (event) {
  switch (event.data.type) {
    case "commandResponse":
      putLineInConsole(event.data.data);
    break;
    case "clear":
      $('#cmd_console').html("");
    break;
    case "setCursorName":
        $('#cursor').html(event.data.data)
      break;
  }
});

function loadcliApp() {
  
}
function putLineInConsole(string){
  $('#cmd_console').append(string + "<br>");
}

function handleKeyPress(e){
  var key=e.keyCode || e.which;
  if (key==13){
    var cmd = $('#cmd_entry').val();
    if(cmd!=""){
      $('#cmd_entry').val("");
      $.post(`https://${GetParentResourceName()}/submitCommand`, JSON.stringify({
        Command: cmd
      }));
      putLineInConsole(cmd);
    
    }
    
    var passwordEntry = $('#passwordEntry').val();
    if(passwordEntry!=""){
      $('#passwordEntry').val("");
      console.log(passwordEntry);
      $.post(`https://${GetParentResourceName()}/passwordSubmit`, JSON.stringify({
        Pass: passwordEntry
      }));
    }
   
  }
  if(key==38){ //up
    
  }
  if(key==40){ //down
    
  }
}


function closecli() {
  removeIcon("cli");
}

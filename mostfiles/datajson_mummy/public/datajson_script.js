/*
Webbie can use a cookie-tunnel to execute code from the server. This means
that in javascript (client-side) a cookie is set to be picked up by the server
and run there. Search for cookievaluest in project_startup.nim where the 
pickup starts.
*/



function setCookieForSeconds(cName, cValue, forSeconds) {
  document.cookie = cName + "=" + cValue + ";max-age=" + forSeconds  + "; path=/datajson";
}



function finalize(){
  const waitmilsecsji = 200
  document.forms["webbieform"].submit();
  // wait some milliseconds for the function to be executed depending on latency
  let now = Date.now(),
      end = now + waitmilsecsji;
  while (now < end) { now = Date.now(); }

  // Set the value of the cookie to DISABLED so that it is not executed on the next submit
  // This is needed because cookie-deletion is insecure
  setCookieForSeconds("datajson_run_function", "DISABLED", 300);  
}



function sendFunctionToServer() {
  setCookieForSeconds("datajson_run_function", 
    "funcname::dummyPass++location::inner++mousvarname::statustext++newcontent::nieuwe statustekst", 300);
  finalize();
}


function setMoustachuVar(mousvarjs, contentjs) {
  setCookieForSeconds("datajson_run_function", 
    "funcname::dummyPass++location::inner++mousvarname::" + mousvarjs + 
    "++newcontent::" + contentjs, 
    300);
  
  finalize();
}


// function dropdownname_01_onchange() {

// // write selection-change to status-text

//   var selectjo = document.getElementById("dropdownname_01");
//   var valuejs = selectjo.options[selectjo.selectedIndex].value;
//   // console.log("bericht is:" + valuejs);

//   var messagejs = "From dropdown1, item " + selectjo.selectedIndex + " = " + valuejs;

//   setMoustachuVar("statustext", messagejs);
// }



function radiorecord_onchange(valuejs) {
// write selection-change to status-text

  document.getElementsByName("curaction")[0].value = "reading rec..";
  
  setMoustachuVar("statustext", valuejs);
  // document.getElementsByName("curaction")[0].value = "idle";
  // alert(valuejs);
 }



function All_tables_onchange() {
// clear input-box values
  document.getElementsByName("curaction")[0].value = "new table..";
  var elems = document.getElementsByClassName("filtering");
  for (var i=0; i<elems.length; i++) {
    elems[i].value = "";}
  var elems = document.getElementsByClassName("data-input");
  for (var i=0; i<elems.length; i++) {
    elems[i].value = "";}

  document.forms["webbieform"].submit(); 
  // document.getElementsByName("curaction")[0].value = "idle";
}


function butLoadTable() {
  // load the table mr_data (for now)
  document.getElementsByName("curaction")[0].value = "loading table..";
  document.forms["webbieform"].submit();  
}


function butSave() {
  console.log("testing 123");
  document.getElementsByName("curaction")[0].value = "saving..";
  document.forms["webbieform"].submit();
}


function butClearFields() {
  console.log("testing 123");
  document.getElementsByName("curaction")[0].value = "clearing..";

  var elems = document.getElementsByClassName("data-input");
  for (var i=0; i<elems.length; i++) {
    elems[i].value = "";}

  document.getElementsByName("curaction")[0].value = "idle";  
  }


function butClearFilter() {
  console.log("testing 123");
  document.getElementsByName("curaction")[0].value = "clearing..";

  var elems = document.getElementsByClassName("filtering");
  for (var i=0; i<elems.length; i++) {
    elems[i].value = "";}

  document.getElementsByName("curaction")[0].value = "idle";  
  }




function butDelete() {
  console.log("testing 123");
  document.getElementsByName("curaction")[0].value = "deleting..";
  document.forms["webbieform"].submit();
}



// function dropdownname_02_onchange() {
// // write selection-change to status-text

//   var selectjo = document.getElementById("dropdownname_02");
//   var valuejs = selectjo.options[selectjo.selectedIndex].value;
//   // console.log("bericht is:" + valuejs);

//   var messagejs = "From dropdown2, item " + selectjo.selectedIndex + " = " + valuejs;

//   setMoustachuVar("statustext", messagejs);
// }


/*
Webbie uses a cookie-tunnel to execute code from the server. This means
that in javascript (client-side) a cookie is set to be picked up by the server
and run there. Search for cookievaluest in project_startup.nim where the 
pickup starts.
*/



function copyText() {
  // copy text from one textbox to an other
  document.getElementById('tbox2').value = document.getElementById('tbox1').value;
  console.log('text copied');
}


function setCookie_old3(cName, cValue, expDays) {
  let date = new Date();
  date.setTime(date.getTime() + (expDays * 24 * 60 * 60 * 1000));
  const expires = "expires=" + date.toUTCString();
  document.cookie = cName + "=" + cValue + "; " + expires + "; path=/";
}


function setCookieForSeconds(cName, cValue, forSeconds) {
  document.cookie = cName + "=" + cValue + ";max-age=" + forSeconds  + "; path=/scricon";
}


function testSetCookie() {
  setCookieForSeconds("Koekje", "Speculaas", 120);
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
  setCookieForSeconds("scricon_run_function", "DISABLED", 300);  
}


function sendFunctionToServer() {
  setCookieForSeconds("scricon_run_function", 
    "funcname::g_tools.dummyPass++location::inner++mousvarname::statustext++newcontent::nieuwe statustekst", 300);
  finalize();
}


function setMoustachuVar(mousvarjs, contentjs) {
  setCookieForSeconds("scricon_run_function", 
    "funcname::g_tools.dummyPass++location::inner++mousvarname::" + mousvarjs + 
    "++newcontent::" + contentjs, 
    300);
  
  finalize();
}


function dropdownname_01_onchange() {

// write selection-change to status-text

  var selectjo = document.getElementById("dropdownname_01");
  var valuejs = selectjo.options[selectjo.selectedIndex].value;
  // console.log("bericht is:" + valuejs);

  var messagejs = "From dropdown1, item " + selectjo.selectedIndex + " = " + valuejs;

  setMoustachuVar("statustext", messagejs);

}


function dropdownname_03_onchange() {
// set the realvalue of dd1 when dd3 changes

  setCookieForSeconds("scricon_run_function", 
    "funcname::g_html_json.setDropDown++location::inner++mousvarname::dropdown1++" + 
    "html-elem-name::dropdownname_01++selected-value::third realvalue++dd-size::1", 
    300);
  finalize();
}


function dropdownname_02_onchange() {
// write selection-change to status-text

  var selectjo = document.getElementById("dropdownname_02");
  var valuejs = selectjo.options[selectjo.selectedIndex].value;
  // console.log("bericht is:" + valuejs);

  var messagejs = "From dropdown2, item " + selectjo.selectedIndex + " = " + valuejs;

  setMoustachuVar("statustext", messagejs);
}


function radiosetexample_onchange(valuejs) {
// write selection-change to status-text

  switch(valuejs) {
    case "rbut1":
      alert("button 1");
      break;
    case "rbut2":
      alert("button 2");
      break;
    case "rbut3":
      alert("button 3");
      break;
    default:
      alert("Error in JavaScript function radiosetexample_onchange");
    }
}

function check1_onchange()
{
  var cboxjo = document.getElementById('id_check1');
  if (cboxjo.checked == true)
  {
    alert("check this one out");
  }
}

function check2_onchange()
{
  var cboxjo = document.getElementById('id_check2');
  if (cboxjo.checked == true)
  {
    alert("check the second");
  }
}

function check3_onchange()
{
  var cboxjo = document.getElementById('id_check3');
  if (cboxjo.checked == true)
  {
    alert("check out thrice");
  }
}



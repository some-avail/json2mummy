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
  setCookieForSeconds("project_run_function", 
    "funcname::dummyPass++location::inner++mousvarname::" + mousvarjs + 
    "++newcontent::" + contentjs, 
    300);
  
  finalize();
}




function radiorecord_onchange(valuejs) {
// write selection-change to status-text

  document.getElementsByName("curaction")[0].value = "reading rec..";
  
  setMoustachuVar("statustext", valuejs);
  // document.getElementsByName("curaction")[0].value = "idle";
  // alert(valuejs);
 }




function butProcedure1() {
  // perform sample action
  document.getElementsByName("curaction")[0].value = "do action 1..";
  document.forms["webbieform"].submit();  
}


function butProcedure2() {
  console.log("testing 123");
  document.getElementsByName("curaction")[0].value = "do action 2..";
  document.forms["webbieform"].submit();
}


function butProcedure3() {
  console.log("testing 123");
  document.getElementsByName("curaction")[0].value = "do action 3..";

  const waitmilsecsji = 1000
  // wait some milliseconds 
  let now = Date.now(),
      end = now + waitmilsecsji;
  while (now < end) { now = Date.now(); }
  document.getElementsByName("curaction")[0].value = "idle";  
  document.forms["webbieform"].submit();
  }



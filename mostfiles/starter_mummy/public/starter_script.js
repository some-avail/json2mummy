/*
Webbie can use a cookie-tunnel to execute code from the server. This means
that in javascript (client-side) a cookie is set to be picked up by the server
and run there. Search for cookievaluest in project_startup.nim where the 
pickup starts.
*/

let projectprefixjs = "starter"

function setCookieForSeconds(cName, cValue, forSeconds) {
  document.cookie = cName + "=" + cValue + ";max-age=" + forSeconds  + "; path=/" + projectprefixjs;
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
  setCookieForSeconds(projectprefixjs + "_run_function", "DISABLED", 300);  
}



function sendFunctionToServer() {
  setCookieForSeconds(projectprefixjs + "_run_function", 
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

function runReverseStringByNim(mousvarjs, contentjs) {
  setCookieForSeconds(projectprefixjs +"_run_function", 
    "funcname::starter_logic.reverseString++param++location::inner++mousvarname::text01++" + 
    "html-elem-name::dropdownname_01++selected-value::third realvalue++dd-size::1",  
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



function reverseString(inputjs) {
  let outputjs = ""
  for (var i=0; i<inputjs.length; i++) {
    outputjs = inputjs.slice(i, i + 1) + outputjs;};
  console.log(outputjs);
  return outputjs
}




function butProcedure1() {
  // perform sample action
  let intervarjs = ""
  document.getElementsByName("curaction")[0].value = "do action 1..";
  intervarjs = document.getElementsByName("text01")[0].value

  document.getElementsByName("text01")[0].value = reverseString(intervarjs)
  document.getElementsByName("curaction")[0].value = "idle";  

}




function butProcedure2() {
  console.log("testing 123");
  document.getElementsByName("curaction")[0].value = "do action 2..";
  document.forms["webbieform"].submit();
}





function butProcedure3() {
  // console.log("testing 123");
  document.getElementsByName("curaction")[0].value = "do action 3..";

  // document.getElementsByName("curaction")[0].value = "idle";  
  document.forms["webbieform"].submit();
  }






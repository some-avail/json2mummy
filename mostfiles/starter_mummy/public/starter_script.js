/*
Formerly a cookie-tunnel was used to run server-code. 
That a approach is deprecated.
Currently this done by setting (preparing) an action-variable named curaction in javascript.
if you dont like the curaction-label you can hide it as well.
Depending on the value of this var the server can run wanted functions.
*/

let projectprefixjs = "starter"


function reverseString(inputjs) {
  let outputjs = ""
  for (var i=0; i<inputjs.length; i++) {
    outputjs = inputjs.slice(i, i + 1) + outputjs;};
  console.log(outputjs);
  return outputjs
}


function butProcedure1() {
  // reverse the string thru javascript
  let intervarjs = ""
  document.getElementsByName("curaction")[0].value = "do action 1..";
  intervarjs = document.getElementsByName("text01")[0].value

  document.getElementsByName("text01")[0].value = reverseString(intervarjs)
  document.getElementsByName("curaction")[0].value = "idle";  

}



function butProcedure2() {
   // reverse the string by preparing a curaction for running server-side code
  console.log("testing 123");
  document.getElementsByName("curaction")[0].value = "do action 2..";
  document.forms["webbieform"].submit();
}



function butProcedure3() {
  // prepare curaction for server-function cycleSequence
  
  document.getElementsByName("curaction")[0].value = "do action 3..";

  // document.getElementsByName("curaction")[0].value = "idle";  
  document.forms["webbieform"].submit();
  }



function butProcedure4() {
  //prepare curaction for dropdown-reload
  document.getElementsByName("curaction")[0].value = "do action 4..";
  document.forms["webbieform"].submit();
}



function dropdownname_01_onchange() {
// prepare curaction to set status matching the dd-value
  document.getElementsByName("curaction")[0].value = "set status dd1..";
  document.forms["webbieform"].submit(); 
}





// allthoe the cookie-tunnel is deprecated i leave some cookie-functions for reference-purpose on 
// how to use cookies

//***********old cookie code***************
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

function setMoustachuVar(mousvarjs, contentjs) {
  setCookieForSeconds("project_run_function", 
    "funcname::dummyPass++location::inner++mousvarname::" + mousvarjs + 
    "++newcontent::" + contentjs, 
    300);
  finalize();
}
//*******end old cookie code**********************

document.addEventListener("DOMContentLoaded",function(){
  if(!window.hireInAI||!window.hireInAI.client)return;
  var api=window.hireInAI,client=api.client;
  var loginForm=document.getElementById("loginForm");
  var signupForm=document.getElementById("signupForm");
  if(loginForm)loginForm.addEventListener("submit",async function(event){
    event.preventDefault();
    var button=loginForm.querySelector("button[type=submit]"),notice=document.getElementById("authMessage"),values=new FormData(loginForm);
    button.disabled=true;api.showMessage(notice,"Signing in…","");
    var result=await client.auth.signInWithPassword({email:String(values.get("email")).trim(),password:String(values.get("password"))});
    button.disabled=false;
    if(result.error){api.showMessage(notice,result.error.message,"error");return;}
    location.href=api.safeNext();
  });
  if(signupForm)signupForm.addEventListener("submit",async function(event){
    event.preventDefault();
    var button=signupForm.querySelector("button[type=submit]"),notice=document.getElementById("authMessage"),values=new FormData(signupForm),password=String(values.get("password"));
    if(password.length<8){api.showMessage(notice,"Use a password with at least 8 characters.","error");return;}
    button.disabled=true;api.showMessage(notice,"Creating your candidate account…","");
    var result=await client.auth.signUp({email:String(values.get("email")).trim(),password:password,options:{data:{full_name:String(values.get("full_name")).trim()}}});
    button.disabled=false;
    if(result.error){api.showMessage(notice,result.error.message,"error");return;}
    if(result.data.session){location.href="dashboard.html";return;}
    api.showMessage(notice,"Account created. Check your email to confirm, then sign in.","success");
  });
});
(function () {
  var url = "https://xyazcbtxuahzrkxdzywy.supabase.co";
  var key = "sb_publishable_q6gw-Br9OjigN_ETqi17yw_RuKBx2Fs";
  if (!window.supabase || !window.supabase.createClient) {
    window.hireInAI = { error: "Supabase library did not load." };
    return;
  }
  var client = window.supabase.createClient(url,key,{auth:{persistSession:true,autoRefreshToken:true,detectSessionInUrl:true}});
  var escapeHtml = function(value) {
    return String(value == null ? "" : value).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;").replace(/'/g,"&#39;");
  };
  var showMessage = function(element,message,kind) {
    if(!element)return;
    element.textContent=message||"";
    element.className="notice"+(kind?" "+kind:"");
  };
  var safeNext = function() {
    var next=new URLSearchParams(location.search).get("next")||"/dashboard";
    if(!/^\/?(?:index(?:\.html)?|jobs(?:\.html)?|job\/\d+|apply(?:\.html)?|ats(?:\.html)?|dashboard(?:\.html)?|recruiter(?:\.html)?|login(?:\.html)?|signup(?:\.html)?)(?:\?[a-z0-9_%=&./-]*)?$/i.test(next))return "/dashboard";
    return next.charAt(0)==="/"?next:"/"+next;
  };
  var getProfile = function(userId) {
    return client.from("profiles").select("user_id,full_name,role").eq("user_id",userId).maybeSingle();
  };
  window.hireInAI={client:client,escapeHtml:escapeHtml,showMessage:showMessage,safeNext:safeNext,getProfile:getProfile,error:null};
  document.querySelectorAll("[data-logout]").forEach(function(button) {
    button.addEventListener("click",async function() {
      var result=await client.auth.signOut();
      if(result.error){alert(result.error.message);return;}
      location.href="index.html";
    });
  });
})();

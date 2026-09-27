// Only allow http(s) employer links; bare domains get https:// added.
function safeUrl(value){
  var url=String(value||"").trim();
  if(!url)return "";
  if(!/^[a-z][a-z0-9+.-]*:/i.test(url))url="https://"+url.replace(/^\/+/,"");
  try{var parsed=new URL(url);return /^https?:$/.test(parsed.protocol)&&parsed.hostname.indexOf(".")>0?parsed.href:"";}catch(e){return "";}
}
document.addEventListener("DOMContentLoaded",async function(){
  var api=window.hireInAI, form=document.getElementById("applicationForm");
  var gate=document.getElementById("applyGate"),gateText=document.getElementById("applyGateText"),gateLink=document.getElementById("applyGateLink");
  // The form stays hidden until the job is confirmed as an internal HireIn job.
  function stop(message){if(gate){gate.classList.add("is-error");gateText.textContent=message;if(gateLink)gateLink.hidden=false;}}
  if(!api||!api.client||!form){stop("The application service is unavailable. Please refresh in a moment.");return;}
  var client=api.client,notice=document.getElementById("status"),submit=document.getElementById("submitButton");
  var params=new URLSearchParams(location.search);
  var jobId=params.get("job")||params.get("id"),jobTitle=document.getElementById("jobTitle");
  if(!jobId||!/^\d+$/.test(jobId)){jobTitle.textContent="Invalid job link";stop("Open this page from a job listing.");return;}
  var found=await client.from("jobs").select("id,title,company,apply_type,apply_url,source_url").eq("id",jobId).maybeSingle();
  if(found.error||!found.data){jobTitle.textContent="Job unavailable";stop(found.error?"This job could not be loaded. Please try again.":"This job may have closed.");return;}
  var job=found.data;
  jobTitle.textContent=job.title+(job.company?" · "+job.company:"");
  // External jobs (apply_type "external", or legacy rows with an employer link) never show the HireIn form.
  var applyType=String(job.apply_type||"").trim().toLowerCase();
  var isExternal=applyType==="external"||(applyType!=="internal"&&Boolean(job.apply_url||job.source_url));
  if(isExternal){
    var target=safeUrl(job.apply_url)||safeUrl(job.source_url);
    if(gateLink)gateLink.href="/job-single.html?id="+encodeURIComponent(job.id);
    if(!target){if(gateLink)gateLink.textContent="Back to job details";stop("Official application link unavailable.");return;}
    gateText.textContent="Redirecting to the employer's official careers website...";
    // Record the click, but never let analytics delay the redirect beyond ~250 ms.
    var tracked=api.recordApplyClick?Promise.resolve(api.recordApplyClick(job.id,"external")).catch(function(){}):Promise.resolve();
    await Promise.race([tracked,new Promise(function(resolve){setTimeout(resolve,250);})]);
    location.replace(target);
    return;
  }
  if(gate)gate.hidden=true;
  form.hidden=false;
  var user=null;
  var auth=await client.auth.getUser(); user=auth.data&&auth.data.user;
  var login=document.getElementById("loginLink");
  if(!user){if(login){login.href="login.html?next="+encodeURIComponent("apply.html?job="+jobId);login.hidden=false;}api.showMessage(notice,"Sign in or create a candidate account before applying.","error");submit.disabled=true;return;}
  var profile=await api.getProfile(user.id);
  if(profile.data&&profile.data.full_name)form.elements.full_name.value=profile.data.full_name;
  if(user.email)form.elements.email.value=user.email;
  var savedResume=document.getElementById("savedResume"),resumeQuery=await client.from("resumes").select("id,name,storage_path").eq("user_id",user.id).order("created_at",{ascending:false});
  (resumeQuery.data||[]).forEach(function(resume){var option=document.createElement("option");option.value=resume.id;option.textContent=resume.name;option.dataset.path=resume.storage_path;savedResume.appendChild(option);});
  savedResume.addEventListener("change",function(){document.getElementById("resumeFile").required=!savedResume.value;});
  submit.disabled=false;
  form.addEventListener("submit",async function(event){
    event.preventDefault();
    var values=new FormData(form),file=values.get("resume_file"),chosen=savedResume.options[savedResume.selectedIndex],path=chosen&&chosen.value?chosen.dataset.path:null,resumeId=chosen&&chosen.value?Number(chosen.value):null;
    if(!path&&(!file||!file.size)){api.showMessage(notice,"Choose a saved resume or upload a PDF to continue.","error");return;}
    if(!path&&(file.type!=="application/pdf"||file.size>5*1024*1024)){api.showMessage(notice,"Upload a PDF smaller than 5 MB.","error");return;}
    submit.disabled=true;api.showMessage(notice,"Uploading resume and submitting your application…","");
    var newResumeId=null,uploadedPath=null;
    if(!path){var cleanName=file.name.replace(/[^a-zA-Z0-9._-]/g,"_"),uploadedPath=user.id+"/applications/"+crypto.randomUUID()+"-"+cleanName;
      var upload=await client.storage.from("resumes").upload(uploadedPath,file,{contentType:"application/pdf",upsert:false});
      if(upload.error){api.showMessage(notice,"Resume upload failed: "+upload.error.message,"error");submit.disabled=false;return;}
      var resume=await client.from("resumes").insert({user_id:user.id,name:file.name,storage_path:uploadedPath}).select("id").single();
      if(resume.error){await client.storage.from("resumes").remove([uploadedPath]);api.showMessage(notice,"Could not save resume record: "+resume.error.message,"error");submit.disabled=false;return;} newResumeId=resume.data.id;path=uploadedPath;
    }
    var application=await client.from("applications").insert({
      job_id:Number(jobId),user_id:user.id,name:String(values.get("full_name")).trim(),
      email:String(values.get("email")).trim(),phone:String(values.get("phone")).trim(),
      portfolio:String(values.get("portfolio")).trim()||null,
      cover_letter:String(values.get("cover_letter")).trim()||null,
      resume_url:path,status:"Applied"
    });
    if(application.error){
      if(newResumeId){await client.from("resumes").delete().eq("id",newResumeId);await client.storage.from("resumes").remove([uploadedPath]);}
      api.showMessage(notice,"Application could not be submitted: "+application.error.message,"error");submit.disabled=false;return;
    }
    api.showMessage(notice,"Application submitted. You can track it in your dashboard.","success");
    form.reset();document.getElementById("resumeFile").required=true;submit.disabled=true;
  });
});

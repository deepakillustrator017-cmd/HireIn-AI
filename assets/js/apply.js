document.addEventListener("DOMContentLoaded",async function(){
  var api=window.hireInAI, form=document.getElementById("applicationForm");
  if(!api||!api.client||!form)return;
  var client=api.client,notice=document.getElementById("status"),submit=document.getElementById("submitButton");
  var jobId=new URLSearchParams(location.search).get("id"),jobTitle=document.getElementById("jobTitle");
  var user=null;
  var auth=await client.auth.getUser(); user=auth.data&&auth.data.user;
  var login=document.getElementById("loginLink");
  if(!user){if(login){login.href="login.html?next="+encodeURIComponent("apply.html?id="+(jobId||""));login.hidden=false;}api.showMessage(notice,"Sign in or create a candidate account before applying.","error");submit.disabled=true;return;}
  if(!jobId||!/^\d+$/.test(jobId)){jobTitle.textContent="Invalid job link";api.showMessage(notice,"Open this page from a job listing.","error");return;}
  var found=await client.from("jobs").select("id,title,company").eq("id",jobId).maybeSingle();
  if(found.error||!found.data){jobTitle.textContent="Job unavailable";api.showMessage(notice,found.error?found.error.message:"This job may have closed.","error");return;}
  jobTitle.textContent=found.data.title+(found.data.company?" · "+found.data.company:"");
  var profile=await api.getProfile(user.id);
  if(profile.data&&profile.data.full_name)form.elements.full_name.value=profile.data.full_name;
  if(user.email)form.elements.email.value=user.email;
  submit.disabled=false;
  form.addEventListener("submit",async function(event){
    event.preventDefault();
    var values=new FormData(form),file=values.get("resume_file");
    if(!file||!file.size){api.showMessage(notice,"Choose your resume PDF to continue.","error");return;}
    if(file.type!=="application/pdf"||file.size>5*1024*1024){api.showMessage(notice,"Upload a PDF smaller than 5 MB.","error");return;}
    submit.disabled=true;api.showMessage(notice,"Uploading resume and submitting your application…","");
    var cleanName=file.name.replace(/[^a-zA-Z0-9._-]/g,"_");
    var path=user.id+"/applications/"+crypto.randomUUID()+"-"+cleanName;
    var upload=await client.storage.from("resumes").upload(path,file,{contentType:"application/pdf",upsert:false});
    if(upload.error){api.showMessage(notice,"Resume upload failed: "+upload.error.message,"error");submit.disabled=false;return;}
    var resume=await client.from("resumes").insert({user_id:user.id,name:file.name,storage_path:path}).select("id").single();
    if(resume.error){await client.storage.from("resumes").remove([path]);api.showMessage(notice,"Could not save resume record: "+resume.error.message,"error");submit.disabled=false;return;}
    var application=await client.from("applications").insert({
      job_id:Number(jobId),user_id:user.id,name:String(values.get("full_name")).trim(),
      email:String(values.get("email")).trim(),phone:String(values.get("phone")).trim(),
      portfolio:String(values.get("portfolio")).trim()||null,
      cover_letter:String(values.get("cover_letter")).trim()||null,
      resume_url:path,status:"Applied"
    });
    if(application.error){
      await client.from("resumes").delete().eq("id",resume.data.id);
      await client.storage.from("resumes").remove([path]);
      api.showMessage(notice,"Application could not be submitted: "+application.error.message,"error");submit.disabled=false;return;
    }
    api.showMessage(notice,"Application submitted. You can track it in your dashboard.","success");
    form.reset();submit.disabled=true;
  });
});
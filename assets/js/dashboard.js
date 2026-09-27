document.addEventListener("DOMContentLoaded",async function(){
  var api=window.hireInAI,client=api&&api.client;if(!client)return;
  var notice=document.getElementById("dashboardMessage"),auth=await client.auth.getUser(),user=auth.data&&auth.data.user;
  if(!user){location.href="login.html?next=dashboard.html";return;}
  var profile=await api.getProfile(user.id);
  document.getElementById("userName").textContent=(profile.data&&profile.data.full_name)||user.email||"Candidate";
  var profileForm=document.getElementById("profileForm"),profileData=await client.from("profiles").select("full_name,phone").eq("user_id",user.id).maybeSingle();
  var hasPhone=true;
  if(profileData.error&&(profileData.error.code==="PGRST204"||profileData.error.code==="42703"||/phone.*column|column.*phone/i.test(profileData.error.message||""))){hasPhone=false;profileData=await client.from("profiles").select("full_name").eq("user_id",user.id).maybeSingle();}
  if(profileData.data){profileForm.elements.full_name.value=profileData.data.full_name||"";profileForm.elements.phone.value=profileData.data.phone||"";}
  profileForm.addEventListener("submit",async function(event){event.preventDefault();var values=new FormData(profileForm),changes={full_name:String(values.get("full_name")).trim()};if(hasPhone)changes.phone=String(values.get("phone")).trim()||null;var save=await client.from("profiles").update(changes).eq("user_id",user.id);if(save.error){api.showMessage(notice,"Could not save profile: "+save.error.message,"error");return;}document.getElementById("userName").textContent=String(values.get("full_name")).trim()||user.email;api.showMessage(notice,"Profile saved.","success");});
  var appRes=await client.from("applications").select("id,job_id,status,applied_at,resume_url,jobs!applications_job_id_fkey(id,title,company)").eq("user_id",user.id).order("id",{ascending:false});
  if(appRes.error)api.showMessage(notice,"Could not load applications: "+appRes.error.message,"error");
  var clickRes=await client.from("apply_clicks").select("id,job_id,apply_type,clicked_at,jobs!apply_clicks_job_id_fkey(id,title,company)").eq("user_id",user.id).eq("apply_type","external").order("clicked_at",{ascending:false});
  var internalApps=(appRes.data||[]).map(function(item){
    return {
      id:"int-"+item.id,
      jobId:item.job_id||(item.jobs&&item.jobs.id),
      title:item.jobs&&item.jobs.title||"Job",
      company:item.jobs&&item.jobs.company||"-",
      status:item.status||"Applied",
      isExternal:false,
      date:item.applied_at,
      resumeUrl:item.resume_url
    };
  });
  var seenClickJobs=new Set(),externalApps=[];
  (clickRes.data||[]).forEach(function(item){
    if(!item.job_id||seenClickJobs.has(Number(item.job_id)))return;
    seenClickJobs.add(Number(item.job_id));
    externalApps.push({
      id:"ext-"+item.id,
      jobId:item.job_id,
      title:item.jobs&&item.jobs.title||"Job",
      company:item.jobs&&item.jobs.company||"-",
      status:"Applied on Company Website",
      isExternal:true,
      date:item.clicked_at,
      resumeUrl:null
    });
  });
  var allApps=internalApps.concat(externalApps).sort(function(a,b){
    return new Date(b.date||0).getTime()-new Date(a.date||0).getTime();
  });
  var applicationPaths=new Set(internalApps.map(function(item){return item.resumeUrl;}).filter(Boolean));
  document.getElementById("applicationCount").textContent=allApps.length;
  document.getElementById("applicationList").innerHTML=allApps.length?allApps.map(function(item){
    var statusBadge=item.isExternal
      ? "<span class='badge badge-external'>🌐 Applied on Company Website</span>"
      : "<span class='badge badge-"+(item.status||"applied").toLowerCase()+"'>"+api.escapeHtml(item.status||"Applied")+"</span>";
    var jobLink=item.jobId
      ? "<a href='/job-single.html?id="+encodeURIComponent(item.jobId)+"'>"+api.escapeHtml(item.title)+"</a>"
      : api.escapeHtml(item.title);
    return "<tr><td>"+jobLink+"</td><td>"+api.escapeHtml(item.company)+"</td><td>"+statusBadge+"</td><td>"+api.escapeHtml(item.date?new Date(item.date).toLocaleDateString("en-IN",{day:"numeric",month:"short",year:"numeric"}):"-")+"</td></tr>";
  }).join(""):"<tr><td colspan='4' class='empty'>No applications yet. Browse jobs to apply.</td></tr>";
  var savedRes=await client.from("saved_jobs").select("id,job_id,jobs!saved_jobs_job_id_fkey(title,company,location)").eq("user_id",user.id).order("id",{ascending:false});
  var saved=savedRes.data||[];document.getElementById("savedCount").textContent=saved.length;
  document.getElementById("savedList").innerHTML=savedRes.error?"<tr><td colspan='3' class='empty'>"+api.escapeHtml(savedRes.error.message)+"</td></tr>":saved.length?saved.map(function(item){var job=item.jobs||{};return "<tr><td><a href='job-single.html?id="+encodeURIComponent(item.job_id)+"'>"+api.escapeHtml(job.title||"Job")+"</a></td><td>"+api.escapeHtml(job.company||"-")+"</td><td><button class='small-button danger' data-unsave='"+Number(item.id)+"'>Remove</button></td></tr>";}).join(""):"<tr><td colspan='3' class='empty'>No saved jobs yet.</td></tr>";
  document.getElementById("savedList").addEventListener("click",async function(event){var button=event.target.closest("[data-unsave]");if(!button)return;button.disabled=true;var result=await client.from("saved_jobs").delete().eq("id",Number(button.dataset.unsave)).eq("user_id",user.id);if(result.error){api.showMessage(notice,result.error.message,"error");button.disabled=false;return;}button.closest("tr").remove();saved.length--;document.getElementById("savedCount").textContent=saved.length;});
  /* ATS History: score, job, date and a full report view (details column holds the saved report). */
  var ATS_BASE="id,job_id,resume_name,score,matched_keywords,missing_keywords,suggestions,created_at,jobs(title,company)";
  var atsRes=await client.from("ats_history").select(ATS_BASE+",details",{count:"exact"}).eq("user_id",user.id).order("created_at",{ascending:false}).limit(25);
  if(atsRes.error&&api.isMissingColumn(atsRes.error))atsRes=await client.from("ats_history").select(ATS_BASE,{count:"exact"}).eq("user_id",user.id).order("created_at",{ascending:false}).limit(25);
  var history=atsRes.data||[],atsDialog=document.getElementById("atsDialog");
  document.getElementById("atsCount").textContent=atsRes.count!=null?atsRes.count:history.length;
  function atsJobName(item){return item.jobs&&item.jobs.title?item.jobs.title+(item.jobs.company?" · "+item.jobs.company:""):(item.details&&item.details.job&&item.details.job.title)||"Custom job description";}
  function scoreClass(score){return score>=80?"band-strong":score>=60?"band-good":score>=40?"band-fair":"band-low";}
  document.getElementById("atsList").innerHTML=atsRes.error?"<tr><td colspan='4' class='empty'>"+api.escapeHtml(atsRes.error.message)+"</td></tr>":history.length?history.map(function(item,index){var score=Number(item.score)||0;return "<tr><td>"+api.escapeHtml(atsJobName(item))+"<div class='muted'>"+api.escapeHtml(item.resume_name||"")+"</div></td><td><span class='ats-score-pill "+scoreClass(score)+"'>"+score+"%</span></td><td>"+api.escapeHtml(item.created_at?new Date(item.created_at).toLocaleDateString("en-IN",{day:"numeric",month:"short",year:"numeric"}):"-")+"</td><td><button type='button' class='small-button' data-report='"+index+"'>View report</button></td></tr>";}).join(""):"<tr><td colspan='4' class='empty'>No ATS checks yet. <a href='ats.html'>Check your resume</a>.</td></tr>";
  document.getElementById("atsList").addEventListener("click",function(event){
    var button=event.target.closest("[data-report]");if(!button||!window.HireInATS)return;
    var item=history[Number(button.dataset.report)];
    document.getElementById("atsDialogTitle").textContent="ATS report · "+atsJobName(item);
    window.HireInATS.render(document.getElementById("atsDialogBody"),window.HireInATS.fromHistory(item),{animate:true});
    atsDialog.showModal();
  });
  atsDialog.addEventListener("click",function(event){if(event.target===atsDialog||event.target.closest("[data-close-dialog]"))atsDialog.close();});
  /* Resume Library: preview, rename, download, delete (storage object + database record). */
  var resumeList=document.getElementById("resumeList"),dialog=document.getElementById("resumeDialog"),dialogFrame=document.getElementById("resumeDialogFrame"),previewUrl=null;
  var resumeRes=await api.resumes.list(user.id),resumes=resumeRes.data;
  var TEMPLATE_LABELS={modern:"Modern",minimal:"Minimal",executive:"Executive",creative:"Creative"};
  function isPdf(item){return /\.pdf$/i.test(item.storage_path||"");}
  function downloadName(item){var base=String(item.resume_name||"resume").replace(/\.(pdf|docx)$/i,"").replace(/[^\w-]+/g,"-").replace(/-+/g,"-").replace(/^-|-$/g,"")||"resume";return base+(isPdf(item)?".pdf":".docx");}
  function renderResumes(){
    document.getElementById("resumeCount").textContent=resumes.length;
    if(resumeRes.error){resumeList.innerHTML="<p class='empty'>Could not load resumes: "+api.escapeHtml(resumeRes.error.message)+"</p>";return;}
    if(!resumes.length){resumeList.innerHTML="<p class='empty'>No resumes yet. <a href='resume-ai.html'>Build your first resume</a>.</p>";return;}
    resumeList.innerHTML=resumes.map(function(item){
      var id=api.escapeHtml(item.id),used=applicationPaths.has(item.storage_path),kind=item.builder?(TEMPLATE_LABELS[item.template]||"Builder")+" template":"Uploaded file";
      var date=item.created_at?new Date(item.created_at).toLocaleDateString(undefined,{year:"numeric",month:"short",day:"numeric"}):"-";
      return "<article class='resume-card' data-id='"+id+"'><div class='resume-card-top'><span class='resume-card-icon' aria-hidden='true'>"+(isPdf(item)?"PDF":"DOC")+"</span><div class='resume-card-title'><h3>"+api.escapeHtml(item.resume_name)+"</h3><span class='muted'>"+api.escapeHtml(kind)+"</span><span class='muted'>Uploaded "+api.escapeHtml(date)+"</span></div></div>"+
        "<div class='resume-card-actions'>"+(isPdf(item)?"<button type='button' class='small-button' data-action='preview'>Preview</button>":"")+"<button type='button' class='small-button secondary-button' data-action='download'>Download</button><button type='button' class='small-button secondary-button' data-action='rename'>Rename</button>"+
        (item.builder&&item.resume_data&&Object.keys(item.resume_data).length?"<a class='small-button secondary-button' href='resume-ai.html?id="+encodeURIComponent(item.id)+"'>Edit</a>":"")+
        (used?"<span class='muted'>Used in an application</span>":"<button type='button' class='small-button danger' data-action='delete'>Delete</button>")+"</div></article>";
    }).join("");
  }
  renderResumes();
  function closePreview(){if(dialog.open)dialog.close();}
  dialog.addEventListener("close",function(){dialogFrame.removeAttribute("src");if(previewUrl){URL.revokeObjectURL(previewUrl);previewUrl=null;}});
  dialog.addEventListener("click",function(event){if(event.target===dialog||event.target.closest("[data-close-dialog]"))closePreview();});
  resumeList.addEventListener("click",async function(event){
    var button=event.target.closest("[data-action]");if(!button)return;
    var card=button.closest(".resume-card"),item=resumes.find(function(r){return String(r.id)===card.dataset.id;});if(!item)return;
    var action=button.dataset.action;
    if(action==="rename"){
      if(card.querySelector(".resume-rename"))return;
      var title=card.querySelector("h3"),formEl=document.createElement("form");formEl.className="resume-rename";
      formEl.innerHTML="<label class='sr-only' for='rename-"+api.escapeHtml(item.id)+"'>Resume name</label><input id='rename-"+api.escapeHtml(item.id)+"' maxlength='120' required><button type='submit' class='small-button'>Save</button><button type='button' class='small-button secondary-button' data-cancel>Cancel</button>";
      var input=formEl.querySelector("input");input.value=item.resume_name;title.hidden=true;title.after(formEl);input.focus();input.select();
      formEl.querySelector("[data-cancel]").addEventListener("click",function(){formEl.remove();title.hidden=false;});
      formEl.addEventListener("submit",async function(e){e.preventDefault();var name=input.value.trim();if(!name)return;var save=formEl.querySelector("[type=submit]");save.disabled=true;
        var result=await api.resumes.rename(user.id,item.id,name);
        if(result.error){api.showMessage(notice,"Could not rename: "+result.error.message,"error");save.disabled=false;return;}
        item.resume_name=name;renderResumes();api.showMessage(notice,"Resume renamed.","success");});
      return;
    }
    button.disabled=true;
    try{
      if(action==="preview"){
        var file=await client.storage.from("resumes").download(item.storage_path);if(file.error)throw new Error("Could not load the PDF: "+file.error.message);
        previewUrl=URL.createObjectURL(new Blob([file.data],{type:"application/pdf"}));
        document.getElementById("resumeDialogTitle").textContent=item.resume_name;
        document.getElementById("resumeDialogOpen").href=await api.resumes.signedUrl(item.storage_path,600).catch(function(){return previewUrl;});
        dialogFrame.src=previewUrl;dialog.showModal();
      }else if(action==="download"){
        var href=await api.resumes.signedUrl(item.storage_path,60,downloadName(item)),link=document.createElement("a");
        link.href=href;link.rel="noopener";document.body.appendChild(link);link.click();link.remove();
      }else if(action==="delete"){
        if(!confirm("Delete \""+item.resume_name+"\"? This removes the PDF and its record permanently.")){button.disabled=false;return;}
        await api.resumes.remove(user.id,item);
        resumes=resumes.filter(function(r){return r.id!==item.id;});renderResumes();api.showMessage(notice,"Resume deleted.","success");return;
      }
    }catch(error){api.showMessage(notice,error.message,"error");}
    button.disabled=false;
  });
});

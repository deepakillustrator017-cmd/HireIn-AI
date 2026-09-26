document.addEventListener("DOMContentLoaded",async function(){
  var api=window.hireInAI,client=api&&api.client;
  if(!client)return;
  var form=document.getElementById("atsForm"),jobSelect=document.getElementById("jobId"),description=document.getElementById("jobDescription");
  var notice=document.getElementById("atsMessage"),result=document.getElementById("atsResult"),button=document.getElementById("analyzeButton");
  var auth=await client.auth.getUser(),user=auth.data&&auth.data.user;
  if(!user){api.showMessage(notice,"Sign in to analyze and save your ATS history.","error");var link=document.getElementById("atsLogin");if(link){link.href="login.html?next=ats.html";link.hidden=false;}button.disabled=true;return;}
  var jobs=await client.from("jobs").select("id,title,company,description").order("id",{ascending:false});
  if(jobs.error){api.showMessage(notice,"Could not load jobs: "+jobs.error.message,"error");return;}
  jobs.data.forEach(function(job){var option=document.createElement("option");option.value=job.id;option.textContent=job.title+" â€” "+job.company;option.dataset.description=job.description||"";jobSelect.appendChild(option);});
  jobSelect.addEventListener("change",function(){var opt=jobSelect.options[jobSelect.selectedIndex];if(opt&&opt.dataset.description)description.value=opt.dataset.description;});
  form.addEventListener("submit",async function(event){
    event.preventDefault();
    var file=document.getElementById("resumeFile").files[0];
    if(!file){api.showMessage(notice,"Choose a PDF resume first.","error");return;}
    if(file.type!=="application/pdf"||file.size>5*1024*1024){api.showMessage(notice,"Upload a PDF smaller than 5 MB.","error");return;}
    var jobText=description.value.trim();
    if(jobText.length<40){api.showMessage(notice,"Choose a job or add a fuller job description (at least 40 characters).","error");return;}
    button.disabled=true;api.showMessage(notice,"Reading your PDF and matching keywordsâ€¦","");
    try{
      if(!window.pdfjsLib)throw new Error("PDF reader did not load. Refresh and try again.");
      window.pdfjsLib.GlobalWorkerOptions.workerSrc="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js";
      var pdf=await window.pdfjsLib.getDocument({data:await file.arrayBuffer()}).promise;
      var parts=[];
      for(var p=1;p<=pdf.numPages;p++){var page=await pdf.getPage(p),content=await page.getTextContent();parts.push(content.items.map(function(item){return item.str;}).join(" "));}
      var resumeText=parts.join(" ").toLowerCase();
      if(resumeText.trim().length<40)throw new Error("No readable text found. Upload a text-based PDF instead of a scanned image.");
      var stop=new Set("the and for with from that this your you our are was were will have has had into about their them they then than when where what which while using use used also can may should must job role work team company candidate experience skills ability".split(" "));
      var words=jobText.toLowerCase().match(/[a-z][a-z0-9+#./-]{2,}/g)||[];
      var keywords=Array.from(new Set(words)).filter(function(word){return !stop.has(word);}).slice(0,60);
      if(!keywords.length)throw new Error("Could not find enough keywords in the job description.");
      var matched=keywords.filter(function(word){return resumeText.includes(word);});
      var missing=keywords.filter(function(word){return !resumeText.includes(word);}).slice(0,12);
      var score=Math.round(matched.length/keywords.length*100);
      var tips=[];
      if(missing.length)tips.push("Add relevant missing terms only where they truthfully describe your experience: "+missing.slice(0,6).join(", ")+".");
      if(score<70)tips.push("Tailor your summary and recent experience to the role's core responsibilities.");
      tips.push("Use measurable outcomes and standard section headings such as Experience, Skills, and Education.");
      tips.push("This score is a keyword estimate, not a hiring decision. Review the resume yourself before applying.");
      var path=user.id+"/ats/"+crypto.randomUUID()+"-"+file.name.replace(/[^a-zA-Z0-9._-]/g,"_");
      var upload=await client.storage.from("resumes").upload(path,file,{contentType:"application/pdf",upsert:false});
      if(upload.error)throw new Error("Resume upload failed: "+upload.error.message);
      var resume=await client.from("resumes").insert({user_id:user.id,name:file.name,storage_path:path});
      if(resume.error){await client.storage.from("resumes").remove([path]);throw new Error(resume.error.message);}
      var jobIdValue=jobSelect.value?Number(jobSelect.value):null;
      var saved=await client.from("ats_history").insert({user_id:user.id,job_id:jobIdValue,resume_name:file.name,score:score,matched_keywords:matched,missing_keywords:missing,suggestions:tips.join(" ")});
      if(saved.error){api.showMessage(notice,"Score calculated, but history could not be saved: "+saved.error.message,"error");button.disabled=false;return;}
      document.getElementById("scoreValue").textContent=score;document.getElementById("scoreRing").style.setProperty("--score",score+"%");
      document.getElementById("matchedKeywords").textContent=matched.length?matched.join(", "):"No matching terms found";
      document.getElementById("missingKeywords").textContent=missing.length?missing.join(", "):"No major missing keywords";
      document.getElementById("suggestions").innerHTML="<ul>"+tips.map(function(tip){return "<li>"+api.escapeHtml(tip)+"</li>";}).join("")+"</ul>";
      result.hidden=false;api.showMessage(notice,"Analysis complete. Your resume and result are saved to your account.","success");
    }catch(error){api.showMessage(notice,error.message||"Could not analyze this PDF.","error");}
    button.disabled=false;
  });
});

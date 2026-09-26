document.addEventListener("DOMContentLoaded",async function(){
  var api=window.hireInAI,client=api&&api.client,search=document.getElementById("search"),grid=document.getElementById("jobs");if(!client||!grid)return;
  var jobs=[],user=null,saved=new Set(),notice=document.getElementById("jobsMessage");
  var auth=await client.auth.getUser();user=auth.data&&auth.data.user;
  if(user){var savedResult=await client.from("saved_jobs").select("job_id").eq("user_id",user.id);(savedResult.data||[]).forEach(function(item){saved.add(Number(item.job_id));});}
  function imageUrl(value){var url=String(value||"");return /^(https?:\/\/|assets\/)/i.test(url)?api.escapeHtml(url):"assets/imgs/theme/jobhub-logo.svg";}
  function render(){
    var query=(search.value||"").trim().toLowerCase();
    var visible=jobs.filter(function(job){return [job.title,job.company,job.location,job.category,job.description].join(" ").toLowerCase().includes(query);});
    if(!visible.length){grid.innerHTML="<div class='empty'>No jobs match your search.</div>";return;}
    grid.innerHTML=visible.map(function(job){
      var id=Number(job.id),posted=job.posted_at?new Date(job.posted_at).toLocaleDateString("en-IN"):"Recently";
      return "<article class='card'><div class='head'><img class='logo-img' alt='' src='"+imageUrl(job.logo)+"'><div><div class='category'>"+api.escapeHtml(job.category||"Opportunity")+"</div><div class='company'>"+api.escapeHtml(job.company||"Company")+"</div></div></div><h2 class='title'>"+api.escapeHtml(job.title||"Open role")+"</h2><div class='meta'>"+api.escapeHtml(job.location||"Remote")+" · "+api.escapeHtml(job.type||"Full time")+"</div><p class='job-summary'>"+api.escapeHtml(String(job.description||"").slice(0,180))+"</p><div class='salary'>"+api.escapeHtml(job.salary||"Salary not listed")+"</div><div class='footer'><span class='date'>Posted "+api.escapeHtml(posted)+"</span><div><button class='save-job' type='button' data-save='"+id+"'>"+(saved.has(id)?"Saved":"Save")+"</button> <a class='btn' href='job-single.html?id="+encodeURIComponent(id)+"'>View</a></div></div></article>";
    }).join("");
  }
  async function loadJobs(){
    grid.innerHTML="<div class='empty'>Loading jobs…</div>";
    var result=await client.from("jobs").select("*").in("status",["published","active"]).order("id",{ascending:false});
    if(result.error){grid.innerHTML="<div class='empty'>Could not load jobs: "+api.escapeHtml(result.error.message)+"</div>";return;}
    jobs=result.data||[];render();
  }
  grid.addEventListener("click",async function(event){
    var button=event.target.closest("[data-save]");if(!button)return;
    if(!user){location.href="login.html?next=job-grid.html";return;}
    var id=Number(button.dataset.save);
    if(saved.has(id)){api.showMessage(notice,"This job is already in your saved list.","success");return;}
    button.disabled=true;
    var result=await client.from("saved_jobs").insert({user_id:user.id,job_id:id});
    button.disabled=false;
    if(result.error){api.showMessage(notice,result.error.message,"error");return;}
    saved.add(id);button.textContent="Saved";api.showMessage(notice,"Job saved to your dashboard.","success");
  });
  if(search)search.addEventListener("input",render);
  document.getElementById("searchForm")?.addEventListener("submit",function(event){event.preventDefault();render();});
  loadJobs();
});
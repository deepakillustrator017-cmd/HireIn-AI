document.addEventListener("DOMContentLoaded",async function(){
  var api=window.hireInAI,client=api&&api.client;if(!client)return;
  var notice=document.getElementById("adminMessage"),auth=await client.auth.getUser(),user=auth.data&&auth.data.user;
  if(!user){location.href="login.html?next=admin.html";return;}
  var profile=await api.getProfile(user.id),role=profile.data&&profile.data.role;
  if(role!=="recruiter"&&role!=="admin"){api.showMessage(notice,"Recruiter access is not enabled for this account. Ask your site administrator to assign the recruiter role.","error");return;}
  document.getElementById("adminContent").hidden=false;
  var result=await client.from("jobs").select("id,title,company,location,salary,status,created_by").order("id",{ascending:false});
  var tbody=document.getElementById("jobRows");
  if(result.error){tbody.innerHTML="<tr><td colspan='5' class='empty'>"+api.escapeHtml(result.error.message)+"</td></tr>";return;}
  var jobs=result.data||[];
  tbody.innerHTML=jobs.length?jobs.map(function(job){var canManage=role==="admin"||job.created_by===user.id;return "<tr><td>"+api.escapeHtml(job.title||"Untitled")+"</td><td>"+api.escapeHtml(job.company||"â€”")+"</td><td>"+api.escapeHtml(job.location||"â€”")+"</td><td>"+api.escapeHtml(job.salary||"â€”")+"</td><td>"+(canManage?"<a class='small-button' href='post-job.html?edit="+Number(job.id)+"'>Edit</a> <button class='small-button danger' data-delete='"+Number(job.id)+"'>Delete</button>":"<span class='muted'>Managed by another recruiter</span>")+"</td></tr>";}).join(""):"<tr><td colspan='5' class='empty'>No jobs yet. Post your first role.</td></tr>";
  tbody.addEventListener("click",async function(event){var button=event.target.closest("[data-delete]");if(!button)return;if(!confirm("Delete this job? This action cannot be undone."))return;button.disabled=true;var del=await client.from("jobs").delete().eq("id",Number(button.dataset.delete));if(del.error){api.showMessage(notice,"Could not delete job: "+del.error.message+" Related applications may prevent deletion; review the database error before retrying.","error");button.disabled=false;return;}location.reload();});
});


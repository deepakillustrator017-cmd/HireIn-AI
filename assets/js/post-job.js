document.addEventListener("DOMContentLoaded",async function(){
  var api=window.hireInAI,client=api&&api.client,form=document.getElementById("jobForm");if(!client||!form)return;
  var notice=document.getElementById("jobMessage"),button=form.querySelector("button[type=submit]"),params=new URLSearchParams(location.search),editId=params.get("edit");
  var auth=await client.auth.getUser(),user=auth.data&&auth.data.user;if(!user){location.href="login.html?next="+encodeURIComponent(location.pathname.split("/").pop()+location.search);return;}
  var profile=await api.getProfile(user.id),role=profile.data&&profile.data.role;if(role!=="recruiter"&&role!=="admin"){api.showMessage(notice,"Only approved recruiters can post jobs.","error");button.disabled=true;return;}
  if(editId){var found=await client.from("jobs").select("*").eq("id",editId).maybeSingle();if(found.error||!found.data){api.showMessage(notice,found.error?found.error.message:"Job not found or not editable.","error");button.disabled=true;return;}var job=found.data;["title","company","category","location","type","salary","description"].forEach(function(key){if(form.elements[key])form.elements[key].value=job[key]||"";});document.getElementById("jobPageTitle").textContent="Edit job";button.textContent="Save Changes";}
  form.addEventListener("submit",async function(event){event.preventDefault();var values=new FormData(form),payload={title:String(values.get("title")).trim(),company:String(values.get("company")).trim(),category:String(values.get("category")).trim()||null,location:String(values.get("location")).trim(),type:String(values.get("type")).trim()||"Full time",salary:String(values.get("salary")).trim()||null,description:String(values.get("description")).trim(),status:"published"};
    if(!payload.title||!payload.company||!payload.location||!payload.description){api.showMessage(notice,"Complete all required fields.","error");return;}
    button.disabled=true;api.showMessage(notice,editId?"Saving changesâ€¦":"Publishing jobâ€¦","");
    var saved=editId?await client.from("jobs").update(payload).eq("id",editId).select("id").maybeSingle():await client.from("jobs").insert(Object.assign(payload,{created_by:user.id})).select("id").single();
    button.disabled=false;if(saved.error){api.showMessage(notice,saved.error.message,"error");return;}
    api.showMessage(notice,"Job published successfully.","success");location.href="admin.html";
  });
});

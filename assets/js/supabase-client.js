(function () {
  var url = "https://xyazcbtxuahzrkxdzywy.supabase.co";
  var key = "sb_publishable_q6gw-Br9OjigN_ETqi17yw_RuKBx2Fs";
  // Shared site chrome: mobile menu toggle and footer year. Runs even if Supabase fails to load.
  function initChrome() {
    var toggle=document.querySelector(".site-nav-toggle"),header=document.querySelector(".site-header");
    if(toggle&&header&&!toggle.dataset.bound){
      toggle.dataset.bound="1";
      toggle.addEventListener("click",function(){var open=header.classList.toggle("is-open");toggle.setAttribute("aria-expanded",String(open));toggle.setAttribute("aria-label",open?"Close menu":"Open menu");});
      document.addEventListener("keydown",function(e){if(e.key==="Escape"&&header.classList.contains("is-open")){header.classList.remove("is-open");toggle.setAttribute("aria-expanded","false");toggle.focus();}});
    }
    document.querySelectorAll("[data-year]").forEach(function(node){node.textContent=new Date().getFullYear();});
  }
  if(document.readyState==="loading")document.addEventListener("DOMContentLoaded",initChrome);else initChrome();
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
    var next=new URLSearchParams(location.search).get("next")||"/dashboard.html";
    if(!/^\/?(?:index(?:\.html)?|jobs(?:\.html)?|job-grid(?:\.html)?|job\/\d+|job-single(?:\.html)?|apply(?:\.html)?|ats(?:\.html)?|dashboard(?:\.html)?|resume-ai(?:\.html)?|recruiters(?:\.html)?|recruiter|admin(?:\.html)?|post-job(?:\.html)?|login(?:\.html)?|signup(?:\.html)?)?(?:\?[a-z0-9_%=&./-]*)?$/i.test(next))return "/dashboard.html";
    return next.charAt(0)==="/"?next:"/"+next;
  };
  var getProfile = function(userId) {
    return client.from("profiles").select("user_id,full_name,role").eq("user_id",userId).maybeSingle();
  };
  var isMissingColumn = function(error) {
    return Boolean(error&&(error.code==="PGRST204"||error.code==="42703"||/column .* does not exist|could not find the .* column/i.test(error.message||"")));
  };
  // Resume library: PDFs live in the private "resumes" bucket at <user_id>/builder/<uuid>.pdf.
  // resume_url stores that object path; viewers get short-lived signed URLs.
  // Every call falls back to the original columns (name, storage_path) until supabase/schema.sql is applied.
  var BASE_COLUMNS="id,user_id,name,storage_path,created_at",FULL_COLUMNS=BASE_COLUMNS+",resume_name,resume_url,template,resume_data";
  var normalizeResume = function(row) {
    var path=row.resume_url||row.storage_path;
    return {id:row.id,user_id:row.user_id,resume_name:row.resume_name||row.name||"Resume",resume_url:path,storage_path:row.storage_path||path,template:row.template||null,resume_data:row.resume_data||null,created_at:row.created_at,builder:/\/builder\//.test(path||"")};
  };
  var resumes = {
    list: async function(userId) {
      var result=await client.from("resumes").select(FULL_COLUMNS).eq("user_id",userId).order("created_at",{ascending:false});
      if(result.error&&isMissingColumn(result.error))result=await client.from("resumes").select(BASE_COLUMNS).eq("user_id",userId).order("created_at",{ascending:false});
      return {data:(result.data||[]).map(normalizeResume),error:result.error};
    },
    get: async function(userId,id) {
      var result=await client.from("resumes").select(FULL_COLUMNS).eq("user_id",userId).eq("id",id).maybeSingle();
      if(result.error&&isMissingColumn(result.error))result=await client.from("resumes").select(BASE_COLUMNS).eq("user_id",userId).eq("id",id).maybeSingle();
      return {data:result.data?normalizeResume(result.data):null,error:result.error};
    },
    save: async function(userId,blob,meta) {
      var path=userId+"/builder/"+crypto.randomUUID()+".pdf";
      var upload=await client.storage.from("resumes").upload(path,blob,{contentType:"application/pdf",upsert:false});
      if(upload.error)throw new Error("PDF upload failed: "+upload.error.message);
      var row={user_id:userId,name:meta.resume_name,storage_path:path,resume_name:meta.resume_name,resume_url:path,template:meta.template,resume_data:meta.resume_data||{}};
      var insert=await client.from("resumes").insert(row).select(FULL_COLUMNS).single();
      if(insert.error&&isMissingColumn(insert.error))insert=await client.from("resumes").insert({user_id:userId,name:meta.resume_name,storage_path:path}).select(BASE_COLUMNS).single();
      if(insert.error){await client.storage.from("resumes").remove([path]);throw new Error("Could not save the resume record: "+insert.error.message);}
      return normalizeResume(insert.data);
    },
    rename: async function(userId,id,name) {
      var result=await client.from("resumes").update({name:name,resume_name:name}).eq("id",id).eq("user_id",userId).select("id");
      if(result.error&&isMissingColumn(result.error))result=await client.from("resumes").update({name:name}).eq("id",id).eq("user_id",userId).select("id");
      if(!result.error&&!(result.data&&result.data.length))return {error:{message:"Resume not found or not editable."}};
      return {error:result.error};
    },
    signedUrl: async function(path,seconds,downloadName) {
      var result=await client.storage.from("resumes").createSignedUrl(path,seconds||3600,downloadName?{download:downloadName}:undefined);
      if(result.error||!result.data)throw new Error("Could not open the file: "+(result.error&&result.error.message||"link unavailable"));
      return result.data.signedUrl;
    },
    remove: async function(userId,resume) {
      var removed=await client.storage.from("resumes").remove([resume.storage_path]);
      if(removed.error)throw new Error("Could not remove the file: "+removed.error.message);
      var record=await client.from("resumes").delete().eq("id",resume.id).eq("user_id",userId);
      if(record.error)throw new Error("The file was removed, but its record could not be deleted: "+record.error.message);
    }
  };
  // Job helpers: older rows keep the work mode in employment_type and may lack category, experience,
  // salary_min and skills, so these values are derived consistently for jobs, job detail and ATS pages.
  var MODES=["Remote","Hybrid","Onsite"];
  var CATEGORIES=[["Design",/design|\bui\b|\bux\b|graphic|illustrat|motion|animat|visual|art director/],["Data & AI",/\bdata\b|analyst|machine learning|\bml\b|\bai\b|scientist/],["Engineering",/engineer|developer|programmer|software|front.?end|back.?end|full.?stack|devops|\bqa\b|tester|android|\bios\b/],["Product",/product manager|product owner/],["Marketing",/marketing|\bseo\b|growth|social media|brand manager/],["Content & Writing",/writer|content|copy|editor/],["Sales",/sales|business development|account executive/],["Human Resources",/recruit|talent|\bhr\b|human resource/],["Finance",/accountant|accounting|finance|audit|\btax\b/],["Customer Support",/support|customer success|customer service/],["Operations",/operations|logistics|supply chain/]];
  function titleCase(value){return String(value||"").trim().replace(/\s+/g," ").replace(/\b\w/g,function(c){return c.toUpperCase();});}
  function generateMonogramSvg(name) {
    var cleaned = String(name || "Company").trim().replace(/[^a-zA-Z0-9\s]/g, "");
    var parts = cleaned.split(/\s+/).filter(Boolean);
    var initials = "";
    if (parts.length >= 2) {
      initials = (parts[0][0] + parts[1][0]).toUpperCase();
    } else if (parts.length === 1 && parts[0].length >= 2) {
      initials = parts[0].substring(0, 2).toUpperCase();
    } else if (parts.length === 1) {
      initials = parts[0][0].toUpperCase();
    } else {
      initials = "HI";
    }
    var svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="100" height="100">' +
      '<rect width="100" height="100" rx="20" fill="#6C3EF4"/>' +
      '<text x="50" y="52" font-family="-apple-system,BlinkMacSystemFont,\'Segoe UI\',Roboto,sans-serif" font-size="42" font-weight="700" fill="#FFFFFF" text-anchor="middle" dominant-baseline="central">' +
      initials +
      '</text></svg>';
    return "data:image/svg+xml;utf8," + encodeURIComponent(svg);
  }

  function extractDomain(url, companyName) {
    if (url && typeof url === "string") {
      var clean = url.trim().replace(/^https?:\/\//i, "").split("/")[0].split("?")[0].replace(/^www\./i, "");
      if (clean && clean.indexOf(".") > 0) return clean;
    }
    if (companyName && typeof companyName === "string") {
      var slug = companyName.toLowerCase().replace(/[^a-z0-9]/g, "");
      if (slug) return slug + ".com";
    }
    return "";
  }

  function handleLogoError(img, companyName, websiteOrUrl) {
    if (!img) return;
    var step = Number(img.dataset.logoStep || 0);
    var name = companyName || img.getAttribute("data-company") || (img.alt ? img.alt.replace(/\s+logo$/i, "") : "") || "Company";
    var domain = extractDomain(websiteOrUrl || img.getAttribute("data-domain") || img.getAttribute("data-source-url"), name);

    if (step === 0 && domain && !/google\.com\/s2\/favicons/.test(img.src)) {
      img.dataset.logoStep = "1";
      img.src = "https://www.google.com/s2/favicons?domain=" + encodeURIComponent(domain) + "&sz=128";
      return;
    }

    img.dataset.logoStep = "2";
    img.onerror = null;
    img.src = generateMonogramSvg(name);
  }

  var jobs = {
    MODES:MODES,
    mode:function(job){
      var type=titleCase(job.employment_type),mode=titleCase(job.work_mode);
      if(MODES.indexOf(type)>=0)return type;
      if(/remote/i.test(job.location||""))return "Remote";
      return MODES.indexOf(mode)>=0?mode:"Onsite";
    },
    type:function(job){var type=titleCase(job.employment_type||job.type);return !type||MODES.indexOf(type)>=0?"Full time":type.replace(/^Full Time$/,"Full time").replace(/^Part Time$/,"Part time");},
    category:function(job){
      var raw=String(job.category||"").trim(),lower=raw.toLowerCase();
      if(lower.length>=3){var known=CATEGORIES.find(function(c){return c[0].toLowerCase().indexOf(lower)===0||lower.indexOf(c[0].toLowerCase())===0;});if(known)return known[0];}
      var inferred=CATEGORIES.find(function(c){return c[1].test(String(job.title||"").toLowerCase());})||CATEGORIES.find(function(c){return c[1].test(String(job.description||"").toLowerCase());});
      return inferred?inferred[0]:(raw.length>3?titleCase(raw):"Other");
    },
    level:function(job){
      var text=(String(job.experience||"")+" "+String(job.title||"")).toLowerCase(),years=(String(job.experience||"").match(/\d+/)||[])[0];
      if(/senior|\bsr\.?\b|\blead\b|principal|\bhead\b|manager|director/.test(text)||Number(years)>=6)return "senior";
      if(/junior|\bjr\.?\b|intern|trainee|fresher|entry|graduate/.test(text)||(years!=null&&Number(years)<2))return "entry";
      if(years!=null)return "mid";
      return "";
    },
    levelLabel:function(level){return {entry:"Entry level",mid:"Mid level",senior:"Senior level"}[level]||"";},
    // Annual salary in INR for filtering/sorting. Bare numbers under 1 lakh are treated as monthly pay.
    salary:function(job){
      if(Number(job.salary_min)>0)return Number(job.salary_min);
      var text=String(job.salary||"").toLowerCase().replace(/,/g,""),match=text.match(/\d+(?:\.\d+)?/);
      if(!match)return 0;
      var amount=Number(match[0]);
      if(/lpa|lakh|\blac|\bl\b/.test(text))return amount*100000;
      if(/\bcr/.test(text))return amount*10000000;
      if(/\d\s*k\b/.test(text))amount*=1000;
      if(/month|\/m|pm\b/.test(text)||amount<100000)return amount*12;
      return amount;
    },
    skills:function(job){return Array.isArray(job.skills)?job.skills.filter(Boolean):String(job.skills||"").split(/[,\n]/).map(function(s){return s.trim();}).filter(Boolean);},
    posted:function(job){var d=new Date(job.posted_at||job.created_at||0);return Number.isNaN(d.getTime())?0:d.getTime();},
    logo:function(job){
      var v=String((job && (job.logo || job.logo_url)) || "").trim();
      if(/^https?:\/\//i.test(v))return v;
      if(/^\/?assets\/[\w./-]+$/i.test(v))return "/"+v.replace(/^\//,"");
      var compName=String((job && (job.company || job.name)) || "").trim();
      var domain=extractDomain((job && (job.website || job.source_url)) || "", compName);
      if(domain)return "https://www.google.com/s2/favicons?domain=" + encodeURIComponent(domain) + "&sz=128";
      return generateMonogramSvg(compName || "Company");
    },
    href:function(job){return "/job-single.html?id="+encodeURIComponent(job.id);},
    // One job card used by the homepage, jobs page and related jobs so they always look the same.
    card:function(job,options){
      options=options||{};
      var posted=jobs.posted(job),company=String(job.company||"Company"),href=jobs.href(job),skills=jobs.skills(job);
      var loc=String(job.location||"").trim().replace(/\b\w/g,function(c){return c.toUpperCase();})||"Remote";
      var meta=[loc,jobs.mode(job),jobs.type(job),jobs.levelLabel(jobs.level(job))||job.experience].filter(Boolean);
      var save=options.saveable?"<button class='save-job' type='button' data-save='"+escapeHtml(job.id)+"' aria-pressed='"+Boolean(options.saved)+"' aria-label='"+(options.saved?"Remove ":"Save ")+escapeHtml(job.title||"job")+(options.saved?" from saved jobs":"")+"'>"+(options.saved?"Saved ✓":"Save")+"</button>":"";
      var domain=extractDomain(job.website || job.source_url, company);
      var logoSrc=jobs.logo(job);
      return "<article class='card'><div class='head'><img class='logo-img' loading='lazy' decoding='async' width='44' height='44' referrerpolicy='no-referrer' alt='"+escapeHtml(company)+" logo' src='"+escapeHtml(logoSrc)+"' data-company='"+escapeHtml(company)+"' data-domain='"+escapeHtml(domain)+"' onerror='window.hireInAI.handleLogoError(this)'><div class='job-company-block'><div class='category'>"+escapeHtml(jobs.category(job))+"</div><div class='company'>"+escapeHtml(company)+"</div></div></div>"+
        "<h3 class='title'><a href='"+href+"'>"+escapeHtml(job.title||"Open role")+"</a></h3>"+
        "<div class='meta'>"+meta.map(function(m){return "<span>"+escapeHtml(m)+"</span>";}).join("")+"</div>"+
        (options.summary===false?"":"<p class='job-summary'>"+escapeHtml(String(job.description||"").slice(0,160))+"</p>")+
        (skills.length?"<div class='job-tags'>"+skills.slice(0,4).map(function(s){return "<span>"+escapeHtml(s)+"</span>";}).join("")+"</div>":"")+
        "<div class='salary'>"+escapeHtml(job.salary||"Salary not listed")+"</div><div class='footer'><span class='date'>"+(posted?"Posted "+escapeHtml(new Date(posted).toLocaleDateString("en-IN",{day:"numeric",month:"short",year:"numeric"})):"Recently posted")+"</span><div>"+save+"<a class='btn' href='"+href+"'>View</a></div></div></article>";
    },
    listPublished:async function(columns,limit){
      var query=client.from("jobs").select(columns||"*").in("status",["published","active"]).order("posted_at",{ascending:false});
      if(limit)query=query.limit(limit);
      return query;
    },
    savedIds:async function(userId){var r=await client.from("saved_jobs").select("job_id").eq("user_id",userId);return new Set((r.data||[]).map(function(x){return Number(x.job_id);}));},
    setSaved:async function(userId,jobId,save){
      var r=save?await client.from("saved_jobs").insert({user_id:userId,job_id:Number(jobId)}):await client.from("saved_jobs").delete().eq("user_id",userId).eq("job_id",Number(jobId));
      if(r.error&&!(save&&r.error.code==="23505"))throw new Error(r.error.message);
    }
  };
  window.hireInAI={
    client:client,
    escapeHtml:escapeHtml,
    showMessage:showMessage,
    safeNext:safeNext,
    getProfile:getProfile,
    isMissingColumn:isMissingColumn,
    resumes:resumes,
    jobs:jobs,
    monogram:generateMonogramSvg,
    extractDomain:extractDomain,
    handleLogoError:handleLogoError,
    error:null
  };
  // Header account link: "Sign In" for visitors, "Dashboard" once signed in.
  client.auth.getSession().then(function(result){
    if(!(result.data&&result.data.session))return;
    document.querySelectorAll("[data-auth-link]").forEach(function(link){link.textContent="Dashboard";link.href="/dashboard.html";});
  }).catch(function(){});
  document.querySelectorAll("[data-logout]").forEach(function(button) {
    button.addEventListener("click",async function() {
      var result=await client.auth.signOut();
      if(result.error){alert(result.error.message);return;}
      location.href="/";
    });
  });
})();

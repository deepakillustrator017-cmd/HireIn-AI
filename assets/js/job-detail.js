(function () {
  "use strict";
  document.addEventListener("DOMContentLoaded", async function () {
    var api = window.hireInAI;
    if (!api || !api.client) return;
    var client = api.client, J = api.jobs;
    var notice = document.getElementById("jobMessage");
    var content = document.getElementById("jobContent");
    var match = location.pathname.match(/\/job\/([^/]+)/i);
    var jobId = new URLSearchParams(location.search).get("id") || (match && decodeURIComponent(match[1]));
    function escape(value) { return api.escapeHtml(value == null ? "" : value); }
    function setText(id, value) { document.getElementById(id).textContent = value || ""; }
    function setRichText(id, value) {
      var target = document.getElementById(id);
      var lines = Array.isArray(value) ? value : String(value || "").split(/\r?\n/).filter(Boolean);
      target.innerHTML = lines.length ? lines.map(function (line) { return "<p>" + escape(line) + "</p>"; }).join("") : "<p>Details will be shared by the employer.</p>";
    }
    // Related jobs: same category, company, work mode, location or shared title/skill words.
    async function renderRelated(job) {
      try {
        var result = await J.listPublished("*", 60);
        if (result.error) return;
        var words = function (j) { return new Set((String(j.title || "") + " " + J.skills(j).join(" ")).toLowerCase().match(/[a-z][a-z+#]{2,}/g) || []); };
        var mine = words(job), category = J.category(job), mode = J.mode(job), place = String(job.location || "").toLowerCase();
        var ranked = (result.data || []).filter(function (j) { return String(j.id) !== String(job.id); }).map(function (j) {
          var score = (J.category(j) === category ? 4 : 0) + (j.company && j.company === job.company ? 2 : 0) + (J.mode(j) === mode ? 1 : 0) + (String(j.location || "").toLowerCase() === place ? 1 : 0);
          words(j).forEach(function (w) { if (mine.has(w)) score += 2; });
          return { job: j, score: score };
        }).filter(function (r) { return r.score > 0; }).sort(function (a, b) { return b.score - a.score || J.posted(b.job) - J.posted(a.job); }).slice(0, 3);
        if (!ranked.length) return;
        document.getElementById("relatedList").innerHTML = ranked.map(function (r) { return J.card(r.job, { summary: false }); }).join("");
        document.getElementById("relatedJobs").hidden = false;
      } catch (_) { /* Related jobs are optional. */ }
    }
    if (!/^\d+$/.test(String(jobId || ""))) {
      api.showMessage(notice, "This job link is invalid. Browse jobs and try again.", "error");
      return;
    }
    try {
      var userResult = await client.auth.getUser();
      var user = userResult.data && userResult.data.user;
      var result = await client.from("jobs").select("*").eq("id", jobId).maybeSingle();
      if (result.error) throw result.error;
      if (!result.data) throw new Error("This job is no longer available.");
      var job = result.data;
      var company = {};
      if (job.company_id) {
        try {
          var companyResult = await client.from("companies").select("name,description,website,logo_url,location").eq("id", job.company_id).maybeSingle();
          if (!companyResult.error && companyResult.data) company = companyResult.data;
        } catch (_) { /* Company profiles are optional until the schema migration is applied. */ }
      }
      var logo = job.logo || company.logo_url || "";
      var image = document.getElementById("jobLogo");
      var compName = job.company || company.name || "Company";
      var compDomain = api.extractDomain ? api.extractDomain(company.website || job.source_url, compName) : "";
      if (image) {
        image.referrerPolicy = "no-referrer";
        image.alt = compName + " logo";
        image.dataset.company = compName;
        image.dataset.domain = compDomain;
        image.onerror = function () { if (api.handleLogoError) api.handleLogoError(image, compName, compDomain); };
        image.src = api.jobs.logo({ logo: logo, website: company.website, source_url: job.source_url, company: compName });
      }
      setText("jobCategory", J.category(job));
      setText("jobTitle", job.title || "Open role");
      setText("jobCompany", job.company || company.name || "Company");
      setText("jobBreadcrumb", job.title || "Job details");
      setRichText("jobDescription", job.description);
      setRichText("jobResponsibilities", job.responsibilities);
      setRichText("jobRequirements", job.requirements);
      setRichText("jobBenefits", job.benefits);
      ["responsibilities", "requirements", "benefits"].forEach(function (key) {
        document.getElementById(key + "Section").hidden = !job[key];
      });
      var skills = Array.isArray(job.skills) ? job.skills : String(job.skills || "").split(/[,\n]/).map(function (skill) { return skill.trim(); }).filter(Boolean);
      document.getElementById("skillsSection").hidden = !skills.length;
      document.getElementById("jobSkills").innerHTML = skills.map(function (skill) { return "<span>" + escape(skill) + "</span>"; }).join("");
      var mode = J.mode(job);
      var metadata = [job.location || "Remote", mode, J.levelLabel(J.level(job)) || job.experience, J.type(job), job.posted_at ? "Posted " + new Date(job.posted_at).toLocaleDateString("en-IN") : "Recently posted"].filter(Boolean);
      document.getElementById("jobMeta").innerHTML = metadata.map(function (value) { return "<span>" + escape(value) + "</span>"; }).join("");
      setText("jobSalary", job.salary || "Salary not listed");
      setText("companyInfo", [company.description || ((job.company || company.name || "The employer") + " is hiring through HireIn AI."), company.website && "Website: " + company.website, company.location && "Location: " + company.location].filter(Boolean).join("\n"));
      document.getElementById("applyNow").href = "/apply.html?id=" + encodeURIComponent(job.id);
      var pageTitle = (job.title || "Job details") + " at " + (job.company || company.name || "HireIn AI") + " | HireIn AI";
      var pageDesc = String(job.description || "Apply to " + job.title + " at " + (job.company || "HireIn AI") + " on HireIn AI.").slice(0, 160);
      var jobUrl = "https://hireinai.in/job/" + encodeURIComponent(job.id);
      document.title = pageTitle;
      var metaDesc = document.querySelector("meta[name=description]");
      if (metaDesc) metaDesc.content = pageDesc;
      var canonEl = document.getElementById("jobCanonical");
      if (canonEl) canonEl.href = jobUrl;
      var ogTitle = document.getElementById("ogTitle"), ogDesc = document.getElementById("ogDescription"), ogUrl = document.getElementById("ogUrl");
      if (ogTitle) ogTitle.content = pageTitle;
      if (ogDesc) ogDesc.content = pageDesc;
      if (ogUrl) ogUrl.content = jobUrl;
      var twTitle = document.getElementById("twTitle"), twDesc = document.getElementById("twDescription");
      if (twTitle) twTitle.content = pageTitle;
      if (twDesc) twDesc.content = pageDesc;

      document.getElementById("jobPostingSchema").textContent = JSON.stringify({
        "@context": "https://schema.org",
        "@type": "JobPosting",
        title: job.title,
        description: job.description,
        datePosted: job.posted_at || job.created_at,
        validThrough: job.expires_at || undefined,
        employmentType: J.type(job).toUpperCase().replace(/\s+/g, "_"),
        url: jobUrl,
        directApply: true,
        industry: J.category(job) || undefined,
        skills: skills.length ? skills.join(", ") : undefined,
        hiringOrganization: {
          "@type": "Organization",
          name: job.company || company.name || "Employer",
          sameAs: company.website || undefined,
          logo: company.logo_url || undefined
        },
        jobLocationType: mode === "Remote" ? "TELECOMMUTE" : undefined,
        applicantLocationRequirements: mode === "Remote" ? { "@type": "Country", name: "India" } : undefined,
        jobLocation: mode === "Remote" ? undefined : {
          "@type": "Place",
          address: {
            "@type": "PostalAddress",
            addressLocality: job.location || undefined,
            addressCountry: "IN"
          }
        },
        baseSalary: job.salary_min ? {
          "@type": "MonetaryAmount",
          currency: job.currency || "INR",
          value: {
            "@type": "QuantitativeValue",
            minValue: job.salary_min,
            maxValue: job.salary_max || undefined,
            unitText: "YEAR"
          }
        } : undefined
      });
      content.hidden = false;
      api.showMessage(notice, "", "");
      var viewKey = "hirein-viewed-" + job.id + "-" + new Date().toISOString().slice(0, 10);
      try {
        if (!sessionStorage.getItem(viewKey)) {
          await client.from("job_views").insert({ job_id: Number(job.id), viewer_id: user ? user.id : null, session_id: sessionStorage.getItem("hirein-session") || crypto.randomUUID() });
          sessionStorage.setItem(viewKey, "1");
        }
      } catch (_) { /* View analytics must not block a job detail page. */ }
      document.getElementById("checkAts").href = "/ats.html?job=" + encodeURIComponent(job.id);
      var saveButton = document.getElementById("saveJob"), isSaved = false;
      function paintSave() { saveButton.textContent = isSaved ? "Saved ✓" : "Save job"; saveButton.setAttribute("aria-pressed", String(isSaved)); }
      if (user) { isSaved = (await J.savedIds(user.id)).has(Number(job.id)); paintSave(); }
      saveButton.addEventListener("click", async function () {
        if (!user) { location.href = "/login.html?next=" + encodeURIComponent(location.pathname + location.search); return; }
        saveButton.disabled = true;
        try { await J.setSaved(user.id, job.id, !isSaved); isSaved = !isSaved; paintSave(); api.showMessage(notice, isSaved ? "Job saved to your dashboard." : "Job removed from your saved list.", "success"); }
        catch (error) { api.showMessage(notice, error.message, "error"); }
        saveButton.disabled = false;
      });
      renderRelated(job);
    } catch (error) {
      api.showMessage(notice, error.message || "Could not load this job.", "error");
    }
  });
})();

(function () {
  "use strict";
  /*
   * HireIn AI ATS checker.
   * analyze() compares extracted resume text with a job and returns a report:
   *   { version, score, band, breakdown, matchedSkills, missingSkills, matchedKeywords, missingKeywords,
   *     skillGap:[{skill,priority}], formatting:[{severity,issue}], suggestions, aiSuggestions, aiSource, job, resume, createdAt }
   * The score is a transparent keyword/structure estimate for guidance, never a hiring decision.
   */
  var SKILLS = ["Figma", "Adobe XD", "Sketch", "Photoshop", "Illustrator", "InDesign", "After Effects", "Premiere Pro", "Canva", "CorelDRAW", "Blender", "Cinema 4D", "UI Design", "UX Design", "Design Systems", "Wireframing", "Prototyping", "User Research", "Usability Testing", "Interaction Design", "Visual Design", "Graphic Design", "Typography", "Branding", "Illustration", "Motion Graphics", "Animation", "Video Editing", "Social Media", "Content Creation", "Print Design", "Packaging Design", "Accessibility", "Responsive Design",
    "HTML", "CSS", "JavaScript", "TypeScript", "React", "Angular", "Vue", "Next.js", "Node.js", "Express", "Python", "Django", "Flask", "Java", "Spring Boot", "C#", ".NET", "C++", "Golang", "PHP", "Laravel", "Ruby", "Kotlin", "Swift", "Flutter", "React Native", "Android", "iOS", "SQL", "MySQL", "PostgreSQL", "MongoDB", "Redis", "GraphQL", "REST APIs", "AWS", "Azure", "GCP", "Docker", "Kubernetes", "Terraform", "CI/CD", "Git", "Linux", "Supabase", "Firebase", "Tailwind CSS", "Jest", "Selenium", "Unit Testing",
    "Excel", "Power BI", "Tableau", "Data Analysis", "Data Visualization", "Statistics", "Machine Learning", "Deep Learning", "NLP", "Pandas", "NumPy", "TensorFlow", "PyTorch",
    "SEO", "SEM", "Google Ads", "Meta Ads", "Google Analytics", "Email Marketing", "Content Marketing", "Copywriting", "Digital Marketing", "Campaign Management", "Market Research", "CRM", "Salesforce", "HubSpot", "Lead Generation", "Negotiation", "Account Management", "Business Development", "Project Management", "Agile", "Scrum", "Jira", "Stakeholder Management", "Product Management", "Budgeting", "Financial Analysis", "Accounting", "Tally", "GST", "Recruitment", "Payroll", "Customer Service", "Communication", "Leadership", "Team Management", "Problem Solving", "Presentation", "Time Management", "Collaboration"];
  var ALIASES = { "UI Design": ["ui", "user interface"], "UX Design": ["ux", "user experience"], "Premiere Pro": ["premiere"], "Node.js": ["nodejs", "node js"], "React": ["reactjs", "react.js"], "Next.js": ["nextjs"], "REST APIs": ["rest api", "restful"], "Excel": ["ms excel", "microsoft excel"], "Power BI": ["powerbi"], "Machine Learning": ["ml"], "Google Ads": ["adwords"], "Meta Ads": ["facebook ads", "instagram ads"], "CI/CD": ["ci cd", "continuous integration"], "Motion Graphics": ["motion design"], "Branding": ["brand"], "Video Editing": ["video editor", "video editing"], "Tailwind CSS": ["tailwind"], "Data Visualization": ["data viz", "dashboards"], "Animation": ["animations", "animated"], "Illustration": ["illustrations"], "Communication": ["communication skills"], "Team Management": ["managed a team", "team lead"], "Customer Service": ["customer support"], "Spring Boot": ["spring"], "Golang": ["go lang"], "Social Media": ["instagram", "social media"] };
  var STOP = new Set("a an and are as at be been being but by can could did do does for from had has have he her his i if in into is it its may me might must my of on or our shall she should so than that the their them then there these they this those to us was we were what when where which while who will with would you your about across after also any both each etc more most other over per such via within without able ability including include includes strong excellent good great work working job role roles team teams candidate candidates looking years year experience experienced responsibilities requirements required preferred plus using use used well knowledge understanding skills skill must-have nice join company opportunity based hiring position apply new day days time help ensure make create build develop manage support provide".split(" "));
  var SENIORITY = new Set(["senior", "junior", "lead", "sr", "jr", "intern", "trainee", "head", "chief", "principal", "associate", "ii", "iii", "i"]);
  var BANDS = [[80, "Strong match", "band-strong"], [60, "Good match", "band-good"], [40, "Fair match", "band-fair"], [0, "Low match", "band-low"]];

  function escapeRe(s) { return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"); }
  function termRe(term) { return new RegExp("(^|[^a-z0-9+#.])" + escapeRe(term.toLowerCase()).replace(/\s+/g, "[\\s-]+") + "(?=$|[^a-z0-9+#])", "i"); }
  var SKILL_RES = SKILLS.map(function (skill) { return { skill: skill, res: [skill].concat(ALIASES[skill] || []).map(termRe) }; });
  function hasSkill(text, entry) { return entry.res.some(function (re) { return re.test(text); }); }
  function countTerm(text, term) { var m = text.match(new RegExp(termRe(term).source, "gi")); return m ? m.length : 0; }
  function words(text) { return text.toLowerCase().match(/[a-z][a-z0-9+#]{2,}/g) || []; }
  function ratio(hit, total) { return total ? Math.round(hit / total * 100) : null; }
  function bandOf(score) { return BANDS.find(function (b) { return score >= b[0]; }); }
  function esc(v) { return String(v == null ? "" : v).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#39;"); }

  function jobText(job) {
    if (!job) return "";
    var skills = Array.isArray(job.skills) ? job.skills.join(", ") : job.skills || "";
    return [job.title, job.category, job.description, job.responsibilities, job.requirements, skills].filter(Boolean).join("\n");
  }

  function analyze(input) {
    var resume = String(input.resumeText || ""), rl = resume.toLowerCase(), jd = String(input.jobText || ""), jl = jd.toLowerCase(), job = input.job || {};
    var title = String(job.title || input.jobTitle || "");
    // 1. Skills required by the job (lexicon hits plus any explicit job.skills)
    var explicit = (Array.isArray(job.skills) ? job.skills : []).map(function (s) { return String(s).trim(); }).filter(Boolean);
    var jobSkills = SKILL_RES.filter(function (e) { return hasSkill(jl, e); });
    explicit.forEach(function (s) { if (!jobSkills.some(function (e) { return e.skill.toLowerCase() === s.toLowerCase(); })) jobSkills.push({ skill: s, res: [termRe(s)], explicit: true }); });
    var matchedSkills = jobSkills.filter(function (e) { return hasSkill(rl, e); }).map(function (e) { return e.skill; });
    var missingEntries = jobSkills.filter(function (e) { return !hasSkill(rl, e); });
    // 2. Other frequent job terms
    var counts = {}, skillWords = new Set(words(jobSkills.map(function (e) { return e.skill; }).join(" ")));
    words(jd).forEach(function (w) { if (w.length >= 4 && !STOP.has(w) && !SENIORITY.has(w) && !skillWords.has(w)) counts[w] = (counts[w] || 0) + 1; });
    var terms = Object.keys(counts).sort(function (a, b) { return counts[b] - counts[a] || a.localeCompare(b); }).slice(0, 15);
    var matchedTerms = terms.filter(function (t) { return termRe(t).test(rl); }), missingTerms = terms.filter(function (t) { return !termRe(t).test(rl); });
    // 3. Job title relevance
    var titleWords = words(title).filter(function (w) { return !STOP.has(w) && !SENIORITY.has(w); });
    var titleHits = titleWords.filter(function (w) { return termRe(w).test(rl); });
    // 4. Formatting / parseability checks
    var formatting = [], wordCount = (resume.match(/\S+/g) || []).length, pages = input.pages || 1;
    function issue(severity, text) { formatting.push({ severity: severity, issue: text }); }
    function section(re) { return re.test(resume); }
    if (input.fileType === "pdf" && wordCount / pages < 60) issue("high", "Very little text was found per page. The PDF may be image-based or scanned — export it as a text-based PDF.");
    if (!/[^\s@]+@[^\s@]+\.[a-z]{2,}/i.test(resume)) issue("high", "No email address found. Put your email in the header as plain text.");
    if (!/(\+?\d[\d\s().-]{8,}\d)/.test(resume)) issue("medium", "No phone number found. Add one in the header.");
    if (!section(/\b(work\s+)?experience\b|\bemployment\b|\bwork history\b|\bprofessional background\b/i)) issue("high", "No standard “Experience” heading found. ATS systems look for common section names.");
    if (!section(/\beducation\b|\bqualifications?\b|\bacademic/i)) issue("medium", "No “Education” heading found.");
    if (!section(/\bskills\b|\bcompetencies\b|\btechnical proficiency\b|\btools\b/i)) issue("medium", "No “Skills” heading found. List core tools and skills in their own section.");
    if (!section(/\bsummary\b|\bprofile\b|\bobjective\b|\babout me\b/i)) issue("low", "No summary/profile section. A 2–3 line summary helps recruiters and ATS match your title.");
    if (!/(19|20)\d{2}/.test(resume)) issue("medium", "No dates found. Add start and end dates for roles and education.");
    if ((resume.match(/\d+(\.\d+)?\s*(%|percent|\+|x\b|k\b|lakh|crore|million|users|customers|clients|projects|hours|days)|[₹$€£]\s?\d/gi) || []).length < 2) issue("medium", "Few measurable results. Quantify achievements (%, time saved, revenue, users) where you truthfully can.");
    if (wordCount < 200) issue("medium", "Resume is short (" + wordCount + " words). Aim for roughly 350–800 words.");
    if (wordCount > 1100) issue("medium", "Resume is long (" + wordCount + " words). Keep it to 1–2 pages focused on relevant experience.");
    if (pages > 2) issue("low", "Resume has " + pages + " pages. Two pages is usually the maximum.");
    if ((resume.match(/[-�]/g) || []).length > 3) issue("low", "Icon fonts or special symbols were found. Replace icons with plain text labels (e.g. “Email:”).");
    if (!/linkedin\.com\//i.test(resume)) issue("low", "No LinkedIn URL found. Adding it helps recruiters verify your profile.");
    // 5. Score (weights renormalised when a signal is unavailable)
    var penalty = formatting.reduce(function (sum, f) { return sum + ({ high: 18, medium: 8, low: 3 })[f.severity]; }, 0);
    var breakdown = { skills: ratio(matchedSkills.length, jobSkills.length), keywords: ratio(matchedTerms.length, terms.length), title: ratio(titleHits.length, titleWords.length), formatting: Math.max(0, 100 - penalty) };
    var weights = { skills: 0.45, keywords: 0.2, title: 0.15, formatting: 0.2 }, total = 0, weightSum = 0;
    Object.keys(weights).forEach(function (k) { if (breakdown[k] != null) { total += breakdown[k] * weights[k]; weightSum += weights[k]; } });
    var score = Math.max(0, Math.min(100, Math.round(weightSum ? total / weightSum : 0)));
    // 6. Skill gap and rule-based suggestions
    var skillGap = missingEntries.map(function (e) {
      var high = e.explicit || e.res.some(function (re) { return re.test(title.toLowerCase()); }) || countTerm(jl, e.skill) >= 2;
      return { skill: e.skill, priority: high ? "High" : "Medium" };
    }).sort(function (a, b) { return a.priority === b.priority ? 0 : a.priority === "High" ? -1 : 1; });
    var suggestions = [];
    var highGap = skillGap.filter(function (g) { return g.priority === "High"; }).map(function (g) { return g.skill; });
    if (highGap.length) suggestions.push("The role emphasises " + highGap.slice(0, 5).join(", ") + ". If you have these skills, list them in Skills and show them in an experience bullet.");
    else if (skillGap.length) suggestions.push("Consider adding " + skillGap.slice(0, 5).map(function (g) { return g.skill; }).join(", ") + " — only if they genuinely reflect your experience.");
    if (title && titleWords.length && titleHits.length < titleWords.length) suggestions.push("Use the target title “" + title + "” (or the closest accurate version) in your headline or summary.");
    if (missingTerms.length) suggestions.push("Mirror important wording from the job description where accurate: " + missingTerms.slice(0, 6).join(", ") + ".");
    formatting.filter(function (f) { return f.severity === "high"; }).slice(0, 2).forEach(function (f) { suggestions.push(f.issue); });
    if (matchedSkills.length) suggestions.push("Move your strongest matching skills (" + matchedSkills.slice(0, 4).join(", ") + ") into the first lines of your summary and most recent role.");
    if (score >= 80) suggestions.push("Strong match. Tailor the first sentence of your summary to this role and apply.");
    else if (score < 50) suggestions.push("Match is low. Tailor your resume to this role before applying, or look for roles closer to your current skills.");
    var band = bandOf(score);
    return {
      version: 1, score: score, band: band[1], breakdown: breakdown,
      matchedSkills: matchedSkills, missingSkills: skillGap.map(function (g) { return g.skill; }),
      matchedKeywords: matchedSkills.concat(matchedTerms), missingKeywords: skillGap.map(function (g) { return g.skill; }).concat(missingTerms).slice(0, 20),
      skillGap: skillGap, formatting: formatting, suggestions: suggestions, aiSuggestions: [], aiSource: "rules",
      job: { id: job.id || null, title: title || "Custom job description", company: job.company || "" },
      resume: { name: input.resumeName || "Resume", words: wordCount, pages: pages, type: input.fileType || "" },
      createdAt: new Date().toISOString()
    };
  }

  /* Rebuild a report from an ats_history row (older rows only have the base columns). */
  function fromHistory(row) {
    var d = row.details && typeof row.details === "object" ? row.details : {};
    var base = d.version ? d : {};
    var legacy = (Array.isArray(d.formatting_issues) ? d.formatting_issues : []).map(function (t) { return { severity: "medium", issue: String(t) }; });
    var score = Number(row.score) || 0;
    return Object.assign({ breakdown: {}, matchedSkills: [], skillGap: [], formatting: legacy, suggestions: (/\n/.test(row.suggestions || "") ? String(row.suggestions).split(/\n+/) : String(row.suggestions || "").match(/[^.!?]+(?:[.!?]+|$)/g) || []).map(function (s) { return s.trim(); }).filter(Boolean), aiSuggestions: [], aiSource: "rules" }, base, {
      score: score, band: bandOf(score)[1],
      matchedKeywords: row.matched_keywords || base.matchedKeywords || [], missingKeywords: row.missing_keywords || base.missingKeywords || [],
      job: Object.assign({ title: row.jobs && row.jobs.title || "Custom job description", company: row.jobs && row.jobs.company || "" }, base.job || {}),
      resume: Object.assign({ name: row.resume_name || "Resume" }, base.resume || {}),
      createdAt: base.createdAt || row.created_at
    });
  }

  function chips(list, cls) { return list.length ? "<div class='ats-chips'>" + list.map(function (k) { return "<span class='ats-chip " + (cls || "") + "'>" + esc(k) + "</span>"; }).join("") + "</div>" : "<p class='muted'>None</p>"; }
  function render(container, report, options) {
    options = options || {};
    var band = bandOf(report.score), b = report.breakdown || {};
    var rows = [["Skills match", b.skills], ["Keyword match", b.keywords], ["Job title match", b.title], ["Formatting & structure", b.formatting]].filter(function (r) { return r[1] != null; });
    var sub = [report.job && report.job.company ? esc(report.job.title) + " at " + esc(report.job.company) : esc(report.job && report.job.title || ""), esc(report.resume && report.resume.name || ""), report.resume && report.resume.words ? report.resume.words + " words" : "", report.createdAt ? esc(new Date(report.createdAt).toLocaleDateString("en-IN", { day: "numeric", month: "short", year: "numeric" })) : ""].filter(Boolean).join(" · ");
    var ai = report.aiSuggestions && report.aiSuggestions.length ? report.aiSuggestions : report.suggestions || [];
    container.innerHTML =
      "<div class='ats-report'><div class='ats-report-top'><div class='score-ring ats-ring " + band[2] + "' role='img' aria-label='ATS score " + report.score + " out of 100'><span><strong>" + (options.animate ? 0 : report.score) + "</strong><small>/ 100</small></span></div>" +
      "<div class='ats-report-summary'><p class='ats-band " + band[2] + "'>" + band[1] + "</p><h2>ATS match report</h2><p class='muted'>" + sub + "</p>" +
      (rows.length ? "<div class='ats-breakdown'>" + rows.map(function (r) { return "<div class='ats-bar'><span>" + r[0] + "</span><div class='ats-bar-track'><i style='width:" + r[1] + "%'></i></div><strong>" + r[1] + "%</strong></div>"; }).join("") + "</div>" : "") + "</div></div>" +
      "<div class='ats-report-grid'><section><h3>Matched keywords <span class='muted'>(" + (report.matchedKeywords || []).length + ")</span></h3>" + chips(report.matchedKeywords || [], "is-match") + "</section>" +
      "<section><h3>Missing keywords <span class='muted'>(" + (report.missingKeywords || []).length + ")</span></h3>" + chips(report.missingKeywords || [], "is-missing") + "</section></div>" +
      "<section class='ats-block'><h3>Skill gap</h3>" + ((report.skillGap || []).length ? "<ul class='ats-gap'>" + report.skillGap.map(function (g) { return "<li><span class='ats-priority priority-" + esc(String(g.priority).toLowerCase()) + "'>" + esc(g.priority) + "</span>" + esc(g.skill) + "</li>"; }).join("") + "</ul>" : "<p class='muted'>" + (report.version ? "No skill gaps detected for the skills this job lists." : "Not available for this older report.") + "</p>") + "</section>" +
      "<section class='ats-block'><h3>Formatting issues</h3>" + ((report.formatting || []).length ? "<ul class='ats-issues'>" + report.formatting.map(function (f) { return "<li class='sev-" + esc(f.severity) + "'><span class='ats-severity'>" + esc(f.severity) + "</span>" + esc(f.issue) + "</li>"; }).join("") + "</ul>" : "<p class='muted'>No common formatting issues detected.</p>") + "</section>" +
      "<section class='ats-block'><h3>AI suggestions</h3><p class='muted'>" + (report.aiSource === "llm" ? "Generated by HireIn AI from your resume and this job." : "Generated by HireIn AI's built-in rules from your resume and this job.") + "</p>" + (ai.length ? "<ol class='ats-suggestions'>" + ai.map(function (s) { return "<li>" + esc(s) + "</li>"; }).join("") + "</ol>" : "<p class='muted'>No suggestions.</p>") + "</section>" +
      "<p class='muted ats-disclaimer'>This score is a keyword and structure estimate to help you tailor your resume. It is not a hiring decision.</p></div>";
    var ring = container.querySelector(".ats-ring"), value = ring.querySelector("strong");
    if (!options.animate || (window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches)) { ring.style.setProperty("--score", report.score + "%"); value.textContent = report.score; return; }
    var start = null, duration = 1100;
    function frame(ts) {
      if (start === null) start = ts;
      var t = Math.min(1, (ts - start) / duration), eased = 1 - Math.pow(1 - t, 3), current = Math.round(report.score * eased);
      ring.style.setProperty("--score", (report.score * eased) + "%"); value.textContent = current;
      if (t < 1) requestAnimationFrame(frame);
    }
    requestAnimationFrame(frame);
    // Background tabs may throttle animation frames; always settle on the final value.
    setTimeout(function () { ring.style.setProperty("--score", report.score + "%"); value.textContent = report.score; }, duration + 150);
  }

  window.HireInATS = { analyze: analyze, render: render, fromHistory: fromHistory, jobText: jobText, skills: SKILLS };

  /* ATS page */
  async function extractText(file, ext) {
    var buffer = await file.arrayBuffer();
    if (ext === "pdf") {
      if (!window.pdfjsLib) throw new Error("The PDF reader did not load. Refresh and try again.");
      window.pdfjsLib.GlobalWorkerOptions.workerSrc = "https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js";
      var pdf = await window.pdfjsLib.getDocument({ data: buffer }).promise, parts = [];
      for (var p = 1; p <= pdf.numPages; p++) {
        var content = await (await pdf.getPage(p)).getTextContent();
        parts.push(content.items.map(function (item) { return item.str + (item.hasEOL ? "\n" : " "); }).join(""));
      }
      return { text: parts.join("\n"), pages: pdf.numPages };
    }
    if (!window.mammoth) throw new Error("The DOCX reader did not load. Refresh and try again.");
    var extracted = await window.mammoth.extractRawText({ arrayBuffer: buffer });
    var text = extracted.value || "";
    return { text: text, pages: Math.max(1, Math.ceil((text.match(/\S+/g) || []).length / 550)) };
  }

  document.addEventListener("DOMContentLoaded", async function () {
    var form = document.getElementById("atsForm");
    if (!form) return;
    var api = window.hireInAI || {}, client = api.client;
    var jobSelect = document.getElementById("jobId"), description = document.getElementById("jobDescription"), fileInput = document.getElementById("resumeFile");
    var notice = document.getElementById("atsMessage"), result = document.getElementById("atsResult"), button = document.getElementById("analyzeButton"), fileLabel = document.getElementById("resumeFileName");
    function say(message, kind) { notice.textContent = message || ""; notice.className = "notice" + (kind ? " " + kind : ""); }
    var jobs = [], user = null;
    if (client) { try { user = (await client.auth.getUser()).data.user; } catch (e) { user = null; } }
    var signIn = document.querySelector(".site-signin");
    if (!user) document.getElementById("atsLogin").hidden = false;
    else if (signIn) { signIn.textContent = "Dashboard"; signIn.href = "dashboard.html"; }
    if (client && api.jobs) {
      var loaded = await api.jobs.listPublished("*");
      if (loaded.error) say("Could not load jobs: " + loaded.error.message + ". You can still paste a job description.", "error");
      jobs = loaded.data || [];
      jobs.forEach(function (job) { var o = document.createElement("option"); o.value = job.id; o.textContent = (job.title || "Role") + " — " + (job.company || "Company") + (job.location ? " (" + job.location + ")" : ""); jobSelect.appendChild(o); });
      var preset = new URLSearchParams(location.search).get("job");
      if (preset && jobs.some(function (j) { return String(j.id) === preset; })) { jobSelect.value = preset; description.value = jobText(jobs.find(function (j) { return String(j.id) === preset; })); }
    }
    function selectedJob() { return jobs.find(function (j) { return String(j.id) === jobSelect.value; }) || null; }
    jobSelect.addEventListener("change", function () { var job = selectedJob(); if (job) description.value = jobText(job); });
    function showFile() { var f = fileInput.files[0]; fileLabel.textContent = f ? f.name + " · " + Math.max(1, Math.round(f.size / 1024)) + " KB" : "No file chosen"; }
    fileInput.addEventListener("change", showFile);
    var drop = document.getElementById("resumeDrop");
    ["dragenter", "dragover"].forEach(function (t) { drop.addEventListener(t, function (e) { e.preventDefault(); drop.classList.add("is-dragging"); }); });
    ["dragleave", "drop"].forEach(function (t) { drop.addEventListener(t, function (e) { e.preventDefault(); drop.classList.remove("is-dragging"); }); });
    drop.addEventListener("drop", function (e) { if (e.dataTransfer.files.length) { fileInput.files = e.dataTransfer.files; showFile(); } });

    form.addEventListener("submit", async function (event) {
      event.preventDefault();
      var file = fileInput.files[0];
      if (!file) { say("Choose a PDF or DOCX resume first.", "error"); return; }
      var ext = file.name.toLowerCase().split(".").pop();
      if (["pdf", "docx"].indexOf(ext) < 0 || file.size > 5 * 1024 * 1024) { say("Upload a PDF or DOCX smaller than 5 MB.", "error"); return; }
      var job = selectedJob(), text = description.value.trim();
      if (!job && text.length < 40) { say("Choose a job or paste a fuller job description (at least 40 characters).", "error"); return; }
      if (job && !text) text = jobText(job);
      button.disabled = true; say("Reading your resume…", "");
      try {
        var extracted = await extractText(file, ext);
        if (extracted.text.trim().length < 40) throw new Error("No readable text was found. Upload a text-based PDF or DOCX (scanned images can't be read).");
        var report = analyze({ resumeText: extracted.text, pages: extracted.pages, fileType: ext, resumeName: file.name, jobText: text, job: job ? Object.assign({}, job, { skills: api.jobs ? api.jobs.skills(job) : job.skills }) : { title: "" } });
        var ai = window.HireInAIService;
        if (ai && ai.run) {
          say("Getting AI suggestions…", "");
          try {
            var review = await ai.run("analyzeATS", { resume: extracted.text.slice(0, 15000), jobDescription: text.slice(0, 8000) });
            if (review.source === "llm" && Array.isArray(review.data.suggestions) && review.data.suggestions.length) { report.aiSuggestions = review.data.suggestions.map(String).slice(0, 8); report.aiSource = "llm"; }
          } catch (e) { /* Built-in suggestions are used when the AI model is unavailable. */ }
        }
        render(result, report, { animate: true });
        result.hidden = false;
        result.scrollIntoView({ behavior: "smooth", block: "start" });
        if (!user) { say("Analysis complete. Sign in to save reports to your dashboard.", "success"); return; }
        say("Analysis complete. Saving your report…", "");
        await saveReport(report, file, ext);
      } catch (error) { say(error.message || "Could not analyze this resume.", "error"); }
      finally { button.disabled = false; }
    });

    async function saveReport(report, file, ext) {
      var path = null;
      try {
        var candidate = user.id + "/ats/" + crypto.randomUUID() + "-" + file.name.replace(/[^a-zA-Z0-9._-]/g, "_");
        var upload = await client.storage.from("resumes").upload(candidate, file, { contentType: ext === "pdf" ? "application/pdf" : "application/vnd.openxmlformats-officedocument.wordprocessingml.document", upsert: false });
        if (!upload.error) {
          var record = await client.from("resumes").insert({ user_id: user.id, name: file.name, storage_path: candidate });
          if (record.error) await client.storage.from("resumes").remove([candidate]); else path = candidate;
        }
      } catch (e) { path = null; }
      var row = { user_id: user.id, job_id: report.job.id ? Number(report.job.id) : null, resume_name: file.name, resume_path: path, score: report.score, matched_keywords: report.matchedKeywords, missing_keywords: report.missingKeywords, suggestions: (report.aiSuggestions.length ? report.aiSuggestions : report.suggestions).join("\n"), details: report };
      var saved = await client.from("ats_history").insert(row);
      if (saved.error && api.isMissingColumn && api.isMissingColumn(saved.error)) { delete row.resume_path; delete row.details; saved = await client.from("ats_history").insert(row); }
      if (saved.error) say("Analysis complete, but the report could not be saved: " + saved.error.message, "error");
      else say("Analysis complete. Report saved to your dashboard ATS history.", "success");
    }
  });
})();

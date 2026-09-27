document.addEventListener("DOMContentLoaded", async function () {
  var api = window.hireInAI || {}, client = api.client, ai = window.HireInAIService, pdf = window.HireInPDF;
  var form = document.getElementById("resumeForm");
  if (!form) return;
  var notice = document.getElementById("resumeMessage"), preview = document.getElementById("resumePreview"), frame = document.getElementById("resumePreviewFrame");
  var undoBar = document.getElementById("resumeUndo"), atsPanel = document.getElementById("atsPanel"), DRAFT_KEY = "hirein.resumeDraft.v1";
  var photo = "", undoSnapshot = null, user = null, saveTimer = null;

  function esc(value) { return String(value == null ? "" : value).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#39;"); }
  function say(message, kind) { notice.textContent = message || ""; notice.className = "notice" + (kind ? " " + kind : ""); }
  function storage(fn) { try { return fn(window.localStorage); } catch (e) { return null; } }
  function bulletLines(text) { return String(text || "").split(/\n+/).map(function (line) { return line.replace(/^\s*(?:[-*•·▪◦>]|\d+[.)])\s*/, "").trim(); }).filter(Boolean); }
  function displayUrl(url) { return String(url || "").trim().replace(/^https?:\/\//i, "").replace(/^www\./i, "").replace(/\/$/, ""); }

  var LISTS = {
    experience: { list: "experienceList", key: "experience", fields: [["role", "Role / title"], ["organization", "Company"], ["dates", "Dates", "e.g. Jan 2021 – Present"], ["details", "Achievements (one per line)"]] },
    project: { list: "projectList", key: "projects", fields: [["name", "Project name"], ["link", "Project link", "https://"], ["details", "Project details"]] },
    education: { list: "educationList", key: "education", fields: [["qualification", "Qualification"], ["organization", "School / institution"], ["dates", "Dates"], ["details", "Details"]] },
    certification: { list: "certificationList", key: "certifications", fields: [["name", "Certification"], ["organization", "Issuing organization"], ["date", "Date"]] },
    language: { list: "languageList", key: "languages", fields: [["name", "Language"], ["level", "Proficiency", "e.g. Fluent"]] },
    link: { list: "linkList", key: "links", fields: [["name", "Label"], ["url", "URL", "https://"]] }
  };
  var SIMPLE = ["resume_name", "full_name", "job_title", "email", "phone", "location", "portfolio", "linkedin", "summary"];

  function addEntry(kind, values, silent) {
    var def = LISTS[kind], card = document.createElement("fieldset");
    card.className = "resume-entry"; card.dataset.kind = kind;
    def.fields.forEach(function (field) {
      var label = document.createElement("label"), title = document.createElement("span"), multi = field[0] === "details";
      var input = document.createElement(multi ? "textarea" : "input");
      label.className = "field" + (multi ? " field-wide" : "");
      title.textContent = field[1]; input.name = field[0]; input.maxLength = multi ? 2500 : 500;
      if (multi) input.rows = 4; else input.type = /link|url/.test(field[0]) ? "url" : "text";
      if (field[2]) input.placeholder = field[2];
      input.value = values && values[field[0]] || "";
      label.appendChild(title); label.appendChild(input); card.appendChild(label);
    });
    var tools = document.createElement("div");
    tools.className = "resume-entry-tools";
    tools.innerHTML = (kind === "experience" ? "<button type='button' class='small-button ai-action' data-entry-ai='improveBulletPoints'>Improve bullets</button><button type='button' class='small-button ai-action' data-entry-ai='generateAchievements'>Suggest achievements</button>" : "") + "<button type='button' class='small-button danger' data-remove>Delete</button>";
    card.appendChild(tools);
    document.getElementById(def.list).appendChild(card);
    if (!silent) { render(); card.querySelector("input,textarea").focus(); }
    return card;
  }
  function filledCards(kind) { return Array.from(document.querySelectorAll("#" + LISTS[kind].list + " .resume-entry")).filter(function (card) { return Array.from(card.querySelectorAll("input,textarea")).some(function (f) { return f.value.trim(); }); }); }
  function cardValues(card) { var item = {}; card.querySelectorAll("input,textarea").forEach(function (f) { item[f.name] = f.value.trim(); }); return item; }

  function data() {
    var d = { template: form.elements.template.value || "modern", photo: photo };
    SIMPLE.forEach(function (name) { d[name] = form.elements[name].value.trim(); });
    d.skills = form.elements.skills.value.split(/[,\n]/).map(function (v) { return v.trim(); }).filter(Boolean);
    Object.keys(LISTS).forEach(function (kind) { d[LISTS[kind].key] = filledCards(kind).map(cardValues); });
    return d;
  }
  function setPhoto(value) {
    photo = value || "";
    var img = document.getElementById("photoPreview");
    img.hidden = !photo; if (photo) img.src = photo; else img.removeAttribute("src");
    document.getElementById("photoPlaceholder").hidden = Boolean(photo);
    document.getElementById("removePhoto").hidden = !photo;
  }
  function setData(d, defaults) {
    d = d || {};
    SIMPLE.forEach(function (name) { form.elements[name].value = d[name] != null ? d[name] : name === "resume_name" ? "My HireIn AI resume" : ""; });
    form.elements.template.value = ["modern", "minimal", "executive", "creative"].indexOf(d.template) >= 0 ? d.template : "modern";
    form.elements.skills.value = (d.skills || []).join(", ");
    setPhoto(d.photo);
    Object.keys(LISTS).forEach(function (kind) {
      var container = document.getElementById(LISTS[kind].list), items = d[LISTS[kind].key] || (kind === "certification" ? d.certificates : null) || [];
      container.innerHTML = "";
      items.forEach(function (item) { addEntry(kind, item, true); });
      if (!items.length && defaults && (kind === "experience" || kind === "education")) addEntry(kind, null, true);
    });
    render();
  }

  /* Live preview: HTML mirror of the PDF layout, rendered at A4 width (794px) and scaled to fit. */
  function detailsHtml(text) {
    var lines = bulletLines(text);
    if (!lines.length) return "";
    return lines.length > 1 || /^\s*(?:[-*•·▪◦]|\d+[.)])/.test(text) ? "<ul>" + lines.map(function (l) { return "<li>" + esc(l) + "</li>"; }).join("") + "</ul>" : "<p>" + esc(lines[0]) + "</p>";
  }
  function section(title, inner) { return inner ? "<section class='rs-section'><h2>" + title + "</h2>" + inner + "</section>" : ""; }
  function entry(title, sub, dates, details, link) {
    return "<article class='rs-entry'><div class='rs-entry-head'><h3>" + esc(title) + "</h3>" + (dates ? "<span class='rs-dates'>" + esc(dates) + "</span>" : "") + "</div>" + (sub ? "<p class='rs-sub'>" + esc(sub) + "</p>" : "") + (link ? "<p class='rs-link'>" + esc(displayUrl(link)) + "</p>" : "") + detailsHtml(details) + "</article>";
  }
  function contacts(d) {
    return [["Email", d.email], ["Phone", d.phone], ["Location", d.location], ["Portfolio", displayUrl(d.portfolio)], ["LinkedIn", displayUrl(d.linkedin)]].filter(function (c) { return c[1]; });
  }
  function mainHtml(d) {
    return section("Summary", d.summary ? "<p>" + esc(d.summary) + "</p>" : "") +
      section("Experience", d.experience.map(function (x) { return entry(x.role || x.organization, x.role ? x.organization : "", x.dates, x.details); }).join("")) +
      section("Projects", d.projects.map(function (x) { return entry(x.name, "", "", x.details, x.link); }).join("")) +
      section("Education", d.education.map(function (x) { return entry(x.qualification || x.organization, x.qualification ? x.organization : "", x.dates, x.details); }).join(""));
  }
  function certHtml(d) { return d.certifications.map(function (x) { return "<div class='rs-mini'><strong>" + esc(x.name) + "</strong>" + ((x.organization || x.date) ? "<span>" + esc([x.organization, x.date].filter(Boolean).join("  ·  ")) + "</span>" : "") + "</div>"; }).join(""); }
  function render() {
    var d = data(), t = d.template, name = d.full_name ? esc(d.full_name) : "<span class='rs-placeholder'>Your Name</span>";
    var title = d.job_title ? "<p class='rs-title'>" + esc(d.job_title) + "</p>" : "", img = photo ? "<img class='rs-photo' src='" + esc(photo) + "' alt=''>" : "";
    var html;
    if (t === "creative") {
      html = "<aside class='rs-side'>" + img +
        section("Contact", contacts(d).map(function (c) { return "<div class='rs-contact-item'><span>" + c[0] + "</span>" + esc(c[1]) + "</div>"; }).join("")) +
        section("Skills", d.skills.length ? "<div class='rs-chips'>" + d.skills.map(function (s) { return "<span>" + esc(s) + "</span>"; }).join("") + "</div>" : "") +
        section("Languages", d.languages.map(function (x) { return "<div class='rs-mini'><strong>" + esc(x.name) + "</strong>" + (x.level ? "<span>" + esc(x.level) + "</span>" : "") + "</div>"; }).join("")) +
        section("Certifications", certHtml(d)) +
        section("Links", d.links.map(function (x) { return "<div class='rs-contact-item'>" + (x.name ? "<span>" + esc(x.name) + "</span>" : "") + esc(displayUrl(x.url)) + "</div>"; }).join("")) +
        "</aside><div class='rs-main'><header class='rs-header'><h1>" + name + "</h1>" + title + "</header>" + mainHtml(d) + "</div>";
    } else {
      var sep = t === "minimal" ? "·" : "|";
      html = "<header class='rs-header'>" + img + "<div class='rs-identity'><h1>" + name + "</h1>" + title + "<p class='rs-contact'>" + contacts(d).map(function (c) { return "<span>" + esc(c[1]) + "</span>"; }).join("<i>" + sep + "</i>") + "</p></div></header><div class='rs-main'>" + mainHtml(d) +
        section("Skills", d.skills.length ? "<p>" + d.skills.map(esc).join("  •  ") + "</p>" : "") +
        section("Certifications", certHtml(d)) +
        section("Languages", d.languages.length ? "<p>" + d.languages.map(function (x) { return esc([x.name, x.level].filter(Boolean).join(" — ")); }).join("   •   ") + "</p>" : "") +
        section("Links", d.links.map(function (x) { return "<p>" + esc([x.name, displayUrl(x.url)].filter(Boolean).join(": ")) + "</p>"; }).join("")) + "</div>";
    }
    preview.className = "resume-sheet template-" + t;
    preview.innerHTML = html;
    fitPreview();
    clearTimeout(saveTimer);
    saveTimer = setTimeout(function () { storage(function (s) { s.setItem(DRAFT_KEY, JSON.stringify(data())); }); }, 400);
  }
  function fitPreview() {
    var scale = Math.min(1, frame.clientWidth / 794) || 1;
    preview.style.setProperty("--preview-scale", scale);
    frame.style.height = Math.ceil(preview.offsetHeight * scale) + "px";
  }
  if (window.ResizeObserver) new ResizeObserver(fitPreview).observe(frame); else window.addEventListener("resize", fitPreview);
  if (document.fonts && document.fonts.ready) document.fonts.ready.then(fitPreview);

  form.addEventListener("input", function (event) { if (event.target.id !== "targetJob" && event.target.id !== "photoInput") render(); });
  form.addEventListener("change", function (event) { if (event.target.name === "template") { render(); if (pdf) pdf.preloadFonts(form.elements.template.value); } });
  form.addEventListener("submit", function (event) { event.preventDefault(); });
  document.querySelectorAll("[data-add]").forEach(function (button) { button.addEventListener("click", function () { addEntry(button.dataset.add); }); });
  form.addEventListener("click", function (event) {
    var remove = event.target.closest("[data-remove]"), entryAi = event.target.closest("[data-entry-ai]");
    if (remove) { var card = remove.closest(".resume-entry"), before = data(); card.remove(); render(); offerUndo(before, "Entry deleted."); }
    if (entryAi) runEntryAI(entryAi.dataset.entryAi, entryAi, entryAi.closest(".resume-entry"));
  });

  /* Profile photo: centre-cropped to a 480px square JPEG so drafts and saved records stay small. */
  document.getElementById("photoInput").addEventListener("change", function () {
    var file = this.files && this.files[0], input = this;
    if (!file) return;
    if (!/^image\/(png|jpeg|webp)$/.test(file.type)) { say("Choose a JPG, PNG or WebP image.", "error"); input.value = ""; return; }
    if (file.size > 8 * 1024 * 1024) { say("Choose a photo smaller than 8 MB.", "error"); input.value = ""; return; }
    var url = URL.createObjectURL(file), img = new Image();
    img.onload = function () {
      var side = Math.min(img.naturalWidth, img.naturalHeight), canvas = document.createElement("canvas"), size = Math.min(480, side);
      canvas.width = canvas.height = size;
      canvas.getContext("2d").drawImage(img, (img.naturalWidth - side) / 2, (img.naturalHeight - side) / 2, side, side, 0, 0, size, size);
      URL.revokeObjectURL(url); input.value = "";
      setPhoto(canvas.toDataURL("image/jpeg", 0.88)); render(); say("Photo added.", "success");
    };
    img.onerror = function () { URL.revokeObjectURL(url); input.value = ""; say("That image could not be read. Try another file.", "error"); };
    img.src = url;
  });
  document.getElementById("removePhoto").addEventListener("click", function () { setPhoto(""); render(); });

  /* AI tools */
  function offerUndo(snapshot, label) { undoSnapshot = snapshot; undoBar.querySelector("span").textContent = label || "AI changes applied."; undoBar.hidden = false; }
  document.getElementById("undoAi").addEventListener("click", function () { if (undoSnapshot) setData(undoSnapshot); undoSnapshot = null; undoBar.hidden = true; say("Change undone.", "success"); });
  function aiResume() { var d = data(); delete d.photo; return d; }
  function sourceNote(result) { return result.source === "local" ? " Drafted with built-in writing rules (AI model unavailable)." : ""; }
  async function runAI(button, action, input, apply) {
    if (!ai || !ai[action]) { say("AI tools did not load. Refresh the page and try again.", "error"); return; }
    button.disabled = true; say("Working on it…", "");
    try {
      var result = await ai[action](input), before = data(), message = apply(result.data, result);
      if (message === false) return;
      render(); offerUndo(before, "AI changes applied.");
      say((message || "AI draft ready. Review it for accuracy before downloading.") + sourceNote(result), "success");
    } catch (error) { say(error.message || "The AI request failed.", "error"); }
    finally { button.disabled = false; }
  }
  function runEntryAI(action, button, card) {
    var item = cardValues(card);
    if (!bulletLines(item.details).length && action === "improveBulletPoints") { say("Add some achievements to this role first.", "error"); return; }
    var details = card.querySelector("textarea[name=details]");
    if (action === "improveBulletPoints") runAI(button, action, { bullets: bulletLines(item.details), role: item.role }, function (out) {
      details.value = out.bullets.map(function (b) { return b.improved; }).join("\n");
      var tips = Array.from(new Set([].concat.apply([], out.bullets.map(function (b) { return b.tips || []; }))));
      return "Bullets improved." + (tips.length ? " Tip: " + tips.slice(0, 2).join(" ") : "");
    });
    else runAI(button, action, { role: item.role, experience: item, resume: aiResume() }, function (out) {
      if (!out.achievements.length) { say("No achievements could be drafted for this role.", "error"); return false; }
      details.value = (details.value.trim() ? details.value.trim() + "\n" : "") + out.achievements.map(function (a) { return a.text; }).join("\n");
      return "Achievement drafts added. Replace every [bracketed] placeholder with your real result, or delete the line.";
    });
  }
  document.querySelectorAll("[data-ai]").forEach(function (button) { button.addEventListener("click", function () {
    var action = button.dataset.ai, d = aiResume();
    if (action === "generateSummary") runAI(button, action, { resume: d }, function (out, res) {
      if (!out.summary) { say((res.warnings || []).slice(-1)[0] || "Add more details before generating a summary.", "error"); return false; }
      form.elements.summary.value = out.summary; return "Summary drafted from your details. Review it before downloading.";
    });
    else if (action === "grammarCorrection") { if (!d.summary) { say("Write a summary first.", "error"); return; } runAI(button, action, { text: d.summary }, function (out) { form.elements.summary.value = out.correctedText || d.summary; return "Grammar checked."; }); }
    else if (action === "rewriteExperience") {
      if (!d.experience.length) { say("Add at least one role first.", "error"); return; }
      var cards = filledCards("experience");
      runAI(button, action, { resume: d }, function (out) {
        out.experience.forEach(function (item) { var card = cards[item.index]; if (card && item.bullets.length) card.querySelector("textarea[name=details]").value = item.bullets.join("\n"); });
        return "Experience rewritten into concise bullets.";
      });
    }
    else if (action === "suggestSkills") runAI(button, action, { resume: d }, function (out) {
      var merged = Array.from(new Set(d.skills.concat(out.skills).map(function (s) { return s.trim(); }).filter(Boolean)));
      var added = merged.length - d.skills.length;
      form.elements.skills.value = merged.join(", ");
      return added ? added + " skill" + (added > 1 ? "s" : "") + " added. Keep only the ones you genuinely have." : (out.reason || "No new skills found.");
    });
    else if (action === "optimizeATS") runATS(button, d);
  }); });

  async function runATS(button, d) {
    button.disabled = true; say("Checking your resume…", "");
    try {
      var result = await ai.optimizeATS({ resume: d, jobDescription: document.getElementById("targetJob").value.trim() }), out = result.data;
      var chips = function (list, add) { return list.length ? "<div class='ats-chips'>" + list.map(function (k) { return add ? "<button type='button' class='ats-chip ats-add' data-keyword='" + esc(k) + "'>+ " + esc(k) + "</button>" : "<span class='ats-chip'>" + esc(k) + "</span>"; }).join("") + "</div>" : "<p class='muted'>None</p>"; };
      atsPanel.innerHTML = "<div class='ats-score'><div class='score-ring' style='--score:" + out.score + "%'><span><strong>" + out.score + "</strong>%</span></div><p class='muted'>ATS readiness estimate" + (result.source === "local" ? " (built-in rules)" : "") + ". Guidance only — not a hiring decision.</p></div>" +
        (out.sectionChecks.length ? "<h4>Checklist</h4><ul class='ats-checks'>" + out.sectionChecks.map(function (c) { return "<li class='" + (c.ok ? "ok" : "todo") + "'><strong>" + esc(c.section) + "</strong>" + (c.ok ? "" : " — " + esc(c.tip)) + "</li>"; }).join("") + "</ul>" : "") +
        (out.matchedKeywords.length || out.missingKeywords.length ? "<h4>Matched keywords</h4>" + chips(out.matchedKeywords) + "<h4>Missing keywords</h4><p class='muted'>Tap to add to skills — only if it truthfully describes you.</p>" + chips(out.missingKeywords, true) : "") +
        (out.suggestions.length ? "<h4>Suggestions</h4><ul>" + out.suggestions.map(function (s) { return "<li>" + esc(s) + "</li>"; }).join("") + "</ul>" : "");
      atsPanel.hidden = false; say("ATS check complete.", "success");
    } catch (error) { say(error.message || "ATS check failed.", "error"); }
    finally { button.disabled = false; }
  }
  atsPanel.addEventListener("click", function (event) {
    var chip = event.target.closest("[data-keyword]"); if (!chip) return;
    var skills = form.elements.skills.value.trim();
    form.elements.skills.value = skills ? skills.replace(/,\s*$/, "") + ", " + chip.dataset.keyword : chip.dataset.keyword;
    chip.disabled = true; chip.textContent = "✓ " + chip.dataset.keyword; render();
  });

  /* Download: vector PDF → local download → private storage upload + database record. */
  function triggerDownload(blob, name) {
    var url = URL.createObjectURL(blob), link = document.createElement("a");
    link.href = url; link.download = name; document.body.appendChild(link); link.click(); link.remove();
    setTimeout(function () { URL.revokeObjectURL(url); }, 4000);
  }
  document.getElementById("downloadResume").addEventListener("click", async function () {
    var button = this, d = data();
    if (!d.full_name) { say("Add your full name before downloading.", "error"); form.elements.full_name.focus(); return; }
    if (!pdf) { say("The PDF generator did not load. Check your connection and refresh.", "error"); return; }
    if (!d.resume_name) { d.resume_name = d.full_name + " resume"; form.elements.resume_name.value = d.resume_name; }
    button.disabled = true; say("Generating your PDF…", "");
    try {
      var out = await pdf.generate(d), fileName = pdf.fileName(d.resume_name);
      triggerDownload(out.blob, fileName);
      var message = "PDF downloaded (" + out.pages + " page" + (out.pages > 1 ? "s" : "") + ", " + Math.max(1, Math.round(out.blob.size / 1024)) + " KB)." + (out.warnings.length ? " " + out.warnings.join(" ") : "");
      if (!user || !api.resumes) { say(message + " Sign in to save resumes to your dashboard library.", "success"); return; }
      say(message + " Saving to your library…", "");
      try { await api.resumes.save(user.id, out.blob, { resume_name: d.resume_name, template: d.template, resume_data: d }); say(message + " Saved to your dashboard resume library.", "success"); }
      catch (error) { say(message + " But saving to your library failed: " + error.message, "error"); }
    } catch (error) { say(error.message || "Could not generate the PDF.", "error"); }
    finally { button.disabled = false; }
  });
  document.getElementById("resetResume").addEventListener("click", function () {
    if (!confirm("Clear every field and start a new resume?")) return;
    var before = data();
    storage(function (s) { s.removeItem(DRAFT_KEY); });
    atsPanel.hidden = true; setData({ email: user && user.email || "" }, true); offerUndo(before, "Form cleared.");
    history.replaceState(null, "", location.pathname);
  });

  /* Initial state: saved resume (?id=), local draft, or a blank form prefilled from the account. */
  var draft = null;
  try { draft = JSON.parse(storage(function (s) { return s.getItem(DRAFT_KEY); }) || "null"); } catch (e) { draft = null; }
  setData(draft || {}, true);
  if (client) {
    try { var auth = await client.auth.getUser(); user = auth.data && auth.data.user; } catch (e) { user = null; }
  }
  var signIn = document.querySelector(".site-signin");
  if (user) { if (signIn) { signIn.textContent = "Dashboard"; signIn.href = "/dashboard"; } }
  else document.getElementById("saveHint").textContent = "You can build and download without an account. Sign in to save resumes to your dashboard library.";
  var id = new URLSearchParams(location.search).get("id");
  if (id && user && api.resumes) {
    var saved = await api.resumes.get(user.id, id);
    if (saved.data && saved.data.resume_data && saved.data.resume_data.full_name !== undefined) { setData(Object.assign({}, saved.data.resume_data, { resume_name: saved.data.resume_name, template: saved.data.template || saved.data.resume_data.template })); say("Loaded “" + saved.data.resume_name + "”. Downloading saves a new copy to your library.", "success"); }
    else say(saved.error ? "Could not load that resume: " + saved.error.message : "That resume was uploaded as a file, so it can't be edited here.", "error");
  } else if (id && !user) say("Sign in to open a saved resume.", "error");
  if (user) {
    if (!form.elements.email.value && user.email) form.elements.email.value = user.email;
    if (!form.elements.full_name.value && api.getProfile) { var profile = await api.getProfile(user.id); if (profile.data && profile.data.full_name) form.elements.full_name.value = profile.data.full_name; }
    render();
  }
  if (pdf) setTimeout(function () { pdf.preloadFonts(form.elements.template.value); }, 1500);
});

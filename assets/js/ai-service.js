(function () {
  "use strict";
  /*
   * HireIn AI writing service.
   *
   * Every resume tool resolves to the same structured envelope:
   *   { ok: true, action, source: "llm" | "local", generatedAt, data: {...}, warnings: [] }
   *
   * Providers are tried in order. The "llm" provider calls the Supabase `ai-assistant`
   * edge function (which keeps the model key server-side). The "local" provider is a
   * deterministic placeholder that never invents facts; it keeps the tools usable when
   * the LLM is not configured and documents the data contract a future model must meet.
   * To connect another LLM, register a provider with HireInAIService.registerProvider().
   */
  var REMOTE_ACTIONS = new Set(["generateSummary", "rewriteExperience", "improveBulletPoints", "generateAchievements", "optimizeATS", "improveExperience", "grammarCorrection", "atsOptimize", "suggestSkills", "extractKeywords", "calculateATS", "analyzeATS"]);
  var STOP = new Set("a an and are as at be been being but by can could did do does for from had has have he her his i if in into is it its may me might must my of on or our shall she should so than that the their them then there these they this those to us was we were what when where which while who will with would you your about across after also any both each etc ie eg more most other over per such via within without able ability including include includes strong excellent good great work working job role team teams candidate candidates looking years year experience experienced responsibilities requirements required preferred plus using use new well who's you'll we're".split(" "));
  var VERBS = ["Led", "Built", "Delivered", "Improved", "Designed", "Launched", "Managed", "Streamlined", "Developed", "Implemented", "Reduced", "Increased", "Automated", "Coordinated", "Optimized", "Created", "Analyzed", "Negotiated", "Mentored", "Resolved", "Owned", "Drove", "Established", "Supported", "Trained", "Achieved", "Organized", "Planned", "Executed", "Maintained", "Produced", "Wrote", "Tested", "Migrated", "Scaled", "Collaborated", "Partnered", "Presented", "Researched", "Handled", "Oversaw", "Directed", "Generated", "Secured", "Won"];
  var WEAK = [[/^(i was |was )?responsible for (managing )?/i, "Managed "], [/^(i )?worked on /i, "Delivered "], [/^(i )?helped (to |with )?/i, "Supported "], [/^(i was )?in charge of /i, "Led "], [/^(i )?was part of /i, "Contributed to "], [/^(i )?did /i, "Completed "], [/^(i )?made /i, "Created "], [/^(i )?handled /i, "Managed "], [/^duties included /i, ""], [/^tasks included /i, ""], [/^(i |we )/i, ""]];
  var FILLER = [/\bvery\b\s*/gi, /\breally\b\s*/gi, /\bvarious\b\s*/gi, /\bsuccessfully\b\s*/gi, /\bbasically\b\s*/gi, /\s+etc\.?$/i];
  var COMMON_SKILLS = ["JavaScript", "TypeScript", "Python", "Java", "C#", "C++", "Go", "SQL", "PostgreSQL", "MySQL", "MongoDB", "React", "Angular", "Vue", "Node.js", "Express", "Django", "Flask", "Spring", "HTML", "CSS", "Tailwind", "AWS", "Azure", "GCP", "Docker", "Kubernetes", "Terraform", "Git", "CI/CD", "REST", "GraphQL", "Supabase", "Firebase", "Figma", "Excel", "Power BI", "Tableau", "Salesforce", "SAP", "Jira", "Agile", "Scrum", "Machine Learning", "Data Analysis", "Project Management", "Product Management", "Stakeholder Management", "Digital Marketing", "SEO", "Content Writing", "Customer Service", "Sales", "Recruitment", "Accounting", "Financial Analysis", "Communication", "Leadership", "Negotiation", "Linux", "Android", "iOS", "Swift", "Kotlin", "Flutter", "React Native", "Photoshop", "Illustrator"];

  function words(text) { return String(text || "").toLowerCase().match(/[a-z][a-z0-9+#./-]*[a-z0-9+#]|[a-z]/g) || []; }
  function clean(text) { return String(text || "").replace(/\s+/g, " ").trim(); }
  function sentenceCase(text) { text = clean(text); return text ? text.charAt(0).toUpperCase() + text.slice(1) : ""; }
  function lines(text) {
    var raw = String(text || "").split(/\n+/).map(function (line) { return line.replace(/^\s*(?:[-*•·▪◦>]|\d+[.)])\s*/, "").trim(); }).filter(Boolean);
    if (raw.length === 1 && raw[0].length > 160) raw = (raw[0].match(/[^.!?]+(?:[.!?]+|$)/g) || []).map(function (line) { return line.trim(); }).filter(Boolean);
    return raw;
  }
  function uniq(list) { var seen = new Set(); return list.filter(function (item) { var key = String(item).toLowerCase(); if (!item || seen.has(key)) return false; seen.add(key); return true; }); }
  function startsWithVerb(text) { var first = (text.split(/\s+/)[0] || "").replace(/[^a-z]/gi, ""); return VERBS.some(function (verb) { return verb.toLowerCase() === first.toLowerCase(); }) || /^[a-z]+(ed)$/i.test(first); }
  function resumeText(resume) {
    resume = resume || {};
    var parts = [resume.job_title, resume.summary, (resume.skills || []).join(" ")];
    ["experience", "projects", "education", "certifications"].forEach(function (key) { (resume[key] || []).forEach(function (item) { parts.push(Object.values(item || {}).join(" ")); }); });
    return parts.join(" \n");
  }
  function yearsOfExperience(experience) {
    var now = new Date().getFullYear(), start = Infinity, end = 0;
    (experience || []).forEach(function (item) {
      var years = (String(item.dates || "").match(/(19|20)\d{2}/g) || []).map(Number);
      if (years.length) { start = Math.min(start, years[0]); end = Math.max(end, years[years.length - 1]); }
      if (/present|current|now|till date/i.test(item.dates || "")) end = now;
    });
    return start === Infinity ? 0 : Math.max(0, end - start);
  }

  function improveBullet(text) {
    var original = clean(text), improved = original, changes = [];
    WEAK.forEach(function (rule) { if (rule[0].test(improved)) { improved = improved.replace(rule[0], rule[1]); changes.push("Replaced a passive opening with an action verb."); } });
    FILLER.forEach(function (rule) { if (rule.test(improved)) { improved = improved.replace(rule, ""); changes.push("Removed filler words."); } });
    improved = sentenceCase(improved).replace(/[.;,\s]+$/, "");
    if (improved !== original.replace(/[.;,\s]+$/, "") && !changes.length) changes.push("Tidied capitalization and punctuation.");
    var tips = [];
    if (!startsWithVerb(improved)) tips.push("Start with a strong action verb such as " + VERBS.slice(0, 4).join(", ") + ".");
    if (!/\d/.test(improved)) tips.push("Add a real measurable result (%, time, revenue, users) if you have one.");
    if (improved.length > 220) tips.push("Shorten to one or two lines for skimmability.");
    return { original: original, improved: improved, changes: uniq(changes), tips: tips };
  }

  /* Local placeholder implementations. Each returns the same `data` shape the LLM must return. */
  var LOCAL = {
    generateSummary: function (input) {
      var r = input.resume || {}, exp = r.experience || [], latest = exp[0] || {};
      var title = clean(r.job_title || latest.role), years = yearsOfExperience(exp), skills = (r.skills || []).slice(0, 5);
      if (!title && !skills.length && !exp.length) return { summary: "", warnings: ["Add a job title, experience or skills so a summary can be drafted from your real details."] };
      var parts = [];
      parts.push((title || "Professional") + (years ? " with " + years + "+ years of experience" : "") + (latest.organization ? ", most recently at " + clean(latest.organization) : "") + ".");
      if (skills.length) parts.push("Skilled in " + (skills.length > 1 ? skills.slice(0, -1).join(", ") + " and " + skills[skills.length - 1] : skills[0]) + ".");
      var impact = exp.map(function (item) { return lines(item.details).find(function (line) { return /\d/.test(line); }); }).find(Boolean);
      if (impact) parts.push("Recent impact: " + improveBullet(impact).improved.replace(/^./, function (c) { return c.toLowerCase(); }) + ".");
      parts.push("Focused on delivering reliable, high-quality results and collaborating across teams.");
      return { summary: parts.join(" "), warnings: [] };
    },
    rewriteExperience: function (input) {
      var list = (input.resume && input.resume.experience) || input.experience || [];
      return { experience: list.map(function (item, index) { return { index: index, role: clean(item.role), organization: clean(item.organization), bullets: lines(item.details).map(function (line) { return improveBullet(line).improved; }) }; }) };
    },
    improveBulletPoints: function (input) {
      var list = Array.isArray(input.bullets) ? input.bullets : lines(input.text);
      return { bullets: list.map(improveBullet) };
    },
    generateAchievements: function (input) {
      var role = clean(input.role || (input.experience && input.experience.role) || (input.resume && input.resume.job_title) || "your role");
      var skill = ((input.resume && input.resume.skills) || [])[0] || "[key skill]";
      return { achievements: [
        { text: "Improved [process or metric] by [X%] as " + role + " by applying " + skill, needsVerification: true },
        { text: "Delivered [project or initiative] [ahead of schedule / under budget], saving [time or cost]", needsVerification: true },
        { text: "Recognized for [award, promotion or stakeholder feedback] after [specific contribution]", needsVerification: true }
      ] };
    },
    optimizeATS: function (input) {
      var r = input.resume || {}, text = resumeText(r).toLowerCase(), jd = clean(input.jobDescription);
      var counts = {};
      words(jd).forEach(function (word) { if (word.length > 2 && !STOP.has(word) && !/^\d+$/.test(word)) counts[word] = (counts[word] || 0) + 1; });
      COMMON_SKILLS.forEach(function (skill) { if (jd.toLowerCase().indexOf(skill.toLowerCase()) >= 0) counts[skill.toLowerCase()] = (counts[skill.toLowerCase()] || 0) + 3; });
      var keywords = Object.keys(counts).sort(function (a, b) { return counts[b] - counts[a]; }).slice(0, 30);
      var matched = keywords.filter(function (word) { return text.indexOf(word) >= 0; }), missing = keywords.filter(function (word) { return text.indexOf(word) < 0; });
      var checks = [
        { section: "Contact details", ok: Boolean(r.email && r.phone), tip: "Include an email address and phone number." },
        { section: "Job title", ok: Boolean(r.job_title), tip: "Add a target job title under your name." },
        { section: "Summary", ok: clean(r.summary).length >= 120, tip: "Write a 2–4 sentence summary (120+ characters)." },
        { section: "Experience", ok: (r.experience || []).length > 0, tip: "Add at least one role with bullet points." },
        { section: "Measurable results", ok: /\d/.test((r.experience || []).map(function (x) { return x.details; }).join(" ")), tip: "Quantify achievements with real numbers." },
        { section: "Education", ok: (r.education || []).length > 0, tip: "Add your education." },
        { section: "Skills", ok: (r.skills || []).length >= 5, tip: "List at least 5 relevant skills." }
      ];
      var sectionScore = checks.filter(function (c) { return c.ok; }).length / checks.length;
      var score = keywords.length ? Math.round((matched.length / keywords.length) * 60 + sectionScore * 40) : Math.round(sectionScore * 100);
      var suggestions = checks.filter(function (c) { return !c.ok; }).map(function (c) { return c.tip; });
      if (missing.length) suggestions.unshift("Add missing keywords only where they truthfully describe your experience.");
      if (!jd) suggestions.push("Paste a job description to measure keyword match for a specific role.");
      return { score: Math.max(0, Math.min(100, score)), matchedKeywords: matched, missingKeywords: missing.slice(0, 15), sectionChecks: checks, suggestions: suggestions };
    },
    grammarCorrection: function (input) {
      var text = String(input.text || "").replace(/[ \t]+/g, " ").replace(/\s+([,.;:!?])/g, "$1").replace(/\bi\b/g, "I").replace(/(^|[.!?]\s+)([a-z])/g, function (m, p, c) { return p + c.toUpperCase(); }).trim();
      return { correctedText: text };
    },
    suggestSkills: function (input) {
      var text = resumeText(input.resume).toLowerCase(), have = new Set(((input.resume && input.resume.skills) || []).map(function (s) { return s.toLowerCase(); }));
      var found = COMMON_SKILLS.filter(function (skill) { return !have.has(skill.toLowerCase()) && new RegExp("(^|[^a-z])" + skill.toLowerCase().replace(/[.*+?^${}()|[\]\\]/g, "\\$&") + "([^a-z]|$)").test(text); });
      return { skills: ((input.resume && input.resume.skills) || []).concat(found), reason: found.length ? "Found in your experience and projects." : "No additional skills were found in your text." };
    }
  };
  LOCAL.improveExperience = function (input) { return { bullets: LOCAL.improveBulletPoints(input).bullets.map(function (b) { return b.improved; }) }; };
  LOCAL.atsOptimize = function (input) { return { optimizedText: LOCAL.grammarCorrection(input).correctedText, suggestions: LOCAL.optimizeATS(input).suggestions }; };

  /* Normalizers coerce any provider's response into the documented shape. */
  function arr(value) { return Array.isArray(value) ? value : []; }
  var NORMALIZE = {
    generateSummary: function (d) { return { summary: clean(d.summary), warnings: arr(d.warnings).map(String) }; },
    rewriteExperience: function (d, input) {
      var source = (input.resume && input.resume.experience) || [];
      return { experience: arr(d.experience).map(function (item, i) { var index = Number.isInteger(item.index) ? item.index : i; return { index: index, role: clean(item.role || (source[index] || {}).role), organization: clean(item.organization || (source[index] || {}).organization), bullets: arr(item.bullets).map(clean).filter(Boolean) }; }) };
    },
    improveBulletPoints: function (d, input) {
      var originals = Array.isArray(input.bullets) ? input.bullets : lines(input.text);
      return { bullets: arr(d.bullets).map(function (b, i) { return typeof b === "string" ? { original: originals[i] || "", improved: clean(b), changes: [], tips: [] } : { original: clean(b.original || originals[i]), improved: clean(b.improved), changes: arr(b.changes).map(String), tips: arr(b.tips).map(String) }; }).filter(function (b) { return b.improved; }) };
    },
    generateAchievements: function (d) { return { achievements: arr(d.achievements).map(function (a) { return typeof a === "string" ? { text: clean(a), needsVerification: true } : { text: clean(a.text), needsVerification: a.needsVerification !== false }; }).filter(function (a) { return a.text; }) }; },
    optimizeATS: function (d) { var score = Number(d.score); return { score: Number.isFinite(score) ? Math.max(0, Math.min(100, Math.round(score))) : 0, matchedKeywords: arr(d.matchedKeywords || d.matchedSkills).map(String), missingKeywords: arr(d.missingKeywords).map(String), sectionChecks: arr(d.sectionChecks), suggestions: arr(d.suggestions).map(String) }; },
    grammarCorrection: function (d) { return { correctedText: String(d.correctedText || "") }; },
    suggestSkills: function (d) { return { skills: arr(d.skills).map(clean).filter(Boolean), reason: String(d.reason || "") }; }
  };

  function remoteRequest(action, input) {
    var api = window.hireInAI;
    if (!api || !api.client) return Promise.reject(new Error("Sign in before using HireIn AI tools."));
    if (!REMOTE_ACTIONS.has(action)) return Promise.reject(new Error("This AI action is not supported."));
    return api.client.functions.invoke("ai-assistant", { body: { action: action, input: input || {} } }).then(function (result) {
      if (result.error) {
        var details = result.error.context && result.error.context.json ? result.error.context.json() : null;
        return Promise.resolve(details).catch(function () { return null; }).then(function (body) {
          throw new Error(body && body.error || result.error.message || "AI service is unavailable.");
        });
      }
      var data = result.data;
      if (!data || typeof data !== "object" || Array.isArray(data)) throw new Error("AI returned an invalid response. Please retry.");
      return data;
    });
  }

  /* The LLM is only attempted for signed-in users, and is skipped for the rest of the tab
     session after it fails (e.g. function not deployed or key missing) to avoid repeated errors. */
  var remote = { session: false, disabled: false };
  try { remote.disabled = sessionStorage.getItem("hirein.aiRemoteDisabled") === "1"; } catch (e) { /* storage unavailable */ }
  var authClient = window.hireInAI && window.hireInAI.client;
  if (authClient) {
    authClient.auth.getSession().then(function (r) { remote.session = Boolean(r.data && r.data.session); }).catch(function () {});
    authClient.auth.onAuthStateChange(function (event, session) { remote.session = Boolean(session); });
  }
  function disableRemote() { remote.disabled = true; try { sessionStorage.setItem("hirein.aiRemoteDisabled", "1"); } catch (e) { /* storage unavailable */ } }

  var providers = [
    { name: "llm", supports: function (action) { return REMOTE_ACTIONS.has(action) && Boolean(authClient) && remote.session && !remote.disabled; }, run: function (action, input) { return remoteRequest(action, input).catch(function (error) { if (!/too large/i.test(error.message || "")) disableRemote(); throw error; }); } },
    { name: "local", supports: function (action) { return Boolean(LOCAL[action]); }, run: function (action, input) { return Promise.resolve(LOCAL[action](input)); } }
  ];

  function runTool(action, input) {
    input = input || {};
    var warnings = [], candidates = providers.filter(function (p) { return p.supports(action); });
    if (!candidates.length) return Promise.reject(new Error("This AI action is not supported."));
    function attempt(i) {
      var provider = candidates[i];
      return provider.run(action, input).then(function (raw) {
        var data = NORMALIZE[action] ? NORMALIZE[action](raw || {}, input) : raw;
        if (data && Array.isArray(data.warnings)) { warnings = warnings.concat(data.warnings); delete data.warnings; }
        return { ok: true, action: action, source: provider.name, generatedAt: new Date().toISOString(), data: data, warnings: warnings };
      }).catch(function (error) {
        if (i + 1 >= candidates.length) throw error;
        warnings.push("AI model unavailable (" + (error && error.message || "unknown error") + "). Used built-in writing rules instead.");
        return attempt(i + 1);
      });
    }
    return attempt(0);
  }
  function tool(name) { return function (input) { return runTool(name, input); }; }
  function raw(name) { return function (input) { return remoteRequest(name, input); }; }

  window.HireInAIService = {
    /* Structured resume tools: resolve to { ok, action, source, generatedAt, data, warnings }. */
    generateSummary: tool("generateSummary"),
    rewriteExperience: tool("rewriteExperience"),
    improveBulletPoints: tool("improveBulletPoints"),
    generateAchievements: tool("generateAchievements"),
    optimizeATS: tool("optimizeATS"),
    grammarCorrection: tool("grammarCorrection"),
    suggestSkills: tool("suggestSkills"),
    run: runTool,
    registerProvider: function (provider, first) { if (provider && provider.name && provider.run && provider.supports) providers[first ? "unshift" : "push"](provider); },
    local: LOCAL,
    /* Raw edge-function access used by the ATS checker (returns the model JSON directly). */
    request: remoteRequest,
    actions: REMOTE_ACTIONS,
    improveExperience: raw("improveExperience"),
    atsOptimize: raw("atsOptimize"),
    extractKeywords: raw("extractKeywords"),
    calculateATS: raw("calculateATS")
  };
})();

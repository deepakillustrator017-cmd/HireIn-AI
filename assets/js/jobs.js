(function () {
  "use strict";
  var pageSize = 12;
  var FILTERS = { q: "search", category: "filterCategory", location: "filterLocation", experience: "filterExperience", salary: "filterSalary", mode: "filterMode", type: "filterType", company: "filterCompany", sort: "sortJobs" };

  document.addEventListener("DOMContentLoaded", function () {
    var api = window.hireInAI;
    var grid = document.getElementById("jobs");
    if (!grid) return;
    if (!api || !api.client) { grid.innerHTML = "<div class='empty'>Jobs could not load. Check your connection and refresh.</div>"; return; }
    var client = api.client, J = api.jobs, escape = api.escapeHtml;
    var form = document.getElementById("searchForm"), count = document.getElementById("jobsCount"), pagination = document.getElementById("jobsPagination"), notice = document.getElementById("jobsMessage");
    var el = {}; Object.keys(FILTERS).forEach(function (key) { el[key] = document.getElementById(FILTERS[key]); });
    var jobs = [], saved = new Set(), user = null, currentPage = 1, params = new URLSearchParams(location.search);
    Object.keys(el).forEach(function (key) { if (el[key] && params.get(key)) el[key].dataset.initial = params.get(key); });
    if (el.q) el.q.value = params.get("q") || "";
    currentPage = Math.max(1, Number(params.get("page")) || 1);

    function unique(values) { return Array.from(new Set(values.map(function (v) { return String(v || "").trim(); }).filter(Boolean))).sort(function (a, b) { return a.localeCompare(b); }); }
    function populate(select, values) {
      if (!select) return;
      values.forEach(function (value) { var option = document.createElement("option"); option.value = value; option.textContent = value; select.appendChild(option); });
    }
    function applyInitial() {
      Object.keys(el).forEach(function (key) {
        var select = el[key], initial = select && select.dataset.initial;
        if (!initial || select.tagName !== "SELECT") return;
        var match = Array.from(select.options).find(function (o) { return o.value.toLowerCase() === initial.toLowerCase(); });
        if (match) select.value = match.value;
      });
    }
    function value(key) { return String(el[key] && el[key].value || "").trim(); }
    function syncUrl() {
      var next = new URLSearchParams();
      Object.keys(el).forEach(function (key) { var v = value(key); if (v && !(key === "salary" && v === "0") && !(key === "sort" && v === "newest")) next.set(key, v); });
      if (currentPage > 1) next.set("page", currentPage);
      var qs = next.toString();
      history.replaceState(null, "", location.pathname + (qs ? "?" + qs : ""));
    }
    function filteredJobs() {
      var q = value("q").toLowerCase(), category = value("category"), loc = value("location").toLowerCase(), level = value("experience"), minSalary = Number(value("salary") || 0), mode = value("mode"), type = value("type").toLowerCase(), company = value("company").toLowerCase();
      var list = jobs.filter(function (job) {
        return (!q || job._search.indexOf(q) >= 0) &&
          (!category || job._category === category) &&
          (!loc || job._location.toLowerCase() === loc) &&
          (!level || job._level === level) &&
          (!minSalary || job._salary >= minSalary) &&
          (!mode || job._mode === mode) &&
          (!type || job._type.toLowerCase() === type) &&
          (!company || String(job.company || "").trim().toLowerCase() === company);
      });
      var sort = value("sort") || "newest";
      list.sort(function (a, b) {
        if (sort === "salary-high") return b._salary - a._salary || b._posted - a._posted;
        if (sort === "salary-low") return (a._salary || Infinity) - (b._salary || Infinity) || b._posted - a._posted;
        return b._posted - a._posted || Number(b.id) - Number(a.id);
      });
      return list;
    }
    function card(job) {
      var id = encodeURIComponent(job.id), company = String(job.company || "Company"), isSaved = saved.has(Number(job.id));
      var posted = job._posted ? new Date(job._posted).toLocaleDateString("en-IN", { day: "numeric", month: "short", year: "numeric" }) : "Recently";
      var meta = [job._location, job._mode, job._type, J.levelLabel(job._level) || job.experience].filter(Boolean);
      return "<article class='card'><div class='head'><img class='logo-img' loading='lazy' alt='" + escape(company) + " logo' src='" + escape(J.logo(job)) + "'><div class='job-company-block'><div class='category'>" + escape(job._category) + "</div><div class='company'>" + escape(company) + "</div></div></div>" +
        "<h2 class='title'><a href='/job/" + id + "'>" + escape(job.title || "Open role") + "</a></h2>" +
        "<div class='meta'>" + meta.map(function (m) { return "<span>" + escape(m) + "</span>"; }).join("") + "</div>" +
        "<p class='job-summary'>" + escape(String(job.description || "").slice(0, 180)) + "</p>" +
        (job._skills.length ? "<div class='job-tags'>" + job._skills.slice(0, 4).map(function (s) { return "<span>" + escape(s) + "</span>"; }).join("") + "</div>" : "") +
        "<div class='salary'>" + escape(job.salary || "Salary not listed") + "</div><div class='footer'><span class='date'>Posted " + escape(posted) + "</span><div><button class='save-job' type='button' data-save='" + escape(job.id) + "' aria-pressed='" + isSaved + "' aria-label='" + (isSaved ? "Remove " : "Save ") + escape(job.title || "job") + (isSaved ? " from saved jobs" : "") + "'>" + (isSaved ? "Saved ✓" : "Save") + "</button><a class='btn' href='/job/" + id + "'>View</a></div></div></article>";
    }
    function drawPagination(pageCount) {
      if (pageCount < 2) { pagination.innerHTML = ""; return; }
      var start = Math.max(1, Math.min(currentPage - 2, pageCount - 4)), end = Math.min(pageCount, start + 4);
      var html = "<button type='button' data-page='" + (currentPage - 1) + "'" + (currentPage === 1 ? " disabled" : "") + ">Previous</button>";
      for (var page = start; page <= end; page++) html += "<button type='button' data-page='" + page + "' aria-label='Page " + page + "'" + (page === currentPage ? " aria-current='page'" : "") + ">" + page + "</button>";
      html += "<button type='button' data-page='" + (currentPage + 1) + "'" + (currentPage === pageCount ? " disabled" : "") + ">Next</button>";
      pagination.innerHTML = html;
    }
    function render() {
      var matching = filteredJobs(), pages = Math.max(1, Math.ceil(matching.length / pageSize));
      currentPage = Math.min(Math.max(1, currentPage), pages);
      var visible = matching.slice((currentPage - 1) * pageSize, currentPage * pageSize);
      count.textContent = matching.length ? matching.length + (matching.length === 1 ? " job" : " jobs") + " found" + (pages > 1 ? " · page " + currentPage + " of " + pages : "") : "";
      grid.innerHTML = visible.length ? visible.map(card).join("") : "<div class='empty'>" + (jobs.length ? "No jobs match these filters. Try clearing a filter or changing your search." : "No live jobs yet. Check back soon.") + "</div>";
      drawPagination(pages);
      syncUrl();
    }
    async function loadJobs() {
      var result = await J.listPublished("*");
      if (result.error) { grid.innerHTML = "<div class='empty'>Jobs could not load right now. Please refresh in a moment.</div>"; api.showMessage(notice, "Could not load jobs: " + result.error.message, "error"); return; }
      jobs = (result.data || []).map(function (job) {
        job._category = J.category(job); job._mode = J.mode(job); job._type = J.type(job); job._level = J.level(job); job._salary = J.salary(job);
        job._location = String(job.location || "").trim().replace(/\b\w/g, function (c) { return c.toUpperCase(); }) || "Remote";
        job._skills = J.skills(job); job._posted = J.posted(job);
        job._search = [job.title, job.company, job._category, job._location, job._mode, job.description, job.responsibilities, job.requirements, job._skills.join(" ")].join(" ").toLowerCase();
        return job;
      });
      populate(el.category, unique(jobs.map(function (j) { return j._category; })));
      populate(el.location, unique(jobs.map(function (j) { return j._location; })));
      populate(el.company, unique(jobs.map(function (j) { return j.company; })));
      applyInitial();
      render();
    }
    Object.keys(el).forEach(function (key) {
      if (!el[key] || key === "q") return;
      el[key].addEventListener("change", function () { currentPage = 1; render(); });
    });
    var typing;
    el.q.addEventListener("input", function () { clearTimeout(typing); typing = setTimeout(function () { currentPage = 1; render(); }, 150); });
    form.addEventListener("submit", function (event) { event.preventDefault(); currentPage = 1; render(); });
    document.getElementById("clearFilters").addEventListener("click", function () {
      Object.keys(el).forEach(function (key) { if (el[key].tagName === "SELECT") el[key].selectedIndex = 0; else el[key].value = ""; });
      currentPage = 1; render();
    });
    pagination.addEventListener("click", function (event) {
      var button = event.target.closest("[data-page]"); if (!button || button.disabled) return;
      currentPage = Number(button.dataset.page); render(); grid.scrollIntoView({ behavior: "smooth", block: "start" });
    });
    grid.addEventListener("click", async function (event) {
      var button = event.target.closest("[data-save]");
      if (!button) return;
      if (!user) { location.href = "/login?next=" + encodeURIComponent("/jobs" + location.search); return; }
      var id = Number(button.dataset.save), save = !saved.has(id);
      button.disabled = true;
      try {
        await J.setSaved(user.id, id, save);
        if (save) saved.add(id); else saved.delete(id);
        render();
        api.showMessage(notice, save ? "Job saved to your dashboard." : "Job removed from your saved list.", "success");
      } catch (error) { api.showMessage(notice, error.message || "Could not update saved jobs.", "error"); button.disabled = false; }
    });
    loadJobs();
    client.auth.getUser().then(async function (result) {
      user = result.data && result.data.user;
      if (!user) return;
      saved = await J.savedIds(user.id);
      if (jobs.length) render();
    }).catch(function () { user = null; });
  });
})();

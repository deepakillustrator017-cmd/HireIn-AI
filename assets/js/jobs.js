(function () {
  "use strict";
  var pageSize = 12;
  var FILTERS = { q: "search", category: "filterCategory", location: "filterLocation", experience: "filterExperience", salary: "filterSalary", mode: "filterMode", type: "filterType", company: "filterCompany", sort: "sortJobs" };

  function emptyState(title, text, action) {
    return "<div class='empty-state'><img src='/assets/imgs/theme/icons/icon-job.svg' alt='' width='48' height='48' loading='lazy' decoding='async'><h3>" + title + "</h3><p>" + text + "</p>" + (action || "") + "</div>";
  }

  document.addEventListener("DOMContentLoaded", function () {
    var grid = document.getElementById("jobs");
    if (!grid) return;
    var api = window.hireInAI;
    var unavailable = emptyState("We're refreshing the job board", "Live jobs couldn't be reached just now. Please try again in a moment.", "<button type='button' class='small-button' data-retry>Try again</button>");
    if (!api || !api.client || !api.jobs) { grid.innerHTML = unavailable; grid.addEventListener("click", function (e) { if (e.target.closest("[data-retry]")) location.reload(); }); return; }
    var client = api.client, J = api.jobs;
    var form = document.getElementById("searchForm"), count = document.getElementById("jobsCount"), pagination = document.getElementById("jobsPagination"), notice = document.getElementById("jobsMessage"), clear = document.getElementById("clearFilters");
    var el = {}; Object.keys(FILTERS).forEach(function (key) { var node = document.getElementById(FILTERS[key]); if (node) el[key] = node; });
    var jobs = [], saved = new Set(), user = null, currentPage = 1, params = new URLSearchParams(location.search);
    Object.keys(el).forEach(function (key) { if (params.get(key)) el[key].dataset.initial = params.get(key); });
    if (el.q) el.q.value = params.get("q") || "";
    currentPage = Math.max(1, Number(params.get("page")) || 1);
    function say(message, kind) { if (notice) api.showMessage(notice, message, kind); }

    function unique(values) { return Array.from(new Set(values.map(function (v) { return String(v || "").trim(); }).filter(Boolean))).sort(function (a, b) { return a.localeCompare(b); }); }
    function populate(select, values) {
      if (!select) return;
      values.forEach(function (value) { var option = document.createElement("option"); option.value = value; option.textContent = value; select.appendChild(option); });
    }
    function applyInitial() {
      Object.keys(el).forEach(function (key) {
        var select = el[key], initial = select.dataset.initial;
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
      try { history.replaceState(null, "", location.pathname + (qs ? "?" + qs : "")); } catch (e) { /* URL sync is optional */ }
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
    function drawPagination(pageCount) {
      if (!pagination) return;
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
      if (count) count.textContent = matching.length ? matching.length + (matching.length === 1 ? " job" : " jobs") + " found" + (pages > 1 ? " · page " + currentPage + " of " + pages : "") : "";
      if (visible.length) grid.innerHTML = visible.map(function (job) { return J.card(job, { saveable: true, saved: saved.has(Number(job.id)) }); }).join("");
      else if (jobs.length) grid.innerHTML = emptyState("No jobs match these filters", "Try a broader search or clear a filter to see more roles.", "<button type='button' class='small-button' data-clear>Clear filters</button>");
      else grid.innerHTML = emptyState("New roles are on the way", "Hiring teams are preparing their next openings. Build an ATS-friendly resume now so you're ready to apply.", "<a class='small-button' href='/resume-ai.html'>Build your resume</a>");
      drawPagination(pages);
      syncUrl();
      var qVal = value("q"), catVal = value("category");
      if (qVal && catVal) { document.title = qVal + " (" + catVal + ") Jobs | HireIn AI"; }
      else if (qVal) { document.title = qVal + " Jobs | HireIn AI"; }
      else if (catVal) { document.title = catVal + " Jobs | HireIn AI"; }
      else { document.title = "Browse Jobs & Opportunities | HireIn AI"; }
    }
    function prepare(job) {
      job._category = J.category(job); job._mode = J.mode(job); job._type = J.type(job); job._level = J.level(job); job._salary = J.salary(job);
      job._location = String(job.location || "").trim().replace(/\b\w/g, function (c) { return c.toUpperCase(); }) || "Remote";
      job._skills = J.skills(job); job._posted = J.posted(job);
      job._search = [job.title, job.company, job._category, job._location, job._mode, job.description, job.responsibilities, job.requirements, job._skills.join(" ")].join(" ").toLowerCase();
      return job;
    }
    async function loadJobs(attempt) {
      var result;
      try { result = await J.listPublished("*"); } catch (error) { result = { error: error }; }
      if (result.error) {
        if (attempt < 2) { setTimeout(function () { loadJobs(attempt + 1); }, 1500 * (attempt + 1)); return; }
        console.warn("HireIn AI jobs unavailable:", result.error.message || result.error);
        if (count) count.textContent = "";
        grid.innerHTML = unavailable;
        return;
      }
      jobs = (result.data || []).map(prepare);
      populate(el.category, unique(jobs.map(function (j) { return j._category; })));
      populate(el.location, unique(jobs.map(function (j) { return j._location; })));
      populate(el.company, unique(jobs.map(function (j) { return j.company; })));
      applyInitial();
      render();
    }
    function clearFilters() {
      Object.keys(el).forEach(function (key) { if (el[key].tagName === "SELECT") el[key].selectedIndex = 0; else el[key].value = ""; });
      currentPage = 1; render();
    }
    Object.keys(el).forEach(function (key) { if (key !== "q") el[key].addEventListener("change", function () { currentPage = 1; render(); }); });
    var typing;
    if (el.q) el.q.addEventListener("input", function () { clearTimeout(typing); typing = setTimeout(function () { currentPage = 1; render(); }, 150); });
    if (form) form.addEventListener("submit", function (event) { event.preventDefault(); currentPage = 1; render(); });
    if (clear) clear.addEventListener("click", clearFilters);
    if (pagination) pagination.addEventListener("click", function (event) {
      var button = event.target.closest("[data-page]"); if (!button || button.disabled) return;
      currentPage = Number(button.dataset.page); render(); grid.scrollIntoView({ behavior: "smooth", block: "start" });
    });
    grid.addEventListener("click", async function (event) {
      if (event.target.closest("[data-retry]")) { grid.innerHTML = "<div class='empty'>Loading jobs…</div>"; loadJobs(2); return; }
      if (event.target.closest("[data-clear]")) { clearFilters(); return; }
      var button = event.target.closest("[data-save]");
      if (!button) return;
      if (!user) { location.href = "/login.html?next=" + encodeURIComponent(location.pathname + location.search); return; }
      var id = Number(button.dataset.save), save = !saved.has(id);
      button.disabled = true;
      try {
        await J.setSaved(user.id, id, save);
        if (save) saved.add(id); else saved.delete(id);
        render();
        say(save ? "Job saved to your dashboard." : "Job removed from your saved list.", "success");
      } catch (error) { say(error.message || "Could not update saved jobs.", "error"); button.disabled = false; }
    });
    loadJobs(0);
    client.auth.getUser().then(async function (result) {
      user = result.data && result.data.user;
      if (!user) return;
      saved = await J.savedIds(user.id);
      if (jobs.length) render();
    }).catch(function () { user = null; });
  });
})();

(function () {
  "use strict";
  var pageSize = 12;

  function safeText(value) { return String(value == null ? "" : value); }
  function escape(value) {
    return window.hireInAI && window.hireInAI.escapeHtml
      ? window.hireInAI.escapeHtml(value)
      : safeText(value).replace(/[&<>"']/g, function (char) { return ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[char]; });
  }
  function dateValue(job) {
    var date = new Date(job.posted_at || job.created_at || 0);
    return Number.isNaN(date.getTime()) ? 0 : date.getTime();
  }
  function salaryValue(job) {
    if (Number(job.salary_min) > 0) return Number(job.salary_min);
    var text = safeText(job.salary).toLowerCase().replace(/,/g, "");
    var match = text.match(/\d+(?:\.\d+)?/);
    if (!match) return 0;
    var amount = Number(match[0]);
    if (/lpa|lakh|lac/.test(text)) amount *= 100000;
    else if (/\bk\b/.test(text)) amount *= 1000;
    return amount;
  }
  function workMode(job) {
    var value = safeText(job.work_mode || "").toLowerCase();
    if (value.indexOf("remote") >= 0 || /remote/i.test(job.location || "")) return "Remote";
    if (value.indexOf("hybrid") >= 0) return "Hybrid";
    return value ? "Onsite" : "Onsite";
  }
  function expLevel(job) {
    var value = safeText(job.experience).toLowerCase();
    if (/senior|lead|principal|staff|\b[6-9]\+?\s*(years|yrs)/.test(value)) return "senior";
    if (/mid|intermediate|\b[2-5]\+?\s*(years|yrs)/.test(value)) return "mid";
    if (value) return "entry";
    return "";
  }
  function imageUrl(job) {
    var value = safeText(job.logo || (job.company_id && job.companies && job.companies.logo_url) || "");
    if (/^https?:\/\//i.test(value) || /^assets\/[\w./-]+$/i.test(value)) return escape(value);
    return "assets/imgs/theme/jobhub-logo.svg";
  }
  function modeOf(job) { return workMode(job); }
  function typeOf(job) { return safeText(job.employment_type || job.type || "Full time"); }
  function locationOf(job) { return safeText(job.location || "Remote"); }

  document.addEventListener("DOMContentLoaded", function () {
    var api = window.hireInAI;
    var grid = document.getElementById("jobs");
    if (!api || !api.client || !grid) return;
    var client = api.client;
    var search = document.getElementById("search");
    var form = document.getElementById("searchForm");
    var companyFilter = document.getElementById("filterCompany");
    var locationFilter = document.getElementById("filterLocation");
    var experienceFilter = document.getElementById("filterExperience");
    var salaryFilter = document.getElementById("filterSalary");
    var modeFilter = document.getElementById("filterMode");
    var typeFilter = document.getElementById("filterType");
    var sortSelect = document.getElementById("sortJobs");
    var count = document.getElementById("jobsCount");
    var pagination = document.getElementById("jobsPagination");
    var notice = document.getElementById("jobsMessage");
    var jobs = [];
    var saved = new Set();
    var user = null;
    var currentPage = 1;
    var params = new URLSearchParams(location.search);
    if (search) search.value = params.get("q") || "";
    if (companyFilter && params.get("company")) companyFilter.dataset.initial = params.get("company");
    if (locationFilter && params.get("location")) locationFilter.dataset.initial = params.get("location");

    function populate(select, values, label) {
      if (!select) return;
      var initial = select.dataset.initial || "";
      values.forEach(function (value) {
        var option = document.createElement("option");
        option.value = value;
        option.textContent = value;
        select.appendChild(option);
      });
      if (initial) {
        var match = Array.from(select.options).find(function (option) { return option.value.toLowerCase() === initial.toLowerCase(); });
        if (match) select.value = match.value;
      }
      select.setAttribute("aria-label", label);
    }
    function unique(values) {
      return Array.from(new Set(values.map(function (value) { return safeText(value).trim(); }).filter(Boolean))).sort(function (a, b) { return a.localeCompare(b); });
    }
    function readFilters() {
      return {
        query: safeText(search && search.value).trim().toLowerCase(),
        company: safeText(companyFilter && companyFilter.value).toLowerCase(),
        location: safeText(locationFilter && locationFilter.value).toLowerCase(),
        experience: safeText(experienceFilter && experienceFilter.value),
        salary: Number(salaryFilter && salaryFilter.value || 0),
        mode: safeText(modeFilter && modeFilter.value).toLowerCase(),
        type: safeText(typeFilter && typeFilter.value).toLowerCase()
      };
    }
    function filteredJobs() {
      var filter = readFilters();
      var list = jobs.filter(function (job) {
        var haystack = [job.title, job.company, job.category, job.location, job.description, job.responsibilities, job.requirements, (job.skills || []).join(" ")].join(" ").toLowerCase();
        return (!filter.query || haystack.indexOf(filter.query) >= 0) &&
          (!filter.company || safeText(job.company).toLowerCase() === filter.company) &&
          (!filter.location || locationOf(job).toLowerCase() === filter.location) &&
          (!filter.experience || expLevel(job) === filter.experience) &&
          (!filter.salary || salaryValue(job) >= filter.salary) &&
          (!filter.mode || modeOf(job).toLowerCase() === filter.mode) &&
          (!filter.type || typeOf(job).toLowerCase() === filter.type);
      });
      var sort = safeText(sortSelect && sortSelect.value || "newest");
      list.sort(function (a, b) {
        if (sort === "salary-high") return salaryValue(b) - salaryValue(a) || dateValue(b) - dateValue(a);
        if (sort === "salary-low") return salaryValue(a) - salaryValue(b) || dateValue(b) - dateValue(a);
        return dateValue(b) - dateValue(a) || Number(b.id) - Number(a.id);
      });
      return list;
    }
    function card(job) {
      var id = encodeURIComponent(job.id);
      var posted = dateValue(job) ? new Date(dateValue(job)).toLocaleDateString("en-IN") : "Recently";
      var company = safeText(job.company || "Company");
      var skills = Array.isArray(job.skills) ? job.skills : [];
      return "<article class='card'><div class='head'><img class='logo-img' loading='lazy' alt='" + escape(company) + " logo' src='" + imageUrl(job) + "'><div class='job-company-block'><div class='category'>" + escape(job.category || "Opportunity") + "</div><div class='company'>" + escape(company) + "</div></div></div>" +
        "<h2 class='title'><a href='/job/" + id + "'>" + escape(job.title || "Open role") + "</a></h2>" +
        "<div class='meta'><span>" + escape(locationOf(job)) + "</span><span>" + escape(modeOf(job)) + "</span><span>" + escape(typeOf(job)) + "</span>" + (job.experience ? "<span>" + escape(job.experience) + "</span>" : "") + "</div>" +
        "<p class='job-summary'>" + escape(safeText(job.description || "").slice(0, 180)) + "</p>" +
        (skills.length ? "<div class='job-tags'>" + skills.slice(0, 4).map(function (skill) { return "<span>" + escape(skill) + "</span>"; }).join("") + "</div>" : "") +
        "<div class='salary'>" + escape(job.salary || "Salary not listed") + "</div><div class='footer'><span class='date'>Posted " + escape(posted) + "</span><div><button class='save-job' type='button' data-save='" + escape(job.id) + "' aria-pressed='" + saved.has(Number(job.id)) + "'>" + (saved.has(Number(job.id)) ? "Saved" : "Save") + "</button><a class='btn' href='/job/" + id + "'>View</a></div></div></article>";
    }
    function drawPagination(pageCount) {
      if (!pagination) return;
      if (pageCount < 2) { pagination.innerHTML = ""; return; }
      var start = Math.max(1, Math.min(currentPage - 2, pageCount - 4));
      var end = Math.min(pageCount, start + 4);
      var html = "<button type='button' data-page='" + (currentPage - 1) + "'" + (currentPage === 1 ? " disabled" : "") + ">Previous</button>";
      for (var page = start; page <= end; page++) html += "<button type='button' data-page='" + page + "' aria-label='Page " + page + "'" + (page === currentPage ? " aria-current='page'" : "") + ">" + page + "</button>";
      html += "<button type='button' data-page='" + (currentPage + 1) + "'" + (currentPage === pageCount ? " disabled" : "") + ">Next</button>";
      pagination.innerHTML = html;
    }
    function render() {
      var matching = filteredJobs();
      var pages = Math.max(1, Math.ceil(matching.length / pageSize));
      currentPage = Math.min(currentPage, pages);
      var visible = matching.slice((currentPage - 1) * pageSize, currentPage * pageSize);
      if (count) count.textContent = matching.length + (matching.length === 1 ? " job" : " jobs") + (matching.length ? " found" : "");
      grid.innerHTML = visible.length ? visible.map(card).join("") : "<div class='empty'>No jobs match these filters. Try changing your search.</div>";
      drawPagination(pages);
    }
    async function loadJobs() {
      try {
        var result = await client.from("jobs").select("*").in("status", ["published", "active"]).order("posted_at", { ascending: false });
        if (result.error) throw result.error;
        jobs = result.data || [];
        populate(companyFilter, unique(jobs.map(function (job) { return job.company; })), "Filter by company");
        populate(locationFilter, unique(jobs.map(function (job) { return locationOf(job); })), "Filter by location");
        render();
      } catch (error) {
        grid.innerHTML = "<div class='empty'>Jobs could not load right now. Please refresh in a moment.</div>";
        if (api.showMessage) api.showMessage(notice, error.message || "Could not load jobs.", "error");
      }
    }
    document.querySelectorAll("#filterCompany,#filterLocation,#filterExperience,#filterSalary,#filterMode,#filterType,#sortJobs").forEach(function (select) {
      select.addEventListener("change", function () { currentPage = 1; render(); });
    });
    if (search) search.addEventListener("input", function () { currentPage = 1; render(); });
    if (form) form.addEventListener("submit", function (event) { event.preventDefault(); currentPage = 1; render(); });
    if (pagination) pagination.addEventListener("click", function (event) { var button = event.target.closest("[data-page]"); if (!button || button.disabled) return; currentPage = Number(button.dataset.page); render(); grid.scrollIntoView({ behavior: "smooth", block: "start" }); });
    grid.addEventListener("click", async function (event) {
      var button = event.target.closest("[data-save]");
      if (!button) return;
      if (!user) { location.href = "/login?next=%2Fjobs"; return; }
      var id = Number(button.dataset.save);
      if (saved.has(id)) { if (api.showMessage) api.showMessage(notice, "This job is already in your saved list.", "success"); return; }
      button.disabled = true;
      try {
        var result = await client.from("saved_jobs").insert({ user_id: user.id, job_id: id });
        if (result.error) throw result.error;
        saved.add(id); button.textContent = "Saved"; button.setAttribute("aria-pressed", "true");
        if (api.showMessage) api.showMessage(notice, "Job saved to your dashboard.", "success");
      } catch (error) {
        if (api.showMessage) api.showMessage(notice, error.message || "Could not save this job.", "error");
        button.disabled = false;
      }
    });
    loadJobs();
    client.auth.getUser().then(async function (result) {
      user = result.data && result.data.user;
      if (!user) return;
      var resultSaved = await client.from("saved_jobs").select("job_id").eq("user_id", user.id);
      (resultSaved.data || []).forEach(function (item) { saved.add(Number(item.job_id)); });
      if (jobs.length) render();
    }).catch(function () { user = null; });
  });
})();

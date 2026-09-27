(function () {
  "use strict";
  var ICONS = { "Design": "proof-reading.svg", "Engineering": "system-analyst.svg", "Data & AI": "testing.svg", "Marketing": "marketing.svg", "Content & Writing": "content-writer.svg", "Sales": "business-development.svg", "Product": "marketing-director.svg" };
  var DEFAULT_CATEGORIES = ["Design", "Engineering", "Data & AI", "Marketing", "Sales", "Content & Writing"];

  document.addEventListener("DOMContentLoaded", async function () {
    var api = window.hireInAI;
    var jobsGrid = document.getElementById("homeJobs"), categoriesGrid = document.getElementById("homeCategories"), companyGrid = document.getElementById("homeCompanyList");
    var esc = api && api.escapeHtml ? api.escapeHtml : function (v) { return String(v == null ? "" : v).replace(/[&<>"']/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]; }); };
    function icon(category) { return "assets/imgs/theme/icons/" + (ICONS[category] || "icon-work.svg"); }
    function renderCategories(counts) {
      var names = Object.keys(counts).sort(function (a, b) { return counts[b] - counts[a] || a.localeCompare(b); });
      DEFAULT_CATEGORIES.forEach(function (name) { if (names.indexOf(name) < 0) names.push(name); });
      categoriesGrid.innerHTML = names.slice(0, 8).map(function (name) {
        var count = counts[name] || 0;
        return "<a class='category-card' href='/jobs.html?category=" + encodeURIComponent(name) + "'><img src='" + icon(name) + "' alt='' loading='lazy'><strong>" + esc(name) + "</strong><span>" + (count ? count + (count === 1 ? " open role" : " open roles") : "Explore roles") + "</span></a>";
      }).join("");
    }
    function emptyJobs(title, text) {
      jobsGrid.innerHTML = "<div class='empty-state'><img src='assets/imgs/theme/icons/icon-job.svg' alt=''><h3>" + title + "</h3><p>" + text + "</p><a class='small-button' href='/resume-ai.html'>Build your resume meanwhile</a></div>";
    }
    if (!api || !api.client || !api.jobs) {
      renderCategories({}); emptyJobs("Jobs are loading slowly", "We couldn't reach the jobs service. Refresh in a moment."); companyGrid.innerHTML = "";
      return;
    }
    var J = api.jobs;
    var result = await J.listPublished("*");
    var jobs = result.error ? [] : result.data || [];
    if (result.error) console.warn("HireIn AI homepage jobs unavailable:", result.error.message);
    var counts = {}, companies = {}, locations = {};
    jobs.forEach(function (job) {
      var category = J.category(job); counts[category] = (counts[category] || 0) + 1;
      var company = String(job.company || "").trim(); if (company) companies[company] = (companies[company] || 0) + 1;
      var loc = String(job.location || "").trim().replace(/\b\w/g, function (c) { return c.toUpperCase(); }); if (loc) locations[loc] = true;
    });
    var stats = { homeOpenJobs: jobs.length, homeCompanies: Object.keys(companies).length, homeRemoteJobs: jobs.filter(function (j) { return J.mode(j) === "Remote"; }).length, homeCategoriesCount: Object.keys(counts).length };
    Object.keys(stats).forEach(function (id) { document.getElementById(id).textContent = result.error ? "—" : String(stats[id]); });
    var select = document.getElementById("homeLocation");
    Object.keys(locations).sort().forEach(function (loc) { var o = document.createElement("option"); o.value = loc; o.textContent = loc; select.appendChild(o); });
    renderCategories(counts);
    if (jobs.length) {
      var featured = jobs.slice().sort(function (a, b) { return Number(b.featured === true) - Number(a.featured === true) || J.posted(b) - J.posted(a); }).slice(0, 6);
      jobsGrid.innerHTML = featured.map(function (job) { return J.card(job, { summary: false }); }).join("");
      document.getElementById("homeJobsTagline").textContent = jobs.length + (jobs.length === 1 ? " live opportunity" : " live opportunities") + " from hiring teams on HireIn AI.";
    } else if (result.error) emptyJobs("Jobs are loading slowly", "We couldn't reach the jobs service. Refresh in a moment.");
    else emptyJobs("New roles are on the way", "Hiring teams are preparing their next openings. Build your resume now so you're ready to apply.");
    var companyNames = Object.keys(companies).sort(function (a, b) { return companies[b] - companies[a] || a.localeCompare(b); }).slice(0, 12);
    companyGrid.innerHTML = companyNames.length ? companyNames.map(function (name) {
      return "<a class='company-chip' href='/jobs.html?company=" + encodeURIComponent(name) + "'><span class='company-initial' aria-hidden='true'>" + esc(name.charAt(0).toUpperCase()) + "</span><span><strong>" + esc(name) + "</strong><small>" + companies[name] + (companies[name] === 1 ? " open role" : " open roles") + "</small></span></a>";
    }).join("") : "<p class='empty'>Companies will appear here as they post roles.</p>";
    try {
      var testimonials = await api.client.from("testimonials").select("person_name,role,company_name,quote").eq("is_approved", true).order("created_at", { ascending: false }).limit(3);
      var rows = testimonials.error ? [] : testimonials.data || [];
      if (rows.length) {
        document.getElementById("homeTestimonialsList").innerHTML = rows.map(function (item) {
          return "<figure class='testimonial-card'><blockquote>“" + esc(item.quote) + "”</blockquote><figcaption><strong>" + esc(item.person_name) + "</strong><span>" + esc([item.role, item.company_name].filter(Boolean).join(" · ")) + "</span></figcaption></figure>";
        }).join("");
        document.getElementById("homeTestimonials").hidden = false;
      }
    } catch (_) { /* Testimonials appear once approved entries exist. */ }
  });
})();

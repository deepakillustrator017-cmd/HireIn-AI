(function () {
  "use strict";
  document.addEventListener("DOMContentLoaded", async function () {
    var api = window.hireInAI;
    if (!api || !api.client) return;
    var client = api.client;
    var escape = api.escapeHtml;
    var searchForm = document.querySelector(".form-find form");
    var searchInput = searchForm && searchForm.querySelector(".input-keysearch");
    var locationInput = searchForm && searchForm.querySelector("select");
    if (searchForm) searchForm.addEventListener("submit", function (event) {
      event.preventDefault();
      var query = searchInput ? searchInput.value.trim() : "";
      var location = locationInput && locationInput.value ? locationInput.options[locationInput.selectedIndex].text : "";
      var params = new URLSearchParams();
      if (query) params.set("q", query);
      if (location && location !== "Location") params.set("location", location);
      window.location.href = "/jobs" + (params.size ? "?" + params.toString() : "");
    });
    document.querySelectorAll(".list-tags-banner a").forEach(function (link) {
      var query = link.textContent.trim();
      if (query) link.href = "/jobs?q=" + encodeURIComponent(query);
    });

    function safeLogo(value) {
      var logo = String(value || "");
      return /^(https?:\/\/|assets\/[\w./-]+$)/i.test(logo) ? escape(logo) : "assets/imgs/theme/jobhub-logo.svg";
    }
    function workMode(job) {
      return job.work_mode || (/remote/i.test(job.location || "") ? "Remote" : "Onsite");
    }
    function companyList(jobs) {
      return Array.from(new Set(jobs.map(function (job) { return String(job.company || "").trim(); }).filter(Boolean)))
        .sort(function (a, b) { return a.localeCompare(b); });
    }
    function renderHomeCard(job) {
      var id = encodeURIComponent(job.id);
      var company = job.company || "Company";
      var posted = job.posted_at || job.created_at;
      var date = posted && !Number.isNaN(new Date(posted).getTime()) ? new Date(posted).toLocaleDateString("en-IN") : "Recently";
      return "<div class='col-lg-4 col-md-6'><article class='card-grid-2 hover-up'><div class='card-block-info'>" +
        "<div class='row align-items-center'><div class='col-8'><div class='card-2-img-text'><span class='card-grid-2-img-small'><img loading='lazy' src='" + safeLogo(job.logo) + "' alt=''></span><span>" + escape(company) + "</span></div></div><div class='col-4 text-end'>" + (job.featured ? "<span class='home-featured-tag'>Featured</span> " : "") + "<span class='btn btn-grey-small disc-btn'>" + escape(job.employment_type || job.type || "Full time") + "</span></div></div>" +
        "<h5 class='mt-20'><a href='/job/" + id + "'>" + escape(job.title || "Open role") + "</a></h5><div class='mt-15'><span class='card-time'>" + escape(date) + "</span><span class='card-location'>" + escape(job.location || workMode(job)) + "</span></div>" +
        "<div class='card-2-bottom mt-30'><div class='row'><div class='col-8'><span class='card-text-price'>" + escape(job.salary || "Salary not listed") + "</span></div><div class='col-4 text-end'><a class='btn btn-border btn-brand-hover' href='/job/" + id + "'>View job</a></div></div></div></div></article></div>";
    }
    function renderCompanies(companies) {
      var wrapper = document.querySelector(".swiper-group-6 .swiper-wrapper");
      if (!wrapper || !companies.length) return;
      wrapper.innerHTML = companies.slice(0, 12).map(function (company) {
        return "<div class='swiper-slide hover-up'><div class='item-logo'><a href='/jobs?company=" + encodeURIComponent(company) + "'><span class='home-company-name'>" + escape(company) + "</span></a></div></div>";
      }).join("");
      if (wrapper.swiper) wrapper.swiper.update();
    }
    function renderTestimonials(rows) {
      var section = document.getElementById("homeTestimonials");
      var grid = document.getElementById("homeTestimonialsList");
      if (!section || !grid || !rows.length) return;
      grid.innerHTML = rows.map(function (item) {
        return "<div class='col-lg-4 col-md-6'><article class='home-testimonial'><p>“" + escape(item.quote) + "”</p><strong>" + escape(item.person_name) + "</strong><span>" + escape([item.role, item.company_name].filter(Boolean).join(" · ")) + "</span></article></div>";
      }).join("");
      section.hidden = false;
    }
    try {
      var response = await client.from("jobs").select("*").in("status", ["published", "active"]).order("posted_at", { ascending: false });
      if (response.error) throw response.error;
      var jobs = response.data || [];
      var companies = companyList(jobs);
      var remote = jobs.filter(function (job) { return String(workMode(job)).toLowerCase() === "remote"; }).length;
      var featured = jobs.filter(function (job) { return job.featured === true; });
      var stats = { homeOpenJobs: jobs.length, homeCompanies: companies.length, homeRemoteJobs: remote, homeFeaturedRoles: featured.length };
      Object.keys(stats).forEach(function (id) { var node = document.getElementById(id); if (node) node.textContent = String(stats[id]); });
      renderCompanies(companies);
      var tabHost = document.querySelector("[data-home-recent-jobs]");
      if (tabHost) {
        var panes = Array.from(tabHost.querySelectorAll(".tab-pane"));
        panes.forEach(function (pane) {
          var navButton = document.querySelector("[data-bs-target='#" + pane.id + "']");
          var category = navButton ? navButton.textContent.trim().toLowerCase() : "";
          var subset = category ? jobs.filter(function (job) { return String(job.category || "").toLowerCase().indexOf(category) >= 0; }) : jobs;
          if (!subset.length) subset = jobs;
          subset = subset.slice().sort(function (a,b) { return Number(b.featured === true) - Number(a.featured === true); });
          var row = pane.querySelector(".row");
          if (row) row.innerHTML = subset.slice(0, 6).map(renderHomeCard).join("") || "<div class='col-12'><p class='empty'>No live opportunities right now. Check back soon.</p></div>";
        });
        var heading = tabHost.closest("section");
        var tagline = heading && heading.querySelector(".row.align-items-end p");
        if (tagline) tagline.textContent = jobs.length + (jobs.length === 1 ? " live opportunity" : " live opportunities") + " from hiring teams.";
      }
    } catch (error) {
      var statIds = ["homeOpenJobs", "homeCompanies", "homeRemoteJobs", "homeFeaturedRoles"];
      statIds.forEach(function (id) { var node = document.getElementById(id); if (node) node.textContent = "—"; });
      console.warn("HireIn AI homepage live data is unavailable:", error.message || error);
    }
    try {
      var testimonials = await client.from("testimonials").select("person_name,role,company_name,quote").eq("is_approved", true).order("created_at", { ascending: false }).limit(3);
      if (!testimonials.error) renderTestimonials(testimonials.data || []);
    } catch (_) { /* Testimonials are optional until verified items are published. */ }
  });
})();

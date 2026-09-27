document.addEventListener("DOMContentLoaded", async function () {
  var api = window.hireInAI;
  var client = api && api.client;
  if (!client) return;

  var notice = document.getElementById("recruiterMessage");
  var content = document.getElementById("recruiterContent");
  var roleWarning = document.getElementById("roleWarning");

  // Authentication check
  var auth = await client.auth.getUser();
  var user = auth.data && auth.data.user;
  if (!user) {
    location.href = "login.html?next=recruiters.html";
    return;
  }

  var profileRes = await api.getProfile(user.id);
  var profile = profileRes.data || {};
  var role = profile.role || "candidate";

  if (role !== "recruiter" && role !== "admin") {
    if (roleWarning) roleWarning.hidden = false;
    api.showMessage(notice, "Recruiter access is required. Your current account role is Candidate.", "error");
    return;
  }

  // Reveal workspace
  if (content) content.hidden = false;
  var welcomeEl = document.getElementById("recruiterWelcome");
  if (welcomeEl) {
    var name = profile.full_name || user.email || "Recruiter";
    welcomeEl.textContent = "Welcome, " + name + ". Manage your published opportunities, review applicants, and track hiring analytics.";
  }

  // Local state
  var state = {
    user: user,
    profile: profile,
    role: role,
    jobs: [],
    applications: [],
    views: [],
    jobSearch: "",
    jobStatusFilter: "all",
    appSearch: "",
    appJobFilter: "all",
    appStatusFilter: "all"
  };

  // Helper: map job status to badge markup
  function getJobStatusBadge(status) {
    var s = String(status || "").toLowerCase();
    if (s === "published" || s === "active") {
      return '<span class="badge badge-active">Active</span>';
    } else if (s === "closed" || s === "paused") {
      return '<span class="badge badge-closed">Closed</span>';
    } else if (s === "draft") {
      return '<span class="badge badge-draft">Draft</span>';
    }
    return '<span class="badge badge-draft">' + api.escapeHtml(status || "Unknown") + '</span>';
  }

  // Helper: map applicant stage to badge markup
  function getAppStatusBadge(status) {
    var s = String(status || "Applied");
    var map = {
      Applied: "badge-applied",
      Reviewing: "badge-reviewing",
      Shortlisted: "badge-shortlisted",
      Interview: "badge-interview",
      Hired: "badge-hired",
      Rejected: "badge-rejected"
    };
    var cls = map[s] || "badge-applied";
    return '<span class="badge ' + cls + '">' + api.escapeHtml(s) + '</span>';
  }

  // 1. Data Loading
  async function loadData() {
    api.showMessage(notice, "Loading recruitment data…", "");

    // Fetch Jobs
    var jobsQuery = client.from("jobs").select("*").order("posted_at", { ascending: false });
    if (role === "recruiter") {
      jobsQuery = jobsQuery.eq("created_by", user.id);
    }
    var jobsRes = await jobsQuery;
    if (jobsRes.error) {
      api.showMessage(notice, "Could not load jobs: " + jobsRes.error.message, "error");
      state.jobs = [];
    } else {
      state.jobs = jobsRes.data || [];
    }

    var ownedJobIds = state.jobs.map(function (j) { return Number(j.id); });

    // Fetch Applications
    var apps = [];
    if (ownedJobIds.length > 0 || role === "admin") {
      var appsQuery = client.from("applications")
        .select("id,job_id,user_id,name,email,phone,portfolio,cover_letter,resume_url,resume_path,status,applied_at,jobs!applications_job_id_fkey(id,title,company,created_by)")
        .order("applied_at", { ascending: false });

      if (role === "recruiter") {
        appsQuery = appsQuery.in("job_id", ownedJobIds);
      }
      var appsRes = await appsQuery;
      if (appsRes.error) {
        // Fallback without relation if FK alias mismatch
        var fallbackQuery = client.from("applications").select("*").order("applied_at", { ascending: false });
        if (role === "recruiter") {
          fallbackQuery = fallbackQuery.in("job_id", ownedJobIds);
        }
        var fbRes = await fallbackQuery;
        if (!fbRes.error) {
          apps = fbRes.data || [];
        }
      } else {
        apps = appsRes.data || [];
      }
    }
    state.applications = apps;

    // Fetch Job Views
    if (ownedJobIds.length > 0) {
      var viewsRes = await client.from("job_views").select("id,job_id,viewed_at").in("job_id", ownedJobIds);
      state.views = viewsRes.data || [];
    } else {
      state.views = [];
    }

    api.showMessage(notice, "", "");
    renderAll();
  }

  // 2. Render Analytics Cards
  function renderAnalytics() {
    var totalJobs = state.jobs.length;
    var activeJobs = state.jobs.filter(function (j) {
      return ["published", "active"].includes(String(j.status || "").toLowerCase());
    }).length;

    var totalViews = state.views.length;
    var totalApps = state.applications.length;
    var shortlisted = state.applications.filter(function (a) {
      return String(a.status || "").toLowerCase() === "shortlisted";
    }).length;

    var conversionRate = totalViews > 0 ? Math.round((totalApps / totalViews) * 100) : 0;
    var shortlistRate = totalApps > 0 ? Math.round((shortlisted / totalApps) * 100) : 0;

    var statActiveEl = document.getElementById("statActiveJobs");
    if (statActiveEl) statActiveEl.textContent = String(activeJobs);

    var statTotalJobsEl = document.getElementById("statTotalJobs");
    if (statTotalJobsEl) statTotalJobsEl.textContent = totalJobs + " total posted";

    var statViewsEl = document.getElementById("statTotalViews");
    if (statViewsEl) statViewsEl.textContent = String(totalViews);

    var statAppsEl = document.getElementById("statTotalApps");
    if (statAppsEl) statAppsEl.textContent = String(totalApps);

    var statConversionEl = document.getElementById("statConversion");
    if (statConversionEl) statConversionEl.textContent = conversionRate + "% view-to-apply";

    var statShortlistedEl = document.getElementById("statShortlisted");
    if (statShortlistedEl) statShortlistedEl.textContent = String(shortlisted);

    var statShortlistRateEl = document.getElementById("statShortlistRate");
    if (statShortlistRateEl) statShortlistRateEl.textContent = shortlistRate + "% of applicants";

    var pipelineTotalEl = document.getElementById("pipelineTotal");
    if (pipelineTotalEl) pipelineTotalEl.textContent = totalApps + " candidate" + (totalApps === 1 ? "" : "s");
  }

  // 3. Render Responsive SVG Charts
  function renderCharts() {
    // Chart 1: Pipeline Breakdown
    var pipelineWrap = document.getElementById("pipelineChartWrap");
    if (pipelineWrap) {
      var stages = [
        { key: "Applied", label: "Applied", color: "#6C3EF4" },
        { key: "Reviewing", label: "Review", color: "#8B5CF6" },
        { key: "Shortlisted", label: "Shortlisted", color: "#7C3AED" },
        { key: "Interview", label: "Interview", color: "#3B82F6" },
        { key: "Hired", label: "Hired", color: "#10B981" },
        { key: "Rejected", label: "Rejected", color: "#EF4444" }
      ];

      var stageCounts = stages.map(function (s) {
        var count = state.applications.filter(function (a) {
          return String(a.status || "").toLowerCase() === s.key.toLowerCase();
        }).length;
        return Object.assign({}, s, { count: count });
      });

      var maxCount = Math.max.apply(null, stageCounts.map(function (s) { return s.count; })) || 1;

      var svgW = 520;
      var svgH = 220;
      var padBottom = 35;
      var padTop = 30;
      var chartH = svgH - padBottom - padTop;
      var barW = 44;
      var gap = (svgW - (stages.length * barW)) / (stages.length + 1);

      var barsSvg = stageCounts.map(function (s, i) {
        var x = gap + i * (barW + gap);
        var bHeight = Math.round((s.count / maxCount) * chartH);
        var minH = s.count > 0 ? Math.max(bHeight, 8) : 3;
        var y = padTop + (chartH - minH);

        return (
          '<g class="chart-bar-group">' +
            '<rect x="' + x + '" y="' + y + '" width="' + barW + '" height="' + minH + '" rx="5" ry="5" fill="' + s.color + '">' +
              '<title>' + api.escapeHtml(s.label) + ': ' + s.count + ' candidates</title>' +
            '</rect>' +
            '<text x="' + (x + barW / 2) + '" y="' + (y - 7) + '" text-anchor="middle" font-size="12" font-weight="700" fill="#111827">' + s.count + '</text>' +
            '<text x="' + (x + barW / 2) + '" y="' + (svgH - 12) + '" text-anchor="middle" font-size="11" font-weight="600" fill="#6B7280">' + api.escapeHtml(s.label) + '</text>' +
          '</g>'
        );
      }).join("");

      var guideLines = [0.25, 0.5, 0.75, 1].map(function (pct) {
        var gy = padTop + chartH * (1 - pct);
        return '<line x1="20" y1="' + gy + '" x2="' + (svgW - 20) + '" y2="' + gy + '" stroke="#F3F0FA" stroke-width="1" stroke-dasharray="3 3" />';
      }).join("");

      pipelineWrap.innerHTML =
        '<svg viewBox="0 0 ' + svgW + ' ' + svgH + '" class="responsive-svg" role="img" aria-label="Candidate pipeline chart">' +
          guideLines +
          barsSvg +
        '</svg>';
    }

    // Chart 2: Job Performance (Views vs Applications)
    var perfWrap = document.getElementById("performanceChartWrap");
    if (perfWrap) {
      if (!state.jobs.length) {
        perfWrap.innerHTML = '<p class="empty" style="margin:auto">No posted jobs to chart. Post a job to track performance.</p>';
        return;
      }

      // Map top 4 jobs with views and apps
      var jobStats = state.jobs.slice(0, 4).map(function (job) {
        var views = state.views.filter(function (v) { return Number(v.job_id) === Number(job.id); }).length;
        var apps = state.applications.filter(function (a) { return Number(a.job_id) === Number(job.id); }).length;
        var title = String(job.title || "Job");
        var shortTitle = title.length > 20 ? title.substring(0, 18) + "…" : title;
        return { id: job.id, title: shortTitle, fullTitle: title, views: views, apps: apps };
      });

      var allVals = [];
      jobStats.forEach(function (j) { allVals.push(j.views, j.apps); });
      var maxVal = Math.max.apply(null, allVals) || 1;

      var svgW2 = 520;
      var svgH2 = 220;
      var rowH = (svgH2 - 20) / jobStats.length;
      var maxBarW = 280;
      var leftOffset = 140;

      var rowsSvg = jobStats.map(function (j, i) {
        var baseY = 15 + i * rowH;
        var viewBarW = Math.max(Math.round((j.views / maxVal) * maxBarW), j.views > 0 ? 6 : 2);
        var appBarW = Math.max(Math.round((j.apps / maxVal) * maxBarW), j.apps > 0 ? 6 : 2);

        var yView = baseY + 8;
        var yApp = baseY + 24;

        return (
          '<g class="job-perf-row">' +
            '<text x="' + (leftOffset - 12) + '" y="' + (baseY + 22) + '" text-anchor="end" font-size="12" font-weight="600" fill="#374151">' +
              '<title>' + api.escapeHtml(j.fullTitle) + '</title>' +
              api.escapeHtml(j.title) +
            '</text>' +
            // Views Bar
            '<rect x="' + leftOffset + '" y="' + yView + '" width="' + viewBarW + '" height="12" rx="4" ry="4" fill="#6C3EF4">' +
              '<title>' + j.views + ' views</title>' +
            '</rect>' +
            '<text x="' + (leftOffset + viewBarW + 6) + '" y="' + (yView + 10) + '" font-size="10" font-weight="700" fill="#6C3EF4">' + j.views + '</text>' +
            // Apps Bar
            '<rect x="' + leftOffset + '" y="' + yApp + '" width="' + appBarW + '" height="12" rx="4" ry="4" fill="#10B981">' +
              '<title>' + j.apps + ' applications</title>' +
            '</rect>' +
            '<text x="' + (leftOffset + appBarW + 6) + '" y="' + (yApp + 10) + '" font-size="10" font-weight="700" fill="#059669">' + j.apps + '</text>' +
          '</g>'
        );
      }).join("");

      perfWrap.innerHTML =
        '<svg viewBox="0 0 ' + svgW2 + ' ' + svgH2 + '" class="responsive-svg" role="img" aria-label="Job performance chart">' +
          rowsSvg +
        '</svg>';
    }
  }

  // 4. Render Jobs Table
  function renderJobsTable() {
    var tbody = document.getElementById("recruiterJobRows");
    if (!tbody) return;

    var filtered = state.jobs.filter(function (job) {
      // Status filter
      var s = String(job.status || "").toLowerCase();
      if (state.jobStatusFilter === "active" && !["published", "active"].includes(s)) return false;
      if (state.jobStatusFilter === "closed" && !["closed", "paused"].includes(s)) return false;
      if (state.jobStatusFilter === "draft" && s !== "draft") return false;

      // Search term
      if (state.jobSearch) {
        var query = state.jobSearch.toLowerCase();
        var matchTitle = String(job.title || "").toLowerCase().includes(query);
        var matchLoc = String(job.location || "").toLowerCase().includes(query);
        var matchCompany = String(job.company || "").toLowerCase().includes(query);
        if (!matchTitle && !matchLoc && !matchCompany) return false;
      }
      return true;
    });

    if (!filtered.length) {
      tbody.innerHTML = '<tr><td colspan="7" class="empty">No matching job postings found.</td></tr>';
      return;
    }

    tbody.innerHTML = filtered.map(function (job) {
      var viewsCount = state.views.filter(function (v) { return Number(v.job_id) === Number(job.id); }).length;
      var appsCount = state.applications.filter(function (a) { return Number(a.job_id) === Number(job.id); }).length;
      var isClosed = ["closed", "paused"].includes(String(job.status || "").toLowerCase());
      var datePosted = job.posted_at || job.created_at;
      var dateStr = datePosted ? new Date(datePosted).toLocaleDateString("en-IN", { day: "numeric", month: "short", year: "numeric" }) : "—";
      var locType = [job.location || "Remote", job.work_mode || job.employment_type || "Full time"].filter(Boolean).join(" · ");

      return (
        '<tr>' +
          '<td>' +
            '<strong><a href="/job-single.html?id=' + encodeURIComponent(job.id) + '" target="_blank" title="View live job">' + api.escapeHtml(job.title || "Untitled Role") + ' ↗</a></strong>' +
            '<div class="muted" style="font-size:12px">' + api.escapeHtml(job.category || "General") + (job.salary ? ' · ' + api.escapeHtml(job.salary) : '') + '</div>' +
          '</td>' +
          '<td>' + api.escapeHtml(locType) + '</td>' +
          '<td>' + getJobStatusBadge(job.status) + '</td>' +
          '<td><strong>' + viewsCount + '</strong></td>' +
          '<td><button type="button" class="text-link" data-filter-job-apps="' + Number(job.id) + '" title="Filter applicant list to this job"><strong>' + appsCount + '</strong></button></td>' +
          '<td>' + api.escapeHtml(dateStr) + '</td>' +
          '<td>' +
            '<div class="action-buttons">' +
              '<a class="small-button secondary-button" href="/post-job.html?edit=' + Number(job.id) + '">Edit</a>' +
              '<button type="button" class="small-button secondary-button" data-toggle-job="' + Number(job.id) + '" data-current="' + api.escapeHtml(job.status || "") + '">' + (isClosed ? 'Reopen' : 'Close') + '</button>' +
              '<button type="button" class="small-button danger" data-delete-job="' + Number(job.id) + '">Delete</button>' +
            '</div>' +
          '</td>' +
        '</tr>'
      );
    }).join("");
  }

  // 5. Render Applicants Table
  function renderApplicantsTable() {
    var tbody = document.getElementById("recruiterApplicantRows");
    if (!tbody) return;

    var filtered = state.applications.filter(function (app) {
      // Job filter
      if (state.appJobFilter !== "all" && Number(app.job_id) !== Number(state.appJobFilter)) {
        return false;
      }
      // Status filter
      if (state.appStatusFilter !== "all" && String(app.status || "").toLowerCase() !== state.appStatusFilter.toLowerCase()) {
        return false;
      }
      // Search term
      if (state.appSearch) {
        var query = state.appSearch.toLowerCase();
        var matchName = String(app.name || "").toLowerCase().includes(query);
        var matchEmail = String(app.email || "").toLowerCase().includes(query);
        var matchPhone = String(app.phone || "").toLowerCase().includes(query);
        if (!matchName && !matchEmail && !matchPhone) return false;
      }
      return true;
    });

    if (!filtered.length) {
      tbody.innerHTML = '<tr><td colspan="6" class="empty">No candidates matching the current filters.</td></tr>';
      return;
    }

    tbody.innerHTML = filtered.map(function (app) {
      var job = state.jobs.find(function (j) { return Number(j.id) === Number(app.job_id); }) || (app.jobs || {});
      var appliedDate = app.applied_at || app.created_at;
      var dateStr = appliedDate ? new Date(appliedDate).toLocaleDateString("en-IN", { day: "numeric", month: "short", year: "numeric" }) : "—";
      var resumePath = app.resume_path || app.resume_url;
      var currentStatus = String(app.status || "Applied");
      var isShortlisted = currentStatus.toLowerCase() === "shortlisted";
      var isRejected = currentStatus.toLowerCase() === "rejected";

      var resumeBtn = resumePath
        ? '<button type="button" class="small-button secondary-button" data-preview-resume="' + Number(app.id) + '">Preview PDF</button>'
        : '<span class="muted">No file</span>';

      return (
        '<tr>' +
          '<td>' +
            '<strong>' + api.escapeHtml(app.name || "Candidate") + '</strong>' +
            '<div class="muted">' + api.escapeHtml(app.email || "—") + (app.phone ? ' · ' + api.escapeHtml(app.phone) : '') + '</div>' +
          '</td>' +
          '<td>' +
            '<strong>' + api.escapeHtml(job.title || "Job #" + app.job_id) + '</strong>' +
            '<div class="muted">' + api.escapeHtml(job.company || "") + '</div>' +
          '</td>' +
          '<td>' + api.escapeHtml(dateStr) + '</td>' +
          '<td>' + resumeBtn + '</td>' +
          '<td>' +
            '<select class="status-select" data-app-status="' + Number(app.id) + '" aria-label="Change stage for ' + api.escapeHtml(app.name || "Candidate") + '">' +
              '<option value="Applied"' + (currentStatus === "Applied" ? " selected" : "") + '>Applied</option>' +
              '<option value="Reviewing"' + (currentStatus === "Reviewing" ? " selected" : "") + '>Reviewing</option>' +
              '<option value="Shortlisted"' + (currentStatus === "Shortlisted" ? " selected" : "") + '>Shortlisted</option>' +
              '<option value="Interview"' + (currentStatus === "Interview" ? " selected" : "") + '>Interview</option>' +
              '<option value="Hired"' + (currentStatus === "Hired" ? " selected" : "") + '>Hired</option>' +
              '<option value="Rejected"' + (currentStatus === "Rejected" ? " selected" : "") + '>Rejected</option>' +
            '</select>' +
          '</td>' +
          '<td>' +
            '<div class="action-buttons">' +
              '<button type="button" class="small-button success-btn" data-action-shortlist="' + Number(app.id) + '" ' + (isShortlisted ? 'disabled style="opacity:0.5"' : '') + '>✓ Shortlist</button>' +
              '<button type="button" class="small-button danger" data-action-reject="' + Number(app.id) + '" ' + (isRejected ? 'disabled style="opacity:0.5"' : '') + '>✕ Reject</button>' +
            '</div>' +
          '</td>' +
        '</tr>'
      );
    }).join("");
  }

  // 6. Populate Applicant Job Filter
  function populateJobFilterOptions() {
    var select = document.getElementById("applicantJobSelect");
    if (!select) return;

    var cur = select.value;
    var html = '<option value="all">All Jobs (' + state.jobs.length + ')</option>';
    html += state.jobs.map(function (j) {
      return '<option value="' + Number(j.id) + '">' + api.escapeHtml(j.title || "Job #" + j.id) + '</option>';
    }).join("");

    select.innerHTML = html;
    select.value = cur || "all";
  }

  function renderAll() {
    renderAnalytics();
    renderCharts();
    populateJobFilterOptions();
    renderJobsTable();
    renderApplicantsTable();
  }

  // 7. Event Delegations

  // Job Actions: Delete, Toggle Status, Filter Applicants
  var jobTable = document.getElementById("recruiterJobRows");
  if (jobTable) {
    jobTable.addEventListener("click", async function (e) {
      // Delete Job
      var delBtn = e.target.closest("[data-delete-job]");
      if (delBtn) {
        var jobId = Number(delBtn.dataset.deleteJob);
        if (!confirm("Are you sure you want to permanently delete this job posting? This cannot be undone.")) return;
        delBtn.disabled = true;
        api.showMessage(notice, "Deleting job posting…", "");

        var res = await client.from("jobs").delete().eq("id", jobId);
        if (res.error) {
          api.showMessage(notice, "Could not delete job: " + res.error.message, "error");
          delBtn.disabled = false;
          return;
        }

        api.showMessage(notice, "Job deleted successfully.", "success");
        state.jobs = state.jobs.filter(function (j) { return Number(j.id) !== jobId; });
        state.applications = state.applications.filter(function (a) { return Number(a.job_id) !== jobId; });
        state.views = state.views.filter(function (v) { return Number(v.job_id) !== jobId; });
        renderAll();
        return;
      }

      // Toggle Job Status (Close / Reopen)
      var toggleBtn = e.target.closest("[data-toggle-job]");
      if (toggleBtn) {
        var jobId = Number(toggleBtn.dataset.toggleJob);
        var current = String(toggleBtn.dataset.current || "").toLowerCase();
        var nextStatus = ["closed", "paused"].includes(current) ? "published" : "closed";

        toggleBtn.disabled = true;
        api.showMessage(notice, "Updating job status to " + nextStatus + "…", "");

        var res = await client.from("jobs").update({ status: nextStatus }).eq("id", jobId);
        if (res.error) {
          api.showMessage(notice, "Could not update status: " + res.error.message, "error");
          toggleBtn.disabled = false;
          return;
        }

        api.showMessage(notice, "Job status marked as " + nextStatus + ".", "success");
        var targetJob = state.jobs.find(function (j) { return Number(j.id) === jobId; });
        if (targetJob) targetJob.status = nextStatus;
        renderAll();
        return;
      }

      // Filter Applicants to this job
      var filterBtn = e.target.closest("[data-filter-job-apps]");
      if (filterBtn) {
        var jobId = Number(filterBtn.dataset.filterJobApps);
        var jobSelect = document.getElementById("applicantJobSelect");
        if (jobSelect) {
          jobSelect.value = String(jobId);
          state.appJobFilter = String(jobId);
          renderApplicantsTable();
          var appSection = document.getElementById("applicantsSection");
          if (appSection) appSection.scrollIntoView({ behavior: "smooth" });
        }
      }
    });
  }

  // Applicant Pipeline: Quick Actions (Shortlist / Reject) and Stage Select
  var appTable = document.getElementById("recruiterApplicantRows");
  if (appTable) {
    // Quick Buttons: Shortlist / Reject
    appTable.addEventListener("click", async function (e) {
      var shortlistBtn = e.target.closest("[data-action-shortlist]");
      var rejectBtn = e.target.closest("[data-action-reject]");
      var previewBtn = e.target.closest("[data-preview-resume]");

      if (shortlistBtn) {
        var appId = Number(shortlistBtn.dataset.actionShortlist);
        await updateApplicantStatus(appId, "Shortlisted");
        return;
      }

      if (rejectBtn) {
        var appId = Number(rejectBtn.dataset.actionReject);
        await updateApplicantStatus(appId, "Rejected");
        return;
      }

      if (previewBtn) {
        var appId = Number(previewBtn.dataset.previewResume);
        var app = state.applications.find(function (a) { return Number(a.id) === appId; });
        if (!app) return;
        await openResumePreview(app);
        return;
      }
    });

    // Dropdown Stage Select Change
    appTable.addEventListener("change", async function (e) {
      var select = e.target.closest("[data-app-status]");
      if (!select) return;
      var appId = Number(select.dataset.appStatus);
      await updateApplicantStatus(appId, select.value);
    });
  }

  // Status Updater
  async function updateApplicantStatus(appId, newStatus) {
    var app = state.applications.find(function (a) { return Number(a.id) === appId; });
    if (!app) return;

    var prevStatus = app.status;
    app.status = newStatus;
    renderAnalytics();
    renderCharts();
    renderApplicantsTable();

    api.showMessage(notice, "Updating candidate stage to " + newStatus + "…", "");
    var res = await client.from("applications").update({ status: newStatus }).eq("id", appId);

    if (res.error) {
      app.status = prevStatus;
      api.showMessage(notice, "Could not update status: " + res.error.message, "error");
      renderAnalytics();
      renderCharts();
      renderApplicantsTable();
    } else {
      api.showMessage(notice, "Candidate " + (app.name || "") + " marked as " + newStatus + ".", "success");
    }
  }

  // Resume Preview Dialog Handler
  var resumeDialog = document.getElementById("resumePreviewDialog");
  var resumeFrame = document.getElementById("resumePreviewFrame");
  var resumeOpenTab = document.getElementById("resumePreviewOpenTab");
  var resumeCloseBtn = document.getElementById("resumePreviewCloseBtn");

  async function openResumePreview(app) {
    if (!resumeDialog || !resumeFrame) return;

    var path = app.resume_path || app.resume_url;
    if (!path) {
      alert("No resume document attached to this application.");
      return;
    }

    var dialogTitle = document.getElementById("resumePreviewDialogTitle");
    if (dialogTitle) dialogTitle.textContent = (app.name || "Candidate") + " — Resume Preview";

    // If it's already a full public HTTP URL
    if (/^https?:\/\//i.test(path)) {
      resumeFrame.src = path;
      if (resumeOpenTab) resumeOpenTab.href = path;
      resumeDialog.showModal();
      return;
    }

    // Generate signed URL from private bucket
    api.showMessage(notice, "Generating secure resume preview link…", "");
    var cleanPath = String(path).replace(/^\/?resumes\//, "");
    var signed = await client.storage.from("resumes").createSignedUrl(cleanPath, 3600);

    if (signed.error || !signed.data || !signed.data.signedUrl) {
      api.showMessage(notice, "Could not access resume: " + (signed.error ? signed.error.message : "File not found"), "error");
      return;
    }

    api.showMessage(notice, "", "");
    resumeFrame.src = signed.data.signedUrl;
    if (resumeOpenTab) resumeOpenTab.href = signed.data.signedUrl;
    resumeDialog.showModal();
  }

  if (resumeCloseBtn) {
    resumeCloseBtn.addEventListener("click", function () {
      if (resumeDialog.open) resumeDialog.close();
    });
  }

  if (resumeDialog) {
    resumeDialog.addEventListener("click", function (e) {
      if (e.target === resumeDialog) resumeDialog.close();
    });
    resumeDialog.addEventListener("close", function () {
      if (resumeFrame) resumeFrame.removeAttribute("src");
      if (resumeOpenTab) resumeOpenTab.removeAttribute("href");
    });
  }

  // 8. Filter & Search Event Listeners

  // Job Search & Status Filter
  var jobSearchInput = document.getElementById("jobSearchInput");
  if (jobSearchInput) {
    jobSearchInput.addEventListener("input", function () {
      state.jobSearch = this.value.trim();
      renderJobsTable();
    });
  }

  var jobStatusFilter = document.getElementById("jobStatusFilter");
  if (jobStatusFilter) {
    jobStatusFilter.addEventListener("change", function () {
      state.jobStatusFilter = this.value;
      renderJobsTable();
    });
  }

  // Applicant Search, Job Select & Status Filter
  var appSearchInput = document.getElementById("applicantSearchInput");
  if (appSearchInput) {
    appSearchInput.addEventListener("input", function () {
      state.appSearch = this.value.trim();
      renderApplicantsTable();
    });
  }

  var appJobSelect = document.getElementById("applicantJobSelect");
  if (appJobSelect) {
    appJobSelect.addEventListener("change", function () {
      state.appJobFilter = this.value;
      renderApplicantsTable();
    });
  }

  var appStatusSelect = document.getElementById("applicantStatusSelect");
  if (appStatusSelect) {
    appStatusSelect.addEventListener("change", function () {
      state.appStatusFilter = this.value;
      renderApplicantsTable();
    });
  }

  // Refresh Dashboard Button
  var refreshBtn = document.getElementById("refreshDashboardBtn");
  if (refreshBtn) {
    refreshBtn.addEventListener("click", function () {
      loadData();
    });
  }

  // Initial Load
  await loadData();
});

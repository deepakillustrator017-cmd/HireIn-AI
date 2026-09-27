document.addEventListener("DOMContentLoaded", async function () {
  var api = window.hireInAI;
  var client = api && api.client;
  if (!client) return;

  var notice = document.getElementById("adminMessage");
  var content = document.getElementById("adminContent");
  var unauthorizedWarning = document.getElementById("unauthorizedWarning");

  // 1. Admin Authentication Guard
  var auth = await client.auth.getUser();
  var user = auth.data && auth.data.user;
  if (!user) {
    location.href = "login.html?next=admin.html";
    return;
  }

  var profileRes = await api.getProfile(user.id);
  var profile = profileRes.data || {};
  var role = profile.role || "candidate";

  if (role !== "admin") {
    if (unauthorizedWarning) unauthorizedWarning.hidden = false;
    api.showMessage(notice, "Access denied. Administrator privileges are required to access this control center.", "error");
    return;
  }

  // Reveal Admin Control Center
  if (content) content.hidden = false;
  var welcomeEl = document.getElementById("adminWelcome");
  if (welcomeEl) {
    var name = profile.full_name || user.email || "Administrator";
    welcomeEl.textContent = "Welcome, " + name + ". Platform governance, user management, recruiter approvals, companies directory, and notifications.";
  }

  // Local State
  var state = {
    user: user,
    profile: profile,
    users: [],
    companies: [],
    jobs: [],
    applications: [],
    atsHistory: [],
    notifications: [],
    hasSuspendedCol: true,
    hasEmailCol: true,
    // Filters
    userSearch: "",
    userRoleFilter: "all",
    userStatusFilter: "all",
    companySearch: "",
    companyApprovalFilter: "all"
  };

  // 2. Data Loader
  async function loadAdminData() {
    api.showMessage(notice, "Loading platform data…", "");

    // A. Fetch Users (Profiles)
    var userSelect = "user_id,full_name,email,role,phone,avatar_url,is_suspended,created_at";
    var usersRes = await client.from("profiles").select(userSelect).order("created_at", { ascending: false });

    if (usersRes.error && api.isMissingColumn(usersRes.error)) {
      state.hasSuspendedCol = false;
      userSelect = "user_id,full_name,email,role,phone,avatar_url,created_at";
      usersRes = await client.from("profiles").select(userSelect).order("created_at", { ascending: false });
    }

    if (usersRes.error && api.isMissingColumn(usersRes.error)) {
      state.hasEmailCol = false;
      userSelect = "user_id,full_name,role,phone,created_at";
      usersRes = await client.from("profiles").select(userSelect).order("created_at", { ascending: false });
    }

    state.users = usersRes.data || [];

    // B. Fetch Companies
    var compRes = await client.from("companies").select("*").order("name");
    state.companies = compRes.data || [];

    // C. Fetch Jobs
    var jobsRes = await client.from("jobs").select("id,title,company,company_id,status,created_by,posted_at,created_at");
    state.jobs = jobsRes.data || [];

    // D. Fetch Applications
    var appsRes = await client.from("applications").select("id,job_id,user_id,status,applied_at");
    state.applications = appsRes.data || [];

    // E. Fetch ATS History
    var atsRes = await client.from("ats_history").select("id,user_id,score,created_at");
    state.atsHistory = atsRes.data || [];

    // F. Fetch Notifications Log
    var notifRes = await client.from("notifications").select("id,user_id,title,body,href,created_at").order("created_at", { ascending: false }).limit(25);
    state.notifications = notifRes.data || [];

    api.showMessage(notice, "", "");
    renderAll();
  }

  // 3. Render Platform KPI Analytics Cards
  function renderAnalyticsCards() {
    var totalUsers = state.users.length;
    var recruiters = state.users.filter(function (u) { return u.role === "recruiter"; }).length;
    var candidates = state.users.filter(function (u) { return u.role === "candidate"; }).length;
    var totalJobs = state.jobs.length;
    var activeJobs = state.jobs.filter(function (j) {
      return ["published", "active"].includes(String(j.status || "").toLowerCase());
    }).length;
    var totalApps = state.applications.length;
    var totalAts = state.atsHistory.length;

    var recruiterPct = totalUsers > 0 ? Math.round((recruiters / totalUsers) * 100) : 0;
    var candidatePct = totalUsers > 0 ? Math.round((candidates / totalUsers) * 100) : 0;

    var elTotalUsers = document.getElementById("statTotalUsers");
    if (elTotalUsers) elTotalUsers.textContent = String(totalUsers);

    var elRecruiters = document.getElementById("statRecruiters");
    if (elRecruiters) elRecruiters.textContent = String(recruiters);

    var elRecruiterPct = document.getElementById("statRecruiterPct");
    if (elRecruiterPct) elRecruiterPct.textContent = recruiterPct + "% of users";

    var elCandidates = document.getElementById("statCandidates");
    if (elCandidates) elCandidates.textContent = String(candidates);

    var elCandidatePct = document.getElementById("statCandidatePct");
    if (elCandidatePct) elCandidatePct.textContent = candidatePct + "% of users";

    var elActiveJobs = document.getElementById("statActiveJobs");
    if (elActiveJobs) elActiveJobs.textContent = String(activeJobs);

    var elTotalJobs = document.getElementById("statTotalJobs");
    if (elTotalJobs) elTotalJobs.textContent = totalJobs + " total posted";

    var elApps = document.getElementById("statApplications");
    if (elApps) elApps.textContent = String(totalApps);

    var elAts = document.getElementById("statAtsReports");
    if (elAts) elAts.textContent = String(totalAts);

    var elChartUsersTotal = document.getElementById("chartUsersTotal");
    if (elChartUsersTotal) elChartUsersTotal.textContent = totalUsers + " registered users";
  }

  // 4. Render Responsive SVG Charts
  function renderCharts() {
    // Chart 1: User Distribution by Role
    var userChartWrap = document.getElementById("userDistributionChart");
    if (userChartWrap) {
      var candidates = state.users.filter(function (u) { return u.role === "candidate"; }).length;
      var recruiters = state.users.filter(function (u) { return u.role === "recruiter"; }).length;
      var admins = state.users.filter(function (u) { return u.role === "admin"; }).length;
      var total = state.users.length || 1;

      var rolesData = [
        { label: "Candidates", count: candidates, color: "#6C3EF4" },
        { label: "Recruiters", count: recruiters, color: "#10B981" },
        { label: "Admins", count: admins, color: "#F59E0B" }
      ];

      var svgW = 500;
      var svgH = 200;
      var barMaxW = 280;
      var startX = 120;

      var rows = rolesData.map(function (item, i) {
        var pct = Math.round((item.count / total) * 100);
        var bW = Math.max(Math.round((item.count / total) * barMaxW), item.count > 0 ? 8 : 2);
        var y = 30 + i * 50;

        return (
          '<g class="chart-row">' +
            '<text x="' + (startX - 12) + '" y="' + (y + 16) + '" text-anchor="end" font-size="13" font-weight="600" fill="#374151">' + item.label + '</text>' +
            '<rect x="' + startX + '" y="' + y + '" width="' + bW + '" height="22" rx="6" ry="6" fill="' + item.color + '">' +
              '<title>' + item.label + ': ' + item.count + ' (' + pct + '%)</title>' +
            '</rect>' +
            '<text x="' + (startX + bW + 10) + '" y="' + (y + 16) + '" font-size="12" font-weight="700" fill="#111827">' + item.count + ' (' + pct + '%)</text>' +
          '</g>'
        );
      }).join("");

      userChartWrap.innerHTML =
        '<svg viewBox="0 0 ' + svgW + ' ' + svgH + '" class="responsive-svg" role="img" aria-label="User role distribution chart">' +
          rows +
        '</svg>';
    }

    // Chart 2: Platform Activity & Volume
    var activityChartWrap = document.getElementById("platformActivityChart");
    if (activityChartWrap) {
      var activeJobsCount = state.jobs.filter(function (j) {
        return ["published", "active"].includes(String(j.status || "").toLowerCase());
      }).length;
      var appsCount = state.applications.length;
      var atsCount = state.atsHistory.length;

      var metrics = [
        { label: "Active Jobs", count: activeJobsCount, color: "#6C3EF4" },
        { label: "Applications", count: appsCount, color: "#8B5CF6" },
        { label: "ATS Checks", count: atsCount, color: "#067647" }
      ];

      var maxM = Math.max.apply(null, metrics.map(function (m) { return m.count; })) || 1;

      var svgW2 = 500;
      var svgH2 = 200;
      var colW = 60;
      var gap = (svgW2 - (metrics.length * colW)) / (metrics.length + 1);
      var chartH = 120;
      var padTop = 30;

      var cols = metrics.map(function (m, i) {
        var x = gap + i * (colW + gap);
        var bH = Math.round((m.count / maxM) * chartH);
        var minH = m.count > 0 ? Math.max(bH, 8) : 3;
        var y = padTop + (chartH - minH);

        return (
          '<g class="activity-col">' +
            '<rect x="' + x + '" y="' + y + '" width="' + colW + '" height="' + minH + '" rx="6" ry="6" fill="' + m.color + '">' +
              '<title>' + m.label + ': ' + m.count + '</title>' +
            '</rect>' +
            '<text x="' + (x + colW / 2) + '" y="' + (y - 8) + '" text-anchor="middle" font-size="13" font-weight="700" fill="#111827">' + m.count + '</text>' +
            '<text x="' + (x + colW / 2) + '" y="' + (padTop + chartH + 22) + '" text-anchor="middle" font-size="12" font-weight="600" fill="#6B7280">' + m.label + '</text>' +
          '</g>'
        );
      }).join("");

      var guideLines2 = [0.5, 1].map(function (pct) {
        var gy = padTop + chartH * (1 - pct);
        return '<line x1="20" y1="' + gy + '" x2="' + (svgW2 - 20) + '" y2="' + gy + '" stroke="#F3F0FA" stroke-width="1" stroke-dasharray="3 3" />';
      }).join("");

      activityChartWrap.innerHTML =
        '<svg viewBox="0 0 ' + svgW2 + ' ' + svgH2 + '" class="responsive-svg" role="img" aria-label="Platform volume chart">' +
          guideLines2 +
          cols +
        '</svg>';
    }
  }

  // 5. Render Recruiter Approvals Table
  function renderRecruiterApprovals() {
    var tbody = document.getElementById("recruiterApprovalRows");
    var badge = document.getElementById("pendingApprovalsBadge");
    if (!tbody) return;

    // Filter companies that are pending approval OR recruiters with unapproved companies
    var pendingCompanies = state.companies.filter(function (c) { return !c.is_approved; });
    if (badge) badge.textContent = pendingCompanies.length + " pending";

    if (!pendingCompanies.length) {
      tbody.innerHTML = '<tr><td colspan="6" class="empty">✓ All recruiter companies are approved and verified. No pending approvals.</td></tr>';
      return;
    }

    tbody.innerHTML = pendingCompanies.map(function (comp) {
      var owner = state.users.find(function (u) { return u.user_id === comp.owner_id; }) || {};
      var ownerName = owner.full_name || "Recruiter Account";
      var ownerEmail = owner.email || "—";
      var websiteLink = comp.website ? '<a href="' + api.escapeHtml(comp.website) + '" target="_blank" rel="noopener">Visit ↗</a>' : '—';

      return (
        '<tr>' +
          '<td><strong>' + api.escapeHtml(ownerName) + '</strong></td>' +
          '<td>' + api.escapeHtml(ownerEmail) + '</td>' +
          '<td>' +
            '<strong>' + api.escapeHtml(comp.name) + '</strong>' +
            (comp.location ? '<div class="muted">' + api.escapeHtml(comp.location) + '</div>' : '') +
          '</td>' +
          '<td>' + websiteLink + '</td>' +
          '<td><span class="badge badge-warning">Pending Approval</span></td>' +
          '<td>' +
            '<div class="action-buttons">' +
              '<button type="button" class="small-button success-btn" data-approve-company="' + api.escapeHtml(comp.id) + '" data-owner="' + api.escapeHtml(comp.owner_id || '') + '">Approve</button>' +
              '<button type="button" class="small-button secondary-button" data-view-company="' + api.escapeHtml(comp.id) + '">Details</button>' +
              '<button type="button" class="small-button danger" data-reject-company="' + api.escapeHtml(comp.id) + '">Reject</button>' +
            '</div>' +
          '</td>' +
        '</tr>'
      );
    }).join("");
  }

  // 6. Render User Management Table
  function renderUserManagement() {
    var tbody = document.getElementById("userManagementRows");
    if (!tbody) return;

    var filtered = state.users.filter(function (u) {
      // Role Filter
      if (state.userRoleFilter !== "all" && u.role !== state.userRoleFilter) {
        return false;
      }
      // Status Filter
      var isSuspended = Boolean(u.is_suspended);
      if (state.userStatusFilter === "active" && isSuspended) return false;
      if (state.userStatusFilter === "suspended" && !isSuspended) return false;

      // Search Query
      if (state.userSearch) {
        var query = state.userSearch.toLowerCase();
        var matchName = String(u.full_name || "").toLowerCase().includes(query);
        var matchEmail = String(u.email || "").toLowerCase().includes(query);
        var matchId = String(u.user_id || "").toLowerCase().includes(query);
        if (!matchName && !matchEmail && !matchId) return false;
      }
      return true;
    });

    if (!filtered.length) {
      tbody.innerHTML = '<tr><td colspan="6" class="empty">No user accounts found matching the current filters.</td></tr>';
      return;
    }

    tbody.innerHTML = filtered.map(function (u) {
      var isSuspended = Boolean(u.is_suspended);
      var isSelf = u.user_id === state.user.id;
      var roleBadge = u.role === "admin" ? '<span class="badge badge-admin">Admin</span>' : u.role === "recruiter" ? '<span class="badge badge-shortlisted">Recruiter</span>' : '<span class="badge badge-draft">Candidate</span>';
      var statusBadge = isSuspended ? '<span class="badge badge-suspended">Suspended</span>' : '<span class="badge badge-active">Active</span>';

      return (
        '<tr>' +
          '<td>' +
            '<strong>' + api.escapeHtml(u.full_name || "Unnamed User") + '</strong>' +
            (u.phone ? '<div class="muted">' + api.escapeHtml(u.phone) + '</div>' : '') +
          '</td>' +
          '<td>' + api.escapeHtml(u.email || "—") + '</td>' +
          '<td><code>' + api.escapeHtml(String(u.user_id).substring(0, 8)) + '…</code></td>' +
          '<td>' +
            (isSelf
              ? roleBadge + ' <small class="muted">(You)</small>'
              : '<select class="status-select" data-user-role-select="' + api.escapeHtml(u.user_id) + '">' +
                  '<option value="candidate"' + (u.role === "candidate" ? " selected" : "") + '>Candidate</option>' +
                  '<option value="recruiter"' + (u.role === "recruiter" ? " selected" : "") + '>Recruiter</option>' +
                  '<option value="admin"' + (u.role === "admin" ? " selected" : "") + '>Admin</option>' +
                '</select>'
            ) +
          '</td>' +
          '<td>' + statusBadge + '</td>' +
          '<td>' +
            (isSelf
              ? '<span class="muted">Active Session</span>'
              : '<button type="button" class="small-button ' + (isSuspended ? 'success-btn' : 'danger') + '" data-toggle-suspend="' + api.escapeHtml(u.user_id) + '" data-suspended="' + isSuspended + '">' +
                  (isSuspended ? 'Activate' : 'Suspend') +
                '</button>'
            ) +
          '</td>' +
        '</tr>'
      );
    }).join("");
  }

  // 7. Render Companies Directory Table
  function renderCompaniesTable() {
    var tbody = document.getElementById("adminCompanyRows");
    if (!tbody) return;

    var filtered = state.companies.filter(function (comp) {
      // Approval Filter
      if (state.companyApprovalFilter === "approved" && !comp.is_approved) return false;
      if (state.companyApprovalFilter === "pending" && comp.is_approved) return false;

      // Search Query
      if (state.companySearch) {
        var query = state.companySearch.toLowerCase();
        var matchName = String(comp.name || "").toLowerCase().includes(query);
        var matchLoc = String(comp.location || "").toLowerCase().includes(query);
        if (!matchName && !matchLoc) return false;
      }
      return true;
    });

    if (!filtered.length) {
      tbody.innerHTML = '<tr><td colspan="6" class="empty">No companies found in directory.</td></tr>';
      return;
    }

    tbody.innerHTML = filtered.map(function (comp) {
      var jobsCount = state.jobs.filter(function (j) {
        return j.company_id === comp.id || String(j.company || "").toLowerCase() === String(comp.name || "").toLowerCase();
      }).length;
      var statusBadge = comp.is_approved
        ? '<span class="badge badge-active">Approved</span>'
        : '<span class="badge badge-warning">Pending Approval</span>';
      var websiteLink = comp.website
        ? '<a href="' + api.escapeHtml(comp.website) + '" target="_blank" rel="noopener">Website ↗</a>'
        : '<span class="muted">—</span>';

      return (
        '<tr>' +
          '<td>' +
            '<strong>' + api.escapeHtml(comp.name) + '</strong>' +
            (comp.description ? '<div class="muted" style="font-size:12px;max-width:240px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">' + api.escapeHtml(comp.description) + '</div>' : '') +
          '</td>' +
          '<td>' + api.escapeHtml(comp.location || "—") + '</td>' +
          '<td>' + websiteLink + '</td>' +
          '<td>' + statusBadge + '</td>' +
          '<td><strong>' + jobsCount + '</strong> jobs</td>' +
          '<td>' +
            '<div class="action-buttons">' +
              '<button type="button" class="small-button secondary-button" data-toggle-company-approval="' + api.escapeHtml(comp.id) + '" data-approved="' + Boolean(comp.is_approved) + '">' +
                (comp.is_approved ? 'Revoke' : 'Approve') +
              '</button>' +
              '<button type="button" class="small-button secondary-button" data-edit-company="' + api.escapeHtml(comp.id) + '">Edit</button>' +
              '<button type="button" class="small-button danger" data-delete-company="' + api.escapeHtml(comp.id) + '">Delete</button>' +
            '</div>' +
          '</td>' +
        '</tr>'
      );
    }).join("");
  }

  // 8. Render Sent Notifications Log Table
  function renderNotificationsLog() {
    var tbody = document.getElementById("sentNotificationRows");
    if (!tbody) return;

    if (!state.notifications.length) {
      tbody.innerHTML = '<tr><td colspan="5" class="empty">No sent notification history found. Use the dispatch form above to send an announcement.</td></tr>';
      return;
    }

    tbody.innerHTML = state.notifications.map(function (n) {
      var recipient = state.users.find(function (u) { return u.user_id === n.user_id; });
      var recipientLabel = recipient ? (recipient.full_name || recipient.email || "User") : String(n.user_id).substring(0, 8) + "…";
      var linkMarkup = n.href ? '<a href="' + api.escapeHtml(n.href) + '" target="_blank">' + api.escapeHtml(n.href) + '</a>' : '<span class="muted">—</span>';
      var dateStr = n.created_at ? new Date(n.created_at).toLocaleDateString("en-IN", { day: "numeric", month: "short", year: "numeric", hour: "2-digit", minute: "2-digit" }) : "—";

      return (
        '<tr>' +
          '<td><strong>' + api.escapeHtml(n.title || "Untitled") + '</strong></td>' +
          '<td><div style="max-width:280px">' + api.escapeHtml(n.body || "") + '</div></td>' +
          '<td>' + api.escapeHtml(recipientLabel) + '</td>' +
          '<td>' + linkMarkup + '</td>' +
          '<td>' + api.escapeHtml(dateStr) + '</td>' +
        '</tr>'
      );
    }).join("");
  }

  function renderAll() {
    renderAnalyticsCards();
    renderCharts();
    renderRecruiterApprovals();
    renderUserManagement();
    renderCompaniesTable();
    renderNotificationsLog();
  }

  // 9. Recruiter Approval Delegations
  var approvalsSection = document.getElementById("approvalsSection");
  if (approvalsSection) {
    approvalsSection.addEventListener("click", async function (e) {
      // Approve Company & Recruiter
      var approveBtn = e.target.closest("[data-approve-company]");
      if (approveBtn) {
        var compId = approveBtn.dataset.approveCompany;
        var ownerId = approveBtn.dataset.owner;
        approveBtn.disabled = true;
        api.showMessage(notice, "Approving company and granting recruiter access…", "");

        var compRes = await client.from("companies").update({ is_approved: true }).eq("id", compId);
        if (compRes.error) {
          api.showMessage(notice, "Could not approve company: " + compRes.error.message, "error");
          approveBtn.disabled = false;
          return;
        }

        // If owner exists and is candidate, elevate to recruiter
        if (ownerId) {
          await client.from("profiles").update({ role: "recruiter" }).eq("user_id", ownerId);
          var ownerProfile = state.users.find(function (u) { return u.user_id === ownerId; });
          if (ownerProfile) ownerProfile.role = "recruiter";
        }

        var targetComp = state.companies.find(function (c) { return c.id === compId; });
        if (targetComp) targetComp.is_approved = true;

        api.showMessage(notice, "Company and recruiter approved successfully.", "success");
        renderAll();
        return;
      }

      // Reject Company
      var rejectBtn = e.target.closest("[data-reject-company]");
      if (rejectBtn) {
        var compId = rejectBtn.dataset.rejectCompany;
        if (!confirm("Are you sure you want to reject this company verification request?")) return;
        rejectBtn.disabled = true;
        api.showMessage(notice, "Rejecting company…", "");

        var compRes = await client.from("companies").update({ is_approved: false }).eq("id", compId);
        if (compRes.error) {
          api.showMessage(notice, "Could not reject: " + compRes.error.message, "error");
          rejectBtn.disabled = false;
          return;
        }

        var targetComp = state.companies.find(function (c) { return c.id === compId; });
        if (targetComp) targetComp.is_approved = false;

        api.showMessage(notice, "Company marked as rejected/unapproved.", "success");
        renderAll();
        return;
      }

      // View Company Info
      var viewBtn = e.target.closest("[data-view-company]");
      if (viewBtn) {
        var compId = viewBtn.dataset.viewCompany;
        var comp = state.companies.find(function (c) { return c.id === compId; });
        if (!comp) return;

        var owner = state.users.find(function (u) { return u.user_id === comp.owner_id; }) || {};
        var infoBody = document.getElementById("companyInfoBody");
        var infoModal = document.getElementById("companyInfoModal");

        if (infoBody && infoModal) {
          infoBody.innerHTML =
            '<div style="display:flex;flex-direction:column;gap:12px">' +
              '<div><strong>Company Name:</strong> ' + api.escapeHtml(comp.name) + '</div>' +
              '<div><strong>Owner Recruiter:</strong> ' + api.escapeHtml(owner.full_name || "Unknown") + ' (' + api.escapeHtml(owner.email || "—") + ')</div>' +
              '<div><strong>Website:</strong> ' + (comp.website ? '<a href="' + api.escapeHtml(comp.website) + '" target="_blank">' + api.escapeHtml(comp.website) + '</a>' : '—') + '</div>' +
              '<div><strong>Location:</strong> ' + api.escapeHtml(comp.location || "Not specified") + '</div>' +
              '<div><strong>Description:</strong> <p style="white-space:pre-line;margin-top:4px">' + api.escapeHtml(comp.description || "No description provided.") + '</p></div>' +
              '<div><strong>Status:</strong> ' + (comp.is_approved ? '<span class="badge badge-active">Approved</span>' : '<span class="badge badge-warning">Pending Approval</span>') + '</div>' +
            '</div>';
          infoModal.showModal();
        }
      }
    });
  }

  // Close Company Info Modal
  var closeInfoBtn = document.getElementById("closeCompanyInfoBtn");
  var companyInfoModal = document.getElementById("companyInfoModal");
  if (closeInfoBtn && companyInfoModal) {
    closeInfoBtn.addEventListener("click", function () {
      if (companyInfoModal.open) companyInfoModal.close();
    });
    companyInfoModal.addEventListener("click", function (e) {
      if (e.target === companyInfoModal) companyInfoModal.close();
    });
  }

  // 10. User Management Delegations (Role Update & Suspend/Activate)
  var userTable = document.getElementById("userManagementRows");
  if (userTable) {
    // Change User Role
    userTable.addEventListener("change", async function (e) {
      var select = e.target.closest("[data-user-role-select]");
      if (!select) return;

      var targetUserId = select.dataset.userRoleSelect;
      var newRole = select.value;

      select.disabled = true;
      api.showMessage(notice, "Updating account role to " + newRole + "…", "");

      var updateRes = await client.from("profiles").update({ role: newRole }).eq("user_id", targetUserId);
      if (updateRes.error) {
        api.showMessage(notice, "Could not update role: " + updateRes.error.message, "error");
        select.disabled = false;
        return;
      }

      var targetUser = state.users.find(function (u) { return u.user_id === targetUserId; });
      if (targetUser) targetUser.role = newRole;

      select.disabled = false;
      api.showMessage(notice, "Account role updated to " + newRole + " successfully.", "success");
      renderAnalyticsCards();
      renderCharts();
    });

    // Toggle Suspend / Activate User
    userTable.addEventListener("click", async function (e) {
      var suspendBtn = e.target.closest("[data-toggle-suspend]");
      if (!suspendBtn) return;

      var targetUserId = suspendBtn.dataset.toggleSuspend;
      var currentlySuspended = suspendBtn.dataset.suspended === "true";
      var nextSuspended = !currentlySuspended;

      suspendBtn.disabled = true;
      api.showMessage(notice, (nextSuspended ? "Suspending" : "Activating") + " account…", "");

      var updateRes = await client.from("profiles").update({ is_suspended: nextSuspended }).eq("user_id", targetUserId);
      if (updateRes.error) {
        if (api.isMissingColumn(updateRes.error)) {
          // Schema does not yet have is_suspended column in live database
          api.showMessage(notice, "Note: Run the updated schema migration to store the is_suspended column in Supabase.", "error");
        } else {
          api.showMessage(notice, "Could not update status: " + updateRes.error.message, "error");
          suspendBtn.disabled = false;
          return;
        }
      }

      var targetUser = state.users.find(function (u) { return u.user_id === targetUserId; });
      if (targetUser) targetUser.is_suspended = nextSuspended;

      api.showMessage(notice, "Account successfully " + (nextSuspended ? "suspended" : "activated") + ".", "success");
      renderUserManagement();
    });
  }

  // 11. Companies CRUD Delegations & Modal Management
  var companyModal = document.getElementById("companyModal");
  var companyForm = document.getElementById("companyForm");
  var companyModalTitle = document.getElementById("companyModalTitle");
  var openCreateBtn1 = document.getElementById("openCreateCompanyBtn");
  var openCreateBtn2 = document.getElementById("createCompanyBtn");
  var closeCompanyModalBtn = document.getElementById("closeCompanyModalBtn");
  var cancelCompanyBtn = document.getElementById("cancelCompanyBtn");

  function openCompanyModal(company) {
    if (!companyModal || !companyForm) return;
    companyForm.reset();

    if (company) {
      // Edit mode
      companyModalTitle.textContent = "Edit Company — " + (company.name || "");
      companyForm.elements.id.value = company.id || "";
      companyForm.elements.name.value = company.name || "";
      companyForm.elements.website.value = company.website || "";
      companyForm.elements.location.value = company.location || "";
      companyForm.elements.logo_url.value = company.logo_url || "";
      companyForm.elements.description.value = company.description || "";
      companyForm.elements.is_approved.checked = Boolean(company.is_approved);
    } else {
      // Create mode
      companyModalTitle.textContent = "Create New Company";
      companyForm.elements.id.value = "";
      companyForm.elements.is_approved.checked = true; // Admins default to approved
    }
    companyModal.showModal();
  }

  if (openCreateBtn1) openCreateBtn1.addEventListener("click", function () { openCompanyModal(null); });
  if (openCreateBtn2) openCreateBtn2.addEventListener("click", function () { openCompanyModal(null); });
  if (closeCompanyModalBtn) closeCompanyModalBtn.addEventListener("click", function () { companyModal.close(); });
  if (cancelCompanyBtn) cancelCompanyBtn.addEventListener("click", function () { companyModal.close(); });
  if (companyModal) {
    companyModal.addEventListener("click", function (e) {
      if (e.target === companyModal) companyModal.close();
    });
  }

  // Save Company Form Submit
  if (companyForm) {
    companyForm.addEventListener("submit", async function (e) {
      e.preventDefault();
      var formData = new FormData(companyForm);
      var editId = formData.get("id");
      var name = String(formData.get("name") || "").trim();
      var website = String(formData.get("website") || "").trim();
      var loc = String(formData.get("location") || "").trim();
      var logo = String(formData.get("logo_url") || "").trim();
      var desc = String(formData.get("description") || "").trim();
      var isApproved = companyForm.elements.is_approved.checked;

      if (!name) {
        alert("Company name is required.");
        return;
      }

      var saveBtn = document.getElementById("saveCompanyBtn");
      if (saveBtn) saveBtn.disabled = true;

      var payload = {
        name: name,
        website: website || null,
        location: loc || null,
        logo_url: logo || null,
        description: desc,
        is_approved: isApproved
      };

      if (editId) {
        // UPDATE Company
        api.showMessage(notice, "Saving company updates…", "");
        var updRes = await client.from("companies").update(payload).eq("id", editId).select().single();
        if (updRes.error) {
          api.showMessage(notice, "Could not update company: " + updRes.error.message, "error");
          if (saveBtn) saveBtn.disabled = false;
          return;
        }

        var idx = state.companies.findIndex(function (c) { return c.id === editId; });
        if (idx !== -1) state.companies[idx] = updRes.data;
        api.showMessage(notice, "Company updated successfully.", "success");
      } else {
        // CREATE Company
        api.showMessage(notice, "Creating company…", "");
        payload.owner_id = state.user.id;
        var insRes = await client.from("companies").insert(payload).select().single();
        if (insRes.error) {
          api.showMessage(notice, "Could not create company: " + insRes.error.message, "error");
          if (saveBtn) saveBtn.disabled = false;
          return;
        }

        state.companies.unshift(insRes.data);
        api.showMessage(notice, "Company created successfully.", "success");
      }

      if (saveBtn) saveBtn.disabled = false;
      companyModal.close();
      renderAll();
    });
  }

  // Companies Table Actions: Approve/Revoke, Edit, Delete
  var compTable = document.getElementById("adminCompanyRows");
  if (compTable) {
    compTable.addEventListener("click", async function (e) {
      // Toggle Approval
      var toggleApproveBtn = e.target.closest("[data-toggle-company-approval]");
      if (toggleApproveBtn) {
        var compId = toggleApproveBtn.dataset.toggleCompanyApproval;
        var currentlyApproved = toggleApproveBtn.dataset.approved === "true";
        var nextApproved = !currentlyApproved;

        toggleApproveBtn.disabled = true;
        api.showMessage(notice, (nextApproved ? "Approving" : "Revoking approval for") + " company…", "");

        var res = await client.from("companies").update({ is_approved: nextApproved }).eq("id", compId);
        if (res.error) {
          api.showMessage(notice, "Could not update company approval: " + res.error.message, "error");
          toggleApproveBtn.disabled = false;
          return;
        }

        var targetComp = state.companies.find(function (c) { return c.id === compId; });
        if (targetComp) targetComp.is_approved = nextApproved;

        api.showMessage(notice, "Company " + (nextApproved ? "approved" : "approval revoked") + ".", "success");
        renderAll();
        return;
      }

      // Edit Company
      var editBtn = e.target.closest("[data-edit-company]");
      if (editBtn) {
        var compId = editBtn.dataset.editCompany;
        var comp = state.companies.find(function (c) { return c.id === compId; });
        if (comp) openCompanyModal(comp);
        return;
      }

      // Delete Company
      var delBtn = e.target.closest("[data-delete-company]");
      if (delBtn) {
        var compId = delBtn.dataset.deleteCompany;
        if (!confirm("Are you sure you want to permanently delete this company? Associated jobs will retain their text company name.")) return;

        delBtn.disabled = true;
        api.showMessage(notice, "Deleting company…", "");

        var delRes = await client.from("companies").delete().eq("id", compId);
        if (delRes.error) {
          api.showMessage(notice, "Could not delete company: " + delRes.error.message, "error");
          delBtn.disabled = false;
          return;
        }

        state.companies = state.companies.filter(function (c) { return c.id !== compId; });
        api.showMessage(notice, "Company deleted.", "success");
        renderAll();
        return;
      }
    });
  }

  // 12. Notifications System
  var notifForm = document.getElementById("notificationForm");
  var audienceSelect = document.getElementById("notifyAudience");
  var singleUserField = document.getElementById("singleUserField");

  if (audienceSelect && singleUserField) {
    audienceSelect.addEventListener("change", function () {
      singleUserField.hidden = this.value !== "single";
    });
  }

  if (notifForm) {
    notifForm.addEventListener("submit", async function (e) {
      e.preventDefault();
      var formData = new FormData(notifForm);
      var audience = formData.get("audience");
      var title = String(formData.get("title") || "").trim();
      var body = String(formData.get("body") || "").trim();
      var href = String(formData.get("href") || "").trim();
      var singleUserId = String(formData.get("user_id") || "").trim();

      if (!title || !body) {
        alert("Title and message body are required.");
        return;
      }

      // Determine target user IDs
      var targetUserIds = [];
      if (audience === "all") {
        targetUserIds = state.users.map(function (u) { return u.user_id; });
      } else if (audience === "recruiter") {
        targetUserIds = state.users.filter(function (u) { return u.role === "recruiter"; }).map(function (u) { return u.user_id; });
      } else if (audience === "candidate") {
        targetUserIds = state.users.filter(function (u) { return u.role === "candidate"; }).map(function (u) { return u.user_id; });
      } else if (audience === "single") {
        if (!singleUserId) {
          alert("Please enter a recipient User ID.");
          return;
        }
        targetUserIds = [singleUserId];
      }

      if (!targetUserIds.length) {
        alert("No recipient users found for selected audience.");
        return;
      }

      var sendBtn = document.getElementById("sendNotificationBtn");
      if (sendBtn) sendBtn.disabled = true;

      api.showMessage(notice, "Dispatching notification to " + targetUserIds.length + " user(s)…", "");

      // Prepare batch payloads
      var rows = targetUserIds.map(function (uid) {
        return {
          user_id: uid,
          title: title,
          body: body,
          href: href || null
        };
      });

      var insertRes = await client.from("notifications").insert(rows).select();
      if (insertRes.error) {
        api.showMessage(notice, "Could not send notification: " + insertRes.error.message, "error");
        if (sendBtn) sendBtn.disabled = false;
        return;
      }

      // Add to local sent notifications list
      var inserted = insertRes.data || rows;
      state.notifications = inserted.concat(state.notifications).slice(0, 30);

      notifForm.reset();
      if (singleUserField) singleUserField.hidden = true;
      if (sendBtn) sendBtn.disabled = false;

      api.showMessage(notice, "Notification successfully dispatched to " + targetUserIds.length + " user(s).", "success");
      renderNotificationsLog();
    });
  }

  // 13. Search & Filter Handlers

  // User Search & Filters
  var userSearchInput = document.getElementById("userSearchInput");
  if (userSearchInput) {
    userSearchInput.addEventListener("input", function () {
      state.userSearch = this.value.trim();
      renderUserManagement();
    });
  }

  var userRoleFilter = document.getElementById("userRoleFilter");
  if (userRoleFilter) {
    userRoleFilter.addEventListener("change", function () {
      state.userRoleFilter = this.value;
      renderUserManagement();
    });
  }

  var userStatusFilter = document.getElementById("userStatusFilter");
  if (userStatusFilter) {
    userStatusFilter.addEventListener("change", function () {
      state.userStatusFilter = this.value;
      renderUserManagement();
    });
  }

  // Company Search & Filter
  var companySearchInput = document.getElementById("companySearchInput");
  if (companySearchInput) {
    companySearchInput.addEventListener("input", function () {
      state.companySearch = this.value.trim();
      renderCompaniesTable();
    });
  }

  var companyApprovalFilter = document.getElementById("companyApprovalFilter");
  if (companyApprovalFilter) {
    companyApprovalFilter.addEventListener("change", function () {
      state.companyApprovalFilter = this.value;
      renderCompaniesTable();
    });
  }

  // Refresh Button
  var refreshBtn = document.getElementById("refreshAdminBtn");
  if (refreshBtn) {
    refreshBtn.addEventListener("click", function () {
      loadAdminData();
    });
  }

  // Initial Load
  await loadAdminData();
});

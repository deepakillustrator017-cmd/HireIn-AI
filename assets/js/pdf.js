(function () {
  "use strict";
  /*
   * HireIn AI resume PDF renderer.
   * Draws the resume with jsPDF's vector text API: A4, selectable/searchable text, embedded
   * (subset) TrueType fonts, clickable links and multi-page flow. No canvas screenshots are used;
   * a canvas is only used to crop the optional profile photo.
   */
  var MM = 0.352778, W = 210, H = 297, M = 16, LINE = 1.38;
  var FONT_BASE = (function () {
    try { return new URL("../fonts/resume/", (document.currentScript && document.currentScript.src) || location.href).href; }
    catch (e) { return "/assets/fonts/resume/"; }
  })();
  var FONTS = {
    sans: { name: "HireInSans", fallback: "helvetica", normal: "Poppins-Regular.ttf", bold: "Poppins-SemiBold.ttf" },
    serif: { name: "HireInSerif", fallback: "times", normal: "CrimsonText-Regular.ttf", bold: "CrimsonText-Bold.ttf" }
  };
  var THEMES = {
    modern: { label: "Modern", font: "sans", layout: "band", accent: [108, 62, 244], ink: [32, 37, 54], muted: [100, 106, 120], rule: [228, 224, 242] },
    minimal: { label: "Minimal", font: "sans", layout: "plain", accent: [55, 65, 81], ink: [17, 24, 39], muted: [107, 114, 128], rule: [209, 213, 219] },
    executive: { label: "Executive", font: "serif", layout: "centered", accent: [31, 41, 55], ink: [17, 24, 39], muted: [75, 85, 99], rule: [31, 41, 55] },
    creative: { label: "Creative", font: "sans", layout: "sidebar", accent: [108, 62, 244], ink: [32, 37, 54], muted: [100, 106, 120], rule: [221, 214, 254], side: [243, 239, 255], sideWidth: 70 }
  };
  var fontCache = {};

  function toBase64(buffer) {
    var bytes = new Uint8Array(buffer), chunks = [];
    for (var i = 0; i < bytes.length; i += 0x8000) chunks.push(String.fromCharCode.apply(null, bytes.subarray(i, i + 0x8000)));
    return btoa(chunks.join(""));
  }
  function fetchFont(file) {
    if (!fontCache[file]) {
      fontCache[file] = fetch(FONT_BASE + file).then(function (response) {
        if (!response.ok) throw new Error("Font " + file + " returned " + response.status);
        return response.arrayBuffer();
      }).then(toBase64);
      fontCache[file].catch(function () { delete fontCache[file]; });
    }
    return fontCache[file];
  }
  function registerFont(doc, family) {
    var spec = FONTS[family];
    return Promise.all([fetchFont(spec.normal), fetchFont(spec.bold)]).then(function (files) {
      doc.addFileToVFS(spec.normal, files[0]); doc.addFont(spec.normal, spec.name, "normal");
      doc.addFileToVFS(spec.bold, files[1]); doc.addFont(spec.bold, spec.name, "bold");
      return { name: spec.name, embedded: true };
    }).catch(function () { return { name: spec.fallback, embedded: false }; });
  }

  function clean(value) { return String(value == null ? "" : value).replace(/[\u0000-\u0008\u000B-\u001F\u007F]/g, " ").replace(/\t/g, " ").trim(); }
  function oneLine(value) { return clean(value).replace(/\s+/g, " "); }
  function bulletLines(text) { return clean(text).split(/\n+/).map(function (line) { return line.replace(/^\s*(?:[-*•·▪◦>]|\d+[.)])\s*/, "").trim(); }).filter(Boolean); }
  function displayUrl(url) { return oneLine(url).replace(/^https?:\/\//i, "").replace(/^www\./i, "").replace(/\/$/, ""); }
  function href(url) {
    url = oneLine(url);
    if (!url) return "";
    if (/^(https?:|mailto:|tel:)/i.test(url)) return url;
    if (/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(url)) return "mailto:" + url;
    return /^[\w.-]+\.[a-z]{2,}(\/|$)/i.test(url) ? "https://" + url : "";
  }
  function contactItems(d) {
    var items = [];
    if (d.email) items.push({ text: oneLine(d.email), url: "mailto:" + oneLine(d.email), label: "Email" });
    if (d.phone) items.push({ text: oneLine(d.phone), url: "tel:" + oneLine(d.phone).replace(/[^\d+]/g, ""), label: "Phone" });
    if (d.location) items.push({ text: oneLine(d.location), label: "Location" });
    if (d.portfolio) items.push({ text: displayUrl(d.portfolio), url: href(d.portfolio), label: "Portfolio" });
    if (d.linkedin) items.push({ text: displayUrl(d.linkedin), url: href(d.linkedin), label: "LinkedIn" });
    return items;
  }
  function circlePhoto(src, px) {
    return new Promise(function (resolve, reject) {
      var img = new Image();
      img.onload = function () {
        var canvas = document.createElement("canvas"), g = canvas.getContext("2d"), side = Math.min(img.naturalWidth, img.naturalHeight);
        canvas.width = canvas.height = px;
        g.beginPath(); g.arc(px / 2, px / 2, px / 2, 0, Math.PI * 2); g.closePath(); g.clip();
        g.drawImage(img, (img.naturalWidth - side) / 2, (img.naturalHeight - side) / 2, side, side, 0, 0, px, px);
        resolve(canvas.toDataURL("image/png"));
      };
      img.onerror = function () { reject(new Error("The profile photo could not be read.")); };
      img.src = src;
    });
  }

  function Layout(doc, theme, font) {
    this.doc = doc; this.theme = theme; this.font = font;
    this.decorate(1);
  }
  Layout.prototype.decorate = function (page) {
    if (!this.theme.side) return;
    this.doc.setPage(page); this.doc.setFillColor.apply(this.doc, this.theme.side); this.doc.rect(0, 0, this.theme.sideWidth, H, "F");
  };
  Layout.prototype.goto = function (page) {
    while (this.doc.getNumberOfPages() < page) { this.doc.addPage("a4", "portrait"); this.decorate(this.doc.getNumberOfPages()); }
    this.doc.setPage(page);
  };
  Layout.prototype.ensure = function (col, height) {
    if (col.y + height > col.bottom && col.y > col.top + 0.5) { col.page += 1; col.y = col.top; }
    this.goto(col.page);
  };
  Layout.prototype.style = function (size, bold, color) {
    this.doc.setFont(this.font, bold ? "bold" : "normal"); this.doc.setFontSize(size); this.doc.setTextColor.apply(this.doc, color || this.theme.ink);
  };
  Layout.prototype.lh = function (size, factor) { return size * MM * (factor || LINE); };
  Layout.prototype.paragraph = function (col, text, o) {
    o = o || {}; text = clean(text); if (!text) return;
    var size = o.size || 9.5, lh = this.lh(size, o.factor), indent = o.indent || 0;
    this.style(size, o.bold, o.color);
    var lines = this.doc.splitTextToSize(text, col.w - indent);
    for (var i = 0; i < lines.length; i++) {
      this.ensure(col, lh); this.style(size, o.bold, o.color);
      var x = o.align === "center" ? col.x + col.w / 2 : o.align === "right" ? col.x + col.w : col.x + indent;
      if (o.url) this.doc.textWithLink(lines[i], x, col.y + lh * 0.74, { url: o.url, align: o.align });
      else this.doc.text(lines[i], x, col.y + lh * 0.74, o.align ? { align: o.align } : undefined);
      col.y += lh;
    }
    col.y += o.after || 0;
  };
  Layout.prototype.bullets = function (col, items, o) {
    o = o || {}; var size = o.size || 9.5, lh = this.lh(size), indent = 4.2;
    items.forEach(function (item) {
      this.style(size, false, o.color);
      var lines = this.doc.splitTextToSize(item, col.w - indent);
      lines.forEach(function (line, i) {
        this.ensure(col, lh); this.style(size, false, o.color);
        if (i === 0) { this.doc.setTextColor.apply(this.doc, this.theme.accent); this.doc.text("•", col.x + 0.6, col.y + lh * 0.74); this.doc.setTextColor.apply(this.doc, o.color || this.theme.ink); }
        this.doc.text(line, col.x + indent, col.y + lh * 0.74); col.y += lh;
      }, this);
      col.y += 0.5;
    }, this);
  };
  Layout.prototype.details = function (col, text, o) {
    var lines = bulletLines(text);
    if (lines.length > 1 || /^\s*(?:[-*•·▪◦]|\d+[.)])/.test(clean(text))) this.bullets(col, lines, o);
    else if (lines.length) this.paragraph(col, lines[0], o);
  };
  Layout.prototype.heading = function (col, title, o) {
    o = o || {}; var t = this.theme, doc = this.doc, layout = o.side ? "side" : t.layout;
    var size = layout === "centered" ? 12 : layout === "side" ? 9.5 : layout === "plain" ? 9.5 : 10.5, lh = this.lh(size, 1.2);
    col.y += o.first ? 0 : (layout === "side" ? 4 : 4.5);
    this.ensure(col, lh + 3 + this.lh(9.5) * 1.6);
    if (layout === "sidebar") { doc.setFillColor.apply(doc, t.accent); doc.rect(col.x, col.y + 0.6, 1.8, lh - 1.2, "F"); }
    this.style(size, true, layout === "plain" ? t.muted : t.accent);
    doc.text(title.toUpperCase(), col.x + (layout === "sidebar" ? 4 : 0), col.y + lh * 0.78);
    col.y += lh + 1;
    doc.setDrawColor.apply(doc, t.rule);
    if (layout === "band") { doc.setLineWidth(0.25); doc.line(col.x, col.y, col.x + col.w, col.y); doc.setDrawColor.apply(doc, t.accent); doc.setLineWidth(0.8); doc.line(col.x, col.y, col.x + 12, col.y); }
    else if (layout === "centered") { doc.setLineWidth(0.45); doc.line(col.x, col.y, col.x + col.w, col.y); }
    else if (layout !== "sidebar") { doc.setLineWidth(0.2); doc.line(col.x, col.y, col.x + col.w, col.y); }
    col.y += layout === "sidebar" ? 1.2 : 2.6;
  };
  Layout.prototype.entry = function (col, e) {
    var t = this.theme, doc = this.doc, titleSize = 10.5, lhT = this.lh(titleSize), dates = oneLine(e.dates);
    // Keep short entries on one page; long ones may split after their first bullet.
    this.style(9.5, false); var body = 0;
    bulletLines(e.details).forEach(function (line) { body += doc.splitTextToSize(line, col.w - 4.2).length * this.lh(9.5) + 0.5; }, this);
    var full = lhT + (e.subtitle ? this.lh(9.2) : 0) + (e.link ? this.lh(8.6) : 0) + 0.8 + body;
    this.ensure(col, full <= 55 ? full : lhT + this.lh(9.2) + this.lh(9.5) * 2);
    this.style(9, false, t.muted);
    var dateW = dates ? doc.getTextWidth(dates) + 4 : 0;
    this.style(titleSize, true, t.ink);
    var titleLines = doc.splitTextToSize(oneLine(e.title) || " ", Math.max(30, col.w - dateW));
    if (dates) { this.style(9, false, t.muted); doc.text(dates, col.x + col.w, col.y + lhT * 0.74, { align: "right" }); }
    this.style(titleSize, true, t.ink);
    titleLines.forEach(function (line) { this.ensure(col, lhT); this.style(titleSize, true, t.ink); doc.text(line, col.x, col.y + lhT * 0.74); col.y += lhT; }, this);
    if (e.subtitle) this.paragraph(col, e.subtitle, { size: 9.2, color: t.layout === "centered" || t.layout === "plain" ? t.muted : t.accent });
    if (e.link) this.paragraph(col, displayUrl(e.link), { size: 8.6, color: t.muted, url: href(e.link) || undefined });
    col.y += 0.8;
    if (e.details) this.details(col, e.details, { color: t.ink });
    col.y += 2.4;
  };
  Layout.prototype.inline = function (col, items, o) {
    var doc = this.doc, size = o.size || 8.6, lh = this.lh(size), sep = o.separator || "   |   ", rows = [[]], widths = [0];
    this.style(size, false, o.color);
    var sepW = doc.getTextWidth(sep);
    items.forEach(function (item) {
      var w = doc.getTextWidth(item.text), row = rows.length - 1, extra = rows[row].length ? sepW : 0;
      if (rows[row].length && widths[row] + extra + w > col.w) { rows.push([]); widths.push(0); row++; extra = 0; }
      rows[row].push(item); widths[row] += extra + w;
    });
    rows.forEach(function (row, r) {
      if (!row.length) return;
      this.ensure(col, lh);
      var x = o.align === "center" ? col.x + (col.w - widths[r]) / 2 : col.x, y = col.y + lh * 0.74;
      row.forEach(function (item, i) {
        if (i) { this.style(size, false, o.sepColor || o.color); doc.text(sep, x, y); x += sepW; }
        this.style(size, false, o.color);
        if (item.url) doc.textWithLink(item.text, x, y, { url: item.url }); else doc.text(item.text, x, y);
        x += doc.getTextWidth(item.text);
      }, this);
      col.y += lh;
    }, this);
  };
  Layout.prototype.chips = function (col, items) {
    var doc = this.doc, t = this.theme, size = 8.4, h = 5.6, gap = 1.6, x = col.x;
    this.style(size, false, t.ink);
    this.ensure(col, h + gap);
    items.forEach(function (text) {
      this.style(size, false, t.ink);
      var w = Math.min(col.w, doc.getTextWidth(text) + 4.4);
      if (x > col.x && x + w > col.x + col.w) { x = col.x; col.y += h + gap; this.ensure(col, h + gap); this.style(size, false, t.ink); }
      doc.setFillColor(255, 255, 255); doc.setDrawColor.apply(doc, t.rule); doc.setLineWidth(0.2);
      doc.roundedRect(x, col.y, w, h, 1.6, 1.6, "FD");
      doc.text(doc.splitTextToSize(text, w - 3)[0], x + 2.2, col.y + h / 2 + size * MM * 0.35);
      x += w + gap;
    }, this);
    col.y += h + gap;
  };

  function sectionsFor(d) {
    return {
      summary: clean(d.summary),
      experience: (d.experience || []).filter(function (x) { return x.role || x.organization || x.details; }),
      projects: (d.projects || []).filter(function (x) { return x.name || x.details; }),
      education: (d.education || []).filter(function (x) { return x.qualification || x.organization; }),
      skills: (d.skills || []).map(oneLine).filter(Boolean),
      certifications: (d.certifications || d.certificates || []).filter(function (x) { return x.name; }),
      languages: (d.languages || []).filter(function (x) { return x.name; }),
      links: (d.links || []).filter(function (x) { return x.url || x.name; })
    };
  }
  function join(parts, sep) { return parts.map(oneLine).filter(Boolean).join(sep || "  ·  "); }

  function mainSections(L, col, s, first) {
    var h = function (title) { L.heading(col, title, { first: first }); first = false; };
    if (s.summary) { h("Summary"); L.paragraph(col, s.summary, { color: L.theme.ink }); }
    if (s.experience.length) { h("Experience"); s.experience.forEach(function (x) { L.entry(col, { title: x.role || x.organization, subtitle: x.role ? x.organization : "", dates: x.dates, details: x.details }); }); }
    if (s.projects.length) { h("Projects"); s.projects.forEach(function (x) { L.entry(col, { title: x.name, link: x.link, details: x.details }); }); }
    if (s.education.length) { h("Education"); s.education.forEach(function (x) { L.entry(col, { title: x.qualification || x.organization, subtitle: x.qualification ? x.organization : "", dates: x.dates, details: x.details }); }); }
    return first;
  }
  function extraSections(L, col, s, first) {
    var t = L.theme, h = function (title) { L.heading(col, title, { first: first }); first = false; };
    if (s.skills.length) { h("Skills"); L.paragraph(col, s.skills.join("  •  "), { color: t.ink }); }
    if (s.certifications.length) { h("Certifications"); s.certifications.forEach(function (x) { L.paragraph(col, x.name, { bold: true, size: 9.8 }); var meta = join([x.organization, x.date]); if (meta) L.paragraph(col, meta, { size: 9, color: t.muted }); col.y += 1.4; }); }
    if (s.languages.length) { h("Languages"); L.paragraph(col, s.languages.map(function (x) { return join([x.name, x.level], " — "); }).join("   •   "), { color: t.ink }); }
    if (s.links.length) { h("Links"); s.links.forEach(function (x) { L.paragraph(col, join([x.name, displayUrl(x.url)], ": "), { color: t.ink, url: href(x.url) || undefined }); }); }
  }

  function drawSingleColumn(L, d, s, photo) {
    var doc = L.doc, t = L.theme, name = oneLine(d.full_name) || "Your Name", title = oneLine(d.job_title), contacts = contactItems(d);
    var col = { x: M, w: W - 2 * M, y: M, page: 1, top: M, bottom: H - M };
    if (t.layout === "band") {
      var photoD = photo ? 30 : 0, textX = M + (photo ? photoD + 7 : 0), head = { x: textX, w: W - M - textX, y: 11, page: 1, top: 11, bottom: H };
      L.style(24, true); var nameLines = doc.splitTextToSize(name, head.w);
      L.style(8.6, false); var contactH = contacts.length ? L.lh(8.6) * Math.ceil(doc.getTextWidth(contacts.map(function (c) { return c.text; }).join("   |   ")) / head.w + 0.2) : 0;
      var bandH = Math.max(photo ? photoD + 16 : 0, 11 + nameLines.length * L.lh(24, 1.15) + (title ? L.lh(12) + 1 : 0) + 2 + contactH + 9);
      doc.setFillColor.apply(doc, t.accent); doc.rect(0, 0, W, bandH, "F");
      if (photo) { var py = (bandH - photoD) / 2; doc.addImage(photo, "PNG", M, py, photoD, photoD); doc.setDrawColor(255, 255, 255); doc.setLineWidth(0.9); doc.circle(M + photoD / 2, py + photoD / 2, photoD / 2, "S"); }
      var textH = nameLines.length * L.lh(24, 1.15) + (title ? L.lh(12) + 1 : 0) + 2 + contactH;
      head.y = Math.max(9, (bandH - textH) / 2);
      L.paragraph(head, name, { size: 24, bold: true, color: [255, 255, 255], factor: 1.15 });
      if (title) L.paragraph(head, title, { size: 12, color: [233, 225, 255], after: 1 });
      head.y += 2;
      if (contacts.length) L.inline(head, contacts, { size: 8.6, color: [255, 255, 255], sepColor: [196, 181, 253] });
      col.y = bandH + 7;
    } else if (t.layout === "plain") {
      var pd = photo ? 24 : 0, headP = { x: M, w: W - 2 * M - (photo ? pd + 6 : 0), y: M, page: 1, top: M, bottom: H };
      if (photo) doc.addImage(photo, "PNG", W - M - pd, M, pd, pd);
      L.paragraph(headP, name, { size: 26, bold: true, color: t.ink, factor: 1.15 });
      if (title) L.paragraph(headP, title, { size: 12, color: t.muted, after: 1.5 });
      if (contacts.length) L.inline(headP, contacts, { size: 8.6, color: t.muted, separator: "   ·   " });
      col.y = Math.max(headP.y, M + pd) + 4;
      doc.setDrawColor.apply(doc, t.ink); doc.setLineWidth(0.6); doc.line(M, col.y, W - M, col.y); col.y += 5;
    } else {
      var headC = { x: M, w: W - 2 * M, y: M - 2, page: 1, top: M, bottom: H };
      if (photo) { doc.addImage(photo, "PNG", W / 2 - 13, headC.y, 26, 26); headC.y += 29; }
      L.paragraph(headC, name.toUpperCase(), { size: 25, bold: true, color: t.ink, align: "center", factor: 1.15 });
      if (title) L.paragraph(headC, title, { size: 12.5, color: t.muted, align: "center", after: 1 });
      if (contacts.length) L.inline(headC, contacts, { size: 9.6, color: t.ink, align: "center", separator: "   |   ", sepColor: t.muted });
      col.y = headC.y + 3;
      doc.setDrawColor.apply(doc, t.ink); doc.setLineWidth(0.7); doc.line(M, col.y, W - M, col.y); doc.setLineWidth(0.25); doc.line(M, col.y + 1.3, W - M, col.y + 1.3);
      col.y += 5;
    }
    var first = mainSections(L, col, s, true);
    extraSections(L, col, s, first);
  }

  function drawSidebar(L, d, s, photo) {
    var doc = L.doc, t = L.theme, sw = t.sideWidth, contacts = contactItems(d);
    var side = { x: 10, w: sw - 20, y: 14, page: 1, top: 14, bottom: H - 14 };
    var main = { x: sw + 10, w: W - sw - 10 - 14, y: 16, page: 1, top: 16, bottom: H - 16 };
    if (photo) { var pd = 40; doc.addImage(photo, "PNG", (sw - pd) / 2, side.y, pd, pd); doc.setDrawColor(255, 255, 255); doc.setLineWidth(1.2); doc.circle(sw / 2, side.y + pd / 2, pd / 2, "S"); side.y += pd + 6; }
    var sideFirst = true, sh = function (title) { L.heading(side, title, { side: true, first: sideFirst }); sideFirst = false; };
    if (contacts.length) { sh("Contact"); contacts.forEach(function (c) { L.paragraph(side, c.label, { size: 7.6, bold: true, color: t.muted, factor: 1.25 }); L.paragraph(side, c.text, { size: 8.6, color: t.ink, url: c.url, after: 1.6 }); }); }
    if (s.skills.length) { sh("Skills"); L.chips(side, s.skills); }
    if (s.languages.length) { sh("Languages"); s.languages.forEach(function (x) { L.paragraph(side, x.name, { size: 9, bold: true }); if (x.level) L.paragraph(side, x.level, { size: 8.6, color: t.muted }); side.y += 1; }); }
    if (s.certifications.length) { sh("Certifications"); s.certifications.forEach(function (x) { L.paragraph(side, x.name, { size: 9, bold: true }); var meta = join([x.organization, x.date]); if (meta) L.paragraph(side, meta, { size: 8.4, color: t.muted }); side.y += 1.4; }); }
    if (s.links.length) { sh("Links"); s.links.forEach(function (x) { if (x.name) L.paragraph(side, x.name, { size: 7.6, bold: true, color: t.muted }); L.paragraph(side, displayUrl(x.url || x.name), { size: 8.6, url: href(x.url) || undefined, after: 1.4 }); }); }

    L.paragraph(main, oneLine(d.full_name) || "Your Name", { size: 25, bold: true, color: t.accent, factor: 1.15 });
    if (oneLine(d.job_title)) L.paragraph(main, d.job_title, { size: 12.5, color: t.ink });
    main.y += 2; doc.setDrawColor.apply(doc, t.accent); doc.setLineWidth(1); doc.line(main.x, main.y, main.x + 18, main.y); main.y += 4;
    mainSections(L, main, s, true);
  }

  function footer(L, d) {
    var doc = L.doc, n = doc.getNumberOfPages();
    if (n < 2) return;
    for (var p = 1; p <= n; p++) {
      doc.setPage(p); L.style(7.5, false, L.theme.muted);
      doc.text(oneLine(d.full_name) || "Resume", L.theme.side ? L.theme.sideWidth + 10 : M, H - 8);
      doc.text("Page " + p + " of " + n, W - (L.theme.side ? 14 : M), H - 8, { align: "right" });
    }
  }

  async function build(data, options) {
    if (!window.jspdf || !window.jspdf.jsPDF) throw new Error("The PDF library did not load. Check your connection and refresh.");
    options = options || {};
    var templateKey = THEMES[options.template || data.template] ? (options.template || data.template) : "modern", theme = THEMES[templateKey], warnings = [];
    var doc = new window.jspdf.jsPDF({ unit: "mm", format: "a4", orientation: "portrait", compress: true, putOnlyUsedFonts: true });
    var font = await registerFont(doc, theme.font);
    if (!font.embedded) warnings.push("Custom fonts could not be loaded, so standard PDF fonts were used.");
    var photo = null;
    if (data.photo && typeof document !== "undefined") { try { photo = await circlePhoto(data.photo, 480); } catch (e) { warnings.push(e.message); } }
    var name = oneLine(data.full_name) || "Resume";
    doc.setProperties({ title: oneLine(data.resume_name) || name + " – Resume", subject: "Resume" + (data.job_title ? " – " + oneLine(data.job_title) : ""), author: name, keywords: (data.skills || []).join(", "), creator: "HireIn AI Resume Builder" });
    try { doc.setLanguage("en-US"); } catch (e) { /* optional metadata */ }
    var L = new Layout(doc, theme, font.name), s = sectionsFor(data);
    if (theme.layout === "sidebar") drawSidebar(L, data, s, photo); else drawSingleColumn(L, data, s, photo);
    footer(L, data);
    return { doc: doc, template: templateKey, pages: doc.getNumberOfPages(), fontsEmbedded: font.embedded, warnings: warnings };
  }
  async function generate(data, options) {
    var result = await build(data, options);
    result.blob = result.doc.output("blob");
    return result;
  }
  function fileName(name) { return (oneLine(name) || "HireIn-AI-resume").replace(/[^\w-]+/g, "-").replace(/-+/g, "-").replace(/^-|-$/g, "").slice(0, 80) + ".pdf"; }

  window.HireInPDF = { generate: generate, build: build, fileName: fileName, templates: THEMES, preloadFonts: function (template) { var spec = FONTS[(THEMES[template] || THEMES.modern).font]; return Promise.all([fetchFont(spec.normal), fetchFont(spec.bold)]).catch(function () {}); } };
})();

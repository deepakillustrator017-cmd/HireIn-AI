-- HireIn AI: real external job openings - Karnataka
-- Cities: Bengaluru 15, Mysuru 1, Mangalore 0 (target was 15 per city; only postings that are genuinely open were imported).
-- Source: the employers' own public job boards (Greenhouse, Lever, SmartRecruiters, Ashby), fetched 2026-09-27.
-- Every row: apply_type='external', apply_url = the official posting URL, status='published'.
-- Salary is only set when the employer publishes it; otherwise salary_min/max are NULL ('Not disclosed').
-- Idempotent: companies upsert by slug (existing rows are kept); jobs are skipped when source_url already exists.
-- See docs/job_sources.md for every careers URL. Postings close over time; re-verify before re-running.

begin;

alter table public.companies add column if not exists industry text;
alter table public.companies add column if not exists city text;
alter table public.companies add column if not exists state text;
alter table public.jobs add column if not exists source_url text;
alter table public.jobs add column if not exists apply_url text;
alter table public.jobs add column if not exists apply_label text default 'Apply on Company Website';
alter table public.jobs add column if not exists state text;
alter table public.jobs add column if not exists apply_type text default 'external' check (apply_type in ('external', 'internal'));

-- 1. Companies (kept as-is if the slug already exists)
insert into public.companies (name, slug, industry, website, logo_url, city, state, location, description, is_approved)
values
  ('Okta', 'okta', 'Identity Security', 'https://www.okta.com', 'https://www.google.com/s2/favicons?domain=okta.com&sz=128', 'Bengaluru', 'Karnataka', 'Bengaluru, Karnataka', 'Okta (Identity Security). Official careers: https://www.okta.com/company/careers/', true),
  ('Stripe', 'stripe', 'Payments', 'https://stripe.com', 'https://www.google.com/s2/favicons?domain=stripe.com&sz=128', 'Bengaluru', 'Karnataka', 'Bengaluru, Karnataka', 'Stripe (Payments). Official careers: https://stripe.com/jobs', true),
  ('GitLab', 'gitlab', 'DevSecOps Software', 'https://about.gitlab.com', 'https://www.google.com/s2/favicons?domain=gitlab.com&sz=128', 'Bengaluru', 'Karnataka', 'Bengaluru, Karnataka', 'GitLab (DevSecOps Software). Official careers: https://about.gitlab.com/jobs/', true),
  ('Databricks', 'databricks', 'Data & AI', 'https://www.databricks.com', 'https://www.google.com/s2/favicons?domain=databricks.com&sz=128', 'Bengaluru', 'Karnataka', 'Bengaluru, Karnataka', 'Databricks (Data & AI). Official careers: https://www.databricks.com/company/careers', true),
  ('ServiceNow', 'servicenow', 'Enterprise Software', 'https://www.servicenow.com', 'https://www.google.com/s2/favicons?domain=servicenow.com&sz=128', 'Bengaluru', 'Karnataka', 'Bengaluru, Karnataka', 'ServiceNow (Enterprise Software). Official careers: https://careers.smartrecruiters.com/ServiceNow', true),
  ('Bosch', 'bosch', 'Engineering & Technology', 'https://www.bosch.in', 'https://www.google.com/s2/favicons?domain=bosch.in&sz=128', 'Bengaluru', 'Karnataka', 'Bengaluru, Karnataka', 'Bosch (Engineering & Technology). Official careers: https://careers.smartrecruiters.com/BoschGroup', true),
  ('Sarvam AI', 'sarvam-ai', 'Artificial Intelligence', 'https://www.sarvam.ai', 'https://www.google.com/s2/favicons?domain=sarvam.ai&sz=128', 'Bengaluru', 'Karnataka', 'Bengaluru, Karnataka', 'Sarvam AI (Artificial Intelligence). Official careers: https://jobs.ashbyhq.com/sarvam', true),
  ('HackerRank', 'hackerrank', 'Developer Technology', 'https://www.hackerrank.com', 'https://www.google.com/s2/favicons?domain=hackerrank.com&sz=128', 'Bengaluru', 'Karnataka', 'Bengaluru, Karnataka', 'HackerRank (Developer Technology). Official careers: https://www.hackerrank.com/careers/', true),
  ('Zscaler', 'zscaler', 'Cloud Security', 'https://www.zscaler.com', 'https://www.google.com/s2/favicons?domain=zscaler.com&sz=128', 'Bengaluru', 'Karnataka', 'Bengaluru, Karnataka', 'Zscaler (Cloud Security). Official careers: https://www.zscaler.com/careers', true),
  ('Swiggy', 'swiggy', 'Consumer Technology', 'https://www.swiggy.com', 'https://www.google.com/s2/favicons?domain=swiggy.com&sz=128', 'Bengaluru', 'Karnataka', 'Bengaluru, Karnataka', 'Swiggy (Consumer Technology). Official careers: https://careers.smartrecruiters.com/Swiggy', true)
on conflict (slug) do nothing;

-- 2. Jobs (16), linked to companies by slug
insert into public.jobs (company_id, company, title, category, location, state, work_mode, employment_type, experience, salary_min, salary_max, salary, currency, skills, description, responsibilities, requirements, benefits, posted_at, source_url, apply_url, apply_type, apply_label, status, featured, logo)
select c.id, c.name, v.title, v.category, v.location, v.state, v.work_mode, v.employment_type, v.experience, v.salary_min, v.salary_max, v.salary, 'INR', v.skills, v.description, v.responsibilities, v.requirements, v.benefits, v.posted_at, v.source_url, v.source_url, 'external', 'Apply on Company Website', 'published', false, c.logo_url
from (values
  -- 1. [QA Engineer] Okta - Senior Software Engineer in Test — macOS (Bengaluru)
  ('okta',
   'Senior Software Engineer in Test — macOS',
   'QA Engineer',
   'Bengaluru, Karnataka',
   'Karnataka',
   'Hybrid',
   'Full time',
   '3+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Python', 'Java', 'Swift', 'Docker', 'Kubernetes', 'CI/CD', 'Machine Learning', 'Recruitment']::text[],
   'Secure Every Identity, from AI to Human
Identity is the key to unlocking the potential of AI. Okta secures AI by building the trusted, neutral infrastructure that enables organizations to safely embrace this new era. This work requires a relentless drive to solve complex challenges with real-world stakes. We are looking for builders and owners who operate with speed and urgency and execute with excellence.
This is an opportunity to do career-defining work. We''re all in on this mission. If you are too, let''s talk.
Secure Every Identity, from AI to Human
Identity is the key to unlocking the potential of AI. Okta secures AI by building the trusted, neutral infrastructure that enables organizations to safely embrace this new era. This work requires a relentless drive to solve complex challenges with real-world stakes. We are looking for builders and owners who operate with speed and urgency and execute with excellence.
This is an opportunity to do career-defining work. We''re all in on this mission. If you are too, let''s talk.
About Okta Verify Team
The Okta MacOS platform team is responsible for building Okta''s MacOS Apps and SDKs. The Okta Verify app allows you to securely access your apps via 2-step verification, ensuring that you, and only you, can access your app accounts. It integrates with MacOS system features by communicating with our backend to and grant proper application access.
Position Overview',
   'Test Automation Framework Architecture
- Design & Scale: Maintain, and expand highly reusable test automation frameworks and performance suites specifically tailored for native macOS desktop applications.
- Integrations: Develop automated functional and integration tests covering deep OS-level components, network interception, and local security configurations.
- Flaky Test Elimination: Contribute to local initiatives within the Automation Guild to systematically triage and eliminate flaky UI tests, driving CI/CD stability.
Quality Engineering & Product Strategy
- Design Transparency: Embed early into product ideation, technical architecture, and system design discussions with Software Development Engineers (SDEs), Product Managers, and Architects, providing explicit quality scaffolding and risk analysis.
- Platform Ownership: Drive comprehensive test planning, execution, and precise effort estimations for the Okta Verify macOS application.
- Technical Debt Reduction: Build automated infrastructure to streamline complex testing scenarios, such as the migration of legacy Objective-C components to modern Swift foundations.
CI/CD & Dev-Ops Synergy
- Pipeline Integration: Maintain and optimize local CI/CD pipelines (leveraging tools like CircleCI) to ensure rapid, deterministic automated gates for macOS client builds.
- Reliability Operations: Partner with Infrastructure and Site Reliability Engineering (SRE) teams to optimize test bed environments and maintain robust alert mechanisms for regression detection.',
   '- Experience: 3+ years of experience in Software Engineering in Test roles, with at least 1+ years deeply focused on automated validation of native macOS desktop applications.
- Programming Proficiency: Strong coding skills in Swift, Objective-C, or Java/Python with a proven ability to write clean, scalable, and maintainable automation code.
- macOS Ecosystem Depth: Understanding of macOS development paradigms, XCTest/XCUITest, application sandboxing, and Apple developer tools.
- Test Tools: Hands-on expertise with cross-platform automation tools, UI testing frameworks, and API validation engines (REST, gRPC, or WebSockets).
- Infrastructure Familiarity: Direct experience working with CI/CD systems (e.g., CircleCI), containerization (Kubernetes/Docker), and standard logging frameworks.
- Education: B.Tech / B.E. in Computer Science, Information Technology, or a closely related technical field.
- Domain Expertise: Experience testing security software, enterprise Identity and Access Management (IAM) systems, or cryptographic applications.
- Technical Familiarity: Familiarity with MDM profiles, enterprise software deployment mechanisms on macOS, and local system frameworks (e.g., Endpoint Security, Local Authentication).
#LI-Hybrid
#P24149
The Okta Experience
- Supporting Your Well-Being
- Driving Social Impact
- Developing Talent and Fostering Connection + Community
We are intentional about connection. Our global community, spanning over 20 offices worldwide, is united by a drive to innovate. Your journey begins with an immersive, in-person onboarding experience designed to accelerate your impact and connect you to our mission and team from day one.
Okta is an Equal Opportunity Employer. All qualified applicants will receive consideration for employment without regard to race, color, religion, sex, sexual orientation, gender identity, national origin, ancestry, marital status, age, physical or mental disability, or status as a protected veteran.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-02-04T15:26:09Z'::timestamptz,
   'https://www.okta.com/company/careers/opportunity/7588357?gh_jid=7588357'),
  -- 2. [DevOps Engineer] Stripe - Staff Engineer, Core Infrastructure (Bengaluru)
  ('stripe',
   'Staff Engineer, Core Infrastructure',
   'DevOps Engineer',
   'Bengaluru, Karnataka',
   'Karnataka',
   'Onsite',
   'Full time',
   '12+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['PostgreSQL', 'MongoDB', 'AWS', 'Azure', 'GCP', 'Kubernetes', 'Terraform', 'CI/CD']::text[],
   'Who we are
About Stripe
Stripe is a financial infrastructure platform for businesses. Millions of companies — from the world''s largest enterprises to the most ambitious startups — use Stripe to accept payments, grow their revenue, and accelerate new business opportunities. Our mission is to increase the GDP of the internet, and we have a staggering amount of work ahead. That means you have an unprecedented opportunity to put the global economy within everyone''s reach while doing the most important work of your career.
About the Organization
The Core Infrastructure organization operates the foundational systems that power Stripe globally — including databases (MongoDB, PostgreSQL), high availability and disaster recovery (HADR), AWS cloud infrastructure, Linux servers, container orchestration, mesh networking, service discovery, and network edge infrastructure.
Within Core Infra, the Regional Enablement Platform (REP) team helps Stripe launch and operate new regions without learning about broken dependencies from users. REP builds the regionalization, validation, deploy-safety, and operator tooling needed to answer practical launch-readiness questions: can critical payment paths run from the new region, which services still depend on a remote control plane, what breaks under packet loss or failover, and what must be fixed before deploys, launches, traffic shifts, or failovers proceed.',
   'As a Staff Engineer on REP, you will play a key leadership role in enabling Stripe''s infrastructure to power all of our products, globally and at scale. You will decide how Stripe validates that a new region can safely take traffic and continue working through network loss, failover, and deploy changes. You will define the checks that must pass before launch or failover, build validation systems that replay real production paths against regional infrastructure, and turn those checks into CI/CD gates, operator workflows, and concrete fixes for service or platform owners. You will also help build Core Infrastructure''s senior technical bench in Bangalore through design review, mentoring, and cross-region technical leadership.
- Define evidence-based readiness criteria for regional launches, traffic migrations, and failovers — replacing manual checklists with repeatable, globally consistent patterns
- Proactively identify and mitigate risks on critical payment paths; use system data to drive ownership and validate that platform mitigations measurably reduce impact
- Lead end-to-end cross-functional delivery for new-region infrastructure, including safe service behaviors for remote control planes
- Build reusable validation tooling that accelerates infrastructure integration for new acquisitions and reduces high-priority blockers
- Convert recurring operational friction into scalable platform capabilities used across teams
- Lead technical conversations and define decision mechanisms across Core Infrastructure and product teams
- Develop and communicate a multi-year technical strategy for REP with clearly defined quarterly milestones and success metrics
- Debug production issues across services and levels of the stack
- Mentor and grow senior engineers, elevating technical planning, design standards, and cross-region execution from Bangalore',
   'We''re looking for someone who meets the minimum requirements to be considered for the role. If you meet these requirements, you are encouraged to apply. The preferred qualifications are a bonus, not a requirement.
- BS or MS in Computer Science or equivalent field
- 12+ years of professional experience in software or infrastructure engineering
- Proven track record leading complex, cross-team or company-wide infrastructure projects with high reliability and scale requirements
- Strong engineering background in distributed systems, platform engineering, or backend infrastructure, with a focus on operational safety and correctness
- Experience optimizing the reliability and security of distributed systems
- Experience scaling and migrating systems with little to no downtime
- Strong technical judgment and written communication skills, including design docs and trade-off analysis
- Experience mentoring engineers at various stages of their careers
- Experience with one or more major cloud providers — AWS, Azure, OCI, or GCP
- Familiarity with ops culture and a solid understanding of metrics, alarms, and dashboards
- Experience validating large-scale migrations, failovers, regional launches, regionalization, or control-plane behavior.
- Experience designing or operating infrastructure with strict reliability, correctness, latency, or availability requirements.
- Strong observability judgment across metrics, logs, tracing, alerting, and incident analysis.
- Experience with networking, service discovery, traffic routing, databases, Kubernetes, Terraform, or cloud infrastructure.
- Experience reducing packet loss, network latency, cross-region dependency risk, or other infrastructure failure modes.
- Experience making infrastructure validation or readiness evidence usable by service owners, operators, or partner teams.
- Experience turning repeated operational problems into reusable tools, standards, or platform mechanisms.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-07-30T04:27:59Z'::timestamptz,
   'https://stripe.com/jobs/search?gh_jid=8070949'),
  -- 3. [Data Analyst] Stripe - Data Science Manager, Risk (Bengaluru)
  ('stripe',
   'Data Science Manager, Risk',
   'Data Analyst',
   'Bengaluru, Karnataka',
   'Karnataka',
   'Onsite',
   'Full time',
   '10+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Python', 'SQL', 'Statistics', 'Stakeholder Management', 'Communication', 'Leadership', 'Team Management']::text[],
   'Who we are
About Stripe
Stripe is a financial infrastructure platform for businesses. Millions of companies—from the world''s largest enterprises to the most ambitious startups—use Stripe to accept payments, grow their revenue, and accelerate new business opportunities. Our mission is to increase the GDP of the internet, and we have a staggering amount of work ahead. That means you have an unprecedented opportunity to put the global economy within everyone''s reach while doing the most important work of your career.
About the team
The Data Science and Analytics organization at Stripe partners with teams across the company to drive rigorous, data-informed decision-making at scale. Within this org, the Verifications and Greater China data teams deliver critical analytical and data science work—from identity verification and risk modeling to market-specific growth insights—that directly shapes Stripe''s ability to serve users safely and expand into new markets.
Today, the team comprises individual contributors distributed across Singapore and India, supporting two high-impact pillars. We''re looking for a founding Data Science Manager based in Bengaluru to build and lead this growing regional footprint from the ground up.',
   'This is a rare 0 → 1 leadership role with a dual mandate.
Pillar 1—Direct Team Leadership
• Manage a team of Data Scientists and Data Analysts (currently 4 individual contributors across India and Singapore) spanning the Verifications and Greater China workstreams.
• Own roadmap prioritization, execution quality, and stakeholder alignment for both workstreams.
• Drive hiring for open and future roles in India, building a high-caliber data team in a competitive talent market.
• Foster individual contributor growth through real-time coaching, mentorship, career development, and performance management.
Pillar 2—Regional Data Craft Lead (India Office)
• Serve as the founding data craft leader for Stripe''s India office. Set quality standards, establish community rituals (knowledge sharing, peer reviews, office hours), and cultivate a strong local data culture.
• Act as the go-to point of contact for data craft standards, tooling, and best practices for co-located analysts, even those outside your direct reporting line.
• Partner with managers and leads across the broader Data org to ensure consistency in methodology, tooling, and quality bar.
• Support onboarding and integration of new data hires in the Bengaluru office.
• Over time, this role has the potential to evolve into a Center of Excellence (COE) model—becoming the single point of data leadership in India across multiple product pillars (e.g., Payments, Growth, Marketing), not just Risk.
• Build, manage, and develop a high-performing, geographically distributed data team.
• Define and drive the data roadmap in close partnership with product, engineering, and business stakeholders—ensuring analytical work is tightly coupled to business outcomes.
• Establish and raise the bar on analytical rigor, experimentation frameworks, and data science best practices across the team.',
   'We''re looking for someone who meets the minimum requirements to be considered for the role. If you meet these requirements, you are encouraged to apply. The preferred qualifications are a bonus, not a requirement.
• 10+ years of experience in data science, analytics, or a related quantitative field, with 3+ years in a people management role leading data scientists or analysts
• Strong technical foundation in SQL, Python or R, statistical modeling, and experimentation design
• Demonstrated ability to translate ambiguous business problems into structured analytical frameworks and actionable insights
• Experience managing and developing individual contributor talent across multiple levels, including coaching, career pathing, and performance management
• Excellent communication and stakeholder management skills—able to influence without authority across functions and time zones along with proven ability to drive alignment and execution across distributed, cross-functional teams
• Advanced degree (M.S. or Ph.D.) in a quantitative discipline such as Statistics, Economics, Computer Science, Mathematics, or a related field
• Experience working in the payments, fintech, or financial services industry
• Prior experience building and scaling data teams in a high-growth environment—particularly standing up 0 → 1 functions or teams
• Track record of being a builder who has personally architected the rituals, standards, hiring bar, and craft culture for a data team from the ground up
• Familiarity with risk, verifications, or compliance-related data domains
• Experience operating across Asia-Pacific markets and navigating the nuances of multi-region team management
• Passion for developing others and creating environments where individual contributors do the best work of their careers',
   'Benefits are listed on the employer''s official job posting.',
   '2026-05-14T15:33:56Z'::timestamptz,
   'https://stripe.com/jobs/search?gh_jid=7923653'),
  -- 4. [Business Analyst] Okta - Senior Product Analyst - Finance Technology (Bengaluru)
  ('okta',
   'Senior Product Analyst - Finance Technology',
   'Business Analyst',
   'Bengaluru, Karnataka',
   'Karnataka',
   'Onsite',
   'Full time',
   '8+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Machine Learning', 'Salesforce', 'Project Management', 'Accounting', 'Recruitment', 'Communication', 'Leadership']::text[],
   'Secure Every Identity, from AI to Human
Identity is the key to unlocking the potential of AI. Okta secures AI by building the trusted, neutral infrastructure that enables organizations to safely embrace this new era. This work requires a relentless drive to solve complex challenges with real-world stakes. We are looking for builders and owners who operate with speed and urgency and execute with excellence.
This is an opportunity to do career-defining work. We''re all in on this mission. If you are too, let''s talk.
About Okta:
Okta is the leading independent provider of identity solutions for enterprises. With a deep commitment to innovation and customer success, we power and secure digital transformation for the world''s biggest brands. We''re scaling rapidly, and we’re seeking talented individuals to join us in enabling secure and seamless digital experiences.
One of the most important components of our operations is an efficient financial system, including seamless processes for the Record-to-Report (R2R) cycle. As a NetSuite R2R Analyst, your role will support and strengthen Okta''s financial systems and processes to ensure accuracy, efficiency, and scalability. This is a potential Contract to Hire position.',
   '- Act as the subject matter expert (SME) for NetSuite functionality in Record-to-Report (R2R) processes, maintaining workflows, configurations, and data integrity to enhance efficiency and compliance (e.g., SOX, GAAP).
- Bridge IT and Treasury operations to configure, integrate, and deploy the Kyriba Treasury Management System (TMS). You will lead full-lifecycle technical implementations, ERP integrations, and secure bank connectivity projects.
- Lead or participate in R2R-related projects, including implementations, migrations, process improvements, customizations, upgrades, and integrations with NetSuite’s financial modules.
- Support month-end, quarter-end, and year-end close processes by ensuring timely reconciliations, reporting, general ledger accuracy, consolidations, and intercompany accounting.
- Partner with finance, IT, and external vendors to provide NetSuite support, resolve issues, streamline processes, evaluate automation opportunities, and deliver user training.
- Monitor audit trails, support audit processes, generate required reports, and ensure system configurations align with audit and compliance standards.
- Provide project updates to leadership, communicate risks or dependencies, and propose actionable solutions to enhance NetSuite workflows and overall system performance.
- Leverage GenAI or Agentic AI solutions to automate financial reconciliation, enhance anomaly detection, and optimize R2R processes.
- Hands-on experience on NetSuite and Kyriba',
   '- Bachelor’s degree in Accounting, Finance, Information Systems, or a related field, with over 8 years of technology experience, including 6+ years of hands-on NetSuite expertise in R2R, accounting, or finance roles.
- Strong knowledge of GAAP/IFRS, general ledger management, financial reporting, and hands-on proficiency in NetSuite customizations, SuiteScript, Workflows, Saved Searches, and Dashboards.
- Expertise in key R2R processes, including journal entries, fixed assets, intercompany transactions, multi-currency accounting, and financial reporting.
- 3–5+ years of hands-on IT experience implementing, configuring, or supporting Kyriba TMS.
- Strong analytical abilities, acute attention to detail, and problem-solving skills to handle complex financial processes effectively.
- Excellent communication skills to convey technical concepts to non-technical stakeholders, with a collaborative mindset to work across cross-functional teams.
- Strong project management skills, ability to prioritize multiple tasks, and a passion for process improvement and automation.
- Experience or familiarity with implementing or utilizing AI/ML-driven solutions within financial systems to drive process automation and data insights.
Nice-to-Have:
- Familiarity with integration tools like Celigo, or similar middleware platforms.
- Knowledge of other financial systems (e.g., Workday, Coupa, Avalara, Salesforce) and how they integrate with NetSuite.
- NetSuite Administrator or ERP Implementation certification is a plus.
#P16564_3519909
#Hybrid_LI
The Okta Experience
- Supporting Your Well-Being
- Driving Social Impact
- Developing Talent and Fostering Connection + Community
We are intentional about connection. Our global community, spanning over 20 offices worldwide, is united by a drive to innovate. Your journey begins with an immersive, in-person onboarding experience designed to accelerate your impact and connect you to our mission and team from day one.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-08-14T11:57:48Z'::timestamptz,
   'https://www.okta.com/company/careers/opportunity/8128431?gh_jid=8128431'),
  -- 5. [Frontend Developer] Okta - Principal UI Software Engineer (Bengaluru)
  ('okta',
   'Principal UI Software Engineer',
   'Frontend Developer',
   'Bengaluru, Karnataka',
   'Karnataka',
   'Hybrid',
   'Full time',
   '13+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Design Systems', 'Responsive Design', 'JavaScript', 'TypeScript', 'React', 'Git', 'Jest', 'Machine Learning']::text[],
   'Secure Every Identity, from AI to Human
Identity is the key to unlocking the potential of AI. Okta secures AI by building the trusted, neutral infrastructure that enables organizations to safely embrace this new era. This work requires a relentless drive to solve complex challenges with real-world stakes. We are looking for builders and owners who operate with speed and urgency and execute with excellence.
This is an opportunity to do career-defining work. We''re all in on this mission. If you are too, let''s talk.
Principal UI Engineer - Frontend/Fullstack (React, TypeScript)
Get to know Okta
Okta is The World’s Identity Company. We free everyone to safely use any technology, anywhere, on any device or app. Our flexible and neutral products, Okta Platform and Auth0 Platform, provide secure access, authentication, and automation, placing identity at the core of business security and growth.
At Okta, we celebrate a variety of perspectives and experiences. We are not looking for someone who checks every single box - we’re looking for lifelong learners and people who can make us better with their unique experiences.
Join our team! We’re building a world where Identity belongs to you.
Access Essentials - Core Product
The Access Essentials organization at Okta builds the platform features for authentication and authorization across Okta-protected resources. Our mission is to enable customers to access these resources seamlessly & securely.',
   '- Lead the design and development of complex, high-performance features using React and TypeScript.
- Collaborate closely with product managers, UI/UX designers, and backend engineers to translate requirements into robust and effective frontend solutions.
- Write clean, modular, well-tested, and maintainable code, adhering to best practices and coding standards.
- Optimize applications for speed, scalability, and responsiveness across various devices and browsers.
- Contribute to the evolution of our frontend architecture, ensuring its long-term scalability and maintainability.
- Participate in code reviews, providing constructive feedback and ensuring code quality across the team.
- Proactively identify and address technical debt, performance bottlenecks, and areas for improvement.
- Stay up-to-date with the latest trends and technologies in frontend development, evaluating and recommending new tools and approaches.
- Champion a culture of continuous improvement, innovation, and technical excellence within the team.',
   '- 13+ years of professional experience in frontend development, with a strong focus on building complex web applications.
- Deep expertise in React, including a strong understanding of its core principles, hooks, component lifecycle, and state management.
- Proficiency in TypeScript, with a proven ability to leverage its features for robust and maintainable codebases.
- Solid understanding of modern JavaScript (ES6+), HTML5, and CSS3.
- Experience with front-end tooling such as Webpack, Babel, Vite, and package managers (Yarn).
- Demonstrated experience consuming and integrating with RESTful APIs.
- Familiarity with testing frameworks (e.g., Jest, React Testing Library, Playwright) and a commitment to writing comprehensive tests.
- Strong understanding of version control systems, particularly Git.
- Experience with responsive design principles and building accessible web interfaces.
- Excellent problem-solving skills, with the ability to debug complex issues and find practical solutions.
- Strong communication and interpersonal skills, with the ability to collaborate effectively within a cross-functional team.
Nice to have:
- Familiarity with design systems and component libraries.
- An understanding of Identity and Access Management protocols and architecture, e.g., FIDO, U2F, WebAuth, SSO, SAML, OAuth, Federation.
- Contributions to open-source projects.
Education and Training:
- Bachelor’s degree in Computer Science or equivalent experience
- years of experience working on large-scale enterprise grade software
#LI-Hybrid
P24145_3361880
The Okta Experience
- Supporting Your Well-Being
- Driving Social Impact
- Developing Talent and Fostering Connection + Community
We are intentional about connection. Our global community, spanning over 20 offices worldwide, is united by a drive to innovate.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-24T08:53:21Z'::timestamptz,
   'https://www.okta.com/company/careers/opportunity/8229910?gh_jid=8229910'),
  -- 6. [Backend Developer] GitLab - Staff Backend Engineer, India (Bengaluru)
  ('gitlab',
   'Staff Backend Engineer, India',
   'Backend Developer',
   'Bengaluru, Karnataka',
   'Karnataka',
   'Onsite',
   'Full time',
   'Not specified',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Ruby', 'PostgreSQL', 'Kubernetes', 'Recruitment', 'Communication', 'Leadership']::text[],
   'GitLab is the intelligent orchestration platform for DevSecOps. GitLab enables organizations to increase developer productivity, improve operational efficiency, reduce security and compliance risk, and accelerate digital transformation. More than 50 million registered users and more than 50% of the Fortune 100* trust GitLab to ship better, more secure software faster.
The same principles built into our products are reflected in how our team works: we embrace AI as a core productivity multiplier, with all team members expected to incorporate AI into their daily workflows to drive efficiency, innovation, and impact. GitLab is where careers accelerate, innovation flourishes, and every voice is valued. Our high-performance culture is driven by our values and continuous knowledge exchange, enabling our team members to reach their full potential while collaborating with industry leaders to solve complex problems. Co-create the future with us as we build technology that transforms how the world develops software.
*Fortune 500® is a registered trademark of Fortune Media IP Limited, used under license. Claim based on GitLab data. Fortune 100 refers to the top 20% ranked companies in the 2025 Fortune 500 list, published in June 2025. Fortune and Fortune Media IP Limited are not affiliated with, and do not endorse products or services of GitLab.',
   'As a Staff Backend Engineer, you will provide technical leadership across your team and adjacent teams, solving the highest-scope and most complex problems in your area. You will lead large, cross-cutting backend initiatives, drive our modular architecture strategy, and define the standards that let teams move faster without compromising quality, security, reliability, or operability.
This is a technical leadership role that combines deep backend expertise, systems judgment, product judgment, and influence across organizational boundaries. You will work with Product, Frontend, Infrastructure, Security, Data, Engineering Managers, and engineers across product groups, bringing subject matter expertise, and you will do it without relying on formal authority.
Why you’ll love this role
- Leverage: Your work multiplies across teams. The platforms, standards, and architectural decisions you lead determine how quickly everyone else can ship.
- Genuinely Hard Problems: You’ll lead the modernization of a large monolith toward modular, reusable, appropriately independent systems — at the scale of a platform used by millions of users.
- Influence Without Bureaucracy: You’ll shape technical direction across teams through clear written proposals and decision records, and partner with Product and Engineering leadership on platform roadmap and investment trade-offs.
- Frontier AI Work: You’ll lead adoption of AI-assisted and agentic engineering workflows and define the review, quality, security, and privacy guardrails that make them safe to rely on.
- Autonomy: You’ll thrive in our remote-first, asynchronous organization, where clear written communication and self-direction are the pillars of success.
- Lead Cross-Cutting Initiatives: Lead the technical design and delivery of large backend initiatives that span teams, and identify and remove systemic bottlenecks across product and infrastructure groups.',
   'See the official job posting for detailed requirements.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-02T18:50:19Z'::timestamptz,
   'https://job-boards.greenhouse.io/gitlab/jobs/8775136002'),
  -- 7. [Full Stack Developer] Databricks - Sr Full Stack Developer (AI Agents) (Bengaluru)
  ('databricks',
   'Sr Full Stack Developer (AI Agents)',
   'Full Stack Developer',
   'Bengaluru, Karnataka',
   'Karnataka',
   'Onsite',
   'Full time',
   '5+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['React', 'Node.js', 'Python', 'GraphQL', 'CI/CD', 'Excel', 'Salesforce', 'Agile']::text[],
   'GAQ226R75',
   'We are looking for a Senior Full Stack Developer to design, build, and deploy modern, scalable AI agents and applications that leverage Large Language Models (LLMs). This role requires a strong focus on end-to-end agent development, including building a high-performance React frontend, designing the agentic logic in Python, integrating with backend services, and ensuring production readiness.
- Design, develop, and deploy AI agents for business-critical workflows, with a focus on LLM orchestration and tooling.
- Implement complex agentic behaviours using frameworks like LangChain or LangGraph, including ReAct loops for reasoning and action.
- Design and develop a high-performance React application for the agent''s user interface.
- Collaborate with backend teams to integrate APIs and services, and build tools for agents.
- Work with middleware (Python/Node.js) to orchestrate agent calls and data flow.
- Implement comprehensive observability and tracing for agent runs and system performance.
- Build reusable, scalable UI components.
- Optimise application performance, responsiveness, and scalability.
- Participate in architectural discussions and contribute to solution design.
- Write clean, maintainable, and testable code with proper documentation.',
   '- 5+ years of experience in full-stack development, with strong expertise in Python and React.js.
- Proven experience in designing, building, and deploying at least 1 production-deployed AI agent or LLM application.
- Deep expertise in LLM orchestration, prompt engineering, and utilizing tools/plugins to extend agent capabilities.
- Experience with agent frameworks like LangChain or LangGraph, including implementing reasoning patterns like the ReAct loop.
- Experience with observability, logging, and tracing for AI agents.
- Experience building large-scale, enterprise-grade applications.
- Strong experience with API integration (REST/GraphQL).
- Experience working in Agile/Scrum environments.
- Strong problem-solving and system design skills
- Ability to work across frontend and backend integration layers
- Ownership mindset with attention to detail
- Good communication and collaboration skills
- Experience with Node.js or Python for middleware development
- Understanding of Salesforce APIs (REST, Apex, RLM/CPQ)
- Experience with event-driven architectures (webhooks, CDC, async processing)
- Knowledge of CI/CD pipelines and DevOps practices
- Experience with Databricks platform and Mosaic AI
About Databricks
Databricks is the Data and AI company. More than 20,000 organizations worldwide — including adidas, AT&T, Bayer, Block, Mastercard, Rivian, Unilever, and 70% of the Fortune 500 — rely on the Databricks Data + AI Platform to build and scale data and AI apps, analytics and agents. Headquartered in San Francisco with 30+ offices around the globe, Databricks offers a unified platform that includes Genie, Lakebase, Agent Bricks, Lakeflow, Lakehouse, and Unity Catalog. To learn more, follow Databricks on LinkedIn, X, YouTube, and Instagram.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-08-21T02:36:37Z'::timestamptz,
   'https://databricks.com/company/careers/open-positions/job?gh_jid=8679982002'),
  -- 8. [Product Designer] ServiceNow - Principal Product Designer (Bengaluru)
  ('servicenow',
   'Principal Product Designer',
   'Product Designer',
   'Bengaluru, Karnataka',
   'Karnataka',
   'Onsite',
   'Full time',
   '15+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Design Systems', 'Product Management', 'Leadership']::text[],
   'It all started in sunny San Diego, California in 2004 when a visionary engineer, Fred Luddy, saw the potential to transform how we work. Fast forward to today — ServiceNow stands as a global market leader, bringing innovative AI-enhanced technology to over 8,100 customers, including 85% of the Fortune 500®. Our intelligent cloud-based platform seamlessly connects people, systems, and processes to empower organizations to find smarter, faster, and better ways to work.
At ServiceNow, we embrace representation in and from all professional and personal backgrounds and cultures. This diversity inspires passion and creativity among our teams and propels innovation in our products. This role is part of our Product Design team that uses their superpower of empathizing, understanding, and applying our users’ and customers’ needs, with the mission to created product experiences they love. Our designers come from a diverse set of skills and background - design systems, visual, interaction, content, and product design. At ServiceNow, design has a very intentional seat at the table, so our team collaborates closely with both engineering and product management from the get-go.
Learn more about our team here https://www.linkedin.com/company/servicenow/life/userexperience/',
   '- You get to lead large, cross-product, strategic initiatives that are critical to the success of a business unit or the company as a whole to transform how people work around the world.
- You drive product experiences that exemplify beautiful design, catalyze user and enterprise productivity, create extensible systems and frameworks, and inspire customers.
- You provide strategic direction, vision, and leadership for collaborative efforts with multidisciplinary teams. You will act as an industry influencer and thought leader, advancing the industry through contributions to trade events and publications.',
   '- Experience in leveraging or critically thinking about how to integrate AI into work processes, decision-making, or problem-solving. This may include using AI-powered tools, automating workflows, analyzing AI-driven insights, or exploring AI''s potential impact on the function or industry.
- 15+ years of relevant design experience.
- An inspiring portfolio demonstrating formative contributions to design language, strategy, processes, and standards, up to company level.
- Strategic advocate for design and for users at the cross-functional senior leadership and executive level.
- Seen as a thought leader in a company and industry, delivering product experiences that exemplify beautiful design, catalyze user and enterprise productivity, create extensible systems and frameworks, and inspire customers.
- Influence skills and drive to define design strategy across multiple products and/or complex horizontal initiatives.
- Experience participating in the complete product development lifecycle of web and/or software applications.
- Experience in user experience design or industry experience (corporate, software, web or agency)',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-23T06:10:14Z'::timestamptz,
   'https://jobs.smartrecruiters.com/ServiceNow/744000151297869-principal-product-designer'),
  -- 9. [UX Designer] Bosch - Senior UX Researcher (Bengaluru)
  ('bosch',
   'Senior UX Researcher',
   'UX Designer',
   'Bengaluru, Karnataka',
   'Karnataka',
   'Onsite',
   'Full time',
   '5-6 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['UX Design', 'Stakeholder Management', 'Leadership', 'Collaboration']::text[],
   'Bosch Global Software Technologies Private Limited is a 100% owned subsidiary of Robert Bosch GmbH, one of the world''s leading global supplier of technology and services, offering end-to-end Engineering, IT and Business Solutions. With over 27,000+ associates, it’s the largest software development center of Bosch, outside Germany, indicating that it is the Technology Powerhouse of Bosch in India with a global footprint and presence in the US, Europe and the Asia Pacific region.
Role Summary:Lead and drive end-to-end UX research, derive actionable insights, and influence product and business decisions across complex, cross-functional environments.Key Responsibilities1. Lead Complex UX Projects- Plan, design, and execute end-to-end research initiatives- Derive deep user insights from qualitative and quantitative data- Translate insights into product, UX, and business recommendations- Define research roadmaps aligned with product strategy- Own research across multiple domains (e.g., automotive, enterprise tools, digital ecosystems)- Handle ambiguity and shape problem statements- Drive discovery and validation phases in product development2.',
   'See the official job posting for the full list of responsibilities.',
   'Bachelor''s/Master''s degree in UX Design or Service Design.',
   'UX Researcher [ Exp: 5-6+ Years ]',
   '2026-07-22T05:29:15Z'::timestamptz,
   'https://jobs.smartrecruiters.com/BoschGroup/744000138992007-senior-ux-researcher'),
  -- 10. [UI Designer] Sarvam AI - Visual Designer (Bengaluru)
  ('sarvam-ai',
   'Visual Designer',
   'UI Designer',
   'Bengaluru, Karnataka',
   'Karnataka',
   'Onsite',
   'Full time',
   '3+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Figma', 'Photoshop', 'Illustrator', 'After Effects', 'Blender', 'Typography', 'Communication']::text[],
   'About Sarvam
Sarvam is building the bedrock of Sovereign AI for India. The company is developing India’s full-stack sovereign AI platform, building across research, models, infrastructure and applications with a singular focus on making AI genuinely work for India. Sarvam works with leading enterprises and public institutions and is backed by Lightspeed, Peak XV, and Khosla Ventures. Sarvam partners with India’s leading brands, including Tata Capital, SBI Life, CRED, IDFC, and LIC.',
   'India built Aadhaar. India built UPI. India is now building its own frontier AI and at Sarvam, all of it is built, deployed and governed here. This presents a generational opportunity to craft a visual language that is as original and ambitious as the technology it represents.
Sarvam’s identity is built on this very conviction. Our monogram, a gateway drawn from mandala geometry and interlocking circles, serves as a living threshold between human and machine. With a palette that moves vibrantly from blue to orange, our brand system is designed to evolve and scale alongside our innovations. It is a powerful foundation, ready for what comes next.
What it needs now is someone to make it live across launch banners, web sections, product surfaces, films, decks, event walls, and a hundred places we haven’t invented yet. This is not a role about decorating an AI company. It’s about building the visual argument for what Indian design looks like at population scale.
- Translate the system into everything it touches. Web sections, launch banners, social, product marketing, event and print collateral, so that someone who encounters one Sarvam surface immediately recognises the next.
- Design to context, not to template. A model-launch banner, a developer docs header and an enterprise one-pager are three different arguments. You read the comms briefly and build the visual that actually carries it.
- Push the brand into new threads. The master system is the root, not the ceiling. We want spin-off expressions from root that stay unmistakably Sarvam while earning their own character. You’ll experiment, propose, and defend.
- Use AI as a first-class part of your craft. Generation, iteration, variation, retouch, cleanup. Not as a novelty you tried once, but as something already in your daily hands with the taste to know where it lifts the work and where it flattens it. Create Automated systems
- Put things into motion. Not every asset is still.',
   '- 3+ years designing communication assets — in-house or at a studio — with a portfolio that shows range across real surfaces, not ten polished shots of the same thing.
- Serious fundamentals. Type, hierarchy, grid, space, colour. We will look closely at how you set type and how you use space. Trend fluency without foundation doesn’t survive here.
- Figma is non-negotiable. Components, variables, auto-layout, libraries other people can build on.
- Photoshop and Illustrator at working depth. After Effects enough to ship motion without waiting on anyone.
- Native fluency with AI design tools and a clear point of view on where they belong in a professional workflow.
- Proof you can extend a brand system, not only execute inside one. Show us where you took something further than the guidelines went.
- A real stake in this. You should care specifically about what the Indian design ecosystem deserves to look like and be a little impatient that it doesn’t look like that yet.
Bonus points
- 3D, rendering, or generative / code-based design Blender, TouchDesigner, p5, shaders
- Indic typography: setting Devanagari, Tamil, Bengali or Kannada properly, not as an afterthought
- Editorial or publication design
- You’ve shipped a brand extension end to end and lived with the consequences
How to apply
Send us your portfolio. We’ll be looking at three things: how you think, how you set type, and one project where you took a system somewhere it hadn’t gone before. tell us what the constraint was and what you did with it.
careers@sarvam.ai · sarvam.ai
Why Sarvam?
Sarvam is a fast-moving, high talent-density team building full-stack AI for India, working on problems that push the frontiers of AI with real population-scale impact.
- Work alongside researchers, engineers, builders, and business leaders who move fast and hold each other to a very high bar
- High ownership and high impact, from day one',
   'Benefits are listed on the employer''s official job posting.',
   '2026-08-25T10:27:35Z'::timestamptz,
   'https://jobs.ashbyhq.com/sarvam/597119b9-ccb6-4b6e-be0e-39eb185093d0'),
  -- 11. [Graphic Designer] HackerRank - Senior Brand Designer (Bengaluru)
  ('hackerrank',
   'Senior Brand Designer',
   'Graphic Designer',
   'Bengaluru, Karnataka',
   'Karnataka',
   'Hybrid',
   'Full time',
   '6+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Figma', 'Prototyping', 'Interaction Design', 'Typography', 'Animation', 'CSS', 'Communication']::text[],
   'HackerRank helps companies like NVIDIA, Amazon, and Microsoft hire and upskill the next generation of developers based on skills, not pedigree. Our platform is trusted by over 2,500 of the world’s most innovative companies to build strong engineering teams ready for what’s next.
Software has entered an era where humans and AI build side by side. As this shift accelerates, the definition of strong technical talent is changing. We give companies better ways to identify and invest in next-generation skills.
People at HackerRank care deeply about the impact of their work and sweat the small details so our customers can be wildly successful with products they genuinely love to use. We move with urgency and believe great outcomes come from high standards.',
   'HackerRank is looking for a Senior Brand Designer to help shape how our brand shows up across campaigns, content, events and digital experiences. This is a hybrid role based in Bangalore.
Our Brand Experience team is small, hands-on and high impact. We treat every designer as a builder, which means you will not just make things look good. You will have the ownership and agency to take ideas from an early concept all the way to something real and shipped.
You will work across brand campaigns, launches, social, presentations, events and web experiences, while helping evolve how HackerRank shows up in the AI era. You will report to the Brand Design Lead and work closely with marketing, product and senior stakeholders across the company. We are looking for designers who are curious about code, motion, interaction and AI. Designers who can move beyond static assets, prototype ideas quickly and help turn creative direction into live experiences.
This is a rare opportunity to sit at the intersection of brand, design and technology, with the freedom to experiment and the visibility to shape how the world sees HackerRank.
- Own creative projects end to end across campaigns, launches, content, events and digital experiences.
- Turn briefs, strategy and loose ideas into distinctive creative directions and polished outcomes.
- Design across social, presentations, reports, campaigns, events and web.
- Build and ship web experiences in Framer, including pages, components and interactive moments.
- Move fluidly between Figma, Framer and code to prototype quickly and bring ideas to life.
- Use AI tools and agents, including Figma and Framer MCPs, to improve the quality and pace of your work.
- Bring motion, interaction and thoughtful micro-interactions into the brand where they add value.
- Build scalable creative systems that work consistently across channels.
- Collaborate with the Brand Design Lead, marketing, product, engineering, agencies and senior stakeholders.',
   '- 6+ years of experience in brand, visual or communication design, ideally within technology, product or a strong creative environment.
- A portfolio showing strong conceptual thinking, typography, visual storytelling and digital craft.
- Strong proficiency in Figma and Adobe Creative Suite, with hands-on experience designing and shipping websites in Framer.
- Comfort moving between design files, Framer and a code editor, with enough technical fluency to care about how the final experience is built.
- Strong visual judgement, attention to detail and experience owning projects independently from ambiguous brief to final delivery.
- Confidence working with senior and executive stakeholders, even when direction is still evolving.
- A strong understanding of brand systems and how to extend them without making the work feel repetitive.
- Fluency with AI-powered creative tools and agents across research, ideation, prototyping and production.
- High agency, curiosity and a willingness to experiment, learn and figure things out.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-08-19T15:04:11Z'::timestamptz,
   'https://job-boards.greenhouse.io/hackerrank/jobs/8141681'),
  -- 12. [Customer Success] Stripe - Social Media, Customer Support Associate (Bengaluru)
  ('stripe',
   'Social Media, Customer Support Associate',
   'Customer Success',
   'Bengaluru, Karnataka',
   'Karnataka',
   'Onsite',
   'Full time',
   '2-5 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Social Media', 'Excel', 'Communication', 'Problem Solving', 'Collaboration']::text[],
   'Who we are
About Stripe
Stripe is a financial infrastructure platform for businesses. Millions of companies - from the world’s largest enterprises to the most ambitious startups - use Stripe to accept payments, grow their revenue, and accelerate new business opportunities. Our mission is to increase the GDP of the internet, and we have a staggering amount of work ahead. That means you have an unprecedented opportunity to put the global economy within everyone''s reach while doing the most important work of your career.
About the team
Stripe was built with simplicity in mind. We strive to deliver frictionless experiences for all of our users, whether they are an Independent Business, Startup, SMB, or Enterprise and our mission is to provide all Stripe Users with the best support experience possible. Today, Stripe handles over a million support cases per year and processes millions of internal transactions. We’re going to achieve excellence by thinking of support in a novel, solution-oriented way, and viewing operations as an integral enabler of all of Stripe’s growth.
Stripe has unique operational problems resulting from both our type of scale and the type of businesses we partner with as a result of “growing the GDP of the Internet.” Stripes leverage understanding of our products, the financial industry and money movement, and our processes to support both internal and external users.',
   'Stripe is launching Stripe Delivery Centers - a brand new global team to design, implement and grow Stripe’s operations for the next decade. We are looking for dynamic and curious people that have a passion for solving global user issues, building operations, drive process improvement and want to play a front-line role in building this new operational capability for Stripe and accelerating Stripe’s growth. If you like challenging, scaled problems and are an amazing teammate, we want to hear from you!
- Deliver exceptional Stripe experience by efficiently and accurately resolving issues across social media platforms (e.g., X, Linkedin, Facebook, and others)
- Help resolve issues that are escalated via social media, including technical product questions, and work to prevent those issues from happening again.
- Partner with internal teams across Stripe (e.g., Comms, Incident Ops, Risk), serving as the ultimate escalation point for high-stakes user issues and proactively initiating incident reports with a user-first mindset.
- Coordinate executive escalations from Stripe’s leaders with other teams
- Contribute and manage new programs focused on improving the Stripe user experience
- Identify operational process gaps and initiate continuous improvements to accelerate global scale while delivering an exceptional experience for Stripe users.
- Be part of building a brand new team and operational culture for Stripe',
   'We''re looking for someone who meets the minimum requirements to be considered for the role. If you meet these requirements, you are encouraged to apply. The preferred qualifications are a bonus, not a requirement.
- You have 2 - 5 yrs of experience with social media support and/or an interest in resolving user issues through those channels (eg. Twitter, Linkedin, Facebook)
- You have prior experience in customer support and external user facing operations.
- You have a user first mindset and are energized by the challenge of solving difficult problems
- You have excellent communication skills, both written and verbally
- You have a user first mindset and are energized by the challenge of solving difficult problems, leveraging a process-oriented approach and a curiosity for technical products.
- You excel in analytical thinking and problem solving
- You have a process-oriented mindset and ability to get things done
- You enjoy working in an in-office environment with strong cross team collaboration and support
- You are able to prioritize and enjoy working in a quick-moving environment
- You are humble and have a proven track record for working well across teams and with external partners
- You’re willing to work a weekend day for which you will receive a weekday off in lieu; the SDC operates during daytime hours in 9 hour shifts (including 1 hour paid lunch break) scheduled to fall between the hours of 6am and 10pm.
- Prior experience or knowledge in user support
- Prior experience working on projects or process improvement initiatives',
   'Benefits are listed on the employer''s official job posting.',
   '2026-07-15T05:11:09Z'::timestamptz,
   'https://stripe.com/jobs/search?gh_jid=7962437'),
  -- 13. [Sales Executive] Zscaler - Associate Analyst, Business Development Operations (Bengaluru)
  ('zscaler',
   'Associate Analyst, Business Development Operations',
   'Sales Executive',
   'Bengaluru, Karnataka',
   'Karnataka',
   'Hybrid',
   'Full time',
   '2+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['AWS', 'Excel', 'Tableau', 'Salesforce', 'Business Development', 'Agile', 'Communication', 'Collaboration']::text[],
   'Zscaler (NASDAQ: ZS) accelerates digital transformation so customers can be more agile, efficient, resilient, and secure. The Zscaler Zero Trust Exchange™️ platform protects thousands of customers from cyberattacks and data loss by securely connecting users, devices, and applications in any location. Distributed across 160+ public exchanges globally and thousands of private exchanges at the edge, the SASE-based Zero Trust Exchange is the world’s largest in-line cloud security platform.
We believe the future of work is Human + AI and are building an AI-native enterprise where human potential is amplified by machine intelligence to solve the world’s hardest security challenges. Driven by deep customer obsession, we are committed to the mission, outcome, and to each other. We bring these commitments to life through three core behaviors: ownership and collaboration, trust through outcomes and impact, and a challenge culture with ongoing feedback. Ready to make an impact at the company pioneering security transformation in the AI era? Join us at Zscaler.
Role
We are looking for an Associate Analyst, Business Development Operations to join our team. This is a Hybrid, Bangalore role, reporting to the Manager, Business Development Operations in the Business Development department.',
   '- Create and enhance Salesforce reports and dashboards to monitor business performance and surface actionable insights
- Own end-to-end delivery of ad-hoc analytics and account mapping requests from the Business Development team, from scoping through insights delivery
- Perform ad-hoc, weekly, monthly, and quarterly analytics to support Business Development organizational needs
- Plan, manage, and deliver operational programs that improve engagement and effectiveness with Technology Partners
- Serve as analytical backbone for the US-based Business Development team while collaborating with India-based Business Intelligence, Sales Operations, Marketing Operations, and other cross-functional teams',
   '- You thrive in ambiguity, comfortably building the path forward in a dynamic environment and seeing uncertainty as an opportunity to construct meaningful solutions.
- You act like an owner with a strong bias for action, operating with integrity and seamlessly navigating between high-level strategy and hands-on execution to break down complex goals into deliverable milestones.
- You are a structured problem-solver who tackles complex challenges with analytical rigor, defining success criteria, anticipating risks, and adapting plans to deliver high-impact outcomes.
- You are a high-trust collaborator who excels at aligning cross-functional, global teams through transparent communication and constructive feedback to clear blockers and maintain momentum.
- You are a continuous learner with a growth mindset, proactively seeking feedback and development opportunities to expand your capabilities and elevate team performance.
- Foundational understanding of AI/ML technologies and experience leveraging, securing, or positioning AI-driven solutions to optimize outcomes within your functional domain
- Engineering or MBA degree, with 2+ years of relevant sales or business operations experience in the software industry
- Demonstrated capability to interpret and translate requirements and goals into a structured analytical approach and methodology
- Technical proficiency with daily, expert-level experience using Salesforce (SFDC), Tableau, Microsoft Excel, and Google Sheets
- Knowledge and operational experience with the AWS marketplace
- Experience utilizing AI-driven analytics tools, automated workflow scripts, or predictive modeling within Salesforce and spreadsheet ecosystems
- Demonstrate a proven ability to leverage AI technologies and workflows to drive measurable operational efficiency
- Exceptional ability to organize data, derive actionable insights, maintain high accuracy, and adhere to strict timelines',
   'Benefits are listed on the employer''s official job posting.',
   '2026-07-29T10:53:53Z'::timestamptz,
   'https://job-boards.greenhouse.io/zscaler/jobs/5189982007'),
  -- 14. [Software Engineer] GitLab - Engineering Manager (Bengaluru)
  ('gitlab',
   'Engineering Manager',
   'Software Engineer',
   'Bengaluru, Karnataka',
   'Karnataka',
   'Onsite',
   'Full time',
   'Not specified',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Recruitment']::text[],
   'GitLab is the intelligent orchestration platform for DevSecOps. GitLab enables organizations to increase developer productivity, improve operational efficiency, reduce security and compliance risk, and accelerate digital transformation. More than 50 million registered users and more than 50% of the Fortune 100* trust GitLab to ship better, more secure software faster.
The same principles built into our products are reflected in how our team works: we embrace AI as a core productivity multiplier, with all team members expected to incorporate AI into their daily workflows to drive efficiency, innovation, and impact. GitLab is where careers accelerate, innovation flourishes, and every voice is valued. Our high-performance culture is driven by our values and continuous knowledge exchange, enabling our team members to reach their full potential while collaborating with industry leaders to solve complex problems. Co-create the future with us as we build technology that transforms how the world develops software.
*Fortune 500® is a registered trademark of Fortune Media IP Limited, used under license. Claim based on GitLab data. Fortune 100 refers to the top 20% ranked companies in the 2025 Fortune 500 list, published in June 2025. Fortune and Fortune Media IP Limited are not affiliated with, and do not endorse products or services of GitLab.
Engineering Manager, Production Engineering - Observability
An overview of this role',
   '- Lead, hire, onboard, and develop a distributed engineering team working asynchronously.
- Set priorities with Site Reliability Engineering, Product Engineering, and GitLab Dedicated teams, and help the team deliver observability services iteratively.
- Own the reliability, scalability, and cost of the team''s metrics, logging, alerting, and capacity planning platforms.
- Reduce noisy or missing alerts and telemetry gaps, and use SLOs, error budgets, and self-service instrumentation to help engineers maintain the health of their services.
- Guide technical decisions about time-series storage, high-cardinality metrics, log pipelines, and distributed tracing.
- Participate in the Incident Manager On Call (IMOC) rotation, coordinating the response to high-severity incidents affecting GitLab.com.
- Keep the team''s on-call rotation sustainable through coverage across time zones, useful runbooks, better alerts, and follow-through on post-incident actions.
- Use AI tools and agents to support engineering workflows and incident triage, reviewing their output while engineers retain responsibility for decisions.
What you’ll bring
- Experience leading an observability, platform engineering, or site reliability engineering team operating at scale, including supporting people in a distributed, asynchronous environment.
- Technical knowledge of metrics systems such as Prometheus and long-term storage, logging platforms such as Elasticsearch or cloud-native services, and alerting design.
- Experience using SLOs, error budgets, and capacity forecasts to make reliability and investment decisions.
- Experience operating a large software-as-a-service platform and investigating production issues such as telemetry gaps, ingestion limits, or noisy and missing alerts.
- Experience participating in and improving production on-call rotations, including incident coordination and balancing operational load with project work.',
   'See the official job posting for detailed requirements.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-26T10:14:32Z'::timestamptz,
   'https://job-boards.greenhouse.io/gitlab/jobs/8799044002'),
  -- 15. [Digital Marketing] Swiggy - Manager - Growth & Storefront (Bengaluru)
  ('swiggy',
   'Manager - Growth & Storefront',
   'Digital Marketing',
   'Bengaluru, Karnataka',
   'Karnataka',
   'Hybrid',
   'Full time',
   '4-5 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['SQL', 'Excel', 'Tableau', 'Data Visualization', 'Product Management', 'Communication', 'Problem Solving']::text[],
   'Ways of working: Mandate 3 : Onsite - Office / Field: Employees are expected to work from the office on all days out of their respective base locations.
About Swiggy Instamart :
Swiggy Instamart, is building the convenience grocery segment in India. We offer more than 40000 items to our customers within 10-15 mins. We are striving to augment our consumer promise of enabling unparalleled convenience by making grocery delivery instant and delightful.',
   '- P&L & Growth Metrics: Own the marketing budget and key performance indicators (KPIs) such as Customer Acquisition Cost (CAC), Retention, and Brand Health metrics.
- Digital Storefront & Merchandising: Own the "homepage" and category pages of the app. You will decide CTR and AOV
- Funnel Optimization & CRO: Monitor the user journey from "App Install" to "Order Placed." You will be responsible for identifying drop-off points and implementing A/B tests on checkout flows, search results, and product display pages (PDPs) to increase conversion.
- Pricing & Promotion Engine: Execute the pricing strategy for the target segment. You will manage the backend configuration of coupons, "slash-pricing," and bundle deals, ensuring they are psychologically appealing and technically seamless.
- App Store Optimization (ASO): Own the brand’s presence on the Apple App Store and Google Play Store. Optimize keywords, screenshots, and descriptions to ensure high organic discoverability and a high "Install-to-Visit" ratio.
- Continuous Growth Engine: Design and execute "Growth Hacks"—identifying non-linear ways to scale (e.g., community-led referral loops, gamified savings, or strategic cross-brand partnerships) to ensure the brand doesn''t lose momentum after the initial hype
- Retention & In-App Triggers: Design and manage automated in-app notifications, "Nudge" banners, and gamified elements to keep target users coming back without expensive re-acquisition costs.
- Inventory & Catalog Sync: Work with the supply chain team to ensure the app reflects real-time stock availability
- Data Instrumentation: Partner with engineering to ensure all user actions are tracked via tools like Google Tag Manager, Clevertap, or Mixpanel, giving the GTM Lead a 360-degree view of campaign performance.',
   '- Experience: 4-5 years in E-commerce Category Management, Growth Product Management, or App Merchandising. Experience in food-tech, grocery-tech, or mass-market D2C brands is a huge plus.
- Result oriented, data forward and a problem solving approach towards business with a key eye on Customer, Consumer and Category Insight.
- Tech Marketing Hybrid: You must be comfortable with "No-Code" dashboarding, CMS tools, and marketing automation platforms.
- Analytical Prowess: Expert-level skills in Excel/SQL and data visualization tools (Tableau/PowerBI). You should be able to find the "why" behind the numbers.
- Data-Driven Decision Making: Proficiency in marketing analytics tools to derive insights from complex data sets and iterate on strategies in real-time.
- Strong communicator: Excellent written and verbal communication skills to craft and deliver the right message, to the right people, at the right time.
- Ability to manage short term needs with long term strategic bets
- Tenacity to develop ideas independently and thrive in a fast-paced start-up environment',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-26T13:32:39Z'::timestamptz,
   'https://jobs.smartrecruiters.com/SWIGGY/6000000001439222-manager-growth-storefront-'),
  -- 16. [Sales Executive] Swiggy - Sales Manager II (Mysuru)
  ('swiggy',
   'Sales Manager II',
   'Sales Executive',
   'Mysuru, Karnataka',
   'Karnataka',
   'Onsite',
   'Full time',
   '0-2 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Excel', 'Market Research', 'Negotiation', 'Business Development', 'Problem Solving']::text[],
   'Swiggy is India''s leading on-demand delivery platform with a tech-first approach to logistics and a solution-first approach to consumer demands. With a presence in 500 cities across India, partnerships with hundreds of thousands of restaurants, an employee base of over 5000, a 2 lakh+ strong independent fleet of Delivery Executives, we deliver unparalleled convenience driven by continuous innovation.
A Sales Manager owns the acquisition and engagement of single-outlet independent restaurants across an assigned city. You are the primary touchpoint for these restaurants—learning their business, understanding their challenges, and building a partnership where you help the restaurant partner directly drive their growth in orders, visibility, and customer engagement. This role is Consultative & On-Field and requires you to be resourceful, adaptable, and genuinely invested in your partners'' success. You''ll develop consultative sales skills, learn restaurant operations intimately, and build the foundation for scaling your career.',
   '● Own a defined geographic territory: build strong and successful relationships with the assigned restaurant partners
● Field-intensive engagement: Conduct in-person visits, walking restaurants through product demos, ROI analysis, and present how working with Swiggy is a mutually beneficial relationship
● Consultative selling: Diagnose restaurant needs through questions about their current channels, delivery logistics, marketing spend, and business goals. Position Swiggy’s products as solutions, not features
● Relationship management: Manage the full lifecycle each month, pitching, negotiation, activation, and ongoing support to the restaurant partner
● Data-driven problem solving: Track adoption metrics, identify why restaurants aren''t growing, troubleshoot issues, and course-correct
● Revenue responsibility: Own targets within your territory; track your own pipeline and conversion rates
● Excel mastery: all the data related to your day-to-day work will be on the city and central trackers, so you must have advanced knowledge of Excel/Googlesheet/WSP
● Market research: Stay updated on restaurant trends, competitive landscape, and local market dynamics. Feedback from the field informs product direction 80 to 90 In-person meetings with restaurant partners a month',
   '● 0-2 years in B2B sales, field sales, or business development (preferably in FMCG, food/beverage, or hotel industry)
● Track record of meeting or exceeding targets and managing your own pipeline
● Restaurant Business is a round-the-clock business; the role holder has to take ownership of the growth of the assigned portfolio of restaurant partners.
● Comfort with data, especially Excel—you should be able to build pivot tables, use VLOOKUP, and create dashboards without help
● Post - Graduated preferably in marketing or sales',
   'Benefits are listed on the employer''s official job posting.',
   '2026-08-10T07:06:32Z'::timestamptz,
   'https://jobs.smartrecruiters.com/SWIGGY/6000000001299599-sales-manager-ii')
) as v(slug, title, category, location, state, work_mode, employment_type, experience, salary_min, salary_max, salary, skills, description, responsibilities, requirements, benefits, posted_at, source_url)
join public.companies c on c.slug = v.slug
where not exists (select 1 from public.jobs j where j.source_url = v.source_url);

commit;

-- Verify: select location, count(*) from public.jobs where state = 'Karnataka' and apply_type = 'external' group by location order by location;

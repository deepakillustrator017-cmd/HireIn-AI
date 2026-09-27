-- HireIn AI: real external job openings - Telangana
-- Cities: Hyderabad 15, Warangal 0 (target was 15 per city; only postings that are genuinely open were imported).
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
  ('Sutherland', 'sutherland', 'Business Process & Digital Services', 'https://www.sutherlandglobal.com', 'https://www.google.com/s2/favicons?domain=sutherlandglobal.com&sz=128', 'Hyderabad', 'Telangana', 'Hyderabad, Telangana', 'Sutherland (Business Process & Digital Services). Official careers: https://careers.smartrecruiters.com/Sutherland', true),
  ('Freshworks', 'freshworks', 'SaaS', 'https://www.freshworks.com', 'https://www.google.com/s2/favicons?domain=freshworks.com&sz=128', 'Hyderabad', 'Telangana', 'Hyderabad, Telangana', 'Freshworks (SaaS). Official careers: https://careers.smartrecruiters.com/Freshworks', true),
  ('ServiceNow', 'servicenow', 'Enterprise Software', 'https://www.servicenow.com', 'https://www.google.com/s2/favicons?domain=servicenow.com&sz=128', 'Hyderabad', 'Telangana', 'Hyderabad, Telangana', 'ServiceNow (Enterprise Software). Official careers: https://careers.smartrecruiters.com/ServiceNow', true),
  ('New Relic', 'new-relic', 'Observability Software', 'https://newrelic.com', 'https://www.google.com/s2/favicons?domain=newrelic.com&sz=128', 'Hyderabad', 'Telangana', 'Hyderabad, Telangana', 'New Relic (Observability Software). Official careers: https://newrelic.com/about/careers', true),
  ('HighRadius', 'highradius', 'Fintech SaaS', 'https://www.highradius.com', 'https://www.google.com/s2/favicons?domain=highradius.com&sz=128', 'Hyderabad', 'Telangana', 'Hyderabad, Telangana', 'HighRadius (Fintech SaaS). Official careers: https://boards.greenhouse.io/highradius', true),
  ('Swiggy', 'swiggy', 'Consumer Technology', 'https://www.swiggy.com', 'https://www.google.com/s2/favicons?domain=swiggy.com&sz=128', 'Hyderabad', 'Telangana', 'Hyderabad, Telangana', 'Swiggy (Consumer Technology). Official careers: https://careers.smartrecruiters.com/Swiggy', true),
  ('Zscaler', 'zscaler', 'Cloud Security', 'https://www.zscaler.com', 'https://www.google.com/s2/favicons?domain=zscaler.com&sz=128', 'Hyderabad', 'Telangana', 'Hyderabad, Telangana', 'Zscaler (Cloud Security). Official careers: https://www.zscaler.com/careers', true)
on conflict (slug) do nothing;

-- 2. Jobs (15), linked to companies by slug
insert into public.jobs (company_id, company, title, category, location, state, work_mode, employment_type, experience, salary_min, salary_max, salary, currency, skills, description, responsibilities, requirements, benefits, posted_at, source_url, apply_url, apply_type, apply_label, status, featured, logo)
select c.id, c.name, v.title, v.category, v.location, v.state, v.work_mode, v.employment_type, v.experience, v.salary_min, v.salary_max, v.salary, 'INR', v.skills, v.description, v.responsibilities, v.requirements, v.benefits, v.posted_at, v.source_url, v.source_url, 'external', 'Apply on Company Website', 'published', false, c.logo_url
from (values
  -- 1. [QA Engineer] Sutherland - Lead -Quality Assurance (Email Abuse) (Hyderabad)
  ('sutherland',
   'Lead -Quality Assurance (Email Abuse)',
   'QA Engineer',
   'Hyderabad, Telangana',
   'Telangana',
   'Onsite',
   'Full time',
   '3+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Excel', 'Stakeholder Management', 'Communication']::text[],
   'At Sutherland we are a group of energetic and driven individuals. If you are looking to build a fulfilling career and are confident you have the skills and experience to help us succeed, we want to work with you!
Role Summary
A Quality Analyst – Email Abuse within the Trust & Safety team will be responsible for ensuring the accuracy, consistency, and effectiveness of decisions made while identifying and addressing abusive, fraudulent, and malicious email activity.
The role involves conducting regular audits, identifying quality and policy gaps, supporting calibration sessions, performing root cause analysis, and providing actionable feedback to Operations and Training teams.
The Quality Analyst will work across email abuse scenarios such as spam, phishing, scams, malicious content, impersonation, spoofing, account compromise, and other forms of email-based abuse, ensuring decisions are aligned with client policies, SOPs, and applicable Trust & Safety standards.',
   '1. Audit Planning & Execution
- Conduct Daily/Weekly/Monthly quality audits of Email Abuse cases based on defined sampling guidelines.
- Ensure adequate coverage across different case types, risk levels, workflows, and escalation categories.
- Perform audits on agent decisions to assess accuracy, policy adherence, investigation quality, and appropriate enforcement actions.
- Conduct Live, Recorded, and Side-by-Side evaluations as required.
- Ensure audit completion within defined QA SLAs.
- Identify critical errors and immediately escalate high-risk or policy-sensitive cases.
2. Quality Assurance & Monitoring
- Maintain adherence to defined sampling, audit, and agent-feedback SLAs.
- Evaluate cases for correct identification and classification of email abuse.
- Assess the accuracy of decisions involving:
- Spam and unsolicited email
- Phishing
- Scams and fraudulent communications
- Malicious or suspicious links
- Impersonation and spoofing
- Account compromise
- Malicious attachments or content
- Abuse of email services
- Identify trends in quality defects, policy misses, investigation errors, and incorrect enforcement decisions.
- Conduct Root Cause Analysis (RCA) for recurring or high-impact quality issues.
- Recommend corrective action plans and targeted coaching for repeated performance gaps.
- Track improvement following corrective actions.
3. Calibration & Consistency Management
- Participate in regular calibration sessions with QA, Training, Operations, and SME teams.
- Ensure consistent interpretation and application of Email Abuse policies.
- Participate in client and cross-location calibration sessions where applicable.
- Identify policy ambiguity and gray-area cases requiring clarification.
- Document calibration outcomes and communicate changes to relevant stakeholders.
- Support Gage R&R / Repeatability & Reproducibility exercises, where applicable, to assess consistency and reliability of quality evaluations.
4.',
   '- Bachelor''s degree in any stream.
- 1.5–3 years of experience in Quality Assurance, preferably within Trust & Safety, Email Abuse, Fraud Operations, Risk Operations, Content Moderation, or Policy Enforcement.
- Experience conducting transaction/case-level audits and providing structured feedback.
- Strong understanding of quality metrics, sampling, audit methodology, and RCA.
- Ability to interpret and apply policy consistently across complex and ambiguous cases.
- Good understanding of Email Abuse concepts such as spam, phishing, scams, spoofing, impersonation, malicious links, and account compromise.
- Strong analytical, decision-making, and problem-solving skills.
- Good written and verbal communication skills.
- Ability to work effectively with Operations, Training, Policy, and SME teams.
- Proficiency in MS Excel and PowerPoint is preferred.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-02T05:56:51Z'::timestamptz,
   'https://jobs.smartrecruiters.com/Sutherland/744000146893979-lead-quality-assurance-email-abuse-'),
  -- 2. [DevOps Engineer] Freshworks - Lead Software Engineer - Site Reliability (Hyderabad)
  ('freshworks',
   'Lead Software Engineer - Site Reliability',
   'DevOps Engineer',
   'Hyderabad, Telangana',
   'Telangana',
   'Onsite',
   'Full time',
   '12+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Docker', 'Kubernetes', 'CI/CD', 'Linux']::text[],
   'Organizations everywhere struggle under the crushing costs and complexities of “solutions” that promise to simplify their lives. To create a better experience for their customers and employees. To help them grow. Software is a choice that can make or break a business. Create better or worse experiences. Propel or throttle growth. Business software has become a blocker instead of ways to get work done.
There’s another option. Freshworks. With a fresh vision for how the world works.
At Freshworks, uptime is sacred. As a Lead Site Reliability Engineer (SRE), you''ll be the engineer behind the curtain—designing for resilience, automating recovery, and ensuring our systems stay fast, stable, and observable at scale. You’ll partner closely with engineering, platform, and product teams to shift reliability left and set the standard for performance and availability.
If you live for clean telemetry, root cause resolution, and engineering chaos into confidence, this is your playground.',
   '- Design and implement tools to improve availability, latency, scalability, and system health.
- Define SLIs/SLOs, manage error budgets, and drive performance engineering efforts.
- Build and maintain automated monitoring, alerting, and remediation pipelines.
- Collaborate with engineering teams to improve reliability by design.
- Lead incident response, root cause analysis, and blameless postmortems.
- Champion observability across services—logs, metrics, traces.
- Contribute to infrastructure architecture, automation, and reliability roadmaps.
- Advocate for SRE best practices across teams and functions.',
   '- 7–12 years of experience in SRE, DevOps, or Production Engineering roles.
- Coding Proficiency: Develop clear, efficient, and well-structured code.
- Linux Expertise: In-depth knowledge of Linux for system administration and advanced troubleshooting.
- Containerization & Orchestration: Practical experience with Docker and Kubernetes for application deployment and management.
- CI/CD Management: Design, implement, and maintain Continuous Integration and Continuous Delivery pipelines.
- Security & Compliance: Understand security best practices and compliance in infrastructure.
- High Availability & Scalability: Design and implement highly available, scalable, and resilient distributed systems.
- Infrastructure as Code (IaC) & Automation: Proficient in IaC tools and automating infrastructure provisioning and management.
- Disaster Recovery (DR) & High Availability (HA): Deep knowledge and practical experience with various DR and HA strategies.
- Observability: Implement and utilize monitoring, logging, and tracing tools for system health.
- System Design (Distributed Systems): Design complex distributed systems with a focus on reliability and operations.
- Problem-Solving & Troubleshooting: Excellent analytical and diagnostic skills for resolving complex system issues.
- Degree in Computer Science, Engineering, or related field.
- Experience building and scaling services in production with high uptime targets (99.99%+).
- Clear track record of reducing incident frequency and improving response metrics (MTTD/MTTR).
- Strong communicator who thrives in high-pressure environments.
- Passionate about automation, chaos engineering, and making things just work.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-25T07:15:59Z'::timestamptz,
   'https://jobs.smartrecruiters.com/Freshworks/744000151772990-lead-software-engineer-site-reliability'),
  -- 3. [Data Analyst] ServiceNow - Staff Data Engineer (Hyderabad)
  ('servicenow',
   'Staff Data Engineer',
   'Data Analyst',
   'Hyderabad, Telangana',
   'Telangana',
   'Onsite',
   'Full time',
   '8+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Python', 'SQL', 'Machine Learning', 'CRM', 'Collaboration']::text[],
   'It all started when engineer Fred Luddy wrote code that automated a tedious task for his coworker, Phyllis. She cried tears of joy. That moment inspired Fred to build a company that could do that for everyone—freeing people from busywork so they could focus on meaningful work. Today, ServiceNow is the AI control tower for business reinvention. Our ServiceNow AI platform brings together any AI, any data, and any workflow— helping 85% of the Fortune 500® work smarter, faster, and better.
Role summary
The Staff Data Engineer designs, builds, and operates the data foundation and the evaluation infrastructure behind ServiceNow CRM Agentic AI. The role has two halves that reinforce each other. The first is conventional but demanding data engineering: architecture, pipelines, and transformation across structured and unstructured sources, held to production standards of reliability and quality. The second is newer and rarer: building the measurement layer that tells product and AI teams whether an AI agent actually did its job.
That second half changes the nature of the work. Agent behavior is probabilistic, so quality cannot be asserted, only measured—against metrics that have to be defined before they can be tracked, and against ground truth that someone has to establish and defend.',
   'See the official job posting for the full list of responsibilities.',
   '- Data engineering depth. 8+ years in data engineering, with a record of owning production data platforms end-to-end. Depth and demonstrated judgment matter more than tenure.
- Domain ownership. Demonstrated ownership of a data domain or platform, including architecture decisions, migrations, and the operational consequences of both.
- Evaluation infrastructure experience. Hands-on experience building measurement or evaluation infrastructure for machine learning or AI systems: evaluation pipelines, benchmark harnesses, quality dashboards, or golden datasets. This is the gating requirement for the role.
- Ground truth and labeling. Experience defining ground truth and running or directing labeling work, including guideline authoring and annotator agreement.
- Core technical stack. Production Python, strong SQL, distributed processing, workflow orchestration, a cloud data platform, and infrastructure-as-code, with continuous integration and on-call experience.
- Standard setting. Evidence of setting standards that others adopted, such as design standards, quality gates, or validation frameworks, rather than only meeting standards already in place.
- CRM and Order domain familiarity. Sales CRM, lead-to-cash, or order data familiarity, at a depth sufficient to judge whether an evaluation dataset reflects how sellers and agents actually work.
- Internal programs. Demonstrated experience in internal evaluation programs and patterns such as automated evaluation suites, data kits, or AI data factory approaches.
- Mentorship and generalization. Mentorship of junior engineers, and a record of generalizing a solution so that it was reused across teams or products.
- Education. Bachelor''s degree in computer science, engineering, or a related technical field, or equivalent practical experience.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-08-26T09:57:57Z'::timestamptz,
   'https://jobs.smartrecruiters.com/ServiceNow/744000145702469-staff-data-engineer'),
  -- 4. [Backend Developer] ServiceNow - Senior Staff Data Platform Software Engineer (Java Distributed Systems & Kafka) (Hyderabad)
  ('servicenow',
   'Senior Staff Data Platform Software Engineer (Java Distributed Systems & Kafka)',
   'Backend Developer',
   'Hyderabad, Telangana',
   'Telangana',
   'Hybrid',
   'Full time',
   '20+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Java', 'MySQL', 'PostgreSQL', 'Kubernetes', 'Unit Testing', 'Leadership']::text[],
   'It all started when engineer Fred Luddy wrote code that automated a tedious task for his coworker, Phyllis. She cried tears of joy. That moment inspired Fred to build a company that could do that for everyone—freeing people from busywork so they could focus on meaningful work. Today, ServiceNow is the AI control tower for business reinvention. Our ServiceNow AI platform brings together any AI, any data, and any workflow— helping 85% of the Fortune 500® work smarter, faster, and better.
Overview
The Data Platform group builds highly scalable, high‑performance platform capabilities for data‑in‑motion and backend storage systems. Our customers operate at massive scale, pushing the boundaries of data volume, throughput, and concurrency. We are looking for a seasoned IC5 Senior Staff Engineer with deep expertise in distributed systems and Data Lake architectures to drive next‑generation platform innovation.
Role Summary
As an IC5 Senior Staff Engineer, you will architect and deliver large‑scale distributed platform components, lead complex technical initiatives, and define engineering best practices. You will bring strong leadership, hands-on engineering depth, and the ability to design and operate reliable, scalable, and high‑performance data systems.',
   '- Architect, design, and build high‑performance distributed systems and platform components.
- Build distributed systems data ingestion solutions with strong emphasis on scalability, quality, and operational excellence.
- Deliver high‑quality, clean, modular, and reusable code while enforcing engineering best practices (code reviews, unit testing, automation, design reviews).
- Build foundational libraries, frameworks, and tools focused on modularity, extensibility, configurability, and maintainability.
- Collaborate across engineering teams to refine requirements and deliver end‑to‑end solutions.
- Provide technical leadership for projects with significant complexity and risk.
- Research, evaluate, and adopt new technologies that enhance platform capabilities.
- Troubleshoot and diagnose complex production issues across distributed systems.',
   'Experience Level
• 15–20 years of hands‑on engineering experience in distributed systems, data platforms, or large‑scale backend infrastructure.
Core Engineering Expertise
- Strong fundamentals in distributed systems architecture, design patterns, and algorithms.
- Deep programming expertise in Java, including JVM internals, memory models, and garbage collection.
- Proven experience in JVM performance tuning, profiling, and diagnosing performance bottlenecks.
- Strong understanding of concurrency, networking, sockets, OS internals, and performance optimization.
- Hands-on experience building and operating large‑scale distributed systems.
- Experience with relational databases such as Oracle, MySQL, or PostgreSQL.
Distributed Systems Expertise
- Experience with large‑scale deployments of distributed systems.
- Deep knowledge of replication, fault-tolerant, and HA strategies.
- Experience working in DevOps environments to operationalize distributed platforms.
- Strong expertise in designing and architecting platforms using:
- Kubernetes (workload deployments, upgrades, monitoring and maintenance)
- Apache Iceberg (tables, catalogs, schema evolution, metadata management) is a plus
- Apache Kafka (high‑scale clusters, topic/partition strategies, HA) is a plus
- Apache Flink (stateful stream processing, exactly‑once semantics) is a plus
- Apache Spark (batch & streaming jobs, optimization, partitioning) is a plus
- Expertise in data formats such as Parquet, ORC, and Avro, along with compaction and governance strategies.
- Ability to build scalable, fault‑tolerant ingestion and transformation workflows.
- Experience integrating Data Lakes with analytics engines, query services, or ML platforms.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-22T06:38:46Z'::timestamptz,
   'https://jobs.smartrecruiters.com/ServiceNow/744000150942129-senior-staff-data-platform-software-engineer-java-distributed-systems-kafka-'),
  -- 5. [Full Stack Developer] Freshworks - Lead Software Engineer - Full Stack (Hyderabad)
  ('freshworks',
   'Lead Software Engineer - Full Stack',
   'Full Stack Developer',
   'Hyderabad, Telangana',
   'Telangana',
   'Onsite',
   'Full time',
   '5-8 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['REST APIs', 'Agile', 'Problem Solving']::text[],
   'Organizations everywhere struggle under the crushing costs and complexities of “solutions” that promise to simplify their lives. To create a better experience for their customers and employees. To help them grow. Software is a choice that can make or break a business. Create better or worse experiences. Propel or throttle growth. Business software has become a blocker instead of ways to get work done.
There’s another option. Freshworks. With a fresh vision for how the world works.
At Freshworks, we build uncomplicated service software designed to eliminate friction and reduce business complexity. As a Lead Full Stack Engineer (IC3), you will be the driving force turning this vision into high-performance software—engineering robust backend systems and responsive frontend layers that deliver exceptional customer and employee experiences at scale.
Impact You Can Create
- Eliminate Enterprise Complexity: Demolish the crushing cost and complexity of legacy systems by building clean, modular, and intentionally simple full-stack software architectures.
- Drive Frictionless Support: Deliver people-first AI features and optimized workflows that empower nearly 75,000 global companies to lower their cost-to-serve and provide faster, more human support.
- Build for Global Trust: Architect enterprise-grade CX and IT solutions that scale effortlessly to handle millions of transactions for household brands like Bridgestone, Sony Music, and New Balance.',
   '- Full-Stack Execution: Design, develop, and maintain robust backend microservices, optimized database schemas, and highly interactive frontend application interfaces.
- Full Lifecycle Ownership: Own end-to-end delivery of core product modules—from initial requirement gathering and system design to automated deployment, monitoring, and production support.
- Code Quality & Best Practices: Write clean, extensible, and testable code based on solid Object-Oriented Programming (OOP) concepts and SOLID design principles.
- Cross-Functional Partnership: Collaborate closely with Product Managers, UX Designers, and SRE teams to convert product strategies into high-value platform capabilities fast.
- Production Governance: Ensure backend and frontend infrastructure are tuned for high availability, multi-tenant fault tolerance, security compliance, and comprehensive observability.
- Performance Optimization: Proactively identify and resolve multi-tier performance bottlenecks, from database execution bottlenecks to client-side page rendering latencies.
- Technical Mentorship: Drive engineering best practices across the track, conduct thorough code reviews, and mentor junior-to-mid-level systems engineers.',
   '- Full-Stack Engineering: Deep technical fluency across backend technologies (REST APIs, microservices, caching layers) and modern frontend development frameworks.
- Core CS Foundations: Strong expertise in Data Structures, Algorithms (DSA), and analyzing time/space complexity trade-offs.
- System Design (HLD/LLD): Proven capability to design scalable, highly available, and fault-tolerant end-to-end multi-tenant systems.
- Data Modeling Rigor: Experience designing database schemas and managing distributed storage layers (RDBMS, NoSQL, and queuing systems).
- AI Tool Fluency: Exposure and experience working with or integrating AI tools to streamline technical execution and user workflows.
- Problem Solving & Articulation: Exceptional analytical logic with a demonstrated capability to break down complex business problems and clearly convey technical design alternatives.
- Professional Timeline: 5 to 8 years of progressive experience building and scaling software products within fast-paced product engineering teams.
- Production Track Record: A verifiable history of shipping enterprise-grade SaaS features at scale and supporting them through successive production iterations.
- Execution Style: A proactive self-starter who thrives in agile environments, navigates ambiguity effectively, and actively balances fast feature delivery with long-term code health.
- Education Baseline: Degree in Computer Science, Engineering, or a related technical field.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-07-13T10:49:36Z'::timestamptz,
   'https://jobs.smartrecruiters.com/Freshworks/744000137424679-lead-software-engineer-full-stack'),
  -- 6. [Product Designer] New Relic - Manager, Product Design: Application Observability (Hyderabad)
  ('new-relic',
   'Manager, Product Design: Application Observability',
   'Product Designer',
   'Hyderabad, Telangana',
   'Telangana',
   'Hybrid',
   'Full time',
   '8+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Figma', 'Design Systems', 'Prototyping', 'Recruitment', 'Communication']::text[],
   'We are a global team of innovators and pioneers dedicated to shaping the future of observability. At New Relic, we build an intelligent platform that empowers companies to thrive in an AI-first world by giving them unparalleled insight into their complex systems. As we continue to expand our global footprint, we''re looking for passionate people to join our mission. If you''re ready to help the world''s best companies optimize their digital applications, we invite you to explore a career with us!
Your opportunity
New Relic is hiring an on-site design manager for our Hyderabad team, leading design for Application Performance Monitoring (APM) and Log Management — two of the platform''s most used products. APM gives engineering teams full-stack visibility across their applications: connecting traces, metrics, and infrastructure data so they can find what''s breaking and understand why. Log Management is where engineers go to make sense of raw data at scale — ingesting, parsing, and querying log data across their entire stack, without the operational overhead of managing it separately. These are the products engineers open when something is on fire, which means the design work is high-stakes and high-visibility.
This is an on-site role in Hyderabad.',
   '- Manage and develop your designers — run consistent 1:1s including regular career development conversations, give direct and specific feedback, set clear expectations for each person, and invest in their growth. Build a team culture where people feel they belong and different perspectives are welcome. You''ll represent your team in calibration conversations and advocate for their work and careers within the broader design org.
- Own design quality across APM and Logs — review work critically, raise problems before they reach partners, and make sure the team is solving the right problems at the right level of craft. You''re accountable for what ships.
- Keep the user''s perspective in the conversation — design managers at New Relic are the voice of the user in product and engineering discussions. You bring user needs and research insights into roadmap conversations, not just design reviews.
- Partner with PM and Engineering — work with your product and engineering counterparts as a peer. Hold the design perspective, push back when the direction needs it, and communicate design''s value in terms of outcomes the business tracks: adoption, retention, time to value.
- Keep the team focused and on track — manage incoming work, maintain visibility into what''s in flight, help the team balance competing priorities, and set clear expectations with PM and Engineering partners about what''s possible and when.
- Help your team use AI well — stay curious about tools like Figma AI, Claude, and Gemini and how they can help your designers work better: faster exploration, smarter prototyping, better research synthesis. You don''t need to be an expert, but you''re not slowing down experimentation either.
- Contribute IC design work when the work calls for it — you''re an experienced designer, and there are moments where the team needs your hands on a problem. Roll up your sleeves when it''s the right call; delegate when it isn''t.',
   '- Experience with APM, log management, observability, or similar developer-facing infrastructure products
- Familiarity with design systems and when to work within them vs. when to push on them
- Experience hiring and growing a design team over time, not just managing a steady state
- Hands-on curiosity with AI tools — Figma AI, Claude, Gemini, and others — in your own workflow or helping your team adopt them
- Comfort prototyping with code or code-adjacent tools — Cursor, v0, Replit, or similar
Fostering a diverse, welcoming and inclusive environment is important to us. We work hard to make everyone feel comfortable bringing their best, most authentic selves to work every day. We celebrate our talented Relics’ different backgrounds and abilities, and recognize the different paths they took to reach us – including nontraditional ones. Their experiences and perspectives inspire us to make our products and company the best they can be. We’re looking for people who feel connected to our mission and values, not just candidates who check off all the boxes.
If you require a reasonable accommodation to complete any part of the application or recruiting process, please reach out to resume@newrelic.com.
We believe in empowering all Relics to achieve professional and business success through a flexible workforce model. This model allows us to work in a variety of workplaces that best support our success, including fully office-based, fully remote, or hybrid.
Our hiring process
In compliance with applicable law, all persons hired will be required to verify identity and eligibility to work and to complete employment eligibility verification. Note: Our stewardship of the data of thousands of customers means that a criminal background check is required to join New Relic.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-21T09:19:17Z'::timestamptz,
   'https://job-boards.greenhouse.io/newrelic/jobs/5395118008'),
  -- 7. [Customer Success] HighRadius - Design Implementation Consultant (AP) (Hyderabad)
  ('highradius',
   'Design Implementation Consultant (AP)',
   'Customer Success',
   'Hyderabad, Telangana',
   'Telangana',
   'Onsite',
   'Full time',
   '6+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Communication', 'Presentation']::text[],
   'About Us
HighRadius provides a single Agentic AI platform for the Office of the CFO. It integrates 180+ agents that orchestrate end-to-end processes across Order-to-Cash, Close & Reconciliation, Consolidation & Reporting, Accounts Payable, B2B Payments, and Treasury. HighRadius guarantees operational KPI improvements by mapping them to specific agents on the platform. With a 3-6 month go-live period, HighRadius drives value creation at 1300+ enterprises such as 3M, Unilever, Bristol-Myers Squibb Company, Red Bull, Lufthansa, and more. HighRadius has been consistently recognized as a market leader by Gartner, IDC, and Forrester.
Job Summary
The Senior Consultant is responsible for delivering the HighRadius Cloud product implementations of Fortune 1000 clients. He/She will be owning solutioning for client engagements throughout the project life cycle. The Senior Consultant is also responsible for delivering the design for the project on time with high quality, value and inline with Client project objectives. This is a highly visible and complex role since the candidate will be the main point of contact for project design and work with Client SMEs and stakeholders and Client users across client organizations. The candidate must have strong solutioning skills, well organized, detail-oriented, quality-minded and possess excellent written and verbal communication skills.',
   '- Perform blueprint design for one to many client projects for multiple HighRadius products. Gather business requirements, explore solution options, brainstorm solutions with internal team(s) and client team(s) wherever required to finalize design.
- Oversee consultant and through them Data Analyst and Associate Consultant to ensure solution is built per the agreed design.
- Ultimately accountable for project success by ensuring client achieves business value through a well defined solution design and holding the Consultant/Associate Consultant/Data Analyst accountable to outcome metrics.
- Keep the Delivery Manager and/or Program Director honest and up to date on any potential risks related to Solution design and/or Project value.
- Ability to produce actionable deliverables, influencing stakeholders to make informed design and decisions- Act as voice of reason within HRC and client teams.
Skill & Experience Needed
- Bachelor''s or Master’s Degree (preferably from a top reputed university).
- Strong solutioning, presentation and facilitation skills with small and large groups.
- Strong analytical skills with the ability to understand Fortune 1000 client business complexities and solution those.
- Overall 6+ years of professional services experience - Combination of Solutioning and delivery management experience.
- Minimum 2+ years of experience as Solution Architect/Technology Business Analyst or equivalent role preferably in a fast-paced consulting / professional services set-up.
- Experience in following the established processes/standards/templates to achieve successful results.
- Experience with Accounts Payable related business process is desirable
What You’ll Get
- Competitive salary.
- Fun-filled work culture (https://www.highradius.com/culture/)
- Equal employment opportunities.
- Opportunity to build with a pre-IPO Global SaaS Centaur.',
   'See the official job posting for detailed requirements.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-08-18T07:34:33Z'::timestamptz,
   'https://www.highradius.com/about/careers-list/?gh_jid=7825675003'),
  -- 8. [Sales Executive] Swiggy - Sales Manager II (Hyderabad)
  ('swiggy',
   'Sales Manager II',
   'Sales Executive',
   'Hyderabad, Telangana',
   'Telangana',
   'Onsite',
   'Full time',
   'Not specified',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Excel', 'Market Research', 'Negotiation', 'Business Development', 'Problem Solving']::text[],
   'Work Mandate 3 – Employees will work fulltime from their base location i.e. Hyderabad.
About Swiggy Assure
Swiggy Assure is Swiggy& business-to-business (B2B) supply platform designed to provide hotels, restaurants, and caterers (HoReCa) & NonHoreca (D2C brands) with high-quality, fresh, locally sourced kitchen essentials like vegetables,dairy, pulses, and imported goods.
Overview
A Sales Manager owns the acquisition and engagement of single-outlet independent restaurants across an assigned city. You are the primary touchpoint for these restaurants—learning their business, understanding their challenges, and building a partnership where you help the restaurant partner directly drive their growth in orders, visibility, and customer engagement. This role is Consultative & On-Field and requires you to be resourceful, adaptable, and genuinely invested in your partners'' success. You''ll develop consultative sales skills, learn restaurant operations intimately, and build the foundation for scaling your career.',
   'Own a defined geographic territory: build strong and successful relationships with the assigned restaurant partners
Field-intensive engagement: Conduct in-person visits, walking restaurants through product demos, ROI analysis, and present how working with Swiggy is a mutually beneficial relationship
Consultative selling: Diagnose restaurant needs through questions about their current channels, delivery logistics, marketing spend, and business goals. Position Swiggy’s products as solutions, not features
Relationship management: Manage the full lifecycle each month, pitching, negotiation, activation, and ongoing support to the restaurant partner
Data-driven problem solving: Track adoption metrics, identify why restaurants aren''t growing, troubleshoot issues, and course-correct
Revenue responsibility: Own targets within your territory; track your own pipeline and conversion rates
Excel mastery: all the data related to your day-to-day work will be on the city and central trackers, so you must have advanced knowledge of Excel/Googlesheet/WSP
Market research: Stay updated on restaurant trends, competitive landscape, and local market dynamics. Feedback from the field informs product direction
80 to 90 In-person meetings with restaurant partners a month',
   'Experience & Background:
1+ year in B2B sales, field sales, or business development (preferably in fmcg, food/beverage, or hotel industry)
Track record of meeting or exceeding targets and managing your own pipeline
Restaurant Business is a round-the-clock business; the role holder has to take ownership of the growth of the assigned portfolio of restaurant partner
Comfort with data, especially Excel—you should be able to build pivot tables, use VLOOKUP, and create dashboards without help
Post - Graduated preferably in marketing or sales.
We are an equal opportunity employer and all qualified applicants will receive consideration for employment without regards to race, color, religion, sex, disability status, or any other characteristic protected by the law.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-25T10:51:27Z'::timestamptz,
   'https://jobs.smartrecruiters.com/SWIGGY/6000000001438700-sales-manager-ii'),
  -- 9. [Software Engineer] ServiceNow - Staff Software Engineer (Hyderabad)
  ('servicenow',
   'Staff Software Engineer',
   'Software Engineer',
   'Hyderabad, Telangana',
   'Telangana',
   'Hybrid',
   'Full time',
   '9+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['GraphQL', 'CI/CD', 'Machine Learning', 'Accounting']::text[],
   'It all started when engineer Fred Luddy wrote code that automated a tedious task for his coworker, Phyllis. She cried tears of joy. That moment inspired Fred to build a company that could do that for everyone—freeing people from busywork so they could focus on meaningful work. Today, ServiceNow is the AI control tower for business reinvention. Our ServiceNow AI platform brings together any AI, any data, and any workflow— helping 85% of the Fortune 500® work smarter, faster, and better.
The Staff Software Engineer (IC4) on AI-Native ITSM designs, builds, ships, and operates capabilities whose core behavior is model-driven rather than explicitly authored—agentic and conversational experiences that interpret an IT operator''s or end-user''s intent, reason over incident, request, change, and knowledge contexts, invoke tools and workflows, and act on the user''s behalf across the incident-to-resolution and request-to-fulfillment lifecycles. An agent operating on incidents and requests touches SLA compliance, incident classification accuracy, knowledge fidelity, and user trust—a confidently wrong diagnosis is not a suggestion, it is a failed resolution. At IC4 the engineer owns AI design decisions across the domain, not within a single feature, and owns the correctness of what ships whether a person or an agent produced it.',
   'See the official job posting for the full list of responsibilities.',
   'Required Experience and Skills - Production track record: A demonstrated record of building, shipping, and operating production software, including hands-on delivery of AI-native application features that real users depend on. Depth and demonstrated judgment matter more than tenure; typically around 9+ years of relevant software engineering experience. - Agentic delivery experience: Direct experience authoring agentic instructions and prompts, designing AI-driven autonomous workflows, and building the evaluation and testing that verifies them. This is required, not preferred. - Production AI integration: Experience integrating large language model APIs and retrieval-grounded features, including agent orchestration, tool and function calling, and structured output enforcement. - Domain ownership: Demonstrated ownership of a complex domain or subsystem end-to-end, including the architectural decisions, migrations, and operational consequences. - Engineering fundamentals: Strong command of data structures, algorithms, system design, APIs, data modeling, and testing. Proficiency in front-end development with a modern component framework, server-side development, relational data modeling, and REST and GraphQL API design. - Applied machine learning literacy: A working command of the concepts that govern how these systems behave—evaluation, embeddings, and the probabilistic output and failure modes of modern models—sufficient to reason about, debug, and verify model-driven behavior in production. - Accountable use of AI coding agents: Current, effective use of AI coding assistants and agents with evidence of accountable delivery: precise specification, critical review of generated output, and verification harnesses. - Operational experience: Hands-on CI/CD, containerized workloads, and observability experience, plus direct on-call and incident-command experience with customer-facing systems.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-25T09:08:43Z'::timestamptz,
   'https://jobs.smartrecruiters.com/ServiceNow/744000151795504-staff-software-engineer'),
  -- 10. [Digital Marketing] HighRadius - Proprietary Content Creator - ABM II (Hyderabad)
  ('highradius',
   'Proprietary Content Creator - ABM II',
   'Digital Marketing',
   'Hyderabad, Telangana',
   'Telangana',
   'Onsite',
   'Full time',
   '2-5 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Business Development']::text[],
   'About Us
HighRadius, a renowned provider of cloud-based Autonomous Software for the Office of the CFO, has transformed critical financial processes for over 800+ leading companies worldwide. Trusted by prestigious organizations like 3M, Unilever, Anheuser-Busch InBev, Sanofi, Kellogg Company, Danone, Hershey''s, and many others, HighRadius optimizes order-to-cash, treasury, and record-to-report processes, earning us back-to-back recognition in Gartner''s Magic Quadrant and a prestigious spot in Forbes Cloud 100 List for three consecutive years.
With a remarkable valuation of $3.1B and an impressive annual recurring revenue exceeding $100M, we experience a robust year-over-year growth of 24%. With a global presence spanning 8+ locations and a recent addition in Poland, we''re in the pre-IPO stage, poised for rapid growth. We invite passionate and diverse individuals to join us on this exciting path to becoming a publicly traded company and shape our promising future.
Business Development Representative
Business Development / Inside Sales is one of the most critical growth roles at
HighRadius.
We call them - Proprietary Content Creator (PCC)
Why?
PCCs are the face of our company. They understand our buyer''s pain points,
spot the whitespace and help sales reps to deliver ARR
We are hiring Business Development Reps, aka PCCs
The day in the life of a PCC
● Use data chops to segment the accounts and contacts',
   'See the official job posting for the full list of responsibilities.',
   'See the official job posting for detailed requirements.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-03T12:12:19Z'::timestamptz,
   'https://www.highradius.com/about/careers-list/?gh_jid=7805608003'),
  -- 11. [Finance Executive] HighRadius - Payroll Specialist | US/EMEA (Hyderabad)
  ('highradius',
   'Payroll Specialist | US/EMEA',
   'Finance Executive',
   'Hyderabad, Telangana',
   'Telangana',
   'Onsite',
   'Full time',
   '5+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Excel', 'Accounting', 'Payroll', 'Communication', 'Problem Solving']::text[],
   'Payroll Specialist II Job Description

Department: G&A

FLSA Status: Exempt

Reports to: Sr. Director People Ops

Reviewed: January 5, 2025

Job Summary:

The Payroll Specialist will ensure timely and accurate, semi-monthly and monthly payrolls for multiple global legal entities (USA, Canada, United Kingdom, Netherlands, Germany, and France). The ideal candidate should have strong attention to detail and be able to multitask while managing the end-to-end payroll process from data entry to disbursement, ensuring accuracy and timeliness across all global entities.

Your Day-to-Day:

- Payroll Processing: Prepare and timely processing of semi-monthly and monthly payroll transactions. This includes, but is not limited to:

- Variable Compensation: Calculates Performance Bonus Payouts, Enters Commission Payments',
   'Department: G&A
FLSA Status: Exempt
Reports to: Sr. Director People Ops
Reviewed: January 5, 2025
Job Summary:
The Payroll Specialist will ensure timely and accurate, semi-monthly and monthly payrolls for multiple global legal entities (USA, Canada, United Kingdom, Netherlands, Germany, and France). The ideal candidate should have strong attention to detail and be able to multitask while managing the end-to-end payroll process from data entry to disbursement, ensuring accuracy and timeliness across all global entities.
- Payroll Processing: Prepare and timely processing of semi-monthly and monthly payroll transactions. This includes, but is not limited to:
- Variable Compensation: Calculates Performance Bonus Payouts, Enters Commission Payments
- Garnishments: Processes all employee garnishments with assistance of payroll providers
- Benefits: Ensures benefit deductions and company contributions are accurate, calculates deduction catch-ups or recalculations.
- Taxes: Processes tax tax withholdings, salary changes, and deductions, complying with federal, state, and local payroll, wage, and hour laws and best practices
- Process payroll-related changes such as tax filing, 401(k), HSA and other healthcare deduction limits for proper authorization.
- Maintains accurate records and reports of payroll transactions. Creates and runs payroll reports as needed or requested
- Coordinate with Accounting and Finance to ensure the proper reconciliation of payrolls and that month-end close accruals are provided and accurate.
- Providing information, addressing issues, and answering employee questions about payroll related matters, and escalates to manager as needed
- Ensuring employee PTO, and other time off, is tracked properly and approved for payroll processing purposes.
- Maintaining all employee payroll information, files, and records to provide an accurate audit trail for compliance.',
   '- Bachelor’s degree and/or equivalent of 5+ years of payroll experience
- Previous experience in payroll systems such as ADP Workforce Now is required, iiPAY or international payroll system experience is a plus
- Has worked in a fast-paced environment
- Proficiency in MS Excel or Google Sheets is required
- Ability to maintain employee confidence and protect payroll operations by keeping information confidential
- Excellent problem solving/judgment skills, and high level of attention to detail and accuracy
- Strong organizational skills and the ability to work under pressure
- Ability to handle and prioritize multiple tasks and meet all deadlines',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-09T19:45:24Z'::timestamptz,
   'https://www.highradius.com/about/careers-list/?gh_jid=7827536003'),
  -- 12. [Operations Executive] Swiggy - Operations Manager (Hyderabad)
  ('swiggy',
   'Operations Manager',
   'Operations Executive',
   'Hyderabad, Telangana',
   'Telangana',
   'Onsite',
   'Full time',
   '4-6 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Communication', 'Leadership', 'Time Management']::text[],
   'Ways of working: Mandate 3: Office / Field: Employees are expected to work from the office on all days out of their respective base locations
About Swiggy Instamart :
Instamart is building the convenience grocery segment in India. We offer more than 30000 + assortments / products to our customers within 10-15 mins. We are striving to augment our consumer promise of enabling unparalleled convenience by making grocery delivery instant and delightful.',
   '- You will lead a team of area managers to optimize the efficiency of operations and achieve the performance target for these areas. You will assist the management in implementing new strategic initiatives as well as contribute ideas for effectively scaling up the operations in these areas
- You will liaise between the implementation team and the operations strategy team to ensure that all the areas under your focus on order fulfilment, logistics and customer experience. - You will be responsible for leading and managing a huge team, their performance, expectations and goals
- Perform cost analysis and reporting as well as manage schedules, quality initiatives and process change initiatives. Design and manage the execution of the employee retention plan; Responsible for deciding on the staffing and training requirements for all the areas under your purview
- Improve the systems, processes and policies in the operations team to better support management reporting, information flow and relevant business metrics
- Ensure the fleet of delivery executives across areas are disciplined and resolve disputes/strikes that may arise in these areas, warranting an efficient and healthy work environment.
- Support the area managers in the design and rollout of a pay-out structure that motivates and rewards the desired behaviors and performance of delivery executives
- Ensure a flawless delivery service for the customers in your areas with a special focus on real-time service levels and schedule adherence.
- Meet or exceed the customer satisfaction rating target of the delivery fleet in all the areas under your purview
- Provide individual coaching feedback sessions, and have weekly one-on-ones with the area managers that focus on improving customer satisfaction
- Schedule frequent hub visits to ensure compliance in hub operations in all areas; Serve as a leader and point of contact as well as to address issues that are supervisor related or complex in nature',
   '- Postgraduate with 4-6 years'' experience.
- Prior experience in process design and operations implementation (preferably in logistics/supply chain management)
- Strong operational, analytical and numerical skills; Ability to use data effectively for devising operations strategy
- Strong time management skills and the ability to prioritize in order to meet daily, weekly, and long-term requirements and goals
- Must have the ability to multi-task, manage multiple hubs and establish priorities
- Good leadership skills (Experience in managing blue-collared employees is a big plus)
- Passion to deliver a positive customer experience; Ability to maintain composure in difficult situations; Good communication skills
- Attention to detail and ability to critically think through and resolve problems',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-22T05:49:51Z'::timestamptz,
   'https://jobs.smartrecruiters.com/SWIGGY/6000000001427603-operations-manager'),
  -- 13. [DevOps Engineer] Sutherland - COE Head – Infrastructure & Cloud Management (Hyderabad)
  ('sutherland',
   'COE Head – Infrastructure & Cloud Management',
   'DevOps Engineer',
   'Hyderabad, Telangana',
   'Telangana',
   'Onsite',
   'Full time',
   '20+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['AWS', 'GCP', 'Communication', 'Leadership']::text[],
   'About Sutherland
Artificial Intelligence. Automation. Cloud engineering. Advanced analytics. For business leaders, these are key factors of success. For us, they’re our core expertise.
We work with iconic brands worldwide. We bring them a unique value proposition through market-leading technology and business process excellence.
We’ve created over 200 unique inventions under several patents across AI and other critical technologies.',
   'We are seeking an experienced ICM COE Head to lead the offshore Practice and Delivery capability engine for Infrastructure & Cloud Management.
This role will be accountable for solutioning, strategic pursuits, capability development, offerings, engineering assets, accelerators and overall delivery outcomes across the ICM portfolio.
The ideal candidate will combine deep Infrastructure, Cloud Operations and AI-enabled Operations expertise with strong experience in large-deal solutioning, practice building and delivery leadership. The role will work in close partnership with the onsite Practice Head, who owns market development and account shaping.
- Lead the offshore ICM Practice and COE capability organization.
- Own technical strategy for strategic pursuits and RFPs.
- Govern solution architecture, estimation, proposal quality and technical defense.
- Assign and govern Named Solution Owners for qualified opportunities.
- Mobilize federated SMEs across Delivery for pursuits and capability development.
- Build and maintain the ICM capability roadmap.
- Develop and industrialize service offerings, accelerators, tools, methodologies and reference architectures.
- Drive AI-enabled Operations, AIOps, automation and infrastructure modernization capabilities.
- Govern technical partnerships, certifications and hyperscaler specializations.
- Ensure strong linkage between delivery experience, reusable IP and future offerings.
- Own overall delivery health and outcomes through the Delivery Director.
- Govern technical quality, critical escalations and customer-impacting issues.
- Drive productivity, automation, reuse and operational maturity across the delivery portfolio.
- Build the overall Strategy for the Practice in terms of capabilities to invest in and offerings to pursue to help meet the Organization growth targets.',
   '- 20+ years of experience in IT services, infrastructure/cloud services, managed services or consulting.
- Strong Infrastructure, Cloud Operations and AI/AIOps background.
- Significant experience leading large COE, practice or delivery organizations.
- Proven experience in complex RFP solutioning and large-deal technical leadership.
- One large RFP at least won and experience of delivering
- Strong understanding of managed infrastructure and cloud operating models.
- Experience in SRE, observability, automation and AI-enabled operations.
- Demonstrated experience building reusable IP, accelerators or service offerings.
- Experience managing federated SME organizations.
- Strong delivery-governance and customer-escalation experience.
- Experience with AWS, GCP, Oracle and Microsoft ecosystems.
- Strong executive communication and stakeholder-management capability.
- Preferred Experience
AI Infrastructure / GPU Infrastructure | AIOps / Agentic Operations | Cloud Operations | Infrastructure Managed Services | SRE | IT Resilience | Security | DB & Application Operations | Platform Engineering | Large Global SI / MSP',
   'Recruiter Screening Focus
- Large infrastructure/cloud COEs or practices personally led.
- Major RFP solutions personally shaped and defended.
- Delivery organizations managed at scale.
- Offerings or accelerators built and commercialized.
- Automation/AIOps transformation delivered.
- Ability to orchestrate deep SMEs without personally owning every technology domain.
- Measurable improvements in delivery quality, productivity or reuse.
Ideal Candidate Profile
A senior technology-services leader who can solve, win, build capability, govern delivery and convert delivery expertise into scalable IP.',
   '2026-09-08T08:24:11Z'::timestamptz,
   'https://jobs.smartrecruiters.com/Sutherland/744000148163514-coe-head-infrastructure-cloud-management'),
  -- 14. [Backend Developer] Zscaler - Sr. Staff Software Development Engineer - Java/Go + Distributed Systems (Hyderabad)
  ('zscaler',
   'Sr. Staff Software Development Engineer - Java/Go + Distributed Systems',
   'Backend Developer',
   'Hyderabad, Telangana',
   'Telangana',
   'Hybrid',
   'Full time',
   '7+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Python', 'Java', 'SQL', 'Redis', 'GraphQL', 'AWS', 'Azure', 'Kubernetes']::text[],
   'Zscaler (NASDAQ: ZS) accelerates digital transformation so customers can be more agile, efficient, resilient, and secure. The Zscaler Zero Trust Exchange™️ platform protects thousands of customers from cyberattacks and data loss by securely connecting users, devices, and applications in any location. Distributed across 160+ public exchanges globally and thousands of private exchanges at the edge, the SASE-based Zero Trust Exchange is the world’s largest in-line cloud security platform.
We believe the future of work is Human + AI and are building an AI-native enterprise where human potential is amplified by machine intelligence to solve the world’s hardest security challenges. Driven by deep customer obsession, we are committed to the mission, outcome, and to each other. We bring these commitments to life through three core behaviors: ownership and collaboration, trust through outcomes and impact, and a challenge culture with ongoing feedback. Ready to make an impact at the company pioneering security transformation in the AI era? Join us at Zscaler.
Role
We are looking for a Sr Staff Software Development Engineer to join our team. This is a hybrid role based in Hyderabad, reporting to the Senior Manager of Software Engineering. You will join the Engineering team that built the world’s largest cloud security platform from the ground up.',
   '- Understand how to build and operate high scale systems
- Provide service and product wide architectural guidance, and drive impactful technical decisions
- Establish and enforce best practices for coding, testing, observability, and CI/CD pipelines to maintain high-quality, production-ready services
- Drive cross-team collaboration and lead initiatives in performance optimization, reliability improvements, and adoption of new technologies/tools to accelerate feature velocity',
   '- You thrive in ambiguity. You''re comfortable building the path as you walk it. You thrive in a dynamic environment, seeing ambiguity not as a hindrance, but as the raw material to build something meaningful.
- You act like an owner. Your passion for the mission fuels your bias for action. You operate with integrity because you genuinely care about the outcome. True ownership involves leveraging dynamic range: the ability to navigate seamlessly between high-level strategy and hands-on execution.
- You are a problem-solver. You love running towards the challenges because you are laser-focused on finding the solution, knowing that solving the hard problems delivers the biggest impact.
- You are a high-trust collaborator. You are ambitious for the team, not just yourself. You embrace our challenge culture by giving and receiving ongoing feedback—knowing that candor delivered with clarity and respect is the truest form of teamwork and the fastest way to earn trust.
- You are a learner. You have a true growth mindset and are obsessed with your own development, actively seeking feedback to become a better partner and a stronger teammate. You love what you do and you do it with purpose.
- Foundational understanding of AI/ML technologies and experience leveraging, securing, or positioning AI-driven solutions to optimize outcomes within your functional domain and experience with agentic AI systems and orchestration workflows
- 7+ years of experience in Java/Go coding in a highly distributed and enterprise-scale environment
- Working knowledge of cloud infrastructure services on AWS or Azure
- Strong experience with distributed systems and microservices architecture
- Strong database knowledge of SQL constructs and data modeling
- Strong experience with Identity governance and administration, Access Management',
   'Benefits are listed on the employer''s official job posting.',
   '2026-07-02T03:52:28Z'::timestamptz,
   'https://job-boards.greenhouse.io/zscaler/jobs/5177393007'),
  -- 15. [Full Stack Developer] Freshworks - Staff Engineer - Full Stack (Hyderabad)
  ('freshworks',
   'Staff Engineer - Full Stack',
   'Full Stack Developer',
   'Hyderabad, Telangana',
   'Telangana',
   'Onsite',
   'Full time',
   '10+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['REST APIs', 'AWS', 'GCP', 'CI/CD', 'Communication', 'Leadership']::text[],
   'Organizations everywhere struggle under the crushing costs and complexities of “solutions” that promise to simplify their lives. To create a better experience for their customers and employees. To help them grow. Software is a choice that can make or break a business. Create better or worse experiences. Propel or throttle growth. Business software has become a blocker instead of ways to get work done.
There’s another option. Freshworks. With a fresh vision for how the world works.
At Freshworks, we don’t just ship software—we shape it to be fast, reliable, and refreshingly simple. As a Staff Full Stack Engineer (IC4), you will architect the end-to-end systems that drive our global SaaS products, balancing complex distributed backend infrastructure with highly responsive, scalable frontend applications. You will lead cross-functional technical strategies, champion engineering excellence across teams, and mentor engineers to level up our entire platform ecosystem.
If you obsess over time and space complexity, love breaking down tough, multi-tier architectural problems, and take pride in leading technical execution without losing touch with the code—you’ll feel right at home.
Impact You Can Create
- E2E Platform Evolution: Own and scale foundational full-stack architectures capable of handling millions of transactions while delivering seamless, high-performance web experiences globally.',
   '- Full-Stack Architecture: Architect, build, and maintain scalable backend microservices and extensible REST APIs paired with intuitive, modular frontend application layers.
- Full Lifecycle Ownership: Own the entire software development lifecycle—from gathering functional/non-functional requirements and data modeling to deployment, automation, and production support.
- Code & Design Optimization: Write clean, modular, and testable code optimized for browser rendering efficiency, database execution performance, and space/time complexity.
- Production Governance: Ensure backend and frontend systems are tuned for high availability (99.99%+), multi-tenant fault tolerance, security compliance, and deep observability.
- Cross-Functional Partnership: Collaborate closely with Product Managers, UI/UX designers, and Site Reliability Engineers (SREs) to ship highly localized, value-driven capabilities fast.
- Root-Cause Analysis: Troubleshoot complex full-stack performance bottlenecks in production, from slow database queries to state-management memory leaks.
- Mentorship & Best Practices: Lead architectural reviews, establish development roadmaps, mentor 2–4 engineers, and actively drive OOPS and SOLID design principles across the org.',
   '- Computer Science Foundations: Expert-level grasp of Data Structures & Algorithms (DSA), time/space complexity trade-offs, and Object-Oriented Design (OOD) anchored in SOLID principles.
- System Design (HLD & LLD): Proven capability to design scalable, highly available, and fault-tolerant end-to-end multi-tenant systems, including APIs, web architectures, schemas, and data models.
- Distributed Infrastructure Stack: Solid exposure to RDBMS, NoSQL, caching strategies, microservices architecture, and distributed queuing systems.
- Modern Web Ecosystems: Strong understanding of frontend engineering paradigms, including component lifecycles, state management, and client-side performance optimization.
- Cloud & DevOps Practice: Hands-on experience working with CI/CD automation pipelines, DevOps tooling, and cloud infrastructure platforms (AWS or GCP).
- AI Tool Fluency: Practical exposure and experience using generative AI tools to improve day-to-day coding efficiency and technical exploration.
- Technical Communication: Exceptional logical reasoning with the ability to clearly articulate complex technical thought processes and designs to both engineers and executives.
- Professional Timeline: 10+ years of progressive software engineering experience building and scaling full-stack applications in high-growth product teams.
- Iterative Sourcing History: A proven track record of building complex systems from scratch and steering them through multiple scale iterations in production.
- Pragmatic Delivery: Skilled at balancing rapid feature delivery with long-term code maintainability, clean documentation, and scalability.
- Collaborative Leadership: Experience managing technical initiatives, coordinating cross-functional engineering loops, and mentoring other engineers.
- Education Baseline: Degree in Computer Science, Engineering, or a related quantitative technical field.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-06-27T10:00:09Z'::timestamptz,
   'https://jobs.smartrecruiters.com/Freshworks/744000134600399-staff-engineer-full-stack')
) as v(slug, title, category, location, state, work_mode, employment_type, experience, salary_min, salary_max, salary, skills, description, responsibilities, requirements, benefits, posted_at, source_url)
join public.companies c on c.slug = v.slug
where not exists (select 1 from public.jobs j where j.source_url = v.source_url);

commit;

-- Verify: select location, count(*) from public.jobs where state = 'Telangana' and apply_type = 'external' group by location order by location;

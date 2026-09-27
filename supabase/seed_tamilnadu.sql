-- HireIn AI: real external job openings - Tamil Nadu
-- Cities: Chennai 15, Coimbatore 15, Trichy 0 (target was 15 per city; only postings that are genuinely open were imported).
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
  ('Sutherland', 'sutherland', 'Business Process & Digital Services', 'https://www.sutherlandglobal.com', 'https://www.google.com/s2/favicons?domain=sutherlandglobal.com&sz=128', 'Chennai', 'Tamil Nadu', 'Chennai, Tamil Nadu', 'Sutherland (Business Process & Digital Services). Official careers: https://careers.smartrecruiters.com/Sutherland', true),
  ('Freshworks', 'freshworks', 'SaaS', 'https://www.freshworks.com', 'https://www.google.com/s2/favicons?domain=freshworks.com&sz=128', 'Chennai', 'Tamil Nadu', 'Chennai, Tamil Nadu', 'Freshworks (SaaS). Official careers: https://careers.smartrecruiters.com/Freshworks', true),
  ('Toast', 'toast', 'Restaurant Technology', 'https://pos.toasttab.com', 'https://www.google.com/s2/favicons?domain=toasttab.com&sz=128', 'Chennai', 'Tamil Nadu', 'Chennai, Tamil Nadu', 'Toast (Restaurant Technology). Official careers: https://careers.toasttab.com', true),
  ('Swiggy', 'swiggy', 'Consumer Technology', 'https://www.swiggy.com', 'https://www.google.com/s2/favicons?domain=swiggy.com&sz=128', 'Chennai', 'Tamil Nadu', 'Chennai, Tamil Nadu', 'Swiggy (Consumer Technology). Official careers: https://careers.smartrecruiters.com/Swiggy', true),
  ('Bosch', 'bosch', 'Engineering & Technology', 'https://www.bosch.in', 'https://www.google.com/s2/favicons?domain=bosch.in&sz=128', 'Chennai', 'Tamil Nadu', 'Chennai, Tamil Nadu', 'Bosch (Engineering & Technology). Official careers: https://careers.smartrecruiters.com/BoschGroup', true),
  ('Paytm', 'paytm', 'Fintech', 'https://paytm.com', 'https://www.google.com/s2/favicons?domain=paytm.com&sz=128', 'Coimbatore', 'Tamil Nadu', 'Coimbatore, Tamil Nadu', 'Paytm (Fintech). Official careers: https://jobs.lever.co/paytm', true)
on conflict (slug) do nothing;

-- 2. Jobs (30), linked to companies by slug
insert into public.jobs (company_id, company, title, category, location, state, work_mode, employment_type, experience, salary_min, salary_max, salary, currency, skills, description, responsibilities, requirements, benefits, posted_at, source_url, apply_url, apply_type, apply_label, status, featured, logo)
select c.id, c.name, v.title, v.category, v.location, v.state, v.work_mode, v.employment_type, v.experience, v.salary_min, v.salary_max, v.salary, 'INR', v.skills, v.description, v.responsibilities, v.requirements, v.benefits, v.posted_at, v.source_url, v.source_url, 'external', 'Apply on Company Website', 'published', false, c.logo_url
from (values
  -- 1. [QA Engineer] Sutherland - QA Engineer (Chennai)
  ('sutherland',
   'QA Engineer',
   'QA Engineer',
   'Chennai, Tamil Nadu',
   'Tamil Nadu',
   'Onsite',
   'Full time',
   '5+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['QA Engineer']::text[],
   'About Sutherland
Artificial Intelligence. Automation.Cloud engineering. Advanced analytics.For business leaders, these are key factors of success. For us, they’re our core expertise.
We work with iconic brands worldwide. We bring them a unique value proposition through market-leading technology and business process excellence.
We’ve created over 200 unique inventions under several patents across AI and other critical technologies.
Role Summary
Owns technical testing of agent outputs — accuracy, turnaround-time impact, and regression testing as agents are iterated — feeding the accuracy and completion-time KPIs tracked at the programme level.',
   '- Build test suites validating agent outputs against golden-record datasets across covered processes.
- Track and report accuracy/turnaround-time metrics to support baselining exercises agreed with the business.
- Run regression testing whenever agent/prompt configurations change, to prevent silent accuracy drift in regulated processes.
- Feed findings into the human QA function for final sign-off — this role supports human QA authority on regulated activity with technical evidence, not replaces it.',
   'Required Experience
- 5+ years QA/test engineering experience, ideally including ML/LLM output validation (not just deterministic software testing).
- Experience defining test datasets and accuracy benchmarks for document/text-processing systems.
- Domain process familiarity a plus for building realistic test scenarios.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-02T06:35:16Z'::timestamptz,
   'https://jobs.smartrecruiters.com/Sutherland/744000146896950-qa-engineer'),
  -- 2. [DevOps Engineer] Sutherland - Cloud/Platform Engineer (AWS) (Chennai)
  ('sutherland',
   'Cloud/Platform Engineer (AWS)',
   'DevOps Engineer',
   'Chennai, Tamil Nadu',
   'Tamil Nadu',
   'Onsite',
   'Full time',
   '5+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['AWS', 'Azure']::text[],
   'About Sutherland
Artificial Intelligence. Automation.Cloud engineering. Advanced analytics.For business leaders, these are key factors of success. For us, they’re our core expertise.
We work with iconic brands worldwide. We bring them a unique value proposition through market-leading technology and business process excellence.
We’ve created over 200 unique inventions under several patents across AI and other critical technologies.
Role Summary
Provisions and operates the AWS environment underpinning all agent services — VPC, Fargate clusters, messaging (SNS/SQS), storage (DynamoDB, S3), and monitoring — while supporting cross-cloud calls to Azure AI services.',
   '- Stand up and maintain the internal-access VPC hosting notification/callback infrastructure, message consumers, and session/context storage.
- Manage infrastructure-as-code for repeatable deployment across new builds as they mobilise.
- Own monitoring/observability and alerting for exactly-once processing guarantees.
- Coordinate environment access and security sign-off with IT/security ahead of each pilot — regulatory sign-off may gate certain pilots.
- Support multi-site delivery continuity from an infrastructure resilience perspective.',
   'Required Experience
- 5+ years AWS infrastructure/DevOps experience: Fargate, VPC design, SNS/SQS, DynamoDB, S3, IAM.
- Experience operating infrastructure for a regulated client (audit logging, least-privilege access, data residency awareness).
- Comfortable working within a client-owned AWS account rather than a vendor''s own tenancy.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-02T06:33:56Z'::timestamptz,
   'https://jobs.smartrecruiters.com/Sutherland/744000146898580-cloud-platform-engineer-aws-'),
  -- 3. [Data Analyst] Sutherland - Data Analyst (Chennai)
  ('sutherland',
   'Data Analyst',
   'Data Analyst',
   'Chennai, Tamil Nadu',
   'Tamil Nadu',
   'Remote',
   'Full time',
   '3-7 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Python', 'SQL', 'Azure', 'CI/CD', 'Git', 'Power BI', 'Pandas', 'NumPy']::text[],
   'Artificial Intelligence. Automation. Cloud Engineering. Advanced Analytics.
For Enterprises, these are key factors of success. For us, they''re our core expertise.
We work with global iconic brands. We bring them a unique value proposition through market-leading technologies and business process excellence. At the heart of it all is Digital Engineering - the foundation that powers rapid innovation and scalable business transformation.
Data Engineering & Fabric Development
- Design and develop data pipelines using Microsoft Fabric Data Factory.
- Create and maintain Lakehouse and Warehouse solutions within Microsoft Fabric.
- Implement and manage Bronze, Silver, and Gold Layer architectures.
- Develop scalable ETL/ELT pipelines for ingesting and transforming data from multiple sources.
- Monitor pipeline performance and troubleshoot data quality issues.
Data Modeling
- Design and develop Fact Tables and Dimension Tables following dimensional modeling principles.
- Create and maintain Star Schema and Snowflake Schema data models.
- Define surrogate keys, business keys, and Slowly Changing Dimensions (SCD) where required.
- Optimize data models for reporting and analytics performance.
SQL Development
- Write complex SQL queries for data extraction, transformation, and validation.
- Build views, stored procedures, and reusable query frameworks.
- Perform query optimization and performance tuning.
Python Development',
   'See the official job posting for the full list of responsibilities.',
   'Our most successful candidates will have:
- 3-7 years of experience in Data Analytics, Data Engineering, or Business Intelligence.
- Minimum 2 years of hands-on experience with Microsoft Fabric or Azure-based analytics platforms.
- Proven experience building:
- Fact Tables
- Dimension Tables
- Data Pipelines
- Power BI datasets
- Experience with Microsoft Azure Data Services.
- Experience with Delta Tables and Apache Spark.
- Familiarity with CI/CD and Git-based development.
- Understanding of data governance and lineage concepts.
- Microsoft Fabric Certification preferred:
- DP-600
- DP-700',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-25T17:14:33Z'::timestamptz,
   'https://jobs.smartrecruiters.com/Sutherland/744000151904629-data-analyst'),
  -- 4. [Business Analyst] Freshworks - Lead - Business Analyst (EX SMB) (Chennai)
  ('freshworks',
   'Lead - Business Analyst (EX SMB)',
   'Business Analyst',
   'Chennai, Tamil Nadu',
   'Tamil Nadu',
   'Onsite',
   'Full time',
   '8+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Excel', 'Tableau', 'Data Analysis', 'Salesforce', 'Stakeholder Management', 'Communication', 'Leadership']::text[],
   'Organizations everywhere struggle under the crushing costs and complexities of “solutions” that promise to simplify their lives. To create a better experience for their customers and employees. To help them grow. Software is a choice that can make or break a business. Create better or worse experiences. Propel or throttle growth. Business software has become a blocker instead of ways to get work done.
There’s another option. Freshworks. With a fresh vision for how the world works.
We are seeking a commercially minded and highly analytical Revenue Operations Business Partner to support our SMB sales leaders and teams. In this role, you will act as a trusted operational partner to SMB leadership, helping them understand business performance, improve forecast accuracy, strengthen pipeline execution, and deliver against revenue goals.
This is a hands-on, high-impact role that combines data analysis, operational rigor and business partnering. You will work closely with SMB leaders to identify risks and opportunities, translate data into actionable insights, and ensure the right operating rhythms and processes are in place to drive consistent execution across the business.
You will own and support key Revenue Operations processes including forecasting, pipeline management, performance tracking and business reviews. You will use data from Salesforce and other reporting tools to identify trends, challenge assumptions and help leaders make better, faster decisions.',
   'Forecasting & Pipeline Management
- Partner with SMB sales leaders to drive a consistent and accurate weekly and monthly forecasting process.
- Monitor lead flow, identify risks and gaps, and work with leaders to understand and address the underlying drivers.
- Analyse pipeline health, coverage, conversion, ageing and progression to identify areas requiring action.
- Maintain strong data quality and operational discipline across Salesforce and other sales systems.
Business Performance & Insights
- Provide SMB leaders with clear, actionable insights into business performance, highlighting trends, risks and opportunities.
- Analyse performance across teams, segments and individual reps to identify areas for improvement.
- Develop and maintain reporting and dashboards that give leaders a clear view of their business.
- Translate complex data into simple recommendations and actions for sales leaders and frontline teams.
- Support regular business reviews, QBRs and performance cadences with relevant analysis and insights.
Business Partnering
- Act as a trusted partner to SMB sales leaders, helping them use data to make informed business decisions.
- Build strong relationships with sales managers and understand the operational challenges impacting their teams.
- Challenge assumptions constructively and bring an independent, data-driven perspective to business discussions.
- Help leaders identify opportunities to improve rep productivity, pipeline generation, conversion and overall sales execution.
- Partner with Finance, Marketing, Enablement and other cross-functional teams to align on performance, priorities and actions.
Operational Excellence & Scalability
- Identify opportunities to simplify, automate and improve SMB sales processes and operating rhythms - using AI where relevant.
- Support the rollout and adoption of new Revenue Operations processes, tools and reporting.',
   '- 5–8 years of experience in Revenue Operations, Sales Operations, Business Operations, Strategy, Finance or a similar analytical/business partnering role.
- Experience supporting sales teams in a B2B SaaS or technology environment, ideally within an SMB or high-volume sales organisation.
- Strong commercial and analytical mindset, with the ability to understand the key drivers of sales performance.
- Proven ability to work with sales leaders and turn data into clear, actionable recommendations.
- Strong experience with Salesforce, Excel and business intelligence/reporting tools.
- Excellent problem-solving skills and a strong attention to detail.
- Highly organised, with the ability to manage multiple priorities in a fast-paced environment.
- Strong communication and stakeholder management skills, with the confidence to challenge and influence sales leaders.
- Comfortable working with large datasets and simplifying complex information for senior stakeholders.
- Based in Bangalore, with the ability to work effectively with global teams and stakeholders across multiple time zones.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-15T14:02:22Z'::timestamptz,
   'https://jobs.smartrecruiters.com/Freshworks/744000149615459-lead-business-analyst-ex-smb-'),
  -- 5. [Backend Developer] Toast - Senior Software  Engineer – (Java Full Stack) (Chennai)
  ('toast',
   'Senior Software  Engineer – (Java Full Stack)',
   'Backend Developer',
   'Chennai, Tamil Nadu',
   'Tamil Nadu',
   'Hybrid',
   'Full time',
   '6+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['React', 'Angular', 'Java', '.NET', 'Kotlin', 'SQL', 'AWS', 'CI/CD']::text[],
   'Toast creates technology to help restaurants and local businesses succeed in a digital world, helping business owners operate, increase sales, engage customers, and keep employees happy.',
   '- Independently design and implement well-defined features across the full stack with minimal day-to-day guidance.
- Collaborate with Product Managers, UX designers, QA, and fellow engineers to translate requirements into working software.
- Develop and maintain frontend features using React or Angular, focusing on usability and performance.
- Contribute to backend services using Java, Kotlin, or .NET (expertise in one is sufficient; .NET is not mandatory).
- Build and consume RESTful APIs and integrate with internal systems.
- Write clean, maintainable, and testable code aligned with Toast engineering standards.
- Participate actively in code reviews—both receiving and providing constructive feedback.
- Troubleshoot production and non-production issues within owned areas and contribute to root-cause analysis.
- Use Gradle or Maven, Git, and standard development workflows effectively.
- Apply AI-assisted development tools (e.g., Claude Code, Cursor, Devin) to improve development speed and quality.
- Support team delivery during critical phases when needed, including production issues and urgent fixes.
- Consistently delivers on commitments with predictable cycle time for scoped work.
- Demonstrates ownership of components or features but does not yet own large systems end-to-end.
- Understands and follows established architectural patterns and engineering best practices.
- Proactively communicates progress, risks, and dependencies.
- Seeks feedback and continuously improves technical depth and execution quality.',
   '- A minimum of Bachelor’s degree in any area, or any other related discipline.
- 6+ years of experience in software or full-stack development.
- Strong hands-on experience with frontend frameworks such as React or Angular.
- Solid backend development experience in Java, Kotlin, or .NET.
- Experience building and consuming RESTful APIs.
- Proficiency with Git and modern branching workflows.
- Working knowledge of SQL and NoSQL databases, including basic schema design and querying.
- Experience with cloud platforms, preferably AWS.
- Familiarity with Gradle or Maven for build and dependency management.
- Experience working in Agile/Scrum teams.
- Strong problem-solving skills and attention to code quality.
- Effective written and verbal communication skills.
Nice-to-Have
- Exposure to AI-assisted development tools (Claude Code, Cursor, Devin).
- Basic understanding of CI/CD pipelines and deployment workflows.
- Experience working in a large-scale SaaS or product engineering environment.
AI at Toast
At Toast, one of our company values is that we''re hungry to build and learn. We believe learning new AI tools empowers us to build for our customers faster, more independently, and with higher quality. We provide these tools across all disciplines, from Engineering and Product to Sales and Support, and are inspired by how our Toasters are already driving real value with them. The people who thrive here are those who embrace changes that let us build more for our customers; it’s a core part of our culture.
Our Total Rewards Philosophy
We strive to provide competitive compensation and benefits programs that help to attract, retain, and motivate the best and brightest people in our industry. Our total rewards package goes beyond great earnings potential and provides the means to a healthy lifestyle with the flexibility to meet Toasters’ changing needs. Learn more about our benefits at https://careers.toasttab.com/toast-benefits.
#LI-HYBRID',
   'Benefits are listed on the employer''s official job posting.',
   '2026-06-30T13:58:48Z'::timestamptz,
   'https://careers.toasttab.com/jobs?gh_jid=8022865'),
  -- 6. [Full Stack Developer] Freshworks - Lead Software Engineer - Full Stack (Chennai)
  ('freshworks',
   'Lead Software Engineer - Full Stack',
   'Full Stack Developer',
   'Chennai, Tamil Nadu',
   'Tamil Nadu',
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
   '2026-09-21T07:10:07Z'::timestamptz,
   'https://jobs.smartrecruiters.com/Freshworks/744000150608630-lead-software-engineer-full-stack'),
  -- 7. [Sales Executive] Swiggy - Sales Manager II (Chennai)
  ('swiggy',
   'Sales Manager II',
   'Sales Executive',
   'Chennai, Tamil Nadu',
   'Tamil Nadu',
   'Onsite',
   'Full time',
   '0-2 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Excel', 'Market Research', 'Negotiation', 'Business Development', 'Problem Solving']::text[],
   'Swiggy is India’s leading on-demand delivery platform with a tech-first approach to logistics and a solution-first approach to consumer demands. With a presence in 500+ cities across India, partnerships with hundreds of thousands of restaurants, an employee base of over 5000, a 2 lakh+ strong independent fleet of Delivery Executives, we deliver unparalleled convenience driven by continuous innovation.
Role:Sales Manager
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
   '2026-09-24T11:29:42Z'::timestamptz,
   'https://jobs.smartrecruiters.com/SWIGGY/6000000001434825-sales-manager-ii-'),
  -- 8. [Software Engineer] Freshworks - Senior Staff Engineer - Systems (Chennai)
  ('freshworks',
   'Senior Staff Engineer - Systems',
   'Software Engineer',
   'Chennai, Tamil Nadu',
   'Tamil Nadu',
   'Hybrid',
   'Full time',
   '12-15 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Python', 'Java', 'Spring Boot', 'CI/CD', 'Linux', 'Product Management', 'Communication', 'Leadership']::text[],
   'Organizations everywhere struggle under the crushing costs and complexities of “solutions” that promise to simplify their lives. To create a better experience for their customers and employees. To help them grow. Software is a choice that can make or break a business. Create better or worse experiences. Propel or throttle growth. Business software has become a blocker instead of ways to get work done.
There’s another option. Freshworks. With a fresh vision for how the world works.
Overview:
As a Senior Staff Engineer, you will serve as a core technical anchor, driving the architectural evolution of Freshworks'' multi-tier SaaS platform. In this role, you will:
- Scale Platform Capabilities: Architect and deliver resilient APIs, microservices, and web-layer platform features that support complex enterprise customer scenarios while drastically improving deployment velocity, system reliability, and low-latency performance.
- Elevate Engineering Discipline: Act as a technical role model and mentor to young, ambitious engineers—fostering a culture rooted in clean coding standards, robust systems thinking, and long-term product ownership.
- Bridge Business & Technology: Partner closely with cross-functional leaders across Architecture, Product Management, Design, QA, Operations, and Customer Success to turn high-level business visions into seamlessly integrated, high-performing software solutions.',
   '- Architecture & Roadmap Execution: Own and deliver the technical roadmap for your engineering domain; design, document, and execute scalable, cost-efficient, and low-latency platform solutions.
- Hands-on Development: Write clean, maintainable, and high-performance code, building APIs and core platform features that scale seamlessly alongside Freshworks’ global growth.
- System Health & Tech Debt Management: Identify critical architectural bottlenecks and technical debt; design and drive practical, iterative refactoring plans without compromising business delivery.
- Operational Excellence & Production Leadership: Take ownership of complex production issues in distributed SaaS environments, driving deep-dive root-cause analyses (RCA) and implementing permanent preventive safeguards.
- Quality & Process Standardization: Establish rigorous engineering standards through code reviews, automated testing, and CI/CD pipeline integration to continuously raise the quality bar.
- Mentorship & Talent Development: Coach and develop engineers across functions, elevating their problem-solving capabilities, systems thinking, and operational discipline.
- Security & Compliance: Ensure all platform designs and team practices strictly align with Freshworks information security standards and regulatory compliance protocols.',
   '- Education: Bachelor’s Degree in Computer Science, Software Engineering, a related technical field, or equivalent practical experience.
- Experience: 12 to 15 years of hands-on software engineering and systems/platform engineering experience within modern distributed SaaS environments.
- Architectural Ownership: Proven track record of owning end-to-end architecture and technical strategy for large-scale products or core platform infrastructure.
- Production Scale: Demonstrated history of building, shipping, and maintaining high-availability, low-latency, and high-throughput systems operating under assertive deployment schedules.
- Cross-Functional Leadership: Extensive experience collaborating with and influencing multi-disciplinary teams (Product, QA, Ops, Design) to drive consensus and alignment.
- Core Backend Expertise: Expert-level mastery in Java (Spring/Spring Boot) or Python for high-scale backend services development.
- Distributed Systems Architecture: Deep proficiency in multi-tier application architecture, microservices design, RESTful APIs, messaging queues, and database layer optimization.
- CS Fundamentals: Exceptional command of data structures, algorithms, advanced Object-Oriented Programming (OOP) concepts, and design patterns.
- SaaS Troubleshooting & Linux: Advanced knowledge of Linux internals, production debugging, log analysis, and system telemetry in distributed Cloud/SaaS setups.
- Engineering Quality & DevOps: Strong experience with CI/CD automation, unit/integration testing frameworks, and writing clean, maintainable code with minimal abstraction.
- Soft Skills & Technical Leadership: Excellent written and verbal communication skills, with the ability to articulate complex technical trade-offs to both technical panels and executive stakeholders.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-22T06:23:34Z'::timestamptz,
   'https://jobs.smartrecruiters.com/Freshworks/744000150937764-senior-staff-engineer-systems'),
  -- 9. [Digital Marketing] Swiggy - City Growth Manager (Chennai)
  ('swiggy',
   'City Growth Manager',
   'Digital Marketing',
   'Chennai, Tamil Nadu',
   'Tamil Nadu',
   'Onsite',
   'Full time',
   '5+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Data Analysis', 'Data Visualization', 'Market Research', 'Project Management', 'Stakeholder Management', 'Communication', 'Leadership', 'Presentation']::text[],
   'About Swiggy Instamart:
Swiggy Instamart, is building the convenience grocery segment in India. We offer more than 30000 + assortments / products to our customers within 10-15 mins. We are striving to augment our consumer promise of enabling unparalleled convenience by making grocery delivery instant and delightful. Instamart has been operating in 100+ cities across India and plan to expand to a few more soon.
We are seeking a strategic and visionary City Growth Manager to lead expansion initiatives and drive sustainable development in Chennai, India. In this pivotal role, you will be responsible for identifying growth opportunities, developing comprehensive expansion strategies, and overseeing the execution of city-level programs that enhance our organizational presence and impact. You will work collaboratively with government agencies, community stakeholders, and internal teams to shape the future of our operations in this dynamic market.
- Develop and execute strategic growth plans to expand organizational presence and market share across Chennai and surrounding regions
- Analyze market trends, demographic data, and competitive landscapes to identify high-potential growth opportunities and areas for expansion
- Build and maintain strong relationships with government officials, municipal authorities, community leaders, and other key stakeholders',
   'See the official job posting for the full list of responsibilities.',
   '- 5+ years of professional experience in city management, urban development, regional expansion, or related strategic roles
- Proven track record of successfully scaling operations and driving measurable growth in competitive markets
- Strong knowledge of urban planning principles, municipal regulations, and local governance structures
- Demonstrated expertise in stakeholder management and relationship building with government and community organizations
- Advanced analytical skills with proficiency in data analysis, market research, and financial modeling
- Experience with project management methodologies and tools for coordinating complex, multi-phase initiatives
- Excellent communication and presentation skills, with the ability to influence diverse audiences
- Strategic thinking capability with a visionary approach to identifying and capitalizing on growth opportunities
- Familiarity with real estate development, infrastructure projects, or property management is preferred
- Knowledge of Chennai''s local market dynamics, regulatory environment, and development landscape is highly valued
- Proficiency with GIS software, urban planning tools, or data visualization platforms is a plus
- Strong organizational and time management skills with the ability to manage multiple priorities simultaneously
- Collaborative leadership style with the ability to work effectively across organizational boundaries
Demonstrated ability to work in a rigorous fast-paced environment with multiple senior stakeholders.
"We are an equal opportunity employer and all qualified applicants will receive consideration for employment without regards to race, colour, religion, sex, disability status, or any other characteristic protected by the law"
We are an equal opportunity employer and all qualified applicants will receive consideration for employment without regard to race, colour, religion, sex, disability status, or any other characteristic protected by the law.',
   'Desired Candidate:
Immense sense of ownership and execution excellence.',
   '2026-09-25T04:59:30Z'::timestamptz,
   'https://jobs.smartrecruiters.com/SWIGGY/6000000001437606-city-growth-manager'),
  -- 10. [Operations Executive] Toast - Senior Specialist, Procurement (Chennai)
  ('toast',
   'Senior Specialist, Procurement',
   'Operations Executive',
   'Chennai, Tamil Nadu',
   'Tamil Nadu',
   'Hybrid',
   'Full time',
   '6+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Branding', 'Communication', 'Collaboration']::text[],
   'Toast creates technology to help restaurants and local businesses succeed in a digital world, helping business owners operate, increase sales, engage customers, and keep employees happy.
We are looking for a strategic, analytical, and highly collaborative Senior Procurement Specialist to manage our indirect procurement efforts. In this role, you will be a true steward of the business, managing a portfolio of $25M+ in indirect spend across key categories including Hardware, Software/SaaS and Professional Services. You will partner closely with internal stakeholders to ensure they have the tools, services, and partnerships they need to succeed.
We operate in a unique environment that combines the fast-paced, builder mentality of a startup with the structured, scalable rigor of a corporate enterprise. If you take immense pride in ownership, lead with curiosity, and know how to deliver impactful savings while making it incredibly easy for your stakeholders to do business, we would love to meet you. This is a hybrid role, blending the flexibility of remote work with in-person collaboration at our Chennai Toast office.',
   '- Drive and execute comprehensive sourcing and category management strategies across Marketing, Branding, Events and Professional Services to align with Toast’s broader financial goals.
- Manage the end-to-end contract lifecycle, negotiating terms that drive measurable cost savings while mitigating risk and protecting the business.
- Champion an exceptional "ease of doing business" by designing frictionless procurement workflows and removing operational roadblocks for internal teams.
- Act as a trusted advisor and business steward, building deep relationships across the organization and guiding stakeholders through the procurement process with empathy and clear communication.',
   '- Bachelor’s degree in business, Supply Chain, Finance, or a related field.
- 6+ years of dedicated experience in indirect procurement, with a strong background in process improvement and Procure-to-Pay (P2P) optimization.
- Deep expertise in category management and contract management.
- Hands-on familiarity with modern procurement and spend management tools, specifically Zip.
- Demonstrated experience implementing AI use cases within procurement to drive automation, efficiency, or deeper data insights.
- Exceptional verbal and written communication skills, paired with the ability to work effectively across multiple concurrent projects in a fast-paced environment.
- Proven experience interacting with, advising, and influencing US-based stakeholders at all levels
- Exceptional verbal and written communication skills, paired with the ability to work effectively across multiple concurrent projects in a fast-paced environment.
- Strong analytical and strategic thinking skills, with a track record of translating complex spend data into actionable initiatives.
- An "ownership" mindset and a natural "learn and be curious" attitude.
- Work timings for the role: 2 PM to 11 PM IST
- This is a hybrid role with 2 days per week in the Chennai office.
What will help you stand out (Nice to Have)
- Experience working in a multinational or high-growth technology company
- Exposure to SOX-compliant or US-listed organizations
- Experience navigating and driving changes in a hybrid culture that balances startup agility with corporate structure (SaaS or tech industry experience is a major plus).
- Relevant industry certifications (e.g., CPSM, CIPS).
AI at Toast
At Toast, one of our company values is that we''re hungry to build and learn. We believe learning new AI tools empowers us to build for our customers faster, more independently, and with higher quality.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-08-26T11:20:08Z'::timestamptz,
   'https://careers.toasttab.com/jobs?gh_jid=8158567'),
  -- 11. [Sales Executive] Swiggy - Sales Manager (Chennai)
  ('swiggy',
   'Sales Manager',
   'Sales Executive',
   'Chennai, Tamil Nadu',
   'Tamil Nadu',
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
   '2026-09-14T06:36:03Z'::timestamptz,
   'https://jobs.smartrecruiters.com/SWIGGY/6000000001404010-sales-manager'),
  -- 12. [Software Engineer] Toast - Principal Software Engineer (Chennai)
  ('toast',
   'Principal Software Engineer',
   'Software Engineer',
   'Chennai, Tamil Nadu',
   'Tamil Nadu',
   'Hybrid',
   'Full time',
   '12+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Java', 'Kotlin', 'SQL', 'GraphQL', 'AWS', 'Azure', 'GCP', 'Agile']::text[],
   'Toast creates technology to help restaurants and local businesses succeed in a digital world, helping business owners operate, increase sales, engage customers, and keep employees happy.
As a Principal Engineer / architect you will be responsible for creating a technical strategy and coordinating the designs for meeting the needs of Toast’s largest restaurant brands. You will partner with Product Managers to develop the technology roadmap that enables enterprise customers to leverage the power of Toast. You will also work closely with technical leaders and implementation teams across the organization to deliver robust, scalable solutions with integrations to customers’ external systems. While the role is primarily internally-facing, it requires infrequent interactions with enterprise customers, listening to their requirements and providing expert guidance as they deploy Toast.
If you’re a technical leader or a solutions architect, experienced with enterprise SaaS, passionate about customer value, and a great collaborator, read on!',
   '- Lead the evolution of Toast’s backend architecture, frameworks, and data models with a strong focus on delivery efficiency, system scalability, and resilience.
- Design and build the next generation of accounting and financial systems using Java, Kotlin, DynamoDB, Pulsar, GraphQL, Big Data tools, and more.
- Define and implement scalable engineering practices, delivery frameworks, and coding standards that raise the technical bar across the org.
- Collaborate cross-functionally with Product, UX, QA, and multiple engineering teams to deliver robust, customer-facing solutions.
- Build and maintain strong partnerships across business units, aligning technology strategies with key company objectives.
- Champion data-driven decision making by developing strategies and prioritizing initiatives with high impact on user and business outcomes.
- Mentor and grow engineers across levels, promoting a culture of inclusivity, continuous learning, and engineering excellence.
- Guide and influence the broader technical roadmap and architecture strategy for Toast.
- Leverage cutting edge AI tools to enhance your development workflow, improve velocity, and help pioneer new approaches to building - contributing to a culture of innovation and productivity across the team',
   '- 12+ years of experience designing and delivering complex, scalable backend systems.
- Proven technical leadership on mission-critical projects, with the ability to influence across multiple teams.
- Strong experience building distributed, event-driven architectures and microservices in Java, Kotlin, Scala, or similar OOP languages.
- Deep understanding of data architecture and schema design; experience with DynamoDB is a plus.
- Hands-on experience with cloud platforms like AWS, GCP, or Azure.
- Strong knowledge of modern database systems (Postgres, SQL Server, DynamoDB).
- Experience working in an Agile/Scrum environment, delivering value continuously.
- Excellent analytical and problem-solving skills; ability to break down complexity and drive solutions that scale.
- A passion for building impactful products with a customer-first mindset.
- Strong interpersonal and leadership skills—respectful, empathetic, humble, and inclusive.
- A growth mindset with a desire to constantly learn and uplift others.
- Comfortable balancing velocity with platform stability and long-term architecture goals.
- Comfortable using AI-powered engineering tools to improve developer productivity, code quality, and technical decision-making, with the ability to critically evaluate and validate AI-generated solutions.
- Demonstrated experience incorporating AI into the software development lifecycle to improve engineering effectiveness, and the ability to champion best practices for responsible, secure, and high-impact AI adoption across engineering teams.
AI at Toast
At Toast, one of our company values is that we''re hungry to build and learn. We believe learning new AI tools empowers us to build for our customers faster, more independently, and with higher quality. We provide these tools across all disciplines, from Engineering and Product to Sales and Support, and are inspired by how our Toasters are already driving real value with them.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-07-01T07:31:05Z'::timestamptz,
   'https://careers.toasttab.com/jobs?gh_jid=8022867'),
  -- 13. [Software Engineer] Bosch - Product Certification Engineer – Power tools (Chennai)
  ('bosch',
   'Product Certification Engineer – Power tools',
   'Software Engineer',
   'Chennai, Tamil Nadu',
   'Tamil Nadu',
   'Onsite',
   'Full time',
   '5+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Project Management', 'Communication', 'Problem Solving', 'Collaboration']::text[],
   'In India, Bosch is a leading supplier of technology and services in the areas of Mobility Solutions, Industrial Technology, Consumer Goods, and Energy and Building Technology. Additionally, Bosch has in India the largest development center outside Germany, for end to end engineering and technology solutions. The Bosch Group operates in India through twelve companies.
Manage power tools product certification for new products and existing products in coordination with test houses, create and track product certification plan for new products.
Transition of Regulation : Integrate new or changed regulations of India including the associated market access requirements into the Power Tools requirements landscape to make them available for stakeholders',
   'See the official job posting for the full list of responsibilities.',
   'Communicates country specific requirements to power tool central certification function with up to date about changes or modifications of national requirements.
Supports local & global business teams with information and interpretation of approval requirements, directives, and standards.
Obtains National Approvals [ex: BIS] for new products. Ensures that all national approval documents, registrations, self-declarations, etc. are available for the product(s) sold in India.
Manages and/or communication with national authorities, local Test Houses and customs
Responsible for internal projects and support plant project management
Support plant for daily maintenance of assigned product category.
Conduct failure analysis and problem solving for products in development and series production
Bachelor or master’s degree in mechanical or electrical engineering
5+ years of professional experience, of which at least 3 years’ experience in engineering related department.
Familiar with country regulations, requirement engineering, Standards, Testing and Certifications for electrical tools is preferred',
   '- Result oriented, careful and conscientious, have initiative and responsibility, good collaboration and communication skill
- Self-motivated, strong ownership, open mind, fast learning and team player.
- Good communication skills in English (reading, writing, speaking).',
   '2026-08-07T11:00:06Z'::timestamptz,
   'https://jobs.smartrecruiters.com/BoschGroup/744000142103929-product-certification-engineer-power-tools'),
  -- 14. [Digital Marketing] Freshworks - Lead - Product Marketing (Chennai)
  ('freshworks',
   'Lead - Product Marketing',
   'Digital Marketing',
   'Chennai, Tamil Nadu',
   'Tamil Nadu',
   'Onsite',
   'Full time',
   '7-9 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Content Creation', 'Data Analysis', 'Market Research', 'Product Management', 'Customer Service', 'Presentation', 'Collaboration']::text[],
   'Organizations everywhere struggle under the crushing costs and complexities of “solutions” that promise to simplify their lives. To create a better experience for their customers and employees. To help them grow. Software is a choice that can make or break a business. Create better or worse experiences. Propel or throttle growth. Business software has become a blocker instead of ways to get work done.
There’s another option. Freshworks. With a fresh vision for how the world works.
Freshworks is hiring a Lead Product Marketer to drive go-to-market strategies, positioning, and adoption across the Freshdesk portfolio. As customer service software rapidly evolves alongside advances in AI and modern CX capabilities, proactive automation, and shifting buyer expectations, staying ahead of market alternatives is critical.
We’re looking for a seasoned SaaS product marketer who can bridge product capabilities with business value, enjoys translating complex AI technology into clear messaging, and thrives working cross-functionally in a fast-moving SaaS environment.',
   '- Develop crisp product positioning and value-driven messaging that differentiates Freshworks solutions in the customer service market.
- Frame technical capabilities into clear, compelling narratives tailored to buyer personas, CX leaders, and executives.
- Lead cross-functional product launches in close collaboration with Product Management, Sales, Marketing, and Enablement teams.
- Lead competitive intelligence across the CX landscape, tracking competitor feature launches, pricing, and GTM moves.
- Develop, scale, and maintain actionable competitive enablement assets, including battlecards, competitive matrices, demos, FAQs, displacement pitch decks, and win/loss analysis. Serve as an SME on direct sales calls, executive briefing centers, and competitive deal desks.
- Create high-impact sales tools, pitch decks, FAQs, demos, and collateral to equip GTM teams with targeted strategies for handling competitor objections, feature gaps, and displacement throughout the buyer journey.
- Partner with Product Management to feed real-time competitive gap insights back into the product roadmap.
- Partner with Demand Generation, Lifecycle Marketing teams, and other PMMs to inject product and competitive positioning into field campaigns, web, content, webinars, and any customer-facing collateral and campaigns.
- Integrate modern AI tools into daily marketing workflows to automate content creation, market research, competitive intelligence, and win/loss data analysis, thereby accelerating output and asset development.
- Stay current on emerging AI technologies and competitive offerings to help shape Freshworks'' AI narrative.',
   '- Any graduate degree (MBA preferred) with 7 to 9 years of prior experience in a similar position.
- Excellent English written, verbal, and presentation skills, with an eye for quality and attention to detail.
- An ability to understand AI, tech, and the customer service domain, including buyer behavior and ideal customer profiles, and translate tech content into marketing material
- Proven track record of planning and executing end-to-end marketing strategies, product launches, customer research, and messaging frameworks.
- Strong messaging and positioning skills, with the ability to simplify technical concepts for both business and technical audiences, complemented by a customer-first mindset supported by strong market research and storytelling abilities.
- Strong expertise in integrating AI into product marketing processes, with hands-on experience using modern AI tools to enhance marketing tasks, content creation, and research workflows.
- Strength in collaborating with cross-functional teams, across geographies, including executive management, product management, operations, sales, and marketing',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-07T11:20:02Z'::timestamptz,
   'https://jobs.smartrecruiters.com/Freshworks/744000147910359-lead-product-marketing'),
  -- 15. [DevOps Engineer] Freshworks - Lead - Data Platform Engineering (Chennai)
  ('freshworks',
   'Lead - Data Platform Engineering',
   'DevOps Engineer',
   'Chennai, Tamil Nadu',
   'Tamil Nadu',
   'Onsite',
   'Full time',
   '8+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Python', 'Java', 'SQL', 'AWS', 'Azure', 'GCP', 'CRM', 'Agile']::text[],
   'Organizations everywhere struggle under the crushing costs and complexities of “solutions” that promise to simplify their lives. To create a better experience for their customers and employees. To help them grow. Software is a choice that can make or break a business. Create better or worse experiences. Propel or throttle growth. Business software has become a blocker instead of ways to get work done.
There’s another option. Freshworks. With a fresh vision for how the world works.
We are looking for highly skilled Data Platform Engineer to design, develop, and deliver enterprise-scale Master Data Management (MDM) and Data Platform solutions. The role will focus on Customer 360, data quality, identity resolution, governance, and cloud-native MDM initiatives across enterprise systems.
The ideal candidate should possess strong expertise in MDM architecture, cloud technologies, data engineering, and enterprise data governance with hands-on technical leadership experience.',
   '- Design, develop, and implement enterprise-wide MDM and Customer 360 solutions using cloud-native MDM platforms.
- Lead technical architecture discussions and drive high-quality engineering delivery.
- Develop scalable data models, match & merge strategies, survivorship rules, hierarchies, and workflow configurations within MDM platforms.
- Build and optimize data pipelines, integrations, mappings, and workflows across CRM, billing, analytics, and downstream systems.
- Drive data quality initiatives including profiling, cleansing, standardization, enrichment, and duplicate resolution.
- Design and develop identity resolution frameworks using enterprise-grade matching algorithms and governance processes.
- Collaborate with business stakeholders, architects, vendors, and engineering teams to translate business requirements into scalable technical solutions.
- Support Customer 360 and AI-ready data foundations leveraging FERN matching, entity resolution, and governance frameworks.
- Develop and support production jobs, operational monitoring, deployment activities, and root cause analysis (RCA).
- Plan infrastructure scalability, reliability, and operational readiness for enterprise data platforms.
- Create data quality rules, workflows, dashboards, and stewardship processes.
- Contribute to release planning, estimations, production support, and continuous platform improvements.
- Mentor junior engineers and contribute to engineering best practices and technical excellence.',
   '- Bachelor’s degree in engineering, Computer Science, or equivalent practical experience.
- 8+ years of experience in Data Engineering, MDM, or Enterprise Data Platform development.
- Strong expertise in Master Data Management concepts including:
- Customer 360
- Match & Merge
- Survivorship
- Identity Resolution
- Hierarchy Management
- Data Governance
- Hands-on experience with one or more MDM platforms such as:
- Reltio
- Informatica MDM
- Other enterprise MDM platforms
- Strong experience in data quality management, profiling, cleansing, standardization, and duplicate detection.
- Expertise in SQL and enterprise data platforms such as:
- Databricks
- Other modern data warehouses
- Strong experience with cloud technologies including AWS, GCP, or Azure.
- Experience building scalable ETL/ELT pipelines and enterprise data integrations.
- Hands-on experience in Python, Java, or Scala is preferred.
- Strong analytical, problem-solving, and communication skills.
- Experience supporting production systems, deployments, monitoring, and operational support.
- Experience with AI-driven MDM, FERN matching, or Customer 360 initiatives.
- Experience with enterprise-scale SaaS or subscription-based platforms.
- Exposure to modern data architecture, Lakehouse platforms, and streaming technologies.
- Experience working in Agile and/or Waterfall delivery models.
- Understanding of data governance, stewardship, and operational monitoring frameworks.
Nice to Have
- Exposure to Agentic AI and AI-powered customer intelligence platforms.
- Experience with metadata management and enterprise data governance tools.
- Knowledge of enterprise architecture review and governance processes.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-08-17T05:35:09Z'::timestamptz,
   'https://jobs.smartrecruiters.com/Freshworks/744000143743519-lead-data-platform-engineering'),
  -- 16. [DevOps Engineer] Bosch - AWS DevOps Support for BHC APAC - HC (Coimbatore)
  ('bosch',
   'AWS DevOps Support for BHC APAC - HC',
   'DevOps Engineer',
   'Coimbatore, Tamil Nadu',
   'Tamil Nadu',
   'Onsite',
   'Full time',
   '6-8 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Python', 'AWS', 'Docker', 'Kubernetes', 'Terraform', 'CI/CD', 'Git', 'Linux']::text[],
   'Bosch Global Software Technologies Private Limited is a 100% owned subsidiary of Robert Bosch GmbH, one of the world''s leading global supplier of technology and services, offering end-to-end Engineering, IT and Business Solutions. With over 27,000+ associates, it’s the largest software development center of Bosch, outside Germany, indicating that it is the Technology Powerhouse of Bosch in India with a global footprint and presence in the US, Europe and the Asia Pacific region.
Job Summary: We are looking for a passionate and proactive DevOps Engineer with hands-on experience in cloud infrastructure, CI/CD, containerization, Kubernetes, and monitoring tools. The ideal candidate should be capable of managing production environments, automating deployments, troubleshooting issues, and continuously improving infrastructure reliability and deployment processes.',
   '- Manage source code repositories using GitHub or Bitbucket, following version control best practices.
- Design, implement, and maintain CI/CD pipelines using Jenkins or GitHub Actions.
- Provision and manage cloud infrastructure on AWS.Manage AWS IAM users, groups, roles, and policies, ensuring secure access management and adherence to the principle of least privilege.
- Build and manage infrastructure using Terraform (preferred).
- Implement and maintain GitOps workflows using Argo CD.Deploy, upgrade, and manage Kubernetes applications using Helm.
- Build, manage, and optimize containerized applications using Docker.
- Monitor application and infrastructure health using OpenSearch, Datadog, Prometheus, and Grafana.
- Analyze application, Kubernetes, and infrastructure logs to identify, troubleshoot, and resolve issues.
- Handle production incidents, perform root cause analysis (RCA), and implement preventive measures.Develop and maintain automation scripts using Bash or Python.
- Collaborate with development, QA, and operations teams to ensure smooth application deployments.
- Automate operational tasks to improve efficiency and reduce manual effort.Maintain system availability, scalability, security, and reliability.
- Document infrastructure, deployment procedures, and operational runbooks.
- Stay updated with emerging DevOps tools, cloud services, and industry best practices.Required SkillsStrong knowledge of Git and version control using GitHub or Bitbucket.
- Experience with CI/CD tools such as Jenkins or GitHub Actions.
- Hands-on experience with AWS cloud services.Experience with Infrastructure as Code (IaC), preferably Terraform.
- Good understanding of GitOps principles and experience with Argo CD.Hands-on experience with Kubernetes and Helm.
- Experience with Docker and containerization concepts.Ability to understand, analyze, and troubleshoot application, Kubernetes, and infrastructure logs.',
   '- Ability to efficiently handle production issues and incident management.
- Strong analytical and problem-solving skills.
- Excellent communication and collaboration skills.Self-driven, proactive, and eager to learn new technologies.
- Ability to work in a fast-paced DevOps environment.
B.E B.Tech',
   '- 6 to 8 years',
   '2026-09-15T13:47:26Z'::timestamptz,
   'https://jobs.smartrecruiters.com/BoschGroup/744000149609680-aws-devops-support-for-bhc-apac-hc'),
  -- 17. [Backend Developer] Bosch - Senior Backend Developer with 5+ years of experience in Java Stack, Python, & AI Integration (Coimbatore)
  ('bosch',
   'Senior Backend Developer with 5+ years of experience in Java Stack, Python, & AI Integration',
   'Backend Developer',
   'Coimbatore, Tamil Nadu',
   'Tamil Nadu',
   'Onsite',
   'Full time',
   '5+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['JavaScript', 'TypeScript', 'React', 'Angular', 'Node.js', 'Python', 'Java', 'SQL']::text[],
   'Bosch Global Software Technologies Private Limited is a 100% owned subsidiary of Robert Bosch GmbH, one of the world''s leading global supplier of technology and services, offering end-to-end Engineering, IT and Business Solutions. With over 27,000+ associates, it’s the largest software development center of Bosch, outside Germany, indicating that it is the Technology Powerhouse of Bosch in India with a global footprint and presence in the US, Europe and the Asia Pacific region.',
   '- Experience in Java Full stack (Angular 18, Java 8+, SpringBoot, Hibernate, Bootstrap, Micro Services)
- Create Python scripts for data processing i.e clear, scalable, and efficient for new & existing applications using Python Modules – NumPy and Pandas
- Development of React JS based chat interface
- Real-time communication using WebSocket / Server-Sent Events (SSE)
- Build and integrate RESTful APIs to connect with other services & able to write and optimizing complex queries.
- Azure AD based authentication
- HTTP / gRPC based communication
- Proficient in scheduling jobs effectively',
   '- BE, B.Tech, MCA
Experience :
- 5+ years of experience in Java Stack, Python, & AI Integration
- Java Full Stack Development and Cloud experience
- Java 8+, SpringBoot, Hibernate, Bootstrap, Micro Services,
- Angular Latest Version
- JavaScript, Bootstrap, HTML5/CSS3, JQuery,
- Node.JS
- GIT, Maven, Jenkins
- AWS or AZURE,
- Database technologies - Oracle / My SQL / No SQL / Mongo DB
- Framework -React JS (Vite / Create React App)
- Language - TypeScript
- UI Library -Material UI / Ant Design
- State Management -Redux Toolkit / React Context
- Agentic AI & Multi-Agent Systems(planning, reasoning, validation, execution)',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-01T13:01:43Z'::timestamptz,
   'https://jobs.smartrecruiters.com/BoschGroup/744000146709740-senior-backend-developer-with-5-years-of-experience-in-java-stack-python-ai-integration'),
  -- 18. [Sales Executive] Paytm - Area Sales Manager - Manager - Lending (LRM) (Coimbatore)
  ('paytm',
   'Area Sales Manager - Manager - Lending (LRM)',
   'Sales Executive',
   'Coimbatore, Tamil Nadu',
   'Tamil Nadu',
   'Onsite',
   'Full time',
   'Not specified',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Communication']::text[],
   'About Us: Paytm is India''s leading mobile payments and financial services distribution company. Pioneer of the mobile QR payments revolution in India, Paytm builds technologies that help small businesses with payments and commerce. Paytm’s mission is to serve half a billion Indians and bring them to the mainstream economy with the help of technology.
About the Team : The Merchant Lending team is one of the fastest-growing business verticals at Paytm, focused on enabling credit access to millions of merchants across India. The team drives credit penetration, loan lifecycle management, and cross-sell of high-value financial products like Gold SIP, Insurance, and other merchant-centric financial Solutions.
About the Role: Paytm is looking for an experienced Sales Leader & People Manager to drive the Merchant Lending business across the assigned region. The role involves scaling merchant loan penetration, strengthening underwriting funnel quality, and unlocking incremental revenue through strategic cross-sell initiatives. Expectations/ Requirements:
1. Grow Merchant Lending penetration and overall credit distribution in the assigned geography.
2.⁠Drive visibility & deployment of lending products—Merchant Loans, BNPL, QR-linked credit, overdraft lines, etc.
3.⁠Lead cross-sell of financial products like Gold SIP, Insurance, and other merchant financial tools to enhance merchant stickiness and revenue-per-merchant.',
   'See the official job posting for the full list of responsibilities.',
   'See the official job posting for detailed requirements.',
   '1. A collaborative output driven program that brings cohesiveness across businesses through technology
2. Improve the average revenue per use by increasing the cross-sell opportunities
3. A solid 360 feedback from your peer teams on your support of their goals
4. Respect, that is earned, not demanded from your peers and manager
With enviable 500 mn+ registered users, 21 mn+ merchants and depth of data in our ecosystem, we are in a unique position to democratize credit for deserving consumers & merchants – and we are committed to it. India’s largest digital lending story is brewing here. It’s your opportunity to be a part of the story!',
   '2026-09-01T07:01:09Z'::timestamptz,
   'https://jobs.lever.co/paytm/8c27b885-4792-4577-8339-a82a027be124'),
  -- 19. [Software Engineer] Bosch - Senior Software developer (Coimbatore)
  ('bosch',
   'Senior Software developer',
   'Software Engineer',
   'Coimbatore, Tamil Nadu',
   'Tamil Nadu',
   'Hybrid',
   'Full time',
   'Not specified',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Python', 'Azure', 'Kubernetes', 'Terraform', 'CI/CD', 'Linux', 'Agile', 'Jira']::text[],
   'Bosch Global Software Technologies Private Limited is a 100% owned subsidiary of Robert Bosch GmbH, one of the world''s leading global supplier of technology and services, offering end-to-end Engineering, IT and Business Solutions. With over 28,200+ associates, it’s the largest software development center of Bosch, outside Germany, indicating that it is the Technology Powerhouse of Bosch in India with a global footprint and presence in the US, Europe and the Asia Pacific region.
We are seeking a skilled Software Devloper / Automation Enginner / Infrastructure Specialist to join our dynamic IT team - Output management Services.
Candidates will:
Drive End-to-End Solutions
- Will be responsible for designing, developing, implementing, and supporting innovative solutions in the areas of ERP, Input & Output Management Services, and digital document processes. You will integrate modern AI and automation technologies into our service landscape and continuously optimize business processes throughout the service lifecycle.
Accelerate Digital Transformation
- Will actively contribute ideas and innovations to enhance our services and processes. Working independently and collaboratively with global teams, you will develop services that improve efficiency, automation, and user experience while driving the organization''s digital transformation journey.
Collaborate Globally
- Will support both technical and strategic initiatives, projects, and service improvements.',
   'See the official job posting for the full list of responsibilities.',
   'Education
- Bachelor’s degree in Computer Science, Information Technology, or related field.
- Advanced Redwood RunMyJobs certifications (preferred).
Additional Information
• Experience with SAP Administration and ERP-related integrations.
• Strong experience with scripting and automation platforms and workflow engines.
o PowerShell, Perl, Python Scripting
o Power Automate
o n8n
o Microsoft Copilot and AI-based automation solutions
• Experience in software development, system integration, and API-based solutions.
• Knowledge of Output Management solutions and document lifecycle management.
• Experience with testing
• Knowledge of DevOps practices and Agile methodologies.
Infrastructure & Operations Knowledge
• Administration and support of Windows, Unix, Linux platform
• Good understanding of:
o Networking concepts and (communication) protocols (TCP/IP, DNS, DHCP, MQTT, Router, Firewalls, VLAN, VPN)
o Enterprise system architectures
o IT Service Management processes (preferably ITIL)
• Strong knowledge of Infrastructure-as-Code and automation
• Experience with Terraform, Ansible, or similar tools
• Knowledge of CI/CD, GitOps, and modern deployment processes
• Experience with multi-cloud or hybrid infrastructures
• Experience with Kubernetes and containerized environments
Personal Competencies
• Structured, independent, and solution-oriented working style.
• Quick learner with a passion for new technologies.
• Team-oriented mindset with strong intercultural collaboration capabilities.
• High sense of ownership and accountability.
Languages
• Excellent written and spoken English.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-23T08:45:52Z'::timestamptz,
   'https://jobs.smartrecruiters.com/BoschGroup/744000151326539-senior-software-developer'),
  -- 20. [Operations Executive] Swiggy - Cluster Operations Manager II (Coimbatore)
  ('swiggy',
   'Cluster Operations Manager II',
   'Operations Executive',
   'Coimbatore, Tamil Nadu',
   'Tamil Nadu',
   'Onsite',
   'Full time',
   '4-6 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Communication', 'Leadership', 'Time Management']::text[],
   'Ways of working: Mandate 3 – Employee will be working from the respective base location of the office/ on field on all the days of the weeks
About Swiggy:
Swiggy is India’s leading on-demand delivery platform with a tech-first approach to logistics and a solution-first approach to consumer demands. With a presence in 500+ cities across India, partnerships with hundreds of thousands of restaurants, an employee base of over 5000, a 2 lakh+ strong independent fleet of Delivery Executives, we delive',
   '- You will lead a team of area managers to optimize the efficiency of operations and achieve the performance target for these areas. You will assist the management in implementing new strategic initiatives as well as contribute ideas for effectively scaling up the operations in these areas.
- You will liaise between the implementation team and the operations strategy team to ensure that all the areas under your focus on order fulfilment, logistics and customer experience.
- You will be responsible for leading and managing a huge team, their performance, expectations and goals.
- Perform cost analysis and reporting as well as manage schedules, quality initiatives and process change initiatives. Design and manage execution of the employee retention plan; Responsible for deciding on the staffing and training requirements for all the areas under your purview.
- Improve the systems, processes and policies in the operations team to better support management reporting, information flow and relevant business metrics
- Ensure the fleet of delivery executives across areas are disciplined and resolve disputes/strikes that may arise in these areas, warranting an efficient and healthy work environment.
- Support the area managers in the design and rollout of a pay-out structure that motivates and rewards the desired behaviors and performance of delivery executives
- Ensure a flawless delivery service for the customers in your areas with special focus on real time service levels and schedule adherence.
- Meet or exceed customer satisfaction rating target of the delivery fleet in all the areas under your purview
- Provide individual coaching feedback sessions, and have weekly one-on-ones with the area managers that focus on improving customer satisfaction
- Schedule frequent hub visits to ensure compliance in hub operations in all areas; Serve as a leader and point of contact as well as to address issues that are supervisor related or complex in nature',
   '- Postgraduate with 4-6 years'' experience.
- Prior experience in process design and operations implementation (preferably in logistics/supply chain management)
- Strong operational, analytical and numerical skills; Ability to use data effectively for devising operations strategy
- Strong time management skills and the ability to prioritize in order to meet daily, weekly, and long-term requirements and goals
- Must have ability to multi-task, manage multiple hubs and establish priorities
- Good leadership skills (Experience in managing blue-collared employees is a big plus)
- Passion to deliver a positive customer experience; Ability to maintain composure in difficult situations; Good communication skills
- Attention to detail and ability to critically think through and resolve problems',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-24T10:31:06Z'::timestamptz,
   'https://jobs.smartrecruiters.com/SWIGGY/6000000001434795-cluster-operations-manager-ii'),
  -- 21. [Software Engineer] Bosch - Embedded_Software_Architect_ECT (Coimbatore)
  ('bosch',
   'Embedded_Software_Architect_ECT',
   'Software Engineer',
   'Coimbatore, Tamil Nadu',
   'Tamil Nadu',
   'Onsite',
   'Full time',
   '10-15 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['C++', 'CI/CD', 'Linux', 'Communication', 'Collaboration']::text[],
   'Bosch Global Software Technologies Private Limited is a 100% owned subsidiary of Robert Bosch GmbH, one of the world''s leading global supplier of technology and services, offering end-to-end Engineering, IT and Business Solutions. With over 27,000+ associates, it’s the largest software development center of Bosch, outside Germany, indicating that it is the Technology Powerhouse of Bosch in India with a global footprint and presence in the US, Europe and the Asia Pacific region.
Looking for an Embedded Software Architect to define and drive scalable, high-quality embedded software architecture. This role requires strong expertise in C/C++ and embedded systems, with working knowledge of connectivity technologies to support connected product development.',
   'See the official job posting for the full list of responsibilities.',
   '•Define end-to-end embedded software architecture (drivers, middleware, application layers).•Design scalable solutions across MCU/SoC platforms, RTOS, and hardware abstraction layers.
•Define communication interfaces and integration strategies across subsystems.
•Architect systems for high performance, low latency, and efficient resource usage.
•Design and support integration of connectivity modules (RF, Wi Fi) into embedded systems.•Assess emerging technologies (AI/ML, GenAI, data platforms) with a focus on improving embedded platform engineering and automation.
•Lead technical discussions and architecture / design reviews.
•Drive innovative initiatives and proof-of-concepts (POCs).•Evaluate emerging tools, frameworks, and connectivity solutions.•Establish and improve CI/CD pipelines for embedded systems.
•Mentor development teams on architecture, best practices, and technical direction•Support teams in debugging complex system-level issues and root cause analysis.
•Strong expertise in Embedded C/C++ development.
•Proven experience in embedded software architecture and system design.
•Experience with modular architecture, and reusable frameworks.
•Hands-on experience with RTOS, drivers, BSP, and low-level system development.
•Ability to analyze tradeoffs between performance, memory, power, and cost.
•Knowledge in secure boot, OTA updates, and cybersecurity concepts.
•Strong analytical thinking and system-level problem-solving capability.
•Familiarity with automation frameworks and DevOps practices in embedded systems.
•Curiosity toward industry trends, emerging technologies, and best practices in software development.
Good to Have:
•ISAQB Certification, Knowledge in Embedded Linux
BE/ME electronics background',
   '10 to 15 years',
   '2026-08-20T06:01:21Z'::timestamptz,
   'https://jobs.smartrecruiters.com/BoschGroup/744000144462528-embedded-software-architect-ect'),
  -- 22. [DevOps Engineer] Bosch - Java Full Stack Developer with DevOps experience (Coimbatore)
  ('bosch',
   'Java Full Stack Developer with DevOps experience',
   'DevOps Engineer',
   'Coimbatore, Tamil Nadu',
   'Tamil Nadu',
   'Onsite',
   'Full time',
   '5+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['JavaScript', 'Angular', 'Node.js', 'Java', 'Spring Boot', 'SQL', 'MySQL', 'Redis']::text[],
   'Bosch Global Software Technologies Private Limited is a 100% owned subsidiary of Robert Bosch GmbH, one of the world''s leading global supplier of technology and services, offering end-to-end Engineering, IT and Business Solutions. With over 27,000+ associates, it’s the largest software development center of Bosch, outside Germany, indicating that it is the Technology Powerhouse of Bosch in India with a global footprint and presence in the US, Europe and the Asia Pacific region.',
   'See the official job posting for the full list of responsibilities.',
   '----------
• Overall 5+ yrs of Software Development experience
• Solid web application development experience using Java and Spring Boot
• Strong SQL and No-SQL databases design experience (Oracle or MySQL/ NoSQL / Mongo)
• Experience in developing RESTful APIs, SOAP and JSON data
• Proficiency in one or more frontend frameworks (Angular Latest Version)
• Hands on experience in JavaScript, Bootstrap, HTML5/CSS3, JQuery
• Strong experience in consuming cloud services like API Gateway, RabbitMQ, Redis, Logic Apps, Active Directory
• Hands on experience in DevOps with setting up CI/CD Pipelines using tools like Git, Jenkins, Maven, JFrog and others
• Hands-on experience in Azure / AWS cloud technologies
• Hands-on experience in AI/ML Technologies would be added advantage
B.E / B.Tech / MCA
Experience :
5+ yrs
- Java Full Stack Development and Cloud experience
- Java 8+, SpringBoot, Hibernate, Bootstrap, Micro Services,
- Angular Latest Version
- JavaScript, Bootstrap, HTML5/CSS3, JQuery,
- Node.JS
- GIT, Maven, Jenkins,
- DevOps,
- AWS or AZURE,
- Database technologies - Oracle / My SQL / No SQL / Mongo DB',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-01T13:02:22Z'::timestamptz,
   'https://jobs.smartrecruiters.com/BoschGroup/744000146711419-java-full-stack-developer-with-devops-experience'),
  -- 23. [Backend Developer] Bosch - Java Application Developer (Coimbatore)
  ('bosch',
   'Java Application Developer',
   'Backend Developer',
   'Coimbatore, Tamil Nadu',
   'Tamil Nadu',
   'Onsite',
   'Full time',
   '4-6 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['CSS', 'JavaScript', 'React', 'Python', 'Java', 'SQL', 'Jira']::text[],
   'Bosch Global Software Technologies Private Limited is a 100% owned subsidiary of Robert Bosch GmbH, one of the world''s leading global supplier of technology and services, offering end-to-end Engineering, IT and Business Solutions. With over 27,000+ associates, it’s the largest software development center of Bosch, outside Germany, indicating that it is the Technology Powerhouse of Bosch in India with a global footprint and presence in the US, Europe and the Asia Pacific region.
Must Have Skills· Must have 4+ yrs of experience in Core Java, RCP, Plugin, SWT, OSGI application development and testing.· Experience with common development and integration tools such as Eclipse IDE, Maven, Jenkins, Sonar· Basic Windows server skills: services, batch files, IIS.· Basic database skills: use database clients and write basic SQL queries · Familiarity with XML, especially use of java XML tools such as Xpath and DOM · Familiarity with JSON, Rest API · Previous experience with JIRA & Confluence or similar systems.· Basic knowledge of HTML5, CSS, Javascript · Ability to work without detailed supervision and to adapt to changing priorities· Ability to communicate with both technical and non-technical people· Willingness to work on legacy codeGood to have Skills· Good to have knowledge in Node JS, React, Remix, electron· Good to have experience Test Automation Frameworks, SWT-BOT· Good to have experience in Hibernate (ORM Framework)· Good to have knowledge in Basic AI, Python scripts',
   'See the official job posting for the full list of responsibilities.',
   'B.E',
   '4 to 6 years experience',
   '2026-08-19T07:58:37Z'::timestamptz,
   'https://jobs.smartrecruiters.com/BoschGroup/744000144249838-java-application-developer'),
  -- 24. [Software Engineer] Bosch - Embedded C++ Developer (Coimbatore)
  ('bosch',
   'Embedded C++ Developer',
   'Software Engineer',
   'Coimbatore, Tamil Nadu',
   'Tamil Nadu',
   'Onsite',
   'Full time',
   '5-7 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['C++', 'Linux']::text[],
   'Bosch Global Software Technologies Private Limited is a 100% owned subsidiary of Robert Bosch GmbH, one of the world''s leading global supplier of technology and services, offering end-to-end Engineering, IT and Business Solutions. With over 27,000+ associates, it’s the largest software development center of Bosch, outside Germany, indicating that it is the Technology Powerhouse of Bosch in India with a global footprint and presence in the US, Europe and the Asia Pacific region.
Proficiency in C++ coding.5 to 7 years of experience in embedded projects . Hands on experience in working with Linux environment.Know how of Cmake and linux build environments like Debain , yocto. Experience in linux kernel space development and application development using C++Good to know: Board bring up and working exp with Polar fire board',
   'See the official job posting for the full list of responsibilities.',
   'BE/B.Tech/ME/M.tech Graduates',
   '5-8 years',
   '2026-08-24T17:15:44Z'::timestamptz,
   'https://jobs.smartrecruiters.com/BoschGroup/744000145331758-embedded-c-developer'),
  -- 25. [DevOps Engineer] Bosch - 2026_CICD_DevOps_Engineer_ProCon_SLA_LGP3 (Coimbatore)
  ('bosch',
   '2026_CICD_DevOps_Engineer_ProCon_SLA_LGP3',
   'DevOps Engineer',
   'Coimbatore, Tamil Nadu',
   'Tamil Nadu',
   'Onsite',
   'Full time',
   '6-9 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Python', 'Git', 'Linux', 'Communication']::text[],
   'Bosch Global Software Technologies Private Limited is a 100% owned subsidiary of Robert Bosch GmbH, one of the world''s leading global supplier of technology and services, offering end-to-end Engineering, IT and Business Solutions. With over 22,700 associates, it’s the largest software development center of Bosch, outside Germany, indicating that it is the Technology Powerhouse of Bosch in India with a global footprint and presence in the US, Europe and the Asia Pacific region.
Dev Ops for Technical Support ProCon
For ProCon we need a DevOps engineer who will take care of the Production, Pilot and Development environments.
• You will be responsible for 24*7 availability of the ProCon application to ensure that production runs without any deviation in the plants
• You will be responsible for the availability of Test and Development environments to ensure that testers and developers can do their job
• You will be the first point of contact for analyzing and troubleshooting the issues
• need experience of the underlying infrastructure and tools for deeper trouble shooting
• You must either solve the issue yourself or coordinate with Dev / Arch / Testing teams to resolve the issue
• You need to acquire enough application knowledge to test if the ProCon application is working correctly
• The main part of your job is the finding, understanding and solving of problems.',
   'See the official job posting for the full list of responsibilities.',
   'o Collaborative working style
? Proficiency in English (C1)
o Independent working style
o Jenkins (multiple years)
? Pipelines development
? Groovy
? Plug-ins like
? Sonarqube
? Bitbucket
? jFrog repositories
? Monitoring integration for tracking the builds
o Scripting experience (multiple years)
? Bash
? Python
o Experience with GitOps tools, e.g. Argo CD
o Experience with Linux
o Experience with Git, e.g., Bitbucket
o DevOps best practices
o Experience with Maven
o Experience with Container technologies in general
B.E/B.Tech/MCA',
   '6-9 Years of Experience',
   '2026-09-01T07:34:22Z'::timestamptz,
   'https://jobs.smartrecruiters.com/BoschGroup/744000146640025-2026-cicd-devops-engineer-procon-sla-lgp3'),
  -- 26. [Software Engineer] Bosch - Embedded_IoT_Architect_ECT (Coimbatore)
  ('bosch',
   'Embedded_IoT_Architect_ECT',
   'Software Engineer',
   'Coimbatore, Tamil Nadu',
   'Tamil Nadu',
   'Onsite',
   'Full time',
   '10-15 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['AWS', 'Azure', 'CI/CD', 'Communication', 'Collaboration']::text[],
   'Bosch Global Software Technologies Private Limited is a 100% owned subsidiary of Robert Bosch GmbH, one of the world''s leading global supplier of technology and services, offering end-to-end Engineering, IT and Business Solutions. With over 27,000+ associates, it’s the largest software development center of Bosch, outside Germany, indicating that it is the Technology Powerhouse of Bosch in India with a global footprint and presence in the US, Europe and the Asia Pacific region.
Looking for an innovative and highly experienced IoT Architect to lead the definition and development of scalable, secure, and robust end-to-end IoT solutions. In this pivotal role, you will bridge the gap between embedded systems, connectivity, and cloud platforms, ensuring seamless integration and optimal performance across the entire IoT ecosystem.',
   'See the official job posting for the full list of responsibilities.',
   '• Define the end-to-end architecture for IoT solutions, encompassing device hardware/firmware, connectivity layers, cloud services, data pipelines, and user interfaces
• Define communication interfaces and integration strategies across subsystems.
• Architect IoT solutions for high performance, low latency, and efficient resource usage.
• Design and implement robust integration patterns between IoT devices and cloud platforms (e.g., AWS IoT, Azure IoT Hub, Google Cloud IoT Core), including device provisioning, authentication, and data ingestion.
• Assess emerging technologies (AI/ML, GenAI, data platforms) with a focus on improving embedded platform engineering and automation.
• Lead technical discussions and architecture / design reviews.
• Drive innovative initiatives and proof-of-concepts (POCs)
.• Evaluate emerging tools, frameworks, and connectivity solutions.
• Establish and improve CI/CD pipelines for embedded systems
.• Mentor development teams on architecture, best practices, and technical direction
• Support teams in debugging complex system-level issues and root cause analysis.
• Proven experience in designing and implementing end-to-end IoT architectures that span embedded devices, connectivity, and cloud layers.
• Hands-on experience with major cloud IoT platforms
• Solid understanding of wireless connectivity technologies
.• Ability to analyze tradeoffs between performance, memory, power, and cost
• Strong analytical thinking and system-level problem-solving capability
• Familiarity with automation frameworks and DevOps practices in embedded systems
• Curiosity toward industry trends, emerging technologies, and best practices in software development
• Extensive experience designing and deploying complex IoT solutions at scale, integrating embedded devices with cloud platforms
Good to Have:
ISAQB Certification, Professional certifications in Cloud Arch.
BE/ME electronics background',
   '10 to 15 years',
   '2026-08-14T13:10:49Z'::timestamptz,
   'https://jobs.smartrecruiters.com/BoschGroup/744000143512564-embedded-iot-architect-ect'),
  -- 27. [Software Engineer] Bosch - Embedded_Software_Architect(Gateway)_ECT (Coimbatore)
  ('bosch',
   'Embedded_Software_Architect(Gateway)_ECT',
   'Software Engineer',
   'Coimbatore, Tamil Nadu',
   'Tamil Nadu',
   'Onsite',
   'Full time',
   '10-15 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['C++', 'CI/CD', 'Linux', 'Communication', 'Collaboration']::text[],
   'Bosch Global Software Technologies Private Limited is a 100% owned subsidiary of Robert Bosch GmbH, one of the world''s leading global supplier of technology and services, offering end-to-end Engineering, IT and Business Solutions. With over 27,000+ associates, it’s the largest software development center of Bosch, outside Germany, indicating that it is the Technology Powerhouse of Bosch in India with a global footprint and presence in the US, Europe and the Asia Pacific region.
Looking for an Embedded Software Architect to define and drive scalable, high-quality embedded software architecture. This role requires strong expertise in C/C++ and embedded systems, with working knowledge of connectivity technologies to support connected product development.',
   '- Translate business and system requirements into technical architecture.
- Define end-to-end embedded software architecture (drivers, middleware, application layers).
- Design scalable solutions across MCU/SoC platforms, RTOS, and hardware abstraction layers.
- Define communication interfaces and integration strategies across subsystems.
- Architect systems for high performance, low latency, and efficient resource usage.
- Ensure compliance with safety, regulatory, and quality requirements
- Design and support integration of connectivity modules (RF, Wi Fi) into embedded systems.
- Assess emerging technologies (AI/ML, GenAI, data platforms) with a focus on improving embedded platform engineering and automation.
- Lead technical discussions and architecture / design reviews.
- Drive innovative initiatives and proof-of-concepts (POCs).
- Evaluate emerging tools, frameworks, and connectivity solutions.
- Establish and improve CI/CD pipelines for embedded systems.
- Mentor development teams on architecture, best practices, and technical direction
- Support teams in debugging complex system-level issues and root cause analysis',
   '- Strong expertise in Embedded C/C++ development on Linux environments
- Proven experience in embedded software architecture and system design.
- Hands-on experience with major cloud IoT platforms
- Experience with modular architecture, and reusable frameworks
- Hands-on experience with RTOS, drivers, BSP, and low-level system development.
- Ability to analyze tradeoffs between performance, memory, power, and cost
- Knowledge in secure boot, OTA updates, and cybersecurity concepts
- Strong analytical thinking and system-level problem-solving capability
- Good communication, technical mentoring, and cross-functional collaboration skills
- Familiarity with automation frameworks and DevOps practices in embedded systems
- Curiosity toward industry trends, emerging technologies, and best practices in software development
- Extensive experience with Embedded C/C++ programming for Linux environments, gateway product development, covering aspects like kernel modules, device drivers, inter-process communication (IPC), and integration with IoT cloud platforms.
- Good to Have ISAQB Certification
- BE/ME electronics background',
   '- 10 to 15 years',
   '2026-08-14T13:07:34Z'::timestamptz,
   'https://jobs.smartrecruiters.com/BoschGroup/744000143513848-embedded-software-architect-gateway-ect'),
  -- 28. [Software Engineer] Bosch - ServiceNow Service Portal Developer (Coimbatore)
  ('bosch',
   'ServiceNow Service Portal Developer',
   'Software Engineer',
   'Coimbatore, Tamil Nadu',
   'Tamil Nadu',
   'Onsite',
   'Part time',
   '5+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Figma', 'CSS', 'JavaScript', 'Angular', 'REST APIs']::text[],
   'Bosch Global Software Technologies Private Limited is a 100% owned subsidiary of Robert Bosch GmbH, one of the world''s leading global supplier of technology and services, offering end-to-end Engineering, IT and Business Solutions. With over 28,200+ associates, it’s the largest software development center of Bosch, outside Germany, indicating that it is the Technology Powerhouse of Bosch in India with a global footprint and presence in the US, Europe and the Asia Pacific region.
Specialized ServiceNow Service Portal Developer to lead the UI/UX transformation of our platform. You will focus exclusively on building modern, high-performance Service Portals, Employee Centers, and custom UI components. This role requires an expert front-end developer who understands the unique architecture of the ServiceNow Portal framework and can build complex, custom widgets from scratch.',
   '- Widget Architecture: Design, clone, code, and maintain highly interactive, reusable Service Portal widgets from scratch.
- UI/UX Customisation: Translate wireframes and Figma designs into responsive pixel-perfect portal pages using Bootstrap and CSS/SASS.
- Portal Core Development: Manage portal configurations, including search sources, theme definitions, main menus, headers, footers, and CSS inclusions.
- Full-Stack Portal Scripting: Write efficient client controllers (AngularJS), server scripts (JavaScript/GlideRecord), and link functions.
- User Experience Optimization: Implement advanced portal features like real-time data updates, dynamic forms, and asynchronous data loading via GlideAjax.
- Mobile Responsiveness: Ensure all portal pages and custom widgets are fully responsive and optimized for mobile devices and tablets.
- Performance Tuning: Troubleshoot and resolve slow portal page load times, widget rendering bottlenecks, and browser compatibility issues.',
   '- ServiceNow Portals: Expert-level knowledge of the Service Portal framework, widget editor, and standard portal tables.
- JavaScript Frameworks: Deep proficiency in AngularJS (1.x), native JavaScript, and JSON data manipulation.
- Front-End Styling: Advanced mastery of HTML5, CSS3, and Bootstrap 3/4.
- API Utilization: Strong experience utilizing ServiceNow REST APIs to fetch and display external data within portal widgets.
- Angular Providers: Proven experience creating custom Angular Services, Directives, and Factories within the ServiceNow environment.
BE, ME, B.Tech, M.Tech, BCA, MCA, B.Sc, MSC',
   '5+ yrs',
   '2026-08-31T05:00:43Z'::timestamptz,
   'https://jobs.smartrecruiters.com/BoschGroup/744000146393239-servicenow-service-portal-developer'),
  -- 29. [Software Engineer] Bosch - SAP Senior Architect / Senior Expert (Coimbatore)
  ('bosch',
   'SAP Senior Architect / Senior Expert',
   'Software Engineer',
   'Coimbatore, Tamil Nadu',
   'Tamil Nadu',
   'Onsite',
   'Full time',
   '8-15 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Business Development', 'Agile', 'Customer Service', 'Leadership']::text[],
   'Bosch Global Software Technologies Private Limited is a 100% owned subsidiary of Robert Bosch GmbH, one of the world''s leading global supplier of technology and services, offering end-to-end Engineering, IT and Business Solutions. With over 27,000+ associates, it’s the largest software development center of Bosch, outside Germany, indicating that it is the Technology Powerhouse of Bosch in India with a global footprint and presence in the US, Europe and the Asia Pacific region.
SAP Senior Architect / Senior Expert who will be responsible for designing, implementing and optimizing SAP technical solutions. He/She will provide Subject Matter Expertise with regards to technical architecture designs, applications, platforms etc. Proficient in analyzing business requirements, architecture solutions and leading implementation teams to deliver successful projects. Plays vital role in building competency framework, designing technical training programs, driving organizational initiatives, Possessing the leadership qualities in mentoring, coaching and developing teams and capable of articulating and presenting the topics to the higher management.',
   '- 8 to 15 years Years of experience and expertise in SAP Technical areas - SAP S/4 ABAP on HANA, SAP UI5, SAP Fiori, OOPs, SAP ABAP, Adobe Forms, Interface frameworks, SAP BTP cloud platform.
- Strong working experience in SAP implementation, rollout, upgrade, migration and support projects
- Vast working experience as full stack Lead developer - Technically very strong in S/4 ABAP on HANA, SAP UI5/Fiori, Interfaces and SAP BTP , SAP Joule
- Strong working experience in implementing technical solutions in one or more process areas including SAP O2C, S2P, M2C etc.
- Working experience in Agile delivery model
- Conducted architecture reviews and assessments to identify areas for optimization and improvement, resulting in enhanced system performance and reliability.
- Developed technical documentation, including architecture diagrams, design specifications, and implementation plans, to support project delivery and knowledge transfer
- Architects and sizes SAP Solutions across multiple platform variants and SAP Technologies - this will include designing SAP solutions in both on premise and Cloud scenarios
- Act as Technical Stream lead, planning and orchestrating required activities aligned to the Technical Architecture, through close supervision of Technical delivery resources
- Supports Business Development leading the creation of estimates, proposals and Statements of Work
- Pro-actively takes responsibility for assigned tasks and projects for quality, productivity and resources
- Adds value to Business Solutions and ensures adherence to best practices and standards by the team
- Meets personal utilisation target by delivering high quality professional solutions to specification that drive value and business benefit
- Delivers customer service standards that exceed expectations',
   'B.E/B.Tech
Experience :
8 to 15 years
SAP S4 HANA/BTP
SAP AI Joule
SAP S4 HANA/BTP',
   'Experience :
8 to 15 years',
   '2026-08-31T10:02:16Z'::timestamptz,
   'https://jobs.smartrecruiters.com/BoschGroup/744000146435774-sap-senior-architect-senior-expert'),
  -- 30. [Software Engineer] Bosch - Software Factory Architect (Lead Developer) – Vehicle Motion (VM) (Coimbatore)
  ('bosch',
   'Software Factory Architect (Lead Developer) – Vehicle Motion (VM)',
   'Software Engineer',
   'Coimbatore, Tamil Nadu',
   'Tamil Nadu',
   'Onsite',
   'Full time',
   '8+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Python', 'Docker', 'Terraform', 'Agile', 'Product Management', 'Collaboration']::text[],
   'Bosch Global Software Technologies Private Limited is a 100% owned subsidiary of Robert Bosch GmbH, one of the world''s leading global supplier of technology and services, offering end-to-end Engineering, IT and Business Solutions. With over 27,000+ associates, it’s the largest software development center of Bosch, outside Germany, indicating that it is the Technology Powerhouse of Bosch in India with a global footprint and presence in the US, Europe and the Asia Pacific region.
The Opportunity: Architect the Future of Developer ExperienceWe are seeking a hands-on, high-impact Software Factory Architect to champion the greenfield creation and deployment of our Global Software Factory & Developer Platform in Coimbatore.This is a unique, high-influence role. You are an exceptional engineer and architect at heart. Your mission is to define, develop, and deploy the modern tool stack and agile engineering methodologies for the entire Vehicle Motion (VM) business unit globally.You will act as the ultimate architect-developer and technical coach. You will build core tooling, automate complex release pipelines, and actively coach and mentor other developers on how to adopt these new, cutting-edge, and AI-accelerated ways of working.',
   'See the official job posting for the full list of responsibilities.',
   'Bachelor’s or Master’s degree in Computer Science, Software Engineering, or a related technical field',
   '8+ years of hands-on software development and platform engineering experience with a strong software architecture foundation',
   '2026-09-01T06:30:56Z'::timestamptz,
   'https://jobs.smartrecruiters.com/BoschGroup/744000146629618-software-factory-architect-lead-developer-vehicle-motion-vm-')
) as v(slug, title, category, location, state, work_mode, employment_type, experience, salary_min, salary_max, salary, skills, description, responsibilities, requirements, benefits, posted_at, source_url)
join public.companies c on c.slug = v.slug
where not exists (select 1 from public.jobs j where j.source_url = v.source_url);

commit;

-- Verify: select location, count(*) from public.jobs where state = 'Tamil Nadu' and apply_type = 'external' group by location order by location;

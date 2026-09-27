-- HireIn AI: real external job openings - Haryana
-- Cities: Gurugram 15, Faridabad 0 (target was 15 per city; only postings that are genuinely open were imported).
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
  ('MongoDB', 'mongodb', 'Database Software', 'https://www.mongodb.com', 'https://www.google.com/s2/favicons?domain=mongodb.com&sz=128', 'Gurugram', 'Haryana', 'Gurugram, Haryana', 'MongoDB (Database Software). Official careers: https://www.mongodb.com/company/careers', true),
  ('Paytm', 'paytm', 'Fintech', 'https://paytm.com', 'https://www.google.com/s2/favicons?domain=paytm.com&sz=128', 'Gurugram', 'Haryana', 'Gurugram, Haryana', 'Paytm (Fintech). Official careers: https://jobs.lever.co/paytm', true),
  ('Swiggy', 'swiggy', 'Consumer Technology', 'https://www.swiggy.com', 'https://www.google.com/s2/favicons?domain=swiggy.com&sz=128', 'Gurugram', 'Haryana', 'Gurugram, Haryana', 'Swiggy (Consumer Technology). Official careers: https://careers.smartrecruiters.com/Swiggy', true),
  ('Zscaler', 'zscaler', 'Cloud Security', 'https://www.zscaler.com', 'https://www.google.com/s2/favicons?domain=zscaler.com&sz=128', 'Gurugram', 'Haryana', 'Gurugram, Haryana', 'Zscaler (Cloud Security). Official careers: https://www.zscaler.com/careers', true),
  ('Bosch', 'bosch', 'Engineering & Technology', 'https://www.bosch.in', 'https://www.google.com/s2/favicons?domain=bosch.in&sz=128', 'Gurugram', 'Haryana', 'Gurugram, Haryana', 'Bosch (Engineering & Technology). Official careers: https://careers.smartrecruiters.com/BoschGroup', true)
on conflict (slug) do nothing;

-- 2. Jobs (15), linked to companies by slug
insert into public.jobs (company_id, company, title, category, location, state, work_mode, employment_type, experience, salary_min, salary_max, salary, currency, skills, description, responsibilities, requirements, benefits, posted_at, source_url, apply_url, apply_type, apply_label, status, featured, logo)
select c.id, c.name, v.title, v.category, v.location, v.state, v.work_mode, v.employment_type, v.experience, v.salary_min, v.salary_max, v.salary, 'INR', v.skills, v.description, v.responsibilities, v.requirements, v.benefits, v.posted_at, v.source_url, v.source_url, 'external', 'Apply on Company Website', 'published', false, c.logo_url
from (values
  -- 1. [DevOps Engineer] MongoDB - Senior Site Reliability Engineer (Gurugram)
  ('mongodb',
   'Senior Site Reliability Engineer',
   'DevOps Engineer',
   'Gurugram, Haryana',
   'Haryana',
   'Hybrid',
   'Full time',
   '6+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Python', 'MongoDB', 'AWS', 'Azure', 'GCP', 'Kubernetes', 'Linux', 'Communication']::text[],
   'We are seeking a Senior Site Reliability Engineer to join our growing Gurugram Products & Technology team to provide technical direction, shape architecture, and build key operational foundations of a new platform we are building to make it easier for customers to build AI applications using MongoDB.
As a Senior Site Reliability Engineer on this new team, you will be responsible for enabling deployment at scale of AI applications and improving the performance, scalability, and reliability of the distributed systems infrastructure for this new product. The platform''s SRE team owns the operational foundations: the Kubernetes fleet, networking, observability and alerting, and tenant isolation. MongoDB engineering teams pride themselves on building high-quality software and living MongoDB cultural values every day – we value intellectual curiosity and honesty, and building together in an environment that prioritizes collaboration over competition.
We are looking to speak to candidates who are based in Gurugram for our hybrid working model.
Position Expectations
- Operate and improve the multi-tenant Kubernetes infrastructure that runs customer workloads
- Build for reliability, making services and infrastructure available, resilient, fault-tolerant, and self-healing
- Identify and configure key metrics to detect incidents and quantify service health, availability, and performance
- Participate in a 24/7 on-call rotation to resolve issues involving platform infrastructure',
   'See the official job posting for the full list of responsibilities.',
   '- Strong background in software development and operating distributed systems
- 6+ years of experience building and operating distributed systems, with proficiency in Python, Go, or a similar programming language
- Experience operating Kubernetes in production and debugging below the abstraction layer, including scheduling, cluster networking, and node-level issues
- Expertise in cloud infrastructure platforms, including AWS, Google Cloud Platform (GCP), or Azure
- Strong understanding of Linux operating system internals and networking concepts such as TCP/IP, DNS, TLS, and routing
- Customer-focused mindset and strong verbal and written technical communication skills, with a desire to collaborate with colleagues
- Strong bias for efficient processes, operational simplicity, and automation over manual work
- Bonus points for experience with Kubernetes networking, such as Istio or Cilium, service mesh or edge load balancing in production, secure multi-tenant runtime environments at scale, multi-cloud infrastructure management, and virtualization or workload isolation technologies
- Eager to learn, with a strong technical background
About MongoDB
MongoDB is built for change, empowering our customers and our people to innovate at the speed of the market. We have redefined the data platform for the AI era, enabling builders to create, transform, and disrupt industries with software. MongoDB’s unified data platform, the most widely available, globally distributed data platform on the market, helps organizations modernize legacy workloads, embrace innovation, and unleash AI. Our cloud-native platform, MongoDB Atlas, is the only globally distributed, multi-cloud data platform and is available across AWS, Google Cloud, and Microsoft Azure.
With offices worldwide and over 67,000 customers, including 75% of the Fortune 100 and AI-native startups, relying on MongoDB for their most important applications, we’re powering the next era of software.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-07-21T16:53:40Z'::timestamptz,
   'https://www.mongodb.com/careers/job/?gh_jid=8051379'),
  -- 2. [Sales Executive] MongoDB - Senior Sales Compensation Engineer (Gurugram)
  ('mongodb',
   'Senior Sales Compensation Engineer',
   'Sales Executive',
   'Gurugram, Haryana',
   'Haryana',
   'Hybrid',
   'Full time',
   '3-5 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['SQL', 'MySQL', 'PostgreSQL', 'MongoDB', 'AWS', 'Azure', 'Salesforce', 'Communication']::text[],
   'We are seeking a Senior Engineer to join MongoDB''s growing Fintech Team. This highly visible role is critical to supporting the company''s continued rapid growth and will focus primarily on the administration and analysis of our Global Sales Incentive Plans.
The ideal candidate is detail-oriented, with strong organizational and time-management skills. Excellent verbal and written communication, along with a collaborative mindset, are essential for working effectively across cross-functional teams and with various levels of management.
Please note this role will require weekend availability during quarter-end close and annual plan implementation periods.
MongoDB engineering teams take pride in building high-quality software while living our cultural values every day. We value intellectual curiosity and honesty, and we foster an environment that prioritizes collaboration over competition.
We are looking to speak with candidates based in Gurugram or Bangalore for our hybrid working model.',
   '- Act as an organizational subject matter expert for commissions processing, the Xactly product suite, and individual commission plan components as they operate in the solution
- Gathering and documenting detailed business requirements
- Responsible for designing, configuring and managing Xactly platform
- Writing rules, analyzing results, troubleshooting, and improving processes as needed
- Create plans and assist in test case creation & testing
- Collaborate with Sales Operations and Finance teams in user acceptance testing for changes to Xactly system as well as facilitate seamless implementations of new functionality through targeted communications, demos, and the user training
- Design, develop, test, document, and deploy high-quality technical solutions on the Xactly platform based on industry best practices to solve business needs
- Trace unexpected results back to their source and diagnose underlying issues. If unable to resolve directly, own coordination and resolution with appropriate resources
- Manage the process of implementing improvements and new functionality in the Xactly application
- Communicate and collaborate with other technical resources and customers in providing timely updates on status of deliverables, shedding light on technical issues, and obtaining buy-in on creative solutions
- Document system configuration and payment administrative processes
- Work closely with globally distributed development team and lead project efforts with less supervision
- Perform ad-hoc reporting and analysis to provide business insight
- Remain current with Xactly products and modules through regular engagement with and training through Xactly resources and communicate trends and future needs to leadership
- Coordinate with the Xactly Data Warehouse and ETL teams to implement commission data changes, and output data for consumption by other business teams',
   '- Bachelor''s or Master''s degree in Computer Science, Information Systems, or equivalent
- 5+ years of experience working with and building Sales Compensation systems in a professional, fast-paced environment
- Strong business relationship and partnership skills and experience
- A current Xactly Incent certification (e.g. Incent Level 3 certification)
- 3-5 years experience querying traditional SQL RDBMS (Oracle, Microsoft SQL Server, MySQL, PostgreSQL, DB2, HyperSQL, Salesforce, SQLite, etc.)
- Experience with the Xactly product suite or competitive product suites highly desirable (ie, SAP CallidusCloud, IBM Varicent, Anaplan, Optymyze, Pigment)
- Experience with design and maintain planning models in Anaplan or Pigment(Preferred), including:
- Quota planning
- Territory planing
- Account Segmentation
- Xactly Incent platform development experience (Configuring, testing, deployment and production support)
- Strong Software Design experience
- Excellent verbal and written communication skills
About MongoDB
MongoDB is built for change, empowering our customers and our people to innovate at the speed of the market. We have redefined the data platform for the AI era, enabling builders to create, transform, and disrupt industries with software. MongoDB’s unified data platform, the most widely available, globally distributed data platform on the market, helps organizations modernize legacy workloads, embrace innovation, and unleash AI. Our cloud-native platform, MongoDB Atlas, is the only globally distributed, multi-cloud data platform and is available across AWS, Google Cloud, and Microsoft Azure.
With offices worldwide and over 67,000 customers, including AI-native startups and approximately 75% of the Fortune 100, relying on MongoDB for their most important applications, we’re powering the next era of software.
Our compass at MongoDB is our Leadership Commitment, guiding how and why we make decisions, show up for each other, and win.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-11T13:41:26Z'::timestamptz,
   'https://www.mongodb.com/careers/job/?gh_jid=8121701'),
  -- 3. [Software Engineer] MongoDB - Senior Software Engineer, AI Framework Integrations (Gurugram)
  ('mongodb',
   'Senior Software Engineer, AI Framework Integrations',
   'Software Engineer',
   'Gurugram, Haryana',
   'Haryana',
   'Hybrid',
   'Full time',
   '5+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['TypeScript', 'Python', 'Java', 'C#', 'MongoDB', 'AWS', 'Azure', 'Docker']::text[],
   'AI frameworks like LangChain, LlamaIndex, and n8n are quickly becoming the default way developers build with AI — and MongoDB wants to be the data platform that shows up everywhere they build. As part of the AI Builders Experience (ABX) org, we''re standing up a brand new engineering team in Gurugram to make that happen, and we''re looking for Senior Software Engineers to be among its founding members.
The team owns the connective layer between MongoDB and third-party AI frameworks, platforms, and tools — the integrations that let developers use MongoDB effectively with the AI stack they''ve already chosen. That means shipping into some of the fastest-moving open-source ecosystems in tech, working mostly in Python and TypeScript, and partnering with the Database Experience (DBX) org when an integration needs new driver, platform, or product capability underneath it.
This is a self-sufficient team by design. You and your engineering manager will be based in Gurugram, and the group is set up to own its area end to end: to decide how integrations get built, tested, released, and maintained, without waiting on another time zone to unblock the day-to-day. You''ll work closest with the engineers sitting next to you, pairing on hard problems, reviewing each other''s code, and dividing up a broad portfolio, while collaborating with product, partners, field teams, and open source maintainers as the work requires.',
   'See the official job posting for the full list of responsibilities.',
   '- Strong background in building core components for scalable, high-availability services, developer platforms, or libraries
- 5+ years of experience building backend systems or developer-facing libraries, with strong proficiency in Python and/or TypeScript
- Proven success in designing, writing, testing, debugging, and performance tuning software in large, long-lived code bases, including code that other developers depend on
- Track record of identifying problems, implementing solutions, and delivering complex projects independently with minimal guidance
- A product-minded approach to engineering, with the judgment to make pragmatic tradeoffs between fast time-to-market and long-term maintainability, and the comfort to operate amid ambiguity and rapidly evolving technologies
- Demonstrated ability to context switch across a portfolio of projects while maintaining sound prioritization and quality.
- Strong and demonstrated interest in modern AI builder workflows and the developer tooling landscape: AI frameworks, agentic patterns, RAG and retrieval, embedding, vector search, or adjacent areas.
- Excellent verbal and written technical communication skills, including the ability to write things down clearly for partners you won''t always overlap with in real time.
- Enjoys collaboration and being part of a close-knit team; is approachable, curious, and intellectually honest.
- Eager to learn, with a strong technical background.
Nice to Have
- Meaningful open source contributions, especially work that landed in repositories you don''t own and required navigating external maintainer review
- Professional experience building AI or framework integrations, MCP servers, agent skills, or plugins for agentic applications
- Familiarity with the agentic AI tooling ecosystem (AI IDEs, CLIs, and assistants) and how developers integrate with it',
   'Benefits are listed on the employer''s official job posting.',
   '2026-08-06T14:33:48Z'::timestamptz,
   'https://www.mongodb.com/careers/job/?gh_jid=8107301'),
  -- 4. [Digital Marketing] Paytm - Growth Operations - Assistant Manager - Travel Business (Bus) (Gurugram)
  ('paytm',
   'Growth Operations - Assistant Manager - Travel Business (Bus)',
   'Digital Marketing',
   'Gurugram, Haryana',
   'Haryana',
   'Onsite',
   'Full time',
   '2+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Digital Marketing', 'Campaign Management', 'Account Management', 'Communication']::text[],
   'About Us:
Paytm is India''s leading financial services company that offers full-stack payments & financial solutions to consumers, offline merchants, and online platforms. The company is on a mission to bring half a billion Indians into the mainstream economy through payments, commerce, banking, investments, and financial services. One97 Communications Limited that owns the brand Paytm is founded by Vijay Shekhar Sharma.
About the Team:
The Travel & Growth Operations team drives digital ticket bookings, campaign management, and strategic institutional partnerships. Acting as a critical operational bridge between growth marketing, tech, and external key accounts like State Road Transport Corporations (RTCs), the team scales user adoption and optimizes booking performance across national transit networks.',
   'Drive digital execution across campaign operations, promotional management, and institutional account management. Blending hands-on growth operations with strategic partnership management focused largely on State Road Transport Corporations (RTCs), you will serve as the core link between RTC officials/depot managers, central growth marketing teams, and tech operations to optimize ticket booking campaigns, digital visibility, and strategic promotional initiatives.',
   '1. Set up, schedule, and automate targeted lifecycle campaigns on growth automation tools like CleverTap (push notifications, in-app popups, and user segmentation tailored for RTC commuters).
2. Manage banner creation workflows, route visibility, featured placements, and promotional banners to boost user conversion for RTC bus bookings.
3. Configure promo codes, manage discount logic, track redemption metrics, enforce fraud controls, and manage promotional budgets for RTC routes.
4. Coordinate closely with central product, tech, and marketing teams to ensure seamless feature rollouts, bug resolution, and operational alignment for RTC platforms.
5. Act as the key relationship point for State Road Transport Corporations (RTCs), understanding their operational requirements and driving booking adoption.
6. Travel on a need basis to meet RTC officials, visit regional bus depots/counters, resolve operational friction, and execute joint promotional activities.
7. Track booking volumes, campaign ROI, route-level conversion metrics, and coupon utilization.
8. Deliver periodic performance reports to RTC partners and internal stakeholders.
2+ years of hands-on experience in growth operations, digital marketing ops, or key account management (Travel, Ticketing, Mobility, or E-Commerce background preferred).
Proficiency with customer engagement platforms like CleverTap, MoEngage, or similar campaign management tools.
Demonstrated experience in managing end-to-end promotional assets (banner workflows, coupon engines, and campaign scheduling).
Strong communication and relationship-building skills to liaison effectively with central internal teams and RTC/government officials.
Strong analytical and reporting capabilities to track campaign ROI, route conversion, and booking performance.
Flexibility and willingness to travel on a need basis for field coordination and RTC partner meetings.',
   'A collaborative output driven program that brings cohesiveness across businesses through technology.Improve the average revenue per use by increasing the cross-sell opportunities.A solid 360 feedback from your peer teams on your support of their goals
If you are the right fit, we believe in creating wealth for you With enviable 500 mn+ registered users, 21 mn+ merchants and depth of data in our ecosystem, we are in a unique position to democratize credit for deserving consumers & merchants – and we are committed to it. India’s largest digital lending story is brewing here. It’s your opportunity to be a part of the story!',
   '2026-08-12T10:05:12Z'::timestamptz,
   'https://jobs.lever.co/paytm/3d396d95-cef6-4a5f-bd07-8b21944533a0'),
  -- 5. [HR Recruiter] Paytm - Talent Acquisition Intern - Gurgaon (Gurugram)
  ('paytm',
   'Talent Acquisition Intern - Gurgaon',
   'HR Recruiter',
   'Gurugram, Haryana',
   'Haryana',
   'Onsite',
   'Internship',
   'Fresher / Internship',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Branding', 'Excel', 'Recruitment', 'Communication']::text[],
   'About Paytm
Paytm is India''s leading mobile payments and financial services distribution company. Pioneer of the mobile QR payments revolution in India, Paytm builds technologies that help small businesses with payments and commerce. Paytm''s mission is to serve half a billion Indians and bring them to the mainstream economy with the help of technology.',
   'A Talent Acquisition (TA) Intern supports the recruitment team by sourcing and screening candidates, coordinating interviews, and maintaining recruitment trackers. They assist with job postings, initial candidate communication, and documentation like offer letters and onboarding forms. The role also involves helping with employer branding activities and ensuring smooth coordination between candidates and hiring managers.',
   '● Basic understanding of recruitment and hiring processes.
● Ability to source, screen, and identify relevant candidate profiles.
● Proficiency in MS Excel, Google Sheets, and Microsoft Office.
● High attention to detail and accuracy in maintaining recruitment documentation.
● Ability to maintain recruitment trackers and reports.
● Ability to work in a fast-paced environment and manage multiple priorities.
● Positive attitude, willingness to learn, and adaptability.
● Knowledge of LinkedIn and job portals will be an added advantage.
● Basic understanding of recruitment and hiring processes.
● Ability to source, screen, and identify relevant candidate profiles.
● Proficiency in MS Excel, Google Sheets, and Microsoft Office.
● High attention to detail and accuracy in maintaining recruitment documentation.
● Ability to maintain recruitment trackers and reports.
● Ability to work in a fast-paced environment and manage multiple priorities.
● Positive attitude, willingness to learn, and adaptability.
● Knowledge of LinkedIn and job portals will be an added advantage.
What You Will Gain:
● Hands-on exposure to Talent Acquisition and recruitment operations.
●Opportunity to interact with candidates, recruiters, and business stakeholders.
●Practical experience in candidate sourcing, screening, interview coordination, and recruitment reporting.',
   'We support our people by providing a range of flexible working options so they can work in the way that best suits them. We also offer you the opportunity to develop your career, working in a diverse and inclusive workplace where the diverse backgrounds, perspectives and life experiences of our people are celebrated and create a great place to grow, thrive and belong. Most importantly, for us Work is Fun!!
If you are the right fit, we believe in creating wealth for you with enviable 500 mn+ registered users,21 mn+ merchants and depth of data in our ecosystem, we are in a unique position to democratize credit for deserving consumers & merchants – and we are committed to it. India’s largest digital lending story is brewing here. It’s your opportunity to be a part of the story! democratize credit for deserving consumers & merchants – and we are committed to it. India’s largest digital lending story is brewing here.',
   '2026-09-08T12:24:47Z'::timestamptz,
   'https://jobs.lever.co/paytm/91ef4dc2-8cd8-427a-84cd-c9308753a203'),
  -- 6. [Sales Executive] Swiggy - Sales Manager II (Gurugram)
  ('swiggy',
   'Sales Manager II',
   'Sales Executive',
   'Gurugram, Haryana',
   'Haryana',
   'Onsite',
   'Full time',
   '0-2 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Excel', 'Market Research', 'Negotiation', 'Business Development', 'Problem Solving']::text[],
   'Swiggy is India’s leading on-demand delivery platform with a tech-first approach to logistics and a solution-first approach to consumer demands. With a presence in 500+ cities across India, partnerships with hundreds of thousands of restaurants, an employee base of over 5000, a 2 lakh+ strong independent fleet of Delivery Executives, we deliver unparalleled convenience driven by continuous innovation.
Overview
A Sales Manager owns the acquisition and engagement of single-outlet independent restaurants across an assigned city. You are the primary touchpoint for these restaurants—learning their business, understanding their challenges, and building a partnership where you help the restaurant partner directly drive their growth in orders, visibility, and customer engagement. This role is Consultative & On-Field and requires you to be resourceful, adaptable, and genuinely invested in your partners'' success. You''ll develop consultative sales skills, learn restaurant operations intimately, and build the foundation for scaling your career.',
   '- Own a defined geographic territory: build strong and successful relationships with the assigned restaurant partners
- Field-intensive engagement: Conduct in-person visits, walking restaurants through product demos, ROI analysis, and present how working with Swiggy is a mutually beneficial relationship
- Consultative selling: Diagnose restaurant needs through questions about their current channels, delivery logistics, marketing spend, and business goals. Position Swiggy’s products as solutions, not features
- Relationship management: Manage the full lifecycle each month, pitching, negotiation, activation, and ongoing support to the restaurant partner
- Data-driven problem solving: Track adoption metrics, identify why restaurants aren''t growing, troubleshoot issues, and course-correct
- Revenue responsibility: Own targets within your territory; track your own pipeline and conversion rates
- Excel mastery: all the data related to your day-to-day work will be on the city and central trackers, so you must have advanced knowledge of Excel/Googlesheet/WSP
- Market research: Stay updated on restaurant trends, competitive landscape, and local market dynamics. Feedback from the field informs product direction
- 80 to 90 In-person meetings with restaurant partners a month',
   'Experience & Background:
- 0-2 years in B2B sales, field sales, or business development (preferably in fmcg, food/beverage, or hotel industry)
- Track record of meeting or exceeding targets and managing your own pipeline
- Restaurant Business is a round-the-clock business; the role holder has to take ownership of the growth of the assigned portfolio of restaurant partner
- Comfort with data, especially Excel—you should be able to build pivot tables, use VLOOKUP, and create dashboards without help
- Post - Graduated preferably in marketing or sales',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-22T06:08:54Z'::timestamptz,
   'https://jobs.smartrecruiters.com/SWIGGY/6000000001427711-sales-manager-ii'),
  -- 7. [Sales Executive] Zscaler - Principal Sales Engineer (Gurugram)
  ('zscaler',
   'Principal Sales Engineer',
   'Sales Executive',
   'Gurugram, Haryana',
   'Haryana',
   'Hybrid',
   'Full time',
   '15+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Agile', 'Leadership', 'Collaboration']::text[],
   'Zscaler (NASDAQ: ZS) accelerates digital transformation so customers can be more agile, efficient, resilient, and secure. The Zscaler Zero Trust Exchange™️ platform protects thousands of customers from cyberattacks and data loss by securely connecting users, devices, and applications in any location. Distributed across 160+ public exchanges globally and thousands of private exchanges at the edge, the SASE-based Zero Trust Exchange is the world’s largest in-line cloud security platform.
We believe the future of work is Human + AI and are building an AI-native enterprise where human potential is amplified by machine intelligence to solve the world’s hardest security challenges. Driven by deep customer obsession, we are committed to the mission, outcome, and to each other. We bring these commitments to life through three core behaviors: ownership and collaboration, trust through outcomes and impact, and a challenge culture with ongoing feedback. Ready to make an impact at the company pioneering security transformation in the AI era? Join us at Zscaler.
Role
We are looking for a Principal Sales Engineer to join our team. This is a Hybrid role, reporting to the Senior Director, Sales Engineering in the APJ Field Sales department.',
   '- Facilitate consultative discovery and design workshops meant to uncover a customer’s business requirements and their current-state architecture
- Design a high-level Zero Trust Architecture including a phased adoption roadmap expressing how the customer can transform to a Zero Trust Architecture future-state over time
- Engage across customer functional teams, as well as Zscaler partner and internal teams, to develop rapport and to ensure success across organizational structures from engineer to executive
- Code-switch seamlessly between CXO and IT Operations audiences to balance a combination of executive presence and deep technical credibility
- Adopt a confident, yet consultative customer-facing persona built on executive presence and humility',
   '- You thrive in ambiguity. You''re comfortable building the path as you walk it. You thrive in a dynamic environment, seeing ambiguity not as a hindrance, but as the raw material to build something meaningful.
- You act like an owner. Your passion for the mission fuels your bias for action. You operate with integrity because you genuinely care about the outcome. True ownership involves leveraging dynamic range: the ability to navigate seamlessly between high-level strategy and hands-on execution.
- You are a problem-solver. You love running towards the challenges because you are laser-focused on finding the solution, knowing that solving the hard problems delivers the biggest impact.
- You are a high-trust collaborator. You are ambitious for the team, not just yourself. You embrace our challenge culture by giving and receiving ongoing feedback—knowing that candor delivered with clarity and respect is the truest form of teamwork and the fastest way to earn trust.
- You are a learner. You have a true growth mindset and are obsessed with your own development, actively seeking feedback to become a better partner and a stronger teammate. You love what you do and you do it with purpose.
- Foundational understanding of AI/ML technologies and experience leveraging, securing, or positioning AI-driven solutions to optimize outcomes within your functional domain
- 15+ years of relevant experience, or 10+ years of experience and an advanced degree
- Advanced product expertise and solution development capability, delivering on advanced solution selling across end-to-end Enterprise Architectures and complex Networking and Security environments
- Hands-on experience with technologies including TCP/IP protocol stack, DNS, BGP routing, MPLS, SD-WAN, GRE, IPsec, Layer-7 firewalls, Web Proxies, Load Balancing, and Data Loss Prevention',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-03T08:26:34Z'::timestamptz,
   'https://job-boards.greenhouse.io/zscaler/jobs/5215336007'),
  -- 8. [Sales Executive] Zscaler - Senior Sales Engineer - Enterprise (Gurugram)
  ('zscaler',
   'Senior Sales Engineer - Enterprise',
   'Sales Executive',
   'Gurugram, Haryana',
   'Haryana',
   'Hybrid',
   'Full time',
   '15+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Linux', 'Agile', 'Leadership', 'Collaboration']::text[],
   'Zscaler (NASDAQ: ZS) accelerates digital transformation so customers can be more agile, efficient, resilient, and secure. The Zscaler Zero Trust Exchange™️ platform protects thousands of customers from cyberattacks and data loss by securely connecting users, devices, and applications in any location. Distributed across 160+ public exchanges globally and thousands of private exchanges at the edge, the SASE-based Zero Trust Exchange is the world’s largest in-line cloud security platform.
We believe the future of work is Human + AI and are building an AI-native enterprise where human potential is amplified by machine intelligence to solve the world’s hardest security challenges. Driven by deep customer obsession, we are committed to the mission, outcome, and to each other. We bring these commitments to life through three core behaviors: ownership and collaboration, trust through outcomes and impact, and a challenge culture with ongoing feedback. Ready to make an impact at the company pioneering security transformation in the AI era? Join us at Zscaler.
Role
We are looking for a Senior Sales Engineer, Enterprise to join our team. This is a Hybrid (Gurgaon) role, reporting to the Senior Manager, Sales Engineering in the SE India department. You will join a global group of professionals passionate about driving a secure, cloud-enabled digital future as a leader in cloud security.',
   '-
Provide technical thought leadership and advice to enterprise customers on how to transform their digital experience
-
Take total ownership of the technical sale and associated processes
-
Identify and qualify technical opportunities while developing and maintaining trusted advisor relationships with key customer stakeholders
-
Deliver impactful sales pitches, technical presentations, and whiteboards to ensure successful deployments',
   '-
You thrive in ambiguity. You''re comfortable building the path as you walk it. You thrive in a dynamic environment, seeing ambiguity not as a hindrance, but as the raw material to build something meaningful.
-
You act like an owner. Your passion for the mission fuels your bias for action. You operate with integrity because you genuinely care about the outcome. True ownership involves leveraging dynamic range: the ability to navigate seamlessly between high-level strategy and hands-on execution.
-
You are a problem-solver. You love running towards the challenges because you are laser-focused on finding the solution, knowing that solving the hard problems delivers the biggest impact.
-
You are a high-trust collaborator. You are ambitious for the team, not just yourself. You embrace our challenge culture by giving and receiving ongoing feedback—knowing that candor delivered with clarity and respect is the truest form of teamwork and the fastest way to earn trust.
-
You are a learner. You have a true growth mindset and are obsessed with your own development, actively seeking feedback to become a better partner and a stronger teammate. You love what you do and you do it with purpose.
-
Foundational understanding of AI/ML technologies and experience leveraging, securing, or positioning AI-driven solutions to optimize outcomes within your functional domain
-
Bachelor’s degree or equivalent combination of education and professional experience
-
15+ years of experience as a Sales Engineer or systems integrator
-
Hands-on experience in installing, configuring, and managing routers, switches, and network security technologies
-
Experience demonstrating or architecting enterprise cloud security platforms utilizing AI-powered threat prevention, automated anomaly detection, or predictive data defense capabilities
-
Proficiency with GPO, Active Directory/LDAP, and SSO/SAML protocols
-',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-19T02:57:37Z'::timestamptz,
   'https://job-boards.greenhouse.io/zscaler/jobs/5240656007'),
  -- 9. [Sales Executive] Zscaler - Partner Sales Director, GSI (Gurugram)
  ('zscaler',
   'Partner Sales Director, GSI',
   'Sales Executive',
   'Gurugram, Haryana',
   'Haryana',
   'Hybrid',
   'Full time',
   '10+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Business Development', 'Agile', 'Presentation', 'Collaboration']::text[],
   'Zscaler (NASDAQ: ZS) accelerates digital transformation so customers can be more agile, efficient, resilient, and secure. The Zscaler Zero Trust Exchange™️ platform protects thousands of customers from cyberattacks and data loss by securely connecting users, devices, and applications in any location. Distributed across 160+ public exchanges globally and thousands of private exchanges at the edge, the SASE-based Zero Trust Exchange is the world’s largest in-line cloud security platform.
We believe the future of work is Human + AI and are building an AI-native enterprise where human potential is amplified by machine intelligence to solve the world’s hardest security challenges. Driven by deep customer obsession, we are committed to the mission, outcome, and to each other. We bring these commitments to life through three core behaviors: ownership and collaboration, trust through outcomes and impact, and a challenge culture with ongoing feedback. Ready to make an impact at the company pioneering security transformation in the AI era? Join us at Zscaler.
Role
We are looking for a Partner Sales Director, GSI to join our team. This is a hybrid position based in Gurgaon role, reporting to the Sr. Director, Alliance Partners in the WW Alliances & Channels department. This role will lead the strategic expansion of our platform within our Global System Integrator (GSI) ecosystem.',
   '-
Drive the commercial sales strategy and "Go-to-Market" approach for the Zscaler product suite through our GSI partners in India, identifying high-potential teams and collaborating on complex, large-scale cloud security migrations
-
Lead the engagement cycle with GSI partners, translating Zscaler’s technical capabilities into quantifiable business outcomes, ROI models, and managed service pricing structures that resonate with stakeholders and global end-customers
-
Act as the bridge between technical architects and commercial sales teams to structure complex proposals for multi-year, multi-tower outsourcing deals, ensuring Zscaler is integrated into standard reference architectures
-
Oversee the technical Proof of Value (PoV) process within GSI accounts, ensuring that technical success criteria are directly aligned with the commercial milestones of a larger digital transformation contract
-
Enable and educate internal GSI teams while serving as the definitive voice of the partner to synthesize field feedback and influence the Zscaler platform roadmap',
   '-
You thrive in ambiguity. You''re comfortable building the path as you walk it. You thrive in a dynamic environment, seeing ambiguity not as a hindrance, but as the raw material to build something meaningful.
-
You act like an owner. Your passion for the mission fuels your bias for action. You operate with integrity because you genuinely care about the outcome. True ownership involves leveraging dynamic range: the ability to navigate seamlessly between high-level strategy and hands-on execution.
-
You are a problem-solver. You love running towards the challenges because you are laser-focused on finding the solution, knowing that solving the hard problems delivers the biggest impact.
-
You are a high-trust collaborator. You are ambitious for the team, not just yourself. You embrace our challenge culture by giving and receiving ongoing feedback—knowing that candor delivered with clarity and respect is the truest form of teamwork and the fastest way to earn trust.
-
You are a learner. You have a true growth mindset and are obsessed with your own development, actively seeking feedback to become a better partner and a stronger teammate. You love what you do and you do it with purpose.
-
Foundational understanding of AI/ML technologies and experience leveraging, securing, or positioning AI-driven solutions to optimize outcomes within your functional domain
-
10+ years of experience in technical sales, business development, or consulting, specifically working with or for Global System Integrators
-
Proven expertise in business development, global alliances, and executing strategic initiatives with a strong techno-commercial mindset
-
Demonstrated track record of structuring complex commercial deals, including consumption-based models and managed services pricing
-',
   'Benefits are listed on the employer''s official job posting.',
   '2026-07-29T06:36:18Z'::timestamptz,
   'https://job-boards.greenhouse.io/zscaler/jobs/5189014007'),
  -- 10. [Sales Executive] Bosch - Sales Quality Warranty - Deputy Manager (Gurugram)
  ('bosch',
   'Sales Quality Warranty - Deputy Manager',
   'Sales Executive',
   'Gurugram, Haryana',
   'Haryana',
   'Onsite',
   'Full time',
   '3-5 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Statistics', 'Negotiation', 'Communication', 'Problem Solving']::text[],
   'In India, Bosch is a leading supplier of technology and services in the areas of Mobility Solutions, Industrial Technology, Consumer Goods, and Energy and Building Technology. Additionally, Bosch has in India the largest development center outside Germany, for end to end engineering and technology solutions. The Bosch Group operates in India through twelve companies.
Manage Customer Quality Complaints, Warranty Claims Administration, Managing Customer Specific Requirements & Contractual Management, Launch, Complaint & Escalation Management Digitization, Reporting & Process Improvement',
   'See the official job posting for the full list of responsibilities.',
   'B.E / B.Tech - (Mech, Automobile, EC, EE)Certification in Automobile, Quality and Digital areas - Desirable
3-5 Years of Experience in Manufacturing/ Quality in automotive domain in team role
Cross-funtional roles in projects as team players desirable
Proficient Technical knowledge on Automotive systems incl. HW, SW and diagnostics.
Proficient knowledge on claim management process
Knowledge on Automotive Legislation / regulation(s) related to customer area for operation
Knowledge on product life cycle and change management at customer and Bosch
Adequate knowledge on legal, product liability, data security, cost awareness
Competent in Analytical thinking and problem solving - System and Product
Complete knowledge of Customer organisation, Processes, strategy and Ecosystem
Positive attitude to work with customer, network with customer profiles & able to Lead self with team
Ability to work with customer on Projects to improve overall quality statistics - Hardware and Software',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-17T08:53:40Z'::timestamptz,
   'https://jobs.smartrecruiters.com/BoschGroup/744000150047799-sales-quality-warranty-deputy-manager'),
  -- 11. [Finance Executive] MongoDB - Sr Finance Systems Admin (L1 Support & Admin) (Gurugram)
  ('mongodb',
   'Sr Finance Systems Admin (L1 Support & Admin)',
   'Finance Executive',
   'Gurugram, Haryana',
   'Haryana',
   'Hybrid',
   'Full time',
   '8+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['SQL', 'MongoDB', 'AWS', 'Azure', 'Power BI', 'Accounting', 'Communication', 'Leadership']::text[],
   'We are looking for a detail-oriented and collaborative Finance Systems Administrator to join the Finance Systems team in India. This is a hands-on, service-delivery role responsible for day-to-day L1 support, user administration, and configuration changes across MongoDB''s suite of Finance applications.
You will be the first point of contact for end users encountering issues or making requests across NetSuite, Coupa, Concur, Graphite, YayPay, EPM system, and associated Tax & Treasury platforms. You will triage, resolve, or escalate tickets, maintain user access, support month-end activities, and help improve operational processes over time.
We are looking to speak to candidates who are based in Gurugram for our hybrid working model.',
   'L1 Support & Ticket Management
- Own the L1 support queue for all Finance applications — triage, prioritise, resolve, or escalate tickets per defined SLAs
- Troubleshoot common functional issues: data entry errors, workflow approvals, report access, login/SSO problems, and configuration mismatches
- Document known issues and resolutions in a shared knowledge base; contribute to runbooks and FAQs to reduce recurring tickets
- Communicate timely and clearly with end users on ticket status, expected resolution, and workarounds
User Administration & Access Management
- Provision, modify, and deprovision user accounts across NetSuite, Coupa, Concur, Graphite, YayPay, and Anaplan/Pigment - set up SCIM where applicable
- Assign roles, permission sets, and approval hierarchies in line with access control policies and least-privilege principles
- Run regular access certification reviews and clean up inactive accounts
- Coordinate with HR and IT during onboarding/offboarding events to ensure timely access changes
Configuration & Admin Tasks
- Perform low-complexity system configuration: adding/updating cost centres, departments, approval workflows, expense categories, supplier records, and similar admin objects
- Support Finance teams with month-end and quarter-end tasks — running scheduled jobs, validating data loads, and confirming system readiness
- Assist in testing configuration changes or patches in sandbox environments before promoting to production
- Maintain system documentation including configuration guides, data dictionaries, and change logs
Stakeholder Coordination
- Liaise with Level 2/3 support teams and external vendors for escalated issues requiring deeper technical or functional expertise
- Participate in regular system health reviews and communicate recurring pain points to the broader product leads
Process Improvement & Compliance
- Identify patterns in the support queue and proactively flag systemic issues to reduce ticket volume',
   'Required
- 6–8 years of experience in Finance systems support, ERP administration, or a similar generalist Finance IT role
- Hands-on working knowledge of at least 2–3 of the following: NetSuite, Coupa, Concur, Anaplan/Pigment, or equivalent cloud Finance applications
- Solid understanding of Finance and Accounting processes: procure-to-pay, order-to-cash, expense management, financial planning, and reporting
- Experience managing user access, roles, and permissions in SaaS Finance platforms
- Strong written and verbal communication skills in English; ability to translate technical issues for non-technical Finance stakeholders
- Organised and methodical approach to ticket handling, documentation, and follow-through
- Experience with YayPay (AR automation), Graphite (contract management), or Tax/Treasury platforms (e.g., Kyriba)
- Familiarity with SSO/SAML provisioning (Okta or similar) in the context of Finance application onboarding
- Exposure to SOX compliance requirements, user access reviews, or IT General Controls (ITGCs)
- Basic SQL or reporting tool skills (SuiteAnalytics, Power BI, or similar) for ad hoc data validation
- Experience in a high-growth, global technology company or shared services environment
Education
- Bachelor''s degree in Information Systems, Computer Science, or a related field. Equivalent practical experience accepted
About MongoDB
MongoDB is built for change, empowering our customers and our people to innovate at the speed of the market. We have redefined the data platform for the AI era, enabling builders to create, transform, and disrupt industries with software. MongoDB’s unified data platform, the most widely available, globally distributed data platform on the market, helps organizations modernize legacy workloads, embrace innovation, and unleash AI. Our cloud-native platform, MongoDB Atlas, is the only globally distributed, multi-cloud data platform and is available across AWS, Google Cloud, and Microsoft Azure.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-07-02T11:32:06Z'::timestamptz,
   'https://www.mongodb.com/careers/job/?gh_jid=8017380'),
  -- 12. [DevOps Engineer] MongoDB - Staff Site Reliability Engineer (Gurugram)
  ('mongodb',
   'Staff Site Reliability Engineer',
   'DevOps Engineer',
   'Gurugram, Haryana',
   'Haryana',
   'Hybrid',
   'Full time',
   '10+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Python', 'MongoDB', 'AWS', 'Azure', 'GCP', 'Kubernetes', 'Leadership', 'Collaboration']::text[],
   'We are seeking a Staff Site Reliability Engineer to join our growing Gurugram Products & Technology team to provide technical direction, shape architecture, and build key operational foundations of a new platform we are building to make it easier for customers to build AI applications using MongoDB.
As a Staff Site Reliability Engineer on this new team, you will be responsible for providing technical leadership for the operational foundations that enable deployment at scale of AI applications. You will own the reliability architecture of the platform as it expands across regions and cloud providers, and set the technical direction for how the platform is operated, including capacity planning, multi-cloud expansion, incident response, and SLO discipline. The platform''s SRE team owns the operational foundations: the Kubernetes fleet, networking, observability and alerting, and tenant isolation. MongoDB engineering teams pride themselves on building high-quality software and living MongoDB cultural values every day – we value intellectual curiosity and honesty, and building together in an environment that prioritizes collaboration over competition.
We are looking to speak to candidates who are based in Bengaluru for our hybrid working model.
Position Expectations
- Own the reliability architecture of the platform across regions and cloud providers',
   'See the official job posting for the full list of responsibilities.',
   '- 10+ years of experience working on software and operating distributed systems, with deep Kubernetes expertise, including designing or evolving multi-cluster platforms
- Proficiency in Python, Go, or a similar programming language
- Understand workload isolation at the systems level: containers, virtual machines, and the trade-offs between them for running untrusted code
- Possess a customer-focused mindset
- Value efficiency in processes and operations, and display a strong preference for automation over manual processes
- Be intimately familiar with the infrastructure primitives of at least one of AWS, GCP, or Azure, and comfortable reasoning about differences between them
- Have a track record of driving infrastructure architecture across teams and mentoring engineers
About MongoDB
MongoDB is built for change, empowering our customers and our people to innovate at the speed of the market. We have redefined the data platform for the AI era, enabling builders to create, transform, and disrupt industries with software. MongoDB’s unified data platform, the most widely available, globally distributed data platform on the market, helps organizations modernize legacy workloads, embrace innovation, and unleash AI. Our cloud-native platform, MongoDB Atlas, is the only globally distributed, multi-cloud data platform and is available across AWS, Google Cloud, and Microsoft Azure.
With offices worldwide and over 67,000 customers, including 75% of the Fortune 100 and AI-native startups, relying on MongoDB for their most important applications, we’re powering the next era of software.
Our compass at MongoDB is our Leadership Commitment, guiding how and why we make decisions, show up for each other, and win. It’s what makes us MongoDB.
To drive the personal growth and business impact of our employees, we’re committed to developing a supportive and enriching culture for everyone.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-07-21T17:03:54Z'::timestamptz,
   'https://www.mongodb.com/careers/job/?gh_jid=8051387'),
  -- 13. [Software Engineer] MongoDB - Technical Services Engineer (Gurugram)
  ('mongodb',
   'Technical Services Engineer',
   'Software Engineer',
   'Gurugram, Haryana',
   'Haryana',
   'Hybrid',
   'Full time',
   '5+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['JavaScript', 'Node.js', 'Python', 'Java', 'C#', 'C++', 'Ruby', 'MongoDB']::text[],
   'MongoDB’s mission is to empower innovators to create, transform, and disrupt industries by unleashing the power of software and data. We enable organizations of all sizes to easily build, scale, and run modern applications by helping them modernize legacy workloads, embrace innovation, and unleash AI. Our industry-leading developer data platform, MongoDB Atlas, is the only globally distributed, multi-cloud database and is available in more than 115 regions across AWS, Google Cloud, and Microsoft Azure. Atlas allows customers to build and run applications anywhere—on premises, or across cloud providers. With offices worldwide and over 175,000 new developers signing up to use MongoDB every month, it’s no wonder that leading organizations, like Samsung and Toyota, trust MongoDB to build next-generation, AI-powered applications.
MongoDB Technical Services Engineers use their exceptional problem solving and customer service skills, along with their deep technical experience, to advise customers and to solve their complex MongoDB problems. Technical Service Engineers are experts in the entire MongoDB ecosystem - database server, drivers, cloud, and infrastructure. This also includes services such as Atlas (database as a service), or Cloud Manager (which helps customers with automation, backup and monitoring of their MongoDB systems).',
   'See the official job posting for the full list of responsibilities.',
   'You should have 5+ years of proven experience, we consider all candidates with an eye for those who are self-taught, insatiably curious, and multi-faceted.
The ideal candidates should have strong technical experience in more than one of the following areas
- Systems engineering experience, including Linux performance, memory management, I/O tuning, configuration, security, networking, clusters, and troubleshooting
- Understand core Kubernetes concepts, including containers, namespaces, custom resources and multi-cluster deployments
- Should have a good understanding of Networking concepts and protocols (DNS, TCP/IP, SSL/TLS, etc.)
- Storage engineering experience, including NAS, SAN, SSD, multi-pathing, and caching
- Experience building and maintaining complex mission-critical production database systems
- Broad awareness of customer workloads and use cases, including performance, availability, and scalability
- Experience analyzing issues holistically, from the application tier through the database, down to the storage
- Be able to read code, and basic coding/scripting ability in one or more languages: Java, Python, Ruby, C, C++, C#, Javascript, node.js, Go, etc.
- Desire and ability to rapidly learn a wide variety of new technical skills
If you have an operations background, we prefer experience administering large-scale production environments, including hardware, operating systems (e.g. Linux, Windows), networks (including firewalls and load balancers), as well as cloud-based resources (e.g. AWS, Azure, Google Cloud Platform).
You should possess a genuine desire to help people, the ability to think on your feet and remain calm under pressure while solving problems in real-time. There’s a lot to learn, so the desire and ability to rapidly learn a wide variety of new technical skills is paramount.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-03T10:07:04Z'::timestamptz,
   'https://www.mongodb.com/careers/job/?gh_jid=8170628'),
  -- 14. [Sales Executive] Bosch - RBIN_2WP/CIN3_ Assistant Manager- Sales (Gurugram)
  ('bosch',
   'RBIN_2WP/CIN3_ Assistant Manager- Sales',
   'Sales Executive',
   'Gurugram, Haryana',
   'Haryana',
   'Onsite',
   'Full time',
   '2-4 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Negotiation', 'Stakeholder Management', 'Accounting', 'Communication', 'Collaboration']::text[],
   'In India, Bosch is a leading supplier of technology and services in the areas of Mobility Solutions, Industrial Technology, Consumer Goods, and Energy and Building Technology. Additionally, Bosch has in India the largest development center outside Germany, for end-to-end engineering and technology solutions.
1. Acquisition & Sales management: Understanding of business model & business frame work for preparation & execution of acquisition milestones as per Bosch standard process ensuring adherence to quotation guidelines (domain specific).
2. Commercial Management: Preparing the pricing reference data by accounting Forex & RMI reconciliations with regular checks on ECI & RMI impacts ensuring timely readiness for series pricing management contracted with customer accounts including samples for project development activities.
3. Business Support: Prepare contractual documents with the proper understanding of purchase, warranty, force maejures etc. clauses ensuring the overall interest of business.
4. Market Prognosis & Internal Planning: Prepare data & reports for the market prognosis & business planning by analyzing market & customer trends for short, mid & long term business planning.
5. Business Stakeholder Management: Build and maintain robust relationships with customers, ensuring high levels of customer satisfaction. Collaborate with cross-functional teams to deliver effective customer support and manage relationships, fostering long-term partnerships.
6.',
   'See the official job posting for the full list of responsibilities.',
   '1. Education: Bachelor''s degree in engineering (Mechanical, Automobile, Industrial Production, Electrical, Electronics or equivalent).
2. Experience:
- 2-4 years of experience in automotive industry and sales/ controlling function.
- 1-4 years of experience in working for automotive projects (desirable)
- 1-3 years of experience in technical pre-selling, innovation, and customer strategy management.
- Competent in customer communication, negotiation & relationship management.
- Novice analytical skills with the efficient timeline management & problem-solving skills.
- Effective collaboration with cross-functional teams (internal & external stakeholders)
- Novice understanding of sales tools & pricing management.',
   'Knowledge:
- Novice knowledge of Powertrain, Assistance (Braking systems), Electrification & Connectivity domain product & technologies of the automotive industry and upcoming market trends.
- Novice understanding of 2 & 3 wheeler product portfolio & new developments.
- Advance skill & user of Microsoft Office tools with novice understanding of ERP tools / systems.
- Novice knowledge of sales process, product development process, commercial & supply chain management (Desirable)',
   '2026-09-10T04:32:31Z'::timestamptz,
   'https://jobs.smartrecruiters.com/BoschGroup/744000148670839-rbin-2wp-cin3-assistant-manager-sales'),
  -- 15. [Sales Executive] Zscaler - Senior Sales Engineer - Public Sector (Gurugram)
  ('zscaler',
   'Senior Sales Engineer - Public Sector',
   'Sales Executive',
   'Gurugram, Haryana',
   'Haryana',
   'Hybrid',
   'Full time',
   '15+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Linux', 'Agile', 'Leadership', 'Collaboration']::text[],
   'Zscaler (NASDAQ: ZS) accelerates digital transformation so customers can be more agile, efficient, resilient, and secure. The Zscaler Zero Trust Exchange™️ platform protects thousands of customers from cyberattacks and data loss by securely connecting users, devices, and applications in any location. Distributed across 160+ public exchanges globally and thousands of private exchanges at the edge, the SASE-based Zero Trust Exchange is the world’s largest in-line cloud security platform.
We believe the future of work is Human + AI and are building an AI-native enterprise where human potential is amplified by machine intelligence to solve the world’s hardest security challenges. Driven by deep customer obsession, we are committed to the mission, outcome, and to each other. We bring these commitments to life through three core behaviors: ownership and collaboration, trust through outcomes and impact, and a challenge culture with ongoing feedback. Ready to make an impact at the company pioneering security transformation in the AI era? Join us at Zscaler.
Role
We are looking for a Senior Sales Engineer, Public Sector to join our team. This is a Hybrid (Gurgaon) role, reporting to the Senior Manager, Sales Engineering in the SE India department. You will join a global group of professionals passionate about driving a secure, cloud-enabled digital future as a leader in cloud security.',
   '-
Provide technical thought leadership and advice to public sector customers on how to transform their digital experience
-
Take total ownership of the technical sale and associated processes
-
Identify and qualify technical opportunities while developing and maintaining trusted advisor relationships with key customer stakeholders
-
Deliver impactful sales pitches, technical presentations, RFPs and whiteboards to ensure successful deployments',
   '-
You thrive in ambiguity. You''re comfortable building the path as you walk it. You thrive in a dynamic environment, seeing ambiguity not as a hindrance, but as the raw material to build something meaningful.
-
You act like an owner. Your passion for the mission fuels your bias for action. You operate with integrity because you genuinely care about the outcome. True ownership involves leveraging dynamic range: the ability to navigate seamlessly between high-level strategy and hands-on execution.
-
You are a problem-solver. You love running towards the challenges because you are laser-focused on finding the solution, knowing that solving the hard problems delivers the biggest impact.
-
You are a high-trust collaborator. You are ambitious for the team, not just yourself. You embrace our challenge culture by giving and receiving ongoing feedback—knowing that candor delivered with clarity and respect is the truest form of teamwork and the fastest way to earn trust.
-
You are a learner. You have a true growth mindset and are obsessed with your own development, actively seeking feedback to become a better partner and a stronger teammate. You love what you do and you do it with purpose.
-
Foundational understanding of AI/ML technologies and experience leveraging, securing, or positioning AI-driven solutions to optimize outcomes within your functional domain
-
Bachelor’s degree or equivalent combination of education and professional experience
-
15+ years of experience as a Sales Engineer or systems integrator
-
Hands-on experience in installing, configuring, and managing routers, switches, and network security technologies
-
Experience demonstrating or architecting enterprise cloud security platforms utilizing AI-powered threat prevention, automated anomaly detection, or predictive data defense capabilities
-
Proficiency with GPO, Active Directory/LDAP, and SSO/SAML protocols
-',
   'Benefits are listed on the employer''s official job posting.',
   '2026-06-26T05:24:54Z'::timestamptz,
   'https://job-boards.greenhouse.io/zscaler/jobs/5170069007')
) as v(slug, title, category, location, state, work_mode, employment_type, experience, salary_min, salary_max, salary, skills, description, responsibilities, requirements, benefits, posted_at, source_url)
join public.companies c on c.slug = v.slug
where not exists (select 1 from public.jobs j where j.source_url = v.source_url);

commit;

-- Verify: select location, count(*) from public.jobs where state = 'Haryana' and apply_type = 'external' group by location order by location;

-- HireIn AI: real external job openings - Maharashtra
-- Cities: Mumbai 15, Pune 15, Nagpur 1 (target was 15 per city; only postings that are genuinely open were imported).
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
  ('ServiceNow', 'servicenow', 'Enterprise Software', 'https://www.servicenow.com', 'https://www.google.com/s2/favicons?domain=servicenow.com&sz=128', 'Mumbai', 'Maharashtra', 'Mumbai, Maharashtra', 'ServiceNow (Enterprise Software). Official careers: https://careers.smartrecruiters.com/ServiceNow', true),
  ('Rubrik', 'rubrik', 'Data Security', 'https://www.rubrik.com', 'https://www.google.com/s2/favicons?domain=rubrik.com&sz=128', 'Mumbai', 'Maharashtra', 'Mumbai, Maharashtra', 'Rubrik (Data Security). Official careers: https://www.rubrik.com/company/careers', true),
  ('Databricks', 'databricks', 'Data & AI', 'https://www.databricks.com', 'https://www.google.com/s2/favicons?domain=databricks.com&sz=128', 'Mumbai', 'Maharashtra', 'Mumbai, Maharashtra', 'Databricks (Data & AI). Official careers: https://www.databricks.com/company/careers', true),
  ('Swiggy', 'swiggy', 'Consumer Technology', 'https://www.swiggy.com', 'https://www.google.com/s2/favicons?domain=swiggy.com&sz=128', 'Mumbai', 'Maharashtra', 'Mumbai, Maharashtra', 'Swiggy (Consumer Technology). Official careers: https://careers.smartrecruiters.com/Swiggy', true),
  ('Paytm', 'paytm', 'Fintech', 'https://paytm.com', 'https://www.google.com/s2/favicons?domain=paytm.com&sz=128', 'Mumbai', 'Maharashtra', 'Mumbai, Maharashtra', 'Paytm (Fintech). Official careers: https://jobs.lever.co/paytm', true),
  ('MongoDB', 'mongodb', 'Database Software', 'https://www.mongodb.com', 'https://www.google.com/s2/favicons?domain=mongodb.com&sz=128', 'Mumbai', 'Maharashtra', 'Mumbai, Maharashtra', 'MongoDB (Database Software). Official careers: https://www.mongodb.com/company/careers', true),
  ('OpenAI', 'openai', 'Artificial Intelligence', 'https://openai.com', 'https://www.google.com/s2/favicons?domain=openai.com&sz=128', 'Mumbai', 'Maharashtra', 'Mumbai, Maharashtra', 'OpenAI (Artificial Intelligence). Official careers: https://openai.com/careers', true),
  ('InMobi', 'inmobi', 'Advertising Technology', 'https://www.inmobi.com', 'https://www.google.com/s2/favicons?domain=inmobi.com&sz=128', 'Mumbai', 'Maharashtra', 'Mumbai, Maharashtra', 'InMobi (Advertising Technology). Official careers: https://www.inmobi.com/company/careers', true),
  ('Druva', 'druva', 'Data Protection', 'https://www.druva.com', 'https://www.google.com/s2/favicons?domain=druva.com&sz=128', 'Pune', 'Maharashtra', 'Pune, Maharashtra', 'Druva (Data Protection). Official careers: https://www.druva.com/company/careers', true),
  ('Zscaler', 'zscaler', 'Cloud Security', 'https://www.zscaler.com', 'https://www.google.com/s2/favicons?domain=zscaler.com&sz=128', 'Pune', 'Maharashtra', 'Pune, Maharashtra', 'Zscaler (Cloud Security). Official careers: https://www.zscaler.com/careers', true),
  ('Hevo Data', 'hevo-data', 'Data Integration', 'https://hevodata.com', 'https://www.google.com/s2/favicons?domain=hevodata.com&sz=128', 'Pune', 'Maharashtra', 'Pune, Maharashtra', 'Hevo Data (Data Integration). Official careers: https://jobs.lever.co/hevodata', true),
  ('Bosch', 'bosch', 'Engineering & Technology', 'https://www.bosch.in', 'https://www.google.com/s2/favicons?domain=bosch.in&sz=128', 'Pune', 'Maharashtra', 'Pune, Maharashtra', 'Bosch (Engineering & Technology). Official careers: https://careers.smartrecruiters.com/BoschGroup', true)
on conflict (slug) do nothing;

-- 2. Jobs (31), linked to companies by slug
insert into public.jobs (company_id, company, title, category, location, state, work_mode, employment_type, experience, salary_min, salary_max, salary, currency, skills, description, responsibilities, requirements, benefits, posted_at, source_url, apply_url, apply_type, apply_label, status, featured, logo)
select c.id, c.name, v.title, v.category, v.location, v.state, v.work_mode, v.employment_type, v.experience, v.salary_min, v.salary_max, v.salary, 'INR', v.skills, v.description, v.responsibilities, v.requirements, v.benefits, v.posted_at, v.source_url, v.source_url, 'external', 'Apply on Company Website', 'published', false, c.logo_url
from (values
  -- 1. [Customer Success] ServiceNow - Customer Success Executive, Strategic Accounts (Mumbai)
  ('servicenow',
   'Customer Success Executive, Strategic Accounts',
   'Customer Success',
   'Mumbai, Maharashtra',
   'Maharashtra',
   'Onsite',
   'Full time',
   '12+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Customer Success']::text[],
   'It all started when engineer Fred Luddy wrote code that automated a tedious task for his coworker, Phyllis. She cried tears of joy. That moment inspired Fred to build a company that could do that for everyone—freeing people from busywork so they could focus on meaningful work. Today, ServiceNow is the AI control tower for business reinvention. Our ServiceNow AI platform brings together any AI, any data, and any workflow— helping 85% of the Fortune 500® work smarter, faster, and better.
We’re looking for someone who can walk into a boardroom with a CIO, CFO, or CHRO and be treated as a peer — not a vendor. This person owns post-sales outcomes across the full customer lifecycle — implementation, adoption, and value realization — in ServiceNow’s large enterprise accounts in India, building the trusted relationships and business fluency that connect the customer’s ambition to what ServiceNow can deliver. Success here isn’t measured by activity — it’s whether your accounts renew, expand, and see real value from the platform.
This is a foundational role with real room to grow — you’ll be building the account ownership and executive presence the next level of this career path demands.',
   '- Develop and nurture executive relationships (CIO, CFO, CHRO, business unit leaders), building the kind of trust senior stakeholders extend over time
- Own the customer’s post-sales journey end to end — implementation, adoption, and value realization — and are accountable for the KPIs that matter: technical health, renewal, satisfaction, and expansion
- Help translate customer goals into a platform roadmap tied to measurable business outcomes
- Set clear, measurable success metrics with the customer, track progress, and refine the plan as milestones shift
- Support and help coordinate co-delivery models across ServiceNow, GSIs, and SI partners so delivery feels seamless to the customer
- Bring a discovery-first mindset — ask the right questions before proposing a fix, and know when to loop in accelerators, advisory sessions, or expert services
- Contribute to implementation and readiness strategies that help shorten time-to-value
- Support delivery governance on multi-track programs, including organizational change efforts
- Help build and communicate the value story for your accounts — able to speak to advisory and platform value, not just professional services ROI
- Champion ServiceNow’s best practices and stay current on how AI and agentic capabilities are changing customer operating models
- Deliver strong, durable customer satisfaction that shows up in renewals and expansion',
   '- Experience in leveraging or critically thinking about how to integrate AI into work processes, decision-making, or problem-solving. This may include using AI-powered tools, automating workflows, analyzing AI-driven insights, or exploring AI''s potential impact on the function or industry.
- 8–12 years in a professional services or consulting environment, ideally with exposure to technology-enabled transformation (Digital/SaaS/Enterprise Software)
- Experience working with or supporting CxO-level stakeholders, with the poise to grow into owning those relationships directly
- Experience at large India enterprise accounts, with solid judgment navigating multiple stakeholders
- Strong command over knowledge of digital transformation — design, implementation, and management
- Emerging expertise in one industry
- IT, HR, or GBS transformation exposure
- Experience partnering with Big 4 or large SI’s in a delivery context
- 2–5 years of experience on large, multi-tracked programs, ideally including organizational change management
- Experience leveraging AI to enhance work processes, decision-making, and problem-solving — including AI-powered automation, workflow optimization, and data-driven insights
- Prior ServiceNow platform exposure is a strong plus — but we’ll weight fast learning and the ability to translate the platform into business language just as heavily
Why this role is worth being ambitious about
You’ll be backed by proven practices drawn from thousands of engagements, with a clear runway for growth as you build account ownership and executive trust. If you want a role where every year adds visibly more responsibility and access, this is where that starts.
FD21',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-16T09:21:34Z'::timestamptz,
   'https://jobs.smartrecruiters.com/ServiceNow/744000149814859-customer-success-executive-strategic-accounts'),
  -- 2. [Sales Executive] Rubrik - Enterprise Account Executive (New Logo/Hunting) - Large Enterprise (Mumbai)
  ('rubrik',
   'Enterprise Account Executive (New Logo/Hunting) - Large Enterprise',
   'Sales Executive',
   'Mumbai, Maharashtra',
   'Maharashtra',
   'Onsite',
   'Full time',
   '10+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Sales Executive']::text[],
   'Enterprise Account Executive - Large Enterprise (Mumbai) - New Logo/Hunting
Rubrik’s Sales organization is a united group of elite cross-functional sales professionals that help companies & government entities achieve resilience against cyberattacks, malicious insiders, and operational disruptions. We offer continuous professional growth and opportunity through our world-class sales enablement program. Our One Rubrik selling approach provides all the resources you need to exceed your goals, maximize your earnings potential, and take your career to the next level. All this while doing something truly purposeful, protecting the world''s data.
As an Enterprise Account Executive, you will have ownership of all elements of bookings growth in new and existing accounts across west India, especially in Mumbai. We are seeking a relentless self-starter who is hyper-focused on acquiring new logos by discovering and developing new opportunities, managing pipeline, and executing account strategies, while also encouraging existing customer expansion. The AE must drive pipeline generation daily while working with Sales Engineers, Sales Development, Channel Development, and Rubrik Channel Partners to exceed sales quotas.',
   '- Define and execute sales plans for the assigned territory to meet and exceed quota through prospecting, qualifying, managing, and closing sales opportunities
- Develop and manage sales pipeline to move a large number of strategic transactions through the sales process
- Identify and close new opportunities for growth working with a mix of mid-enterprise accounts
- Present Rubrik, Inc. solutions within complex data center design environments
- Co-sell and strategize with partners, distributors, and VAR’s to enable rapid growth
- Provide Rubrik, Inc. management with feedback about the local market opportunity and identification of new business opportunities and channel partnerships',
   '- 10+ years Tech sales experience (selling either IT Infrastructure or SaaS – ideally both)
- Consistent track record landing net "new logos"
- Strong track record of performance selling to End User Fortune 100
- Track record of net new business logos via self sourced pipeline generation activities
- Understands & has used MEDDPICC as a sales qualification tool
- Understanding and experience working with channel
- Highly driven, goal oriented "get it done" attitude
- Experience selling a complex solution
Above all, you will have the ability to operate in a fast-paced, changing environment, self-starter and operate in highly matrixed organization. Demonstrate Rubrik’s RIVET values and be a role model collaborating effectively and creating a positive environment.
#LI-Onsite
#LI-MR3
Join Us in Securing and Accelerating the World''s AI Transformation
Rubrik (RBRK), the Security and AI Operations Company, leads at the intersection of data protection, cyber resilience, and enterprise AI acceleration. Rubrik Security Cloud delivers complete cyber resilience by securing, monitoring, and recovering data, identities, and workloads across clouds. Rubrik Agent Cloud accelerates trusted AI agent deployments at scale by monitoring and auditing agentic actions, enforcing real-time guardrails, fine-tuning for accuracy and undoing agentic mistakes.
Linkedin | X (formerly Twitter) | Instagram | Rubrik.com
Inclusion @ Rubrik
At Rubrik, we are dedicated to fostering a culture where people from all backgrounds are valued, feel they belong, and believe they can succeed. Our commitment to inclusion is at the heart of our mission to secure the world’s data.
Our goal is to hire and promote the best talent, regardless of background. We continually review our hiring practices to ensure fairness and strive to create an environment where every employee has equal access to opportunities for growth and excellence.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-25T11:00:09Z'::timestamptz,
   'https://www.rubrik.com/company/careers/departments/job.8223186?gh_jid=8223186'),
  -- 3. [Software Engineer] Databricks - Delivery Solutions Architect (Mumbai)
  ('databricks',
   'Delivery Solutions Architect',
   'Software Engineer',
   'Mumbai, Maharashtra',
   'Maharashtra',
   'Hybrid',
   'Full time',
   '10+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Python', 'SQL', 'Excel', 'Project Management']::text[],
   'CSQ427R264
At Databricks, we are on a mission to empower our customers to solve the world''s toughest data problems by utilising the the Databricks Data Intelligence Platform.
As a Delivery Solutions Architect (DSA), you will play an important role during this journey. You will collaborate with our sales and field engineering teams to accelerate the adoption and growth of the Databricks platform in your customers. You will also help ensure customer success by increasing focus and technical accountability to our most complex customers who need guidance to accelerate usage on Databricks workloads that they have already selected, helping them maximise the value they get of our platform and the return on investment.
This is a hybrid technical and commercial role. It is commercial in the sense that you will drive growth in your assigned customers and use cases through leading your customers'' stakeholders, building executive relationships, orchestration of other focused/ specialised teams within Databricks, and creating and driving plans and strategies for Databricks colleagues to build upon. This is in parallel to being technical, with expectations being that you become the post-sale technical lead across all Databricks products. This requires you to use your skills and technical credibility to engage and communicate at all levels with an organisation. You will report directly to a DSA Manager within the Field Engineering organization.
The impact you will have:',
   'See the official job posting for the full list of responsibilities.',
   'See the official job posting for detailed requirements.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-16T18:23:37Z'::timestamptz,
   'https://databricks.com/company/careers/open-positions/job?gh_jid=8735814002'),
  -- 4. [Digital Marketing] Swiggy - Content Executive - Events and Partnerships (Mumbai)
  ('swiggy',
   'Content Executive - Events and Partnerships',
   'Digital Marketing',
   'Mumbai, Maharashtra',
   'Maharashtra',
   'Onsite',
   'Full time',
   'Not specified',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Social Media', 'SEO', 'Content Marketing']::text[],
   'About Swiggy:
Founded in 2014, Swiggy is India’s leading tech-driven on-demand delivery platform with a vision to elevate the quality of life for the urban consumer by offering unparalleled convenience. The platform is engineered to connect millions of consumers with hundreds of thousands of restaurants and stores across 500+ cities. Our phenomenal growth has come on the back of great technology, incredible innovation and sound decision-making.
About Servd
- Collaborate with the Events & Partnerships team to align content with brand goals, initiatives, and event objectives.
- Develop compelling, on-brand content across social media, websites, and partner platforms, including reels, stories, short-form videos, interviews, BTS, and trend-driven content.
- Attend and cover events, activations, and partnerships, capturing engaging content and ensuring timely delivery of all content deliverables.
- Build and maintain relationships with industry experts, collaborators, PR agencies and stakeholders to create event opportunities and co-branded campaigns.
- Support brainstorming and develop creative event content strategies to drive growth and revenue for event IPs across verticals.
- Manage the content calendar and live schedule for events, coordinate shoots and internal teams, and ensure timely posting and execution.
- Act as the main point of contact for internal and external teams on events-related content.',
   'See the official job posting for the full list of responsibilities.',
   '- Proven content marketing experience, preferably in lifestyle or hospitality industries.
- Comfortable being on camera and/or has proven experience as an Anchor or Host, preferably in the F&B or lifestyle domain.
- Excellent writing and editing skills, with keen attention to detail, create compelling content and grammar.
- Passion for exploring and discovering Mumbai''s F&B, lifestyle, cultural, and entertainment experiences. Proficiency in content management and social media platforms.
- Familiarity with SEO principles and keyword research tools.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-26T11:47:31Z'::timestamptz,
   'https://jobs.smartrecruiters.com/SWIGGY/6000000001439142-content-executive-events-and-partnerships'),
  -- 5. [Finance Executive] Paytm - Treasury & Capital Markets - Paytm Money (Mumbai)
  ('paytm',
   'Treasury & Capital Markets - Paytm Money',
   'Finance Executive',
   'Mumbai, Maharashtra',
   'Maharashtra',
   'Onsite',
   'Full time',
   '10+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Stakeholder Management', 'Accounting', 'Leadership']::text[],
   'Hiring | Treasury & Capital Markets | Paytm
About Paytm
Paytm is one of India’s leading digital financial services platforms, serving 450M+ consumers and 45M+ merchants. We are building the next generation of financial services by combining technology, scale and innovation to create seamless experiences for consumers and businesses.
We are looking for an experienced Treasury professional to join our Corporate Treasury & Capital Markets team.',
   'The role will be responsible for managing funding, liquidity, banking relationships, debt capital markets, treasury operations, investments and regulatory compliance.
This is a strategic treasury role requiring strong exposure to debt instruments, capital markets, banking relationships, cash management and treasury accounting, along with the ability to work closely with internal and external stakeholders.
1. Capital Markets & Debt Management
Structure, execute and manage CPs, NCDs and Term Loans
Coordinate with credit rating agencies, merchant bankers, debenture trustees, institutional investors and banks
Support fundraising and debt optimization initiatives
Manage financing documentation, security creation and ROC/CERSAI filings
Monitor debt portfolio, repayment schedules and borrowing costs
2. Liquidity & Treasury Investments
Manage daily cash positioning and liquidity across bank accounts
Optimize surplus funds across money market instruments, mutual funds and fixed-income investments
Drive cash-flow and working-capital forecasting
Ensure efficient deployment of funds and minimize idle cash
3. Banking Relationships & Treasury Operations
Manage strategic relationships with banks and financial institutions
Negotiate banking facilities, pricing and credit limits
Oversee H2H, CMS and online banking platforms
Manage banking access controls, signatory matrices, payment gateways and collection accounts
Support internal, statutory and regulatory audits
4. Treasury Accounting, MIS & Reporting
Ensure accurate treasury accounting through SAP FICO/TRM
Manage accounting for interest accruals, loan repayments, borrowing costs and treasury transactions
Build and monitor MIS covering debt, liquidity, interest costs, yield and risk metrics
Present treasury insights to senior leadership
5. Regulatory Compliance & Governance',
   'Ensure timely treasury-related regulatory filings
Manage ROC/CERSAI registrations and documentation
Drive continuous improvement in treasury processes and controls
8–10 years of post-qualification experience in Corporate Treasury, Capital Markets, Banking or Financial Institutions
Strong hands-on experience in Debt Capital Markets and Corporate Treasury
Exposure to CPs, NCDs, Term Loans and debt fundraising
Strong understanding of liquidity and cash-flow management
Experience managing banking relationships and treasury operations
Working knowledge of SAP FICO/TRM
Strong understanding of RBI, FEMA, KYC and treasury compliance
Experience with ROC/CERSAI charge creation and filings
Location: Mumbai
Why Paytm?
At Paytm, you get the opportunity to work at the intersection of technology, financial services and large-scale digital commerce.
Work with one of India''s most recognized digital financial services platforms
Opportunity to manage high-scale treasury and capital market operations
Work closely with senior leadership, banks, financial institutions and capital market stakeholders
Be part of a fast-paced environment where technology and finance come together
Solve complex, high-impact problems at significant scale
Build and shape treasury practices in a dynamic and evolving financial services ecosystem',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-17T07:08:32Z'::timestamptz,
   'https://jobs.lever.co/paytm/031097bb-4cb9-43cd-af38-5483cbfa6064'),
  -- 6. [Operations Executive] Databricks - Partner Enablement Operations Manager (Mumbai)
  ('databricks',
   'Partner Enablement Operations Manager',
   'Operations Executive',
   'Mumbai, Maharashtra',
   'Maharashtra',
   'Onsite',
   'Full time',
   '10+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Excel', 'Stakeholder Management', 'Leadership']::text[],
   'FEQ327R583
The Partner Enablement Operations Manager is a senior operator and builder responsible for designing and running a scalable, predictable, and data-driven operating model for partner enablement at Databricks.
This role serves as the operational backbone and strategic integrator for partner enablement, connecting global strategy to the execution across AMER, EMEA, and APJ regions while ensuring programs are delivered consistently, efficiently, and at scale.
The ideal candidate brings strong executive presence, systems thinking, and a bias for automation. They know how to reduce operational friction, build governance that scales, and introduce AI-enabled workflows that improve responsiveness without adding unnecessary complexity or headcount.
We are looking for a builder who can architect operating systems and drive scalability and excellence for the future.',
   '- Own the partner enablement operating model, including core planning cadences, governance mechanisms, and execution frameworks that connect strategy to execution.
- Run QBRs, MBRs, and executive reviews for partner enablement leadership, using clear metrics and forward-looking insights to drive accountability and decision-making.
- Lead end-to-end execution of partner enablement initiatives, ensuring timelines, dependencies, and deliverables are managed effectively across functions and regions.
- Build and maintain dashboards and operating reviews that surface partner engagement, program performance, risk signals, and areas requiring intervention.
- Act as a key point of contact for cross-regional operational issues and escalations, resolving immediate friction while converting recurring issues into structural improvements.
- Design and implement scalable workflows, SOPs, SLAs, and intake mechanisms that improve consistency, reduce manual effort, and create a better experience for internal stakeholders and partners.
- Introduce AI-enabled and automation-first workflows for intake, reporting, support, certification, and partner operations where they can safely improve speed, quality, and scale.
- Collaborate closely with the Partner organization, Learning and Enablement, Professional Services, and other cross-functional teams to remove friction and improve execution across the partner ecosystem.
- Partner closely with the broader operations business to drive cross-functional leverage of ideas and excellence, ensuring new methods and operational innovations are scaled beyond just partner operations.
- Establish clear ownership models, decision rights, and governance guardrails to support regional nuance without creating shadow processes or operational inconsistencies.',
   '- 10+ years of experience in Learning Operations, Program Management, Professional Services Operations, or a related operational leadership field in a high-growth technology environment.
- Proven experience supporting global or multi-region teams and translating central strategy into executable operating plans.
- Preferred experience in the Data & AI space, with a strong understanding of Databricks'' platform capabilities, key differentiators, and end-to-end solutions, and the ability to work effectively with technical stakeholders.
- Demonstrated ownership of operating cadence, forecasting, planning, and execution frameworks in a complex, matrixed environment.
- Strong analytical capability and the ability to turn data into executive insight, operational decisions, and measurable business outcomes.
- Experience improving processes and workflows, with a clear track record of reducing manual effort and increasing scale through automation or AI-enabled solutions.
- Strong stakeholder management skills and the ability to influence senior leaders across functions without direct authority.
- Ability to work independently, manage priorities across time zones, and drive execution in ambiguous, fast-moving environments.
- Must be open to working a flexible schedule, including frequent late hours to accommodate discussions with the broader enablement team and partner liaisons, the majority of whom are based in the AMER timezone.
- Experience in partner enablement, customer education, learning operations, or training operations.
- Deep expertise working with and for System Integrators (SIs) and ISVs, with a strong grasp of their core operational principles and business models.
- Fluency with AI tools, workflow automation, and analytics platforms used to streamline operations and generate actionable insights.
- Strong commercial and operational acumen, including comfort with utilization, forecasting, partner spend, margin thinking, or RevOps-aligned execution.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-08-04T14:43:57Z'::timestamptz,
   'https://databricks.com/company/careers/open-positions/job?gh_jid=8644000002'),
  -- 7. [Customer Success] Paytm - Customer Support Associate (Mumbai)
  ('paytm',
   'Customer Support Associate',
   'Customer Success',
   'Mumbai, Maharashtra',
   'Maharashtra',
   'Onsite',
   'Full time',
   '4+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['CRM', 'Communication']::text[],
   'Role Overview:
We are looking for a dynamic CST Associate for a blend of voice and non-voice processes. The role involves handling customer interactions across multiple communication channels.

Key Responsibilities:
Handle inbound and outbound customer callsRespond to customer queries via email, chat, and other digital platformsProvide accurate information on products, services, and policiesTroubleshoot issues and escalate when requiredMaintain professionalism and ensure customer satisfactionDocument interactions and follow up as neededCollaborate with internal teams to improve service qualityMeet KPIs and SLA targetsAdhere to company policies and processes

Skills & Qualifications:',
   'We are looking for a dynamic CST Associate for a blend of voice and non-voice processes. The role involves handling customer interactions across multiple communication channels.
Handle inbound and outbound customer callsRespond to customer queries via email, chat, and other digital platformsProvide accurate information on products, services, and policiesTroubleshoot issues and escalate when requiredMaintain professionalism and ensure customer satisfactionDocument interactions and follow up as neededCollaborate with internal teams to improve service qualityMeet KPIs and SLA targetsAdhere to company policies and processes',
   '2–4 years of experience in voice and non-voice customer serviceManage multiple chats/emails/calls simultaneouslyExcellent communication skills in English (written and verbal)Strong problem-solving abilitiesAbility to multitask efficientlyFamiliarity with CRM tools is an advantageComfortable working in a fast-paced environmentWillingness to work rotational shifts (6 days/week)Good interpersonal and teamwork skillsCandidates with hands on experience on AI tools would be preferred.
Office Location:',
   'Benefits are listed on the employer''s official job posting.',
   '2026-05-07T10:22:03Z'::timestamptz,
   'https://jobs.lever.co/paytm/cca996fb-c2b7-46a7-8280-c793670aa81f'),
  -- 8. [Sales Executive] ServiceNow - Enterprise Account Executive - MRD (Mumbai)
  ('servicenow',
   'Enterprise Account Executive - MRD',
   'Sales Executive',
   'Mumbai, Maharashtra',
   'Maharashtra',
   'Onsite',
   'Full time',
   '8+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Business Development']::text[],
   'It all started when engineer Fred Luddy wrote code that automated a tedious task for his coworker, Phyllis. She cried tears of joy. That moment inspired Fred to build a company that could do that for everyone—freeing people from busywork so they could focus on meaningful work. Today, ServiceNow is the AI control tower for business reinvention. Our ServiceNow AI platform brings together any AI, any data, and any workflow— helping 85% of the Fortune 500® work smarter, faster, and better.
You will produce new business sales revenue from a SaaS license model. You will accomplish this through account planning, territory planning, researching prospect customers, using business development strategies and completing field-based sales activities within a defined set of prospects, territory or vertical.',
   '- Develop relationships with multiple C-suite personas (e.g., CFO, CIO, COO, CDO) across all product sales
- Oversee client relationship mapping to the account team, orchestrating an account strategy across a broad virtual team (Solutions Consultants, Solutions Specialist, Success resources, Partners and Marketing, etc.)
- Be a trusted advisor to your customers by understanding their business and advising on how ServiceNow can help help their IT roadmap
- Identify the right specialist/ support resources to bring into a deal, at the right time',
   '- Experience in leveraging or critically thinking about how to integrate AI into work processes, decision-making, or problem-solving. This may include using AI-powered tools, automating workflows, analyzing AI-driven insights, or exploring AI''s potential impact on the function or industry.
- 8+ years of sales experience within software OR solutions sales organization catering to the MRD vertical
- Experience establishing trusted relationships with current and prospective clients and other teams
- Ability to produce new business, Hunt New Logos ,negotiate deals, and maintain healthy C-Level relationships
- Experience achieving sales targets
- The ability to understand the "bigger picture" and our plans around IT
- Experience promoting a customer success focus in a "win as a team" environment',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-24T09:29:35Z'::timestamptz,
   'https://jobs.smartrecruiters.com/ServiceNow/744000151572119-enterprise-account-executive-mrd'),
  -- 9. [Software Engineer] MongoDB - Advisory Solutions Architect (Mumbai)
  ('mongodb',
   'Advisory Solutions Architect',
   'Software Engineer',
   'Mumbai, Maharashtra',
   'Maharashtra',
   'Hybrid',
   'Full time',
   '12+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Node.js', 'Python', 'Java', 'C#', 'C++', 'SQL', 'MongoDB', 'AWS']::text[],
   'We are looking for passionate technologists to join our Pre-Sales organization to ensure that our growth is grounded and guided by strong technical alignment with our platform and the needs of our customers.
MongoDB Pre-Sales Solution Architects are responsible for guiding our customers and users to design and build reliable, scalable systems using our data platform. Our team is made up of seasoned technical sales professionals, software architects, entrepreneurs, and developers who take direct responsibility for customer success, including the design of their software, deployment, and operations. You''ll work closely with our sales executives, helping customers solve business problems by leveraging our solutions, playing a key role in winning deals and driving the business forward. You''ll be a trusted advisor to a wide range of users from startups to the world''s largest enterprise IT organizations.
We are looking to speak to candidates who are based in Mumbai for our hybrid working model.
What you do at MongoDB:
In this role, you will work on complex opportunities where analysis of situations or data requires an in-depth evaluation of various factors. You will:
- Design and Architect: Design scalable and performant applications, systems and infrastructure for large software projects leveraging MongoDB',
   'See the official job posting for the full list of responsibilities.',
   '- Effective Communication: Master presentations, demonstrations, and whiteboarding
- Client Interaction: Develop strategies for discovery and objection handling
Industry Insights:
- Diverse Market Verticals: Gain exposure to a broad spectrum of interesting use cases across various industries
As an ideal candidate, you will have:
- Ideally, 12+ years of related experience in a customer facing role, minimum 7 years of pre-sales experience while navigating complex enterprise software sales cycles with multiple stakeholders
- Minimum of 3 years experience with modern scripting languages (e.g. Python, Node.js, SQL) and/or popular programming languages (e.g. C/C++, Java, C#) in a professional capacity
- Experience designing with scalable and highly available distributed systems in the cloud and on-prem
- Demonstrated ability to work with customers to review complex architecture of existing applications, providing guidance on how to improve by leveraging technology
- Excellent presentation, communication, and interpersonal skills, with the ability to convey complex technical and business concepts in a clear and compelling manner to technology and business leadership
- Presented at industry conferences, published articles, papers or blog posts sharing expertise and showing thought leadership
- Demonstrated ability to drive effective collaboration with Sales Leadership at the Regional Director level to proactively identify strategies driving growth across multiple Sales Reps / Accounts or Industry Verticals
- Demonstrated strong understanding of popular sales methodologies/ frameworks such as MEDDPICC/ Command of the Message
- The ability to travel up to 25%
- A Master’s degree or equivalent work experience
You may also have:
- Experience with database programming and data models
- Experience in data engineering or AI/ML projects
- Experience in transforming legacy systems and platforms into modern, scalable, and efficient technology stacks',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-11T13:02:29Z'::timestamptz,
   'https://www.mongodb.com/careers/job/?gh_jid=8195304'),
  -- 10. [Digital Marketing] OpenAI - B2B Marketing Lead, India (Mumbai)
  ('openai',
   'B2B Marketing Lead, India',
   'Digital Marketing',
   'Mumbai, Maharashtra',
   'Maharashtra',
   'Hybrid',
   'Full time',
   '10+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Stakeholder Management', 'Leadership']::text[],
   'About the Role
We are seeking an experienced and versatile India Business Marketing Lead to drive OpenAI’s enterprise and B2B marketing strategy in India. This is a critical leadership role for a full-stack B2B marketer with strong India market judgment—someone who can operate across enterprise, startup, developer, and partner audiences, build foundational capabilities, and deliver high-impact programs that support revenue growth and long-term trust.
This role will be responsible for shaping and executing integrated B2B marketing initiatives that support enterprise adoption, partner-led growth, startups, and developer-adjacent business audiences in India. The ideal candidate brings deep experience working with sales-led GTM teams, navigating complex stakeholder environments, and translating global strategy into locally effective execution for India.',
   'We are seeking an experienced and versatile India Business Marketing Lead to drive OpenAI’s enterprise and B2B marketing strategy in India. This is a critical leadership role for a full-stack B2B marketer with strong India market judgment—someone who can operate across enterprise, startup, developer, and partner audiences, build foundational capabilities, and deliver high-impact programs that support revenue growth and long-term trust.
This role will be responsible for shaping and executing integrated B2B marketing initiatives that support enterprise adoption, partner-led growth, startups, and developer-adjacent business audiences in India. The ideal candidate brings deep experience working with sales-led GTM teams, navigating complex stakeholder environments, and translating global strategy into locally effective execution for India.
- Lead the development and execution of India B2B marketing strategy, aligned with global priorities and India GTM objectives.
- Drive full-funnel B2B marketing programs across field marketing, content, customer marketing, events, executive engagement, and partner marketing.
- Partner closely with India GTM, Partnerships, Product Marketing, Comms, and Global Affairs to deliver integrated programs that support enterprise adoption and pipeline growth.
- Translate global B2B narratives and launches into India-relevant, market-specific execution across enterprise, startup, developer, and partner motions.
- Establish strong India marketing operating rhythms, including planning cycles, agency management, budget oversight, performance measurement, and reporting.
- Act as the India voice for B2B marketing, bringing market insight, customer perspective, trust signals, and local nuance into global strategy discussions.
- Build and scale foundational B2B marketing capabilities in India, with an eye toward future team growth and specialization.',
   '- 10+ years of experience in B2B or integrated marketing, ideally within technology, platforms, or high-growth environments.
- Proven track record of building and executing B2B marketing programs that support enterprise or partner-led GTM motions in India and/or similarly complex markets.
- Strong understanding of India enterprise buying dynamics, including the role of trust, regulation, partners, SI ecosystems, and local proof points.
- Demonstrated ability to operate at both strategic and executional levels in fast-moving, ambiguous environments.
- Experience working closely with Sales, GTM, Partnerships, Product Marketing, and Comms teams in a matrixed organization.
- Excellent communicator and collaborator, with strong stakeholder management and influence skills across business, policy, product, and GTM audiences.
- Experience managing teams, agencies, vendors, and regional or local partners in India preferred.
Nice to Have:
- Experience marketing AI, developer, or highly technical products.
- Familiarity with regulated industries or trust-sensitive enterprise environments.
- Prior experience leading India, South Asia, regional, or global marketing scopes.
At OpenAI, we value thoughtful builders who are excited to operate at the intersection of technology, business, and societal impact. If you’re motivated by complex challenges, India market nuance, and the opportunity to shape how AI is adopted by businesses in India, we’d love to hear from you.
About OpenAI
OpenAI is an AI research and deployment company dedicated to ensuring that general-purpose artificial intelligence benefits all of humanity. We push the boundaries of the capabilities of AI systems and seek to safely deploy them to the world through our products.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-07-11T00:33:54Z'::timestamptz,
   'https://jobs.ashbyhq.com/openai/2e127590-8604-4901-ac38-8dfd8e9e255f'),
  -- 11. [Finance Executive] Paytm - Finance Controls & Governance (Mumbai)
  ('paytm',
   'Finance Controls & Governance',
   'Finance Executive',
   'Mumbai, Maharashtra',
   'Maharashtra',
   'Onsite',
   'Full time',
   '10+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Accounting', 'Collaboration']::text[],
   'Manager – Finance Controls & Governance
Location: Mumbai, India
Experience: 5–10 Years',
   'We are looking for an experienced Finance professional to join our team as Manager – Finance Controls & Governance. This role is responsible for strengthening the Finance control environment by ensuring adherence to internal policies, monitoring financial and system controls, overseeing critical reconciliations, and driving governance across finance processes.
The ideal candidate will have strong expertise in financial controls, ERP governance, reconciliations, audit management, and process improvement, with the ability to collaborate across Finance, Technology, Compliance, and Operations teams.
1. Financial Controls & Governance
Ensure adherence to approved Finance SOPs, policies, and internal control frameworks.
Monitor key financial processes to identify control gaps, risks, and improvement opportunities.
Conduct periodic control reviews and ensure timely implementation of corrective actions.
Drive process standardization, automation, and continuous improvement initiatives.
Strengthen governance practices to ensure finance processes remain compliant, efficient, and audit-ready.
2. Reconciliations & Exception Management
Oversee critical reconciliations, including:
Bank Reconciliations
General Ledger (GL) Reconciliations
Settlement Accounts
Suspense Accounts
Monitor ageing of unreconciled items and ensure timely resolution of exceptions.
Investigate recurring reconciliation issues and implement preventive controls.
Prepare and publish periodic dashboards on reconciliation status, ageing, and control exceptions.
3. SAP & Financial Systems Controls
Monitor SAP financial controls, master data governance, and accounting configurations.
Review user access, Segregation of Duties (SoD), and maker-checker controls in collaboration with Technology teams.
Monitor system interfaces, manual journal entries, reversals, exception reports, and suspense accounts.
Participate in User Acceptance Testing (UAT) for ERP enhancements and system upgrades.',
   '-Success Measures:
The successful candidate will be expected to:
Achieve 100% adherence to Finance SOPs and internal control processes.
Ensure timely completion of critical reconciliations and reduce ageing of outstanding items.
Close audit observations and control deficiencies within agreed timelines.
Maintain effective SAP access governance, Segregation of Duties (SoD), and system controls.
Drive automation initiatives to reduce manual interventions and improve operational efficiency.
Deliver accurate and timely Finance Control MIS with zero material control failures.
Location -
Mumbai, India
Candidates based in Mumbai or willing to relocate are encouraged to apply.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-07-27T12:27:52Z'::timestamptz,
   'https://jobs.lever.co/paytm/5a817d1c-0cae-4d72-bac2-2daf6c296a02'),
  -- 12. [Operations Executive] Databricks - Manager, Strategy & Operations (Mumbai)
  ('databricks',
   'Manager, Strategy & Operations',
   'Operations Executive',
   'Mumbai, Maharashtra',
   'Maharashtra',
   'Onsite',
   'Full time',
   '7+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['SQL', 'Excel', 'Tableau', 'Salesforce', 'Customer Service', 'Leadership']::text[],
   'SLSQ227R598
Databricks is looking for a motivated Sr. Manager, Strategy & Operations to join our Field Engineering team that helps define Go-To-Market (GTM) strategy, provides strategic analyses and instills operational thoughtfulness to our successful & fast-growing GTM business.
You will use data and qualitative information to help our Sales and Field Engineering Leadership manage the business. You will support essential aspects of our GTM design and annual planning process. This is an individual contributor role. You will help build our data and analytics foundation including executive reporting, health of business reviews, dashboards, and Indicators. You will work with our Field Engineering, Sales, Finance, Data, Marketing, Order Ops, and other GTM teams. You will report to the Sr. Director, Strategy and Ops.
The impact you will have:
- Establish the GTM Strategy and build processes in place to ensure we have the right investments at the right time
- Be a trusted partner to the GTM Leadership by defining, tracking, and implementing goals, programs and strategies that scale
- Guide annual GTM planning process (FY and long-range modeling, investment Return on investment analysis, HC planning, capacity setting)
- Design and manage the headcount forecasting process (FY, long-range, and quarterly modeling)
- Lead executive analyses, strategies, and deliverables (e.g., board materials, QBR)',
   'See the official job posting for the full list of responsibilities.',
   'See the official job posting for detailed requirements.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-04-03T04:26:04Z'::timestamptz,
   'https://databricks.com/company/careers/open-positions/job?gh_jid=8482368002'),
  -- 13. [Sales Executive] InMobi - Assistant Sales Manager - Digital Ads (Mumbai)
  ('inmobi',
   'Assistant Sales Manager - Digital Ads',
   'Sales Executive',
   'Mumbai, Maharashtra',
   'Maharashtra',
   'Onsite',
   'Full time',
   '4-5 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Branding', 'Machine Learning', 'Leadership', 'Collaboration']::text[],
   'InMobi (Corporate)
InMobi Group is a global technology company shaping the future of agentic commerce and advertising. Through its ecosystem of businesses — including InMobi Advertising and flagship consumer platform Glance — InMobi leverages data, machine learning, and generative AI to help brands reach audiences more precisely and consumers discover products more intuitively. Glance, which is pioneering new models of agentic commerce, is owned and operated by Glance InMobi Pte. Ltd., a non-consolidated subsidiary of InMobi Pte. Ltd.
InMobi Advertising
InMobi Advertising, part of global technology company InMobi, is an agentic advertising platform helping brands and merchants achieve their business outcomes. Through its proprietary intelligence, AI-led solutions, and vast consumer reach — including flagship consumer platform Glance — InMobi Advertising delivers the omnichannel performance defining what''s next in advertising and commerce. Glance is owned and operated by Glance InMobi Pte. Ltd., a non-consolidated subsidiary of InMobi Pte. Ltd. To learn more, visit advertising.inmobi.com.
Glance
Glance is an intelligent shopping agent, redefining the commerce experience. Powered by proprietary agentic intelligence and generative AI, Glance delivers a hyper-personalized consumer experience across mobile and TV — shaping the new era of shopping. Glance is operated by Glance InMobi Pte.',
   'See the official job posting for the full list of responsibilities.',
   'Branding Digital Ad Sales
Native Display Ad Sales
Bing Ads Certification',
   'Benefits are listed on the employer''s official job posting.',
   '2026-07-03T09:54:25Z'::timestamptz,
   'https://job-boards.greenhouse.io/inmobi/jobs/8023176'),
  -- 14. [Software Engineer] MongoDB - Senior Solutions Architect (Mumbai)
  ('mongodb',
   'Senior Solutions Architect',
   'Software Engineer',
   'Mumbai, Maharashtra',
   'Maharashtra',
   'Hybrid',
   'Full time',
   '8-11 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Node.js', 'Python', 'Java', 'C#', 'C++', 'SQL', 'MongoDB', 'AWS']::text[],
   'We are looking for passionate technologists to join our Pre-Sales organization to ensure that our growth is grounded and guided by strong technical alignment with our platform and the needs of our customers.
MongoDB Pre-Sales Solution Architects are responsible for guiding our customers and users to design and build reliable, scalable systems using our data platform. Our team is made up of seasoned technical sales professionals, software architects, entrepreneurs, and developers who take direct responsibility for customer success, including the design of their software, deployment, and operations. You''ll work closely with our sales executives, helping customers solve business problems by leveraging our solutions, playing a key role in winning deals and driving the business forward. You''ll be a trusted advisor to a wide range of users from startups to the world''s largest enterprise IT organizations.
We are looking to speak to candidates who are based in Mumbai for our hybrid working model.
As an ideal candidate, you will have:
- Ideally 8 to 11 years of related experience in a customer facing role, with 5 to 7 years of experience in pre-sales with enterprise software
- Minimum of 3 years experience with modern scripting languages (e.g. Python, Node.js, SQL) and/or popular programming languages (e.g. C/C++, Java, C#) in a professional capacity
- Experience designing with scalable and highly available distributed systems in the cloud and on-prem',
   'See the official job posting for the full list of responsibilities.',
   '- Effective Communication: Master presentations, demonstrations, and whiteboarding
- Client Interaction: Develop strategies for discovery and objection handling
Industry Insights:
- Diverse Market Verticals: Gain exposure to a broad spectrum of interesting use cases across various industries
About MongoDB
MongoDB is built for change, empowering our customers and our people to innovate at the speed of the market. We have redefined the data platform for the AI era, enabling builders to create, transform, and disrupt industries with software. MongoDB’s unified data platform, the most widely available, globally distributed data platform on the market, helps organizations modernize legacy workloads, embrace innovation, and unleash AI. Our cloud-native platform, MongoDB Atlas, is the only globally distributed, multi-cloud data platform and is available across AWS, Google Cloud, and Microsoft Azure.
With offices worldwide and over 67,000 customers, including AI-native startups and approximately 75% of the Fortune 100, relying on MongoDB for their most important applications, we’re powering the next era of software.
Our compass at MongoDB is our Leadership Commitment, guiding how and why we make decisions, show up for each other, and win. It’s what makes us MongoDB.
To drive the personal growth and business impact of our employees, we’re committed to developing a supportive and enriching culture for everyone. From employee affinity groups, to fertility assistance and a generous parental leave policy, we value our employees’ wellbeing and want to support them along every step of their professional and personal journeys. Learn more about what it’s like to work at MongoDB, and help us make an impact on the world!
MongoDB is committed to providing any necessary accommodations for individuals with disabilities within our application and interview process. To request an accommodation due to a disability, please inform your recruiter.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-15T10:27:55Z'::timestamptz,
   'https://www.mongodb.com/careers/job/?gh_jid=8203765'),
  -- 15. [Sales Executive] Rubrik - Senior Sales Engineer (Mumbai)
  ('rubrik',
   'Senior Sales Engineer',
   'Sales Executive',
   'Mumbai, Maharashtra',
   'Maharashtra',
   'Hybrid',
   'Full time',
   '7-10 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Leadership']::text[],
   'Senior Sales Engineer (Pre-sales) Mumbai, India
Rubrik is looking for Sales Engineers to provide technical direction and business guidance to the regional sales team. As a Sales Engineer, you will be accountable for regional revenue goals by driving innovative technical programs and overseeing day-to-day account-level activities. You will be responsible for evangelizing, positioning, and architecting the industry''s first hyper-converged hybrid cloud data management platform for a mix of enterprise, mid-market, and small business customers throughout your region.
About the position:
- Provides technical leadership and direction to customers and internal staff in the development of fully integrated technology solutions in support of pre-sales activities in the assigned market.
- Assists in the analysis, design and development of fully integrated technology solutions.
- Demonstrates technical leadership and subject matter expertise on Rubrik’s products, distributed architectures, file systems, and competitive storage offerings in the SAN product space.
- Acts as technical expert and consultant to develop and propose solutions that meet the technology and business requirements of assigned customers.
- Makes technical and sales presentations to customer''s technical staff and senior management.
- Serves as a trusted technology advisor to customers and serves as an internal resource on technical issues or specific business applications within an assigned market segment.',
   'See the official job posting for the full list of responsibilities.',
   '- 7-10 + years of sales engineering experience (or customer facing consulting experience) with Large Enterprise clients preferably in a software or data center environment.
- Driven - need for success, highly energetic with a strong hands-on, “can do” approach.
- The successful candidate must have a fundamental breadth of technical knowledge in cloud data management, backup and disaster recovery and data analytics.
- Entrepreneurial - willing to go the extra mile, strong work ethic, resourceful, “get it done” attitude
- Strives in moving in a fast-paced environment; including handling multiple calls/demos per day with immediate follow up.
- A high level of business acumen and experience working with Cxo level personnel, bringing technology solutions to solve business challenges.
- Smart, adaptable and open-minded
- Bachelor’s degree required or equivalent experience (pref in technology/computer science)
Bonus Points:
- Knowledge of Partner and Client ecosystem a plus
Join Us in Securing and Accelerating the World''s AI Transformation
Rubrik (RBRK), the Security and AI Operations Company, leads at the intersection of data protection, cyber resilience, and enterprise AI acceleration. Rubrik Security Cloud delivers complete cyber resilience by securing, monitoring, and recovering data, identities, and workloads across clouds. Rubrik Agent Cloud accelerates trusted AI agent deployments at scale by monitoring and auditing agentic actions, enforcing real-time guardrails, fine-tuning for accuracy and undoing agentic mistakes.
Linkedin | X (formerly Twitter) | Instagram | Rubrik.com
Inclusion @ Rubrik
At Rubrik, we are dedicated to fostering a culture where people from all backgrounds are valued, feel they belong, and believe they can succeed. Our commitment to inclusion is at the heart of our mission to secure the world’s data.
Our goal is to hire and promote the best talent, regardless of background.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-08-20T17:29:11Z'::timestamptz,
   'https://www.rubrik.com/company/careers/departments/job.8108586?gh_jid=8108586'),
  -- 16. [QA Engineer] Druva - Senior Staff Software Engineer in Test (Pune)
  ('druva',
   'Senior Staff Software Engineer in Test',
   'QA Engineer',
   'Pune, Maharashtra',
   'Maharashtra',
   'Onsite',
   'Full time',
   '6-9 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Python', 'Golang', 'SQL', 'MongoDB', 'Git', 'Linux', 'Agile', 'Jira']::text[],
   'About Druva
Druva is the resilience foundation for the AI enterprise, helping organizations secure and recover from connected risk across data, cyber, identity, and AI. The Resilience Cloud is a fully managed, cloud-native SaaS platform that delivers air-gapped and immutable protection across cloud, SaaS, on-premises, endpoint, and edge environments. Powered by Dru MetaGraph, Druva’s graph-powered intelligence layer, the platform connects critical business context so customers can understand risk, respond faster, recover cleanly, and govern data with greater confidence.
Trusted by nearly 7,500 customers, including 75 of the Fortune 500, Druva helps safeguard the critical information and systems businesses depend on in an increasingly connected world.
Visit druva.com and follow us on LinkedIn, X and Facebook.',
   'We are looking for a highly skilled SDET to join our Agile development team. In this role, you will not just test software; you will deconstruct complex features to understand their design, build robust automation frameworks, and ensure the resilience of our cloud-based backup solutions.
You will work closely with developers to perform white-box and black-box testing, owning the quality of features from conception to deployment.
- Agile Collaboration: Work closely with the development team in an Agile environment to understand functional specifications and design requirements.
- Test Planning: Independently create comprehensive feature test plans aligned with development milestones and feature completion.
- Automation Frameworks: Leverage existing automation frameworks to automate feature tests and actively augment libraries to support new functionalities.
- End-to-End Ownership: Own the complete test execution cycle for user stories, ensuring high-quality delivery.
- Testing Strategy: Perform a mix of automated, manual, white-box, and black-box testing.
- Infrastructure Management: Create, maintain, and document testbed setups and environments.
- Quality Assurance: Timely reporting, tracking, and updating of issues and test cases using management tools.
- Cross-Functional Delivery: Collaborate with cross-functional teams to ensure quality benchmarks are met throughout the development lifecycle.',
   'Operating Systems & Core Concepts:
- Proficiency in Windows and Linux OS.
- Deep understanding of Threading, Multiprocessing, and Socket Programming.
- Strong knowledge of Networking protocols and Cloud Architecture.
Programming & Scripting:
- Strong proficiency in one or more high-level languages: Python, Golang.
- Experience with SQL databases.
Testing & Tools:
- Expertise in RESTful API testing.
- Proficiency with bug and test management tools (e.g., Jira, XRay).
- Familiarity with Agile testing methodologies and quality metrics.
- Strong analytical, troubleshooting, and debugging capabilities.
Version Control:
- Proficiency with Git or SVN.
Pluses (Nice to Have)
- Familiarity with virtualization technologies (e.g., VMware).
- Experience with NoSQL databases (e.g., MongoDB, Cassandra).
- B.Tech / B.E / M.E./ M.Tech (Computer Science) or equivalent.
Experience : 6-9 Years',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-21T05:49:12Z'::timestamptz,
   'https://www.druva.com/why-druva/explore/careers/jobs/8750848002/?gh_jid=8750848002'),
  -- 17. [DevOps Engineer] Zscaler - Senior Staff Platform Engineer (Pune)
  ('zscaler',
   'Senior Staff Platform Engineer',
   'DevOps Engineer',
   'Pune, Maharashtra',
   'Maharashtra',
   'Hybrid',
   'Full time',
   '8+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Python', 'AWS', 'Kubernetes', 'Terraform', 'CI/CD', 'Agile', 'Communication', 'Collaboration']::text[],
   'Zscaler (NASDAQ: ZS) accelerates digital transformation so customers can be more agile, efficient, resilient, and secure. The Zscaler Zero Trust Exchange™️ platform protects thousands of customers from cyberattacks and data loss by securely connecting users, devices, and applications in any location. Distributed across 160+ public exchanges globally and thousands of private exchanges at the edge, the SASE-based Zero Trust Exchange is the world’s largest in-line cloud security platform.
We believe the future of work is Human + AI and are building an AI-native enterprise where human potential is amplified by machine intelligence to solve the world’s hardest security challenges. Driven by deep customer obsession, we are committed to the mission, outcome, and to each other. We bring these commitments to life through three core behaviors: ownership and collaboration, trust through outcomes and impact, and a challenge culture with ongoing feedback. Ready to make an impact at the company pioneering security transformation in the AI era? Join us at Zscaler.
Role
We are looking for a Sr. Staff AI Platform Engineer to join our team. This is an On-site role based in Bangalore/Pune, reporting to the Senior Manager in the IT Data Strategy department. In this position, you will design, scale, and maintain enterprise cloud infrastructure and platform capabilities to support production AI/ML workloads.',
   '- Design, build, and maintain scalable, secure, and highly available AWS infrastructure (EKS, Lambda, ECS, VPC, IAM) for AI/ML workloads using Terraform, following IaC best practices including reusable modules, remote state management, and environment-based blueprints
- Own and continuously evolve GitLab CI/CD pipelines for AI platform services, automating build, test, security scanning, and multi-environment deployment workflows to enable fast, reliable, and repeatable releases
- Architect a centralized observability stack using Prometheus and Grafana with golden-signal dashboards across AI/ML services and infrastructure, design intelligent alerting strategies (Alertmanager, PagerDuty, OpsGenie), and lead incident response, root-cause analysis, and postmortems to improve MTTA/MTTR
- Define and track DORA metrics to drive delivery and reliability improvements, while building self-healing, auto-scaling, and cost-optimized infrastructure for AI/ML services (LLM inference, vector databases, agent frameworks) on Kubernetes (EKS)
- Implement infrastructure security best practices, establish platform governance standards, partner with AI/ML and data engineering teams on production-grade AI/RAG deployments, and mentor junior/mid-level engineers through design and code reviews',
   '- You act like an owner with a passion for the mission, operating with integrity and navigating seamlessly between high-level platform strategy and hands-on execution.
- You are a high-trust collaborator who is ambitious for the overall team, fostering an open feedback culture delivered with clarity and respect to build lasting trust.
- You are driven by innovation and deep technical curiosity, continuously seeking secure, scalable, and modern solutions to complex platform engineering challenges.
- You champion simplicity by distilling complex technical architecture, user needs, and operational concepts into clear, actionable plans and focused communication.
- You are data-driven, leveraging analytics and measurable metrics to guide informed engineering decisions, evaluate truth, and optimize reliability.
- Demonstrated curiosity and active exploration of AI tools, with a proven history of integrating new technologies to enhance daily workflows and augment problem-solving
- 8+ years of experience as a Platform Engineer / Site Reliability Engineer / DevOps Engineer, including 3+ years supporting AI/ML or data platform infrastructure, with deep hands-on expertise in AWS (EKS, Lambda, ECS, VPC, IAM, S3)
- Strong hands-on experience with Infrastructure as Code using Terraform (modules, workspaces, remote state) and designing/maintaining CI/CD pipelines with GitLab CI/CD (or equivalent), including runners and deployment automation
- Proven expertise in centralized observability using Prometheus and Grafana (custom exporters, dashboard design, alerting rules), along with experience designing and tuning alerting/on-call systems (Alertmanager, PagerDuty, OpsGenie) and owning incident response for production services
- Solid, hands-on understanding of DevOps/DORA metrics (deployment frequency, lead time for changes, change failure rate, MTTR) and how to use them to drive engineering improvement',
   'Benefits are listed on the employer''s official job posting.',
   '2026-08-04T10:21:02Z'::timestamptz,
   'https://job-boards.greenhouse.io/zscaler/jobs/5200228007'),
  -- 18. [Data Analyst] Druva - Senior Data Analyst (Pune)
  ('druva',
   'Senior Data Analyst',
   'Data Analyst',
   'Pune, Maharashtra',
   'Maharashtra',
   'Onsite',
   'Full time',
   '5+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Python', 'SQL', 'Tableau', 'Statistics', 'Salesforce', 'HubSpot', 'Communication']::text[],
   'Druva, the autonomous data security company, puts data security on autopilot with a 100% SaaS, fully managed platform to secure and recover data from all threats. The Druva Data Security Cloud ensures the availability, confidentiality, and fidelity of data - providing customers with autonomous protection, rapid incident response, and guaranteed data recovery. The company is trusted by its more than 6,000 customers, including 65 of the Fortune 500, to defend business data in today’s ever-connected world. Amidst a rapidly evolving security landscape, Druva offers a $10 million Data Resiliency Guarantee ensuring customer data is protected and secured against every cyber threat. Visit druva.com and follow us on LinkedIn, X and Facebook.
Senior Business Analyst - Go-To-Market',
   '- Act as a strategic advisor to your cross-functional stakeholders in Sales, Marketing, Channel, and Renewals and a liaison to the technical Business Intelligence team
- Execute deep-dive analysis addressing key business issues and present findings to senior stakeholders
- Collaborate with key stakeholders to translate business questions into verifiable hypotheses using complex, multi-source data
- Build dashboards and custom reports to track key metrics, empower other team members with data, and investigate business questions
- Demonstrate great judgment in quickly forming actionable, data-driven conclusions in the face of uncertainty
- Enable effective decision making by retrieving and aggregating data from multiple sources and compiling it into a digestible and actionable format
- Diagnose business process flows and contribute to improving automation and process improvements via data apps, workflow triggers/alerts and business applications enhancements
What We Are Looking For:
- Bachelor''s degree in Computer Science, Statistics, Business, or related discipline
- 5 years relevant experience in business analysis, management consulting, or other related experiences analyzing large datasets to solve business problems and presenting results
- Proven analytical and quantitative skills with an ability to use data and metrics to back up assumptions, develop business cases, and complete root cause analyses
- Ability to take loosely defined business questions and translate them into clearly defined technical/data specifications
- Experience working directly in the SaaS space, bonus to have experience working with Sales, Marketing, Channel, or Renewals teams
- Experience defining requirements and using data and metrics to draw business insights and process improvements
- Experience making business recommendations and influencing stakeholders
- Experience with a modern BI stack with tools such as dbt, Looker, Sigma, Snowflake, Tableau, Alteryx, etc.',
   'See the official job posting for detailed requirements.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-16T15:15:23Z'::timestamptz,
   'https://www.druva.com/why-druva/explore/careers/jobs/8793808002/?gh_jid=8793808002'),
  -- 19. [Customer Success] Hevo Data - Senior Customer Experience Engineer (Pune)
  ('hevo-data',
   'Senior Customer Experience Engineer',
   'Customer Success',
   'Pune, Maharashtra',
   'Maharashtra',
   'Onsite',
   'Full time',
   '6+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Java', 'SQL', 'MySQL', 'PostgreSQL', 'REST APIs', 'Communication', 'Collaboration']::text[],
   'About Hevo
Hevo Data is a no-code data pipeline platform that helps companies consolidate data from multiple sources for faster analytics. Our fully managed pipelines let data teams move data from 150+ sources (databases, SaaS applications, cloud storage, SDKs, streaming services) into warehouses and lakes, all without writing code.
Over 2,000 data teams in 45+ countries use Hevo, including DoorDash, Foot Locker, Arhaus, and Santander. We’re top-rated in the G2 Data Pipeline category, backed by Sequoia Capital, Qualgro, and Chiratae Ventures, and operate out of San Francisco and Bangalore.
Role Summary
The Senior Customer Experience Engineer takes ownership of the CX team''s most complex, ambiguous, and high-impact customer issues, leading technical investigations through to resolution while keeping customers clearly informed throughout.
With deep specialization in JDBC-based sources and integrations, the role acts as the technical bridge between customers, CX, Product, and Engineering. Beyond resolving individual tickets, this role is expected to strengthen support processes, expand the use of AI and automation, build technical depth across the team, and mentor other CX engineers — pushing the team toward greater speed, accuracy, and consistency in service delivery.',
   '-
Own complex, ambiguous, and high-impact customer issues from investigation through resolution, with clear and proactive customer communication throughout.
-
Act as the technical escalation point for L1 and Associate CXEs, offering troubleshooting guidance and helping the team avoid unnecessary Engineering escalations.
-
Diagnose issues using SQL, logs, API responses, database behavior, and product internals — going beyond surface-level troubleshooting.
-
Partner with Engineering and Product on complex issues by providing strong technical context, reproduction steps, impact assessment, and investigation findings.
-
Spot recurring issues and work with Engineering/Product to drive permanent fixes, rather than repeatedly patching the same symptoms.
-
Participate in — and where appropriate, lead — customer-impacting incidents and high-priority escalations.
-
Drive improvements to support processes, tooling, automation, and AI-assisted workflows that cut resolution time, reduce repeat issues, and lower manual effort.
-
Build and own technical depth in areas such as JDBC integrations, databases, APIs, and data pipelines, acting as the team''s internal subject-matter expert.
-
Mentor Associate CXEs and teammates through case reviews, technical coaching, and knowledge sharing, and show broader team citizenship — covering escalations, contributing to shared SOPs/KBs, and flagging process gaps beyond your own scope.
-
Own and continuously improve technical documentation, SOPs, KBs, and enablement material for the wider team.
What Success Looks Like
-
Consistent ownership and resolution of complex, high-impact technical issues, with strong customer communication throughout.
-
Low rate of avoidable escalations, and high-quality escalations when Engineering involvement is genuinely required.
-
Fewer recurring issues and repeat contacts, with reduced dependency on Engineering over time.
-',
   '-
Strong grasp of cloud technologies, databases, and integrations, with hands-on experience troubleshooting applications end-to-end.
-
Strong SQL skills and hands-on debugging experience across databases, applications, and integrations.
-
Solid knowledge of JDBC-based integrations and the connectivity concepts behind them.
-
Working knowledge of data warehousing, ETL, REST APIs, webhooks, and distributed systems fundamentals.
-
Familiarity with Java or another object-oriented programming language.
-
Excellent troubleshooting, debugging, research, and problem-solving abilities.
-
Solid track record in technical product support, including email-based support operations.
-
Experience producing technical documentation and enabling other technical team members.
-
Strong customer communication skills, with the ability to explain complex technical issues clearly.
-
Ability to independently prioritize and drive complex issues across multiple teams.
-
3–6 years of experience in technical product support, application support, database/integration support, or a similar technical role.
-
1+ years of hands-on experience troubleshooting JDBC sources or integrations.
-
DBA experience with PostgreSQL, MySQL, SQL Server, Oracle, or similar databases.
-
Experience supporting B2B SaaS, integration, or data infrastructure products.
-
Experience handling customer-impacting incidents and complex technical escalations.
-
Experience with ETL or data integration platforms.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-25T08:22:07Z'::timestamptz,
   'https://jobs.lever.co/hevodata/bfdebed3-3762-4854-a1e9-01bda6bebe09'),
  -- 20. [Sales Executive] Swiggy - Sales Manager I (Pune)
  ('swiggy',
   'Sales Manager I',
   'Sales Executive',
   'Pune, Maharashtra',
   'Maharashtra',
   'Onsite',
   'Full time',
   '0-2 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Excel', 'Market Research', 'Negotiation', 'Business Development', 'Problem Solving']::text[],
   'About Swiggy:
Swiggy is India’s leading on-deamand delivery platform with a tech-first approach to logistics and a solution-first approach to consumer demands. With a presence in 500+ cities across India, partnerships with hundreds of thousands of restaurants, an employee base of over 5000, a 2 lakh+ strong independent fleet of Delivery Executives, we deliver unparalleled convenience driven by continuous innovation.',
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
- 0-2 years in B2B sales, field sales, or business development (preferably in FMCG food/beverage, or hotel industry)
- Track record of meeting or exceeding targets and managing your own pipeline
- Restaurant Business is a round-the-clock business; the role holder has to take ownership of the growth of the assigned portfolio of restaurant partner
- Comfort with data, especially Excel—you should be able to build pivot tables, use VLOOKUP, and create dashboards without help
- Post - Graduated preferably in marketing or sales
0-2 years in B2B sales, field sales, or business development (preferably in FMCG food/beverage, or hotel industry)',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-23T06:04:16Z'::timestamptz,
   'https://jobs.smartrecruiters.com/SWIGGY/6000000001431650-sales-manager-i'),
  -- 21. [Software Engineer] Zscaler - Senior Detection Engineer (Pune)
  ('zscaler',
   'Senior Detection Engineer',
   'Software Engineer',
   'Pune, Maharashtra',
   'Maharashtra',
   'Hybrid',
   'Full time',
   'Not specified',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Python', 'Ruby', 'CI/CD', 'Git', 'Machine Learning', 'Agile', 'Collaboration']::text[],
   'Zscaler (NASDAQ: ZS) accelerates digital transformation so customers can be more agile, efficient, resilient, and secure. The Zscaler Zero Trust Exchange™️ platform protects thousands of customers from cyberattacks and data loss by securely connecting users, devices, and applications in any location. Distributed across 160+ public exchanges globally and thousands of private exchanges at the edge, the SASE-based Zero Trust Exchange is the world’s largest in-line cloud security platform.
We believe the future of work is Human + AI and are building an AI-native enterprise where human potential is amplified by machine intelligence to solve the world’s hardest security challenges. Driven by deep customer obsession, we are committed to the mission, outcome, and to each other. We bring these commitments to life through three core behaviors: ownership and collaboration, trust through outcomes and impact, and a challenge culture with ongoing feedback. Ready to make an impact at the company pioneering security transformation in the AI era? Join us at Zscaler.
Role
We are looking for a Senior Detection Engineer to join our team. This is a Hybrid role in Pune, reporting to the Senior Manager, Threat Researcher in the Threat Hunting department. You will own a coverage area and be accountable for its technical direction, overall efficacy, and high-standard content development.',
   '- Take complete accountability for your domain''s health, backlog prioritization, and performance - serving as the ultimate point of contact for its overall efficacy
- Personally tackle the hardest detection challenges to establish design patterns, coding standards, and implementation blueprints for the rest of the team
- Define clear criteria for validated, tuned, and maintainable content, using design/code reviews and root-cause analyses to continuously eliminate false positives and missed threats
- Identify and actively drive the core numbers that define area health, including detection fidelity, ATT&CK coverage, false-positive/negative rates, and regression prevention
- Systematically translate input from threat intelligence, proactive threat hunting, and SOC analyst feedback into concrete roadmap priorities and continuous engine improvements',
   '- You thrive in ambiguity. You''re comfortable building the path as you walk it. You thrive in a dynamic environment, seeing ambiguity not as a hindrance, but as the raw material to build something meaningful.
- You act like an owner. Your passion for the mission fuels your bias for action. You operate with integrity because you genuinely care about the outcome. True ownership involves leveraging dynamic range: the ability to navigate seamlessly between high-level strategy and hands-on execution.
- You are a problem-solver. You love running towards the challenges because you are laser-focused on finding the solution, knowing that solving the hard problems delivers the biggest impact.
- You are a high-trust collaborator. You are ambitious for the team, not just yourself. You embrace our challenge culture by giving and receiving ongoing feedback—knowing that candor delivered with clarity and respect is the truest form of teamwork and the fastest way to earn trust.
- You are a learner. You have a true growth mindset and are obsessed with your own development, actively seeking feedback to become a better partner and a stronger teammate. You love what you do and you do it with purpose.
- Foundational understanding of AI/ML technologies and experience leveraging, securing, or positioning AI-driven solutions to optimize outcomes within your functional domain
- Deep detection experience in at least one of Endpoint (MDR), Cloud/SaaS, Identity, Email, or SIEM, and the judgment to own that area
- A track record of owning technical work end-to-end and being answerable for its quality without much oversight
- A strong grasp of how attackers operate, and fluent use of ATT&CK to decide where coverage should go
- Detector-as-code, version control, code review, and controlled deployment as the way you already work (Git, CI/CD)
- Experience leveraging AI-driven automation, LLMs, or machine learning models to accelerate detection engineering and threat analysis workflows',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-01T09:55:46Z'::timestamptz,
   'https://job-boards.greenhouse.io/zscaler/jobs/5200408007'),
  -- 22. [Digital Marketing] Swiggy - Assistant Manager - Growth & Marketing (Pune)
  ('swiggy',
   'Assistant Manager - Growth & Marketing',
   'Digital Marketing',
   'Pune, Maharashtra',
   'Maharashtra',
   'Onsite',
   'Full time',
   '3-5 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Campaign Management', 'Negotiation', 'Problem Solving']::text[],
   'About Swiggy Instamart:
Swiggy Instamart, is building the convenience grocery segment in India. We offer more than 40000 items to our customers within 10-15 mins. We are striving to augment our consumer promise of enabling unparalleled convenience by making grocery delivery instant and delightful. Instamart has been operating in 120+ cities across India and plan to expand to a few more soon. We have seen immense love from the customers till now and are excited to redefine how India shops.
Ways of working: Mandate 3 : Onsite - Office / Field: Employees are expected to work from the office on all days out of their respective base locations.
Location: Pune, Maharashtra',
   '- BTL Strategy & Framework: Design the overarching BTL roadmap for the brand launch, identifying high-affinity "pockets" where our target audience lives, commutes, and shops.
- Ownership of "Wacky" Activations: Lead the conceptualization and high-stakes execution of "Out-of-the-Box" marketing stunts. You will be expected to turn wild ideas into reality to drive massive top-of-funnel awareness.
- Continuous Growth Through Physical Loops: Move beyond one-off events to create repeatable "Growth Engines" on the ground—such as hyper-local referral hubs, society-level subscription drives, and community-based sampling programs.
- End-to-End Campaign Management: Own the BTL lifecycle from vendor scouting and negotiation to fabrication, promoter training, and post-activation auditing.
- Creative Scoping for Offline: Work closely with design teams to create POSM (Point of Sale Material) and activation setups ensuring the brand aesthetic is maintained across all touchpoints.
- Budget & ROI Ownership: Manage a significant BTL budget, with a ruthless focus on Cost Per Trial (CPT) and Cost Per Acquisition (CPA). You will be responsible for proving the ROI of offline efforts through data-backed reporting.
- Field Intelligence: Build a feedback loop from the ground up. You will synthesize consumer reactions from the field to provide the product and GTM teams with insights on pricing sensitivity, packaging appeal, and competitor moves.',
   '- 3-5 years of experience in BTL, Rural Marketing, or Experimental Marketing. Candidates from Telecom, FMCG, or Fintech (Payment Apps) who have managed large-scale ground activations are preferred.
- A proven track record of "Growth Hacking" in the offline world. You should have examples of how you gained massive visibility using unconventional methods rather than just standard billboards.
- Existing relationships with high-quality BTL agencies and fabricators across major urban and semi-urban hubs.
- Strong marketing knowledge with problem solving skills, ability to hustle and get things done in minimum time frames
- Ability to use tools to bridge the gap between offline activations and online app conversions.
- Extreme attention to detail and willingness to roll up your sleeves - high ownership & action bias',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-26T13:31:55Z'::timestamptz,
   'https://jobs.smartrecruiters.com/SWIGGY/6000000001439199-assistant-manager-growth-marketing'),
  -- 23. [Operations Executive] Swiggy - Operations Manager (Pune)
  ('swiggy',
   'Operations Manager',
   'Operations Executive',
   'Pune, Maharashtra',
   'Maharashtra',
   'Onsite',
   'Full time',
   '4-6 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Communication', 'Leadership', 'Time Management']::text[],
   'About Swiggy:
Swiggy is India’s leading on-deamand delivery platform with a tech-first approach to logistics and a solution-first approach to consumer demands. With a presence in 500+ cities across India, partnerships with hundreds of thousands of restaurants, an employee base of over 5000, a 2 lakh+ strong independent fleet of Delivery Executives, we deliver unparalleled convenience driven by continuous innovation.',
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
- Attention to detail and ability to critically think through and resolve problems
"We are an equal opportunity employer, and all qualified applicants will receive consideration for employment without regards to race, color, religion, sex, disability status, or any other characteristic protected by the law"
Postgraduate with 4-6 years'' experience.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-25T06:39:17Z'::timestamptz,
   'https://jobs.smartrecruiters.com/SWIGGY/6000000001438314--operations-manager'),
  -- 24. [Customer Success] Hevo Data - Associate Customer Experience Engineer (Pune)
  ('hevo-data',
   'Associate Customer Experience Engineer',
   'Customer Success',
   'Pune, Maharashtra',
   'Maharashtra',
   'Onsite',
   'Full time',
   '3+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Java', 'SQL', 'MySQL', 'PostgreSQL', 'REST APIs', 'Communication']::text[],
   'About Hevo
Hevo Data is a no-code data pipeline platform that helps companies consolidate data from multiple sources for faster analytics. Our fully managed pipelines let data teams move data from 150+ sources (databases, SaaS applications, cloud storage, SDKs, streaming services) into warehouses and lakes, all without writing code.
Over 2,000 data teams in 45+ countries use Hevo, including DoorDash, Foot Locker, Arhaus, and Santander. We’re top-rated in the G2 Data Pipeline category, backed by Sequoia Capital, Qualgro, and Chiratae Ventures, and operate out of San Francisco and Bangalore.
Role Summary
An Associate Customer Experience Engineer owns customer issues end-to-end, keeps unnecessary escalations to a minimum, and ensures every interaction reflects a high standard of customer experience.
This role centers on troubleshooting JDBC-based sources and integrations, partnering closely with Product and Engineering whenever an issue calls for deeper investigation. The role calls for building solid technical depth over time, following and refining support workflows, putting AI and automation to good use, and adding to the team''s shared knowledge so issues get resolved faster and more consistently across the board.',
   '-
Own customer issues and drive them to resolution within SLA timelines, combining structured investigation with clear, timely updates to the customer.
-
Investigate issues by digging into SQL, logs, API responses, database behavior, product documentation, and other diagnostic tools available.
-
Loop in Product and Engineering as needed, sharing the relevant technical context, investigation findings, and steps to reproduce the issue.
-
Keep unnecessary escalations to a minimum by building strong product and technical knowledge and resolving issues independently wherever possible.
-
Follow established support processes and flag improvements that cut down on rework, manual effort, and resolution time.
-
Use AI-assisted tools, automation, and diagnostic capabilities to make troubleshooting faster and more consistent.
-
Build deeper technical expertise in JDBC-based sources and integrations, along with databases, APIs, ETL, and related technologies.
-
Add to SOPs, KB articles, onboarding material, and other knowledge assets the wider team relies on.
-
Support teammates when needed and take an active part in team training, enablement, and knowledge-sharing activities.
What Success Looks Like
-
Steady SLA adherence combined with consistently high-quality resolutions on owned tickets.
-
A growing ability to resolve technically complex issues without outside help.
-
An avoidable escalation rate that stays low and keeps trending downward.
-
Customer communication that is clear, accurate, and easy to act on.
-
Meaningful, ongoing contributions to SOPs, KBs, and broader team enablement.
-
Real, measurable use of AI and automation to cut down on manual effort and resolution time.
-
Visible growth in technical depth and troubleshooting capability over time.',
   '-
Solid grasp of cloud technologies and core database concepts, including the basics of database administration.
-
Hands-on experience troubleshooting databases, applications, or integrations.
-
Strong command of SQL.
-
Familiarity with data warehousing, ETL, REST APIs, and webhooks.
-
Working knowledge of Java or another object-oriented programming language.
-
Sharp troubleshooting, debugging, research, and problem-solving abilities.
-
Background in technical product support, including email-based support.
-
Able to write and maintain clear technical documentation such as KBs and SOPs.
-
Strong written and verbal communication with a sharp eye for detail.
-
Genuinely curious and customer-first, with the ability to break down and synthesize technical information effectively.
-
1–3 years in technical product support, application support, database support, or a similar technical role.
-
Hands-on experience troubleshooting JDBC-based sources or integrations.
-
DBA experience with PostgreSQL, MySQL, SQL Server, Oracle, or a similar database platform.
-
Background supporting B2B SaaS products or integration platforms.
-
Exposure to ETL/data integration platforms.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-25T08:16:49Z'::timestamptz,
   'https://jobs.lever.co/hevodata/96993ebc-609a-4733-84cd-e1a0c3e69fda'),
  -- 25. [Sales Executive] Bosch - Senior Engineer / Assistant Manager - Sales and Project Management (Power Solutions) (Pune)
  ('bosch',
   'Senior Engineer / Assistant Manager - Sales and Project Management (Power Solutions)',
   'Sales Executive',
   'Pune, Maharashtra',
   'Maharashtra',
   'Onsite',
   'Full time',
   '2-4 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Negotiation', 'Project Management', 'Communication', 'Leadership', 'Presentation']::text[],
   'In India, Bosch is a leading supplier of technology and services in the areas of Mobility, Industrial Technology, Consumer Goods, and Energy and Building Technology. Additionally, Bosch has in India the largest development center outside Germany, for end-to-end engineering and technology solutions. The Bosch Group operates in India through 14 companies: Bosch Limited – the flagship company of the Bosch Group in India – Bosch Chassis Systems India Private Limited, Bosch Rexroth (India) Private Li
The purpose of this position is to achieve project goals by timely execution of project activities according to standard project management process there by act as enabler to secure new projects leading to business enhancement with customer.
1.Preparation & presentation of the acquisition case as per standard project management process to the concerned approving authority, prepare & submit customer quotation based on approved bottom lines, negotiate and sign off contract inline to bottom lines/ conditions approved by management.
2. Review and manage stake holders (Ex :A-Panel, B Panel) during acquisition phase and escalate project / customer specific topics to leadership team to seek appropriate interventions.
3. Follow up/ tracking of prices due to various factors (Forex, RMI, Volumes, ECI, ECN, Energy etc)
4.',
   'See the official job posting for the full list of responsibilities.',
   'Bachelors degree in engineering (Mechanical, Automobile, Industrial Production, Electrical, Electronics or equivalent).
- Project Management Professional (PMP Certified; Optional).
- 2 to 4 years of experience in similar industry and function.
- Experience of working for automotive projects (desirable).
- Competent in SAP, MS office tools, PPAP and APQP process.
- Advanced Knowledge of Diesel/ alternative powertrain technologies, Engine Management System.
- Product development life cycle, Overview of Bosch product portfolio and new developments.
- Basic analytical/critical skills, commercial acumen and entrepreneurial mindset
- Basic skills in negotiation, communication, presentation, should exhibit Agility, Competent Project planning, risk management skills & self driven to perform under challenging budgets with quality and time focus.
- Customer relationship management',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-16T03:08:02Z'::timestamptz,
   'https://jobs.smartrecruiters.com/BoschGroup/744000149767699-senior-engineer-assistant-manager-sales-and-project-management-power-solutions-'),
  -- 26. [Software Engineer] Druva - Senior Staff Software Engineer, Distributed Systems (Pune)
  ('druva',
   'Senior Staff Software Engineer, Distributed Systems',
   'Software Engineer',
   'Pune, Maharashtra',
   'Maharashtra',
   'Onsite',
   'Full time',
   '5-7 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Python', 'Java', 'C++', 'AWS', 'Kubernetes', 'Linux', 'Product Management', 'Communication']::text[],
   'About Druva
Druva is the resilience foundation for the AI enterprise, helping organizations secure and recover from connected risk across data, cyber, identity, and AI. The Resilience Cloud is a fully managed, cloud-native SaaS platform that delivers air-gapped and immutable protection across cloud, SaaS, on-premises, endpoint, and edge environments. Powered by Dru MetaGraph, Druva’s graph-powered intelligence layer, the platform connects critical business context so customers can understand risk, respond faster, recover cleanly, and govern data with greater confidence.
Trusted by nearly 7,500 customers, including 75 of the Fortune 500, Druva helps safeguard the critical information and systems businesses depend on in an increasingly connected world.
Visit druva.com and follow us on LinkedIn, X and Facebook.
The Data team within Foundation processes data at scale. It builds and operates tools that scan petabytes of data to extract insights. The team builds indices and views for semi-structured data to facilitate analytics, using both in-house and off-the-shelf tools.
. The team diligently keeps track of newer services, storage tiers, and various aspects of existing AWS services to take advantage of the continuous evolution of services and use them effectively in the background.
As a Sr. Software Engineer, you will be providing technical leadership to create high-quality software by owning low level , design and implementation of services within a product.',
   '- The Sr. Software Engineer''s role is to be the technical leader in building enterprise-grade scalable, performant systems which deliver the required functionality to the customers and delight them
- Should be able to design and implement sufficiently large and complex features and/or architectural improvements to the product.
- Suggest and propose solutions to complex design problems.
- Identify areas of engineering improvements to the product and work with product architects and the team to address them.
- Should be able to technically guide junior engineers with feature design and implementation.
- Review design and implementation done by junior engineers.
- Should be able to independently handle complex escalations and guide others as required.
- Be able to write technical blogs and make technical presentations in internal and external forums',
   '- Excellent written and verbal communication skills
- Working knowledge of Dockers and Kubernetes will be an advantage
- Tech / B.E / M.E./ M.Tech (Computer Science) or equivalent',
   'Benefits are listed on the employer''s official job posting.',
   '2026-03-13T07:43:47Z'::timestamptz,
   'https://www.druva.com/why-druva/explore/careers/jobs/8207141002/?gh_jid=8207141002'),
  -- 27. [Sales Executive] Bosch - RBIN_2WP/CIN1_Deputy Manager_Senior Sales & Acquisition Manager (Pune)
  ('bosch',
   'RBIN_2WP/CIN1_Deputy Manager_Senior Sales & Acquisition Manager',
   'Sales Executive',
   'Pune, Maharashtra',
   'Maharashtra',
   'Onsite',
   'Full time',
   '4-8 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Negotiation', 'Project Management', 'Stakeholder Management', 'Communication', 'Presentation', 'Collaboration']::text[],
   'In India, Bosch is a leading supplier of technology and services in the areas of Mobility Solutions, Industrial Technology, Consumer Goods, and Energy and Building Technology. Additionally, Bosch has in India the largest development center outside Germany, for end-to-end engineering and technology solutions.
Acquisition & Sales Management Lead account acquisitions from qualification to contract finalization ensuring profitability. Negotiate special revenue agreements that align with EBIT targets & secure bottom-line agreements to support business growth.
Pre-selling & Innovation Align Bosch’s technology roadmap with customer vehicle roadmaps to provide strategic inputs for innovation & new product development strategy.
Business Management Lead & execute timely internal & external alignments on various business/contractual topics, NDAs, purchase & warranty agreements focusing on planning & profitability of series projects along with functional coordination of customer team related planning center activities, while maintaining transparency towards achieving various KPIs for global accounts.
Commercial Management Execute & own the overall price management contracted with customer accounts, ensuring timely Forex & RMI reconciliations with regular checks & measures on ECI & RMI impacts, monitoring credit limits resulting in achieving target receivables.',
   'See the official job posting for the full list of responsibilities.',
   '- Bachelors degree in Engineering (Mechanical, Automobile, Electrical, Electronics or equivalent).
- MBA/PGDM in Business / Marketing / Finance / Operations preferred.
- 4-8 years of experience in automotive industry & sales/ controlling function
- 2-4 years of experience in working for automotive projects (desirable)
- 2-4 years of experience in technical pre-selling, innovation, commercial & customer strategy management.
- Effective communication, negotiation & presentation skills.
- Advance analytical skills with the efficient timeline management & problem-solving skills.
- Effective collaboration with cross-functional teams (internal & external stakeholders).
- Advance understanding of sales tools & pricing management.
- Educate & guide sales & acquisition managers.',
   'Knowledge:
- Advance knowledge & understanding of Powertrain, Assistance (Braking systems), Electrification & Connectivity domain product & technologies of the automotive industry and upcoming market trends.
- Competent in technical sales with knowledge of automotive industries & products.
- Advance skill & user of Microsoft Office tools with novice understanding of ERP tools / systems.
- Advance knowledge of sales process, product development, commercial & supply chain management (Desirable)',
   '2026-07-13T03:53:15Z'::timestamptz,
   'https://jobs.smartrecruiters.com/BoschGroup/744000137361819-rbin-2wp-cin1-deputy-manager-senior-sales-acquisition-manager'),
  -- 28. [Software Engineer] Databricks - Solutions Architect (Pune)
  ('databricks',
   'Solutions Architect',
   'Software Engineer',
   'Pune, Maharashtra',
   'Maharashtra',
   'Onsite',
   'Full time',
   '12+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Python', 'Java', 'SQL', 'AWS', 'Azure', 'GCP', 'Excel', 'Machine Learning']::text[],
   'FEQ327R324
As a Solutions Architect part of a Global Capability Center(GCC) focused Field Engineering team, you will shape the future of the Data and AI landscape by working with the most sophisticated Data and AI teams in the world, including Fortune 500 enterprises and global AI-forward SaaS customers operating globally. In this role, you will be deeply embedded with our named strategic accounts, serving as a trusted long-term technical advisor while also collaborating with internal sales, product, and engineering teams.
You will help our customers achieve tangible data-driven outcomes through the Databricks Data Intelligence Platform, helping data teams complete projects and integrate our platform into their enterprise ecosystem. You''ll grow as a leader in your field, while finding solutions to our customers'' biggest challenges in data engineering, analytics, AI and data science.
Reporting to the Field Engineering Manager, you will collaborate with our most strategic global prospects and customers, partner with regional field teams across geographies, work directly with product and engineering to drive the Databricks roadmap forward, and work with the broader customer-facing team to develop architectures and solutions using our platform. You will guide customers through the competitive landscape, best practices, and implementation, and develop technical champions along the way.
The impact you will have',
   'See the official job posting for the full list of responsibilities.',
   'See the official job posting for detailed requirements.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-07-23T04:34:18Z'::timestamptz,
   'https://databricks.com/company/careers/open-positions/job?gh_jid=8641892002'),
  -- 29. [Sales Executive] Hevo Data - Solution Engineer (Post-sales) (Pune)
  ('hevo-data',
   'Solution Engineer (Post-sales)',
   'Sales Executive',
   'Pune, Maharashtra',
   'Maharashtra',
   'Onsite',
   'Full time',
   '9+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Communication', 'Leadership']::text[],
   'Hevo Data
Solution Engineer (Post-sales)
About Hevo
DoorDash, Footlocker, Arhaus, Santander, and thousands of other data-driven companies have one thing in common. They all use Hevo Data’s fully managed Automated Pipelines to consolidate their data from multiple sources like Databases, Marketing Applications, Cloud Storage, SDKs, Streaming Services, etc.
We are a San Francisco, Bangalore, and Pune-based company with 2000+ customers spread across 45+ countries in e-commerce, financial technology, and healthcare. Strongly backed by marquee investors like Sequoia Capital, we have raised $42 Million to date and are looking forward to our next phase of hyper-growth!
Why do we exist?
At Hevo, our mission is to enable every company to be data-driven. We started on this journey 9 years back, and as the first step in this direction, we built our first product – “Data Pipeline” or simply “Pipeline”.
Hevo Pipeline is a no-code platform that helps companies connect all their sources of data within the company to get a unified view of their business. The platform offers integrations with 150+ data sources such as Databases, SaaS applications, Advertising Channels, etc.
Today, we enable close to 2000 companies across more than 40+ countries to be more data-driven. Our aim is to make the technology so simple that anyone should be able to solve their data problems and not be limited due to their lack of technical skills.',
   'We are growing into mid-market and enterprise accounts where the technical bar - and the stakes - are higher. To win and retain these customers, we are building the technical depth in our post-sale motion to match.
Enterprise buyers are not just buying a product. They are making architectural decisions. The CTOs, data architects, and engineering leads we work with at this level need a technical counterpart.
As a Solution Engineer, you are that person. You are not the first point of contact, and you are not handling tickets.
You are the expert our Account Managers bring in when a customer conversation goes beyond relationship management - a quarterly architecture review, a complex integration challenge, a strategic expansion decision, or simply when a CTO wants to talk to someone who really knows data.
-
Be the senior technical specialist that Account Managers call on for complex customer conversations - architecture reviews, expansion discussions, and senior-level technical engagements.
-
Engage credibly with CTOs, senior engineers, and data architects as a genuine thought partner: understand their architecture, challenge assumptions, co-design pipelines, and offer a credible point of view.
-
Lead technical discovery and solution design for enterprise customers evaluating new use cases, migrations, or architectural changes involving Hevo.
-
Translate complex customer requirements into actionable guidance - both for the customer and, where needed, and for Hevo''s internal engineering team.
-
Build and maintain deep expertise in the modern data stack: cloud data warehouses, orchestration, transformation, and the broader ecosystem Hevo operates within.
-
Identify expansion opportunities through technical engagement and hand them off to the AM with enough context to move the conversation forward commercially.
-',
   'See the official job posting for detailed requirements.',
   '-
-
Direct access to leadership and real influence on how the post-sale function is built.
-
A collaborative, high-trust environment where technical depth is valued and rewarded.',
   '2026-06-28T07:12:42Z'::timestamptz,
   'https://jobs.lever.co/hevodata/86fd190d-754d-45b6-9f04-59585dc6d15b'),
  -- 30. [Software Engineer] Bosch - IN_RBIC_Senior Engineer_Application Engineer(Active Safety & New Braking Systems) (Pune)
  ('bosch',
   'IN_RBIC_Senior Engineer_Application Engineer(Active Safety & New Braking Systems)',
   'Software Engineer',
   'Pune, Maharashtra',
   'Maharashtra',
   'Onsite',
   'Full time',
   '3+ years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['C++', 'Communication']::text[],
   'Bosch Chassis Systems India Ltd is a 100% Bosch owned company in India. The company design and develops world class Hydraulic Brake System Parts that include Boosters, Tandem master cylinders and Proportionating valves. The Control Division develops innovative components, systems and functions in the field of vehicle safety, vehicle dynamics and driver assistance like ABS and ESP.RBIC would soon be expanding portfolio in passive safety and other Driver assistance products.
Company: Bosch Chassis Systems India Pvt. Ltd.
Department: VM/EAS-IN, Engineering for Active Safety
Job Summary:
Join a world leader in automotive technology. As an application engineer in our Active Safety team, you will play
a pivotal role in the development & calibration of cutting-edge safety systems like ABS, ESP & new-generation
braking systems like Integrated Power Brake® & iBooster® on new prototype vehicle platforms. You will work
on a diverse range of automobiles, including combustion engines vehicles, hybrids & EVs in both passenger &
commercial vehicle segments, ensuring they meet the highest standards of safety & performance. This is a
hands-on role for an engineer who is passionate about vehicle performance calibration, vehicle dynamics &
shaping the future of mobility.',
   '* System Calibration & Performance: Understanding system requirements, calibrate, test, & evaluate
algorithms in control systems installed on prototype vehicles to meet Bosch, customer, & legal standards.
* Vehicle Validation: Conduct comprehensive vehicle performance tests in various environments (summer &
winter proving grounds) & analyze results to optimize & validate system behavior.
* Customer Engagement: Act as a key technical contact for customers, understanding their requirements,
providing expert support, & ensuring successful project delivery.
* Technical Problem-Solving: Diagnose & troubleshoot complex in-vehicle issues related to hardware,
software, & data acquisition systems during the entire development cycle.
* Cross-Functional Support: Collaborate with internal & external teams to support project acquisition & other
technical activities, ensuring adherence to all development & quality processes.',
   '* Basic understanding of ABS/ESP systems- working principle, hardware, software & use cases.
* Direct vehicle testing & validation experience on proving grounds & test tracks- Brake tests, dynamic lane
changes & handling maneuvers on different test surfaces. Track driving license good to have (not
mandatory).
* Strong ability to gauge vehicle behavior & evaluate impact of change in vehicle system components- in-depth
knowhow of vehicle systems, vehicle dynamics, tire behavior & basic powertrain concepts.
* Extensive experience in homologation testing as per UNECE & AIS regulations relevant to braking systems
& active safety systems for passenger & commercial vehicles.
* Basic experience with software tools like- MATLAB, Simulink, Carmaker, Doors, ALM, etc.
* Hands-on with DAQS (Data acquisition systems & tools)- Vbox, Vector tools (XCP, CANalyzer, CANoe),
external data loggers, sensors & SW programming tools.
* Engineering graduate/postgraduate with 3+ years of experience in the automotive engineering domain
* Basic understanding of programming languages- C & C++.
* Experience in hydraulic brake system development.
* Passenger car driving license with 3+ years of driving experience.
* Strong social skills– active listening, relationship management, effective oral & written communication (in
English), positive engagement with cross-functional teams & clients.
* Good analytical & logical reasoning with a problem-solving mindset.
* Willingness to travel to different customer test locations & proving grounds across the globe.',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-08T13:26:53Z'::timestamptz,
   'https://jobs.smartrecruiters.com/BoschGroup/744000148238040-in-rbic-senior-engineer-application-engineer-active-safety-new-braking-systems-'),
  -- 31. [Sales Executive] Swiggy - Sales Manager (Nagpur)
  ('swiggy',
   'Sales Manager',
   'Sales Executive',
   'Nagpur, Maharashtra',
   'Maharashtra',
   'Onsite',
   'Full time',
   '0-2 years',
   null::numeric,
   null::numeric,
   'Not disclosed',
   array['Excel', 'Market Research', 'Negotiation', 'Business Development', 'Problem Solving']::text[],
   'Swiggy is India’s leading on-demand delivery platform with a tech-first approach to logistics and a solution-first approach to consumer demands. With a presence in 500+ cities across India, partnerships with hundreds of thousands of restaurants, an employee base of over 5000, a 2 lakh+ strong independent fleet of Delivery Executives, we deliver unparalleled convenience driven by continuous innovation.
A Sales Manager owns the acquisition and engagement of single-outlet independent restaurants across an assigned city. You are the primary touchpoint for these restaurants learning their business understanding their challenges, and building a partnership where you help the restaurant partner directly drive their growth in orders, visibility, and customer engagement. This role is Consultative & On-Field and requires you to be resourceful, adaptable, and genuinely invested in your partners'' success. You''ll develop consultative sales skills, learn restaurant operations intimately, and build the foundation for scaling your career.',
   '● Own a defined geographic territory: build strong and successful relationships with the assigned restaurant partners
● Field-intensive engagement: Conduct in-person visits, walking restaurants through product demos, ROI analysis, and present how working with Swiggy is a mutually beneficial relationship
● Consultative selling: Diagnose restaurant needs through questions about their current channels, delivery logistics, marketing spend, and business goals. Position Swiggy’s products as solutions, not features
● Relationship management: Manage the full lifecycle each month, pitching, negotiation, activation, and ongoing support to the restaurant partner
● Data-driven problem solving: Track adoption metrics, identify why restaurants aren''t growing, troubleshoot issues, and course-correct
● Revenue responsibility: Own targets within your territory; track your own pipeline and conversion rates
● Excel mastery: all the data related to your day-to-day work will be on the city and central trackers, so you must have advanced knowledge of Excel/Google sheet/WSP
● Market research: Stay updated on restaurant trends, competitive landscape, and local market dynamics. Feedback from the field informs product direction 80 to 90 In-person meetings with restaurant partners a month',
   'Graduate',
   'Benefits are listed on the employer''s official job posting.',
   '2026-09-15T10:22:40Z'::timestamptz,
   'https://jobs.smartrecruiters.com/SWIGGY/6000000001408137-sales-manager')
) as v(slug, title, category, location, state, work_mode, employment_type, experience, salary_min, salary_max, salary, skills, description, responsibilities, requirements, benefits, posted_at, source_url)
join public.companies c on c.slug = v.slug
where not exists (select 1 from public.jobs j where j.source_url = v.source_url);

commit;

-- Verify: select location, count(*) from public.jobs where state = 'Maharashtra' and apply_type = 'external' group by location order by location;

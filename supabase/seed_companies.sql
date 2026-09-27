-- HireIn AI: 50 Verified Real Companies Seed Script
-- Distribution: Karnataka (12), Tamil Nadu (10), Telangana (10), Maharashtra (10), Haryana (8)
-- All companies have active engineering and hiring presence in India.

-- Ensure required columns exist on public.companies
alter table public.companies add column if not exists industry text;
alter table public.companies add column if not exists city text;
alter table public.companies add column if not exists state text;

insert into public.companies (
  name,
  slug,
  industry,
  website,
  logo_url,
  city,
  state,
  location,
  description,
  is_approved
)
values
  -- ========================================================
  -- 1. KARNATAKA (12 Companies)
  -- ========================================================
  (
    'Infosys',
    'infosys',
    'Information Technology',
    'https://www.infosys.com',
    'https://upload.wikimedia.org/wikipedia/commons/9/95/Infosys_logo.svg',
    'Bengaluru',
    'Karnataka',
    'Bengaluru, Karnataka',
    'Global leader in next-generation digital services, enterprise consulting, and cloud transformation.',
    true
  ),
  (
    'Wipro',
    'wipro',
    'IT Services & Consulting',
    'https://www.wipro.com',
    'https://upload.wikimedia.org/wikipedia/commons/a/a0/Wipro_Primary_Logo_Color_RGB.svg',
    'Bengaluru',
    'Karnataka',
    'Bengaluru, Karnataka',
    'Leading global technology services and consulting company focused on building innovative solutions.',
    true
  ),
  (
    'Flipkart',
    'flipkart',
    'E-commerce & Technology',
    'https://www.flipkart.com',
    'https://upload.wikimedia.org/wikipedia/en/thumb/7/7a/Flipkart_logo.svg/320px-Flipkart_logo.svg.png',
    'Bengaluru',
    'Karnataka',
    'Bengaluru, Karnataka',
    'India''s premier e-commerce marketplace empowering millions of consumers, sellers, and logistics partners.',
    true
  ),
  (
    'Swiggy',
    'swiggy',
    'Consumer Tech & Quick Commerce',
    'https://www.swiggy.com',
    'https://upload.wikimedia.org/wikipedia/en/thumb/1/12/Swiggy_logo.svg/320px-Swiggy_logo.svg.png',
    'Bengaluru',
    'Karnataka',
    'Bengaluru, Karnataka',
    'Leading on-demand convenience platform offering food delivery, Instamart grocery, and logistics.',
    true
  ),
  (
    'Zerodha',
    'zerodha',
    'Financial Technology & Brokerage',
    'https://zerodha.com',
    'https://zerodha.com/static/images/logo.svg',
    'Bengaluru',
    'Karnataka',
    'Bengaluru, Karnataka',
    'India''s largest retail stock broker and financial technology pioneer empowering millions of investors.',
    true
  ),
  (
    'Razorpay',
    'razorpay',
    'Fintech & Payments',
    'https://razorpay.com',
    'https://upload.wikimedia.org/wikipedia/commons/8/89/Razorpay_logo.svg',
    'Bengaluru',
    'Karnataka',
    'Bengaluru, Karnataka',
    'Full-stack financial services platform powering modern digital payments, banking, and credit for businesses.',
    true
  ),
  (
    'PhonePe',
    'phonepe',
    'Fintech & Digital Payments',
    'https://www.phonepe.com',
    'https://upload.wikimedia.org/wikipedia/commons/7/71/PhonePe_Logo.svg',
    'Bengaluru',
    'Karnataka',
    'Bengaluru, Karnataka',
    'Leading digital payments and financial services company driving financial inclusion across India.',
    true
  ),
  (
    'CRED',
    'cred',
    'Fintech & Consumer Tech',
    'https://cred.club',
    'https://upload.wikimedia.org/wikipedia/en/thumb/7/7c/CRED_New_Logo.svg/320px-CRED_New_Logo.svg.png',
    'Bengaluru',
    'Karnataka',
    'Bengaluru, Karnataka',
    'High-trust community of creditworthy individuals offering premium financial products and rewards.',
    true
  ),
  (
    'Ola',
    'ola',
    'Mobility & EV Technology',
    'https://www.olacabs.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Ola_Cabs_logo.svg/320px-Ola_Cabs_logo.svg.png',
    'Bengaluru',
    'Karnataka',
    'Bengaluru, Karnataka',
    'Mobility platform and electric vehicle manufacturer shaping the future of sustainable urban transport.',
    true
  ),
  (
    'Postman',
    'postman',
    'Developer Tools & SaaS',
    'https://www.postman.com',
    'https://assets.getpostman.com/common-share/postman-logo-stacked.svg',
    'Bengaluru',
    'Karnataka',
    'Bengaluru, Karnataka',
    'Leading collaborative API development platform used by over 30 million developers worldwide.',
    true
  ),
  (
    'Myntra',
    'myntra',
    'Fashion & E-commerce',
    'https://www.myntra.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/Myntra_logo.png/320px-Myntra_logo.png',
    'Bengaluru',
    'Karnataka',
    'Bengaluru, Karnataka',
    'India''s premier e-commerce destination for fashion, beauty, and lifestyle shopping.',
    true
  ),
  (
    'BigBasket',
    'bigbasket',
    'E-commerce & Retail Tech',
    'https://www.bigbasket.com',
    'https://upload.wikimedia.org/wikipedia/en/thumb/0/07/Bigbasket_Logo.svg/320px-Bigbasket_Logo.svg.png',
    'Bengaluru',
    'Karnataka',
    'Bengaluru, Karnataka',
    'India''s largest online grocery supermarket and delivery network operated by Tata Digital.',
    true
  ),

  -- ========================================================
  -- 2. TAMIL NADU (10 Companies)
  -- ========================================================
  (
    'Zoho Corporation',
    'zoho',
    'Enterprise SaaS & Cloud Software',
    'https://www.zoho.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Zoho_Corporation_2019_logo.svg/320px-Zoho_Corporation_2019_logo.svg.png',
    'Chennai',
    'Tamil Nadu',
    'Chennai, Tamil Nadu',
    'Global software technology company providing an extensive suite of business applications on cloud.',
    true
  ),
  (
    'Freshworks',
    'freshworks',
    'Enterprise SaaS & CRM',
    'https://www.freshworks.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/2/23/Freshworks_Inc_logo.svg/320px-Freshworks_Inc_logo.svg.png',
    'Chennai',
    'Tamil Nadu',
    'Chennai, Tamil Nadu',
    'Innovative software solutions that empower IT, customer service, and sales teams to work faster.',
    true
  ),
  (
    'HCLTech',
    'hcltech',
    'Information Technology',
    'https://www.hcltech.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/HCL_Technologies_logo.svg/320px-HCL_Technologies_logo.svg.png',
    'Chennai',
    'Tamil Nadu',
    'Chennai, Tamil Nadu',
    'Global technology company supercharging progress with cutting-edge engineering, cloud, and AI capabilities.',
    true
  ),
  (
    'Cognizant India',
    'cognizant',
    'IT Consulting & Digital Services',
    'https://www.cognizant.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/Cognizant_logo_2022.svg/320px-Cognizant_logo_2022.svg.png',
    'Chennai',
    'Tamil Nadu',
    'Chennai, Tamil Nadu',
    'Multinational technology powerhouse engineering modern businesses to improve everyday lives.',
    true
  ),
  (
    'TVS Motor Company',
    'tvs-motor',
    'Automotive & Clean Mobility',
    'https://www.tvsmotor.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/TVS_Motor_Company_logo.svg/320px-TVS_Motor_Company_logo.svg.png',
    'Chennai',
    'Tamil Nadu',
    'Chennai, Tamil Nadu',
    'Reputed two and three-wheeler manufacturer globally recognized for engineering excellence and EV mobility.',
    true
  ),
  (
    'Ashok Leyland',
    'ashok-leyland',
    'Automotive & Heavy Engineering',
    'https://www.ashokleyland.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/Ashok_Leyland_logo.svg/320px-Ashok_Leyland_logo.svg.png',
    'Chennai',
    'Tamil Nadu',
    'Chennai, Tamil Nadu',
    'Flagship of the Hinduja Group and India''s second largest commercial vehicle manufacturer.',
    true
  ),
  (
    'Kissflow',
    'kissflow',
    'Low-Code Software & Workflow Automation',
    'https://kissflow.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Kissflow_Logo.svg/320px-Kissflow_Logo.svg.png',
    'Chennai',
    'Tamil Nadu',
    'Chennai, Tamil Nadu',
    'Pioneering low-code work platform simplifying business operations and digital transformation.',
    true
  ),
  (
    'Ramco Systems',
    'ramco-systems',
    'Enterprise Software & Cloud ERP',
    'https://www.ramco.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Ramco_Systems_logo.svg/320px-Ramco_Systems_logo.svg.png',
    'Chennai',
    'Tamil Nadu',
    'Chennai, Tamil Nadu',
    'Enterprise cloud software provider transforming Global Payroll, Aviation M&E, and Logistics management.',
    true
  ),
  (
    'Chargebee',
    'chargebee',
    'Fintech & Subscription Management',
    'https://www.chargebee.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fe/Chargebee_Logo.svg/320px-Chargebee_Logo.svg.png',
    'Chennai',
    'Tamil Nadu',
    'Chennai, Tamil Nadu',
    'Leading revenue management and subscription billing platform powering thousands of fast-growing businesses.',
    true
  ),
  (
    'Sify Technologies',
    'sify',
    'Cloud Infrastructure & Telecom',
    'https://www.sify.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Sify_Technologies_Logo.svg/320px-Sify_Technologies_Logo.svg.png',
    'Chennai',
    'Tamil Nadu',
    'Chennai, Tamil Nadu',
    'Comprehensive ICT solutions company operating hyper-scale data centers, cloud networks, and digital infrastructure.',
    true
  ),

  -- ========================================================
  -- 3. TELANGANA (10 Companies)
  -- ========================================================
  (
    'Dr. Reddy''s Laboratories',
    'dr-reddys',
    'Pharmaceuticals & Biotechnology',
    'https://www.drreddys.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Dr._Reddy%27s_Laboratories_logo.svg/320px-Dr._Reddy%27s_Laboratories_logo.svg.png',
    'Hyderabad',
    'Telangana',
    'Hyderabad, Telangana',
    'Integrated global pharmaceutical company committed to providing affordable and innovative medicines.',
    true
  ),
  (
    'Cyient',
    'cyient',
    'Engineering & Technology Services',
    'https://www.cyient.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/Cyient_Logo.svg/320px-Cyient_Logo.svg.png',
    'Hyderabad',
    'Telangana',
    'Hyderabad, Telangana',
    'Global intelligent engineering and digital manufacturing partner to aerospace and industrial leaders.',
    true
  ),
  (
    'LTIMindtree',
    'ltimindtree',
    'Information Technology',
    'https://www.ltimindtree.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/LTIMindtree_Logo.svg/320px-LTIMindtree_Logo.svg.png',
    'Hyderabad',
    'Telangana',
    'Hyderabad, Telangana',
    'Global technology consulting and digital solutions company helping enterprises accelerate digital roadmaps.',
    true
  ),
  (
    'Darwinbox',
    'darwinbox',
    'HR Tech & Enterprise SaaS',
    'https://darwinbox.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Darwinbox_Logo.svg/320px-Darwinbox_Logo.svg.png',
    'Hyderabad',
    'Telangana',
    'Hyderabad, Telangana',
    'Leading enterprise HR technology platform providing end-to-end employee lifecycle management with AI.',
    true
  ),
  (
    'HighRadius',
    'highradius',
    'Fintech & SaaS',
    'https://www.highradius.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/HighRadius_Logo.svg/320px-HighRadius_Logo.svg.png',
    'Hyderabad',
    'Telangana',
    'Hyderabad, Telangana',
    'Autonomous finance software platform automating Order-to-Cash, Treasury, and Record-to-Report processes.',
    true
  ),
  (
    'Tanla Platforms',
    'tanla',
    'Cloud Communications & CPaaS',
    'https://www.tanla.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Tanla_Platforms_Logo.svg/320px-Tanla_Platforms_Logo.svg.png',
    'Hyderabad',
    'Telangana',
    'Hyderabad, Telangana',
    'India''s premier CPaaS provider securing and enabling trusted digital interactions for major brands.',
    true
  ),
  (
    'Zen Technologies',
    'zen-technologies',
    'Defense Tech & Simulators',
    'https://www.zentechnologies.com',
    'https://www.zentechnologies.com/assets/images/logo.png',
    'Hyderabad',
    'Telangana',
    'Hyderabad, Telangana',
    'Pioneers in high-end defense simulation systems, tactical training solutions, and counter-drone robotics.',
    true
  ),
  (
    'CtrlS Datacenters',
    'ctrls',
    'Cloud & Data Center Infrastructure',
    'https://www.ctrls.in',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/CtrlS_Logo.svg/320px-CtrlS_Logo.svg.png',
    'Hyderabad',
    'Telangana',
    'Hyderabad, Telangana',
    'Asia''s largest Rated-4 hyperscale data center provider powering high-availability cloud environments.',
    true
  ),
  (
    'Biological E.',
    'biological-e',
    'Biotechnology & Healthcare',
    'https://www.biologicale.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/2/23/Biological_E._Limited_Logo.svg/320px-Biological_E._Limited_Logo.svg.png',
    'Hyderabad',
    'Telangana',
    'Hyderabad, Telangana',
    'Prominent biotechnology company and global vaccine manufacturer committed to universal healthcare access.',
    true
  ),
  (
    'Aurobindo Pharma',
    'aurobindo-pharma',
    'Pharmaceuticals & Life Sciences',
    'https://www.aurobindo.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Aurobindo_Pharma_logo.svg/320px-Aurobindo_Pharma_logo.svg.png',
    'Hyderabad',
    'Telangana',
    'Hyderabad, Telangana',
    'Global pharmaceutical manufacturing giant with diversified generic formulations and API capabilities.',
    true
  ),

  -- ========================================================
  -- 4. MAHARASHTRA (10 Companies)
  -- ========================================================
  (
    'Tata Consultancy Services',
    'tcs',
    'Information Technology',
    'https://www.tcs.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/Tata_Consultancy_Services_Logo.svg/320px-Tata_Consultancy_Services_Logo.svg.png',
    'Mumbai',
    'Maharashtra',
    'Mumbai, Maharashtra',
    'Flagship global IT consulting and business transformation giant of the Tata Group.',
    true
  ),
  (
    'Reliance Jio',
    'reliance-jio',
    'Telecommunications & Digital Services',
    'https://www.jio.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/5/50/Reliance_Jio_Logo_%28October_2015%29.svg/320px-Reliance_Jio_Logo_%28October_2015%29.svg.png',
    'Mumbai',
    'Maharashtra',
    'Mumbai, Maharashtra',
    'India''s premier digital services company operating world-class 5G connectivity and cloud platforms.',
    true
  ),
  (
    'Larsen & Toubro',
    'larsen-toubro',
    'Engineering & Heavy Infrastructure',
    'https://www.larsentoubro.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/L%26T.png/320px-L%26T.png',
    'Mumbai',
    'Maharashtra',
    'Mumbai, Maharashtra',
    'Multinational conglomerate engaged in technology, engineering, construction, and hi-tech manufacturing.',
    true
  ),
  (
    'Tech Mahindra',
    'tech-mahindra',
    'IT Services & Consulting',
    'https://www.techmahindra.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Tech_Mahindra_New_Logo.svg/320px-Tech_Mahindra_New_Logo.svg.png',
    'Pune',
    'Maharashtra',
    'Pune, Maharashtra',
    'Leading provider of digital transformation, consulting, and business re-engineering services.',
    true
  ),
  (
    'Persistent Systems',
    'persistent-systems',
    'Software Product Engineering',
    'https://www.persistent.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/0/06/Persistent_Systems_Logo.svg/320px-Persistent_Systems_Logo.svg.png',
    'Pune',
    'Maharashtra',
    'Pune, Maharashtra',
    'Trusted digital engineering partner building next-generation software products and cloud platforms.',
    true
  ),
  (
    'Kotak Mahindra Bank',
    'kotak-mahindra-bank',
    'Banking & Financial Services',
    'https://www.kotak.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cc/Kotak_Mahindra_Bank_logo.svg/320px-Kotak_Mahindra_Bank_logo.svg.png',
    'Mumbai',
    'Maharashtra',
    'Mumbai, Maharashtra',
    'One of India''s premier private banking, asset management, and investment banking institutions.',
    true
  ),
  (
    'Tata Motors',
    'tata-motors',
    'Automotive & Electric Mobility',
    'https://www.tatamotors.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Tata_Motors_Logo.svg/320px-Tata_Motors_Logo.svg.png',
    'Mumbai',
    'Maharashtra',
    'Mumbai, Maharashtra',
    'Automotive manufacturing leader pioneering electric mobility and commercial transport across India.',
    true
  ),
  (
    'Bajaj Finserv',
    'bajaj-finserv',
    'Financial Services & FinTech',
    'https://www.bajajfinserv.in',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/9/99/Bajaj_Finserv_Logo.svg/320px-Bajaj_Finserv_Logo.svg.png',
    'Pune',
    'Maharashtra',
    'Pune, Maharashtra',
    'Diversified financial giant offering consumer lending, wealth management, insurance, and payments.',
    true
  ),
  (
    'BookMyShow',
    'bookmyshow',
    'Entertainment & Online Ticketing',
    'https://in.bookmyshow.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/7/77/BookMyShow_Logo.svg/320px-BookMyShow_Logo.svg.png',
    'Mumbai',
    'Maharashtra',
    'Mumbai, Maharashtra',
    'India''s premier entertainment destination and online ticketing platform for cinema, live events, and sports.',
    true
  ),
  (
    'Nykaa',
    'nykaa',
    'Beauty & Consumer E-commerce',
    'https://www.nykaa.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/Nykaa_Logo.svg/320px-Nykaa_Logo.svg.png',
    'Mumbai',
    'Maharashtra',
    'Mumbai, Maharashtra',
    'Leading omnichannel lifestyle retailer specializing in curated beauty, wellness, and fashion products.',
    true
  ),

  -- ========================================================
  -- 5. HARYANA (8 Companies)
  -- ========================================================
  (
    'Zomato',
    'zomato',
    'Food Tech & Online Delivery',
    'https://www.zomato.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/7/75/Zomato_logo.png/320px-Zomato_logo.png',
    'Gurugram',
    'Haryana',
    'Gurugram, Haryana',
    'Leading food discovery, restaurant partner platform, and online food delivery service across India.',
    true
  ),
  (
    'Blinkit',
    'blinkit',
    'Quick Commerce & Logistics',
    'https://blinkit.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/Blinkit-yellow-app-icon.svg/320px-Blinkit-yellow-app-icon.svg.png',
    'Gurugram',
    'Haryana',
    'Gurugram, Haryana',
    'Pioneering quick commerce platform delivering groceries, electronics, and daily essentials within minutes.',
    true
  ),
  (
    'MakeMyTrip',
    'makemytrip',
    'Online Travel & Hospitality Tech',
    'https://www.makemytrip.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/MakeMyTrip_Logo.svg/320px-MakeMyTrip_Logo.svg.png',
    'Gurugram',
    'Haryana',
    'Gurugram, Haryana',
    'India''s premier online travel company offering comprehensive flight, train, hotel, and holiday packages.',
    true
  ),
  (
    'PolicyBazaar',
    'policybazaar',
    'Insurtech & Financial Services',
    'https://www.policybazaar.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Policybazaar_logo.svg/320px-Policybazaar_logo.svg.png',
    'Gurugram',
    'Haryana',
    'Gurugram, Haryana',
    'India''s largest online insurance marketplace providing transparent advisory and policy comparison.',
    true
  ),
  (
    'Delhivery',
    'delhivery',
    'Supply Chain & Logistics Tech',
    'https://www.delhivery.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Delhivery_Logo.svg/320px-Delhivery_Logo.svg.png',
    'Gurugram',
    'Haryana',
    'Gurugram, Haryana',
    'India''s largest fully integrated logistics and supply chain services company powered by automation.',
    true
  ),
  (
    'Urban Company',
    'urban-company',
    'On-Demand Services & Consumer Tech',
    'https://www.urbancompany.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/Urban_Company_logo.svg/320px-Urban_Company_logo.svg.png',
    'Gurugram',
    'Haryana',
    'Gurugram, Haryana',
    'Asia''s largest home services marketplace connecting consumers with trained and verified service professionals.',
    true
  ),
  (
    'Cars24',
    'cars24',
    'Auto Tech & E-commerce',
    'https://www.cars24.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/CARS24_Logo.svg/320px-CARS24_Logo.svg.png',
    'Gurugram',
    'Haryana',
    'Gurugram, Haryana',
    'Leading e-commerce platform for pre-owned vehicles transforming car buying and selling through tech.',
    true
  ),
  (
    'Oyo Rooms',
    'oyo-rooms',
    'Hospitality & Travel Tech',
    'https://www.oyorooms.com',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/1/19/OYO_Rooms_%28logo%29.png/320px-OYO_Rooms_%28logo%29.png',
    'Gurugram',
    'Haryana',
    'Gurugram, Haryana',
    'Global hospitality technology platform empowering small hotel owners with technology and demand generation.',
    true
  )
on conflict (slug) do update set
  name = excluded.name,
  industry = excluded.industry,
  website = excluded.website,
  logo_url = excluded.logo_url,
  city = excluded.city,
  state = excluded.state,
  location = excluded.location,
  description = excluded.description,
  is_approved = excluded.is_approved,
  updated_at = now();

-- =============================================================================
-- Demo seed data for placement_db (PostgreSQL + Spring Boot).
-- Clears existing rows, resets identity sequences, then inserts connected data.
-- Login sample: email <local>@<role>.com (student | staff | system); demo password = <local>@123 per user row.
-- Note: table `roles` is limited to three distinct role_name values (STUDENT, STAFF, SYSTEM) by the domain model.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1) Truncate all application tables (children implied via CASCADE where needed).
--    Order in the list is not significant when all related tables are included.
-- -----------------------------------------------------------------------------
TRUNCATE TABLE
    staff_managed_role_departments,
    staff_managed_role_students,
    staff_managed_role_drives,
    staff_managed_role_companies,
    staff_managed_roles,
    staff_professional_experiences,
    staff_subjects,
    staff_qualifications,
    company_documents,
    selection_rounds,
    job_applications,
    drive_offered_roles,
    drive_branches,
    skills,
    platform_links,
    project,
    backlog,
    education,
    student_experiences,
    jobs,
    drives,
    company_contact_support,
    student_profile,
    staff_profiles,
    companies,
    departments,
    users,
    roles
RESTART IDENTITY CASCADE;

-- Older DBs may have legacy CHECK constraints that omit SYSTEM; RoleType enum includes STUDENT, STAFF, SYSTEM.
ALTER TABLE roles DROP CONSTRAINT IF EXISTS roles_role_name_check;
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check;

-- -----------------------------------------------------------------------------
-- 2) Reference data: roles (domain allows only three enum values; all inserted).
-- -----------------------------------------------------------------------------
INSERT INTO roles (id, role_name) VALUES
    (1, 'STUDENT'),
    (2, 'STAFF'),
    (3, 'SYSTEM');

-- -----------------------------------------------------------------------------
-- 3) Departments (no FKs) — Indian engineering / management departments.
-- -----------------------------------------------------------------------------
INSERT INTO departments (id, name, code, college_name) VALUES
    (1, 'Computer Science & Engineering', 'CSE', 'BITS Pilani'),
    (2, 'Electronics & Communication', 'ECE', 'BITS Pilani'),
    (3, 'Information Technology', 'IT', 'VJTI Mumbai'),
    (4, 'MBA Core', 'MBA-CORE', 'NMIMS Mumbai'),
    (5, 'Data Science & AI', 'DSAI', 'IIIT Hyderabad');

-- -----------------------------------------------------------------------------
-- 4) Users — demo logins use <local>@<role>.com; BCrypt password = plain text <local>@123 per row.
-- -----------------------------------------------------------------------------
INSERT INTO users (id, email, password, role, created_at) VALUES
    (1, 'aarav@student.com', '$2b$10$uLJ23jzqbpHtaJqgcS9xwe7X1xf/4ujtarRgZtJEPMmassaVF1Nrm', 'STUDENT', TIMESTAMPTZ '2026-01-10 08:00:00+00'),
    (2, 'kavya@student.com', '$2b$10$rTpbCruJgY0305.1M6Kl7e6tQw/Ib9idU2JjulFlJbfo8XFN/jfGK', 'STUDENT', TIMESTAMPTZ '2026-01-10 08:05:00+00'),
    (3, 'arjun@student.com', '$2b$10$Fpd/h0LYWC06MMMH69TS2eYW8NFaiTsjgB3msJ6mxTdUub5ni5Jme', 'STUDENT', TIMESTAMPTZ '2026-01-10 08:10:00+00'),
    (4, 'zoya@student.com', '$2b$10$Ci/Eg2NNs5KDO/EF8nNRpeDc3yKJ4CHE6rUUB5J4zppV9Pkd8jq32', 'STUDENT', TIMESTAMPTZ '2026-01-10 08:15:00+00'),
    (5, 'veer@student.com', '$2b$10$0TWCxRZvgyVuF1m6uwBDhOQjPQzFhijx/qE4GU0puHKMvf4MdIkcm', 'STUDENT', TIMESTAMPTZ '2026-01-10 08:20:00+00'),
    (6, 'meher@staff.com', '$2b$10$LSHrjpF3Zr2KCaLI1VZuCegNdMl2DIumJOSqb9QjuZZGjcIfAr/AC', 'STAFF', TIMESTAMPTZ '2026-01-05 09:00:00+00'),
    (7, 'isha@staff.com', '$2b$10$TBSNlFrZiossyWvZ5kwrLuxYeVlpnbfZh2b2Vwkhp/WwyD7ZNa8GC', 'STAFF', TIMESTAMPTZ '2026-01-05 09:05:00+00'),
    (8, 'reyansh@staff.com', '$2b$10$Nw8POWuMYgPqq2Q.tuavYeLkx0erY5/St0NK8dkNY6HdjgZP92OPm', 'STAFF', TIMESTAMPTZ '2026-01-05 09:10:00+00'),
    (9, 'anaya@staff.com', '$2b$10$iebbwscOiXRe.uunZt/mOOzD7jX1T.gq7ePZ6lkUFAXxZ.7r8AN/i', 'STAFF', TIMESTAMPTZ '2026-01-05 09:15:00+00'),
    (10, 'kiara@staff.com', '$2b$10$rfdhKoXpquIzkFa5.2LQz.hLZf0VAVOkSgpCQSYLIZHyRP.932FDC', 'STAFF', TIMESTAMPTZ '2026-01-05 09:20:00+00'),
    (11, 'admin@system.com', '$2b$10$qu9IxSti21iXsh2yMrV4Uuq8o1XfybuID3CZb402h8AhtNcK.s1SO', 'SYSTEM', TIMESTAMPTZ '2025-12-01 10:00:00+00');

-- -----------------------------------------------------------------------------
-- 5) Companies — parent for jobs, drives, contacts, applications.company_id
--    image_url: placeholder only (no real image URL).
-- -----------------------------------------------------------------------------
INSERT INTO companies (id, name, tagline, location, email, website_url, description, overview, sector, image_url) VALUES
    (1, 'Razorpay', 'Payments for modern India', 'Bengaluru, Karnataka', 'careers@razorpay-demo.example', 'https://razorpay.com', 'Full-stack payments and banking suite for Indian businesses.', 'High-growth fintech with strong campus hiring across SDE and analyst tracks.', 'Fintech', NULL), -- add image url here
    (2, 'Swiggy', 'Eat what you love', 'Bengaluru, Karnataka', 'campus@swiggy-demo.example', 'https://www.swiggy.com', 'Consumer tech and logistics at scale across Indian cities.', 'Tech roles in logistics, discovery, and platform engineering.', 'Consumer Tech', NULL), -- add image url here
    (3, 'Tata Consultancy Services', 'Building on belief', 'Mumbai, Maharashtra', 'nextstep@tcs-demo.example', 'https://www.tcs.com', 'Global IT services with deep India campus programs.', 'Large-scale engineering, consulting, and digital transformation.', 'IT Services', NULL), -- add image url here
    (4, 'Zoho Corporation', 'Made in India, for the world', 'Tenkasi / Chennai, Tamil Nadu', 'careers@zoho-demo.example', 'https://www.zoho.com', 'Product company spanning CRM, finance, and collaboration.', 'Product engineering with emphasis on ownership and craft.', 'SaaS', NULL), -- add image url here
    (5, 'Infosys Limited', 'Navigate your next', 'Bengaluru, Karnataka', 'campus@infosys-demo.example', 'https://www.infosys.com', 'Digital services and consulting with Pan-India onboarding.', 'Digital, cloud, and core engineering programs for freshers.', 'IT Services', NULL); -- add image url here

-- One brochure/policy link per company (element collection: company_documents)
INSERT INTO company_documents (company_id, document_url) VALUES
    (1, 'PLACEHOLDER_DOC_URL_razorpay_brochure'),
    (2, 'PLACEHOLDER_DOC_URL_swiggy_faq'),
    (3, 'PLACEHOLDER_DOC_URL_tcs_eligibility'),
    (4, 'PLACEHOLDER_DOC_URL_zoho_product_deck'),
    (5, 'PLACEHOLDER_DOC_URL_infosys_joining_kit');

INSERT INTO company_contact_support (id, company_id, name, email, phone, preferred_mode) VALUES
    (1, 1, 'Aditya Malhotra', 'aditya.malhotra@razorpay-demo.example', '9876543210', 'EMAIL'),
    (2, 2, 'Neha Krishnan', 'neha.krishnan@swiggy-demo.example', '9876543211', 'WHATSAPP'),
    (3, 3, 'Rohan Iyer', 'rohan.iyer@tcs-demo.example', '9876543212', 'PHONE'),
    (4, 4, 'Priya Sundaram', 'priya.sundaram@zoho-demo.example', '9876543213', 'EMAIL'),
    (5, 5, 'Siddharth Menon', 'siddharth.menon@infosys-demo.example', '9876543214', 'OTHER');

-- -----------------------------------------------------------------------------
-- 6) Staff profiles — each row links 1:1 to a STAFF user (user_id 6..10).
-- -----------------------------------------------------------------------------
INSERT INTO staff_profiles (id, user_id, name, user_email, email, phone_number, linkedin, office_location, college_name, joining_year, joining_month, ending_year, ending_month) VALUES
    (1, 6, 'Meher Qureshi', 'meher@staff.com', 'meher@staff.com', '9123456701', 'https://www.linkedin.com/in/meher-qureshi-demo', 'NMIMS Mumbai Placement Cell', 'NMIMS Mumbai', 2018, 7, NULL, NULL),
    (2, 7, 'Isha Kapoor', 'isha@staff.com', 'isha@staff.com', '9123456702', 'https://www.linkedin.com/in/isha-kapoor-demo', 'NMIMS Mumbai Placement Cell', 'NMIMS Mumbai', 2019, 6, NULL, NULL),
    (3, 8, 'Reyansh Desai', 'reyansh@staff.com', 'reyansh@staff.com', '9123456703', 'https://www.linkedin.com/in/reyansh-desai-demo', 'BITS Pilani Training & Placement', 'BITS Pilani', 2015, 8, NULL, NULL),
    (4, 9, 'Anaya Sen', 'anaya@staff.com', 'anaya@staff.com', '9123456704', 'https://www.linkedin.com/in/anaya-sen-demo', 'BITS Pilani Training & Placement', 'BITS Pilani', 2017, 7, NULL, NULL),
    (5, 10, 'Kiara Nambiar', 'kiara@staff.com', 'kiara@staff.com', '9123456705', 'https://www.linkedin.com/in/kiara-nambiar-demo', 'IIIT Hyderabad CDC', 'IIIT Hyderabad', 2020, 1, NULL, NULL);

-- Element collections for staff (subjects / qualifications)
INSERT INTO staff_subjects (staff_id, subject_line) VALUES
    (1, 'Data Structures & Algorithms'),
    (1, 'Operating Systems Lab'),
    (2, 'Business Communication'),
    (2, 'Aptitude & Reasoning'),
    (3, 'Compiler Design'),
    (4, 'Database Systems'),
    (5, 'Human–Computer Interaction'),
    (5, 'Product Management Basics');

INSERT INTO staff_qualifications (staff_id, qualification_line) VALUES
    (1, 'M.Tech Computer Science, IIT Bombay'),
    (2, 'MBA Marketing, NMIMS Mumbai'),
    (3, 'B.E. Computer Science, BITS Pilani'),
    (4, 'M.E. Software Systems, BITS Pilani'),
    (5, 'MS Human–Computer Interaction, Georgia Tech (alumni demo)');

INSERT INTO staff_professional_experiences (id, staff_id, company_name, role_title, from_date, to_date, description) VALUES
    (1, 1, 'Campus Mentors Pvt Ltd', 'Aptitude Coach', DATE '2016-06-01', DATE '2019-03-31', 'Conducted nationwide aptitude workshops for engineering colleges.'),
    (2, 2, 'NMIMS Consulting Club', 'Program Coordinator', DATE '2019-08-01', DATE '2022-05-31', 'Coordinated industry panels and mock GD–PI seasons.'),
    (3, 3, 'Finacle Labs', 'Senior SDE', DATE '2015-07-01', DATE '2021-12-31', 'Built reconciliation microservices for UPI-scale traffic (demo narrative).'),
    (4, 4, 'EduTech India', 'Engineering Manager', DATE '2017-07-01', DATE '2024-01-15', 'Led a team of twelve engineers across LMS and assessment products.'),
    (5, 5, 'DesignUp Collective', 'UX Research Consultant', DATE '2020-02-01', DATE '2023-11-30', 'Partnered with startups on qualitative research for onboarding funnels.');

-- -----------------------------------------------------------------------------
-- 7) Student profiles — user_id 1..5 ; photo_url left NULL (add image url here).
-- -----------------------------------------------------------------------------
INSERT INTO student_profile (id, user_id, name, username, user_email, domain_role, phone_number, photo_url, bio, address_line, city, state, pin_code, resume_url, hired, hired_company_name, dob) VALUES
    (1, 1, 'Aarav Sharma', 'aarav_sharma', 'aarav@student.com', 'Backend Intern track', '9821012345', NULL, 'Prefers distributed systems; active in BITS ACM chapter.', 'Hostel 7, Vidya Vihar', 'Pilani', 'Rajasthan', '333031', 'PLACEHOLDER_RESUME_URL_aarav', FALSE, NULL, DATE '2003-04-12'),
    (2, 2, 'Kavya Nair', 'kavya_codes', 'kavya@student.com', 'Full Stack', '9821012346', NULL, 'Full-stack projects with React and Spring; interned at a Jaipur startup.', 'Near Marine Drive', 'Mumbai', 'Maharashtra', '400020', 'PLACEHOLDER_RESUME_URL_kavya', FALSE, NULL, DATE '2003-09-21'),
    (3, 3, 'Arjun Verma', 'arjun_v', 'arjun@student.com', 'ML Systems', '9810213456', NULL, 'Kaggle student ambassador; research on low-resource NLP for Hindi.', 'Hauz Khas', 'New Delhi', 'Delhi', '110016', 'PLACEHOLDER_RESUME_URL_arjun', FALSE, NULL, DATE '2002-11-03'),
    (4, 4, 'Zoya Khan', 'zoya_k', 'zoya@student.com', 'Product + UX', '9810213457', NULL, 'Design lead for college fest app; PMF case competitions.', 'Saket', 'New Delhi', 'Delhi', '110017', 'PLACEHOLDER_RESUME_URL_zoya', FALSE, NULL, DATE '2003-01-30'),
    (5, 5, 'Veer Patil', 'veer_patil', 'veer@student.com', 'Finance Tech', '9890123789', NULL, 'FinTech society head; CFA level 1 candidate.', 'Vile Parle West', 'Mumbai', 'Maharashtra', '400056', 'PLACEHOLDER_RESUME_URL_veer', FALSE, NULL, DATE '2002-07-19');

INSERT INTO education (id, student_id, university, branch, course, domain, current_year, tenth_percentage, twelfth_percentage, current_cgpa, tenth_school_name, twelfth_school_name, graduation_college_name, post_graduation_college_name, gap_years, gap_reason) VALUES
    (1, 1, 'BITS Pilani', 'ENGINEERING_TECHNOLOGY', 'BTECH', 'SOFTWARE_DEVELOPMENT', 3, 94.20, 95.40, 8.76, 'Delhi Public School RK Puram', 'Modern School Barakhamba Road', 'BITS Pilani', NULL, 0, NULL),
    (2, 2, 'BITS Pilani', 'ENGINEERING_TECHNOLOGY', 'BTECH', 'WEB_DEVELOPMENT', 3, 92.80, 93.10, 8.54, 'Kendriya Vidyalaya IIT Powai', 'PACE Junior Science College', 'BITS Pilani', NULL, 0, NULL),
    (3, 3, 'IIT Delhi', 'ENGINEERING_TECHNOLOGY', 'BTECH', 'DATA_SCIENCE', 4, 96.00, 97.20, 9.12, 'Sardar Patel Vidyalaya', 'FIITJEE South Delhi', 'IIT Delhi', NULL, 0, NULL),
    (4, 4, 'IIT Delhi', 'ENGINEERING_TECHNOLOGY', 'BTECH', 'PRODUCT_MANAGEMENT', 4, 93.50, 94.00, 8.88, 'The Mother''s International School', 'Sri Venkateswara College', 'IIT Delhi', NULL, 0, NULL),
    (5, 5, 'NMIMS Mumbai', 'MANAGEMENT_BUSINESS', 'MBA', 'FINANCE', 2, 91.00, 92.40, 3.72, 'St. Xavier''s High School', 'HR College of Commerce', 'NMIMS Mumbai', NULL, 0, NULL);

-- Point backlog.education_profile_id at JPA table education (some DBs still reference legacy education_profile).
ALTER TABLE backlog DROP CONSTRAINT IF EXISTS fk5u1qwp7myqgobsrnyyaih04yt;
ALTER TABLE backlog DROP CONSTRAINT IF EXISTS fk3hyqfels8nq9wa75qfnhq7xnv;
ALTER TABLE backlog DROP CONSTRAINT IF EXISTS fk_backlog_education_profile;
ALTER TABLE backlog DROP CONSTRAINT IF EXISTS backlog_education_profile_id_fkey;
ALTER TABLE backlog ADD CONSTRAINT fk_backlog_education_profile FOREIGN KEY (education_profile_id) REFERENCES education (id);

INSERT INTO backlog (id, education_profile_id, subject, semester) VALUES
    (1, 1, 'Humanities Elective', 2),
    (2, 2, 'Environmental Sciences', 1),
    (3, 3, 'None (clean record)', 0),
    (4, 4, 'None (clean record)', 0),
    (5, 5, 'Business Statistics makeup', 1);

-- Note: rows 3–4 use placeholder subject text so each education profile can still carry a backlog row for demo queries.

INSERT INTO skills (id, student_id, languages, frameworks, tools, platforms) VALUES
    (1, 1, 'Java, Go, SQL', 'Spring Boot, Hibernate', 'Docker, Git, IntelliJ', 'Linux, AWS'),
    (2, 2, 'JavaScript, TypeScript, Java', 'React, Node.js', 'Git, VS Code, Postman', 'Linux, Vercel'),
    (3, 3, 'Python, C++, SQL', 'PyTorch, scikit-learn', 'Weights & Biases, Git', 'Linux, GCP'),
    (4, 4, 'Figma, TypeScript', 'React, Next.js', 'Miro, Notion, Git', 'Web'),
    (5, 5, 'Python, R, SQL', 'Pandas, NumPy', 'Excel, Power BI, Git', 'Windows, Bloomberg Terminal (lab)');

INSERT INTO platform_links (id, student_id, platform_type, url) VALUES
    (1, 1, 'GITHUB', 'https://github.com/aarav-sharma-demo'),
    (2, 2, 'LINKEDIN', 'https://www.linkedin.com/in/kavya-nair-demo'),
    (3, 3, 'LEETCODE', 'https://leetcode.com/u/arjunverma-demo'),
    (4, 4, 'PORTFOLIO', 'PLACEHOLDER_PORTFOLIO_URL_zoya'),
    (5, 5, 'GITHUB', 'https://github.com/veer-patil-demo');

INSERT INTO project (id, student_id, title, description, link) VALUES
    (1, 1, 'CampusRide pooling', 'Carpooling matcher for inter-hostel trips with surge pricing awareness.', 'https://github.com/demo/campusrides'),
    (2, 2, 'Mess Feedback NLP', 'Sentiment dashboard for hostel mess comments using IndicBERT.', 'https://github.com/demo/mess-nlp'),
    (3, 3, 'KrishiVision', 'Crop stress detection from smartphone images for Punjab farms.', 'https://github.com/demo/krishivision'),
    (4, 4, 'MetroDelhi accessibility map', 'OpenDataDelhi + Figma prototype for low-vision commuters.', 'https://github.com/demo/metro-a11y'),
    (5, 5, 'UPI spend classifier', 'Rule engine + ML hybrid for personal finance literacy workshops.', 'https://github.com/demo/upi-classifier');

INSERT INTO student_experiences (id, student_id, company_name, job_type, location, from_date, to_date, role_description) VALUES
    (1, 1, 'ChaiPoint Tech', 'INTERNSHIP', 'Gurugram', DATE '2025-05-15', DATE '2025-07-30', 'Backend intern on inventory sync service (Spring + Kafka).'),
    (2, 2, 'The Souled Store', 'PART_TIME', 'Mumbai', DATE '2024-06-01', DATE '2025-03-31', 'Store ops analytics dashboards in Google Sheets + Apps Script.'),
    (3, 3, 'IITD Hyperplane Lab', 'CONTRACT', 'New Delhi', DATE '2025-01-10', DATE '2025-04-30', 'Research assistant on Hindi–English code-mixed ASR.'),
    (4, 4, 'Delhi Govt Internship', 'INTERNSHIP', 'New Delhi', DATE '2024-12-01', DATE '2025-01-20', 'UX research for e-governance kiosk flows.'),
    (5, 5, 'Axis Bank Learning', 'APPRENTICESHIP', 'Mumbai', DATE '2025-02-01', DATE '2025-04-15', 'Branch rotation with focus on retail liabilities reporting.');

-- -----------------------------------------------------------------------------
-- 8) Jobs — each tied to a company; placement_coordinator_staff_id -> staff_profiles.id
-- -----------------------------------------------------------------------------
INSERT INTO jobs (id, company_id, job_type, internship_duration, work_mode, ctc_lpa, additional_info, last_date_to_apply, job_posting_time, venue, job_description, preparation_guide, requirements, responsibilities, eligibility, result_status, result_date, placement_coordinator_staff_id, created_at, updated_at) VALUES
    (1, 1, 'FULL_TIME', NULL, 'HYBRID', 18.50, 'Includes wellness allowance (demo).', DATE '2026-06-15', TIMESTAMP '2026-05-01 10:00:00', 'Razorpay Bengaluru Office', 'Payments platform engineer working on ledger microservices.', 'Revise DB transactions, idempotency keys, and REST design.', 'Strong Java, distributed systems basics.', 'Design APIs, pair with SRE on incidents.', 'B.Tech CSE/IT, 2026 passing, CGPA >= 7.5', 'NOT_ANNOUNCED', NULL, 1, TIMESTAMP '2026-05-01 10:00:00', TIMESTAMP '2026-05-10 12:00:00'),
    (2, 2, 'FULL_TIME', NULL, 'ON_SITE', 16.00, 'Rotations across marketplace and ads.', DATE '2026-06-20', TIMESTAMP '2026-05-02 11:00:00', 'Swiggy Koramangala HQ', 'Backend engineer for catalog ingestion pipelines.', 'Practice system design for high write throughput.', 'Java/Kotlin, Kafka basics.', 'Own on-call for ingestion services monthly.', 'B.Tech/M.Tech 2026, pH test cleared', 'ANNOUNCED', DATE '2026-05-01', 2, TIMESTAMP '2026-05-02 11:00:00', TIMESTAMP '2026-05-11 09:30:00'),
    (3, 3, 'INTERNSHIP', '6 months', 'HYBRID', 4.20, 'PPO possible after review.', DATE '2026-06-01', TIMESTAMP '2026-05-03 09:00:00', 'TCS Digital Zone Pune', 'Digital internship on cloud migration toolkit.', 'Brush up Azure fundamentals and agile ceremonies.', 'Basic Java + willingness to travel.', 'Shadow solution architects on client workshops.', 'Pre-final/final year engineering students', 'NOT_ANNOUNCED', NULL, 3, TIMESTAMP '2026-05-03 09:00:00', TIMESTAMP '2026-05-12 08:00:00'),
    (4, 4, 'FULL_TIME', NULL, 'REMOTE', 14.75, 'Product pods across Chennai/Tenkasi.', DATE '2026-06-25', TIMESTAMP '2026-05-04 14:00:00', 'Remote (India)', 'Full-stack engineer on Zoho Books integrations.', 'Revise JavaScript modules and multi-tenant SaaS patterns.', 'Strong problem solving, respectful code review habits.', 'Ship features end-to-end with QA partners.', '2026 graduates from CS/IT programs', 'NOT_ANNOUNCED', NULL, 4, TIMESTAMP '2026-05-04 14:00:00', TIMESTAMP '2026-05-13 10:45:00'),
    (5, 5, 'FULL_TIME', NULL, 'HYBRID', 12.00, 'Mysore / Pune training hubs.', DATE '2026-06-30', TIMESTAMP '2026-05-05 08:30:00', 'Infosys Mysuru EC', 'Systems engineer stream with digital specialization.', 'InfyTQ modules + aptitude refresh.', 'Good communication, adaptable to agile squads.', 'Rotate across maintenance and greenfield squads.', '2026 batch with no active standing arrears', 'NOT_ANNOUNCED', NULL, 5, TIMESTAMP '2026-05-05 08:30:00', TIMESTAMP '2026-05-14 07:15:00');

-- -----------------------------------------------------------------------------
-- 9) Drives — campus visit style; registration_deadline is NOT NULL
-- -----------------------------------------------------------------------------
INSERT INTO drives (id, drive_name, company_id, registration_deadline, drive_date_time, venue, result_status, result_date, placement_coordinator_staff_id, created_at, updated_at) VALUES
    (1, 'Razorpay Winter Campus 2026', 1, TIMESTAMP '2026-06-10 18:00:00', TIMESTAMP '2026-07-02 09:30:00', 'NMIMS Mumbai Auditorium', 'NOT_ANNOUNCED', NULL, 1, TIMESTAMP '2026-05-01 09:00:00', TIMESTAMP '2026-05-10 10:00:00'),
    (2, 'Swiggy Mega Drive Mumbai', 2, TIMESTAMP '2026-06-12 18:00:00', TIMESTAMP '2026-07-05 10:00:00', 'Swiggy Mumbai Office', 'ANNOUNCED', DATE '2026-05-08', 2, TIMESTAMP '2026-05-02 09:00:00', TIMESTAMP '2026-05-11 11:00:00'),
    (3, 'TCS Digital National Qualifier', 3, TIMESTAMP '2026-05-28 23:59:00', TIMESTAMP '2026-06-18 08:00:00', 'TCS iON online + Pune hub', 'NOT_ANNOUNCED', NULL, 3, TIMESTAMP '2026-05-03 09:00:00', TIMESTAMP '2026-05-12 09:30:00'),
    (4, 'Zoho Off-campus India 2026', 4, TIMESTAMP '2026-06-18 23:59:00', TIMESTAMP '2026-07-10 09:00:00', 'Zoho Tenkasi Mini Auditorium', 'NOT_ANNOUNCED', NULL, 4, TIMESTAMP '2026-05-04 09:00:00', TIMESTAMP '2026-05-13 12:00:00'),
    (5, 'Infosys HackWithInfy + SP', 5, TIMESTAMP '2026-06-22 23:59:00', TIMESTAMP '2026-07-12 08:30:00', 'Infosys Mysuru Global Education Center', 'NOT_ANNOUNCED', NULL, 5, TIMESTAMP '2026-05-05 09:00:00', TIMESTAMP '2026-05-14 08:00:00');

-- Drive branches: each drive allows a distinct branch bucket (unique drive_id + branch)
INSERT INTO drive_branches (id, drive_id, branch) VALUES
    (1, 1, 'ENGINEERING_TECHNOLOGY'),
    (2, 2, 'ENGINEERING_TECHNOLOGY'),
    (3, 3, 'MANAGEMENT_BUSINESS'),
    (4, 4, 'COMPUTER_APPLICATIONS_IT'),
    (5, 5, 'ENGINEERING_TECHNOLOGY');

-- Offered roles inside a drive; linked_job_id optionally points at canonical job posting
INSERT INTO drive_offered_roles (id, drive_id, role_title, linked_job_id) VALUES
    (1, 1, 'Software Engineer – Payments', 1),
    (2, 2, 'Backend Engineer – Catalog', 2),
    (3, 3, 'Digital Intern', 3),
    (4, 4, 'Product Engineer – Books', 4),
    (5, 5, 'Systems Engineer', 5);

-- Managed scopes for placement officers (after students, companies, and drives exist for FKs in collection tables)
-- -----------------------------------------------------------------------------
-- 10) Staff managed roles + collection tables (company / drive / student / department scope rows)
-- -----------------------------------------------------------------------------
INSERT INTO staff_managed_roles (id, staff_id) VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5);

INSERT INTO staff_managed_role_companies (managed_role_id, company_id) VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5);

INSERT INTO staff_managed_role_drives (managed_role_id, drive_id) VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5);

INSERT INTO staff_managed_role_students (managed_role_id, student_id) VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5);

INSERT INTO staff_managed_role_departments (managed_role_id, department) VALUES
    (1, 'ENGINEERING_TECHNOLOGY'),
    (2, 'MANAGEMENT_BUSINESS'),
    (3, 'ENGINEERING_TECHNOLOGY'),
    (4, 'COMPUTER_APPLICATIONS_IT'),
    (5, 'ENGINEERING_TECHNOLOGY');

-- -----------------------------------------------------------------------------
-- 11) Selection rounds — CHECK: exactly one of (job_id, drive_id) is non-null.
-- -----------------------------------------------------------------------------
INSERT INTO selection_rounds (id, job_id, drive_id, round_name, sequence_number, scheduled_date, is_completed) VALUES
    (1, 1, NULL, 'Online assessment', 1, TIMESTAMP '2026-06-20 10:00:00', FALSE),
    (2, 2, NULL, 'Code pair round', 2, TIMESTAMP '2026-06-22 14:00:00', FALSE),
    (3, 3, NULL, 'Digital aptitude + English', 1, TIMESTAMP '2026-06-05 09:00:00', FALSE),
    (4, 4, NULL, 'Take-home + discussion', 1, TIMESTAMP '2026-06-28 11:00:00', FALSE),
    (5, 5, NULL, 'InfyTQ round 2', 2, TIMESTAMP '2026-07-01 09:00:00', FALSE),
    (6, NULL, 1, 'Pre-placement talk', 1, TIMESTAMP '2026-06-25 16:00:00', FALSE),
    (7, NULL, 2, 'Swiggy tech mixer', 1, TIMESTAMP '2026-06-18 18:30:00', FALSE),
    (8, NULL, 3, 'National qualifier test', 1, TIMESTAMP '2026-06-10 08:00:00', FALSE),
    (9, NULL, 4, 'Zoho written + apps', 1, TIMESTAMP '2026-07-08 09:00:00', FALSE),
    (10, NULL, 5, 'HackWithInfy finals', 1, TIMESTAMP '2026-07-11 09:00:00', FALSE);

-- -----------------------------------------------------------------------------
-- 12) Applications — company_id must match the job''s company for referential consistency.
-- -----------------------------------------------------------------------------
INSERT INTO job_applications (id, student_id, job_id, company_id, applied_at, status, interview_date, interview_mode) VALUES
    (1, 1, 1, 1, TIMESTAMP '2026-05-06 11:00:00', 'SHORTLISTED', TIMESTAMP '2026-06-21 10:00:00', 'ONLINE'),
    (2, 2, 2, 2, TIMESTAMP '2026-05-07 15:30:00', 'INTERVIEW_SCHEDULED', TIMESTAMP '2026-06-23 11:00:00', 'HYBRID'),
    (3, 3, 3, 3, TIMESTAMP '2026-05-08 09:45:00', 'APPLIED', NULL, NULL),
    (4, 4, 4, 4, TIMESTAMP '2026-05-09 13:20:00', 'APPLICATION_REVIEWED', NULL, NULL),
    (5, 5, 5, 5, TIMESTAMP '2026-05-10 17:00:00', 'OFFER', TIMESTAMP '2026-07-02 09:00:00', 'IN_PERSON');

-- -----------------------------------------------------------------------------
-- 13) Keep SERIAL/IDENTITY sequences aligned with explicit IDs (next insert safe).
-- -----------------------------------------------------------------------------
SELECT SETVAL(PG_GET_SERIAL_SEQUENCE('roles', 'id'), (SELECT COALESCE(MAX(id), 1) FROM roles));
SELECT SETVAL(PG_GET_SERIAL_SEQUENCE('departments', 'id'), (SELECT COALESCE(MAX(id), 1) FROM departments));
SELECT SETVAL(PG_GET_SERIAL_SEQUENCE('users', 'id'), (SELECT COALESCE(MAX(id), 1) FROM users));
SELECT SETVAL(PG_GET_SERIAL_SEQUENCE('companies', 'id'), (SELECT COALESCE(MAX(id), 1) FROM companies));
SELECT SETVAL(PG_GET_SERIAL_SEQUENCE('company_contact_support', 'id'), (SELECT COALESCE(MAX(id), 1) FROM company_contact_support));
SELECT SETVAL(PG_GET_SERIAL_SEQUENCE('staff_profiles', 'id'), (SELECT COALESCE(MAX(id), 1) FROM staff_profiles));
SELECT SETVAL(PG_GET_SERIAL_SEQUENCE('staff_professional_experiences', 'id'), (SELECT COALESCE(MAX(id), 1) FROM staff_professional_experiences));
SELECT SETVAL(PG_GET_SERIAL_SEQUENCE('staff_managed_roles', 'id'), (SELECT COALESCE(MAX(id), 1) FROM staff_managed_roles));
SELECT SETVAL(PG_GET_SERIAL_SEQUENCE('student_profile', 'id'), (SELECT COALESCE(MAX(id), 1) FROM student_profile));
SELECT SETVAL(PG_GET_SERIAL_SEQUENCE('education', 'id'), (SELECT COALESCE(MAX(id), 1) FROM education));
SELECT SETVAL(PG_GET_SERIAL_SEQUENCE('backlog', 'id'), (SELECT COALESCE(MAX(id), 1) FROM backlog));
SELECT SETVAL(PG_GET_SERIAL_SEQUENCE('skills', 'id'), (SELECT COALESCE(MAX(id), 1) FROM skills));
SELECT SETVAL(PG_GET_SERIAL_SEQUENCE('platform_links', 'id'), (SELECT COALESCE(MAX(id), 1) FROM platform_links));
SELECT SETVAL(PG_GET_SERIAL_SEQUENCE('project', 'id'), (SELECT COALESCE(MAX(id), 1) FROM project));
SELECT SETVAL(PG_GET_SERIAL_SEQUENCE('student_experiences', 'id'), (SELECT COALESCE(MAX(id), 1) FROM student_experiences));
SELECT SETVAL(PG_GET_SERIAL_SEQUENCE('jobs', 'id'), (SELECT COALESCE(MAX(id), 1) FROM jobs));
SELECT SETVAL(PG_GET_SERIAL_SEQUENCE('drives', 'id'), (SELECT COALESCE(MAX(id), 1) FROM drives));
SELECT SETVAL(PG_GET_SERIAL_SEQUENCE('drive_branches', 'id'), (SELECT COALESCE(MAX(id), 1) FROM drive_branches));
SELECT SETVAL(PG_GET_SERIAL_SEQUENCE('drive_offered_roles', 'id'), (SELECT COALESCE(MAX(id), 1) FROM drive_offered_roles));
SELECT SETVAL(PG_GET_SERIAL_SEQUENCE('selection_rounds', 'id'), (SELECT COALESCE(MAX(id), 1) FROM selection_rounds));
SELECT SETVAL(PG_GET_SERIAL_SEQUENCE('job_applications', 'id'), (SELECT COALESCE(MAX(id), 1) FROM job_applications));

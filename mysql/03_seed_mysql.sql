/* ============================================================
   INHYMA Website — MySQL Seed Data
   Converted from sql/03_seed.sql

   Run AFTER 02_procedures_mysql.sql

   Safe to re-run: every block skips rows that already exist.
   Products and Categories are NOT seeded here — import them with
   `npm run import:inhyma` (20 categories / 139 products), or
   migrate the rows from your existing SQL Server database.
   ============================================================ */

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

/* ---------------- Admin user ----------------
   Username: admin      Password: Admin@123
   CHANGE THIS PASSWORD IMMEDIATELY AFTER FIRST LOGIN
   (Admin panel -> My Account -> Change Password)
   The hash below is bcrypt cost 10 for the literal 'Admin@123'.
   ------------------------------------------------------------ */
INSERT IGNORE INTO `Users` (`Username`, `Email`, `PasswordHash`, `FullName`, `Role`, `IsActive`)
VALUES ('admin', 'admin@inhyma.com',
        '$2a$10$l8BF2a5On1Sqv2RUvPCJ3uQwRLVbCHTQoneADynsRfpuNbpR9Q.Ky',
        'Administrator', 'admin', 1);


/* ---------------- Industries ---------------- */
INSERT IGNORE INTO `Industries` (`Name`, `Slug`, `ShortDescription`, `Description`, `IconEmoji`, `DisplayOrder`)
VALUES
('Food Processing', 'food-processing',
 'Complete packaging lines for snacks, beverages, dairy, frozen foods, spices, and confectionery. Our food-grade equipment meets FDA and FSSAI standards.',
 'We provide turnkey food processing and packaging automation — from snack packaging to liquid filling, vacuum sealing and labeling.',
 '🍽️', 1);

INSERT IGNORE INTO `Industries` (`Name`, `Slug`, `ShortDescription`, `IconEmoji`, `DisplayOrder`)
VALUES
('Pharmaceutical', 'pharmaceutical', 'GMP-compliant packaging and filling systems for tablets, capsules, liquids, and syrups. Clean room compatible equipment with full traceability.', '💊', 2),
('Cosmetics & Personal Care', 'cosmetics', 'Precision filling and labeling for beauty products, skincare, hair care, and personal care items.', '💄', 3),
('FMCG', 'fmcg', 'High-speed packaging automation for fast-moving consumer goods. From sachets to bulk cartons.', '🛒', 4),
('Chemical', 'chemical', 'Corrosion-resistant filling and packaging equipment for chemical, petrochemical, and agrochemical products.', '🧪', 5),
('Logistics', 'logistics', 'Conveyor, sortation and material handling systems for warehouses and distribution centers.', '🚚', 6),
('Manufacturing', 'manufacturing', 'End-to-end factory automation and production line optimization for manufacturers.', '🏭', 7);

/* Specific tags for Food Processing */
INSERT INTO `IndustryTags` (`IndustryId`, `TagText`, `DisplayOrder`)
SELECT i.IndustryId, v.TagText, v.DisplayOrder
FROM `Industries` i
CROSS JOIN (
    SELECT 'Snack Packaging' AS TagText, 1 AS DisplayOrder
    UNION ALL SELECT 'Liquid Filling',  2
    UNION ALL SELECT 'Vacuum Sealing',  3
    UNION ALL SELECT 'Labeling',        4
) v
WHERE i.Slug = 'food-processing'
  AND i.IndustryId NOT IN (SELECT * FROM (SELECT DISTINCT IndustryId FROM `IndustryTags`) t);

/* Generic tags for every industry that still has none */
INSERT INTO `IndustryTags` (`IndustryId`, `TagText`, `DisplayOrder`)
SELECT i.IndustryId, v.TagText, v.DisplayOrder
FROM `Industries` i
CROSS JOIN (
    SELECT 'Automation' AS TagText, 1 AS DisplayOrder
    UNION ALL SELECT 'Packaging',        2
    UNION ALL SELECT 'Custom Solutions', 3
) v
WHERE i.IndustryId NOT IN (SELECT * FROM (SELECT DISTINCT IndustryId FROM `IndustryTags`) t);


/* ---------------- Solutions ---------------- */
INSERT IGNORE INTO `Solutions` (`Title`, `Slug`, `Description`, `ImagePath`, `DisplayOrder`)
VALUES
('Factory Automation', 'factory-automation', 'Complete factory automation — PLC/SCADA integration, robotics, and end-to-end line control to maximize throughput.', '/uploads/solutions/factory_automation.jpg', 1),
('Packaging Automation', 'packaging-automation', 'Integrated packaging lines combining filling, sealing, labeling and cartoning for high-volume operations.', '/uploads/solutions/packaging_automation.jpg', 2),
('Warehouse Automation', 'warehouse-automation', 'Automated storage, retrieval, conveyors and sortation systems for modern warehouses.', '/uploads/solutions/warehouse_automation.jpg', 3),
('Material Handling Systems', 'material-handling-systems', 'Custom conveyors, stackers and handling equipment engineered for your material flow.', '/uploads/solutions/material_handling.jpg', 4),
('Production Line Optimization', 'production-line-optimization', 'Audit, redesign and optimize your production lines to cut waste and boost efficiency.', '/uploads/solutions/production_optimization.jpg', 5);


/* ---------------- Blog ---------------- */
INSERT IGNORE INTO `BlogPosts` (`Title`, `Slug`, `Tag`, `Excerpt`, `Body`, `IconEmoji`, `ReadTime`, `PublishedDate`)
VALUES
('Top 10 Packaging Automation Trends for 2025', 'top-10-packaging-automation-trends-2025', 'Packaging Trends', 'Discover the latest trends shaping the future of industrial packaging automation.', '<p>The packaging industry is evolving rapidly. Here are the top trends to watch in 2025.</p>', '📦', '5 min read', '2025-06-15'),
('How to Choose the Right Filling Machine for Your Business', 'how-to-choose-filling-machine', 'Buying Guide', 'A comprehensive guide covering liquid, paste, and powder filling machines.', '<p>Choosing the right filling machine depends on capacity, accuracy, and budget.</p>', '🤖', '8 min read', '2025-06-08'),
('ROI of Packaging Automation: What to Expect', 'roi-of-packaging-automation', 'Case Study', 'Real-world data on the return on investment after implementing automation.', '<p>Automation typically pays back within 12-24 months.</p>', '📊', '6 min read', '2025-05-28'),
('India''s Manufacturing Sector: Growth Outlook 2025-2030', 'india-manufacturing-growth-outlook', 'Industry News', 'Analysis of India''s manufacturing growth trajectory.', '<p>India''s manufacturing sector is poised for strong growth.</p>', '🏭', '7 min read', '2025-05-20'),
('5 Signs Your Factory Needs Automation', '5-signs-your-factory-needs-automation', 'Automation Insights', 'Key indicators that it''s time to invest in automation.', '<p>From quality issues to labor shortages, here are the signs.</p>', '⚡', '5 min read', '2025-05-12'),
('Conveyor Systems Buyer''s Guide', 'conveyor-systems-buyers-guide', 'Buying Guide', 'Everything you need to know about choosing the right conveyor system.', '<p>Types, selection criteria and maintenance for conveyor systems.</p>', '🔧', '10 min read', '2025-05-05');


/* ---------------- Team ---------------- */
INSERT INTO `TeamMembers` (`Name`, `Role`, `Initials`, `DisplayOrder`)
SELECT v.Name, v.Role, v.Initials, v.DisplayOrder
FROM (
    SELECT 'Founder' AS Name, 'Managing Director' AS Role, 'FK' AS Initials, 1 AS DisplayOrder
    UNION ALL SELECT 'Co-Founder', 'Operations Director', 'VK', 2
) v
WHERE v.Name NOT IN (SELECT * FROM (SELECT Name FROM `TeamMembers`) t);


/* ---------------- Core Values ---------------- */
INSERT INTO `CoreValues` (`Icon`, `Title`, `Body`, `DisplayOrder`)
SELECT v.Icon, v.Title, v.Body, v.DisplayOrder
FROM (
    SELECT '🤝' AS Icon, 'Trust' AS Title, 'Building lasting relationships through transparency and reliability.' AS Body, 1 AS DisplayOrder
    UNION ALL SELECT '⚡', 'Innovation',     'Constantly evolving with cutting-edge technology and solutions.', 2
    UNION ALL SELECT '🏆', 'Quality',        'Delivering only the highest quality equipment and service.', 3
    UNION ALL SELECT '🎯', 'Customer First', 'Every decision is guided by what''s best for our customers.', 4
    UNION ALL SELECT '🔧', 'Support',        'Comprehensive after-sales support that goes above and beyond.', 5
    UNION ALL SELECT '🌱', 'Growth',         'Enabling our clients'' business growth with scalable solutions.', 6
) v
WHERE v.Title NOT IN (SELECT * FROM (SELECT Title FROM `CoreValues`) t);


/* ---------------- Stats ---------------- */
INSERT INTO `Stats` (`Label`, `Value`, `Suffix`, `DisplayOrder`)
SELECT v.Label, v.Value, v.Suffix, v.DisplayOrder
FROM (
    SELECT 'Happy Clients' AS Label, 500 AS Value, '+' AS Suffix, 1 AS DisplayOrder
    UNION ALL SELECT 'Machines Installed', 5000, '+', 2
    UNION ALL SELECT 'Cities Served',        20, '+', 3
    UNION ALL SELECT 'Retention Rate',       95, '%', 4
) v
WHERE v.Label NOT IN (SELECT * FROM (SELECT Label FROM `Stats`) t);


/* ---------------- Testimonials ---------------- */
INSERT INTO `Testimonials` (`AuthorName`, `AuthorRole`, `Initials`, `Rating`, `Content`, `DisplayOrder`)
SELECT v.AuthorName, v.AuthorRole, v.Initials, v.Rating, v.Content, v.DisplayOrder
FROM (
    SELECT 'Rajesh Mehta' AS AuthorName, 'Director, Pioneer Foods' AS AuthorRole, 'RM' AS Initials, 5 AS Rating,
           'Inhyma''s automatic packing machines have doubled our production efficiency. Outstanding service and support!' AS Content, 1 AS DisplayOrder
    UNION ALL SELECT 'Dr. Amit Shah', 'Operations Head, BioPharma India', 'AS', 5,
           'Highly reliable GMP-compliant filling systems. Their team''s technical expertise and post-sales support are top-notch.', 2
    UNION ALL SELECT 'Sarah Jenkins', 'Logistics Manager, Apex Logistics', 'SJ', 5,
           'The custom conveyor sortation system provided by Inhyma streamlined our warehouse operations completely. Highly recommended!', 3
) v
WHERE v.AuthorName NOT IN (SELECT * FROM (SELECT AuthorName FROM `Testimonials`) t);


/* ---------------- Site Settings ----------------
   Without these the header, footer and hero render empty.
   ------------------------------------------------------------ */
INSERT IGNORE INTO `SiteSettings` (`SettingKey`, `SettingValue`, `SettingGroup`, `Label`)
VALUES
('company_name',     'INHYMA Solutions LLP',                                                              'general', 'Company Name'),
('tagline',          'Your Industrial Hyper Market',                                                      'general', 'Tagline'),
('phone',            '+91 83558 96311',                                                                   'contact', 'Phone'),
('email',            'inhymasolutionsdm@gmail.com',                                                       'contact', 'Email'),
('whatsapp',         '918355896311',                                                                      'contact', 'WhatsApp Number'),
('address',          'Office No.42, Lodha Supremus, Wagle Estate, Thane West - 400064',                    'contact', 'Address'),
('social_linkedin',  '#',                                                                                 'social',  'LinkedIn URL'),
('social_instagram', '#',                                                                                 'social',  'Instagram URL'),
('social_youtube',   '#',                                                                                 'social',  'YouTube URL'),
('social_facebook',  '#',                                                                                 'social',  'Facebook URL'),
('social_twitter',   '#',                                                                                 'social',  'Twitter / X URL'),
('hero_title',       'India''s Industrial Hyper Market',                                                  'hero',    'Hero Title'),
('hero_subtitle',    'Innovative packaging machinery, material handling equipment, and automation systems that drive business growth.', 'hero', 'Hero Subtitle'),
('footer_about',     'INHYMA Solutions LLP is India''s leading industrial hyper market providing innovative packaging machinery, material handling equipment, and automation systems to businesses across multiple industries.', 'footer', 'Footer About Text');


SELECT 'INHYMA MySQL seed data loaded.' AS Status;

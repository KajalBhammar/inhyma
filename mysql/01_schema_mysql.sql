/* ============================================================
   INHYMA Website — MySQL Schema
   Converted from SQL Server (InhymaDB / defaultdb.sql)

   Target: MySQL 8.0.13+  or  MariaDB 10.2+
   Engine: InnoDB   Charset: utf8mb4 (required — emoji columns)

   Run FIRST, then 02_procedures_mysql.sql, then 03_seed_mysql.sql

   Type mapping used throughout:
     INT IDENTITY(1,1) -> INT AUTO_INCREMENT
     NVARCHAR(n)       -> VARCHAR(n)        (utf8mb4)
     NVARCHAR(MAX)     -> LONGTEXT
     BIT               -> TINYINT(1)
     DATETIME2(7)      -> DATETIME(6)
     SYSUTCDATETIME()  -> UTC_TIMESTAMP(6)
   ============================================================ */

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

/* Align the database's own default collation with the tables below.
   Some hosts (Aiven, MySQL 8.0.1+) default to utf8mb4_0900_ai_ci. Stored
   procedure parameters inherit the database/connection collation, so a
   mismatch makes "WHERE Username = p_Login" fail with
   ERROR 1267 Illegal mix of collations. Omitting the database name
   applies this to whichever database you are connected to. */
ALTER DATABASE CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 0;

/* ------------------------------------------------------------
   Admin Users (authentication)
   ------------------------------------------------------------ */
DROP TABLE IF EXISTS `Users`;
CREATE TABLE `Users` (
  `UserId`       INT           NOT NULL AUTO_INCREMENT,
  `Username`     VARCHAR(60)   NOT NULL,
  `Email`        VARCHAR(160)  NOT NULL,
  `PasswordHash` VARCHAR(255)  NOT NULL,
  `FullName`     VARCHAR(120)  NULL,
  `Role`         VARCHAR(30)   NOT NULL DEFAULT 'admin',
  `IsActive`     TINYINT(1)    NOT NULL DEFAULT 1,
  `LastLoginAt`  DATETIME(6)   NULL,
  `CreatedAt`    DATETIME(6)   NOT NULL DEFAULT (UTC_TIMESTAMP(6)),
  PRIMARY KEY (`UserId`),
  UNIQUE KEY `UQ_Users_Username` (`Username`),
  UNIQUE KEY `UQ_Users_Email` (`Email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ------------------------------------------------------------
   Product Categories
   ------------------------------------------------------------ */
DROP TABLE IF EXISTS `Categories`;
CREATE TABLE `Categories` (
  `CategoryId`   INT           NOT NULL AUTO_INCREMENT,
  `Name`         VARCHAR(120)  NOT NULL,
  `Slug`         VARCHAR(140)  NOT NULL,
  `Description`  VARCHAR(500)  NULL,
  `ImagePath`    VARCHAR(400)  NULL,
  `DisplayOrder` INT           NOT NULL DEFAULT 0,
  `IsActive`     TINYINT(1)    NOT NULL DEFAULT 1,
  `ShowOnHome`   TINYINT(1)    NOT NULL DEFAULT 1,
  `CreatedAt`    DATETIME(6)   NOT NULL DEFAULT (UTC_TIMESTAMP(6)),
  `UpdatedAt`    DATETIME(6)   NULL,
  PRIMARY KEY (`CategoryId`),
  UNIQUE KEY `UQ_Categories_Slug` (`Slug`),
  KEY `IX_Categories_Order` (`DisplayOrder`, `Name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ------------------------------------------------------------
   Product Subcategories
   ------------------------------------------------------------ */
DROP TABLE IF EXISTS `Subcategories`;
CREATE TABLE `Subcategories` (
  `SubcategoryId` INT          NOT NULL AUTO_INCREMENT,
  `CategoryId`    INT          NOT NULL,
  `Name`          VARCHAR(120) NOT NULL,
  `Slug`          VARCHAR(140) NOT NULL,
  `Description`   VARCHAR(500) NULL,
  `ImagePath`     VARCHAR(400) NULL,
  `DisplayOrder`  INT          NOT NULL DEFAULT 0,
  `IsActive`      TINYINT(1)   NOT NULL DEFAULT 1,
  `CreatedAt`     DATETIME(6)  NOT NULL DEFAULT (UTC_TIMESTAMP(6)),
  `UpdatedAt`     DATETIME(6)  NULL,
  PRIMARY KEY (`SubcategoryId`),
  UNIQUE KEY `UQ_Subcategories_Category_Slug` (`CategoryId`, `Slug`),
  KEY `IX_Subcategories_Order` (`DisplayOrder`, `Name`),
  CONSTRAINT `FK_Subcategories_Categories` FOREIGN KEY (`CategoryId`)
    REFERENCES `Categories` (`CategoryId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ------------------------------------------------------------
   Products
   ------------------------------------------------------------ */
DROP TABLE IF EXISTS `Products`;
CREATE TABLE `Products` (
  `ProductId`        INT           NOT NULL AUTO_INCREMENT,
  `CategoryId`       INT           NULL,
  `SubcategoryId`    INT           NULL,
  `Name`             VARCHAR(200)  NOT NULL,
  `Slug`             VARCHAR(220)  NOT NULL,
  `CategoryLabel`    VARCHAR(120)  NULL,
  `ShortDescription` VARCHAR(600)  NULL,
  `Description`      LONGTEXT      NULL,
  `Badge`            VARCHAR(60)   NULL,
  `IsFeatured`       TINYINT(1)    NOT NULL DEFAULT 0,
  `IsActive`         TINYINT(1)    NOT NULL DEFAULT 1,
  `DisplayOrder`     INT           NOT NULL DEFAULT 0,
  `CreatedAt`        DATETIME(6)   NOT NULL DEFAULT (UTC_TIMESTAMP(6)),
  `UpdatedAt`        DATETIME(6)   NULL,
  PRIMARY KEY (`ProductId`),
  UNIQUE KEY `UQ_Products_Slug` (`Slug`),
  KEY `IX_Products_Category` (`CategoryId`),
  KEY `IX_Products_Subcategory` (`SubcategoryId`),
  KEY `IX_Products_Listing` (`IsActive`, `DisplayOrder`, `Name`),
  KEY `IX_Products_Featured` (`IsFeatured`),
  CONSTRAINT `FK_Products_Categories` FOREIGN KEY (`CategoryId`)
    REFERENCES `Categories` (`CategoryId`) ON DELETE SET NULL,
  CONSTRAINT `FK_Products_Subcategories` FOREIGN KEY (`SubcategoryId`)
    REFERENCES `Subcategories` (`SubcategoryId`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* Product feature chips (e.g. "60 PPM", "SS 304") */
DROP TABLE IF EXISTS `ProductFeatures`;
CREATE TABLE `ProductFeatures` (
  `FeatureId`    INT          NOT NULL AUTO_INCREMENT,
  `ProductId`    INT          NOT NULL,
  `FeatureText`  VARCHAR(160) NOT NULL,
  `DisplayOrder` INT          NOT NULL DEFAULT 0,
  PRIMARY KEY (`FeatureId`),
  KEY `IX_ProductFeatures_Product` (`ProductId`, `DisplayOrder`),
  CONSTRAINT `FK_ProductFeatures_Products` FOREIGN KEY (`ProductId`)
    REFERENCES `Products` (`ProductId`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* Product spec table rows (Name / Value pairs) */
DROP TABLE IF EXISTS `ProductSpecs`;
CREATE TABLE `ProductSpecs` (
  `SpecId`       INT          NOT NULL AUTO_INCREMENT,
  `ProductId`    INT          NOT NULL,
  `SpecName`     VARCHAR(160) NOT NULL,
  `SpecValue`    VARCHAR(400) NOT NULL,
  `DisplayOrder` INT          NOT NULL DEFAULT 0,
  PRIMARY KEY (`SpecId`),
  KEY `IX_ProductSpecs_Product` (`ProductId`, `DisplayOrder`),
  CONSTRAINT `FK_ProductSpecs_Products` FOREIGN KEY (`ProductId`)
    REFERENCES `Products` (`ProductId`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* Product application chips (e.g. "Snacks", "Spices") */
DROP TABLE IF EXISTS `ProductApplications`;
CREATE TABLE `ProductApplications` (
  `AppId`        INT          NOT NULL AUTO_INCREMENT,
  `ProductId`    INT          NOT NULL,
  `AppText`      VARCHAR(160) NOT NULL,
  `DisplayOrder` INT          NOT NULL DEFAULT 0,
  PRIMARY KEY (`AppId`),
  KEY `IX_ProductApplications_Product` (`ProductId`, `DisplayOrder`),
  CONSTRAINT `FK_ProductApplications_Products` FOREIGN KEY (`ProductId`)
    REFERENCES `Products` (`ProductId`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* Product images (files on disk, path stored here) */
DROP TABLE IF EXISTS `ProductImages`;
CREATE TABLE `ProductImages` (
  `ImageId`      INT          NOT NULL AUTO_INCREMENT,
  `ProductId`    INT          NOT NULL,
  `FilePath`     VARCHAR(400) NOT NULL,
  `FileName`     VARCHAR(260) NULL,
  `AltText`      VARCHAR(200) NULL,
  `IsPrimary`    TINYINT(1)   NOT NULL DEFAULT 0,
  `DisplayOrder` INT          NOT NULL DEFAULT 0,
  `CreatedAt`    DATETIME(6)  NOT NULL DEFAULT (UTC_TIMESTAMP(6)),
  PRIMARY KEY (`ImageId`),
  KEY `IX_ProductImages_Product` (`ProductId`, `IsPrimary`, `DisplayOrder`),
  CONSTRAINT `FK_ProductImages_Products` FOREIGN KEY (`ProductId`)
    REFERENCES `Products` (`ProductId`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ------------------------------------------------------------
   Industries
   ------------------------------------------------------------ */
DROP TABLE IF EXISTS `Industries`;
CREATE TABLE `Industries` (
  `IndustryId`       INT          NOT NULL AUTO_INCREMENT,
  `Name`             VARCHAR(160) NOT NULL,
  `Slug`             VARCHAR(180) NOT NULL,
  `ShortDescription` VARCHAR(800) NULL,
  `Description`      LONGTEXT     NULL,
  `IconEmoji`        VARCHAR(20)  NULL,
  `ImagePath`        VARCHAR(400) NULL,
  `DisplayOrder`     INT          NOT NULL DEFAULT 0,
  `IsActive`         TINYINT(1)   NOT NULL DEFAULT 1,
  `CreatedAt`        DATETIME(6)  NOT NULL DEFAULT (UTC_TIMESTAMP(6)),
  `UpdatedAt`        DATETIME(6)  NULL,
  PRIMARY KEY (`IndustryId`),
  UNIQUE KEY `UQ_Industries_Slug` (`Slug`),
  KEY `IX_Industries_Order` (`DisplayOrder`, `Name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `IndustryTags`;
CREATE TABLE `IndustryTags` (
  `TagId`        INT          NOT NULL AUTO_INCREMENT,
  `IndustryId`   INT          NOT NULL,
  `TagText`      VARCHAR(160) NOT NULL,
  `DisplayOrder` INT          NOT NULL DEFAULT 0,
  PRIMARY KEY (`TagId`),
  KEY `IX_IndustryTags_Industry` (`IndustryId`, `DisplayOrder`),
  CONSTRAINT `FK_IndustryTags_Industries` FOREIGN KEY (`IndustryId`)
    REFERENCES `Industries` (`IndustryId`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ------------------------------------------------------------
   Solutions
   ------------------------------------------------------------ */
DROP TABLE IF EXISTS `Solutions`;
CREATE TABLE `Solutions` (
  `SolutionId`   INT          NOT NULL AUTO_INCREMENT,
  `Title`        VARCHAR(200) NOT NULL,
  `Slug`         VARCHAR(220) NOT NULL,
  `Description`  LONGTEXT     NULL,
  `ImagePath`    VARCHAR(400) NULL,
  `DisplayOrder` INT          NOT NULL DEFAULT 0,
  `IsActive`     TINYINT(1)   NOT NULL DEFAULT 1,
  `CreatedAt`    DATETIME(6)  NOT NULL DEFAULT (UTC_TIMESTAMP(6)),
  `UpdatedAt`    DATETIME(6)  NULL,
  PRIMARY KEY (`SolutionId`),
  UNIQUE KEY `UQ_Solutions_Slug` (`Slug`),
  KEY `IX_Solutions_Order` (`DisplayOrder`, `Title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `SolutionFeatures`;
CREATE TABLE `SolutionFeatures` (
  `FeatureId`    INT          NOT NULL AUTO_INCREMENT,
  `SolutionId`   INT          NOT NULL,
  `FeatureText`  VARCHAR(300) NOT NULL,
  `DisplayOrder` INT          NOT NULL DEFAULT 0,
  PRIMARY KEY (`FeatureId`),
  KEY `IX_SolutionFeatures_Solution` (`SolutionId`, `DisplayOrder`),
  CONSTRAINT `FK_SolutionFeatures_Solutions` FOREIGN KEY (`SolutionId`)
    REFERENCES `Solutions` (`SolutionId`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ------------------------------------------------------------
   Blog / Knowledge Center
   ------------------------------------------------------------ */
DROP TABLE IF EXISTS `BlogPosts`;
CREATE TABLE `BlogPosts` (
  `PostId`        INT          NOT NULL AUTO_INCREMENT,
  `Title`         VARCHAR(250) NOT NULL,
  `Slug`          VARCHAR(270) NOT NULL,
  `Tag`           VARCHAR(80)  NULL,
  `Excerpt`       VARCHAR(800) NULL,
  `Body`          LONGTEXT     NULL,
  `ImagePath`     VARCHAR(400) NULL,
  `IconEmoji`     VARCHAR(20)  NULL,
  `ReadTime`      VARCHAR(40)  NULL,
  `Author`        VARCHAR(120) NULL,
  `PublishedDate` DATE         NULL,
  `IsPublished`   TINYINT(1)   NOT NULL DEFAULT 1,
  `CreatedAt`     DATETIME(6)  NOT NULL DEFAULT (UTC_TIMESTAMP(6)),
  `UpdatedAt`     DATETIME(6)  NULL,
  PRIMARY KEY (`PostId`),
  UNIQUE KEY `UQ_BlogPosts_Slug` (`Slug`),
  KEY `IX_BlogPosts_Published` (`IsPublished`, `PublishedDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ------------------------------------------------------------
   About page content: Team / Values / Stats
   ------------------------------------------------------------ */
DROP TABLE IF EXISTS `TeamMembers`;
CREATE TABLE `TeamMembers` (
  `MemberId`     INT          NOT NULL AUTO_INCREMENT,
  `Name`         VARCHAR(120) NOT NULL,
  `Role`         VARCHAR(120) NULL,
  `Initials`     VARCHAR(8)   NULL,
  `ImagePath`    VARCHAR(400) NULL,
  `DisplayOrder` INT          NOT NULL DEFAULT 0,
  `IsActive`     TINYINT(1)   NOT NULL DEFAULT 1,
  PRIMARY KEY (`MemberId`),
  KEY `IX_TeamMembers_Order` (`DisplayOrder`, `MemberId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `CoreValues`;
CREATE TABLE `CoreValues` (
  `ValueId`      INT          NOT NULL AUTO_INCREMENT,
  `Icon`         VARCHAR(20)  NULL,
  `Title`        VARCHAR(120) NOT NULL,
  `Body`         VARCHAR(500) NULL,
  `DisplayOrder` INT          NOT NULL DEFAULT 0,
  `IsActive`     TINYINT(1)   NOT NULL DEFAULT 1,
  PRIMARY KEY (`ValueId`),
  KEY `IX_CoreValues_Order` (`DisplayOrder`, `ValueId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `Stats`;
CREATE TABLE `Stats` (
  `StatId`       INT          NOT NULL AUTO_INCREMENT,
  `Label`        VARCHAR(120) NOT NULL,
  `Value`        INT          NOT NULL DEFAULT 0,
  `Suffix`       VARCHAR(10)  NULL,
  `DisplayOrder` INT          NOT NULL DEFAULT 0,
  `IsActive`     TINYINT(1)   NOT NULL DEFAULT 1,
  PRIMARY KEY (`StatId`),
  KEY `IX_Stats_Order` (`DisplayOrder`, `StatId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ------------------------------------------------------------
   Leads (contact form + quote form + industry consultation)
   ------------------------------------------------------------ */
DROP TABLE IF EXISTS `Leads`;
CREATE TABLE `Leads` (
  `LeadId`             INT          NOT NULL AUTO_INCREMENT,
  `Name`               VARCHAR(160) NOT NULL,
  `Company`            VARCHAR(200) NULL,
  `Mobile`             VARCHAR(40)  NULL,
  `Email`              VARCHAR(160) NULL,
  `Industry`           VARCHAR(120) NULL,
  `ProductRequirement` VARCHAR(200) NULL,
  `Quantity`           VARCHAR(80)  NULL,
  `Budget`             VARCHAR(80)  NULL,
  `Subject`            VARCHAR(200) NULL,
  `Message`            LONGTEXT     NULL,
  `Source`             VARCHAR(40)  NOT NULL DEFAULT 'contact',
  `Status`             VARCHAR(40)  NOT NULL DEFAULT 'new',
  `CreatedAt`          DATETIME(6)  NOT NULL DEFAULT (UTC_TIMESTAMP(6)),
  PRIMARY KEY (`LeadId`),
  KEY `IX_Leads_Status` (`Status`),
  KEY `IX_Leads_Created` (`CreatedAt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ------------------------------------------------------------
   CallLogs (CRM interactions, notes and next reminders)
   ------------------------------------------------------------ */
DROP TABLE IF EXISTS `CallLogs`;
CREATE TABLE `CallLogs` (
  `CallLogId`        INT         NOT NULL AUTO_INCREMENT,
  `LeadId`           INT         NOT NULL,
  `Notes`            LONGTEXT    NOT NULL,
  `NextReminderDate` DATETIME(6) NULL,
  `CreatedAt`        DATETIME(6) NOT NULL DEFAULT (UTC_TIMESTAMP(6)),
  PRIMARY KEY (`CallLogId`),
  KEY `IX_CallLogs_Lead` (`LeadId`, `NextReminderDate`),
  CONSTRAINT `FK_CallLogs_Leads` FOREIGN KEY (`LeadId`)
    REFERENCES `Leads` (`LeadId`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ------------------------------------------------------------
   Testimonials (client reviews)
   ------------------------------------------------------------ */
DROP TABLE IF EXISTS `Testimonials`;
CREATE TABLE `Testimonials` (
  `TestimonialId` INT          NOT NULL AUTO_INCREMENT,
  `AuthorName`    VARCHAR(120) NOT NULL,
  `AuthorRole`    VARCHAR(120) NULL,
  `Initials`      VARCHAR(8)   NULL,
  `Rating`        INT          NOT NULL DEFAULT 5,
  `Content`       LONGTEXT     NOT NULL,
  `DisplayOrder`  INT          NOT NULL DEFAULT 0,
  `IsActive`      TINYINT(1)   NOT NULL DEFAULT 1,
  `CreatedAt`     DATETIME(6)  NOT NULL DEFAULT (UTC_TIMESTAMP(6)),
  PRIMARY KEY (`TestimonialId`),
  KEY `IX_Testimonials_Order` (`DisplayOrder`, `TestimonialId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ------------------------------------------------------------
   ClientLogos (trusted partners)
   ------------------------------------------------------------ */
DROP TABLE IF EXISTS `ClientLogos`;
CREATE TABLE `ClientLogos` (
  `LogoId`       INT          NOT NULL AUTO_INCREMENT,
  `Name`         VARCHAR(100) NOT NULL,
  `ImagePath`    VARCHAR(255) NOT NULL,
  `DisplayOrder` INT          NOT NULL DEFAULT 0,
  `IsActive`     TINYINT(1)   NOT NULL DEFAULT 1,
  `CreatedAt`    DATETIME(6)  NOT NULL DEFAULT (UTC_TIMESTAMP(6)),
  PRIMARY KEY (`LogoId`),
  KEY `IX_ClientLogos_Order` (`DisplayOrder`, `Name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ------------------------------------------------------------
   Site Settings (key/value CMS: contact info, hero text, social)
   ------------------------------------------------------------ */
DROP TABLE IF EXISTS `SiteSettings`;
CREATE TABLE `SiteSettings` (
  `SettingId`    INT          NOT NULL AUTO_INCREMENT,
  `SettingKey`   VARCHAR(120) NOT NULL,
  `SettingValue` LONGTEXT     NULL,
  `SettingGroup` VARCHAR(60)  NULL,
  `Label`        VARCHAR(160) NULL,
  `UpdatedAt`    DATETIME(6)  NULL,
  PRIMARY KEY (`SettingId`),
  UNIQUE KEY `UQ_SiteSettings_Key` (`SettingKey`),
  KEY `IX_SiteSettings_Group` (`SettingGroup`, `SettingKey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

SELECT 'INHYMA MySQL schema ready.' AS Status;

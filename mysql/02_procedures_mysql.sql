/* ============================================================
   INHYMA Website — MySQL Stored Procedures
   Converted from SQL Server (defaultdb.sql)

   Run AFTER 01_schema_mysql.sql

   IMPORTANT — differences from the SQL Server originals:

   1. Parameters are prefixed  p_  (e.g. @Name -> p_Name).
      MySQL resolves an unprefixed parameter that shares a column's
      name in favour of the parameter, which silently breaks
      "WHERE Name = Name". The prefix is mandatory, not cosmetic.

   2. MySQL parameters CANNOT have default values. Every CALL must
      pass every parameter positionally. Each procedure re-applies
      the SQL Server defaults itself via IFNULL(...) at the top, so
      passing NULL behaves exactly like omitting the argument did.

   3. GET_BY_SLUG no longer calls the procedure recursively (MySQL
      forbids that unless max_sp_recursion_depth is raised). It
      resolves the slug to an id and falls through to GET_BY_ID.

   Translation map:
     SCOPE_IDENTITY()   -> LAST_INSERT_ID()
     SYSUTCDATETIME()   -> UTC_TIMESTAMP(6)
     SELECT TOP (n)     -> LIMIT n
     '%' + @S + '%'     -> CONCAT('%', p_S, '%')
     NEWID()            -> RAND()
     THROW              -> SIGNAL SQLSTATE '45000'
     #TempTable         -> CREATE TEMPORARY TABLE
   ============================================================ */

/* Procedure parameters inherit the collation that is active when the
   procedure is CREATED. Pin it to match the tables, otherwise on servers
   whose default is utf8mb4_0900_ai_ci (Aiven, MySQL 8.0.1+) every
   "WHERE column = p_param" comparison fails at runtime with
   ERROR 1267 Illegal mix of collations. */
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

DELIMITER $$

/* ============================================================
   USERS
   ============================================================ */
DROP PROCEDURE IF EXISTS `usp_User_Manage`$$
CREATE PROCEDURE `usp_User_Manage`(
    IN p_Action       VARCHAR(30),
    IN p_UserId       INT,
    IN p_Login        VARCHAR(160),
    IN p_Username     VARCHAR(60),
    IN p_Email        VARCHAR(160),
    IN p_PasswordHash VARCHAR(255),
    IN p_FullName     VARCHAR(120),
    IN p_Role         VARCHAR(30)
)
BEGIN
    SET p_Role = IFNULL(p_Role, 'admin');

    IF p_Action = 'GET_BY_LOGIN' THEN
        SELECT UserId, Username, Email, PasswordHash, FullName, Role, IsActive, LastLoginAt, CreatedAt
        FROM Users
        WHERE (Username = p_Login OR Email = p_Login)
        LIMIT 1;

    ELSEIF p_Action = 'GET_BY_ID' THEN
        SELECT UserId, Username, Email, PasswordHash, FullName, Role, IsActive, LastLoginAt, CreatedAt
        FROM Users WHERE UserId = p_UserId;

    ELSEIF p_Action = 'CREATE' THEN
        INSERT INTO Users (Username, Email, PasswordHash, FullName, Role)
        VALUES (p_Username, p_Email, p_PasswordHash, p_FullName, p_Role);
        SELECT LAST_INSERT_ID() AS UserId;

    ELSEIF p_Action = 'COUNT' THEN
        SELECT COUNT(*) AS Cnt FROM Users;

    ELSEIF p_Action = 'UPDATE_LAST_LOGIN' THEN
        UPDATE Users SET LastLoginAt = UTC_TIMESTAMP(6) WHERE UserId = p_UserId;

    ELSEIF p_Action = 'UPDATE_PASSWORD' THEN
        UPDATE Users SET PasswordHash = p_PasswordHash WHERE UserId = p_UserId;
    END IF;
END$$


/* ============================================================
   CATEGORIES
   ============================================================ */
DROP PROCEDURE IF EXISTS `usp_Category_Manage`$$
CREATE PROCEDURE `usp_Category_Manage`(
    IN p_Action          VARCHAR(20),
    IN p_CategoryId      INT,
    IN p_Name            VARCHAR(120),
    IN p_Slug            VARCHAR(140),
    IN p_Description     VARCHAR(500),
    IN p_ImagePath       VARCHAR(400),
    IN p_DisplayOrder    INT,
    IN p_IsActive        TINYINT,
    IN p_ShowOnHome      TINYINT,
    IN p_IncludeInactive TINYINT
)
BEGIN
    SET p_DisplayOrder    = IFNULL(p_DisplayOrder, 0);
    SET p_IsActive        = IFNULL(p_IsActive, 1);
    SET p_ShowOnHome      = IFNULL(p_ShowOnHome, 1);
    SET p_IncludeInactive = IFNULL(p_IncludeInactive, 1);

    IF p_Action = 'GET_ALL' THEN
        SELECT c.CategoryId, c.Name, c.Slug, c.Description,
               COALESCE(c.ImagePath, (
                   SELECT pi.FilePath
                   FROM Products p
                   JOIN ProductImages pi ON pi.ProductId = p.ProductId
                   WHERE p.CategoryId = c.CategoryId AND p.IsActive = 1
                   ORDER BY p.IsFeatured DESC, p.DisplayOrder, pi.IsPrimary DESC, pi.DisplayOrder
                   LIMIT 1
               )) AS ImagePath,
               c.DisplayOrder, c.IsActive, c.ShowOnHome,
               (SELECT COUNT(*) FROM Subcategories s
                 WHERE s.CategoryId = c.CategoryId
                   AND (p_IncludeInactive = 1 OR s.IsActive = 1)) AS SubcategoryCount,
               (SELECT COUNT(*) FROM Products p
                 WHERE p.CategoryId = c.CategoryId
                   AND (p_IncludeInactive = 1 OR p.IsActive = 1)) AS ProductCount
        FROM Categories c
        WHERE (p_IncludeInactive = 1 OR c.IsActive = 1)
        ORDER BY c.DisplayOrder, c.Name;

    ELSEIF p_Action = 'GET_BY_ID' THEN
        SELECT c.CategoryId, c.Name, c.Slug, c.Description,
               COALESCE(c.ImagePath, (
                   SELECT pi.FilePath
                   FROM Products p
                   JOIN ProductImages pi ON pi.ProductId = p.ProductId
                   WHERE p.CategoryId = c.CategoryId AND p.IsActive = 1
                   ORDER BY p.IsFeatured DESC, p.DisplayOrder, pi.IsPrimary DESC, pi.DisplayOrder
                   LIMIT 1
               )) AS ImagePath,
               c.DisplayOrder, c.IsActive, c.ShowOnHome
        FROM Categories c WHERE c.CategoryId = p_CategoryId;

    ELSEIF p_Action = 'CREATE' THEN
        INSERT INTO Categories (Name, Slug, Description, ImagePath, DisplayOrder, IsActive, ShowOnHome)
        VALUES (p_Name, p_Slug, p_Description, p_ImagePath, p_DisplayOrder, p_IsActive, p_ShowOnHome);
        SELECT LAST_INSERT_ID() AS CategoryId;

    ELSEIF p_Action = 'UPDATE' THEN
        UPDATE Categories
        SET Name         = p_Name,
            Slug         = p_Slug,
            Description  = p_Description,
            ImagePath    = COALESCE(p_ImagePath, ImagePath),
            DisplayOrder = p_DisplayOrder,
            IsActive     = p_IsActive,
            ShowOnHome   = p_ShowOnHome,
            UpdatedAt    = UTC_TIMESTAMP(6)
        WHERE CategoryId = p_CategoryId;

    ELSEIF p_Action = 'DELETE' THEN
        UPDATE Products SET SubcategoryId = NULL WHERE CategoryId = p_CategoryId;
        DELETE FROM Subcategories WHERE CategoryId = p_CategoryId;
        DELETE FROM Categories WHERE CategoryId = p_CategoryId;
    END IF;
END$$


/* ============================================================
   SUBCATEGORIES
   ============================================================ */
DROP PROCEDURE IF EXISTS `usp_Subcategory_Manage`$$
CREATE PROCEDURE `usp_Subcategory_Manage`(
    IN p_Action          VARCHAR(20),
    IN p_SubcategoryId   INT,
    IN p_CategoryId      INT,
    IN p_CategorySlug    VARCHAR(140),
    IN p_Name            VARCHAR(120),
    IN p_Slug            VARCHAR(140),
    IN p_Description     VARCHAR(500),
    IN p_ImagePath       VARCHAR(400),
    IN p_DisplayOrder    INT,
    IN p_IsActive        TINYINT,
    IN p_IncludeInactive TINYINT
)
BEGIN
    SET p_DisplayOrder    = IFNULL(p_DisplayOrder, 0);
    SET p_IsActive        = IFNULL(p_IsActive, 1);
    SET p_IncludeInactive = IFNULL(p_IncludeInactive, 1);

    IF p_Action = 'GET_ALL' THEN
        SELECT s.SubcategoryId, s.CategoryId, s.Name, s.Slug, s.Description,
               COALESCE(s.ImagePath, (
                   SELECT pi.FilePath
                   FROM Products p
                   JOIN ProductImages pi ON pi.ProductId = p.ProductId
                   WHERE p.SubcategoryId = s.SubcategoryId AND p.IsActive = 1
                   ORDER BY p.IsFeatured DESC, p.DisplayOrder, pi.IsPrimary DESC, pi.DisplayOrder
                   LIMIT 1
               )) AS ImagePath,
               s.DisplayOrder, s.IsActive,
               c.Name AS CategoryName, c.Slug AS CategorySlug,
               (SELECT COUNT(*) FROM Products p WHERE p.SubcategoryId = s.SubcategoryId) AS ProductCount
        FROM Subcategories s
        JOIN Categories c ON c.CategoryId = s.CategoryId
        WHERE (p_IncludeInactive = 1 OR (s.IsActive = 1 AND c.IsActive = 1))
          AND (p_CategoryId IS NULL OR s.CategoryId = p_CategoryId)
          AND (p_CategorySlug IS NULL OR c.Slug = p_CategorySlug)
        ORDER BY c.DisplayOrder, c.Name, s.DisplayOrder, s.Name;

    ELSEIF p_Action = 'GET_BY_ID' THEN
        SELECT s.SubcategoryId, s.CategoryId, s.Name, s.Slug, s.Description,
               s.ImagePath, s.DisplayOrder, s.IsActive,
               c.Name AS CategoryName, c.Slug AS CategorySlug
        FROM Subcategories s
        JOIN Categories c ON c.CategoryId = s.CategoryId
        WHERE s.SubcategoryId = p_SubcategoryId;

    ELSEIF p_Action = 'CREATE' THEN
        INSERT INTO Subcategories (CategoryId, Name, Slug, Description, ImagePath, DisplayOrder, IsActive)
        VALUES (p_CategoryId, p_Name, p_Slug, p_Description, p_ImagePath, p_DisplayOrder, p_IsActive);
        SELECT LAST_INSERT_ID() AS SubcategoryId;

    ELSEIF p_Action = 'UPDATE' THEN
        UPDATE Subcategories
        SET CategoryId   = p_CategoryId,
            Name         = p_Name,
            Slug         = p_Slug,
            Description  = p_Description,
            ImagePath    = COALESCE(p_ImagePath, ImagePath),
            DisplayOrder = p_DisplayOrder,
            IsActive     = p_IsActive,
            UpdatedAt    = UTC_TIMESTAMP(6)
        WHERE SubcategoryId = p_SubcategoryId;

        /* Keep child products aligned with the subcategory's parent category */
        UPDATE Products
        SET CategoryId = p_CategoryId, UpdatedAt = UTC_TIMESTAMP(6)
        WHERE SubcategoryId = p_SubcategoryId;

    ELSEIF p_Action = 'DELETE' THEN
        IF EXISTS (SELECT 1 FROM Products WHERE SubcategoryId = p_SubcategoryId) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Move or delete the products in this subcategory before deleting it.';
        END IF;

        DELETE FROM Subcategories WHERE SubcategoryId = p_SubcategoryId;
    END IF;
END$$


/* ============================================================
   PRODUCTS
   ============================================================ */
DROP PROCEDURE IF EXISTS `usp_Product_Manage`$$
CREATE PROCEDURE `usp_Product_Manage`(
    IN p_Action           VARCHAR(30),
    IN p_ProductId        INT,
    IN p_CategoryId       INT,
    IN p_SubcategoryId    INT,
    IN p_Name             VARCHAR(200),
    IN p_Slug             VARCHAR(220),
    IN p_CategoryLabel    VARCHAR(120),
    IN p_ShortDescription VARCHAR(600),
    IN p_Description      LONGTEXT,
    IN p_Badge            VARCHAR(60),
    IN p_IsFeatured       TINYINT,
    IN p_IsActive         TINYINT,
    IN p_DisplayOrder     INT,
    IN p_CategorySlug     VARCHAR(140),
    IN p_SubcategorySlug  VARCHAR(140),
    IN p_Search           VARCHAR(200),
    IN p_IncludeInactive  TINYINT,
    IN p_FeaturedOnly     TINYINT,
    IN p_Top              INT,
    IN p_FeatureText      VARCHAR(160),
    IN p_SpecName         VARCHAR(160),
    IN p_SpecValue        VARCHAR(400),
    IN p_AppText          VARCHAR(160),
    IN p_ImageId          INT,
    IN p_FilePath         VARCHAR(400),
    IN p_FileName         VARCHAR(260),
    IN p_AltText          VARCHAR(200),
    IN p_IsPrimary        TINYINT
)
BEGIN
    DECLARE v_EffectiveCategoryId    INT DEFAULT NULL;
    DECLARE v_EffectiveSubcategoryId INT DEFAULT NULL;
    DECLARE v_Top                    INT DEFAULT 100000;
    DECLARE v_RelCategoryId          INT DEFAULT NULL;
    DECLARE v_RelSubcategoryId       INT DEFAULT NULL;
    DECLARE v_ImgProductId           INT DEFAULT NULL;

    SET p_DisplayOrder    = IFNULL(p_DisplayOrder, 0);
    SET p_IncludeInactive = IFNULL(p_IncludeInactive, 0);
    SET p_FeaturedOnly    = IFNULL(p_FeaturedOnly, 0);
    SET p_IsPrimary       = IFNULL(p_IsPrimary, 0);

    SET v_EffectiveCategoryId    = p_CategoryId;
    SET v_EffectiveSubcategoryId = p_SubcategoryId;

    /* GET_BY_SLUG resolves to an id, then runs the GET_BY_ID branch.
       (SQL Server called the procedure recursively; MySQL forbids that.) */
    IF p_Action = 'GET_BY_SLUG' THEN
        SELECT ProductId INTO p_ProductId FROM Products WHERE Slug = p_Slug LIMIT 1;
        SET p_Action = 'GET_BY_ID';
    END IF;

    /* Every product must end up in a subcategory. If only a category was
       given, fall back to that category's "General Products" bucket,
       creating it on first use. */
    IF p_Action IN ('CREATE', 'UPDATE') THEN
        IF v_EffectiveSubcategoryId IS NOT NULL THEN
            SELECT CategoryId INTO v_EffectiveCategoryId
            FROM Subcategories
            WHERE SubcategoryId = v_EffectiveSubcategoryId
            LIMIT 1;

        ELSEIF v_EffectiveCategoryId IS NOT NULL THEN
            SELECT SubcategoryId INTO v_EffectiveSubcategoryId
            FROM Subcategories
            WHERE CategoryId = v_EffectiveCategoryId AND Slug = 'general-products'
            LIMIT 1;

            IF v_EffectiveSubcategoryId IS NULL THEN
                INSERT INTO Subcategories
                    (CategoryId, Name, Slug, Description, DisplayOrder, IsActive)
                VALUES
                    (v_EffectiveCategoryId, 'General Products', 'general-products',
                     'Products awaiting assignment to a specific subcategory.', 9999, 1);
                SET v_EffectiveSubcategoryId = LAST_INSERT_ID();
            END IF;
        END IF;
    END IF;

    IF p_Action = 'GET_ALL' THEN
        SET v_Top = IFNULL(p_Top, 100000);

        SELECT p.ProductId, p.Name, p.Slug, p.CategoryLabel, p.ShortDescription, p.Badge,
               p.IsFeatured, p.IsActive, p.DisplayOrder, p.CategoryId, p.SubcategoryId,
               c.Name AS CategoryName, c.Slug AS CategorySlug,
               s.Name AS SubcategoryName, s.Slug AS SubcategorySlug,
               (SELECT pi.FilePath FROM ProductImages pi
                 WHERE pi.ProductId = p.ProductId
                 ORDER BY pi.IsPrimary DESC, pi.DisplayOrder, pi.ImageId
                 LIMIT 1) AS PrimaryImage
        FROM Products p
        LEFT JOIN Categories c    ON c.CategoryId    = p.CategoryId
        LEFT JOIN Subcategories s ON s.SubcategoryId = p.SubcategoryId
        WHERE (p_IncludeInactive = 1 OR p.IsActive = 1)
          AND (p_FeaturedOnly = 0 OR p.IsFeatured = 1)
          AND (p_CategorySlug IS NULL OR c.Slug = p_CategorySlug)
          AND (p_SubcategorySlug IS NULL OR s.Slug = p_SubcategorySlug)
          AND (p_Search IS NULL
               OR p.Name             LIKE CONCAT('%', p_Search, '%')
               OR p.ShortDescription LIKE CONCAT('%', p_Search, '%')
               OR p.CategoryLabel    LIKE CONCAT('%', p_Search, '%')
               OR c.Name             LIKE CONCAT('%', p_Search, '%')
               OR s.Name             LIKE CONCAT('%', p_Search, '%'))
        ORDER BY p.DisplayOrder, p.Name
        LIMIT v_Top;

    ELSEIF p_Action = 'GET_EXPORT' THEN
        DROP TEMPORARY TABLE IF EXISTS ExportProducts;
        CREATE TEMPORARY TABLE ExportProducts (ProductId INT NOT NULL PRIMARY KEY);

        INSERT INTO ExportProducts (ProductId)
        SELECT p.ProductId
        FROM Products p
        LEFT JOIN Categories c    ON c.CategoryId    = p.CategoryId
        LEFT JOIN Subcategories s ON s.SubcategoryId = p.SubcategoryId
        WHERE (p_IncludeInactive = 1 OR p.IsActive = 1)
          AND (p_CategorySlug IS NULL OR c.Slug = p_CategorySlug)
          AND (p_SubcategorySlug IS NULL OR s.Slug = p_SubcategorySlug)
          AND (p_Search IS NULL
               OR p.Name             LIKE CONCAT('%', p_Search, '%')
               OR p.ShortDescription LIKE CONCAT('%', p_Search, '%')
               OR p.CategoryLabel    LIKE CONCAT('%', p_Search, '%')
               OR c.Name             LIKE CONCAT('%', p_Search, '%')
               OR s.Name             LIKE CONCAT('%', p_Search, '%'));

        /* recordset 1 — products */
        SELECT p.ProductId, p.Name,
               c.Name AS CategoryName,
               s.Name AS SubcategoryName,
               p.DisplayOrder
        FROM ExportProducts ep
        JOIN Products p           ON p.ProductId     = ep.ProductId
        LEFT JOIN Categories c    ON c.CategoryId    = p.CategoryId
        LEFT JOIN Subcategories s ON s.SubcategoryId = p.SubcategoryId
        ORDER BY p.DisplayOrder, p.Name;

        /* recordset 2 — features */
        SELECT pf.ProductId, pf.FeatureText, pf.DisplayOrder
        FROM ProductFeatures pf
        JOIN ExportProducts ep ON ep.ProductId = pf.ProductId
        JOIN Products p        ON p.ProductId  = pf.ProductId
        ORDER BY p.DisplayOrder, p.Name, pf.DisplayOrder, pf.FeatureId;

        /* recordset 3 — specs */
        SELECT ps.ProductId, ps.SpecName, ps.SpecValue, ps.DisplayOrder
        FROM ProductSpecs ps
        JOIN ExportProducts ep ON ep.ProductId = ps.ProductId
        JOIN Products p        ON p.ProductId  = ps.ProductId
        ORDER BY p.DisplayOrder, p.Name, ps.DisplayOrder, ps.SpecId;

        /* recordset 4 — applications */
        SELECT pa.ProductId, pa.AppText, pa.DisplayOrder
        FROM ProductApplications pa
        JOIN ExportProducts ep ON ep.ProductId = pa.ProductId
        JOIN Products p        ON p.ProductId  = pa.ProductId
        ORDER BY p.DisplayOrder, p.Name, pa.DisplayOrder, pa.AppId;

        DROP TEMPORARY TABLE IF EXISTS ExportProducts;

    ELSEIF p_Action = 'GET_BY_ID' THEN
        SELECT p.ProductId, p.CategoryId, p.SubcategoryId, p.Name, p.Slug, p.CategoryLabel,
               p.ShortDescription, p.Description, p.Badge, p.IsFeatured, p.IsActive, p.DisplayOrder,
               c.Name AS CategoryName, c.Slug AS CategorySlug,
               s.Name AS SubcategoryName, s.Slug AS SubcategorySlug
        FROM Products p
        LEFT JOIN Categories c    ON c.CategoryId    = p.CategoryId
        LEFT JOIN Subcategories s ON s.SubcategoryId = p.SubcategoryId
        WHERE p.ProductId = p_ProductId;

        SELECT FeatureId, FeatureText, DisplayOrder FROM ProductFeatures
        WHERE ProductId = p_ProductId ORDER BY DisplayOrder, FeatureId;

        SELECT SpecId, SpecName, SpecValue, DisplayOrder FROM ProductSpecs
        WHERE ProductId = p_ProductId ORDER BY DisplayOrder, SpecId;

        SELECT AppId, AppText, DisplayOrder FROM ProductApplications
        WHERE ProductId = p_ProductId ORDER BY DisplayOrder, AppId;

        SELECT ImageId, FilePath, FileName, AltText, IsPrimary, DisplayOrder FROM ProductImages
        WHERE ProductId = p_ProductId ORDER BY IsPrimary DESC, DisplayOrder, ImageId;

    ELSEIF p_Action = 'GET_RELATED' THEN
        SET v_Top = IFNULL(p_Top, 3);

        SELECT CategoryId, SubcategoryId
          INTO v_RelCategoryId, v_RelSubcategoryId
        FROM Products WHERE ProductId = p_ProductId LIMIT 1;

        SELECT p.ProductId, p.Name, p.Slug, p.CategoryLabel, p.Badge,
               c.Name AS CategoryName, s.Name AS SubcategoryName,
               (SELECT pi.FilePath FROM ProductImages pi
                 WHERE pi.ProductId = p.ProductId
                 ORDER BY pi.IsPrimary DESC, pi.DisplayOrder
                 LIMIT 1) AS PrimaryImage
        FROM Products p
        LEFT JOIN Categories c    ON c.CategoryId    = p.CategoryId
        LEFT JOIN Subcategories s ON s.SubcategoryId = p.SubcategoryId
        WHERE p.IsActive = 1 AND p.ProductId <> p_ProductId
          AND ((v_RelSubcategoryId IS NOT NULL AND p.SubcategoryId = v_RelSubcategoryId)
               OR (v_RelSubcategoryId IS NULL
                   AND (v_RelCategoryId IS NULL OR p.CategoryId = v_RelCategoryId)))
        ORDER BY p.DisplayOrder, RAND()
        LIMIT v_Top;

    ELSEIF p_Action = 'CREATE' THEN
        INSERT INTO Products (CategoryId, SubcategoryId, Name, Slug, CategoryLabel,
                              ShortDescription, Description, Badge, IsFeatured, IsActive, DisplayOrder)
        VALUES (v_EffectiveCategoryId, v_EffectiveSubcategoryId, p_Name, p_Slug, p_CategoryLabel,
                p_ShortDescription, p_Description, p_Badge,
                COALESCE(p_IsFeatured, 0), COALESCE(p_IsActive, 1), p_DisplayOrder);
        SELECT LAST_INSERT_ID() AS ProductId;

    ELSEIF p_Action = 'UPDATE' THEN
        UPDATE Products
        SET CategoryId       = v_EffectiveCategoryId,
            SubcategoryId    = v_EffectiveSubcategoryId,
            Name             = p_Name,
            Slug             = p_Slug,
            CategoryLabel    = p_CategoryLabel,
            ShortDescription = p_ShortDescription,
            Description      = p_Description,
            Badge            = p_Badge,
            IsFeatured       = COALESCE(p_IsFeatured, IsFeatured),
            IsActive         = COALESCE(p_IsActive, IsActive),
            DisplayOrder     = p_DisplayOrder,
            UpdatedAt        = UTC_TIMESTAMP(6)
        WHERE ProductId = p_ProductId;

    ELSEIF p_Action = 'DELETE' THEN
        DELETE FROM Products WHERE ProductId = p_ProductId;

    /* ---------- child collections ---------- */
    ELSEIF p_Action = 'CREATE_FEATURE' THEN
        INSERT INTO ProductFeatures (ProductId, FeatureText, DisplayOrder)
        VALUES (p_ProductId, p_FeatureText, p_DisplayOrder);

    ELSEIF p_Action = 'DELETE_FEATURES' THEN
        DELETE FROM ProductFeatures WHERE ProductId = p_ProductId;

    ELSEIF p_Action = 'CREATE_SPEC' THEN
        INSERT INTO ProductSpecs (ProductId, SpecName, SpecValue, DisplayOrder)
        VALUES (p_ProductId, p_SpecName, p_SpecValue, p_DisplayOrder);

    ELSEIF p_Action = 'DELETE_SPECS' THEN
        DELETE FROM ProductSpecs WHERE ProductId = p_ProductId;

    ELSEIF p_Action = 'CREATE_APP' THEN
        INSERT INTO ProductApplications (ProductId, AppText, DisplayOrder)
        VALUES (p_ProductId, p_AppText, p_DisplayOrder);

    ELSEIF p_Action = 'DELETE_APPS' THEN
        DELETE FROM ProductApplications WHERE ProductId = p_ProductId;

    /* ---------- images ---------- */
    ELSEIF p_Action = 'CREATE_IMAGE' THEN
        IF p_IsPrimary = 1 THEN
            UPDATE ProductImages SET IsPrimary = 0 WHERE ProductId = p_ProductId;
        END IF;
        INSERT INTO ProductImages (ProductId, FilePath, FileName, AltText, IsPrimary, DisplayOrder)
        VALUES (p_ProductId, p_FilePath, p_FileName, p_AltText, p_IsPrimary, p_DisplayOrder);
        SELECT LAST_INSERT_ID() AS ImageId;

    ELSEIF p_Action = 'GET_IMAGES' THEN
        SELECT ImageId, ProductId, FilePath, FileName, AltText, IsPrimary, DisplayOrder
        FROM ProductImages WHERE ProductId = p_ProductId
        ORDER BY IsPrimary DESC, DisplayOrder, ImageId;

    ELSEIF p_Action = 'GET_IMAGE_BY_ID' THEN
        SELECT ImageId, ProductId, FilePath, FileName, AltText, IsPrimary, DisplayOrder
        FROM ProductImages WHERE ImageId = p_ImageId;

    ELSEIF p_Action = 'DELETE_IMAGE' THEN
        DELETE FROM ProductImages WHERE ImageId = p_ImageId;

    ELSEIF p_Action = 'SET_PRIMARY_IMAGE' THEN
        SELECT ProductId INTO v_ImgProductId FROM ProductImages WHERE ImageId = p_ImageId LIMIT 1;
        UPDATE ProductImages SET IsPrimary = 0 WHERE ProductId = v_ImgProductId;
        UPDATE ProductImages SET IsPrimary = 1 WHERE ImageId = p_ImageId;
    END IF;
END$$


/* ============================================================
   INDUSTRIES
   ============================================================ */
DROP PROCEDURE IF EXISTS `usp_Industry_Manage`$$
CREATE PROCEDURE `usp_Industry_Manage`(
    IN p_Action           VARCHAR(20),
    IN p_IndustryId       INT,
    IN p_Name             VARCHAR(160),
    IN p_Slug             VARCHAR(180),
    IN p_ShortDescription VARCHAR(800),
    IN p_Description      LONGTEXT,
    IN p_IconEmoji        VARCHAR(20),
    IN p_ImagePath        VARCHAR(400),
    IN p_DisplayOrder     INT,
    IN p_IsActive         TINYINT,
    IN p_IncludeInactive  TINYINT,
    IN p_TagText          VARCHAR(160)
)
BEGIN
    SET p_DisplayOrder    = IFNULL(p_DisplayOrder, 0);
    SET p_IsActive        = IFNULL(p_IsActive, 1);
    SET p_IncludeInactive = IFNULL(p_IncludeInactive, 0);

    IF p_Action = 'GET_BY_SLUG' THEN
        SELECT IndustryId INTO p_IndustryId FROM Industries WHERE Slug = p_Slug LIMIT 1;
        SET p_Action = 'GET_BY_ID';
    END IF;

    IF p_Action = 'GET_ALL' THEN
        SELECT IndustryId, Name, Slug, ShortDescription, IconEmoji, ImagePath, DisplayOrder, IsActive
        FROM Industries
        WHERE (p_IncludeInactive = 1 OR IsActive = 1)
        ORDER BY DisplayOrder, Name;

    ELSEIF p_Action = 'GET_BY_ID' THEN
        SELECT IndustryId, Name, Slug, ShortDescription, Description, IconEmoji, ImagePath, DisplayOrder, IsActive
        FROM Industries WHERE IndustryId = p_IndustryId;

        SELECT TagId, TagText, DisplayOrder FROM IndustryTags
        WHERE IndustryId = p_IndustryId ORDER BY DisplayOrder, TagId;

    ELSEIF p_Action = 'CREATE' THEN
        INSERT INTO Industries (Name, Slug, ShortDescription, Description, IconEmoji, ImagePath, DisplayOrder, IsActive)
        VALUES (p_Name, p_Slug, p_ShortDescription, p_Description, p_IconEmoji, p_ImagePath, p_DisplayOrder, p_IsActive);
        SELECT LAST_INSERT_ID() AS IndustryId;

    ELSEIF p_Action = 'UPDATE' THEN
        UPDATE Industries
        SET Name             = p_Name,
            Slug             = p_Slug,
            ShortDescription = p_ShortDescription,
            Description      = p_Description,
            IconEmoji        = p_IconEmoji,
            ImagePath        = COALESCE(p_ImagePath, ImagePath),
            DisplayOrder     = p_DisplayOrder,
            IsActive         = p_IsActive,
            UpdatedAt        = UTC_TIMESTAMP(6)
        WHERE IndustryId = p_IndustryId;

    ELSEIF p_Action = 'DELETE' THEN
        DELETE FROM Industries WHERE IndustryId = p_IndustryId;

    ELSEIF p_Action = 'CREATE_TAG' THEN
        INSERT INTO IndustryTags (IndustryId, TagText, DisplayOrder)
        VALUES (p_IndustryId, p_TagText, p_DisplayOrder);

    ELSEIF p_Action = 'DELETE_TAGS' THEN
        DELETE FROM IndustryTags WHERE IndustryId = p_IndustryId;
    END IF;
END$$


/* ============================================================
   SOLUTIONS
   ============================================================ */
DROP PROCEDURE IF EXISTS `usp_Solution_Manage`$$
CREATE PROCEDURE `usp_Solution_Manage`(
    IN p_Action          VARCHAR(20),
    IN p_SolutionId      INT,
    IN p_Title           VARCHAR(200),
    IN p_Slug            VARCHAR(220),
    IN p_Description     LONGTEXT,
    IN p_ImagePath       VARCHAR(400),
    IN p_DisplayOrder    INT,
    IN p_IsActive        TINYINT,
    IN p_IncludeInactive TINYINT,
    IN p_FeatureText     VARCHAR(300)
)
BEGIN
    SET p_DisplayOrder    = IFNULL(p_DisplayOrder, 0);
    SET p_IsActive        = IFNULL(p_IsActive, 1);
    SET p_IncludeInactive = IFNULL(p_IncludeInactive, 0);

    IF p_Action = 'GET_ALL' THEN
        SELECT SolutionId, Title, Slug, Description, ImagePath, DisplayOrder, IsActive
        FROM Solutions
        WHERE (p_IncludeInactive = 1 OR IsActive = 1)
        ORDER BY DisplayOrder, Title;

        SELECT FeatureId, SolutionId, FeatureText, DisplayOrder
        FROM SolutionFeatures
        ORDER BY SolutionId, DisplayOrder, FeatureId;

    ELSEIF p_Action = 'GET_BY_ID' THEN
        SELECT SolutionId, Title, Slug, Description, ImagePath, DisplayOrder, IsActive
        FROM Solutions WHERE SolutionId = p_SolutionId;

        SELECT FeatureId, FeatureText, DisplayOrder FROM SolutionFeatures
        WHERE SolutionId = p_SolutionId ORDER BY DisplayOrder, FeatureId;

    ELSEIF p_Action = 'CREATE' THEN
        INSERT INTO Solutions (Title, Slug, Description, ImagePath, DisplayOrder, IsActive)
        VALUES (p_Title, p_Slug, p_Description, p_ImagePath, p_DisplayOrder, p_IsActive);
        SELECT LAST_INSERT_ID() AS SolutionId;

    ELSEIF p_Action = 'UPDATE' THEN
        UPDATE Solutions
        SET Title        = p_Title,
            Slug         = p_Slug,
            Description  = p_Description,
            ImagePath    = COALESCE(p_ImagePath, ImagePath),
            DisplayOrder = p_DisplayOrder,
            IsActive     = p_IsActive,
            UpdatedAt    = UTC_TIMESTAMP(6)
        WHERE SolutionId = p_SolutionId;

    ELSEIF p_Action = 'DELETE' THEN
        DELETE FROM Solutions WHERE SolutionId = p_SolutionId;

    ELSEIF p_Action = 'CREATE_FEATURE' THEN
        INSERT INTO SolutionFeatures (SolutionId, FeatureText, DisplayOrder)
        VALUES (p_SolutionId, p_FeatureText, p_DisplayOrder);

    ELSEIF p_Action = 'DELETE_FEATURES' THEN
        DELETE FROM SolutionFeatures WHERE SolutionId = p_SolutionId;
    END IF;
END$$


/* ============================================================
   BLOG
   ============================================================ */
DROP PROCEDURE IF EXISTS `usp_Blog_Manage`$$
CREATE PROCEDURE `usp_Blog_Manage`(
    IN p_Action             VARCHAR(20),
    IN p_PostId             INT,
    IN p_Title              VARCHAR(250),
    IN p_Slug               VARCHAR(270),
    IN p_Tag                VARCHAR(80),
    IN p_Excerpt            VARCHAR(800),
    IN p_Body               LONGTEXT,
    IN p_ImagePath          VARCHAR(400),
    IN p_IconEmoji          VARCHAR(20),
    IN p_ReadTime           VARCHAR(40),
    IN p_Author             VARCHAR(120),
    IN p_PublishedDate      DATE,
    IN p_IsPublished        TINYINT,
    IN p_IncludeUnpublished TINYINT,
    IN p_Top                INT
)
BEGIN
    DECLARE v_Top INT DEFAULT 100000;

    SET p_IncludeUnpublished = IFNULL(p_IncludeUnpublished, 0);

    IF p_Action = 'GET_ALL' THEN
        SET v_Top = IFNULL(p_Top, 100000);
        SELECT PostId, Title, Slug, Tag, Excerpt, ImagePath, IconEmoji, ReadTime, Author, PublishedDate, IsPublished
        FROM BlogPosts
        WHERE (p_IncludeUnpublished = 1 OR IsPublished = 1)
        ORDER BY PublishedDate DESC, PostId DESC
        LIMIT v_Top;

    ELSEIF p_Action = 'GET_BY_ID' THEN
        SELECT PostId, Title, Slug, Tag, Excerpt, Body, ImagePath, IconEmoji, ReadTime, Author, PublishedDate, IsPublished
        FROM BlogPosts WHERE PostId = p_PostId;

    ELSEIF p_Action = 'GET_BY_SLUG' THEN
        SELECT PostId, Title, Slug, Tag, Excerpt, Body, ImagePath, IconEmoji, ReadTime, Author, PublishedDate, IsPublished
        FROM BlogPosts WHERE Slug = p_Slug;

    ELSEIF p_Action = 'GET_RELATED' THEN
        SET v_Top = IFNULL(p_Top, 3);
        SELECT PostId, Title, Slug, Tag, IconEmoji, ImagePath, ReadTime, PublishedDate
        FROM BlogPosts
        WHERE IsPublished = 1 AND PostId <> p_PostId
        ORDER BY PublishedDate DESC, PostId DESC
        LIMIT v_Top;

    ELSEIF p_Action = 'CREATE' THEN
        INSERT INTO BlogPosts (Title, Slug, Tag, Excerpt, Body, ImagePath, IconEmoji, ReadTime, Author, PublishedDate, IsPublished)
        VALUES (p_Title, p_Slug, p_Tag, p_Excerpt, p_Body, p_ImagePath, p_IconEmoji, p_ReadTime, p_Author,
                p_PublishedDate, COALESCE(p_IsPublished, 1));
        SELECT LAST_INSERT_ID() AS PostId;

    ELSEIF p_Action = 'UPDATE' THEN
        UPDATE BlogPosts
        SET Title         = p_Title,
            Slug          = p_Slug,
            Tag           = p_Tag,
            Excerpt       = p_Excerpt,
            Body          = p_Body,
            ImagePath     = COALESCE(p_ImagePath, ImagePath),
            IconEmoji     = p_IconEmoji,
            ReadTime      = p_ReadTime,
            Author        = p_Author,
            PublishedDate = p_PublishedDate,
            IsPublished   = p_IsPublished,
            UpdatedAt     = UTC_TIMESTAMP(6)
        WHERE PostId = p_PostId;

    ELSEIF p_Action = 'DELETE' THEN
        DELETE FROM BlogPosts WHERE PostId = p_PostId;
    END IF;
END$$


/* ============================================================
   TEAM MEMBERS
   ============================================================ */
DROP PROCEDURE IF EXISTS `usp_Team_Manage`$$
CREATE PROCEDURE `usp_Team_Manage`(
    IN p_Action          VARCHAR(20),
    IN p_MemberId        INT,
    IN p_Name            VARCHAR(120),
    IN p_Role            VARCHAR(120),
    IN p_Initials        VARCHAR(8),
    IN p_ImagePath       VARCHAR(400),
    IN p_DisplayOrder    INT,
    IN p_IsActive        TINYINT,
    IN p_IncludeInactive TINYINT
)
BEGIN
    SET p_DisplayOrder    = IFNULL(p_DisplayOrder, 0);
    SET p_IsActive        = IFNULL(p_IsActive, 1);
    SET p_IncludeInactive = IFNULL(p_IncludeInactive, 0);

    IF p_Action = 'GET_ALL' THEN
        SELECT MemberId, Name, Role, Initials, ImagePath, DisplayOrder, IsActive
        FROM TeamMembers
        WHERE (p_IncludeInactive = 1 OR IsActive = 1)
        ORDER BY DisplayOrder, MemberId;

    ELSEIF p_Action = 'GET_BY_ID' THEN
        SELECT MemberId, Name, Role, Initials, ImagePath, DisplayOrder, IsActive
        FROM TeamMembers WHERE MemberId = p_MemberId;

    ELSEIF p_Action = 'CREATE' THEN
        INSERT INTO TeamMembers (Name, Role, Initials, ImagePath, DisplayOrder, IsActive)
        VALUES (p_Name, p_Role, p_Initials, p_ImagePath, p_DisplayOrder, p_IsActive);
        SELECT LAST_INSERT_ID() AS MemberId;

    ELSEIF p_Action = 'UPDATE' THEN
        UPDATE TeamMembers
        SET Name         = p_Name,
            Role         = p_Role,
            Initials     = p_Initials,
            ImagePath    = COALESCE(p_ImagePath, ImagePath),
            DisplayOrder = p_DisplayOrder,
            IsActive     = p_IsActive
        WHERE MemberId = p_MemberId;

    ELSEIF p_Action = 'DELETE' THEN
        DELETE FROM TeamMembers WHERE MemberId = p_MemberId;
    END IF;
END$$


/* ============================================================
   CORE VALUES
   ============================================================ */
DROP PROCEDURE IF EXISTS `usp_Value_Manage`$$
CREATE PROCEDURE `usp_Value_Manage`(
    IN p_Action          VARCHAR(20),
    IN p_ValueId         INT,
    IN p_Icon            VARCHAR(20),
    IN p_Title           VARCHAR(120),
    IN p_Body            VARCHAR(500),
    IN p_DisplayOrder    INT,
    IN p_IsActive        TINYINT,
    IN p_IncludeInactive TINYINT
)
BEGIN
    SET p_DisplayOrder    = IFNULL(p_DisplayOrder, 0);
    SET p_IsActive        = IFNULL(p_IsActive, 1);
    SET p_IncludeInactive = IFNULL(p_IncludeInactive, 0);

    IF p_Action = 'GET_ALL' THEN
        SELECT ValueId, Icon, Title, Body, DisplayOrder, IsActive
        FROM CoreValues
        WHERE (p_IncludeInactive = 1 OR IsActive = 1)
        ORDER BY DisplayOrder, ValueId;

    ELSEIF p_Action = 'GET_BY_ID' THEN
        SELECT ValueId, Icon, Title, Body, DisplayOrder, IsActive
        FROM CoreValues WHERE ValueId = p_ValueId;

    ELSEIF p_Action = 'CREATE' THEN
        INSERT INTO CoreValues (Icon, Title, Body, DisplayOrder, IsActive)
        VALUES (p_Icon, p_Title, p_Body, p_DisplayOrder, p_IsActive);
        SELECT LAST_INSERT_ID() AS ValueId;

    ELSEIF p_Action = 'UPDATE' THEN
        UPDATE CoreValues
        SET Icon         = p_Icon,
            Title        = p_Title,
            Body         = p_Body,
            DisplayOrder = p_DisplayOrder,
            IsActive     = p_IsActive
        WHERE ValueId = p_ValueId;

    ELSEIF p_Action = 'DELETE' THEN
        DELETE FROM CoreValues WHERE ValueId = p_ValueId;
    END IF;
END$$


/* ============================================================
   STATS
   ============================================================ */
DROP PROCEDURE IF EXISTS `usp_Stat_Manage`$$
CREATE PROCEDURE `usp_Stat_Manage`(
    IN p_Action          VARCHAR(20),
    IN p_StatId          INT,
    IN p_Label           VARCHAR(120),
    IN p_Value           INT,
    IN p_Suffix          VARCHAR(10),
    IN p_DisplayOrder    INT,
    IN p_IsActive        TINYINT,
    IN p_IncludeInactive TINYINT
)
BEGIN
    SET p_Value           = IFNULL(p_Value, 0);
    SET p_DisplayOrder    = IFNULL(p_DisplayOrder, 0);
    SET p_IsActive        = IFNULL(p_IsActive, 1);
    SET p_IncludeInactive = IFNULL(p_IncludeInactive, 0);

    IF p_Action = 'GET_ALL' THEN
        SELECT StatId, Label, Value, Suffix, DisplayOrder, IsActive
        FROM Stats
        WHERE (p_IncludeInactive = 1 OR IsActive = 1)
        ORDER BY DisplayOrder, StatId;

    ELSEIF p_Action = 'GET_BY_ID' THEN
        SELECT StatId, Label, Value, Suffix, DisplayOrder, IsActive
        FROM Stats WHERE StatId = p_StatId;

    ELSEIF p_Action = 'CREATE' THEN
        INSERT INTO Stats (Label, Value, Suffix, DisplayOrder, IsActive)
        VALUES (p_Label, p_Value, p_Suffix, p_DisplayOrder, p_IsActive);
        SELECT LAST_INSERT_ID() AS StatId;

    ELSEIF p_Action = 'UPDATE' THEN
        UPDATE Stats
        SET Label        = p_Label,
            Value        = p_Value,
            Suffix       = p_Suffix,
            DisplayOrder = p_DisplayOrder,
            IsActive     = p_IsActive
        WHERE StatId = p_StatId;

    ELSEIF p_Action = 'DELETE' THEN
        DELETE FROM Stats WHERE StatId = p_StatId;
    END IF;
END$$


/* ============================================================
   LEADS
   ============================================================ */
DROP PROCEDURE IF EXISTS `usp_Lead_Manage`$$
CREATE PROCEDURE `usp_Lead_Manage`(
    IN p_Action             VARCHAR(20),
    IN p_LeadId             INT,
    IN p_Name               VARCHAR(160),
    IN p_Company            VARCHAR(200),
    IN p_Mobile             VARCHAR(40),
    IN p_Email              VARCHAR(160),
    IN p_Industry           VARCHAR(120),
    IN p_ProductRequirement VARCHAR(200),
    IN p_Quantity           VARCHAR(80),
    IN p_Budget             VARCHAR(80),
    IN p_Subject            VARCHAR(200),
    IN p_Message            LONGTEXT,
    IN p_Source             VARCHAR(40),
    IN p_Status             VARCHAR(40),
    IN p_Notes              LONGTEXT,
    IN p_NextReminderDate   DATETIME(6)
)
BEGIN
    SET p_Source = IFNULL(p_Source, 'contact');

    IF p_Action = 'CREATE' THEN
        INSERT INTO Leads (Name, Company, Mobile, Email, Industry, ProductRequirement,
                           Quantity, Budget, Subject, Message, Source)
        VALUES (p_Name, p_Company, p_Mobile, p_Email, p_Industry, p_ProductRequirement,
                p_Quantity, p_Budget, p_Subject, p_Message, p_Source);
        SELECT LAST_INSERT_ID() AS LeadId;

    ELSEIF p_Action = 'GET_ALL' THEN
        SELECT L.LeadId, L.Name, L.Company, L.Mobile, L.Email, L.Industry, L.ProductRequirement,
               L.Quantity, L.Budget, L.Subject, L.Message, L.Source, L.Status, L.CreatedAt,
               (SELECT cl.NextReminderDate
                  FROM CallLogs cl
                 WHERE cl.LeadId = L.LeadId
                   AND cl.NextReminderDate IS NOT NULL
                   AND cl.NextReminderDate >= UTC_TIMESTAMP(6)
                 ORDER BY cl.NextReminderDate ASC
                 LIMIT 1) AS NextReminderDate
        FROM Leads L
        WHERE (p_Status IS NULL OR L.Status = p_Status)
        ORDER BY L.CreatedAt DESC;

    ELSEIF p_Action = 'GET_BY_ID' THEN
        SELECT L.LeadId, L.Name, L.Company, L.Mobile, L.Email, L.Industry, L.ProductRequirement,
               L.Quantity, L.Budget, L.Subject, L.Message, L.Source, L.Status, L.CreatedAt,
               (SELECT cl.NextReminderDate
                  FROM CallLogs cl
                 WHERE cl.LeadId = L.LeadId
                   AND cl.NextReminderDate IS NOT NULL
                   AND cl.NextReminderDate >= UTC_TIMESTAMP(6)
                 ORDER BY cl.NextReminderDate ASC
                 LIMIT 1) AS NextReminderDate
        FROM Leads L WHERE L.LeadId = p_LeadId;

    ELSEIF p_Action = 'UPDATE_STATUS' THEN
        UPDATE Leads SET Status = p_Status WHERE LeadId = p_LeadId;

    ELSEIF p_Action = 'DELETE' THEN
        DELETE FROM Leads WHERE LeadId = p_LeadId;

    ELSEIF p_Action = 'CREATE_CALL_LOG' THEN
        INSERT INTO CallLogs (LeadId, Notes, NextReminderDate)
        VALUES (p_LeadId, p_Notes, p_NextReminderDate);
        SELECT LAST_INSERT_ID() AS CallLogId;

    ELSEIF p_Action = 'GET_CALL_LOGS' THEN
        SELECT CallLogId, LeadId, Notes, NextReminderDate, CreatedAt
        FROM CallLogs
        WHERE LeadId = p_LeadId
        ORDER BY CreatedAt DESC;
    END IF;
END$$


/* ============================================================
   SITE SETTINGS
   ============================================================ */
DROP PROCEDURE IF EXISTS `usp_Setting_Manage`$$
CREATE PROCEDURE `usp_Setting_Manage`(
    IN p_Action       VARCHAR(20),
    IN p_SettingKey   VARCHAR(120),
    IN p_SettingValue LONGTEXT,
    IN p_SettingGroup VARCHAR(60),
    IN p_Label        VARCHAR(160)
)
BEGIN
    IF p_Action = 'GET_ALL' THEN
        SELECT SettingId, SettingKey, SettingValue, SettingGroup, Label, UpdatedAt
        FROM SiteSettings ORDER BY SettingGroup, SettingKey;

    ELSEIF p_Action = 'GET_BY_KEY' THEN
        SELECT SettingId, SettingKey, SettingValue, SettingGroup, Label
        FROM SiteSettings WHERE SettingKey = p_SettingKey;

    ELSEIF p_Action = 'UPSERT' THEN
        IF EXISTS (SELECT 1 FROM SiteSettings WHERE SettingKey = p_SettingKey) THEN
            UPDATE SiteSettings
            SET SettingValue = p_SettingValue,
                SettingGroup = COALESCE(p_SettingGroup, SettingGroup),
                Label        = COALESCE(p_Label, Label),
                UpdatedAt    = UTC_TIMESTAMP(6)
            WHERE SettingKey = p_SettingKey;
        ELSE
            INSERT INTO SiteSettings (SettingKey, SettingValue, SettingGroup, Label, UpdatedAt)
            VALUES (p_SettingKey, p_SettingValue, p_SettingGroup, p_Label, UTC_TIMESTAMP(6));
        END IF;
    END IF;
END$$


/* ============================================================
   TESTIMONIALS
   ============================================================ */
DROP PROCEDURE IF EXISTS `usp_Testimonial_Manage`$$
CREATE PROCEDURE `usp_Testimonial_Manage`(
    IN p_Action          VARCHAR(20),
    IN p_TestimonialId   INT,
    IN p_AuthorName      VARCHAR(120),
    IN p_AuthorRole      VARCHAR(120),
    IN p_Initials        VARCHAR(8),
    IN p_Rating          INT,
    IN p_Content         LONGTEXT,
    IN p_DisplayOrder    INT,
    IN p_IsActive        TINYINT,
    IN p_IncludeInactive TINYINT
)
BEGIN
    SET p_Rating          = IFNULL(p_Rating, 5);
    SET p_DisplayOrder    = IFNULL(p_DisplayOrder, 0);
    SET p_IsActive        = IFNULL(p_IsActive, 1);
    SET p_IncludeInactive = IFNULL(p_IncludeInactive, 0);

    IF p_Action = 'GET_ALL' THEN
        SELECT TestimonialId, AuthorName, AuthorRole, Initials, Rating, Content, DisplayOrder, IsActive, CreatedAt
        FROM Testimonials
        WHERE (p_IncludeInactive = 1 OR IsActive = 1)
        ORDER BY DisplayOrder, TestimonialId;

    ELSEIF p_Action = 'GET_BY_ID' THEN
        SELECT TestimonialId, AuthorName, AuthorRole, Initials, Rating, Content, DisplayOrder, IsActive, CreatedAt
        FROM Testimonials WHERE TestimonialId = p_TestimonialId;

    ELSEIF p_Action = 'CREATE' THEN
        INSERT INTO Testimonials (AuthorName, AuthorRole, Initials, Rating, Content, DisplayOrder, IsActive)
        VALUES (p_AuthorName, p_AuthorRole, p_Initials, p_Rating, p_Content, p_DisplayOrder, p_IsActive);
        SELECT LAST_INSERT_ID() AS TestimonialId;

    ELSEIF p_Action = 'UPDATE' THEN
        UPDATE Testimonials
        SET AuthorName   = p_AuthorName,
            AuthorRole   = p_AuthorRole,
            Initials     = p_Initials,
            Rating       = p_Rating,
            Content      = p_Content,
            DisplayOrder = p_DisplayOrder,
            IsActive     = p_IsActive
        WHERE TestimonialId = p_TestimonialId;

    ELSEIF p_Action = 'DELETE' THEN
        DELETE FROM Testimonials WHERE TestimonialId = p_TestimonialId;
    END IF;
END$$


/* ============================================================
   CLIENT LOGOS
   ============================================================ */
DROP PROCEDURE IF EXISTS `usp_ClientLogo_Manage`$$
CREATE PROCEDURE `usp_ClientLogo_Manage`(
    IN p_Action          VARCHAR(50),
    IN p_LogoId          INT,
    IN p_Name            VARCHAR(100),
    IN p_ImagePath       VARCHAR(255),
    IN p_DisplayOrder    INT,
    IN p_IsActive        TINYINT,
    IN p_IncludeInactive TINYINT
)
BEGIN
    SET p_DisplayOrder    = IFNULL(p_DisplayOrder, 0);
    SET p_IsActive        = IFNULL(p_IsActive, 1);
    SET p_IncludeInactive = IFNULL(p_IncludeInactive, 0);

    IF p_Action = 'GET_ALL' THEN
        SELECT LogoId, Name, ImagePath, DisplayOrder, IsActive, CreatedAt
        FROM ClientLogos
        WHERE (p_IncludeInactive = 1 OR IsActive = 1)
        ORDER BY DisplayOrder ASC, Name ASC;

    ELSEIF p_Action = 'GET_BY_ID' THEN
        SELECT LogoId, Name, ImagePath, DisplayOrder, IsActive, CreatedAt
        FROM ClientLogos WHERE LogoId = p_LogoId;

    ELSEIF p_Action = 'CREATE' THEN
        INSERT INTO ClientLogos (Name, ImagePath, DisplayOrder, IsActive)
        VALUES (p_Name, p_ImagePath, p_DisplayOrder, p_IsActive);
        SELECT LAST_INSERT_ID() AS LogoId;

    ELSEIF p_Action = 'UPDATE' THEN
        UPDATE ClientLogos
        SET Name         = IFNULL(p_Name, Name),
            ImagePath    = IFNULL(p_ImagePath, ImagePath),
            DisplayOrder = IFNULL(p_DisplayOrder, DisplayOrder),
            IsActive     = IFNULL(p_IsActive, IsActive)
        WHERE LogoId = p_LogoId;

    ELSEIF p_Action = 'DELETE' THEN
        DELETE FROM ClientLogos WHERE LogoId = p_LogoId;
    END IF;
END$$


/* ============================================================
   DASHBOARD
   ============================================================ */
DROP PROCEDURE IF EXISTS `usp_Dashboard_Counts`$$
CREATE PROCEDURE `usp_Dashboard_Counts`()
BEGIN
    SELECT
        (SELECT COUNT(*) FROM Products)                   AS Products,
        (SELECT COUNT(*) FROM Categories)                 AS Categories,
        (SELECT COUNT(*) FROM Industries)                 AS Industries,
        (SELECT COUNT(*) FROM Solutions)                  AS Solutions,
        (SELECT COUNT(*) FROM BlogPosts)                  AS BlogPosts,
        (SELECT COUNT(*) FROM Leads)                      AS Leads,
        (SELECT COUNT(*) FROM Leads WHERE Status = 'new') AS NewLeads,
        (SELECT COUNT(*) FROM Testimonials)               AS Testimonials;
END$$

DELIMITER ;

SELECT 'INHYMA MySQL stored procedures ready (15).' AS Status;

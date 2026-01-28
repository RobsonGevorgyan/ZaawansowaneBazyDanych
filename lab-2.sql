-- =============================================
-- Imię           : Robert
-- Nazwisko       : Gevorgyan
-- Numer indeksu  : 234272
-- =============================================

-- =============================================
-- Zadanie 1
-- =============================================
DECLARE @Litera CHAR(1) = 'R';
DECLARE @Cyfra INT = 2;
DECLARE @CustomerForLab1 INT;
DECLARE @CategoryForLab1 INT;

SELECT TOP (1) @CustomerForLab1 = CustomerID
FROM SalesLT.Customer
WHERE LastName LIKE @Litera + '%'
  AND CustomerID % 10 = @Cyfra
ORDER BY CustomerID;

IF @CustomerForLab1 IS NULL
BEGIN
    SET IDENTITY_INSERT SalesLT.Customer ON;

    ;WITH PasswordTemplate AS (
        SELECT TOP (1) PasswordHash, PasswordSalt
        FROM SalesLT.Customer
        ORDER BY CustomerID
    )
    INSERT INTO SalesLT.Customer (
        CustomerID,
        NameStyle,
        Title,
        FirstName,
        MiddleName,
        LastName,
        Suffix,
        CompanyName,
        SalesPerson,
        EmailAddress,
        Phone,
        PasswordHash,
        PasswordSalt,
        rowguid,
        ModifiedDate
    )
    SELECT
        99992,
        0,
        NULL,
        'Robert',
        NULL,
        'Rivers-Lab2',
        NULL,
        'Lab2 Corporation',
        'adventure-works\\rgear0',
        'robert.rivers.lab2@contoso.com',
        '555-0122',
        PasswordHash,
        PasswordSalt,
        NEWID(),
        SYSDATETIME()
    FROM PasswordTemplate;

    SET IDENTITY_INSERT SalesLT.Customer OFF;

    SET @CustomerForLab1 = 99992;
END;

IF NOT EXISTS (
    SELECT 1
    FROM SalesLT.CustomerAddress ca
    JOIN SalesLT.Address a ON a.AddressID = ca.AddressID
    WHERE ca.CustomerID = @CustomerForLab1
      AND a.City LIKE @Litera + '%'
)
BEGIN
    DECLARE @Lab2AddressID INT;

    INSERT INTO SalesLT.Address (
        AddressLine1,
        AddressLine2,
        City,
        StateProvince,
        CountryRegion,
        PostalCode,
        rowguid,
        ModifiedDate
    )
    VALUES (
        '234272 Riverside Ave',
        NULL,
        'Rzeszow-Lab2',
        'Podkarpackie',
        'Poland',
        '35-001',
        NEWID(),
        SYSDATETIME()
    );

    SET @Lab2AddressID = SCOPE_IDENTITY();

    INSERT INTO SalesLT.CustomerAddress (
        CustomerID,
        AddressID,
        AddressType,
        rowguid,
        ModifiedDate
    )
    VALUES (
        @CustomerForLab1,
        @Lab2AddressID,
        'Home',
        NEWID(),
        SYSDATETIME()
    );
END;

SELECT TOP (1) @CategoryForLab1 = ProductCategoryID
FROM SalesLT.ProductCategory
WHERE ProductCategoryID % 10 = @Cyfra
ORDER BY ProductCategoryID;

IF @CategoryForLab1 IS NULL
BEGIN
    SET IDENTITY_INSERT SalesLT.ProductCategory ON;

    INSERT INTO SalesLT.ProductCategory (
        ProductCategoryID,
        ParentProductCategoryID,
        Name,
        rowguid,
        ModifiedDate
    )
    VALUES (
        9002,
        NULL,
        'Lab2 Special R Category',
        NEWID(),
        SYSDATETIME()
    );

    SET IDENTITY_INSERT SalesLT.ProductCategory OFF;

    SET @CategoryForLab1 = 9002;
END;

IF NOT EXISTS (
    SELECT 1
    FROM SalesLT.Product
    WHERE Name = 'Road-Racer-234272R'
)
BEGIN
    INSERT INTO SalesLT.Product (
        Name,
        ProductNumber,
        Color,
        StandardCost,
        ListPrice,
        Size,
        Weight,
        ProductCategoryID,
        ProductModelID,
        SellStartDate,
        SellEndDate,
        DiscontinuedDate,
        ThumbNailPhoto,
        ThumbnailPhotoFileName,
        rowguid,
        ModifiedDate
    )
    SELECT TOP (1)
        'Road-Racer-234272R' AS Name,
        ProductNumber + '-234272R' AS ProductNumber,
        Color,
        StandardCost,
        ListPrice,
        Size,
        Weight,
        @CategoryForLab1,
        ProductModelID,
        SYSDATETIME(),
        NULL,
        NULL,
        ThumbNailPhoto,
        ThumbnailPhotoFileName,
        NEWID(),
        SYSDATETIME()
    FROM SalesLT.Product
    ORDER BY ProductID;
END;

IF OBJECT_ID('SalesLT.ProductsCategories234272', 'U') IS NOT NULL
BEGIN
    DROP TABLE SalesLT.ProductsCategories234272;
END;

SELECT
    p.Name,
    p.ProductNumber,
    pc.Name AS CategoryName,
    234272 AS OwnerId
INTO SalesLT.ProductsCategories234272
FROM SalesLT.Product AS p
JOIN SalesLT.ProductCategory AS pc
    ON p.ProductCategoryID = pc.ProductCategoryID
WHERE p.Name LIKE 'R%R'
   OR pc.Name LIKE '%R%';

-- =============================================
-- Zadanie 2
-- =============================================
DECLARE @Litera2 CHAR(1) = 'R';
DECLARE @Cyfra2 INT = 2;

SELECT CustomerID, FirstName, LastName
FROM SalesLT.Customer
WHERE LastName LIKE @Litera2 + '%'
  AND CustomerID % 10 = @Cyfra2;

-- =============================================
-- Zadanie 3
-- =============================================
DECLARE @Litera3 CHAR(1) = 'R';
DECLARE @Produkty TABLE (
    ProductID INT,
    Name NVARCHAR(50),
    ListPrice MONEY
);

INSERT INTO @Produkty (ProductID, Name, ListPrice)
SELECT ProductID, Name, ListPrice
FROM SalesLT.Product
WHERE Name LIKE '%' + @Litera3 + '%';

SELECT ProductID, Name, ListPrice
FROM @Produkty;

-- =============================================
-- Zadanie 4
-- =============================================
IF OBJECT_ID('tempdb..#KlienciMiasta', 'U') IS NOT NULL
BEGIN
    DROP TABLE #KlienciMiasta;
END;

CREATE TABLE #KlienciMiasta (
    CustomerID INT,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    City NVARCHAR(50)
);

INSERT INTO #KlienciMiasta (CustomerID, FirstName, LastName, City)
SELECT DISTINCT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    a.City
FROM SalesLT.CustomerAddress AS ca
JOIN SalesLT.Address AS a ON ca.AddressID = a.AddressID
JOIN SalesLT.Customer AS c ON c.CustomerID = ca.CustomerID
WHERE a.City LIKE 'R%';

SELECT CustomerID, FirstName, LastName, City
FROM #KlienciMiasta;

DROP TABLE #KlienciMiasta;

-- =============================================
-- Zadanie 5
-- =============================================
IF NOT EXISTS (
    SELECT 1 FROM sys.schemas WHERE name = 'Student_272'
)
BEGIN
    EXEC('CREATE SCHEMA Student_272 AUTHORIZATION dbo;');
END;

IF OBJECT_ID('Student_272.ProduktyR', 'U') IS NOT NULL
BEGIN
    DROP TABLE Student_272.ProduktyR;
END;

CREATE TABLE Student_272.ProduktyR (
    ProductID INT NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    Category NVARCHAR(100) NOT NULL,
    ListPrice MONEY NOT NULL
);

INSERT INTO Student_272.ProduktyR (ProductID, Name, Category, ListPrice)
SELECT
    p.ProductID,
    p.Name,
    pc.Name AS Category,
    p.ListPrice
FROM SalesLT.Product AS p
JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID
WHERE pc.Name LIKE '%R%';

SELECT ProductID, Name, Category, ListPrice
FROM Student_272.ProduktyR;

-- =============================================
-- Zadanie 6
-- =============================================
DECLARE @Podsumowanie TABLE (
    Category NVARCHAR(100),
    SredniaCena MONEY
);

INSERT INTO @Podsumowanie (Category, SredniaCena)
SELECT
    pc.Name,
    AVG(p.ListPrice) AS SredniaCena
FROM SalesLT.ProductCategory AS pc
JOIN SalesLT.Product AS p ON pc.ProductCategoryID = p.ProductCategoryID
WHERE pc.ProductCategoryID % 10 = 2
GROUP BY pc.Name;

SELECT Category, SredniaCena
FROM @Podsumowanie;

-- =============================================
-- Zadanie 7
-- =============================================
DECLARE @SchemaY SYSNAME = '234272';

IF NOT EXISTS (
    SELECT 1 FROM sys.schemas WHERE name = @SchemaY
)
BEGIN
    EXEC('CREATE SCHEMA [' + @SchemaY + '] AUTHORIZATION dbo;');
END;

DECLARE @TablesToMove TABLE (TableName SYSNAME);
INSERT INTO @TablesToMove (TableName)
VALUES ('Customer'), ('CustomerAddress');

DECLARE @CurrentTable SYSNAME;
DECLARE @SourceSchema SYSNAME;
DECLARE @Sql NVARCHAR(MAX);

WHILE EXISTS (SELECT 1 FROM @TablesToMove)
BEGIN
    SELECT TOP (1) @CurrentTable = TableName FROM @TablesToMove;
    DELETE FROM @TablesToMove WHERE TableName = @CurrentTable;

    SET @SourceSchema = NULL;
    SET @Sql = NULL;

    SELECT @SourceSchema = s.name
    FROM sys.tables t
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE t.name = @CurrentTable;

    IF @SourceSchema IS NOT NULL AND @SourceSchema <> @SchemaY
    BEGIN
        SET @Sql = N'ALTER SCHEMA [' + @SchemaY + N'] TRANSFER [' + @SourceSchema + N'].[' + @CurrentTable + N'];';
        EXEC sys.sp_executesql @Sql;
    END;

    IF EXISTS (
        SELECT 1
        FROM sys.synonyms
        WHERE name = @CurrentTable
          AND SCHEMA_NAME(schema_id) = 'SalesLT'
    )
    BEGIN
        SET @Sql = N'DROP SYNONYM SalesLT.' + QUOTENAME(@CurrentTable) + N';';
        EXEC sys.sp_executesql @Sql;
    END;

    IF OBJECT_ID('SalesLT.' + @CurrentTable, 'U') IS NULL
    BEGIN
        SET @Sql = N'CREATE SYNONYM SalesLT.' + QUOTENAME(@CurrentTable) + N' FOR [' + @SchemaY + N'].[' + @CurrentTable + N'];';
        EXEC sys.sp_executesql @Sql;
    END;
END;

-- =============================================
-- Imię           : Robert
-- Nazwisko       : Gevorgyan
-- Numer indeksu  : 234272
-- =============================================

-- =============================================
-- Zadanie 1
-- =============================================
SELECT *
FROM SalesLT.Customer
WHERE LastName LIKE 'R%';

-- =============================================
-- Zadanie 2
-- =============================================
SELECT FirstName, LastName, EmailAddress
FROM SalesLT.Customer
WHERE CustomerID % 10 = 2;

-- =============================================
-- Zadanie 3
-- =============================================
SELECT Name, ListPrice, ProductNumber
FROM SalesLT.Product
WHERE Name LIKE '%R%'
ORDER BY ListPrice DESC;

-- =============================================
-- Zadanie 4
-- =============================================
SELECT ProductCategoryID, AVG(ListPrice) AS AverageListPrice
FROM SalesLT.Product
WHERE ProductCategoryID % 10 = 2
GROUP BY ProductCategoryID;

-- =============================================
-- Zadanie 5
-- =============================================
SELECT DISTINCT a.City
FROM SalesLT.CustomerAddress ca
JOIN SalesLT.Address a ON ca.AddressID = a.AddressID
WHERE a.City LIKE 'R%';

-- =============================================
-- Zadanie 6
-- =============================================
IF NOT EXISTS (
    SELECT 1
    FROM SalesLT.Customer
    WHERE EmailAddress = 'robert.gevorgyan@lab2.com'
)
BEGIN
    ;WITH PasswordTemplate AS (
        SELECT TOP 1 PasswordHash, PasswordSalt
        FROM SalesLT.Customer
        ORDER BY CustomerID
    )
    INSERT INTO SalesLT.Customer (
        NameStyle,
        FirstName,
        LastName,
        CompanyName,
        EmailAddress,
        PasswordHash,
        PasswordSalt,
        rowguid,
        ModifiedDate
    )
    SELECT
        0,
        'Robert',
        'Gevorgyan',
        'Lab2',
        'robert.gevorgyan@lab2.com',
        PasswordHash,
        PasswordSalt,
        NEWID(),
        GETDATE()
    FROM PasswordTemplate;
END;

SELECT CustomerID, FirstName, LastName, CompanyName, EmailAddress
FROM SalesLT.Customer
WHERE EmailAddress = 'robert.gevorgyan@lab2.com';

-- =============================================
-- Zadanie 7
-- =============================================
IF NOT EXISTS (
    SELECT 1 FROM SalesLT.ProductCategory WHERE Name = 'Special-R'
)
BEGIN
    INSERT INTO SalesLT.ProductCategory (
        ParentProductCategoryID,
        Name,
        rowguid,
        ModifiedDate
    )
    VALUES (NULL, 'Special-R', NEWID(), GETDATE());
END;

IF NOT EXISTS (
    SELECT 1 FROM SalesLT.ProductCategory WHERE Name = 'Extra-2'
)
BEGIN
    INSERT INTO SalesLT.ProductCategory (
        ParentProductCategoryID,
        Name,
        rowguid,
        ModifiedDate
    )
    VALUES (NULL, 'Extra-2', NEWID(), GETDATE());
END;

-- =============================================
-- Zadanie 8
-- =============================================
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
FROM SalesLT.Product p
JOIN SalesLT.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID
WHERE
    (p.Name LIKE 'R%R')
    OR (pc.Name LIKE '%R%');

-- =============================================
-- Zadanie 9
-- =============================================
SELECT CategoryName, COUNT(*) AS ProductCount
FROM SalesLT.ProductsCategories234272
GROUP BY CategoryName;

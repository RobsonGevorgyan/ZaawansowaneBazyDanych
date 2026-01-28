-- =============================================
-- Imie: Robert
-- Nazwisko: Gevorgyan
-- Numer indeksu: 234272
-- =============================================

-- =============================================
-- Zadanie 1
-- =============================================
-- Nie da się wykonać zadania, poniewaz CREATE VIEW musi być pierwszą instrukcją i nie moze ona korzystac ze zmiennych lokalnych

-- =============================================
-- Zadanie 2
-- =============================================
-- Wybieramy tylko tych klientów, którzy wydali 50k

CREATE OR ALTER VIEW Student_272.TheBestCustomers
AS
SELECT
c.CustomerID,
c.CompanyName,
SUM(oh.TotalDue) AS MoneySpent

FROM [234272].Customer c
JOIN SalesLT.SalesOrderHeader oh ON c.CustomerID = oh.CustomerID
GROUP BY c.CustomerID, c.CompanyName
HAVING SUM (oh.TotalDue) >= 50000;
GO

-- =============================================
-- Zadanie 3
-- =============================================
CREATE OR ALTER FUNCTION Student_272.ufn_ProductsJsonByCategory
(
    @CategoryName NVARCHAR(50)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
RETURN (
	SELECT
	p.ProductID,
	p.Name,
	p.ProductNumber,
	p.ListPrice,
	p.Color,
	pc.Name AS Category

    FROM SalesLT.Product p
	JOIN SalesLT.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID

    WHERE pc.Name = @CategoryName
    FOR JSON PATH
);
END;
GO

-- =============================================
-- Zadanie 4
-- =============================================
CREATE OR ALTER FUNCTION Student_272.ufn_IsPriceHigherThanCurrent
(
    @ProductJson NVARCHAR(MAX)
)
RETURNS BIT
AS
BEGIN
	DECLARE @ProductID INT;
	DECLARE @JsonPrice DECIMAL(18,2);
	DECLARE @CurrentPrice DECIMAL(18,2);

	SELECT
    @ProductID = ProductID,
    @JsonPrice = NewPrice

    FROM OPENJSON(@ProductJson)
    WITH (
        ProductID INT '$.ProductID',
        NewPrice DECIMAL(18,2) '$.NewPrice'
    );


	SELECT @CurrentPrice = ListPrice
	FROM SalesLT.Product
    WHERE ProductID = @ProductID;

	IF @JsonPrice > @CurrentPrice
        RETURN 1;

	RETURN 0;
END;
GO

-- =============================================
-- Zadanie 5
-- =============================================
CREATE OR ALTER FUNCTION Student_272.ufn_CheckPricesJSON()
RETURNS TABLE
AS
RETURN
(
	SELECT
    p.ProductID,
    p.Name,
    Student_272.ufn_IsPriceHigherThanCurrent(
            CONCAT('{"ProductID":', p.ProductID, ',"NewPrice":', p.ListPrice + 10, '}')
        ) AS IsHigher
    FROM SalesLT.Product p
);
GO

-- =============================================
-- Zadanie 6
-- =============================================
CREATE OR ALTER FUNCTION Student_272.ufn_CalcAdjustedPrices()
RETURNS TABLE
AS
RETURN
(
    SELECT
    ProductID,
    CAST(ListPrice - (ListPrice * 0.02) AS DECIMAL(18,2)) AS AdjustedPrice
    FROM (
        SELECT TOP (25) ProductID, ListPrice
        FROM SalesLT.Product
        ORDER BY ListPrice DESC
    ) AS TopProducts
);
GO

DECLARE @Summary TABLE
(
    ProductID INT,
    AdjustedPrice DECIMAL(18,2)
);

INSERT INTO @Summary (ProductID, AdjustedPrice)
SELECT ProductID, AdjustedPrice
FROM Student_272.ufn_CalcAdjustedPrices();
GO

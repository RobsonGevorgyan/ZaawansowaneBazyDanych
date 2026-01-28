-- =============================================
-- Imie: Robert
-- Nazwisko: Gevorgyan
-- Numer indeksu: 234272
-- =============================================

-- =============================================
-- Zadanie 1
-- =============================================
-- https://github.com/RobsonGevorgyan/ZaawansowaneBazyDanych

-- =============================================
-- Zadanie 2
-- =============================================
ALTER TABLE [234272].[Customer]
ADD
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN
        CONSTRAINT DF_234272_Customer_ValidFrom DEFAULT SYSUTCDATETIME(),
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN
        CONSTRAINT DF_234272_Customer_ValidTo DEFAULT CONVERT(DATETIME2, '9999-12-31 23:59:59.9999999'),
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo);
GO

ALTER TABLE [234272].[Customer]
SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [234272].[CustomerHistory]));
GO

-- =============================================
-- Zadanie 3
-- =============================================
IF OBJECT_ID('tempdb..#Lab3Checkpoint') IS NOT NULL
    DROP TABLE #Lab3Checkpoint;

CREATE TABLE #Lab3Checkpoint
(
    CheckpointTime DATETIME2 NOT NULL
);

UPDATE c
SET
    CompanyName = CONCAT('RG_Lab3_Company_', CustomerID),
    EmailAddress = CONCAT('rg.lab3.', CustomerID, '@example.com')
FROM [234272].[Customer] AS c
WHERE c.CustomerID IN
(
    SELECT TOP (10) CustomerID
    FROM [234272].[Customer]
    ORDER BY CustomerID
);

DECLARE @TargetCustomerID INT =
(
    SELECT TOP (1) CustomerID
    FROM [234272].[Customer]
    ORDER BY CustomerID
);

UPDATE [234272].[Customer]
SET CompanyName = 'RG_Lab3_Update_A'
WHERE CustomerID = @TargetCustomerID;

UPDATE [234272].[Customer]
SET CompanyName = 'RG_Lab3_Update_B'
WHERE CustomerID = @TargetCustomerID;

UPDATE [234272].[Customer]
SET CompanyName = 'RG_Lab3_Update_C'
WHERE CustomerID = @TargetCustomerID;

INSERT INTO #Lab3Checkpoint (CheckpointTime)
VALUES (SYSUTCDATETIME());

INSERT INTO [234272].[Customer]
    (FirstName, LastName, CompanyName, EmailAddress, PasswordHash, PasswordSalt)
VALUES
('Marta', 'Radosz', 'RG_Lab3', 'marta.radosz@lab3.com', 'uRlorVzDGNJIX9I+ehTlRK+liT4UKRgWhApJgUMC2d4=', 'sPoUBSQ='),
('Kamil', 'Rydzewski', 'RG_Lab3', 'kamil.rydzewski@lab3.com', 'uRlorVzDGNJIX9I+ehTlRK+liT4UKRgWhApJgUMC2d4=', 'sPoUBSQ='),
('Ola', 'Rafalska', 'RG_Lab3', 'ola.rafalska@lab3.com', 'uRlorVzDGNJIX9I+ehTlRK+liT4UKRgWhApJgUMC2d4=', 'sPoUBSQ='),
('Pawel', 'Roch', 'RG_Lab3', 'pawel.roch@lab3.com', 'uRlorVzDGNJIX9I+ehTlRK+liT4UKRgWhApJgUMC2d4=', 'sPoUBSQ='),
('Iza', 'Rudnicka', 'RG_Lab3', 'iza.rudnicka@lab3.com', 'uRlorVzDGNJIX9I+ehTlRK+liT4UKRgWhApJgUMC2d4=', 'sPoUBSQ=');
GO

-- =============================================
-- Zadanie 4
-- =============================================
DECLARE @TargetCustomerID_Z4 INT =
(
    SELECT TOP (1) CustomerID
    FROM [234272].[Customer]
    ORDER BY CustomerID
);

SELECT *
FROM [234272].[Customer]
FOR SYSTEM_TIME ALL
WHERE CustomerID = @TargetCustomerID_Z4;
GO

-- =============================================
-- Zadanie 5
-- =============================================
DECLARE @AsOfTime DATETIME2 =
(
    SELECT TOP (1) CheckpointTime
    FROM #Lab3Checkpoint
);

SELECT *
FROM [234272].[Customer]
FOR SYSTEM_TIME AS OF @AsOfTime;
GO

-- =============================================
-- Zadanie 6
-- =============================================
CREATE XML SCHEMA COLLECTION SalesLT.ProductAttributeSchema AS
N'
<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">

  <xsd:element name="Attributes">
    <xsd:complexType>
      <xsd:sequence>
        <xsd:element name="Weight" type="xsd:decimal"/>
        <xsd:element name="Color" type="xsd:string"/>
        <xsd:element name="Height" type="xsd:decimal"/>
        <xsd:element name="Width" type="xsd:decimal"/>
        <xsd:element name="Length" type="xsd:decimal"/>
        <xsd:element name="Material" type="xsd:string"/>
      </xsd:sequence>
    </xsd:complexType>
  </xsd:element>

</xsd:schema>
';
GO

CREATE TABLE [SalesLT].[ProductAttribute]
(
    ProductAttributeID INT IDENTITY PRIMARY KEY,
    ProductID INT NOT NULL,
    Attributes XML (SalesLT.ProductAttributeSchema) NOT NULL,

    CONSTRAINT FK_ProductAttribute_Product
        FOREIGN KEY (ProductID)
        REFERENCES [SalesLT].[Product](ProductID)
);
GO

-- =============================================
-- Zadanie 7
-- =============================================
INSERT INTO SalesLT.ProductAttribute (ProductID, Attributes)
VALUES
(706,
'<Attributes>
    <Weight>1.5</Weight>
    <Color>Red</Color>
    <Height>10</Height>
    <Width>20</Width>
    <Length>30</Length>
    <Material>Steel</Material>
</Attributes>'
),

(707,
'<Attributes>
    <Weight>2.3</Weight>
    <Color>Blue</Color>
    <Height>15</Height>
    <Width>25</Width>
    <Length>35</Length>
    <Material>Aluminum</Material>
</Attributes>'
),

(708,
'<Attributes>
    <Weight>0.9</Weight>
    <Color>Black</Color>
    <Height>8</Height>
    <Width>12</Width>
    <Length>18</Length>
    <Material>Carbon</Material>
</Attributes>'
),

(709,
'<Attributes>
    <Weight>3.2</Weight>
    <Color>White</Color>
    <Height>20</Height>
    <Width>30</Width>
    <Length>40</Length>
    <Material>Plastic</Material>
</Attributes>'
),

(710,
'<Attributes>
    <Weight>4.1</Weight>
    <Color>Green</Color>
    <Height>25</Height>
    <Width>35</Width>
    <Length>45</Length>
    <Material>Titanium</Material>
</Attributes>'
);
GO

-- =============================================
-- Zadanie 8
-- =============================================
UPDATE SalesLT.ProductAttribute
SET Attributes.modify('
    replace value of (/Attributes/Color)[1]
    with concat("R_", (/Attributes/Color)[1])
');
GO

-- =============================================
-- Zadanie 9
-- =============================================
DECLARE @json NVARCHAR(MAX) = N'
{
    "ProductId": 1,
    "Name": "Example product",
    "Price": 199.99,
    "Stock": 50,
    "Warehouse": "A1"
}';

SET @json = JSON_MODIFY(@json, '$.Stock', 234272);
GO

-- Set-based update without cursor; OUTPUT lists updated IDs
UPDATE SalesLT.Product
SET ListPrice = ListPrice + 2
OUTPUT inserted.ProductID AS UpdatedProductID;

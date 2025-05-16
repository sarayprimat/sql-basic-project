-------------------------------------------- טבלה 1

select*
into [sales].[Sales].[Customer]
from [AdventureWorks2022].[Sales].[Customer]

-- מפתח ראשי

ALTER TABLE [sales].[Sales].[Customer]
ADD CONSTRAINT [PK_Customer_CustomerID]  PRIMARY KEY ([CustomerID])

-------------------------------------------------------------------------- הוספת מפתח זר עבור PersonID
ALTER TABLE [Sales].[Customer]
ADD CONSTRAINT [FK_Customer_Person_PersonID] 
FOREIGN KEY ([PersonID]) 
REFERENCES [Sales].[Person]([PersonID]);

-- הוספת מפתח זר עבור TerritoryID
ALTER TABLE [Sales].[Customer]
ADD CONSTRAINT [FK_Customer_SalesTerritory_TerritoryID] 
FOREIGN KEY ([TerritoryID]) 
REFERENCES [Sales].[SalesTerritory]([TerritoryID]);

------------------------------------------------------------------------------- הוספת מפתח זר עבור StoreID
ALTER TABLE [Sales].[Customer]
ADD CONSTRAINT [FK_Customer_Person_PersonID] 
FOREIGN KEY ([PersonID])  
REFERENCES [Sales].[Person]([PersonID]);


ALTER TABLE employees
ADD department_id INT CONSTRAINT emp_dept_id_dept_id_fk REFERENCES
departments(department_id)

------------------------------------------------ טבלה 2


select[TerritoryID],[Name],[CountryRegionCode],[Group],[SalesYTD],
[SalesLastYear],[CostYTD],[CostLastYear],[rowguid], [ModifiedDate]
into [sales].[Sales].[SalesTerritory]
from [AdventureWorks2022].[Sales].[SalesTerritory]

-- מפתח ראשי

ALTER TABLE [sales].[Sales].[SalesTerritory]
ADD CONSTRAINT[PK_SalesTerritory_TerritoryID]  PRIMARY KEY ([TerritoryID])



------------------------------------------- טבלה 3

select*
into [sales].[Sales].[SalesPerson]
from [AdventureWorks2022].[Sales].[SalesPerson]

-- מפתח ראשי

ALTER TABLE [sales].[Sales].[SalesPerson]
ADD CONSTRAINT [PK_SalesPerson_BusinessEntityID]  PRIMARY KEY ([BusinessEntityID])

------------------------------------------- טבלה 4

select*
into [sales].[Sales].[CreditCard]
from [AdventureWorks2022].[Sales].[CreditCard]

-- מפתח ראשי

ALTER TABLE [sales].[Sales].[CreditCard]
ADD CONSTRAINT  [PK_CreditCard_CreditCardID] PRIMARY KEY ([CreditCardID])


---------------------------------------------- טבלה 5 

select*
into [sales].[Sales].[SalesOrderHeader]
from [AdventureWorks2022].[Sales].[SalesOrderHeader]

-- מפתח ראשי

ALTER TABLE [sales].[Sales].[SalesOrderHeader]
ADD CONSTRAINT [PK_SalesOrderHeader_SalesOrderID]  PRIMARY KEY ([SalesOrderID])

--------------------------------------------- טבלה 6

select*
into [sales].[Person].[Address]
from [AdventureWorks2022].[Person].[Address]

-- מפתח ראשי

ALTER TABLE [sales].[Person].[Address]
ADD CONSTRAINT [PK_Address_AddressID]  PRIMARY KEY ([AddressID])

-------------------------------------------- טבלה 7

select*
into [sales].[Purchasing].[ShipMethod]
from [AdventureWorks2022].[Purchasing].[ShipMethod]

-- מפתח ראשי

ALTER TABLE [sales].[Purchasing].[ShipMethod]
ADD CONSTRAINT [PK_ShipMethod_ShipMethodID]  PRIMARY KEY ([ShipMethodID])

------------------------------------------ טבלה 8

select*
into [sales].[Sales].[CurrencyRate]
from [AdventureWorks2022].[Sales].[CurrencyRate]

-- מפתח ראשי

ALTER TABLE [sales].[Sales].[CurrencyRate]
ADD CONSTRAINT [PK_CurrencyRate_CurrencyRateID]  PRIMARY KEY ([CurrencyRateID])

----------------------------------------- טבלה 9
select[SalesOrderID],[SalesOrderDetailID],[CarrierTrackingNumber],[OrderQty],[ProductID],
[SpecialOfferID],[UnitPrice],[UnitPriceDiscount],[LineTotal],[rowguid],[ModifiedDate]
into [sales].[Sales].[SalesOrderDetail]
from [AdventureWorks2022].[Sales].[SalesOrderDetail]

-- מפתח ראשי
ALTER TABLE [sales].[Sales].[SalesOrderDetail]
ADD CONSTRAINT PK_SalesOrderDetail
PRIMARY KEY ([SalesOrderID], [SalesOrderDetailID])

------------------------------------------ טבלה 10

select*
into [sales].[Sales].[SpecialOfferProduct]
from [AdventureWorks2022].[Sales].[SpecialOfferProduct]

-- מפתח ראשי

ALTER TABLE [sales].[Sales].[SpecialOfferProduct]
ADD CONSTRAINT [PK_SpecialOfferProduct_SpecialOfferID_ProductID]
PRIMARY KEY ([SpecialOfferID], [ProductID])


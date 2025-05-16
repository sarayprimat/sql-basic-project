---פתרון פרוייקט 2:
--מגישות:
--שחר אליהו 211363361
-- שרי פרימט 206584864 
-- שיר טרוינה 323023713

-------------------------------------------------------------------------------------------------------------------------------1

SELECT 
    *, ((a.YearlyLinearIncome / LAG(a.YearlyLinearIncome) OVER (ORDER BY a.year)) - 1) * 100 AS GrowthPercentage 
    
FROM (
    SELECT 
        YEAR([OrderDate]) AS [Year], 
        SUM([ExtendedPrice] - [TaxAmount]) AS IncomePerYear, 
        COUNT(DISTINCT MONTH([OrderDate])) AS NumberOfDistinctMonths, 
        (SUM([ExtendedPrice] - [TaxAmount]) / COUNT(DISTINCT MONTH([OrderDate]))) * 12 AS YearlyLinearIncome 
    FROM [Sales].[Orders] O 
    INNER JOIN [Sales].[Invoices] I ON O.OrderID = I.OrderID  
    INNER JOIN [Sales].[InvoiceLines] IL ON I.InvoiceID = IL.InvoiceID 
    GROUP BY YEAR([OrderDate]) 
) a 


--------------------------------------------------------------------------------------------------------------------------------2

SELECT *
FROM (
    SELECT 
        YEAR(O.OrderDate) AS TheYear,                           
        DATEPART(QUARTER, O.OrderDate) AS TheQuarter,          
        C.CustomerName,                                         
        SUM(OL.Quantity * OL.UnitPrice) AS IncomePerYear,       
        DENSE_RANK() OVER (PARTITION BY YEAR(O.OrderDate), 
        DATEPART(QUARTER, O.OrderDate)                         
        ORDER BY SUM(OL.Quantity * OL.UnitPrice) DESC
        ) AS DNR                                                
    FROM Sales.Orders O                                        
        INNER JOIN Sales.Invoices I ON O.OrderID = I.OrderID    
        INNER JOIN Sales.OrderLines OL ON O.OrderID = OL.OrderID 
        INNER JOIN Sales.Customers C ON O.CustomerID = C.CustomerID 
    GROUP BY 
        YEAR(O.OrderDate),                                    
        DATEPART(QUARTER, O.OrderDate),                       
        C.CustomerName                                          
) b
WHERE b.DNR <= 5                                                
ORDER BY TheYear, TheQuarter, DNR                              
 

--------------------------------------------------------------------------------------------------------------------------3


WITH RankedProducts AS (
    SELECT 
        SI.StockItemID AS StockItemID,                      
        SI.StockItemName AS StockItemName,                 
        SUM(IL.ExtendedPrice - IL.TaxAmount) AS TotalProfit, 
        RANK() OVER (ORDER BY SUM(IL.ExtendedPrice - IL.TaxAmount) DESC) AS Rank 
    FROM 
        [Sales].[InvoiceLines] IL
        INNER JOIN [Warehouse].[StockItems] SI ON IL.StockItemID = SI.StockItemID 
    GROUP BY 
        SI.StockItemID,                                     
        SI.StockItemName                                    
)
SELECT 
    StockItemID,                                           
    StockItemName,                                         
    TotalProfit                                          
FROM RankedProducts
WHERE Rank <= 10                                          
ORDER BY TotalProfit DESC                                


--------------------------------------------------------------------------------------------------------------------------------4

WITH RankedStockItems AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY (SI.RecommendedRetailPrice - SI.UnitPrice) DESC) AS Rn,  
        SI.StockItemID,                      
        SI.StockItemName,                  
        SI.UnitPrice,                         
        SI.RecommendedRetailPrice, 
        (SI.RecommendedRetailPrice - SI.UnitPrice) AS NominalProductProfit, 
        DENSE_RANK() OVER (ORDER BY (SI.RecommendedRetailPrice - SI.UnitPrice) DESC) AS DNR
    FROM 
        [Warehouse].[StockItems] SI                                      
    WHERE 
        SI.UnitPrice > 0 AND                                
        SI.RecommendedRetailPrice > 0 AND                  
        GETDATE() BETWEEN SI.ValidFrom AND SI.ValidTo       
)
SELECT 
    Rn,                                           
    StockItemID,                                          
    StockItemName,                                         
    UnitPrice,                                             
    RecommendedRetailPrice,                                
    NominalProductProfit, 
    DNR 
FROM RankedStockItems
ORDER BY Rn
                                         


--------------------------------------------------------------------------------------------------------------------------------5

SELECT CAST(S.SupplierID AS VARCHAR) + ' - ' + S.SupplierName AS SupplierDetails, 
STRING_AGG(CAST(SI.StockItemID AS VARCHAR) + ' ' + SI.StockItemName, ' / ') AS ProductDetails 
FROM  [Purchasing].[Suppliers] S
INNER JOIN [Warehouse].[StockItems] SI ON S.SupplierID = SI.SupplierID 
GROUP BY S.SupplierID, S.SupplierName                                                                              
ORDER BY S.SupplierID                                             

----------------------------------------------------------------------------------------------------------------------------------6



WITH CustomerPurchases AS (
    SELECT 
        C.CustomerID,                                              
        CT.CityName,                                              
        CO.CountryName,                                            
        CO.Continent,                                              
        CO.Region,                                                 
        SUM(IL.ExtendedPrice) AS TotalExtendedPrice                
    FROM 
        [Sales].[Customers] C
        INNER JOIN [Application].[Cities] CT ON C.PostalCityID = CT.CityID        
        INNER JOIN [Application].[StateProvinces] SP ON CT.StateProvinceID = SP.StateProvinceID 
        INNER JOIN [Application].[Countries] CO ON SP.CountryID = CO.CountryID     
        INNER JOIN [Sales].[Invoices] I ON C.CustomerID = I.CustomerID       
        INNER JOIN [Sales].[InvoiceLines] IL ON I.InvoiceID = IL.InvoiceID   
    GROUP BY 
        C.CustomerID, CT.CityName, CO.CountryName, CO.Continent, CO.Region 
)
SELECT TOP 5                                                   
    CustomerID,                                                 
    CityName,                                                
    CountryName,                                                 
    Continent,                                                  
    Region,                                                     
    TotalExtendedPrice                                          
FROM 
    CustomerPurchases
ORDER BY 
    TotalExtendedPrice DESC                                       


-------------------------------------------------------------------------------------------------------------------------------------7

WITH cte AS (
    SELECT 
        OrderYear,
        OrderMonth,
        SUM(Quantity * UnitPrice) AS MonthlyTotal
    FROM (
        SELECT 
            YEAR(O.OrderDate) AS OrderYear,
            MONTH(O.OrderDate) AS OrderMonth,
            OL.Quantity,
            OL.UnitPrice
        FROM [Sales].[Orders] O
        INNER JOIN [Sales].[Invoices] I ON I.OrderID = O.OrderID
        INNER JOIN [Sales].[OrderLines] OL ON OL.OrderID = O.OrderID
        INNER JOIN [Warehouse].[StockItems] SI ON OL.StockItemID = SI.StockItemID
    ) a
    GROUP BY OrderYear, OrderMonth

    UNION ALL

    SELECT 
        OrderYear,
        NULL AS OrderMonth,
        NULL AS MonthlyTotal
    FROM (
        SELECT 
            YEAR(O.OrderDate) AS OrderYear,
            MONTH(O.OrderDate) AS OrderMonth,
            SUM(OL.Quantity * OL.UnitPrice) AS MonthlyTotal
        FROM [Sales].[Orders] O
        INNER JOIN [Sales].[OrderLines] OL ON OL.OrderID = O.OrderID
        GROUP BY YEAR(O.OrderDate), MONTH(O.OrderDate)
    ) a
    GROUP BY OrderYear
)

SELECT 
    OrderYear,
    CASE 
        WHEN OrderMonth IS NULL THEN 'Grand Total'
        ELSE CAST(OrderMonth AS VARCHAR)
    END AS OrderMonth,
    CASE 
        WHEN OrderMonth IS NULL THEN 
            SUM(MonthlyTotal) OVER (PARTITION BY OrderYear)
        ELSE 
            MonthlyTotal
    END AS MonthlyTotal,
    CASE 
        WHEN OrderMonth IS NULL THEN 
            SUM(MonthlyTotal) OVER (PARTITION BY OrderYear)
        ELSE 
            SUM(MonthlyTotal) OVER (PARTITION BY OrderYear ORDER BY ISNULL(OrderMonth, 13))
    END AS CumulativeTotal
FROM cte
ORDER BY 
    OrderYear,
    ISNULL(OrderMonth, 13)


----------------------------------------------------------------------------------------------------------------------------8

WITH OrdersSummary AS (
    SELECT 
        MONTH(OrderDate) AS OrderMonth,
        YEAR(OrderDate) AS OrderYear,
        COUNT(OrderID) AS OrderCount
    FROM Sales.Orders
    GROUP BY MONTH(OrderDate), YEAR(OrderDate)
)
SELECT 
    OrderMonth,
    ISNULL([2013], 0) AS [2013],
    ISNULL([2014], 0) AS [2014],
    ISNULL([2015], 0) AS [2015],
    ISNULL([2016], 0) AS [2016]
FROM OrdersSummary
PIVOT (
    SUM(OrderCount)
    FOR OrderYear IN ([2013], [2014], [2015], [2016])
) AS PivotTable
ORDER BY OrderMonth

-----------------------------------------------------------------------------------------------------------------------------9
with cte 
as 
(select o.CustomerID,c.CustomerName, OrderDate,
lag(orderDate) over (partition by o.customerID order by orderDate) as PreviousOrderDate,
max(orderDate) over (partition by o.customerID) as lastOrder,
max(orderDate) over () as LastAllOrder,
DATEDIFF(day,lag(orderDate) over (partition by o.customerID order by orderDate),orderDate) as daysSinceLastOrder,
DATEDIFF(day,MAX(orderDate) over(partition by o.customerID), max(orderDate) over()) as DaysSinceLastOrderToMaxOrder
from sales.Customers as c inner join Sales.Orders as o
	on c.CustomerID = o.CustomerID ) 

select CustomerID,CustomerName,OrderDate,PreviousOrderDate	, DaysSinceLastOrderToMaxOrder,
AVG(daysSinceLastOrder) over(partition by CustomerID) as avgDaysBetweenOrders,
case when AVG(daysSinceLastOrder) over(partition by CustomerID) > DaysSinceLastOrderToMaxOrder then 'active' else 'potenial churn'   end as 'customer_status'
from cte
order by 1



-----------------------------------------------------------------------------------------------------------------------------------10

SELECT *, CONCAT(CAST(CAST(customerCount AS DECIMAL(5,2)) / totalCustCount * 100.0 AS DECIMAL(5,2)), '%') AS Percentage
FROM (
       SELECT CustomerCategoryName,COUNT(DISTINCT customerName) AS customerCount,
       SUM(COUNT(DISTINCT customerName)) OVER () AS totalCustCount
        FROM
            (
             SELECT cc.CustomerCategoryName,
                    CASE 
                        WHEN CustomerName LIKE 'Wingtip%' THEN 'Wingtip'
                        WHEN CustomerName LIKE 'tailspin%' THEN 'tailspin'
                        ELSE CustomerName 
                    END AS customerName
                FROM sales.CustomerCategories AS cc 
                INNER JOIN sales.Customers AS c ON cc.CustomerCategoryID = c.CustomerCategoryID
            ) AS a
        GROUP BY CustomerCategoryName
    ) AS b









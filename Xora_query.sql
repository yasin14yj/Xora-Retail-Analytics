-- Print first 10 rows
SELECT * FROM Fact_Sales LIMIT 10;

-- 1. What is the total monthly revenue generated for each month throughout 2025?
SELECT 
    DATE_FORMAT(Date, '%Y-%m') AS SalesMonth,
    SUM(FinalPrice) AS TotalRevenue
FROM Fact_Sales
GROUP BY DATE_FORMAT(Date, '%Y-%m')
ORDER BY SalesMonth ASC;

-- 2. Which are the top 3 product categories by total revenue?
SELECT 
    Category,
    SUM(FinalPrice) AS TotalRevenue
FROM Fact_Sales
JOIN Dim_Product ON Fact_Sales.ProductID = Dim_Product.ProductID
GROUP BY Category
ORDER BY TotalRevenue DESC
LIMIT 3;
-- 3. What is the total number of transactions and total revenue for each sales channel (Store vs. Online)?
SELECT 
    SalesChannel,
    COUNT(OrderID) AS TotalTransactions,
    SUM(FinalPrice) AS TotalRevenue
FROM Fact_Sales
GROUP BY SalesChannel;
-- 4. List the top 10 customers who have placed the highest number of orders in the last two years.
SELECT 
    c.CustomerName,
    COUNT(f.OrderID) AS TotalOrders,
    SUM(f.Quantity) AS TotalItemsBought
FROM Fact_Sales f
JOIN Dim_Customer c ON f.CustomerID = c.CustomerID
GROUP BY c.CustomerName
ORDER BY TotalOrders DESC
LIMIT 10;
-- 5. Which products have generated the lowest total revenue (excluding those with zero sales)?
SELECT 
    p.ProductName,
    SUM(f.FinalPrice) AS TotalRevenue
FROM Fact_Sales f
JOIN Dim_Product p ON f.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY TotalRevenue ASC
LIMIT 5;
-- 6. What is the average order value (AOV) for each state, sorted from the highest to the lowest?
SELECT 
    s.State,
    AVG(f.FinalPrice) AS AverageOrderValue
FROM Fact_Sales f
JOIN Dim_Store s ON f.StoreID = s.StoreID
GROUP BY s.State
ORDER BY AverageOrderValue DESC;
-- 7. What is the total count of 'New Customers' who have made exactly one transaction?
SELECT COUNT(*) AS TotalNewCustomers
FROM (
    SELECT CustomerID
    FROM Fact_Sales
    GROUP BY CustomerID
    HAVING COUNT(OrderID) = 1
) AS NewCustTable;
-- 8. For each product category, which product has the highest total quantity sold? (Use a Window Function).
WITH ProductSales AS (
    SELECT 
        p.Category,
        p.ProductName,
        SUM(f.Quantity) AS TotalQty,
        RANK() OVER (PARTITION BY p.Category ORDER BY SUM(f.Quantity) DESC) as SalesRank
    FROM Fact_Sales f
    JOIN Dim_Product p ON f.ProductID = p.ProductID
    GROUP BY p.Category, p.ProductName
)
SELECT * FROM ProductSales WHERE SalesRank = 1;
-- 9. What is the total 'lost revenue' (potential revenue vs. final revenue) for each sales channel due to discounts?
SELECT 
    f.SalesChannel,
    SUM((p.Price * f.Quantity) - f.FinalPrice) AS TotalDiscountGiven
FROM Fact_Sales f
JOIN Dim_Product p ON f.ProductID = p.ProductID
GROUP BY f.SalesChannel;
-- 10. Compare the total revenue between 2024 and 2025 to determine the growth trend.
SELECT 
    YEAR(Date) AS SalesYear,
    SUM(FinalPrice) AS TotalRevenue
FROM Fact_Sales
WHERE YEAR(Date) IN (2024, 2025)
GROUP BY YEAR(Date);
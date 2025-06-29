Use sales_dashboard
SELECT * FROM Mobile_db

---Calculate Total Sales
SELECT
    ROUND(SUM(Price_Per_Unit * Units_Sold) / 1000000, 2) AS Total_Sales_Million
FROM
    Mobile_db;
GO

---Calculate Total Transaction
SELECT COUNT(TRANSACTION_ID) AS Total_Transaction
FROM Mobile_db
Go

---Calculate Total Quality
SELECT SUM(Units_Sold) AS Total_Quality
FROM Mobile_db
Go
 
---Calculate Average Price
SELECT 
    ROUND(AVG(Price_Per_Unit) / 100000, 2) AS Average_Price_Lakh
FROM 
    Mobile_db;

Go

---Calculate Average Rating
SELECT AVG(Customer_Ratings) AS Average_Rating
FROM Mobile_db
Go

---Calculate Total Quality By Month
SELECT 
Month,
DATENAME(MONTH, DATEFROMPARTS(2023, Month, 1)) AS Month_Name,
SUM(Units_Sold) AS Total_Quality
FROM Mobile_db
GROUP BY Month 
ORDER BY MONTH ASC;
Go

---Calculate	Customer Status by Rating Status	
SELECT 
Customer_Ratings,
CASE 
WHEN Customer_Ratings >4 THEN 'Good'
WHEN Customer_Ratings >2 THEN 'Average'
Else 'Poor'
END AS Customer_Status
FROM Mobile_db
GROUP BY 
Customer_Ratings,
CASE 
WHEN Customer_Ratings >4 THEN 'Good'
WHEN Customer_Ratings >2 THEN 'Average'
Else 'Poor'
END;
Go


----Calculate Transaction ID by Payment Method
SELECT 
Payment_Method,
COUNT(Transaction_ID) AS Transaction_ID
FROM Mobile_db
GROUP BY Payment_Method;
Go

----Calculate Total Sales By Day
SELECT
DATENAME(Weekday, DATEFROMPARTS(Year, Month, Day)) AS Day_Name,
DATENAME(MONTH, DATEFROMPARTS(2023, Month, 1)) AS Month_Name,
CONCAT(ROUND(SUM(Price_Per_Unit*Units_Sold/1000000),2),'M') AS Total_Sales
FROM Mobile_db
GROUP BY DATENAME(Weekday, DATEFROMPARTS(Year, Month, Day)),
DATENAME(MONTH, DATEFROMPARTS(2023, Month, 1)) 
ORDER BY 
CASE Datename(Weekday, DATEFROMPARTS(Year, Month, Day)) 
WHEN 'Monday' THEN 1
WHEN 'Tuesday' THEN 2
WHEN 'Wednesday' THEN 3
WHEN 'Thursday' THEN 4
WHEN 'Friday' THEN 5
WHEN 'Saturday' THEN 6
WHEN 'Sunday' THEN 7
END;
Go

----Calculate Total Sales By Month and Day
-- Step 1: Create a Calendar Table
WITH Calendar AS (
    SELECT CAST('2021-01-01' AS DATE) AS Date
    UNION ALL
    SELECT DATEADD(DAY, 1, Date)
    FROM Calendar
    WHERE Date < '2024-12-31'
)
-- Step 2: Join with your sales table
SELECT
    DATENAME(MONTH, c.Date) AS Month_Name,
    DATENAME(WEEKDAY, c.Date) AS Weekday,
    CONCAT(ROUND(SUM(ISNULL(m.Price_Per_Unit * m.Units_Sold, 0)/1000000),2),'M') AS Total_Sales    ---ISNULL-Handles days with no sales.
FROM
    Calendar c
LEFT JOIN            -----Ensures even days without sales appear.
    Mobile_db m
    ON c.Date = DATEFROMPARTS(m.Year, m.Month, m.Day)
GROUP BY
    DATENAME(MONTH, c.Date),
    DATENAME(WEEKDAY, c.Date),
	MONTH(c.Date),
    DATEPART(WEEKDAY, c.Date)
ORDER BY
    MONTH(c.Date),
    DATEPART(WEEKDAY, c.Date)
OPTION (MAXRECURSION 0);
Go

---Calculate Total Sales by Mobile Model
SELECT
Mobile_Model,
SUM(Price_Per_Unit *Units_Sold) AS Total_Sales
FROM Mobile_db
GROUP BY Mobile_Model
ORDER BY Total_Sales;
GO

---Calculate Brand wise Total Sales and Total Transaction
SELECT 
Brand,
ROUND(SUM(Price_Per_Unit *Units_Sold),3) AS Total_Sales,
COUNT(Transaction_ID) AS Transaction_ID
FROM Mobile_db
GROUP BY BRAND;
Go

---Calculate Total Sales By City
SELECT
CITY,
ROUND(SUM(Price_Per_Unit *Units_Sold),3) AS Total_Sales
FROM Mobile_db
GROUP BY City
ORDER BY Total_Sales
Go

---Calculate MTD By Year, Quarter, Month, Day
With DailySales AS (SELECT
YEAR,
MONTH,
CASE
WHEN MONTH IN (1,2,3) THEN 'Qtr 1'
WHEN MONTH IN (4,5,6) THEN 'Qtr 2'
WHEN MONTH IN (7,8,9) THEN 'Qtr 3'
WHEN MONTH IN (10,11,12) THEN 'Qtr 4'
END AS Quarter,
DATENAME(MONTH, DATEFROMPARTS(YEAR,MONTH,DAY)) AS Month_Name,
DAY,
ROUND(SUM(Price_Per_Unit *Units_Sold)/100000.0, 2) AS Daily_Sales_Lakhs
FROM Mobile_db
GROUP BY 
Year,
Month,
Day)
SELECT
YEAR,
MONTH,
Quarter,
Daily_Sales_Lakhs,
ROUND(SUM(Daily_Sales_Lakhs) OVER (PARTITION BY YEAR, MONTH_NAME ORDER BY DAY), 2) AS MTD_Sales_Lakhs
FROM DailySales
ORDER BY 
YEAR,
Quarter,
Month,
DAY;
Go










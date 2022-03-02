--*************************************************************************--
-- Title: Assignment07
-- Author: AMcGrady
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2017-01-01,RRoot,Created File
-- 2022-02-27,AMcGrady,Completed Questions 1-4
-- 2022-02-28,AMcGrady,Completed Questions 5-8
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_AMcGrady')
	 Begin 
	  Alter Database [Assignment07DB_AMcGrady] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_AMcGrady;
	 End
	Create Database Assignment07DB_AMcGrady;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_AMcGrady;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

-- <Put Your Code Here> --

-- Inspect the vProducts base view for table structure and column names
-- SELECT * FROM vProducts;
-- GO

-- Select the desired columns for the final results
-- SELECT ProductName, UnitPrice FROM vProducts;
-- GO

-- Use the currency format function to format price as US Dollars. Order by ProductName for final results
SELECT
	ProductName,
	Format(UnitPrice, 'C', 'en-US') AS UnitPrice
FROM
	vProducts
ORDER BY 
    ProductName;
GO


-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.
-- <Put Your Code Here> --

-- Inspect the data in the Categories and Products table for stucture and naming convention
-- SELECT * FROM vProducts;
-- SELECT * FROM vCategories;
-- GO

-- Select the desired columns for the final results with the above function for UnitPrice from question 1
-- SELECT ProductName, Format(UnitPrice, 'C', 'en-US') AS UnitPrice FROM vProducts;
-- SELECT CategoryName FROM vCategories;
-- GO

-- Join the two tables on the common CategoryID field and sort by CategoryName and ProductName for the final results
SELECT
    C.CategoryName,
    P.ProductName,
    Format(P.UnitPrice, 'C', 'en-US') AS UnitPrice
FROM
    vProducts AS P
JOIN
    vCategories AS C
ON
    P.CategoryID = C.CategoryID
ORDER BY 
    C.CategoryName, 
    P.ProductName;
GO

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --

-- Insprect the tables for structure and column names
-- SELECT * FROM vProducts;
-- SELECT * FROM vInventories;
-- GO

-- Select the desired columns from each table for the final results
-- SELECT ProductName FROM vProducts;
-- SELECT InventoryDate, [Count] FROM vInventories;
-- GO

-- Format the InventoryDate in the requested format using the built-in DateName function
-- SELECT DateName(mm, I.InventoryDate) + ', ' + DateName(yy, I.InventoryDate) AS InventoryDate, [Count] FROM vInventories;
-- GO

-- Join the two tables on the common ProductID value
-- SELECT
--     P.ProductName,
--     DateName(mm, I.InventoryDate) + ', ' + DateName(yy, I.InventoryDate) AS InventoryDate,
--     I.[Count] AS InventoryCount
-- FROM
--     vProducts AS P
-- JOIN
--     vInventories AS I
-- ON
--     P.ProductID = I.ProductID;
-- GO

-- Order by ProductName and InventoryDate to get the final results
SELECT
    P.ProductName,
    DateName(mm, I.InventoryDate) + ', ' + DateName(yy, I.InventoryDate) AS InventoryDate,
    I.[Count] AS InventoryCount
FROM
    vProducts AS P
JOIN
    vInventories AS I
ON
    P.ProductID = I.ProductID
ORDER BY
    P.ProductName,
    I.InventoryDate;
GO


-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --

-- Create a view with the Select statement from Question 3
GO
CREATE
VIEW vProductInventories
	AS 
		SELECT TOP 1000000000
    		P.ProductName,
            DateName(mm, I.InventoryDate) + ', ' + DateName(yy, I.InventoryDate) AS InventoryDate,
            I.[Count] AS InventoryCount
        FROM
            vProducts AS P
        JOIN
            vInventories AS I
        ON
            P.ProductID = I.ProductID
        ORDER BY
            P.ProductName,
            I.InventoryDate;
GO

-- Check that it works: Select * From vProductInventories;
SELECT * FROM vProductInventories;
GO

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --

-- Inspect the Categories, Inventories, and Products tables for structure and column names
-- SELECT * FROM vCategories;
-- SELECT * FROM vInventories;
-- SELECT * FROM vProducts;
-- GO

-- Select the columns needed for the final results. The Products table is a bridge between Categories and Inventories on the ProductID field
-- SELECT CategoryID, CategoryName FROM vCategories;
-- SELECT CategoryID, ProductID FROM vProducts;
-- SELECT InventoryDate, ProductID, [Count] FROM vInventories;
-- GO

-- Join the three tables with the desired columns for the final results using the same DateName function as the above questions
-- SELECT
--     C.CategoryName,
--     DateName(mm, I.InventoryDate) + ', ' + DateName(yy, I.InventoryDate) AS InventoryDate,
--     I.[Count] AS InventoryCount
-- FROM
--     vCategories AS C
-- JOIN
--     vProducts AS P
-- ON
--     C.CategoryID = P.CategoryID
-- JOIN
--     vInventories AS I
-- ON
--     P.ProductID = I.ProductID
-- ORDER BY
--     C.CategoryName, I.InventoryDate;
-- GO

-- Use the SUM function to get the total inventory counts for each month with a groupby on the Category Name and Inventory Date
-- SELECT
--     C.CategoryName,
--     DateName(mm, I.InventoryDate) + ', ' + DateName(yy, I.InventoryDate) AS InventoryDate,
--     SUM(I.[Count]) AS InventoryCountByCategory
-- FROM
--     vCategories AS C
-- JOIN
--     vProducts AS P
-- ON
--     C.CategoryID = P.CategoryID
-- JOIN
--     vInventories AS I
-- ON
--     P.ProductID = I.ProductID
-- GROUP BY
--     C.CategoryName, I.InventoryDate
-- ORDER BY
--     C.CategoryName, I.InventoryDate;
-- GO

-- Create the view for the desired final results
GO
CREATE
VIEW vCategoryInventories
	AS 
		SELECT TOP 1000000000
            C.CategoryName,
            DateName(mm, I.InventoryDate) + ', ' + DateName(yy, I.InventoryDate) AS InventoryDate,
            SUM(I.[Count]) AS InventoryCountByCategory
        FROM
            vCategories AS C
        JOIN
            vProducts AS P
        ON
            C.CategoryID = P.CategoryID
        JOIN
            vInventories AS I
        ON
            P.ProductID = I.ProductID
        GROUP BY
            C.CategoryName, 
            I.InventoryDate
        ORDER BY
            C.CategoryName, 
            I.InventoryDate;
GO

-- Check that it works: Select * From vCategoryInventories;
SELECT * FROM vCategoryInventories;
GO

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

-- <Put Your Code Here> --
/*
-- Inspect the Products and Inventories tables for stucture and column names
SELECT * FROM vProductInventories;
GO

-- Use a LAG function to create the PreviousMonthCount column, partitioning the function by the ProductName field and creating a default value of 0 for nulls
SELECT ProductName, InventoryDate, InventoryCount, LAG(InventoryCount, 1, 0) OVER (PARTITION BY ProductName ORDER BY Month(InventoryDate)) AS PreviousMonthCount
FROM vProductInventories
ORDER BY ProductName, Month(InventoryDate);
GO
*/
-- Create the view from this query
GO
CREATE
VIEW vProductInventoriesWithPreviousMonthCounts
	AS 
		SELECT TOP 1000000000
            ProductName, 
            InventoryDate, 
            InventoryCount, 
            LAG(InventoryCount, 1, 0) OVER (PARTITION BY ProductName ORDER BY Month(InventoryDate)) AS PreviousMonthCount
        FROM 
            vProductInventories
        ORDER BY 
            ProductName, 
            Month(InventoryDate);
GO


-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;
SELECT * FROM vProductInventoriesWithPreviousMonthCounts;
GO

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --
/*
-- Inspect the vProductInventoriesWithPreviousMonthCounts view
SELECT * FROM vProductInventoriesWithPreviousMonthCounts;
GO

-- Add the KPI field using a CASE WHEN function
SELECT
    ProductName,
    InventoryDate,
    InventoryCount,
    PreviousMonthCount,
    CASE WHEN InventoryCount > PreviousMonthCount THEN 1
        WHEN InventoryCount = PreviousMonthCount THEN 0
        WHEN InventoryCount < PreviousMonthCount THEN -1
        END
            AS CountVsPreviousCountKPI
FROM 
    vProductInventoriesWithPreviousMonthCounts
ORDER BY 
        ProductName, 
        Month(InventoryDate);
GO
*/

-- Create the new vProductInventoriesWithPreviousMonthCountsWithKPIs view
GO
CREATE
VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs
	AS 
		SELECT TOP 1000000000
            ProductName,
            InventoryDate,
            InventoryCount,
            PreviousMonthCount,
            CASE 
                WHEN InventoryCount > PreviousMonthCount THEN 1
                WHEN InventoryCount = PreviousMonthCount THEN 0
                WHEN InventoryCount < PreviousMonthCount THEN -1
            END
                AS CountVsPreviousCountKPI
        FROM 
            vProductInventoriesWithPreviousMonthCounts
        ORDER BY 
            ProductName, 
            Month(InventoryDate);
GO

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
SELECT * FROM vProductInventoriesWithPreviousMonthCountsWithKPIs;
GO

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --

-- Inspect the view
-- SELECT * FROM vProductInventoriesWithPreviousMonthCountsWithKPIs;
-- GO

-- Create a UDF table function that will return a table based on the KPI value entered in the parameters
GO
CREATE FUNCTION fProductInventoriesWithPreviousMonthCountsWithKPIs(@KPI int)
    RETURNS TABLE
        AS
            RETURN
            (SELECT TOP 1000000000 
                ProductName,
                InventoryDate,
                InventoryCount,
                PreviousMonthCount,
                CountVsPreviousCountKPI
            FROM
                vProductInventoriesWithPreviousMonthCountsWithKPIs
            WHERE
                CountVsPreviousCountKPI = @KPI
            ORDER By
                ProductName,
                Month(InventoryDate));
GO


-- Check that it works:
SELECT * FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
SELECT * FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
SELECT * FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
GO

/***************************************************************************************/
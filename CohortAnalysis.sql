---Cleaning Data

---Total Records = 541909
---135080 Records have no customerID
---406829 Records have customerID

;WITH online_retail as
(

	SELECT [InvoiceNo]
		  ,[StockCode]
		  ,[Description]
		  ,[Quantity]
		  ,[InvoiceDate]
		  ,[UnitPrice]
		  ,[CustomerID]
		  ,[Country]
	  FROM [PortfolioProject].[dbo].[online_retail]
	  WHERE CustomerID IS NOT NULL
)

, quantity_unit_price as

(

---397882 records with Quantity and UnitPrice

	SELECT*
	FROM online_retail
	WHERE Quantity > 0 and UnitPrice > 0
)
, dup_check as
(
	---Duplicate check
	SELECT * , ROW_NUMBER() 
	OVER (partition by InvoiceNo, StockCode, Quantity
	ORDER BY InvoiceDate) dup_flag
	FROM quantity_unit_price

)
---392669 records of clean data
---5215 duplicate records
---pass into a temp table so that I don't have to call entire code
SELECT *
INTO #online_retail_main
FROM dup_check
WHERE dup_flag = 1

---CLEAN DATA
---BEGIN COHORT ANALYSIS

SELECT *
FROM #online_retail_main

---Create a cohort of initial customer purchases to test retention rate
---Unique Identifier (CustomerID)
---Initial Start Date (First Invoice Date)
---Revenue Data

SELECT
	CustomerID,
	min(InvoiceDate) first_purchase_date,
	DATEFROMPARTS(year(min(InvoiceDate)), month(min(InvoiceDate)), 1) Cohort_Date
INTO #cohort
FROM #online_retail_main
GROUP BY CustomerID

---This is a time-based cohort based on customers first online purchase date (month/year)

SELECT *
FROM #cohort

---Create Cohort Index (number of months since customer's first engagement)
---Need to join both temp tables to include the cohort date and the invoice date
---Then find the time lapsed between the first invoice date and the cohort date

SELECT
	mmm.*,
	cohort_index = year_dif * 12 + month_dif + 1   ---converts years to month, add 1 to have cohort index start at 1, not 0
INTO #cohort_retention
FROM
	(
		SELECT
			mm. *,
			year_dif = invoice_year - cohort_year,
			month_dif = invoice_month - cohort_month
		FROM 
			(
				SELECT
					m.*,
					c.Cohort_Date,
					year(m.InvoiceDate) invoice_year,
					month(m.InvoiceDate) invoice_month,
					year(c.Cohort_Date) cohort_year,
					month(c.Cohort_Date) cohort_month
				FROM #online_retail_main m
				left join #cohort c
					on m.CustomerID = c.CustomerID
			)mm
	)mmm

---How many cohorts are there in all? (13)

SELECT DISTINCT
	cohort_index
FROM #cohort_retention


---Pivot Data to see the cohort table
---How many customers returned in next month, etc.? (1 = month of first purchase)
SELECT *
INTO #cohort_pivot ---temp table 
FROM 
(
	SELECT DISTINCT
		CustomerID,
		Cohort_Date,
		cohort_index
	FROM #cohort_retention
)tbl
pivot(
	COUNT(CustomerID)
	for Cohort_Index In
		(
		[1],
		[2],
		[3],
		[4],
		[5],
		[6],
		[7],
		[8],
		[9],
		[10],
		[11],
		[12],
		[13])

)as pivot_table

SELECT *
FROM #cohort_pivot
ORDER BY Cohort_Date

---In ratio format

SELECT Cohort_Date , 
	1.0 * [1]/[1] * 100 as [1],
	1.0 * [2]/[1] * 100 as [2],
	1.0 * [3]/[1] * 100 as [3],
	1.0 * [4]/[1] * 100 as [4],
	1.0 * [5]/[1] * 100 as [5],
	1.0 * [6]/[1] * 100 as [6],
	1.0 * [7]/[1] * 100 as [7],
	1.0 * [8]/[1] * 100 as [8],
	1.0 * [9]/[1] * 100 as [9],
	1.0 * [10]/[1] * 100 as [10],
	1.0 * [11]/[1] * 100 as [11],
	1.0 * [12]/[1] * 100 as [12],
	1.0 * [13]/[1] * 100 as [13]
FROM #cohort_pivot
ORDER BY Cohort_Date





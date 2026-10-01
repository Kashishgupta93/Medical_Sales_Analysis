-- convert date  +time (Date) column to dateonly column that only contains date
ALTER TABLE medicaldata
ADD COLUMN Date_only DATE; 

-- Assign date into date_only from date column
UPDATE medicaldata
SET Date_only="Date"::DATE;

-- Verify the table 
SELECT *
FROM medicaldata;

-- Count total record
SELECT COUNT(*) FROM medicaldata;

-- How many different medicines
SELECT COUNT(DISTINCT "Medicine_Name") AS unique_medicines
FROM medicaldata;

-- Find out name of all distinct medicines
SELECT DISTINCT("Medicine_Name") from medicaldata;

-- How many distinct category
SELECT COUNT(DISTINCT "Category") AS unique_category
FROM medicaldata;

-- find out all distinct category name
SELECT DISTINCT("Category") FROM medicaldata;

-- What payment method used
SELECT DISTINCT("Payment_Mode") FROM medicaldata;

-- count how many no of people used different payment mode (
-- how many for by upi,cash,card
SELECT "Payment_Mode",COUNT("Invoice_No")
FROM medicaldata
GROUP BY "Payment_Mode";

-- Check missing medicine name
SELECT * FROM medicaldata
WHERE "Medicine_Name" IS NULL;

-- Check missing categories
SELECT * FROM medicaldata
WHERE "Category" IS NULL;

-- Check invalid quantities
SELECT "Quantity_Sold" FROM medicaldata
WHERE "Quantity_Sold"<=0;

-- Check invalid prices
SELECT * FROM medicaldata 
WHERE "Unit_Price" <=0;

-- What is the total revenue?
SELECT ROUND(SUM("Net_Sales_Before_GST")::numeric,2) AS revenue
FROM medicaldata;

-- How many units were sold?
SELECT ROUND(SUM("Quantity_Sold")::numeric,2) As Toatal_unitSold
FROM medicaldata;

-- How many bills/transactions were generated?
SELECT COUNT(DISTINCT("Invoice_No")) AS total_bills
FROM medicaldata;

-- What is the average bill value?
SELECT ROUND(SUM("Net_Sales_Before_GST")::numeric/
COUNT(DISTINCT("Invoice_No")),2) as avg_bill
FROM medicaldata;

-- Which medicines are selling the most?
SELECT "Medicine_Name",SUM("Quantity_Sold") as unit_sold
FROM medicaldata GROUP BY "Medicine_Name"
ORDER BY unit_sold DESC;

--which medicines generating the most revenue?
SELECT "Medicine_Name",ROUND(SUM("Net_Sales_Before_GST")::numeric,2) as revenue
FROM medicaldata GROUP BY "Medicine_Name"
ORDER BY revenue DESC;

-- Revenue by category
SELECT "Category",ROUND(SUM("Net_Sales_Before_GST")::numeric,2) as revenue
FROM medicaldata GROUP BY "Category"
ORDER BY revenue DESC;

-- Units sold by category
SELECT "Category",SUM("Quantity_Sold") as total_unit
FROM medicaldata GROUP BY "Category"
ORDER BY total_unit DESC;

-- Inwhich month highest revenue
SELECT "Month",ROUND(SUM("Net_Sales_Before_GST")::numeric,2)
as monthly_revenue FROM medicaldata
GROUP BY "Month" ORDER BY monthly_revenue DESC;


-- Daily revenue
SELECT date_only ,ROUND(SUM("Net_Sales_Before_GST")::numeric,2) AS daily_revenue
FROM medicaldata GROUP BY date_only
ORDER BY  daily_revenue DESC;

-- Which payment method is used most frequently 
-- / generates the most billed amount?
SELECT
    "Payment_Mode",
    ROUND(SUM("Total_Bill")::numeric,2) AS total_amount
FROM medicaldata
GROUP BY "Payment_Mode"
ORDER BY total_amount DESC;

-- How much discount was given ?
SELECT SUM("Discount") as total_discount
FROM medicaldata;

-- Which categroy recieve highest discount?
SELECT "Category" ,SUM("Discount") as total_dis
FROM medicaldata GROUP BY "Category" 
ORDER BY total_dis DESC;

-- Which medicines generated more than ₹10,000 revenue?
SELECT
    "Medicine_Name",
    SUM("Net_Sales_Before_GST") AS revenue
FROM medicaldata
GROUP BY "Medicine_Name"
HAVING SUM("Net_Sales_Before_GST") > 10000
ORDER BY revenue DESC;

-- Which medicines generated more than ₹10,000 revenue?(by using CTE)
WITH medicine_sales AS (
    SELECT
        "Medicine_Name",
        SUM("Net_Sales_Before_GST") AS revenue
    FROM medicaldata
    GROUP BY "Medicine_Name"
)
SELECT *
FROM medicine_sales
WHERE revenue > 10000
ORDER BY revenue DESC;

-- transactions based on bill amount
SELECT
    "Invoice_No",
    "Total_Bill",
    CASE
        WHEN "Total_Bill" < 500 THEN 'Low'
        WHEN "Total_Bill" < 1000 THEN 'Medium'
        ELSE 'High'
    END AS bill_category
FROM medicaldata;

-- window function to rank medicines based on their revenue contribution
SELECT
    "Medicine_Name",
    ROUND(SUM("Net_Sales_Before_GST")::numeric,2) AS revenue,
    RANK() OVER (
        ORDER BY ROUND(SUM("Net_Sales_Before_GST")::numeric,2) DESC
    ) AS revenue_rank
FROM medicaldata
GROUP BY "Medicine_Name";

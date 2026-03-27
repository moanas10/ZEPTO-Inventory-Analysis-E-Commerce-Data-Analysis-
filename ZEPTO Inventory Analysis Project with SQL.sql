drop table if exists zepto;

CREATE TABLE zepto (
  sku_id SERIAL PRIMARY KEY,
  category VARCHAR(120),
  name VARCHAR(150) NOT NULL,
  mrp NUMERIC(8,2),
  discountPercent NUMERIC(5,2),
  availableQuantity INTEGER,
  discountedSellingPrice NUMERIC(8,2),
  weightInGms INTEGER,
  outOfStock BOOLEAN,
  quantity INTEGER
);

SELECT * FROM zepto
LIMIT 10;

-- Data Exploration --

-- Lets Check if all rows were improted
SELECT COUNT(*) FROM zepto;
-- Lets see f we have any NULL values
SELECT * FROM zepto
WHERE name IS NULL
OR
category IS NULL
OR
mrp IS NULL
OR
discountPercent IS NULL
OR
discountedSellingPrice IS NULL
OR
weightInGms IS NULL
OR
availableQuantity IS NULL
OR
outOfStock IS NULL
OR
quantity IS NULL;
-- Different Product Categories
SELECT DISTINCT category
FROM zepto
ORDER BY category;
-- In Stock vs Out of Stock Products
SELECT outofstock, COUNT(sku_id)
FROM zepto
GROUP BY outofstock;
-- Check for all unique product names
SELECT name, COUNT(sku_id) as "Number of SKUs"
FROM zepto
GROUP BY name
HAVING COUNT(sku_id) > 1;


-- Data Cleaning --

-- Lets check if incase we hve any products with price=0 which should not be possible
SELECT * FROM zepto
WHERE mrp = 0 OR discountedsellingprice = 0;

DELETE FROM zepto
WHERE mrp = 0;

-- Prices in paise is a bit confusing. Lets convert all values in mrp to actual currency: Rupees
UPDATE zepto
SET mrp = mrp/100.0, discountedsellingprice = discountedsellingprice/100.0;


-- Here is the FUN PART:  Business Analysis for extracting useful business insights --

-- Q1. Find the top 10 best-value products based on the discount percentage.
SELECT DISTINCT name, category, mrp, discountedsellingprice, discountpercent
FROM zepto
ORDER BY discountpercent DESC
LIMIT 10;

-- Q2. What are the Products with High MRP but Out of Stock
SELECT DISTINCT name, category, mrp, outofstock
FROM zepto
WHERE outofstock = TRUE
ORDER BY mrp DESC;

-- Q3. Calculate Estimated Revenue for each category
SELECT category, SUM(discountedsellingprice * quantity) AS estimated_revenue
FROM zepto
GROUP BY category
ORDER BY estimated_revenue;

-- Q4. Find all products where MRP is greater than ₹500 and discount is less than 10%
SELECT DISTINCT name, mrp, discountpercent
FROM zepto
WHERE mrp > 500 AND discountpercent < 10.00
ORDER BY mrp DESC, discountpercent DESC;

-- Q5. Identify the top 5 categories offering the highest average discount percentage
SELECT category, ROUND(AVG(discountpercent),2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

-- Q6. Find the price per gram for products above 100g and sort by best value.
SELECT DISTINCT name, discountedsellingprice, weightingms, 
	   ROUND(discountedsellingprice/weightingms,2) AS price_per_gram
FROM zepto
WHERE weightingms > 100
ORDER BY price_per_gram;

-- Q7. Group the products into categories like Low, Medium, Bulk.
SELECT DISTINCT name, weightingms,
CASE WHEN weightingms < 1000 THEN 'Low'
	 WHEN weightingms < 5000 THEN 'Medium'
	 ELSE 'Bulk' END AS weight_category
FROM zepto;

-- Q8. What is the Total Inventory Weight Per Category
SELECT 
  category,
  SUM(weightInGms * availablequantity) AS total_weight
FROM zepto
WHERE outOfStock = FALSE
GROUP BY category;
